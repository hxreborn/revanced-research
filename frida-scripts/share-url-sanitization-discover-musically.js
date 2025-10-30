/**
 * Comprehensive Method Discovery for Musically Share Flow
 *
 * Purpose: Find ACTUAL methods called during share, not just assume X.aOp
 * Approach: Hook multiple layers and trace full call stack
 */

console.log("\n[*] === Musically Share Method Discovery ===");
console.log("[*] Target: com.zhiliaoapp.musically v36.5.4\n");

Java.perform(function() {
    console.log("[*] Java environment ready\n");

    // Strategy 1: Hook ALL methods in X.aOp class
    try {
        const aOp = Java.use("X.aOp");
        console.log("[+] X.aOp class found");

        const methods = aOp.class.getDeclaredMethods();
        console.log("[*] Total methods in X.aOp:", methods.length);

        // Hook EVERY method in the class
        for (let i = 0; i < methods.length; i++) {
            const method = methods[i];
            const methodName = method.getName();

            try {
                const overloads = aOp[methodName].overloads;

                overloads.forEach(function(overload, idx) {
                    overload.implementation = function() {
                        console.log("\n" + "▓".repeat(80));
                        console.log("[!!!] X.aOp." + methodName + " CALLED (overload " + idx + ")");
                        console.log("▓".repeat(80));
                        console.log("[*] Timestamp:", new Date().toISOString());
                        console.log("[*] Arguments:", arguments.length);

                        for (let j = 0; j < arguments.length; j++) {
                            try {
                                console.log("  [" + j + "]", arguments[j]);
                            } catch (e) {
                                console.log("  [" + j + "] <error reading arg>");
                            }
                        }

                        const result = overload.apply(this, arguments);

                        console.log("[*] Returned:", result);
                        console.log("▓".repeat(80) + "\n");

                        return result;
                    };
                });

                console.log("  [✓] Hooked:", methodName, "(" + overloads.length + " overloads)");
            } catch (e) {
                // Some methods might not be hookable
            }
        }

        console.log("[+] Hooked all X.aOp methods\n");

    } catch (e) {
        console.error("[!] Could not hook X.aOp:", e);
    }

    // Strategy 2: Hook ShareExtService implementation (IV4)
    try {
        const IV4 = Java.use("X.IV4");
        console.log("\n[+] X.IV4 class found");

        const methods = IV4.class.getDeclaredMethods();
        console.log("[*] Total methods in X.IV4:", methods.length);

        for (let i = 0; i < methods.length; i++) {
            const method = methods[i];
            const methodName = method.getName();

            try {
                const overloads = IV4[methodName].overloads;

                overloads.forEach(function(overload, idx) {
                    overload.implementation = function() {
                        console.log("\n[→→→] X.IV4." + methodName + " CALLED");
                        console.log("[*] Args:", Array.prototype.slice.call(arguments));

                        const result = overload.apply(this, arguments);
                        console.log("[*] Result:", result);

                        return result;
                    };
                });

                console.log("  [✓] Hooked:", methodName);
            } catch (e) {
                // Skip non-hookable methods
            }
        }

        console.log("[+] Hooked all X.IV4 methods\n");

    } catch (e) {
        console.error("[!] Could not hook X.IV4:", e);
    }

    // Strategy 3: Hook ShareExtServiceImpl
    try {
        const ShareExtServiceImpl = Java.use("com.ss.android.ugc.aweme.share.ShareExtServiceImpl");
        console.log("\n[+] ShareExtServiceImpl found");

        const methods = ShareExtServiceImpl.class.getDeclaredMethods();
        console.log("[*] Total methods:", methods.length);

        for (let i = 0; i < methods.length; i++) {
            const method = methods[i];
            const methodName = method.getName();

            try {
                const overloads = ShareExtServiceImpl[methodName].overloads;

                overloads.forEach(function(overload, idx) {
                    overload.implementation = function() {
                        console.log("\n[→→→] ShareExtServiceImpl." + methodName + " CALLED");
                        console.log("[*] Args:", Array.prototype.slice.call(arguments));

                        const result = overload.apply(this, arguments);
                        console.log("[*] Result:", result);

                        return result;
                    };
                });

                console.log("  [✓] Hooked:", methodName);
            } catch (e) {
                // Skip
            }
        }

        console.log("[+] Hooked all ShareExtServiceImpl methods\n");

    } catch (e) {
        console.error("[!] Could not hook ShareExtServiceImpl:", e);
    }

    // Strategy 4: Hook URL-related String methods but ONLY for TikTok URLs
    try {
        const String = Java.use("java.lang.String");

        // Hook indexOf
        const indexOfChar = String.indexOf.overload('int');
        indexOfChar.implementation = function(ch) {
            const str = this.toString();

            if (str.includes("tiktok.com") && ch === 63) {  // 63 = '?'
                console.log("\n[STRING] indexOf('?') on TikTok URL");
                console.log("  Input:", str);
                console.log("\n[STACK]");
                const Exception = Java.use("java.lang.Exception");
                const Log = Java.use("android.util.Log");
                console.log(Log.getStackTraceString(Exception.$new()));
            }

            return indexOfChar.call(this, ch);
        };

        console.log("[+] Hooked String.indexOf for TikTok URLs\n");

    } catch (e) {
        console.error("[!] Could not hook String:", e);
    }

    // Strategy 5: Trace Observable.just() calls
    try {
        // Try to find Observable classes used in Musically
        const aX5 = Java.use("X.aX5");
        console.log("\n[+] X.aX5 (Observable) found");

        const LJ = aX5.LJ;
        if (LJ) {
            const overloads = LJ.overloads;
            console.log("[*] X.aX5.LJ overloads:", overloads.length);

            overloads.forEach(function(overload, idx) {
                overload.implementation = function() {
                    console.log("\n[OBSERVABLE] X.aX5.LJ called");
                    console.log("[*] Creating Observable with value:", arguments[0]);

                    // Get stack trace to see WHO is creating this Observable
                    try {
                        const Exception = Java.use("java.lang.Exception");
                        const Log = Java.use("android.util.Log");
                        console.log("\n[STACK TRACE]");
                        console.log(Log.getStackTraceString(Exception.$new()));
                    } catch (e) {
                        console.log("[!] Could not get stack");
                    }

                    const result = overload.apply(this, arguments);
                    return result;
                };
            });

            console.log("[+] Hooked X.aX5.LJ (Observable factory)\n");
        }

    } catch (e) {
        console.error("[!] Could not hook X.aX5:", e);
    }

    // Strategy 6: Clipboard hook (keep this as confirmation)
    try {
        const ClipboardManager = Java.use("android.content.ClipboardManager");

        ClipboardManager.setPrimaryClip.overload('android.content.ClipData').implementation = function(clipData) {
            console.log("\n" + "█".repeat(80));
            console.log("[CLIPBOARD] Content copied!");
            console.log("█".repeat(80));

            try {
                if (clipData) {
                    const itemCount = clipData.getItemCount();
                    for (let i = 0; i < itemCount; i++) {
                        const item = clipData.getItemAt(i);
                        if (item) {
                            const text = item.getText();
                            if (text) {
                                const textStr = text.toString();
                                console.log("[" + i + "] Text:", textStr);

                                if (textStr.includes("tiktok.com")) {
                                    console.log("\n[★] TIKTOK URL DETECTED");
                                    console.log("[★] URL:", textStr);

                                    // Get stack trace to find caller
                                    try {
                                        const Exception = Java.use("java.lang.Exception");
                                        const Log = Java.use("android.util.Log");
                                        console.log("\n[CLIPBOARD STACK TRACE]");
                                        console.log(Log.getStackTraceString(Exception.$new()));
                                    } catch (e) {
                                        console.log("[!] Could not get stack");
                                    }
                                }
                            }
                        }
                    }
                }
            } catch (e) {
                console.log("[!] Error reading clipboard:", e);
            }

            console.log("█".repeat(80) + "\n");

            return this.setPrimaryClip(clipData);
        };

        console.log("[+] Hooked Android Clipboard with stack traces\n");

    } catch (e) {
        console.error("[!] Could not hook clipboard:", e);
    }

    console.log("\n" + "=".repeat(80));
    console.log("[*] ALL DISCOVERY HOOKS INSTALLED");
    console.log("[*] Waiting for share action...");
    console.log("=".repeat(80) + "\n");
});
