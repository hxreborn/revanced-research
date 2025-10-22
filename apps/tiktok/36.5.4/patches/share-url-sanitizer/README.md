# Share URL Sanitizer - Patch Reference

Remove tracking parameters from TikTok share URLs (utm_*, share_*, etc.)

**Result**: 89% size reduction (568 → 63 chars), 100% parameter removal

---

## Quick Links to Documentation

| Resource | Purpose |
|----------|---------|
| [../../../phases.md#phase-6-smali-implementation](../../../phases.md) | Phase 6 technical spec |
| [../../../phases.md#phase-7-revanced-port](../../../phases.md) | Phase 7 technical spec |
| [../../../injection-points.md](../../../injection-points.md) | Injection location & registers |
| [../../../validation-log.md](../../../validation-log.md) | Test results & APK hashes |
| [../../../attempt-history.md](../../../attempt-history.md) | Attempt timeline |

---

## Implementation Files

### Phase 6: Smali (Raw Bytecode)
- **File**: `smali.patch`
- **Location**: `smali_classes15/X/UEU.smali:3866`
- **Method**: `LIZLLL(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)LX/Wu4;`
- **Approach**: Strip everything after `?` character (whitelist sanitization)
- **Status**: ✅ Validated in Smali, tested on device

### Phase 7: ReVanced Framework
- **Location**: `revanced-src/revanced-patches/`
- **Extension**: `extensions/tiktok/src/main/java/app/revanced/extension/tiktok/share/ShareUrlSanitizer.java`
- **Patch**: `patches/src/main/kotlin/app/revanced/patches/tiktok/misc/share/SanitizeShareUrlsPatch.kt`
- **Fingerprint**: `patches/src/main/kotlin/app/revanced/patches/tiktok/misc/share/Fingerprints.kt`
- **Status**: ✅ Built and tested, ready for upstream PR

---

## How to Use This Patch

### Smali (Manual Application)

1. Extract and decompile original APK:
```bash
unzip -j base.apk classes15.dex
baksmali d classes15.dex -o smali-classes15/
```

2. Apply patch to `smali_classes15/X/UEU.smali` after line 3864 (see `smali.patch` for code)

3. Recompile and test:
```bash
smali a smali_classes15/ -o classes15-patched.dex --api 35
zip -j patched.apk classes15-patched.dex
zipalign -v 4 patched.apk patched-aligned.apk
apksigner sign --ks ~/.android/debug.keystore patched-aligned.apk
adb install -r patched-aligned.apk
```

### ReVanced (Framework Integration)

Already implemented in `revanced-src/revanced-patches/` branch `feat/tiktok-sanitize-share-urls`:

```bash
cd revanced-src/revanced-patches
./gradlew build
java -jar revanced-cli.jar \
  -a base.apk \
  --patch "Sanitize share URLs" \
  --out patched.apk
```

---

## Test Results

**Before**:
```
https://www.tiktok.com/@pure.8k/video/7558444171787373846?_r=1&u_code=0&...&utm_source=copy&...utm_medium=android&...
```
(568 chars, 18 tracking parameters, 505 bytes)

**After**:
```
https://www.tiktok.com/@pure.8k/video/7558444171787373846
```
(63 chars, 0 tracking parameters)

See [../../../validation-log.md](../../../validation-log.md) for full evidence.

---

## Build Artifacts

| Artifact | Location | Purpose |
|----------|----------|---------|
| Phase 6 DEX | `../../smali-tests/05-option-c-bypass/classes15-sanitizer-fixed.dex` | Compiled bytecode |
| Phase 6 APK | `../../smali-tests/05-option-c-bypass/phase6-sanitizer-fixed-aligned.apk` | Test APK |
| Phase 7 APK | `../../revanced-builds/phase6-revanced-aligned.apk` | ReVanced build |
| Test Logs | `../../logs/phase6-test-clipboard.log` | Validation evidence |

```
0552a22f1fb944b42bd265d5d5c6e342404396517e94ec1f2809f8bbfcb4d80d  base.apk
e8febd0c08b2f5fcbc51cffe0e417ca5a8cd54e90aa2b584e1e5d451eb0a164d  revanced-builds/phase6-revanced-aligned.apk
```

---

## Technical Notes

- **Whitelist approach**: Future-proof against new tracking parameters
- **Register safe**: No DEX verification conflicts (v0=int, v1/v2=String)
- **Edge cases handled**: Null URLs, missing `?`, `?` at position 0
- **Version resilient**: ReVanced uses bytecode fingerprints, not line numbers

See [../../../injection-points.md](../../../injection-points.md) for detailed register allocation and implementation specs.
