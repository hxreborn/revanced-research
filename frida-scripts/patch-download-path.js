/**
 * Patches TikTok download path at runtime by intercepting ContentValues
 * Target: TikTok 36.5.4 (Trill variant)
 *
 * Usage: frida -U $(adb shell pidof com.ss.android.ugc.trill) -l patch-download-path.js
 */

const CUSTOM_PATH = "DCIM/TikTok/";

console.log("[*] TikTok Download Path Patcher loaded");
console.log("[*] Target path: " + CUSTOM_PATH);

Java.perform(function() {
    const LBT = Java.use("X.LBT");
    const ContentValues = Java.use("android.content.ContentValues");
    const ContentResolver = Java.use("android.content.ContentResolver");

    // Strategy 1: Hook LBT.LJ and replace p3 parameter
    try {
        LBT.LJ.overload("android.content.Context", "java.lang.String", "java.lang.String", "java.lang.String").implementation = function(context, displayName, mimeType, relativePath) {
            console.log("\n[PATCH] LBT.LJ intercepted");
            console.log("  Original path: " + relativePath);

            // Replace with custom path
            const patchedPath = CUSTOM_PATH;
            console.log("  Patched path:  " + patchedPath);

            // Call original with modified parameter
            const result = this.LJ(context, displayName, mimeType, patchedPath);

            console.log("  Result Uri: " + result);
            return result;
        };
        console.log("[+] Patched LBT.LJ parameter");
    } catch (e) {
        console.log("[-] Failed to patch LBT.LJ: " + e);
    }

    // Strategy 2: Hook ContentValues.put to log and modify relative_path
    try {
        const putString = ContentValues.put.overload("java.lang.String", "java.lang.String");
        putString.implementation = function(key, value) {
            if (key === "relative_path") {
                console.log("\n[CONTENTVALUES] put(relative_path) intercepted");
                console.log("  Original: " + value);

                // Only modify if it's the TikTok download path
                if (value && (value.includes("DCIM/Camera") || value.includes("Camera/"))) {
                    const patched = CUSTOM_PATH;
                    console.log("  Patched:  " + patched);
                    return this.put(key, patched);
                }
            }
            return this.put(key, value);
        };
        console.log("[+] Patched ContentValues.put(String, String)");
    } catch (e) {
        console.log("[-] Failed to patch ContentValues: " + e);
    }

    // Strategy 3: Hook ContentResolver.insert to verify final values
    try {
        ContentResolver.insert.overload("android.net.Uri", "android.content.ContentValues").implementation = function(uri, values) {
            const uriStr = uri.toString();

            // Only log MediaStore video inserts
            if (uriStr.includes("video/media")) {
                console.log("\n[CONTENTRESOLVER] insert() called");
                console.log("  Uri: " + uriStr);

                // Extract and log ContentValues
                const relativePath = values.getAsString("relative_path");
                const displayName = values.getAsString("_display_name");
                const mimeType = values.getAsString("mime_type");

                console.log("  ContentValues:");
                console.log("    relative_path: " + relativePath);
                console.log("    _display_name: " + displayName);
                console.log("    mime_type:     " + mimeType);
            }

            return this.insert(uri, values);
        };
        console.log("[+] Hooked ContentResolver.insert for verification");
    } catch (e) {
        console.log("[-] Failed to hook ContentResolver.insert: " + e);
    }

    console.log("\n[*] All patches applied. Trigger a download to test.");
    console.log("[*] Expected: Downloads will go to /storage/emulated/0/" + CUSTOM_PATH);
});
