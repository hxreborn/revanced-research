# JVM Garbage Collection Troubleshooting

When decompiling large APKs with jadx, you may encounter JVM crashes with `SIGSEGV` errors from garbage collection threads.

## Symptoms

```
SIGSEGV (0xb) at pc=0x..., pid=..., tid=...
Current thread: ConcurrentGCThread "G1 Conc#2"
Fatal Error: SEGV received
Dumping core...
```

## Root Causes

- **Large heap sizes** (20+ GB) triggering GC edge cases
- **Humongous objects** (large byte arrays, maps) from APK processing
- **G1 GC bugs** in certain OpenJDK versions
- **High thread concurrency** creating allocation pressure

## Quick Fixes (Try in Order)

### 1. Reduce Heap Size

Most effective first step:

```bash
export JAVA_TOOL_OPTIONS="-XX:+UseParallelGC -Xms2g -Xmx8g"
./scripts/run-jadx.sh app.apk
```

Or via pipeline:

```bash
JAVA_TOOL_OPTIONS="-XX:+UseParallelGC -Xms2g -Xmx8g" \
./docs/templates/scripts/decompile-pipeline.sh myapp 1.0.0 app.apk
```

### 2. Use Single Thread

Eliminates allocation concurrency issues:

```bash
export THREADS=1
./scripts/run-jadx.sh app.apk
```

### 3. Switch Garbage Collector

If Parallel GC fails, try alternatives:

```bash
# ZGC (low-latency, good for large heaps on modern JVMs)
export JAVA_TOOL_OPTIONS="-XX:+UseZGC -Xms4g -Xmx16g"
./scripts/run-jadx.sh app.apk

# Serial GC (most stable, but slower)
export JAVA_TOOL_OPTIONS="-XX:+UseSerialGC -Xms2g -Xmx8g"
./scripts/run-jadx.sh app.apk
```

### 4. Verify Java Version

Ensure Java 17+:

```bash
java -version
# Should show: openjdk version "17.0.x" or newer
```

Newer JDKs (21+, Temurin builds) have better GC stability.

## Complete Solutions by Scenario

### Small APKs (< 50MB)

```bash
export JAVA_TOOL_OPTIONS="-XX:+UseParallelGC -Xms1g -Xmx4g"
export THREADS=2
./scripts/run-jadx.sh small.apk
```

### Medium APKs (50-200MB)

```bash
export JAVA_TOOL_OPTIONS="-XX:+UseParallelGC -Xms2g -Xmx8g"
export THREADS=4
./scripts/run-jadx.sh medium.apk
```

### Large APKs (200MB+, Heavily Obfuscated)

```bash
# Conservative: Highest stability
export JAVA_TOOL_OPTIONS="-XX:+UseParallelGC -Xms4g -Xmx12g"
export THREADS=1
./scripts/run-jadx.sh large.apk

# Balanced: Good performance + stability
export JAVA_TOOL_OPTIONS="-XX:+UseZGC -Xms4g -Xmx16g"
export THREADS=2
./scripts/run-jadx.sh large.apk

# Performance: If you have 32GB+ RAM
export JAVA_TOOL_OPTIONS="-XX:+UseZGC -Xms8g -Xmx24g"
export THREADS=8
./scripts/run-jadx.sh large.apk
```

## Environment Variables Reference

### JAVA_TOOL_OPTIONS

Set global JVM configuration:

```bash
# Syntax: -XX:+UseGC_NAME -Xms<min> -Xmx<max>

export JAVA_TOOL_OPTIONS="-XX:+UseParallelGC -Xms4g -Xmx12g"
```

**GC Options:**
- `-XX:+UseParallelGC` — Parallel GC (simple, stable, good throughput)
- `-XX:+UseG1GC` — G1 GC (default in Java 9+, can crash on large heaps)
- `-XX:+UseZGC` — ZGC (low-latency, needs Java 11+, experimental)
- `-XX:+UseSerialGC` — Serial GC (stable but slow)
- `-XX:+UseShenandoahGC` — Shenandoah (low-latency, needs Java 12+)

**Heap Sizing:**
- `-Xms<size>` — Minimum heap (e.g., `-Xms2g`)
- `-Xmx<size>` — Maximum heap (e.g., `-Xmx16g`)
- Rule of thumb: Leave 8GB for OS and other processes

### scripts/run-jadx.sh Variables

```bash
export THREADS=4           # Override auto-detected core count
export TIMEOUT_S=900       # Timeout in seconds (default 420s = 7min)
export TIMEOUT_S=0         # Disable timeout
```

## Advanced Debugging

### Enable GC Logging

Diagnose GC issues in detail:

```bash
export JAVA_TOOL_OPTIONS="-XX:+UseParallelGC -Xms2g -Xmx8g \
  -Xlog:gc*:file=gc.log:level=info:time,level,tags"
./scripts/run-jadx.sh app.apk
# Outputs: gc.log with detailed GC events
```

### Monitor Decompilation in Real-Time

In a separate terminal:

```bash
watch -n 1 "free -h && echo '---' && ps aux | grep -i java | grep -v grep"
```

Observe:
- Memory growth → if it climbs to max heap, increase `-Xmx`
- CPU usage → if low, increase `THREADS`
- Crashes → collect `hs_err_pid*.log` for analysis

### Collect Crash Info

After a crash, examine the error log:

```bash
# Find the latest crash log
ls -lt hs_err_pid*.log | head -1

# Key sections to check:
grep "SEGV" hs_err_pid*.log
grep "GC History" hs_err_pid*.log
grep "Heap" hs_err_pid*.log
```

## Recommended Configurations by System

### 4-8GB RAM, 2-4 cores (Laptop/Minimal)

```bash
export JAVA_TOOL_OPTIONS="-XX:+UseParallelGC -Xms1g -Xmx3g"
export THREADS=1
```

### 8-16GB RAM, 4-8 cores (Workstation)

```bash
export JAVA_TOOL_OPTIONS="-XX:+UseParallelGC -Xms2g -Xmx8g"
export THREADS=4
```

### 16-32GB RAM, 8+ cores (Development Server)

```bash
export JAVA_TOOL_OPTIONS="-XX:+UseParallelGC -Xms4g -Xmx12g"
export THREADS=6
```

### 32GB+ RAM, 16+ cores (Workstation/Server)

```bash
export JAVA_TOOL_OPTIONS="-XX:+UseZGC -Xms8g -Xmx24g"
export THREADS=12
```

## Common Mistakes

❌ **Don't set -Xmx to 100% of system RAM:**
```bash
# BAD - leaves no room for OS
export JAVA_TOOL_OPTIONS="-Xmx32g"
```

✅ **Do leave 8GB for OS:**
```bash
# GOOD - on 32GB system
export JAVA_TOOL_OPTIONS="-Xmx24g"
```

---

❌ **Don't use G1GC with huge heaps:**
```bash
# BAD - G1 crashes at 20GB+
export JAVA_TOOL_OPTIONS="-XX:+UseG1GC -Xmx28g"
```

✅ **Use Parallel or ZGC for large heaps:**
```bash
# GOOD
export JAVA_TOOL_OPTIONS="-XX:+UseZGC -Xmx24g"
```

---

❌ **Don't use too many threads:**
```bash
# BAD - allocation pressure
export THREADS=32
```

✅ **Use conservative thread count:**
```bash
# GOOD - leave headroom for GC threads
export THREADS=8  # on 16-core system
```

## Integration with revanced-research

### Option 1: Per-Session

```bash
export JAVA_TOOL_OPTIONS="-XX:+UseParallelGC -Xms4g -Xmx12g"
export THREADS=4
./scripts/run-jadx.sh app.apk apps/app/1.0.0
```

### Option 2: Per-Script

```bash
JAVA_TOOL_OPTIONS="-XX:+UseParallelGC -Xms4g -Xmx12g" THREADS=4 \
  ./docs/templates/scripts/decompile-pipeline.sh myapp 1.0.0 app.apk
```

### Option 3: Shell Alias

Add to `~/.bashrc`:

```bash
alias jadx-safe='JAVA_TOOL_OPTIONS="-XX:+UseParallelGC -Xms2g -Xmx8g" THREADS=1 ./scripts/run-jadx.sh'
alias jadx-perf='JAVA_TOOL_OPTIONS="-XX:+UseZGC -Xms8g -Xmx24g" THREADS=12 ./scripts/run-jadx.sh'

# Then use:
jadx-safe app.apk
jadx-perf app.apk
```

## Further References

- [Oracle GC Tuning Guide](https://docs.oracle.com/en/java/javase/21/gctuning/)
- [OpenJDK Bug Database](https://bugs.openjdk.org/)
- [jadx GitHub Issues](https://github.com/skylot/jadx/issues)
- [DECOMPILATION_GUIDE.md](./DECOMPILATION_GUIDE.md) — Main usage guide
