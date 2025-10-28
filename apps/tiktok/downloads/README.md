# Downloads - TikTok

## Status

**Phase 1 (Foundation):** Complete. X.DVV.LIZLLL fingerprint working with 2 string anchors. Extension method injects path modification.

**Phase 2 (Refactor):** Complete. Simplified patch to high-level API (`addInstructions`). Injects `DownloadsPatch.getDownloadPath()` calls instead of bytecode manipulation.

**Phase 3 (Settings):** Pending. Integrate user-configurable path via ReVanced settings instead of hardcoded "Movies/TikTok/".

---

## Patch Location

`revanced-src/revanced-patches/patches/src/main/kotlin/app/revanced/patches/tiktok/interaction/downloads/`

---

## Current Implementation

### Target Method
X.DVV.LIZLLL (classes6.dex): `PUBLIC STATIC (Context, String) → Uri`

Constructs MediaStore `relative_path` parameter. Fingerprint anchors: `"video/mp4"` and `"/Camera/"`.

### Why 2 Strings, Not 4

Generic strings `"/"` and `"/Camera"` matched multiple methods across DEXes (wrong targets). Refined to `"video/mp4"` + `"/Camera/"` for X.DVV.LIZLLL specificity.

### Implementation
Patch uses high-level patcher API to inject calls to `DownloadsPatch.getDownloadPath()` extension method at two injection points in X.DVV.LIZLLL:
1. After method references that return `Uri` type
2. After `<init>` method references

Extension method handles path resolution. Currently returns hardcoded "Movies/TikTok/".

### Tested On
- com.zhiliaoapp.musically v36.5.4 (device): Downloads confirmed in /storage/emulated/0/Movies/TikTok/

---

## Next

Phase 3: Replace hardcoded path with user-configurable path via ReVanced settings.
