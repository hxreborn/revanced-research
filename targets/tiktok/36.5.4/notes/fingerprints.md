# Fingerprint Candidates

| Status | Patch | Class | Method Descriptor | Key Literals/Signals | Notes |
|--------|-------|-------|-------------------|-----------------------|-------|
| draft  | share-sanitizer | Lcom/ss/android/ugc/aweme/share/improve/pkg/AwemeSharePackage; | buildShareContent(...) | `"share_link"`, `"share_link_id"`, map construction before channel dispatch | Candidate injection point before URL is added to payload map.

## Heuristics
- Describe matching literals/opcodes.
- Note dependencies (classes invoked, resources referenced).
- Capture DEX split (`smali_classesN`) and register pressure hints.

## Verification Steps
- [ ] Confirm descriptor in smali
- [ ] Validate opcode context
- [ ] Cross-check app versions
- [ ] Diff against previous run if fingerprint changed
