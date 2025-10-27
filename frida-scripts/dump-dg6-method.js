// Dump DG6.LIZ() method bytecode and implementation
// Target: X.DG6.LIZ() that constructs download path

Java.perform(function() {
    console.log("[+] DG6 Method Dumper Starting...\n");

    try {
        // Find the DG6 class
        var DG6 = Java.use("X.DG6");
        console.log("[+] Found X.DG6 class");

        // Get the LIZ method that returns File
        var lizMethod = DG6.LIZ;
        console.log("[+] Found LIZ() method\n");

        // Get method details using reflection
        var Class = Java.use("java.lang.Class");
        var dg6Class = DG6.class;
        var methods = dg6Class.getDeclaredMethods();

        console.log("=".repeat(80));
        console.log("CLASS: X.DG6");
        console.log("=".repeat(80));

        for (var i = 0; i < methods.length; i++) {
            var method = methods[i];
            var methodName = method.getName();
            var returnType = method.getReturnType().getName();
            var params = method.getParameterTypes();
            var paramStr = "";

            for (var j = 0; j < params.length; j++) {
                paramStr += params[j].getName();
                if (j < params.length - 1) paramStr += ", ";
            }

            console.log("\nMethod: " + methodName + "(" + paramStr + ") -> " + returnType);

            // Focus on LIZ methods
            if (methodName === "LIZ") {
                console.log("  >>> TARGET METHOD FOUND <<<");
                console.log("  Modifiers: " + method.getModifiers());
            }
        }

        console.log("\n" + "=".repeat(80));
        console.log("HOOKING X.DG6.LIZ() TO CAPTURE RUNTIME BEHAVIOR");
        console.log("=".repeat(80) + "\n");

        // Hook all LIZ variants
        try {
            DG6.LIZ.overload('java.lang.String').implementation = function(str) {
                console.log("\n[*] X.DG6.LIZ(String) CALLED");
                console.log("  Input: " + str);
                var result = this.LIZ(str);
                console.log("  Return: " + result);
                return result;
            };
        } catch(e) {}

        // Hook LIZLLL - likely the path constructor
        try {
            DG6.LIZLLL.overload('android.content.Context').implementation = function(context) {
                console.log("\n" + "=".repeat(80));
                console.log("[*] X.DG6.LIZLLL(Context) CALLED - PATH CONSTRUCTOR");
                console.log("=".repeat(80));

                // Get stack trace
                var Exception = Java.use("java.lang.Exception");
                var Log = Java.use("android.util.Log");
                var stack = Log.getStackTraceString(Exception.$new());

                // Call original
                var result = this.LIZLLL(context);

                console.log("[RETURN VALUE - PATH]");
                console.log("  >>> " + result + " <<<");

                console.log("\n[CALL STACK (first 15 frames)]");
                var lines = stack.split("\n");
                for (var i = 0; i < Math.min(lines.length, 15); i++) {
                    console.log("  " + lines[i].trim());
                }

                console.log("\n" + "=".repeat(80) + "\n");

                return result;
            };
        } catch(e) {}

        // Hook LIZIZ
        try {
            DG6.LIZIZ.overload('java.lang.String', 'java.lang.String').implementation = function(str1, str2) {
                console.log("\n[*] X.DG6.LIZIZ(String, String) CALLED");
                console.log("  Param1: " + str1);
                console.log("  Param2: " + str2);
                this.LIZIZ(str1, str2);
            };
        } catch(e) {}

        console.log("[+] Hook installed successfully");
        console.log("[+] Waiting for downloads...\n");

        // Also try to enumerate all fields in DG6 to understand the class structure
        console.log("=".repeat(80));
        console.log("CLASS FIELDS");
        console.log("=".repeat(80));

        var fields = dg6Class.getDeclaredFields();
        for (var i = 0; i < fields.length; i++) {
            var field = fields[i];
            console.log("  Field: " + field.getName() + " : " + field.getType().getName());
        }

        console.log("\n=".repeat(80));
        console.log("READY - Download a video to capture DG6.LIZ() behavior");
        console.log("=".repeat(80) + "\n");

    } catch (e) {
        console.log("[-] Error: " + e);
        console.log("[-] Stack: " + e.stack);
    }
});
