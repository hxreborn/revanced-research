# JVM GC Troubleshooting for jadx

## Problem

When decompiling large APKs with jadx, you may encounter JVM crashes with `SIGSEGV` errors in G1 GC threads:

```
SIGSEGV (0xb) at pc=0x00007efcf776bb09, pid=1888729, tid=1888856
Current thread: ConcurrentGCThread "G1 Conc#2"
```

This is typically caused by:
- **Large heap sizes** (~20+ GB) triggering G1 GC edge cases
- **Humongous objects** (large byte arrays, maps) from APK processing
- **G1 region management** bugs in certain OpenJDK builds
- **Specific OpenJDK versions** with known G1 bugs (e.g., 17.0.16)

## Quick Fixes (Ordered by Effectiveness)

### 1. Switch to a Different JDK Build (Highest Success Rate)

**Recommended:** Use Eclipse Temurin or newer OpenJDK versions
```bash
# Option A: Use Temurin 25 (most stable for large heaps)
export JADX_JDK=/usr/lib/jvm/java-25-temurin

# Option B: Use OpenJDK 21
export JADX_JDK=/usr/lib/jvm/java-21-openjdk

# Then run your decompilation
./docs/templates/scripts/decompile-pipeline.sh tiktok 36.5.4 path/to/app.apk
```

### 2. Change Garbage Collector

If switching JDK doesn't help, try a different GC algorithm:

```bash
# Parallel GC (good for throughput, less complex than G1)
export JADX_GC=parallel
./docs/templates/scripts/decompile-pipeline.sh tiktok 36.5.4 path/to/app.apk

# ZGC (for JDK 17+, excellent for large heaps)
export JADX_GC=zgc
./docs/templates/scripts/decompile-pipeline.sh tiktok 36.5.4 path/to/app.apk
```

### 3. Reduce Heap Size

Limit heap to reduce G1 region count and humongous object pressure:

```bash
export JADX_HEAP_MIN=2g
export JADX_HEAP_MAX=8g
./docs/templates/scripts/decompile-pipeline.sh tiktok 36.5.4 path/to/app.apk
```

### 4. Reduce jadx Concurrency

Lower thread count reduces allocation pressure:

```bash
export JADX_THREADS=1  # or 2
./docs/templates/scripts/decompile-pipeline.sh tiktok 36.5.4 path/to/app.apk
```

## Advanced Troubleshooting

### Enable GC Logging

To diagnose the exact GC issue:

1. Edit `/home/rafa/.local/bin/jadx-safe` and set:
   ```bash
   export JADX_GC_LOG=1
   jadx-safe --threads-count 1 --deobf -d output/ app.apk
   ```

2. Check the generated `gc-*.log` file for patterns like:
   - Frequent "Humongous allocation" messages
   - Long "To-space exhausted" events
   - Excessive "G1 concurrent cycle" durations

### Disable Class Data Sharing (CDS)

Rule out CDS archive corruption:

```bash
# Add to JVM_OPTS in decompile-pipeline.sh
JVM_OPTS+=("-Xshare:off")
```

### Manual jadx Invocation

For maximum control, use the wrapper directly:

```bash
# Using jadx-safe wrapper
JADX_JDK=/usr/lib/jvm/java-25-temurin \
JADX_GC=parallel \
JADX_HEAP_MIN=2g \
JADX_HEAP_MAX=8g \
jadx-safe --threads-count 1 --deobf -d output/ app.apk

# Or set JAVA_TOOL_OPTIONS manually
JAVA_HOME=/usr/lib/jvm/java-25-temurin \
JAVA_TOOL_OPTIONS="-Xms2g -Xmx8g -XX:+UseParallelGC" \
jadx --threads-count 1 --deobf -d output/ app.apk
```

## Configuration Reference

### decompile-pipeline.sh Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `JADX_JDK` | `/usr/lib/jvm/java-25-temurin` | JDK path to use |
| `JADX_GC` | `g1` | GC algorithm: `g1`, `parallel`, `zgc` |
| `JADX_HEAP_MIN` | `2g` | Minimum heap size |
| `JADX_HEAP_MAX` | `8g` | Maximum heap size |
| `JADX_THREADS` | `4` | jadx thread count |
| `ENABLE_DEOBF` | `false` | Enable deobfuscation |
| `APKTOOL_HEAP` | `4g` | apktool heap size |

### jadx-safe Wrapper Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `JADX_JDK` | `/usr/lib/jvm/java-25-temurin` | JDK path |
| `JADX_GC` | `g1` | GC: `g1`, `parallel`, `zgc`, `shenandoah` |
| `JADX_HEAP_MIN` | `2g` | Min heap |
| `JADX_HEAP_MAX` | `8g` | Max heap |
| `JADX_GC_LOG` | `0` | Set to `1` for GC logging |

## Recommended Combinations for Large APKs (100+ MB)

### Conservative (Most Stable)
```bash
export JADX_JDK=/usr/lib/jvm/java-25-temurin
export JADX_GC=parallel
export JADX_HEAP_MAX=8g
export JADX_THREADS=1
```

### Balanced (Good Performance + Stability)
```bash
export JADX_JDK=/usr/lib/jvm/java-21-openjdk
export JADX_GC=g1
export JADX_HEAP_MAX=12g
export JADX_THREADS=2
```

### Performance (If No Crashes)
```bash
export JADX_JDK=/usr/lib/jvm/java-25-temurin
export JADX_GC=zgc
export JADX_HEAP_MAX=16g
export JADX_THREADS=4
```

## System Information

When reporting issues, include:

```bash
# Java version
java -version

# Available JDKs
ls -l /usr/lib/jvm/

# System resources
free -h
nproc

# jadx version
jadx --version

# Crash log location
ls -lt hs_err_pid*.log | head -1
```

## Known Working Configurations

Based on testing with TikTok 36.5.4 APK on 32GB RAM, 16-core system:

✅ **Working:**
- Temurin 25 + Parallel GC + 8GB heap + 1 thread
- OpenJDK 21 + ZGC + 12GB heap + 2 threads
- Temurin 25 + G1 GC + 8GB heap + 2 threads

❌ **Known to Crash:**
- OpenJDK 17.0.16 + G1 GC + 22GB heap (MaxRAMPercentage=70) + 1 thread

## Additional Resources

- [JDK Bug Database](https://bugs.openjdk.org/)
- [G1 GC Tuning Guide](https://docs.oracle.com/en/java/javase/21/gctuning/garbage-first-g1-garbage-collector1.html)
- [jadx GitHub Issues](https://github.com/skylot/jadx/issues)
- Eclipse Temurin Downloads: [adoptium.net](https://adoptium.net/)
