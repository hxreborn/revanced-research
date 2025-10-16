# APK Decompilation Guide

## Quick Start (Recommended)

For **32GB+ RAM systems**, use the high-performance wrapper:

```bash
# Decompile any APK with optimal settings
jadx-hp --deobf -d output/ app.apk

# Or use the full pipeline (recommended for new targets)
./docs/templates/scripts/decompile-pipeline.sh <app-id> <version> <apk-path>
```

**No configuration needed!** Defaults are optimized for your system.

## Available Wrappers

### 1. `jadx-hp` - High Performance (Recommended)
**Best for:** Systems with 32GB+ RAM and 8+ cores

```bash
jadx-hp --deobf -d output/ app.apk
```

**Features:**
- ✓ Temurin 25 JDK (most stable)
- ✓ Parallel GC (avoids G1 crashes)
- ✓ 24GB max heap
- ✓ 12 threads (optimal for 16-core CPUs)
- ✓ `--show-bad-code` enabled (decompiles more code)
- ✓ Auto-deobfuscation support

**Proven on:** TikTok 36.5.4 (391K files, 6.3GB output, 0 crashes)

### 2. `jadx-safe` - Safe Mode
**Best for:** Systems with 8-16GB RAM or when debugging crashes

```bash
jadx-safe --deobf -d output/ app.apk
```

**Features:**
- ✓ Conservative 2-8GB heap
- ✓ Configurable GC algorithm
- ✓ Optional GC logging for troubleshooting

### 3. `decompile-pipeline.sh` - Full Pipeline
**Best for:** Complete APK analysis workflow

```bash
./docs/templates/scripts/decompile-pipeline.sh tiktok 36.5.4 ~/downloads/tiktok.apk
```

**Features:**
- ✓ Runs both apktool AND jadx
- ✓ Organized output in `apps/<app>/<version>/`
- ✓ SHA-256 hash verification
- ✓ Performance metrics
- ✓ Logs saved for debugging

## Default Settings (High Performance)

Optimized for **CachyOS Linux, 32GB RAM, 16 cores (AMD Ryzen 7 5700X3D)**

| Setting | Default | Why |
|---------|---------|-----|
| JDK | Temurin 25 | Most stable GC, latest features |
| GC Algorithm | Parallel GC | Simpler than G1, avoids SIGSEGV crashes |
| Min Heap | 4 GB | Reduces GC cycles |
| Max Heap | 24 GB | Maximizes available RAM (leaves 8GB for system) |
| Threads | 12 | Optimal for 16 cores (leaves headroom) |
| Deobfuscation | Enabled | Better code readability |
| Show Bad Code | Enabled | Decompiles more classes (fewer errors) |

## Environment Variables

Override defaults for specific needs:

```bash
# Conservative settings for older/smaller systems
export JADX_HEAP_MAX=8g
export JADX_THREADS=4

# Maximum performance (all 16 cores, 28GB RAM)
export JADX_HEAP_MAX=28g
export JADX_THREADS=16

# Use G1 GC instead of Parallel (if you prefer)
export JADX_GC=g1

# Disable show-bad-code
export SHOW_BAD_CODE=false

# Then run your command
jadx-hp --deobf -d output/ app.apk
```

### Complete Variable Reference

| Variable | Default | Options |
|----------|---------|---------|
| `JADX_JDK` | `/usr/lib/jvm/java-25-temurin` | Any JDK 17+ path |
| `JADX_GC` | `parallel` | `parallel`, `g1`, `zgc`, `shenandoah` |
| `JADX_HEAP_MIN` | `4g` | Any size: `512m`, `2g`, etc. |
| `JADX_HEAP_MAX` | `24g` | Any size: `8g`, `16g`, `28g`, etc. |
| `JADX_THREADS` | `12` | `1` to `16` (or your CPU count) |
| `ENABLE_DEOBF` | `true` | `true`, `false` |
| `SHOW_BAD_CODE` | `true` | `true`, `false` |
| `JADX_GC_LOG` | `0` | `1` to enable GC logging |

## Performance Examples

### Small APK (< 50MB)
```bash
# Fast, minimal resources
export JADX_HEAP_MAX=4g
export JADX_THREADS=4
jadx-hp -d output/ small.apk
```

### Medium APK (50-150MB)
```bash
# Balanced (default settings work great)
jadx-hp --deobf -d output/ medium.apk
```

### Large APK (150MB+)
```bash
# Maximum power (default settings)
./docs/templates/scripts/decompile-pipeline.sh app 1.0.0 large.apk
```

### Extreme APK (300MB+, heavily obfuscated)
```bash
# All resources, show all code
export JADX_HEAP_MAX=28g
export JADX_THREADS=14
export SHOW_BAD_CODE=true
jadx-hp --deobf --show-bad-code -d output/ extreme.apk
```

## Troubleshooting

### Still Getting Crashes?

1. **Try ZGC** (best for very large heaps):
   ```bash
   export JADX_GC=zgc
   jadx-hp --deobf -d output/ app.apk
   ```

2. **Reduce heap size**:
   ```bash
   export JADX_HEAP_MAX=16g
   jadx-hp --deobf -d output/ app.apk
   ```

3. **Single threaded** (eliminates concurrency issues):
   ```bash
   export JADX_THREADS=1
   jadx-hp --deobf -d output/ app.apk
   ```

4. **Enable GC logging**:
   ```bash
   export JADX_GC_LOG=1
   jadx-hp --deobf -d output/ app.apk
   # Check gc-*.log file for issues
   ```

### Error: "975 errors" or Similar

This is **normal** for obfuscated apps! The 975 errors from TikTok represent:
- **0.6% error rate** (99.4% success)
- Heavily obfuscated code that can't be fully recovered
- Dead code or invalid bytecode

With `--show-bad-code`, jadx decompiles these as comments, which is better than nothing.

### See Also

- [JVM_GC_TROUBLESHOOTING.md](./JVM_GC_TROUBLESHOOTING.md) - Deep dive into GC issues
- [AGENTS.md](../AGENTS.md) - Automation and analysis tools
- [test-jadx-config.sh](../test-jadx-config.sh) - Verify your setup

## Output Structure

Using `decompile-pipeline.sh`:

```
apps/<app>/<version>/
├── apk/
│   ├── <app>-<version>.apk     # Original APK
│   └── hashes.txt               # SHA-256 checksum
├── decode/
│   ├── apktool/                 # Resources, smali, AndroidManifest.xml
│   └── jadx/                    # Java source code
│       ├── sources/             # Decompiled .java files
│       └── resources/           # Resources
├── artifacts/
│   ├── apktool-decode.log       # apktool output
│   ├── jadx-export.log          # jadx output (check for errors)
│   └── decompile-performance.txt # Timing and stats
├── notes/                       # Your analysis notes
└── scripts/                     # Analysis scripts
```

## Tips & Best Practices

### 1. Always Use Deobfuscation
```bash
jadx-hp --deobf -d output/ app.apk
```
Renames obfuscated classes from `a.b.c.d` to meaningful names.

### 2. Check Logs for Real Errors
```bash
# 975 "errors" might just be obfuscated code
grep ERROR apps/app/version/artifacts/jadx-export.log | head -20
```

### 3. Large APKs: Use the Pipeline
The pipeline script handles everything and saves logs:
```bash
./docs/templates/scripts/decompile-pipeline.sh youtube 19.0.0 youtube.apk
```

### 4. Search Decompiled Code
```bash
# Find specific classes
rg "class MainActivity" apps/app/version/decode/jadx/

# Find string literals
rg "api.example.com" apps/app/version/decode/jadx/
```

### 5. Monitor System Resources
```bash
# While jadx runs in another terminal:
watch -n1 "free -h && echo && ps aux | grep java | grep -v grep"
```

## Benchmarks

**TikTok 36.5.4** (166K classes, 49 DEX files):
- **Duration:** ~6 minutes
- **Output:** 6.3 GB (391K Java files)
- **Memory:** Peak 18GB
- **CPU:** ~12 cores utilized
- **Errors:** 975 (0.6%)
- **Crashes:** 0 ✓

**Settings used:** `jadx-hp` defaults (Temurin 25, Parallel GC, 24GB heap, 12 threads)

## FAQ

**Q: Why Parallel GC instead of G1?**
A: G1 has known SIGSEGV bugs with large heaps (20GB+) in OpenJDK 17.x. Parallel GC is simpler and more stable.

**Q: Can I use my system Java instead of Temurin?**
A: Yes, but Temurin 21+ is recommended. Set `export JADX_JDK=/usr/lib/jvm/java-21-openjdk`

**Q: What if I only have 16GB RAM?**
A: Use `jadx-safe` or set `export JADX_HEAP_MAX=8g` with `jadx-hp`

**Q: Should I always use --deobf?**
A: Yes, unless you specifically want to see obfuscated names. Performance impact is minimal.

**Q: What does --show-bad-code do?**
A: Forces jadx to generate code even for methods it can't fully decompile (as comments). Reduces error count.

---

**Last Updated:** Based on TikTok 36.5.4 decompilation success (Oct 2025)
**Tested On:** CachyOS Linux, 32GB RAM, AMD Ryzen 7 5700X3D (16 cores)
