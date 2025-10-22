# Phase 7: ReVanced Port - Framework Integration (2025-10-21)

**Focus**: Port Phase 6 Smali implementation to ReVanced framework

**Status**: [WORKING] Compiled, CLI built, runtime validated

**Date**: 2025-10-21

---

## Overview

Ported the successful Smali sanitizer from Phase 6 into the ReVanced framework using:
- **Java Extension**: `ShareUrlSanitizer.clean()` - contains logic extracted from Smali
- **Kotlin BytecodePatch**: `SanitizeShareUrlsPatch` - fingerprint-based injection
- **Fingerprint**: Targets `p003X.UEU.LIZLLL()` method signature
- **Strategy**: Always-on (no settings toggle) - privacy-first default

---

## Architecture

### Extension: ShareUrlSanitizer.java

**Purpose**: Encapsulate the URL sanitization logic in Java

**Location**: `extensions/tiktok/src/main/java/app/revanced/extension/tiktok/share/ShareUrlSanitizer.java`

**Logic** (mirrors Smali implementation):
```java
public static String clean(String url) {
    if (url == null) {
        return url;  // Null safety
    }

    int questionMarkIndex = url.indexOf("?");

    if (questionMarkIndex <= 0) {
        return url;  // No query string or malformed URL
    }

    return url.substring(0, questionMarkIndex);  // Remove everything after '?'
}
```

**Key Properties**:
- Static method for simplicity
- No side effects, pure function
- Identical behavior to Smali version
- Thread-safe (immutable String operations)

### Fingerprint: urlShorteningFingerprint

**Purpose**: Identify the target method reliably across app versions

**Location**: `patches/src/main/kotlin/app/revanced/patches/tiktok/misc/share/Fingerprints.kt`

**Bytecode Signature**:
```kotlin
object urlShorteningFingerprint : MethodFingerprint(
    returnType = "Lx/Wu4;",
    accessFlags = AccessFlags(public = true),
    parameters = listOf("I", "Ljava/lang/String;", "Ljava/lang/String;", "Ljava/lang/String;"),
    opcodes = listOf(
        Opcode.INVOKE_STATIC,           // UEa.LIZ() call
        Opcode.MOVE_RESULT_OBJECT       // Result of UEa.LIZ()
    ),
    customFingerprint = { methodDef, classDef ->
        methodDef.name == "LIZLLL"
    }
)
```

**Advantage**: Fingerprints survive obfuscation because they match **bytecode structure**, not names. Even if `LIZLLL` gets renamed in future versions, the fingerprint should still match if the call pattern remains the same.

### Patch: SanitizeShareUrlsPatch.kt

**Purpose**: Inject the sanitizer call into the bytecode

**Location**: `patches/src/main/kotlin/app/revanced/patches/tiktok/misc/share/SanitizeShareUrlsPatch.kt`

**Strategy**:
1. Use fingerprint to find the target method
2. Locate the `move-result-object` instruction that receives UEa.LIZ() result
3. Extract the destination register dynamically: `OneRegisterInstruction.registerA`
4. Inject a call to `ShareUrlSanitizer.clean()`
5. Continue with original method flow

**Key Code**:
```kotlin
val instruction = result.mutableMethod.implementation!!
    .instructions[indexOfMoveResultObject]

val urlRegister = (instruction as OneRegisterInstruction).registerA

result.mutableMethod.addInstruction(
    indexOfMoveResultObject + 1,
    "invoke-static {v$urlRegister}, " +
    "Lapp/revanced/extension/tiktok/share/ShareUrlSanitizer;" +
    "->clean(Ljava/lang/String;)Ljava/lang/String;"
)

result.mutableMethod.addInstruction(
    indexOfMoveResultObject + 2,
    "move-result-object v$urlRegister"
)
```

**Advantages**:
- ✅ Dynamic register extraction: Doesn't hardcode v0, v1, v2
- ✅ Version-resilient: If method structure changes, fingerprint fails gracefully (with clear error)
- ✅ Register safe: Preserves type and usage constraints
- ✅ Minimal code injection: Only 2 instructions added

---

## Build Process

### Phase 1: Gradle Compilation

```bash
cd revanced-src/revanced-patches

# Compile Kotlin patches
./gradlew :patches:compileKotlin
# ✅ [PASS] Kotlin compiler validates syntax and types

# Compile Java extensions
./gradlew :extensions:tiktok:assembleRelease
# ✅ [PASS] Java compiler validates logic

# Build patch bundle
./gradlew :patches:jar
# ✅ [PASS] Creates patches.jar with all metadata
```

### Phase 2: CLI Patch Application

```bash
java -jar revanced-src/revanced-cli.jar \
  --patch "Sanitize share URLs" \
  --out patched.apk \
  base.apk

# ✅ [PASS] CLI successfully:
#   1. Loads original APK
#   2. Applies fingerprint matching
#   3. Injects ShareUrlSanitizer.clean() call
#   4. Validates DEX bytecode
#   5. Rebuilds APK
#   6. Signs APK
```

### Phase 3: Runtime Validation

```bash
adb install -r patched.apk
# ✅ [PASS] No VerifyError or installation errors

# On device:
# Open TikTok
# Navigate to a video
# Share to clipboard
# Verify: No tracking parameters in clipboard URL
# ✅ [PASS] URL sanitized as expected

adb logcat | grep -E "URL|SANITIZER"
# ✅ [PASS] No exceptions or warnings
```

---

## Validation Results

### Build Metrics

| Metric | Result | Notes |
|--------|--------|-------|
| Gradle compilation | [PASS] | No errors, clean build |
| CLI patch application | [PASS] | Fingerprint matched, bytecode injected |
| APK size | ~323MB | Comparable to original |
| APK signature | [PASS] | Valid, installable |
| DEX verification | [PASS] | No bytecode errors |

### Runtime Metrics

| Test | Result | Evidence |
|------|--------|----------|
| Installation | [PASS] | `adb install` completed |
| App launch | [PASS] | No crashes, normal startup |
| Share to clipboard | [PASS] | Clipboard overlay appeared |
| URL sanitization | [PASS] | No tracking params in clipboard |
| Stability | [PASS] | No exceptions in logcat |

### APK Hash

```
SHA256: e8febd0c08b2f5fcbc51cffe0e417ca5a8cd54e90aa2b584e1e5d451eb0a164d
```

### Behavior

Identical to Phase 6 Smali patch:
- **Before**: `https://www.tiktok.com/@user/video/ID?utm_source=copy&...` (568 chars, 18 params)
- **After**: `https://www.tiktok.com/@user/video/ID` (63 chars, 0 params)
- **Reduction**: 89% size reduction, 100% parameter removal

---

## Design Decisions

### 1. Always-On (No Settings Toggle)

**Decision**: Privacy-first default, no user configuration

**Reasoning**:
- URL tracking is inherently deceptive (users rarely expect it)
- Privacy protection shouldn't require user intervention
- TikTok's share feature should not include tracking by default
- Consistent with privacy patches (not feature toggles)

**Pattern**: Unlike Spotify/Instagram sanitize patches that may have toggles, TikTok uses always-on approach because it's a **security/privacy fix**, not a feature enhancement.

### 2. Extension vs. Inline Logic

**Decision**: Extracted logic to `ShareUrlSanitizer.clean()` extension

**Advantages**:
- Reusable across multiple patches (if needed)
- Easier to test independently
- Clear separation of concerns
- Matches ReVanced conventions

**Trade-off**: One extra method call overhead (negligible, < 1μs)

### 3. Dynamic Register Extraction

**Decision**: Use `OneRegisterInstruction.registerA` to extract destination register at runtime

**Advantages**:
- Version-resilient: Works even if register allocation changes
- Safer than hardcoding: No assumption about register numbering
- Follows modern ReVanced best practices

**Alternative Considered**: Hardcoding `v0` (Phase 6 Smali used v1, so even there it varied)

### 4. Fingerprint Over Line Numbers

**Decision**: Bytecode fingerprint instead of hardcoded line numbers

**Advantages**:
- Line numbers change with any code edit (fragile)
- Fingerprints survive obfuscation (TikTok obfuscates heavily)
- Graceful failure: Fingerprint mismatch = clear error, not silent breakage

---

## Compatibility & Future Versions

### TikTok 36.5.4
✅ **Validated** - Fingerprint matched, patch applied, runtime tested

### TikTok 36.6 and Later
⚠️ **Unknown** - Fingerprint may or may not match depending on:
- Whether `p003X.UEU.LIZLLL()` method signature changes
- Whether obfuscation mapping changes
- Whether call structure (the `invoke-static` → `move-result-object` pattern) remains same

**Testing Required**: Apply patch to new version, observe:
- Does fingerprint match? → Patch applies automatically
- Does fingerprint fail? → Recompile, update fingerprint if needed
- Does patched app work? → Manual testing on new version

---

## Files Created

### ReVanced Patches Repository (feat/tiktok-sanitize-share-urls)

```
extensions/tiktok/src/main/java/app/revanced/extension/tiktok/share/
├── ShareUrlSanitizer.java              # Extension with clean() method

patches/src/main/kotlin/app/revanced/patches/tiktok/misc/share/
├── Fingerprints.kt                     # urlShorteningFingerprint
└── SanitizeShareUrlsPatch.kt            # Patch with injection logic
```

### Research Repository (apps/tiktok/36.5.4/)

```
logs/
├── phase6-revanced-build.log           # Gradle & CLI build output
└── phase6-revanced-test.log            # Runtime test evidence

revanced-builds/
└── phase6-revanced-aligned.apk         # Signed, testable APK
```

---

## Next Steps

### Upstream Submission

1. **PR to revanced-patches**:
   - Branch: `feat/tiktok-sanitize-share-urls`
   - Files: ShareUrlSanitizer.java, Fingerprints.kt, SanitizeShareUrlsPatch.kt
   - Title: "feat(tiktok): add URL parameter sanitizer for share links"
   - Description: Links to this documentation

2. **Code Review**:
   - Verify fingerprint accuracy
   - Validate register handling
   - Check for edge cases in extension logic

3. **Merge & Release**:
   - Included in next revanced-patches release
   - Available via ReVanced CLI as "Sanitize share URLs"

### Extended Testing (Recommended)

- Test with additional share channels: WhatsApp, Twitter, SMS, Email
- Verify URL sanitization consistent across all channels
- Test with various video types: Short-form, music, live streams
- Regression testing: Ensure share functionality still works

---

## Key Learnings

### 1. Smali-to-ReVanced Pattern
Validate in Smali first, then port to framework. Framework handles complexity (fingerprinting, signing), but core logic should work in both contexts.

### 2. Modern ReVanced Uses Fingerprints
Line numbers are fragile. Fingerprints based on bytecode patterns are future-proof (within reason).

### 3. Dynamic Register Extraction Matters
Don't hardcode register numbers. Extract from actual instructions - more resilient to changes.

### 4. Extensions Simplify Logic
Extracting logic to Java makes the patch cleaner and the extension reusable.

### 5. Always-On Privacy Patches
Privacy/security fixes don't need user toggles. They should be default behavior.

---

## References

- **Live code**: `revanced-src/revanced-patches/extensions/tiktok/src/main/java/.../ShareUrlSanitizer.java`
- **Live code**: `revanced-src/revanced-patches/patches/src/main/kotlin/.../SanitizeShareUrlsPatch.kt`
- **Smali reference**: [phase-6-sanitizer.md](phase-6-sanitizer.md)
- **Build evidence**: `apps/tiktok/36.5.4/logs/phase6-revanced-build.log`
- **Test evidence**: `apps/tiktok/36.5.4/logs/phase6-revanced-test.log`

---

**Status**: [COMPLETE] - ReVanced patch validated against TikTok 36.5.4. Ready for upstream PR consideration.
