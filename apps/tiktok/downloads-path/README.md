# Downloads Path - TikTok

Single source of truth for downloads path fix research. All findings, technical details, and validation results consolidated here.

## Summary

Problem: TikTok downloads ignore custom path setting in ReVanced settings menu. Files always save to `storage/emulated/0/DCIM/Camera` regardless of user preference (DCIM/Movies/Pictures/TikTok).

Suspected Cause: ReVanced fingerprint (`downloadUriFingerprint`) not matching target method in 36.5.4, causing silent patch failure.

Solution: TBD - currently investigating actual download path construction method.

Status: Investigation Phase

Patch: `revanced-src/revanced-patches/patches/src/main/kotlin/app/revanced/patches/tiktok/interaction/downloads/`

---

## Version Map

| Version | App | Status | Key Files | Logs | Base APK |
|---------|-----|--------|-----------|------|----------|
| 36.5.4 | Musically | Investigating | TBD | [Logs](36.5.4/logs) | [APK Info](../../musically/apks/36.5.4/base.apk.info) |

---

## Technical Reference

### Current ReVanced Patch Analysis

**DownloadsPatch.kt Structure:**

1. ACL Download Restrictions (3 patches):
   - `aclCommonShareFingerprint` → ACLCommonShare.getCode() returns 0
   - `aclCommonShare2Fingerprint` → ACLCommonShare.getShowType() returns 2
   - `aclCommonShare3Fingerprint` → ACLCommonShare.getTranscode() conditional watermark removal

2. Download Path Override (1 patch):
   - `downloadUriFingerprint` → targets method returning Uri
   - Injects `DownloadsPatch.getDownloadPath()` at 2 locations:
     - Before first `<init>` call
     - Before method returning Uri
   - Both write to v0 register (second overwrites first)

**downloadUriFingerprint Definition:**
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

**Identified Weaknesses:**

1. Fragile string matching - common strings might match multiple methods
2. Double injection to same register - suggests uncertain injection point
3. No verification that custom path flows into Uri construction
4. Silent failure if fingerprint doesn't match - ACL patches apply but path doesn't

### Obfuscation Map

Musically (com.zhiliaoapp.musically):

| Obfuscated Class | Purpose | Key Methods | Smali Location | Status |
|------------------|---------|-------------|----------------|--------|
| TBD | Download Uri builder | TBD | TBD | Investigating |

### Injection Points

TBD - Currently investigating actual download path construction method

---

## Validation

### Test Matrix

| Scenario | Test | Result | Evidence |
|----------|------|--------|----------|
| TBD | TBD | TBD | TBD |

---

### Root Cause Analysis

**Critical Finding**: Fingerprint strings DO NOT exist in Musically 36.5.4

Search results:
- "/Camera" → NOT FOUND
- "/Camera/" → NOT FOUND
- "video/mp4" → NOT FOUND
- "DCIM" → NOT FOUND
- MediaStore APIs → NOT FOUND in expected format

Trill comparison:
- Trill APK contains "/Camera" string (localized)
- Suggests fingerprint designed for Trill, not Musically

**Conclusion**: `downloadUriFingerprint` cannot match any method in Musically → patch silently skips download path modification → hardcoded path always used

### Next Steps

1. Manual DEX extraction and decompilation
2. Search for actual download/save logic (ContentResolver, File APIs)
3. Identify real injection point
4. Create new fingerprint or generic pattern matcher

---

## Timeline

- **2025-10-26 14:00**: Phase 0 - Branch created, identified patch weaknesses
- **2025-10-26 14:30**: Phase 1 - Confirmed fingerprint strings absent in Musically 36.5.4
- **2025-10-26 14:45**: Phase 1 - Discovered apktool-16g decompilation empty (0 smali files)

---

## References

- Workflow: [Phase 2 (Smali Testing)](/WORKFLOW.md#phase-2-smali-testing)
- ReVanced Patch: [DownloadsPatch.kt](../../../revanced-src/revanced-patches/patches/src/main/kotlin/app/revanced/patches/tiktok/interaction/downloads/DownloadsPatch.kt)
- APK metadata: [base.apk.info](../../musically/apks/36.5.4/base.apk.info)

---

Last Updated: 2025-10-26
Status: Investigation Phase
