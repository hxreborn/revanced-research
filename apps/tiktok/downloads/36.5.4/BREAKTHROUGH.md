# Method LJJIIJ in TikTok v36.5.4

**Date:** 2025-10-28
**Status:** Method located
**Location:** `smali_classes10/X/Kjb.3.smali:5034`

---

## Analysis Summary

Method `X.Kjb.LJJIIJ` is present in TikTok v36.5.4 classes10.dex. Initial Frida hook attempts failed due to signature mismatch.

### Method Signature (Smali)
```smali
.method public static LJJIIJ(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;ZLjava/lang/String;Ljava/lang/String;I)Landroid/net/Uri;
```

### Method Signature (Java)
```java
public static Uri LJJIIJ(Context context, String str, String str2, boolean z, String str3, String str4, int i)
```

### Parameters Analysis
- `p0`: Context
- `p1`: String (file path?)
- `p2`: String (filename?)
- `p3`: boolean (is video?)
- `p4`: String (MIME type, nullable)
- `p5`: String (relative path, nullable - **THIS IS THE KEY!**)
- `p6`: int (flags)

---

## The Download Path Logic

**File:** `smali_classes10/X/Kjb.3.smali` lines 5075-5110

```smali
:cond_2
    const-string v0, "context"
    invoke-static {p0, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    if-nez p5, :cond_2              # If relativePath parameter is null...

    invoke-static {}, LX/CLD;->LIZ()Ljava/lang/StringBuilder;
    move-result-object v1

    sget-object v0, Landroid/os/Environment;->DIRECTORY_DCIM:Ljava/lang/String;  # Get "DCIM"
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v0, "/Camera/"                                                  # ← TARGET!
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-static {v1}, LX/CLD;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;
    move-result-object p5              # Default path = "DCIM/Camera/"
```

**Translation:** If no custom path is provided, default to `DCIM/Camera/`

---

## Why Frida Failed to Hook

### Initial Frida Error
```
[-] Failed to hook X.Kjb.LJJIIJ: TypeError: cannot read property 'overload' of undefined
```

### Root Cause
The file is named `Kjb.3.smali` but declares `class public final LX/Kjb;`. This suggests:
1. **Possibility 1:** The .3 suffix is apktool's artifact for handling multiple DEX classes
2. **Possibility 2:** The method might be in a companion object or nested structure
3. **Possibility 3:** Frida needs to access it differently (e.g., `X.Kjb$Companion`)

### Call Sites Confirm It Works
Found **10 invocations** of `LX/Kjb;->LJJIIJ` in production code:
- `smali/X/0n0.1.smali`
- `smali/X/0mu.3.smali`
- `smali_classes10/X/Jqk.1.smali`
- `smali_classes10/X/Jtr.1.smali` ← Used for TT_Glance/Moments
- `smali_classes10/X/Jtg.1.smali` (2x)

The method is **actively used** - but WHERE for regular downloads?

---

## New Questions

### Q1: Why isn't this method called during regular downloads?
**Answer Needed:** Frida trace showed downloads going to `/files/share/out/` but never called `LJJIIJ`.

**Hypothesis:** Regular downloads might use a DIFFERENT code path entirely!

### Q2: What calls LJJIIJ for regular video downloads?
From grep results, we see it called for:
- ✓ TT_Glance (Moments/Stories) - `X/Jtr.1.smali`
- ? Regular video downloads - **NOT FOUND YET**

### Q3: Is `/files/share/out/` constructed elsewhere?
**Action Required:** Search for `"share"` + `"out"` string concatenation

---

## ReVanced Patch Status

### Current Patch Target
```kotlin
downloadPathFingerprint.method.apply {
    val cameraIndex = indexOfFirstInstructionOrThrow {
        val ref = (this as? ReferenceInstruction)?.reference as? StringReference
        ref?.string == "/Camera/"
    }

    val dcimIndex = indexOfFirstInstructionReversed(cameraIndex) {
        val ref = (this as? ReferenceInstruction)?.reference as? FieldReference
        ref?.name == "DIRECTORY_DCIM"
    }

    // Replace DIRECTORY_DCIM with "" and /Camera/ with Videos/TikTok/
}
```

### Patch Fingerprint
```kotlin
internal val downloadPathFingerprint = fingerprint {
    accessFlags(AccessFlags.PUBLIC, AccessFlags.STATIC)
    returns("Landroid/net/Uri;")
    parameters("Landroid/content/Context;", "Ljava/lang/String;")  # ← WRONG!
    strings("video/mp4", "/Camera/")
}
```

### Parameter Mismatch

Method signature has 7 parameters but ReVanced fingerprint searches for 2.

**Corrected Fingerprint:**
```kotlin
internal val downloadPathFingerprint = fingerprint {
    accessFlags(AccessFlags.PUBLIC, AccessFlags.STATIC)
    returns("Landroid/net/Uri;")
    parameters(
        "Landroid/content/Context;",
        "Ljava/lang/String;",
        "Ljava/lang/String;",
        "Z",  // boolean
        "Ljava/lang/String;",
        "Ljava/lang/String;",
        "I"   // int
    )
    strings("video/mp4", "/Camera/")
}
```

---

## Next Steps

### Required Actions

1. Update `downloadPathFingerprint` with correct 7-parameter signature
2. Test patch application against `X/Kjb.3.smali`
3. Verify bytecode modifications execute correctly

### Validation Requirements

1. Trace `X.Kjb.LJJIIJ` with corrected signature during download
2. Confirm method invocation occurs in download flow
3. If method not invoked, locate alternate download path construction

### Path Analysis

Search Smali for `"share"` and `"out"` concatenation patterns to identify alternative paths.

---

## Evidence Summary

| Finding | Status | Evidence |
|---------|--------|----------|
| Method exists | ✓ Confirmed | `Kjb.3.smali:5034` |
| Method has `/Camera/` string | ✓ Confirmed | `Kjb.3.smali:5096` |
| Method has `DIRECTORY_DCIM` | ✓ Confirmed | `Kjb.3.smali:5087` |
| Method signature matches | ✗ Mismatch | 7 params vs 2 params in fingerprint |
| Method called during download | ? Unknown | Frida failed to hook |
| Files actually move to Videos/TikTok | ✗ No | Files stay in `/files/share/out/` |

---

## Key Code Locations

### Method Definition
```
apps/tiktok/apks/36.5.4/apktool-smali/smali_classes10/X/Kjb.3.smali:5034-5300
```

### Call Sites
```bash
# All places that invoke LJJIIJ:
grep -r "invoke.*LX/Kjb;->LJJIIJ" apps/tiktok/apks/36.5.4/apktool-smali/smali*
```

### ReVanced Patch
```
revanced-src/revanced-patches/patches/src/main/kotlin/app/revanced/patches/tiktok/interaction/downloads/DownloadsPatch.kt:73-113
revanced-src/revanced-patches/patches/src/main/kotlin/app/revanced/patches/tiktok/interaction/downloads/Fingerprints.kt:69-74
```

---

## Summary

Method `X.Kjb.LJJIIJ` exists with 7 parameters. ReVanced fingerprint specifies 2 parameters, causing fingerprint mismatch. Files saved to `/files/share/out/` indicate either:
1. Fingerprint failed to match method
2. Patch matched wrong method variant
3. Actual download flow uses different code path

Required fix: Update fingerprint with 7-parameter signature and revalidate patch application.
