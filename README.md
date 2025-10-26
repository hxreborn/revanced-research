# revanced-research

![GitHub last commit](https://img.shields.io/github/last-commit/hxreborn/revanced-research?label=updated&color=ff6f3d)
![Status: Experimental](https://img.shields.io/badge/status-experimental-ffb347)
![GPLv3](https://img.shields.io/badge/license-GPLv3-blue)

Smali-first reverse-engineering workspace for Android APK analysis and ReVanced patch development.

## Navigation

| Path | Purpose |
|------|---------|
| `apps/<app-family>/<variant>/apks/<version>/` | APK artifacts: base.apk, metadata, decompilation outputs |
| `apps/<app-family>/<feature>/` | Research workspace: problem analysis, smali tests, logs |
| `apps/<app-family>/<feature>/<version>/` | Version-specific artifacts (smali-tests/, logs/, patches/) |
| `revanced-src/` | ReVanced patches (submodule, upstream port only) |

## Targets

| App | Feature | Status | Documentation |
|-----|---------|--------|---|
| Trill + Musically | Share URL sanitization | Passed | [README.md](apps/tiktok/share-url-sanitization/README.md) |

## Prerequisites

- `apktool` - APK decompilation
- `baksmali`/`smali` - DEX manipulation
- `zipalign`, `apksigner` - APK signing
- `jadx` - Source deobfuscation (optional)
- `rg` (ripgrep) - Fast code search

## Approach

Every patch begins with **Smali-first validation**: bytecode changes are tested in raw Smali (via baksmali/apktool) before porting to ReVanced. This ensures:
- Injection points are proven to work
- Register allocation is correct
- Bytecode patterns are established before abstraction to ReVanced

Feature READMEs serve as the single source of truth, combining research findings, technical details, and validation results across versions in one place.

## License

[GPLv3](LICENSE)
