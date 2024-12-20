-- --------------------------------------------------------------------
-- "math_utility_pkg" package contains types used by the both the fixed
-- and floating point packages.
-- This package should be compiled into "ieee_proposed" and used as follows:
-- use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
-- use ieee_proposed.math_utility.all;
-- use ieee_proposed.fixed_pkg.all;
-- use ieee_proposed.float_pkg.all;
--
--  This verison is designed to work with the VHDL-93 compilers.  Please
--  note the "%%%" comments.  These are where we diverge from the
--  VHDL-2008 LRM.
--
-- --------------------------------------------------------------------
-- Version    : $Revision: #1 $
-- Date       : $Date: 2009/05/20 $
-- --------------------------------------------------------------------

package math_utility_pkg is

  -- Types used for generics of fixed_generic_pkg
  
  type fixed_round_style_type is (fixed_round, fixed_truncate);
  
  type fixed_overflow_style_type is (fixed_saturate, fixed_wrap);

  -- Type used for generics of float_generic_pkg

  -- These are the same as the C FE_TONEAREST, FE_UPWARD, FE_DOWNWARD,
  -- and FE_TOWARDZERO floating point rounding macros.

  type round_type is (round_nearest,    -- Default, nearest LSB '0'
                      round_inf,        -- Round toward positive infinity
                      round_neginf,     -- Round toward negative infinity
                      round_zero);      -- Round toward zero (truncate)

end package math_utility_pkg;
