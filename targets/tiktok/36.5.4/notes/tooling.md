# Tooling & Environment

## Inputs
- APK: `apk/com.zhiliaoapp.musically_36.5.4-2base.apk`
- Hash: `sha256:b560a53fcea5246f03416556fead581cb49e37ff938c60ed10c8ec53defadb3c`

## Tool Versions
| Tool    | Version | Flags |
|---------|---------|-------|
| apktool | 2.12.1  | `-JXmx4g d` |
| jadx    | dev (build reports) | `--threads-count 4` (crashed), `--threads-count 1 --no-imports` (crashed) |
| d2j-dex2jar | 2.4 (reader/translator/ir) | _not executed yet_ |
| frida   | _not installed_ | |

## Commands Used
```
# Decode smali/resources (27.3 s real, 160.6 s user, 47.1 s sys)
apktool -JXmx4g d apk/com.zhiliaoapp.musically_36.5.4-2base.apk -o decode/apktool -f

# Attempted decompile (crashed with SIGSEGV, RSS ~14 GB)
jadx --threads-count 4 -d decode/jadx apk/com.zhiliaoapp.musically_36.5.4-2base.apk

# Retry with reduced parallelism (still crashed after ~280 s)
jadx --threads-count 1 --no-imports -d decode/jadx apk/com.zhiliaoapp.musically_36.5.4-2base.apk
```

## Notes
- JADx crashes leave partial output in `decode/jadx` and write `hs_err_pid1797451.log`; clean directory before retrying to avoid stale diffs.
- Consider running FernFlower via `d2j-dex2jar` for high-level views until a stable JADx configuration is identified.
- Future runs should set `TIMEFORMAT` or `/usr/bin/time` to capture wall/user/sys metrics plus RSS.
