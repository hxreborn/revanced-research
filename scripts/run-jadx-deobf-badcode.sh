#!/usr/bin/env bash
# JADX run: Temurin 25, G1GC, 20GB heap, 8 threads, deobf ON, show-bad-code ON.

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

THREADS=8  # Reduced for stability with deobf+badcode combo

TIMEOUT_S="${TIMEOUT_S:-600}" # 10 min (successful run took 5-6 min)
TIMEOUT_ARGS="${TIMEOUT_ARGS:-"--signal=TERM --kill-after=15s"}"
TIMEOUT_BIN="$(command -v timeout || true)"

OUT_DEC="$ROOT/decode/jadx-deobf-badcode"
OUT_LOG="$ROOT/analysis"
mkdir -p "$OUT_DEC" "$OUT_LOG"

# Clean decode dir
echo "[clean] wiping $OUT_DEC/*"
find "$OUT_DEC" -mindepth 1 -maxdepth 1 -print0 2>/dev/null | xargs -0r rm -rf

# JVM: Temurin 25, G1GC, 20GB heap (safer for deobf+badcode combo)
export JAVA_TOOL_OPTIONS="-Xms4g -Xmx20g -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UseStringDeduplication"

ts="$(date +%Y%m%d-%H%M%S)"
log="$OUT_LOG/jadx_deobf_badcode_${THREADS}_${ts}.log"

cmd=(jadx --threads-count 8 --deobf --show-bad-code --no-debug-info -d "$OUT_DEC" "$APK")

echo "==> Temurin25 G1GC  heap=20GB  threads=8  timeout=${TIMEOUT_S}s  JAVA_HOME=$JAVA_HOME"
echo "==> DEOBF: ON  SHOW-BAD-CODE: ON"
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
echo "-- [Temurin25 G1GC j=$THREADS] exit=$exit_code"
echo "Output dir: $OUT_DEC"
echo "Full log:   $log"