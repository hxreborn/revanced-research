#!/usr/bin/env bash
# apktool_bruteforce_decode.sh
# Usage: ./apktool_bruteforce_decode.sh /abs/path/base.apk /abs/output/dir
set -euo pipefail

APK="${1:?APK path required}"
OUT="${2:?Output dir required}"
LOGDIR="${LOGDIR:-$(dirname "$OUT")/logs}"
JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-21-openjdk}"
TMPDIR_FALLBACK="${TMPDIR_FALLBACK:-/mnt/fasttmp}"
MIN_FREE_GB="${MIN_FREE_GB:-50}"

mkdir -p "$LOGDIR" "$TMPDIR_FALLBACK"
export PATH="$JAVA_HOME/bin:$PATH"
export LC_ALL=C LANG=C
export TMPDIR="${TMPDIR:-$TMPDIR_FALLBACK}"
ulimit -n 131072 || true

# Locate apktool.jar
find_apktool_jar() {
  local j
  j="$(pacman -Ql apktool 2>/dev/null | awk '/\/apktool\.jar$/ {print $2; exit}')"
  [[ -z "${j:-}" ]] && j="$(sudo find /usr -maxdepth 5 -name apktool.jar 2>/dev/null | head -n1)"
  [[ -n "${j:-}" && -f "$j" ]] && echo "$j" || {
    echo "apktool.jar not found"
    exit 3
  }
}
APKTOOL_JAR="$(find_apktool_jar)"

# Guard: free space in TMPDIR
free_gb="$(df -Pk "$TMPDIR" | awk 'NR==2{print int($4/1024/1024)}')"
((free_gb >= MIN_FREE_GB)) || {
  echo "Low TMP free space: ${free_gb}GB < ${MIN_FREE_GB}GB"
  exit 4
}

echo "java: $(java -version 2>&1 | head -n1)"
echo "jar : $APKTOOL_JAR"
echo "tmp : $TMPDIR  (free ${free_gb}GB)"
echo

# Config matrix (fast → heavy)
GCS=(
  "-XX:+UseZGC"
  "-XX:+UseG1GC"
  "-XX:+UseParallelGC"
)
HEAPS=(
  "-Xms6g -Xmx20g"
  "-Xms8g -Xmx24g"
  "-Xms8g -Xmx28g"
)
STACKS=(
  "-Xss512k"
  "-Xss1m"
)
META=(
  "-XX:MaxMetaspaceSize=1g"
  "-XX:MaxMetaspaceSize=2g"
)
THREADS=(1 2)

common="-Dfile.encoding=UTF-8 -Djava.io.tmpdir=$TMPDIR"

attempt=0
for gc in "${GCS[@]}"; do
  for heap in "${HEAPS[@]}"; do
    for stk in "${STACKS[@]}"; do
      for m in "${META[@]}"; do
        for j in "${THREADS[@]}"; do
          attempt=$((attempt + 1))
          tag="try${attempt}"
          log="$LOGDIR/apktool_decode_${tag}.log"
          echo "[$tag] gc='${gc#-XX:+}' heap='${heap}' stack='${stk}' meta='${m}' -j $j"
          rm -rf "$OUT"
          set +e
          java $gc $heap $m $stk $common -jar "$APKTOOL_JAR" \
            d -f -j "$j" "$APK" -o "$OUT" 2>&1 | tee "$log"
          rc=${PIPESTATUS[0]}
          set -e
          # Success check: exit code 0 and smali tree exists
          if [[ $rc -eq 0 && -d "$OUT/smali" ]]; then
            echo "[SUCCESS] $tag → $OUT"
            echo "Log: $log"
            exit 0
          else
            echo "[FAIL] $tag rc=$rc  (log: $log)"
          fi
        done
      done
    done
  done
done

echo "All combos failed. See logs in $LOGDIR"
exit 10
