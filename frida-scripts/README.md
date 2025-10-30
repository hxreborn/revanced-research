# Frida Scripts - TikTok Research

Dynamic analysis scripts for reverse engineering and patch development.

---

## Connection Methods Reference

### Attach Mode (Recommended for Testing)

Connect to already-running process. Faster for iterative testing.

```bash
# By package name
frida -U -n <package> -l script.js

# By PID
adb shell pidof <package>
frida -U <PID> -l script.js
```

### Spawn Mode

Launch app from scratch, hooks installed before code execution.

```bash
frida -U -f <package> -l script.js
```

---

## Downloads Feature

- `downloads-lbt-trace.js` - Trace LBT.LIZLLL and LBT.LJ during downloads
- `downloads-trace.js` - Basic path tracing
- `downloads-trace-verbose.js` - Detailed inspection with call stack
- `downloads-contentvalues-trace.js` - ContentValues parameter inspection
- `downloads-patch.js` - Runtime path modification (pre-validation testing)

See: `apps/tiktok/downloads/README.md`

---

## Share URL Sanitization

- `share-url-tiktok-trace.js` - Trace UEU methods (Trill variant)
- `share-url-musically-trace.js` - Trace aOp methods (Musically variant)

See: `apps/tiktok/share-url-sanitization/README.md`

## Other

- `diagnose-toggle-issue-musically.js` - Toggle feature diagnostics
- `discover-musically-share-methods.js` - Share method discovery
- `simple-toggle-trace.js` - Basic toggle state tracing
- `setup-frida.sh` - Device setup script
- `compare-both-apps.sh` - Side-by-side app tracing

---

## Prerequisites

- Rooted Android device or debuggable APK
- frida-server running on device (match frida CLI version)
- Target APK installed

---

## References

- Feature docs: `../apps/tiktok/{share-url-sanitization,downloads}/README.md`
