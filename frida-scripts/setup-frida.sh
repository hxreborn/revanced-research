#!/usr/bin/env bash

#
# Automated Frida Setup for Android + Arch Linux
#
# Downloads and installs:
# - frida-tools on PC (via pip)
# - frida-server on Android device (arm64-v8a)
#

set -euo pipefail

FRIDA_VERSION="16.5.9"
FRIDA_SERVER_URL="https://github.com/frida/frida/releases/download/${FRIDA_VERSION}/frida-server-${FRIDA_VERSION}-android-arm64.xz"
FRIDA_SERVER_FILE="frida-server-${FRIDA_VERSION}-android-arm64"
DOWNLOAD_DIR="/tmp"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}Frida Setup for Android + Arch Linux${NC}"
echo -e "${BLUE}======================================${NC}\n"

# Check if device is connected
echo -e "${BLUE}[1/6]${NC} Checking device connection..."
if ! adb devices | grep -q "device$"; then
    echo -e "${RED}[ERROR]${NC} No Android device connected"
    echo "Connect your device and enable USB debugging"
    exit 1
fi
echo -e "${GREEN}✓${NC} Device connected\n"

# Install frida-tools on PC
echo -e "${BLUE}[2/6]${NC} Installing frida-tools on PC..."

if command -v yay &> /dev/null; then
    echo "Using yay (AUR) for installation..."
    yay -S --noconfirm python-frida python-frida-tools || {
        echo -e "${YELLOW}Warning: AUR install failed, falling back to pip${NC}"
        pip install --user frida-tools
    }
elif command -v paru &> /dev/null; then
    echo "Using paru (AUR) for installation..."
    paru -S --noconfirm python-frida python-frida-tools || {
        echo -e "${YELLOW}Warning: AUR install failed, falling back to pip${NC}"
        pip install --user frida-tools
    }
else
    echo "Using pip for installation..."
    pip install --user frida-tools
fi

echo -e "${GREEN}✓${NC} frida-tools installed\n"

# Verify installation
FRIDA_CLI_VERSION=$(frida --version 2>/dev/null || echo "unknown")
echo -e "  Frida CLI version: ${FRIDA_CLI_VERSION}\n"

# Download frida-server
echo -e "${BLUE}[3/6]${NC} Downloading frida-server ${FRIDA_VERSION} for arm64..."

cd "${DOWNLOAD_DIR}"

if [[ -f "${FRIDA_SERVER_FILE}" ]]; then
    echo -e "${YELLOW}File already exists, skipping download${NC}"
else
    wget -q --show-progress "${FRIDA_SERVER_URL}"
    unxz "${FRIDA_SERVER_FILE}.xz"
fi

echo -e "${GREEN}✓${NC} Downloaded\n"

# Push to device
echo -e "${BLUE}[4/6]${NC} Pushing frida-server to device..."

adb push "${FRIDA_SERVER_FILE}" /data/local/tmp/frida-server
adb shell "chmod 755 /data/local/tmp/frida-server"

echo -e "${GREEN}✓${NC} Pushed to /data/local/tmp/frida-server\n"

# Kill existing frida-server if running
echo -e "${BLUE}[5/6]${NC} Stopping existing frida-server (if any)..."
adb shell "su -c 'killall frida-server'" 2>/dev/null || echo "No existing frida-server running"

# Start frida-server
echo -e "${BLUE}[6/6]${NC} Starting frida-server on device..."

adb shell "su -c '/data/local/tmp/frida-server &'" &
sleep 2

# Verify frida-server is running
if adb shell "ps -A | grep frida-server" | grep -q frida-server; then
    echo -e "${GREEN}✓${NC} frida-server is running\n"
else
    echo -e "${RED}[ERROR]${NC} frida-server failed to start"
    echo "Make sure your device is rooted and try running manually:"
    echo "  adb shell"
    echo "  su"
    echo "  /data/local/tmp/frida-server &"
    exit 1
fi

# Test connection
echo -e "${BLUE}Testing connection...${NC}"
if frida-ps -U &> /dev/null; then
    echo -e "${GREEN}✓${NC} Frida is working!\n"
    echo -e "${GREEN}Running processes on device:${NC}"
    frida-ps -U | head -10
    echo ""
else
    echo -e "${RED}[ERROR]${NC} Cannot connect to frida-server"
    echo "Try restarting frida-server manually"
    exit 1
fi

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}Frida Setup Complete!${NC}"
echo -e "${GREEN}======================================${NC}\n"

echo "You can now run:"
echo "  frida-ps -U                      # List processes"
echo "  frida -U com.ss.android.ugc.trill # Attach to TikTok"
echo ""
echo "Or use the tracing scripts:"
echo "  ./compare-both-apps.sh"
echo ""
