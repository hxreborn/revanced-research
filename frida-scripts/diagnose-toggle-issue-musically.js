/**
 * Diagnostic Frida Script: Musically Toggle Issue
 *
 * App: com.zhiliaoapp.musically v36.5.4
 * Purpose: Diagnose "network unstable" error when sanitization toggle is OFF
 *
 * Usage:
 *   frida -U -f com.zhiliaoapp.musically -l diagnose-toggle-issue-musically.js --no-pause
 */

Java.perform(function() {
    console.log("\n[*] === Musically Toggle Diagnostic ===");
    console.log("[*] Tracing sanitization flow and short URL API calls\n");

    // Hook X.aOp.LIZLLL - Main URL generation method
    try {
        const aOp = Java.use("X.aOp");

        aOp.LIZLLL.overload('int', 'java.lang.String', 'java.lang.String', 'java.lang.String').implementation = function(i, str1, itemType, key) {
            console.log("\n" + "=".repeat(80));
            console.log("[LIZLLL] Main URL generation method called");
            console.log("=".repeat(80));
            console.log("[*] Timestamp:", new Date().toISOString());
            console.log("[*] Parameters:");
            console.log("    int:", i);
            console.log("    URL:", str1);
            console.log("    itemType:", itemType);
            console.log("    key:", key);

            try {
                // Call original
                console.log("\n[*] Calling original LIZLLL...");
                const result = this.LIZLLL(i, str1, itemType, key);

                console.log("[*] Result returned");
                if (result) {
                    console.log("    Type:", result.$className);

                    // Try to inspect Observable
                    try {
                        console.log("    Observable returned - will emit URL asynchronously");
                    } catch (e) {
                        console.log("    Could not inspect Observable:", e);
                    }
                } else {
                    console.log("    NULL result - THIS MIGHT BE THE ISSUE!");
                }

                console.log("=".repeat(80) + "\n");
                return result;

            } catch (e) {
                console.log("\n[!!!] EXCEPTION in LIZLLL:");
                console.log("    Message:", e.message);
                console.log("    Stack:", e.stack);
                console.log("=".repeat(80) + "\n");
                throw e;
            }
        };

        console.log("[✓] Hooked X.aOp.LIZLLL");

    } catch (e) {
        console.error("[!] Could not hook X.aOp:", e);
    }

    // Hook the short URL API - X.IV4.LIZIZ.LJIIZILJ
    try {
        const IV4 = Java.use("X.IV4");
        console.log("[*] X.IV4 class found");

        // Get the LIZIZ singleton instance
        const lizizInstance = IV4.LIZIZ.value;
        if (lizizInstance) {
            console.log("[✓] Got X.IV4.LIZIZ instance:", lizizInstance.$className);

            // Hook LJIIZILJ method - the short URL API
            const instanceClass = Java.use(lizizInstance.$className);

            if (instanceClass.LJIIZILJ) {
                const overloads = instanceClass.LJIIZILJ.overloads;
                console.log("[*] LJIIZILJ overloads:", overloads.length);

                overloads.forEach(function(overload, idx) {
                    overload.implementation = function() {
                        console.log("\n" + ">>>".repeat(26));
                        console.log("[SHORT_URL_API] LJIIZILJ called - Overload " + idx);
                        console.log(">>>".repeat(26));
                        console.log("[*] This should be called when toggle is OFF");
                        console.log("[*] If not called, the original API flow is broken");

                        console.log("\n[*] Arguments:");
                        for (let i = 0; i < arguments.length; i++) {
                            const arg = arguments[i];
                            if (arg === null || arg === undefined) {
                                console.log("    [" + i + "] null/undefined");
                            } else if (typeof arg === 'string') {
                                console.log("    [" + i + "] String:", arg);
                            } else if (typeof arg === 'number') {
                                console.log("    [" + i + "] Number:", arg);
                            } else {
                                try {
                                    console.log("    [" + i + "]", arg.$className);
                                } catch (e) {
                                    console.log("    [" + i + "] unknown type");
                                }
                            }
                        }

                        try {
                            console.log("\n[*] Calling original short URL API...");
                            const result = overload.apply(this, arguments);

                            console.log("[*] Short URL API returned successfully");
                            if (result) {
                                console.log("    Type:", result.$className);
                            } else {
                                console.log("    NULL result");
                            }

                            console.log("<<<".repeat(26) + "\n");
                            return result;

                        } catch (e) {
                            console.log("\n[!!!] EXCEPTION in short URL API:");
                            console.log("    Message:", e.message);
                            console.log("    Stack:", e.stack);
                            console.log("<<<".repeat(26) + "\n");
                            throw e;
                        }
                    };
                });

                console.log("[✓] Hooked short URL API (LJIIZILJ)");
            }
        }

    } catch (e) {
        console.error("[!] Could not hook short URL API:", e);
    }

    // Hook ReVanced settings/preferences to see toggle state
    try {
        const Settings = Java.use("app.revanced.extension.tiktok.settings.Settings");
        console.log("[✓] ReVanced Settings class found");

        // Look for sanitize share URLs setting
        if (Settings.SANITIZE_SHARE_URLS) {
            const originalGet = Settings.SANITIZE_SHARE_URLS.get;
            Settings.SANITIZE_SHARE_URLS.get = function() {
                const value = originalGet.call(this);
                console.log("\n[TOGGLE_STATE] SANITIZE_SHARE_URLS =", value);
                return value;
            };
            console.log("[✓] Hooked toggle state getter");
        }

    } catch (e) {
        console.log("[!] Could not hook ReVanced settings:", e.message);
        console.log("[*] Toggle might be in different location");
    }

    // Hook Toast to catch error messages
    try {
        const Toast = Java.use("android.widget.Toast");

        Toast.makeText.overload('android.content.Context', 'java.lang.CharSequence', 'int').implementation = function(context, text, duration) {
            const textStr = text.toString();

            if (textStr.toLowerCase().includes("network") ||
                textStr.toLowerCase().includes("unstable")) {
                console.log("\n" + "!!!".repeat(26));
                console.log("[ERROR_TOAST] Network error message displayed:");
                console.log("    Message:", textStr);
                console.log("    Context:", context);

                // Get stack trace
                try {
                    const Exception = Java.use("java.lang.Exception");
                    const Log = Java.use("android.util.Log");
                    console.log("\n[STACK_TRACE]");
                    console.log(Log.getStackTraceString(Exception.$new()));
                } catch (e) {
                    console.log("Could not get stack trace");
                }

                console.log("!!!".repeat(26) + "\n");
            }

            return this.makeText(context, text, duration);
        };

        console.log("[✓] Hooked Toast messages");

    } catch (e) {
        console.error("[!] Could not hook Toast:", e);
    }

    // Hook clipboard to see final result
    try {
        const ClipboardManager = Java.use("android.content.ClipboardManager");

        ClipboardManager.setPrimaryClip.overload('android.content.ClipData').implementation = function(clipData) {
            console.log("\n" + "▼".repeat(40));
            console.log("[CLIPBOARD] Final shared URL:");
            console.log("▼".repeat(40));

            if (clipData && clipData.getItemCount() > 0) {
                const item = clipData.getItemAt(0);
                const text = item.getText();
                if (text) {
                    const url = text.toString();
                    console.log("[*] URL:", url);
                    console.log("[*] Length:", url.length, "chars");

                    if (url.includes("?")) {
                        console.log("[*] Contains query params - toggle might be OFF");
                    } else {
                        console.log("[*] No query params - sanitization applied (toggle ON)");
                    }

                    if (url.includes("vm.tiktok") || url.includes("vt.tiktok")) {
                        console.log("[*] Short URL format - original API was used");
                    } else {
                        console.log("[*] Canonical URL format");
                    }
                }
            }

            console.log("▲".repeat(40) + "\n");
            return this.setPrimaryClip(clipData);
        };

        console.log("[✓] Hooked clipboard");

    } catch (e) {
        console.error("[!] Could not hook clipboard:", e);
    }

    console.log("\n" + "=".repeat(80));
    console.log("ALL HOOKS ACTIVE - Waiting for share action...");
    console.log("=".repeat(80));
    console.log("\nExpected flow when toggle is OFF:");
    console.log("  1. [LIZLLL] called");
    console.log("  2. [TOGGLE_STATE] shows false");
    console.log("  3. [SHORT_URL_API] called (LJIIZILJ)");
    console.log("  4. [CLIPBOARD] short URL or canonical with params");
    console.log("\nIf step 3 is missing, that's your problem!");
    console.log("=".repeat(80) + "\n");
});
