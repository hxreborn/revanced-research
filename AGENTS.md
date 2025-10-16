# AGENTS

Ops manual for the revanced-research lab—the reverse engineering hub powering ReVanced patch development. Keep this document synchronized with the project so any agent can ramp quickly.

---

## Base Practices

- **Network boundaries**: All RE activity lives here, outside the `revanced-patches/` repo. Only push distilled fingerprints, bytecode offsets, or patch snippets back to the main project.
- **Single source of truth**: Maintain this playbook and shared templates; per-app findings belong under `targets/<package>/<version>/notes/`.
- **Version isolation**: Always nest target per app *and* version so multiple builds can be analyzed in parallel without collisions.
- **Lightweight provenance**: Track hashes of input APKs (`sha256sum`), tool versions, and key commands. Store them alongside notes for traceability.
- **Optional git**: If you want history inside `revanced-research/`, initialize a separate repository but avoid committing large decode outputs.
- **Determinism first**: Remove `decode/*` and `artifacts/*` before each run, record tool versions, and persist APK hashes to keep diffs meaningful.

---

## Directory Layout

````text
revanced-research/
├── AGENTS.md                # Reverse-engineering playbook
├── README.md                # Project overview
├── docs/
│   ├── templates/           # Note templates (journal/tooling/etc.)
│   └── targets/             # Target index & status docs
├── scripts/                 # Utility helpers (cleanup, tooling checks)
└── targets/
    └── <package>/           # e.g., tiktok, youtube
        └── <version>/       # e.g., 36.5.4, 19.15.34
            ├── apk/         # Pristine APKs (hashes logged)
            ├── decode/
            │   ├── apktool/ # `apktool d` output
            │   └── jadx/    # `jadx` export
            ├── notes/       # journal, fingerprints, patch plan, tooling
            ├── artifacts/   # Dumps, payloads, screenshots
            └── tmp/         # Scratch data (safe to wipe)
```

> **Naming conventions**
> - `<app-id>`: lowercase, hyphenated package nickname (match ReVanced module if possible).
> - `<version>`: raw version string from APK metadata. If multiple channels exist (beta/dev), append `-beta`, `-dev`, etc.
> - Store alternate architectures under the same version (e.g., `apk/tiktok-arm64-v8a.apk`).

When starting a new investigation, copy the template structure with:
```
mkdir -p targets/<package>/<version>/{apk,decode/{apktool,jadx},notes,artifacts,tmp}
cp docs/templates/*.md targets/<package>/<version>/notes/
```

## Tooling Baseline

- `apktool` — decodes resources and smali; run with larger heap for multi-dex apps (`apktool -JXmx4g d <apk>`).
- `jadx` — decompiles dex to Java/Kotlin; supports CLI or GUI. Use `--threads-count 4` and `--deobf` when stable, and capture crash logs/heap metrics if it fails.
- `dex2jar / d2j-*` — converts dex ↔ jar, plus auxiliary scripts (smali, baksmali, checksum recalcs).
- `rg`, `fd` — fast textual search for strings, class names, or opcodes across smali and resources.
- `adb` — deploys builds to emulator/device, collects `logcat`, pulls files, triggers intents.
- `frida` (optional) — runtime instrumentation for method tracing or payload inspection.
- `jq`, `protoc`, custom scripts — parse JSON/Protobuf payloads when analyzing network traffic or serialized data.
- **Java 17+** — required by ReVanced build system; ensure matches repo expectations.

Tips:
- Keep **heap-friendly** use of tools: `jadx` can OOM on gigantic APKs—split dex, lower thread counts, or process critical packages individually.
- Measure decode/decompile runs (`time`, RSS) and log results in `targets/<package>/<version>/notes/tooling.md` for future diffing.
- Whenever `apktool` fails due to framework resources, install matching `framework-res.apk` into `~/.local/share/apktool/framework/`.
- For reproducibility, pin tool versions and CLI options in `targets/<package>/<version>/notes/tooling.md` and commit mapping files if generated.

---

## Generic Workflow

1. **Acquire APK**: Store pristine copy (keep hash). If patched variants exist, save them separately.
2. **Decode resources**: `apktool -JXmx4g d <apk> -o apktool/ -f`. Verify `AndroidManifest.xml`, `res/`, and `smali*/`.
3. **Decompile bytecode**: `jadx --threads-count 4 -d jadx/ <apk>` (add `--deobf` if names are obfuscated). Capture runtime stats (wall/user/sys, peak RSS) and keep crash logs.
4. **Reconnaissance**:
   - Enumerate entry points from `AndroidManifest.xml` (activities, services, receivers) and map to target features.
   - Build a high-level class/resource graph: key packages, smali splits, resource IDs via `res/values/public.xml`.
   - Resolve or pin deobfuscation mappings (JADx `mapping.txt`, custom symbol tables).
   - Deep search for target strings, API endpoints, or feature flags in `smali*/` and partial `jadx/` output using `rg`.
   - Map class hierarchies and singleton providers relevant to the feature.
5. **Bytecode analysis**:
   - Confirm control flow in smali for accuracy; `jadx` may misrepresent intents.
   - Document method descriptors (`Lcom/example/Class;->method(ILjava/lang/String;)V`) for fingerprinting.
   - Record register usage where patch injections will occur, note surrounding native calls/anti-tamper checks.
6. **Obfuscation & defenses**:
   - Catalogue naming patterns (`LX/`, Kotlin lambdas), native libraries, and protector modules (e.g., `libmetasec`, `libEncryptor`).
   - Note existing bypass strategies or hooks needed to keep patches functional.

7. **Runtime validation (optional)**:
   - Install on emulator, monitor `logcat`, simulate feature usage.
   - Hook suspicious methods with Frida to observe parameters/return values.
8. **Summarize findings**:
   - Update `targets/<package>/<version>/notes/fingerprints.md` with candidate matchers.
   - Draft patch plan in `targets/<package>/<version>/notes/patch-plan.md` detailing injection points and dependencies.
9. **Diff & determinism**: compare output manifests/smali against previous runs (`diff -ruN`, checksums) to flag unexpected drift.
10. **Feedback loop**: When patch implementation starts in repo, keep references here for quick lookup.

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

---

## TikTok Share Sanitizer Focus (tiktok / 36.5.4)

### Objectives
- Identify the code path that builds outgoing share links (e.g., `ShareService`, `SharePackage`, or JSON payload constructors).
- Extract the method(s) responsible for populating tracking parameters (`_r`, `share_uid`, etc.) and the earliest point we can sanitize URLs.
- Determine if there is a centralized `LinkSanitizer` analog or if we need to introduce one via extension.

### Target Signals
- Strings/literals: look for `share_link`, `utm_campaign`, `share_copy`, `aweme_id`.
- Network endpoints: search for `api/share`, `v1/aweme/share/`.
- Data structures: TikTok uses protobuf-like builders; inspect classes under `com.bytedance.frameworks.core.*`, `com.ss.android.ugc.aweme.share`.

### Planned Steps
1. **apktool decode** → `targets/tiktok/36.5.4/decode/apktool/`
2. **jadx export** → `targets/tiktok/36.5.4/decode/jadx/`
3. **Initial grep**:
   - `rg "share_link" targets/tiktok/36.5.4/decode/apktool`
   - `rg "utm_" targets/tiktok/36.5.4/decode/apktool`
   - `rg "SharePackage" targets/tiktok/36.5.4/decode/apktool`
4. **Feature mapping**:
   - Track down the share flow entry (likely `ShareReportService`, `ShareDialog`, `ShareBundle`).
   - Document builder sequence and pinpoint the final method assembling the URL.
5. **Candidate patch strategy**:
   - Fingerprint method that yields raw URL before user sees/copies it.
   - Inject call to shared sanitizer (if available) or plan new extension hook under `extensions/tiktok/.../SanitizeSharingLinksPatch`.
   - Record dependencies (e.g., ensure patch runs after any share UI modifications).

### Notes to Capture
- Compatible TikTok versions and observed hashes.
- Any dynamic feature flags gating the share functionality.
- Potential side effects (e.g., if sanitized URL breaks QR codes or deep links).

---

## Checklist (Running)
- [ ] Run `apktool -JXmx4g d … -o decode/apktool/`
- [ ] Run `jadx --threads-count 4 -d decode/jadx/ …`
- [ ] Populate `targets/<package>/<version>/notes/fingerprints.md` with 3+ candidate methods
- [ ] Validate link builder via emulator/Frida (optional)
- [ ] Outline patch execution plan
