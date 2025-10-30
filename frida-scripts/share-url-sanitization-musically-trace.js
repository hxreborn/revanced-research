/**
 * Safe Frida Script: Musically Share URL Tracing (Non-Crashing)
 *
 * App: com.zhiliaoapp.musically v36.5.4
 * Fixes: Removed aggressive String hooks that caused crashes
 * Added: Clipboard monitoring to catch actual shared URLs
 */

console.log("\n[*] === Musically Safe Share URL Tracer ===");
console.log("[*] Target: com.zhiliaoapp.musically v36.5.4\n");

Java.perform(function() {
    console.log("[*] Java environment ready");

    try {
        // Hook X.aOp methods
        const aOp = Java.use("X.aOp");
        console.log("[✓] X.aOp class found");

        // Hook LIZLLL - Main URL generation (Observable)
        if (aOp.LIZLLL) {
            const lizlllOverloads = aOp.LIZLLL.overloads;
            console.log("[*] LIZLLL overloads:", lizlllOverloads.length);

            lizlllOverloads.forEach(function(overload, idx) {
                overload.implementation = function() {
                    console.log("\n" + "=".repeat(80));
                    console.log("[!!!] LIZLLL CALLED - Overload " + idx);
                    console.log("=".repeat(80));
                    console.log("[*] Timestamp:", new Date().toISOString());

                    try {
                        console.log("[*] Arguments:");
                        for (let i = 0; i < arguments.length; i++) {
                            const arg = arguments[i];
                            if (arg === null || arg === undefined) {
                                console.log("  [" + i + "] null/undefined");
                            } else if (typeof arg === 'string') {
                                console.log("  [" + i + "] String: " + arg);
                            } else if (typeof arg === 'number') {
                                console.log("  [" + i + "] Number: " + arg);
                            } else {
                                try {
                                    console.log("  [" + i + "] " + arg.$className + ": " + arg);
                                } catch (e) {
                                    console.log("  [" + i + "] " + typeof arg);
                                }
                            }
                        }

                        console.log("\n[*] Calling original method...");
                        const result = overload.apply(this, arguments);

                        console.log("[*] Result returned");
                        if (result) {
                            try {
                                console.log("  └─ Type:", result.$className || typeof result);
                                console.log("  └─ Value:", result);
                            } catch (e) {
                                console.log("  └─ Result exists but couldn't log details");
                            }
                        } else {
                            console.log("  └─ null/undefined");
                        }

                        console.log("\n[STACK TRACE]");
                        try {
                            const Exception = Java.use("java.lang.Exception");
                            const Log = Java.use("android.util.Log");
                            console.log(Log.getStackTraceString(Exception.$new()));
                        } catch (e) {
                            console.log("Could not get stack trace");
                        }

                        console.log("=".repeat(80) + "\n");

                        return result;

                    } catch (e) {
                        console.log("[!] Error in LIZLLL hook:", e);
                        console.log("[*] Calling original anyway...");
                        return overload.apply(this, arguments);
                    }
                };
            });

            console.log("[✓] Hooked LIZLLL");
        }

        // Hook LIZJ - String URL processing
        if (aOp.LIZJ) {
            const lizjOverloads = aOp.LIZJ.overloads;
            console.log("[*] LIZJ overloads:", lizjOverloads.length);

            lizjOverloads.forEach(function(overload, idx) {
                overload.implementation = function() {
                    console.log("\n[→] LIZJ Called - Overload " + idx);

                    try {
                        for (let i = 0; i < arguments.length; i++) {
                            if (typeof arguments[i] === 'string') {
                                console.log("    [" + i + "] " + arguments[i]);
                            } else {
                                console.log("    [" + i + "] " + typeof arguments[i] + ": " + arguments[i]);
                            }
                        }

                        const result = overload.apply(this, arguments);
                        console.log("    Result:", result);

                        return result;
                    } catch (e) {
                        console.log("    [!] Error:", e);
                        return overload.apply(this, arguments);
                    }
                };
            });

            console.log("[✓] Hooked LIZJ");
        }

        // Hook LIZ - Bundle URL builder
        if (aOp.LIZ) {
            const lizOverloads = aOp.LIZ.overloads;
            console.log("[*] LIZ overloads:", lizOverloads.length);

            lizOverloads.forEach(function(overload, idx) {
                overload.implementation = function() {
                    console.log("\n[→] LIZ Called - Overload " + idx);

                    try {
                        for (let i = 0; i < arguments.length; i++) {
                            const arg = arguments[i];
                            if (typeof arg === 'string') {
                                console.log("    Base URL:", arg);
                            } else if (arg && arg.$className && arg.$className.includes("Bundle")) {
                                console.log("    Bundle provided");
                                try {
                                    const keys = arg.keySet().toArray();
                                    console.log("    Bundle keys:", keys.length);
                                    for (let j = 0; j < Math.min(keys.length, 5); j++) {
                                        const key = keys[j];
                                        const value = arg.getString(key);
                                        console.log("      " + key + " = " + value);
                                    }
                                } catch (e) {
                                    console.log("    Could not enumerate bundle");
                                }
                            }
                        }

                        const result = overload.apply(this, arguments);
                        console.log("    Result:", result);

                        return result;
                    } catch (e) {
                        console.log("    [!] Error:", e);
                        return overload.apply(this, arguments);
                    }
                };
            });

            console.log("[✓] Hooked LIZ");
        }

    } catch (e) {
        console.error("[!] Error setting up X.aOp hooks:", e);
    }

    // Hook Android Clipboard to catch actual shared URLs
    try {
        const ClipboardManager = Java.use("android.content.ClipboardManager");
        const ClipData = Java.use("android.content.ClipData");

        ClipboardManager.setPrimaryClip.overload('android.content.ClipData').implementation = function(clipData) {
            console.log("\n" + "▼".repeat(80));
            console.log("[CLIPBOARD] Content copied!");
            console.log("▼".repeat(80));

            try {
                if (clipData) {
                    const itemCount = clipData.getItemCount();
                    console.log("[*] Items in clipboard:", itemCount);

                    for (let i = 0; i < itemCount; i++) {
                        const item = clipData.getItemAt(i);
                        if (item) {
                            const text = item.getText();
                            if (text) {
                                const textStr = text.toString();
                                console.log("[" + i + "] Text:", textStr);

                                // Check if it's a TikTok URL
                                if (textStr.includes("tiktok.com") || textStr.includes("vm.tiktok") || textStr.includes("vt.tiktok")) {
                                    console.log("\n[★★★] TIKTOK URL DETECTED:");
                                    console.log("     " + textStr);
                                    console.log("     Length:", textStr.length, "chars");

                                    // Analyze URL structure
                                    if (textStr.includes("?")) {
                                        const parts = textStr.split("?");
                                        console.log("     Base:", parts[0]);
                                        console.log("     Params:", parts[1]);
                                    } else {
                                        console.log("     No query parameters (short URL or clean)");
                                    }
                                }
                            }
                        }
                    }
                }
            } catch (e) {
                console.log("[!] Error reading clipboard:", e);
            }

            console.log("▲".repeat(80) + "\n");

            return this.setPrimaryClip(clipData);
        };

        console.log("[✓] Hooked Android Clipboard");

    } catch (e) {
        console.error("[!] Could not hook clipboard:", e);
    }

    console.log("\n[*] ========================================");
    console.log("[*] ALL HOOKS ACTIVE");
    console.log("[*] Waiting for share actions...");
    console.log("[*] ========================================\n");

});
