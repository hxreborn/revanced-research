# ReVanced Patch Development Runbook

## **Repository Structure**
```bash
revanced-research/
├── README.md                    # This runbook (main documentation)
├── attempt-history.md           # Global attempt tracker
├── apps/
│   └── tiktok/
│       ├── 36.5.4/
│       │   ├── base.apk                # Original APK
│       │   ├── obfuscation-map.md      # Obfuscated class mappings
│       │   ├── injection-points.md     # Confirmed injection points
│       │   ├── decompiled-jadx/        # JADX decompilation output
│       │   ├── decompiled-smali/       # Smali decompilation output
│       │   ├── smali-tests/            # Smali test builds
│       │   ├── revanced-builds/        # ReVanced test builds
│       │   └── logs/                   # Test run logs
│       └── 36.6.0/                     # Next version...
└── revanced-src/
    ├── revanced-patches/        # Submodule (forked)
    ├── revanced-integrations/   # Submodule (forked)
    └── revanced-cli.jar         # CLI tool
```

---

## **Mission Statement**
Ship a working ReVanced patch using proven Smali edits. Test everything in raw Smali first, then port to ReVanced. Document every attempt to avoid circles.

---

## **Phase 0: Repository Setup** (One-time)

### Initialize Structure
```bash
# Create main research repository (its revanced-research, this one)
mkdir rv-research && cd rv-research
git init

# Add ReVanced as submodules
git submodule add https://github.com/hxreborn/revanced-patches revanced-src/revanced-patches
git submodule add https://github.com/hxreborn/revanced-integrations revanced-src/revanced-integrations

# Download CLI
wget https://github.com/ReVanced/revanced-cli/releases/latest/download/revanced-cli.jar -O revanced-src/revanced-cli.jar

# Create documentation
cat > README.md << 'EOF'
# ReVanced Research Repository

## Purpose
Systematic approach to developing ReVanced patches with full documentation and testing.

## Structure
- `apps/`: Version-specific research and testing
- `revanced-src/`: ReVanced source code (submodules)
- `attempt-history.md`: Global tracking to avoid circles
EOF

cat > attempt-history.md << 'EOF'
# Global Attempt Tracker

| Date | App | Version | Target | Method | Result | Next |
|------|-----|---------|--------|--------|--------|------|
EOF

# Study successful patches for reference
cd revanced-src/revanced-patches
grep -r "BytecodePatch" src/ --include="*.kt" | head -20
cat src/main/kotlin/app/revanced/patches/youtube/misc/links/OpenLinksDirectlyPatch.kt
cat src/main/kotlin/app/revanced/patches/youtube/layout/hide/watermark/HideWatermarkPatch.kt
cd ../..

git add .
git commit -m "Initial rv-research structure"
```

---

## **Phase 1: Version-Specific Discovery**

### 1.1 Create App Version Workspace
```bash
# Set target
APP="tiktok"
VERSION="36.5.4"
APK_SHA="abc123..."

# Create structure
mkdir -p apps/$APP/$VERSION/{hotswap,patched,logs,indices}
cd apps/$APP/$VERSION

# Copy and verify APK
cp /path/to/base.apk .
sha256sum base.apk > APK_INFO.txt
echo "Version: $VERSION" >> APK_INFO.txt

# Decompile for research
apktool d -f base.apk -o decompiled-smali/
jadx base.apk --deobf -d decompiled-jadx/
```

### 1.2 Create Search Indices
```bash
# Build searchable indices
grep -r "share\|link\|url" decompiled-jadx/ > indices/strings.txt
grep -r "onClick\|button\|clip" decompiled-jadx/ > indices/handlers.txt
grep -r "Bundle\|Intent\|extras" decompiled-jadx/ > indices/bundles.txt
grep -r "copylink\|share_url\|utm_" decompiled-jadx/ > indices/specific.txt
```

### 1.3 Document Obfuscated Targets
```bash
cat > obfuscation-map.md << 'EOF'
# TikTok 36.5.4 - Obfuscated Class Mapping

## Confirmed Targets
| Obfuscated | Purpose | Method | Verified |
|------------|---------|--------|----------|
| Lcom/ss/android/ugc/aweme/share/improve/pkg/LinkSharePackage; | Share extras builder | a(Ljava/lang/String;Landroid/content/Context;)Landroid/os/Bundle; | ❓ |
| Lcom/ss/android/ugc/aweme/share/ShareServiceImpl; | URL generator | a(Lcom/ss/android/ugc/aweme/feed/model/Aweme;Ljava/lang/String;)Ljava/lang/String; | ❓ |

## Search Patterns That Worked
- "share_url" → Found in LinkSharePackage
- "copylink" → Found in clipboard handler
- "utm_source" → Found in URL builder
EOF
```

---

## **Phase 2: Smali Testing**

### 2.1 Create Smali Test
```bash
cd apps/$APP/$VERSION

# Create test iteration
TEST_NUM=01-ljijj-bundle
cp -r decompiled-smali/ smali-tests/$TEST_NUM/
cd smali-tests/$TEST_NUM/

# Edit target method
vim smali_classes3/com/ss/android/ugc/aweme/share/improve/pkg/LinkSharePackage.smali
```

### 2.2 Insert Test Code
```smali
# Find your injection point (e.g., after "const-string v3, share_url")
# INSERT:
    const-string v0, "HOTSWAP_TEST"
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "URL before: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    
    # Your actual modification (hardcoded for test)
    const-string v4, "https://vm.tiktok.com/CLEANED_TEST"
```

### 2.3 Build and Verify
```bash
# Build test APK
apktool b . -o ../$TEST_NUM.apk
cd ..
zipalign -v 4 $TEST_NUM.apk $TEST_NUM-aligned.apk
apksigner sign --ks ~/.android/debug.keystore --ks-pass pass:android $TEST_NUM-aligned.apk

# Install and test
adb install -r $TEST_NUM-aligned.apk
adb logcat -c
adb shell am start com.ss.android.ugc.trill/.main.MainActivity

# Trigger share action and capture logs
adb logcat -d | tee ../logs/smali-test-$TEST_NUM-$(date +%Y%m%d-%H%M%S).log | grep "HOTSWAP_TEST"
```

### 2.4 Document Results
```bash
cd ..
cat >> injection-points.md << 'EOF'
# Verified Injection Points - TikTok 36.5.4

## Test 01-ljijj-bundle - 2024-12-25
- **Target**: LinkSharePackage.a() line 423
- **Class**: Lcom/ss/android/ugc/aweme/share/improve/pkg/LinkSharePackage;
- **Method**: a(Ljava/lang/String;Landroid/content/Context;)Landroid/os/Bundle;
- **Injection**: After `const-string v3, "share_url"`
- **Registers**: v4 contains URL, v0-v2 free, .locals 8
- **Try blocks**: None at injection point
- **Result**: ✅ URL changed successfully
- **Log**: logs/smali-test-01-ljijj-bundle-20241225-150000.log

## What Worked
- String "share_url" exists at line 423
- Register v4 definitely contains the URL
- No try-catch conflicts
- Can safely use v0-v2 as temp registers
EOF

# Update targets
sed -i 's/❓/✅ Line 423/' obfuscation-map.md
```

---

## **Phase 3: Staged ReVanced Implementation**

### 3.1 Smali Validation
Before creating any ReVanced code, ensure your Smali modifications work perfectly:

```bash
cd apps/$APP/$VERSION

# Create smali-validated test with both LJIJJ and LJFF methods
cp -r decompiled-smali/ smali-tests/smali-validated/
cd smali-tests/smali-validated/

# Edit LJIJJ method (LinkSharePackage)
vim smali_classes3/com/ss/android/ugc/aweme/share/improve/pkg/LinkSharePackage.smali
# Add your URL cleaning logic after verification

# Edit LJFF method (ShareServiceImpl)
vim smali_classes3/com/ss/android/ugc/aweme/share/ShareServiceImpl.smali
# Add your URL cleaning logic after verification

# Build and test both modifications together
apktool b . -o ../smali-validated.apk
cd ..
zipalign -v 4 smali-validated.apk smali-validated-aligned.apk
apksigner sign --ks ~/.android/debug.keystore --ks-pass pass:android smali-validated-aligned.apk

# Verify both methods work
adb install -r smali-validated-aligned.apk
adb logcat -c
# Test sharing
adb logcat -d > ../logs/smali-validated-$(date +%Y%m%d-%H%M%S).log

# Document exactly what works
cd ..
echo "## Smali Validated - Both Methods" >> injection-points.md
echo "- LJIJJ: ✅ Works at line 423" >> injection-points.md
echo "- LJFF: ✅ Works at line 567" >> injection-points.md
echo "- Both together: ✅ No conflicts" >> injection-points.md
```

### 3.2 Stage 1: LJIJJ Method Only

Create fingerprint from verified code:

```bash
cd revanced-src/revanced-patches
git checkout -b feat/tiktok-clean-urls

mkdir -p src/main/kotlin/app/revanced/patches/tiktok/share/fingerprints/
cat > src/main/kotlin/app/revanced/patches/tiktok/share/fingerprints/LjijjBundleFingerprint.kt << 'EOF'
package app.revanced.patches.tiktok.share.fingerprints

import app.revanced.patcher.fingerprint.MethodFingerprint

// Based on: revanced-research/apps/tiktok/36.5.4/injection-points.md Test 01-ljijj-bundle
// LJIJJ Method - Share extras builder
internal object LjijjBundleFingerprint : MethodFingerprint(
    returnType = "Landroid/os/Bundle;",
    parameters = listOf("Ljava/lang/String;", "Landroid/content/Context;"),
    strings = listOf(
        "share_url"  // VERIFIED at line 423 in smali test
    )
)
EOF
```

Create patch for single method:

```kotlin
cat > src/main/kotlin/app/revanced/patches/tiktok/share/CleanShareUrlsPatch.kt << 'EOF'
package app.revanced.patches.tiktok.share

import app.revanced.patcher.data.BytecodeContext
import app.revanced.patcher.extensions.InstructionExtensions.addInstructions
import app.revanced.patcher.patch.BytecodePatch
import app.revanced.patcher.patch.annotation.CompatiblePackage
import app.revanced.patcher.patch.annotation.Patch
import app.revanced.patches.tiktok.share.fingerprints.LjijjBundleFingerprint
import app.revanced.util.exception

@Patch(
    name = "Clean share URLs - Stage 1",
    description = "Testing LJIJJ method only.",
    compatiblePackages = [CompatiblePackage("com.ss.android.ugc.trill")]
)
object CleanShareUrlsPatch : BytecodePatch(
    setOf(LjijjBundleFingerprint)  // Just one fingerprint
) {
    override fun execute(context: BytecodeContext) {
        // LJIJJ method only
        LjijjBundleFingerprint.result?.let { result ->
            val method = result.mutableMethod
            val insertIndex = result.scanResult.patternScanResult!!.endIndex

            method.addInstructions(
                insertIndex,
                """
                    const-string v0, "STAGE1"
                    const-string v1, "LJIJJ patch triggered"
                    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

                    invoke-static {v4}, Lapp/revanced/integrations/tiktok/patches/CleanSharePatch;->sanitizeUrl(Ljava/lang/String;)Ljava/lang/String;
                    move-result-object v4
                """
            )
        } ?: throw LjijjBundleFingerprint.exception
    }
}
EOF
```

Test Stage 1:

```bash
# Build and test
cd revanced-src/revanced-patches && ./gradlew build patches:buildAndroid
cd ../..

cd apps/$APP/$VERSION
java -jar ../../../revanced-src/revanced-cli.jar patch \
    --patch "Clean share URLs - Stage 1" \
    --merge ../../../revanced-src/revanced-integrations.apk \
    --out revanced-builds/stage1-ljijj-only.apk \
    base.apk

adb install -r revanced-builds/stage1-ljijj-only.apk
adb logcat -c
# Test share
adb logcat -d | grep "STAGE1"

# Document Stage 1 success
echo "## Stage 1: LJIJJ Only - ✅ Working" >> injection-points.md
```

### 3.3 Stage 2: Add LJFF Method

Only proceed after Stage 1 is confirmed working:

```bash
# Add second fingerprint
cat > src/main/kotlin/app/revanced/patches/tiktok/share/fingerprints/LjffBuilderFingerprint.kt << 'EOF'
package app.revanced.patches.tiktok.share.fingerprints

import app.revanced.patcher.fingerprint.MethodFingerprint

// LJFF Method - URL builder
internal object LjffBuilderFingerprint : MethodFingerprint(
    returnType = "Ljava/lang/String;",
    parameters = listOf(
        "Lcom/ss/android/ugc/aweme/feed/model/Aweme;",
        "Ljava/lang/String;"
    ),
    strings = listOf("getShareLinkShortenUrl")  // Verified in smali-validated test
)
EOF
```

Update patch to include both methods:

```kotlin
@Patch(
    name = "Clean share URLs",
    description = "Removes tracking parameters from share URLs.",
    compatiblePackages = [CompatiblePackage("com.ss.android.ugc.trill")]
)
object CleanShareUrlsPatch : BytecodePatch(
    setOf(
        LjijjBundleFingerprint,     // LJIJJ - Stage 1
        LjffBuilderFingerprint      // LJFF - Stage 2
    )
) {
    override fun execute(context: BytecodeContext) {
        // LJIJJ method
        LjijjBundleFingerprint.result?.let { result ->
            val method = result.mutableMethod
            val insertIndex = result.scanResult.patternScanResult!!.endIndex

            method.addInstructions(
                insertIndex,
                """
                    const-string v0, "LJIJJ"
                    const-string v1, "Cleaning in bundle method"
                    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

                    invoke-static {v4}, Lapp/revanced/integrations/tiktok/patches/CleanSharePatch;->sanitizeUrl(Ljava/lang/String;)Ljava/lang/String;
                    move-result-object v4
                """
            )
        } ?: throw LjijjBundleFingerprint.exception

        // LJFF method
        LjffBuilderFingerprint.result?.let { result ->
            val method = result.mutableMethod
            val returnIndex = method.implementation!!.instructions.size - 1

            method.addInstructions(
                returnIndex,
                """
                    const-string v1, "LJFF"
                    const-string v2, "Cleaning in builder method"
                    invoke-static {v1, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

                    invoke-static {v0}, Lapp/revanced/integrations/tiktok/patches/CleanSharePatch;->sanitizeUrl(Ljava/lang/String;)Ljava/lang/String;
                    move-result-object v0
                """
            )
        } ?: throw LjffBuilderFingerprint.exception
    }
}
```

Test Stage 2:

```bash
# Build and test with both methods
cd revanced-src/revanced-patches && ./gradlew build
cd ../../apps/$APP/$VERSION

java -jar ../../../revanced-src/revanced-cli.jar patch \
    --patch "Clean share URLs" \
    --merge ../../../revanced-src/revanced-integrations.apk \
    --out revanced-builds/stage2-both-methods.apk \
    base.apk

adb install -r revanced-builds/stage2-both-methods.apk
adb logcat -c
# Test share
adb logcat -d | grep -E "LJIJJ|LJFF"

# Both methods should log
echo "## Stage 2: Both Methods - ✅ Working" >> injection-points.md
```

### 3.4 Integration Helper

Create helper with aggressive logging initially:

```bash
cd revanced-src/revanced-integrations
mkdir -p app/revanced/integrations/tiktok/patches/
cat > app/revanced/integrations/tiktok/patches/CleanSharePatch.java << 'EOF'
package app.revanced.integrations.tiktok.patches;

import android.util.Log;

public class CleanSharePatch {
    private static final String TAG = "RV_CLEAN";
    
    public static String sanitizeUrl(String url) {
        // Aggressive logging for debugging
        Log.d(TAG, "sanitizeUrl called");
        Log.d(TAG, "Input type: " + (url == null ? "NULL" : url.getClass().getName()));
        Log.d(TAG, "Input value: " + (url == null ? "NULL" : url));
        
        if (url == null) {
            Log.w(TAG, "Received null URL, returning null");
            return null;
        }
        
        if (url.isEmpty()) {
            Log.w(TAG, "Received empty URL, returning empty");  
            return url;
        }
        
        try {
            String cleaned = url.replaceAll("[?&](utm_[^&]*|tt_[^&]*|enter_[^&]*)", "")
                                .replaceAll("[?&]$", "");
            
            Log.d(TAG, "Original: " + url);
            Log.d(TAG, "Cleaned: " + cleaned);
            
            return cleaned;
            
        } catch (Exception e) {
            Log.e(TAG, "Exception in sanitizeUrl, returning original", e);
            return url;
        }
    }
}
EOF
```

---

## **Phase 4: Common ReVanced Patterns Reference**

### 4.1 Pattern Library (Study from existing patches)
```kotlin
// Pattern 1: Simple string replacement (like HideWatermark)
addInstruction(index, "const-string v0, \"\"")

// Pattern 2: Boolean return (like HideAds) 
addInstructions(index, """
    const/4 v0, 0x0
    return v0
""")

// Pattern 3: Method replacement (like OpenLinksDirectly)
replaceInstruction(index, 
    "invoke-static {v0}, Lintegrations/Helper;->process(Ljava/lang/String;)Ljava/lang/String;"
)

// Pattern 4: Nop out calls (like DisableAutoplay)
replaceInstruction(index, "nop")

// Pattern 5: Hook with preservation (our approach)
addInstructions(index, """
    invoke-static {v4}, Lintegrations/Helper;->process(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v4
""")
```

### 4.2 Troubleshooting Decision Tree
```
Fingerprint not matching?
├─ Did hot-swap test pass? 
│  └─ No → Fix Smali first, don't touch ReVanced
├─ Are strings exact? 
│  └─ Check: grep -r "exact_string" jadx-out/
├─ Is return type correct?
│  └─ Check in jadx: Ctrl+F for method signature
├─ Try removing opcodes
│  └─ Keep only strings + returnType
└─ Try broader strings
   └─ "share" instead of "share_url"

Patch crashes app?
├─ Wrong register used?
│  └─ Check .locals N in method header
├─ Inside try-catch violation?
│  └─ Check .catch directives range
├─ Register clobbered?
│  └─ Use v5-v7 if v0-v4 taken
├─ Wide type issue?
│  └─ long/double need 2 registers (v6:v7)
└─ 35c/3rc compliance?
   └─ Use move-object/from16 for p0-p2

Can't find target in obfuscated code?
├─ Search by user-visible strings
│  └─ "Link copied", "Share", toast messages
├─ Search by Android APIs
│  └─ "ClipboardManager", "Intent.putExtra"
├─ Search by behavior
│  └─ Find R.id.share_button → trace onClick
├─ Use network strings
│  └─ API endpoints rarely change
└─ Check ReVanced's existing patches
   └─ Same app, different feature
```

---

## **Phase 5: Verification Protocol**

### 5.1 Test Checklist
```markdown
## Stage 1: Basic Function
- [ ] App launches without crash
- [ ] See "STAGE1" or "LJIJJ" in logs
- [ ] See "RV_CLEAN" → "sanitizeUrl called"  
- [ ] See "RV_CLEAN" → "Input value: https://..."
- [ ] See "RV_CLEAN" → "Cleaned: https://..." (no tracking params)

## Stage 2: Feature Test
- [ ] Share button → Share sheet appears
- [ ] Copy link → Link in clipboard
- [ ] Copied URL has no utm_*, tt_*, enter_*
- [ ] Share to WhatsApp → Clean URL sent
- [ ] Share to Twitter → Clean URL in tweet

## Stage 3: Edge Cases
- [ ] Share from profile page
- [ ] Share from sound page  
- [ ] Share from hashtag page
- [ ] Share while offline
- [ ] Share immediately after app launch
```

### 5.2 Update Global Tracker
```bash
cd ../../..
cat >> ATTEMPTS.md << 'EOF'
| 2024-12-25 | tiktok | 36.5.4 | URL clean | Hotswap test | ✅ Works | Create fingerprint |
| 2024-12-25 | tiktok | 36.5.4 | URL clean | Stage 1 LJIJJ | ✅ Matched | Add LJFF |
| 2024-12-25 | tiktok | 36.5.4 | URL clean | Stage 2 Both | ✅ Works | Production |
EOF
```

---

## **Phase 6: Production & Multi-Version**

### 6.1 Remove Debug Logging for Production
```java
// Production helper - minimal logging
public static String sanitizeUrl(String url) {
    if (url == null) return null;
    try {
        return url.replaceAll("[?&](utm_[^&]*|tt_[^&]*|enter_[^&]*)", "")
                  .replaceAll("[?&]$", "");
    } catch (Exception ignored) {
        return url;
    }
}
```

### 6.2 Test on Multiple Versions
```bash
# Test compatibility
for VERSION in 36.5.4 36.6.0 36.6.5; do
    cd apps/tiktok/$VERSION
    echo "Testing version $VERSION..."
    java -jar ../../../revanced-src/revanced-cli.jar patch \
        --patch "Clean share URLs" \
        --out revanced-builds/test.apk \
        base.apk 2>&1 | grep -E "(SUCCESS|FAILED|Exception)"
done
```

---

## **Success Factors**

1. **ALWAYS smali test first** - Never write ReVanced code until Smali edit is proven
2. **Document obfuscated names** - Map every `Lcom/a/b/c;->d` to its purpose
3. **Stage your integration** - One method at a time (LJIJJ first, then LJFF)
4. **Log aggressively initially** - Remove logs only after everything works
5. **Track every attempt** - Update attempt-history.md to avoid circles
6. **Follow ReVanced patterns** - Copy their style exactly

---

## **Git Workflow**

### Research Commits
```bash
# After successful smali test
git add apps/tiktok/36.5.4/
git commit -m "test(tiktok): verify LJIJJ injection on 36.5.4"

# After Stage 1 works (docs)
git add apps/tiktok/36.5.4/injection-points.md
git commit -m "docs(tiktok): add injection-points for stage 1 share URL FP"

# When adding or updating the raw APK
git add apps/tiktok/36.5.4/apk/
git commit -m "chore(apk): add TikTok 36.5.4 base artifact"

```

### Submodule Development
```bash
cd revanced-src/revanced-patches
git checkout -b feature/tiktok/sanitize-clean-url
git add -A
git commit -m "feat(tiktok): add share URL sanitizer"
git push -u origin feature/tiktok/sanitize-clean-url
```

### Update Parent Repository
```bash
cd ../..
git add revanced-src/revanced-patches
git commit -m "patches: update submodule for tiktok clean URLs"
git push
```

---

## **Deliverables**

1. ✅ `README.md` - This runbook
2. ✅ `apps/tiktok/VERSION/injection-points.md` - Proven injection points
3. ✅ `apps/tiktok/VERSION/obfuscation-map.md` - Class mappings
4. ✅ `attempt-history.md` - Global attempt tracker
5. ✅ Working ReVanced patch in submodule
6. ✅ Test APKs with verification logs

---

