# Downloads - TikTok

## Summary

ReVanced patch developed for TikTok 36.5.4 downloads customization. Implementation complete, requires rebuild and device testing.

Patch replaces both DIRECTORY_DCIM and `/Camera/` in StringBuilder construction to prevent path duplication. Extension returns complete path (`DCIM/TikTok/` or `Videos/TikTok/`), replacing hardcoded `DCIM/Camera/` flow.

Fingerprint matches both Trill (X/LBT.LIZLLL) and Musically (X/Kjb.LJJIIJ) using method signature guards, avoiding obfuscated class name dependencies.

Patch: `revanced-src/revanced-patches/patches/src/main/kotlin/app/revanced/patches/tiktok/interaction/downloads/`

---

## Version Map

| Version | App | Status | Files |
|---------|-----|--------|-------|
| 36.5.4 | Trill | ReVanced Patch Developed | [LBT.smali](36.5.4/files/LBT.smali) (classes10.dex) |
| 36.5.4 | Musically | ReVanced Patch Developed | Kjb.LJJIIJ in classes10.dex |

**Testing resources:**
- [trace-lbt-methods.js](../../../frida-scripts/trace-lbt-methods.js)
- [patch-download-path.js](../../../frida-scripts/patch-download-path.js)

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

TikTok 36.5.4 uses MediaStore scoped storage API instead of direct file I/O. Version requiring fingerprint update testing: ≤36.4.x.

**Flow:**
```
LBT.LIZLLL(Context, String) → Uri
  ├─ Constructs "DCIM/Camera/" relative path
  └─ LBT.LJ(Context, filename, mimeType, relativePath) → Uri
      ├─ ContentValues.put("relative_path", relativePath)
      └─ ContentResolver.insert(uri, values)
```

### Solution: StringBuilder Path Construction Replacement

**Problem:**
Code constructs: `DIRECTORY_DCIM + "/Camera/"` via StringBuilder. Extension returns complete path `"DCIM/TikTok/"` or `"Videos/TikTok/"`. Naive replacement of `/Camera/` literal causes duplication: `"DCIM" + "DCIM/TikTok/"` = wrong path.

**Target methods:**
- Trill 36.5.4: `X/LBT.LIZLLL(Context, String)` in classes10.dex
- Musically 36.5.4: `X/Kjb.LJJIIJ(Context, String, String, Z, String, String, I)` in classes10.dex

Both construct MediaStore relative_path parameter via:
```smali
sget-object v0, Landroid/os/Environment;->DIRECTORY_DCIM:Ljava/lang/String;
invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(...)
const-string v0, "/Camera/"
invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(...)
invoke-static {p0, p1, v0, v1}, LX/LBT;->LJ(...)  # or DVV.LJ for Musically
```

**Injection strategy:**
1. Find `/Camera/` literal (anchor point)
2. Extract register from const-string instruction (register-safe, no v0 assumption)
3. Walk backwards using `indexOfFirstInstructionReversed` to find DIRECTORY_DCIM sget
4. Replace DIRECTORY_DCIM with empty string: `const-string vX, ""`
5. Replace `/Camera/` with extension call returning full path

Result: StringBuilder constructs `"" + "DCIM/TikTok/"` = correct path

**Fingerprint (both variants):**
```kotlin
internal val downloadPathFingerprint = fingerprint {
    accessFlags(AccessFlags.PUBLIC, AccessFlags.STATIC)
    returns("Landroid/net/Uri;")
    // No parameters() - Trill uses (Context, String), Musically uses (Context, String, String, Z, String, String, I)
    strings("/Camera/", "video/mp4")

    custom { method, classDef ->
        val impl = method.implementation ?: return@custom false

        // Guard: Single /Camera/ literal (excludes helpers)
        val cameraSlashCount = impl.instructions.count {
            val ref = (it as? ReferenceInstruction)?.reference as? StringReference
            ref?.string == "/Camera/"
        }

        // Guard: Must call LJ with 4 parameters (MediaStore flow)
        val hasLjCall = impl.instructions.any {
            val ref = (it as? ReferenceInstruction)?.reference as? MethodReference
            ref?.name == "LJ" && ref.parameterTypes.size == 4
        }

        cameraSlashCount == 1 && hasLjCall
    }
}
```

**Patch logic:**
```kotlin
downloadPathFingerprint.method.apply {
    val impl = implementation!!

    // Find /Camera/ literal
    val cameraPathIndex = indexOfFirstInstructionOrThrow {
        val ref = (this as? ReferenceInstruction)?.reference as? StringReference
        ref?.string == "/Camera/"
    }

    // Extract register (register-safe)
    val cameraInstruction = impl.instructions[cameraPathIndex] as Instruction21c
    val pathRegister = cameraInstruction.registerA

    // Find DIRECTORY_DCIM sget (walk backwards)
    val dcimIndex = indexOfFirstInstructionReversed(cameraPathIndex) {
        val ref = (it as? ReferenceInstruction)?.reference as? FieldReference
        ref?.name == "DIRECTORY_DCIM"
    }

    // Replace DIRECTORY_DCIM with empty string
    replaceInstructions(dcimIndex, """const-string v$pathRegister, """)

    // Replace /Camera/ with extension call
    replaceInstructions(cameraPathIndex, """
        invoke-static {}, Lapp/revanced/extension/tiktok/download/DownloadsPatch;->getDownloadPath()Ljava/lang/String;
        move-result-object v$pathRegister
    """)
}
```

Extension ensures trailing slash for MediaStore compatibility:
```java
public static String getDownloadPath() {
    String path = Settings.DOWNLOAD_PATH.get();  // "DCIM/TikTok" or "Videos/TikTok"
    if (!path.endsWith("/")) path = path + "/";
    return path;  // "DCIM/TikTok/" or "Videos/TikTok/"
}
```

Avoids obfuscated class names (X/LBT, X/Kjb) by matching method signature patterns. Fingerprint guards ensure single injection site per method.

---

## Timeline

### Investigation Timeline (2025-10-26 to 2025-10-27)

**Initial analysis:** downloadUriFingerprint matches zero methods. Located K6I/KHJ with `/DCIM/Camera/` strings but runtime Frida trace showed never called.

**DG6 attempt:** Found DG6.LIZLLL in call stack with `/share/` string. Built patch with class validation, failed - downloads still DCIM/Camera. Root cause: MediaStore API replaced direct file I/O.

**LBT discovery:** Located X.LBT in classes10.dex. LIZLLL:11694 constructs `/Camera/` path passed to LJ(p3) → ContentValues.put("relative_path") → ContentResolver.insert().

**Frida validation:** Confirmed LBT.LIZLLL and LBT.LJ execute during download. Stack: ACallableS39S1200000_9 → LBT.LIZLLL → LBT.LJ → ContentResolver.insert. Intercepted ContentValues, modified path to "DCIM/TikTok/", verified file saved to custom location.

**Smali validation:** Patched LBT.smali:11694 in apktool-dg6 decompilation. Reassembled classes10.dex (11MB), injected into stock APK. Signed, installed, tested - downloads save to DCIM/TikTok/.

**ReVanced patch development (2025-10-27):**

Phase 1 - Fingerprint design:
- Researched ReVanced best practices for resilient fingerprints
- Avoided obfuscated class name dependencies (X/LBT, X/Kjb change between variants)
- Implemented custom block with guards: single `/Camera/` literal, LJ method call with 4 parameters
- Removed parameters() constraint to match both Trill (2 params) and Musically (7 params) signatures

Phase 2 - Initial implementation:
- Built patch targeting `/Camera/` literal replacement
- Fixed API usage: `indexOfFirstInstructionOrThrow` with proper casting
- Added imports: ReferenceInstruction, Instruction21c, StringReference, MethodReference
- Gradle build succeeded: patches-5.45.0-dev.2.rvp (4.3MB)
- Applied to Trill, installed with adb -r - all patches succeeded

Phase 3 - Path duplication bug:
- Downloads still saved to DCIM/Camera despite Videos/TikTok setting
- Root cause: Extension returns `"Videos/TikTok/"` but code prepends DIRECTORY_DCIM
- Result: `"DCIM" + "Videos/TikTok/"` = wrong path in ContentValues
- Solution: Replace DIRECTORY_DCIM sget with empty string, use full extension path
- Implemented register-safe extraction (no v0 assumption)
- Used `indexOfFirstInstructionReversed` to find DIRECTORY_DCIM before `/Camera/`
- Added imports: indexOfFirstInstructionReversed, FieldReference

Status: Implementation complete, requires rebuild and device testing.

---

## References

- Workflow: [Phase 2 (Smali Testing)](/WORKFLOW.md#phase-2-smali-testing)
- ReVanced Patch: [DownloadsPatch.kt](../../../revanced-src/revanced-patches/patches/src/main/kotlin/app/revanced/patches/tiktok/interaction/downloads/DownloadsPatch.kt)
