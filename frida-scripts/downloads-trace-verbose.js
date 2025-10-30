/**
 * VERBOSE Frida script to trace ALL TikTok download activity
 * Usage: frida -U TikTok -l trace-download-verbose.js
 */

Java.perform(function() {
    console.log("\n" + "=".repeat(80));
    console.log("[*] VERBOSE TikTok Download Path Tracer Started");
    console.log("[*] Trigger a download in the app to see ALL method calls");
    console.log("=".repeat(80) + "\n");

    // Hook ALL methods in X.Kjb class
    try {
        var Kjb = Java.use("X.Kjb");
        var methods = Kjb.class.getDeclaredMethods();

        console.log("[*] Found " + methods.length + " methods in X.Kjb class");
        console.log("[*] Hooking ALL methods...\n");

        methods.forEach(function(method) {
            var methodName = method.getName();
            var overloads = Kjb[methodName];

            if (overloads) {
                try {
                    overloads.overloads.forEach(function(overload) {
                        overload.implementation = function() {
                            console.log("\n[X.Kjb." + methodName + "] CALLED");
                            console.log("  Arguments: " + arguments.length);
                            for (var i = 0; i < arguments.length; i++) {
                                try {
                                    console.log("  arg[" + i + "]: " + arguments[i]);
                                } catch(e) {
                                    console.log("  arg[" + i + "]: <error reading>");
                                }
                            }

                            var result = this[methodName].apply(this, arguments);
                            console.log("  Result: " + result);

                            return result;
                        };
                    });
                    console.log("[+] Hooked X.Kjb." + methodName);
                } catch(e) {
                    // Skip if can't hook
                }
            }
        });
    } catch(e) {
        console.log("[-] Failed to hook X.Kjb: " + e);
    }

    // Hook getExternalFilesDir
    try {
        var Context = Java.use("android.content.Context");
        Context.getExternalFilesDir.overload('java.lang.String').implementation = function(type) {
            var result = this.getExternalFilesDir(type);
            console.log("\n[Context.getExternalFilesDir] CALLED");
            console.log("  Type: " + type);
            console.log("  Result: " + result);

            return result;
        };
        console.log("[+] Hooked Context.getExternalFilesDir\n");
    } catch(e) {
        console.log("[-] Failed to hook getExternalFilesDir: " + e);
    }

    // Hook File constructor - MORE VERBOSE
    try {
        var File = Java.use("java.io.File");

        // String constructor
        var FileInitString = File.$init.overload('java.lang.String');
        FileInitString.implementation = function(path) {
            if (path && (path.indexOf("TikTok") >= 0 ||
                         path.indexOf("Camera") >= 0 ||
                         path.indexOf("share") >= 0 ||
                         path.indexOf("download") >= 0 ||
                         path.indexOf("DCIM") >= 0 ||
                         path.indexOf("Videos") >= 0 ||
                         path.indexOf(".mp4") >= 0)) {
                console.log("\n[File.<init>(String)] Creating file:");
                console.log("  Path: " + path);
            }
            return FileInitString.call(this, path);
        };

        // File, String constructor
        try {
            var FileInitFileString = File.$init.overload('java.io.File', 'java.lang.String');
            FileInitFileString.implementation = function(parent, child) {
                var fullPath = parent.getAbsolutePath() + "/" + child;
                if (fullPath && (fullPath.indexOf("TikTok") >= 0 ||
                                 fullPath.indexOf("Camera") >= 0 ||
                                 fullPath.indexOf("share") >= 0 ||
                                 fullPath.indexOf("download") >= 0 ||
                                 fullPath.indexOf("DCIM") >= 0 ||
                                 fullPath.indexOf("Videos") >= 0 ||
                                 fullPath.indexOf(".mp4") >= 0)) {
                    console.log("\n[File.<init>(File, String)] Creating file:");
                    console.log("  Parent: " + parent.getAbsolutePath());
                    console.log("  Child: " + child);
                    console.log("  Full path: " + fullPath);
                }
                return FileInitFileString.call(this, parent, child);
            };
        } catch(e) {}

        console.log("[+] Hooked File constructors\n");
    } catch(e) {
        console.log("[-] Failed to hook File: " + e);
    }

    // Hook ContentValues - ALL puts
    try {
        var ContentValues = Java.use("android.content.ContentValues");

        ContentValues.put.overload('java.lang.String', 'java.lang.String').implementation = function(key, value) {
            console.log("\n[ContentValues.put] String value:");
            console.log("  Key: " + key);
            console.log("  Value: " + value);
            return this.put(key, value);
        };

        console.log("[+] Hooked ContentValues.put\n");
    } catch(e) {
        console.log("[-] Failed to hook ContentValues: " + e);
    }

    // Hook ContentResolver.insert to see MediaStore operations
    try {
        var ContentResolver = Java.use("android.content.ContentResolver");
        ContentResolver.insert.overload('android.net.Uri', 'android.content.ContentValues').implementation = function(uri, values) {
            console.log("\n[ContentResolver.insert] MediaStore insert:");
            console.log("  URI: " + uri);
            console.log("  ContentValues: " + values);

            var result = this.insert(uri, values);
            console.log("  Result URI: " + result);

            return result;
        };
        console.log("[+] Hooked ContentResolver.insert\n");
    } catch(e) {
        console.log("[-] Failed to hook ContentResolver: " + e);
    }

    // Hook Environment.getExternalStoragePublicDirectory
    try {
        var Environment = Java.use("android.os.Environment");
        Environment.getExternalStoragePublicDirectory.implementation = function(type) {
            var result = this.getExternalStoragePublicDirectory(type);
            console.log("\n[Environment.getExternalStoragePublicDirectory] CALLED");
            console.log("  Type: " + type);
            console.log("  Result: " + result);
            return result;
        };
        console.log("[+] Hooked Environment.getExternalStoragePublicDirectory\n");
    } catch(e) {
        console.log("[-] Failed to hook Environment: " + e);
    }

    // Hook FileOutputStream to see actual file writes
    try {
        var FileOutputStream = Java.use("java.io.FileOutputStream");
        var FileOutputStreamInit = FileOutputStream.$init.overload('java.io.File');
        FileOutputStreamInit.implementation = function(file) {
            var path = file.getAbsolutePath();
            if (path && (path.indexOf("TikTok") >= 0 ||
                         path.indexOf("Camera") >= 0 ||
                         path.indexOf("share") >= 0 ||
                         path.indexOf("download") >= 0 ||
                         path.indexOf("DCIM") >= 0 ||
                         path.indexOf("Videos") >= 0 ||
                         path.indexOf(".mp4") >= 0)) {
                console.log("\n[FileOutputStream.<init>] Opening file for WRITE:");
                console.log("  Path: " + path);
                console.log("  Stack trace:");
                console.log(Java.use("android.util.Log").getStackTraceString(Java.use("java.lang.Exception").$new()));
            }
            return FileOutputStreamInit.call(this, file);
        };
        console.log("[+] Hooked FileOutputStream\n");
    } catch(e) {
        console.log("[-] Failed to hook FileOutputStream: " + e);
    }

    console.log("\n" + "=".repeat(80));
    console.log("[*] ALL HOOKS INSTALLED - Download a video now!");
    console.log("=".repeat(80) + "\n");
});
