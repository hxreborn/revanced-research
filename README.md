# revanced-research

![GitHub last commit](https://img.shields.io/github/last-commit/hxreborn/revanced-research?label=updated&color=ff6f3d)
![Status: Experimental](https://img.shields.io/badge/status-experimental-ffb347)
![GPLv3](https://img.shields.io/badge/license-GPLv3-blue)

Smali-first reverse-engineering workspace for Android APK analysis and ReVanced patch development.

## Workspace Layout

| Path | Tracked | Purpose |
|------|---------|---------|
| `apps/<family>/apks/<version>/<package>.apk.{info,sha256}` | ✓ | APK metadata |
| `apps/<family>/<feature>/README.md` | ✓ | Research findings |
| `apps/<family>/<feature>/<version>/files/` | ✓ | Reference smali |
| `apps/<family>/apks/<version>/<package>.apk` | ✗ | APK binaries |
| `apps/<family>/apks/<version>/{apktool,jadx}/` | ✗ | Decompilations |
| `apps/<family>/<feature>/<version>/smali-tests/` | ✗ | Test outputs |
| `revanced-src/` | submodule | Patch port target |

Procedures: [WORKFLOW.md](WORKFLOW.md)

## Environment

- [apktool](https://apktool.org/) - APK decompilation
- [baksmali/smali](https://github.com/JesusFreke/smali) - DEX manipulation
- [Android SDK](https://developer.android.com/studio) - zipalign, apksigner (`~/Android/Sdk/build-tools/36.1.0/`)
- [jadx](https://github.com/skylot/jadx) - Source deobfuscation
- [frida](https://frida.re/) - Dynamic instrumentation
- [ripgrep](https://github.com/BurntSushi/ripgrep) - Code search

Java 11 for large DEX assembly (`-Xmx16G`).

## Resources

- [Dalvik Bytecode Reference](https://source.android.com/docs/core/runtime/dalvik-bytecode) - Official AOSP docs
- [Smali Wiki](https://github.com/JesusFreke/smali/wiki) - Registers, types, methods
- [Smali Reference](https://github.com/LaurieWired/SmaliReference) - Practical examples

## License

[GPLv3](https://www.gnu.org/licenses/gpl-3.0.html)
