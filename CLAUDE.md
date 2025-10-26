# CLAUDE.md

**Purpose:** Instructions for Claude Code when working in this repository. Keeps edits reproducible, focused, and reviewable.

**Changelog:** 2025-10-26 - Updated to reflect app family structure. Feature READMEs are the single source of truth.

---

## Repository Mission

Research and develop ReVanced patches through **Smali-first validation**. Every bytecode change must work in raw Smali before porting to ReVanced.

**Current Work**: See feature READMEs in `apps/<app-family>/<feature>/README.md` for status and findings.

---

## Core Principles

1. **Validate in Smali first** - Never modify `revanced-src/revanced-patches/` until proven in smali-tests
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

**Use TodoWrite proactively** for:
- Multi-step Smali validation workflows
- Complex ReVanced patch porting
- Any task with 3+ distinct steps

**Use Task tool (subagent_type=Explore)** when:
- Exploring the codebase for patterns (e.g., "find all share URL handlers")
- Searching across decompiled sources without a specific file target
- Answering "how does X work" questions

**Ask questions** when:
- Multiple approaches are valid and user preference matters
- Requirements are ambiguous
- You need clarification on obfuscation mappings

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

### Documentation (Required after validation)
- Feature `README.md` - Update status, technical details, validation results
- `logs/` - Save test logs with timestamps
- Inline Smali comments - Document register usage, injection points, edge cases

---

## Environment Notes

**Paths in $PATH:**
- `/usr/share/java/smali/` (baksmali/smali)
- `~/Android/Sdk/build-tools/36.1.0/` (zipalign, apksigner)

**Memory limits:** For large DEX assembly, set `SMALI_THREADS=1` and `java -Xmx16G`

**Git commit style:** Conventional commits (`type(scope): summary`)
- `test(tiktok): verify canonical URL patch in UEU.smali:150`
- `docs(smali): update injection points for LJIJJ method`

---

## Safety Guardrails

- **No network requests** unless explicitly asked
- **No background jobs** without notification
- **Report OOM errors** with stderr snippet and suggest alternatives (reduce threads, Java 11)
- **Only stage intentional changes** - use `git add -p` when committing

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
