# TikTok 36.5.4 - Obfuscated Class Mapping

## Share-Related Classes

| Obfuscated Class | Purpose | Key Methods | Location | Status |
|------------------|---------|------------|----------|--------|
| `com.p124ss.ugc.aweme.creation.base.ShareModel` | Share model data | `getShareUrl()`, `setShareUrl()` | classes10.dex | ✅ Found |
| `com.appsflyer.share.ShareInviteHelper` | AppsFlyerLib share helper | `generateInviteUrl()` | classes20.dex | ✅ Found |
| `com.bytedance.android.livesdkapi.depend.model.live.Room` | Live room with share_url field | `shareUrl` (field) | - | ✅ Found |

## URL/Link Related

### Strings Found
- `share_url` - Annotation: `@InterfaceC37646Cp7("share_url")` in Room.java
- `copylink` - URL copy functionality
- `utm_source` - Tracking parameter (TARGET FOR REMOVAL)
- `utm_*` - Generic tracking patterns
- `tt_*` - TikTok tracking patterns
- `enter_*` - Tracking parameters

### Search Locations
- **JADX output**: `decompiled-jadx/sources/` (166,751 Java sources decompiled at 99% completion)
- **Smali bytecode**: `decompiled-smali-full/smali_classes*/` (248,437 complete Smali files)
- **Search indices**:
  - `indices/strings.txt` (39,246 URL/link/share related hits)
  - `indices/handlers.txt` (30,477 onClick/button/clip related hits)
  - `indices/bundles.txt` (94,225 Bundle/Intent/extras hits)
  - `indices/canonical-urls.txt` (546,958 video_id/aweme_id/tiktok.com patterns)
  - `indices/specific.txt` (188 copylink/share_url/utm_ tracking patterns)

## Share Intent Link Canonicalizer - Patch Goal

**Objective**: Use canonical full-length URLs instead of TikTok-shortened links when sharing to external apps

**Strategy**:
- **Intercept canonical URL** BEFORE it's shortened by TikTok's API
- **Bypass API shortener** to use full canonical URL in share Intent
- **Result**: External apps receive full URLs like `https://www.tiktok.com/@user/video/ID` instead of `https://vm.tiktok.com/{SHORT_ID}`
- **Benefit**: Direct access to video content without tracking parameter injection, no dependency on TikTok's shortener service

**Patch Strategy**:
1. **Identify canonical URL source**: Find where full-length video URLs are stored (before API shortening)
2. **Locate interception point**: In `AbstractC82063UGk.m11879LJ()` or earlier in the pipeline
3. **Override with canonical URL**: Substitute the shortened link with the full canonical URL
4. **Pass to Intent**: Let canonical URL flow through to Intent.putExtra() or clipboard

**Expected flow**:
```
User taps Share
     ↓
Canonical URL available (e.g., https://www.tiktok.com/@user/video/XXXX)
     ↓
API shortening process (would create vm.tiktok.com link)
     ↓
[PATCH INTERCEPTION - Use canonical instead of shortened]
     ↓
Intent.putExtra() receives canonical URL
     ↓
Send to external app / clipboard with full URL
```

**Key principle**: Single interception point in URL building pipeline for consistent canonical links across all share channels

## Phase 1 Findings

### Verified Share Flow Implementation

**FOUND: WrapDefaultWhatsappChannel** (classes15.dex)
- **File**: `com/p124ss/android/ugc/aweme/channel/share/channel/wrap/WrapDefaultWhatsappChannel.java`
- **Key method**: `LJIJ(UGU content, Context context)` - Line 31
- **URL handling**:
  - **Line 45**: `AbstractC82063UGk.m11879LJ(content)` - Extracts URL from content
  - **Line 57**: `intent2.putExtra("android.intent.extra.TEXT", AbstractC82063UGk.m11879LJ(content))` - **INJECTION POINT**
  - **Line 46/56**: Intent.setData() and putExtra() with URI
- **Status**: **✅ VERIFIED - This is where URLs are sent to WhatsApp**

### Share Channel Architecture

Each share channel (WhatsApp, Twitter, SMS, copy, etc.) extends `IWrapChannel`
- All channels use similar pattern: extract URL via `AbstractC82063UGk.m11879LJ(content)`
- All channels pass URL to external apps via `Intent.putExtra("android.intent.extra.TEXT", url)`
- Need to find and patch the central URL extraction method: `AbstractC82063UGk.m11879LJ()`

### URL String Handlers

1. **AbstractC82063UGk.m11879LJ()** - CRITICAL
   - **Type**: Static URL builder/extractor method
   - **Location**: classes15.dex (p003X/AbstractC82063UGk.java)
   - **Signature**: `public static String m11879LJ(UGU content)`
   - **Status**: **✅ VERIFIED - PRIMARY PATCH TARGET**

   **Method Analysis** (Lines 67-93 of AbstractC82063UGk.java):
   ```java
   public static String m11879LJ(UGU content) {
       String strLIZIZ;
       UGT ugt;
       String str;

       // Check if content is UGT type and has LJ field (title)
       if ((content instanceof UGT) && (str = (ugt = (UGT) content).f10258LJ) != null &&
           C41221EDo.LIZ(str)) {
           StringBuilder sbLIZ = CD7.LIZ();
           sbLIZ.append(ugt.f10258LJ);          // Append title
           sbLIZ.append(' ');
           strLIZIZ = CD7.LIZIZ(sbLIZ);         // Convert to string
       } else {
           strLIZIZ = "";
       }

       // Main URL construction
       String str2 = content.LIZJ;              // Get primary share URL
       if (str2 != null && str2.length() != 0) {
           StringBuilder sbLIZ2 = CD7.LIZ();
           sbLIZ2.append(content.LIZJ);         // Primary URL
           sbLIZ2.append(' ');
           sbLIZ2.append(strLIZIZ);             // Title (if present)
           sbLIZ2.append(content.LIZIZ);        // Secondary content
           return CD7.LIZIZ(sbLIZ2);
       }

       // Fallback: return secondary content if no primary URL
       StringBuilder sbLIZ3 = CD7.LIZ();
       sbLIZ3.append(strLIZIZ);
       sbLIZ3.append(content.LIZIZ);
       return CD7.LIZIZ(sbLIZ3);
   }
   ```

   **Key Insight**: The method combines:
   - `content.LIZJ` - Primary URL (this is where shortened vm.tiktok.com link comes from)
   - `content.LIZIZ` - Secondary content/hashtags
   - `ugt.f10258LJ` - Optional title

   **CANONICAL URL STRATEGY**:
   - `content.LIZJ` is already the shortened API result (vm.tiktok.com)
   - Need to find where the CANONICAL full-length URL is stored in the content object
   - Look for fields like:
     - `shareUrl` / `share_url` / `canonicalUrl`
     - Full path URLs (https://www.tiktok.com/@username/video/ID)
     - Video ID that can be reconstructed
   - Replace content.LIZJ with canonical URL before String concatenation

2. **Intent.putExtra("android.intent.extra.TEXT", url)** - Injection point
   - Type: Intent builder
   - Purpose: Passes URL to external app
   - Appears in: All channel implementations
   - Status: Secondary (needs interception before this call)

3. **ClipboardManager writes**
   - Type: System API
   - Purpose: Copies URL to clipboard (copy channel)
   - Pattern: `ClipData.newPlainText(label, urlString)`
   - Status: Search in Smali

## Phase 1.3 COMPLETE - Canonical URL Interception Point FOUND

### ✅ VERIFIED: UEU.LIZJ() - Canonical URL Builder

**File**: `p003X/UEU.java`
**Method**: `LIZJ(int i, String str, String itemType, String key)` (Lines 62-90)
**Status**: **✅ PRIMARY INTERCEPTION POINT**

**How it works**:
```java
public static final String LIZJ(int i, String str, String itemType, String key) {
    // str = original URL (e.g., shortened link from API)
    // itemType = content type ("video", "post", etc)
    // key = share channel ("whatsapp", "twitter", "copy", etc)

    String str2 = str;
    if (!C83039UhW.LJII()) {  // Check if condition is met
        // ... complex processing ...
        String strLJJJJ = C48911HFi.LIZIZ.LJJJJ(...);  // Build canonical URL
        // Returns canonicalized URL or original
    }
    return str2;  // Return value used in share intents
}
```

**Patch Strategy**:
- Intercept `UEU.LIZJ()` return value
- This method ALREADY transforms URLs based on conditions
- We can modify the return to ALWAYS use canonical URL format
- Result: All share channels automatically get canonical URLs

### ✅ VERIFIED: UGU Content Object Structure

**File**: `InviteFriendsSheetPackage.java:33-48`
**Call chain**:
```java
// Line 33: Canonical URL generated
String strLIZJ = UEU.LIZJ(0, this.url, this.itemType, channel.key());

// Line 48: Passed to UGU content object
return new UGU(strLIZJ, strLJIJJ);
```

**Then passed to** `AbstractC82063UGk.m11879LJ()` which combines:
- `UGU.LIZJ` → Contains result from `UEU.LIZJ()` (canonical URL)
- `UGU.LIZIZ` → Additional content/hashtags

### ✅ VERIFIED: UEU.LIZJ() Smali Bytecode

**Smali File**: `smali_classes15/X/UEU.smali`
**Method**: `LIZJ(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;` (Lines 107-310)

**Key Return Points**:
- **Line 306**: `return-object v1` - Returns canonical/processed URL
- **Line 310**: `return-object p1` - Returns original or transformed URL
- **Line 160-172**: Check condition `if (!C83039UhW.LJII())` - decides which path to take

**Conditional Logic** (Lines 148-172):
```smali
# Line 148: Check if condition is met
invoke-static {}, LX/UhW;->LJII()Z
move-result v0

# Line 160: Branch based on condition
if-nez v0, :cond_1          # If condition false, go to cond_1 (canonical URL processing)
                             # If condition true, skip to :cond_1 (return original)
```

**Patch Injection Point**:
- **After Line 263**: Where canonical URL is built via `ShareExtService.LJJJJ()`
- **Before Line 306/310**: Force return of canonical URL regardless of condition
- **Strategy**: Modify conditional to ALWAYS take canonical URL path

## Next Steps (Phase 2) - Canonical URL Patch Implementation

- [ ] **Locate UEU.LIZJ() in Smali** - ✅ FOUND: `smali_classes15/X/UEU.smali:107-310`
- [ ] **Analyze return path** - ✅ ANALYZED: Two return points (v1=canonical, p1=original)
- [ ] **Create patch logic** - Modify conditional or force v1 return
- [ ] **Create smali-tests/01-canonical-url/** - Test interception
- [ ] **Implement Smali modifications** - Override URL return logic
- [ ] **Test across channels** - Verify canonical URLs in WhatsApp, Twitter, copy, etc.
- [ ] **Port to ReVanced** - Create fingerprint-based patch

## Search Patterns for Phase 2

```bash
# Find Intent.putExtra() calls with URLs (PRIMARY TARGET)
rg "putExtra.*TEXT|putExtra.*url" decompiled-jadx/sources/ -B3 -A3

# Find ClipboardManager clipboard writes (PRIMARY TARGET)
rg "ClipboardManager|ClipData.newPlainText" decompiled-jadx/sources/ -B3 -A3

# Find where tracking parameters are added
rg "utm_|tt_|enter_" decompiled-jadx/sources/ -B2 -A2

# Find all share-related classes
rg "class.*Share" decompiled-jadx/sources/ -l

# Find Intent creation patterns
rg "new Intent|ACTION_SEND|android.intent" decompiled-jadx/sources/ -B2 -A5

# Find URL string manipulation
rg "append|concat|format.*url" decompiled-jadx/sources/ -i -B2 -A2
```

## Resources

- **Decompiled JADX**: `decompiled-jadx/` (Java sources)
- **Smali output**: `decompiled-smali/` (Bytecode)
- **Search index**: `indices/strings.txt`
- **APK metadata**: `apk-metadata.txt` (SHA256: 0552a22f...)
