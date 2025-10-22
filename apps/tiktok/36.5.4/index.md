# TikTok 36.5.4 - Research Workspace

Reverse-engineering workspace for TikTok 36.5.4 (36.5.4) with focus on tracking parameter removal from share URLs.

---

## Available Patches

| Patch | Purpose | Status |
|-------|---------|--------|
| **[Share URL Sanitizer](patches/share-url-sanitizer/)** | Remove tracking parameters (utm_*, share_*, etc.) from share URLs | ✅ Complete |

See [patches/README.md](patches/README.md) for all available patches.

---

## Quick Start

### Want to use the Share URL Sanitizer patch?

**Recommended (ReVanced)**:
```bash
cd revanced-src/revanced-patches
./gradlew build
java -jar revanced-cli.jar -a base.apk --patch "Sanitize share URLs" --out patched.apk
```

**Manual (Smali)**:
See [patches/share-url-sanitizer/README.md](patches/share-url-sanitizer/README.md) for detailed instructions.

---

## Documentation Index

### Entry Points
- **[patches/README.md](patches/README.md)** - All patches with status and navigation
- **[patches/share-url-sanitizer/README.md](patches/share-url-sanitizer/)** - Feature guide, usage, and technical details

### Technical Reference
- **[phases.md](phases.md)** - Phase 4-7 technical specs (Smali & ReVanced implementations)
- **[injection-points.md](injection-points.md)** - Injection location, register allocation, bytecode
- **[obfuscation-map.md](obfuscation-map.md)** - Class/method mappings
- **[validation-log.md](validation-log.md)** - Test results and APK hashes

### Research Notes
- **[overview.md](overview.md)** - APK metadata, build commands, design notes
- **[attempt-history.md](attempt-history.md)** - Complete attempt timeline and findings

---

## Workspace Structure

```
apps/tiktok/36.5.4/
├── patches/                              ← Start here for patches
│   ├── README.md                         (patch index)
│   └── share-url-sanitizer/
│       ├── README.md                     (feature documentation)
│       └── smali.patch                   (implementation)
│
├── *.md                                  ← Technical documentation
├── smali-tests/                          ← Test builds
├── revanced-builds/                      ← ReVanced APKs
├── logs/                                 ← Test evidence
└── decompiled-*/                         ← Decompilation artifacts
```

---

## APK Information

| Property | Value |
|----------|-------|
| Package | `com.zhiliaoapp.musically` |
| Version | 36.5.4 |
| SHA256 | `0552a22f1fb944b42bd265d5d5c6e342404396517e94ec1f2809f8bbfcb4d80d` |

---

## Status

| Component | Status |
|-----------|--------|
| Share URL Sanitizer (Smali) | ✅ Validated |
| Share URL Sanitizer (ReVanced) | ✅ Validated |
| ReVanced Upstream PR | ✅ Ready |

---

**For detailed information, start with [patches/README.md](patches/README.md) or [patches/share-url-sanitizer/README.md](patches/share-url-sanitizer/).**
