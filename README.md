# revanced-research

![GitHub last commit](https://img.shields.io/github/last-commit/hxreborn/revanced-research?label=updated&color=ff6f3d)
![Status: Experimental](https://img.shields.io/badge/status-experimental-ffb347)
![GPLv3](https://img.shields.io/badge/license-GPLv3-blue)

Smali-first reverse-engineering workspace for Android APK analysis and ReVanced patch development.

## Quick Start

```bash
git clone --recursive https://github.com/hxreborn/revanced-research.git
cd revanced-research
cat apps/tiktok/features/share-url-sanitization/README.md          # Active feature
ls -la apps/tiktok/apks/36.5.4/                                    # APK artifacts
```

## Navigation

| Path | Purpose |
|------|---------|
| `apps/<app>/features/<feature>/` | Research workspace: problem analysis, smali tests, logs |
| `apps/<app>/features/<feature>/<version>/` | Version-specific artifacts (smali-tests/, logs/) |
| `apps/<app>/apks/<version>/` | APK artifacts: base.apk, metadata, decompilation outputs |
| `revanced-src/` | ReVanced patches (submodule, upstream port only) |

## Targets

| App | Feature | Status | Documentation |
|-----|---------|--------|---|
| TikTok | Share URL sanitization | Passed | [README.md](apps/tiktok/features/share-url-sanitization/README.md) |

## Prerequisites

- `apktool` - APK decompilation
- `baksmali`/`smali` - DEX manipulation
- `zipalign`, `apksigner` - APK signing
- `jadx` - Source deobfuscation (optional)
- `rg` (ripgrep) - Fast code search
