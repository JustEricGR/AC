//
// Useful FLI C functions to call from SystemVerilog procedural code.
//
package mti_fli;
    import "DPI-C" function void    mti_Command (input string s);
    import "DPI-C" function int     mti_Cmd (input string s);
    import "DPI-C" function string  mti_GetProductVersion ();
    import "DPI-C" function chandle mti_Interp();
    import "DPI-C" function void    Tcl_ResetResult(input chandle interp);
    import "DPI-C" function string  Tcl_GetStringResult(input chandle interp);
endpackage


//
// Useful C stdlib functions to call from SystemVerilog procedural code.
//
package mti_cstdlib;
    import "DPI-C" function string getenv (input string s);
    import "DPI-C" function int putenv (input string s);
    import "DPI-C" function int system (input string s);
    import "DPI-C" function int abs (input int j);
endpackage


//
// Useful C string lib functions to call from SystemVerilog procedural code.
//
package mti_cstring;
    import "DPI-C" function string  strchr (input string s, input int c);
    import "DPI-C" function string  strrchr (input string s, input int c);
    import "DPI-C" function string  strpbrk (input string s1, input string s2);
    import "DPI-C" function string  strstr (input string s1, input string s2);
`ifdef _LP64
    import "DPI-C" function int     strncmp (input string s1, input string s2, input longint n);
    import "DPI-C" function longint strcspn (input string s1, input string s2);
    import "DPI-C" function longint strspn (input string s1, input string s2);
`else
    import "DPI-C" function int     strncmp (input string s1, input string s2, input int n);
    import "DPI-C" function int     strcspn (input string s1, input string s2);
    import "DPI-C" function int     strspn (input string s1, input string s2);
`endif
endpackage

//
// GUI Debugging tools
//
package mti_debug;
    typedef enum {
        ENV_INSTANCE,  // for defining regions or scopes
        ENV_PORT,      // for defining ports on an instance
        ENV_OBJECT,    // for defining valued items
        ENV_FILTER,    // name is list of patterns to hide
        ENV_ALLOW,     // name is list of patterns to not hide
        ENV_ACCESSMODE,// list of filtered (hidden) access modes
                       //  one of: protected, local, static, const
        ENV_ELABORATE
    } env_kind;
    // ENUM definition for void $mtiRegisterEnv(
    //                              input env_kind kind,
    //                              input classvar parent,
    //                              input classvar obj,
    //                              input string name);
    //
endpackage
