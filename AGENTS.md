# AGENTS

Ops manual for the revanced-research lab—the reverse engineering hub powering ReVanced patch development. Keep this document synchronized with the project so any agent can ramp quickly.

---

## Base Practices

- **Network boundaries**: All RE activity lives here, outside the `revanced-patches/` repo. Only push distilled fingerprints, bytecode offsets, or patch snippets back to the main project.
- **Single source of truth**: Maintain one AGENTS guide and shared templates; per-app findings belong under `apps/<app>/<version>/notes/`.
- **Version isolation**: Always nest workspace per app *and* version so multiple builds can be analyzed in parallel without collisions.
- **Lightweight provenance**: Track hashes of input APKs (`sha256sum`), tool versions, and key commands. Store them alongside notes for traceability.
- **Optional git**: If you want history inside `revanced-research/`, initialize a separate repository but avoid committing large decode outputs.

---

## Directory Layout

```
revanced-research/
├── AGENTS.md                    # This playbook
├── templates/                   # Shared note/checklist templates
└── apps/
    └── <app-id>/                # e.g., "tiktok", "youtube"
        └── <version>/           # e.g., "36.5.4", "19.15.34"
            ├── apk/             # Pristine & derived APKs (keep hashes)
            ├── decode/
            │   ├── apktool/     # `apktool d` output
            │   └── jadx/        # `jadx` export
            ├── notes/
            │   ├── journal.md   # Running log, decisions
            │   ├── fingerprints.md
            │   ├── patch-plan.md
            │   └── tooling.md   # CLI flags, tool versions
            ├── artifacts/       # Payload dumps, screenshots, logs
            ├── scripts/         # Ad-hoc helpers (python/js/etc.)
            └── tmp/             # Throwaway scratch (safe to wipe)
```

> **Naming conventions**
> - `<app-id>`: lowercase, hyphenated package nickname (match ReVanced module if possible).
> - `<version>`: raw version string from APK metadata. If multiple channels exist (beta/dev), append `-beta`, `-dev`, etc.
> - Store alternate architectures under the same version (e.g., `apk/tiktok-arm64-v8a.apk`).

When starting a new investigation, copy the template structure with:
```
mkdir -p apps/<app-id>/<version>/{apk,decode/{apktool,jadx},notes,scripts,artifacts,tmp}
cp templates/{journal.md,fingerprints.md,patch-plan.md,tooling.md} apps/<app-id>/<version>/notes/
```

## Tooling Baseline

- `apktool` — decodes resources and smali; run with larger heap for multi-dex apps (`apktool -JXmx4g d <apk>`).
- `jadx` — decompiles dex to Java/Kotlin; supports CLI or GUI. Use `--threads-count 4` and `--deobf` for readability when stable.
- `dex2jar / d2j-*` — converts dex ↔ jar, plus auxiliary scripts (smali, baksmali, checksum recalcs).
- `rg`, `fd` — fast textual search for strings, class names, or opcodes across smali and resources.
- `adb` — deploys builds to emulator/device, collects `logcat`, pulls files, triggers intents.
- `frida` (optional) — runtime instrumentation for method tracing or payload inspection.
- `jq`, `protoc`, custom scripts — parse JSON/Protobuf payloads when analyzing network traffic or serialized data.
- **Java 17+** — required by ReVanced build system; ensure matches repo expectations.

Tips:
- Keep **heap-friendly** use of tools: `jadx` can OOM on gigantic APKs—split dex or limit threads if needed.
- Whenever `apktool` fails due to framework resources, install matching `framework-res.apk` into `~/.local/share/apktool/framework/`.
- For reproducibility, note exact tool versions and CLI options in `notes/tooling.md`.

---

## Generic Workflow

1. **Acquire APK**: Store pristine copy (keep hash). If patched variants exist, save them separately.
2. **Decode resources**: `apktool -JXmx4g d <apk> -o apktool/ -f`. Verify `AndroidManifest.xml`, `res/`, and `smali*/`.
3. **Decompile bytecode**: `jadx --threads-count 4 -d jadx/ <apk>` (add `--deobf` if names are obfuscated).
4. **Reconnaissance**:
   - Note entry points (activities, services) from manifest.
   - Search for target strings, API endpoints, or feature flags in `jadx/` or `smali*/` using `rg`.
   - Map class hierarchies and singleton providers relevant to the feature.
5. **Bytecode analysis**:
   - Confirm control flow in smali for accuracy; `jadx` may misrepresent intents.
   - Document method descriptors (`Lcom/example/Class;->method(ILjava/lang/String;)V`) for fingerprinting.
   - Record register usage where patch injections will occur.
6. **Runtime validation (optional)**:
   - Install on emulator, monitor `logcat`, simulate feature usage.
   - Hook suspicious methods with Frida to observe parameters/return values.
7. **Summarize findings**:
   - Update `notes/fingerprints.md` with candidate matchers.
   - Draft patch plan in `notes/patch-plan.md` detailing injection points and dependencies.
8. **Feedback loop**: When patch implementation starts in repo, keep references here for quick lookup.

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
1. **apktool decode** → `apps/tiktok/36.5.4/decode/apktool/`
2. **jadx export** → `apps/tiktok/36.5.4/decode/jadx/`
3. **Initial grep**:
   - `rg "share_link" -n apktool/smali*`
   - `rg "utm_" -n jadx/sources`
   - `rg "SharePackage" -n jadx/sources`
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
- [ ] Run `apktool -JXmx4g d … -o apktool/`
- [ ] Run `jadx --threads-count 4 -d jadx/ …`
- [ ] Populate `notes/fingerprints.md` with 3+ candidate methods
- [ ] Validate link builder via emulator/Frida (optional)
- [ ] Outline patch execution plan
