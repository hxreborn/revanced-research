# LJFF Data Flow Analysis

**Target**: `Lcom/p124ss/android/ugc/aweme/share/C98549aQC;->LJFF(...)`  
**Location**: `classes18.dex`, line 183 (CFR reference)  
**Status**: DESIGN PHASE — Ready for bytecode verification  

---

## Call Path

```
User Share Action (Copy Link, More Options, Channel Chip)
  ↓
ShareService.triggerShare(Aweme, channel)
  ↓
C98759aTa.LIZZ()  [Share context builder]
  ↓
CopyLinkWorker.doWork()  [or equivalent handler]
  ↓
[PATCH TARGET] C98549aQC.LJFF(itemType, url1, url2, url3)
  ├─ Parameter p1: int itemType (identifies share type)
  ├─ Parameter p2-p4: String (URL components / metadata)
  ├─ Contains Aweme context (accessed via cache/fields)
  ├─ [PATCH INJECTION POINT]
  └─ invoke-interface {...}, IShortenUrlApi;->getShareLinkShortenUel(...)
       [TO BE REPLACED WITH: buildCanonicalUrl() → AbstractC98976aX5.m14172LJ()]
  ↓
C50550Hrl.LIZIZ()  [Observer/metrics chain]
  ↓
Result: Observable<String> (canonical URL or short URL) to clipboard/share
```

---

## Method Signature Analysis

### LJFF Bytecode Signature

```smali
.method public LJFF(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)L...;
    .param p1, "itemType"           # int (share type identifier)
    .param p2, "url1"               # String (share URL or component)
    .param p3, "url2"               # String (title or metadata)
    .param p4, "url3"               # String (additional context)
    .return L...                    # Observable or reactive wrapper
```

### Parameter Semantics (To Be Confirmed)

| Param | Name | Type | Purpose | Source |
|-------|------|------|---------|--------|
| p0 | this | C98549aQC | Instance reference | n/a |
| p1 | itemType | int | Share type enum (link, message, etc.) | SharePackage / caller |
| p2 | url1 | String | Primary URL or share data | Context/cache |
| p3 | url2 | String | Title or secondary data | Aweme metadata |
| p4 | url3 | String | Additional context | Config or feature flags |

**Critical Unknown**: Which parameter(s) contain actionable Aweme fields (userId, videoId)?

---

## Data Availability in LJFF Context

### Aweme Field Access Strategy

**Known**: Aweme object is referenced by `CopyLinkWorker` before LJFF is invoked.

**Questions**:
- [ ] Is Aweme passed as parameter to LJFF?
- [ ] Is Aweme cached in a static/instance field accessible from LJFF scope?
- [ ] Are userId/videoId already extracted and passed as string parameters?

**References for Bytecode Verification**:
- `apps/tiktok/36.5.4/decode/jadx/sources/p003X/C98759aTa.java:23` — Share context builder
- `apps/tiktok/36.5.4/decode/jadx/sources/com/.../Aweme.java:1896` — getAid() method
- `apps/tiktok/36.5.4/decode/jadx/sources/com/.../User.java:2205` — getUniqueId() method

**Strategy**:
1. **If Aweme in LJFF scope**: Extract userId/videoId directly
2. **If Aweme cached**: Access via static/instance field lookup
3. **If only strings available**: Parse/validate and use parameters as-is

---

## Injection Point Specification

### Current Flow (Pre-Patch)

```smali
.method public LJFF(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)L...;
    .locals N
    
    # ... setup code ...
    
    new-instance v_api, LIShortenUrlApi;  # Create API client
    invoke-direct {v_api, ...}, LIShortenUrlApi;-><init>(...)V
    
    # [INJECTION POINT: HERE - Before API call]
    
    invoke-interface {v_api, v_request}, 
        LIShortenUrlApi;->getShareLinkShortenUel(...)  # SHORTENER CALL
    move-result-object v_result
    
    # ... downstream consumer wiring ...
    
    return v_result
.end method
```

### Patched Flow (Conceptual)

```smali
.method public LJFF(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)L...;
    .locals N + 2  # May need additional registers
    
    # ... setup code ...
    
    # [PATCH BLOCK A: Extract Aweme fields]
    invoke-static {p1}, Lcom/revanced/tiktok/extensions/ShareUrlUtils;
        ->extractAwemeContext(I)...  # Returns userId, videoId
    move-result-object v_aweme_ctx
    
    # [PATCH BLOCK B: Build canonical URL]
    invoke-static {p1, v_userId, v_videoId, p2}, 
        Lcom/revanced/tiktok/extensions/ShareUrlUtils;
        ->buildCanonicalUrl(ILjava/lang/String;JLjava/lang/String;)Ljava/lang/String;
    move-result-object v_canonical
    
    # [PATCH BLOCK C: Wrap in Observable]
    invoke-static {v_canonical}, 
        LAbstractC98976aX5;->m14172LJ(Ljava/lang/String;)L...;
    move-result-object v_result
    
    # Continue with existing downstream (observer chain unchanged)
    
    return v_result
.end method
```

---

## Register Allocation Planning

### Pre-Injection State

```
Registers occupied (assuming typical method):
- p0: this (C98549aQC)
- p1: itemType (int)
- p2-p4: String parameters
- v0-vN: Local variables / temporaries
```

### Register Requirements for Patch

```
Additional registers needed:
- v_userId: String (from Aweme.User.getUniqueId())
- v_videoId: long (from Aweme.getAid())
- v_canonical: String (result of buildCanonicalUrl)
- v_result: L... (Observable, returned from m14172LJ)
- v_aweme_ctx: Optional (if Aweme object cached)
```

**To Be Determined During Bytecode Phase**:
- How many registers currently in use?
- Can we reuse existing registers or must allocate new locals?
- What register holds the original v_result (IShortenUrlApi return)?

---

## itemType Enum Mapping

### Current Unknowns

The LJFF method receives an `itemType` parameter to identify the share type. We must determine:

1. **Which int values = "link shares"?**
   - Copy link: `itemType == ???`
   - Share sheet: `itemType == ???`
   - Channel chips: `itemType == ???`

2. **Where is the enum defined?**
   - Search: `EnumC98548aQB` or similar
   - File: `apps/tiktok/36.5.4/decode/jadx/sources/p003X/C98548aQB.java`

3. **Should we check itemType or always apply patch?**
   - **Option A**: Check itemType before canonical build (safer)
   - **Option B**: Apply to all shares (simpler, but may affect non-link shares)

### Resolution Steps

```bash
# Search for itemType enum
rg "enum.*C98548\|itemType.*final int" apps/tiktok/36.5.4/decode/

# Check LJFF callers for itemType values
rg "\.LJFF\(" apps/tiktok/36.5.4/decode/jadx/sources/ | head -20

# Map constants to share types
rg "COPY_LINK\|SHARE_SHEET\|CHANNEL" apps/tiktok/36.5.4/decode/jadx/sources/
```

---

## Observable Wrapper Compatibility

### Target Function

```java
// Location: AbstractC98976aX5.java
public static Object m14172LJ(String value) {
    // Expected behavior: Wraps String into Observable<String>
    // Type: Must match return type of IShortenUrlApi.getShareLinkShortenUel()
}
```

### Validation Requirements

- [ ] Check function signature in `apps/tiktok/36.5.4/decode/cfr/classes18/X/aX5.java`
- [ ] Confirm return type is Observable or reactive equivalent
- [ ] Verify C50550Hrl observer chain expects this type
- [ ] Test that downstream doesn't assume specific response object properties

**Reference**:
- `apps/tiktok/36.5.4/decode/cfr/classes18/X/aX5.java` — Observable wrapper definition
- `apps/tiktok/36.5.4/decode/jadx/sources/p003X/C50550Hrl.java:24` — Observer chain

---

## Version Stability Assumptions

### Assumption: LJFF Signature Remains Stable

| Version | Expected | Risk | Notes |
|---------|----------|------|-------|
| 36.5.4 | ✅ Match | LOW | Target version |
| 36.6.x | Likely ✅ | MEDIUM | Minor version; usually preserved |
| 37.0.x | Unknown | HIGH | Major version; flag for testing |

**Plan**: Patch 36.5.4 now; document assumptions; validate on 36.6.x before 37.x support.

---

## Bytecode Verification Checklist

Before proceeding to smali injection:

- [ ] **Confirm Aweme accessibility**
  - [ ] Is Aweme object in LJFF scope?
  - [ ] Can we extract userId and videoId?
  - [ ] If not, trace back to CopyLinkWorker for field access

- [ ] **Map itemType enum**
  - [ ] Find EnumC98548aQB or similar
  - [ ] Document int values for link shares
  - [ ] Decide: Check itemType or apply unconditionally?

- [ ] **Validate Observable wrapper**
  - [ ] Confirm AbstractC98976aX5.m14172LJ signature
  - [ ] Verify return type matches IShortenUrlApi result
  - [ ] Test observer chain compatibility

- [ ] **Register allocation**
  - [ ] Count current register usage in LJFF
  - [ ] Plan register assignments for patch
  - [ ] Determine if locals expansion needed

- [ ] **Fingerprint validation**
  - [ ] Locate LJFF in 36.5.4 bytecode
  - [ ] Confirm invoke-interface to IShortenUrlApi
  - [ ] Test fingerprint on emulator

---

## Next Steps

1. **Read LJFF bytecode** from CFR/JADX output
2. **Resolve critical unknowns** (Aweme access, itemType mapping, observable type)
3. **Map exact registers** for patch injection
4. **Draft smali code** with concrete register assignments
5. **Test on emulator** against TC-001 through TC-006

---

## References

| File | Purpose |
|------|---------|
| `apps/tiktok/36.5.4/decode/cfr/classes18/X/aQC.java:183` | LJFF method location |
| `apps/tiktok/36.5.4/decode/jadx/sources/p003X/C98759aTa.java:23` | Share context builder |
| `apps/tiktok/36.5.4/decode/jadx/sources/p003X/C50550Hrl.java:24` | Observer chain |
| `implementation-strategy.md` | High-level design spec |
| `fingerprints.md` | FP-NEW bytecode anchors |

