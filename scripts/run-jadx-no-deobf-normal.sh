#!/usr/bin/env bash
# JADX run: Temurin 25, ParallelGC, 24GB heap, 12 threads, deobf OFF, show-bad-code OFF.

set -euo pipefail

APK="${1:?APK path required}"
# Extract package and version from APK path (e.g., apps/tiktok/36.5.4/apk/tiktok-36.5.4.apk)
if [[ -n "${2:-}" ]]; then
  ROOT="$2"
else
  # Auto-detect from APK path
  APK_PATH="$(dirname "$(dirname "$APK")")"  # Go up two levels: from apk/ to <version>/ to apps/<package>/
  ROOT="$APK_PATH"
fi

JAVA_HOME="${JADX_JDK:-/usr/lib/jvm/java-25-temurin}"
export PATH="$JAVA_HOME/bin:$PATH"

THREADS=12  # Fixed to successful configuration

TIMEOUT_S="${TIMEOUT_S:-600}" # 10 min (successful run took 5-6 min)
TIMEOUT_ARGS="${TIMEOUT_ARGS:-"--signal=TERM --kill-after=15s"}"
TIMEOUT_BIN="$(command -v timeout || true)"

OUT_DEC="$ROOT/decode/jadx-no-deobf-normal"
OUT_LOG="$ROOT/analysis"
mkdir -p "$OUT_DEC" "$OUT_LOG"

# Clean decode dir
echo "[clean] wiping $OUT_DEC/*"
find "$OUT_DEC" -mindepth 1 -maxdepth 1 -print0 2>/dev/null | xargs -0r rm -rf

# JVM: Temurin 25, ParallelGC, 24GB heap (successful config)
export JAVA_TOOL_OPTIONS="-Xms4g -Xmx24g -XX:+UseParallelGC -XX:ParallelGCThreads=12"

ts="$(date +%Y%m%d-%H%M%S)"
log="$OUT_LOG/jadx_no_deobf_normal_${THREADS}_${ts}.log"

cmd=(jadx --threads-count 12 --no-debug-info -d "$OUT_DEC" "$APK")

echo "==> Temurin25 ParallelGC  heap=24GB  threads=12  timeout=${TIMEOUT_S}s  JAVA_HOME=$JAVA_HOME"
echo "==> DEOBF: OFF SHOW-BAD-CODE: OFF"
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
echo "-- [Temurin25 ParallelGC j=$THREADS] exit=$exit_code"
echo "Output dir: $OUT_DEC"
echo "Full log:   $log"