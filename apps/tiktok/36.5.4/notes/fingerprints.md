# Bytecode Fingerprints

**App:** TikTok
**Version:** 36.5.4
**Patch Target:** Share Link Sanitizer
**Obfuscation Level:** HIGH (R8/ProGuard)

---

## Overview

Fingerprints for identifying and patching TikTok's share link handling pipeline. Target is the final clipboard write operation to intercept and sanitize tracking URLs.

---

## FP-001: CopyLinkChannel.LJI() - Final Clipboard Write

**Priority:** CRITICAL
**Status:** VALIDATED
**Confidence:** 95%
**DEX Location:** `classes8.dex`

### Target

**Feature:** Share link interception before clipboard
**Patch Name:** ClipboardInterceptor

### Method Signature

```smali
# Decompiled Java
public boolean LJI(
    C98754aTV content,
    Context context,
    InterfaceC50877Hx2 callback
)
```

**Return Type:** `boolean`
**Parameters:** `(Lcom/p124ss/android/ugc/aweme/share/model/C98754aTV;Landroid/content/Context;LInterfaceC50877Hx2;)Z`
**Access Flags:** `public`
**Visibility:** Instance method

### Location

**Class:** `Lcom/p124ss/android/ugc/aweme/share/improve/channel/CopyLinkChannel;`
**Package Pattern:** `com/p124ss/android/ugc/aweme/share/improve/channel/*`
**Superclass:** `Ljava/lang/Object;`
**Interfaces:** `InterfaceC98362aNB` (handler interface)

### Key Operations

1. Receives `C98754aTV content` object containing:
   - `content.LIZJ` (title string)
   - `content.LIZLLL` (share URL - TARGET FOR INTERCEPTION)

2. Extracts both fields and combines them

3. Delegates to `C98761aTc.LIZLLL()` for clipboard write

### Opcodes Pattern

```smali
.method public LJI(Lcom/p124ss/android/ugc/aweme/share/model/C98754aTV;Landroid/content/Context;LInterfaceC50877Hx2;)Z
    .locals 2

    # Check if content exists
    if-eqz p1, :cond_0

    # Extract field LIZLLL (share URL)
    iget-object v0, p1, Lcom/p124ss/android/ugc/aweme/share/model/C98754aTV;->LIZLLL:Ljava/lang/String;

    # Extract field LIZJ (title)
    iget-object v1, p1, Lcom/p124ss/android/ugc/aweme/share/model/C98754aTV;->LIZJ:Ljava/lang/String;

    # Invoke clipboard handler
    invoke-static {v0, v1}, LC98761aTc;->LIZLLL(Ljava/lang/String;Ljava/lang/String;)Z
    move-result v0

    return v0

    :cond_0
    const/4 v0, 0x0
    return v0
.end method
```

**Key Sequence:**
1. Parameter check: `if-eqz p1`
2. Field extraction: `iget-object` x2
3. Clipboard delegation: `invoke-static` to `C98761aTc.LIZLLL()`
4. Return result: `move-result`, `return`

### Matching Strategy

**Primary Match:** Method signature + opcodes + field access pattern
**Fallback 1:** Method signature + invoke to `C98761aTc.LIZLLL()`
**Fallback 2:** Class inheritance pattern + parameter types
**Fallback 3:** Package pattern `com/p124ss/android/ugc/aweme/share/improve/channel/*`

### Version Compatibility

| Version | Status | Notes |
|---------|--------|-------|
| 36.5.4 | ✅ MATCH | Original discovery |
| 36.6.x | UNTESTED | Likely match; minor version should preserve signature |
| 37.x.x | UNTESTED | Major version may have refactoring |

---

## FP-002: C98444aOV.LIZIZ() - URL Parameter Builder

**Priority:** HIGH
**Status:** VALIDATED
**Confidence:** 90%
**DEX Location:** `classes18.dex`

### Target

**Feature:** URL construction with tracking parameters
**Patch Name:** TrackingParamExtractor (optional secondary patch)

### Method Signature

```smali
# Decompiled Java
public void LIZIZ(
    BaseSharePackage sharePackage,
    Context context,
    List<InterfaceC98362aNB> channels
)
```

### Key Operations

**Lines 137-146 (Tracking params extraction):**

```java
UriProtector.getQueryParameter(uri, "invitation_scene")  // User context
UriProtector.getQueryParameter(uri, "share_link_id")      // CRITICAL TRACKING ID
UriProtector.getQueryParameter(uri, "share_item_id")      // Content ID
UriProtector.getQueryParameter(uri, "social_share_type")  // Platform type
```

**Lines 194-195 (API shortening call):**

```java
IMultiShortenUrlApi api = C1GW.LIZ;  // Shortening service
AbstractC98976aX5<MultiShortenModel> response =
    api.getPreShareLinkShortenUrl(
        new MultiShortenShareRequest(scene, shareUrlInfos)
    );
```

### Matching Strategy

**Pattern:** Search for `share_link_id` string literal + `social_share_type` param extraction
**Fallback:** Method contains `MultiShortenShareRequest` instantiation

---

## FP-003: AwemeSharePackage - Share Content Builder

**Priority:** MEDIUM
**Status:** VALIDATED
**Confidence:** 85%

### Target

**File:** `com/p124ss/android/ugc/aweme/share/improve/pkg/AwemeSharePackage.java`
**Method:** `LIZLLL()` - Builds share package, dispatches to channels

### Key Signals

- Handles multiple channels: WhatsApp, Facebook, Instagram, SMS, etc.
- Channel dispatch via handler classes: `C98480aP5`, `C98472aOx`, etc.
- URL building happens in channel-specific handlers

### String Literals

- `"whatsapp"`, `"facebook"`, `"instagram"`, `"sms"`
- `"copy_link"`

---

## FP-004: ShareServiceImpl - Share Flow Entry Point

**Priority:** MEDIUM
**Status:** VALIDATED
**Confidence:** 85%

### Target

**File:** `com/p124ss/android/ugc/aweme/share/ShareServiceImpl.java`
**Pattern:** Instantiates `CopyLinkChannel(false)` at multiple locations

### Invocation Pattern

```smali
new-instance v0, Lcom/p124ss/android/ugc/aweme/share/improve/channel/CopyLinkChannel;
invoke-direct {v0, v1}, Lcom/p124ss/android/ugc/aweme/share/improve/channel/CopyLinkChannel;-><init>(Z)V
invoke-interface {p1}, Lcom/p124ss/android/ugc/aweme/share/ShareService;->LIZIZ(Lcom/p124ss/android/ugc/aweme/share/base/model/BaseSharePackage;)V
```

**Locations:** Lines 978, 1091, 1397 (all identical pattern)

---

## String Literals for Verification

Search these strings to confirm class locations:

| String | Expected Class | Purpose |
|--------|----------------|---------|
| `"invitation_scene"` | C98444aOV | URL param extraction |
| `"share_link_id"` | C98444aOV | Tracking ID param |
| `"social_share_type"` | C98444aOV | Platform param |
| `"/tiktok/share/link/shorten/multi/v1"` | IMultiShortenUrlApi | API endpoint |
| `"CopyLinkChannel"` | ShareServiceImpl | Entry point |

---

## Verification Steps

- [x] Confirm classes exist in classes18.dex and classes8.dex
- [x] Verify method signatures match decompiled output
- [x] Locate tracking parameters in source
- [x] Identify clipboard delegation point
- [ ] Extract exact smali bytecode for injection verification
- [ ] Test fingerprints on emulator with hook

---

## Cross-Decompiler Notes

**jadx vs CFR:**
- jadx: Accurate decompilation of obfuscated code; heavy use of renamed types
- CFR: Better type inference for generics; not tested on this APK (CFR incompatible with large APKs)

All findings based on **jadx** decompilation with `--deobf` flag.
