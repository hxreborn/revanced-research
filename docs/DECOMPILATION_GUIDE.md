# APK Decompilation Guide

Reverse-engineer Android APKs using `jadx` and `apktool`. This guide documents the actual scripts and workflows in `revanced-research`.

## Quick Start

### 1. Set Up a New Target

```bash
./scripts/setup-workspace.sh com.example.app 1.0.0
# Creates: apps/com.example.app/1.0.0/ with full directory structure
```

### 2. Place Your APK

```bash
cp /path/to/app.apk apps/com.example.app/1.0.0/apk/
sha256sum apps/com.example.app/1.0.0/apk/app.apk > apps/com.example.app/1.0.0/apk/hashes.txt
```

### 3. Run Decompilation (Full Pipeline)

```bash
./docs/templates/scripts/decompile-pipeline.sh com.example.app 1.0.0 apps/com.example.app/1.0.0/apk/app.apk
```

Or manually:

```bash
# Decode resources
apktool -JXmx4g d apps/com.example.app/1.0.0/apk/app.apk -o apps/com.example.app/1.0.0/decode/apktool -f

# Decompile to Java
./scripts/run-jadx.sh apps/com.example.app/1.0.0/apk/app.apk apps/com.example.app/1.0.0
```

## Available Scripts

### `scripts/run-jadx.sh`

Fast JADX decompilation with auto-tuned settings.

```bash
./scripts/run-jadx.sh <apk-path> [output-dir]

# Examples
./scripts/run-jadx.sh app.apk apps/myapp/1.0.0
./scripts/run-jadx.sh ~/downloads/tiktok.apk
```

**Features:**
- Detects CPU cores automatically
- Uses 80% available RAM
- Configurable via environment variables
- Streams output live with timing

**Environment Variables:**

```bash
# Override thread count (default: auto-detect)
export THREADS=4
./scripts/run-jadx.sh app.apk

# Increase timeout (default: 420s = 7 min)
export TIMEOUT_S=900
./scripts/run-jadx.sh large_app.apk

# Disable timeout
export TIMEOUT_S=0
./scripts/run-jadx.sh app.apk
```

### `docs/templates/scripts/decompile-pipeline.sh`

Complete APK analysis pipeline: **apktool** → **jadx** → organized output.

```bash
./docs/templates/scripts/decompile-pipeline.sh <app-id> <version> <apk-path>

# Example
./docs/templates/scripts/decompile-pipeline.sh tiktok 36.5.4 ~/downloads/tiktok.apk
```

**Output structure:**

```
apps/tiktok/36.5.4/
├── apk/
│   ├── tiktok-36.5.4.apk
│   └── hashes.txt
├── decode/
│   ├── apktool/          # Resources, smali, AndroidManifest
│   └── jadx/             # Java decompilation
├── notes/                # Your analysis (journal, fingerprints, etc.)
├── analysis/             # Reports and classifications
└── artifacts/            # Logs and metrics
```

### CFR (Optional - Complementary)

**CFR** is an alternative Java decompiler with different heuristics than jadx. Use it alongside jadx for better code quality in specific scenarios.

**Usage:**

```bash
# Decompile entire APK with CFR
cfr apps/app/1.0.0/apk/app.apk --outputdir apps/app/1.0.0/decode/cfr

# Decompile specific DEX file
cfr classes.dex --outputdir cfr_output

# With deobfuscation
cfr app.apk --outputdir output/ --decompile-concurrency 4
```

**When to use CFR vs jadx:**

| Aspect | jadx | CFR |
|--------|------|-----|
| Speed | ⚡ Faster | 🐢 Slower |
| Code quality | Good | Better for modern Java |
| Lambda expressions | Basic | Excellent |
| Type inference | Standard | Advanced heuristics |
| Coverage | More complete | Some edge cases |
| Large APKs | ✅ Preferred | ⚠️ Slower |

**Typical workflow:** jadx for coverage, CFR for specific suspicious methods.

### `scripts/setup-workspace.sh`

Initialize a new target directory with templates.

```bash
./scripts/setup-workspace.sh <package> <version> [--force]

# Example
./scripts/setup-workspace.sh com.whatsapp 2.24.0
```

Creates full workspace with templates and placeholder README.

## JVM Configuration

### Default Behavior

`run-jadx.sh` automatically:
- Detects available CPU cores
- Allocates 80% of available RAM
- Uses Parallel GC (stable for large heaps)
- Enables deobfuscation (`--deobf`)

### Manual JVM Tuning

Override via `JAVA_TOOL_OPTIONS`:

```bash
# Conservative (smaller systems, 8GB RAM, 4 cores)
export JAVA_TOOL_OPTIONS="-XX:+UseParallelGC -Xms2g -Xmx6g"
./scripts/run-jadx.sh app.apk

# Aggressive (larger systems, 32GB+ RAM, 16+ cores)
export JAVA_TOOL_OPTIONS="-XX:+UseParallelGC -Xms8g -Xmx24g"
./scripts/run-jadx.sh app.apk

# ZGC (experimental, good for very large heaps on modern JVMs)
export JAVA_TOOL_OPTIONS="-XX:+UseZGC -Xms8g -Xmx20g"
./scripts/run-jadx.sh app.apk
```

## Troubleshooting

### JVM Crashes (SIGSEGV)

If you see:
```
SIGSEGV (0xb) at pc=..., pid=..., tid=...
```

Try these in order:

**1. Reduce heap size:**
```bash
export JAVA_TOOL_OPTIONS="-XX:+UseParallelGC -Xms2g -Xmx8g"
./scripts/run-jadx.sh app.apk
```

**2. Use single thread:**
```bash
export THREADS=1
./scripts/run-jadx.sh app.apk
```

**3. Try ZGC garbage collector:**
```bash
export JAVA_TOOL_OPTIONS="-XX:+UseZGC -Xms4g -Xmx12g"
./scripts/run-jadx.sh app.apk
```

**4. Check Java version** (17+ required):
```bash
java -version
```

### Out of Memory

```bash
# Increase max heap
export JAVA_TOOL_OPTIONS="-XX:+UseParallelGC -Xms4g -Xmx16g"
./scripts/run-jadx.sh large_app.apk
```

### Slow Decompilation

```bash
# Use more threads
export THREADS=8
./scripts/run-jadx.sh app.apk

# Or increase timeout
export TIMEOUT_S=1200  # 20 minutes
./scripts/run-jadx.sh app.apk
```

## Performance Benchmarks

Reference: **TikTok 36.5.4** (166K classes, 49 DEX files, 397 MB)

| Metric | Result |
|--------|--------|
| Duration | ~6-7 minutes |
| Output Size | 6.3 GB |
| Java Files | 391,259 |
| Errors | 975 (0.6%) |
| Memory Peak | ~18 GB |
| Status | ✅ Success |

**Command used:**
```bash
export JAVA_TOOL_OPTIONS="-XX:+UseParallelGC -Xms4g -Xmx16g"
./scripts/run-jadx.sh tiktok-36.5.4.apk apps/tiktok/36.5.4
```

## Analysis & Search

### Find Specific Patterns

```bash
# Search for classes
rg "class MainActivity" apps/app/version/decode/jadx/sources/

# Find API endpoints
rg "https?://[a-zA-Z0-9.-]+\.[a-z]+" apps/app/version/decode/jadx/sources/

# Look for crypto operations
rg "Cipher|RSA|AES|encrypt" apps/app/version/decode/jadx/sources/

# Find permissions used
grep 'permission' apps/app/version/decode/apktool/AndroidManifest.xml
```

### Check Decompilation Errors

```bash
# View error log
cat apps/app/version/artifacts/jadx-export.log | grep ERROR | head -20

# Count total errors
grep -c ERROR apps/app/version/artifacts/jadx-export.log
```

### Monitor Resources During Decompilation

In a separate terminal:

```bash
watch -n 1 "free -h && echo '---' && ps aux | grep -i java | grep -v grep"
```

## Known Issues

### High Error Count (e.g., "975 errors")

This is **normal** for obfuscated apps:
- Represents only 0.6% of methods
- Caused by ProGuard/R8 obfuscation, not tool failure
- Actual decompilation completeness: **99.4%**

Use `--show-bad-code` to include problematic methods as comments:

```bash
jadx --show-bad-code --deobf -j 4 -d output/ app.apk
```

### Framework Errors in apktool

```
Can't find framework-res.apk
```

Solution:
```bash
# Let apktool auto-download
apktool d app.apk  # Downloads on first run

# Or manually install
apktool if framework-res.apk
```

## Workflow Example

Complete analysis session:

```bash
# 1. Setup
./scripts/setup-workspace.sh instagram 340.0.0

# 2. Copy APK and verify
cp ~/downloads/instagram.apk apps/instagram/340.0.0/apk/
sha256sum apps/instagram/340.0.0/apk/instagram.apk > apps/instagram/340.0.0/apk/hashes.txt

# 3. Decode resources
apktool -JXmx4g d apps/instagram/340.0.0/apk/instagram.apk \
  -o apps/instagram/340.0.0/decode/apktool -f

# 4. Primary decompilation with jadx (fast, complete coverage)
./scripts/run-jadx.sh apps/instagram/340.0.0/apk/instagram.apk apps/instagram/340.0.0

# 5. Optional: Secondary decompilation with CFR (better heuristics)
cfr apps/instagram/340.0.0/apk/instagram.apk \
  --outputdir apps/instagram/340.0.0/decode/cfr --decompile-concurrency 4

# 6. Start analysis
cd apps/instagram/340.0.0/notes/
vim journal.md  # Log discoveries

# 7. Search for targets
rg "share_link" ../decode/jadx/sources/
rg "share_link" ../decode/cfr/  # Compare with CFR output if unclear

# 8. Compare decompilers for suspicious methods
# Use CFR for advanced type inference, jadx for coverage

# 9. Document findings
vim fingerprints.md    # Candidate patch methods
vim patch-plan.md      # Injection strategy
vim tooling.md         # Tool versions, APK hash, decompiler versions
```

**Note:** Using both jadx and CFR provides better heuristic coverage. jadx is faster for initial exploration, CFR for detailed analysis of suspicious code patterns.

## Further Reading

- [JVM_GC_TROUBLESHOOTING.md](./JVM_GC_TROUBLESHOOTING.md) — Advanced GC debugging
- [AGENTS.md](../AGENTS.md) — Automation workflows and analysis strategies
- [jadx GitHub](https://github.com/skylot/jadx) — Official JADX documentation
- [CFR](https://www.benf.org/other/cfr/) — Alternative decompiler with advanced heuristics
- [apktool GitHub](https://github.com/ibotpeaches/Apktool) — Resource decoding reference
