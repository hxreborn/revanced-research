# TikTok Downloads Path Patch - Investigation Results

**Status:** ❌ PATCH BROKEN - Method doesn't exist in target version
**Version Tested:** TikTok v36.5.4 (Musically/US variant)
**Date:** 2025-10-27

---

## Problem Statement

The ReVanced downloads patch claims to redirect TikTok downloads from `DCIM/Camera/` to `Videos/TikTok/`, but downloads are actually saved to:
```
/storage/emulated/0/Android/data/com.ss.android.ugc.trill/files/share/out/
```

This is **app-scoped storage**, not the public `Videos/TikTok/` directory as intended.

---

## Root Cause Analysis

### Critical Finding #1: Method Doesn't Exist
The current patch targets `X/Kjb.LJJIIJ`, which **does not exist** in v36.5.4:

```
[-] Failed to hook X.Kjb.LJJIIJ: TypeError: cannot read property 'overload' of undefined
```

**Source:** `revanced-src/revanced-patches/patches/.../DownloadsPatch.kt:73-113`

The fingerprint matches something (allows patch to apply), but the target method signature has either:
- Changed between versions
- Been removed entirely
- Never existed in Musically variant

### Critical Finding #2: Wrong Download Flow

Frida trace reveals TikTok uses **two-stage download**:

1. **Stage 1 - App-Private Cache (actual files):**
   ```
   /storage/emulated/0/Android/data/com.ss.android.ugc.trill/files/share/out/video.mp4
   /storage/emulated/0/Android/data/com.ss.android.ugc.trill/files/share/tmp/video.mp4
   ```

2. **Stage 2 - MediaStore Registration (metadata only):**
   ```
   ContentValues.put("relative_path", "Videos/TikTok/")  ← FROM PATCH!
   ContentValues.put("_display_name", "video.mp4")
   ```

**The patch IS working for MediaStore**, but files never actually move because TikTok downloads to app storage using `File` API, not MediaStore directly.

---

## Frida Trace Output

**Command:**
```bash
frida -U TikTok -l trace-download.js
```

**Full Output (Download triggered):**
```
[*] TikTok Download Path Tracer Started
[*] Trigger a download in the app to see the trace
============================================================
[-] Failed to hook X.Kjb.LJJIIJ: TypeError: cannot read property 'overload' of undefined
[+] Hooked Context.getExternalFilesDir
[+] Hooked File constructor
[+] Hooked ContentValues.put

[*] All hooks installed. Trigger a download now!
============================================================

[File.<init>] Creating file with download-related path:
  Path: /storage/emulated/0/Android/data/com.ss.android.ugc.trill/files/share/out/ce8e25c739b7636185f85021df4b0f14.mp4

[File.<init>] Creating file with download-related path:
  Path: /storage/emulated/0/Android/data/com.ss.android.ugc.trill/files/share/tmp/ce8e25c739b7636185f85021df4b0f14.mp4

[File.<init>] Creating file with download-related path:
  Path: /storage/emulated/0/Android/data/com.ss.android.ugc.trill/files/share/out/ce8e25c739b7636185f85021df4b0f14.mp4

[File.<init>] Creating file with download-related path:
  Path: /storage/emulated/0/Android/data/com.ss.android.ugc.trill/files/share/tmp/ce8e25c739b7636185f85021df4b0f14.mp4

[File.<init>] Creating file with download-related path:
  Path: /storage/emulated/0/Android/data/com.ss.android.ugc.trill/files/share/out/ce8e25c739b7636185f85021df4b0f14.mp4

[File.<init>] Creating file with download-related path:
  Path: /storage/emulated/0/Android/data/com.ss.android.ugc.trill/files/share/out/ce8e25c739b7636185f85021df4b0f14.mp4

[File.<init>] Creating file with download-related path:
  Path: /storage/emulated/0/Android/data/com.ss.android.ugc.trill/files/share/out/ce8e25c739b7636185f85021df4b0f14.mp4

[File.<init>] Creating file with download-related path:
  Path: /storage/emulated/0/DCIM/Camera

[ContentValues.put] Setting MediaStore value:
  Key: _display_name
  Value: ce8e25c739b7636185f85021df4b0f14.mp4

[ContentValues.put] Setting MediaStore value:
  Key: relative_path
  Value: Videos/TikTok/
```

**Key Observations:**
- Files created in `/files/share/out/` (7 times - checking, temp, final)
- Files also created in `/files/share/tmp/` (temp download location)
- MediaStore shows `Videos/TikTok/` ✓ (patch working here)
- But actual file is in app storage ✗ (patch NOT intercepting File API)

---

## Technical Details

### Current Patch Logic (BROKEN)

**File:** `revanced-src/revanced-patches/patches/.../DownloadsPatch.kt`

```kotlin
downloadPathFingerprint.method.apply {
    // Find DIRECTORY_DCIM field access
    val dcimIndex = indexOfFirstInstructionReversed(cameraIndex) {
        val ref = (this as? ReferenceInstruction)?.reference as? FieldReference
        ref?.name == "DIRECTORY_DCIM"
    }

    // Replace DIRECTORY_DCIM with empty string
    replaceInstruction(dcimIndex, BuilderInstruction21c(
        Opcode.CONST_STRING, pathRegister, ImmutableStringReference("")
    ))

    // Replace "/Camera/" with "Videos/TikTok/"
    replaceInstruction(cameraIndex, BuilderInstruction21c(
        Opcode.CONST_STRING, pathRegister, ImmutableStringReference("Videos/TikTok/")
    ))
}
```

**Fingerprint:**
```kotlin
internal val downloadPathFingerprint = fingerprint {
    accessFlags(AccessFlags.PUBLIC, AccessFlags.STATIC)
    returns("Landroid/net/Uri;")
    parameters("Landroid/content/Context;", "Ljava/lang/String;")
    strings("video/mp4", "/Camera/")
}
```

**Problem:** This fingerprint doesn't match the actual download method being called.

### Smali Search Results

Found `/Camera/` in three locations:
```
smali_classes10/X/Jtr.1.smali:    const-string v0, "/Camera/"
smali_classes10/X/KHJ.smali:    const-string v0, "/DCIM/Camera/"
smali_classes10/X/Kjb.3.smali:    const-string v0, "/Camera/"
```

`X/Kjb.3.smali` contains the logic:
```smali
invoke-static {}, LX/CLD;->LIZ()Ljava/lang/StringBuilder;
move-result-object v1
sget-object v0, Landroid/os/Environment;->DIRECTORY_DCIM:Ljava/lang/String;
invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
const-string v0, "/Camera/"
invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
invoke-static {v1}, LX/CLD;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;
move-result-object p5
```

**But this method is NOT called during downloads!**

---

## Next Steps

### Immediate Action Items (Next Session)

**Priority 1: Identify Actual Download Method**
```bash
# 1. Run verbose Frida script to capture ALL method calls during download
frida -U TikTok -l apps/tiktok/downloads/36.5.4/trace-download-verbose.js

# 2. Trigger download in TikTok app
# 3. Capture and analyze output to find which methods are actually called

# Expected output will show:
# - Which X.Kjb methods (if any) are invoked
# - Where /share/out/ path is constructed
# - Stack traces showing call chain from UI to File API
```

**Priority 2: Search Smali for File Creation Logic**
```bash
# Find where "/share/out/" or "share" + "out" strings are used
cd apps/tiktok/apks/36.5.4/apktool-smali
grep -r '"share"' smali* | grep "const-string" | grep -i "out\|download\|video"

# Find getExternalFilesDir usage
grep -r "getExternalFilesDir" smali* | less

# Identify the class that constructs the download path
```

**Priority 3: Locate Alternative Hook Points**
- Search for methods that call `File.<init>` with paths containing "share/out"
- Find download completion callbacks
- Identify ContentResolver.insert call sites to hook earlier in the flow

---

### Long-Term Fix Strategies

### Option 1: Find Correct Method (Recommended)
1. Use verbose Frida script (`trace-download-verbose.js`) to hook ALL `X.Kjb` methods
2. Identify which method (if any) constructs the MediaStore path
3. Update fingerprint to target correct method
4. Test if files actually move to public storage

### Option 2: Hook File API Directly
1. Find where `getExternalFilesDir()` + `/share/out/` is constructed
2. Patch that location to use `Environment.getExternalStoragePublicDirectory(DIRECTORY_DCIM)` instead
3. This would redirect at the File API level, not MediaStore

### Option 3: Post-Download Move
1. Let TikTok download to app storage
2. Hook the download completion callback
3. Move file from `/files/share/out/` to `Videos/TikTok/`
4. Update MediaStore entry to point to new location

---

### Questions to Answer Next Session

1. **Does X.Kjb contain ANY methods in v36.5.4?**
   - Run: `frida -U TikTok -e 'Java.perform(() => console.log(Java.use("X.Kjb").class.getDeclaredMethods()))'`

2. **Where is "/share/out/" constructed?**
   - Check Smali for string concatenation or StringBuilder usage
   - May be split into separate strings: "share" + "/" + "out"

3. **Can we hook earlier in the flow?**
   - Before File API calls
   - At download button click handler
   - At download intent creation

4. **Should we abandon X.Kjb entirely?**
   - If the class no longer handles downloads, find the new handler
   - May need to search for "video/mp4" MIME type usage instead

---

## Tools & Scripts

### Frida Scripts
- `trace-download.js` - Basic download tracing (used for investigation)
- `trace-download-verbose.js` - Comprehensive tracing with stack traces
- `frida-setup.md` - Frida installation guide

### Commands Used
```bash
# Decompile APK
apktool d base.apk -o apktool-smali

# Search for /Camera/ string
grep -r "/Camera/" apktool-smali/smali* | grep "const-string"

# Run Frida trace
frida -U TikTok -l trace-download.js
```

---

## Environment

- **Device:** Pixel 9 Pro (id=47011FDAP000KT)
- **Android Version:** (not specified)
- **TikTok APK:** `com.zhiliaoapp.musically_36.5.4-2023605040_minAPI21(arm64-v8a,armeabi-v7a)(nodpi)_apkmirror.com.apk`
- **Frida:** v17.4.1 (client + server)
- **ReVanced Patches:** commit `668c0844` (fix/tiktok-downloads-path branch)

---

## References

- **ReVanced Patch:** `revanced-src/revanced-patches/patches/src/main/kotlin/app/revanced/patches/tiktok/interaction/downloads/`
- **Extension:** `revanced-src/revanced-patches/extensions/tiktok/src/main/java/app/revanced/extension/tiktok/download/DownloadsPatch.java`
- **Smali Files:** `apps/tiktok/apks/36.5.4/apktool-smali/smali_classes10/X/Kjb.*.smali`

---

## Conclusion

The current patch is **fundamentally broken** for v36.5.4:
1. ✗ Target method doesn't exist
2. ✗ Wrong code path (File API, not MediaStore)
3. ✓ MediaStore metadata is correct (but files aren't there)

**Impact:** Downloads appear in gallery apps (due to MediaStore entry) but physical files are in app-scoped storage, making them inaccessible to other apps and difficult to find for users.

**Fix Required:** Complete rewrite targeting the actual download flow, likely hooking `getExternalFilesDir()` or the File creation logic.
