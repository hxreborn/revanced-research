# Targets

Each subdirectory hosts research artefacts for a specific package and version.

```
targets/
└── <package>/
    └── <version>/
        ├── apk/            # Input APKs (pristine)
        ├── decode/         # apktool/jadx outputs (gitignored)
        ├── notes/          # journal, tooling, fingerprints, patch plan
        ├── artifacts/      # payload dumps, logs, screenshots
        └── tmp/            # scratch space (safe to delete)
```

Active targets:
- `tiktok/36.5.4` — share sanitizer research (see `notes/` for journal & plan).

Before starting a new target, copy the templates:
```bash
mkdir -p targets/<package>/<version>/{apk,decode/{apktool,jadx},notes,artifacts,tmp}
cp docs/templates/*.md targets/<package>/<version>/notes/
```
