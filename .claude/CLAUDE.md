# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

`revanced-research` is a **reverse-engineering workspace** for analyzing Android APKs to support ReVanced patch development. It maintains a clean, reproducible environment isolated from the main `revanced-patches/` repository. Output includes decompiled sources, decoded resources, and detailed analysis notes—no patched APKs are generated here.

**Key principle:** All findings are documented for traceability (APK hashes, tool versions, commands) so analyses can be reproduced and compared across runs.

## Architecture & Workflow

### High-Level Flow

1. **APK Acquisition** → `apps/<package>/<version>/apk/` (hash verified)
2. **Resource Decode** → `apktool -JXmx4g d` → `apps/<package>/<version>/decode/apktool/`
3. **Bytecode Decompile** → `jadx --threads-count 4 --deobf` → `apps/<package>/<version>/decode/jadx/`
4. **Analysis & Documentation** → Notes in `apps/<package>/<version>/notes/` (fingerprints, patch plans, journal)
5. **Distilled Output** → Push only fingerprints/offsets back to `revanced-patches/`

### Directory Structure

```
revanced-research/
├── AGENTS.md              # Reverse-engineering playbook (Conventional Commits, RE workflow)
├── README.md              # Project overview
├── CONTRIBUTING.md        # Contribution guidelines
├── docs/
│   ├── templates/         # Markdown templates (journal.md, fingerprints.md, patch-plan.md, tooling.md)
│   ├── DECOMPILATION_GUIDE.md
│   └── JVM_GC_TROUBLESHOOTING.md
├── scripts/
│   ├── check-tools.sh     # Validates Java, apktool, jadx, Android tools, Frida, ripgrep, disk/memory
│   ├── run-jadx.sh        # JADX decompilation with auto-tuned GC (ParallelGC, 80% RAM, all cores)
│   ├── cleanup.sh         # Removes decode/, artifacts/, tmp/ safely
│   ├── deobfuscate.py     # Basic class purpose analyzer
│   └── advanced_deobf.py  # API pattern classifier (network, crypto, db, media, etc.)
├── apps/
│   └── <package>/<version>/
│       ├── apk/           # Pristine APKs (MUST NOT commit .apk files)
│       ├── decode/
│       │   ├── apktool/   # Resources, smali, manifest (gitignored)
│       │   └── jadx/      # Java sources, resources (gitignored)
│       ├── notes/         # journal.md, fingerprints.md, patch-plan.md, tooling.md
│       ├── artifacts/     # Dumps, screenshots, payloads (gitignored)
│       └── tmp/           # Scratch space (gitignored)
```

## Common Commands

### Setup & Validation

```bash
# Validate toolchain
./scripts/check-tools.sh

# Create new target workspace
mkdir -p apps/<package>/<version>/{apk,decode/{apktool,jadx},notes,artifacts,tmp}
cp docs/templates/*.md apps/<package>/<version>/notes/
```

### Decompilation (Primary Workflow)

```bash
# Decode APK resources (requires ~4-6x APK size disk space)
apktool -JXmx4g d -o apps/<package>/<version>/decode/apktool apps/<package>/<version>/apk/<app>.apk

# Decompile to Java (auto-detects cores, uses 80% RAM, enables deobfuscation)
./scripts/run-jadx.sh apps/<package>/<version>/apk/<app>.apk apps/<package>/<version>

# Or manually (useful if tuning GC for crash recovery):
# - ParallelGC: stable for large heaps, simple, older JVMs
# - G1GC: good for <16GB heaps, modern JVMs
# - ZGC: latest, best for >20GB heaps (but can crash—use if ParallelGC fails)
export JAVA_HOME=/usr/lib/jvm/java-25-temurin
export JAVA_TOOL_OPTIONS="-XX:+UseG1GC -Xms4g -Xmx16g"
jadx --deobf --no-debug-info -j 8 -d apps/<package>/<version>/decode/jadx apps/<package>/<version>/apk/<app>.apk
```

### Analysis & Search

```bash
# Fast source code search (ripgrep)
rg "share_link" apps/<package>/<version>/decode/jadx/sources/
rg "api.*share" apps/<package>/<version>/decode/apktool/smali/

# Find classes by pattern
rg "class.*ShareService" apps/<package>/<version>/decode/jadx/

# Extract strings
rg -o '"([^"]{10,})"' apps/<package>/<version>/decode/jadx/sources/ | sort -u

# Find method descriptors
rg "Lcom/example/Class;->method\(" apps/<package>/<version>/decode/jadx/
```

### Cleanup

```bash
# Safe cleanup (removes large decode/ artifacts/)
./scripts/cleanup.sh

# Or manually
find targets -name "decode" -type d -exec rm -rf {} \; 2>/dev/null
```

## Key Tools & Versions

| Tool | Rec. Version | Purpose | Notes |
|------|--------------|---------|-------|
| Java | 17+ | ReVanced requirement | Temurin 21/25 preferred |
| apktool | 2.12+ | Decode resources → smali, resources, manifest | Use `-JXmx4g` for large APKs |
| jadx | 1.5+ | Decompile DEX → Java | Use `--deobf` for obfuscated code; supports GUI (`jadx-gui`) |
| dex2jar | 2.4+ | DEX ↔ JAR conversion | Optional; alternative to jadx for certain tasks |
| ripgrep (`rg`) | latest | Fast code search | Better than grep for large codebases |
| fd | latest | Fast file finding | Better than find for patterns |
| Android SDK | latest | adb, zipalign, apksigner | For device deployment & validation |
| Frida | optional | Runtime instrumentation | For method hooking, dynamic analysis |
| jq | latest | JSON parsing | For API responses, config parsing |

Log exact versions used in `apps/<package>/<version>/notes/tooling.md` for reproducibility.

## Known Issues & Troubleshooting

### JADX Crashes During Decompilation

**Problem:** SIGSEGV in GC threads (Parallel/Z/G1GC) when decompiling large APKs (300MB+).

**Solution sequence:**
1. Try **G1GC** with conservative heap: `JAVA_TOOL_OPTIONS="-XX:+UseG1GC -Xms4g -Xmx16g"` (usually works)
2. If still crashes, reduce threads: `-j 4` or `-j 1`
3. Last resort: Split DEX files, process packages individually

See `docs/JVM_GC_TROUBLESHOOTING.md` for detailed diagnosis.

### apktool Framework Errors

**Problem:** `Can't find framework-res.apk` error when decoding certain APKs.

**Solution:**
```bash
# Framework gets auto-downloaded, but you can preinstall:
apktool if framework-res.apk  # if command
# Or place in ~/.local/share/apktool/framework/
```

### Out of Memory with Large APKs

- Increase system swap
- Reduce `jadx` threads: `--threads-count 2`
- Use separate machine with more RAM
- Process critical packages only (use smali for verification)

## Important Practices

### Determinism & Traceability

- **Always log APK hash** before processing:
  ```bash
  sha256sum apps/<package>/<version>/apk/<app>.apk > apps/<package>/<version>/apk/hashes.txt
  ```
- **Pin tool versions** in `apps/<package>/<version>/notes/tooling.md`
- **Remove `decode/*` before re-running** to avoid stale analysis
- **Commit fingerprints and findings**, not large outputs

### .gitignore Rules

The following are ignored (large, ephemeral):
- `apps/*/*/decode/` — decompilation output
- `apps/*/*/artifacts/` — dumps, payloads
- `apps/*/*/tmp/` — scratch space
- `apps/*/*/apk/*.apk` — pristine APKs (log hashes instead)
- `hs_err_pid*.log` — JVM crash logs
- `*.log`, `*.tmp`, `*.bak`

### Commit Style

Use **Conventional Commits** (max 72 chars, one line, no body):

```
<type>(<scope>): <imperative verb>
```

**Types:** `feat`, `fix`, `docs`, `refactor`, `chore`, `test`, `build`, `ci`
**Scope:** app name or doc area (e.g., `tiktok`, `agents`, `tools`)
**Examples:**
- `docs(agents): add decompilation troubleshooting`
- `feat(tiktok): add share link analyzer`
- `fix(jadx): handle ZGC crash recovery`
- `chore: update apktool to 2.12`

## Per-Target Documentation

Each target needs four core notes (templates in `docs/templates/`):

1. **`journal.md`** — Daily log of discoveries, commands run, issues encountered
2. **`fingerprints.md`** — Candidate methods for patching (with descriptors, smali offsets)
3. **`patch-plan.md`** — Injection strategy, dependencies, side effects
4. **`tooling.md`** — APK hash, tool versions, CLI flags, performance metrics

Update these as you analyze so future runs (or other agents) can quickly understand the landscape.

## Integration with revanced-patches

When analysis is complete:
1. Extract **method descriptors** (e.g., `Lcom/example/Share;->buildLink(Ljava/lang/String;)Ljava/lang/String;`)
2. Extract **smali offsets** or **bytecode patterns** for stable matching
3. Document **dependencies** (e.g., "runs after UI patch")
4. Push findings to `revanced-patches/` as a patch outline, not raw decompiled code

**Do NOT commit** full sources, APKs, or decode outputs to this repo.

## Reference

- **AGENTS.md** — Full reverse-engineering playbook with workflow details
- **README.md** — Project overview and setup
- **docs/DECOMPILATION_GUIDE.md** — Detailed decompilation instructions
- **docs/JVM_GC_TROUBLESHOOTING.md** — GC crash diagnosis & recovery
