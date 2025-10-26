/**
 * Simple Toggle Diagnostic - Musically
 *
 * Traces:
 * 1. Sanitizer calls and return values
 * 2. Whether short URL API is reached
 * 3. Final clipboard URL
 */

Java.perform(function() {
    console.log("\n[*] Simple Toggle Tracer - Musically\n");

    // Hook sanitizer
    try {
        const Sanitizer = Java.use("app.revanced.extension.tiktok.share.ShareUrlSanitizer");

        Sanitizer.sanitizeShareUrl.implementation = function(url) {
            console.log("\n[SANITIZER] Called");
            console.log("  Input:", url);

            const result = this.sanitizeShareUrl(url);

            console.log("  Output:", result);
            console.log("  " + (result === null ? "NULL = Toggle OFF" : "Sanitized = Toggle ON"));

            return result;
        };

        console.log("[✓] Hooked sanitizer");
    } catch (e) {
        console.log("[!] No sanitizer found:", e.message);
    }

    // Hook short URL API
    try {
        const IV4 = Java.use("X.IV4");
        const api = IV4.LIZIZ.value;

        if (api && Java.use(api.$className).LJIIZILJ) {
            Java.use(api.$className).LJIIZILJ.overloads.forEach(function(overload) {
                overload.implementation = function() {
                    console.log("\n[SHORT_URL_API] Called - Original flow reached");
                    const result = overload.apply(this, arguments);
                    console.log("[SHORT_URL_API] Returned successfully");
                    return result;
                };
            });
            console.log("[✓] Hooked short URL API");
        }
    } catch (e) {
        console.log("[!] Could not hook API:", e.message);
    }

    // Hook clipboard
    try {
        Java.use("android.content.ClipboardManager").setPrimaryClip.overload('android.content.ClipData').implementation = function(clip) {
            if (clip && clip.getItemCount() > 0) {
                const text = clip.getItemAt(0).getText();
                if (text) {
                    const url = text.toString();
                    if (url.includes("tiktok")) {
                        console.log("\n[RESULT]", url);
                        console.log("  " + (url.includes("?") ? "Has params (toggle OFF or failed)" : "Clean (toggle ON)"));
                    }
                }
            }
            return this.setPrimaryClip(clip);
        };
        console.log("[✓] Hooked clipboard");
    } catch (e) {
        console.log("[!] No clipboard hook");
    }

    console.log("\n[*] Ready. Share a link now.\n");
});
