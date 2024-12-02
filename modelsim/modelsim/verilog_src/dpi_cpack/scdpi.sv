package mti_scdpi;

typedef logic  sc_logic;
typedef bit    sc_bit;
typedef bit    sc_bv;
typedef logic  sc_lv;
typedef bit    sc_int;
typedef bit    sc_uint;
typedef bit    sc_bigint;
typedef bit    sc_biguint;
typedef bit    sc_fixed;
typedef bit    sc_ufixed;
typedef bit    sc_fixed_fast;
typedef bit    sc_ufixed_fast;
typedef bit    sc_fix;
typedef bit    sc_ufix;
typedef bit    sc_fix_fast;
typedef bit    sc_ufix_fast;
typedef bit    sc_signed;
typedef bit    sc_unsigned;

import "DPI-C" function string scSetScopeByName(input string scope);
import "DPI-C" function string scGetScopeName();

endpackage
