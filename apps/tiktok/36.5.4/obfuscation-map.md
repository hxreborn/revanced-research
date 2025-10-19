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
- **JADX output**: `decompiled-jadx/sources/` (166,751 sources decompiled)
- **Indices**: `indices/strings.txt` (39,246 lines of relevant hits)

## Share Intent Link Sanitizer - Patch Goal

**Objective**: Remove tracking parameters from share URLs before they're passed to external apps via Intent

**URL Sanitization Pattern**:
- Remove query parameters: `utm_*`, `tt_*`, `enter_*` and other tracking vectors
- Keep canonical short link structure: `https://vm.tiktok.com/{VIDEO_ID}`
- Result: Clean, shareable URLs without analytics tracking

**Patch Strategy**:
1. **Identify share intent creation**: Find where URLs are attached to share Intents
2. **Locate URL parameter**: Get the tracking URL string before it's sent to external apps
3. **Sanitize**: Strip tracking parameters using regex or string operations
4. **Pass clean URL**: Let cleaned URL flow through to Intent.putExtra() or clipboard

**Expected flow**:
```
User taps Share → URL with tracking params
                    ↓
            Patch interception point
                    ↓
            Sanitize tracking params
                    ↓
            Create/update Intent with clean URL
                    ↓
            Send to external app / clipboard
```

**Reference architecture** (from older package analysis - method names may differ):
- Entry point: Share orchestrator (100% coverage across all channels)
- Injection point: Before Intent.putExtra() or clipboard write
- Exit point: External app receives clean URL

**Key principle**: Single-point sanitization for consistent behavior across all share channels

## Phase 1 Findings

### Share Flow Candidates for Patching

1. **Intent.putExtra() calls** (Android framework)
   - Type: System API
   - Purpose: Passes URL to external apps
   - Pattern: `putExtra("android.intent.extra.TEXT", urlString)`
   - Status: **SEARCH TARGET**

2. **Clipboard writes** (ClipboardManager)
   - Type: System API
   - Purpose: Copies URL to clipboard
   - Pattern: `ClipData.newPlainText(label, urlString)`
   - Status: **SEARCH TARGET**

3. **ShareModel** (classes10.dex)
   - Type: Data model
   - Purpose: Encapsulates share content and metadata
   - Key field: URL storage
   - Status: Investigate

4. **Room.java** (live API)
   - Annotation: `@InterfaceC37646Cp7("share_url")`
   - Direct URL field reference
   - Status: Investigate

## Next Steps (Phase 2) - Share Intent Sanitizer

- [ ] **Find Intent.putExtra() calls** - Where URLs are passed to external apps
- [ ] **Find ClipboardManager writes** - Where URLs are copied to clipboard
- [ ] **Locate URL parameter** - Get the tracking URL string before Intent/clipboard use
- [ ] **Verify parameter location** - Ensure URL is in a modifiable register/variable
- [ ] **Create smali-tests/01-intent-sanitizer/** - Test URL parameter sanitization
- [ ] **Implement sanitization** - Remove utm_*, tt_*, enter_* before Intent/clipboard
- [ ] **Test across channels** - Verify clean URLs in WhatsApp, Twitter, copy, etc.

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
