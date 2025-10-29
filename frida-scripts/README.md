# Frida Tracing Scripts for TikTok Research

Dynamic analysis scripts for TikTok reverse engineering and patch development.

---

## Connection Methods Reference

### Attach Mode (Recommended for Testing)

Connect to already-running process. Faster for iterative testing.

```bash
# By package name
frida -U -n <package> -l script.js

# By PID
adb shell pidof <package>
frida -U <PID> -l script.js
```

### Spawn Mode

Launch app from scratch, hooks installed before code execution.

```bash
frida -U -f <package> -l script.js
```

---

## Download Path Analysis Scripts

### trace-lbt-methods.js

Traces X.LBT MediaStore download path methods.

**Target**: TikTok 36.5.4 (Trill variant)

**Purpose**: Verify LBT.LIZLLL and LBT.LJ execution during downloads

**Usage**:
```bash
# Attach mode (recommended)
frida -U -n com.ss.android.ugc.trill -l trace-lbt-methods.js
```

**Expected output**:
```
[LBT.LIZLLL] Called
  Filename: 491f78cbaa2881116ec5e8d1108f2fc1.mp4
  Return Uri: content://media/external_primary/video/media/1234

[LBT.LJ] Called
  Relative Path: DCIM/Camera/  ← TARGET PARAMETER
```

**Related**: `apps/tiktok/downloads/README.md`

### patch-download-path.js

Runtime path modification test. Intercepts LBT.LJ and replaces relative_path before MediaStore insert.

**Configuration**:
```javascript
const CUSTOM_PATH = "DCIM/TikTok/";  // Edit this
```

**Usage**:
```bash
frida -U -n com.ss.android.ugc.trill -l patch-download-path.js
# Download video in app
# Verify: adb shell ls /storage/emulated/0/DCIM/TikTok/
```

**Purpose**: Validate path modification approach before Smali/ReVanced implementation.

---

## Share URL Sanitization Scripts

### 1. `trace-share-url-tiktok.js`

**Target**: `com.ss.android.ugc.trill` (Trill / TikTok International) v36.5.4

**Hooks**:
- `X.UEU.LIZLLL()` - Main URL generation method
- `X.UEU.LIZJ()` - URL processing/transformation
- `X.UEU.LIZ()` - Bundle-based URL building

**Usage**:
```bash
# With USB device
frida -U -f com.ss.android.ugc.trill -l trace-share-url-tiktok.js

# Attach to running process
frida -U com.ss.android.ugc.trill -l trace-share-url-tiktok.js

# Save output to file
frida -U -f com.ss.android.ugc.trill -l trace-share-url-tiktok.js > tiktok-trace.log 2>&1
```

### 2. `trace-share-url-musically.js`

**Target**: `com.zhiliaoapp.musically` (Musically / TikTok US) v36.5.4

**Hooks**:
- `X.aOp.LIZLLL()` - Main URL generation method
- `X.aOp.LIZJ()` - URL processing/transformation
- `X.aOp.LIZ()` - Bundle-based URL building

**Usage**:
```bash
# With USB device
frida -U -f com.zhiliaoapp.musically -l trace-share-url-musically.js

# Attach to running process
frida -U com.zhiliaoapp.musically -l trace-share-url-musically.js

# Save output to file
frida -U -f com.zhiliaoapp.musically -l trace-share-url-musically.js > musically-trace.log 2>&1
```

### 3. `trace-download-path-musically.js`

**Target**: `com.zhiliaoapp.musically` (Musically / TikTok US) v36.5.4

**Purpose**: Find the actual download path method by tracing File I/O and storage operations

**Hooks**:
- File constructors and FileOutputStream
- Environment storage APIs (getExternalStorageDirectory, etc.)
- MediaStore ContentResolver operations
- ContentValues path setters (DISPLAY_NAME, RELATIVE_PATH)
- StringBuilder path construction
- `X.KHJ.LIZ()` / `X.K6I.LIZ()` (verification)

**Usage**:
```bash
# Option 1: Spawn and resume (type %resume in console after script loads)
frida -U -f com.zhiliaoapp.musically -l trace-download-path-musically.js > ../apps/tiktok/downloads/36.5.4/logs/frida-output.txt 2>&1

# Option 2: Attach to running app (RECOMMENDED)
adb shell am start -n com.zhiliaoapp.musically/.splash.SplashActivity
frida -U com.zhiliaoapp.musically -l trace-download-path-musically.js > ../apps/tiktok/downloads/36.5.4/logs/frida-output.txt 2>&1
```

**Note**: DO NOT use `--no-pause` flag - it doesn't work. Use spawn + %resume or attach method.

### 4. `compare-both-apps.sh`

**Usage**: Run tracing on both apps side-by-side for comparison

```bash
chmod +x compare-both-apps.sh
./compare-both-apps.sh
```

---

## Prerequisites

- Rooted Android device or debuggable APK
- frida-server running on device (match frida CLI version)
- Target APK installed

---

## References

- Feature docs: `../apps/tiktok/{share-url-sanitization,downloads}/README.md`
