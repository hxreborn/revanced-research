# Phase 4: Discovery & Verification (2025-10-19)

**Focus**: Locate canonical URL entry point and verify injection location safety

**Result**: [PASS] Breakthrough discovery - canonical URL found at AwemeSharePackage.LJIJJLI(), line 2795

---

## Discovery Path

### Failed Attempts (Context)

Before finding the correct injection point, we tested several hypotheses:

| Attempt | Target Method | Location | Result | Reason |
|---------|--------------|----------|--------|--------|
| Test 1 | `UEU.LIZJ()` | `X/UEU.smali:150` | [BROKEN] | Method never called during share flow |
| Test 2 | `UGk.LJ()` | `X/UGk.smali:3142` | [BROKEN] | Method exists in bytecode but not executed |
| Test 3 | `AwemeSharePackage.LJIJJ()` | `AwemeSharePackage.smali:21638` | [BROKEN] | Shortened URL already in List - too late in pipeline |

These early attempts taught us that:
1. Static method hooks may not be called at expected times
2. Verifying execution flow via Smali inspection is critical
3. Need to trace the **complete call chain**, not just find methods by name

### Breakthrough: URL Entry Point

**Critical Finding at `AwemeSharePackage.LJIJJLI()` line 2795**:

```smali
iget-object v4, p0, Lcom/ss/android/ugc/aweme/share/base/model/BaseSharePackage;->url:Ljava/lang/String;
# v4 = "https://www.tiktok.com/@user/video/ID?params..."
```

**URL arrives CANONICAL**, meaning:
- No shortening has occurred yet
- No tracking parameters stripped
- Complete control over what gets distributed to share channels

### URL Processing Flow

```
1. AwemeSharePackage.LJIJJLI()          (line 2795)
   ↓ Receives canonical URL from BaseSharePackage

2. ULX.LIZ(v4, p0)                      (formats URL, still canonical)
   ↓

3. UEU.LIZLLL(v3, v2, v1, v0)           (line 2932, shortening orchestrator)
   ↓ Calls UEa.LIZ()

4. UEa.LIZ()                            (ADDS tracking blob)
   ↓ Returns URL with 18 parameters, 505 bytes

5. Distribution
   ↓ Sent to Intent (WhatsApp/Twitter/SMS) or Clipboard
```

**Strategic Insight**: The URL gets tracking parameters **added** at step 4, not shortened. This means we need to **sanitize parameters**, not detect/remove shortened URLs.

---

## Verification (Phase 4)

### Injection Location Safety Check

**Test Environment**: Fresh decompilation with minimal logging patch at line 3866 in `X/UEU.smali`

**Verification Results**:
- **Compilation**: No errors, valid bytecode (103MB DEX)
- **Installation**: No DEX verification errors or VerifyError exceptions
- **DEX verification**: Passed without issues
- **App launch**: Normal operation, no crashes
- **Share function**: Trigger share, observe execution reaches patched location

### Obfuscation Mappings Verified

All JVM type descriptors verified byte-for-byte:
- `p003X.UEU` - URL transformer (classes15.dex)
- `p003X.UEa` - URL builder with tracking (classes15.dex)
- `p003X.C54243JOk` - AwemeSharePackage factory (classes9.dex)
- Share plumbing - Intent (ACTION_SEND, EXTRA_TEXT), ClipboardManager

### Call Chain Verification

End-to-end verification:
1. User taps "Share"
2. AwemeSharePackage.LJIJJLI() called with Aweme object
3. Canonical URL retrieved from BaseSharePackage
4. UEU.LIZLLL() orchestrator called
5. Inside LIZLLL: UEa.LIZ() adds tracking parameters
6. Result distributed to share channels

**No lambdas or complex indirection** - straightforward patching possible

---

## Key Learnings

1. **Smali inspection is reliable**: Following the actual method call graph in bytecode reveals truth better than Java decompilation
2. **Canonical URLs persist longer than expected**: Share URLs maintain full canonical form until final distribution
3. **Tracking happens late**: The last method in the chain (UEa.LIZ()) is where parameters are added
4. **Register pressure is manageable**: LIZLLL uses only v0-v5, leaving room for temporary operations
5. **DEX verification is strict but predictable**: Following type safety rules prevents failures

---

## Next Steps

**Phase 5-6**: Implement URL sanitization at the injection point (line 3866 in UEU.LIZLLL method)

See [phase-5-bypass.md](phase-5-bypass.md) and [phase-6-sanitizer.md](phase-6-sanitizer.md) for implementation details.
