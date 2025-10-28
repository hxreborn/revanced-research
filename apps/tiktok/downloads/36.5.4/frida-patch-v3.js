/**
 * Frida Runtime Patch v3 for TikTok Downloads
 * Target: com.zhiliaoapp.musically v36.5.4
 *
 * Fixed: X.CtJ.LIZ takes String argument, not returns File
 * Strategy: Modify the STRING path argument before method processes it
 */

console.log('[*] TikTok Downloads Patch v3 Loading...');
console.log('[*] Target: com.zhiliaoapp.musically v36.5.4\n');

Java.perform(() => {
    // ==============================================================================
    // PATCH 1: X.CtJ.LIZ - Modify STRING argument containing /share/out/ path
    // ==============================================================================
    try {
        console.log('[*] Hooking X.CtJ.LIZ...');

        const CtJ = Java.use('X.CtJ');
        const File = Java.use('java.io.File');
        const Environment = Java.use('android.os.Environment');

        // Get the LIZ method
        const LIZ = CtJ.LIZ;

        if (LIZ && LIZ.overloads) {
            LIZ.overloads.forEach((overload) => {
                overload.implementation = function() {
                    // Check if first argument is a String containing /share/out/
                    if (arguments.length > 0 && typeof arguments[0] === 'string') {
                        const originalPath = arguments[0];

                        if (originalPath.includes('/share/out/')) {
                            console.log(`\n[HOOK] X.CtJ.LIZ called`);
                            console.log(`[HOOK]   Original path: ${originalPath}`);

                            // Extract filename
                            const filename = originalPath.substring(originalPath.lastIndexOf('/') + 1);

                            // Construct new public storage path
                            const dcimDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM.value);
                            const tiktokDir = File.$new(dcimDir, 'TikTok');

                            // Ensure directory exists
                            if (!tiktokDir.exists()) {
                                tiktokDir.mkdirs();
                                console.log('[PATCH] Created /DCIM/TikTok/ directory');
                            }

                            // Create new path string
                            const newFile = File.$new(tiktokDir, filename);
                            const newPath = newFile.getAbsolutePath();

                            console.log(`[PATCH] Redirected to: ${newPath}`);
                            console.log('[PATCH] ✅ Path successfully patched!\n');

                            // Replace the path argument
                            arguments[0] = newPath;
                        }
                    }

                    // Call original method with modified arguments
                    return overload.call(this, ...arguments);
                };
            });

            console.log('[+] Successfully hooked X.CtJ.LIZ\n');
        }

    } catch (e) {
        console.log('[!] Failed to hook X.CtJ.LIZ:', e.message);
        console.log('[!] Stack:', e.stack);
    }

    // ==============================================================================
    // PATCH 2: ContentResolver.insert - Fix MediaStore relative_path
    // ==============================================================================
    try {
        console.log('[*] Hooking ContentResolver.insert...');

        const ContentResolver = Java.use('android.content.ContentResolver');

        ContentResolver.insert.overload('android.net.Uri', 'android.content.ContentValues').implementation = function(uri, values) {
            const uriStr = uri.toString();

            if (uriStr.includes('MediaStore') && uriStr.includes('video') && values) {
                const relativePath = values.get('relative_path');

                if (relativePath) {
                    const relativePathStr = relativePath.toString();

                    if (relativePathStr === 'DCIM/Camera/') {
                        console.log(`\n[HOOK] ContentResolver.insert - MediaStore registration`);
                        console.log(`[HOOK]   Original relative_path: ${relativePathStr}`);

                        // Fix the path to match our DCIM/TikTok location
                        values.put('relative_path', 'DCIM/TikTok/');

                        console.log(`[PATCH] Updated relative_path: DCIM/TikTok/`);
                        console.log('[PATCH] ✅ MediaStore metadata patched!\n');
                    }
                }
            }

            return this.insert(uri, values);
        };

        console.log('[+] Successfully hooked ContentResolver.insert\n');

    } catch (e) {
        console.log('[!] Failed to hook ContentResolver.insert:', e.message);
    }

    // ==============================================================================
    // MONITORING: Track File operations to confirm patch worked
    // ==============================================================================
    try {
        console.log('[*] Setting up File monitoring...');

        const File = Java.use('java.io.File');
        const seenFiles = new Set();

        // Monitor File(String) constructor
        File.$init.overload('java.lang.String').implementation = function(path) {
            const pathStr = path.toString();

            if (pathStr.endsWith('.mp4') &&
                (pathStr.includes('/DCIM/') ||
                 pathStr.includes('/share/out/') ||
                 pathStr.includes('/share/tmp/')) &&
                !seenFiles.has(pathStr)) {

                seenFiles.add(pathStr);
                console.log(`\n[FILE] New .mp4 detected: ${pathStr}`);

                if (pathStr.includes('/DCIM/TikTok/')) {
                    console.log('[SUCCESS] ✅✅✅ FILE IN CORRECT LOCATION! ✅✅✅\n');
                } else if (pathStr.includes('/share/out/')) {
                    console.log('[WARNING] ⚠️  App-scoped storage (patch may have failed)\n');
                } else if (pathStr.includes('/share/tmp/')) {
                    console.log('[INFO] Temporary download file (expected)\n');
                }
            }

            return this.$init(path);
        };

        // Monitor File(File, String) constructor
        File.$init.overload('java.io.File', 'java.lang.String').implementation = function(parent, child) {
            const parentPath = parent.getAbsolutePath().toString();
            const fullPath = `${parentPath}/${child}`;

            if (fullPath.endsWith('.mp4') &&
                (fullPath.includes('/DCIM/') ||
                 fullPath.includes('/share/out/') ||
                 fullPath.includes('/share/tmp/')) &&
                !seenFiles.has(fullPath)) {

                seenFiles.add(fullPath);
                console.log(`\n[FILE] New .mp4 detected: ${fullPath}`);

                if (fullPath.includes('/DCIM/TikTok/')) {
                    console.log('[SUCCESS] ✅✅✅ FILE IN CORRECT LOCATION! ✅✅✅\n');
                } else if (fullPath.includes('/share/out/')) {
                    console.log('[WARNING] ⚠️  App-scoped storage (patch may have failed)\n');
                } else if (fullPath.includes('/share/tmp/')) {
                    console.log('[INFO] Temporary download file (expected)\n');
                }
            }

            return this.$init(parent, child);
        };

        console.log('[+] File monitoring enabled\n');

    } catch (e) {
        console.log('[!] Failed to set up monitoring:', e.message);
    }
});

console.log('========================================');
console.log('[*] All patches applied!');
console.log('[*] Ready to test downloads');
console.log('[*] Expected: Files in /DCIM/TikTok/');
console.log('========================================\n');
