#!/usr/bin/env bash

#
# Compare TikTok vs Musically Share URL Behavior
#
# Runs Frida tracing on both apps side-by-side and compares output
# Usage: ./compare-both-apps.sh
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/trace-outputs"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

TIKTOK_PKG="com.ss.android.ugc.trill"
MUSICALLY_PKG="com.zhiliaoapp.musically"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}TikTok Share URL Comparison Tool${NC}"
echo -e "${BLUE}======================================${NC}\n"

# Create output directory
mkdir -p "${OUTPUT_DIR}"

# Check if frida is installed
if ! command -v frida &> /dev/null; then
    echo -e "${RED}[ERROR] frida-tools not found${NC}"
    echo "Install with: pip install frida-tools"
    exit 1
fi

# Check if device is connected
if ! frida-ps -U &> /dev/null; then
    echo -e "${RED}[ERROR] No USB device found or frida-server not running${NC}"
    echo "1. Connect your Android device"
    echo "2. Run frida-server on the device:"
    echo "   adb shell \"/data/local/tmp/frida-server &\""
    exit 1
fi

echo -e "${GREEN}✓${NC} Device connected"

# Check if apps are installed
TIKTOK_INSTALLED=$(adb shell pm list packages | grep -c "${TIKTOK_PKG}" || echo "0")
MUSICALLY_INSTALLED=$(adb shell pm list packages | grep -c "${MUSICALLY_PKG}" || echo "0")

if [[ "${TIKTOK_INSTALLED}" == "0" ]]; then
    echo -e "${YELLOW}[WARN] ${TIKTOK_PKG} not installed${NC}"
fi

if [[ "${MUSICALLY_INSTALLED}" == "0" ]]; then
    echo -e "${YELLOW}[WARN] ${MUSICALLY_PKG} not installed${NC}"
fi

if [[ "${TIKTOK_INSTALLED}" == "0" ]] && [[ "${MUSICALLY_INSTALLED}" == "0" ]]; then
    echo -e "${RED}[ERROR] No target apps installed${NC}"
    exit 1
fi

echo ""

# Menu
echo -e "${BLUE}Select option:${NC}"
echo "1. Trace TikTok only"
echo "2. Trace Musically only"
echo "3. Trace both (sequential)"
echo "4. Compare existing logs"
read -p "Choice [1-4]: " choice

case $choice in
    1)
        echo -e "\n${BLUE}Starting TikTok trace...${NC}"
        echo "Output: ${OUTPUT_DIR}/tiktok-${TIMESTAMP}.log"
        echo -e "${YELLOW}Perform share actions now. Press Ctrl+C to stop.${NC}\n"

        frida -U -f "${TIKTOK_PKG}" \
            -l "${SCRIPT_DIR}/trace-share-url-tiktok.js" \
            2>&1 | tee "${OUTPUT_DIR}/tiktok-${TIMESTAMP}.log"
        ;;

    2)
        echo -e "\n${BLUE}Starting Musically trace...${NC}"
        echo "Output: ${OUTPUT_DIR}/musically-${TIMESTAMP}.log"
        echo -e "${YELLOW}Perform share actions now. Press Ctrl+C to stop.${NC}\n"

        frida -U -f "${MUSICALLY_PKG}" \
            -l "${SCRIPT_DIR}/trace-share-url-musically.js" \
            2>&1 | tee "${OUTPUT_DIR}/musically-${TIMESTAMP}.log"
        ;;

    3)
        echo -e "\n${BLUE}Starting TikTok trace first...${NC}"
        echo "Output: ${OUTPUT_DIR}/tiktok-${TIMESTAMP}.log"
        echo -e "${YELLOW}Perform share actions. Press Ctrl+C when done.${NC}\n"

        frida -U -f "${TIKTOK_PKG}" \
            -l "${SCRIPT_DIR}/trace-share-url-tiktok.js" \
            2>&1 | tee "${OUTPUT_DIR}/tiktok-${TIMESTAMP}.log" || true

        echo -e "\n${BLUE}Starting Musically trace...${NC}"
        echo "Output: ${OUTPUT_DIR}/musically-${TIMESTAMP}.log"
        echo -e "${YELLOW}Perform share actions. Press Ctrl+C when done.${NC}\n"

        frida -U -f "${MUSICALLY_PKG}" \
            -l "${SCRIPT_DIR}/trace-share-url-musically.js" \
            2>&1 | tee "${OUTPUT_DIR}/musically-${TIMESTAMP}.log" || true

        echo -e "\n${BLUE}Comparing logs...${NC}\n"
        bash "${SCRIPT_DIR}/compare-both-apps.sh" 4 "${OUTPUT_DIR}/tiktok-${TIMESTAMP}.log" "${OUTPUT_DIR}/musically-${TIMESTAMP}.log"
        ;;

    4)
        # Find latest logs
        LATEST_TIKTOK=$(find "${OUTPUT_DIR}" -name "tiktok-*.log" -type f -printf '%T@ %p\n' | sort -rn | head -1 | cut -d' ' -f2-)
        LATEST_MUSICALLY=$(find "${OUTPUT_DIR}" -name "musically-*.log" -type f -printf '%T@ %p\n' | sort -rn | head -1 | cut -d' ' -f2-)

        if [[ -z "${LATEST_TIKTOK}" ]] || [[ -z "${LATEST_MUSICALLY}" ]]; then
            echo -e "${RED}[ERROR] Could not find both log files${NC}"
            exit 1
        fi

        echo -e "${BLUE}Comparing:${NC}"
        echo "  TikTok: ${LATEST_TIKTOK}"
        echo "  Musically: ${LATEST_MUSICALLY}"
        echo ""

        # Extract tracking parameters from both logs
        echo -e "${BLUE}=== TRACKING PARAMETERS COMPARISON ===${NC}\n"

        echo -e "${GREEN}TikTok Tracking Params:${NC}"
        grep -oP '\[TRACKING\] \K.*' "${LATEST_TIKTOK}" | sort -u || echo "(none found)"

        echo ""
        echo -e "${GREEN}Musically Tracking Params:${NC}"
        grep -oP '\[TRACKING\] \K.*' "${LATEST_MUSICALLY}" | sort -u || echo "(none found)"

        echo ""
        echo -e "${BLUE}=== COMMON PARAMETERS ===${NC}"
        comm -12 \
            <(grep -oP '\[TRACKING\] \K[^=]+' "${LATEST_TIKTOK}" | sort -u) \
            <(grep -oP '\[TRACKING\] \K[^=]+' "${LATEST_MUSICALLY}" | sort -u) || echo "(none)"

        echo ""
        echo -e "${BLUE}=== UNIQUE TO TIKTOK ===${NC}"
        comm -23 \
            <(grep -oP '\[TRACKING\] \K[^=]+' "${LATEST_TIKTOK}" | sort -u) \
            <(grep -oP '\[TRACKING\] \K[^=]+' "${LATEST_MUSICALLY}" | sort -u) || echo "(none)"

        echo ""
        echo -e "${BLUE}=== UNIQUE TO MUSICALLY ===${NC}"
        comm -13 \
            <(grep -oP '\[TRACKING\] \K[^=]+' "${LATEST_TIKTOK}" | sort -u) \
            <(grep -oP '\[TRACKING\] \K[^=]+' "${LATEST_MUSICALLY}" | sort -u) || echo "(none)"

        echo ""
        echo -e "${BLUE}=== BYTES ADDED ===${NC}"
        TIKTOK_BYTES=$(grep -oP 'Bytes added: \K\d+' "${LATEST_TIKTOK}" | head -1 || echo "0")
        MUSICALLY_BYTES=$(grep -oP 'Bytes added: \K\d+' "${LATEST_MUSICALLY}" | head -1 || echo "0")
        echo "  TikTok:    ${TIKTOK_BYTES} bytes"
        echo "  Musically: ${MUSICALLY_BYTES} bytes"

        # Generate diff report
        DIFF_REPORT="${OUTPUT_DIR}/comparison-${TIMESTAMP}.txt"
        {
            echo "TikTok vs Musically Share URL Comparison"
            echo "Generated: $(date)"
            echo ""
            echo "=== FILES ==="
            echo "TikTok: ${LATEST_TIKTOK}"
            echo "Musically: ${LATEST_MUSICALLY}"
            echo ""
            echo "=== TRACKING PARAMETERS ==="
            echo ""
            echo "TikTok:"
            grep -oP '\[TRACKING\] \K.*' "${LATEST_TIKTOK}" | sort -u
            echo ""
            echo "Musically:"
            grep -oP '\[TRACKING\] \K.*' "${LATEST_MUSICALLY}" | sort -u
        } > "${DIFF_REPORT}"

        echo ""
        echo -e "${GREEN}Full report saved to: ${DIFF_REPORT}${NC}"
        ;;

    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo -e "\n${GREEN}Done!${NC}"
