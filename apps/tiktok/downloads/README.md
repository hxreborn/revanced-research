# Downloads - TikTok

## Status

**Phase 1 (Foundation):** Complete. X.DVV.LIZLLL fingerprint working. Patch applies and modifies MediaStore path via extension method.

**Phase 2 (Refactor):** In progress. Simplify DownloadsPatch.kt from low-level instruction manipulation to high-level patcher API. Replace `BuilderInstruction21c` with `replaceInstructions`.

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

### Current Approach
1. Patch finds `<init>` and `Uri`-return method references
2. Injects `DownloadsPatch.getDownloadPath()` calls
3. Extension returns hardcoded "Movies/TikTok/"
4. MediaStore receives modified path

### Tested On
- com.zhiliaoapp.musically v36.5.4 (device): Downloads confirmed in /storage/emulated/0/Movies/TikTok/

---

## Next Steps

1. Replace low-level `BuilderInstruction21c` manipulation with `replaceInstructions(smali_string)`
2. Integrate with settings extension for user-configurable path
3. Remove hardcoded path constant
