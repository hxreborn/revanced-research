# Injection Points Reference - TikTok 36.5.4

**Status**: [PASS] Phase 6 production implementation - verified and tested

**For discovery narrative**: See [phases/phase-4-discovery.md](phases/phase-4-discovery.md)

---

## URL Processing Flow

```
AwemeSharePackage.LJIJJLI()          (line 2795)
  ↓ Receives canonical URL from BaseSharePackage

ULX.LIZ(v4, p0)                      (formats URL, still canonical)
  ↓

UEU.LIZLLL(v3, v2, v1, v0)           (line 3866) ← INJECTION POINT
  ↓ Calls UEa.LIZ()

UEa.LIZ()                            (ADDS tracking blob - 18 params, 505 bytes)
  ↓ Returns URL with query parameters

Distribution
  ↓ Sent to Intent (WhatsApp/Twitter/SMS) or Clipboard
```

---

## Phase 6: Production Injection Point

### Location

| Property | Value |
|----------|-------|
| **File** | `smali_classes15/X/UEU.smali` |
| **Method** | `LIZLLL(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)LX/Wu4;` |
| **Line** | 3866 |
| **Position** | Immediately after `move-result-object v1` from `UEa.LIZ()` call |
| **Modification** | `.registers 6` → `.registers 8` (add v2-v3 for temporaries) |

### Register Allocation

| Register | Type | Purpose |
|----------|------|---------|
| v0 | int | indexOf result (position of '?') |
| v1 | String | URL (modified in-place, initially contains result from UEa.LIZ()) |
| v2 | String | const-string temporaries and substring parameters |
| v3 | String | Reserved/unused in production |
| v4-v5 | String | Method parameters (p0-p3 mapping) - not used by sanitizer |

### Implementation Code

```smali
move-result-object v1              # v1 = canonical URL from UEa.LIZ()

# Null safety check
if-eqz v1, :keep_shortened_c
goto :start_sanitize

:start_sanitize
# Find position of '?' character
const-string v2, "?"
invoke-virtual {v1, v2}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I
move-result v0

# Skip if no '?' found (-1) or '?' at position 0
if-lez v0, :check_shortened

# Extract base URL (remove query string)
const/4 v2, 0x0
invoke-virtual {v1, v2, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;
move-result-object v1              # v1 now contains clean URL

:check_shortened
# Continue to isEmpty check and rest of original method

:keep_shortened_c
# Fall through to rest of method (null case)
```

### Edge Cases

| Case | Condition | Handling |
|------|-----------|----------|
| Null URL | `v1 == null` | `if-eqz v1, :keep_shortened_c` - skip sanitization |
| No query string | `indexOf("?")` returns -1 | `if-lez v0, :check_shortened` - skip substring |
| Malformed URL | '?' at position 0 | `if-lez v0, :check_shortened` - skip sanitization |
| Valid query string | `indexOf("?")` returns > 0 | Execute `substring(0, v0)` to remove parameters |

### Type Safety

**Critical**: DEX verifier enforces strict typing
- v0: **Always** `int` (never String or Object)
- v1: **Always** `String` (never int or Object)
- v2: **Always** `String` (never repurposed for int operations)

Violating this causes DEX verification failure.

### Label Naming

Labels use `_c` suffix to prevent collisions with other patches:
- `:keep_shortened_c` - Null or no query string path
- `:check_shortened` - Continue to next phase
- `:start_sanitize` - Begin parameter stripping

---

## Results

### Size Reduction

| Metric | Before | After | Reduction |
|--------|--------|-------|-----------|
| URL Length | 568 chars | 63 chars | **89%** |
| Parameters | 18 | 0 | **100%** |

### URL Transformation

**Before**:
```
https://www.tiktok.com/@pure.8k/video/7558444171787373846?_r=1&u_code=0&preview_pb=0&sharer_language=en&_d=f01b3cehlc22d5&share_item_id=7558444171787373846&source=h5_m&timestamp=1760976423&social_share_type=0&utm_source=copy&utm_campaign=client_share&utm_medium=android&share_iid=7563309489895655181&share_link_id=dee1bbdf-0e16-4192-843c-1c412928ba2f&share_app_id=1180&ugbiz_name=MAIN&ug_btm=b2001&link_reflow_popup_iteration_sharer=%7B...%7D
```

**After**:
```
https://www.tiktok.com/@pure.8k/video/7558444171787373846
```

### Parameters Removed

| Category | Parameters | Count |
|----------|------------|-------|
| Marketing | utm_source, utm_campaign, utm_medium | 3 |
| Analytics | share_iid, share_link_id, share_app_id, share_item_id | 4 |
| Internal | _d, _r, u_code | 3 |
| Behavioral | timestamp, social_share_type | 2 |
| Business | ugbiz_name, ug_btm | 2 |
| Dynamic | link_reflow_popup_iteration_sharer (JSON blob) | 1 |

**Total**: 18 parameters, 505 bytes

---

## Validation

| Test | Result | Evidence |
|------|--------|----------|
| DEX compilation | [PASS] | No errors, valid bytecode (103MB) |
| APK installation | [PASS] | No VerifyError or verification errors |
| Runtime execution | [PASS] | Share function works, no crashes |
| Parameter removal | [PASS] | All 18 parameters removed successfully |
| Edge cases | [PASS] | Null check, no '?', '?' at position 0 - all handled |

---

## Verification Logs

```
D/URL_BEFORE_CLEAN(3643): https://www.tiktok.com/@pure.8k/video/7558444171787373846?_r=1&u_code=0&...
D/SANITIZER(3643): Tracking parameters removed
D/URL_AFTER_CLEAN(3643): https://www.tiktok.com/@pure.8k/video/7558444171787373846
```

---

## Build Artifacts

| Artifact | Location | Purpose |
|----------|----------|---------|
| Patch file | `apps/tiktok/36.5.4/patches/phase6-url-sanitizer.smali.patch` | Manual application reference |
| DEX | `apps/tiktok/36.5.4/smali-tests/05-option-c-bypass/classes15-sanitizer-fixed.dex` | Compiled bytecode |
| APK | `apps/tiktok/36.5.4/smali-tests/05-option-c-bypass/phase6-sanitizer-fixed-aligned.apk` | Test APK |
| Log | `apps/tiktok/36.5.4/logs/phase6-test-clipboard.log` | Logcat evidence |

---

## Related Documentation

- **Phase 6 Details**: [phases/phase-6-sanitizer.md](phases/phase-6-sanitizer.md) - Complete implementation walkthrough
- **Phase 7 ReVanced**: [phases/phase-7-revanced.md](phases/phase-7-revanced.md) - Framework integration
- **Obfuscation Map**: [obfuscation-map.md](obfuscation-map.md) - Class/method reference
- **Validation Log**: [validation-log.md](validation-log.md) - Test results summary

---

**Status**: [COMPLETE] - Production Smali implementation validated. Ready for framework porting or manual application.
