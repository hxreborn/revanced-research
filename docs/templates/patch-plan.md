# Patch Implementation Plan

**App**: `<app-id>`  
**Version**: `<version>`  
**Patch Name**: `<patch-name>`  
**Priority**: `[CRITICAL|HIGH|MEDIUM|LOW]`  
**Status**: `[DRAFT|REVIEW|APPROVED|IMPLEMENTED|DEPLOYED]`  
**Author**: `<your-name>`  
**Last Updated**: `YYYY-MM-DD`

---

## Executive Summary

**Objective**: Single sentence describing what the patch accomplishes.

**User Impact**: How users benefit from this patch.

**Risk Level**: `[LOW|MEDIUM|HIGH]`  
**Complexity**: `[TRIVIAL|SIMPLE|MODERATE|COMPLEX|VERY_COMPLEX]`

---

## Problem Statement

### Current Behavior

Detailed description of the existing app behavior that needs modification.

**Evidence**:
- Screenshots: `artifacts/before-*.png`
- Logcat: `artifacts/logcat-before.txt`

### Desired Behavior

Clear description of how the app should behave after patching.

**Success Criteria**:
- [ ] Criterion 1: Measurable outcome
- [ ] Criterion 2: Observable change
- [ ] Criterion 3: Regression not introduced

---

## Technical Analysis

### Target Components

**Primary Class**: `Lcom/example/app/TargetClass;`  
**Secondary Classes**: List any dependent or related classes

### Call Graph

```
MainActivity.onCreate()
  └─> FeatureManager.initialize()
      └─> [TARGET] FeatureConfig.isEnabled()
          └─> returns boolean
```

### Dependencies

**Required Patches**: List patches that must run before this one  
**Conflicting Patches**: List patches that cannot coexist  
**External Dependencies**: Android API Level, libraries

---

## Implementation Strategy

### Approach Overview

**Method**: `[BYTECODE_INJECTION|METHOD_REPLACEMENT|RESOURCE_MODIFICATION|HOOK_INSERTION|HYBRID]`

### Fingerprint Selection

**Primary Fingerprint**: FP-XXX (see fingerprints.md)  
**Confidence**: 95%  
**Fallback Fingerprint**: FP-YYY

### Injection Details

#### Injection Point 1

**Target**: `Lcom/example/TargetClass;->targetMethod(Ljava/lang/String;)Z`  
**Position**: `BEFORE` first instruction

**Injected Bytecode** (smali):

```smali
const/4 v0, 0x1
return v0
```

---

## Testing Plan

### Test Environments

**Emulator**: Pixel 6 Pro (API 33)  
**Physical Device**: Samsung Galaxy S23

### Test Cases

#### TC-001: Feature Enabled Check

**Precondition**: App installed with patch applied  
**Steps**:
1. Launch app
2. Navigate to feature UI
3. Verify feature is accessible

**Expected**: Feature displays correctly  
**Status**: `[PASS|FAIL|BLOCKED]`

---

## Risk Assessment

### Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Fingerprint fails on minor version update | MEDIUM | HIGH | Maintain fuzzy fallback fingerprints |
| Patch breaks unrelated feature | LOW | HIGH | Comprehensive regression testing |

### Security Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Patch introduces vulnerability | LOW | CRITICAL | Security review |

---

## Implementation Checklist

### Pre-Implementation

- [ ] Fingerprints validated across target versions
- [ ] Dependencies identified
- [ ] Test plan approved

### Development

- [ ] Patch code written and reviewed
- [ ] Bytecode injection verified in smali
- [ ] Comments and documentation added

### Testing

- [ ] Unit tests pass
- [ ] Tested on emulator (all test cases pass)
- [ ] Tested on physical device
- [ ] Regression tests pass

### Deployment

- [ ] Code review completed
- [ ] PR created in revanced-patches repo
- [ ] CI/CD pipeline passes
- [ ] Released to users

---

## References

### Code References

**Fingerprints**: FP-XXX, FP-YYY (see fingerprints.md)  
**Journal Entries**: YYYY-MM-DD session (see journal.md)

---

## Approval & Sign-Off

**Technical Reviewer**: (YYYY-MM-DD)  
**Final Approver**: (YYYY-MM-DD)
