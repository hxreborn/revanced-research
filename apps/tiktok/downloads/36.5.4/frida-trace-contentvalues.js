/**
 * Trace ContentValues.put calls to find where relative_path is set
 * Target: com.zhiliaoapp.musically v36.5.4
 */

console.log('[*] ContentValues tracer loading...\n');

function getJavaStackTrace() {
    try {
        const Exception = Java.use('java.lang.Exception');
        const sw = Java.use('java.io.StringWriter').$new();
        const pw = Java.use('java.io.PrintWriter').$new(sw);
        Exception.$new('Stack trace').printStackTrace(pw);
        return '\n' + sw.toString();
    } catch (e) {
        return '  <error getting stack trace>';
    }
}

Java.perform(() => {
    const ContentValues = Java.use('android.content.ContentValues');

    ContentValues.put.overload('java.lang.String', 'java.lang.String').implementation = function(key, value) {
        if (key === 'relative_path' || (value && value.toString().includes('Camera'))) {
            console.log('\n========================================');
            console.log('[ContentValues.put] FOUND');
            console.log(`Key: ${key}`);
            console.log(`Value: ${value}`);
            console.log('Stack trace:');
            console.log(getJavaStackTrace());
            console.log('========================================\n');
        }

        return this.put(key, value);
    };

    console.log('[+] Hooked ContentValues.put(String, String)\n');
    console.log('[*] Download a video to capture relative_path assignment\n');
});
