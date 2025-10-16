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
- [ ] (Optional) PR created in revanced-patches repo
- [ ] CI/CD pipeline passes
- [ ] Released to users

---

## References

### Code References

**Fingerprints**: FP-XXX, FP-YYY (see fingerprints.md)
**Analysis Notes**: See README.md for findings summary

---

## Example: TikTok 36.5.4 Share Link Sanitizer

This is a complete example from start to finish.

### Executive Summary

**Objective**: Remove tracking parameters from TikTok share links before clipboard write.

**User Impact**: Users can share videos without exposing tracking UUIDs that correlate behavior across platforms.

**Risk Level**: LOW
**Complexity**: SIMPLE

### Problem Statement

#### Current Behavior

TikTok embeds tracking identifiers (`share_link_id`, `social_share_type`, `invitation_scene`, `share_item_id`) in every share link. These are encoded in short URLs (`vm.tiktok.com/XXX`) and logged server-side to correlate user behavior.

**Example tracking chain:**
```
Share video → share_link_id=UUID-1 generated
→ Link sent to WhatsApp
→ User opens link → TikTok logs UUID-1
→ Later share → UUID-2 logged
→ TikTok correlates UUID-1 + UUID-2 to user account
```

#### Desired Behavior

Users' clipboard receives clean links with no tracking parameters.

**Success Criteria**:
- [ ] Shared links have no query parameters
- [ ] Link functionality preserved (video still loads)
- [ ] Works across all share destinations (WhatsApp, SMS, Email, etc.)
- [ ] No app crashes
- [ ] Reproducible across multiple shares

### Technical Analysis

#### Target Components

**Primary Class**: `CopyLinkChannel` (line 36, method `LJI()`)
**Location**: `classes8.dex`
**Fingerprint**: FP-001 (see fingerprints.md for full details)

#### Call Graph

```
ShareServiceImpl.LIZIZ()
  └─> new CopyLinkChannel(false)
      └─> [PATCH TARGET] CopyLinkChannel.LJI()
          ├─ input: content.LIZLLL (share URL with params)
          ├─ [SANITIZATION POINT]
          └─> C98761aTc.LIZLLL() → Clipboard write
```

#### Dependencies

- None (Android Uri.parse built-in)

### Implementation Strategy

#### Approach

**Method**: BYTECODE_INJECTION

Inject URL sanitization logic inside `CopyLinkChannel.LJI()` after field extraction, before clipboard delegation.

#### Fingerprint Selection

**Primary**: FP-001 (`CopyLinkChannel.LJI()` method signature + opcodes)
**Confidence**: 95%
**Fallback**: String literals + method signature if primary fails

#### Injection Details

**Target Method**: `CopyLinkChannel;->LJI(C98754aTV;Landroid/content/Context;InterfaceC50877Hx2;)Z`
**Position**: After `iget-object` field extraction of `content.LIZLLL`, before `invoke-static` to clipboard

**Injected Code** (smali):
```smali
# After extracting v0 (share URL)
invoke-static {v0}, Lcom/revanced/tiktok/extensions/ShareLinkUtils;->sanitizeShareUrl(Ljava/lang/String;)Ljava/lang/String;
move-result-object v0  # v0 now contains sanitized URL
# Continue with v0 to clipboard
```

**Helper Class**:
```java
public class ShareLinkUtils {
    public static String sanitizeShareUrl(String url) {
        try {
            Uri uri = Uri.parse(url);
            return uri.getScheme() + "://" + uri.getAuthority() + uri.getPath();
        } catch (Exception e) {
            return url;  // Fallback on error
        }
    }
}
```

### Testing Plan

#### TC-001: WhatsApp Share
- Open video → Share → WhatsApp
- Verify URL has no `?share_link_id=`, `?social_share_type=`, etc.
- **Expected**: `https://www.tiktok.com/@user/video/12345`

#### TC-002: Clipboard Copy
- Copy link to clipboard → Paste in Notes
- **Expected**: Clean canonical URL only

#### TC-003: Multiple Shares
- Share 3 times to different apps
- **Expected**: Identical URL each time (no randomized tracking IDs)

#### TC-004: Link Functionality
- Share and copy link → Open in browser
- **Expected**: Video loads correctly

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Fingerprint fails on 36.6.x | LOW | HIGH | Test across minor versions |
| URL parsing fails | VERY LOW | MEDIUM | Fallback to original URL |
| Patch breaks share | VERY LOW | CRITICAL | Test all share paths |
| TikTok detects patch | LOW | MEDIUM | No client-side prevention |

### Implementation Checklist

- [ ] Fingerprints validated (FP-001 tested on 36.5.4)
- [ ] Dependencies identified (none)
- [ ] Test plan created (TC-001 through TC-004)
- [ ] ShareLinkUtils helper class implemented
- [ ] Smali injection tested
- [ ] All TCs pass on emulator
- [ ] Code review complete
- [ ] (Optional) PR created

---

## Approval & Sign-Off

**Technical Reviewer**: (YYYY-MM-DD)
**Final Approver**: (YYYY-MM-DD)
