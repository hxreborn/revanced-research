# Downloads - TikTok

## Summary

ReVanced patch for TikTok 36.5.4 downloads customization. Patch replaces DIRECTORY_DCIM with empty string and `/Camera/` with extension method returning full path (`DCIM/TikTok/` or `Videos/TikTok/`).

Fingerprint matches Trill (X/LBT.LIZLLL) and Musically (X/Kjb.LJJIIJ) variants using method signature guards instead of obfuscated class name matching.

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

TikTok 36.5.4 uses MediaStore scoped storage API via ContentValues relative_path parameter instead of direct file path operations.

**Download flow:**
```
LBT.LIZLLL(Context, String) → Uri
  ├─ Constructs relative_path via StringBuilder
  ├─ DIRECTORY_DCIM + "/Camera/" = "DCIM/Camera/"
  └─ LBT.LJ invokes ContentResolver.insert with relative_path
```

### Solution

StringBuilder constructs `DIRECTORY_DCIM + "/Camera/"` (evaluated to "DCIM/Camera/"). Replacement with extension method returning full path requires:
1. Replace `DIRECTORY_DCIM` sget with empty string to avoid `"DCIM" + "DCIM/TikTok/"` duplication
2. Replace `/Camera/` literal with extension method returning user-configured path

**Target methods:**
- Trill 36.5.4: `X/LBT.LIZLLL(Context, String)` in classes10.dex
- Musically 36.5.4: `X/Kjb.LJJIIJ(Context, String, String, Z, String, String, I)` in classes10.dex

Both construct relative_path via:
```smali
sget-object v0, Landroid/os/Environment;->DIRECTORY_DCIM:Ljava/lang/String;
invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(...)
const-string v0, "/Camera/"
invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(...)
```

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

## Timeline

### Investigation Summary (2025-10-26 to 2025-10-28)

**Initial attempts:** downloadUriFingerprint matched zero methods. K6I/KHJ class located with `/DCIM/Camera/` strings but Frida trace showed method never invoked during downloads.

**DG6 variant:** DG6.LIZLLL found in call stack but patch application failed - downloads still directed to DCIM/Camera. Cause: TikTok 36.5.4 uses MediaStore API rather than direct file path operations.

**Correct target method:** X.LBT.LIZLLL located in classes10.dex. Method constructs `/Camera/` string passed to LBT.LJ, which calls ContentResolver.insert with relative_path parameter.

**Smali-level patch:** LBT.smali modified at string literal location. DEX reassembled and injected into APK. Device test confirmed downloads saved to custom location.

**ReVanced patch development:**
- Fingerprint designed without parameter count constraint (matches both Trill and Musically variants)
- Method guard: single `/Camera/` literal, LJ invocation with 4 parameters
- Initial build succeeded but patch applied with path duplication (DIRECTORY_DCIM + full path)
- Root cause: Extension method returned full path but code prepended DIRECTORY_DCIM
- Solution: Replace DIRECTORY_DCIM constant with empty string, replace `/Camera/` with extension call
- Register extraction from const-string instruction (no register name hardcoding)

Status: Patch modifications implemented and compiled successfully. Device testing pending.

---

## References

- Workflow: [Phase 2 (Smali Testing)](/WORKFLOW.md#phase-2-smali-testing)
- ReVanced Patch: [DownloadsPatch.kt](../../../revanced-src/revanced-patches/patches/src/main/kotlin/app/revanced/patches/tiktok/interaction/downloads/DownloadsPatch.kt)
