# Share URL Sanitization - TikTok

Status: Patch implemented and tested on-device (v36.5.4).

---

## Target Method

`X.UEU.LIZLLL` (Trill, classes15.dex) / `X.aOp.LIZLLL` (Musically, classes18.dex): receives canonical URL from `UEa.LIZ()` / `aTZ.LIZ()` and adds 21 tracking parameters.

Injection point: strip query string via `substring(0, indexOf("?"))` before return.

---

## Implementation

### Fingerprint (Fingerprints.kt)

```kotlin
internal val urlShorteningFingerprint = fingerprint {
    accessFlags(AccessFlags.PUBLIC, AccessFlags.STATIC, AccessFlags.FINAL)
    returns("LX/")
    parameters("I", "Ljava/lang/String;", "Ljava/lang/String;", "Ljava/lang/String;")
    opcodes(Opcode.RETURN_OBJECT)
    strings("getShortShareUrlObservab\u2026ongUrl, subBizSceneValue)")
    custom { method, _ -> method.name == "LIZLLL" }
}
```

Unique string (Kotlin intrinsics debug output): `"getShortShareUrlObservab\u2026ongUrl, subBizSceneValue)"` only appears in target method.

### Patch Logic (SanitizeShareUrlsPatch.kt)

Insert before URL return:
```smali
const-string v2, "?"
invoke-virtual {v1, v2}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I
move-result v0

if-lez v0, :keep_url

const/4 v2, 0x0
invoke-virtual {v1, v2, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;
move-result-object v1

:keep_url
# Continue to original return
```

Result: removes all query parameters (21 total, 505 bytes) from share URL.

### Extension (ShareUrlSanitizer.java)

```java
public static String sanitizeShareUrl(String url) {
    if (url == null) return null;
    int queryPos = url.indexOf("?");
    if (queryPos <= 0) return url;
    return url.substring(0, queryPos);
}
```

---

## Validation

| Scenario | Test | Result |
|----------|------|--------|
| Copy link (Clipboard) | Share via clipboard | Passed |
| URL format | Canonical structure | Passed |
| Parameter removal | All tracking params stripped | Passed |
| App stability | Crashes/hangs | None |
| DEX compilation | Bytecode validity | Passed |
| ReVanced build | Gradle + CLI | Passed |

Size reduction: 568 chars → 63 chars (89% reduction).

Example:
```
Before: https://www.tiktok.com/@user/video/123?_r=1&utm_source=copy&...
After:  https://www.tiktok.com/@user/video/123
```

---

## Tracking Parameters Removed (v36.5.4)

21 parameters total:
- TikTok tracking: `_r`, `_d`, `u_code`, `share_iid`, `source` (5)
- Marketing: `utm_source`, `utm_campaign`, `utm_medium` (3)
- Share metadata: `social_share_type`, `sharer_language`, `share_link_id`, `share_item_id`, `share_app_id`, `timestamp` (6)
- Business: `ugbiz_name`, `ug_btm` (2)
- A/B testing: `preview_pb`, `link_reflow_popup_iteration_sharer` (2)

Blanket removal via query string stripping (no parameter whitelist).

---

## References

- ReVanced Patch: `revanced-src/revanced-patches/patches/src/main/kotlin/app/revanced/patches/tiktok/misc/share/`
- Fingerprint: `revanced-src/revanced-patches/patches/src/main/kotlin/app/revanced/patches/tiktok/misc/share/Fingerprints.kt`
- Extension: `revanced-src/revanced-patches/extensions/tiktok/src/main/java/app/revanced/extension/tiktok/share/ShareUrlSanitizer.java`

---

Last Updated: 2025-10-30
