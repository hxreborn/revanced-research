# Phase 5: Bypass Shortening Orchestrator (2025-10-20)

**Focus**: Replace shortened URLs with canonical URLs to remove tracking

**Status**: [SUPERSEDED] by Phase 6 - Approach based on incorrect assumption

**Date**: 2025-10-20

---

## Hypothesis

**Original Assumption**: UEU.LIZLLL() returns shortened URLs (vm./vt.tiktok.com) that need to be replaced with canonical URLs

**Implementation Plan**:
1. Detect if URL is shortened (starts with vm./vt.tiktok.com)
2. Replace with canonical form (www.tiktok.com/@user/video/ID)
3. Bypass the shortening orchestrator entirely

---

## Technical Implementation

### Injection Point
- **File**: `smali_classes15/X/UEU.smali`
- **Method**: `LIZLLL(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)LX/Wu4;`
- **Line**: 3866 (after `move-result-object` from `UEa.LIZ()` call)

### Register Allocation

```
.registers 6
v0 = local (int - detection result)
v1 = local (String - URL)
v2-v5 = method parameters (p0-p3)
```

### Smali Code Attempted

```smali
move-result-object v1           # v1 = URL from UEa.LIZ()

# Null check
if-eqz v1, :keep_shortened

# Check if URL is shortened (vm. or vt. prefix)
const-string v0, "vm.tiktok.com"
invoke-virtual {v1, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
move-result v0

if-nez v0, :check_vt            # If not vm., check vt.

# Replace with canonical form
const-string v1, "https://www.tiktok.com/@user/video/ID"
goto :continue

:check_vt
# Similar check for vt.tiktok.com...
# (pattern repeated)

:keep_shortened
# Continue to rest of method

:continue
# Method continues...
```

### Build Results

- ✅ **Gradle compile**: Success - valid Kotlin bytecode
- ✅ **DEX assembly**: Success - baksmali/smali cycle valid
- ✅ **APK installation**: Success - no VerifyError
- ✅ **App launch**: Success - no crashes

**But functionally**: ❌ **[FAIL]** - No shortened URLs detected

---

## Why This Approach Failed

### Discovery During Testing

When comparing URLs before and after patching:
- **Expected**: `vm.tiktok.com/...` or `vt.tiktok.com/...`
- **Actual**: `https://www.tiktok.com/@user/video/ID?_r=1&u_code=0&utm_source=copy&...share_link_id=...`

**Realization**: The URL at UEa.LIZ() **is not shortened**. It's a **canonical URL with massive tracking blob** (505 bytes, 18 parameters).

The "shortening orchestrator" doesn't actually shorten URLs at this layer - it **adds tracking information**.

---

## What This Phase Taught Us

### Technical Achievements (Carried Forward)

Even though the functional goal was wrong, the implementation revealed several patterns used in Phase 6:

1. **Register allocation strategy**: `.registers 6` with proper parameter mapping
2. **DEX type safety**: Using v0 for int results, v1 for String operations
3. **Label naming**: Suffix labels with `_c` or unique identifiers (`:keep_shortened_c`, `:check_shortened`) to prevent collisions
4. **Null safety pattern**: Always `if-eqz` before calling methods
5. **Control flow**: Using `goto` and conditional branches together

### The Real Problem

URLs already **contain** the tracking parameters by the time they reach LIZLLL(). The solution isn't to detect and replace URLs, but to **strip the query parameters** from the canonical URL.

**Result**: Leads directly to Phase 6's parameter sanitization approach.

---

## References

- **Smali test**: `apps/tiktok/36.5.4/smali-tests/05-option-c-bypass/`
- **Build artifacts**: `phase5-final-aligned.apk`, `classes15-final.dex`
- **Key insight**: Phase 6 uses the same injection point (line 3866) with whitelist sanitization instead

---

## Conclusion

**Status**: [SUPERSEDED]

This phase was **not wasted** - it provided:
1. Proof that the injection point is safe and accessible
2. Register allocation patterns for Phase 6
3. Understanding of what data actually flows through UEu.LIZLLL()
4. Direction for Phase 6's simpler, more effective approach

See [phase-6-sanitizer.md](phase-6-sanitizer.md) for the successful solution.
