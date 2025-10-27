// TikTok Download Path Tracer
// Comprehensive hooks to find the real download path method

Java.perform(function() {
    console.log("[+] TikTok Download Path Tracer Starting...");

    // === 1. File Operations ===
    hookFileConstructors();
    hookFileOutputStreams();

    // === 2. Android Storage APIs ===
    hookEnvironmentAPIs();
    hookMediaStore();

    // === 3. Path Operations ===
    // hookStringBuilderForPaths();  // Disabled - too invasive, causes crashes

    // === 4. TikTok Specific ===
    hookTikTokPathMethods();

    console.log("[+] All hooks installed. Waiting for download...");
});

function hookFileConstructors() {
    var File = Java.use("java.io.File");

    File.$init.overload('java.lang.String').implementation = function(path) {
        if (isRelevantPath(path)) {
            if (isDCIMPath(path)) {
                console.log("\n\n========================================");
                console.log("*** DCIM/CAMERA PATH DETECTED ***");
                console.log("========================================");
                logWithStack("[File(String)] " + path);
                console.log("========================================\n");
            } else {
                logWithStack("[File(String)] " + path);
            }
        }
        return this.$init(path);
    };

    try {
        File.$init.overload('java.io.File', 'java.lang.String').implementation = function(parent, child) {
            var fullPath = parent.getAbsolutePath() + "/" + child;
            if (isRelevantPath(fullPath)) {
                logWithStack("[File(File,String)] " + fullPath);
            }
            return this.$init(parent, child);
        };
    } catch(e) {
        console.log("[-] File(File,String) hook failed: " + e);
    }
}

function hookFileOutputStreams() {
    try {
        var FileOutputStream = Java.use("java.io.FileOutputStream");

        FileOutputStream.$init.overload('java.io.File').implementation = function(file) {
            var path = file.getAbsolutePath();
            if (isRelevantPath(path)) {
                if (isDCIMPath(path)) {
                    console.log("\n\n========================================");
                    console.log("*** DCIM FILEOUTPUTSTREAM DETECTED ***");
                    console.log("========================================");
                    logWithStack("[FileOutputStream(File)] " + path);
                    console.log("========================================\n");
                } else {
                    logWithStack("[FileOutputStream(File)] " + path);
                }
            }
            return this.$init(file);
        };

        FileOutputStream.$init.overload('java.lang.String').implementation = function(path) {
            if (isRelevantPath(path)) {
                if (isDCIMPath(path)) {
                    console.log("\n\n========================================");
                    console.log("*** DCIM FILEOUTPUTSTREAM DETECTED ***");
                    console.log("========================================");
                    logWithStack("[FileOutputStream(String)] " + path);
                    console.log("========================================\n");
                } else {
                    logWithStack("[FileOutputStream(String)] " + path);
                }
            }
            return this.$init(path);
        };
    } catch(e) {
        console.log("[-] FileOutputStream hook failed: " + e);
    }
}

function hookEnvironmentAPIs() {
    try {
        var Environment = Java.use("android.os.Environment");

        Environment.getExternalStorageDirectory.implementation = function() {
            var result = this.getExternalStorageDirectory();
            console.log("[Environment.getExternalStorageDirectory] " + result.getAbsolutePath());
            return result;
        };

        Environment.getExternalStoragePublicDirectory.implementation = function(type) {
            var result = this.getExternalStoragePublicDirectory(type);
            console.log("[Environment.getExternalStoragePublicDirectory] type=" + type + " -> " + result.getAbsolutePath());
            return result;
        };
    } catch(e) {
        console.log("[-] Environment API hook failed: " + e);
    }
}

function hookMediaStore() {
    try {
        var ContentResolver = Java.use("android.content.ContentResolver");

        ContentResolver.insert.overload('android.net.Uri', 'android.content.ContentValues').implementation = function(uri, values) {
            if (uri.toString().indexOf("MediaStore") !== -1) {
                console.log("\\n[MediaStore.insert] URI: " + uri);
                if (values) {
                    var displayName = values.getAsString("_display_name");
                    var relativePath = values.getAsString("relative_path");
                    console.log("  DISPLAY_NAME: " + displayName);
                    console.log("  RELATIVE_PATH: " + relativePath);
                    logWithStack("[MediaStore Path]");
                }
            }
            return this.insert(uri, values);
        };

        ContentResolver.openOutputStream.overload('android.net.Uri').implementation = function(uri) {
            if (uri.toString().indexOf("MediaStore") !== -1 || isRelevantPath(uri.toString())) {
                logWithStack("[ContentResolver.openOutputStream] " + uri);
            }
            return this.openOutputStream(uri);
        };
    } catch(e) {
        console.log("[-] MediaStore hook failed: " + e);
    }
}

function hookStringBuilderForPaths() {
    try {
        var StringBuilder = Java.use("java.lang.StringBuilder");

        var originalToString = StringBuilder.toString.implementation;
        StringBuilder.toString.implementation = function() {
            var result = originalToString.call(this);
            if (isRelevantPath(result) && result.length > 10) {
                logWithStack("[StringBuilder.toString] " + result);
            }
            return result;
        };
    } catch(e) {
        console.log("[-] StringBuilder hook failed: " + e);
    }
}

function hookTikTokPathMethods() {
    setTimeout(function() {
        try {
            // Hook KHJ.LIZ
            var KHJ = Java.use("X.KHJ");
            console.log("[+] Found KHJ class, hooking LIZ()...");
            KHJ.LIZ.implementation = function() {
                var result = this.LIZ();
                logWithStack("[KHJ.LIZ()] " + result);
                return result;
            };
        } catch(e) {
            console.log("[-] KHJ.LIZ hook failed: " + e);
        }

        try {
            // Hook K6I.LIZ
            var K6I = Java.use("X.K6I");
            console.log("[+] Found K6I class, hooking LIZ()...");
            K6I.LIZ.implementation = function() {
                var result = this.LIZ();
                logWithStack("[K6I.LIZ()] " + result);
                return result;
            };
        } catch(e) {
            console.log("[-] K6I.LIZ hook failed: " + e);
        }
    }, 1000);
}

function isRelevantPath(path) {
    if (!path) return false;
    var lower = path.toLowerCase();
    return lower.indexOf("dcim") !== -1 ||
           lower.indexOf("camera") !== -1 ||
           lower.indexOf("tiktok") !== -1 ||
           lower.indexOf("download") !== -1 ||
           lower.indexOf(".mp4") !== -1 ||
           lower.indexOf("video") !== -1;
}

function isDCIMPath(path) {
    if (!path) return false;
    var lower = path.toLowerCase();
    return lower.indexOf("dcim") !== -1 || lower.indexOf("camera") !== -1;
}

function logWithStack(message) {
    console.log("\\n[*] " + message);
    var Exception = Java.use("java.lang.Exception");
    var Log = Java.use("android.util.Log");
    var stack = Log.getStackTraceString(Exception.$new());

    // Filter for TikTok-specific frames
    var lines = stack.split("\\n");
    console.log("Stack trace (TikTok methods):");
    var count = 0;
    for (var i = 0; i < lines.length && count < 20; i++) {
        if (lines[i].indexOf("com.ss.android") !== -1 ||
            lines[i].indexOf("com.zhiliaoapp") !== -1 ||
            lines[i].indexOf(" X.") !== -1 ||
            lines[i].indexOf("(X.") !== -1) {
            console.log("  " + lines[i].trim());
            count++;
        }
    }
}
