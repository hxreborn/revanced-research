# ReVanced Research Repository

Systematic approach to developing ReVanced patches. Test everything in raw Smali first, then port to ReVanced.

## Repository Structure

```
revanced-research/
├── README.md                    # This file
├── CLAUDE.md                    # AI project context & commands
├── WORKFLOW.md                  # Detailed phase-by-phase guide
├── attempt-history.md           # Attempt tracker
├── apps/tiktok/36.5.4/
│   ├── base.apk                 # Original APK (.gitignore)
│   ├── apk-metadata.txt         # SHA256 verification
│   ├── obfuscation-map.md       # Class mappings (Phase 1)
│   ├── injection-points.md      # Verified points (Phase 2)
│   ├── decompiled-{jadx,smali}/ # Decompiled code
│   ├── smali-tests/             # Test builds
│   ├── revanced-builds/         # Patched APKs
│   └── logs/                    # Test logs
└── revanced-src/
    ├── revanced-patches/        # Submodule
    └── revanced-cli.jar         # CLI tool
```

## Mission

Ship a working ReVanced patch using proven Smali edits. **Always test Smali first.**

## Current Status

- **Phase 0**: ✅ Setup complete
- **Phase 1**: Next - Decompile APK and create search indices
- **Target**: TikTok 36.5.4 - Remove tracking parameters from share URLs

## Key Principles

1. **ALWAYS smali test first** - Never write ReVanced code unproven
2. **Document obfuscation** - Map `Lcom/a/b/c;->d` to purpose
3. **Stage integration** - One method at a time
4. **Log aggressively** - Remove only after working
5. **Track attempts** - Update attempt-history.md
6. **Conventional commits** - feat/fix/chore/test/docs

## Documentation

- **@CLAUDE.md** - Commands, naming conventions, tech stack
- **@WORKFLOW.md** - Complete phase-by-phase instructions
- **@attempt-history.md** - All attempts and results

## Build Tools

### apktool

**Location**: `/usr/share/java/android-apktool/apktool.jar`

**Command for Arch Linux with AMD Ryzen 7 5700X3D (16 cores, 31GB RAM)**:
```bash
java -Xmx16384M -XX:+UseG1GC -XX:MaxGCPauseMillis=200 \
  -jar /usr/share/java/android-apktool/apktool.jar b \
  -f -j 14 <smali-directory> -o <output.apk>
```

**Settings Breakdown**:
- `-Xmx16384M`: 16GB heap (half system RAM for optimal GC)
- `-XX:+UseG1GC`: G1 Garbage Collector (best for large heaps)
- `-XX:MaxGCPauseMillis=200`: GC pause target (200ms)
- `-j 14`: 14 threads (leave 2 cores for system on 16-core CPU)

**Common Issues**:
- **PNG/JPEG mismatch**: Decompiled resources may have wrong extensions (e.g., bs6.png actually JPEG)
  - Solution: Rename to correct extension or delete non-critical files

**Note**: `/usr/bin/apktool` wrapper script may have issues - use jar directly with full java command

## Quick Commands

```bash
# Decompile
apktool d -f base.apk -o decompiled-smali/
jadx base.apk --deobf -d decompiled-jadx/

# Search
rg "search_term" decompiled-jadx/ -l

# Test smali changes
apktool b . -o ../test.apk
```

See **@CLAUDE.md** for more commands and Phase 1 workflow.
