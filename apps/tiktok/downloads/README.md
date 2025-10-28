# Downloads - TikTok

Status: Complete. Patch implemented, tested on-device.

---

## Target Method

`X.DVV.LIZLLL` (classes6.dex): `PUBLIC STATIC (Context, String) → Uri`

Constructs MediaStore `relative_path` for video downloads. Fingerprint: `"video/mp4"` + `"/Camera/"`.

---

## Implementation

**Previous approach:** Located two instruction indices (`<init>` call and Uri-returning method) via `indexOfFirstInstructionOrThrow`, inserted `getDownloadPath()` calls with result in v0. Stopped working on v36.5.4 (reported September 2024, [#3695](https://github.com/ReVanced/revanced-patches/issues/3695)) - downloads saved to DCIM regardless of configured folder.

**Current approach:** Pattern-match `Environment.DIRECTORY_*` field accesses. Remove 4-instruction sequence (field load + append + string literal + append), replace with 3-instruction extension call + append.

```kotlin
instructions.withIndex()
    .filter { (it.value as? ReferenceInstruction)?.reference as? FieldReference
        matches Environment.DIRECTORY_* }
    .asReversed()  // preserve index validity during mutation
    .forEach { fieldIndex ->
        repeat(4) { removeInstruction(fieldIndex) }
        addInstructions(fieldIndex, extension call + append)
    }
```

Difference: Current approach removes original path construction at field access, preventing TikTok's hardcoded logic from executing. Previous approach inserted extension calls but allowed original construction to overwrite register.

Processes 2 occurrences per method (v36.5.4).

---

## Settings

`DownloadsPatch.getDownloadPath()` returns `Settings.DOWNLOAD_PATH` value:
- Format: `"BaseDir/Subdirectory/"` (trailing slash enforced)
- Default: `"DCIM/TikTok"`
- UI: Radio (DCIM/Movies/Pictures) + text input for subdirectory

---

## Validation

com.zhiliaoapp.musically v36.5.4 (on-device):
- Default `DCIM/TikTok` → `/storage/emulated/0/DCIM/TikTok/` ✓
- Custom `Pictures/CustomPath` → `/storage/emulated/0/Pictures/CustomPath/` ✓
