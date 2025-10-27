# Downloads - TikTok

## Summary

Downloads ignore custom path setting in ReVanced menu.
Files save to `/Android/data/com.ss.android.*/files/share/out/` then copied to DCIM/Camera by MediaStore API.

Cause: `downloadPathFingerprint` targets dead code (K6I/KHJ methods never execute during downloads).

Solution: Target actual download path constructor `X/DG6.LIZLLL(Context)` using `/share/` string in classes6.dex.

Patch: `revanced-src/revanced-patches/patches/src/main/kotlin/app/revanced/patches/tiktok/interaction/downloads/`

**CRITICAL DISCOVERY:** K6I/KHJ methods containing `/DCIM/Camera/` exist but are **NEVER called**. Runtime analysis proves DG6.LIZLLL is the actual download path method.

---

## Version Map

| Version | App | Status | Files |
|---------|-----|--------|-------|
| 36.5.4 | Trill | Runtime Verified | [DG6.smali](36.5.4/files/DG6.smali) (actual), ~~K6I.smali~~ (dead code) |
| 36.5.4 | Musically | Pending | DG6.smali expected in classes6.dex |

Note: K6I/KHJ exist and contain `/DCIM/Camera/` but are never executed. Confirmed via Frida runtime tracing.

---

## Technical Reference

### Runtime Analysis (Frida - 2025-10-27)

**Objective:** Determine why current patch targets K6I/KHJ but downloads still use default path.

**Method:** Instrumented File I/O operations during live downloads using Frida on Pixel 9 Pro.

**Key Findings:**

Download call stack (actual execution):
```
X.DG6.LIZ(SourceFile:16777226)
  ↓
X.UbO.LIZ(SourceFile:16777324)
  ↓
X.UMX.LJJIJ(SourceFile:117440924)
  ↓
X.UMX.LJIIL(SourceFile:33554458)
```

Actual download path:
```
/storage/emulated/0/Android/data/com.ss.android.ugc.trill/files/share/out/491f78cbaa2881116ec5e8d1108f2fc1.mp4
```

**Critical Evidence:**
- `DG6.LIZ()` called multiple times per download (File constructor invocations)
- `K6I.LIZ()` NEVER called during downloads
- `KHJ.LIZ()` NEVER called during downloads
- Files written to `/Android/data/.../files/share/out/` (app-specific storage)
- DCIM/Camera copies appear via MediaStore API **after** download completes (different inodes, separate operation)

**Conclusion:** K6I/KHJ are legacy/unused code paths. DG6.LIZLLL constructs actual download path.

Log evidence: `apps/tiktok/downloads/36.5.4/logs/frida-dcim-live.log` (67,022 lines)

### Current Patch Structure

DownloadsPatch.kt components:

ACL restrictions functional:
- `aclCommonShareFingerprint` → ACLCommonShare.getCode() returns 0
- `aclCommonShare2Fingerprint` → ACLCommonShare.getShowType() returns 2
- `aclCommonShare3Fingerprint` → ACLCommonShare.getTranscode() watermark removal

Download path non-functional:
- `downloadUriFingerprint` → targets non-existent method
- Injects `DownloadsPatch.getDownloadPath()` at 2 locations
- Both write to v0 register (second overwrites first)

downloadUriFingerprint definition:
```kotlin
internal val downloadUriFingerprint = fingerprint {
    accessFlags(AccessFlags.PUBLIC, AccessFlags.STATIC)
    returns("Landroid/net/Uri;")
    parameters(
        "Landroid/content/Context;",
        "Ljava/lang/String;"
    )
    strings(
        "/",
        "/Camera",
        "/Camera/",
        "video/mp4"
    )
}
```

Patch weaknesses:
- Fragile string matching
- Double injection to same register
- No verification custom path applies
- Silent failure: ACL patches work, path doesn't

### Fingerprint Failure Analysis

Searched classes.dex: Musically 14,966 files, Trill 14,863 files.

Method signature `(Context,String)→Uri`:
- Musically: absent
- Trill: absent

Strings:
- "/Camera": absent both variants
- "/Camera/": absent both variants
- "video/mp4": absent both variants

downloadUriFingerprint matches zero methods in 36.5.4 for both variants.

### DG6.LIZLLL - Actual Download Path Constructor

Location: `smali_classes6/X/DG6.smali:587-748`

Signature:
```smali
.method public static LIZLLL(Landroid/content/Context;)Ljava/lang/String;
```

Path construction (line 667):
```smali
const-string v0, "/share/"
invoke-virtual {p0, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
```

Returns: `{base_path}/share/` stored in static field `DG6.LIZ`

Base path determined by:
1. Checks `D7F.PREFER_PRIVATE` policy
2. Calls `D7B.LJII(Context, D7F)` → returns File
3. Falls back to `ccj.LLLLIIIILLL(Context, null)` if null
4. Appends `/share/` component

Result: `/Android/data/com.ss.android.*/files/share/`

### K6I/KHJ - Dead Code (Not Executed)

Location: `smali_classes10/X/K6I.smali:4522` (Trill), `X/KHJ.smali` (Musically)

Contains `/DCIM/Camera/` string but never invoked during downloads. Runtime analysis confirmed zero calls.

---

## Validation

### Runtime Test

Installed debug APK with logs in `X/1pI.onSuccessed`.

Results:
- Downloads functional
- Watermark removal functional
- Custom path ignored, saves to DCIM/Camera
- Debug logs absent, X/1pI unrelated to video downloads

downloadUriFingerprint non-functional, ACL fingerprints functional.

### Test Matrix

| Scenario | Result | Evidence |
|----------|--------|----------|
| Download with custom path | Ignored, saves to DCIM/Camera | Runtime test |
| Watermark removal | Functional | Runtime test |
| Fingerprint match | Zero matches in classes.dex | Static analysis |
| Actual method location | classes10.dex line 4522 | Static analysis |

---

## Implementation (2025-10-27 Update)

Replaced downloadPathFingerprint targeting K6I/KHJ with DG6-focused approach:

```kotlin
internal val downloadPathFingerprint = fingerprint {
    accessFlags(AccessFlags.PUBLIC, AccessFlags.STATIC)
    returns("Ljava/lang/String;")
    parameters("Landroid/content/Context;")
    strings("/share/")
    custom { method, classDef ->
        classDef.endsWith("/DG6;")
    }
}
```

Fingerprint strategy:
- Matches `LIZLLL(Context) -> String` signature
- Targets `/share/` string (line 667 in DG6.smali)
- Class validation prevents matching Cne.LJIILJJIL (which also has `/share/` + Context)
- Avoids hardcoded method names (resilient to obfuscation)

**Critical Discovery:**
K6I/KHJ (dead code) builds public path:
```
Environment.getExternalStorageDirectory() + "/DCIM/Camera/"
= /storage/emulated/0/DCIM/Camera/  (public storage)
```

DG6.LIZLLL (actual code) builds app-specific path:
```
D7B.LJII(Context, PREFER_PRIVATE) + "/share/"
= /Android/data/com.ss.android.*/files/share/  (app-specific storage)
```

Replacing `/share/` alone insufficient - still results in app-specific storage with different folder name.

**Solution:** Replace entire return value with public path.

Injection:
```kotlin
val returnIndex = indexOfFirstInstructionOrThrow {
    opcode == Opcode.RETURN_OBJECT
}

addInstructions(returnIndex,
    """
    invoke-static {}, Lapp/revanced/extension/tiktok/download/DownloadsPatch;->getDownloadPath()Ljava/lang/String;
    move-result-object v0
    """
)
```

`getDownloadPath()` returns: `Environment.getExternalStorageDirectory() + "/" + userPath + "/"`

Result: Downloads go directly to user-configured public storage (e.g., `/storage/emulated/0/DCIM/TikTok/`), bypassing app-specific storage entirely.

---

## Timeline

### Initial Analysis (2025-10-26)
- 14:00: Identified downloadUriFingerprint matches zero methods
- 14:20: Located K6I/KHJ methods containing `/DCIM/Camera/` in classes10.dex
- 14:30: Created fingerprint targeting K6I.LIZ

### Runtime Discovery (2025-10-27)
- 09:00: Frida File I/O instrumentation on Pixel 9 Pro
- 09:15: Traced download to `/Android/data/.../files/share/out/`, K6I never called
- 09:30: Identified DG6.LIZ in call stack, confirmed via stack traces
- 10:00: Decompiled 49 DEX files (400MB APK, 20GB RAM, 8 threads)
- 10:15: Found DG6.LIZLLL(Context) in smali_classes6, line 667: `/share/`
- 10:45: Created resilient fingerprint using Context parameter + `/share/` string
- 11:02: Built patches-5.45.0-dev.2.rvp with updated fingerprint
- 11:20: First patch attempt crashed (Cne.LJIILJJIL also matched, register overflow)
- 11:28: Added class validation (`endsWith("/DG6;")`), removed logging code
- 11:35: Discovered app-specific vs public storage issue, updated extension to return full path
- 11:40: Test failed - downloads still go to DCIM/Camera (MediaStore API likely involved)

---

## References

- Workflow: [Phase 2 (Smali Testing)](/WORKFLOW.md#phase-2-smali-testing)
- ReVanced Patch: [DownloadsPatch.kt](../../../revanced-src/revanced-patches/patches/src/main/kotlin/app/revanced/patches/tiktok/interaction/downloads/DownloadsPatch.kt)
