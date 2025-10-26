# Frida Tracing Scripts for TikTok Share URL Sanitization

**Purpose**: Dynamic analysis of share URL generation in TikTok apps to understand runtime behavior before developing Smali patches.

---

## Scripts

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

### 3. `compare-both-apps.sh`

**Usage**: Run tracing on both apps side-by-side for comparison

```bash
chmod +x compare-both-apps.sh
./compare-both-apps.sh
```

---

## Prerequisites

### Install Frida

```bash
# Install Frida CLI tools
pip install frida-tools

# Verify installation
frida --version
```

### Setup Device

1. **Root your Android device** or use an emulator with root access
2. **Install frida-server** on the device:

```bash
# Download frida-server matching your Frida version
# https://github.com/frida/frida/releases

# Push to device
adb push frida-server-16.1.3-android-arm64 /data/local/tmp/frida-server
adb shell "chmod 755 /data/local/tmp/frida-server"

# Run frida-server
adb shell "/data/local/tmp/frida-server &"
```

3. **Verify connection**:

```bash
frida-ps -U
```

### Install Target Apps

Download base APKs separately (APK binaries are gitignored):

```bash
# Verify APKs are present locally
ls -lh apps/tiktok/trill/apks/36.5.4/base.apk
ls -lh apps/tiktok/musically/apks/36.5.4/base.apk

# Then install
adb install apps/tiktok/trill/apks/36.5.4/base.apk
adb install apps/tiktok/musically/apks/36.5.4/base.apk
```

---

## How to Trigger Share Actions

### Method 1: UI Interaction
1. Open the app
2. Navigate to any video
3. Tap the "Share" button
4. Select any share method (copy link, share to...)

### Method 2: Deep Link
```bash
# Trigger share programmatically
adb shell am start -a android.intent.action.VIEW \
  -d "snssdk1233://video/<video_id>"
```

---

## Expected Output

### Successful Hook
```
[*] Trill Share URL Tracer Started
[*] Target: com.ss.android.ugc.trill v36.5.4
[*] Waiting for share action...

[+] Hooked: X.UEU.LIZLLL()
[+] Hooked: X.UEU.LIZJ()
[+] Hooked: X.UEU.LIZ()
```

### When Share Button is Clicked
```
================================================================================
[+] LIZLLL METHOD CALLED
================================================================================
[*] Timestamp: 2025-10-24T12:30:45.123Z

[PARAMETERS]
  └─ Int param: 1
  └─ URL (str1): https://vm.tiktok.com/ABCD1234/
  └─ Item Type: video
  └─ Key: share_url

[*] Calling original LIZLLL...

[RESULT]
  └─ Return type: X.Wu4
  └─ Observable returned (will emit URL asynchronously)

[CALL STACK]
<stack trace showing caller hierarchy>
================================================================================

[→] LIZJ (URL Processing) Called
    Input URL: https://vm.tiktok.com/ABCD1234/
    Item Type: video
    Key: share_url
    Output URL: https://vm.tiktok.com/ABCD1234/?utm_source=...
    [!] URL Modified!
    [!] Bytes added: 505
    [!] Potential tracking params detected
    [!] Parameters:
        └─ [TRACKING] utm_source = share
        └─ [TRACKING] utm_medium = android
        └─ [TRACKING] share_link_id = abc123
        └─ [TRACKING] enter_from = main_page
        ...
```

---

## What to Look For

### 1. Tracking Parameters Added
The scripts highlight parameters that start with:
- `utm_*` - Campaign tracking
- `share_*` - Share attribution
- `sec_*` - Security tokens
- `enter_from`, `enter_method` - Navigation tracking
- `timestamp_ms` - Timestamp

### 2. URL Transformation
- Compare input URL vs output URL
- Note the byte size increase (should be ~505 bytes)
- Identify all parameter names and values

### 3. Call Stack
- Understand where the share action is triggered from
- Identify UI components or share handlers
- Map the execution flow

### 4. Return Values
- Observable pattern (async URL emission)
- How the URL is packaged for the share sheet

---

## Troubleshooting

### "Error: Java API not available"
- Ensure the app is running when attaching Frida
- Use `-f` flag to spawn the app: `frida -U -f <package> -l script.js`

### "TypeError: cannot read property 'overload' of undefined"
- The class or method might not be loaded yet
- Try performing a share action to trigger class loading
- Add `Java.classFactory.loader` checks if needed

### "Failed to spawn: unable to find application"
- Verify the package name: `adb shell pm list packages | grep tiktok`
- Ensure the APK is installed: `adb shell pm list packages -f`

### No output when sharing
- Add console.log to verify hooks are installed
- Try different share methods (copy link vs share to app)
- Check if the share button actually triggers URL generation

---

## Next Steps After Tracing

1. **Analyze Logs**: Compare Trill vs Musically output
2. **Identify Patterns**: Look for common bytecode paths
3. **Parameter List**: Document all tracking parameters found
4. **Develop Patch**: Use insights to create Smali modifications
5. **Validate**: Re-run Frida after patching to confirm parameters removed

---

## References

- Feature Documentation: `../apps/tiktok/share-url-sanitization/README.md`
- Obfuscation Map: See "Technical Reference" section in feature README
- Key Smali Files: `../apps/tiktok/share-url-sanitization/36.5.4/key-files/`

Note: Decompiled sources (JADX, apktool outputs) are gitignored for size. Generate locally using:
```bash
cd apps/tiktok/<variant>/apks/36.5.4/
jadx -d jadx-deobf base.apk
apktool d base.apk -o apktool
```
