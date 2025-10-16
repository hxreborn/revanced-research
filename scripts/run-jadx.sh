#!/usr/bin/env bash
# Fast JADX run: ParallelGC, 80% RAM, all cores, deobf ON, full live output.

set -euo pipefail

APK="${1:?APK path required}"
ROOT="${2:-apps/app}"

JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-21-temurin}"
export PATH="$JAVA_HOME/bin:$PATH"

CPU="$( (nproc --all 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 16))"
THREADS="${THREADS:-$CPU}"

TIMEOUT_S="${TIMEOUT_S:-420}" # 7 min
TIMEOUT_ARGS="${TIMEOUT_ARGS:-"--signal=TERM --kill-after=15s"}"
TIMEOUT_BIN="$(command -v timeout || true)"

OUT_DEC="$ROOT/decode/jadx"
OUT_LOG="$ROOT/analysis"
mkdir -p "$OUT_DEC" "$OUT_LOG"

# Clean decode dir
echo "[clean] wiping $OUT_DEC/*"
find "$OUT_DEC" -mindepth 1 -maxdepth 1 -print0 2>/dev/null | xargs -0r rm -rf

# JVM: 80% RAM, full threads, Parallel GC
export JAVA_TOOL_OPTIONS="-XX:+UseParallelGC -XX:MaxRAMPercentage=80.0 -XX:ParallelGCThreads=${THREADS} -XX:CICompilerCount=${THREADS} -Xshare:off"

ts="$(date +%Y%m%d-%H%M%S)"
log="$OUT_LOG/jadx_parallel_${THREADS}_${ts}.log"

cmd=(jadx --deobf --no-debug-info -j "$THREADS" -d "$OUT_DEC" "$APK")

echo "==> ParallelGC  -j $THREADS  MaxRAM=80%  timeout=${TIMEOUT_S}s  JAVA_HOME=$JAVA_HOME"
echo "Command: ${cmd[*]}"
echo "Logs: $log"
echo "-----------------------------------------------"

# Run and stream live output while timing
set +e
if [[ -n "$TIMEOUT_BIN" && "$TIMEOUT_S" -gt 0 ]]; then
  { time $TIMEOUT_BIN $TIMEOUT_ARGS "$TIMEOUT_S" "${cmd[@]}" 2>&1 | tee "$log"; } 2>&1
  exit_code=${PIPESTATUS[0]}
else
  { time "${cmd[@]}" 2>&1 | tee "$log"; } 2>&1
  exit_code=${PIPESTATUS[0]}
fi
set -e

echo "-----------------------------------------------"
echo "-- [ParallelGC j=$THREADS] exit=$exit_code"
echo "Output dir: $OUT_DEC"
echo "Full log:   $log"
