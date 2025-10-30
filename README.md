# revanced-research
![GitHub last commit](https://img.shields.io/github/last-commit/hxreborn/revanced-research?label=-%20updated&color=ff6f3d) ![Status: Experimental](https://img.shields.io/badge/status-experimental-ffb347) ![GPLv3](https://img.shields.io/badge/license-GPLv3-blue)

Reverse-engineering workspace tuned for Android APK analysis with shell-first tooling (apktool, jadx, ripgrep, frida). Notes stay lean for future me; feel free to reuse the pattern.

## Workflow

Quick reference below; full procedures live in `WORKFLOW.md` and the individual feature READMEs.

1. **Pull and decompile** — Example: stage TikTok Trill v36.5.4 and hunt the downloads path builder.
   ```bash
   cd apps/tiktok/apks/36.5.4
   apktool d base.apk -o apktool-output
   rg --context 1 --line-number --pcre2 "DIRECTORY_" ../downloads/36.5.4/files -g'DVV.smali'
   ```
   ```smali
   apps/tiktok/downloads/36.5.4/files/DVV.smali:767-    sget-object v0, Landroid/os/Environment;->DIRECTORY_MOVIES:Ljava/lang/String;
   apps/tiktok/downloads/36.5.4/files/DVV.smali-768-    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
   apps/tiktok/downloads/36.5.4/files/DVV.smali-769-    const-string v0, "/TikTok"
   ```
2. **Validate the idea** — Example: trace MediaStore writes while downloads patch scripts are injected.
   ```bash
   sudo sysctl -w kernel.perf_event_paranoid=1 >/dev/null  # Linux: allow Frida perf events
   frida -U -f com.ss.android.ugc.trill -l frida-scripts/downloads-trace.js --no-pause
   tail -n 12 apps/tiktok/downloads/36.5.4/logs/frida-trace-live.log
   ```
   ```text
   [ContentResolver.insert] MediaStore registration
   ContentValues:
     _display_name: eb1e3fe0a080184fdf311ccd206ca8ff.mp4
     mime_type: video/mp4
     relative_path: DCIM/Camera/
   ```
3. **Document and port** — Example: promote the smali test and confirm the Kotlin patch mirrors it.
   ```bash
   cp apps/tiktok/downloads/36.5.4/smali-tests/dvv-patch/DVV.smali apps/tiktok/downloads/36.5.4/files/DVV.smali  # promote scratch smali to tracked
   rg -n "getDownloadPath" revanced-src/revanced-patches/patches/src/main/kotlin/app/revanced/patches/tiktok/interaction/downloads/DownloadsPatch.kt
   ```
   ```kotlin
   70:                        invoke-static {}, $EXTENSION_CLASS_DESCRIPTOR->getDownloadPath()Ljava/lang/String;
   ```

## Layout

```
apps/<family>/
  apks/<version>/
    base.apk.info
    base.apk.sha256
    base.apk
    jadx-output/
    apktool-output/
  <feature>/
    README.md
    <version>/
      files/
      logs/
      smali-tests/

frida-scripts/
revanced-src/
WORKFLOW.md
```

Track metadata and reference smali; keep APKs, decomp outputs, and scratch logs on local storage (tmpfs works great).

## Toolbox
- [apktool](https://apktool.org/) — decode/encode APK resources. Docs: [apktool documentation](https://ibotpeaches.github.io/Apktool/documentation/).
- [jadx](https://github.com/skylot/jadx) — Java-oriented decompilation. Docs: [jadx wiki](https://github.com/skylot/jadx/wiki).
- [baksmali / smali](https://github.com/JesusFreke/smali) — DEX disassembly and assembly. Docs: [smali wiki](https://github.com/JesusFreke/smali/wiki).
- [frida](https://frida.re/) — dynamic instrumentation. Docs: [Frida API reference](https://frida.re/docs/home/).
- [ripgrep](https://github.com/BurntSushi/ripgrep) — fast text search (`rg --pcre2`, `rg --json`) across smali/JADX trees.
- [Android SDK Build-Tools](https://developer.android.com/tools/releases/build-tools) — `zipalign`, `apksigner`, related utilities; stage paths via `sdkmanager` or `asdf`.
- [Java LTS](https://openjdk.org/projects/jdk/) — stay on current LTS (17/21) when running Gradle or smali assembly; the extra headroom (`-Xmx16G`) helps with oversized social media APKs. Docs: [Java API](https://docs.oracle.com/javase/specs/).
- [bubblewrap](https://github.com/containers/bubblewrap) / [firejail](https://firejail.wordpress.com/) — sandbox patched APK runs when testing on Linux hosts.

## References

**Bytecode & Smali:**
- [Dalvik Bytecode](https://source.android.com/docs/core/runtime/dalvik-bytecode) — official spec.
- [Smali Wiki](https://github.com/JesusFreke/smali/wiki) — registers, types, and method syntax.
- [Smali Reference](https://github.com/LaurieWired/SmaliReference) — practical opcode examples.

**Kotlin & Patching:**
- [Kotlin Documentation](https://kotlinlang.org/docs/home.html) — language reference.
- [ReVanced Patcher](https://github.com/ReVanced/revanced-patcher/tree/main/docs) — bytecode patching API.
- [ReVanced Patches](https://github.com/ReVanced/revanced-patches) — patch patterns & conventions; see `patches/src/main/kotlin/` for examples.

## License
[GPLv3](https://www.gnu.org/licenses/gpl-3.0.html)
