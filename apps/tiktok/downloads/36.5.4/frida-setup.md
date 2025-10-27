# Frida Setup Guide for TikTok Download Tracing

## Prerequisites
- Rooted Android device or emulator
- ADB installed and device connected
- Python 3 installed

## 1. Install Frida on Your Computer

```bash
# Install Frida tools via pip
pip3 install frida-tools

# Verify installation
frida --version
```

## 2. Install Frida Server on Android Device

### Step 1: Check your device architecture
```bash
adb shell getprop ro.product.cpu.abi
# Common outputs: arm64-v8a, armeabi-v7a, x86_64, x86
```

### Step 2: Download frida-server
Go to: https://github.com/frida/frida/releases

Download the matching version for your device:
- `frida-server-<version>-android-arm64.xz` (for arm64-v8a)
- `frida-server-<version>-android-arm.xz` (for armeabi-v7a)
- `frida-server-<version>-android-x86_64.xz` (for x86_64)
- `frida-server-<version>-android-x86.xz` (for x86)

**Important:** Frida tools version on computer MUST match frida-server version on device!

### Step 3: Extract and push to device
```bash
# Extract (macOS/Linux)
xz -d frida-server-*-android-*.xz

# Push to device
adb push frida-server-*-android-* /data/local/tmp/frida-server

# Make it executable
adb shell "chmod 755 /data/local/tmp/frida-server"
```

### Step 4: Run frida-server
```bash
# Start frida-server as root
adb shell "su -c /data/local/tmp/frida-server &"

# Verify it's running
adb shell "ps | grep frida-server"
```

## 3. Verify Frida is Working

```bash
# List running processes (should show TikTok if running)
frida-ps -U

# Should output something like:
# PID  Name
# ---  ----
# 1234 com.zhiliaoapp.musically
```

## 4. Run the TikTok Download Trace

### Option A: Attach to running app (recommended)
```bash
# 1. Open TikTok on your device
# 2. Run Frida script
frida -U com.zhiliaoapp.musically -l apps/tiktok/downloads/36.5.4/trace-download.js

# 3. In TikTok, download a video
# 4. Watch the Frida console for output
```

### Option B: Spawn app
```bash
frida -U -f com.zhiliaoapp.musically -l apps/tiktok/downloads/36.5.4/trace-download.js
# Then type: %resume
```

## Troubleshooting

### "Failed to spawn: unable to find application"
- Make sure TikTok is installed: `adb shell pm list packages | grep musically`
- Use attach mode instead (Option A)

### "Failed to attach: unable to connect to remote frida-server"
- Make sure frida-server is running: `adb shell "ps | grep frida-server"`
- Restart frida-server: `adb shell "su -c 'killall frida-server'; su -c /data/local/tmp/frida-server &"`

### Version mismatch error
```bash
# Check computer version
frida --version

# Download matching frida-server version from:
# https://github.com/frida/frida/releases/tag/<your-version>
```

### "unable to access jarfile" or SELinux errors
```bash
# Try SELinux permissive mode (temporary)
adb shell "su -c 'setenforce 0'"
```

## Expected Output

When you download a video in TikTok, you should see output like:

```
[*] TikTok Download Path Tracer Started
============================================================

[Context.getExternalFilesDir] CALLED - App-specific storage
  Type: null
  Result: /storage/emulated/0/Android/data/com.zhiliaoapp.musically/files
  Stack trace: ...

[File.<init>] Creating file with download-related path:
  Path: /storage/emulated/0/Android/data/.../files/share/out/video.mp4
```

Or if using MediaStore:

```
[Kjb.LJJIIJ] CALLED - MediaStore path method
  Result URI: content://media/external/video/media/12345
```

## Next Steps

1. Copy the Frida output
2. Share it to identify which method is actually called during download
3. We'll use that to fix the ReVanced patch
