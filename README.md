# revanced-research

![GitHub last commit](https://img.shields.io/github/last-commit/hxreborn/revanced-research?label=updated&color=ff6f3d)
![Status: Experimental](https://img.shields.io/badge/status-experimental-ffb347)
![GPLv3](https://img.shields.io/badge/license-GPLv3-blue)

Smali-first reverse-engineering workspace for Android APK analysis and ReVanced patch development.

## Navigation

| Path | Purpose |
|------|---------|
| `apps/<app-family>/<variant>/apks/<version>/` | APK metadata: checksums, build info (binaries gitignored) |
| `apps/<app-family>/<feature>/` | Feature documentation: research findings, technical details |
| `apps/<app-family>/<feature>/<version>/files/` | Reference smali files for documentation |
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

Smali-first validation: test bytecode changes in raw Smali before porting to ReVanced. Feature READMEs are the single source of truth.

## License

GPLv3
