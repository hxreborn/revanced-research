# Downloads - TikTok

## Summary

ReVanced patch for TikTok 36.5.4 downloads customization. Target methods use MediaStore scoped storage API to control download destination via `relative_path` parameter.

**Status:** Patch implementation in progress. Smali-level validation confirmed approach works (tested on device). ReVanced patch developed targeting X/LBT.LIZLLL (Trill) and X/Kjb.LJJIIJ (Musically) but device testing shows downloads still go to default location.

**Root cause of failure:** X.Kjb.LJJIIJ (Musically) method exists but is not invoked during regular video downloads. Downloads use different code path via X.CtJ.LIZ. Patch requires redesign to target actual download method.

Patch: `revanced-src/revanced-patches/patches/src/main/kotlin/app/revanced/patches/tiktok/interaction/downloads/`

---

## Version Map

| Version | App | Status | Files |
|---------|-----|--------|-------|
| 36.5.4 | Trill | ReVanced Patch Developed | [LBT.smali](36.5.4/files/LBT.smali) (classes10.dex) |
| 36.5.4 | Musically | ReVanced Patch Developed | Kjb.LJJIIJ in classes10.dex |

**Testing tools:**
- [trace-lbt-methods.js](../../../frida-scripts/trace-lbt-methods.js) - Runtime method execution trace
- [patch-download-path.js](../../../frida-scripts/patch-download-path.js) - ContentValues interception

---

## Technical Reference

---

## Validation

### Runtime Test Results (Frida)

| Test | Result | Evidence |
|------|--------|----------|
| LBT.LIZLLL execution | Called during download | Frida trace, stack dump |
| LBT.LJ execution | Called with relative_path="DCIM/Camera/" | Frida trace, parameter log |
| ContentValues interception | Modified relative_path to "DCIM/TikTok/" | Frida hook output |
| MediaStore insert | Received modified ContentValues | ContentResolver.insert() log |
| File location verification | File saved to DCIM/TikTok/ | adb shell ls, 10MB file at 15:11 |

### Smali Validation Results

| Test | Result | Evidence |
|------|--------|----------|
| Patch location | LBT.smali:11694 (apktool) / :829 (baksmali) | String replacement verified |
| DEX reassembly | Reassembled classes10.dex, injected into stock APK | 11MB patched DEX |
| APK rebuild | Single DEX injection, avoided full rebuild | 380MB signed APK |
| Installation | Installed via incremental install | 10.3s |
| File location | File saved to DCIM/TikTok/ | 702KB file at 15:56 |

Change: `const-string v0, "/Camera/"` → `const-string v0, "/TikTok/"` in LBT.LIZLLL method.

**Test commands:**
```bash
# Trace methods
frida -U $(adb shell pidof com.ss.android.ugc.trill) -l frida-scripts/trace-lbt-methods.js

# Test path modification
frida -U $(adb shell pidof com.ss.android.ugc.trill) -l frida-scripts/patch-download-path.js
```

**Frida output (2025-10-27):**
```
[CONTENTVALUES] put(relative_path) intercepted
  Original: DCIM/Camera/
  Patched:  DCIM/TikTok/

[CONTENTRESOLVER] insert() called
  Uri: content://media/external_primary/video/media
  ContentValues:
    relative_path: DCIM/TikTok/
    _display_name: 2dc2091647ea9b6e978d755fa82ad36b.mp4
    mime_type:     video/mp4
```

---

## Implementation

### Root Cause

TikTok 36.5.4 uses two-stage download process with separate code paths:

**Stage 1: File Creation (App-Scoped Storage)**
- Method: X.CtJ.LIZ
- Downloads to: `/storage/emulated/0/Android/data/com.ss.android.ugc.trill/files/share/out/`
- This is the actual download destination where files are written
- Method signature and exact invocation path identified via Frida stack traces

**Stage 2: MediaStore Registration (Public Storage Intent)**
- Method: X.Kjb.LJJIIJ (Musically) or X.LBT.LIZLLL (Trill)
- Constructs: `DIRECTORY_DCIM + "/Camera/"` via StringBuilder
- Calls: ContentResolver.insert with relative_path parameter
- Result: MediaStore metadata updated but files NOT moved from `/files/share/out/`

**Current patch targets Stage 2 only**, which does not affect actual download location. Files remain in app-scoped storage despite correct MediaStore metadata.

**Download flow (current):**
```
Stage 1 - X.CtJ.LIZ(Context, String) → File
  └─ Creates file in /files/share/out/ directory

Stage 2 - X.Kjb.LJJIIJ(Context, String, ...) → Uri
  ├─ Constructs relative_path: DIRECTORY_DCIM + "/Camera/"
  └─ ContentResolver.insert registers file with MediaStore
```

### Solution

StringBuilder constructs `DIRECTORY_DCIM + "/Camera/"` (evaluated to "DCIM/Camera/"). Replacement with extension method returning full path requires:
1. Replace `DIRECTORY_DCIM` sget with empty string to avoid `"DCIM" + "DCIM/TikTok/"` duplication
2. Replace `/Camera/` literal with extension method returning user-configured path

**Target methods (MediaStore registration):**

**Trill 36.5.4:**
```smali
.method public static LIZLLL(Landroid/content/Context;Ljava/lang/String;)Landroid/net/Uri;
```

**Musically 36.5.4:**
```smali
.method public static LJJIIJ(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;ZLjava/lang/String;Ljava/lang/String;I)Landroid/net/Uri;
```

Note: Musically method has 7 parameters but ReVanced fingerprint specified 2 (parameter count mismatch). Method exists at `smali_classes10/X/Kjb.3.smali:5034` but is not called during regular downloads.

Both construct relative_path via:
```smali
sget-object v0, Landroid/os/Environment;->DIRECTORY_DCIM:Ljava/lang/String;
invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(...)
const-string v0, "/Camera/"
invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(...)
```

**Actual download method (not patched):**
- Method: `X/CtJ.LIZ(Context, String) → File`
- Location: classes10.dex
- Behavior: Writes files to `/storage/emulated/0/Android/data/.../files/share/out/`
- This method requires patching to change download destination

**Injection points:**
1. Locate `/Camera/` string literal (unique anchor)
2. Replace DIRECTORY_DCIM sget with empty string constant
3. Replace `/Camera/` literal with extension method call

Register names extracted from instructions (no hardcoded register assumptions).

**Fingerprint design:**
- No parameters() constraint to match both Trill (2 params) and Musically (7 params)
- Strings matching: `/Camera/` and `video/mp4` as anchors
- Custom guards: single `/Camera/` literal, LJ method call with 4 parameters (MediaStore signature)

**Patch modifications:**
1. Find `/Camera/` string reference
2. Extract register from const-string instruction
3. Walk backward to find DIRECTORY_DCIM sget
4. Replace DIRECTORY_DCIM with empty string
5. Replace `/Camera/` with `invoke-static` to extension method

Extension method `getDownloadPath()` returns configured path with trailing slash appended (required for MediaStore scoped storage).

---

## Investigation & Status

### Phase 1: Initial Discovery (2025-10-26)
- fingerprint matched zero methods in standard locations
- K6I/KHJ class located with `/DCIM/Camera/` strings
- Frida trace confirmed these methods never called during actual downloads

### Phase 2: MediaStore Method Location (2025-10-27)
- X.LBT.LIZLLL identified in Trill (classes10.dex)
- X.Kjb.LJJIIJ identified in Musically (classes10.dex at smali_classes10/X/Kjb.3.smali:5034)
- Both handle MediaStore registration with `/Camera/` path
- Smali-level patch successful: Modified string literal, reassembled DEX, device test showed files saved to custom location

### Phase 3: Device Testing Reveals Real Issue (2025-10-28)
- ReVanced patch developed and applied successfully
- Device test: Downloads still go to DCIM/Camera/ (or /files/share/out/ for Musically)
- Root cause identified: Patched methods are not called during regular video downloads
- Two-stage process discovered:
  - **X.CtJ.LIZ** (real download method, NOT patched) writes to `/files/share/out/`
  - **X.Kjb.LJJIIJ** (patched) only handles MediaStore metadata registration
- Files never reach public storage because Stage 1 writes to app-scoped storage

### Current Status
**Patch requires redesign** to target X.CtJ.LIZ instead of X.Kjb.LJJIIJ. Current patch successfully modifies bytecode but has zero runtime effect on download destination.

---

## References

- Workflow: [Phase 2 (Smali Testing)](/WORKFLOW.md#phase-2-smali-testing)
- ReVanced Patch: [DownloadsPatch.kt](../../../revanced-src/revanced-patches/patches/src/main/kotlin/app/revanced/patches/tiktok/interaction/downloads/DownloadsPatch.kt)
