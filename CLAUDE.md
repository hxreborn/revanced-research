# CLAUDE.md

Instructions for Claude Code when working in this repository. Keeps edits reproducible, focused, and reviewable.

Changelog: 2025-10-30 - flexible methodology, CLAUDE.md style applied to feature READMEs.

---

## Repository Mission

Research and develop ReVanced patches through **Smali-first validation**. Every bytecode change must work in raw Smali before porting to ReVanced.

**Current Work**: See feature READMEs in `apps/<app-family>/<feature>/README.md` for status and findings.

---

## Core Principles

1. **Flexible approach** - Validate approach based on task (Smali-first for risky changes, direct ReVanced for straightforward patches)
2. **No APK artifacts in git** - Track metadata via .info/.sha256 files (gitignore exceptions), never commit binaries
3. **Surgical edits** - Prefer targeted DEX injection (baksmali → smali) over full apktool rebuilds
4. **Keep READMEs current** - Update feature README with injection points, findings, and validation results as you work

---

## Workspace Boundaries

Structure: `apps/<app-family>/{apks,<feature>}/`

| Directory | Access | Tracked | Purpose |
|-----------|--------|---------|---------|
| `apps/<app-family>/apks/<version>/<package>.apk.{info,sha256}` | R/W | ✓ | APK metadata |
| `apps/<app-family>/<feature>/README.md` | R/W | ✓ | Single source of truth: status, findings, validation results |
| `apps/<app-family>/<feature>/<version>/files/` | R/W | ✓ | Reference smali for documentation |
| `apps/<app-family>/apks/<version>/<package>.apk` | R/W | ✗ | APK binaries - local only |
| `apps/<app-family>/apks/<version>/{apktool,jadx}/` | R/W | ✗ | Decompilation outputs - local only |
| `apps/<app-family>/<feature>/<version>/smali-tests/` | R/W | ✗ | Smali test outputs - local only |
| `apps/<app-family>/<feature>/<version>/logs/` | R/W | ✗ | Test logs - local only |
| `revanced-src/revanced-patches/` | R | - | Upstream port (read-only after Smali validation) |

Example: `apps/tiktok/` contains APKs (com.zhiliaoapp.musically, com.ss.android.ugc.trill) and features (share-url-sanitization, downloads)

---

## Task Management

- **TodoWrite:** Multi-step workflows, 3+ distinct steps
- **Task tool (Explore):** Codebase patterns, cross-file searches, architecture questions
- **Ask questions:** When multiple approaches exist, requirements unclear, or obfuscation mappings need clarification

---

## Development Workflow

### Discovery (Read-only, local workspace)
```bash
# Generate decompilation locally (JADX/apktool are gitignored)
cd apps/tiktok/apks/36.5.4/
jadx -d jadx-deobf com.ss.android.ugc.trill.apk
apktool d com.ss.android.ugc.trill.apk -o apktool

# Search decompilation for patterns
rg "<pattern>" jadx-deobf/ apktool/

# Verify in Smali tests (local only)
rg "<pattern>" ../../share-url-sanitization/36.5.4/smali-tests/*/smali-classes*/
```

### Smali Testing
Detailed commands in `WORKFLOW.md` Phase 2:
1. Extract target DEX: `unzip -j <package>.apk classes15.dex`
2. Decompile: `baksmali d classes15.dex -o smali-classes15/`
3. Edit smali, add verification logs
4. Recompile: `smali a smali-classes15/ -o classes15-patched.dex --api 35`
5. Inject: `zip -j patched.apk classes15-patched.dex`
6. Sign: `zipalign` → `apksigner`

**Note:** smali-tests/ outputs are gitignored. After validation, copy reference files to `apps/<app-family>/<feature>/<version>/files/` for git tracking.

### ReVanced Patch Application

After updating patches in `revanced-src/revanced-patches/`:
```bash
# Build patches
cd revanced-src/revanced-patches
./gradlew build

# Apply patches (use -p SPACE path, NOT -p=path)
java -jar revanced-src/revanced-cli.jar patch \
  -p revanced-src/revanced-patches/patches/build/libs/patches-X.Y.Z.rvp \
  apps/<app-family>/apks/<version>/<package>.apk

# Optional flags:
# -e <patch-name>  Enable specific patch
# -d <patch-name>  Disable specific patch
# -o <output.apk>  Output path (defaults to <package>-patched.apk)
# -i               Install to connected ADB device
# --exclusive      Disable all patches except -e enabled ones
```

**CRITICAL:** Use `-p <path>` with SPACE, not `-p=<path>` or `--patches=<path>`. CLI v5.0.1 fails silently with `=` syntax.

Output: `<package>-patched.apk` in same directory as input APK.

### Documentation (Required after validation)
- Feature `README.md` - Update status, technical details, validation results
- `logs/` - Save test logs with timestamps
- Inline Smali comments - Document register usage, injection points, edge cases

---

## Code Comments

**Inline comments:** Capture why, not what. Reference logical sections/methods, not line numbers. One idea per sentence, max two sentences. Examples:
- ✓ "Intercept after URL builder so tracking never executes"
- ✗ "Get item at line 369 and check if null"

**Style:** Use facts only - no marketing ("elegant", "production-ready"), pronouns ("we", "our"), or decorative flair (emojis, ASCII art).

**External docs:** Full analysis, design rationale, research notes - if more than 2 lines, move to documentation.

**Future work:** Only TODO if addressing in next few commits; move longer-term concerns to issues.

---

## Environment Notes

**Paths in $PATH:**
- `/usr/share/java/smali/` (baksmali/smali)
- `~/Android/Sdk/build-tools/36.1.0/` (zipalign, apksigner)

**apktool usage:** Use Java 11 with increased heap for large DEX processing:
```bash
export JAVA_HOME="/usr/lib/jvm/java-11-openjdk"
java -Xmx20g -Xms8g -jar "/usr/share/java/android-apktool/apktool.jar" d <apk-file>
```

**Memory limits:** For large DEX assembly, set `SMALI_THREADS=1` and `java -Xmx16G`

**Git commit style:** Conventional commits (`type(scope): summary`)
- `test(tiktok): verify canonical URL patch in UEU.smali:150`
- `docs(smali): update injection points for LJIJJ method`

---

## Upstream PR Guidelines

When porting patches to [ReVanced Patches](https://github.com/ReVanced/revanced-patches):

1. **Target branch**: Always PR to `dev` branch, never `main`
2. **Smali validation**: Include reference smali files and validation results from `apps/<app-family>/<feature>/<version>/files/`
3. **Test evidence**: Document device testing (app version, platform, results) in PR description
4. **Extension code**: Provide clean extension implementations with proper error handling
5. **Code style**: Follow ReVanced patterns - match existing Kotlin style, use consistent naming
6. **Documentation**: Fingerprints must be precise, include alternatives if fuzzy matching needed
7. **Register spacing**: Add spacing around register references in invoke instructions for readability

---

## Quick Reference

Tracked in Git:
- `apps/<app-family>/<feature>/README.md`
- `apps/<app-family>/<feature>/<version>/files/*.smali`
- `apps/<app-family>/apks/<version>/<package>.apk.info`
- `apps/<app-family>/apks/<version>/<package>.apk.sha256`

Local workspace gitignored:
- `apps/<app-family>/<feature>/<version>/smali-tests/`
- `apps/<app-family>/<feature>/<version>/logs/`
- `apps/<app-family>/apks/<version>/<package>.apk`
- `apps/<app-family>/apks/<version>/{apktool,jadx}/`
