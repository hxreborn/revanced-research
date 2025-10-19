# Repository Guidelines

## Project Structure & Module Organization
The `apps/<app>/<version>/` tree is your sandbox for reverse-engineering: store APKs, Jadx and smali outputs, injection notes, logs, and experimental builds there so each attempt stays reproducible. Upstream sources live in `revanced-src/`; the `revanced-patches` submodule is a Gradle multi-module project where `patches/` defines metadata and common utilities, while `extensions/<app>/` contains the Android libraries that ship patch logic per host app (manifest, Java/Kotlin sources, and optional stubs). Keep shared tooling like `revanced-cli.jar` in place.

## Build, Test, and Development Commands
- `cd revanced-src/revanced-patches && ./gradlew :patches:assemble` — compiles every patch bundle and validates project wiring.
- `./gradlew :extensions:youtube:assembleRelease` (swap the extension) — builds a specific integration APK for smoke-testing.
- `./gradlew lint ktlintCheck` — runs static analysis; fix violations before opening a PR.
- `java -jar ../../revanced-cli.jar patch -m patches.json -a ../../apps/<app>/<version>/base.apk` — local verification of a patch set.

## Coding Style & Naming Conventions
Kotlin and Java sources use the official Kotlin code style with ktlint (`.editorconfig` enforces IntelliJ defaults and allows wildcard imports where needed). Prefer 4-space indentation, camelCase members, and descriptive module IDs such as `app.revanced.extension.youtube.patches.HideShortsPatch`. Place new resources under `src/main/res` or `src/main/resources/addresources` to match existing layouts. Keep Gradle logic in Kotlin DSL files (`build.gradle.kts`) and reuse helper functions from `extensions/shared` instead of duplicating bytecode operations.

## Testing Guidelines
Every new patch must compile (`./gradlew :patches:compileKotlin`) and ship without warnings. Add regression tests under `src/test/java` or `src/test/kotlin` when logic can be unit-tested; otherwise document manual validation steps in the corresponding `apps/<app>/<version>/logs/` entry. When targeting obfuscated classes, capture before/after smali snippets in `obfuscation-map.md` and re-run the CLI patch command against the recorded APK to confirm behavior.

## Commit & Pull Request Guidelines
Follow the established Conventional Commit pattern (`type(scope): summary`), e.g. `fix(X / Twitter): avoid null stream crash`. Branch from `dev`, reference related issues in the description, and include screenshots or log excerpts if UI behavior changes. PRs should link to updated research artifacts (attempt history, injection notes) and state which APK build was used for validation. Run the full Gradle lint suite before pushing; CI expects clean formatting and passing assemblies.

## Security & Configuration Tips
Never commit proprietary APKs—keep `apps/**/base.apk` gitignored and share checksums only. Store tokens for GitHub Packages (`GITHUB_ACTOR` / `GITHUB_TOKEN`) in your shell profile before invoking publish tasks. When exchanging research outputs, scrub personal device identifiers from logs and crash reports.
