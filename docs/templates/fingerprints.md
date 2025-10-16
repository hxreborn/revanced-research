# Bytecode Fingerprints

**App**: `<app-id>`  
**Version**: `<version>`  
**Last Updated**: `YYYY-MM-DD`

---

## Overview

This document catalogs method fingerprints for patch injection points. Each fingerprint should be specific enough to match the target method across obfuscation but flexible enough to work across minor version changes.

**Fingerprint Strategy**: `[EXACT|FUZZY|REGEX|OPCODES|HYBRID]`  
**Obfuscation Level**: `[NONE|LOW|MEDIUM|HIGH]`

---

## Fingerprint Template

### FP-XXX: Descriptive Name

**Priority**: `[CRITICAL|HIGH|MEDIUM|LOW]`  
**Status**: `[CANDIDATE|VALIDATED|DEPLOYED|DEPRECATED]`  
**Confidence**: `[0-100]%`

**Target Feature**: Feature or behavior this fingerprint supports  
**Patch Name**: Name of the patch that uses this fingerprint

#### Method Signature

```smali
# Original (if known)
Lcom/example/app/FeatureClass;->targetMethod(Ljava/lang/String;I)Z

# Obfuscated (if applicable)
La/b/c/d;->a(Ljava/lang/String;I)Z
```

**Return Type**: `boolean`  
**Parameters**: `String, int`  
**Access Flags**: `public static`

#### Location Context

**Class**: `Lcom/example/app/FeatureClass;` or `La/b/c/d;`  
**Package Pattern**: `com/example/app/*` or `a/b/c/*`  
**Superclass**: `Ljava/lang/Object;`  
**Interfaces**: None / `Lcom/example/Callback;`

#### Opcodes Pattern

```smali
.method public static targetMethod(Ljava/lang/String;I)Z
    .locals 3
    
    const/4 v0, 0x1
    
    invoke-static {p0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z
    move-result v1
    
    if-eqz v1, :cond_0
    
    const/4 v0, 0x0
    
    :cond_0
    return v0
.end method
```

**Key Opcodes Sequence**:
1. `const/4 v0, 0x1` — Initialize return value
2. `invoke-static {p0}, Landroid/text/TextUtils;->isEmpty(...)Z` — Check empty
3. `if-eqz v1, :cond_0` — Branch on result
4. `return v0` — Return boolean

#### String Literals

**Strings Present**:
- `"feature_enabled"` (offset: +12 instructions)
- `"default_config"` (offset: +45 instructions)

#### Method References

**Calls To** (internal):
- `Lcom/example/util/ConfigManager;->getBoolean(Ljava/lang/String;)Z`

**Calls To** (Android framework):
- `Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z`

#### Matching Strategy

**Primary Match**: Exact method signature + opcode sequence  
**Fallback 1**: Method signature + string literal "feature_enabled"  
**Fallback 2**: Method signature + calls to TextUtils.isEmpty + return type  
**Fallback 3**: Class name pattern + parameter count + return type

#### Version Compatibility

| App Version | Match Status | Notes |
|-------------|--------------|-------|
| 36.5.4 | MATCH | Original discovery |
| 36.6.0 | MATCH | Identical signature |
| 37.0.0 | PARTIAL | String literal changed |
| 37.1.0 | FAIL | Method moved |

---

## Fingerprint Index

Quick reference table:

| ID | Name | Target Class | Method | Status | Confidence |
|----|------|--------------|--------|--------|------------|
| FP-001 | Feature 1 | TargetClass | method1 | VALIDATED | 95% |
| FP-002 | Feature 2 | OtherClass | method2 | CANDIDATE | 70% |

---

## Maintenance

### Change Log

**YYYY-MM-DD**: FP-001 updated for version 37.0.0  
**YYYY-MM-DD**: FP-002 deprecated — method removed
