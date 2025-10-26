# Universal LIZLLL URL Sanitization Patch

Reference implementation guide. For current status, findings, and validation results, see the canonical documentation at `../README.md`.

Version: 36.5.4
Apps: Trill (com.ss.android.ugc.trill), Musically (com.zhiliaoapp.musically)
Method: `LIZLLL(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)`
Injection Point: After canonical URL retrieval, before short URL conversion

---

## Patch Strategy

Goal: Return sanitized canonical URL instead of short URL

Method flow:
1. Line 369: Get canonical URL with tracking params → stored in v1
2. Line 377-385: Check if v1 is empty
3. **← INJECT HERE:** Strip query params from v1, wrap in Observable, return
4. ~~Line 406-418: Convert to short URL~~ (bypassed)
5. Line 422-431: Wrap URL in Observable and return

---

## Injection Code Template

Insert after line 385 (`:cond_0` label), before line 392:

```smali
# ===== REVANCED PATCH: URL SANITIZATION START =====
# Strip query parameters from canonical URL (v1)
# Find '?' position
const-string v0, "?"
invoke-virtual {v1, v0}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I
move-result v0

# If no '?' found (v0 == -1), skip to wrap_url
const/4 v2, -0x1
if-eq v0, v2, :wrap_url

# Extract substring before '?'
const/4 v2, 0x0
invoke-virtual {v1, v2, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;
move-result-object v1

:wrap_url
# Wrap sanitized URL in Observable and return
# NOTE: Class names differ between apps - see app-specific sections below
new-instance v0, LX/{WRAPPER_CLASS};
invoke-direct {v0, v1}, LX/{WRAPPER_CLASS};-><init>(Ljava/lang/String;)V
invoke-static {v0}, LX/{OBSERVABLE_TYPE};->LJ(LX/{CALLBACK_INTERFACE};)LX/{OBSERVABLE_IMPL};
move-result-object v1

# Fingerprint validation (reuse existing line 393)
const-string v0, "getShortShareUrlObservab\u2026ongUrl, subBizSceneValue)"
invoke-static {v1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V
return-object v1
# ===== REVANCED PATCH: URL SANITIZATION END =====
```

---

## App-Specific Adaptations

### Trill (com.ss.android.ugc.trill)

File: `smali_classes15/X/UEU.smali`
Return type: `LX/Wu4;`

Class mappings:
- `{WRAPPER_CLASS}` → `5dx`
- `{OBSERVABLE_TYPE}` → `Wu4`
- `{CALLBACK_INTERFACE}` → `5aI`
- `{OBSERVABLE_IMPL}` → `WsX`

Injection location: After line 385, before line 392

Full injected code:
```smali
# ===== REVANCED PATCH: URL SANITIZATION START =====
const-string v0, "?"
invoke-virtual {v1, v0}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I
move-result v0
const/4 v2, -0x1
if-eq v0, v2, :wrap_url_tiktok
const/4 v2, 0x0
invoke-virtual {v1, v2, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;
move-result-object v1

:wrap_url_tiktok
new-instance v0, LX/5dx;
invoke-direct {v0, v1}, LX/5dx;-><init>(Ljava/lang/String;)V
invoke-static {v0}, LX/Wu4;->LJ(LX/5aI;)LX/WsX;
move-result-object v1
const-string v0, "getShortShareUrlObservab\u2026ongUrl, subBizSceneValue)"
invoke-static {v1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V
return-object v1
# ===== REVANCED PATCH: URL SANITIZATION END =====
```

---

### Musically (com.zhiliaoapp.musically)

File: `smali_classes18/X/aOp.smali`
Return type: `LX/aX5;`

Class mappings:
- `{WRAPPER_CLASS}` → `5fj`
- `{OBSERVABLE_TYPE}` → `aX5`
- `{CALLBACK_INTERFACE}` → `5de`
- `{OBSERVABLE_IMPL}` → `aX6`

Injection location: After line 385, before line 392

Full injected code:
```smali
# ===== REVANCED PATCH: URL SANITIZATION START =====
const-string v0, "?"
invoke-virtual {v1, v0}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I
move-result v0
const/4 v2, -0x1
if-eq v0, v2, :wrap_url_musically
const/4 v2, 0x0
invoke-virtual {v1, v2, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;
move-result-object v1

:wrap_url_musically
new-instance v0, LX/5fj;
invoke-direct {v0, v1}, LX/5fj;-><init>(Ljava/lang/String;)V
invoke-static {v0}, LX/aX5;->LJ(LX/5de;)LX/aX6;
move-result-object v1
const-string v0, "getShortShareUrlObservab\u2026ongUrl, subBizSceneValue)"
invoke-static {v1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V
return-object v1
# ===== REVANCED PATCH: URL SANITIZATION END =====
```

---

## Lines to Remove (Bypassed)

After injection, the following lines become unreachable and can be removed:

Lines **Lines 392-418:**: Short URL conversion logic
```smali
# Line 392-402: Jump target and fingerprint check
:goto_0
const-string v0, "getShortShareUrlObservab..."
invoke-static {v1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(...)
return-object v1

# Line 404-418: Short URL API call
:cond_0
sget-object v0, LX/HFi;->LIZIZ  # or LX/IV4;->LIZIZ for Musically
invoke-interface {v0, p0, p2, p3, v1}, ...->LJIILLIIL(...)  # or LJIIZILJ
move-result-object v1
goto :goto_0
```

Note: Removing is optional - the `return-object v1` in our patch makes them unreachable anyway.

---

## Verification Plan

### 1. Static Analysis (Post-Patch)
```bash
# Verify injection in correct position
rg -A 20 "REVANCED PATCH: URL SANITIZATION START" apps/{tiktok,musically}/apks/36.5.4/apktool/smali_classes*/X/{UEU,aOp}.smali

# Verify line numbers unchanged
grep -n "getShortShareUrlObservab" apps/{tiktok,musically}/apks/36.5.4/apktool/smali_classes*/X/{UEU,aOp}.smali
```

### 2. Frida Dynamic Validation
Use existing trace scripts to confirm sanitized URLs:

Expected output:
```
[→] LIZ Called
    Input:  https://www.tiktok.com/@user/video/1234567890123456789
    Output: https://www.tiktok.com/@user/video/1234567890123456789
```

**NOT:**
```
[→] LIZ Called
    Input:  https://vm.tiktok.com/ZNdc8UtG1/
    Output: https://vm.tiktok.com/ZNdc8UtG1/
```

### 3. Runtime Testing
1. Rebuild APKs with patched Smali
2. Sign and install on device
3. Perform share action (Copy Link)
4. Paste into text editor
5. Verify: No query parameters, no short URL

---

## Success Criteria

- [ ] Patch compiles without errors (smali → DEX)
- [ ] APK installs without crashes
- [ ] Share action produces canonical URL only
- [ ] URL format: `https://www.tiktok.com/@{username}/video/{id}`
- [ ] No tracking parameters (no `?`, no `&`)
- [ ] No short URL domains (vm.tiktok.com, vt.tiktok.com)
- [ ] Both apps produce identical URL format

---

## Edge Cases

### Empty URL (line 377-385)
**Handled by:** Existing null/empty checks run before our patch

### No '?' in URL
**Handled by:** `if-eq v0, v2, :wrap_url` → skips substring extraction

### Multiple '?' (malformed)
**Handled by:** `indexOf` returns first occurrence, strips all params

### Already sanitized URL
**Handled by:** No '?' found → returns URL unchanged

---

## Rollback Procedure

If patch fails:
1. Restore original Smali from apktool decompilation
2. Remove lines containing "REVANCED PATCH" comments
3. Verify line 392-418 remain intact
4. Recompile and test

---

## Next Steps

1. Create test workspaces for both apps
2. Apply patches and compile to DEX
3. Inject DEX into APK
4. Sign and install
5. Test with Frida validation
6. Document results in `apps/cross-app/features/share-url-sanitization/36.5.4/logs/`
