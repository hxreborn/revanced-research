/**
 * Traces X.LBT MediaStore download path methods
 * Target: TikTok 36.5.4 (Trill variant)
 *
 * Usage: frida -U $(adb shell pidof com.ss.android.ugc.trill) -l trace-lbt-methods.js
 */

console.log("[*] LBT Method Tracer loaded");

Java.perform(function() {
    const LBT = Java.use("X.LBT");

    // Hook LIZLLL(Context, String) -> Uri
    // Constructs DCIM/Camera/ path and calls LJ
    try {
        LBT.LIZLLL.overload("android.content.Context", "java.lang.String").implementation = function(context, filename) {
            console.log("\n[LBT.LIZLLL] Called");
            console.log("  Context: " + context);
            console.log("  Filename: " + filename);

            // Call original method
            const result = this.LIZLLL(context, filename);

            console.log("  Return Uri: " + result);
            console.log("  Stack trace:");
            console.log(Java.use("android.util.Log").getStackTraceString(Java.use("java.lang.Exception").$new()));

            return result;
        };
        console.log("[+] Hooked LBT.LIZLLL(Context, String)");
    } catch (e) {
        console.log("[-] Failed to hook LBT.LIZLLL: " + e);
    }

    // Hook LJ(Context, String, String, String) -> Uri
    // Parameter 4 (p3) is the relative_path value
    try {
        LBT.LJ.overload("android.content.Context", "java.lang.String", "java.lang.String", "java.lang.String").implementation = function(context, displayName, mimeType, relativePath) {
            console.log("\n[LBT.LJ] Called");
            console.log("  Context: " + context);
            console.log("  Display Name: " + displayName);
            console.log("  MIME Type: " + mimeType);
            console.log("  Relative Path: " + relativePath);
            console.log("  ^^^ THIS IS THE TARGET VALUE TO MODIFY ^^^");

            // Call original method
            const result = this.LJ(context, displayName, mimeType, relativePath);

            console.log("  Return Uri: " + result);

            return result;
        };
        console.log("[+] Hooked LBT.LJ(Context, String, String, String)");
    } catch (e) {
        console.log("[-] Failed to hook LBT.LJ: " + e);
    }

    console.log("\n[*] All hooks installed.");
});
