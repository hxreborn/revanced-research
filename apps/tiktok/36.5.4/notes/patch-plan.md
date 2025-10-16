# Patch Plan – TikTok Share Link Sanitizer

**App / Version**: TikTok 36.5.4  
**Patch name**: Share Link Sanitizer  
**Priority**: High  
**Current status**: DESIGN ➜ IMPLEMENTATION Ready  
**Last updated**: 2025-10-16  

---

## 1. Goal

Deliver canonical share URLs (`https://www.tiktok.com/@handle/video/<aid>`) for every share surface, eliminating TikTok’s short-link tracking while keeping analytics and UI stable.

---

## 2. Final Strategy Summary

| Item | Decision |
|---|---|
| **Injection point** | `Lp004Y/ACallableS112S0200000_17;->call$0()` (smali_classes18) |
| **Why here?** | This callable owns the Aweme payload *and* executes immediately before `C98549aQC.LJFF()` launches the shortener |
| **Action** | Bypass the `C98549aQC.LJFF` call, synthesize our own `ShortenModel`, wrap with `C54361JSy` |
| **Helpers** | `CanonicalUrlBuilder.buildFromAweme(Aweme, String)` + `CanonicalShortenModelFactory.create(String)` |
| **Null safety** | Five-level fallback chain for handles; fall back to video-only URL if none available |
| **Risk** | Medium – smali patch invokes helpers, extra register juggling |
| **Estimate** | 10–12 hours (helper work, smali patch, regression tests) |

---

## 3. Data & Helpers

### Aweme access
```
p0  -> ACallableS112S0200000_17 instance
p0.f17831l1 -> C98759aTa
p0.f17831l1.LJJLJLI -> Aweme (full metadata)
```

### Helper expectations

```java
// CanonicalUrlBuilder
public static String buildFromAweme(@Nullable Aweme aweme,
                                    @Nullable String fallbackShareUrl);
// Fallback chain: uniqueId → uid → secUid → aweme.getAuthorUid()
// → handle parsed from shareUrl → video-only URL.

// CanonicalShortenModelFactory
public static ShortenModel create(String url); // statusCode 200, statusMsg "Success"
```

Helpers compile in the extension module; expose fully qualified names for smali invocations.

---

## 4. Smali Patch Blueprint

1. Locate `invoke-static {…, …}, Lp003X/C98549aQC;->LJFF(...)` inside `call$0()`.
2. Within the `if (!C79341T9s.LJII())` branch, replace the LJFF block with:
   ```smali
   iget-object vX, p0, Lp004Y/ACallableS112S0200000_17;->f17831l1:Ljava/lang/Object;
   check-cast vX, Lp003X/C98759aTa;
   iget-object vAweme, vX, Lp003X/C98759aTa;->LJJLJLI:Lcom/ss/android/ugc/aweme/feed/model/Aweme;

   invoke-static {vAweme, vShareUrl},
       Lapp/revanced/tiktok/share/CanonicalUrlBuilder;->buildFromAweme(Lcom/ss/android/ugc/aweme/feed/model/Aweme;Ljava/lang/String;)Ljava/lang/String;
   move-result-object vCanonical

   invoke-static {vCanonical},
       Lapp/revanced/tiktok/share/CanonicalShortenModelFactory;->create(Ljava/lang/String;)Lcom/ss/android/ugc/aweme/share/model/ShortenModel;
   move-result-object vModel

   new-instance vObs, Lp003X/C54361JSy;
   invoke-direct {vObs, vModel}, Lp003X/C54361JSy;-><init>(Ljava/lang/Object;)V

   move-object vResult, vObs
   ```
3. Preserve the `else` branch (existing fallback) so behaviour is unchanged when TikTok disables the feature via `C79341T9s`.
4. Remove the original LJFF invocation to prevent re-shortening.

---

## 5. Testing Matrix

| ID | Scenario | Expected Outcome |
|----|----------|------------------|
| TC-001 | Regular video copy-link | Canonical URL with @handle/video |
| TC-002 | Ads/promoted content (missing author) | Video-only canonical URL fallback |
| TC-003 | Privacy / restricted accounts | Safe fallback, no crash |
| TC-004 | Story / alternate surfaces | Canonical or fallback URLs preserved |
| TC-005 | Share to third-party app | Intent contains canonical link |
| TC-006 | Legacy shortened link flow | Parser recovers handle or falls back gracefully |

**Validation tips**
- Monitor `adb logcat` for helper logs & fallback messages.
- Confirm no hits to `/tiktok/share/link/shorten/v1/`.
- Check ShortenModel status code remains 200.

---

## 6. Execution Checklist

- [ ] Implement & compile helper classes.
- [ ] Export original smali for `call$0()` as backup.
- [ ] Apply smali patch, adjust registers.
- [ ] Rebuild patched APK, deploy to device/emulator.
- [ ] Run TC-001 through TC-006, capture logs/screens.
- [ ] Document verification in `research-status.md` & commit diff.

---

## 7. Rollback Plan

If regression appears:
1. Restore original smali & remove helper references.
2. Rebuild/flash to confirm rollback.
3. Investigate failure (likely fallback gap or register misuse) before re-applying.

---

## 8. Reference Files

- `decode/jadx/sources/p004Y/ACallableS112S0200000_17.java`
- `decode/jadx/sources/p003X/C98759aTa.java`
- `decode/jadx/sources/p003X/C54361JSy.java`
- `decode/jadx/sources/com/p124ss/android/ugc/aweme/feed/model/Aweme.java`

This single plan supersedes all earlier draft documents. No other share-sanitizer notes remain authoritative. (If you uncover new edge cases, update this file rather than spawning additional docs.)
- `p1`: itemType parameter
- `v_userId`: From Aweme.User.getUniqueId()
- `v_videoId`: From Aweme.getAid()
- `v_result`: Observable returned to observer chain

---

## Testing Plan

### Test Environment Matrix

| Scenario | Environment | Verification Method |
|----------|-------------|---------------------|
| Copy Link | Emulator (API 33) | Clipboard inspection |
| Share Sheet | Emulator + proxy | Network/intent data |
| Analytics | Emulator | Logcat: C50550Hrl |
| Link Functionality | Emulator + Browser | Video load test |
| Edge Cases | Emulator | Special chars, profiles, etc. |

### Test Cases (All Passing Required)

#### TC-001: Copy Link (Primary)
**Precondition**: Patched TikTok installed  
**Steps**:
1. Launch TikTok → Navigate to any video
2. Tap Share → Copy Link
3. Paste in Notes app, inspect clipboard

**Expected**: `https://www.tiktok.com/@{username}/video/{id}` (NO `vm.tiktok.com`, NO params)  
**Verification**: URL matches pattern; opens correctly in browser  
**Status**: `[PASS|FAIL|BLOCKED]`

#### TC-002: Share → More Options
**Precondition**: Patched TikTok installed  
**Steps**:
1. Tap Share → "More" / "More options"
2. Select destination (Notes, Email, WhatsApp)
3. Verify URL in destination

**Expected**: Canonical URL sent  
**Verification**: Same format as TC-001  
**Status**: `[PASS|FAIL|BLOCKED]`

#### TC-003: Share Channel Chips
**Precondition**: TikTok UI shows direct channel chips (WhatsApp, Messenger, etc.)  
**Steps**:
1. Tap channel chip (if available)
2. Monitor clipboard or share intent data

**Expected**: Canonical URL  
**Verification**: No short codes, no tracking params  
**Status**: `[PASS|FAIL|BLOCKED]`

#### TC-004: Analytics Intact
**Precondition**: Logcat enabled, filter: `logcat | grep -i "Hrl"`  
**Steps**:
1. Perform shares (TC-001, TC-002, TC-003)
2. Monitor logcat output

**Expected**: Logging fires normally, no exceptions  
**Verification**: C50550Hrl observer chain completes without errors  
**Status**: `[PASS|FAIL|BLOCKED]`

#### TC-005: Video Functionality
**Precondition**: Patched TikTok on emulator  
**Steps**:
1. Copy canonical URL via TC-001
2. Open in browser or share to recipient
3. Verify video plays

**Expected**: Full video functionality  
**Verification**: No 404, no redirect loops, metadata displays  
**Status**: `[PASS|FAIL|BLOCKED]`

#### TC-006: Edge Cases
**Precondition**: Various video scenarios  
**Steps**:
1. Share video with special characters/emoji in username
2. Share from user profile (not feed)
3. Share live/story if available

**Expected**: All produce canonical URL consistently  
**Verification**: Same format across edge cases  
**Status**: `[PASS|FAIL|BLOCKED]`

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Fingerprint fails | LOW | HIGH | Test across versions |
| URL parsing fails | VERY LOW | MEDIUM | Fallback to original URL |
| Share breaks | VERY LOW | CRITICAL | Test all share paths |
| App detects patch | LOW | MEDIUM | No prevention possible |

---

## Implementation Checklist

- [ ] ReVanced patch JSON configured
- [ ] Helper class bytecode prepared
- [ ] Smali injection tested
- [ ] TC-001 through TC-004 pass
- [ ] Code review complete
- [ ] PR created

---

## Notes

- Patch prevents users from sharing tracking URLs in chat messages
- Server-side tracking (Phase 1/2) occurs before patch point; cannot be prevented client-side
- Future: Network interception could prevent Phase 2 API call (out of scope)
