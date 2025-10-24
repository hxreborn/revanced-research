# ReVanced Patch Development Runbook

> **Single Source of Truth**: Feature READMEs (`apps/<app>/features/<feature>/README.md`) contain all research findings, technical details, and validation results. This runbook describes the procedures to produce those findings. Always reference the feature README for current status.

## **Repository Structure**
```bash
revanced-research/
├── README.md                    # Main documentation + status
├── WORKFLOW.md                  # This runbook
├── apps/
│   └── <app>/
│       ├── features/
│       │   └── <feature>/
│       │       ├── README.md                    # Consolidated feature doc (all sections)
│       │       ├── 36.5.4/
│       │       │   ├── smali-tests/            # Smali test builds
│       │       │   └── logs/                   # Test run logs
│       │       └── 36.6.0/
│       │           ├── smali-tests/
│       │           └── logs/
│       └── apks/
│           ├── 36.5.4/
│           │   ├── base.apk
│           │   ├── base.apk.sha256
│           │   ├── base.apk.info
│           │   ├── apktool/                    # apktool decompilation output
│           │   └── jadx/                       # JADX decompilation output
│           └── 36.6.0/
│               ├── base.apk
│               └── ...
└── revanced-src/
    ├── revanced-patches/        # Submodule (forked)
    └── revanced-cli.jar         # CLI tool
```

**For concrete examples**, see `apps/tiktok/features/share-url-sanitization/README.md` - complete feature research with all sections.

---

## **Mission Statement**
Ship a working ReVanced patch using proven Smali edits. Test everything in raw Smali first, then port to ReVanced. Document every attempt to avoid circles.

---

## **Documentation Guidelines**

**Single source of truth per feature**: `apps/<app>/features/<feature>/README.md`

This README consolidates:
- Summary (problem, solution, status)
- Version Map (tested versions, links)
- Technical Reference (obfuscation mappings, injection points, fingerprints)
- Validation (test matrices, results, logs)
- Timeline (phases, decisions, rationale)
- References (related resources)

Supporting files (for organization only):
- `apps/<app>/features/<feature>/<version>/smali-tests/` - Bytecode experiments and test APKs
- `apps/<app>/features/<feature>/<version>/logs/` - Device logs, CLI output, validation evidence
- `apps/<app>/features/<feature>/<version>/obfuscation-map.md` - Deobfuscation findings (referenced from README)
- `apps/<app>/apks/<version>/` - Raw APK artifacts and decompilations

**Workflow:**
1. Create feature/version folder structure
2. Decompile APK into apks/<version>/{apktool,jadx}
3. Run smali experiments in features/<feature>/<version>/smali-tests/
4. Update feature README as you learn (status, findings, validation results)
5. Version-specific details go in: obfuscation-map.md, smali-tests/, logs/ (not separate top-level files)

---

## **Phase 0: Repository Setup**

One-time setup when adding a new APK and feature:

### 0.1 Create APK Storage

```bash
mkdir -p apps/<app>/apks/<version>/{apktool,jadx}
touch apps/<app>/apks/<version>/apktool/.gitkeep
touch apps/<app>/apks/<version>/jadx/.gitkeep

# Create metadata
sha256sum apps/<app>/apks/<version>/base.apk > apps/<app>/apks/<version>/base.apk.sha256
cat > apps/<app>/apks/<version>/base.apk.info << 'EOF'
Version: <VERSION>
Package: <PACKAGE_NAME>
Architecture: arm64-v8a, armeabi-v7a
Min SDK: <MIN_SDK>
Target SDK: <TARGET_SDK>
EOF
```

### 0.2 Create Feature Workspace

```bash
mkdir -p apps/<app>/features/<feature>/<version>/{smali-tests,logs}

# Create initial README with template sections
cat > apps/<app>/features/<feature>/README.md << 'EOF'
# <Feature Name> - <App>

## Summary
[Problem statement, solution approach, status]

## Version Map
[Table: version, status, links to smali-tests/, logs/, apk info]

## Technical Reference
[Obfuscation map, injection points, fingerprints]

## Validation
[Test matrix with results and log links]

## Timeline & Decisions
[Phase history with rationale]

## Next Steps & References
[TODOs and links]
EOF
```

---

## **Phase 1: Discovery**

Decompile APK and explore:

### 1.1 Decompile to APK storage

```bash
# apktool
apktool d -f apps/<app>/apks/<version>/base.apk -o apps/<app>/apks/<version>/apktool

# JADX
jadx apps/<app>/apks/<version>/base.apk -d apps/<app>/apks/<version>/jadx --deobf
```

### 1.2 Take temporary notes

As you search and find patterns, save scratch findings in:
```
apps/<app>/features/<feature>/notes.md  (temporary)
```

Later, consolidate these into the feature README's "Technical Reference" section.

---

## **Phase 2: Smali Testing**

When creating a new smali-test experiment:

```bash
# 1. Create test directory
TEST_NUM=01-my-experiment
cd apps/<app>/features/<feature>/<version>/smali-tests/$TEST_NUM
mkdir -p .

# 2. Extract target DEX and decompile
unzip -j ../../../../../apks/<version>/base.apk classes15.dex -d .
baksmali d classes15.dex -o smali-classes15/

# 3. Edit and document
vim smali-classes15/X/UEU.smali
# Add logging for verification, then:

# 4. Build and test
smali a smali-classes15/ -o classes15-patched.dex --api 35
cp ../../../../../apks/<version>/base.apk test.apk
zip -j test.apk classes15-patched.dex
zip -d test.apk "META-INF/*"
zipalign -f 4 test.apk test-aligned.apk
apksigner sign --ks ~/.android/debug.keystore --ks-pass pass:android test-aligned.apk
adb install -r test-aligned.apk
adb logcat -c
# ... trigger share action in app ...
adb logcat -d | tee ../logs/test-$TEST_NUM-$(date +%s).log
```

**Document results:** After testing, update feature README with outcome:
- Add injection point details to "Technical Reference" section
- Update register allocation table
- Add result row to "Validation" section with link to log file
- Note any register constraints or guard clauses learned

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

### 3.2 Create Extension Helper (Java)

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
    -o revanced-build-test.apk \
    -e "Your patch name" \
    apps/<app>/apks/<version>/base.apk

# Install and test
adb install -r revanced-build-test.apk
adb logcat -c
# Trigger feature
adb logcat -d | tee apps/<app>/features/<feature>/<version>/logs/revanced-test-$(date +%s).log

# Save CLI output
sha256sum revanced-build-test.apk
```

### 3.6 Document Results

Update feature README with ReVanced validation:

```bash
# 1. Add to "Validation" section of feature README
# - Add row: "ReVanced build | Gradle + CLI | Passed | [log link]"
# - Note fingerprint matched, patch applied, no errors

# 2. Add to "Implementation" subsection (if new)
# - Link to extension: revanced-src/revanced-patches/extensions/...
# - Link to patch: revanced-src/revanced-patches/patches/...
# - Note versions tested, fingerprints used

# 3. Commit
git add apps/<app>/features/<feature>/README.md \
        apps/<app>/features/<feature>/<version>/logs/*.log \
        apps/<app>/apks/<version>/base.apk.sha256 \
        apps/<app>/apks/<version>/base.apk.info
git commit -m "docs(<feature>): validate ReVanced port for <version>"
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
- Forgetting `:patches:apiDump` → build fails with API mismatch
- Hardcoding registers (v1, v2) → breaks if code changes
- Missing `local.properties` → extension build fails
- Extract registers dynamically from instructions
- Use descriptive patch names (used in CLI `-e` flag)

---

## **Phase 2 Alternative: Targeted DEX Pipeline** (Large APKs)

**Use this when**: Full `apktool b` rebuilds cause OOM errors or bloat APK size (379 MB → 631 MB).
**Benefit**: Surgical patch deployment, preserves original APK size and resources.

### 2A.1 Extract Target DEX Shard

```bash
cd apps/<app>/features/<feature>/<version>/smali-tests/01-canonical-url

# Extract only the target DEX shard (e.g., classes15 for X/UEU.smali)
unzip -j ../../../../../apks/<version>/base.apk classes15.dex -d .

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
cp ../../../../../apks/<version>/base.apk patched-working.apk

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
adb logcat -d | tee ../logs/targeted-dex-01-canonical-$(date +%Y%m%d-%H%M%S).log | grep "REVANCED_CANONICAL"
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
cd apps/<app>/features/<feature>/<version>/smali-tests/01-canonical-url

# Edit target method
vim smali-classes15/X/UGk.smali  # or other target file

# Compile + Inject + Sign + Install
SMALI_THREADS=1 /usr/lib/jvm/java-11-openjdk/bin/java -Xms2G -Xmx16G \
  -jar /usr/share/java/smali/smali.jar assemble smali-classes15 \
  -o classes15-patched.dex --api 35 && python3 -c "
import zipfile, os
os.system('cp ../../../../../apks/<version>/base.apk temp.apk')
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

// Based on: revanced-research/apps/<app>/features/<feature>/<version>/smali-tests/ and feature README
// LJIJJ Method - Share extras builder
internal object LjijjBundleFingerprint : MethodFingerprint(
    returnType = "Landroid/os/Bundle;",
    parameters = listOf("Ljava/lang/String;", "Landroid/content/Context;"),
    strings = listOf(
        "share_url"  // Verified at line 423 in smali test
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

java -jar revanced-src/revanced-cli.jar patch \
    --patch "Clean share URLs - Stage 1" \
    --merge revanced-src/revanced-integrations.apk \
    --out stage1-test.apk \
    apps/<app>/apks/<version>/base.apk

adb install -r stage1-test.apk
adb logcat -c
# Test share
adb logcat -d | tee apps/<app>/features/<feature>/<version>/logs/stage1-test.log | grep "STAGE1"

# Update feature README "Validation" section with result
# Note: "Stage 1 - LJIJJ Only - Passed"
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
cd ../..

java -jar revanced-src/revanced-cli.jar patch \
    --patch "Clean share URLs" \
    --merge revanced-src/revanced-integrations.apk \
    --out stage2-test.apk \
    apps/<app>/apks/<version>/base.apk

adb install -r stage2-test.apk
adb logcat -c
# Test share
adb logcat -d | tee apps/<app>/features/<feature>/<version>/logs/stage2-test.log | grep -E "LJIJJ|LJFF"

# Update feature README "Validation" section
# Note: "Stage 2 - Both Methods - Passed"
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
# When adding new version (36.6.0, etc):
# 1. Create feature/<feature>/36.6.0/{smali-tests,logs}
# 2. Create apks/36.6.0/ with base.apk, metadata
# 3. Repeat Phase 2 (Smali testing)
# 4. Update feature README Version Map with results
# 5. Test ReVanced patch with new version

java -jar revanced-src/revanced-cli.jar patch \
    -p revanced-src/revanced-patches/patches/build/libs/patches-*.rvp \
    -o test-36.6.0.apk \
    -e "Your patch name" \
    apps/<app>/apks/36.6.0/base.apk

adb install -r test-36.6.0.apk
adb logcat -c
# Test and capture results
adb logcat -d | tee apps/<app>/features/<feature>/36.6.0/logs/revanced-test.log

# Update feature README with 36.6.0 row in Version Map + Validation table
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
git add apps/<app>/features/<feature>/<version>/smali-tests/
git commit -m "test(<feature>): validate Smali injection for <version>"

# After updating feature documentation
git add apps/<app>/features/<feature>/README.md
git commit -m "docs(<feature>): update validation and technical reference for <version>"

# When adding or updating the raw APK
git add apps/<app>/apks/<version>/
git commit -m "chore(apk): add <app> <version> base artifact and metadata"

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

1. `apps/<app>/features/<feature>/README.md` - Consolidated feature documentation (6 sections)
2. `apps/<app>/features/<feature>/<version>/smali-tests/` - Validated Smali experiments
3. `apps/<app>/features/<feature>/<version>/logs/` - Test execution evidence
4. `apps/<app>/apks/<version>/` - Base APK, metadata, decompilations
5. `revanced-src/revanced-patches/` - Working ReVanced patch (submodule)
6. `attempt-history.md` - Global status and links to features

---

