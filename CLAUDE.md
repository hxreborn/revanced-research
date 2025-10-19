# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ReVanced patch development research repository. The workflow is: **test everything in raw Smali first**, then port proven edits to ReVanced patches. Never write ReVanced code until Smali modifications are verified working.

Current target: TikTok 36.5.4 share URL cleaning (remove utm_*, tt_*, enter_* tracking parameters)

## Repository Architecture

```
revanced-research/
├── apps/tiktok/36.5.4/          # Version-specific workspace
│   ├── base.apk                  # Original APK (gitignored)
│   ├── apk-metadata.txt          # SHA256 + version info
│   ├── decompiled-jadx/          # JADX output (Java, gitignored)
│   ├── decompiled-smali/         # apktool output (Smali, gitignored)
│   ├── smali-tests/              # Test builds (gitignored)
│   │   ├── 01-*/                 # Numbered iterations
│   │   └── smali-validated/      # Final validated test
│   ├── revanced-builds/          # Patched APKs (gitignored)
│   ├── logs/                     # Test logs (gitignored)
│   ├── indices/                  # Search indices (gitignored)
│   ├── obfuscation-map.md        # Class name mappings (created in Phase 1)
│   └── injection-points.md       # Verified points (created in Phase 2)
└── revanced-src/
    ├── revanced-patches/         # Git submodule
    │   ├── patches/src/main/kotlin/app/revanced/patches/
    │   └── extensions/tiktok/    # Integration helpers
    └── revanced-cli.jar          # Patching tool
```

**Key Insight**: `apps/tiktok/36.5.4/` contains your research workspace. Smali tests happen here. Only after validation do you touch `revanced-src/`.

## Development Workflow

### Phase 1: Version-Specific Discovery
```bash
cd apps/tiktok/36.5.4

# Decompile APK
apktool d -f base.apk -o decompiled-smali/
jadx base.apk --deobf -d decompiled-jadx/

# Build search indices for target discovery
rg "share\|link\|url" decompiled-jadx/ > indices/strings.txt
rg "onClick\|button\|clip" decompiled-jadx/ > indices/handlers.txt

# Document obfuscated class mappings in obfuscation-map.md
# Map Lcom/ss/android/ugc/aweme/share/improve/pkg/LinkSharePackage; to purpose
```

### Phase 2: Smali Testing (CRITICAL)
```bash
cd apps/tiktok/36.5.4

# Create numbered test iteration
TEST_NUM="01-ljijj-bundle"
cp -r decompiled-smali/ smali-tests/$TEST_NUM/
cd smali-tests/$TEST_NUM/

# Edit target smali file
vim smali_classes3/com/ss/android/ugc/aweme/share/improve/pkg/LinkSharePackage.smali

# Insert test logs + hardcoded modification
# Add after target instruction (e.g., after "const-string v3, share_url"):
#   const-string v0, "HOTSWAP_TEST"
#   const-string v1, "URL before: ..."
#   invoke-static {v0, v1}, Landroid/util/Log;->d(...)
#   const-string v4, "https://vm.tiktok.com/CLEANED_TEST"

# Build test APK
apktool b . -o ../test.apk
cd ..
zipalign -v 4 test.apk test-aligned.apk
apksigner sign --ks ~/.android/debug.keystore --ks-pass pass:android test-aligned.apk

# Install and verify
adb install -r test-aligned.apk
adb logcat -c
# Trigger share action in app
adb logcat -d | tee ../logs/test-$(date +%Y%m%d-%H%M%S).log | grep "HOTSWAP_TEST"
```

**Do not proceed to Phase 3 until Smali test succeeds.**

### Phase 3: Staged ReVanced Implementation

Only after `smali-tests/smali-validated/` proves both methods work together:

```bash
cd revanced-src/revanced-patches
git checkout -b feat/tiktok-clean-urls

# Stage 1: Single method only (LJIJJ)
# Create fingerprint: patches/src/main/kotlin/app/revanced/patches/tiktok/share/fingerprints/LjijjBundleFingerprint.kt
# Create patch: patches/src/main/kotlin/app/revanced/patches/tiktok/share/CleanShareUrlsPatch.kt

./gradlew :patches:build

# Test Stage 1
cd ../../apps/tiktok/36.5.4
java -jar ../../../revanced-src/revanced-cli.jar patch \
    --patch "Clean share URLs - Stage 1" \
    --merge ../../../revanced-src/revanced-integrations.apk \
    --out revanced-builds/stage1.apk \
    base.apk

adb install -r revanced-builds/stage1.apk
adb logcat | grep "STAGE1"

# Stage 2: Add second method (LJFF) only after Stage 1 works
# Update fingerprint set and patch logic
# Test Stage 2 the same way
```

**Staged integration rule**: One method at a time. LJIJJ first, then LJFF.

## Essential Commands

### Search & Discovery
```bash
# Always use ripgrep for code searching
rg "search_term" decompiled-jadx/ -l           # List files with matches
rg "share_url" decompiled-jadx/ -A 5 -B 5      # Show context
rg "Lcom/ss/android" decompiled-smali/ --type smali  # Smali search

# View specific smali method
cat decompiled-smali/smali_classes3/com/ss/android/ugc/aweme/share/improve/pkg/LinkSharePackage.smali
```

### Build & Test Smali
```bash
# From smali-tests/01-*/
apktool b . -o ../test.apk
zipalign -v 4 ../test.apk ../test-aligned.apk
apksigner sign --ks ~/.android/debug.keystore --ks-pass pass:android ../test-aligned.apk
adb install -r ../test-aligned.apk
```

### Build ReVanced Patch
```bash
cd revanced-src/revanced-patches
./gradlew :patches:build

# Patch APK
cd ../../apps/tiktok/36.5.4
java -jar ../../../revanced-src/revanced-cli.jar patch \
    --patch "Patch Name" \
    --out revanced-builds/patched.apk \
    base.apk
```

### Testing & Logging
```bash
adb logcat -c                                  # Clear logs
adb logcat -d > logs/test-$(date +%Y%m%d-%H%M%S).log  # Dump to file
adb logcat | grep "TAG"                        # Live filtering
```

## Critical Development Rules

1. **ALWAYS Smali test first** - Never write ReVanced code until Smali edit is proven working in `smali-tests/`
2. **Stage integration** - One method at a time (LJIJJ first, verify, then add LJFF)
3. **Document obfuscation** - Map every `Lcom/a/b/c;->d` to its purpose in `obfuscation-map.md`
4. **Log aggressively** - Remove logs only after everything works in production
5. **Track attempts** - Update `attempt-history.md` after each phase to avoid circles
6. **Verify APK SHA256** - Check `apk-metadata.txt` before starting work on a version

## Naming Conventions

**Test directories:**
- `smali-tests/01-ljijj-bundle/` - First test (descriptive name)
- `smali-tests/02-ljff-builder/` - Second test
- `smali-tests/smali-validated/` - Final combined test before ReVanced port

**Documentation files:**
- `obfuscation-map.md` - Obfuscated class mappings with verification status (❓/✅)
- `injection-points.md` - Verified injection points with line numbers, registers, try-catch info
- `attempt-history.md` - Global attempt tracker (date, target, method, result, next step)
- `apk-metadata.txt` - APK SHA256, version, package name

**Log files:**
- `logs/smali-test-01-ljijj-bundle-20241225-150000.log`
- `logs/stage1-ljijj-only-20241225-160000.log`

## Git Workflow

### Conventional Commits
Always use conventional commit format:

```bash
# Research commits (main repo)
git commit -m "test(tiktok): verify LJIJJ injection on 36.5.4"
git commit -m "docs(tiktok): add injection-points for share URL cleaning"
git commit -m "feat(tiktok): add smali-validated test with both methods"

# Submodule commits (revanced-patches)
cd revanced-src/revanced-patches
git commit -m "feat(tiktok): add share URL sanitizer patch"
git commit -m "fix(smali): correct register allocation in LJFF method"

# Update parent after submodule changes
cd ../..
git commit -m "chore(patches): update submodule for tiktok clean URLs"
```

Prefix: `feat|fix|chore|test|docs|refactor`

### Submodule Development
```bash
cd revanced-src/revanced-patches
git checkout -b feature/tiktok/clean-share-urls
# Make changes
git push -u origin feature/tiktok/clean-share-urls

cd ../..
git add revanced-src/revanced-patches
git commit -m "chore(patches): update submodule for feature branch"
```

## Common Pitfalls & Solutions

**Fingerprint not matching?**
- Did smali test pass? If no, fix Smali first, don't touch ReVanced
- Check strings are exact: `rg "exact_string" decompiled-jadx/`
- Verify return type in jadx decompilation
- Try removing opcodes, keep only strings + returnType

**Patch crashes app?**
- Wrong register used? Check `.locals N` in method header
- Inside try-catch violation? Check `.catch` directives range
- Register clobbered? Use different registers (v5-v7 if v0-v4 taken)

**Can't find target in obfuscated code?**
- Search by user-visible strings: "Link copied", "Share"
- Search by Android APIs: "ClipboardManager", "Intent.putExtra"
- Search network strings: API endpoints rarely change
- Check existing ReVanced patches for same app

## Important Notes

- **File sizes**: APKs, decompiled code, and build outputs are gitignored
- **APK verification**: Always verify SHA256 in `apk-metadata.txt` before decompilation
- **Logs**: Keep all test logs for debugging and documentation
- **ReVanced patterns**: Study existing patches in `revanced-src/revanced-patches/patches/src/` for reference
- **Register allocation**: Smali registers are version-specific; document in `injection-points.md`
- **Multi-version testing**: Test on multiple app versions after production-ready (36.5.4, 36.6.0, etc.)

## References

- **Main workflow**: See [WORKFLOW.md](WORKFLOW.md) for complete phase-by-phase instructions
- **Attempt tracking**: See [attempt-history.md](attempt-history.md) for all attempts and learnings
- **Version workspace**: `apps/tiktok/36.5.4/` for current target
- **Submodule source**: https://github.com/hxreborn/revanced-patches
