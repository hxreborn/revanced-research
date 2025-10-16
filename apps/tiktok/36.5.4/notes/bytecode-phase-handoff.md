# Bytecode Phase Handoff

**Status**: Documentation Complete → Ready for Bytecode Verification & Implementation  
**Date**: 2025-10-16  
**Target**: Smali injection into `C98549aQC.LJFF()`  

---

## What's Locked & Ready

✅ **patch-plan.md**
- Clear problem statement (short-code metadata tracking)
- Call graph centered on C98549aQC.LJFF
- Helper function signature defined
- 6 test cases with pass/fail criteria
- No legacy CopyLinkChannel references (only comparison table)

✅ **fingerprints.md**
- FP-NEW: C98549aQC.LJFF() with bytecode anchors
- FP-001 archived with rationale and historical context
- Observable wrapper type documented

✅ **ljff-data-flow-analysis.md**
- Complete call path diagram
- Register allocation planning template
- Bytecode verification checklist (14 items)
- Resolution steps for open questions

✅ **implementation-strategy.md**
- High-level bytecode planning
- Helper class signatures
- Test environment matrix

✅ **tooling.md**
- Reproducible decompilation commands
- CFR metrics (84 seconds per JAR)
- Tool versions pinned

---

## Critical Unknowns to Resolve

Before proceeding to smali bytecode, resolve these 3 blockers:

### **1. Aweme Field Access in LJFF Context** 🔍

**Question**: How do we get `userId` and `videoId` in LJFF?

**Options**:
- [ ] **Option A**: Aweme passed as parameter to LJFF (check signature in bytecode)
- [ ] **Option B**: Aweme cached in static/instance field (trace from CopyLinkWorker)
- [ ] **Option C**: Fields already extracted and passed as string params (p2-p4)

**How to Resolve**:
```bash
# 1. Check LJFF callers
rg "\.LJFF\(" /home/rafa/revanced-research/apps/tiktok/36.5.4/decode/jadx/sources/ \
  --context 3 | head -20

# 2. Check if Aweme available in scope
rg "class C98549aQC" /home/rafa/revanced-research/apps/tiktok/36.5.4/decode/jadx/sources/ \
  -A 30 | grep -i "aweme\|field\|static"

# 3. Trace CopyLinkWorker backwards
cat /home/rafa/revanced-research/apps/tiktok/36.5.4/decode/jadx/sources/p004Y/ACallableS112S0200000_17.java:56
```

**Decision**: Must pick ONE path before coding helper

---

### **2. itemType Enum Mapping** 🔍

**Question**: Which int value = "link share" (vs message, story, etc.)?

**Options**:
- [ ] Find EnumC98548aQB or similar constant definitions
- [ ] Search for named constants (e.g., `LINK_CHANNEL = 1`, `SHARE_SHEET = 2`)
- [ ] Empirical: Apply patch to ALL itemType values (simpler but less precise)

**How to Resolve**:
```bash
# 1. Search for itemType enum
rg "enum.*C98548\|CHANNEL.*=\|LINK.*=" /home/rafa/revanced-research/apps/tiktok/36.5.4/decode/ \
  --type java | head -20

# 2. Check LJFF callers for itemType values
rg "\.LJFF\(" /home/rafa/revanced-research/apps/tiktok/36.5.4/decode/ \
  -B 5 | grep -E "const.*=|LJFF.*[0-9]"

# 3. Check SharePackage for channel types
rg "class.*SharePackage\|itemType\|channel" /home/rafa/revanced-research/apps/tiktok/36.5.4/decode/jadx/sources/p003X/ \
  | grep -i "type\|channel"
```

**Decision**: Document itemType value(s) or use `isLinkShareType()` helper

---

### **3. Observable Type Compatibility** 🔍

**Question**: Does `AbstractC98976aX5.m14172LJ(String)` return same type as `IShortenUrlApi.getShareLinkShortenUel()`?

**How to Resolve**:
```bash
# 1. Check aX5.m14172LJ signature
rg "m14172LJ\|public.*Object" /home/rafa/revanced-research/apps/tiktok/36.5.4/decode/cfr/classes18/X/aX5.java \
  -A 5 | head -15

# 2. Check IShortenUrlApi return type
rg "getShareLinkShortenUel\|Observable" /home/rafa/revanced-research/apps/tiktok/36.5.4/decode/ \
  --type java | head -10

# 3. Check C50550Hrl observer expectations
cat /home/rafa/revanced-research/apps/tiktok/36.5.4/decode/jadx/sources/p003X/C50550Hrl.java:24
```

**Decision**: Type must be compatible or add wrapper layer

---

## Verification Steps Before Smali

```bash
# Step 1: Extract exact LJFF bytecode from apktool output
cd /home/rafa/revanced-research/apps/tiktok/36.5.4/decode/apktool
find . -name "*.smali" -exec grep -l "LJFF" {} \; | head -5

# Step 2: Locate IShortenUrlApi.getShareLinkShortenUel invoke
grep -r "getShareLinkShortenUel\|IShortenUrlApi" . | head -10

# Step 3: Identify register state at injection point
# (Use smali bytecode to map which registers hold what at invoke-interface)

# Step 4: Test fingerprint on CFR output
grep -n "LJFF\|invoke-interface.*IShortenUrlApi" \
  /home/rafa/revanced-research/apps/tiktok/36.5.4/decode/cfr/classes18/X/aQC.java
```

---

## Smali Phase Readiness Checklist

Once unknowns are resolved:

- [ ] **Aweme Access Path**: Decided (parameter vs cached vs extracted)
- [ ] **itemType Value**: Documented (int value or helper function)
- [ ] **Observable Type**: Confirmed compatible with downstream observer
- [ ] **Register Allocation**: Map out exact register assignments
- [ ] **Bytecode Extracted**: LJFF smali from apktool output ready
- [ ] **Injection Point Located**: IShortenUrlApi invoke-interface found in smali
- [ ] **Test Environment**: Emulator ready for TC-001 through TC-006

---

## Next Actions

### **Phase: Bytecode Verification** (~1-2 hours)
1. Run commands above to resolve 3 unknowns
2. Document findings in ljff-data-flow-analysis.md
3. Update helper function signature if needed
4. Finalize register allocation diagram

### **Phase: Smali Implementation** (~2-3 hours)
1. Extract LJFF method from apktool smali output
2. Locate IShortenUrlApi.getShareLinkShortenUel invoke-interface
3. Draft smali injection (replace invoke-interface with buildCanonicalUrl → m14172LJ)
4. Validate register assignments

### **Phase: Testing** (~2-3 hours)
1. Build patched APK
2. Install on emulator
3. Execute TC-001 through TC-006
4. Capture logcat for analytics verification

---

## Hand-off Summary

**Documentation State**: 🟢 PRODUCTION-READY
- All introductory sections consistent
- Legacy references documented
- Open questions tracked
- Test cases defined

**Unknowns State**: 🟡 BLOCKING (must resolve before smali)
- Aweme field access method
- itemType enum value(s)
- Observable type compatibility

**Readiness**: 📋 Ready to proceed once unknowns resolved

---

## Files for Reference

| File | Purpose |
|------|---------|
| `patch-plan.md` | High-level strategy, test cases |
| `fingerprints.md` | FP-NEW spec + archived FP-001 |
| `ljff-data-flow-analysis.md` | Call path, register planning, verification checklist |
| `implementation-strategy.md` | Bytecode-level design |
| `cfr-comparison.md` | Decompiler validation |
| `tooling.md` | Reproducible commands |

---

**Status**: ✅ Documentation locked → ⏳ Awaiting bytecode verification → 🚀 Ready for smali implementation

