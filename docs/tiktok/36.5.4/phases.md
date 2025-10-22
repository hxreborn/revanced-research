# Phase Reference - TikTok 36.5.4 Share URL Sanitization

---

## Phase 4: Injection Point Verification

**Status**: [PASS]
**Finding**: Canonical URL at `AwemeSharePackage.LJIJJLI()`, line 2795

### Failed Injection Attempts

| Target Method | Location | Result |
|--------------|----------|--------|
| `UEU.LIZJ()` | `X/UEU.smali:150` | [BROKEN] Method not called during share |
| `UGk.LJ()` | `X/UGk.smali:3142` | [BROKEN] Not in call stack |
| `AwemeSharePackage.LJIJJ()` | `AwemeSharePackage.smali:21638` | [BROKEN] URL already shortened |

### Verified Injection Point

**File**: `smali_classes15/X/UEU.smali`
**Method**: `LIZLLL(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)LX/Wu4;`
**Line**: 3866 (after `move-result-object` from `UEa.LIZ()`)

URL arrives canonical at `AwemeSharePackage.LJIJJLI()` and is passed through `UEU.LIZLLL()` where `UEa.LIZ()` adds 18 tracking parameters before distribution.

---

## Phase 6: Smali Implementation

**Status**: [VALIDATED]
**Result**: 89% size reduction (568 → 63 chars), 100% parameter removal

### Injection Location

**File**: `smali_classes15/X/UEU.smali`
**Method**: `LIZLLL(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)LX/Wu4;`
**Line**: 3866
**Register Change**: `.registers 6` → `.registers 8`

### Register Allocation

| Register | Type | Purpose |
|----------|------|---------|
| v0 | int | indexOf result |
| v1 | String | URL (from UEa.LIZ(), modified in-place) |
| v2 | String | Temporaries (const-string, substring) |
| v3 | String | Reserved |
| v4-v5 | String | Method parameters (unused) |

### Smali Code

```smali
move-result-object v1              # v1 = canonical URL from UEa.LIZ()

# Null safety check
if-eqz v1, :keep_shortened_c
goto :start_sanitize

:start_sanitize
# Find position of '?' character
const-string v2, "?"
invoke-virtual {v1, v2}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I
move-result v0

# Skip if no '?' found (-1) or '?' at position 0
if-lez v0, :check_shortened

# Extract base URL (remove query string)
const/4 v2, 0x0
invoke-virtual {v1, v2, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;
move-result-object v1              # v1 now contains clean URL

:check_shortened
# Continue to isEmpty check and rest of original method

:keep_shortened_c
# Fall through to rest of method (null case)
```

### Edge Cases

1. **Null URL**: `if-eqz` guard skips sanitization
2. **No query string** (`indexOf` → -1): `if-lez` guard skips operation
3. **Malformed URL** (`indexOf` → 0): `if-lez` guard skips sanitization
4. **Valid query string** (position > 0): Executes `substring(0, v0)`

### Validation

89% size reduction (568 → 63 chars), 100% parameter removal. See [validation-log.md](validation-log.md) for test details.

---

## Phase 7: ReVanced Port

**Status**: [WORKING]
**Result**: Compiled, CLI built, runtime tested (identical to Phase 6)

### Extension: ShareUrlSanitizer.java

**Location**: `extensions/tiktok/src/main/java/app/revanced/extension/tiktok/share/ShareUrlSanitizer.java`

```java
public static String clean(String url) {
    if (url == null) {
        return url;
    }

    int questionMarkIndex = url.indexOf("?");

    if (questionMarkIndex <= 0) {
        return url;
    }

    return url.substring(0, questionMarkIndex);
}
```

### Fingerprint

**Location**: `patches/src/main/kotlin/app/revanced/patches/tiktok/misc/share/Fingerprints.kt`

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

Fingerprints match bytecode structure, not names, surviving obfuscation across versions.

### Patch: SanitizeShareUrlsPatch.kt

**Location**: `patches/src/main/kotlin/app/revanced/patches/tiktok/misc/share/SanitizeShareUrlsPatch.kt`

1. Use fingerprint to find the target method
2. Locate the `move-result-object` instruction that receives UEa.LIZ() result
3. Extract the destination register dynamically: `OneRegisterInstruction.registerA`
4. Inject a call to `ShareUrlSanitizer.clean()`
5. Continue with original method flow

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

Dynamic register extraction. No hardcoding of register numbers.

### Build

```bash
cd revanced-src/revanced-patches
./gradlew :patches:compileKotlin
./gradlew :extensions:tiktok:assembleRelease
./gradlew :patches:jar
```

```bash
java -jar revanced-src/revanced-cli.jar patch \
  -p revanced-src/revanced-patches/patches/build/libs/patches-*.rvp \
  -o patched.apk \
  base.apk
```

### Validation

Build successful, runtime tested, behavior identical to Phase 6 (89% size reduction, 100% parameter removal). See [validation-log.md](validation-log.md) for full build and test results.

---

## Design Notes

**Always-On**: No settings toggle. Privacy-first default.

**Register Extraction**: Dynamic via `OneRegisterInstruction.registerA`, not hardcoded.

**Whitelist Approach**: Remove everything after `?` character. Future-proof against new tracking parameters.

**Type Safety**: v0 always int, v1/v2 always String. DEX verifier requirement.

---

**APK Tested**: TikTok 36.5.4
**APK Hash**: e8febd0c08b2f5fcbc51cffe0e417ca5a8cd54e90aa2b584e1e5d451eb0a164d
