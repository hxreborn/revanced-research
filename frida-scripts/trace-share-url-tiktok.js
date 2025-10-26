/**
 * Frida Script: TikTok Share URL Tracing
 *
 * App: com.ss.android.ugc.trill (TikTok International) v36.5.4
 * Target: Share URL generation and parameter tracking
 *
 * Usage:
 *   frida -U -f com.ss.android.ugc.trill -l trace-share-url-tiktok.js --no-pause
 *
 * Description:
 *   Hooks the LIZLLL method in X.UEU class to trace:
 *   - Method parameters (item type, key, URL)
 *   - Generated share URLs
 *   - Tracking parameters added
 *   - Call stack for understanding invocation path
 */

Java.perform(function() {
    console.log("\n[*] TikTok Share URL Tracer Started");
    console.log("[*] Target: com.ss.android.ugc.trill v36.5.4");
    console.log("[*] Waiting for share action...\n");

    try {
        // Target class: X.UEU
        const UEU = Java.use("X.UEU");

        // Hook LIZLLL method - Main URL generation
        UEU.LIZLLL.overload('int', 'java.lang.String', 'java.lang.String', 'java.lang.String').implementation = function(i, str1, itemType, key) {
            console.log("\n" + "=".repeat(80));
            console.log("[+] LIZLLL METHOD CALLED");
            console.log("=".repeat(80));
            console.log("[*] Timestamp:", new Date().toISOString());

            // Log parameters
            console.log("\n[PARAMETERS]");
            console.log("  └─ Int param:", i);
            console.log("  └─ URL (str1):", str1);
            console.log("  └─ Item Type:", itemType);
            console.log("  └─ Key:", key);

            // Call original method
            console.log("\n[*] Calling original LIZLLL...");
            const result = this.LIZLLL(i, str1, itemType, key);

            // Log result
            console.log("\n[RESULT]");
            console.log("  └─ Return type:", result ? result.$className : "null");
            console.log("  └─ Return object:", result);

            // Try to extract URL from result if possible
            try {
                if (result) {
                    // The result is an Observable (Wu4), we'll trace its emissions
                    console.log("  └─ Observable returned (will emit URL asynchronously)");
                }
            } catch (e) {
                console.log("  └─ Could not extract URL from result:", e);
            }

            // Log call stack
            console.log("\n[CALL STACK]");
            console.log(Java.use("android.util.Log").getStackTraceString(Java.use("java.lang.Exception").$new()));

            console.log("=".repeat(80) + "\n");

            return result;
        };

        console.log("[+] Hooked: X.UEU.LIZLLL()");

        // Hook helper method LIZJ - String URL processing
        UEU.LIZJ.overload('int', 'java.lang.String', 'java.lang.String', 'java.lang.String').implementation = function(i, str, itemType, key) {
            console.log("\n[→] LIZJ (URL Processing) Called");
            console.log("    Input URL:", str);
            console.log("    Item Type:", itemType);
            console.log("    Key:", key);

            const result = this.LIZJ(i, str, itemType, key);

            console.log("    Output URL:", result);

            // Compare input and output to see what was added
            if (str !== result) {
                console.log("    [!] URL Modified!");
                const added = result.length - str.length;
                console.log("    [!] Bytes added:", added);

                // Try to identify tracking parameters
                if (result.includes("?") || result.includes("&")) {
                    console.log("    [!] Potential tracking params detected");

                    // Extract parameters
                    const params = result.split(/[?&]/);
                    console.log("    [!] Parameters:");
                    params.forEach(p => {
                        if (p && p.includes("=")) {
                            const [key, value] = p.split("=", 2);
                            // Highlight tracking parameters
                            if (key.startsWith("utm_") ||
                                key.startsWith("share_") ||
                                key.startsWith("sec_") ||
                                key === "enter_from" ||
                                key === "timestamp_ms") {
                                console.log("        └─ [TRACKING]", key, "=", value);
                            } else {
                                console.log("        └─", key, "=", value);
                            }
                        }
                    });
                }
            }

            return result;
        };

        console.log("[+] Hooked: X.UEU.LIZJ()");

        // Hook the URL Builder API (C48911HFi.LIZIZ.LJIILLIIL)
        try {
            const HFi = Java.use("X.HFi");
            const HFiInstance = HFi.LIZIZ.value;

            // This will need to be adjusted based on the actual class structure
            console.log("[*] Attempting to hook URL builder API...");
            console.log("[*] HFi.LIZIZ type:", HFiInstance ? HFiInstance.$className : "null");
        } catch (e) {
            console.log("[!] Could not hook URL builder API:", e);
        }

        // Hook LIZ method - URL building with Bundle
        UEU.LIZ.overload('android.os.Bundle', 'java.lang.String').implementation = function(bundle, str) {
            console.log("\n[→] LIZ (Bundle URL Builder) Called");
            console.log("    Base URL:", str);

            if (bundle) {
                console.log("    Bundle params:");
                const keys = bundle.keySet().toArray();
                for (let i = 0; i < keys.length; i++) {
                    const key = keys[i];
                    const value = bundle.getString(key);
                    console.log("      └─", key, "=", value);
                }
            }

            const result = this.LIZ(bundle, str);
            console.log("    Result URL:", result);

            return result;
        };

        console.log("[+] Hooked: X.UEU.LIZ()");

    } catch (e) {
        console.error("\n[!] Error setting up hooks:", e);
        console.error("[!] Stack trace:", e.stack);
    }
});

/**
 * Output Format Legend:
 *
 * [+] Successfully hooked method
 * [*] Information message
 * [→] Helper method called
 * [!] Important finding (URL modified, tracking detected)
 * [TRACKING] Identified tracking parameter
 *
 * Tracking Parameters to Watch:
 * - utm_* (UTM campaign tracking)
 * - share_* (Share attribution)
 * - sec_* (Security/session tokens)
 * - enter_from, enter_method (Navigation tracking)
 * - timestamp_ms (Timestamp tracking)
 */
