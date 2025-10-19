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

## Phase 1 Findings

### Share Flow Entry Points
1. **ShareModel** (classes10.dex)
   - Type: Data model
   - Purpose: Encapsulates share content and metadata
   - Key field: URL storage

2. **Room.java** (live API)
   - Annotation: `@InterfaceC37646Cp7("share_url")`
   - Direct URL field reference
   - **Promising for injection point**

3. **AppsFlyerLib helper**
   - Third-party analytics
   - May intercept/modify URLs
   - Check if bypassed

## Next Steps (Phase 2)

- [ ] Search for URL builder methods in decompiled code
- [ ] Find share action click handlers
- [ ] Locate parameter appending functions
- [ ] Identify exact injection points
- [ ] Verify register allocation in Smali
- [ ] Create numbered smali tests

## Search Patterns to Use

```bash
# Find all share-related classes
rg "class.*Share" decompiled-jadx/sources/ -l

# Find utm/tt_ parameter handling
rg "utm_|tt_|enter_" decompiled-jadx/sources/ -B2 -A2

# Find Intent.putExtra for URL
rg "putExtra.*url|putExtra.*link" decompiled-jadx/sources/ -i

# Find URL construction
rg "append|format|concat" decompiled-jadx/sources/ -l | xargs rg "url|link"
```

## Resources

- **Decompiled JADX**: `decompiled-jadx/` (Java sources)
- **Smali output**: `decompiled-smali/` (Bytecode)
- **Search index**: `indices/strings.txt`
- **APK metadata**: `apk-metadata.txt` (SHA256: 0552a22f...)
