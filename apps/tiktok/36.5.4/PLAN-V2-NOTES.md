# Plan V2 - Smali Injection for Canonical URLs

## Objective
Modify `AwemeSharePackage.LJIJJ()` to canonicalize share URLs BEFORE they are written into the extras bundle. This bypasses the entire API shortening pipeline (`/tiktok/share/link/shorten/multi/v1/`).

## Status ✅ FACT-CHECKED
- ✅ `AwemeSharePackage.LJJ()` method exists at line 3012 (returns Aweme)
- ✅ `LJIJJ()` method found at line 2320
- ✅ `putString("share_url", v4)` call exists at line 2432
- ✅ `Aweme.getShareUrl()` method exists
- ✅ `Aweme.aid` field exists (video ID)
- ✅ `Aweme.uniqueId` field exists (creator username)

## Data Available
From `Aweme` object we can access:
- **`aid`** - Video ID (Aweme ID)
- **`uniqueId`** - Creator username
- **`getShareUrl()`** - Current share URL (may be canonical or shortened depending on state)

## Canonical URL Format
```
https://www.tiktok.com/@{uniqueId}/video/{aid}
```

## Implementation Strategy

### Current Flow (BROKEN)
```
AwemeSharePackage.LJIJJ line 2359
  ↓ Gets URL from List[p4]
  ↓ Line 2406: UEU.LIZ() processes URL
  ↓ Line 2432: putString("share_url", v4) ← INJECTION POINT
  ↓ extras.putString("share_url", shortened_url)
  ↓ API sends to /tiktok/share/link/shorten/multi/v1/
  ↓ Backend returns vm.tiktok.com shortened with tracking params baked in
```

### New Flow (PLAN V2)
```
AwemeSharePackage.LJIJJ line 2359
  ↓ Gets URL from List[p4]
  ↓ Line 2406: UEU.LIZ() processes URL
  ↓ Line 2420: [INJECT HERE] Get Aweme via p0.LJJ()
  ↓ [INJECT HERE] Build canonical: "https://www.tiktok.com/@" + aid + "/video/" + uniqueId
  ↓ [INJECT HERE] Use canonical URL instead of v4
  ↓ Line 2432: putString("share_url", v7_canonical)  ← MODIFIED
  ↓ extras.putString("share_url", canonical_url)
  ↓ Downstream consumers see canonical URL
  ✅ Skips shortening API entirely
```

## Injection Details

**File**: `apps/tiktok/36.5.4/decompiled-smali-full/smali_classes15/com/ss/android/ugc/aweme/share/improve/pkg/AwemeSharePackage.smali`

**Injection Point**: After line 2419 (before :cond_1), before line 2424 where putString is called

**Registers Available** (within .locals 8):
- v0 - "share_url" key (will be overwritten by subsequent code, fine)
- v1 - extras Bundle (will be overwritten, fine)
- v2 - original URL from List (already used)
- v3 - (used in conditional flow)
- v4 - URL result from UEU.LIZ() ← **This is what we replace**
- v5 - temporary flag
- v6 - FREE (use for Aweme)
- v7 - FREE (use for canonical URL result)

## Smali Patch Code

```smali
# Around line 2419, in the :cond_1 label area
# Before the putString call at line 2432

# Get Aweme object
invoke-virtual {p0}, Lcom/ss/android/ugc/aweme/share/improve/pkg/AwemeSharePackage;->LJJ()Lcom/ss/android/ugc/aweme/feed/model/Aweme;
move-result-object v6

# Initialize v7 as empty string (fallback)
const-string v7, ""

# Check if Aweme is null
if-eqz v6, :use_original_url

# Get aid (video ID)
iget-object v3, v6, Lcom/ss/android/ugc/aweme/feed/model/Aweme;->aid:Ljava/lang/String;
if-eqz v3, :use_original_url

# Get uniqueId (creator username)
iget-object v2, v6, Lcom/ss/android/ugc/aweme/feed/model/Aweme;->uniqueId:Ljava/lang/String;
if-eqz v2, :use_original_url

# Build canonical URL: "https://www.tiktok.com/@" + uniqueId + "/video/" + aid
new-instance v7, Ljava/lang/StringBuilder;
invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

const-string v1, "https://www.tiktok.com/@"
invoke-virtual {v7, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
invoke-virtual {v7, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

const-string v1, "/video/"
invoke-virtual {v7, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
invoke-virtual {v7, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
move-result-object v7

# Add logging to verify patch is active
const-string v1, "PLAN_V2_CANONICAL"
new-instance v2, Ljava/lang/StringBuilder;
invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
const-string v3, "Built canonical: "
invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
invoke-virtual {v2, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
move-result-object v2
invoke-static {v1, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

# Jump to use the canonical URL
:goto_canonical

# Fallback: use original URL
:use_original_url
move-object v7, v4

:goto_canonical
# Replace v4 with v7 (canonical) in subsequent putString call
move-object v4, v7
```

## Expected Behavior After Patch
1. ✅ App logs "PLAN_V2_CANONICAL" with canonical URL on share action
2. ✅ Share URLs to WhatsApp/SMS/clipboard are canonical (https://www.tiktok.com/@user/video/ID)
3. ✅ API call to `/tiktok/share/link/shorten/multi/v1/` still happens but receives canonical URL
4. ✅ Backend may reject or pass through canonical URL unchanged (no vm.tiktok.com shortening)
5. ✅ If backend returns error, fallback uses original URL (no crash)

## Next Steps
1. Apply patch to AwemeSharePackage.smali
2. Recompile classes15.dex using smali assembler
3. Inject into test APK
4. Test on device with logcat filtering for "PLAN_V2_CANONICAL"
5. Verify share URLs are canonical format
6. Check if API bypass works (no shortening API participation)

## Risks & Mitigations
- **Risk**: Null Aweme or missing fields → **Mitigation**: Fallback to original URL
- **Risk**: Register conflicts → **Mitigation**: Using v6, v7 which are free within .locals 8
- **Risk**: Try-catch violations → **Mitigation**: Not modifying exception handling blocks
- **Risk**: StringBuilder creation overhead → **Mitigation**: Minimal impact, only on share action (infrequent)

