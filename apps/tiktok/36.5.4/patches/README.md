# TikTok 36.5.4 - Patch Repository

Manual patch implementations and references for TikTok 36.5.4 research.

---

## Available Patches

### Share URL Sanitizer
Remove tracking parameters from share URLs (utm_*, share_*, _d, _r, etc.)

| Component | Location | Documentation |
|-----------|----------|-----------------|
| **Smali** | `share-url-sanitizer/smali.patch` | [README](share-url-sanitizer/README.md) |
| **ReVanced** | `revanced-src/revanced-patches/` | [phases.md#phase-7](../phases.md#phase-7-revanced-port) |

**Result**: 89% size reduction (568 → 63 chars), 100% tracking parameter removal

---

## Quick Navigation

- **Phase 6 (Smali)**: [share-url-sanitizer/README.md](share-url-sanitizer/README.md)
- **Phase 7 (ReVanced)**: [../phases.md#phase-7-revanced-port](../phases.md#phase-7-revanced-port)
- **Injection Point**: [../injection-points.md](../injection-points.md)
- **Validation Evidence**: [../validation-log.md](../validation-log.md)
- **Attempt History**: [../attempt-history.md](../attempt-history.md)

---

## How to Apply Patches

### Using ReVanced (Recommended)
ReVanced framework handles version compatibility automatically via bytecode fingerprints.

```bash
cd revanced-src/revanced-patches
./gradlew build
java -jar revanced-cli.jar -a base.apk --patch "Sanitize share URLs" --out patched.apk
```

### Manual Smali Application
For direct APK modification or educational purposes:

1. Read `share-url-sanitizer/README.md` for detailed instructions
2. Extract patch code from `share-url-sanitizer/smali.patch`
3. Apply to `smali_classes15/X/UEU.smali` after line 3864
4. Recompile with baksmali/smali tools

---

## APK Hashes (SHA256)

```
0552a22f1fb944b42bd265d5d5c6e342404396517e94ec1f2809f8bbfcb4d80d  base.apk
e8febd0c08b2f5fcbc51cffe0e417ca5a8cd54e90aa2b584e1e5d451eb0a164d  revanced-builds/phase6-revanced-aligned.apk
```

Verify with: `sha256sum -c <<< "hash  path"`

---

## Architecture

```
patches/
├── README.md                               (this file - index)
├── share-url-sanitizer/                   (feature group)
│   ├── README.md                          (feature documentation with links)
│   └── smali.patch                        (Phase 6 smali implementation)
│
└── [future patches by feature name]
```

**Organization**: Group by feature/goal, not by phase or tool.
- Easy to discover: "I need URL sanitizer" → `patches/share-url-sanitizer/`
- Clear hierarchy: README links to docs, patch files are implementation
- Version-agnostic: Smali and ReVanced implementations grouped together

---

## Status

| Patch | Status | Version |
|-------|--------|---------|
| Share URL Sanitizer | [COMPLETE] | 36.5.4 |

---

See [../index.md](../index.md) for full documentation index.
