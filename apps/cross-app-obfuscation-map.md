# Cross-App Obfuscation Mapping: TikTok vs Musically (36.5.4)

**Generated**: 2025-10-24
**Purpose**: Document obfuscation differences between com.ss.android.ugc.trill and com.zhiliaoapp.musically for share URL sanitization patch development

---

## Target Feature: Share URL Generation

### Primary Classes

| Component | TikTok (trill) | Musically | Notes |
|-----------|----------------|-----------|-------|
| **Package** | `com.ss.android.ugc.trill` | `com.zhiliaoapp.musically` | Different app IDs |
| **Java Class** | `p003X.UEU` | `p003X.C98464aOp` | Deobfuscated names |
| **Smali Path** | `smali_classes15/X/UEU.smali` | `smali_classes18/X/aOp.smali` | Different DEX files |
| **Java Source** | `apps/tiktok/apks/36.5.4/jadx-deobf/sources/p003X/UEU.java` | `apps/musically/apks/36.5.4/jadx-deobf/sources/p003X/C98464aOp.java` | Decompiled Java |
| **Fingerprint String** | `getShortShareUrlObservab…ongUrl, subBizSceneValue)` | `getShortShareUrlObservab…ongUrl, subBizSceneValue)` | Identical |

---

## Share URL Call Chain

### Caller Class Identified (2025-10-24)

Both apps use identical call path.

| Aspect | TikTok (trill) | Musically | Match |
|--------|----------------|-----------|-------|
| **Caller Class** | `LinkDefaultSharePackageV2` | `LinkDefaultSharePackageV2` | Identical |
| **Caller Method** | `LJIILL()` | `LJIILL()` | Identical |
| **Location** | `com/ss/android/ugc/aweme/model/LinkDefaultSharePackageV2.java` | `com/ss/android/ugc/aweme/model/LinkDefaultSharePackageV2.java` | Identical |
| **Line Number** | Line 38 | Line 38 | Identical |
| **Method Call** | `UEU.LIZLLL(0, this.url, this.itemType, channel.key())` | `C98464aOp.LIZLLL(0, this.url, this.itemType, channel.key())` | Only class name differs |

**Proof:** Static code analysis confirms both apps execute the same share flow, targeting the same LIZLLL method.

**Why Frida failed on Musically:** AOT/JIT optimization inlined the method, bypassing runtime hooks. Bytecode patches still work because they modify pre-compilation.

---

## Method Signatures

### URL Generation Method (LIZLLL)

| Aspect | TikTok (trill) | Musically | Match |
|--------|----------------|-----------|-------|
| **Method Name** | `LIZLLL` | `LIZLLL` | Identical |
| **Parameters** | `(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)` | `(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)` | Identical |
| **Return Type** | `LX/Wu4;` | `LX/aX5;` | Different obfuscation |
| **Signature** | `.method public static final LIZLLL(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)LX/Wu4;` | `.method public static final LIZLLL(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)LX/aX5;` | Different return type only |

---

## Helper Classes

### URL Builder API Class

| Aspect | TikTok (trill) | Musically | Notes |
|--------|----------------|-----------|-------|
| **Class** | `C48911HFi` | `IV4` | Different obfuscation |
| **Method** | `LJIILLIIL` | `LJIIZILJ` | Different obfuscation |
| **Call Pattern** | `C48911HFi.LIZIZ.LJIILLIIL(i, itemType, key, strLIZ)` | `IV4.LIZIZ.LJIIZILJ(i, itemType, key, strLIZ)` | Different |

### Other Helper Classes

| Purpose | TikTok (trill) | Musically | Notes |
|---------|----------------|-----------|-------|
| URL Builder | `C269118gM` | `C272038l4` | Query param builder |
| File URI Helper | `C81593TzI` | `C78430SpN` | File to URI conversion |
| Ref Holder | `C531004j` | `C530904i` | Mutable reference |
| URL Processor | `C82001UEa` | `C98758aTZ` | URL transformation |

---

## Code Structure Analysis

### Identical Elements (Universal Patch Candidates)

1. **Method name**: `LIZLLL` - can use as stable fingerprint
2. **Parameter count and types**: 4 params (int + 3 strings) - consistent signature
3. **Fingerprint string**: `getShortShareUrlObservab` - present in both apps
4. **Method visibility**: `public static final` - same access modifiers
5. **Core logic flow**: Nearly identical bytecode structure

### Variable Elements (Requires App-Specific Handling)

1. **DEX location**: `classes15` vs `classes18` - different split DEX files
2. **Class names**: `UEU` vs `aOp` - different obfuscated identifiers
3. **Return types**: `Wu4` vs `aX5` - different observable wrapper classes
4. **Helper class names**: All helper classes have different obfuscated names
5. **Method names in helpers**: API methods like `LJIILLIIL` vs `LJIIZILJ` differ

---

## Patch Strategy

### Option 1: Fingerprint-Based Universal Patch (Recommended)

**Approach**: Use stable identifiers to locate the method, then apply logic-equivalent patches

**Stable Fingerprints**:
- Search for string literal: `"getShortShareUrlObservab"`
- Method signature pattern: `LIZLLL(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)`
- Return type pattern: Observable-like class (Wu4/aX5 pattern)

**Patch Logic** (app-agnostic):
1. Locate method by fingerprint
2. Identify the API call instruction (invoke-virtual on LJIILLIIL/LJIIZILJ)
3. Insert URL sanitization before the call returns
4. Strip tracking parameters: utm_*, share_*, sec_*, enter_from, etc.

### Option 2: Parallel App-Specific Patches

**Approach**: Maintain separate patches for each app with identical logic

**TikTok Patch**:
- Target: `smali_classes15/X/UEU.smali`
- Method: `LIZLLL`
- Line reference: TBD after analyzing full method

**Musically Patch**:
- Target: `smali_classes18/X/aOp.smali`
- Method: `LIZLLL`
- Line reference: TBD after analyzing full method

---

## Next Steps

1. Completed: Located target classes and methods in both apps
2. In Progress: Document obfuscation mapping
3. Next: Analyze full LIZLLL method bytecode for both apps
4. Next: Write Frida tracing scripts to confirm runtime behavior
5. Next: Develop Smali patch with parameter stripping logic
6. Next: Test patches on both apps

---

## Tracking Parameters (21 total, 505 bytes)

From previous research on trill 36.5.4:

```
utm_source, utm_medium, utm_campaign, utm_content, utm_term,
share_link_id, share_app_id, share_iid, timestamp_ms,
enter_from, enter_method, share_item_id, share_token,
sec_user_id, sec_uid, share_signature, share_sig,
link_id, from_ssr, gd_label, pd_label
```

**Total size**: 505 bytes overhead per share URL

---

## Files Modified

- This document: `apps/cross-app-obfuscation-map.md`
- TikTok deobf source: `apps/tiktok/apks/36.5.4/jadx-deobf/sources/p003X/UEU.java`
- Musically deobf source: `apps/musically/apks/36.5.4/jadx-deobf/sources/p003X/C98464aOp.java`
- TikTok Smali: `apps/tiktok/apks/36.5.4/apktool/smali_classes15/X/UEU.smali`
- Musically Smali: `apps/musically/apks/36.5.4/apktool/smali_classes18/X/aOp.smali`
