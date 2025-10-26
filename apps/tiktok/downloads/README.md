# Downloads - TikTok

## Summary

Downloads ignore custom path setting in ReVanced menu.
Files save to `storage/emulated/0/DCIM/Camera` regardless of preference.

Cause: `downloadUriFingerprint` matches no methods in 36.5.4.

Solution: Replace with fingerprint targeting `X/KHJ.LIZ()` (Musically) and `X/K6I.LIZ()` (Trill) in classes10.dex.

Patch: `revanced-src/revanced-patches/patches/src/main/kotlin/app/revanced/patches/tiktok/interaction/downloads/`

---

## Version Map

| Version | App | Status | Files |
|---------|-----|--------|-------|
| 36.5.4 | Musically | Verified | [KHJ.smali](36.5.4/files/) |
| 36.5.4 | Trill | Verified | [K6I.smali](36.5.4/files/) |

---

## Technical Reference

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

### Actual Download Path Method

Located in classes10.dex:

Musically:
- Class: `X/KHJ`
- Method: `.method public static final LIZ()Ljava/lang/String;`
- Line 4522: `const-string v0, "/DCIM/Camera/"`

Trill:
- Class: `X/K6I`
- Method: `.method public static final LIZ()Ljava/lang/String;`
- Line 4522: `const-string v0, "/DCIM/Camera/"`

Method structure:
```smali
.method public static final LIZ()Ljava/lang/String;
    invoke-static {}, LX/CLD;->LIZ()Ljava/lang/StringBuilder;
    move-result-object v1
    invoke-static {}, LX/bFn;->H()Ljava/io/File;  # getExternalStorageDirectory()
    move-result-object v0
    invoke-virtual {v0}, Ljava/io/File;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v0, "/DCIM/Camera/"
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-static {v1}, LX/CLD;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method
```

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

## Implementation Options

Replace downloadUriFingerprint with:

```kotlin
internal val downloadPathFingerprint = fingerprint {
    accessFlags(AccessFlags.PUBLIC, AccessFlags.STATIC, AccessFlags.FINAL)
    returns("Ljava/lang/String;")
    parameters()
    strings("/DCIM/Camera/")
}
```

Injection approach:
- Match string `/DCIM/Camera/` at line 4522
- Replace `const-string v0, "/DCIM/Camera/"` with `invoke-static {}, Lapp/revanced/extension/tiktok/download/DownloadsPatch;->getDownloadPath()`
- Works both variants, identical structure

---

## Timeline

- 2025-10-26 14:00: Branch created, patch weaknesses identified
- 2025-10-26 14:30: Fingerprint strings absent in Musically classes.dex
- 2025-10-26 14:07: Runtime test confirmed fingerprint mismatch
- 2025-10-26 14:10: Verified Trill, confirmed broken both variants
- 2025-10-26 14:20: Located download path method classes10.dex both variants

---

## References

- Workflow: [Phase 2 (Smali Testing)](/WORKFLOW.md#phase-2-smali-testing)
- ReVanced Patch: [DownloadsPatch.kt](../../../revanced-src/revanced-patches/patches/src/main/kotlin/app/revanced/patches/tiktok/interaction/downloads/DownloadsPatch.kt)
