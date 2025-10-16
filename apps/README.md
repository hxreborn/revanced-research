# Applications

Each subdirectory hosts reverse-engineering analysis for a specific app and version.

## Directory Structure

```
apps/
└── <app-name>/
    └── <version>/
        ├── README.md              # App status, findings, & benchmarks
        ├── apk/                   # Input APKs (pristine, hashes logged)
        ├── decode/
        │   ├── apktool/          # Resource decode output (gitignored)
        │   └── jadx/             # Java decompilation (gitignored)
        ├── notes/
        │   ├── journal.md        # Discovery timeline & observations
        │   ├── fingerprints.md   # Candidate patch methods
        │   ├── patch-plan.md     # Injection strategy & dependencies
        │   └── tooling.md        # Tool versions, APK hash, performance
        ├── analysis/             # Reports & classification data
        ├── artifacts/            # Dumps, screenshots (gitignored)
        └── tmp/                  # Scratch space (safe to delete)
```

## Active Investigations

- **tiktok/36.5.4** — Share link sanitizer research
  - Status: ✅ Decompilation complete (391,259 Java files)
  - Next: Fingerprint share link builder methods
  - See `tiktok/36.5.4/README.md` for details

## Starting a New Application

```bash
APP=<app-name>
VER=<version>

# Create workspace
mkdir -p apps/$APP/$VER/{apk,decode/{apktool,jadx},notes,analysis,artifacts,tmp}

# Create note templates (or copy from docs/templates/)
touch apps/$APP/$VER/README.md
touch apps/$APP/$VER/notes/{journal,fingerprints,patch-plan,tooling}.md
```
