# ReVanced Research Repository

Workspace for researching app patches for ReVanced. Every bytecode change is validated in Smali before we even think about packaging it for wider use.

**Status:** Phase 2 | **Last Updated:** 2025-10-20 | **Current:** Canonical URL interception at LJIJJLI (blocked by LIZLLL)

## Quick Start

```bash
# Clone and setup
git clone https://github.com/revanced/revanced-research
cd revanced-research
git submodule update --init --recursive

# Read workflow
cat WORKFLOW.md      # Phase-by-phase runbook
cat CLAUDE.md        # LLM agent instructions
cat docs/status.md   # Current state dashboard
```

## Scope & Current Focus
- **Target app:** TikTok 36.5.4  
- **Objective:** Remove TikTok’s tracking parameters from outbound share URLs while preserving functionality.  
- **Phase:** 2 (Smali validation and canonical URL verification).

## Repository Layout
| Path | Purpose |
| --- | --- |
| `apps/tiktok/36.5.4/` | Version-specific lab: APK artefacts, decompilations, verification notes, and smali test iterations. |
| `apps/tiktok/36.5.4/smali-tests/` | Numbered experiments that assemble patched DEX shards before they ship. |
| `apps/tiktok/36.5.4/verification/` | Evidence from the deep analysis pass (JADX vs. Smali checks, plumbing traces). |
| `revanced-src/revanced-patches/` | Submodule mirror of the upstream ReVanced patches project for eventual porting. |
| `attempt-history.md` | Chronological tracker of major attempts, blockers, and follow-up actions. |

## Working Model
1. **Study first.** Use the decompiled sources and indices to map obfuscated classes. Document findings in `obfuscation-map.md` and `verification/` notes.
2. **Prove in Smali.** Apply changes to `smali-tests/<nn>-*/smali-classesXX`, assemble with `smali`, swap the DEX into a copy of `base.apk`, then `zipalign` and sign with `apksigner`.
3. **Record everything.** Update `injection-points.md`, `attempt-history.md`, and commit any new verification artifacts so future contributors can follow the trail.
4. **Port responsibly.** Only when a change is stable do we touch `revanced-src/revanced-patches`, following the staged integration guidance in `WORKFLOW.md`.

## Tooling Requirements
- Java 11+ (for baksmali/smali) and the Android SDK build-tools (Zipalign + Apksigner live under `~/Android/Sdk/build-tools/36.1.0/`).
- `baksmali` / `smali` for targeted DEX edits (preferred over full apktool rebuilds).
- `jadx` for Java-side reconnaissance. Full apktool decompilation is optional and usually avoided for large builds.

## Key Documentation
| File | Summary |
| --- | --- |
| `AGENTS.md` | Contributor quick-reference: repository conventions, coding standards, and review expectations. |
| `CLAUDE.md` | LLM-specific instructions for running tasks safely and updating artefacts. |
| `WORKFLOW.md` | Phase-by-phase runbook from environment setup to upstream patch submission. |
| `apps/tiktok/36.5.4/obfuscation-map.md` | Verified obfuscation mappings for the current target. |
| `apps/tiktok/36.5.4/injection-points.md` | Documented hook locations with register allocations and guards. |

## Contribution Checklist
- Follow conventional commits (`type(scope): summary`). Examples: `docs(tiktok): refresh verification log`, `test(smali): add canonical URL regression`.
- Never commit APK binaries; keep SHA256 hashes in `apk-metadata.txt` instead.
- Keep experiments reproducible—include commands, register notes, and log excerpts in the corresponding `logs/` or `verification/` files.
- Open a PR only after Smali validation is complete and documented.

For detailed instructions and historical context, start with `WORKFLOW.md`, then review the latest entries in `attempt-history.md`. Welcome aboard!
