--------------------------------------------------------------------------
--                                                                      --
-- Copyright (c) 1990, 1991, 1992 by Synopsys, Inc.                     --
--                                             All rights reserved.     --
--                                                                      --
-- This source file may be used and distributed without restriction     --
-- provided that this copyright statement is not removed from the file  --
-- and that any derivative work contains this copyright notice.         --
--                                                                      --
--	Package name: STD_LOGIC_UNSIGNED                                --
--                                 					--
--									--
--      Date:        	09/11/92	KN				--
--			10/08/92 	AMT				--
--									--
--	Purpose: 							--
--	 A set of unsigned arithemtic, conversion,                      --
--           and comparision functions for STD_LOGIC_VECTOR.            --
--									--
--	Note:  comparision of same length discrete arrays is defined	--
--		by the LRM.  This package will "overload" those 	--
--		definitions						--
--									--
--------------------------------------------------------------------------

---------------------------------------------------
-- Attributes added to invoke MTI builtin functions
---------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

package STD_LOGIC_UNSIGNED is

    attribute builtin_subprogram: string;

    function "+"(L: STD_LOGIC_VECTOR; R: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR;
    attribute builtin_subprogram of
        "+"[STD_LOGIC_VECTOR, STD_LOGIC_VECTOR return STD_LOGIC_VECTOR]: 
		function is "stdarith_plus_uuu";

    function "+"(L: STD_LOGIC_VECTOR; R: INTEGER) return STD_LOGIC_VECTOR;
    attribute builtin_subprogram of
        "+"[STD_LOGIC_VECTOR, INTEGER return STD_LOGIC_VECTOR]: 
		function is "stdarith_plus_uiu";

    function "+"(L: INTEGER; R: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR;
    attribute builtin_subprogram of
        "+"[INTEGER, STD_LOGIC_VECTOR return STD_LOGIC_VECTOR]: 
		function is "stdarith_plus_iuu";

    function "+"(L: STD_LOGIC_VECTOR; R: STD_LOGIC) return STD_LOGIC_VECTOR;
    attribute builtin_subprogram of
        "+"[STD_LOGIC_VECTOR, STD_LOGIC return STD_LOGIC_VECTOR]: 
		function is "stdarith_plus_uxu";

    function "+"(L: STD_LOGIC; R: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR;
    attribute builtin_subprogram of
        "+"[STD_LOGIC, STD_LOGIC_VECTOR return STD_LOGIC_VECTOR]: 
		function is "stdarith_plus_xuu";


    function "-"(L: STD_LOGIC_VECTOR; R: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR;
    attribute builtin_subprogram of
        "-"[STD_LOGIC_VECTOR, STD_LOGIC_VECTOR return STD_LOGIC_VECTOR]: 
		function is "stdarith_minus_uuu";

    function "-"(L: STD_LOGIC_VECTOR; R: INTEGER) return STD_LOGIC_VECTOR;
    attribute builtin_subprogram of
        "-"[STD_LOGIC_VECTOR, INTEGER return STD_LOGIC_VECTOR]: 
		function is "stdarith_minus_uiu";

    function "-"(L: INTEGER; R: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR;
    attribute builtin_subprogram of
        "-"[INTEGER, STD_LOGIC_VECTOR return STD_LOGIC_VECTOR]: 
		function is "stdarith_minus_iuu";

    function "-"(L: STD_LOGIC_VECTOR; R: STD_LOGIC) return STD_LOGIC_VECTOR;
    attribute builtin_subprogram of
        "-"[STD_LOGIC_VECTOR, STD_LOGIC return STD_LOGIC_VECTOR]: 
		function is "stdarith_minus_uxu";

    function "-"(L: STD_LOGIC; R: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR;
    attribute builtin_subprogram of
        "-"[STD_LOGIC, STD_LOGIC_VECTOR return STD_LOGIC_VECTOR]: 
		function is "stdarith_minus_xuu";


    function "+"(L: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR;
    attribute builtin_subprogram of
        "+"[STD_LOGIC_VECTOR return STD_LOGIC_VECTOR]: 
		function is "stdarith_unary_plus_uu";


    function "*"(L: STD_LOGIC_VECTOR; R: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR;
    attribute builtin_subprogram of
        "*"[STD_LOGIC_VECTOR, STD_LOGIC_VECTOR return STD_LOGIC_VECTOR]: 
		function is "stdarith_mult_uuu";


    function "<"(L: STD_LOGIC_VECTOR; R: STD_LOGIC_VECTOR) return BOOLEAN;
    attribute builtin_subprogram of
        "<"[STD_LOGIC_VECTOR, STD_LOGIC_VECTOR return BOOLEAN]: 
		function is "stdarith_lt_uu";

    function "<"(L: STD_LOGIC_VECTOR; R: INTEGER) return BOOLEAN;
    attribute builtin_subprogram of
        "<"[STD_LOGIC_VECTOR, INTEGER return BOOLEAN]: 
		function is "stdarith_lt_ui";

    function "<"(L: INTEGER; R: STD_LOGIC_VECTOR) return BOOLEAN;
    attribute builtin_subprogram of
        "<"[INTEGER, STD_LOGIC_VECTOR return BOOLEAN]: 
		function is "stdarith_lt_iu";


    function "<="(L: STD_LOGIC_VECTOR; R: STD_LOGIC_VECTOR) return BOOLEAN;
    attribute builtin_subprogram of
        "<="[STD_LOGIC_VECTOR, STD_LOGIC_VECTOR return BOOLEAN]: 
		function is "stdarith_lte_uu";

    function "<="(L: STD_LOGIC_VECTOR; R: INTEGER) return BOOLEAN;
    attribute builtin_subprogram of
        "<="[STD_LOGIC_VECTOR, INTEGER return BOOLEAN]: 
		function is "stdarith_lte_ui";

    function "<="(L: INTEGER; R: STD_LOGIC_VECTOR) return BOOLEAN;
    attribute builtin_subprogram of
        "<="[INTEGER, STD_LOGIC_VECTOR return BOOLEAN]: 
		function is "stdarith_lte_iu";


    function ">"(L: STD_LOGIC_VECTOR; R: STD_LOGIC_VECTOR) return BOOLEAN;
    attribute builtin_subprogram of
        ">"[STD_LOGIC_VECTOR, STD_LOGIC_VECTOR return BOOLEAN]: 
		function is "stdarith_gt_uu";

    function ">"(L: STD_LOGIC_VECTOR; R: INTEGER) return BOOLEAN;
    attribute builtin_subprogram of
        ">"[STD_LOGIC_VECTOR, INTEGER return BOOLEAN]: 
		function is "stdarith_gt_ui";

    function ">"(L: INTEGER; R: STD_LOGIC_VECTOR) return BOOLEAN;
    attribute builtin_subprogram of
        ">"[INTEGER, STD_LOGIC_VECTOR return BOOLEAN]: 
		function is "stdarith_gt_iu";


    function ">="(L: STD_LOGIC_VECTOR; R: STD_LOGIC_VECTOR) return BOOLEAN;
    attribute builtin_subprogram of
        ">="[STD_LOGIC_VECTOR, STD_LOGIC_VECTOR return BOOLEAN]: 
		function is "stdarith_gte_uu";

    function ">="(L: STD_LOGIC_VECTOR; R: INTEGER) return BOOLEAN;
    attribute builtin_subprogram of
        ">="[STD_LOGIC_VECTOR, INTEGER return BOOLEAN]: 
		function is "stdarith_gte_ui";

    function ">="(L: INTEGER; R: STD_LOGIC_VECTOR) return BOOLEAN;
    attribute builtin_subprogram of
        ">="[INTEGER, STD_LOGIC_VECTOR return BOOLEAN]: 
		function is "stdarith_gte_iu";


    function "="(L: STD_LOGIC_VECTOR; R: STD_LOGIC_VECTOR) return BOOLEAN;
    attribute builtin_subprogram of
        "="[STD_LOGIC_VECTOR, STD_LOGIC_VECTOR return BOOLEAN]: 
		function is "stdarith_eq_uu";

    function "="(L: STD_LOGIC_VECTOR; R: INTEGER) return BOOLEAN;
    attribute builtin_subprogram of
        "="[STD_LOGIC_VECTOR, INTEGER return BOOLEAN]: 
		function is "stdarith_eq_ui";

    function "="(L: INTEGER; R: STD_LOGIC_VECTOR) return BOOLEAN;
    attribute builtin_subprogram of
        "="[INTEGER, STD_LOGIC_VECTOR return BOOLEAN]: 
		function is "stdarith_eq_iu";


    function "/="(L: STD_LOGIC_VECTOR; R: STD_LOGIC_VECTOR) return BOOLEAN;
    attribute builtin_subprogram of
        "/="[STD_LOGIC_VECTOR, STD_LOGIC_VECTOR return BOOLEAN]: 
		function is "stdarith_neq_uu";

    function "/="(L: STD_LOGIC_VECTOR; R: INTEGER) return BOOLEAN;
    attribute builtin_subprogram of
        "/="[STD_LOGIC_VECTOR, INTEGER return BOOLEAN]: 
		function is "stdarith_neq_ui";

    function "/="(L: INTEGER; R: STD_LOGIC_VECTOR) return BOOLEAN;
    attribute builtin_subprogram of
        "/="[INTEGER, STD_LOGIC_VECTOR return BOOLEAN]: 
		function is "stdarith_neq_iu";

    function SHL(ARG:STD_LOGIC_VECTOR;COUNT: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR;
    attribute builtin_subprogram of
        SHL[STD_LOGIC_VECTOR, STD_LOGIC_VECTOR return STD_LOGIC_VECTOR]: function is "stdarith_shl_uuu";

    function SHR(ARG:STD_LOGIC_VECTOR;COUNT: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR;
    attribute builtin_subprogram of
        SHR[STD_LOGIC_VECTOR, STD_LOGIC_VECTOR return STD_LOGIC_VECTOR]: function is "stdarith_shr_uuu";

    function CONV_INTEGER(ARG: STD_LOGIC_VECTOR) return INTEGER;
    attribute builtin_subprogram of
        CONV_INTEGER[STD_LOGIC_VECTOR return INTEGER]: 
		function is "stdarith_conv_integer_ui2"; 
------------------------------------------------------------------------------------------
--  If desired, you may select an optional implementation for CONV_INTEGER(STD_LOGIC_VECTOR)
--  by changing the value of the attribute:
--      stdarith_conv_integer_ui implements the original CONV_INTEGER(STD_LOGIC_VECTOR) VHDL which
--          generates an error if the argument is larger than 31 bits.
--      stdarith_conv_integer_ui2 allows 32 bits. It generates a warning if the
--          argument is 32 bits and the MSB is not zero.
--      The default is stdarith_conv_integer_ui2.
--
--    attribute builtin_subprogram of
--        CONV_INTEGER[STD_LOGIC_VECTOR return INTEGER]: function is "stdarith_conv_integer_ui"; 
------------------------------------------------------------------------------------------


-- remove this since it is already in std_logic_arith
--    function CONV_STD_LOGIC_VECTOR(ARG: INTEGER; SIZE: INTEGER) return STD_LOGIC_VECTOR;

end STD_LOGIC_UNSIGNED;



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

package body STD_LOGIC_UNSIGNED is


    function maximum(L, R: INTEGER) return INTEGER is
    begin
        if L > R then
            return L;
        else
            return R;
        end if;
    end;


    function "+"(L: STD_LOGIC_VECTOR; R: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
        -- pragma label_applies_to plus
        constant length: INTEGER := maximum(L'length, R'length);
        variable result  : STD_LOGIC_VECTOR (length-1 downto 0);
    begin
        result  := UNSIGNED(L) + UNSIGNED(R);-- pragma label plus
        return   std_logic_vector(result);
    end;

    function "+"(L: STD_LOGIC_VECTOR; R: INTEGER) return STD_LOGIC_VECTOR is
        -- pragma label_applies_to plus
        variable result  : STD_LOGIC_VECTOR (L'range);
    begin
        result  := UNSIGNED(L) + R;-- pragma label plus
        return   std_logic_vector(result);
    end;

    function "+"(L: INTEGER; R: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
        -- pragma label_applies_to plus
        variable result  : STD_LOGIC_VECTOR (R'range);
    begin
        result  := L + UNSIGNED(R);-- pragma label plus
        return   std_logic_vector(result);
    end;

    function "+"(L: STD_LOGIC_VECTOR; R: STD_LOGIC) return STD_LOGIC_VECTOR is
        -- pragma label_applies_to plus
        variable result  : STD_LOGIC_VECTOR (L'range);
    begin
        result  := UNSIGNED(L) + R;-- pragma label plus
        return   std_logic_vector(result);
    end;

    function "+"(L: STD_LOGIC; R: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
            -- pragma label_applies_to plus
    variable result  : STD_LOGIC_VECTOR (R'range);
    begin
        result  := L + UNSIGNED(R);-- pragma label plus
        return   std_logic_vector(result);
    end;

    function "-"(L: STD_LOGIC_VECTOR; R: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
        -- pragma label_applies_to minus
        constant length: INTEGER := maximum(L'length, R'length);
        variable result  : STD_LOGIC_VECTOR (length-1 downto 0);
    begin
        result  := UNSIGNED(L) - UNSIGNED(R); -- pragma label minus
        return   std_logic_vector(result);
    end;

    function "-"(L: STD_LOGIC_VECTOR; R: INTEGER) return STD_LOGIC_VECTOR is
        -- pragma label_applies_to minus
        variable result  : STD_LOGIC_VECTOR (L'range);
    begin
        result  := UNSIGNED(L) - R; -- pragma label minus
        return   std_logic_vector(result);
    end;

    function "-"(L: INTEGER; R: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
        -- pragma label_applies_to minus
        variable result  : STD_LOGIC_VECTOR (R'range);
    begin
        result  := L - UNSIGNED(R);  -- pragma label minus
        return   std_logic_vector(result);
    end;

    function "-"(L: STD_LOGIC_VECTOR; R: STD_LOGIC) return STD_LOGIC_VECTOR is
        variable result  : STD_LOGIC_VECTOR (L'range);
    begin
        result  := UNSIGNED(L) - R;
        return   std_logic_vector(result);
    end;

    function "-"(L: STD_LOGIC; R: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
        -- pragma label_applies_to minus
        variable result  : STD_LOGIC_VECTOR (R'range);
    begin
        result  := L - UNSIGNED(R);  -- pragma label minus
        return   std_logic_vector(result);
    end;

    function "+"(L: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
        variable result  : STD_LOGIC_VECTOR (L'range);
    begin
        result  := + UNSIGNED(L);
        return   std_logic_vector(result);
    end;

    function "*"(L: STD_LOGIC_VECTOR; R: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
        -- pragma label_applies_to mult
        constant length: INTEGER := maximum(L'length, R'length);
        variable result  : STD_LOGIC_VECTOR ((L'length+R'length-1) downto 0);
    begin
        result  := UNSIGNED(L) * UNSIGNED(R); -- pragma label mult
        return   std_logic_vector(result);
    end;
        
    function "<"(L: STD_LOGIC_VECTOR; R: STD_LOGIC_VECTOR) return BOOLEAN is
        -- pragma label_applies_to lt
        constant length: INTEGER := maximum(L'length, R'length);
    begin
        return   UNSIGNED(L) < UNSIGNED(R); -- pragma label lt
    end;

    function "<"(L: STD_LOGIC_VECTOR; R: INTEGER) return BOOLEAN is
        -- pragma label_applies_to lt
    begin
        return   UNSIGNED(L) < R; -- pragma label lt
    end;

    function "<"(L: INTEGER; R: STD_LOGIC_VECTOR) return BOOLEAN is
        -- pragma label_applies_to lt
    begin
        return   L < UNSIGNED(R); -- pragma label lt
    end;

    function "<="(L: STD_LOGIC_VECTOR; R: STD_LOGIC_VECTOR) return BOOLEAN is
       -- pragma label_applies_to leq
    begin
        return   UNSIGNED(L) <= UNSIGNED(R); -- pragma label leq
    end;

    function "<="(L: STD_LOGIC_VECTOR; R: INTEGER) return BOOLEAN is
       -- pragma label_applies_to leq
    begin
        return   UNSIGNED(L) <= R; -- pragma label leq
    end;

    function "<="(L: INTEGER; R: STD_LOGIC_VECTOR) return BOOLEAN is
       -- pragma label_applies_to leq
    begin
        return   L <= UNSIGNED(R); -- pragma label leq
    end;

    function ">"(L: STD_LOGIC_VECTOR; R: STD_LOGIC_VECTOR) return BOOLEAN is
        -- pragma label_applies_to gt
    begin
        return   UNSIGNED(L) > UNSIGNED(R); -- pragma label gt
    end;

    function ">"(L: STD_LOGIC_VECTOR; R: INTEGER) return BOOLEAN is
        -- pragma label_applies_to gt
    begin
        return   UNSIGNED(L) > R; -- pragma label gt
    end;

    function ">"(L: INTEGER; R: STD_LOGIC_VECTOR) return BOOLEAN is
        -- pragma label_applies_to gt
    begin
        return   L > UNSIGNED(R); -- pragma label gt
    end;

    function ">="(L: STD_LOGIC_VECTOR; R: STD_LOGIC_VECTOR) return BOOLEAN is
        -- pragma label_applies_to geq
    begin
        return   UNSIGNED(L) >= UNSIGNED(R);  -- pragma label geq
    end;

    function ">="(L: STD_LOGIC_VECTOR; R: INTEGER) return BOOLEAN is
        -- pragma label_applies_to geq
    begin
        return   UNSIGNED(L) >= R;  -- pragma label geq
    end;

    function ">="(L: INTEGER; R: STD_LOGIC_VECTOR) return BOOLEAN is
        -- pragma label_applies_to geq
    begin
        return   L >= UNSIGNED(R);  -- pragma label geq
    end;

    function "="(L: STD_LOGIC_VECTOR; R: STD_LOGIC_VECTOR) return BOOLEAN is
    begin
        return   UNSIGNED(L) = UNSIGNED(R);
    end;

    function "="(L: STD_LOGIC_VECTOR; R: INTEGER) return BOOLEAN is
    begin
        return   UNSIGNED(L) = R;
    end;

    function "="(L: INTEGER; R: STD_LOGIC_VECTOR) return BOOLEAN is
    begin
        return   L = UNSIGNED(R);
    end;

    function "/="(L: STD_LOGIC_VECTOR; R: STD_LOGIC_VECTOR) return BOOLEAN is
    begin
        return   UNSIGNED(L) /= UNSIGNED(R);
    end;

    function "/="(L: STD_LOGIC_VECTOR; R: INTEGER) return BOOLEAN is
    begin
        return   UNSIGNED(L) /= R;
    end;

    function "/="(L: INTEGER; R: STD_LOGIC_VECTOR) return BOOLEAN is
    begin
        return   L /= UNSIGNED(R);
    end;

    function CONV_INTEGER(ARG: STD_LOGIC_VECTOR) return INTEGER is
        variable result    : UNSIGNED(ARG'range);
    begin
        result    := UNSIGNED(ARG);
        return   CONV_INTEGER(result);
    end;
    function SHL(ARG:STD_LOGIC_VECTOR;COUNT: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
    begin
       return STD_LOGIC_VECTOR(SHL(UNSIGNED(ARG),UNSIGNED(COUNT)));
    end;
 
    function SHR(ARG:STD_LOGIC_VECTOR;COUNT: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
    begin
       return STD_LOGIC_VECTOR(SHR(UNSIGNED(ARG),UNSIGNED(COUNT)));
    end;


-- remove this since it is already in std_logic_arith
    --function CONV_STD_LOGIC_VECTOR(ARG: INTEGER; SIZE: INTEGER) return STD_LOGIC_VECTOR is
        --variable result1 : UNSIGNED (SIZE-1 downto 0);
        --variable result2 : STD_LOGIC_VECTOR (SIZE-1 downto 0);
    --begin
        --result1 := CONV_UNSIGNED(ARG,SIZE);
        --return   std_logic_vector(result1);
    --end;


end STD_LOGIC_UNSIGNED;


