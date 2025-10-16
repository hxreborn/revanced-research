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
      alt="ReVanced headline logo"
    >
  </picture>
  <br>
  <a href="https://revanced.app/">
     <picture>
         <source height="24px" media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/ReVanced/revanced-patches/main/assets/revanced-logo/revanced-logo.svg" />
         <img height="24px" src="https://raw.githubusercontent.com/ReVanced/revanced-patches/main/assets/revanced-logo/revanced-logo.svg" alt="ReVanced" />
     </picture>
   </a>&nbsp;&nbsp;&nbsp;
   <a href="https://github.com/ReVanced">
       <picture>
           <source height="24px" media="(prefers-color-scheme: dark)" srcset="https://i.ibb.co/dMMmCrW/Git-Hub-Mark.png" />
           <img height="24px" src="https://i.ibb.co/9wV3HGF/Git-Hub-Mark-Light.png" alt="GitHub" />
       </picture>
   </a>&nbsp;&nbsp;&nbsp;
   <a href="http://revanced.app/discord">
       <picture>
           <source height="24px" media="(prefers-color-scheme: dark)" srcset="https://user-images.githubusercontent.com/13122796/178032563-d4e084b7-244e-4358-af50-26bde6dd4996.png" />
           <img height="24px" src="https://user-images.githubusercontent.com/13122796/178032563-d4e084b7-244e-4358-af50-26bde6dd4996.png" alt="Discord" />
       </picture>
   </a>&nbsp;&nbsp;&nbsp;
   <a href="https://reddit.com/r/revancedapp">
       <picture>
           <source height="24px" media="(prefers-color-scheme: dark)" srcset="https://user-images.githubusercontent.com/13122796/178032351-9d9d5619-8ef7-470a-9eec-2744ece54553.png" />
           <img height="24px" src="https://user-images.githubusercontent.com/13122796/178032351-9d9d5619-8ef7-470a-9eec-2744ece54553.png" alt="Reddit" />
       </picture>
   </a>&nbsp;&nbsp;&nbsp;
   <a href="https://t.me/app_revanced">
      <picture>
         <source height="24px" media="(prefers-color-scheme: dark)" srcset="https://user-images.githubusercontent.com/13122796/178032213-faf25ab8-0bc3-4a94-a730-b524c96df124.png" />
         <img height="24px" src="https://user-images.githubusercontent.com/13122796/178032213-faf25ab8-0bc3-4a94-a730-b524c96df124.png" alt="Telegram" />
      </picture>
   </a>&nbsp;&nbsp;&nbsp;
   <a href="https://x.com/revancedapp">
      <picture>
         <source media="(prefers-color-scheme: dark)" srcset="https://user-images.githubusercontent.com/93124920/270180600-7c1b38bf-889b-4d68-bd5e-b9d86f91421a.png">
         <img height="24px" src="https://user-images.githubusercontent.com/93124920/270108715-d80743fa-b330-4809-b1e6-79fbdc60d09c.png" alt="X" />
      </picture>
   </a>&nbsp;&nbsp;&nbsp;
   <a href="https://www.youtube.com/@ReVanced">
      <picture>
         <source height="24px" media="(prefers-color-scheme: dark)" srcset="https://user-images.githubusercontent.com/13122796/178032714-c51c7492-0666-44ac-99c2-f003a695ab50.png" />
         <img height="24px" src="https://user-images.githubusercontent.com/13122796/178032714-c51c7492-0666-44ac-99c2-f003a695ab50.png" alt="YouTube" />
     </picture>
   </a>
   <br>
   <br>
   Reverse engineering workspace for ReVanced patches
</p>

# revanced-research

![GitHub last commit](https://img.shields.io/github/last-commit/hxreborn/revanced-research?label=updated&color=ff6f3d)
![Status: Experimental](https://img.shields.io/badge/status-experimental-ffb347)
![GPLv3](https://img.shields.io/badge/license-GPLv3-blue)

A reverse-engineering workspace for ReVanced patch development. Documents tooling expectations, repeatable workflows, and app-specific findings. **Does not ship patched APKs**—purely for research and documentation.

## 🧱 Repository Layout
```text
revanced-research/
├── docs/              # Human guides & templates
│   ├── templates/     # Analysis templates (README, fingerprints, patch-plan)
│   └── jvm_gc_troubleshooting.md
├── apps/              # Per-app analysis workspaces
│   └── <package>/<version>/
│       ├── apk/       # Pristine APKs
│       ├── decode/    # Decompilation outputs (gitignored)
│       ├── notes/     # Analysis documents
│       └── artifacts/ # Dumps & screenshots (gitignored)
└── scripts/           # Utility scripts (apktool, jadx wrappers, etc.)
```

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/hxreborn/revanced-research.git && cd revanced-research

# 2. Set up a target workspace
export APP=myapp VER=1.0.0
mkdir -p apps/$APP/$VER/{apk,decode/{apktool,jadx},notes,artifacts,tmp}
cp docs/templates/*.md apps/$APP/$VER/notes/

# 3. Place APK, decode, decompile, analyze, and document findings
# See docs/templates/ and docs/JVM_GC_TROUBLESHOOTING.md for guidance
```

## 📚 Resources
- **`docs/templates/`** — Analysis templates (README, fingerprints, patch-plan)
- **`docs/JVM_GC_TROUBLESHOOTING.md`** — GC crash diagnosis for large APK decompilation
- **Example**: `apps/tiktok/36.5.4/notes/` shows completed analysis

## 📚 Quick Links
- [ReVanced Patches](https://revanced.app/patches)
- [Contributing Guidelines](https://github.com/hxreborn/revanced-research)
- **License**: [GPLv3](LICENSE)
