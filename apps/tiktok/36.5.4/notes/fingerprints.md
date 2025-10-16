# Fingerprint Candidates

## Primary Share Flow

### 1. CopyLinkChannel (Confirmed - Primary Target)
| Status | Component | File Path | Method | Signals |
|--------|-----------|-----------|--------|---------|
| **CONFIRMED** | Link Copy Handler | `com/p124ss/android/ugc/aweme/share/improve/channel/CopyLinkChannel.java` | `LJI()` (line 36) | Handles final link copy before clipboard |

**Key findings:**
- `LJI(C98754aTV content, Context context, ...)` receives pre-built share link in `content.LIZLLL`
- Combines title (`content.LIZJ`) + link (`content.LIZLLL`)
- Delegates to `C98761aTc` for clipboard copy (line 51)
- **Patch point:** Intercept `content.LIZLLL` before copy

### 2. AwemeSharePackage (Confirmed - Link Builder)
| Status | Component | File Path | Method | Signals |
|--------|-----------|-----------|--------|---------|
| **CONFIRMED** | Share Package | `com/p124ss/android/ugc/aweme/share/improve/pkg/AwemeSharePackage.java` | `LIZLLL()` | Builds share content, dispatches channels |

**Key findings:**
- Handles multiple share channels (WhatsApp, Facebook, Instagram, SMS, etc.)
- Channel dispatch via handler classes: `C98480aP5`, `C98472aOx`, etc.
- URL building happens in channel-specific handlers
- **Patch point:** Intercept URL before channel assignment

### 3. ShareServiceImpl (Confirmed - Entry Point)
| Status | Component | File Path | Method | Signals |
|--------|-----------|-----------|--------|---------|
| **CONFIRMED** | Service | `com/p124ss/android/ugc/aweme/share/ShareServiceImpl.java` | Multiple LIZIZ() calls | Instantiates `CopyLinkChannel(false)` at lines 978, 1091, 1397, etc. |

**Invocation pattern:**
```java
c98409aNw.LIZIZ(new CopyLinkChannel(false));  // Line 978
```

### 4. ShareService Interface (Confirmed - API)
| Status | Component | File Path | Methods | Notes |
|--------|-----------|-----------|---------|-------|
| **CONFIRMED** | Interface | `com/p124ss/android/ugc/aweme/share/ShareService.java` | ~40 obfuscated methods | One unobfuscated: `shareSubscribeLink()` (line 177) |

---

## Link Building Chain

```
ShareServiceImpl.LIZIZ()
    ↓ (instantiates)
CopyLinkChannel(false)
    ↓ (receives)
C98754aTV content (title + LIZLLL)
    ↓ (calls)
CopyLinkChannel.LJI()
    ↓ (extracts)
content.LIZLLL (the share link - FINAL TARGET)
    ↓ (delegates to)
C98761aTc.LIZLLL() → Clipboard
```

---

## Tracking Parameters Found

From search results in `ApS49S0210000_6.java`:
```
- share_source (from utm_source)
- share_link_id (hardcoded or generated)
- utm_campaign
```

---

## Heuristics for Matching

- Look for `CopyLinkChannel` instantiation in smali
- Match method signature: `LJI(C98754aTV, Context, InterfaceC50877Hx2)` → `boolean`
- Track field `LIZLLL` (string type, contains full share URL)
- Verify call chain: `LIZLLL()` in CopyLinkChannel invokes clipboard write

## DEX Location

- **Likely class split:** `classes8.dex` (CopyLinkChannel found here)
- Verify in: `smali/com/p124ss/android/ugc/aweme/share/improve/channel/CopyLinkChannel.smali`

## Verification Steps

- [x] Confirm ShareServiceImpl instantiates CopyLinkChannel
- [x] Verify CopyLinkChannel.LJI() is link copy handler
- [x] Locate tracking parameters (share_source, utm_campaign, share_link_id)
- [ ] Extract exact smali bytecode for patch fingerprinting
- [ ] Test on emulator with hook to verify interception point
- [ ] Cross-check app versions (36.5.4 ✓ confirmed)
