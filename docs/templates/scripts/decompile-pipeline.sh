#!/usr/bin/env bash
#
# decompile-pipeline.sh
# Automated decompilation pipeline with performance metrics and validation
#
# Usage: ./decompile-pipeline.sh <app-id> <version> <apk-path>
# Example: ./decompile-pipeline.sh tiktok 36.5.4 ~/downloads/tiktok.apk

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APKTOOL_HEAP="${APKTOOL_HEAP:-4g}"
JADX_THREADS="${JADX_THREADS:-4}"
JADX_HEAP="${JADX_HEAP:-6g}"
ENABLE_DEOBF="${ENABLE_DEOBF:-false}"

# Arguments
APP_ID="${1:-}"
VERSION="${2:-}"
APK_PATH="${3:-}"

usage() {
    cat <<EOF
Usage: $0 <app-id> <version> <apk-path>

Automated APK decompilation pipeline with metrics.

Arguments:
    app-id      Application identifier (e.g., tiktok, youtube)
    version     Version string (e.g., 36.5.4)
    apk-path    Path to the APK file

Environment Variables:
    APKTOOL_HEAP    Heap size for apktool (default: 4g)
    JADX_THREADS    Number of jadx threads (default: 4)
    JADX_HEAP       Heap size for jadx (default: 6g)
    ENABLE_DEOBF    Enable jadx deobfuscation (default: false)

Example:
    $0 tiktok 36.5.4 ~/downloads/tiktok-36.5.4.apk

EOF
    exit 1
}

# Validate arguments
if [[ -z "$APP_ID" || -z "$VERSION" || -z "$APK_PATH" ]]; then
    echo -e "${RED}Error: Missing required arguments${NC}"
    usage
fi

if [[ ! -f "$APK_PATH" ]]; then
    echo -e "${RED}Error: APK file not found: $APK_PATH${NC}"
    exit 1
fi

# Setup target
WORKSPACE="targets/$APP_ID/$VERSION"
mkdir -p "$WORKSPACE"/{apk,decode/{apktool,jadx},notes,artifacts,scripts,tmp}

echo -e "${BLUE}=== APK Decompilation Pipeline ===${NC}"
echo -e "App:     $APP_ID"
echo -e "Version: $VERSION"
echo -e "APK:     $APK_PATH"
echo

# Copy APK to target
APK_FILENAME="${APP_ID}-${VERSION}.apk"
APK_WORKSPACE="$WORKSPACE/apk/$APK_FILENAME"

echo -e "${YELLOW}[1/5] Copying APK to target...${NC}"
cp "$APK_PATH" "$APK_WORKSPACE"
echo -e "${GREEN}✓ APK copied${NC}"
echo

# Hash verification
echo -e "${YELLOW}[2/5] Computing APK hashes...${NC}"
SHA256=$(sha256sum "$APK_WORKSPACE" | awk '{print $1}')
echo -e "SHA-256: ${GREEN}$SHA256${NC}"

cat > "$WORKSPACE/apk/hashes.txt" <<EOF
# APK Hashes
SHA-256: $SHA256
EOF

echo -e "${GREEN}✓ Hashes saved${NC}"
echo

# apktool decode
echo -e "${YELLOW}[3/5] Decoding with apktool...${NC}"
APKTOOL_START=$(date +%s)

if apktool -JXmx"$APKTOOL_HEAP" d "$APK_WORKSPACE" -o "$WORKSPACE/decode/apktool/" -f 2>&1 | tee "$WORKSPACE/artifacts/apktool-decode.log"; then
    APKTOOL_END=$(date +%s)
    APKTOOL_DURATION=$((APKTOOL_END - APKTOOL_START))
    
    echo -e "${GREEN}✓ apktool completed in ${APKTOOL_DURATION}s${NC}"
else
    echo -e "${RED}✗ apktool failed${NC}"
    exit 1
fi
echo

# jadx export
echo -e "${YELLOW}[4/5] Decompiling with jadx...${NC}"

JADX_ARGS="--threads-count $JADX_THREADS"
if [[ "$ENABLE_DEOBF" == "true" ]]; then
    JADX_ARGS="$JADX_ARGS --deobf"
fi

JADX_START=$(date +%s)

if env JAVA_OPTS="-Xmx$JADX_HEAP" jadx $JADX_ARGS -d "$WORKSPACE/decode/jadx/" "$APK_WORKSPACE" 2>&1 | tee "$WORKSPACE/artifacts/jadx-export.log"; then
    JADX_END=$(date +%s)
    JADX_DURATION=$((JADX_END - JADX_START))
    
    echo -e "${GREEN}✓ jadx completed in ${JADX_DURATION}s${NC}"
else
    echo -e "${YELLOW}⚠ jadx export completed with warnings${NC}"
fi
echo

# Performance report
echo -e "${YELLOW}[5/5] Generating performance report...${NC}"

cat > "$WORKSPACE/artifacts/decompile-performance.txt" <<EOF
# Decompilation Performance Report
Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

App:     $APP_ID
Version: $VERSION
SHA-256: $SHA256

apktool:
  Duration: ${APKTOOL_DURATION}s
  Output:   $(du -sh "$WORKSPACE/decode/apktool/" | awk '{print $1}')

jadx:
  Duration: ${JADX_DURATION}s
  Output:   $(du -sh "$WORKSPACE/decode/jadx/" | awk '{print $1}')

Java:    $(java -version 2>&1 | head -n 1)
apktool: $(apktool --version 2>&1 | head -n 1)
jadx:    $(jadx --version 2>&1 | head -n 1)
EOF

echo -e "${GREEN}✓ Performance report generated${NC}"
echo

echo -e "${BLUE}=== Pipeline Complete ===${NC}"
echo -e "${GREEN}✓ Workspace: $WORKSPACE${NC}"
echo -e "Next: cd $WORKSPACE/scripts/ && python3 detect-obfuscation.py ../decode/apktool/"
