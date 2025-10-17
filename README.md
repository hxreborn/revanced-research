<picture>
  <source
    media="(prefers-color-scheme: dark)"
    srcset="https://raw.githubusercontent.com/ReVanced/revanced-patches/main/assets/revanced-headline/revanced-headline-vertical-dark.svg"
  >
  <img 
    width="256px"
    alt="ReVanced headline logo"
    src="https://raw.githubusercontent.com/ReVanced/revanced-patches/main/assets/revanced-headline/revanced-headline-vertical-light.svg"
  >
</picture>

# revanced-research

![GitHub last commit](https://img.shields.io/github/last-commit/hxreborn/revanced-research?label=updated&color=ff6f3d)
![Status: Experimental](https://img.shields.io/badge/status-experimental-ffb347)
![GPLv3](https://img.shields.io/badge/license-GPLv3-blue)

[Website](https://revanced.app/) · [GitHub](https://github.com/ReVanced) · [Discord](http://revanced.app/discord) · [Reddit](https://reddit.com/r/revancedapp) · [Telegram](https://t.me/app_revanced) · [X](https://x.com/revancedapp) · [YouTube](https://www.youtube.com/@ReVanced)

---

## ❓ About

`revanced-research` is a reverse-engineering workspace for analyzing Android APKs. It documents bytecode fingerprints, patch strategies, and analysis findings.

**No APKs or binaries are provided or distributed from this repository.**

## 📂 Repository Layout

Example for TikTok `36.5.4`:

```
revanced-research/
├── README.md
├── CONTRIBUTING.md
├── scripts/                        # setup, cleanup, decompile helpers
└── apps/
    └── tiktok/36.5.4/
        ├── apk/
        │   └── tiktok-36.5.4.apk   # pristine; record SHA-256 in notes
        ├── notes/
        │   ├── README.md           # what this target covers and scope
        │   ├── fingerprints.md     # bytecode/class/method signatures
        │   ├── patch-plan.md       # planned changes and hook points
        │   ├── research-status.md  # phase, blockers, next steps
        │   └── tooling.md          # exact tool versions and commands
        └── helpers/                # small scripts or reference stubs (optional)
```

Notes:
- Decompile outputs and large artifacts are ignored by Git and not listed here.
- File names use kebab-case. One topic per doc.

## 🚀 Getting Started

1. **Clone**
   ```bash
   git clone https://github.com/hxreborn/revanced-research.git
   cd revanced-research
   ```

2. **Create workspace**
   ```bash
   mkdir -p apps/myapp/1.0.0/{apk,notes}
   ```

3. **Add APK and record metadata**
   - Place APK in `apps/myapp/1.0.0/apk/`
   - Record SHA-256 hash and tool versions in `apps/myapp/1.0.0/notes/tooling.md`
   - See [apps/tiktok/36.5.4/notes/tooling.md](./apps/tiktok/36.5.4/notes/tooling.md) for example format

## 🛠 Tools

- **apktool** — Decode APKs to smali and resources
- **jadx** — Decompile DEX to Java source
- **dex2jar** — Convert DEX → JAR for Java decompilers (e.g., CFR)
- **adb** — Device/emulator interaction
- **rg / fd** — Search decompiled sources

Pin exact versions and CLI flags in `apps/<package>/<version>/notes/tooling.md` per target.

## 📚 References

- [ReVanced Documentation](https://github.com/ReVanced/revanced-documentation)
- [ReVanced Patcher](https://github.com/ReVanced/revanced-patcher)
- [ReVanced CLI](https://github.com/ReVanced/revanced-cli)
- [ReVanced Manager](https://github.com/ReVanced/revanced-manager)
- [Official Patch Catalogue](https://revanced.app/patches)

## 🤝 Contributing

This is a personal tool shared as-is. Keep decompilation outputs and APKs out of Git. Document findings in `apps/<package>/<version>/notes/` for reproducibility. Follow [Conventional Commits](https://www.conventionalcommits.org/) style (`docs:`, `feat:`, `fix:`, etc.).

## ⚖️ License

Licensed under [GNU General Public License v3.0](LICENSE).

ReVanced name, logo, and brand assets © their respective owners. Used here for documentation alignment.
