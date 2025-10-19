# ReVanced Research Repository

## Purpose
Systematic approach to developing ReVanced patches with full documentation and testing. This repository uses proven Smali edits as the foundation, testing everything in raw Smali first, then porting to ReVanced.

## Structure

```
revanced-research/
├── README.md                    # This file
├── attempt-history.md           # Global attempt tracker
├── apps/                        # Version-specific research
│   └── tiktok/
│       └── 36.5.4/
│           ├── base.apk                # Original APK (in .gitignore)
│           ├── apk-metadata.txt        # SHA256 and metadata
│           ├── obfuscation-map.md      # Obfuscated class mappings
│           ├── injection-points.md     # Verified injection points
│           ├── decompiled-jadx/        # JADX output
│           ├── decompiled-smali/       # Smali decompilation
│           ├── smali-tests/            # Smali test builds
│           ├── revanced-builds/        # ReVanced patched builds
│           └── logs/                   # Test run logs
└── revanced-src/
    ├── revanced-patches/        # Submodule (forked)
    └── revanced-cli.jar         # CLI tool
```

## Mission Statement
Ship a working ReVanced patch using proven Smali edits. Test everything in raw Smali first, then port to ReVanced. Document every attempt to avoid circles.

## Key Principles

1. **ALWAYS smali test first** - Never write ReVanced code until Smali edit is proven
2. **Document obfuscated names** - Map every `Lcom/a/b/c;->d` to its purpose
3. **Stage your integration** - One method at a time (LJIJJ first, then LJFF)
4. **Log aggressively initially** - Remove logs only after everything works
5. **Track every attempt** - Update attempt-history.md to avoid circles
6. **Follow ReVanced patterns** - Copy their style exactly

## Quick Start

See `runbook.md` for detailed phase-by-phase instructions.

### Phase 0: Repository Setup (Complete ✅)
- Initialize structure and documentation
- Set up ReVanced submodules
- Study reference patches

### Phase 1: Version-Specific Discovery
- Decompile APK with apktool and jadx
- Create search indices
- Document obfuscated class mappings

### Phase 2: Smali Testing
- Create numbered smali tests (01-*, 02-*, etc.)
- Insert test code and verify
- Document verified injection points

### Phase 3: Staged ReVanced Implementation
- Create fingerprints based on verified Smali
- Stage integration one method at a time
- Test each stage before proceeding

### Phase 4-6: Patterns, Production & Verification
- Reference existing patch patterns
- Clean up debug logging
- Test on multiple versions

## References

- Runbook: `runbook.md` - Complete step-by-step guide
- Attempt History: `attempt-history.md` - Tracks all attempts and results
- Per-version docs in `apps/tiktok/VERSION/`

## Success Factors

- Proven Smali edits before any ReVanced work
- Clear documentation of obfuscation mapping
- Systematic staging of integration
- Comprehensive logging during development
- Meticulous attempt tracking
