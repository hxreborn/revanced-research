<p align="center">
  <picture>
    <source
      width="256px"
      media="(prefers-color-scheme: dark)"
      srcset="https://raw.githubusercontent.com/ReVanced/revanced-patches/main/assets/revanced-headline/revanced-headline-vertical-dark.svg"
    >
    <img 
      width="256px"
      src="https://raw.githubusercontent.com/ReVanced/revanced-patches/main/assets/revanced-headline/revanced-headline-vertical-light.svg"
    >
  </picture>
  <br>
  <a href="https://revanced.app/">
     <picture>
         <source height="24px" media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/ReVanced/revanced-patches/main/assets/revanced-logo/revanced-logo.svg" />
         <img height="24px" src="https://raw.githubusercontent.com/ReVanced/revanced-patches/main/assets/revanced-logo/revanced-logo.svg" />
     </picture>
   </a>&nbsp;&nbsp;&nbsp;
   <a href="https://github.com/ReVanced">
       <picture>
           <source height="24px" media="(prefers-color-scheme: dark)" srcset="https://i.ibb.co/dMMmCrW/Git-Hub-Mark.png" />
           <img height="24px" src="https://i.ibb.co/9wV3HGF/Git-Hub-Mark-Light.png" />
       </picture>
   </a>&nbsp;&nbsp;&nbsp;
   <a href="http://revanced.app/discord">
       <picture>
           <source height="24px" media="(prefers-color-scheme: dark)" srcset="https://user-images.githubusercontent.com/13122796/178032563-d4e084b7-244e-4358-af50-26bde6dd4996.png" />
           <img height="24px" src="https://user-images.githubusercontent.com/13122796/178032563-d4e084b7-244e-4358-af50-26bde6dd4996.png" />
       </picture>
   </a>&nbsp;&nbsp;&nbsp;
   <a href="https://reddit.com/r/revancedapp">
       <picture>
           <source height="24px" media="(prefers-color-scheme: dark)" srcset="https://user-images.githubusercontent.com/13122796/178032351-9d9d5619-8ef7-470a-9eec-2744ece54553.png" />
           <img height="24px" src="https://user-images.githubusercontent.com/13122796/178032351-9d9d5619-8ef7-470a-9eec-2744ece54553.png" />
       </picture>
   </a>&nbsp;&nbsp;&nbsp;
   <a href="https://t.me/app_revanced">
      <picture>
         <source height="24px" media="(prefers-color-scheme: dark)" srcset="https://user-images.githubusercontent.com/13122796/178032213-faf25ab8-0bc3-4a94-a730-b524c96df124.png" />
         <img height="24px" src="https://user-images.githubusercontent.com/13122796/178032213-faf25ab8-0bc3-4a94-a730-b524c96df124.png" />
      </picture>
   </a>&nbsp;&nbsp;&nbsp;
   <a href="https://x.com/revancedapp">
      <picture>
         <source media="(prefers-color-scheme: dark)" srcset="https://user-images.githubusercontent.com/93124920/270180600-7c1b38bf-889b-4d68-bd5e-b9d86f91421a.png">
         <img height="24px" src="https://user-images.githubusercontent.com/93124920/270108715-d80743fa-b330-4809-b1e6-79fbdc60d09c.png" />
      </picture>
   </a>&nbsp;&nbsp;&nbsp;
   <a href="https://www.youtube.com/@ReVanced">
      <picture>
         <source height="24px" media="(prefers-color-scheme: dark)" srcset="https://user-images.githubusercontent.com/13122796/178032714-c51c7492-0666-44ac-99c2-f003a695ab50.png" />
         <img height="24px" src="https://user-images.githubusercontent.com/13122796/178032714-c51c7492-0666-44ac-99c2-f003a695ab50.png" />
     </picture>
   </a>
   <br>
   <br>
   Reverse engineering workspace for ReVanced patches
</p>

# revanced-research

![GitHub last commit](https://img.shields.io/github/last-commit/hxreborn/revanced-research?label=updated&color=ff6f3d)
![GitHub issues](https://img.shields.io/github/issues/hxreborn/revanced-research?color=ffb347)
![GitHub stars](https://img.shields.io/github/stars/hxreborn/revanced-research?style=social)

`revanced-research` is an operations hub for investigating Android APKs in support of ReVanced and custom patches. It keeps branding in line with the official ReVanced ecosystem while documenting tooling expectations, repeatable workflows, and app-specific findings in one public home.

> **Heads up**: This project does not ship patched APKs. It exists purely for research and documentation that supports patch development.

## ✨ Purpose
- Maintain a clean, reproducible reverse-engineering environment that mirrors the official ReVanced workflow.

## 🧱 Repository Layout
```
revanced-research/
├── AGENTS.md                  # Ops manual / playbook
├── README.md                  # You're here
├── templates/                 # Note & checklist templates
└── apps/
    └── <app-id>/<version>/    # Per-target workspaces
        ├── apk/               # Pristine APKs (hashes logged in notes)
        ├── decode/apktool/    # apktool output (gitignored)
        ├── decode/jadx/       # jadx output (gitignored)
        ├── notes/             # journal, fingerprints, patch plan, tooling
        ├── artifacts/         # dumps, payloads, screenshots (gitignored)
        ├── scripts/           # helper scripts
        └── tmp/               # scratch pad
```

## 🚀 Getting Started
1. **Clone & read**
   ```bash
   git clone https://github.com/hxreborn/revanced-research.git
   cd revanced-research
   ```
   Skim `AGENTS.md` to understand conventions and tooling.
2. **Spawn a workspace**
   ```bash
   export APP_ID=tiktok
   export APP_VER=36.5.4
   mkdir -p apps/$APP_ID/$APP_VER/{apk,decode/{apktool,jadx},notes,artifacts,scripts,tmp}
   cp templates/*.md apps/$APP_ID/$APP_VER/notes/
   ```
3. **Stage the APK** — Drop the pristine APK into `apps/$APP_ID/$APP_VER/apk/`, record its SHA-256 in `notes/tooling.md`.
4. **Decode & decompile** — Follow the commands in `AGENTS.md` (`apktool -JXmx4g`, `jadx --threads-count 4`, etc.). Keep generated output out of Git thanks to `.gitignore`.
5. **Document findings** — Use `notes/journal.md` for daily logs, `notes/fingerprints.md` for match candidates, and `notes/patch-plan.md` for final injection strategies.

## 🔧 Toolchain Snapshot
| Tool       | Recommended Version | Notes |
|------------|---------------------|-------|
| Java       | 17+                 | Matches ReVanced patch build requirements |
| apktool    | 2.12.x              | Run with `-JXmx4g` for multi-dex apps |
| jadx       | 1.5+                | CLI or GUI, `--deobf` optional |
| dex2jar    | 2.4+                | Bundle of `d2j-*` helpers |
| adb        | latest platform-tools | For emulator/device validation |
| frida      | optional            | Runtime inspection/hooking |
| rg / fd    | latest              | Fast text searching across smali/Java |

Log exact versions and CLI flags in `notes/tooling.md` for reproducibility.

## 📚 Reference Links
- [ReVanced Documentation](https://github.com/ReVanced/revanced-documentation)
- [ReVanced Patcher](https://github.com/ReVanced/revanced-patcher)
- [ReVanced CLI](https://github.com/ReVanced/revanced-cli)
- [ReVanced Manager](https://github.com/ReVanced/revanced-manager)
- [Official Patch Catalogue](https://revanced.app/patches)

## 🤝 Contributing
This is a personal tool shared as-is. PRs are welcome, but responses might be slow.
- Keep large decode outputs, APKs, and temporary files out of Git.
- Sync major discoveries back into `AGENTS.md` or the relevant `apps/<app>/<version>/notes/` file so future contributors benefit.
- Follow Conventional Commit message style when updating the playbook or templates (`docs:`, `chore:`, etc.).

## ⚖️ License
This project is licensed under the [GNU General Public License v3.0](LICENSE).

<sub>ReVanced name, logo, and brand assets © their respective owners. Used here for documentation alignment.</sub>
