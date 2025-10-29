# Downloads - TikTok

Status: Complete. Patch implemented, tested on-device.

---

## Target Method

`X.DVV.LIZLLL` (classes6.dex): `PUBLIC STATIC (Context, String) → Uri`

Constructs MediaStore `relative_path` for video downloads. Fingerprint: `"video/mp4"` + `"/Camera/"`.

---

## Why Main Branch Failed on 36.5.4

Main injected `getDownloadPath()` calls but never removed the 4-instruction block constructing `Environment.DIRECTORY_DCIM + "/Camera/"`. Stock path construction executed after injection, overwriting custom path. Downloads always saved to DCIM/Camera ([#3695](https://github.com/ReVanced/revanced-patches/issues/3695)).

Fingerprint was not the issue. ReVanced uses fuzzy matching - the original 4-string fingerprint `("/", "/Camera", "/Camera/", "video/mp4")` successfully matches LIZLLL method on v36.5.4 despite method containing only `("/", "/TikTok", "/TikTok/", "video/mp4")`. Verified via logcat on both trill (LX/LBT;.LIZLLL) and musically (LX/DVV;.LIZLLL).

---

## Current Implementation

### Fingerprint (Fingerprints.kt:33)

```kotlin
strings(
    "/",
    "/Camera",
    "/Camera/",
    "video/mp4"
)
```

Original fingerprint retained. ReVanced fuzzy matching handles method variations across app variants.

### Extension Signature (DownloadsPatch.kt:20-24)

```kotlin
private const val EXTENSION_CLASS_DESCRIPTOR =
    "Lapp/revanced/extension/tiktok/download/DownloadsPatch;"

private const val GET_DOWNLOAD_PATH_SIGNATURE =
    "$EXTENSION_CLASS_DESCRIPTOR->getDownloadPath()Ljava/lang/String;"
```

Centralised descriptor prevents drift. Main duplicated raw strings across multiple injection sites.

### Path Replacement (DownloadsPatch.kt:72-118)

Walks instructions matching `Environment.DIRECTORY_*` field access pattern:

```kotlin
instructions.withIndex()
    .filter {
        val ref = (it.value as? ReferenceInstruction)?.reference as? FieldReference
        ref?.definingClass == "Landroid/os/Environment;" && ref.name.startsWith("DIRECTORY_")
    }
    .map { it.index }
    .asReversed()
```

Processes in reverse to maintain index validity during removal. Each block is 4 consecutive instructions. Example: blocks at indices `[767, 824]` become `[824, 767]` after reversal.

Removal sequence:
1. `removeInstructions(824, 4)` → removes indices 824, 825, 826, 827
2. `removeInstructions(767, 4)` → removes indices 767, 768, 769, 770

Processing backward prevents index invalidation. If processed forward, removing 767-770 would shift all later indices down by 4, making 824→820 and removing wrong instructions at the old index.

For each match:

1. **Validate 4-instruction pattern** (fieldIndex to fieldIndex+3):
   - `sget-object DIRECTORY_* → pathRegister`
   - `invoke-virtual StringBuilder.append(pathRegister)`
   - `const-string "/Camera/" → register`
   - `invoke-virtual StringBuilder.append(register)`

2. **Extract path register** from `Instruction21c` destination at fieldIndex

3. **Remove original block** via `removeInstructions(fieldIndex, 4)`

4. **Insert extension call** using captured register:
   ```smali
   invoke-static {}, getDownloadPath()
   move-result-object v$pathRegister
   invoke-virtual {v1, v$pathRegister}, Ljava/lang/StringBuilder;->append(...)
   ```

Removes TikTok's path construction instead of inserting before it. Original append sequence never executes. Handles N occurrences (v36.5.4 has 2) without hardcoded indices.

---

## Settings

`DownloadsPatch.getDownloadPath()` returns `Settings.DOWNLOAD_PATH` value:
- Format: `"BaseDir/Subdirectory"` (MediaStore normalizes trailing slashes)
- Default: `"DCIM/TikTok"`
- UI: Radio (DCIM/Movies/Pictures) + text input for subdirectory

---

## Validation

com.zhiliaoapp.musically v36.5.4 (on-device):
- Default `DCIM/TikTok` → `/storage/emulated/0/DCIM/TikTok/` ✓
- Custom `Pictures/CustomPath` → `/storage/emulated/0/Pictures/CustomPath/` ✓
