# ReVanced Patch Development Runbook

## **Repository Structure**
```bash
revanced-research/
├── README.md                    # Main documentation + status
├── WORKFLOW.md                  # This runbook
├── CLAUDE.md                    # LLM agent instructions
├── AGENTS.md                    # Contributor guidelines
├── attempt-history.md           # Global attempt tracker
├── docs/
│   └── <app>/<version>/        # Per-target documentation (analysis, findings, phases)
├── apps/
│   └── <app>/<version>/
│       ├── base.apk                # Original APK
│       ├── decompiled-jadx/        # JADX decompilation output
│       ├── decompiled-smali/       # Smali decompilation output
│       ├── smali-tests/            # Smali test builds
│       ├── revanced-builds/        # ReVanced test builds
│       └── logs/                   # Test run logs
└── revanced-src/
    ├── revanced-patches/        # Submodule (forked)
    └── revanced-cli.jar         # CLI tool
```

**For concrete examples**, see `docs/tiktok/$VERSION/` - complete TikTok $VERSION share URL sanitizer research.

---

## **Mission Statement**
Ship a working ReVanced patch using proven Smali edits. Test everything in raw Smali first, then port to ReVanced. Document every attempt to avoid circles.

---

## **Documentation Guidelines**

**File Purpose & Boundaries:**
- `attempt-history.md` (app-specific): Discovery, implementation notes, test results
- `injection-points.md`: Technical details (registers, injection points, edge cases)
- `obfuscation-map.md`: Class mappings and method signatures
- `*-TEST-RESULTS.md`: Test validation evidence

**Rules:**
1. **Plan in existing files** - Use attempt-history.md for planning, don't create separate planning docs
2. **Professional tone** - No emojis, use [PASS]/[FAIL]/[SUPERSEDED] markers instead
3. **Update, don't duplicate** - If content exists elsewhere, link to it instead of copying
4. **Archive superseded work** - Don't delete failed attempts, move to "Archive" section
5. **Delete temporary artifacts** - Remove planning docs after implementation is documented

**File Lifecycle:**
```
Plan → (in attempt-history.md)
Implement → (document in injection-points.md)
Test → (results in *-TEST-RESULTS.md)
Cleanup → (consolidate, remove planning docs, archive superseded approaches)
```

---

## **Phase 2: Smali Testing**

**For initial repository setup, see `docs/bootstrap.md` (archived Phase 0).**

When creating a new smali-test experiment:

```bash
# 1. Create test directory
TEST_NUM=01-my-experiment
cd apps/$APP/$VERSION/smali-tests/$TEST_NUM

# 2. Extract target DEX and decompile
unzip -j ../../base.apk classes15.dex -d .
baksmali d classes15.dex -o smali-classes15/

# 3. Edit and document
vim smali-classes15/X/UEU.smali
# Add logging for verification, then:

# 4. Build and test
smali a smali-classes15/ -o classes15-patched.dex --api 35
cp ../../base.apk test.apk
zip -j test.apk classes15-patched.dex
zip -d test.apk "META-INF/*"
zipalign -f 4 test.apk test-aligned.apk
apksigner sign --ks ~/.android/debug.keystore --ks-pass pass:android test-aligned.apk
adb install -r test-aligned.apk
adb logcat -c
# ... trigger share action in app ...
adb logcat -d | tee ../../logs/test-$TEST_NUM-$(date +%s).log
```

**Document results:** After testing, update `injection-points.md` with outcome, log file location, and next steps.

---

## **Phase 3: ReVanced Patch Porting**

**Prerequisites**: Phase 2 Smali testing complete with validated patch

### 3.1 Review Existing Patches for House Style

```bash
cd revanced-src/revanced-patches

# Review TikTok patches to understand patterns
cat patches/src/main/kotlin/app/revanced/patches/tiktok/interaction/downloads/DownloadsPatch.kt
cat patches/src/main/kotlin/app/revanced/patches/tiktok/misc/settings/SettingsPatch.kt

# Key observations:
# - Uses bytecodePatch DSL (annotation-based, no JSON metadata)
# - dependsOn(sharedExtensionPatch) for TikTok
# - compatibleWith("$PACKAGE_NAME"("$VERSION"), ...)
# - Extension helpers in extensions/tiktok/src/main/java/
```

### 3.2 Create Feature Branch

```bash
cd revanced-src/revanced-patches
git checkout dev
git pull origin dev
git checkout -b feat/your-patch-name
```

### 3.3 Create Extension Helper (Java)

```bash
mkdir -p extensions/tiktok/src/main/java/app/revanced/extension/tiktok/yourfeature
```

Create helper class (example for URL sanitization):
```java
package app.revanced.extension.tiktok.yourfeature;

@SuppressWarnings("unused")
public final class YourHelper {
    public static String yourMethod(String input) {
        // Your logic here (matches Smali implementation)
        return cleanedResult;
    }
}
```

### 3.4 Create Fingerprint & Patch (Kotlin)

```bash
mkdir -p patches/src/main/kotlin/app/revanced/patches/tiktok/category/feature
```

**Fingerprints.kt**:
```kotlin
package app.revanced.patches.tiktok.category.feature

import app.revanced.patcher.fingerprint
import com.android.tools.smali.dexlib2.AccessFlags

internal val yourFingerprint = fingerprint {
    accessFlags(AccessFlags.PUBLIC, AccessFlags.STATIC, AccessFlags.FINAL)
    returns("LX/ReturnType;")
    parameters("I", "Ljava/lang/String;", ...)
    custom { method, classDef ->
        classDef.endsWith("/YourClass;") && method.name == "yourMethod"
    }
}
```

**YourPatch.kt**:
```kotlin
package app.revanced.patches.tiktok.category.feature

import app.revanced.patcher.extensions.InstructionExtensions.addInstructions
import app.revanced.patcher.patch.bytecodePatch
import app.revanced.patches.tiktok.misc.extension.sharedExtensionPatch
import app.revanced.util.getReference
import app.revanced.util.indexOfFirstInstructionOrThrow
import com.android.tools.smali.dexlib2.iface.instruction.OneRegisterInstruction
import com.android.tools.smali.dexlib2.iface.reference.MethodReference

@Suppress("unused")
val yourPatch = bytecodePatch(
    name = "Your patch name",
    description = "What it does",
) {
    dependsOn(sharedExtensionPatch)

    compatibleWith(
        "$PACKAGE_NAME"("$VERSION"),
        "com.zhiliaoapp.musically"("$VERSION"),
    )

    execute {
        yourFingerprint.method.apply {
            // Find injection point dynamically
            val targetIndex = indexOfFirstInstructionOrThrow {
                val ref = getReference<MethodReference>()
                ref?.definingClass == "LX/TargetClass;" && ref.name == "targetMethod"
            }

            // Extract register dynamically (safer than hardcoding)
            val moveResultIndex = targetIndex + 1
            val urlRegister = (implementation!!.instructions[moveResultIndex]
                as OneRegisterInstruction).registerA

            // Insert patch code
            addInstructions(
                moveResultIndex + 1,
                """
                    invoke-static {v$urlRegister}, Lapp/revanced/extension/tiktok/yourfeature/YourHelper;->yourMethod(Ljava/lang/String;)Ljava/lang/String;
                    move-result-object v$urlRegister
                """
            )
        }
    }
}
```

### 3.5 Build & Test

```bash
cd revanced-src/revanced-patches

# Configure Android SDK (first time only)
echo "sdk.dir=$HOME/Android/Sdk" > local.properties

# Build patches
./gradlew :patches:compileKotlin
./gradlew :extensions:tiktok:assembleRelease

# Update API declarations (required)
./gradlew :patches:apiDump

# Build final JAR
./gradlew :patches:build
# Output: patches/build/libs/patches-*.rvp

# Test with CLI
cd ../..  # back to research root
java -jar revanced-src/revanced-cli.jar patch \
    -p revanced-src/revanced-patches/patches/build/libs/patches-*.rvp \
    -o apps/$APP/$VERSION/revanced-builds/your-patch-aligned.apk \
    -e "Your patch name" \
    apps/$APP/$VERSION/base.apk

# Install and test
adb install -r apps/$APP/$VERSION/revanced-builds/your-patch-aligned.apk
adb logcat -c
# Trigger feature
adb logcat -d > apps/$APP/$VERSION/logs/revanced-test.log

# Capture APK hash
sha256sum apps/$APP/$VERSION/revanced-builds/your-patch-aligned.apk \
    > apps/$APP/$VERSION/revanced-builds/your-patch-aligned.apk.sha256
```

### 3.6 Document Results & Cleanup

Update research repo and clean up temporary artifacts:

```bash
# 1. Delete planning artifacts (if any were created during development)
rm apps/$APP/$VERSION/*-PLAN.md 2>/dev/null || true
rm apps/$APP/$VERSION/*-NOTES.md 2>/dev/null || true

# 2. Update core documentation files
# - attempt-history.md (root): Add Phase 7 entry to global tracker
# - attempt-history.md (app): Add Phase 7 section with implementation summary
# - injection-points.md: Update with final injection details (if changed from Smali)
# - *-TEST-RESULTS.md: Add ReVanced validation section

# Example for attempt-history.md (app-specific):
cat >> apps/$APP/$VERSION/attempt-history.md << 'EOF'
## Phase 7: ReVanced Port

**Date**: $(date +%Y-%m-%d)
**Branch**: feat/your-patch-name
**Status**: [SUCCESS]

### Implementation
- Extension: YourHelper.clean() (Java)
- Patch: yourPatch (Kotlin BytecodePatch)
- Register handling: Dynamic extraction

### Validation
- Build: [PASS]
- Runtime: [PASS]
- Behavior: Identical to Phase 6 Smali patch

### Files Created
- extensions/.../YourHelper.java
- patches/.../Fingerprints.kt
- patches/.../YourPatch.kt
EOF

# 3. Commit to research repo
git add apps/$APP/$VERSION/logs/*.log \
        apps/$APP/$VERSION/revanced-builds/*.sha256 \
        attempt-history.md \
        apps/$APP/$VERSION/attempt-history.md \
        apps/$APP/$VERSION/injection-points.md \
        apps/$APP/$VERSION/*-TEST-RESULTS.md
git commit -m "docs($APP): document ReVanced port validation for $VERSION"
```

**Consolidation checklist:**
- [ ] Planning documents deleted (none should remain after implementation)
- [ ] All cross-references updated and working
- [ ] Professional tone maintained (no emojis unless explicitly requested)
- [ ] Superseded approaches archived in "Archive" section, not deleted
- [ ] Test evidence captured in logs/ directory
- [ ] Build artifacts documented with SHA256 hashes only (no binaries in git)

### 3.7 Key Patterns

**Dynamic Register Extraction** (safer than hardcoding):
```kotlin
val moveResultInstruction = implementation!!.instructions[moveResultIndex]
val targetRegister = (moveResultInstruction as OneRegisterInstruction).registerA
```

**CLI Syntax**:
- `-p` for patches bundle (RVP file)
- `-e` for enable patch by name (exact match)
- `-o` for output APK path

**Common Pitfalls**:
- ❌ Forgetting `:patches:apiDump` → build fails with API mismatch
- ❌ Hardcoding registers (v1, v2) → breaks if code changes
- ❌ Missing `local.properties` → extension build fails
- ✅ Extract registers dynamically from instructions
- ✅ Use descriptive patch names (used in CLI `-e` flag)

---

## **Phase 2 Alternative: Targeted DEX Pipeline** (Recommended for Large APKs)

**Use this when**: Full `apktool b` rebuilds cause OOM errors or bloat APK size (379 MB → 631 MB).
**Benefit**: Surgical patch deployment, preserves original APK size and resources.

### 2A.1 Extract Target DEX Shard

```bash
cd apps/$APP/$VERSION/smali-tests/01-canonical-url

# Extract only the target DEX shard (e.g., classes15 for X/UEU.smali)
unzip -j ../../base.apk classes15.dex -d .

# Verify extraction
ls -lh classes15.dex
```

### 2A.2 Decompile DEX to Smali

```bash
# Use baksmali to decompile only the target shard
baksmali d classes15.dex -o smali-classes15/

# Verify target file exists
ls -lh smali-classes15/X/UEU.smali
```

### 2A.3 Apply Patch + Verification Logs

```bash
# Edit target smali file
vim smali-classes15/X/UEU.smali

# Find line ~150 (after parameter checks, before invoke-static LJII())
# PATCH: Force canonical URL path by setting v0 to 0 (false condition)
# Locate the section:
#   .line 67108881
#   const/4 v7, 0x1
#   invoke-static {}, LX/UhW;->LJII()Z
#   move-result v0

# Replace with:
#   const/4 v7, 0x1
#   const/4 v0, 0x0           # PATCH: Force canonical URL
#   const-string v2, "REVANCED_CANONICAL"
#   const-string v3, "Canonical URL patch active"
#   invoke-static {v2, v3}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
```

### 2A.4 Recompile to DEX

```bash
# Assemble patched smali back to DEX
smali a smali-classes15/ -o classes15-patched.dex

# Verify DEX creation
ls -lh classes15-patched.dex
```

### 2A.5 Inject DEX into Original APK

```bash
# Copy original APK to working version
cp ../../base.apk patched-working.apk

# Replace the DEX in the APK (use -j to only update the file)
zip -j patched-working.apk classes15-patched.dex

# Strip stale signature metadata (CRITICAL - prevents install failure)
zip -d patched-working.apk "META-INF/*"

# Verify structure
unzip -l patched-working.apk | grep -E "^.*classes15\.dex|^.*META-INF" | head -5
```

### 2A.6 Align & Sign APK

```bash
# Align APK to 4-byte boundary (required for installation)
zipalign -p -f 4 patched-working.apk patched-aligned.apk

# Sign with debug keystore
apksigner sign \
  --ks ~/.android/debug.keystore \
  --ks-pass pass:android \
  --out patched-tiktok-$VERSION.apk \
  patched-aligned.apk

# Verify signature is valid
apksigner verify patched-tiktok-$VERSION.apk
```

### 2A.7 Install & Test

```bash
# Install patched APK
adb install -r patched-tiktok-$VERSION.apk

# Clear logcat to see fresh logs
adb logcat -c

# Test share functionality:
# 1. Open TikTok
# 2. Find a video
# 3. Tap Share → WhatsApp (or other channel)
# 4. Observe URL in shared message (should be www.tiktok.com/@user/video/ID, NOT vm.tiktok.com/...)
# 5. Test copy to clipboard as well

# Capture verification logs
adb logcat -d | tee ../../logs/targeted-dex-01-canonical-$(date +%Y%m%d-%H%M%S).log | grep "REVANCED_CANONICAL"
```

### 2A.8 Troubleshooting

**APK install fails with INSTALL_PARSE_FAILED_NO_CERTIFICATES**:
- Verify you ran `zip -d` to remove META-INF/*
- Check APK signature: `apksigner verify patched-tiktok-$VERSION.apk`
- Rebuild if needed

**Patch didn't activate (no log line)**:
- Verify smali edit was applied correctly
- Check UEU.smali line ~150 has your patch
- Rebuild smali → DEX

**URL is still shortened**:
- Verify patch was actually injected into APK
- Check logcat for which methods are called during share
- Verify DEX was correctly injected into APK

### 2A.9 Quick Rebuild After Patch Changes

When debugging or modifying the smali patch, use this pipeline for rapid iteration:

```bash
cd apps/$APP/$VERSION/smali-tests/01-canonical-url

# Edit target method
vim smali-classes15/X/UGk.smali  # or other target file

# Compile + Inject + Sign + Install (one command)
SMALI_THREADS=1 /usr/lib/jvm/java-11-openjdk/bin/java -Xms2G -Xmx16G \
  -jar /usr/share/java/smali/smali.jar assemble smali-classes15 \
  -o classes15-patched.dex --api 35 && python3 -c "
import zipfile, os
os.system('cp ../../base.apk temp.apk')
with zipfile.ZipFile('temp.apk', 'r') as orig, \
     zipfile.ZipFile('patched.apk', 'w', zipfile.ZIP_STORED) as new:
    for item in orig.infolist():
        if item.filename != 'classes15.dex' and not item.filename.startswith('META-INF/'):
            new.writestr(item, orig.read(item.filename))
    with open('classes15-patched.dex', 'rb') as f:
        info = zipfile.ZipInfo('classes15.dex')
        info.compress_type = zipfile.ZIP_STORED
        new.writestr(info, f.read())
os.remove('temp.apk')
" && /home/rafa/Android/Sdk/build-tools/36.1.0/apksigner sign \
  --ks ~/.android/debug.keystore --ks-pass pass:android \
  --out patched-tiktok-$VERSION.apk patched.apk && \
adb shell am force-stop $PACKAGE_NAME && \
adb install -r patched-tiktok-$VERSION.apk && \
adb shell am start -n $PACKAGE_NAME/.MainActivity
```

---

### 3.2 Stage 1: LJIJJ Method Only

Create fingerprint from verified code:

```bash
cd revanced-src/revanced-patches
git checkout -b feat/tiktok-clean-urls

mkdir -p src/main/kotlin/app/revanced/patches/tiktok/share/fingerprints/
cat > src/main/kotlin/app/revanced/patches/tiktok/share/fingerprints/LjijjBundleFingerprint.kt << 'EOF'
package app.revanced.patches.tiktok.share.fingerprints

import app.revanced.patcher.fingerprint.MethodFingerprint

// Based on: revanced-research/apps/$APP/$VERSION/injection-points.md Test 01-ljijj-bundle
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
    compatiblePackages = [CompatiblePackage("$PACKAGE_NAME")]
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
    compatiblePackages = [CompatiblePackage("$PACKAGE_NAME")]
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
| 2024-12-25 | tiktok | $VERSION | URL clean | Hotswap test | ✅ Works | Create fingerprint |
| 2024-12-25 | tiktok | $VERSION | URL clean | Stage 1 LJIJJ | ✅ Matched | Add LJFF |
| 2024-12-25 | tiktok | $VERSION | URL clean | Stage 2 Both | ✅ Works | Production |
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
for VERSION in $VERSION 36.6.0 36.6.5; do
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
git add apps/$APP/$VERSION/
git commit -m "test(tiktok): verify LJIJJ injection on $VERSION"

# After Stage 1 works (docs)
git add apps/$APP/$VERSION/injection-points.md
git commit -m "docs(tiktok): add injection-points for stage 1 share URL FP"

# When adding or updating the raw APK
git add apps/$APP/$VERSION/apk/
git commit -m "chore(apk): add TikTok $VERSION base artifact"

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

