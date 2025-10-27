/**
 * Frida script to trace TikTok download path logic
 *
 * Usage (if app is already running):
 *   frida -U com.zhiliaoapp.musically -l trace-download.js
 *
 * Usage (spawn app):
 *   frida -U -f com.zhiliaoapp.musically -l trace-download.js
 *   (then resume in Frida console)
 */

Java.perform(function() {
    console.log("[*] TikTok Download Path Tracer Started");
    console.log("[*] Trigger a download in the app to see the trace");
    console.log("=".repeat(60));

    // Hook the suspected MediaStore method
    try {
        var Kjb = Java.use("X.Kjb");
        Kjb.LJJIIJ.overload('android.content.Context', 'java.lang.String', 'java.lang.String', 'boolean', 'java.lang.String', 'java.lang.String', 'int').implementation = function(ctx, p1, p2, p3, p4, p5, p6) {
            console.log("\n[Kjb.LJJIIJ] CALLED - MediaStore path method");
            console.log("  Context: " + ctx);
            console.log("  Param1: " + p1);
            console.log("  Param2: " + p2);
            console.log("  Param3: " + p3);
            console.log("  Param4: " + p4);
            console.log("  Param5: " + p5);
            console.log("  Param6: " + p6);

            var result = this.LJJIIJ(ctx, p1, p2, p3, p4, p5, p6);
            console.log("  Result URI: " + result);
            console.log("  Stack trace:");
            console.log(Java.use("android.util.Log").getStackTraceString(Java.use("java.lang.Exception").$new()));

            return result;
        };
        console.log("[+] Hooked X.Kjb.LJJIIJ (MediaStore method)");
    } catch(e) {
        console.log("[-] Failed to hook X.Kjb.LJJIIJ: " + e);
    }

    // Hook getExternalFilesDir to find app-specific storage usage
    try {
        var Context = Java.use("android.content.Context");
        Context.getExternalFilesDir.overload('java.lang.String').implementation = function(type) {
            var result = this.getExternalFilesDir(type);
            console.log("\n[Context.getExternalFilesDir] CALLED - App-specific storage");
            console.log("  Type: " + type);
            console.log("  Result: " + result);
            console.log("  Stack trace:");
            console.log(Java.use("android.util.Log").getStackTraceString(Java.use("java.lang.Exception").$new()));

            return result;
        };
        console.log("[+] Hooked Context.getExternalFilesDir");
    } catch(e) {
        console.log("[-] Failed to hook getExternalFilesDir: " + e);
    }

    // Hook File constructor to see where files are being created
    try {
        var File = Java.use("java.io.File");
        var FileInit = File.$init.overload('java.lang.String');
        FileInit.implementation = function(path) {
            if (path && (path.indexOf("TikTok") >= 0 || path.indexOf("Camera") >= 0 || path.indexOf("share") >= 0 || path.indexOf("download") >= 0)) {
                console.log("\n[File.<init>] Creating file with download-related path:");
                console.log("  Path: " + path);
            }
            return FileInit.call(this, path);
        };
        console.log("[+] Hooked File constructor");
    } catch(e) {
        console.log("[-] Failed to hook File: " + e);
    }

    // Hook MediaStore ContentValues to see what's being inserted
    try {
        var ContentValues = Java.use("android.content.ContentValues");
        ContentValues.put.overload('java.lang.String', 'java.lang.String').implementation = function(key, value) {
            if (key === "relative_path" || key === "_display_name" || key === "title") {
                console.log("\n[ContentValues.put] Setting MediaStore value:");
                console.log("  Key: " + key);
                console.log("  Value: " + value);
            }
            return this.put(key, value);
        };
        console.log("[+] Hooked ContentValues.put");
    } catch(e) {
        console.log("[-] Failed to hook ContentValues: " + e);
    }

    console.log("\n[*] All hooks installed. Trigger a download now!");
    console.log("=".repeat(60));
});
