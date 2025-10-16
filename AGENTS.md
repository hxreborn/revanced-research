# AGENTS

Ops manual for the revanced-research lab—the reverse engineering hub powering ReVanced patch development. Keep this document synchronized with the project so any agent can ramp quickly.

---

## Base Practices

- **Network boundaries**: All RE activity lives here, outside the `revanced-patches/` repo. Only push distilled fingerprints, bytecode offsets, or patch snippets back to the main project.
- **Single source of truth**: Maintain this guide and shared templates; per-app findings belong under `apps/<package>/<version>/notes/`.
- **Version isolation**: Always nest target per app *and* version so multiple builds can be analyzed in parallel without collisions.
- **Lightweight provenance**: Track hashes of input APKs (`sha256sum`), tool versions, and key commands. Store them alongside notes for traceability.
- **Optional git**: If you want history inside `revanced-research/`, initialize a separate repository but avoid committing large decode outputs.
- **Determinism first**: Remove `decode/*` and `artifacts/*` before each run, record tool versions, and persist APK hashes to keep diffs meaningful.

---

## Directory Layout

````text
revanced-research/
├── README.md                # Human overview & quick start
├── AGENTS.md                # Machine-facing guide (this file)
├── CLAUDE.md                # Claude Code guidance
├── docs/
│   ├── templates/           # Markdown skeletons for per-target notes
│   └── JVM_GC_TROUBLESHOOTING.md
├── scripts/                 # Utility helpers (setup, cleanup, jadx wrapper)
└── apps/
    └── <package>/<version>/ # e.g., tiktok/36.5.4
        ├── apk/             # Pristine APKs (hashes logged)
        ├── decode/          # Tool outputs (apktool/, jadx/, optional dex2jar/, cfr/)
        ├── notes/           # README, fingerprints, patch-plan (core) + optional tooling, data-flow, etc.
        ├── artifacts/       # Dumps, payloads, screenshots
        └── tmp/             # Scratch data (safe to wipe)
```

> **Navigation tip**: keep humans in `README.md`, automation context here, Claude specifics in `CLAUDE.md`, toolkit references under `docs/`, and per-app runbooks inside `apps/<package>/<version>/notes/`.

> **Naming conventions**
> - `<app-id>`: lowercase, hyphenated package nickname (match ReVanced module if possible).
> - `<version>`: raw version string from APK metadata. If multiple channels exist (beta/dev), append `-beta`, `-dev`, etc.
> - Store alternate architectures under the same version (e.g., `apk/tiktok-arm64-v8a.apk`).

When starting a new investigation, copy the template structure with:
```
mkdir -p apps/<package>/<version>/{apk,decode/{apktool,jadx,dex2jar,cfr},notes,artifacts,tmp}
cp docs/templates/*.md apps/<package>/<version>/notes/
```

## Tooling Baseline

- `apktool` — decodes resources and smali; run with larger heap for multi-dex apps (`apktool -JXmx4g d <apk>`).
- `jadx` — decompiles dex to Java/Kotlin; supports CLI or GUI. Use `--threads-count 4` and `--deobf` when stable, and capture crash logs/heap metrics if it fails.
- `dex2jar / d2j-*` — converts dex ↔ jar, plus auxiliary scripts (smali, baksmali, checksum recalcs).
- `cfr` — Java bytecode decompiler for JARs; compare against `jadx` when control flow looks suspicious.
- `rg`, `fd` — fast textual search for strings, class names, or opcodes across smali and resources.
- `adb` — deploys builds to emulator/device, collects `logcat`, pulls files, triggers intents.
- `frida` (optional) — runtime instrumentation for method tracing or payload inspection.
- `jq`, `protoc`, custom scripts — parse JSON/Protobuf payloads when analyzing network traffic or serialized data.
- **Java 17+** — required by ReVanced build system; ensure matches repo expectations.

Tips:
- Keep **heap-friendly** use of tools: `jadx` can OOM on gigantic APKs—split dex, lower thread counts, or process critical packages individually.
- For `dex2jar`, favor per-dex conversion when full-apk runs exhaust heap; bump `D2J_JAVA_OPTS` and stash outputs in `decode/dex2jar/`.
- Measure decode/decompile runs (`time`, RSS) and log results in `apps/<package>/<version>/notes/tooling.md` for future diffing.
- Record CFR command lines, JVM flags, runtimes, and warnings in the same tooling log for reproducibility.
- Whenever `apktool` fails due to framework resources, install matching `framework-res.apk` into `~/.local/share/apktool/framework/`.
- For reproducibility, pin tool versions and CLI options in `apps/<package>/<version>/notes/tooling.md` and commit mapping files if generated.
- **For JADX GC crashes**, see `docs/JVM_GC_TROUBLESHOOTING.md` for detailed diagnosis and recovery strategies.

---

## Generic Workflow

1. **Acquire APK**: Store pristine copy (keep hash). If patched variants exist, save them separately.
2. **Decode resources**: `apktool -JXmx4g d <apk> -o apktool/ -f`. Verify `AndroidManifest.xml`, `res/`, and `smali*/`.
3. **Decompile bytecode**: `jadx --threads-count 4 -d jadx/ <apk>` (add `--deobf` if names are obfuscated). Capture runtime stats (wall/user/sys, peak RSS) and keep crash logs.
4. **Convert dex to JARs**: run `d2j-dex2jar` (per-dex if needed) and stash results in `decode/dex2jar/`. Note heap flags and warnings.
5. **Optional CFR pass**: `cfr decode/dex2jar/classesX.jar --outputdir decode/cfr/classesX` when `jadx` output is unclear or needs validation.
6. **Reconnaissance**:
   - Enumerate entry points from `AndroidManifest.xml` (activities, services, receivers) and map to target features.
   - Build a high-level class/resource graph: key packages, smali splits, resource IDs via `res/values/public.xml`.
   - Resolve or pin deobfuscation mappings (JADx `mapping.txt`, custom symbol tables).
   - Deep search for target strings, API endpoints, or feature flags in `smali*/` and partial `jadx/` output using `rg`.
   - Map class hierarchies and singleton providers relevant to the feature.
7. **Bytecode analysis**:
   - Confirm control flow in smali for accuracy; `jadx` may misrepresent intents.
   - Document method descriptors (`Lcom/example/Class;->method(ILjava/lang/String;)V`) for fingerprinting.
   - Record register usage where patch injections will occur, note surrounding native calls/anti-tamper checks.
8. **Obfuscation & defenses**:
   - Catalogue naming patterns (`LX/`, Kotlin lambdas), native libraries, and protector modules (e.g., `libmetasec`, `libEncryptor`).
   - Note existing bypass strategies or hooks needed to keep patches functional.

9. **Runtime validation (optional)**:
   - Install on emulator, monitor `logcat`, simulate feature usage.
   - Hook suspicious methods with Frida to observe parameters/return values.
10. **Summarize findings**:
   - Update `apps/<package>/<version>/notes/fingerprints.md` with candidate matchers.
   - Draft patch plan in `apps/<package>/<version>/notes/patch-plan.md` detailing injection points and dependencies.
11. **Diff & determinism**: compare output manifests/smali against previous runs (`diff -ruN`, checksums) to flag unexpected drift.
12. **Feedback loop**: When patch implementation starts in repo, keep references here for quick lookup.

---

## Commit Style

Use **Conventional Commits** for consistency. One line only. Max 72 characters. No body.

### Format

```
<type>(<scope>): <imperative summary>
```

### Types

- `feat` — new feature
- `fix` — bug fix
- `docs` — documentation updates
- `style` — code style (formatting, missing semicolons, etc.)
- `refactor` — code refactoring without behavior change
- `perf` — performance improvement
- `test` — test additions or fixes
- `build` — build system changes
- `ci` — CI/CD configuration
- `chore` — dependency updates, housekeeping
- `revert` — revert previous commit

### Rules

- Lowercase type and scope
- No trailing period
- Use verbs in imperative: "add", "fix", "refactor", not "added", "fixed", "refactored"
- Keep total under 72 chars
- Group changes into the smallest logical commits
- One feature/fix per commit when possible

### Examples

```
feat(tiktok): add share link sanitizer
fix(apktool): handle framework resources gracefully
docs(agents): add commit style guidelines
refactor(fingerprints): simplify pattern matching
test(obfuscation): add detection tests
chore: update jadx to 1.5.2
ci(workflows): add reproducibility checks
```

### Breaking Changes

Mark with `!` before the colon (still one line):

```
feat(api)!: drop support for app versions <36.0.0
fix(decoder)!: change smali output format
```

---

## Per-App Playbooks

Keep universal guidance in this file and capture app- or feature-specific investigations under `apps/<package>/<version>/notes/`. Each target should have:

- `README.md` — current status, scope, and verification checkpoints
- `fingerprints.md` — bytecode fingerprints with FP naming states (FP-NEW, FP-00X, ARCHIVED)
- `patch-plan.md` — injection strategy (dependencies, risks, testing)
- Optional deep dives (`tooling.md`, `*-data-flow-analysis.md`, `*-phase-handoff.md`) when additional bytecode or runtime evidence is required

When a new investigation starts, clone the templates from `docs/templates/`, record the APK hash, and keep the notes self-contained so the universal guide remains lean.

---

## Operational Checklist Template

Use this runbook block when kicking off or reviewing a target. Populate the placeholders and paste into the per-app `notes/README.md` (or a dedicated runbook doc):

```
### Runbook: <target summary>
- Owner: <agent/contact>
- Prerequisites: <apk hash logged, tools verified, emulator ready, etc.>
- Tools: apktool ≥2.12, jadx ≥1.5, dex2jar (optional), frida (optional)

1. Prep workspace (`setup-workspace.sh <package> <version>`)
2. Verify inputs (`sha256sum apk/<file>.apk`, document in tooling.md)
3. Decode resources (`apktool -JXmx4g d ...`)
4. Decompile bytecode (`./scripts/run-jadx.sh ...`)
5. Capture metrics/logs (stash in `notes/tooling.md`, `artifacts/`)
6. Update fingerprints & patch plan (min. three candidate methods)
7. Validate behavior (emulator/device, logcat, optional Frida hooks)
8. Record open questions & blockers (phase handoff if needed)

- Success Criteria: <e.g., canonical URL extracted before shortening>
- Rollback / Cleanup: `./scripts/cleanup.sh`, remove `decode/` before reruns
- Escalation: <who to notify if tooling fails or behavior regresses>
```

---

## Automation & Documentation Aids

- **RepoSummary** or similar tools can generate status digests; attach them to `notes/research-status.md` so humans can skim progress.
- **DocAgent** outputs (flowcharts, state diagrams) should land in `artifacts/` with links from the per-app README.
- **VisDocSketcher** (or any quick diagramming tool) helps illustrate intricate control flow—convert to PNG/SVG and store in `artifacts/`.
- Log when automated insights diverge from manual findings so future agents know which source of truth to trust.

---

## Maintenance Cadence

- **Quarterly audit**: Validate tool versions, directory layout, and links in this guide against the repo.
- **Per-release check**: When a new app version is added, ensure templates are up to date and `.gitignore` still protects decode outputs.
- **Ownership**: The maintainer of `revanced-research` (or delegate) signs off on updates; note changes in the repo changelog or via Conventional Commit messages (`docs(agents): ...`).
