# Phase 6: URL Parameter Sanitizer - Pre-Implementation Analysis

**Date**: 2025-10-20
**Status**: PLANNING - Awaiting approval

---

## 1. Register Pressure Analysis

### Current State in UEU.LIZLLL()
- **Directive**: `.registers 8` (modified from 6)
- **Parameters**: p0 (int), p1 (String canonical), p2 (String itemType), p3 (String key)
- **Local registers**: v0-v3 available
- **Current usage**: v1 = shortened result, v2/v3 = temp strings/booleans
- **Assessment**: ✅ **SUFFICIENT** - We have v2/v3 for sanitizer operations

### LJIJJLI Alternative (if needed)
- **Directive**: `.locals 5` (v0-v4 available)
- **Critical registers**:
  - v4 = canonical URL from BaseSharePackage (line 23076)
  - v2 = formatted URL / Wu4 result (reused)
  - v0-v1 = temp usage
- **Assessment**: ⚠️ **TIGHT** - All registers in use, would need `.locals 6` or `.locals 7`

### Recommendation
**✅ Sanitize in UEU.LIZLLL()** - We already have sufficient registers (v0-v3) and active logging infrastructure.

---

## 2. Parameter Rules Definition

### The Problem: Massive Tracking Blob

TikTok appends a **massive tracking blob** to every share URL:
```
https://www.tiktok.com/@user/video/ID?_r=1&u_code=0&...utm_source=copy&...
                                      ↑
                        505 bytes of tracking parameters!
```

### Strategy: **WHITELIST** (safer, future-proof)

**Keep ONLY**:
```
Base URL: https://www.tiktok.com/@{username}/video/{video_id}
```

**Remove EVERYTHING after `?`** (the entire massive tracking blob) - This includes:
- ❌ `utm_*` (utm_source, utm_campaign, utm_medium)
- ❌ `share_*` (share_iid, share_link_id, share_app_id, share_item_id)
- ❌ `_d`, `_r` (TikTok internal tracking)
- ❌ `u_code`, `preview_pb`, `sharer_language`
- ❌ `social_share_type`, `timestamp`
- ❌ `ugbiz_name`, `ug_btm`
- ❌ `link_reflow_popup_iteration_sharer`
- ❌ `source`

### Implementation
```smali
# Find first '?' in URL
invoke-virtual {v1, v2}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I
move-result v3
if-lez v3, :keep_url_as_is
# Substring from 0 to first '?'
const/4 v2, 0x0
invoke-virtual {v1, v2, v3}, Ljava/lang/String;->substring(II)Ljava/lang/String;
move-result-object v1
:keep_url_as_is
```

**Why whitelist over blacklist?**
- Future-proof against new tracking parameters
- Simpler logic (one `indexOf` + `substring`)
- TikTok constantly adds new tracking fields
- Clean URLs are predictable: `@user/video/ID`

---

## 3. Logging Strategy

### Logs to Add
```smali
# Before sanitization
const-string v2, "URL_BEFORE_CLEAN"
invoke-static {v2, v1}, Landroid/util/Log;->d(...)

# After sanitization
const-string v2, "URL_AFTER_CLEAN"
invoke-static {v2, v1}, Landroid/util/Log;->d(...)

# Confirm parameters removed
const-string v2, "SANITIZER"
const-string v3, "Tracking parameters removed"
invoke-static {v2, v3}, Landroid/util/Log;->d(...)
```

### Log File Storage
Create: `apps/tiktok/36.5.4/logs/phase6-sanitizer-test-YYYYMMDD-HHMM.log`

**Capture command**:
```bash
adb logcat -d | grep -E "URL_BEFORE_CLEAN|URL_AFTER_CLEAN|SANITIZER" > logs/phase6-sanitizer-test-$(date +%Y%m%d-%H%M).log
```

**Expected output**:
```
D/URL_BEFORE_CLEAN: https://www.tiktok.com/@user/video/123?utm_source=copy&...
D/SANITIZER: Tracking parameters removed
D/URL_AFTER_CLEAN: https://www.tiktok.com/@user/video/123
```

---

## 4. Regression Test Plan

### Test Matrix

| Test # | Share Method | Expected Behavior | Verification |
|--------|-------------|-------------------|--------------|
| **1** | Copy Link (clipboard) | Clean URL copied | `adb shell service call clipboard 1` or paste |
| **2** | Share to WhatsApp | Clean URL in Intent | Logcat: `Intent.*EXTRA_TEXT` |
| **3** | Share to Twitter | Clean URL in Intent | Logcat: `Intent.*EXTRA_TEXT` |
| **4** | Share to Discord | Clean URL in Intent | Logcat: `Intent.*EXTRA_TEXT` |
| **5** | Share to Email | Clean URL in Intent | Logcat: `Intent.*EXTRA_TEXT` |
| **6** | Share to SMS | Clean URL in Intent | Logcat: `Intent.*EXTRA_TEXT` |
| **7** | Failure path | Null/empty handling | App doesn't crash |
| **8** | URL without `?` | No crash, returns as-is | Log shows no change |

### Test Procedure (per WORKFLOW.md)
1. Build sanitizer APK
2. Install on device
3. Clear logcat: `adb logcat -c`
4. Trigger share for each method
5. Capture logs: `adb logcat -d > logs/test-N.log`
6. Verify clean URL received (clipboard or logcat Intent)
7. Check app stability (no crashes)

### Success Criteria
- ✅ All 8 tests pass
- ✅ URLs contain ONLY `@user/video/ID`
- ✅ No crashes or DEX verification errors
- ✅ Logs prove sanitization occurred

---

## 5. Documentation Updates

### injection-points.md
**Add Section**:
```markdown
## Phase 6: URL Parameter Sanitizer (2025-10-20)

**Location**: `X/UEU.smali` LIZLLL method, line 3864+
**Strategy**: Remove all query parameters after `?` in canonical URL
**Implementation**: String.indexOf('?') + substring(0, index)
**Result**: Clean URLs like `https://www.tiktok.com/@user/video/ID`

**Test Results**: [Link to phase6 logs]
```

### obfuscation-map.md
**Update Phase 5 section**:
```markdown
## Phase 6: URL Sanitizer ✅
**Status**: Removes all tracking parameters from canonical URLs
**Patch Code**: UEU.LIZLLL line 3880+ (after LIZLLL_RESULT log)
```

### attempt-history.md
**Add Phase 6 entry**:
```markdown
## Phase 6: URL Parameter Sanitizer (2025-10-20)

**Discovery**: UEU.LIZLLL returns canonical URLs with extensive tracking params
**Solution**: Strip everything after first `?` character
**Build**: phase6-sanitizer-aligned.apk
**Tests**: 8/8 pass
**Status**: COMPLETE ✅
```

### WORKFLOW.md
**Add to Phase 2 Section** (or create Phase 6 section):
```markdown
### Phase 6: Testing Sanitizer

1. Build: `smali a ... -o classes15-sanitizer.dex`
2. Install: `adb install -r phase6-sanitizer-aligned.apk`
3. Test matrix: 8 scenarios (see PHASE6-SANITIZER-PLAN.md)
4. Capture logs: `adb logcat -d > logs/phase6-test-SCENARIO.log`
5. Verify: Check clipboard/Intent for clean URL
```

### Status Dashboard (README.md or obfuscation-map.md)
```markdown
**Current Phase**: 6 (URL Sanitizer)
**Status**: ✅ COMPLETE
**Result**: Clean canonical URLs without tracking
**Next**: Port to ReVanced patch
```

---

## 6. Implementation Pseudocode

```smali
# In UEU.LIZLLL after line 3880 (LIZLLL_RESULT log)

# Log before cleaning
const-string v2, "URL_BEFORE_CLEAN"
invoke-static {v2, v1}, Landroid/util/Log;->d(...)

# Find '?' character
const-string v2, "?"
invoke-virtual {v1, v2}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I
move-result v3

# If '?' found (index > 0), substring it
if-lez v3, :keep_full_url

const/4 v2, 0x0
invoke-virtual {v1, v2, v3}, Ljava/lang/String;->substring(II)Ljava/lang/String;
move-result-object v1

const-string v2, "SANITIZER"
const-string v3, "Tracking parameters removed"
invoke-static {v2, v3}, Landroid/util/Log;->d(...)

:keep_full_url

# Log after cleaning
const-string v2, "URL_AFTER_CLEAN"
invoke-static {v2, v1}, Landroid/util/Log;->d(...)

# Continue to existing check_shortened logic...
```

---

## 7. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Register conflict | LOW | HIGH | Use v2/v3 which are already temp registers |
| DEX verification | LOW | HIGH | Test with small change first |
| Null `?` handling | MEDIUM | MEDIUM | Check `if-lez` before substring |
| Breaks other flows | LOW | HIGH | Test all 8 share methods |
| Future TikTok updates | HIGH | LOW | Whitelist approach is future-proof |

---

## 8. Approval Checklist

- [x] Register analysis complete
- [x] Parameter rules defined (whitelist)
- [x] Logging strategy documented
- [x] Test plan created (8 scenarios)
- [x] Documentation updates planned
- [x] Pseudocode reviewed
- [ ] **User approval obtained** ⏳
- [ ] Implementation
- [ ] Testing
- [ ] Documentation updated

---

**Awaiting your approval to proceed with implementation.**
