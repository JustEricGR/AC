-- ----------------------------------------------------------------------------
--
--  Copyright (c) Mentor Graphics Corporation, 1982-1996, All Rights Reserved.
--                       UNPUBLISHED, LICENSED SOFTWARE.
--            CONFIDENTIAL AND PROPRIETARY INFORMATION WHICH IS THE
--          PROPERTY OF MENTOR GRAPHICS CORPORATION OR ITS LICENSORS.
--
-- PackageName :  STD_Regpak  (stand alone)
-- Title       :  Standard Register Package
-- Purpose     :  This packages defines a set of standard declarations
--             :  and subprograms used to model digital components at
--             :  the RTL level.
--             :  
-- Comments    : 
--             :
-- Assumptions : none
-- Limitations : none
-- Known Errors: none
-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- Mentor Graphics Corporation owns the sole copyright to this software.
-- Under International Copyright laws you (1) may not make a copy of this
-- software except for the purposes of maintaining a single archive copy, 
-- (2) may not derive works herefrom, (3) may not distribute this work to
-- others. These rights are provided for information clarification, 
-- other restrictions of rights may apply as well.
--
-- This is an "Unpublished" work.
-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>> License   NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- This software is further protected by specific source code and/or
-- object code licenses provided by Mentor Graphics Corporation. Use of this
-- software other than as provided in the licensing agreement constitues
-- an infringement. No modification or waiver of any right(s) shall be 
-- given other than by the written authorization of an officer of The 
-- Mentor Graphics Corporation.
-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>> Proprietary Information <<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- This source code contains proprietary information of Mentor Graphics 
-- Corporation and shall not be disclosed other than as provided in the software
-- licensing agreement.
-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>> Warrantee <<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- Mentor Graphics Corporation MAKES NO WARRANTY OF ANY KIND WITH REGARD TO 
-- THE USE OF THIS SOFTWARE, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS
-- FOR A PARTICULAR PURPOSE.
-- ----------------------------------------------------------------------------
--  Version No:  |    Author:    |  Mod. Date:| Changes Made:
--     v1.000    | M.K. Dhodhi   |  10/01/91  | Production Release
--     v1.100    | M.K. Dhodhi   |  12/17/91  | adding procedures to handle signals. 
--               |               |            | Adding ZeroDivide flag in RegDiv,
--                                            | RegMod, RegRem procedures.
--     v1.110    | M.K. Dhodhi   |  03/06/92  | production release
--     v1.200    | M.K. Dhodhi   |  04/21/92  | stand alone version 
--     v1.210    | M.K. Dhodhi   |  07/10/92  | fixing Mem-alloc bug for synopsys
--     v1.300    | M.K. Dhodhi   |  08/03/92  | production release
--     v1.400    | M.K. Dhodhi   |  11/06/92  |Fixed compare. No need to 
--                               |            |complement MSB for Unsigned.
--     v1.500    | M.K. Dhodhi   |  11/17/92  | production release
--     v1.600    | M.K. Dhodhi   |  02/11/93  | fixed To_StdUlogicVector,
--                                            | To_StdLogicVector, To_BitVector
--     v1.610    | W.R. Migatz   |  04/14/93  | production release - no change from v1.60
--     v1.700 B  | W.R. Migatz   |  05/3/93   | Beta release - no change from v1.60
--     v1.700    | W.R. Migatz   |  05/25/93  | production release - no changes
--     v1.800    | W.R. Migatz   |  07/27/93  | mentor support and bug fix to compare function 
--                                            | to handle 2 zeros and to add don't cares into
--					      | RegEqual, RegNotEqual, =, and /=
--     v2.000    | W.R. Migatz   |  07/21/94  | Fixed bug in To_Integer (didn't work with 'L's 
--					      | or 'H's).  Added mixed (slv, sul), (sulv, sul), 
--					      | and (bv, bit) operators to the overloaded "+" 
--					      | and "-" operators.  Replaced RegShift with new
--					      | RegShift. - production release
--     v2.100    | W.R. Migatz   |  01/10/96  | Production release
--                                            | Initialization banner removed
--     v2.2      |  B. Caslis   |  07/25/96   | Updated for Mentor Graphics Release
-- -----------------------------------------------------------------------------
 
Library ieee;
Use     ieee.std_logic_1164.all; -- Reference the STD_Logic system

PACKAGE STD_Regpak is

 -- ************************************************************************
 -- Display Banner
 -- ************************************************************************
    CONSTANT StdRegpakBanner : BOOLEAN;

    -- ************************************************************************
    --
    -- ************************************************************************
    -------------------------------------------------------------------
    -- Provide for mathematical operations in popular formats
    -------------------------------------------------------------------
    TYPE regmode_type IS ( TwosComp, OnesComp, Unsigned, SignMagnitude );
 
    TYPE left_or_right is ( left, right );
    -------------------------------------------------------------------
    -- Commonly used registers
    -------------------------------------------------------------------
    SUBTYPE reg_64 is std_ulogic_vector ( 63 downto 0 );
    SUBTYPE reg_32 is std_ulogic_vector ( 31 downto 0 );
    SUBTYPE reg_16 is std_ulogic_vector ( 15 downto 0 );
    SUBTYPE reg_8  is std_ulogic_vector ( 7  downto 0 );
    SUBTYPE reg_4  is std_ulogic_vector ( 3  downto 0 );
    SUBTYPE reg_2  is std_ulogic_vector ( 1  downto 0 );
 
    CONSTANT WarningsOn     : Boolean;
    CONSTANT DefaultRegMode : regmode_type;
    CONSTANT max_string_len : INTEGER := 256;  -- for To_String
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "+" operator
    -- 1.3.3    
    --     Purpose       : Addition operator for logic vectors.
    --     
    --     Parameters    :     result            left              right
    --                       std_logic_vector    std_logic_vector  std_logic_vector
    --     
    --     NOTE          : Addition is performed in DefaultRegMode  which is set
    --                     to Two's complement. 
    --                     The operands may be of different length. The length of
    --                     the result equals the length of the longer operand.
    --     
    --                     Any overflow condition and carry_out is ignored
    --     
    --     Use           : 
    --                      VARIABLE a,b,c : std_logic_vector ( 7 downto 0 );
    --                      c := a + b;
    --                      c := a + B"0101";  -- c = a + 5;
    --                      c := a + B"101";   -- c = a + (-3)
    --
    --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    FUNCTION  "+" ( CONSTANT addend       : IN std_logic_vector;
                    CONSTANT augend       : IN std_logic_vector
                  ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "+" operator
    -- 1.3.4
    --     Purpose       : Addition operator for logic vectors.
    --
    --     Parameters    :     result         left                   right
    --                       std_logic_vector    std_logic_vector  Integer
    --
    --     NOTE          : The addition operation is performed assuming all
    --                     operands and results are in DefaultRegMode which
    --                     is set to Two's complement.
    --
    --                     The augend is converted to Std_logic_vector of length
    --                     equal to the addend. The length of 
    --                     the result equals the length of the addend.
    --
    --                     Any overflow condition is reported.
    --
    --     Use           :
    --                      VARIABLE a,c : std_logic_vector ( 7 downto 0 );
    --                      VARIABLE b: Integer; 
    --                      c := a + b;
    --                      c := a + 5;
    --
    --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    FUNCTION  "+" ( CONSTANT addend       : IN std_logic_vector;
                    CONSTANT augend       : IN Integer
                  ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "+" operator
    --  1.3.5
    --     Purpose       : Addition operator for logic vectors.
    --
    --     Parameters    :     result         left       right
    --                       std_logic_vector   Integer   std_logic_vector
    --
    --     NOTE          : The addition operation is performed assuming all
    --                     operands and results are 
    --                        
    --
    --                     The addend is converted to Std_logic_vector of length
    --                     equal to the augend. The length of 
    --                     the result equals the length of the augend
    --
    --                     Any overflow condition is ignored.
    --
    --     Use           :
    --                      VARIABLE a: Integer; 
    --                      VARIABLE b,c : std_logic_vector ( 7 downto 0 );
    --                      c := a + b;
    --                      c := 5 + b;
    --
    --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    FUNCTION  "+" ( CONSTANT addend       : IN Integer;
                    CONSTANT augend       : IN std_logic_vector
                  ) RETURN std_logic_vector;
     -------------------------------------------------------------------------------
     --     Function Name : Overloaded "+" operator
     -- 1.3.3    
     --     Purpose       : Addition operator for logic vectors.
     --     
     --     Parameters    :     result            left              right
     --                         std_logic_vector  std_logic_vector  std_ulogic
     --     
     --     NOTE          : Addition is performed in DefaultRegMode  which is set
     --                     to Two's complement. 
     --                     The length of the result equals the length of the left operand
     --     
     --                     Any overflow condition and carry_out is ignored
     --     
     --     Use           : 
     --                      VARIABLE a,c : std_logic_vector ( 7 downto 0 );
     --			     VARAIBLE b   : std_ulogic := '1';
     --                      c := a + b;
     --
     --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
     -------------------------------------------------------------------------------
     FUNCTION  "+" ( CONSTANT addend       : IN std_logic_vector;
		     CONSTANT augend       : IN std_ulogic
		   ) RETURN std_logic_vector;
     -------------------------------------------------------------------------------
     --     Function Name : Overloaded "+" operator
     -- 1.3.3    
     --     Purpose       : Addition operator for logic vectors.
     --     
     --     Parameters    :     result            left              right
     --                         std_logic_vector  std_ulogic	    std_logic_vector
     --     
     --     NOTE          : Addition is performed in DefaultRegMode  which is set
     --                     to Two's complement. 
     --                     The length of the result equals the length of the right operand
     --     
     --                     Any overflow condition and carry_out is ignored
     --     
     --     Use           : 
     --                      VARIABLE b, c : std_logic_vector ( 7 downto 0 );
     --			     VARIABLE a   : std_ulogic
     --                      c := a + b;
     --
     --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
     -------------------------------------------------------------------------------
     FUNCTION  "+" ( CONSTANT addend       : IN std_ulogic;
		     CONSTANT augend       : IN std_logic_vector
		   ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "+" operator
    --     
    --     Purpose       : Addition operator for std_ulogic_vectors.
    --     
    --     Parameters    :     result            left              right
    --                     std_ulogic_vector  std_ulogic_vector  std_ulogic_vector
    --     
    --     NOTE          : Addition is performed in DefaultRegMode  which is set
    --                     to Two's complement. 
    --                     The operands may be of different length. The length of
    --                     the result equals the length of the longer operand.
    --     
    --                     Any overflow condition and carry_out is ignored
    --     
    --     Use           : 
    --                      VARIABLE a,b,c : std_ulogic_vector ( 7 downto 0 );
    --                      c := a + b;
    --                      c := a + B"0101";  -- c = a + 5;
    --                      c := a + B"101";   -- c = a + (-3)
    --
    --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    FUNCTION  "+" ( CONSTANT addend       : IN std_ulogic_vector;
                    CONSTANT augend       : IN std_ulogic_vector
                  ) RETURN std_ulogic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "+" operator
    -- 
    --     Purpose       : Addition operator for std_ulogic vectors.
    --
    --     Parameters    :     result         left                   right
    --                    std_ulogic_vector  std_ulogic_vector    Integer
    --
    --     NOTE          : The addition operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The augend is converted to Std_ulogic_vector of length
    --                     equal to the addend. The length of 
    --                     the result equals the length of the addend.
    --
    --                     Any overflow condition is reported.
    --
    --     Use           :
    --                      VARIABLE a,c : std_ulogic_vector ( 7 downto 0 );
    --                      VARIABLE b: Integer; 
    --                      c := a + b;
    --                      c := a + 5;
    --
    --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    FUNCTION  "+" ( CONSTANT addend       : IN std_ulogic_vector;
                    CONSTANT augend       : IN Integer
                  ) RETURN std_ulogic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "+" operator
    --  
    --     Purpose       : Addition operator for std_ulogic vectors.
    --
    --     Parameters    :     result         left       right
    --                    std_ulogic_vector   Integer   std_ulogic_vector
    --
    --     NOTE          : The addition operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The addend is converted to Std_ulogic_vector of length
    --                     equal to the augend. The length of 
    --                     the result equals the length of the augend
    --
    --                     Any overflow condition is ignored.
    --
    --     Use           :
    --                      VARIABLE a: Integer; 
    --                      VARIABLE b,c : std_ulogic_vector ( 7 downto 0 );
    --                      c := a + b;
    --                      c := 5 + b;
    --
    --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    FUNCTION  "+" ( CONSTANT addend       : IN Integer;
                    CONSTANT augend       : IN std_ulogic_vector
                  ) RETURN std_ulogic_vector;
     -------------------------------------------------------------------------------
     --     Function Name : Overloaded "+" operator
     -- 1.3.3    
     --     Purpose       : Addition operator for std_ulogic_vectors.
     --     
     --     Parameters    :     result            left              right
     --                     std_ulogic_vector  std_ulogic_vector  std_ulogic
     --     
     --     NOTE          : Addition is performed in DefaultRegMode  which is set
     --                     to Two's complement. 
     --			    The length of the result equals the length of the left
     --                     operator.
     --     
     --                     Any overflow condition and carry_out is ignored
     --     
     --     Use           : 
     --                      VARIABLE a, c : std_ulogic_vector ( 7 downto 0 );
     --			     VARIABLE b : std_ulogic;
     --                      c := a + b;
     --
     --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
     -------------------------------------------------------------------------------
     FUNCTION  "+" ( CONSTANT addend       : IN std_ulogic_vector;
		     CONSTANT augend       : IN std_ulogic
		   ) RETURN std_ulogic_vector;
     -------------------------------------------------------------------------------
     --     Function Name : Overloaded "+" operator
     -- 1.3.3    
     --     Purpose       : Addition operator for std_ulogic_vectors.
     --     
     --     Parameters    :     result            left              right
     --                     std_ulogic_vector  std_ulogic	  std_ulogic_vector
     --     
     --     NOTE          : Addition is performed in DefaultRegMode  which is set
     --                     to Two's complement. 
     --			    The length of the result equals the length of the right
     --                     operator.
     --     
     --                     Any overflow condition and carry_out is ignored
     --     
     --     Use           : 
     --                      VARIABLE b, c : std_ulogic_vector ( 7 downto 0 );
     --			     VARIABLE a : std_ulogic;
     --                      c := a + b;
     --
     --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
     -------------------------------------------------------------------------------
     FUNCTION  "+" ( CONSTANT addend       : IN std_ulogic;
		     CONSTANT augend       : IN std_ulogic_vector
		   ) RETURN std_ulogic_vector;
    ---------------------------------------------------------------------------------
    --     Function Name : Overloaded "+" operator
    -- 1.3.6 
    --     Purpose       : Addition operator for bit vectors.
    --
    --     Parameters    :     result         left       right
    --                        bit_vector    bit_vector   bit_vector 
    --
    --     NOTE          : The addition operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The operands may be of different length. The length of
    --                     the result equals the length of the longer operand.
    --
    --                     Any overflow condition is ignored.
    --
    --     Use           :
    --                      VARIABLE a,b,c : bit_vector ( 7 downto 0 );
    --                      c := a + b;
    --                      c := a + B"0101";  -- c = a + 5;
    --                      c := a + B"101";   -- c = a + (-3)
    --
    --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
   -------------------------------------------------------------------------------
    FUNCTION  "+" ( CONSTANT addend       : IN bit_vector;
                    CONSTANT augend       : IN bit_vector
                  ) RETURN bit_vector;
    ---------------------------------------------------------------------------------
    --     Function Name : Overloaded "+" operator
    -- 1.3.7
    --     Purpose       : Addition operator for bit vectors.
    --
    --     Parameters    :     result         left       right
    --                        bit_vector    bit_vector   Integer 
    --
    --     NOTE          : The addition operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The augend is converted to bit_vector of length
    --                     equal to the addend. The length of 
    --                     the result equals the length of the addend.
    --
    --                     Any overflow condition is ignored.
    --
    --     Use           :
    --                      VARIABLE a,c : bit_vector ( 7 downto 0 );
    --                      VARIABLE b: Integer; 
    --                      c := a + b;
    --                      c := a + 5;
    --
    --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
   -------------------------------------------------------------------------------
    FUNCTION  "+" ( CONSTANT addend       : IN bit_vector;
                    CONSTANT augend       : IN Integer
                  ) RETURN bit_vector;
    ---------------------------------------------------------------------------------
    --     Function Name : Overloaded "+" operator
    -- 1.3.8
    --     Purpose       : Addition operator for bit vectors.
    --
    --     Parameters    :     result         left       right
    --                        bit_vector    Integer   bit_vector 
    --
    --     NOTE          : The addition operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The addend is converted to bit_vector of length
    --                     equal to the augend. The length of 
    --                     the result equals the length of the augend
    --
    --                     Any overflow condition is ignored.
    --
    --     Use           :
    --                      VARIABLE a: Integer; 
    --                      VARIABLE b,c : bit_vector ( 7 downto 0 );
    --                      c := a + b;
    --                      c := 5 + b; 
    --
    --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
   -------------------------------------------------------------------------------
    FUNCTION  "+" ( CONSTANT addend       : IN Integer;
                    CONSTANT augend       : IN bit_vector
                  ) RETURN bit_vector;
     ---------------------------------------------------------------------------------
     --     Function Name : Overloaded "+" operator
     -- 1.3.6 
     --     Purpose       : Addition operator for bit vectors.
     --
     --     Parameters    :     result         left       right
     --                        bit_vector    bit_vector   bit
     --
     --     NOTE          : The addition operation is performed assuming all
     --                     operands and results are signed Two's complement integers.
     --
     --                     The length of the result equals the length of the left
     --                     operand.
     --
     --                     Any overflow condition is ignored.
     --
     --     Use           :
     --                      VARIABLE a, c : bit_vector ( 7 downto 0 );
     --			     VARIABLE b    : bit;
     --                      c := a + b;
     --
     --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
     FUNCTION  "+" ( CONSTANT addend       : IN bit_vector;
		     CONSTANT augend       : IN bit
		   ) RETURN bit_vector;
     ---------------------------------------------------------------------------------
     --     Function Name : Overloaded "+" operator
     -- 1.3.6 
     --     Purpose       : Addition operator for bit vectors.
     --
     --     Parameters    :     result         left       right
     --                         bit_vector     bit	  bit_vector
     --
     --     NOTE          : The addition operation is performed assuming all
     --                     operands and results are signed Two's complement integers.
     --
     --                     The length of the result equals the length of the right
     --                     operand.
     --
     --                     Any overflow condition is ignored.
     --
     --     Use           :
     --                      VARIABLE b, c : bit_vector ( 7 downto 0 );
     --			     VARIABLE a    : bit;
     --                      c := a + b;
     --
     --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
     FUNCTION  "+" ( CONSTANT addend       : IN bit;
		     CONSTANT augend       : IN bit_vector
		   ) RETURN bit_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "-" operator
    -- 1.3.11    
    --     Purpose       : Subtraction operator for logic vectors.
    --     
    --     Parameters    :     result         left       right
    --                       std_logic_vector    std_logic_vector  std_logic_vector
    --     
    --     NOTE          : The subtraction operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The operands may be of different length. The length of
    --                     the result equals the length of the longer operand.
    --     
    --                     Any underflow condition is ignored.
    --     
    --     Use           : 
    --                      VARIABLE a,b,c : std_logic_vector ( 7 downto 0 );
    --                      c := a - b;
    --                      c := a - B"0101";  -- c = a - 5;
    --                      c := a - B"101";   -- c = a - (-3)
    --     
    --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    FUNCTION  "-" ( CONSTANT minuend      : IN std_logic_vector;
                    CONSTANT subtrahend   : IN std_logic_vector
                  ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "-" operator
    -- 1.3.12
    --     Purpose       : Subtraction operator for logic vectors.
    --
    --     Parameters    :     result         left       right
    --                       std_logic_vector    INTEGER  std_logic_vector
    --
    --     NOTE          : The subtraction operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The minuend is converted to std_logic_vector of length
    --                     equal to the subtrahend. The length of the result
    --                     equals the length of the subtrahend.
    --
    --                     Any overflow condition is ignored.
    --
    --     Use           :
    --                      VARIABLE a: Integer;
    --                      VARIABLE b,c : std_logic_vector ( 7 downto 0 );
    --                      c := a - b;
    --                      c := 5 - b;
    --
    --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    FUNCTION  "-" ( CONSTANT minuend      : IN Integer;
                    CONSTANT subtrahend   : IN std_logic_vector
                  ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "-" operator
    -- 1.3.13
    --     Purpose       : Subtraction operator for logic vectors.
    --
    --     Parameters    :     result         left       right
    --                       std_logic_vector    std_logic_vector  Integer
    --
    --     NOTE          : The subtraction operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The subtrahend is converted to std_logic_vector of length
    --                     equal to the minuend. The length of the result
    --                     equals the length of the minuend.
    --
    --                     Any overflow condition is ignored.
    --
    --     Use           :
    --                      VARIABLE a,c : std_logic_vector ( 7 downto 0 );
    --                      VARIABLE b: Integer;
    --                      c := a - b;
    --                      c := a - 5;
    --
    --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    FUNCTION  "-" ( CONSTANT minuend      : IN std_logic_vector;
                    CONSTANT subtrahend   : IN Integer
                  ) RETURN std_logic_vector;
     -------------------------------------------------------------------------------
     --     Function Name : Overloaded "-" operator
     -- 1.3.11    
     --     Purpose       : Subtraction operator for logic vectors.
     --     
     --     Parameters    :     result            left              right
     --                       std_logic_vector    std_logic_vector  std_ulogic
     --     
     --     NOTE          : The subtraction operation is performed assuming all
     --                     operands and results are signed Two's complement integers.
     --
     --                     The length of the result equals the length of the left 
     --                     operand.
     --     
     --                     Any underflow condition is ignored.
     --     
     --     Use           : 
     --                      VARIABLE a, c : std_logic_vector ( 7 downto 0 );
     --			     VARIABLE b    : std_ulogic;
     --                      c := a - b;
     --     
     --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
     -------------------------------------------------------------------------------
     FUNCTION  "-" ( CONSTANT minuend      : IN std_logic_vector;
		     CONSTANT subtrahend   : IN std_ulogic
		   ) RETURN std_logic_vector;
     -------------------------------------------------------------------------------
     --     Function Name : Overloaded "-" operator
     -- 1.3.11    
     --     Purpose       : Subtraction operator for logic vectors.
     --     
     --     Parameters    :     result            left              right
     --                       std_logic_vector    std_ulogic	    std_logic_vector
     --     
     --     NOTE          : The subtraction operation is performed assuming all
     --                     operands and results are signed Two's complement integers.
     --
     --                     The length of the result equals the length of the right 
     --                     operand.
     --     
     --                     Any underflow condition is ignored.
     --     
     --     Use           : 
     --                      VARIABLE b, c : std_logic_vector ( 7 downto 0 );
     --			     VARIABLE a    : std_ulogic;
     --                      c := a - b;
     --     
     --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
     -------------------------------------------------------------------------------
     FUNCTION  "-" ( CONSTANT minuend      : IN std_ulogic;
		     CONSTANT subtrahend   : IN std_logic_vector
		   ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "-" operator
    --     
    --     Purpose       : Subtraction operator for ulogic vectors.
    --     
    --     Parameters    :     result         left                right
    --                    std_ulogic_vector  std_ulogic_vector  std_ulogic_vector
    --     
    --     NOTE          : The subtraction operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The operands may be of different length. The length of
    --                     the result equals the length of the longer operand.
    --     
    --                     Any underflow condition is ignored.
    --     
    --     Use           : 
    --                      VARIABLE a,b,c : std_ulogic_vector ( 7 downto 0 );
    --                      c := a - b;
    --                      c := a - B"0101";  -- c = a - 5;
    --                      c := a - B"101";   -- c = a - (-3)
    --     
    --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    FUNCTION  "-" ( CONSTANT minuend      : IN std_ulogic_vector;
                    CONSTANT subtrahend   : IN std_ulogic_vector
                  ) RETURN std_ulogic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "-" operator
    -- 1.3.12
    --     Purpose       : Subtraction operator for ulogic vectors.
    --
    --     Parameters    :     result         left       right
    --                    std_ulogic_vector  INTEGER  std_ulogic_vector
    --
    --     NOTE          : The subtraction operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The minuend is converted to std_ulogic_vector of length
    --                     equal to the subtrahend. The length of the result
    --                     equals the length of the subtrahend.
    --
    --                     Any overflow condition is ignored.
    --
    --     Use           :
    --                      VARIABLE a: Integer;
    --                      VARIABLE b,c : std_logic_vector ( 7 downto 0 );
    --                      c := a - b;
    --                      c := 5 - b;
    --
    --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    FUNCTION  "-" ( CONSTANT minuend      : IN Integer;
                    CONSTANT subtrahend   : IN std_ulogic_vector
                  ) RETURN std_ulogic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "-" operator
    -- 1.3.13
    --     Purpose       : Subtraction operator for ulogic vectors.
    --
    --     Parameters    :     result         left              right
    --                     std_ulogic_vector std_ulogic_vector  Integer
    --
    --     NOTE          : The subtraction operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The subtrahend is converted to std_ulogic_vector of length
    --                     equal to the minuend. The length of the result
    --                     equals the length of the minuend.
    --
    --                     Any overflow condition is ignored.
    --
    --     Use           :
    --                      VARIABLE a,c : std_ulogic_vector ( 7 downto 0 );
    --                      VARIABLE b: Integer;
    --                      c := a - b;
    --                      c := a - 5;
    --
    --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    FUNCTION  "-" ( CONSTANT minuend      : IN std_ulogic_vector;
                    CONSTANT subtrahend   : IN Integer
                  ) RETURN std_ulogic_vector;
     -------------------------------------------------------------------------------
     --     Function Name : Overloaded "-" operator
     -- 1.3.11    
     --     Purpose       : Subtraction operator for logic vectors.
     --     
     --     Parameters    :     result            left              right
     --                       std_ulogic_vector   std_ulogic_vector std_ulogic
     --     
     --     NOTE          : The subtraction operation is performed assuming all
     --                     operands and results are signed Two's complement integers.
     --
     --                     The length of the result equals the length of the left 
     --                     operand.
     --     
     --                     Any underflow condition is ignored.
     --     
     --     Use           : 
     --                      VARIABLE a, c : std_ulogic_vector ( 7 downto 0 );
     --			     VARIABLE b    : std_ulogic;
     --                      c := a - b;
     --     
     --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
     -------------------------------------------------------------------------------
     FUNCTION  "-" ( CONSTANT minuend      : IN std_ulogic_vector;
		     CONSTANT subtrahend   : IN std_ulogic
		   ) RETURN std_ulogic_vector;
     -------------------------------------------------------------------------------
     --     Function Name : Overloaded "-" operator
     -- 1.3.11    
     --     Purpose       : Subtraction operator for logic vectors.
     --     
     --     Parameters    :     result            left              right
     --                       std_ulogic_vector   std_ulogic	    std_ulogic_vector
     --     
     --     NOTE          : The subtraction operation is performed assuming all
     --                     operands and results are signed Two's complement integers.
     --
     --                     The length of the result equals the length of the right 
     --                     operand.
     --     
     --                     Any underflow condition is ignored.
     --     
     --     Use           : 
     --                      VARIABLE b, c : std_ulogic_vector ( 7 downto 0 );
     --			     VARIABLE a    : std_ulogic;
     --                      c := a - b;
     --     
     --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
     -------------------------------------------------------------------------------
     FUNCTION  "-" ( CONSTANT minuend      : IN std_ulogic;
		     CONSTANT subtrahend   : IN std_ulogic_vector
		   ) RETURN std_ulogic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "-" operator
    -- 1.3.14 
    --     Purpose       : Subtraction operator for bit vectors.
    --
    --     Parameters    :     result         left       right
    --                       bit_vector    bit_vector  bit_vector
    --
    --     NOTE          : The subtraction operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The operands may be of different length. The length of
    --                     the result equals the length of the longer operand.
    --
    --                     Any underflow condition is ignored.
    --
    --     Use           :
    --                      VARIABLE a,b,c : bit_vector ( 7 downto 0 );
    --                      c := a - b;
    --                      c := a - B"0101";  -- c = a - 5;
    --                      c := a - B"101";   -- c = a - (-3)
    --
    --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    FUNCTION  "-" ( CONSTANT minuend      : IN bit_vector;
                    CONSTANT subtrahend   : IN bit_vector
                  ) RETURN bit_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "-" operator
    -- 1.3.15
    --     Purpose       : Subtraction operator for logic vectors.
    --
    --     Parameters    :     result         left       right
    --                       bit_vector    bit_vector  Integer
    --
    --     NOTE          : The subtraction operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The subtrahend is converted to bit_vector of length
    --                     equal to the minuend. The length of the result
    --                     equals the length of the minuend.
    --
    --                     Any overflow condition is ignored.
    --
    --     Use           :
    --                      VARIABLE a,c : bit_vector ( 7 downto 0 );
    --                      VARIABLE b: Integer;
    --                      c := a - b;
    --                      c := a - 5;
    --
    --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    FUNCTION  "-" ( CONSTANT minuend      : IN bit_vector;
                    CONSTANT subtrahend   : IN Integer
                  ) RETURN bit_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "-" operator
    -- 1.3.16
    --     Purpose       : Subtraction operator for bit vectors.
    --
    --     Parameters    :     result         left       right
    --                       bit_vector    INTEGER  bit_vector
    --
    --     NOTE          : The subtraction operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The minuend is converted to bit_vector of length
    --                     equal to the subtrahend. The length of the result
    --                     equals the length of the subtrahend.
    --
    --                     Any overflow condition is ignored.
    --
    --     Use           :
    --                      VARIABLE a: Integer;
    --                      VARIABLE b,c : bit_vector ( 7 downto 0 );
    --                      c := a - b;
    --                      c := 5 - b;
    --
    --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    FUNCTION  "-" ( CONSTANT minuend      : IN Integer;
                    CONSTANT subtrahend   : IN bit_vector
                  ) RETURN bit_vector;
     -------------------------------------------------------------------------------
     --     Function Name : Overloaded "-" operator
     -- 1.3.11    
     --     Purpose       : Subtraction operator for logic vectors.
     --     
     --     Parameters    :     result            left              right
     --                         bit_vector        bit_vector	    bit
     --     
     --     NOTE          : The subtraction operation is performed assuming all
     --                     operands and results are signed Two's complement integers.
     --
     --                     The length of the result equals the length of the left 
     --                     operand.
     --     
     --                     Any underflow condition is ignored.
     --     
     --     Use           : 
     --                      VARIABLE a, c : bit_vector ( 7 downto 0 );
     --			     VARIABLE b    : bit;
     --                      c := a - b;
     --     
     --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
     -------------------------------------------------------------------------------
     FUNCTION  "-" ( CONSTANT minuend      : IN bit_vector;
		     CONSTANT subtrahend   : IN bit
		   ) RETURN bit_vector;
     -------------------------------------------------------------------------------
     --     Function Name : Overloaded "-" operator
     -- 1.3.11    
     --     Purpose       : Subtraction operator for logic vectors.
     --     
     --     Parameters    :     result            left              right
     --				bit_vector        bit		    bit_vector
     --     
     --     NOTE          : The subtraction operation is performed assuming all
     --                     operands and results are signed Two's complement integers.
     --
     --                     The length of the result equals the length of the right 
     --                     operand.
     --     
     --                     Any underflow condition is ignored.
     --     
     --     Use           : 
     --                      VARIABLE b, c : bit_vector ( 7 downto 0 );
     --			     VARIABLE a    : bit;
     --                      c := a - b;
     --     
     --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
     -------------------------------------------------------------------------------
     FUNCTION  "-" ( CONSTANT minuend      : IN bit;
		     CONSTANT subtrahend   : IN bit_vector
		   ) RETURN bit_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "-" operator
    -- 1.4.5
    --     Purpose       : Unary minus operator for bit vectors.
    --
    --     Parameters    :     result         v 
    --                       bit_vector    bit_vector 
    --
    --     NOTE          : The  minus  operation is performed assuming 
    --                     operand and result are signed Two's complement integers.
    --
    --     Use           :
    --                      VARIABLE a,c : bit_vector ( 7 downto 0 );
    --                      c :=  - a;
    --
    --     See Also      :  RegNegate
    -------------------------------------------------------------------------------
    FUNCTION "-"  (CONSTANT subtrahend   : IN bit_vector
                  ) RETURN bit_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "-" operator
    -- 1.4.6
    --     Purpose       : Unary minus operator for logic vectors.
    --
    --     Parameters    :     result              operand 
    --                       std_logic_vector    std_logic_vector 
    --
    --     NOTE          : The  minus  operation is performed assuming 
    --                     operand and result are in signed Two's complement notation.
    --
    --     Use           :
    --                      VARIABLE a,c : std_logic_vector ( 7 downto 0 );
    --                      c :=  - a;
    --
    --     See Also      :  RegNegate
    -------------------------------------------------------------------------------
    FUNCTION "-"  (CONSTANT subtrahend   : IN std_logic_vector
                  ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "-" operator
    --
    --     Purpose       : Unary minus operator for ulogic vectors.
    --
    --     Parameters    :     result              operand 
    --                       std_ulogic_vector    std_ulogic_vector 
    --
    --     NOTE          : The  minus  operation is performed assuming 
    --                     operand and result are in signed Two's complement notation.
    --
    --     Use           :
    --                      VARIABLE a,c : std_ulogic_vector ( 7 downto 0 );
    --                      c :=  - a;
    --
    --     See Also      :  RegNegate
    -------------------------------------------------------------------------------
    FUNCTION "-"  (CONSTANT subtrahend   : IN std_ulogic_vector
                  ) RETURN std_ulogic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "*" operator
    --    
    --     Purpose       : Multiplication operator for logic vectors.
    --     
    --     Parameters    :     result         left       right
    --                       std_logic_vector    std_logic_vector  std_logic_vector
    --     
    --     NOTE          : The multiplication operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The operands may be of different length. The length of
    --                     the result equals the length of the longer operand.
    --     
    --                     A temporary result is computed of sufficient length
    --                     to avoid overflow. The high order bits of this temporary
    --                     vector are truncated to form the required length result.
    --                     No indication is given if the magnitude of the computed
    --                     result exceeds the size of the returned result vector.
    --     
    --     Use           : 
    --                      VARIABLE a,b,c : std_logic_vector ( 7 downto 0 );
    --                      c := a * b;
    --                      c := a * B"1101";  -- c = a * (-3)
    --     
    --     See Also      : RegMult, RegDiv
    -------------------------------------------------------------------------------
    FUNCTION  "*" ( CONSTANT multiplicand : IN std_logic_vector;
                    CONSTANT multiplier   : IN std_logic_vector
                  ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "*" operator
    -- 1.5.4
    --     Purpose       : Multiplication operator for logic vectors.
    --
    --     Parameters    :     result           left                right
    --                       std_logic_vector    std_logic_vector  Integer
    --
    --     NOTE          : The multiplication operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The multiplier is converted to std_logic_vector of length
    --                     equal to the multiplicand. The length of the result
    --                     equals the length of the multiplicand.
 
    --
    --                     A temporary result is computed of sufficient length
    --                     to avoid overflow. The high order bits of this temporary
    --                     vector are truncated to form the required length result.
    --                     No indication is given if the magnitude of the computed
    --                     result exceeds the size of the returned result vector.
    --
    --     Use           :
    --                      VARIABLE a,c : std_logic_vector ( 7 downto 0 );
    --                      VARIABLE b: Integer;
    --                      c := a * b;
    --                      c := a * 5; 
    --
    --     See Also      : RegMult, RegDiv
  -------------------------------------------------------------------------------
    FUNCTION  "*" ( CONSTANT multiplicand : IN std_logic_vector;
                    CONSTANT multiplier   : IN Integer
                  ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "*" operator
    -- 1.5.5
    --     Purpose       : Multiplication operator for logic vectors.
    --
    --     Parameters    :     result           left                right
    --                       std_logic_vector    Integer     std_logic_vector
    --
    --     NOTE          : The multiplication operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The multiplicand is converted to std_logic_vector of length
    --                     equal to the multiplier. The length of the result
    --                     equals the length of the multiplier.
 
    --
    --                     A temporary result is computed of sufficient length
    --                     to avoid overflow. The high order bits of this temporary
    --                     vector are truncated to form the required length result.
    --                     No indication is given if the magnitude of the computed
    --                     result exceeds the size of the returned result vector.
    --
    --     Use           :
    --                      VARIABLE a,c : std_logic_vector ( 7 downto 0 );
    --                      VARIABLE b: Integer;
    --                      c := a * b;
    --                      c := a * 5; 
    --
    --     See Also      : RegMult, RegDiv
    -------------------------------------------------------------------------------
    FUNCTION  "*" ( CONSTANT multiplicand : IN Integer;
                    CONSTANT multiplier   : IN std_logic_vector
                  ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "*" operator
    --    
    --     Purpose       : Multiplication operator for ulogic vectors.
    --     
    --     Parameters    :     result         left       right
    --                    std_ulogic_vector    std_ulogic_vector  std_ulogic_vector
    --     
    --     NOTE          : The multiplication operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The operands may be of different length. The length of
    --                     the result equals the length of the longer operand.
    --     
    --                     A temporary result is computed of sufficient length
    --                     to avoid overflow. The high order bits of this temporary
    --                     vector are truncated to form the required length result.
    --                     No indication is given if the magnitude of the computed
    --                     result exceeds the size of the returned result vector.
    --     
    --     Use           : 
    --                      VARIABLE a,b,c : std_ulogic_vector ( 7 downto 0 );
    --                      c := a * b;
    --                      c := a * B"1101";  -- c = a * (-3)
    --     
    --     See Also      : RegMult, RegDiv
    -------------------------------------------------------------------------------
    FUNCTION  "*" ( CONSTANT multiplicand : IN std_ulogic_vector;
                    CONSTANT multiplier   : IN std_ulogic_vector
                  ) RETURN std_ulogic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "*" operator
    -- 1.5.4
    --     Purpose       : Multiplication operator for logic vectors.
    --
    --     Parameters    :     result           left                right
    --                     std_ulogic_vector    std_ulogic_vector  Integer
    --
    --     NOTE          : The multiplication operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The multiplier is converted to std_ulogic_vector of length
    --                     equal to the multiplicand. The length of the result
    --                     equals the length of the multiplicand.
 
    --
    --                     A temporary result is computed of sufficient length
    --                     to avoid overflow. The high order bits of this temporary
    --                     vector are truncated to form the required length result.
    --                     No indication is given if the magnitude of the computed
    --                     result exceeds the size of the returned result vector.
    --
    --     Use           :
    --                      VARIABLE a,c : std_ulogic_vector ( 7 downto 0 );
    --                      VARIABLE b: Integer;
    --                      c := a * b;
    --                      c := a * 5; 
    --
    --     See Also      : RegMult, RegDiv
  -------------------------------------------------------------------------------
    FUNCTION  "*" ( CONSTANT multiplicand : IN std_ulogic_vector;
                    CONSTANT multiplier   : IN Integer
                  ) RETURN std_ulogic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "*" operator
    -- 1.5.5
    --     Purpose       : Multiplication operator for logic vectors.
    --
    --     Parameters    :     result           left                right
    --                       std_ulogic_vector    Integer     std_ulogic_vector
    --
    --     NOTE          : The multiplication operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The multiplicand is converted to std_ulogic_vector of length
    --                     equal to the multiplier. The length of the result
    --                     equals the length of the multiplier.
 
    --
    --                     A temporary result is computed of sufficient length
    --                     to avoid overflow. The high order bits of this temporary
    --                     vector are truncated to form the required length result.
    --                     No indication is given if the magnitude of the computed
    --                     result exceeds the size of the returned result vector.
    --
    --     Use           :
    --                      VARIABLE a,c : std_ulogic_vector ( 7 downto 0 );
    --                      VARIABLE b: Integer;
    --                      c := a * b;
    --                      c := a * 5; 
    --
    --     See Also      : RegMult, RegDiv
    -------------------------------------------------------------------------------
    FUNCTION  "*" ( CONSTANT multiplicand : IN Integer;
                    CONSTANT multiplier   : IN std_ulogic_vector
                  ) RETURN std_ulogic_vector;
--+-----------------------------------------------------------------------------
--|     Function Name : Overloaded "*" operator
--|
--|     Purpose       : Multiplication operator for bit vectors.
--|
--|     Parameters    :     result         left       right
--|                       BIT_VECTOR    BIT_VECTOR  BIT_VECTOR
--|
--|     NOTE          : The multiplication operation is performed assuming all
--|                     operands and results are signed Two's complement integers.
--|
--|                     The operands may be of different length. The length of
--|                     the result equals the length of the longer operand.
--|
--|                     A temporary result is computed of sufficient length
--|                     to avoid overflow. The high order bits of this temporary
--|                     vector are truncated to form the required length result.
--|                     No indication is given if the magnitude of the computed
--|                     result exceeds the size of the returned result vector.
--|
--|     Use           :
--|                      VARIABLE a,b,c : bit_vector ( 7 downto 0 );
--|                      c := a * b;
--|                      c := a * B"1101";  -- c = a * (-3)
--|
--|     See Also      : RegMult, RegDiv
--|-----------------------------------------------------------------------------
    FUNCTION  "*" ( CONSTANT multiplicand : IN BIT_VECTOR;
                    CONSTANT multiplier   : IN BIT_VECTOR
                  ) RETURN BIT_VECTOR;
--+-----------------------------------------------------------------------------
--|     Function Name : Overloaded "*" operator
--| 1.5.7
--|     Purpose       : Multiplication operator for bit vectors.
--|
--|     Parameters    :     result         left       right
--|                       BIT_VECTOR    BIT_VECTOR  INTEGER
--|
--|     NOTE          : The multiplication operation is performed assuming all
--|                     operands and results are signed Two's complement integers.
--|
--|                     The multiplier is converted to bit_vector of length
--|                     equal to the multiplicand. The length of the result
--|                     equals the length of the multiplicand.
--|
--|                     A temporary result is computed of sufficient length
--|                     to avoid overflow. The high order bits of this temporary
--|                     vector are truncated to form the required length result.
--|                     No indication is given if the magnitude of the computed
--|                     result exceeds the size of the returned result vector.
--|
--|     Use           :
--|                      VARIABLE a,c : BIT_VECTOR ( 7 downto 0 );
--|                      VARIABLE b: INTEGER;
--|                      c := a * b;
--|                      c := a * 5; 
--|
--|     See Also      : RegMult, RegDiv
--|-----------------------------------------------------------------------------
    FUNCTION  "*" ( CONSTANT multiplicand : IN BIT_VECTOR;
                    CONSTANT multiplier   : IN INTEGER
                  ) RETURN BIT_VECTOR;
--+-----------------------------------------------------------------------------
--|     Function Name : Overloaded "*" operator
--| 1.5.8
--|     Purpose       : Multiplication operator for bit vectors.
--|
--|     Parameters    :     result         left       right
--|                       BIT_VECTOR    INTEGER  BIT_VECTOR
--|
--|     NOTE          : The multiplication operation is performed assuming all
--|                     operands and results are signed Two's complement integers.
--|
--|                     The multiplicand is converted to BIT_VECTOR of length
--|                     equal to the multiplier. The length of the result
--|                     equals the length of the multiplier.
--|
--|                     A temporary result is computed of sufficient length
--|                     to avoid overflow. The high order bits of this temporary
--|                     vector are truncated to form the required length result.
--|                     No indication is given if the magnitude of the computed
--|                     result exceeds the size of the returned result vector.
--|
--|     Use           :
--|                      VARIABLE a : INTEGER;
--|                      VARIABLE b,c : BIT_VECTOR ( 7 downto 0 );
--|                      c := a * b;
--|                      c := 5 * b; 
--|
--|     See Also      : RegMult, RegDiv
--|-----------------------------------------------------------------------------
   FUNCTION  "*" ( CONSTANT multiplicand : IN INTEGER; 
                   CONSTANT multiplier   : IN BIT_VECTOR
                  ) RETURN BIT_VECTOR;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "/" operator
    --    
    --     Purpose       : Division operator for logic vectors.
    --     
    --     Parameters    :     result         left       right
    --                       std_logic_vector    std_logic_vector  std_logic_vector
    --     
    --     NOTE          : The division operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The operands may be of different length. The length of
    --                     the result equals the length of the longer operand.
    --     
    --                     Any remainder is ignored - no rounding is applied.
    --
    --                     An ASSERTION message of severity WARNING is issued
    --                     if division by 0 is attempted. In this case the
    --                     return value is 0 (all 0's).
    --     
    --     Use           : 
    --                      VARIABLE a,b,c : std_logic_vector ( 7 downto 0 );
    --                      c := a / b;
    --                      c := a / B"1101";  -- c = a / (-3)
    --     Se Also       : RegMult, RegDiv
    ---------------------------------------------------------------------------------
    FUNCTION  "/" ( CONSTANT dividend     : IN std_logic_vector;
                    CONSTANT divisor      : IN std_logic_vector
                  ) RETURN std_logic_vector;
    ---------------------------------------------------------------------------------
    --     Function Name : Overloaded "/" operator
    -- 1.5.12
    --     Purpose       : Division operator for logic vectors.
    --
    --     Parameters    :     result         left       right
    --                       std_logic_vector    std_logic_vector  INTEGER
    --
    --     NOTE          : The division operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The divisor is converted to std_logic_vector of length
    --                     equal to the dividend. The length of the result
    --                     equals the length of the dividend.
    --
    --                     Any remainder is ignored - no rounding is applied.
    --
    --                     An ASSERTION message of severity WARNING is issued
    --                     if division by 0 is attempted. In this case the
    --                     return value is 0 (all 0's).
    --
    --     Use           :
    --                      VARIABLE a,c : std_logic_vector ( 7 downto 0 );
    --                      VARIABLE b : INTEGER;
    --                      c := a / b;
    --                      c := a / 5; 
    --     Se Also       : RegMult, RegDiv
  --------------------------------------------------------------------------------
    FUNCTION  "/" ( CONSTANT dividend     : IN std_logic_vector;
                    CONSTANT divisor      : IN INTEGER
                  ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "/" operator
    -- 1.5.13
    --     Purpose       : Division operator for logic vectors.
    --
    --     Parameters    :     result         left       right
    --                       std_logic_vector    INTEGER  std_logic_vector
    --
    --     NOTE          : The division operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The dividend is converted to std_logic_vector of length
    --                     equal to the divisor. The length of the result
    --                     equals the length of the divisor.
    --
    --                     Any remainder is ignored - no rounding is applied.
    --
    --                     An ASSERTION message of severity WARNING is issued
    --                     if division by 0 is attempted. In this case the
    --                     return value is 0 (all 0's).
    --
    --     Use           :
    --                      VARIABLE a : INTEGER;
    --                      VARIABLE b,c : std_logic_vector ( 7 downto 0 );
    --                      c := a / b;
    --                      c := 5 / b;
    --     Se Also       : RegMult, RegDiv
    --------------------------------------------------------------------------------
    FUNCTION  "/" ( CONSTANT dividend     : IN INTEGER;
                    CONSTANT divisor      : IN std_logic_vector
                  ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "/" operator
    --    
    --     Purpose       : Division operator for ulogic vectors.
    --     
    --     Parameters    :     result         left       right
    --                       std_ulogic_vector    std_ulogic_vector  std_ulogic_vector
    --     
    --     NOTE          : The division operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The operands may be of different length. The length of
    --                     the result equals the length of the longer operand.
    --     
    --                     Any remainder is ignored - no rounding is applied.
    --
    --                     An ASSERTION message of severity WARNING is issued
    --                     if division by 0 is attempted. In this case the
    --                     return value is 0 (all 0's).
    --     
    --     Use           : 
    --                      VARIABLE a,b,c : std_ulogic_vector ( 7 downto 0 );
    --                      c := a / b;
    --                      c := a / B"1101";  -- c = a / (-3)
    --     Se Also       : RegMult, RegDiv
    -----------------------------------------------------------------------------------
    FUNCTION  "/" ( CONSTANT dividend     : IN std_ulogic_vector;
                    CONSTANT divisor      : IN std_ulogic_vector
                  ) RETURN std_ulogic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "/" operator
    -- 1.5.12
    --     Purpose       : Division operator for logic vectors.
    --
    --     Parameters    :     result         left       right
    --                       std_ulogic_vector    std_ulogic_vector  INTEGER
    --
    --     NOTE          : The division operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The divisor is converted to std_ulogic_vector of length
    --                     equal to the dividend. The length of the result
    --                     equals the length of the dividend.
    --
    --                     Any remainder is ignored - no rounding is applied.
    --
    --                     An ASSERTION message of severity WARNING is issued
    --                     if division by 0 is attempted. In this case the
    --                     return value is 0 (all 0's).
    --
    --     Use           :
    --                      VARIABLE a,c : std_ulogic_vector ( 7 downto 0 );
    --                      VARIABLE b : INTEGER;
    --                      c := a / b;
    --                      c := a / 5; 
    --     Se Also       : RegMult, RegDiv
    --------------------------------------------------------------------------------
    FUNCTION  "/" ( CONSTANT dividend     : IN std_ulogic_vector;
                    CONSTANT divisor      : IN INTEGER
                  ) RETURN std_ulogic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "/" operator
    -- 1.5.13
    --     Purpose       : Division operator for logic vectors.
    --
    --     Parameters    :     result         left       right
    --                       std_ulogic_vector    INTEGER  std_ulogic_vector
    --
    --     NOTE          : The division operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The dividend is converted to std_ulogic_vector of length
    --                     equal to the divisor. The length of the result
    --                     equals the length of the divisor.
    --
    --                     Any remainder is ignored - no rounding is applied.
    --
    --                     An ASSERTION message of severity WARNING is issued
    --                     if division by 0 is attempted. In this case the
    --                     return value is 0 (all 0's).
    --
    --     Use           :
    --                      VARIABLE a : INTEGER;
    --                      VARIABLE b,c : std_ulogic_vector ( 7 downto 0 );
    --                      c := a / b;
    --                      c := 5 / b;
    --     Se Also       : RegMult, RegDiv
    --------------------------------------------------------------------------------
    FUNCTION  "/" ( CONSTANT dividend     : IN INTEGER;
                    CONSTANT divisor      : IN std_ulogic_vector
                  ) RETURN std_ulogic_vector;
--+-----------------------------------------------------------------------------
--|     Function Name : Overloaded "/" operator
--| 1.5.14
--|     Purpose       : Division operator for bit vectors.  
--|     Parameters    :     result         left       right
--|                       BIT_VECTOR    BIT_VECTOR  BIT_VECTOR
--|
--|     NOTE          : The division operation is performed assuming all
--|                     operands and results are signed Two's complement integers.
--|
--|                     The operands may be of different length. The length of
--|                     the result equals the length of the longer operand.
--|
--|                     Any remainder is ignored - no rounding is applied.
--|
--|                     An ASSERTION message of severity WARNING is issued
--|                     if division by 0 is attempted. In this case the
--|                     return value is 0 (all 0's).
--|
--|
--|     Use           :
--|                      VARIABLE a,b,c : bit_vector ( 7 downto 0 );
--|                      c := a / b;
--|                      c := a / B"1101";  -- c = a / (-3)
--|
--|     See Also      : RegMult, RegDiv
--|-----------------------------------------------------------------------------
    FUNCTION  "/" ( CONSTANT dividend     : IN BIT_VECTOR;
                    CONSTANT divisor      : IN BIT_VECTOR
                  ) RETURN BIT_VECTOR;
--+-----------------------------------------------------------------------------
--|     Function Name : Overloaded "/" operator
--| 1.5.15
--|     Purpose       : Division operator for bit vectors.
--|     Parameters    :     result         left       right
--|                       BIT_VECTOR    BIT_VECTOR  INTEGER
--|
--|     NOTE          : The division operation is performed assuming all
--|                     operands and results are signed Two's complement integers.
--|
--|                     The divisor is converted to bit_vector of length
--|                     equal to the dividend. The length of the result
--|                     equals the length of the dividend.
--|
--|                     Any remainder is ignored - no rounding is applied.
--|
--|                     An ASSERTION message of severity WARNING is issued
--|                     if division by 0 is attempted. In this case the
--|                     return value is 0 (all 0's).
--|
--|
--|     Use           :
--|                      VARIABLE a,c : BIT_VECTOR ( 7 downto 0 );
--|                      VARIABLE b : INTEGER;
--|                      c := a / b;
--|                      c := a / 5;
--| 
--|     See Also      : RegMult, RegDiv
--|-----------------------------------------------------------------------------
    FUNCTION  "/" ( CONSTANT dividend     : IN BIT_VECTOR;
                    CONSTANT divisor      : IN INTEGER
                  ) RETURN BIT_VECTOR;
--+-----------------------------------------------------------------------------
--|     Function Name : Overloaded "/" operator
--| 1.5.16
--|     Purpose       : Division operator for bit vectors.
--|     Parameters    :     result         left       right
--|                       BIT_VECTOR    INTEGER  BIT_VECTOR
--|
--|     NOTE          : The division operation is performed assuming all
--|                     operands and results are signed Two's complement integers.
--|
--|                     The dividend is converted to bit_vector of length
--|                     equal to the divisor. The length of the result
--|                     equals the length of the divisor.
--|
--|                     Any remainder is ignored - no rounding is applied.
--|
--|                     An ASSERTION message of severity WARNING is issued
--|                     if division by 0 is attempted. In this case the
--|                     return value is 0 (all 0's).
--|
--|
--|     Use           :
--|                      VARIABLE a : INTEGER;
--|                      VARIABLE b,c : BIT_VECTOR ( 7 downto 0 );
--|                      c := a / b;
--|                      c := 5 / b;
--|
--|     See Also      : RegMult, RegDiv
--|-----------------------------------------------------------------------------
    FUNCTION  "/" ( CONSTANT dividend     : IN INTEGER;
                    CONSTANT divisor      : IN BIT_VECTOR
                  ) RETURN BIT_VECTOR;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "mod" operator
    -- 1.5.19
    --     Purpose       : Modulus operator for logic vectors.
    --
    --     Parameters    :     result         left       right
    --                       std_logic_vector    std_logic_vector  std_logic_vector
    --
    --     NOTE          : The modulus operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The operands may be of different length. The length of
    --                     the result equals the length of the longer operand.
    --
    --                     An ASSERTION message of severity WARNING is issued
    --                     if division by 0 is attempted. In this case the
    --                     return value is 0 (all 0's).
    --
    --     Use           :
    --                      VARIABLE a,b,c : std_logic_vector ( 7 downto 0 );
    --                      c := a mod b;
    --                      c := a mod B"1101";  -- c = a / (-3)
    --     Se Also       : RegRem, RegDiv
   ----------------------------------------------------------------------------------
    FUNCTION  "mod" ( CONSTANT dividend     : IN std_logic_vector;
                      CONSTANT modulus      : IN std_logic_vector
                    ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "mod" operator
    -- 1.5.20
    --     Purpose       : Modulus operator for logic vectors.
    --
    --     Parameters    :     result         left       right
    --                       std_logic_vector    std_logic_vector  INTEGER
    --
    --     NOTE          : The modulus operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The modulus is converted to std_logic_vector of length
    --                     equal to the dividend. The length of the result
    --                     equals the length of the dividend.
    --
    --                     An ASSERTION message of severity WARNING is issued
    --                     if division by 0 is attempted. In this case the
    --                     return value is 0 (all 0's).
    --
    --     Use           :
    --                      VARIABLE a,c : std_logic_vector ( 7 downto 0 );
    --                      VARIABLE b : INTEGER;
    --                      c := a mod b;
    --                      c := a mod 5;
    --     Se Also       : RegRem, RegDiv
    --------------------------------------------------------------------------------
    FUNCTION  "mod" ( CONSTANT dividend     : IN std_logic_vector;
                      CONSTANT modulus      : IN INTEGER
                    ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "mod" operator
    -- 1.5.21
    --     Purpose       : Modulus operator for logic vectors.
    --
    --     Parameters    :     result         left       right
    --                       std_logic_vector    INTEGER  std_logic_vector
    --
    --     NOTE          : The modulus operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The dividend is converted to std_logic_vector of length
    --                     equal to the modulus. The length of the result
    --                     equals the length of the modulus.
    --
    --                     An ASSERTION message of severity WARNING is issued
    --                     if division by 0 is attempted. In this case the
    --                     return value is 0 (all 0's).
    --
    --     Use           :
    --                      VARIABLE a : INTEGER;
    --                      VARIABLE b,c : std_logic_vector ( 7 downto 0 );
    --                      c := a mod b;
    --                      c := 5 mod b;
    --     Se Also       : RegRem, RegDiv
    --------------------------------------------------------------------------------
    FUNCTION  "mod" ( CONSTANT dividend     : IN INTEGER;
                      CONSTANT modulus      : IN std_logic_vector
                    ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "mod" operator
    -- 
    --     Purpose       : Modulus operator for ulogic vectors.
    --
    --     Parameters    :     result         left       right
    --                       std_ulogic_vector    std_ulogic_vector  std_ulogic_vector
    --
    --     NOTE          : The modulus operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The operands may be of different length. The length of
    --                     the result equals the length of the longer operand.
    --
    --                     An ASSERTION message of severity WARNING is issued
    --                     if division by 0 is attempted. In this case the
    --                     return value is 0 (all 0's).
    --
    --     Use           :
    --                      VARIABLE a,b,c : std_ulogic_vector ( 7 downto 0 );
    --                      c := a mod b;
    --                      c := a mod B"1101";  -- c = a / (-3)
    --     Se Also       : RegRem, RegDiv
    --------------------------------------------------------------------------------
    FUNCTION  "mod" ( CONSTANT dividend     : IN std_ulogic_vector;
                      CONSTANT modulus      : IN std_ulogic_vector
                    ) RETURN std_ulogic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "mod" operator
    -- 
    --     Purpose       : Modulus operator for ulogic vectors.
    --
    --     Parameters    :     result         left       right
    --                       std_ulogic_vector    std_ulogic_vector  INTEGER
    --
    --     NOTE          : The modulus operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The modulus is converted to std_ulogic_vector of length
    --                     equal to the dividend. The length of the result
    --                     equals the length of the dividend.
    --
    --                     An ASSERTION message of severity WARNING is issued
    --                     if division by 0 is attempted. In this case the
    --                     return value is 0 (all 0's).
    --
    --     Use           :
    --                      VARIABLE a,c : std_ulogic_vector ( 7 downto 0 );
    --                      VARIABLE b : INTEGER;
    --                      c := a mod b;
    --                      c := a mod 5;
    --     Se Also       : RegRem, RegDiv
  --------------------------------------------------------------------------------
    FUNCTION  "mod" ( CONSTANT dividend     : IN std_ulogic_vector;
                      CONSTANT modulus      : IN INTEGER
                    ) RETURN std_ulogic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "mod" operator
    -- 1.5.21
    --     Purpose       : Modulus operator for ulogic vectors.
    --
    --     Parameters    :     result         left       right
    --                       std_ulogic_vector    INTEGER  std_ulogic_vector
    --
    --     NOTE          : The modulus operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The dividend is converted to std_ulogic_vector of length
    --                     equal to the modulus. The length of the result
    --                     equals the length of the modulus.
    --
    --                     An ASSERTION message of severity WARNING is issued
    --                     if division by 0 is attempted. In this case the
    --                     return value is 0 (all 0's).
    --
    --     Use           :
    --                      VARIABLE a : INTEGER;
    --                      VARIABLE b,c : std_ulogic_vector ( 7 downto 0 );
    --                      c := a mod b;
    --                      c := 5 mod b;
    --     Se Also       : RegRem, RegDiv
    --------------------------------------------------------------------------------
    FUNCTION  "mod" ( CONSTANT dividend     : IN INTEGER;
                      CONSTANT modulus      : IN std_ulogic_vector
                    ) RETURN std_ulogic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "mod" operator
    -- 1.5.22
    --     Purpose       : Modulus operator for bit vectors.
    --
    --     Parameters    :     result         left       right
    --                       bit_vector    bit_vector  bit_vector
    --
    --     NOTE          : The modulus operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The operands may be of different length. The length of
    --                     the result equals the length of the longer operand.
    --
    --
    --                     An ASSERTION message of severity WARNING is issued
    --                     if division by 0 is attempted. In this case the
    --                     return value is 0 (all 0's).
    --
    --     Use           :
    --                      VARIABLE a,b,c : bit_vector ( 7 downto 0 );
    --                      c := a mod b;
    --                      c := a mod B"1101";  -- c = a / (-3)
    --     Se Also       : RegRem, RegDiv
    ----------------------------------------------------------------------------------
    FUNCTION  "mod" ( CONSTANT dividend     : IN bit_vector;
                      CONSTANT modulus      : IN bit_vector
                    ) RETURN BIT_VECTOR;
     -------------------------------------------------------------------------------
    --     Function Name : Overloaded "mod" operator
    -- 1.5.23
    --     Purpose       : Modulus operator for bit vectors.
    --
    --     Parameters    :     result         left       right
    --                       bit_vector     bit_vector  INTEGER
    --
    --     NOTE          : The modulus operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The modulus is converted to bit_vector of length
    --                     equal to the dividend. The length of the result
    --                     equals the length of the dividend.
    --
    --                     An ASSERTION message of severity WARNING is issued
    --                     if division by 0 is attempted. In this case the
    --                     return value is 0 (all 0's).
    --
    --     Use           :
    --                      VARIABLE a,c : bit_vector ( 7 downto 0 );
    --                      VARIABLE b : INTEGER;
    --                      c := a mod b;
    --                      c := a mod 5;
    --     Se Also       : RegRem, RegDiv
    --------------------------------------------------------------------------------
    FUNCTION  "mod" ( CONSTANT dividend     : IN bit_vector;
                      CONSTANT modulus      : IN INTEGER
                    ) RETURN BIT_VECTOR;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "mod" operator
    -- 1.5.24
    --     Purpose       : Modulus operator for bit vectors.
    --
    --     Parameters    :     result         left       right
    --                       bit_vector    INTEGER  bit_vector
    --
    --     NOTE          : The modulus operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The dividend is converted to bit_vector of length
    --                     equal to the modulus. The length of the result
    --                     equals the length of the modulus.
    --
    --                     An ASSERTION message of severity WARNING is issued
    --                     if division by 0 is attempted. In this case the
    --                     return value is 0 (all 0's).
    --
    --     Use           :
    --                      VARIABLE a : INTEGER;
    --                      VARIABLE b,c : bit_vector ( 7 downto 0 );
    --                      c := a mod b;
    --                      c := 5 mod b;
    --     Se Also       : RegRem, RegDiv
    --------------------------------------------------------------------------------
    FUNCTION  "mod" ( CONSTANT dividend     : IN INTEGER;
                      CONSTANT modulus      : IN bit_vector
                    ) RETURN BIT_VECTOR;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "rem" operator
    -- 1.5.27
    --     Purpose       : Remainder operator for logic vectors.
    --
    --     Parameters    :     result         left             right
    --                     std_logic_vector  std_logic_vector  std_logic_vector
    --
    --     NOTE          : The division operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The operands may be of different length. The length of
    --                     the result equals the length of the longer operand.
    --
    --                     An ASSERTION message of severity WARNING is issued
    --                     if division by 0 is attempted. In this case the
    --                     return value is 0 (all 0's).
    --
    --     Use           :
    --                      VARIABLE a,b,c : std_logic_vector ( 7 downto 0 );
    --                      c := a rem b;
    --                      c := a rem B"1101";  -- c = a rem (-3)
    -----------------------------------------------------------------------------------
    FUNCTION  "rem" ( CONSTANT dividend     : IN std_logic_vector;
                      CONSTANT divisor      : IN std_logic_vector
                    ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "rem" operator
    -- 1.5.28
    --     Purpose       : Remainder operator for logic vectors.
    --
    --     Parameters    :     result         left       right
    --                       std_logic_vector    std_logic_vector  INTEGER
    --
    --     NOTE          : The division operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The divisor is converted to std_logic_vector of length
    --                     equal to the dividend. The length of the result
    --                     equals the length of the dividend.
    --
    --                     An ASSERTION message of severity WARNING is issued
    --                     if division by 0 is attempted. In this case the
    --                     return value is 0 (all 0's).
    --
    --     Use           :
    --                      VARIABLE a,c : std_logic_vector ( 7 downto 0 );
    --                      VARIABLE b : INTEGER;
    --                      c := a rem b;
    --                      c := a rem 5;
    --     Se Also       : RegMod, RegDiv
    ------------------------------------------------------------------------------
    FUNCTION  "rem" ( CONSTANT dividend     : IN std_logic_vector;
                      CONSTANT divisor      : IN INTEGER
                    ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "rem" operator
    -- 1.5.29
    --     Purpose       : Remainder operator for logic vectors.
    --
    --     Parameters    :     result         left       right
    --                       std_logic_vector    INTEGER  std_logic_vector
    --
    --     NOTE          : The division operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The dividend is converted to std_logic_vector of length
    --                     equal to the divisor. The length of the result
    --                     equals the length of the divisor.
    --
    --                     An ASSERTION message of severity WARNING is issued
    --                     if division by 0 is attempted. In this case the
    --                     return value is 0 (all 0's).
    --
    --     Use           :
    --                      VARIABLE a : INTEGER;
    --                      VARIABLE b,c : std_logic_vector ( 7 downto 0 );
    --                      c := a rem b;
    --                      c := 5 rem b;
    --     Se Also       : RegMod, RegDiv
    ------------------------------------------------------------------------------
    FUNCTION  "rem" ( CONSTANT dividend     : IN INTEGER;
                      CONSTANT divisor      : IN std_logic_vector
                    ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "rem" operator
    -- 
    --     Purpose       : Remainder operator for ulogic vectors.
    --
    --     Parameters    :     result         left             right
    --                     std_ulogic_vector  std_ulogic_vector  std_ulogic_vector
    --
    --     NOTE          : The division operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The operands may be of different length. The length of
    --                     the result equals the length of the longer operand.
    --
    --                     An ASSERTION message of severity WARNING is issued
    --                     if division by 0 is attempted. In this case the
    --                     return value is 0 (all 0's).
    --
    --     Use           :
    --                      VARIABLE a,b,c : std_ulogic_vector ( 7 downto 0 );
    --                      c := a rem b;
    --                      c := a rem B"1101";  -- c = a rem (-3)
    ---------------------------------------------------------------------------------
    FUNCTION  "rem" ( CONSTANT dividend     : IN std_ulogic_vector;
                      CONSTANT divisor      : IN std_ulogic_vector
                    ) RETURN std_ulogic_vector;
    --------------------------------------------------------------------------------
    --     Function Name : Overloaded "rem" operator
    -- 
    --     Purpose       : Remainder operator for ulogic vectors.
    --
    --     Parameters    :     result         left       right
    --                       std_ulogic_vector    std_ulogic_vector  INTEGER
    --
    --     NOTE          : The division operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The divisor is converted to std_ulogic_vector of length
    --                     equal to the dividend. The length of the result
    --                     equals the length of the dividend.
    --
    --                     An ASSERTION message of severity WARNING is issued
    --                     if division by 0 is attempted. In this case the
    --                     return value is 0 (all 0's).
    --
    --     Use           :
    --                      VARIABLE a,c : std_ulogic_vector ( 7 downto 0 );
    --                      VARIABLE b : INTEGER;
    --                      c := a rem b;
    --                      c := a rem 5;
    --     Se Also       : RegMod, RegDiv
    --------------------------------------------------------------------------------
    FUNCTION  "rem" ( CONSTANT dividend     : IN std_ulogic_vector;
                      CONSTANT divisor      : IN INTEGER
                    ) RETURN std_ulogic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "rem" operator
    -- 1.5.29
    --     Purpose       : Remainder operator for ulogic vectors.
    --
    --     Parameters    :     result         left       right
    --                       std_ulogic_vector    INTEGER  std_ulogic_vector
    --
    --     NOTE          : The division operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The dividend is converted to std_ulogic_vector of length
    --                     equal to the divisor. The length of the result
    --                     equals the length of the divisor.
    --
    --                     An ASSERTION message of severity WARNING is issued
    --                     if division by 0 is attempted. In this case the
    --                     return value is 0 (all 0's).
    --
    --     Use           :
    --                      VARIABLE a : INTEGER;
    --                      VARIABLE b,c : std_ulogic_vector ( 7 downto 0 );
    --                      c := a rem b;
    --                      c := 5 rem b;
    --     Se Also       : RegMod, RegDiv
    --------------------------------------------------------------------------------
    FUNCTION  "rem" ( CONSTANT dividend     : IN INTEGER;
                      CONSTANT divisor      : IN std_ulogic_vector
                    ) RETURN std_ulogic_vector;
--+-----------------------------------------------------------------------------
--|     Function Name : Overloaded "rem" operator
--| 1.5.30
--|     Purpose       : Remainder operator for bit vectors.
--|     Parameters    :     result         left       right
--|                       BIT_VECTOR    BIT_VECTOR  BIT_VECTOR
--|
--|     NOTE          : The division operation is performed assuming all
--|                     operands and results are signed Two's complement integers.
--|
--|                     The operands may be of different length. The length of
--|                     the result equals the length of the longer operand.
--|
--|                     An ASSERTION message of severity WARNING is issued
--|                     if division by 0 is attempted. In this case the
--|                     return value is 0 (all 0's).
--|
--|
--|     Use           :
--|                      VARIABLE a,b,c : bit_vector ( 7 downto 0 );
--|                      c := a rem b;
--|                      c := a rem B"1101";  -- c = a rem (-3)
--|
--|     See Also      : RegMod, RegDiv
--|-----------------------------------------------------------------------------
    FUNCTION  "rem" ( CONSTANT dividend     : IN BIT_VECTOR;
                      CONSTANT divisor      : IN BIT_VECTOR
                    ) RETURN BIT_VECTOR;
--+-----------------------------------------------------------------------------
--|     Function Name : Overloaded "rem" operator
--| 1.5.31
--|     Purpose       : Remainder operator for bit vectors.
--|     Parameters    :     result         left       right
--|                       BIT_VECTOR    BIT_VECTOR  INTEGER
--|
--|     NOTE          : The division operation is performed assuming all
--|                     operands and results are signed Two's complement integers.
--|
--|                     The divisor is converted to bit_vector of length
--|                     equal to the dividend. The length of the result
--|                     equals the length of the dividend.
--|
--|                     An ASSERTION message of severity WARNING is issued
--|                     if division by 0 is attempted. In this case the
--|                     return value is 0 (all 0's).
--|
--|
--|     Use           :
--|                      VARIABLE a,c : BIT_VECTOR ( 7 downto 0 );
--|                      VARIABLE b : INTEGER;
--|                      c := a rem b;
--|                      c := a rem 5;
--|
--|     See Also      : RegMod, RegDiv
--|-----------------------------------------------------------------------------
    FUNCTION  "rem" ( CONSTANT dividend     : IN BIT_VECTOR;
                      CONSTANT divisor      : IN INTEGER
                    ) RETURN BIT_VECTOR;
--+-----------------------------------------------------------------------------
--|     Function Name : Overloaded "rem" operator
--| 1.5.32
--|     Purpose       : Remainder operator for bit vectors.
--|     Parameters    :     result         left       right
--|                       BIT_VECTOR    INTEGER  BIT_VECTOR
--|
--|     NOTE          : The division operation is performed assuming all
--|                     operands and results are signed Two's complement integers.
--|
--|                     The dividend is converted to bit_vector of length
--|                     equal to the divisor. The length of the result
--|                     equals the length of the divisor.
--|
--|                     An ASSERTION message of severity WARNING is issued
--|                     if division by 0 is attempted. In this case the
--|                     return value is 0 (all 0's).
--|
--|
--|     Use           :
--|                      VARIABLE a : INTEGER;
--|                      VARIABLE b,c : BIT_VECTOR ( 7 downto 0 );
--|                      c := a rem b;
--|                      c := 5 rem b;
--|
--|     See Also      : RegMod, RegDiv
--|-----------------------------------------------------------------------------
    FUNCTION  "rem" ( CONSTANT dividend     : IN INTEGER;
                      CONSTANT divisor      : IN BIT_VECTOR
                    ) RETURN BIT_VECTOR;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "**" operator
    -- 1.6.3
    --     Purpose       : Exponentiation operator for logic vectors.
    --
    --     Parameters    :     result         left       right
    --                       std_logic_vector    std_logic_vector  std_logic_vector
    --
    --     NOTE          : The exponentiation operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --
    --                     A temporary result is computed of sufficient length
    --                     to avoid overflow. The high order bits of this temporary
    --                     vector are truncated to form the required length result.
    --                     No indication is given if the magnitude of the computed
    --                     result exceeds the size of the returned result vector.
    --
    --     Use           :
    --                      VARIABLE a,b,c : std_logic_vector ( 7 downto 0 );
    --                      c := a ** b;
    --                      c := a ** B"1101";  -- c = a ** (-3)
    --
    --     See Also      : RegMult, RegExp 
    -------------------------------------------------------------------------------
    FUNCTION  "**" ( CONSTANT base  : IN std_logic_vector;
                     CONSTANT exponent  : IN std_logic_vector
                   ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "**" operator
    -- 1.6.4
    --     Purpose       : Exponentiation operator for logic vectors.
    --
    --     Parameters    :     result           left                right
    --                       std_logic_vector    std_logic_vector  Integer
    --
    --     NOTE          : The Exponentiation operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The exponent is converted to std_logic_vector of length
    --                     equal to the base. The length of the result
    --                     equals the length of the base.
    --
    --                     A temporary result is computed of sufficient length
    --                     to avoid overflow. The high order bits of this temporary
    --                     vector are truncated to form the required length result.
    --                     No indication is given if the magnitude of the computed
    --                     result exceeds the size of the returned result vector.
    --
    --     Use           :
    --                      VARIABLE a,c : std_logic_vector ( 7 downto 0 );
    --                      VARIABLE b: Integer;
    --                      c := a ** b;
    --                      c := a ** 5;
    --
  --
    --     See Also      : RegMult, RegExp
  -------------------------------------------------------------------------------
    FUNCTION  "**" ( CONSTANT base : IN std_logic_vector;
                     CONSTANT exponent : IN Integer
                   ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "**" operator
    -- 1.6.5
    --     Purpose       : Exponentiation operator for logic vectors.
    --
    --     Parameters    :     result           left                right
    --                       std_logic_vector    Integer     std_logic_vector
    --
    --     NOTE          : The exponentiation operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The base is converted to std_logic_vector of length
    --                     equal to the IntegerBitLength (Implied length). 
    --                     The length of the result equals the implied length.
 
    --
    --                     A temporary result is computed of sufficient length
    --                     to avoid overflow. The high order bits of this temporary
    --                     vector are truncated to form the required length result.
    --                     No indication is given if the magnitude of the computed
    --                     result exceeds the size of the returned result vector.
    --
    --     Use           :
    --                      VARIABLE a,c : std_logic_vector ( 7 downto 0 );
    --                      VARIABLE b: Integer;
    --                      c := a ** b;
    --                      c := a ** 5;
    --
    --     See Also      : RegMult, RegExp
   -------------------------------------------------------------------------------
    FUNCTION  "**" ( CONSTANT base : IN Integer;
                     CONSTANT exponent : IN std_logic_vector
                   ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "**" operator
    -- 
    --     Purpose       : Exponentiation operator for ulogic vectors.
    --
    --     Parameters    :     result         left       right
    --                       std_ulogic_vector    std_ulogic_vector  std_ulogic_vector
    --
    --     NOTE          : The exponentiation operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --
    --                     A temporary result is computed of sufficient length
    --                     to avoid overflow. The high order bits of this temporary
    --                     vector are truncated to form the required length result.
    --                     No indication is given if the magnitude of the computed
    --                     result exceeds the size of the returned result vector.
    --
    --     Use           :
    --                      VARIABLE a,b,c : std_ulogic_vector ( 7 downto 0 );
    --                      c := a ** b;
    --                      c := a ** B"1101";  -- c = a ** (-3)
    --
    --     See Also      : RegMult, RegExp 
    -------------------------------------------------------------------------------
    FUNCTION  "**" ( CONSTANT base      : IN std_ulogic_vector;
                     CONSTANT exponent  : IN std_ulogic_vector
                   ) RETURN std_ulogic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "**" operator
    -- 1.6.4
    --     Purpose       : Exponentiation operator for ulogic vectors.
    --
    --     Parameters    :     result           left                right
    --                       std_ulogic_vector    std_ulogic_vector  Integer
    --
    --     NOTE          : The Exponentiation operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The exponent is converted to std_ulogic_vector of length
    --                     equal to the base. The length of the result
    --                     equals the length of the base.
    --
    --                     A temporary result is computed of sufficient length
    --                     to avoid overflow. The high order bits of this temporary
    --                     vector are truncated to form the required length result.
    --                     No indication is given if the magnitude of the computed
    --                     result exceeds the size of the returned result vector.
    --
    --     Use           :
    --                      VARIABLE a,c : std_ulogic_vector ( 7 downto 0 );
    --                      VARIABLE b: Integer;
    --                      c := a ** b;
    --                      c := a ** 5;
    --
  --
    --     See Also      : RegMult, RegExp
  -------------------------------------------------------------------------------
    FUNCTION  "**" ( CONSTANT base :   IN std_ulogic_vector;
                     CONSTANT exponent : IN Integer
                   ) RETURN std_ulogic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "**" operator
    -- 
    --     Purpose       : Exponentiation operator for ulogic vectors.
    --
    --     Parameters    :     result           left                right
    --                       std_ulogic_vector    Integer     std_ulogic_vector
    --
    --     NOTE          : The exponentiation operation is performed assuming all
    --                     operands and results are signed Two's complement integers.
    --
    --                     The base is converted to std_ulogic_vector of length
    --                     equal to the IntegerBitLength (Implied length). 
    --                     The length of the result  equals the implied length.
    --
    --                     A temporary result is computed of sufficient length
    --                     to avoid overflow. The high order bits of this temporary
    --                     vector are truncated to form the required length result.
    --                     No indication is given if the magnitude of the computed
    --                     result exceeds the size of the returned result vector.
    --
    --     Use           :
    --                      VARIABLE a,c : std_ulogic_vector ( 7 downto 0 );
    --                      VARIABLE b: Integer;
    --                      c := a ** b;
    --                      c := a ** 5;
    --
    --     See Also      : RegMult, RegExp
    -------------------------------------------------------------------------------
    FUNCTION  "**" ( CONSTANT base : IN Integer;
                     CONSTANT exponent : IN std_ulogic_vector
                   ) RETURN std_ulogic_vector;
--+----------------------------------------------------------------------------
--|      Function Name : Overloaded "**" operator
--|  1.6.6
--|      Purpose       : Exponentiation operator for logic vectors.
--| 
--|      Parameters    :     result        left         right
--|                        bit_vector    bit_vector  bit_vector
--| 
--|      NOTE          : The exponentiation operation is performed assuming all
--|                      operands and results are signed Two's complement integers.
--|
--|                     A temporary result is computed of sufficient length
--|                     to avoid overflow. The high order bits of this temporary
--|                     vector are truncated to form the required length result.
--|                     No indication is given if the magnitude of the computed
--|                     result exceeds the size of the returned result vector.
--|
--|    
--|      Use           :
--|                       VARIABLE a,b,c : bit_vector ( 7 downto 0 );
--|                       c := a ** b;
--|                      c := a ** B"1101";  -- c = a ** (-3)
--|
--|      See Also      : RegMult, RegExp
--|---------------------------------------------------------------------------------
    FUNCTION  "**" ( CONSTANT base : IN bit_vector;
                     CONSTANT exponent : IN bit_vector
                   ) RETURN BIT_VECTOR;
--+-----------------------------------------------------------------------------
--|     Function Name : Overloaded "**" operator
--| 1.6.7
--|     Purpose       : Exponentiation operator for bit vectors.
--|
--|     Parameters    :     result         left       right
--|                       BIT_VECTOR    BIT_VECTOR  INTEGER
--|
--|     NOTE          : The Exponentiation operation is performed assuming all
--|                     operands and results are signed Two's complement integers.
--|
--|                     The exponent is converted to std_ulogic_vector of length
--|                     equal to the base. The length of the result
--|                     equals the length of the base.
--|
--|                     A temporary result is computed of sufficient length
--|                     to avoid overflow. The high order bits of this temporary
--|                     vector are truncated to form the required length result.
--|                     No indication is given if the magnitude of the computed
--|                     result exceeds the size of the returned result vector.
--|
--|     Use           :
--|                      VARIABLE a,c : BIT_VECTOR ( 7 downto 0 );
--|                      VARIABLE b: INTEGER;
--|                      c := a ** b;
--|                      c := a ** 5;
--|
--|     See Also      : RegMult, RegExp
--|-----------------------------------------------------------------------------
    FUNCTION  "**" ( CONSTANT base     : IN BIT_VECTOR;
                     CONSTANT exponent : IN INTEGER
                   ) RETURN BIT_VECTOR;
--+-----------------------------------------------------------------------------
--|     Function Name : Overloaded "**" operator
--| 1.6.8
--|     Purpose       : Exponentiation operator for bit vectors.
--|
--|     Parameters    :     result         left       right
--|                       BIT_VECTOR    INTEGER  BIT_VECTOR
--|
--|     NOTE          : The exponentiation operation is performed assuming all
--|                     operands and results are signed Two's complement integers.
--|
--|                     The base is converted to BIT_VECTOR of length
--|                     equal to the IntegerBitLength (implied length). 
--|                     The length of the result equals the implied length.
--|
--|                     A temporary result is computed of sufficient length
--|                     to avoid overflow. The high order bits of this temporary
--|                     vector are truncated to form the required length result.
--|                     No indication is given if the magnitude of the computed
--|                     result exceeds the size of the returned result vector.
--|
--|     Use           :
--|                      VARIABLE a : INTEGER;
--|                      VARIABLE b,c : BIT_VECTOR ( 7 downto 0 );
--|                      c := a ** b;
--|                      c := 5 ** b;
--|
--|     See Also      : RegMult, RegExp
--|-----------------------------------------------------------------------------
   FUNCTION  "**" ( CONSTANT base     : IN INTEGER;
                    CONSTANT exponent : IN BIT_VECTOR
                  ) RETURN BIT_VECTOR;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "ABS" operator
    -- 1.6.11
    --     Purpose       : Absolute value operator for logic vectors.
    --
    --     Parameters    :     result             operand       
    --                       std_logic_vector    std_logic_vector
    --
    --
    --     Use           :
    --                      VARIABLE a,c : std_logic_vector ( 7 downto 0 );
    --                      c := ABS(a);
    --
    --     See Also      : RegAbs
    -------------------------------------------------------------------------------
    FUNCTION  "ABS" ( CONSTANT operand : IN std_logic_vector
                    ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "ABS" operator
    -- 
    --     Purpose       : Absolute value operator for ulogic vectors.
    --
    --     Parameters    :     result             operand       
    --                       std_ulogic_vector    std_ulogic_vector
    --
    --
    --     Use           :
    --                      VARIABLE a,c : std_ulogic_vector ( 7 downto 0 );
    --                      c := ABS(a);
    --
    --     See Also      : RegAbs
    -------------------------------------------------------------------------------
    FUNCTION  "ABS" ( CONSTANT operand : IN std_ulogic_vector
                    ) RETURN std_ulogic_vector;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "ABS" operator
    -- 1.6.12
    --     Purpose       : Absolute value operator for bit vectors.
    --
    --     Parameters    :     result        operand       
    --                       bit_vector    bit_vector
    --
    --
    --     Use           :
    --                      VARIABLE a,c : bit_vector ( 7 downto 0 );
    --                      c := ABS(a);
    --
    --     See Also      : RegAbs
    -------------------------------------------------------------------------------
    FUNCTION  "ABS" ( CONSTANT operand : IN bit_vector
                    ) RETURN BIT_VECTOR;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "=" operator
    --   1.2.1 and 1.2.3  
    --     Purpose       : Equality relational operator for std_logic_vector : integer.
    --     
    --     Parameters    :     result         left              right
    --                        std_ulogic  std_logic_vector   std_logic_vector
    --                        BOOLEAN     INTEGER            std_logic_vector
    --                        BOOLEAN     std_logic_vector   INTEGER
    --                        std_ulogic  INTEGER            std_logic_vector
    --                        std_ulogic  std_logic_vector   INTEGER
    --                                     
    --     NOTE          : The std_logic_vector operands are assumed to be  
    --                     in  DefaultRegMode. If not they will be converted
    --                     to DefaultRegMode in the compare procedure. 
    --                     These vectors may be of any length.
    --
    --     Use           : 
    --                      VARIABLE a : std_logic_vector ( 7 DOWNTO 0 ) := X"FF";
    --                      VARIABLE b : INTEGER;
    --                      IF ( a = b )  THEN 
    --     
    --     See Also      : RegEqual, RegNotEqual,
    -------------------------------------------------------------------------------
    FUNCTION  "=" ( CONSTANT l  : std_logic_vector;
                    CONSTANT r  : std_logic_vector
                  ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION  "=" ( CONSTANT l  : std_logic_vector;
                    CONSTANT r  : INTEGER
                  ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION  "=" ( CONSTANT l  : INTEGER   ;
                    CONSTANT r  : std_logic_vector 
                  ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION  "=" ( CONSTANT l  : std_logic_vector;
                    CONSTANT r  : INTEGER
                  ) RETURN std_ulogic;
    -- -----------------------------------------------------------------------------
    FUNCTION  "=" ( CONSTANT l  : INTEGER   ;
                    CONSTANT r  : std_logic_vector 
                  ) RETURN std_ulogic;

    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "=" operator
    --   
    --     Purpose       : Equality relational operator for std_ulogic_vector : integer.
    --     
    --     Parameters    :     result         left              right
    --                        std_ulogic  std_ulogic_vector   std_ulogic_vector
    --                        BOOLEAN     INTEGER            std_ulogic_vector
    --                        BOOLEAN     std_ulogic_vector   INTEGER
    --                        std_ulogic  INTEGER            std_ulogic_vector
    --                        std_ulogic  std_ulogic_vector   INTEGER
    --                                     
    --     NOTE          : The std_ulogic_vector operands are assumed to be  
    --                     in  DefaultRegMode. If not they will be converted
    --                     to DefaultRegMode in the compare procedure. 
    --                     These vectors may be of any length.
    --
    --     Use           : 
    --                      VARIABLE a : std_ulogic_vector ( 7 DOWNTO 0 ) := X"FF";
    --                      VARIABLE b : INTEGER;
    --                      IF ( a = b )  THEN 
    --     
    --     See Also      : RegEqual, RegNotEqual,
    -------------------------------------------------------------------------------
    FUNCTION  "=" ( CONSTANT l  : std_ulogic_vector;
                    CONSTANT r  : std_ulogic_vector
                  ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION  "=" ( CONSTANT l  : std_ulogic_vector;
                    CONSTANT r  : INTEGER
                  ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION  "=" ( CONSTANT l  : INTEGER   ;
                    CONSTANT r  : std_ulogic_vector 
                  ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION  "=" ( CONSTANT l  : std_ulogic_vector;
                    CONSTANT r  : INTEGER
                  ) RETURN std_ulogic;
    -- -----------------------------------------------------------------------------
    FUNCTION  "=" ( CONSTANT l  : INTEGER   ;
                    CONSTANT r  : std_ulogic_vector 
                  ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "=" operator
    -- 1.2.2 and 1.2.4
    --     Purpose       : Equality relational operator for bit_vector : integer.
    --
    --     Parameters    :     result         left       right
    --                        BOOLEAN       INTEGER   bit_vector 
    --                        BOOLEAN      bit_vector   INTEGER
    --
    --     NOTE          : The bit_vector operands are assumed to be 
    --                     in  DefaultRegMode. If not they will be converted
    --                     to DefaultRegMode in the compare procedure. 
    --                     These vectors may be of any length.
    --
    --     Use           :
    --                      VARIABLE a : bit_vector ( 7 DOWNTO 0 ) := X"FF";
    --                      VARIABLE b : INTEGER;
    --                      IF ( a = b )  THEN
    --
    --     See Also      : compare, RegLessThan, RegGreaterThan,
    -------------------------------------------------------------------------------
    FUNCTION  "=" ( CONSTANT l  : bit_vector;
                    CONSTANT r  : bit_vector
                  ) RETURN bit;
    -------------------------------------------------------------------------------
    FUNCTION  "=" ( CONSTANT l  : bit_vector;
                    CONSTANT r  : INTEGER
                  ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION  "=" ( CONSTANT l  : INTEGER   ;
                    CONSTANT r  : bit_vector 
                  ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION  "=" ( CONSTANT l  : bit_vector;
                    CONSTANT r  : INTEGER
                  ) RETURN bit;
    -- -----------------------------------------------------------------------------
    FUNCTION  "=" ( CONSTANT l  : INTEGER   ;
                    CONSTANT r  : bit_vector 
                  ) RETURN bit;

    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "/=" operator
    -- 1.2.10 and 1.2.12
    --     Purpose       : Inequality relational operator for bit_vector : integer.
    --
    --     Parameters    :     result         left       right
    --                        BOOLEAN       INTEGER    bit_vector
    --                        BOOLEAN      bit_vector   INTEGER
    --
    --     NOTE          : The bit_vector operands are assumed to be 
    --                     in  DefaultRegMode. If not they will be converted
    --                     to DefaultRegMode in the compare procedure. 
    --                     These vectors may be of any length.
    --
    --     Use           :
    --                      VARIABLE a : bit_vector ( 7 DOWNTO 0 ) := X"FF";
    --                      VARIABLE b : INTEGER;
    --                      IF ( a /= b )  THEN
    --
    --     See Also      : compare, RegLessThan, RegGreaterThan,
    -------------------------------------------------------------------------------
   FUNCTION  "/=" ( CONSTANT l  : bit_vector;
                    CONSTANT r  : bit_vector
                  ) RETURN bit;
    -------------------------------------------------------------------------------
    FUNCTION  "/=" ( CONSTANT l  : bit_vector;
                     CONSTANT r  : INTEGER
                   ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION  "/=" ( CONSTANT l  : INTEGER   ;
                     CONSTANT r  : bit_vector 
                   ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION  "/=" ( CONSTANT l  : bit_vector;
                    CONSTANT r  : INTEGER
                  ) RETURN bit;
    -- -----------------------------------------------------------------------------
    FUNCTION  "/=" ( CONSTANT l  : INTEGER   ;
                     CONSTANT r  : bit_vector 
                   ) RETURN bit;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "/=" operator
    --   1.2.9 and 1.2.11 
    --     Purpose       : Inequality relational operator for
    --                     std_logic_vector : integer.
    --     
    --     Parameters    :     result         left       right
    --                        std_ulogic  std_logic_vector   std_logic_vector
    --                        BOOLEAN     INTEGER            std_logic_vector
    --                        BOOLEAN     std_logic_vector   INTEGER
    --                        std_ulogic  INTEGER            std_logic_vector
    --                        std_ulogic  std_logic_vector   INTEGER
    --                                     
    --     NOTE          : The std_logic_vector operands are assumed to be 
    --                     integers. These vectors may be of any length.
    --                     in  DefaultRegMode. If not they will be converted
    --                     to DefaultRegMode in the compare procedure. 
    --
    --     Use           : 
    --                      VARIABLE a : std_logic_vector ( 7 DOWNTO 0 ) := X"FF";
    --                      VARIABLE b : INTEGER;
    --                      IF ( a /= b )  THEN 
    --     
    --     See Also      : RegEqual, RegLessThan, RegGreaterThan,
    -------------------------------------------------------------------------------
    FUNCTION "/=" ( CONSTANT l  : std_logic_vector;
                    CONSTANT r  : std_logic_vector
                  ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION  "/=" ( CONSTANT l  : std_logic_vector;
                     CONSTANT r  : INTEGER
                   ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION  "/=" ( CONSTANT l  : INTEGER   ;
                    CONSTANT r  : std_logic_vector 
                  ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION  "/=" ( CONSTANT l  : std_logic_vector;
                     CONSTANT r  : INTEGER
                   ) RETURN std_ulogic;
       -- -----------------------------------------------------------------------------
    FUNCTION  "/=" ( CONSTANT l  : INTEGER   ;
                     CONSTANT r  : std_logic_vector 
                   ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "/=" operator
    --    
    --     Purpose       : Inequality relational operator for
    --                     std_ulogic_vector : integer.
    --     
    --     Parameters    :     result         left       right
    --                        std_ulogic  std_ulogic_vector   std_ulogic_vector
    --                        BOOLEAN     INTEGER            std_ulogic_vector
    --                        BOOLEAN     std_ulogic_vector   INTEGER
    --                        std_ulogic  INTEGER            std_ulogic_vector
    --                        std_ulogic  std_ulogic_vector   INTEGER
    --                                     
    --     NOTE          : The std_ulogic_vector operands are assumed to be 
    --                     integers. These vectors may be of any length.
    --                     in  DefaultRegMode. If not they will be converted
    --                     to DefaultRegMode in the compare procedure. 
    --
    --     Use           : 
    --                      VARIABLE a : std_ulogic_vector ( 7 DOWNTO 0 ) := X"FF";
    --                      VARIABLE b : INTEGER;
    --                      IF ( a /= b )  THEN 
    --     
    --     See Also      : RegEqual, RegLessThan, RegGreaterThan,
    -------------------------------------------------------------------------------
    FUNCTION "/=" ( CONSTANT l  : std_ulogic_vector;
                    CONSTANT r  : std_ulogic_vector
                  ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION  "/=" ( CONSTANT l  : std_ulogic_vector;
                     CONSTANT r  : INTEGER
                   ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION  "/=" ( CONSTANT l  : INTEGER   ;
                    CONSTANT r  : std_ulogic_vector 
                  ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION  "/=" ( CONSTANT l  : std_ulogic_vector;
                     CONSTANT r  : INTEGER
                   ) RETURN std_ulogic;
       -- -----------------------------------------------------------------------------
    FUNCTION  "/=" ( CONSTANT l  : INTEGER   ;
                     CONSTANT r  : std_ulogic_vector 
                   ) RETURN std_ulogic;

    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "<" operator
    -- 1.2.18 and 1.2.20     
    --     Purpose       : Less-than relational operator for bit_vectors.
    --     
    --     Parameters    :     result         left       right
    --                        BOOLEAN       INTEGER    bit_vector
    --                        BOOLEAN      bit_vector   INTEGER
    --     
    --     NOTE          : The bit_vector operands are assumed to be 
    --                     in  DefaultRegMode. If not they will be converted
    --                     to DefaultRegMode in the compare procedure. 
    --                     These vectors may be of any length.
    --
    --     Use           :
    --                      VARIABLE a : bit_vector ( 7 DOWNTO 0 ) := X"FF";
    --                      VARIABLE b : INTEGER;
    --                      IF ( a < b )  THEN 
    --     
    --     See Also      : compare, RegLessThan, RegGreaterThan,
    -------------------------------------------------------------------------------
    FUNCTION  "<" ( CONSTANT l  : bit_vector;
                    CONSTANT r  : bit_vector
                  ) RETURN bit;
    -------------------------------------------------------------------------------
    FUNCTION  "<" ( CONSTANT l  : bit_vector;
                    CONSTANT r  : INTEGER
                  ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION  "<" ( CONSTANT l  : INTEGER   ;
                    CONSTANT r  : bit_vector 
                  ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION  "<" ( CONSTANT l  : bit_vector;
                    CONSTANT r  : INTEGER
                  ) RETURN bit;
    -- -----------------------------------------------------------------------------
    FUNCTION  "<" ( CONSTANT l  : INTEGER   ;
                    CONSTANT r  : bit_vector 
                  ) RETURN bit;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "<" operator
    --
    --     Purpose       : Less-than relational operator for std_logic_vectors.
    --
    --     Parameters    :     result         left             right
    --                        std_ulogic  std_logic_vector   std_logic_vector
    --                        BOOLEAN     INTEGER            std_logic_vector
    --                        BOOLEAN     std_logic_vector   INTEGER
    --                        std_ulogic  INTEGER            std_logic_vector
    --                        std_ulogic  std_logic_vector   INTEGER
    --
    --     NOTE          : The std_logic_vector operands are assumed to be 
    --                     in  DefaultRegMode. If not they will be converted
    --                     to DefaultRegMode in the compare procedure. 
    --                     These vectors may be of any length.
    --
    --     Use           :
    --                      VARIABLE a : std_logic_vector ( 7 DOWNTO 0 ) := X"FF";
    --                      VARIABLE b : INTEGER;
    --                      IF ( a < b )  THEN
    --
    --     See Also      : RegEqual, RegLessThan, RegGreaterThan,
    -------------------------------------------------------------------------------
    FUNCTION  "<" ( CONSTANT l  : std_logic_vector;
                    CONSTANT r  : std_logic_vector
                  ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION  "<" ( CONSTANT l  : std_logic_vector;
                    CONSTANT r  : INTEGER
                  ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION  "<" ( CONSTANT l  : INTEGER   ;
                    CONSTANT r  : std_logic_vector 
                  ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION  "<" ( CONSTANT l  : std_logic_vector;
                    CONSTANT r  : INTEGER
                  ) RETURN std_ulogic;
    -- -----------------------------------------------------------------------------
    FUNCTION  "<" ( CONSTANT l  : INTEGER   ;
                    CONSTANT r  : std_logic_vector 
                  ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "<" operator
    --
    --     Purpose       : Less-than relational operator for std_logic_vectors.
    --
    --     Parameters    :     result         left             right
    --                        std_ulogic  std_ulogic_vector   std_ulogic_vector
    --                        BOOLEAN     INTEGER            std_ulogic_vector
    --                        BOOLEAN     std_ulogic_vector   INTEGER
    --                        std_ulogic  INTEGER            std_ulogic_vector
    --                        std_ulogic  std_ulogic_vector   INTEGER
    --
    --     NOTE          : The std_ulogic_vector operands are assumed to be 
    --                     in  DefaultRegMode. If not they will be converted
    --                     to DefaultRegMode in the compare procedure. 
    --                     These vectors may be of any length.
    --
    --     Use           :
    --                      VARIABLE a : std_ulogic_vector ( 7 DOWNTO 0 ) := X"FF";
    --                      VARIABLE b : INTEGER;
    --                      IF ( a < b )  THEN
    --
    --     See Also      : RegEqual, RegLessThan, RegGreaterThan,
    -------------------------------------------------------------------------------
    FUNCTION  "<" ( CONSTANT l  : std_ulogic_vector;
                    CONSTANT r  : std_ulogic_vector
                  ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION  "<" ( CONSTANT l  : std_ulogic_vector;
                    CONSTANT r  : INTEGER
                  ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION  "<" ( CONSTANT l  : INTEGER   ;
                    CONSTANT r  : std_ulogic_vector 
                  ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION  "<" ( CONSTANT l  : std_ulogic_vector;
                    CONSTANT r  : INTEGER
                  ) RETURN std_ulogic;
    -- -----------------------------------------------------------------------------
    FUNCTION  "<" ( CONSTANT l  : INTEGER   ;
                    CONSTANT r  : std_ulogic_vector 
                  ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "<=" operator
    --    
    --     Purpose       : Less-than-or-equal relational operator 
    --                     for std_logic_vectors.
    --     
    --     Parameters    :     result         left       right
    --                        std_ulogic  std_logic_vector   std_logic_vector
    --                        BOOLEAN     INTEGER            std_logic_vector
    --                        BOOLEAN     std_logic_vector   INTEGER
    --                        std_ulogic  INTEGER            std_logic_vector
    --                        std_ulogic  std_logic_vector   INTEGER
    --     
    --     NOTE          : The std_logic_vector operands are assumed to be 
    --                     in  DefaultRegMode. If not they will be converted
    --                     to DefaultRegMode in the compare procedure. 
    --                     These vectors may be of any length.
    --
    --     Use           : 
    --                      VARIABLE a : std_logic_vector ( 7 DOWNTO 0 ) := X"FF";
    --                      VARIABLE b : INTEGER;
    --                      IF ( a <= b )  THEN 
    --     
    --     See Also      : compare, RegLessThan, RegGreaterThan,
    -------------------------------------------------------------------------------
    FUNCTION  "<=" ( CONSTANT l  : std_logic_vector;
                     CONSTANT r  : std_logic_vector
                   ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION  "<=" ( CONSTANT l  : std_logic_vector;
                     CONSTANT r  : INTEGER
                   ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION  "<=" ( CONSTANT l  : INTEGER   ;
                     CONSTANT r  : std_logic_vector 
                   ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION  "<=" ( CONSTANT l  : std_logic_vector;
                     CONSTANT r  : INTEGER
                   ) RETURN std_ulogic;
    -- -----------------------------------------------------------------------------
    FUNCTION  "<=" ( CONSTANT l  : INTEGER   ;
                     CONSTANT r  : std_logic_vector 
                   ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "<=" operator
    --    
    --     Purpose       : Less-than-or-equal relational operator 
    --                     for std_ulogic_vectors.
    --     
    --     Parameters    :     result         left       right
    --                        std_ulogic  std_ulogic_vector   std_ulogic_vector
    --                        BOOLEAN     INTEGER            std_ulogic_vector
    --                        BOOLEAN     std_ulogic_vector   INTEGER
    --                        std_ulogic  INTEGER            std_ulogic_vector
    --                        std_ulogic  std_ulogic_vector   INTEGER
    --     
    --     NOTE          : The std_ulogic_vector operands are assumed to be 
    --                     in  DefaultRegMode. If not they will be converted
    --                     to DefaultRegMode in the compare procedure. 
    --                     These vectors may be of any length.
    --
    --     Use           : 
    --                      VARIABLE a : std_ulogic_vector ( 7 DOWNTO 0 ) := X"FF";
    --                      VARIABLE b : INTEGER;
    --                      IF ( a <= b )  THEN 
    --     
    --     See Also      : compare, RegLessThan, RegGreaterThan,
    -------------------------------------------------------------------------------
    FUNCTION  "<=" ( CONSTANT l  : std_ulogic_vector;
                     CONSTANT r  : std_ulogic_vector
                   ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION  "<=" ( CONSTANT l  : std_ulogic_vector;
                     CONSTANT r  : INTEGER
                   ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION  "<=" ( CONSTANT l  : INTEGER   ;
                     CONSTANT r  : std_ulogic_vector 
                   ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION  "<=" ( CONSTANT l  : std_ulogic_vector;
                     CONSTANT r  : INTEGER
                   ) RETURN std_ulogic;
    -- -----------------------------------------------------------------------------
    FUNCTION  "<=" ( CONSTANT l  : INTEGER   ;
                     CONSTANT r  : std_ulogic_vector 
                   ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded "<=" operator
    -- 1.2.26 and 1.2.28     
    --     Purpose       : Less-than-or-equal relational operator for bit_vectors.
    --     
    --     Parameters    :     result         left       right
    --                        BOOLEAN       INTEGER    bit_vector
    --                        BOOLEAN      bit_vector   INTEGER
    --     
    --     NOTE          : The bit_vector operands are assumed to be 
    --                     in  DefaultRegMode. If not they will be converted
    --                     to DefaultRegMode in the compare procedure. 
    --                     These vectors may be of any length.
    --
    --     Use           :
    --                      VARIABLE a : bit_vector ( 7 DOWNTO 0 ) := X"FF";
    --                      VARIABLE b : INTEGER;
    --                      IF ( a <= b )  THEN 
    --     
    --     See Also      : compare, RegLessThan, RegGreaterThan,
    -------------------------------------------------------------------------------
    FUNCTION  "<=" ( CONSTANT l  : bit_vector;
                     CONSTANT r  : bit_vector
                  ) RETURN bit;
    -------------------------------------------------------------------------------
    FUNCTION  "<=" ( CONSTANT l  : bit_vector;
                    CONSTANT r  : INTEGER
                  ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION  "<=" ( CONSTANT l  : INTEGER   ;
                     CONSTANT r  : bit_vector 
                   ) RETURN BOOLEAN;
     -------------------------------------------------------------------------------
    FUNCTION  "<=" ( CONSTANT l  : bit_vector;
                     CONSTANT r  : INTEGER
                   ) RETURN bit;
     -- -----------------------------------------------------------------------------
    FUNCTION  "<=" ( CONSTANT l  : INTEGER   ;
                     CONSTANT r  : bit_vector 
                   ) RETURN bit;

    -------------------------------------------------------------------------------
    --     Function Name : Overloaded ">" operator
    -- 1.2.18 and 1.2.20     
    --     Purpose       : greater-than relational operator for bit_vectors.
    --     
    --     Parameters    :     result         left       right
    --                        BOOLEAN       INTEGER    bit_vector
    --                        BOOLEAN      bit_vector   INTEGER
    --     
    --     NOTE          : The bit_vector operands are assumed to be 
    --                     in  DefaultRegMode. If not they will be converted
    --                     to DefaultRegMode in the compare procedure. 
    --                     These vectors may be of any length.
    --
    --     Use           :
    --                      VARIABLE a : bit_vector ( 7 DOWNTO 0 ) := X"FF";
    --                      VARIABLE b : INTEGER;
    --                      IF ( a > b )  THEN 
    --     
    --     See Also      : compare, RegLessThan, RegGreaterThan,
    -------------------------------------------------------------------------------
    FUNCTION  ">" ( CONSTANT l  : bit_vector;
                    CONSTANT r  : bit_vector
                  ) RETURN bit;
    -------------------------------------------------------------------------------
    FUNCTION  ">" ( CONSTANT l  : bit_vector;
                    CONSTANT r  : INTEGER
                  ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION  ">" ( CONSTANT l  : INTEGER   ;
                    CONSTANT r  : bit_vector 
                  ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION  ">" ( CONSTANT l  : bit_vector;
                    CONSTANT r  : INTEGER
                  ) RETURN bit;
    -- -----------------------------------------------------------------------------
    FUNCTION  ">" ( CONSTANT l  : INTEGER   ;
                    CONSTANT r  : bit_vector 
                  ) RETURN bit;
    --------------------------------------------------------------------------------
    --     Function Name : Overloaded ">" operator
    --    
    --     Purpose       : Greater-than relational operator for std_logic_vectors.
    --     
    --     Parameters    :     result         left       right
    --                        std_ulogic  std_logic_vector   std_logic_vector
    --                        BOOLEAN     INTEGER            std_logic_vector
    --                        BOOLEAN     std_logic_vector   INTEGER
    --                        std_ulogic  INTEGER            std_logic_vector
    --                        std_ulogic  std_logic_vector   INTEGER
    --     
    --     NOTE          : The std_logic_vector operands are assumed to be 
    --                     in  DefaultRegMode. If not they will be converted
    --                     to DefaultRegMode in the compare procedure. 
    --                     These vectors may be of any length.
    --
    --     Use           : 
    --                      VARIABLE a : std_logic_vector ( 7 DOWNTO 0 ) := X"FF";
    --                      VARIABLE b : INTEGER;
    --                      IF ( a > b )  THEN 
    --     
    --     See Also      : RegEqual, RegLessThan, RegGreaterThan,
    -------------------------------------------------------------------------------
    FUNCTION  ">" ( CONSTANT l  : std_logic_vector;
                    CONSTANT r  : std_logic_vector
                  ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION  ">" ( CONSTANT l  : std_logic_vector;
                    CONSTANT r  : INTEGER
                  ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION  ">" ( CONSTANT l  : INTEGER   ;
                    CONSTANT r  : std_logic_vector 
                  ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION  ">" ( CONSTANT l  : std_logic_vector;
                    CONSTANT r  : INTEGER
                  ) RETURN std_ulogic;
    -- -----------------------------------------------------------------------------
    FUNCTION  ">" ( CONSTANT l  : INTEGER   ;
                    CONSTANT r  : std_logic_vector 
                  ) RETURN std_ulogic;
    --------------------------------------------------------------------------------
    --     Function Name : Overloaded ">" operator
    --    
    --     Purpose       : Greater-than relational operator for std_ulogic_vectors.
    --     
    --     Parameters    :     result         left       right
    --                        std_ulogic  std_ulogic_vector   std_ulogic_vector
    --                        BOOLEAN     INTEGER            std_ulogic_vector
    --                        BOOLEAN     std_ulogic_vector   INTEGER
    --                        std_ulogic  INTEGER            std_ulogic_vector
    --                        std_ulogic  std_ulogic_vector   INTEGER
    --     
    --     NOTE          : The std_ulogic_vector operands are assumed to be 
    --                     in  DefaultRegMode. If not they will be converted
    --                     to DefaultRegMode in the compare procedure. 
    --                     These vectors may be of any length.
    --
    --     Use           : 
    --                      VARIABLE a : std_ulogic_vector ( 7 DOWNTO 0 ) := X"FF";
    --                      VARIABLE b : INTEGER;
    --                      IF ( a > b )  THEN 
    --     
    --     See Also      : RegEqual, RegLessThan, RegGreaterThan,
    -------------------------------------------------------------------------------
    FUNCTION  ">" ( CONSTANT l  : std_ulogic_vector;
                    CONSTANT r  : std_ulogic_vector
                  ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION  ">" ( CONSTANT l  : std_ulogic_vector;
                    CONSTANT r  : INTEGER
                  ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION  ">" ( CONSTANT l  : INTEGER   ;
                    CONSTANT r  : std_ulogic_vector 
                  ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION  ">" ( CONSTANT l  : std_ulogic_vector;
                    CONSTANT r  : INTEGER
                  ) RETURN std_ulogic;
    -- -----------------------------------------------------------------------------
    FUNCTION  ">" ( CONSTANT l  : INTEGER   ;
                    CONSTANT r  : std_ulogic_vector 
                  ) RETURN std_ulogic;

    -------------------------------------------------------------------------------
    --     Function Name : Overloaded ">=" operator
    -- 1.2.26 and 1.2.28     
    --     Purpose       : greater-than-or-equal relational operator for bit_vectors.
    --     
    --     Parameters    :     result         left       right
    --                        BOOLEAN       INTEGER    bit_vector
    --                        BOOLEAN      bit_vector   INTEGER
    --     
    --     NOTE          : The bit_vector operands are assumed to be 
    --                     in  DefaultRegMode. If not they will be converted
    --                     to DefaultRegMode in the compare procedure. 
    --                     These vectors may be of any length.
    --
    --     Use           :
    --                      VARIABLE a : bit_vector ( 7 DOWNTO 0 ) := X"FF";
    --                      VARIABLE b : INTEGER;
    --                      IF ( a >= b )  THEN 
    --     
    --     See Also      : compare, RegLessThan, RegGreaterThan,
    -------------------------------------------------------------------------------
    FUNCTION  ">=" ( CONSTANT l  : bit_vector;
                     CONSTANT r  : bit_vector
                   ) RETURN bit;
    -------------------------------------------------------------------------------
    FUNCTION  ">=" ( CONSTANT l  : bit_vector;
                     CONSTANT r  : INTEGER
                   ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION  ">=" ( CONSTANT l  : INTEGER   ;
                     CONSTANT r  : bit_vector 
                   ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION  ">=" ( CONSTANT l  : bit_vector;
                     CONSTANT r  : INTEGER
                   ) RETURN bit;
    -- -----------------------------------------------------------------------------
    FUNCTION  ">=" ( CONSTANT l  : INTEGER   ;
                     CONSTANT r  : bit_vector 
                   ) RETURN bit;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded ">=" operator
    --    
    --     Purpose       : Greater-than-or-equal relational operator 
    --                     for std_logic_vectors.
    --     
    --     Parameters    :     result         left       right
    --                        std_ulogic  std_logic_vector   std_logic_vector
    --                        BOOLEAN     INTEGER            std_logic_vector
    --                        BOOLEAN     std_logic_vector   INTEGER
    --                        std_ulogic  INTEGER            std_logic_vector
    --                        std_ulogic  std_logic_vector   INTEGER
    --     
    --     NOTE          : The std_logic_vector operands are assumed to be 
    --                     in  DefaultRegMode. If not they will be converted
    --                     to DefaultRegMode in the compare procedure. 
    --                     These vectors may be of any length.
    --
    --     Use           : 
    --                      VARIABLE a : std_logic_vector ( 7 DOWNTO 0 ) := X"FF";
    --                      VARIABLE b : INTEGER;
    --                      IF ( a >= b )  THEN 
    --     
    --     See Also      : compare, RegLessThan, RegGreaterThan,
    -------------------------------------------------------------------------------
    FUNCTION  ">=" ( CONSTANT l  : std_logic_vector;
                     CONSTANT r  : std_logic_vector
                   ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION  ">=" ( CONSTANT l  : std_logic_vector;
                     CONSTANT r  : INTEGER
                   ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION  ">=" ( CONSTANT l  : INTEGER   ;
                     CONSTANT r  : std_logic_vector 
                   ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION  ">=" ( CONSTANT l  : std_logic_vector;
                     CONSTANT r  : INTEGER
                   ) RETURN std_ulogic;
    -- -----------------------------------------------------------------------------
    FUNCTION  ">=" ( CONSTANT l  : INTEGER   ;
                     CONSTANT r  : std_logic_vector 
                   ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    --     Function Name : Overloaded ">=" operator
    --    
    --     Purpose       : Greater-than-or-equal relational operator 
    --                     for std_ulogic_vectors.
    --     
    --     Parameters    :     result         left       right
    --                        std_ulogic  std_ulogic_vector   std_ulogic_vector
    --                        BOOLEAN     INTEGER            std_ulogic_vector
    --                        BOOLEAN     std_ulogic_vector   INTEGER
    --                        std_ulogic  INTEGER            std_ulogic_vector
    --                        std_ulogic  std_ulogic_vector   INTEGER
    --     
    --     NOTE          : The std_ulogic_vector operands are assumed to be 
    --                     in  DefaultRegMode. If not they will be converted
    --                     to DefaultRegMode in the compare procedure. 
    --                     These vectors may be of any length.
    --
    --     Use           : 
    --                      VARIABLE a : std_ulogic_vector ( 7 DOWNTO 0 ) := X"FF";
    --                      VARIABLE b : INTEGER;
    --                      IF ( a >= b )  THEN 
    --     
    --     See Also      : compare, RegLessThan, RegGreaterThan,
    -------------------------------------------------------------------------------
    FUNCTION  ">=" ( CONSTANT l  : std_ulogic_vector;
                     CONSTANT r  : std_ulogic_vector
                   ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION  ">=" ( CONSTANT l  : std_ulogic_vector;
                     CONSTANT r  : INTEGER
                   ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION  ">=" ( CONSTANT l  : INTEGER   ;
                     CONSTANT r  : std_ulogic_vector 
                   ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION  ">=" ( CONSTANT l  : std_ulogic_vector;
                     CONSTANT r  : INTEGER
                   ) RETURN std_ulogic;
    -- -----------------------------------------------------------------------------
    FUNCTION  ">=" ( CONSTANT l  : INTEGER   ;
                     CONSTANT r  : std_ulogic_vector 
                   ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    --     Function Name : RegEqual
    -- 1.2.49
    --     Overloading   : Input parameter TYPEs.
    --
    --     Purpose       : Compute equality relation for bit_vector
    --
    --     Parameters    : l       - input bit_vector | INTEGER
    --                     r       - input bit_vector | INTEGER
    --                     SrcRegMode - input regmode_type, indicating the format of
    --                               the bit_vector operands (l,r).
    --                               Default is TwosComp.
    --
    --     Result        : BOOLEAN | bit. 
    --
    --     NOTE          : The operands may be of any length, and may be different
    --                     lengths.
    --
    --                     Overloading not defined for both inputs of INTEGER type.
    --
    --     Use           :
    --                      VARIABLE a, b : bit_vector ( 7 DOWNTO 0 );
    --                      IF ( RegEqual ( a, b, TwosComp)   )  THEN
    --
    --     See Also      : RegLessThanOrEqual, RegGreaterThan, RegGreaterThanOrEqual.
    -------------------------------------------------------------------------------
    FUNCTION RegEqual     ( CONSTANT l          : IN bit_vector;
                            CONSTANT r          : IN bit_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN bit;
    -----------------------------------------------------------------------------
    FUNCTION RegEqual    (  CONSTANT l        : IN bit_vector;
                            CONSTANT r        : IN bit_vector;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION RegEqual     ( CONSTANT l          : IN bit_vector;
                            CONSTANT r          : IN INTEGER;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegEqual    (  CONSTANT l          : IN INTEGER;
                            CONSTANT r          : IN bit_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegEqual     ( CONSTANT l          : IN bit_vector;
                            CONSTANT r          : IN INTEGER;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN bit;
    -------------------------------------------------------------------------------
    FUNCTION RegEqual    (  CONSTANT l          : IN INTEGER;
                            CONSTANT r          : IN bit_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN bit;
    -------------------------------------------------------------------------------
    --     Function Name : RegEqual
    --
    --     Overloading   : Input parameter TYPEs.
    --    
    --     Purpose       : Compute equality relation for std_logic_vectors
    --     
    --     Parameters    : l       - input std_logic_vector | INTEGER
    --                     r       - input std_logic_vector | INTEGER
    --                     SrcRegMode - input regmode_type, indicating the format of
    --                               the std_logic_vector operands (l,r).
    --                               Default is TwosComp.
    --     
    --     Result        : BOOLEAN | std_ulogic
    --
    --     NOTE          : The operands may be of any length, and may be different
    --                     lengths. 
    --
    --                     Overloading not defined for both inputs of INTEGER type.
    --
    --     Use           : 
    --                      VARIABLE a, b : std_logic_vector ( 7 DOWNTO 0 );
    --                      IF ( RegEqual ( a, b, TwosComp)   )  THEN 
    --     
    --     See Also      : compare, RegLessThan, RegLessThanOrEqual, RegGreaterThan, 
    --                     RegGreaterThanOrEqual.

    -------------------------------------------------------------------------------
    FUNCTION RegEqual     ( CONSTANT l          : IN std_logic_vector;
                            CONSTANT r          : IN std_logic_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic;
    -----------------------------------------------------------------------------
    FUNCTION RegEqual    (  CONSTANT l          : IN std_logic_vector;
                            CONSTANT r          : IN std_logic_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION RegEqual     ( CONSTANT l          : IN std_logic_vector;
                            CONSTANT r          : IN INTEGER;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegEqual    (  CONSTANT l          : IN INTEGER;
                            CONSTANT r          : IN std_logic_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegEqual     ( CONSTANT l          : IN std_logic_vector;
                            CONSTANT r          : IN INTEGER;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION RegEqual    (  CONSTANT l          : IN INTEGER;
                            CONSTANT r          : IN std_logic_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    --     Function Name : RegEqual
    --
    --     Overloading   : Input parameter TYPEs.
    --    
    --     Purpose       : Compute equality relation for std_ulogic_vectors
    --     
    --     Parameters    : l       - input std_ulogic_vector | INTEGER
    --                     r       - input std_ulogic_vector | INTEGER
    --                     SrcRegMode - input regmode_type, indicating the format of
    --                               the std_ulogic_vector operands (l,r).
    --                               Default is TwosComp.
    --     
    --     Result        : BOOLEAN | std_ulogic
    --
    --     NOTE          : The operands may be of any length, and may be different
    --                     lengths. 
    --
    --                     Overloading not defined for both inputs of INTEGER type.
    --
    --     Use           : 
    --                      VARIABLE a, b : std_ulogic_vector ( 7 DOWNTO 0 );
    --                      IF ( RegEqual ( a, b, TwosComp)   )  THEN 
    --     
    --     See Also      : compare, RegLessThan, RegLessThanOrEqual, RegGreaterThan, 
    --                     RegGreaterThanOrEqual.

    -------------------------------------------------------------------------------
    FUNCTION RegEqual     ( CONSTANT l          : IN std_ulogic_vector;
                            CONSTANT r          : IN std_ulogic_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic;
    -----------------------------------------------------------------------------
    FUNCTION RegEqual    (  CONSTANT l          : IN std_ulogic_vector;
                            CONSTANT r          : IN std_ulogic_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION RegEqual     ( CONSTANT l          : IN std_ulogic_vector;
                            CONSTANT r          : IN INTEGER;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegEqual    (  CONSTANT l          : IN INTEGER;
                            CONSTANT r          : IN std_ulogic_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegEqual     ( CONSTANT l          : IN std_ulogic_vector;
                            CONSTANT r          : IN INTEGER;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION RegEqual    (  CONSTANT l          : IN INTEGER;
                            CONSTANT r          : IN std_ulogic_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    --     Function Name : RegNotEqual
    -- 1.2.51
    --     Overloading   : Input parameter TYPEs.
    --
    --     Purpose       : Compute inequality relation for bit_vectors
    --
    --     Parameters    : l       - input bit_vector | INTEGER
    --                     r       - input bit_vector | INTEGER
    --                     SrcRegMode - input regmode_type, indicating the format of
    --                               the bit_vector operands (l,r).
    --                               Default is TwosComp.
    --
    --     Result        : BOOLEAN | bit
    --
    --     NOTE          : The operands may be of any length, and may be different
    --                     lengths.
    --
    --                     Overloading not defined for both inputs of INTEGER type.
    --
    --     Use           :
    --                      VARIABLE a, b : bit_vector ( 7 DOWNTO 0 );
    --                      IF ( RegNotEqual ( a, b, TwosComp)   )  THEN
    --
    --     See Also      : RegLessThan, RegLessThanOrEqual, RegGreaterThan,
    --                     RegGreaterThanOrEqual.
    -------------------------------------------------------------------------------
    FUNCTION RegNotEqual  ( CONSTANT l          : IN bit_vector;
                            CONSTANT r          : IN bit_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN bit;
    -----------------------------------------------------------------------------
    FUNCTION RegNotEqual  ( CONSTANT l          : IN bit_vector;
                            CONSTANT r          : IN bit_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION RegNotEqual  ( CONSTANT l          : IN bit_vector;
                            CONSTANT r          : IN INTEGER;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegNotEqual  ( CONSTANT l          : IN INTEGER;
                            CONSTANT r          : IN bit_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegNotEqual  ( CONSTANT l          : IN bit_vector;
                            CONSTANT r          : IN INTEGER;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN bit;
    -------------------------------------------------------------------------------
    FUNCTION RegNotEqual  ( CONSTANT l          : IN INTEGER;
                            CONSTANT r          : IN bit_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN bit;
    -- ----------------------------------------------------------------------------
    --     Function Name : RegNotEqual
    --    
    --     Purpose       : Compute inequality  relation for std_logic_vectors
    --     
    --     Parameters    : l       - input std_logic_vector | INTEGER
    --                     r       - input std_logic_vector | INTEGER
    --                     SrcRegMode - input regmode_type, indicating the format of
    --                               the std_logic_vector operands (l,r).
    --                               Default is TwosComp.
    --     
    --     Result        : BOOLEAN | std_ulogic
    --
    --     NOTE          : The operands may be of any length, and may be different
    --                     lengths. 
    --
    --                     Overloading not defined for both inputs of INTEGER type.
    --
    --     Use           : 
    --                      VARIABLE a, b : std_logic_vector ( 7 DOWNTO 0 );
    --                      IF ( RegNotEqual ( a, b, TwosComp)   )  THEN 
    --     
    --     See Also      : compare, RegLessThan, RegLessThanOrEqual, RegGreaterThan, 
    --                     RegGreaterThanOrEqual.
    -------------------------------------------------------------------------------
    FUNCTION RegNotEqual   ( CONSTANT l          : IN std_logic_vector;
                             CONSTANT r          : IN std_logic_vector;
                             CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                           ) RETURN std_ulogic;
    -----------------------------------------------------------------------------
    FUNCTION RegNotEqual   ( CONSTANT l          : IN std_logic_vector;
                             CONSTANT r          : IN std_logic_vector;
                             CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                           ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION RegNotEqual   ( CONSTANT l          : IN std_logic_vector;
                             CONSTANT r          : IN INTEGER;
                             CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                           ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegNotEqual   ( CONSTANT l          : IN INTEGER;
                             CONSTANT r          : IN std_logic_vector;
                             CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                           ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegNotEqual  ( CONSTANT l          : IN std_logic_vector;
                            CONSTANT r          : IN INTEGER;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION RegNotEqual  ( CONSTANT l          : IN INTEGER;
                            CONSTANT r          : IN std_logic_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic;
    -- ----------------------------------------------------------------------------
    --     Function Name : RegNotEqual
    --    
    --     Purpose       : Compute inequality  relation for std_ulogic_vectors
    --     
    --     Parameters    : l       - input std_ulogic_vector | INTEGER
    --                     r       - input std_ulogic_vector | INTEGER
    --                     SrcRegMode - input regmode_type, indicating the format of
    --                               the std_ulogic_vector operands (l,r).
    --                               Default is TwosComp.
    --     
    --     Result        : BOOLEAN | std_ulogic
    --
    --     NOTE          : The operands may be of any length, and may be different
    --                     lengths. 
    --
    --                     Overloading not defined for both inputs of INTEGER type.
    --
    --     Use           : 
    --                      VARIABLE a, b : std_ulogic_vector ( 7 DOWNTO 0 );
    --                      IF ( RegNotEqual ( a, b, TwosComp)   )  THEN 
    --     
    --     See Also      : compare, RegLessThan, RegLessThanOrEqual, RegGreaterThan, 
    --                     RegGreaterThanOrEqual.
    -------------------------------------------------------------------------------
    FUNCTION RegNotEqual   ( CONSTANT l          : IN std_ulogic_vector;
                             CONSTANT r          : IN std_ulogic_vector;
                             CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                           ) RETURN std_ulogic;
    -----------------------------------------------------------------------------
    FUNCTION RegNotEqual   ( CONSTANT l          : IN std_ulogic_vector;
                             CONSTANT r          : IN std_ulogic_vector;
                             CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                           ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION RegNotEqual   ( CONSTANT l          : IN std_ulogic_vector;
                             CONSTANT r          : IN INTEGER;
                             CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                           ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegNotEqual   ( CONSTANT l          : IN INTEGER;
                             CONSTANT r          : IN std_ulogic_vector;
                             CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                           ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegNotEqual  ( CONSTANT l          : IN std_ulogic_vector;
                            CONSTANT r          : IN INTEGER;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION RegNotEqual  ( CONSTANT l          : IN INTEGER;
                            CONSTANT r          : IN std_ulogic_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    --     Function Name : RegLessThan
    -- 1.2.49
    --     Overloading   : Input parameter TYPEs.
    --
    --     Purpose       : Compute a less than relation for bit_vector
    --
    --     Parameters    : l       - input bit_vector | INTEGER
    --                     r       - input bit_vector | INTEGER
    --                     SrcRegMode - input regmode_type, indicating the format of
    --                               the bit_vector operands (l,r).
    --                               Default is TwosComp.
    --
    --     Result        : BOOLEAN | bit. 
    --
    --     NOTE          : The operands may be of any length, and may be different
    --                     lengths.
    --
    --                     Overloading not defined for both inputs of INTEGER type.
    --
    --     Use           :
    --                      VARIABLE a, b : bit_vector ( 7 DOWNTO 0 );
    --                      IF ( RegLessThan ( a, b, TwosComp)   )  THEN
    --
    --     See Also      : RegLessThanOrEqual, RegGreaterThan, RegGreaterThanOrEqual.
    -------------------------------------------------------------------------------
    FUNCTION RegLessThan  ( CONSTANT l          : IN bit_vector;
                            CONSTANT r          : IN bit_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN bit;
    -----------------------------------------------------------------------------
    FUNCTION RegLessThan (  CONSTANT l        : IN bit_vector;
                            CONSTANT r        : IN bit_vector;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION RegLessThan  ( CONSTANT l          : IN bit_vector;
                            CONSTANT r          : IN INTEGER;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegLessThan (  CONSTANT l          : IN INTEGER;
                            CONSTANT r          : IN bit_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegLessThan  ( CONSTANT l          : IN bit_vector;
                            CONSTANT r          : IN INTEGER;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN bit;
    -------------------------------------------------------------------------------
    FUNCTION RegLessThan (  CONSTANT l          : IN INTEGER;
                            CONSTANT r          : IN bit_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN bit;
    -------------------------------------------------------------------------------
    --     Function Name : RegLessThan
    --
    --     Overloading   : Input parameter TYPEs.
    --    
    --     Purpose       : Compute a less than relation for std_logic_vectors
    --     
    --     Parameters    : l       - input std_logic_vector | INTEGER
    --                     r       - input std_logic_vector | INTEGER
    --                     SrcRegMode - input regmode_type, indicating the format of
    --                               the std_logic_vector operands (l,r).
    --                               Default is TwosComp.
    --     
    --     Result        : BOOLEAN relation. A TRUE value is returned if: l < r
    --
    --     NOTE          : The operands may be of any length, and may be different
    --                     lengths. 
    --
    --                     Overloading not defined for both inputs of INTEGER type.
    --
    --     Use           : 
    --                      VARIABLE a, b : std_logic_vector ( 7 DOWNTO 0 );
    --                      IF ( RegLessThan ( a, b, TwosComp)   )  THEN 
    --     
    --     See Also      : compare, RegLessThan, RegLessThanOrEqual, RegGreaterThan, 
    --                     RegGreaterThanOrEqual.

    -------------------------------------------------------------------------------
    FUNCTION RegLessThan  ( CONSTANT l          : IN std_logic_vector;
                            CONSTANT r          : IN std_logic_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic;
    -----------------------------------------------------------------------------
    FUNCTION RegLessThan (  CONSTANT l          : IN std_logic_vector;
                            CONSTANT r          : IN std_logic_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION RegLessThan  ( CONSTANT l          : IN std_logic_vector;
                            CONSTANT r          : IN INTEGER;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegLessThan (  CONSTANT l          : IN INTEGER;
                            CONSTANT r          : IN std_logic_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegLessThan  ( CONSTANT l          : IN std_logic_vector;
                            CONSTANT r          : IN INTEGER;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION RegLessThan (  CONSTANT l          : IN INTEGER;
                            CONSTANT r          : IN std_logic_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    --     Function Name : RegLessThan
    --
    --     Overloading   : Input parameter TYPEs.
    --    
    --     Purpose       : Compute a less than relation for std_ulogic_vectors
    --     
    --     Parameters    : l       - input std_ulogic_vector | INTEGER
    --                     r       - input std_ulogic_vector | INTEGER
    --                     SrcRegMode - input regmode_type, indicating the format of
    --                               the std_ulogic_vector operands (l,r).
    --                               Default is TwosComp.
    --     
    --     Result        : BOOLEAN relation. A TRUE value is returned if: l < r
    --
    --     NOTE          : The operands may be of any length, and may be different
    --                     lengths. 
    --
    --                     Overloading not defined for both inputs of INTEGER type.
    --
    --     Use           : 
    --                      VARIABLE a, b : std_ulogic_vector ( 7 DOWNTO 0 );
    --                      IF ( RegLessThan ( a, b, TwosComp)   )  THEN 
    --     
    --     See Also      : compare, RegLessThan, RegLessThanOrEqual, RegGreaterThan, 
    --                     RegGreaterThanOrEqual.

    -------------------------------------------------------------------------------
    FUNCTION RegLessThan  ( CONSTANT l          : IN std_ulogic_vector;
                            CONSTANT r          : IN std_ulogic_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic;
    -----------------------------------------------------------------------------
    FUNCTION RegLessThan (  CONSTANT l          : IN std_ulogic_vector;
                            CONSTANT r          : IN std_ulogic_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION RegLessThan  ( CONSTANT l          : IN std_ulogic_vector;
                            CONSTANT r          : IN INTEGER;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegLessThan (  CONSTANT l          : IN INTEGER;
                            CONSTANT r          : IN std_ulogic_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegLessThan  ( CONSTANT l          : IN std_ulogic_vector;
                            CONSTANT r          : IN INTEGER;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION RegLessThan (  CONSTANT l          : IN INTEGER;
                            CONSTANT r          : IN std_ulogic_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    --     Function Name : RegLessThanOrEqual
    -- 1.2.51
    --     Overloading   : Input parameter TYPEs.
    --
    --     Purpose       : Compute a less than or equal relation for bit_vectors
    --
    --     Parameters    : l       - input bit_vector | INTEGER
    --                     r       - input bit_vector | INTEGER
    --                     SrcRegMode - input regmode_type, indicating the format of
    --                               the bit_vector operands (l,r).
    --                               Default is TwosComp.
    --
    --     Result        : BOOLEAN | bit
    --
    --     NOTE          : The operands may be of any length, and may be different
    --                     lengths.
    --
    --                     Overloading not defined for both inputs of INTEGER type.
    --
    --     Use           :
    --                      VARIABLE a, b : bit_vector ( 7 DOWNTO 0 );
    --                      IF ( RegLessThanOrEqual ( a, b, TwosComp)   )  THEN
    --
    --     See Also      : RegLessThan, RegLessThanOrEqual, RegGreaterThan,
    --                     RegGreaterThanOrEqual.
    -------------------------------------------------------------------------------
    FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN bit_vector;
                                  CONSTANT r          : IN bit_vector;
                                  CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                ) RETURN bit;
    -----------------------------------------------------------------------------
    FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN bit_vector;
                                  CONSTANT r          : IN bit_vector;
                                  CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN bit_vector;
                                  CONSTANT r          : IN INTEGER;
                                  CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN INTEGER;
                                  CONSTANT r          : IN bit_vector;
                                  CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN bit_vector;
                                  CONSTANT r          : IN INTEGER;
                                  CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                ) RETURN bit;
    -------------------------------------------------------------------------------
    FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN INTEGER;
                                  CONSTANT r          : IN bit_vector;
                                  CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                ) RETURN bit;
    -- ----------------------------------------------------------------------------
    --     Function Name : RegLessThanOrEqual
    --    
    --     Purpose       : Compute a less than or equal relation for std_logic_vectors
    --     
    --     Parameters    : l       - input std_logic_vector | INTEGER
    --                     r       - input std_logic_vector | INTEGER
    --                     SrcRegMode - input regmode_type, indicating the format of
    --                               the std_logic_vector operands (l,r).
    --                               Default is TwosComp.
    --     
    --     Result        : BOOLEAN | std_ulogic
    --
    --     NOTE          : The operands may be of any length, and may be different
    --                     lengths. 
    --
    --                     Overloading not defined for both inputs of INTEGER type.
    --
    --     Use           : 
    --                      VARIABLE a, b : std_logic_vector ( 7 DOWNTO 0 );
    --                      IF ( RegLessThanOrEqual ( a, b, TwosComp)   )  THEN 
    --     
    --     See Also      : compare, RegLessThan, RegLessThanOrEqual, RegGreaterThan, 
    --                     RegGreaterThanOrEqual.
    -------------------------------------------------------------------------------
    FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN std_logic_vector;
                                  CONSTANT r          : IN std_logic_vector;
                                  CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                ) RETURN std_ulogic;
    -----------------------------------------------------------------------------
    FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN std_logic_vector;
                                  CONSTANT r          : IN std_logic_vector;
                                  CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN std_logic_vector;
                                  CONSTANT r          : IN INTEGER;
                                  CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN INTEGER;
                                  CONSTANT r          : IN std_logic_vector;
                                  CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN std_logic_vector;
                                  CONSTANT r          : IN INTEGER;
                                  CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN INTEGER;
                                  CONSTANT r          : IN std_logic_vector;
                                  CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                ) RETURN std_ulogic;
    -- ----------------------------------------------------------------------------
    --     Function Name : RegLessThanOrEqual
    --    
    --     Purpose       : Compute a less than or equal relation for std_ulogic_vectors
    --     
    --     Parameters    : l       - input std_ulogic_vector | INTEGER
    --                     r       - input std_ulogic_vector | INTEGER
    --                     SrcRegMode - input regmode_type, indicating the format of
    --                               the std_ulogic_vector operands (l,r).
    --                               Default is TwosComp.
    --     
    --     Result        : BOOLEAN | std_ulogic
    --
    --     NOTE          : The operands may be of any length, and may be different
    --                     lengths. 
    --
    --                     Overloading not defined for both inputs of INTEGER type.
    --
    --     Use           : 
    --                      VARIABLE a, b : std_ulogic_vector ( 7 DOWNTO 0 );
    --                      IF ( RegLessThanOrEqual ( a, b, TwosComp)   )  THEN 
    --     
    --     See Also      : compare, RegLessThan, RegLessThanOrEqual, RegGreaterThan, 
    --                     RegGreaterThanOrEqual.
    -------------------------------------------------------------------------------
    FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN std_ulogic_vector;
                                  CONSTANT r          : IN std_ulogic_vector;
                                  CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                ) RETURN std_ulogic;
    -----------------------------------------------------------------------------
    FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN std_ulogic_vector;
                                  CONSTANT r          : IN std_ulogic_vector;
                                  CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN std_ulogic_vector;
                                  CONSTANT r          : IN INTEGER;
                                  CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN INTEGER;
                                  CONSTANT r          : IN std_ulogic_vector;
                                  CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN std_ulogic_vector;
                                  CONSTANT r          : IN INTEGER;
                                  CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN INTEGER;
                                  CONSTANT r          : IN std_ulogic_vector;
                                  CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    --     Function Name : RegGreaterThan
    -- 1.2.53
    --     Overloading   : Input parameter TYPEs.
    --
    --     Purpose       : Compute a greater than relation for bit_vectors
    --
    --     Parameters    : l       - input bit_vector | INTEGER
    --                     r       - input bit_vector | INTEGER
    --                     SrcRegMode - input regmode_type, indicating the format of
    --                               the bit_vector operands (l,r).
    --                               Default is TwosComp.
    --
    --     Result        : BOOLEAN | bit
    --
    --     NOTE          : The operands may be of any length, and may be different
    --                     lengths.
    --
    --                     Overloading not defined for both inputs of INTEGER type.
    --
    --     Use           :
    --                      VARIABLE a, b : bit_vector ( 7 DOWNTO 0 );
    --                      IF ( RegGreaterThan ( a, b, TwosComp)   )  THEN
    --
    --     See Also      : RegLessThan, RegLessThanOrEqual, RegGreaterThan,
    --                     RegGreaterThanOrEqual.
    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThan ( CONSTANT l          : IN bit_vector;
                              CONSTANT r          : IN bit_vector;
                              CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                            ) RETURN bit;
    -----------------------------------------------------------------------------
    FUNCTION RegGreaterThan ( CONSTANT l           : IN bit_vector;
                              CONSTANT r           : IN bit_vector;
                              CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
                            ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION RegGreaterThan ( CONSTANT l          : IN bit_vector;
                              CONSTANT r          : IN INTEGER;
                              CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                            ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThan ( CONSTANT l          : IN INTEGER;
                              CONSTANT r          : IN bit_vector;
                              CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                            ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThan  ( CONSTANT l          : IN bit_vector;
                               CONSTANT r          : IN INTEGER;
                               CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                             ) RETURN bit;
    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThan (  CONSTANT l          : IN INTEGER;
                               CONSTANT r          : IN bit_vector;
                               CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                             ) RETURN bit;
    -------------------------------------------------------------------------------
    --     Function Name : RegGreaterThan
    --
    --     Overloading   : Input parameter TYPEs.
    --    
    --     Purpose       : Compute a greater than relation for std_logic_vectors
    --     
    --     Parameters    : l       - input std_logic_vector | INTEGER
    --                     r       - input std_logic_vector | INTEGER
    --                     SrcRegMode - input regmode_type, indicating the format of
    --                               the std_logic_vector operands (l,r).
    --                               Default is TwosComp.
    --     
    --     Result        : BOOLEAN | std_ulogic
    --
    --     NOTE          : The operands may be of any length, and may be different
    --                     lengths. 
    --
    --                     Overloading not defined for both inputs of INTEGER type.
    --
    --     Use           : 
    --                      VARIABLE a, b : std_logic_vector ( 7 DOWNTO 0 );
    --                      IF ( RegGreaterThan ( a, b, TwosComp)   )  THEN 
    --     
    --     See Also      : compare, RegLessThan, RegLessThanOrEqual, RegGreaterThan, 
    --                     RegGreaterThanOrEqual.

    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThan  ( CONSTANT l          : IN std_logic_vector;
                               CONSTANT r          : IN std_logic_vector;
                               CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                             ) RETURN std_ulogic;
    -----------------------------------------------------------------------------
    FUNCTION RegGreaterThan (  CONSTANT l          : IN std_logic_vector;
                               CONSTANT r          : IN std_logic_vector;
                               CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                             ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION RegGreaterThan  ( CONSTANT l          : IN std_logic_vector;
                               CONSTANT r          : IN INTEGER;
                               CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                             ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThan (  CONSTANT l          : IN INTEGER;
                               CONSTANT r          : IN std_logic_vector;
                               CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                             ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThan  ( CONSTANT l          : IN std_logic_vector;
                               CONSTANT r          : IN INTEGER;
                               CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                             ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThan (  CONSTANT l          : IN INTEGER;
                               CONSTANT r          : IN std_logic_vector;
                               CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                             ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    --     Function Name : RegGreaterThan
    --
    --     Overloading   : Input parameter TYPEs.
    --    
    --     Purpose       : Compute a greater than relation for std_ulogic_vectors
    --     
    --     Parameters    : l       - input std_ulogic_vector | INTEGER
    --                     r       - input std_ulogic_vector | INTEGER
    --                     SrcRegMode - input regmode_type, indicating the format of
    --                               the std_ulogic_vector operands (l,r).
    --                               Default is TwosComp.
    --     
    --     Result        : BOOLEAN | std_ulogic
    --
    --     NOTE          : The operands may be of any length, and may be different
    --                     lengths. 
    --
    --                     Overloading not defined for both inputs of INTEGER type.
    --
    --     Use           : 
    --                      VARIABLE a, b : std_ulogic_vector ( 7 DOWNTO 0 );
    --                      IF ( RegGreaterThan ( a, b, TwosComp)   )  THEN 
    --     
    --     See Also      : compare, RegLessThan, RegLessThanOrEqual, RegGreaterThan, 
    --                     RegGreaterThanOrEqual.

    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThan  ( CONSTANT l          : IN std_ulogic_vector;
                               CONSTANT r          : IN std_ulogic_vector;
                               CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                             ) RETURN std_ulogic;
    -----------------------------------------------------------------------------
    FUNCTION RegGreaterThan (  CONSTANT l          : IN std_ulogic_vector;
                               CONSTANT r          : IN std_ulogic_vector;
                               CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                             ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION RegGreaterThan  ( CONSTANT l          : IN std_ulogic_vector;
                               CONSTANT r          : IN INTEGER;
                               CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                             ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThan (  CONSTANT l          : IN INTEGER;
                               CONSTANT r          : IN std_ulogic_vector;
                               CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                             ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThan  ( CONSTANT l          : IN std_ulogic_vector;
                               CONSTANT r          : IN INTEGER;
                               CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                             ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThan (  CONSTANT l          : IN INTEGER;
                               CONSTANT r          : IN std_ulogic_vector;
                               CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                             ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    --     Function Name : RegGreaterThanOrEqual
    -- 
    --     Overloading   : Input parameter TYPEs.
    --
    --     Purpose       : Compute a greater than or equal relation 
    --                     for bit_vectors
    --
    --     Parameters    : l       - input bit_vector | INTEGER
    --                     r       - input bit_vector | INTEGER
    --                     SrcRegMode - input regmode_type, indicating the format of
    --                               the bit_vector operands (l,r).
    --                               Default is TwosComp.
    --
    --     Result        : BOOLEAN |bit
    --
    --     NOTE          : The operands may be of any length, and may be different
    --                     lengths.
    --
    --                     Overloading not defined for both inputs of INTEGER type.
    --
    --     Use           :
    --                      VARIABLE a, b : bit_vector ( 7 DOWNTO 0 );
    --                      IF ( RegGreaterThanOrEqual (a, b, TwosComp) )  THEN
    --
    --     See Also      : RegLessThan, RegLessThanOrEqual, RegGreaterThan,
    --                     RegGreaterThanOrEqual.
   -------------------------------------------------------------------------------
    FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN bit_vector;
                                     CONSTANT r          : IN bit_vector;
                                     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                   ) RETURN bit;
    -----------------------------------------------------------------------------
    FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN bit_vector;
                                     CONSTANT r          : IN bit_vector;
                                     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                  ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN bit_vector;
                                     CONSTANT r          : IN INTEGER;
                                     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                   ) RETURN BOOLEAN;

    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN INTEGER;
                                     CONSTANT r          : IN bit_vector;
                                     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                  ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN bit_vector;
                                     CONSTANT r          : IN INTEGER;
                                     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                   ) RETURN bit;
    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN INTEGER;
                                     CONSTANT r          : IN bit_vector;
                                     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                   ) RETURN bit;
    -- ----------------------------------------------------------------------------
    --     Function Name : RegGreaterThanOrEqual
    --    
    --     Purpose       : Compute a less than or equal relation for std_logic_vectors
    --     
    --     Parameters    : l       - input std_logic_vector | INTEGER
    --                     r       - input std_logic_vector | INTEGER
    --                     SrcRegMode - input regmode_type, indicating the format of
    --                               the std_logic_vector operands (l,r).
    --                               Default is TwosComp.
    --     
    --     Result        : BOOLEAN | std_ulogic
    --
    --     NOTE          : The operands may be of any length, and may be different
    --                     lengths. 
    --
    --                     Overloading not defined for both inputs of INTEGER type.
    --
    --     Use           : 
    --                      VARIABLE a, b : std_logic_vector ( 7 DOWNTO 0 );
    --                      IF ( RegGreaterThanOrEqual ( a, b, TwosComp)   )  THEN 
    --     
    --     See Also      : compare, RegLessThan, RegLessThanOrEqual, RegGreaterThan, 
    --                     RegGreaterThanOrEqual.
    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN std_logic_vector;
                                     CONSTANT r          : IN std_logic_vector;
                                     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                   ) RETURN std_ulogic;
    -----------------------------------------------------------------------------
    FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN std_logic_vector;
                                     CONSTANT r          : IN std_logic_vector;
                                     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                   ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN std_logic_vector;
                                     CONSTANT r          : IN INTEGER;
                                     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                   ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN INTEGER;
                                     CONSTANT r          : IN std_logic_vector;
                                     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                   ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN std_logic_vector;
                                     CONSTANT r          : IN INTEGER;
                                     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                   ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN INTEGER;
                                     CONSTANT r          : IN std_logic_vector;
                                     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                   ) RETURN std_ulogic;
    -- ----------------------------------------------------------------------------
    --     Function Name : RegGreaterThanOrEqual
    --    
    --     Purpose       : Compute a less than or equal relation for std_ulogic_vectors
    --     
    --     Parameters    : l       - input std_ulogic_vector | INTEGER
    --                     r       - input std_ulogic_vector | INTEGER
    --                     SrcRegMode - input regmode_type, indicating the format of
    --                               the std_ulogic_vector operands (l,r).
    --                               Default is TwosComp.
    --     
    --     Result        : BOOLEAN | std_ulogic
    --
    --     NOTE          : The operands may be of any length, and may be different
    --                     lengths. 
    --
    --                     Overloading not defined for both inputs of INTEGER type.
    --
    --     Use           : 
    --                      VARIABLE a, b : std_ulogic_vector ( 7 DOWNTO 0 );
    --                      IF ( RegGreaterThanOrEqual ( a, b, TwosComp)   )  THEN 
    --     
    --     See Also      : compare, RegLessThan, RegLessThanOrEqual, RegGreaterThan, 
    --                     RegGreaterThanOrEqual.
    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN std_ulogic_vector;
                                     CONSTANT r          : IN std_ulogic_vector;
                                     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                   ) RETURN std_ulogic;
    -----------------------------------------------------------------------------
    FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN std_ulogic_vector;
                                     CONSTANT r          : IN std_ulogic_vector;
                                     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                   ) RETURN BOOLEAN;
    -- -----------------------------------------------------------------------------
    FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN std_ulogic_vector;
                                     CONSTANT r          : IN INTEGER;
                                     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                   ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN INTEGER;
                                     CONSTANT r          : IN std_ulogic_vector;
                                     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                   ) RETURN BOOLEAN;
    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN std_ulogic_vector;
                                     CONSTANT r          : IN INTEGER;
                                     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                   ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN INTEGER;
                                     CONSTANT r          : IN std_ulogic_vector;
                                     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                   ) RETURN std_ulogic;
    -------------------------------------------------------------------------------
    --     Function Name  : SignExtend
    -- 1.7.1
    --     Overloading    : None
    --    
    --     Purpose        : Sign Extend a bit vector
    --     
    --     Parameters     : 
    --                      SrcReg     - input  bit_vector, the vector to be read.
    --                      DstLength  - input  NATURAL, length of the return vector.
    --                      SignBitPos - input  NATURAL, position of the sign bit.
    --                      SrcRegMode    - input  regmode_type, indicating the format of
    --                                   the input bit_vector.   Default is TwosComp.
    --     
    --     Result         : bit_vector, the extened bit vector
    --
    --     NOTE           : The length of the return bit vector  is specified by the
    --                      parameter 'DstLength'. The input bit vector will 
    --                      be sign extended. 
    --
    --     Use            :
    --                      VARIABLE vect : bit_vector ( 15 DOWNTO 0 );
    --                      vect := SignExtend ( B"11111101", 16, 8, TwosComp ); -- set to -4
    --     
    --     See Also       : RegFill
    -------------------------------------------------------------------------------
    FUNCTION SignExtend   ( CONSTANT SrcReg      : IN bit_vector;
                            CONSTANT DstLength   : IN NATURAL;
                            CONSTANT SignBitPos  : IN NATURAL;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN BIT_VECTOR;
    -------------------------------------------------------------------------------
    --     Function Name  : SignExtend
    -- 1.7.2
    --     Overloading    : None
    --
    --     Purpose        : Sign Extend an std_logic_vector
    --
    --     Parameters     :
    --                      SrcReg     - input  std_logic_vector, the vector to be read.
    --                      DstLength  - input  NATURAL, length of the return vector.
    --                      SignBitPos - input  NATURAL, position of the sign bit.
    --                      SrcRegMode    - input  regmode_type, indicating the format
    --                                      of the input std_logic_vector.   
    --                                      Default is DefaultRegMode.
    --
    --     Result         : std_logic_vector, the extened std_logic_vector
    --
    --     NOTE           : The length of the return logic vector  is specified by the
    --                      parameter 'DstLength'. The input logic vector will 
    --                      be sign extended. 
    --
    --     Use            :
    --                      VARIABLE vect : std_logic_vector ( 15 DOWNTO 0 );
    --                      vect := SignExtend ( B"11111101", 16, 8, TwosComp );
    --
    --     See Also       : RegFill
    -------------------------------------------------------------------------------
    FUNCTION SignExtend   ( CONSTANT SrcReg      : IN std_logic_vector;
                            CONSTANT DstLength   : IN NATURAL;
                            CONSTANT SignBitPos  : IN NATURAL;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name  : SignExtend
    -- 1.7.2
    --     Overloading    : None
    --
    --     Purpose        : Sign Extend an std_ulogic_vector
    --
    --     Parameters     :
    --                      SrcReg     - input  std_ulogic_vector, the vector to be read.
    --                      DstLength  - input  NATURAL, length of the return vector.
    --                      SignBitPos - input  NATURAL, position of the sign bit.
    --                      SrcRegMode    - input  regmode_type, indicating the format
    --                                     of the input std_ulogic_vector.   
    --                                     Default is DefaultRegMode.
    --
    --     Result         : std_ulogic_vector, the extened std_ulogic_vector
    --
    --     NOTE           : The length of the return logic vector  is specified by the
    --                      parameter 'DstLength'. The input logic vector will 
    --                      be sign extended. 
    --
    --     Use            :
    --                      VARIABLE vect : std_ulogic_vector ( 15 DOWNTO 0 );
    --                      vect := SignExtend ( B"11111101", 16, 8, TwosComp );
    --
    --     See Also       : RegFill
    -------------------------------------------------------------------------------
    FUNCTION SignExtend   ( CONSTANT SrcReg      : IN std_ulogic_vector;
                            CONSTANT DstLength   : IN NATURAL;
                            CONSTANT SignBitPos  : IN NATURAL;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic_vector;
    -------------------------------------------------------------------------------
    --     Function Name  : RegFill
    -- 1.7.3
    --     Overloading    : None
    --
    --     Purpose        : Fill the most significant bits of a register with 
    --                      a given value
    --
    --     Parameters     :
    --                      SrcReg     - input  bit_vector, the vector to be read.
    --                      DstLength  - input  NATURAL, length of the return vector.
    --                      FillVal    - input  bit,  default is '0'
    --
    --     Result         : bit_vector
    --
    --     NOTE           : The length of the return bit vector  is specified by the
    --                      parameter 'DstLength'. The input bit vector will
    --                      be  filled with the FillVal
    --
    --     Use            :
    --                      VARIABLE vect : bit_vector ( 15 DOWNTO 0 );
    --                      vect := RegFill ( B"00000101", 16, '0');
    --                    or 
    --                      vect := RegFill ( B"00000101", 16);
    --
    --     See Also       : SignExtend
    -------------------------------------------------------------------------------
    FUNCTION RegFill   ( CONSTANT SrcReg      : IN bit_vector;
                         CONSTANT DstLength   : IN NATURAL;
                         CONSTANT FillVal     : IN bit      := '0'
                       ) RETURN BIT_VECTOR;
    -------------------------------------------------------------------------------
    --     Function Name  : RegFill
    -- 1.7.4
    --     Overloading    : None
    --
    --     Purpose        : Fill an std_logic_vector with a given value
    --
    --     Parameters     :
    --                      SrcReg     - input  std_logic_vector, the  logic vector 
    --                                          to be read.
    --                      DstLength  - input  NATURAL, length of the return 
    --                                                    logic vector.
    --                      FillVal    - input  std_ulogic, default is '0'
    --
    --     Result         : std_logic_vector of length DstLength
    --
    --     NOTE           : The length of the return logic vector  is specified by the
    --                      parameter 'DstLength'. The input logic vector will
    --                      be  filled with the FillVal
    --
    --     Use            :
    --                      VARIABLE vect : std_logic_vector ( 15 DOWNTO 0 );
    --                      vect := RegFill ( "00000101", 16, 'U');
    --
    --     See Also       : SignExtend
    ------------------------------------------------------------------------------
    FUNCTION RegFill   ( CONSTANT SrcReg      : IN std_logic_vector;
                         CONSTANT DstLength   : IN NATURAL;
                         CONSTANT FillVal     : IN std_ulogic   := '0'
                       ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name  : RegFill
    -- 
    --     Overloading    : None
    --
    --     Purpose        : Fill an std_ulogic_vector with a given value
    --
    --     Parameters     :
    --                      SrcReg     - input  std_ulogic_vector, the  
    --                                          logic vector to be read.
    --                      DstLength  - input  NATURAL, length of the return 
    --                                          logic vector.
    --                      FillVal    - input  std_ulogic,  default is '0'
    --
    --     Result         : std_ulogic_vector of length DstLength
    --
    --     NOTE           : The length of the return logic vector  is specified by the
    --                      parameter 'DstLength'. The input logic vector will
    --                      be  filled with the FillVal
    --
    --     Use            :
    --                      VARIABLE vect : std_ulogic_vector ( 15 DOWNTO 0 );
    --                      vect := RegFill ( "00000101", 16, 'U');
    --
    --     See Also       : SignExtend
    -------------------------------------------------------------------------------
    FUNCTION RegFill   ( CONSTANT SrcReg      : IN std_ulogic_vector;
                         CONSTANT DstLength   : IN NATURAL;
                         CONSTANT FillVal     : IN std_ulogic   := '0'
                       ) RETURN std_ulogic_vector;
--+-----------------------------------------------------------------------------
--|     Function Name  : ConvertMode
--| 1.8.2
--|     Overloading    : None
--| 
--|     Purpose        : Convert a BIT_VECTOR  from source mode to destination mode. 
--| 
--|     Parameters     :
--|                      SrcReg     - input  BIT_VECTOR, the vector to be read.
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                   the input BIT_VECTOR.   Default is TwosComp.
--|                      DstRegMode - input regmode_type, indicating the format of
--|                                   the output bit_vector.
--|
--|     Result         : BIT_VECTOR, the vector in the  notation specified by
--|                        the destination mode. 
--|
--|
--|     Use            :
--|                      VARIABLE vect : BIT_VECTOR ( 15 DOWNTO 0 );
--|                      vect := ConvertMode ( B"0101",UnSigned, TwosComp ); -- set to +5
--|
--|     See Also       : To_TwosComp, To_OnesComp, To_Unsign, To_SignMag
--|-----------------------------------------------------------------------------
    FUNCTION ConvertMode  ( CONSTANT SrcReg      : IN BIT_VECTOR;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode;
                            CONSTANT DstRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN BIT_VECTOR;
--+-----------------------------------------------------------------------------
--|     Function Name  : ConvertMode
--| 1.8.1
--|     Overloading    : None
--| 
--|     Purpose        : Convert a std_logic_vector  from source mode 
--|                      to destination mode. 
--| 
--|     Parameters     :
--|                      SrcReg     - input  std_logic_vector, the vector to be read.
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                   the input std_logic_vector.   
--|                                   Default is DefaultRegMode
--|
--|                      DstRegMode - input regmode_type, indicating the format of
--|                                   the output std_logic_vector.
--|
--|     Result         : std_logic_vector, the vector in the notation specified 
--|                      by  the destination mode.
--|
--|
--|     Use            :
--|                      VARIABLE vect : std_logic_vector ( 15 DOWNTO 0 );
--|                      vect := ConvertMode ( B"0101",UnSigned, TwosComp ); 
--|
--|     See Also       : To_TwosComp, To_OnesComp, To_Unsign, To_SignMag
--|-----------------------------------------------------------------------------
    FUNCTION ConvertMode  ( CONSTANT SrcReg      : IN std_logic_vector;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode;
                            CONSTANT DstRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN std_logic_vector;
--+-----------------------------------------------------------------------------
--|     Function Name  : ConvertMode
--| 1.8.1
--|     Overloading    : None
--| 
--|     Purpose        : Convert an std_ulogic_vector from source mode 
--|                      to destination mode. 
--| 
--|     Parameters     :
--|                      SrcReg     - input  std_ulogic_vector, the vector to be read.
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                   the input std_ulogic_vector.   
--|                                   Default is DefaultRegMode.
--|
--|                      DstRegMode - input regmode_type, indicating the format of
--|                                   the output std_ulogic_vector.
--|
--|     Result         : std_ulogic_vector, the vector in the notation specified 
--|                      by  the destination mode.
--|
--|
--|     Use            :
--|                      VARIABLE vect : std_ulogic_vector ( 15 DOWNTO 0 );
--|                      vect := ConvertMode ( "0101",UnSigned, TwosComp ); 
--|
--|     See Also       : To_TwosComp, To_OnesComp, To_Unsign, To_SignMag
--|-----------------------------------------------------------------------------
    FUNCTION ConvertMode  ( CONSTANT SrcReg      : IN std_ulogic_vector;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode;
                            CONSTANT DstRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic_vector;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_TwosComp
--| 1.8.7
--|     Overloading    : None
--|  
--|     Purpose        : Convert a BIT_VECTOR to Two's Compliment Notation.
--|  
--|     Parameters     :
--|                      SrcReg     - input  BIT_VECTOR, the vector to be read.
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input BIT_VECTOR.   Default is TwosComp.
--|
--|     Result         : BIT_VECTOR, the vector in Two's complement notation.
--|
--|
--|     Use            :
--|                      VARIABLE vect : BIT_VECTOR ( 15 DOWNTO 0 );
--|                      vect := To_TwosComp ( B"101",  UnSigned ); -- set to +5
--|
--|     See Also       : To_BitVector, To_Integer, To_TwosComp, From_TwosComp
--|-----------------------------------------------------------------------------
    FUNCTION To_TwosComp  ( CONSTANT SrcReg      : IN BIT_VECTOR;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN BIT_VECTOR;
    -------------------------------------------------------------------------------
    --     Function Name  : To_TwosComp
    -- 1.8.8
    --     Overloading    : None
    --    
    --     Purpose        : Convert an std_logic_vector to Two's Compliment Notation.
    --     
    --     Parameters     : 
    --                      SrcReg     - input  std_logic_vector, the vector to be read.
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input std_logic_vector.   Default is TwosComp.
    --     
    --     Result         : std_logic_vector, the vector in Two's complement notation.
    --
    --     Use            : 
    --                      VARIABLE vect : std_logic_vector ( 15 DOWNTO 0 );
    --                      vect := To_TwosComp ( B"101", UnSigned ); -- set to +5
    --     
    --     See Also       : To_StdLogicVector, To_Integer, To_TwosComp, From_TwosComp
    -------------------------------------------------------------------------------
    FUNCTION To_TwosComp  ( CONSTANT SrcReg      : IN std_logic_vector;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name  : To_TwosComp
    -- 1.8.8
    --     Overloading    : None
    --    
    --     Purpose        : Convert an std_ulogic_vector to Two's Compliment Notation.
    --     
    --     Parameters     : 
    --                      SrcReg     - input  std_ulogic_vector, the vector to be read.
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input std_ulogic_vector.   Default is TwosComp.
    --     
    --     Result         : std_ulogic_vector, the vector in Two's complement notation.
    --
    --     Use            : 
    --                      VARIABLE vect : std_ulogic_vector ( 15 DOWNTO 0 );
    --                      vect := To_TwosComp ( B"101", UnSigned ); -- set to +5
    --     
    --     See Also       : To_StdLogicVector, To_Integer, To_TwosComp, From_TwosComp
    -------------------------------------------------------------------------------
    FUNCTION To_TwosComp  ( CONSTANT SrcReg      : IN std_ulogic_vector;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic_vector;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_OnesComp
--| 1.8.9
--|     Overloading    : None
--|  
--|     Purpose        : Convert a BIT_VECTOR to One's Compliment Notation.
--|  
--|     Parameters     :
--|                      SrcReg     - input  BIT_VECTOR, the vector to be read.
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input BIT_VECTOR.   Default is TwosComp.
--|
--|     Result         : BIT_VECTOR, the vector in One's complement notation.
--|
--|
--|     Use            :
--|                      VARIABLE vect : BIT_VECTOR ( 15 DOWNTO 0 );
--|                      vect := To_OnesComp ( B"101", UnSigned ); -- set to +5
--|
--|     See Also       : To_BitVector, To_Integer, To_TwosComp, From_TwosComp
--|-----------------------------------------------------------------------------
    FUNCTION To_OnesComp  ( CONSTANT SrcReg      : IN BIT_VECTOR;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN BIT_VECTOR;
    -------------------------------------------------------------------------------
    --     Function Name  : To_OnesComp
    -- 1.8.10
    --     Overloading    : None
    --
    --     Purpose        : Convert an std_logic_vector to One's Compliment Notation.
    --
    --     Parameters     :
    --                      SrcReg     - input  std_logic_vector, the vector to be read.
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input std_logic_vector.   Default is TwosComp.
    --
    --     Result         : std_logic_vector, the vector in One's complement notation.
    --
    --     Use            :
    --                      VARIABLE vect : std_logic_vector ( 15 DOWNTO 0 );
    --                      vect := To_OnesComp ( B"101", UnSigned ); -- set to +5
    --
    --     See Also       : To_StdLogicVector, To_Integer, To_TwosComp, 
    -------------------------------------------------------------------------------
    FUNCTION To_OnesComp  ( CONSTANT SrcReg      : IN std_logic_vector;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name  : To_OnesComp
    -- 
    --     Overloading    : None
    --
    --     Purpose        : Convert an std_ulogic_vector to One's Compliment Notation.
    --
    --     Parameters     :
    --                      SrcReg     - input  std_ulogic_vector, the vector to be read.
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input std_ulogic_vector.   Default is TwosComp.
    --
    --     Result         : std_ulogic_vector, the vector in One's complement notation.
    --
    --     Use            :
    --                      VARIABLE vect : std_ulogic_vector ( 15 DOWNTO 0 );
    --                      vect := To_OnesComp ( B"101", UnSigned ); -- set to +5
    --
    --     See Also       : To_StdLogicVector, To_Integer, To_TwosComp, 
    -------------------------------------------------------------------------------
    FUNCTION To_OnesComp  ( CONSTANT SrcReg      : IN std_ulogic_vector;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic_vector;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_Unsign
--| 1.8.11
--|     Overloading    : None
--| 
--|     Purpose        : Convert a BIT_VECTOR to Unsigned Notation.
--| 
--|     Parameters     :
--|                      SrcReg     - input  BIT_VECTOR, the vector to be read.
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input BIT_VECTOR.   Default is TwosComp.
--|
--|     Result         : BIT_VECTOR, the vector in unsigned notation.
--|
--|
--|     Use            :
--|                      VARIABLE vect : BIT_VECTOR ( 15 DOWNTO 0 );
--|                      vect := To_Unsign ( B"0101", SignMagnitude ); -- set to +5
--|
--|     See Also       : to_BitVector, to_Integer, To_TwosComp, From_TwosComp
--|-----------------------------------------------------------------------------
    FUNCTION To_Unsign    ( CONSTANT SrcReg      : IN BIT_VECTOR;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN BIT_VECTOR;
    -------------------------------------------------------------------------------
    --     Function Name  : To_Unsign
    --
    --     Overloading    : None
    --
    --     Purpose        : Convert a std_logic_vector to Unsigned Notation.
    --
    --     Parameters     :
    --                      SrcReg     - input  std_logic_vector, the vector to be read.
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input std_logic_vector.   Default is TwosComp.
    --
    --     Result         : std_logic_vector, the vector in unsigned notation.
    --
    --
    --     Use            :
    --                      VARIABLE vect : std_logic_vector ( 15 DOWNTO 0 );
    --                      vect := To_Unsign ( B"0l01",SignMagnitude ); -- set to +5
    --
    --     See Also       : To_StdLogicVector, To_Integer, To_TwosComp, From_TwosComp
  -------------------------------------------------------------------------------
    FUNCTION To_Unsign    ( CONSTANT SrcReg      : IN std_logic_vector;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN std_logic_vector;
   -------------------------------------------------------------------------------
    --     Function Name  : To_Unsign
    --
    --     Overloading    : None
    --
    --     Purpose        : Convert an std_ulogic_vector to Unsigned Notation.
    --
    --     Parameters     :
    --                      SrcReg     - input  std_ulogic_vector, the vector to be read.
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input std_ulogic_vector.   Default is TwosComp.
    --
    --     Result         : std_ulogic_vector, the vector in unsigned notation.
    --
    --
    --     Use            :
    --                      VARIABLE vect : std_ulogic_vector ( 15 DOWNTO 0 );
    --                      vect := To_Unsign ( "0l01",SignMagnitude ); -- set to +5
    --
    --     See Also       : To_StdLogicVector, To_Integer, To_TwosComp, From_TwosComp
  -------------------------------------------------------------------------------
    FUNCTION To_Unsign    ( CONSTANT SrcReg      : IN std_ulogic_vector;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic_vector;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_SignMag
--| 1.8.13
--|     Overloading    : None
--|  
--|     Purpose        : Convert a BIT_VECTOR to Sign-magnitude Notation.
--|  
--|     Parameters     :
--|                      SrcReg     - input  BIT_VECTOR, the vector to be read.
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input BIT_VECTOR.   Default is TwosComp.
--|
--|     Result         : BIT_VECTOR, the vector in Two's complement notation.
--|
--|     Use            :
--|                      VARIABLE vect : BIT_VECTOR ( 15 DOWNTO 0 );
--|                      vect := To_SignMag ( B"101", 16, UnSigned ); -- set to +5
--|
--|     See Also       : to_BitVector, to_Integer, To_TwosComp, From_TwosComp
--|-----------------------------------------------------------------------------
    FUNCTION To_SignMag   ( CONSTANT SrcReg      : IN BIT_VECTOR;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN BIT_VECTOR;
    -------------------------------------------------------------------------------
    --     Function Name  : To_SignMag
    --
    --     Overloading    : None
    --
    --     Purpose        : Convert a std_logic_vector to SignMagnitude Notation.
    --
    --     Parameters     :
    --                      SrcReg     - input  std_logic_vector, the vector to be read.
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input std_logic_vector.   Default is TwosComp.
    --
    --     Result         : std_logic_vector, the vector in Two's complement notation.
    --
    --     Use            :
    --                      VARIABLE vect : std_logic_vector ( 15 DOWNTO 0 );
    --                      vect := To_SignMag ( "101", 16, UnSigned ); -- set to +5
    --
    --     See Also       : To_StdLogicVector, To_Integer, To_TwosComp, From_TwosComp
    -------------------------------------------------------------------------------
    FUNCTION To_SignMag   ( CONSTANT SrcReg      : IN std_logic_vector;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name  : To_SignMag
    --
    --     Overloading    : None
    --
    --     Purpose        : Convert a std_ulogic_vector to SignMagnitude Notation.
    --
    --     Parameters     :
    --                      SrcReg     - input  std_ulogic_vector, the vector to be read.
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input std_ulogic_vector.   Default is TwosComp.
    --
    --     Result         : std_ulogic_vector, the vector in Two's complement notation.
    --
    --     Use            :
    --                      VARIABLE vect : std_ulogic_vector ( 15 DOWNTO 0 );
    --                      vect := To_SignMag ( "101", 16, UnSigned ); -- set to +5
    --
    --     See Also       : To_StdLogicVector, To_Integer, To_TwosComp, From_TwosComp
    -------------------------------------------------------------------------------
    FUNCTION To_SignMag   ( CONSTANT SrcReg      : IN std_ulogic_vector;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic_vector;
    -------------------------------------------------------------------------------
    --     Function Name  : To_StdLogicVector
    --
    --     Overloading    : Procedure and Function.
    --
    --     Purpose        : Translate an INTEGER into a std_logic_vector.
    --
    --     Parameters     : intg    - input  INTEGER, the value to be translated.
    --                      width   - input  INTEGER, length of the return vector.
    --                                Default is IntegerBitLength  (Machine Integer
    --                                length).
    --                      SrcRegMode - input  regmode_type, indicating the format
    --                                   of the output std_logic_vector.   Default 
    --                                   is TwosComp.
    --
    --     Result        : std_logic_vector, the binary representation of the integer.
    --
    --     NOTE          : An ASSERTION message of severity ERROR if the conversion
    --                      fails:
    --                       * 'intg' is negative and UnSigned format is specified.
    --                         The absolute value of 'intg' is used.
    --                       * The length of 'SrcReg' is insufficient to hold the
    --                         binary value. The low order bits are returned.
    --
    --                      A runtime system error should occur if the value of
    --                      'width'  does not equal the expected return vector
    --                      length (from the context of the function usage).
    --
   --     Use            :
    --                      VARIABLE vect : std_logic_vector ( 15 DOWNTO 0 );
    --
    --                      vect := To_StdLogicVector ( -294, 16, TwosComp );
    --
    --     See Also       : To_StdLogicVector, To_Integer, To_TwosComp, From_TwosComp
    -------------------------------------------------------------------------------
    FUNCTION To_StdLogicVector ( CONSTANT intg       : IN INTEGER;
                                 CONSTANT width      : IN NATURAL      := 0;
                                 CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                               ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name  : To_StdULogicVector
    --
    --     Overloading    : Procedure and Function.
    --
    --     Purpose        : Translate an INTEGER into a std_ulogic_vector.
    --
    --     Parameters     : intg    - input  INTEGER, the value to be translated.
    --                      width   - input  INTEGER, length of the return vector.
    --                                Default is IntegerBitLength  (Machine Integer
    --                                length).
    --                      SrcRegMode - input  regmode_type, indicating the format
    --                                   of the output std_logic_vector.   Default 
    --                                   is TwosComp.
    --
    --     Result        : std_ulogic_vector
    --
    --     NOTE          : An ASSERTION message of severity ERROR if the conversion
    --                      fails:
    --                       * 'intg' is negative and UnSigned format is specified.
    --                         The absolute value of 'intg' is used.
    --                       * The length of 'SrcReg' is insufficient to hold the
    --                         binary value. The low order bits are returned.
    --
    --                      A runtime system error should occur if the value of
    --                      'width'  does not equal the expected return vector
    --                      length (from the context of the function usage).
    --
   --     Use            :
    --                      VARIABLE vect : std_logic_vector ( 15 DOWNTO 0 );
    --
    --                      vect := To_StdLogicVector ( -294, 16, TwosComp );
    --
    --     See Also       : To_StdLogicVector, To_Integer, To_TwosComp, From_TwosComp
    -------------------------------------------------------------------------------
    FUNCTION To_StdULogicVector ( CONSTANT intg       : IN INTEGER;
                                  CONSTANT width      : IN NATURAL      := 0;
                                  CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                ) RETURN std_ulogic_vector;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_BitVector
--|
--|     Overloading    : 
--|
--|     Purpose        : Translate an INTEGER into a BIT_VECTOR.
--|
--|     Parameters     : intg    - input  INTEGER, the value to be translated.
--|                      width   - input  NATURAL, length of the return vector.
--|                                Default is IntegerBitLength (Machine integer length).
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the output BIT_VECTOR.   Default is TwosComp.
--|
--|     Result        : BIT_VECTOR, the binary representation of the integer.
--|
--|     NOTE           : An ASSERTION message of severity ERROR if the conversion
--|                      fails:
--|                       * 'intg' is negative and UnSigned format is specified.
--|                         The absolute value of 'intg' is used.
--|                       * The length of 'SrcReg' is insufficient to hold the
--|                         binary value. The low order bits are returned.
--|
--|                      A runtime system error should occur if the value of
--|                      'width' is does not equal the expected return vector
--|                      length (from the context of the function usage).
--|
--|     Use            :
--|                      VARIABLE vect : BIT_VECTOR ( 15 DOWNTO 0 );
--|
--|                      vect := To_BitVector ( -294, 16, TwosComp );
--|
--|     See Also       : To_BitVector, To_Integer, To_TwosComp, From_TwosComp
--|-----------------------------------------------------------------------------
    FUNCTION To_BitVector ( CONSTANT intg       : IN INTEGER;
                            CONSTANT width      : IN Natural;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN BIT_VECTOR;
 --+-----------------------------------------------------------------------------
--|     Function Name  : To_Integer
--|
--|     Overloading    : 
--|
--|     Purpose        : Interpret a BIT_VECTOR as an INTEGER.
--|
--|     Parameters     :
--|                      SrcReg     - input  BIT_VECTOR, the vector to be read.
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input BIT_VECTOR.   Default is TwosComp.
--|
--|
--|     Result         : INTEGER, the integer value of the vector.
--|
--|     NOTE           : An ASSERTION message of severity ERROR if the conversion
--|                      fails:
--|                       * Magnitude of the computed integer is to large.
--|                         The input value is considered to large if after
--|                         removing leading 0's (1's for negative numbers)
--|                         the length of the remaining vector is > IntegerBitLength-1.
--|                         (ie the machine integer length).
--|                      The error return value is 0.
--|
--|                      A runtime system error should occur if the value of
--|                      'width' is does not equal the expected return vector
--|                      length (from the context of the function usage).
--|
--|     Use            :
--|                      VARIABLE vect : BIT_VECTOR ( 15 DOWNTO 0 );
--|                      VARIABLE intg : INTEGER;
--|
--|                      intg := To_Integer ( vect, TwosComp );
--|
--|     See Also       : To_BitVector, To_Integer, To_TwosComp
--|-----------------------------------------------------------------------------
    FUNCTION To_Integer  ( CONSTANT SrcReg     : IN BIT_VECTOR;
                           CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                         ) RETURN INTEGER;
    -------------------------------------------------------------------------------
    --     Function Name  : To_Integer
    --
    --     Overloading    : 
    --    
    --     Purpose        : Interpret a std_logic_vector as an INTEGER.
    --     
    --     Parameters     : 
    --                      SrcReg     - input  std_logic_vector, the vector to be read.
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input std_logic_vector.   Default is TwosComp.
    --     
    --     Result         : INTEGER, the integer value of the vector.
    --
    --     NOTE           : An ASSERTION message of severity ERROR if the conversion
    --                      fails:
    --                       * Magnitude of the computed integer is to large.
    --                         The input value is considered to large if after
    --                         removing leading 0's (1's for negative numbers)
    --                         the length of the remaining vector is > IntegerBitLength-1.
    --                         (ie the machine integer length).
    --                      The error return value is 0.
    --
    --                      A runtime system error should occur if the value of
    --                      'width' is does not equal the expected return vector
    --                      length (from the context of the function usage).
    --
    --     Use            : 
    --                      VARIABLE vect : std_logic_vector ( 15 DOWNTO 0 );
    --                      VARIABLE intg : INTEGER;
    --
    --                      intg := To_Integer ( vect, TwosComp );
    --     
    --     See Also       : To_StdLogicVector, To_Integer, To_TwosComp, From_TwosComp
    -------------------------------------------------------------------------------
    FUNCTION To_Integer  ( CONSTANT SrcReg     : IN std_logic_vector;
                           CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                         ) RETURN INTEGER;
    -------------------------------------------------------------------------------
    --     Function Name  : To_Integer
    --
    --     Overloading    : 
    --    
    --     Purpose        : Interpret a std_ulogic_vector as an INTEGER.
    --     
    --     Parameters     : 
    --                      SrcReg     - input  std_ulogic_vector, the vector to be read.
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input std_ulogic_vector.   Default is TwosComp.
    --     
    --     Result         : INTEGER, the integer value of the vector.
    --
    --     NOTE           : An ASSERTION message of severity ERROR if the conversion
    --                      fails:
    --                       * Magnitude of the computed integer is to large.
    --                         The input value is considered to large if after
    --                         removing leading 0's (1's for negative numbers)
    --                         the length of the remaining vector is > IntegerBitLength-1.
    --                         (ie the machine integer length).
    --                      The error return value is 0.
    --
    --                      A runtime system error should occur if the value of
    --                      'width' is does not equal the expected return vector
    --                      length (from the context of the function usage).
    --
    --     Use            : 
    --                      VARIABLE vect : std_ulogic_vector ( 15 DOWNTO 0 );
    --                      VARIABLE intg : INTEGER;
    --
    --                      intg := To_Integer ( vect, TwosComp );
    --     
    --     See Also       : To_StdLogicVector, To_Integer, To_TwosComp, From_TwosComp
    -------------------------------------------------------------------------------
    FUNCTION To_Integer  ( CONSTANT SrcReg     : IN std_ulogic_vector;
                           CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                         ) RETURN INTEGER;
    -------------------------------------------------------------------------------
    --     Procedure Name : RegAbs
    -- 1.6.9
    --     Overloading    : Procedure .
    --
    --     Purpose        : converts  std_logic_vector into an absolute value.
    --
    --     Parameters     :
    --                      result     - INPUT_output  std_logic_vector, 
    --                      SrcReg     - input  std_logic_vector, the vector to be read.
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input std_logic_vector.   Default is TwosComp.
    --
    --
    --     Use            :
    --                      VARIABLE reslt, vect : std_logic_vector ( 15 DOWNTO 0 );
    --
    --                       RegAbs ( reslt,  vect, TwosComp );
    --
    -------------------------------------------------------------------------------
    PROCEDURE RegAbs  ( VARIABLE result     : INOUT std_logic_vector;
                        CONSTANT SrcReg     : IN std_logic_vector;
                        CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                      );
    -------------------------------------------------------------------------------
    --     Procedure Name : RegAbs
    -- 
    --     Overloading    : Procedure .
    --
    --     Purpose        : converts  std_ulogic_vector into an absolute value.
    --
    --     Parameters     :
    --                      result     - input_output  std_ulogic_vector, 
    --                      SrcReg     - input  std_ulogic_vector, the vector to be read.
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input std_ulogic_vector.   Default is TwosComp.
    --
    --
    --     Use            :
    --                      VARIABLE reslt, vect : std_ulogic_vector ( 15 DOWNTO 0 );
    --
    --                       RegAbs ( reslt,  vect, TwosComp );
    --
    -------------------------------------------------------------------------------
    PROCEDURE RegAbs  ( VARIABLE result     : INOUT std_ulogic_vector;
                        CONSTANT SrcReg     : IN std_ulogic_vector;
                        CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                      );
    -------------------------------------------------------------------------------
    --     Function Name  : RegAbs
    --
    --     Procedure Name : RegAbs
    -- 1.6.10
    --     Overloading    : Procedure .
    --
    --     Purpose        : converts  bit_vectors into an absolute value.
    --
    --     Parameters     :
    --                      result    - input_output  bit_vector, 
    --                      SrcReg     - input  bit_vector, the vector to be read.
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input bit_vector.   Default is TwosComp.
    --
    --
    --     Use            :
    --                      VARIABLE reslt, vect : std_ulogic_vector ( 15 DOWNTO 0 );
    --
    --                       RegAbs ( reslt,  vect, TwosComp );
    --
    -------------------------------------------------------------------------------
    PROCEDURE RegAbs  ( VARIABLE result     : INOUT bit_vector;
                        CONSTANT SrcReg     : IN bit_vector;
                        CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                      );
--+-----------------------------------------------------------------------------
--|     Function Name  : RegAdd
--|
--|     Overloading    : None
--|
--|     Purpose        : Addition of BIT_VECTORS.
--|
--|     Parameters     :
--|                      result     - input_output BIT_VECTOR, the computed sum
--|                      carry_out  - output BIT,
--|                      overflow   - output BIT, overflow condition
--|                      addend     - input  BIT_VECTOR,
--|                      augend     - input  BIT_VECTOR,
--|                      carry_in   - input  BIT,  
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input BIT_VECTOR.   Default is TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|                    
--|                       carry_in is only applicable in case od Twos's complkement
--|                       and unsigned addition. carry_in is ignored in case of
--|                       0ne's complement and sign-magnitude addition.
--|
--|                      A temporary result is computed with length N (where
--|                      N is the greater of the input vector lengths).
--|                      This computed value is extended or truncated to match
--|                      the width of 'result'. If truncated, the low order bits
--|                      are returned.
--| 
--|     Use            :
--|                      VARIABLE x, y, sum : BIT_VECTOR ( 15 DOWNTO 0);
--|                      VARIABLE carry_in, carry_out , ovf: BIT;
--| 
--|                      RegAdd ( sum, carry_out, ovf,x, y, carry_in, UnSigned );
--| 
--|     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE RegAdd  ( VARIABLE result     : INOUT BIT_VECTOR;
                        VARIABLE carry_out  : OUT BIT;
                        VARIABLE overflow   : OUT BIT;
                        CONSTANT addend     : IN BIT_VECTOR;
                        CONSTANT augend     : IN BIT_VECTOR;
                        CONSTANT carry_in   : IN BIT;
                        CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode 
                      );
--+-----------------------------------------------------------------------------
--|     Function Name  : RegAdd
--|
--|     Overloading    : None
--|
--|     Purpose        : Addition of logic vectors.
--|
--|     Parameters     :
--|                      result     - input_output std_logic_vector, the computed sum
--|                      carry_out  - output std_logic,
--|                      overflow   - output std_logic,
--|                      addend     - input  std_logic_vector,
--|                      augend     - input  std_logic_vector,
--|                      carry_in   - input  std_logic, carry into the LSB.
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input std_logic_vector.   Default is TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|  
--|                       carry_in is only applicable in case od Twos's complkement
--|                       and unsigned addition. carry_in is ignored in case of
--|                       0ne's complement and sign-magnitude addition.
--|
--|                      A temporary result is computed with length N (where
--|                      N is the greater of the input vector lengths).
--|                      This computed value is extended or truncated to match
--|                      the width of 'result'. If truncated, the low order bits
--|                      are returned.
--| 
--|     Use            :
--|                      VARIABLE x, y, sum : std_logic_vector ( 15 DOWNTO 0);
--|                      VARIABLE carry_in, carry_out , ovf: std_ulogic;
--| 
--|                      RegAdd ( sum, carry_out, ovf,x, y, carry_in, TwosComp );
--| 
--|     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE RegAdd  ( VARIABLE result     : INOUT std_logic_vector;
                        VARIABLE carry_out  : OUT std_ulogic;
                        VARIABLE overflow   : OUT std_ulogic;
                        CONSTANT addend     : IN std_logic_vector;
                        CONSTANT augend     : IN std_logic_vector;
                        CONSTANT carry_in   : IN std_ulogic;
                        CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode 
                      );
--+-----------------------------------------------------------------------------
--|     Function Name  : RegAdd
--|
--|     Overloading    : None
--|
--|     Purpose        : Addition of logic vectors.
--|
--|     Parameters     :
--|                      result     - input_output std_ulogic_vector, the computed sum
--|                      carry_out  - output std_logic,
--|                      overflow   - output std_logic,
--|                      addend     - input  std_ulogic_vector,
--|                      augend     - input  std_ulogic_vector,
--|                      carry_in   - input  std_logic, carry into the LSB.
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input std_ulogic_vector.   Default is TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|  
--|                       carry_in is only applicable in case od Twos's complkement
--|                       and unsigned addition. carry_in is ignored in case of
--|                       0ne's complement and sign-magnitude addition.
--|
--|                      A temporary result is computed with length N (where
--|                      N is the greater of the input vector lengths).
--|                      This computed value is extended or truncated to match
--|                      the width of 'result'. If truncated, the low order bits
--|                      are returned.
--| 
--|     Use            :
--|                      VARIABLE x, y, sum : std_ulogic_vector ( 15 DOWNTO 0);
--|                      VARIABLE carry_in, carry_out , ovf: std_ulogic;
--| 
--|                      RegAdd ( sum, carry_out, ovf,x, y, carry_in, TwosComp );
--| 
--|     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE RegAdd  ( VARIABLE result     : INOUT std_ulogic_vector;
                        VARIABLE carry_out  : OUT std_ulogic;
                        VARIABLE overflow   : OUT std_ulogic;
                        CONSTANT addend     : IN std_ulogic_vector;
                        CONSTANT augend     : IN std_ulogic_vector;
                        CONSTANT carry_in   : IN std_ulogic;
                        CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode 
                      );
--+-----------------------------------------------------------------------------
--|     Function Name  : RegSub
--|    
--|     Overloading    : None
--|
--|     Purpose        : Subtraction of BIT_VECTORS.
--|                       ( result = minuend - subtrahend )
--|
--|     Parameters     :
--|                      result     - input_output BIT_VECTOR, the computed sum
--|                      borrow_out - output BIT,
--|                      overflow   - output BIT, overflow condition
--|                      minuend - input  BIT_VECTOR,
--|                      subtrahend - input  BIT_VECTOR,
--|                      borrow_in  - input  BIT, borrow from the LSB
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input BIT_VECTOR.   Default is TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|                      borrow_in is only applicable in case od Twos's complement
--|                       and unsigned subtraction. borrow_in is ignored in case of
--|                       0ne's complement and sign-magnitude subtraction.
--|
--|                      A temporary result is computed with length N (where
--|                      N is the greater of the input vector lengths).
--|     Use            :
--|                      VARIABLE x, y, diff : BIT_VECTOR ( 15 DOWNTO 0);
--|                      VARIABLE n_borrow, borrow_in : BIT;
--|
--|                      RegSub ( diff, n_borrow, x, y, borrow_in, UnSigned );
--|
--|     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE RegSub  ( VARIABLE result     : INOUT BIT_VECTOR;
                        VARIABLE borrow_out : OUT BIT;
                        VARIABLE overflow   : OUT BIT;
                        CONSTANT minuend    :  IN BIT_VECTOR;
                        CONSTANT subtrahend :  IN BIT_VECTOR;
                        CONSTANT borrow_in  :  IN BIT          := '0';
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode );
   
--+-----------------------------------------------------------------------------
--|     Function Name  : RegSub
--|    
--|     Overloading    : None
--|
--|     Purpose        : Subtraction of logic vectors.
--|                       ( result = minuend - subtrahend )
--|
--|     Parameters     :
--|                      result     - input_output std_logic_vector, the computed diff
--|                      borrow_out - output std_logic,
--|                      overflow   - output std_logic, overflow condition
--|                      minuend - input  std_logic_vector,
--|                      subtrahend - input  std_logic_vector,
--|                      borrow_in  - input  std_logic, borrow from the LSB
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input std_logic_vector.   Default is TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|                      borrow_in is only applicable in case od Twos's complement
--|                       and unsigned subtraction. borrow_in is ignored in case of
--|                       0ne's complement and sign-magnitude subtraction.
--|
--|                      A temporary result is computed with length N (where
--|                      N is the greater of the input vector lengths).
--|     Use            :
--|                      VARIABLE x, y, diff : std_logic_vector ( 15 DOWNTO 0);
--|                      VARIABLE n_borrow, borrow_in : std_ulogic;
--|
--|                      RegSub ( diff, n_borrow, x, y, borrow_in, UnSigned );
--|
--|     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE RegSub  ( VARIABLE result     : INOUT std_logic_vector;
                        VARIABLE borrow_out : OUT std_ulogic;
                        VARIABLE overflow   : OUT std_ulogic;
                        CONSTANT minuend    :  IN std_logic_vector;
                        CONSTANT subtrahend :  IN std_logic_vector;
                        CONSTANT borrow_in  :  IN std_ulogic         := '0';
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      );
--+-----------------------------------------------------------------------------
--|     Function Name  : RegSub
--|    
--|     Overloading    : None
--|
--|     Purpose        : Subtraction of logic vectors.
--|                       ( result = minuend - subtrahend )
--|
--|     Parameters     :
--|                      result     - input_output std_ulogic_vector, the computed diff
--|                      borrow_out - output std_logic,
--|                      overflow   - output std_logic, overflow condition
--|                      minuend - input  std_ulogic_vector,
--|                      subtrahend - input  std_ulogic_vector,
--|                      borrow_in  - input  std_logic, borrow from the LSB
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input std_ulogic_vector.   Default is TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|                      borrow_in is only applicable in case od Twos's complement
--|                       and unsigned subtraction. borrow_in is ignored in case of
--|                       0ne's complement and sign-magnitude subtraction.
--|
--|                      A temporary result is computed with length N (where
--|                      N is the greater of the input vector lengths).
--|     Use            :
--|                      VARIABLE x, y, diff : std_ulogic_vector ( 15 DOWNTO 0);
--|                      VARIABLE n_borrow, borrow_in : std_ulogic;
--|
--|                      RegSub ( diff, n_borrow, x, y, borrow_in, UnSigned );
--|
--|     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE RegSub  ( VARIABLE result     : INOUT std_ulogic_vector;
                        VARIABLE borrow_out : OUT std_ulogic;
                        VARIABLE overflow   : OUT std_ulogic;
                        CONSTANT minuend    :  IN std_ulogic_vector;
                        CONSTANT subtrahend :  IN std_ulogic_vector;
                        CONSTANT borrow_in  :  IN std_ulogic         := '0';
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      );
--+-----------------------------------------------------------------------------
--|     Function Name  : RegMult
--|
--|     Overloading    : None
--|
--|     Purpose        : Multiplication of BIT_VECTORS.
--|
--|     Parameters     :
--|                      result       - output BIT_VECTOR, the computed product
--|                      overflow     - output BIT, overflow condition
--|                      multiplicand - input BIT_VECTOR,
--|                      multiplier   -  input BIT_VECTOR,
--|                      SrcRegMode   - input  regmode_type, indicating the format 
--|                                     of the input BIT_VECTOR.   Default is 
--|                                     DefaultRegMode which is set to TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|    Algorithm       : The multiplication is carried out as follows:
--|
--|                      1) Determine sign of result based on sign of 
--|                         multiploicand and sign  of multiplier.
--|
--|                      2) Convert the multiplicand amd multiplier to Unsigned 
--|                         representation.
--|                      
--|                      3) Perform multiplication based on add and shift algorithm.
--|
--|                      4) Convert the result to the SrcRegMode with appropropriate sign
--|
--|     Result         :
--|                     A  temporary result is computed with length N+M (where
--|                      N,M are the lengths of the multiplicand and multiplier).
--|                      This computed value is extended or truncated to match
--|                      the width of 'result'. If truncated, the low order bits
--|                      are returned.
--|
--|                      The parameter 'overflow' is set to '1' if the product of the
--|                      of the two inputs too large to fit in the parameter result.
--|
--|     Use            :
--|                      VARIABLE x, y, prod : BIT_VECTOR ( 15 DOWNTO 0);
--|                      VARIABLE ovfl : BIT;
--|
--|                      RegMult ( prod, ovfl, x, y, TwosComp );
--|
--|     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE RegMult ( VARIABLE result       : OUT BIT_VECTOR;
                        VARIABLE overflow     : OUT BIT;
                        CONSTANT multiplicand : IN BIT_VECTOR;
                        CONSTANT multiplier   : IN BIT_VECTOR;
                        CONSTANT SrcRegMode   : IN regmode_type := DefaultRegMode 
                      );
--+-----------------------------------------------------------------------------
--|     Function Name  : RegMult
--|
--|     Overloading    : None
--|
--|     Purpose        : Multiplication of std_logic_vectors.
--|
--|     Parameters     :
--|                      result       - output std_logic_vector, the computed product
--|                      overflow     - output std_ulogic, overflow condition
--|                      multiplicand - input std_logic_vector,
--|                      multiplier   -  input std_logic_vector,
--|                      SrcRegMode   - input  regmode_type, indicating the format 
--|                                     of the input std_logic_vector.   Default is 
--|                                     DefaultRegMode which is set to TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|    Algorithm       : The multiplication is carried out as follows:
--|
--|                      1) Determine sign of result based on sign of 
--|                         multiploicand and sign  of multiplier.
--|
--|                      2) Convert the multiplicand amd multiplier to Unsigned 
--|                         representation.
--|                      
--|                      3) Perform multiplication based on add and shift algorithm.
--|
--|                      4) Convert the result to the SrcRegMode with appropropriate sign
--|
--|     Result         :
--|                     A  temporary result is computed with length N+M (where
--|                      N,M are the lengths of the multiplicand and multiplier).
--|                      This computed value is extended or truncated to match
--|                      the width of 'result'. If truncated, the low order std_ulogics
--|                      are returned.
--|
--|                      The parameter 'overflow' is set to '1' if the product of the
--|                      of the two inputs too large to fit in the parameter result.
--|
--|     Use            :
--|                      VARIABLE x, y, prod : std_logic_vector ( 15 DOWNTO 0);
--|                      VARIABLE ovfl : std_ulogic;
--|
--|                      RegMult ( prod, ovfl, x, y, TwosComp );
--|
--|     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE RegMult ( VARIABLE result       : OUT std_logic_vector;
                        VARIABLE overflow     : OUT std_ulogic;
                        CONSTANT multiplicand : IN std_logic_vector;
                        CONSTANT multiplier   : IN std_logic_vector;
                        CONSTANT SrcRegMode   : IN regmode_type := DefaultRegMode 
                      );

--+-----------------------------------------------------------------------------
--|     Function Name  : RegMult
--|
--|     Overloading    : None
--|
--|     Purpose        : Multiplication of std_ulogic_vectorS.
--|
--|     Parameters     :
--|                      result       - output std_ulogic_vector, the computed product
--|                      overflow     - output std_ulogic, overflow condition
--|                      multiplicand - input std_ulogic_vector,
--|                      multiplier   -  input std_ulogic_vector,
--|                      SrcRegMode   - input  regmode_type, indicating the format 
--|                                     of the input std_ulogic_vector.   Default is 
--|                                     DefaultRegMode which is set to TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|    Algorithm       : The multiplication is carried out as follows:
--|
--|                      1) Determine sign of result based on sign of 
--|                         multiploicand and sign  of multiplier.
--|
--|                      2) Convert the multiplicand amd multiplier to Unsigned 
--|                         representation.
--|                      
--|                      3) Perform multiplication based on add and shift algorithm.
--|
--|                      4) Convert the result to the SrcRegMode with appropropriate sign
--|
--|     Result         :
--|                     A  temporary result is computed with length N+M (where
--|                      N,M are the lengths of the multiplicand and multiplier).
--|                      This computed value is extended or truncated to match
--|                      the width of 'result'. If truncated, the low order std_ulogics
--|                      are returned.
--|
--|                      The parameter 'overflow' is set to '1' if the product of the
--|                      of the two inputs too large to fit in the parameter result.
--|
--|     Use            :
--|                      VARIABLE x, y, prod : std_ulogic_vector ( 15 DOWNTO 0);
--|                      VARIABLE ovfl : std_ulogic;
--|
--|                      RegMult ( prod, ovfl, x, y, TwosComp );
--|
--|     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE RegMult ( VARIABLE result       : OUT std_ulogic_vector;
                        VARIABLE overflow     : OUT std_ulogic;
                        CONSTANT multiplicand : IN std_ulogic_vector;
                        CONSTANT multiplier   : IN std_ulogic_vector;
                        CONSTANT SrcRegMode   : IN regmode_type := DefaultRegMode 
                      );
--+-----------------------------------------------------------------------------
--|     Function Name  : RegDiv
--|
--|     Overloading    : None
--|
--|     Purpose        : Division of BIT_VECTORS. (Result = dividend / divisor)
--|
--|     Parameters     :
--|                      result     - output BIT_VECTOR,
--|                      remainder  - output BIT_VECTOR,
--|                      ZeroDivide - output BIT,
--|                                   set to '1'  when divide by zero occurred
--|                                          '0'  divide by zero did not occur
--|                      dividend   - input  BIT_VECTOR,
--|                      divisor    - input  BIT_VECTOR,
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input BIT_VECTOR.   Default is TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|                      Temporary result and remainder values are computed with
--|                      same length as the dividend. This computed value is
--|                      extended or truncated to match the widths of 'result'
--|                      and 'remainder'. When truncated, the low order bits are
--|                      returned.
--|
--|                      The remainder has the same sign as the dividend.
--|
--|     Use            :
--|                      VARIABLE x, y, res, rem : BIT_VECTOR ( 15 DOWNTO 0);
--|                      VARIABLE zflag     : BIT;
--|
--|                      RegDiv ( res, rem,zflag, x, y, TwosComp );
--|
--|     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE RegDiv  ( VARIABLE result     : OUT BIT_VECTOR;
                        VARIABLE remainder  : OUT BIT_VECTOR;
                        VARIABLE ZeroDivide : OUT BIT;
                        CONSTANT dividend   :  IN BIT_VECTOR;
                        CONSTANT divisor    :  IN BIT_VECTOR;
                        CONSTANT SrcRegMode    :  IN regmode_type := DefaultRegMode
                      );
    -------------------------------------------------------------------------------
    --     Function Name  : RegDiv
    --
    --     Overloading    : None
    --    
    --     Purpose        : Division of std_logic_vectors.(Result = dividend/divisor)
    --     
    --     Parameters     : 
    --                      result     - output std_logic_vector, 
    --                      remainder  - output std_logic_vector,
    --                      ZeroDivide - output Std_ulogic,
    --                                   set to '1'  when divide by zero occurred
    --                                          '0'  divide by zero did not occur
    --                      dividend   - input  std_logic_vector, 
    --                      divisor    - input  std_logic_vector, 
    --                      SrcRegMode - input  regmode_type, indicating the format 
    --                                   of  the input std_logic_vector.   
    --                                   Default is TwosComp.
    --     
    --     NOTE           : 
    --                      The inputs may be of any length and may be of differing 
    --                      lengths. 
    --
    --                      Temporary result and remainder values are computed with 
    --                      same length as the dividend. This computed value is 
    --                      extended or truncated to match the widths of 'result' 
    --                      and 'remainder'. When truncated, the low order bits are 
    --                      returned.
    --
    --                      The remainder has the same sign as the dividend.
    --     Use            : 
    --                      VARIABLE x, y, res, rem : std_logic_vector ( 15 DOWNTO 0);
    --                      VARIABLE zflag     : std_ulogic;
    --
    --                      RegDiv ( res, rem, zflag,x, y, TwosComp );
    --     
    --     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    PROCEDURE RegDiv  ( VARIABLE result     : OUT std_logic_vector;
                        VARIABLE remainder  : OUT std_logic_vector;
                        VARIABLE ZeroDivide : OUT std_ulogic;
                        CONSTANT dividend   :  IN std_logic_vector;
                        CONSTANT divisor    :  IN std_logic_vector;
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      );
    -------------------------------------------------------------------------------
    --     Function Name  : RegDiv
    --
    --     Overloading    : None
    --    
    --     Purpose        : Division of std_ulogic_vectors.(Result = dividend/divisor)
    --     
    --     Parameters     : 
    --                      result     - output std_ulogic_vector, 
    --                      remainder  - output std_ulogic_vector,
    --                      ZeroDivide - output Std_ulogic,
    --                                   set to '1'  when divide by zero occurred
    --                                          '0'  divide by zero did not occur
    --                      dividend   - input  std_ulogic_vector, 
    --                      divisor    - input  std_ulogic_vector, 
    --                      SrcRegMode - input  regmode_type, indicating the format 
    --                                   of  the input std_ulogic_vector.   
    --                                   Default is TwosComp.
    --     
    --     NOTE           : 
    --                      The inputs may be of any length and may be of differing 
    --                      lengths. 
    --
    --                      Temporary result and remainder values are computed with 
    --                      same length as the dividend. This computed value is 
    --                      extended or truncated to match the widths of 'result' 
    --                      and 'remainder'. When truncated, the low order bits are 
    --                      returned.
    --
    --                      The remainder has the same sign as the dividend.
    --     Use            : 
    --                      VARIABLE x, y, res, rem : std_ulogic_vector ( 15 DOWNTO 0);
    --                      VARIABLE zflag     : std_ulogic;
    --
    --                      RegDiv ( res, rem, zflag,x, y, TwosComp );
    --     
    --     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    PROCEDURE RegDiv  ( VARIABLE result     : OUT std_ulogic_vector;
                        VARIABLE remainder  : OUT std_ulogic_vector;
                        VARIABLE ZeroDivide : OUT std_ulogic;
                        CONSTANT dividend   :  IN std_ulogic_vector;
                        CONSTANT divisor    :  IN std_ulogic_vector;
                        CONSTANT SrcRegMode    :  IN regmode_type := DefaultRegMode
                      );
--+-----------------------------------------------------------------------------
--|     Function Name  : RegMod
--| 1.5.17  
--|     Overloading    : None
--| 
--|     Purpose        : Modulus operation of  BIT_VECTORS.
--| 
--|     Parameters     :
--|                      result     - output BIT_VECTOR,
--|                      ZeroDivide - output BIT,
--|                                   set to '1'  when divide by zero occurred
--|                                          '0'  divide by zero did not occur
--|                      dividend   - input  BIT_VECTOR,
--|                      modulus    - input  BIT_VECTOR,
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input BIT_VECTOR.   Default is TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|                      Temporary quotient and modulus values are computed with
--|                      same length as the dividend. This computed value is
--|                      extended or truncated to match the widths of 'result'
--|                      When truncated, the low order bits are
--|                      returned.
--|
--|                      The mod has the same sign as the modulus operator.
--|
--|     Use            :
--|                      VARIABLE x, y, res : BIT_VECTOR ( 15 DOWNTO 0);
--|                      VARIABLE zflag     : BIT;
--|
--|                      RegMod ( res,zflag, x, y, TwosComp );
--|
--|     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE RegMod  ( VARIABLE result     : OUT BIT_VECTOR;
                        VARIABLE ZeroDivide : OUT BIT;
                        CONSTANT dividend   : IN BIT_VECTOR;
                        CONSTANT modulus    : IN BIT_VECTOR;
                        CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                      );
    -------------------------------------------------------------------------------
    --     Function Name  : RegMod
    -- 1.5.18  
    --     Overloading    : None
    --
    --     Purpose        : Modulus  operation of std_logic_vectors.
    --
    --     Parameters     :
    --                      result     - output std_logic_vector,
    --                      ZeroDivide - output Std_ulogic,
    --                                   set to '1'  when divide by zero occurred
    --                                          '0'  divide by zero did not occur
    --                      dividend   - input  std_logic_vector,
    --                      modulus    - input  std_logic_vector,
    --                      SrcRegMode - input  regmode_type, indicating the format
    --                                    of the input std_logic_vector.   
    --                                    Default is DefaultRegMode.
    --
    --     NOTE           :
    --                      The inputs may be of any length and may be of differing
    --                      lengths.
    --
    --                      Temporary quotient and modulus values are computed with
    --                      same length as the dividend. This computed value is
    --                      extended or truncated to match the widths of 'result'
    --                      When truncated, the low order bits are
    --                      returned.
    --
    --                      The mod has the same sign as the modulus operator.
    --
    --     Use            :
    --                      VARIABLE x, y, ovf : std_logic_vector ( 15 DOWNTO 0);
    --                      VARIABLE zflag     : std_ulogic;
    --
    --                      RegMod ( res,zflag, x, y, TwosComp );
    --
    --     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    PROCEDURE RegMod  ( VARIABLE result     : OUT std_logic_vector;
                        VARIABLE ZeroDivide : OUT std_ulogic;
                        CONSTANT dividend   :  IN std_logic_vector;
                        CONSTANT modulus    :  IN std_logic_vector;
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      );
    -------------------------------------------------------------------------------
    --     Function Name  : RegMod
    --   
    --     Overloading    : None
    --
    --     Purpose        : Modulus  operation of std_ulogic_vectors.
    --
    --     Parameters     :
    --                      result     - output std_ulogic_vector,
    --                      ZeroDivide - output Std_ulogic,
    --                                   set to '1'  when divide by zero occurred
    --                                          '0'  divide by zero did not occur
    --                      dividend   - input  std_ulogic_vector,
    --                      modulus    - input  std_ulogic_vector,
    --                      SrcRegMode - input  regmode_type, indicating the format
    --                                    of the input std_ulogic_vector.   
    --                                    Default is DefaultRegMode.
    --
    --     NOTE           :
    --                      The inputs may be of any length and may be of differing
    --                      lengths.
    --
    --                      Temporary quotient and modulus values are computed with
    --                      same length as the dividend. This computed value is
    --                      extended or truncated to match the widths of 'result'
    --                      When truncated, the low order bits are
    --                      returned.
    --
    --                      The mod has the same sign as the modulus operator.
    --
    --     Use            :
    --                      VARIABLE x, y, res : std_ulogic_vector ( 15 DOWNTO 0);
    --                      VARIABLE zflag     : std_ulogic;
    --
    --                      RegMod ( res, zflag, x, y, TwosComp );
    --
    --     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    PROCEDURE RegMod  ( VARIABLE result     : OUT std_ulogic_vector;
                        VARIABLE ZeroDivide : OUT std_ulogic;
                        CONSTANT dividend   :  IN std_ulogic_vector;
                        CONSTANT modulus    :  IN std_ulogic_vector;
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      );
--+-----------------------------------------------------------------------------
--|     Function Name  : RegRem
--| 1.5.25
--|     Overloading    : None
--|
--|     Purpose        : Remainder operation of  BIT_VECTORS.
--|
--|     Parameters     :
--|                      result     - output BIT_VECTOR,
--|                      ZeroDivide - output BIT,
--|                                   set to '1'  when divide by zero occurred
--|                                          '0'  divide by zero did not occur
--|                      dividend   - input  BIT_VECTOR,
--|                      divisor    - input  BIT_VECTOR,
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input BIT_VECTOR.   Default is TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|                      Temporary quotient and remainder values are computed with
--|                      same length as the dividend. This computed value is
--|                      extended or truncated to match the widths of 'result'
--|                      When truncated, the low order bits are
--|                      returned.
--|
--|                      The remainder has the same sign as the dividend.
--|
--|     Use            :
--|                      VARIABLE x, y, res : BIT_VECTOR ( 15 DOWNTO 0);
--|                      VARIABLE zflag     : BIT;
--|
--|                      RegRem ( res, zflag, x, y, TwosComp );
--|
--|     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE RegRem  ( VARIABLE result     : OUT BIT_VECTOR;
                        VARIABLE ZeroDivide : OUT BIT;
                        CONSTANT dividend   :  IN BIT_VECTOR;
                        CONSTANT divisor    :  IN BIT_VECTOR;
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      );
    -------------------------------------------------------------------------------
    --     Function Name  : RegRem
    -- 1.5.26
    --     Overloading    : None
    --
    --     Purpose        :Remainder operation of std_logic_vectorS. 
    --
    --     Parameters     :
    --                      result     - output std_logic_vector,
    --                      ZeroDivide - output Std_ulogic,
    --                                   set to '1'  when divide by zero occurred
    --                                          '0'  divide by zero did not occur
    --                      dividend   - input  std_logic_vector,
    --                      divisor    - input  std_logic_vector,
    --                      SrcRegMode - input  regmode_type, indicating the format
    --                                    of the input std_logic_vector.   
    --                                     Default is StdRegMode.
    --
    --     NOTE           :
    --                      The inputs may be of any length and may be of differing
    --                      lengths.
    --
    --                      Temporary quotient and remainder values are computed with
    --                      same length as the dividend. This computed value is
    --                      extended or truncated to match the widths of 'result'
    --                      When truncated, the low order bits are
    --                      returned.
    --                      The remainder has the same sign as the dividend.
    --
    --
    --     Use            :
    --                      VARIABLE x, y, res : std_logic_vector ( 15 DOWNTO 0);
    --                      VARIABLE zflag     : std_ulogic;
    --
    --                      RegRem ( res,zflag, x, y, TwosComp );
    --
    --     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc,  RegNegate
    -------------------------------------------------------------------------------
    PROCEDURE RegRem  ( VARIABLE result     : OUT std_logic_vector;
                        VARIABLE ZeroDivide : OUT std_ulogic;
                        CONSTANT dividend   :  IN std_logic_vector;
                        CONSTANT divisor    :  IN std_logic_vector;
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      );
    -------------------------------------------------------------------------------
    --     Function Name  : RegRem
    -- 
    --     Overloading    : None
    --
    --     Purpose        :Remainder operation of std_ulogic_vectorS. 
    --
    --     Parameters     :
    --                      result     - output std_ulogic_vector,
    --                      ZeroDivide - output Std_ulogic,
    --                                   set to '1'  when divide by zero occurred
    --                                          '0'  divide by zero did not occur
    --                      dividend   - input  std_ulogic_vector,
    --                      divisor    - input  std_ulogic_vector,
    --                      SrcRegMode - input  regmode_type, indicating the format
    --                                    of the input std_ulogic_vector.   
    --                                     Default is StdRegMode.
    --
    --     NOTE           :
    --                      The inputs may be of any length and may be of differing
    --                      lengths.
    --
    --                      Temporary quotient and remainder values are computed with
    --                      same length as the dividend. This computed value is
    --                      extended or truncated to match the widths of 'result'
    --                      When truncated, the low order bits are
    --                      returned.
    --
    --                      The remainder has the same sign as the dividend.
    --
    --
    --     Use            :
    --                      VARIABLE x, y, res : std_ulogic_vector ( 15 DOWNTO 0);
    --                      VARIABLE zflag     : std_ulogic;
    --
    --                      RegRem ( res, zflag,x, y, TwosComp );
    --
    --     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc,  RegNegate
    -------------------------------------------------------------------------------
    PROCEDURE RegRem  ( VARIABLE result     : OUT std_ulogic_vector;
                        VARIABLE ZeroDivide : OUT std_ulogic;
                        CONSTANT dividend   :  IN std_ulogic_vector;
                        CONSTANT divisor    :  IN std_ulogic_vector;
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      ); 
--+-----------------------------------------------------------------------------
--|     Function Name  : RegExp
--| 1.6.1 
--|     Overloading    : None
--|
--|     Purpose        : Exponentiation of BIT_VECTORS.
--|
--|     Parameters     :
--|                      result     - output BIT_VECTOR, 
--|                      overflow   - output BIT, overflow condition
--|                      base       - input BIT_VECTOR,
--|                      exponent   -  input BIT_VECTOR,
--|                      SrcRegMode - input  regmode_type, indicating the format
--|                                   of the input BIT_VECTOR.  
--|                                    Default is DefaultRegMode.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|                      This computed value is extended or truncated to match
--|                      the width of 'result'. If truncated, the low order bits
--|                      are returned.
--|
--|     Limitations:     This procedure converts the exponent to integer and
--|                      uses repeated multiplications to calculate exponentiation.
--|                      Therefore, exponet cannot be large the maximum integer 
--|                      value of the system. 
--|
--|     Use            :
--|                      VARIABLE x, y, expo : BIT_VECTOR ( 15 DOWNTO 0);
--|                      VARIABLE ovfl : BIT;
--|
--|                      RegExp ( expo, ovfl, x, y, TwosComp );
--|
--|     See Also       : RegMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE RegExp ( VARIABLE result     : OUT BIT_VECTOR;
                       VARIABLE overflow   : OUT BIT;
                       CONSTANT base       : IN BIT_VECTOR;
                       CONSTANT exponent   : IN BIT_VECTOR;
                       CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                     );
--+-----------------------------------------------------------------------------
--|     Function Name  : RegExp
--| 1.6.2
--|     Overloading    : None
--|
--|     Purpose        : Exponentiation of logic vectors.
--|
--|     Parameters     :
--|                      result     - output std_logic_vector,
--|                      overflow   - output std_ulogic, overflow condition
--|                      base       - input std_logic_vector,
--|                      exponent   -  input std_logic_vector,
--|                      SrcRegMode - input  regmode_type, indicating the format 
--|                                of the input std_logic_vector.  
--|                                Default is DefaultRegMode.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|                      This computed value is extended or truncated to match
--|                      the width of 'result'. If truncated, the low order bits
--|                      are returned.
--|
--|     Limitations:     This procedure converts the exponent to integer and
--|                      uses repeated multiplications to calculate exponentiation.
--|                      Therefore, exponet cannot be large the maximum integer 
--|                      value of the system. 
--|
--|     Use            :
--|                      VARIABLE x, y, expo : std_logic_vector ( 15 DOWNTO 0);
--|                      VARIABLE ovfl : std_ulogic;
--|
--|                      RegExp ( expo, ovfl, x, y, TwosComp );
--|
--|     See Also       : RegMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE RegExp ( VARIABLE result     : OUT std_logic_vector;
                       VARIABLE overflow   : OUT std_ulogic;
                       CONSTANT base       : IN std_logic_vector;
                       CONSTANT exponent   : IN std_logic_vector;
                       CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                     );
--+-----------------------------------------------------------------------------
--|     Function Name  : RegExp
--| 
--|     Overloading    : None
--|
--|     Purpose        : Exponentiation of logic vectors.
--|
--|     Parameters     :
--|                      result     - output std_ulogic_vector,
--|                      overflow   - output std_ulogic, overflow condition
--|                      base       - input std_ulogic_vector,
--|                      exponent   -  input std_ulogic_vector,
--|                      SrcRegMode - input  regmode_type, indicating the format 
--|                                of the input std_ulogic_vector.  
--|                                Default is DefaultRegMode.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|                      This computed value is extended or truncated to match
--|                      the width of 'result'. If truncated, the low order bits
--|                      are returned.
--|
--|     Limitations:     This procedure converts the exponent to integer and
--|                      uses repeated multiplications to calculate exponentiation.
--|                      Therefore, exponet cannot be large the maximum integer 
--|                      value of the system. 
--|
--|     Use            :
--|                      VARIABLE x, y, expo : std_ulogic_vector ( 15 DOWNTO 0);
--|                      VARIABLE ovfl : std_ulogic;
--|
--|                      RegExp ( expo, ovfl, x, y, TwosComp );
--|
--|     See Also       : RegMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE RegExp ( VARIABLE result     : OUT std_ulogic_vector;
                       VARIABLE overflow   : OUT std_ulogic;
                       CONSTANT base       : IN std_ulogic_vector;
                       CONSTANT exponent   : IN std_ulogic_vector;
                       CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                     );
--+-----------------------------------------------------------------------------
--|     Function Name  : RegShift
--| 
--|     Overloading    : None
--|
--|     Purpose        : Bidirectional logical shift operator for   BIT_VECTORS.
--|
--|     Parameters     :
--|                      SrcReg      - input  BIT_VECTOR, vector to be shifted
--|                      DstReg      - inout, BIT_VECTOR, shifted result
--|                      ShiftO      - inout, BIT, holds the last bit shifted out 
--|                                          of register
--|                      direction   - input, BIT
--|                                         '0'  means right shift
--|                                         '1'  means left shift, default is left shift
--|                      FillVal     - input, BIT, value to fill register with. 
--|                                          default is '0'
--|                      Nbits       - input , NATURAL, number of positions to shift
--|                                          default is 1.
--|
--|     Result         : Shifted bit_vector
--|
--|     Use            :
--|                      VARIABLE acc   : BIT_VECTOR ( 15 DOWNTO 0);
--|                      VARIABLE carry : BIT;
--|
--|                      RegShift ( acc, acc, carry, '1', '0',3 );
--|
--|-----------------------------------------------------------------------------
   PROCEDURE RegShift  ( CONSTANT SrcReg    : IN BIT_VECTOR;
                         VARIABLE DstReg    : INOUT BIT_VECTOR;
                         VARIABLE ShiftO    : INOUT BIT; 
                         CONSTANT direction : IN BIT     := '1';
                         CONSTANT FillVal   : IN BIT     := '0';
                         CONSTANT Nbits     : IN Natural := 1
                      ); 
--+-----------------------------------------------------------------------------
--|     Function Name  : RegShift
--| 
--|     Overloading    : None
--|
--|     Purpose        : Bidirectional logical shift operator for logic vector.
--|
--|     Parameters     :
--|                      SrcReg      - input  std_logic_vector, vector to be shifted
--|                      DstReg      - inout, std_logic_vector, shifted result
--|                      ShiftO      - inout, std_ulogic, holds the last bit shifted out 
--|                                          of register
--|                      direction   - input, Std_ulogic
--|                                         '0'  means right shift
--|                                         '1' | 'X'  means left shift, 
--|                                          default is left shift
--|                      FillVal     - input, Std_ulogic, value to fill register with. 
--|                                          default is '0'
--|                      Nbits       - input , NATURAL, number of positions to shift
--|                                          default is 1.
--|
--|     Result         : Shifted std_logic_vector
--|
--|     Use            :
--|                      VARIABLE acc   : std_logic_vector ( 15 DOWNTO 0);
--|                      VARIABLE carry : std_ulogic;
--|
--|                      RegShift ( acc, acc, carry, '1', '0',3 );
--|
--|-----------------------------------------------------------------------------
   PROCEDURE RegShift  ( CONSTANT SrcReg    : IN std_logic_vector;
                         VARIABLE DstReg    : INOUT std_logic_vector;
                         VARIABLE ShiftO    : INOUT std_ulogic; 
                         CONSTANT direction : IN std_ulogic   := '1';
                         CONSTANT FillVal   : IN std_ulogic   := '0';
                         CONSTANT Nbits     : IN Natural      := 1
                      ); 
--+-----------------------------------------------------------------------------
--|     Function Name  : RegShift
--| 
--|     Overloading    : None
--|
--|     Purpose        : Bidirectional logical shift operator for ulogic vector.
--|
--|     Parameters     :
--|                      SrcReg      - input  std_ulogic_vector, vector to be shifted
--|                      DstReg      - inout, std_ulogic_vector, shifted result
--|                      ShiftO      - inout, std_ulogic, holds the last bit shifted out 
--|                                          of register
--|                      direction   - input, Std_ulogic
--|                                         '0'  means right shift
--|                                         '1' | 'X'  means left shift, 
--|                                          default is left shift
--|                      FillVal     - input, Std_ulogic, value to fill register with. 
--|                                          default is '0'
--|                      Nbits       - input , NATURAL, number of positions to shift
--|                                          default is 1.
--|
--|     Result         : Shifted std_ulogic_vector
--|
--|     Use            :
--|                      VARIABLE acc   : std_ulogic_vector ( 15 DOWNTO 0);
--|                      VARIABLE carry : std_ulogic;
--|
--|                      RegShift ( acc, acc, carry, '1', '0',3 );
--|
--|-----------------------------------------------------------------------------
   PROCEDURE RegShift  ( CONSTANT SrcReg    : IN std_ulogic_vector;
                         VARIABLE DstReg    : INOUT std_ulogic_vector;
                         VARIABLE ShiftO    : INOUT std_ulogic; 
                         CONSTANT direction : IN std_ulogic   := '1';
                         CONSTANT FillVal   : IN std_ulogic   := '0';
                         CONSTANT Nbits     : IN Natural      := 1
                      ); 
--+-----------------------------------------------------------------------------
--|     Function Name  : RegInc
--| 
--|     Overloading    : None
--|  
--|     Purpose        : Increment a BIT_VECTOR by 1.
--|  
--|     Parameters     :
--|                      SrcReg     - input  BIT_VECTOR
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input BIT_VECTOR.   Default is TwosComp.
--|  
--|     Result         : BIT_VECTOR ( SrcReg + 1 )
--| 
--|     NOTE           : The length of the return vector is the same as the
--|                      the input vector.
--|  
--|                      Overflow conditions are ignored. UnSigned numbers wrap
--|                      to 0, signed numbers wrap to the largest negative value.
--| 
--|     Use            :
--|                      VARIABLE vect : BIT_VECTOR ( 3 DOWNTO 0 );
--|                      vect := RegInc ( vect, UnSigned )
--| 
--| 
--|     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    FUNCTION RegInc  ( CONSTANT SrcReg        :  IN BIT_VECTOR;
                       CONSTANT SrcRegMode    :  IN regmode_type := DefaultRegMode
                     ) RETURN BIT_VECTOR;
    
    -------------------------------------------------------------------------------
    --     Function Name  : RegInc
    --
    --     Overloading    : None
    --    
    --     Purpose        : Increment a std_logic_vector by 1.
    --     
    --     Parameters     : 
    --                      SrcReg     - input  std_logic_vector
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input std_logic_vector.   Default is TwosComp.
    --     
    --     Result         : std_logic_vector ( SrcReg + 1 )
    --
    --     NOTE           : The length of the return vector is the same as the
    --                      the input vector.
    --                      
    --                      Overflow conditions are ignored. UnSigned numbers wrap
    --                      to 0, signed numbers wrap to the largest negative value.
    --
    --     Use            : 
    --                      VARIABLE vect : std_logic_vector ( 3 DOWNTO 0 );
    --                      vect := RegInc ( vect, UnSigned )
    --     
    --     
    --     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    FUNCTION  RegInc  ( CONSTANT SrcReg        :  IN std_logic_vector;
                        CONSTANT SrcRegMode    :  IN regmode_type := DefaultRegMode
                      ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name  : RegInc
    --
    --     Overloading    : None
    --    
    --     Purpose        : Increment a std_ulogic_vector by 1.
    --     
    --     Parameters     : 
    --                      SrcReg     - input  std_ulogic_vector
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input std_ulogic_vector.   Default is TwosComp.
    --     
    --     Result         : std_ulogic_vector ( SrcReg + 1 )
    --
    --     NOTE           : The length of the return vector is the same as the
    --                      the input vector.
    --                      
    --                      Overflow conditions are ignored. UnSigned numbers wrap
    --                      to 0, signed numbers wrap to the largest negative value.
    --
    --     Use            : 
    --                      VARIABLE vect : std_ulogic_vector ( 3 DOWNTO 0 );
    --                      vect := RegInc ( vect, UnSigned )
    --     
    --     
    --     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    FUNCTION  RegInc  ( CONSTANT SrcReg        :  IN std_ulogic_vector;
                        CONSTANT SrcRegMode    :  IN regmode_type := DefaultRegMode
                      ) RETURN std_ulogic_vector;
--+-----------------------------------------------------------------------------
--|     Function Name  : RegDec
--|
--|     Overloading    : None
--| 
--|     Purpose        : Decrement a BIT_VECTOR by 1.
--| 
--|     Parameters     :
--|                      SrcReg     - input  BIT_VECTOR
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input BIT_VECTOR.   Default is TwosComp.
--| 
--|     Result         : BIT_VECTOR ( SrcReg - 1 )
--|
--|     NOTE           : The length of the return vector is the same as the
--|                      the input vector.
--| 
--|
--|     Use            :
--|                      VARIABLE vect : BIT_VECTOR ( 3 DOWNTO 0 );
--|                      vect := RegDec ( vect, UnSigned )
--| 
--| 
--|     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    FUNCTION RegDec  ( CONSTANT SrcReg        :  IN BIT_VECTOR;
                       CONSTANT SrcRegMode    :  IN regmode_type := DefaultRegMode
                     ) RETURN BIT_VECTOR;
    -------------------------------------------------------------------------------
    --     Function Name  : RegDec
    --
    --     Overloading    : None
    --    
    --     Purpose        : Decrement a std_logic_vector by 1.
    --     
    --     Parameters     : 
    --                      SrcReg     - input  std_logic_vector
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input std_logic_vector.   Default is TwosComp.
    --     
    --     Result         : std_logic_vector ( SrcReg - 1 )
    --
    --     NOTE           : The length of the return vector is the same as the
    --                      the input vector.
    --                      
    --
    --     Use            : 
    --                      VARIABLE vect : std_logic_vector ( 3 DOWNTO 0 );
    --                      vect := RegDec ( vect, UnSigned )
    --     
    --     
    --     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    FUNCTION  RegDec  ( CONSTANT SrcReg        :  IN std_logic_vector;
                        CONSTANT SrcRegMode    :  IN regmode_type := DefaultRegMode
                      ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name  : RegDec
    --
    --     Overloading    : None
    --    
    --     Purpose        : Decrement a std_ulogic_vector by 1.
    --     
    --     Parameters     : 
    --                      SrcReg     - input  std_ulogic_vector
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input std_ulogic_vector.   Default is TwosComp.
    --     
    --     Result         : std_ulogic_vector ( SrcReg - 1 )
    --
    --     NOTE           : The length of the return vector is the same as the
    --                      the input vector.
    --                      
    --
    --     Use            : 
    --                      VARIABLE vect : std_ulogic_vector ( 3 DOWNTO 0 );
    --                      vect := RegDec ( vect, UnSigned )
    --     
    --     
    --     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    FUNCTION  RegDec  ( CONSTANT SrcReg        :  IN std_ulogic_vector;
                        CONSTANT SrcRegMode    :  IN regmode_type := DefaultRegMode
                      ) RETURN std_ulogic_vector;
--+-----------------------------------------------------------------------------
--|     Function Name  : RegNegate
--|
--|     Overloading    : None
--|
--|     Purpose        : Negate a BIT_VECTOR ( v := 0 - v )
--|
--|     Parameters     :
--|                      SrcReg     - input  BIT_VECTOR
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input BIT_VECTOR.   Default is TwosComp.
--|
--|     Result         : BIT_VECTOR ( 0 - SrcReg )
--|
--|     NOTE           : The length of the return vector is the same as the
--|                      the input vector.
--|
--|                      If 'SrcRegMode' is UnSigned the bitwise NOT of 'SrcReg'
--|                      is returned.
--|
--|                      An overflow can occur when 'SrcRegMode' is TwosComp and
--|                      'SrcReg' is the largest negative value (ie "100...00").
--|                      In this case NO error is indicated and the returned
--|                      value is the same as the input.
--|
--|     Use            :
--|                      VARIABLE vect : BIT_VECTOR (15 DOWNTO 0 );
--|                      vect := RegNegate ( vect, TwosComp );
--|
--|     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    FUNCTION RegNegate  ( CONSTANT SrcReg      :  IN BIT_VECTOR;
                          CONSTANT SrcRegMode  :  IN regmode_type := DefaultRegMode
                        ) RETURN BIT_VECTOR;
    -------------------------------------------------------------------------------
    --     Function Name  : RegNegate
    --
    --     Overloading    : None
    --    
    --     Purpose        : Negate a std_logic_vector ( v := 0 - v )
    --     
    --     Parameters     : 
    --                      SrcReg     - input  std_logic_vector
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input std_logic_vector.   Default is TwosComp.
    --     
    --     Result         : std_logic_vector ( 0 - SrcReg )
    --
    --     NOTE           : The length of the return vector is the same as the
    --                      the input vector.
    --                      
    --                      If 'SrcRegMode' is UnSigned the bitwise NOT of 'SrcReg'
    --                      is returned.
    --
    --                      An overflow can occur when 'SrcRegMode' is TwosComp and
    --                      'SrcReg' is the largest negative value (ie "100...00").
    --                      In this case NO error is indicated and the returned
    --                      value is the same as the input.
    --
    --     Use            : 
    --                      VARIABLE vect : std_logic_vector (15 DOWNTO 0 );
    --                      vect := RegNegate ( vect, TwosComp );
    --                      vect := RegNegate ( vect );
    --     
    --     
    --     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    FUNCTION  RegNegate  ( CONSTANT SrcReg     :  IN std_logic_vector;
                           CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                         ) RETURN std_logic_vector;
    -------------------------------------------------------------------------------
    --     Function Name  : RegNegate
    --
    --     Overloading    : None
    --    
    --     Purpose        : Negate an std_ulogic_vector 
    --     
    --     Parameters     : 
    --                      SrcReg     - input  std_ulogic_vector
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input std_ulogic_vector.   Default is TwosComp.
    --     
    --     Result         : std_ulogic_vector ( 0 - SrcReg )
    --
    --     NOTE           : The length of the return vector is the same as the
    --                      the input vector.
    --                      
    --                      If 'SrcRegMode' is UnSigned the bitwise NOT of 'SrcReg'
    --                      is returned.
    --
    --                      An overflow can occur when 'SrcRegMode' is TwosComp and
    --                      'SrcReg' is the largest negative value (ie "100...00").
    --                      In this case NO error is indicated and the returned
    --                      value is the same as the input.
    --
    --     Use            : 
    --                      VARIABLE vect : std_ulogic_vector (15 DOWNTO 0 );
    --                      vect := RegNegate ( vect, TwosComp );
    --                      vect := RegNegate ( vect );
    --     
    --     
    --     See Also       : RegAdd, RegSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    FUNCTION  RegNegate  ( CONSTANT SrcReg     :  IN std_ulogic_vector;
                           CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                         ) RETURN std_ulogic_vector;

    -- ----------------------------------------------------------------------------
    -- ----------------------------------------------------------------------------
    --    Adding procedure to handle signals
    -- ----------------------------------------------------------------------------
    -- ----------------------------------------------------------------------------
    --     Procedure Name : SregAbs
    -- 1.6.9
    --     Overloading    : Procedure .
    --
    --     Purpose        : converts  std_logic_vector into an absolute value.
    --
    --     Parameters     :
    --                      result     - input-output  std_logic_vector, 
    --                      SrcReg     - input  std_logic_vector, the vector to be read.
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input std_logic_vector.   Default is TwosComp.
    --
    --
    --     Use            :
    --                      signal reslt, vect : std_logic_vector ( 15 DOWNTO 0 );
    --
    --                       SregAbs ( reslt,  vect, TwosComp );
    --
    -------------------------------------------------------------------------------
    PROCEDURE SregAbs ( SIGNAL result       : INOUT std_logic_vector;
                        CONSTANT SrcReg     : IN std_logic_vector;
                        CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                      );
    -------------------------------------------------------------------------------
    --     Procedure Name : SregAbs
    -- 
    --     Overloading    : Procedure .
    --
    --     Purpose        : converts  std_ulogic_vector into an absolute value.
    --
    --     Parameters     :
    --                      result     - input- output  std_ulogic_vector, 
    --                      SrcReg     - input  std_ulogic_vector, the vector to be read.
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input std_ulogic_vector.   Default is TwosComp.
    --
    --
    --     Use            :
    --                       SIGNAL reslt, vect : std_ulogic_vector ( 15 DOWNTO 0 );
    --
    --                       SregAbs ( reslt,  vect, TwosComp );
    --
    -------------------------------------------------------------------------------
    PROCEDURE SregAbs  ( SIGNAL result       : INOUT std_ulogic_vector;
                        CONSTANT SrcReg     : IN std_ulogic_vector;
                        CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                      );
    -------------------------------------------------------------------------------
    --     Procedure Name  : SregAbs
    -- 1.6.10
    --     Overloading    : Procedure .
    --
    --     Purpose        : converts  bit_vectors into an absolute value.
    --
    --     Parameters     :
    --                      result     - input-output  bit_vector, 
    --                      SrcReg     - input  bit_vector, the vector to be read.
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input bit_vector.   Default is TwosComp.
    --
    --
    --     Use            :
    --                      SIGNAL reslt, vect : bit_vector ( 15 DOWNTO 0 );
    --
    --                       SregAbs ( reslt,  vect, TwosComp );
    --
    -------------------------------------------------------------------------------
    PROCEDURE SregAbs  ( SIGNAL result      : INOUT bit_vector;
                        CONSTANT SrcReg     : IN bit_vector;
                        CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                      );
--+-----------------------------------------------------------------------------
--|     Function Name  : SregAdd
--|
--|     Overloading    : None
--|
--|     Purpose        : Addition of BIT_VECTORS.
--|
--|     Parameters     :
--|                      result     - input-output BIT_VECTOR, the computed sum
--|                      carry_out  - output BIT,
--|                      overflow   - output BIT, overflow condition
--|                      addend     - input  BIT_VECTOR,
--|                      augend     - input  BIT_VECTOR,
--|                      carry_in   - input  BIT,  
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input BIT_VECTOR.   Default is TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|                    
--|                       carry_in is only applicable in case od Twos's complkement
--|                       and unsigned addition. carry_in is ignored in case of
--|                       0ne's complement and sign-magnitude addition.
--|
--|                      A temporary result is computed with length N (where
--|                      N is the greater of the input vector lengths).
--|                      This computed value is extended or truncated to match
--|                      the width of 'result'. If truncated, the low order bits
--|                      are returned.
--| 
--|     Use            :
--|                      SIGNAL x, y, sum : BIT_VECTOR ( 15 DOWNTO 0);
--|                      SIGNAL carry_in, carry_out , ovf: BIT;
--| 
--|                      SregAdd ( sum, carry_out, ovf,x, y, carry_in, UnSigned );
--| 
--|     See Also       : SregSub, SregMult, SregDiv
--|-----------------------------------------------------------------------------
    PROCEDURE SregAdd  (SIGNAL result       : INOUT BIT_VECTOR;
                        SIGNAL carry_out    : OUT BIT;
                        SIGNAL overflow     : OUT BIT;
                        CONSTANT addend     : IN BIT_VECTOR;
                        CONSTANT augend     : IN BIT_VECTOR;
                        CONSTANT carry_in   : IN BIT;
                        CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode 
                      );
--+-----------------------------------------------------------------------------
--|     Function Name  : SregAdd
--|
--|     Overloading    : None
--|
--|     Purpose        : Addition of logic vectors.
--|
--|     Parameters     :
--|                      result     - output std_logic_vector, the computed sum
--|                      carry_out  - output std_logic,
--|                      overflow   - output std_logic,
--|                      addend     - input  std_logic_vector,
--|                      augend     - input  std_logic_vector,
--|                      carry_in   - input  std_logic, carry into the LSB.
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input std_logic_vector.   Default is TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|  
--|                       carry_in is only applicable in case od Twos's complkement
--|                       and unsigned addition. carry_in is ignored in case of
--|                       0ne's complement and sign-magnitude addition.
--|
--|                      A temporary result is computed with length N (where
--|                      N is the greater of the input vector lengths).
--|                      This computed value is extended or truncated to match
--|                      the width of 'result'. If truncated, the low order bits
--|                      are returned.
--| 
--|     Use            :
--|                      SIGNAL x, y, sum : std_logic_vector ( 15 DOWNTO 0);
--|                      SIGNAL carry_in, carry_out , ovf: std_ulogic;
--| 
--|                      SregAdd ( sum, carry_out, ovf,x, y, carry_in, TwosComp );
--| 
--|     See Also       : SregAdd, SregSub, SregMult, SregDiv, SregInc, SregDec, SregNegate
--|-----------------------------------------------------------------------------
    PROCEDURE SregAdd ( SIGNAL result       : INOUT std_logic_vector;
                        SIGNAL carry_out    : OUT std_ulogic;
                        SIGNAL overflow     : OUT std_ulogic;
                        CONSTANT addend     : IN std_logic_vector;
                        CONSTANT augend     : IN std_logic_vector;
                        CONSTANT carry_in   : IN std_ulogic;
                        CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode 
                      );
--+-----------------------------------------------------------------------------
--|     Function Name  : SregAdd
--|
--|     Overloading    : None
--|
--|     Purpose        : Addition of ulogic vectors.
--|
--|     Parameters     :
--|                      result     - input-output std_ulogic_vector, the computed sum
--|                      carry_out  - output std_logic,
--|                      overflow   - output std_logic,
--|                      addend     - input  std_ulogic_vector,
--|                      augend     - input  std_ulogic_vector,
--|                      carry_in   - input  std_logic, carry into the LSB.
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input std_ulogic_vector.   Default is TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|  
--|                       carry_in is only applicable in case od Twos's complkement
--|                       and unsigned addition. carry_in is ignored in case of
--|                       0ne's complement and sign-magnitude addition.
--|
--|                      A temporary result is computed with length N (where
--|                      N is the greater of the input vector lengths).
--|                      This computed value is extended or truncated to match
--|                      the width of 'result'. If truncated, the low order bits
--|                      are returned.
--| 
--|     Use            :
--|                      SIGNAL x, y, sum : std_ulogic_vector ( 15 DOWNTO 0);
--|                      SIGNAL carry_in, carry_out , ovf: std_ulogic;
--| 
--|                      SregAdd ( sum, carry_out, ovf,x, y, carry_in, TwosComp );
--| 
--|     See Also       : SregSub, SregMult, SregDiv 
--|-----------------------------------------------------------------------------
    PROCEDURE SregAdd ( SIGNAL result       : INOUT std_ulogic_vector;
                        SIGNAL carry_out    : OUT std_ulogic;
                        SIGNAL overflow     : OUT std_ulogic;
                        CONSTANT addend     : IN std_ulogic_vector;
                        CONSTANT augend     : IN std_ulogic_vector;
                        CONSTANT carry_in   : IN std_ulogic;
                        CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode 
                      );
--+-----------------------------------------------------------------------------
--|     Function Name  : SregSub
--|    
--|     Overloading    : None
--|
--|     Purpose        : Subtraction of BIT_VECTORS.
--|                       ( result = minuend - subtrahend )
--|
--|     Parameters     :
--|                      result     - input-output BIT_VECTOR, the computed sum
--|                      borrow_out - output BIT,
--|                      overflow   - output BIT, overflow condition
--|                      minuend - input  BIT_VECTOR,
--|                      subtrahend - input  BIT_VECTOR,
--|                      borrow_in  - input  BIT, borrow from the LSB
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input BIT_VECTOR.   Default is TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|                      borrow_in is only applicable in case od Twos's complement
--|                       and unsigned subtraction. borrow_in is ignored in case of
--|                       0ne's complement and sign-magnitude subtraction.
--|
--|                      A temporary result is computed with length N (where
--|                      N is the greater of the input vector lengths).
--|     Use            :
--|                      SIGNAL x, y, diff : BIT_VECTOR ( 15 DOWNTO 0);
--|                      SIGNAL n_borrow, borrow_in : BIT;
--|
--|                      SregSub ( diff, n_borrow, x, y, borrow_in, UnSigned );
--|
--|     See Also       : SregAdd,  SregMult, SregDiv
--|-----------------------------------------------------------------------------
    PROCEDURE SregSub  (SIGNAL result       : INOUT BIT_VECTOR;
                        SIGNAL borrow_out   : OUT BIT;
                        SIGNAL overflow     : OUT BIT;
                        CONSTANT minuend    :  IN BIT_VECTOR;
                        CONSTANT subtrahend :  IN BIT_VECTOR;
                        CONSTANT borrow_in  :  IN BIT          := '0';
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode 
                      );
--+-----------------------------------------------------------------------------
--|     Function Name  : SregSub
--|    
--|     Overloading    : None
--|
--|     Purpose        : Subtraction of logic vectors.
--|                       ( result = minuend - subtrahend )
--|
--|     Parameters     :
--|                      result     - input_output std_logic_vector, the computed diff
--|                      borrow_out - output std_logic,
--|                      overflow   - output std_logic, overflow condition
--|                      minuend    - input  std_logic_vector,
--|                      subtrahend - input  std_logic_vector,
--|                      borrow_in  - input  std_logic, borrow from the LSB
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                   the input std_logic_vector.   Default is TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|                      borrow_in is only applicable in case od Twos's complement
--|                       and unsigned subtraction. borrow_in is ignored in case of
--|                       0ne's complement and sign-magnitude subtraction.
--|
--|                      A temporary result is computed with length N (where
--|                      N is the greater of the input vector lengths).
--|     Use            :
--|                      SIGNAL x, y, diff : std_logic_vector ( 15 DOWNTO 0);
--|                      SIGNAL n_borrow, borrow_in : std_ulogic;
--|
--|                      SregSub ( diff, n_borrow, x, y, borrow_in, UnSigned );
--|
--|     See Also       : SregAdd, SregMult, SregDiv
--|-----------------------------------------------------------------------------
    PROCEDURE SregSub  (SIGNAL result       : INOUT std_logic_vector;
                        SIGNAL borrow_out   : OUT std_ulogic;
                        SIGNAL overflow     : OUT std_ulogic;
                        CONSTANT minuend    :  IN std_logic_vector;
                        CONSTANT subtrahend :  IN std_logic_vector;
                        CONSTANT borrow_in  :  IN std_ulogic         := '0';
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      );
--+-----------------------------------------------------------------------------
--|     Function Name  : SregSub
--|    
--|     Overloading    : None
--|
--|     Purpose        : Subtraction of ulogic vectors.
--|                       ( result = minuend - subtrahend )
--|
--|     Parameters     :
--|                      result     - input_output std_ulogic_vector, the computed diff
--|                      borrow_out - output std_logic,
--|                      overflow   - output std_logic, overflow condition
--|                      minuend    - input  std_ulogic_vector,
--|                      subtrahend - input  std_ulogic_vector,
--|                      borrow_in  - input  std_logic, borrow from the LSB
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                   the input std_ulogic_vector.   Default is TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|                      borrow_in is only applicable in case od Twos's complement
--|                       and unsigned subtraction. borrow_in is ignored in case of
--|                       0ne's complement and sign-magnitude subtraction.
--|
--|                      A temporary result is computed with length N (where
--|                      N is the greater of the input vector lengths).
--|     Use            :
--|                      SIGNAL x, y, diff : std_ulogic_vector ( 15 DOWNTO 0);
--|                      SIGNAL n_borrow, borrow_in : std_ulogic;
--|
--|                      SregSub ( diff, n_borrow, x, y, borrow_in, UnSigned );
--|
--|     See Also       : SregAdd, SregSub, SregDiv, SregMult
--|-----------------------------------------------------------------------------
    PROCEDURE SregSub  (SIGNAL result       : INOUT std_ulogic_vector;
                        SIGNAL borrow_out   : OUT std_ulogic;
                        SIGNAL overflow     : OUT std_ulogic;
                        CONSTANT minuend    :  IN std_ulogic_vector;
                        CONSTANT subtrahend :  IN std_ulogic_vector;
                        CONSTANT borrow_in  :  IN std_ulogic         := '0';
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      );
--+-----------------------------------------------------------------------------
--|     Function Name  : SregMult
--|
--|     Overloading    : None
--|
--|     Purpose        : Multiplication of BIT_VECTORS.
--|
--|     Parameters     :
--|                      result       - output BIT_VECTOR, the computed product
--|                      overflow     - output BIT, overflow condition
--|                      multiplicand - input BIT_VECTOR,
--|                      multiplier   -  input BIT_VECTOR,
--|                      SrcRegMode   - input  regmode_type, indicating the format 
--|                                     of the input BIT_VECTOR.   Default is 
--|                                     DefaultRegMode which is set to TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|    Algorithm       : The multiplication is carried out as follows:
--|
--|                      1) Determine sign of result based on sign of 
--|                         multiploicand and sign  of multiplier.
--|
--|                      2) Convert the multiplicand amd multiplier to Unsigned 
--|                         representation.
--|                      
--|                      3) Perform multiplication based on add and shift algorithm.
--|
--|                      4) Convert the result to the SrcRegMode with appropropriate sign
--|
--|     Result         :
--|                     A  temporary result is computed with length N+M (where
--|                      N,M are the lengths of the multiplicand and multiplier).
--|                      This computed value is extended or truncated to match
--|                      the width of 'result'. If truncated, the low order bits
--|                      are returned.
--|
--|                      The parameter 'overflow' is set to '1' if the product of the
--|                      of the two inputs too large to fit in the parameter result.
--|
--|     Use            :
--|                      SIGNAL x, y, prod : BIT_VECTOR ( 15 DOWNTO 0);
--|                      SIGNAL ovfl : BIT;
--|
--|                      SregMult ( prod, ovfl, x, y, TwosComp );
--|
--|     See Also       : SregAdd, SregSub, SregDiv
--|-----------------------------------------------------------------------------
    PROCEDURE SregMult (SIGNAL result         : OUT BIT_VECTOR;
                        SIGNAL overflow       : OUT BIT;
                        CONSTANT multiplicand : IN BIT_VECTOR;
                        CONSTANT multiplier   : IN BIT_VECTOR;
                        CONSTANT SrcRegMode   : IN regmode_type := DefaultRegMode 
                      );

--+-----------------------------------------------------------------------------
--|     Function Name  : SregMult
--|
--|     Overloading    : None
--|
--|     Purpose        : Multiplication of std_logic_vectorS.
--|
--|     Parameters     :
--|                      result       - output std_logic_vector, the computed product
--|                      overflow     - output std_ulogic, overflow condition
--|                      multiplicand - input std_logic_vector,
--|                      multiplier   -  input std_logic_vector,
--|                      SrcRegMode   - input  regmode_type, indicating the format 
--|                                     of the input std_logic_vector.   Default is 
--|                                     DefaultRegMode which is set to TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|    Algorithm       : The multiplication is carried out as follows:
--|
--|                      1) Determine sign of result based on sign of 
--|                         multiploicand and sign  of multiplier.
--|
--|                      2) Convert the multiplicand amd multiplier to Unsigned 
--|                         representation.
--|                      
--|                      3) Perform multiplication based on add and shift algorithm.
--|
--|                      4) Convert the result to the SrcRegMode with appropropriate sign
--|
--|     Result         :
--|                     A  temporary result is computed with length N+M (where
--|                      N,M are the lengths of the multiplicand and multiplier).
--|                      This computed value is extended or truncated to match
--|                      the width of 'result'. If truncated, the low order std_ulogics
--|                      are returned.
--|
--|                      The parameter 'overflow' is set to '1' if the product of the
--|                      of the two inputs too large to fit in the parameter result.
--|
--|     Use            :
--|                      SIGNAL x, y, prod : std_logic_vector ( 15 DOWNTO 0);
--|                      SIGNAL ovfl : std_ulogic;
--|
--|                      SregMult ( prod, ovfl, x, y, TwosComp );
--|
--|     See Also       : RegAdd, SregSub, SregMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE SregMult (SIGNAL result         : OUT std_logic_vector;
                        SIGNAL overflow       : OUT std_ulogic;
                        CONSTANT multiplicand : IN std_logic_vector;
                        CONSTANT multiplier   : IN std_logic_vector;
                        CONSTANT SrcRegMode   : IN regmode_type := DefaultRegMode 
                      );

--+-----------------------------------------------------------------------------
--|     Function Name  : SregMult
--|
--|     Overloading    : None
--|
--|     Purpose        : Multiplication of std_ulogic_vectorS.
--|
--|     Parameters     :
--|                      result       - output std_ulogic_vector, the computed product
--|                      overflow     - output std_ulogic, overflow condition
--|                      multiplicand - input std_ulogic_vector,
--|                      multiplier   -  input std_ulogic_vector,
--|                      SrcRegMode   - input  regmode_type, indicating the format 
--|                                     of the input std_ulogic_vector.   Default is 
--|                                     DefaultRegMode which is set to TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|    Algorithm       : The multiplication is carried out as follows:
--|
--|                      1) Determine sign of result based on sign of 
--|                         multiploicand and sign  of multiplier.
--|
--|                      2) Convert the multiplicand amd multiplier to Unsigned 
--|                         representation.
--|                      
--|                      3) Perform multiplication based on add and shift algorithm.
--|
--|                      4) Convert the result to the SrcRegMode with appropropriate sign
--|
--|     Result         :
--|                     A  temporary result is computed with length N+M (where
--|                      N,M are the lengths of the multiplicand and multiplier).
--|                      This computed value is extended or truncated to match
--|                      the width of 'result'. If truncated, the low order std_ulogics
--|                      are returned.
--|
--|                      The parameter 'overflow' is set to '1' if the product of the
--|                      of the two inputs too large to fit in the parameter result.
--|
--|     Use            :
--|                      SIGNAL x, y, prod : std_ulogic_vector ( 15 DOWNTO 0);
--|                      SIGNAL ovfl : std_ulogic;
--|
--|                      SregMult ( prod, ovfl, x, y, TwosComp );
--|
--|     See Also       : RegAdd, SregSub, SregMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE SregMult (SIGNAL result         : OUT std_ulogic_vector;
                        SIGNAL overflow       : OUT std_ulogic;
                        CONSTANT multiplicand : IN std_ulogic_vector;
                        CONSTANT multiplier   : IN std_ulogic_vector;
                        CONSTANT SrcRegMode   : IN regmode_type := DefaultRegMode 
                      );

--+-----------------------------------------------------------------------------
--|     Function Name  : SregDiv
--|
--|     Overloading    : None
--|
--|     Purpose        : Division of BIT_VECTORS. (Result = dividend / divisor)
--|
--|     Parameters     :
--|                      result     - output BIT_VECTOR,
--|                      remainder  - output BIT_VECTOR,
--|                      ZeroDivide - output BIT,
--|                                   set to '1'  when divide by zero occurred
--|                                          '0'  divide by zero did not occur
--|                      dividend   - input  BIT_VECTOR,
--|                      divisor    - input  BIT_VECTOR,
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input BIT_VECTOR.   Default is TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|                      Temporary result and remainder values are computed with
--|                      same length as the dividend. This computed value is
--|                      extended or truncated to match the widths of 'result'
--|                      and 'remainder'. When truncated, the low order bits are
--|                      returned.
--|
--|                      The remainder has the same sign as the dividend.
--|
--|     Use            :
--|                      SIGNAL x, y, res, rem : BIT_VECTOR ( 15 DOWNTO 0);
--|                      SIGNAL Zflag : BIT;
--|
--|                      SregDiv ( res, rem,Zflag, x, y, TwosComp );
--|
--|     See Also       : SregAdd, SregSub, SregMult, SregDiv
--|-----------------------------------------------------------------------------
    PROCEDURE SregDiv ( SIGNAL result       : OUT BIT_VECTOR;
                        SIGNAL remainder    : OUT BIT_VECTOR;
                        SIGNAL ZeroDivide   : OUT BIT;
                        CONSTANT dividend   :  IN BIT_VECTOR;
                        CONSTANT divisor    :  IN BIT_VECTOR;
                        CONSTANT SrcRegMode    :  IN regmode_type := DefaultRegMode
                      );
    -------------------------------------------------------------------------------
    --     Function Name  : SregDiv
    --
    --     Overloading    : None
    --    
    --     Purpose        : Division of std_logic_vectors.(Result = dividend/divisor)
    --     
    --     Parameters     : 
    --                      result     - output std_logic_vector, 
    --                      remainder  - output std_logic_vector,
    --                      ZeroDivide - output std_ulogic,
    --                                   set to '1' when  divide by zero occurred
    --                                          '0'  divide by zero did not occur  
    --                      dividend   - input  std_logic_vector, 
    --                      divisor    - input  std_logic_vector, 
    --                      SrcRegMode - input  regmode_type, indicating the format 
    --                                   of  the input std_logic_vector.   
    --                                   Default is TwosComp.
    --     
    --     NOTE           : 
    --                      The inputs may be of any length and may be of differing 
    --                      lengths. 
    --
    --                      Temporary result and remainder values are computed with 
    --                      same length as the dividend. This computed value is 
    --                      extended or truncated to match the widths of 'result' 
    --                      and 'remainder'. When truncated, the low order bits are 
    --                      returned.
    --
    --                      The remainder has the same sign as the dividend.
    --     Use            : 
    --                      SIGNAL x, y, res, rem : std_logic_vector ( 15 DOWNTO 0);
    --                      SIGNAL Zflag : std_ulogic;
    --
    --                      SregDiv ( res, rem, Zflag, x, y, TwosComp );
    --     
    --     See Also       : SregAdd, SregSub, SregMult
    -------------------------------------------------------------------------------
    PROCEDURE SregDiv ( SIGNAL result       : OUT std_logic_vector;
                        SIGNAL remainder    : OUT std_logic_vector;
                        SIGNAL ZeroDivide   : OUT std_ulogic;  
                        CONSTANT dividend   :  IN std_logic_vector;
                        CONSTANT divisor    :  IN std_logic_vector;
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      );

    -------------------------------------------------------------------------------
    --     Function Name  : SregDiv
    --
    --     Overloading    : None
    --    
    --     Purpose        : Division of std_ulogic_vectors.(Result = dividend/divisor)
    --     
    --     Parameters     : 
    --                      result     - output std_ulogic_vector, 
    --                      remainder  - output std_ulogic_vector,
    --                      ZeroDivide - output std_ulogic,
    --                                   set to '1' when  divide by zero occurred
    --                                          '0'  divide by zero did not occur  
    --                      dividend   - input  std_ulogic_vector, 
    --                      divisor    - input  std_ulogic_vector, 
    --                      SrcRegMode - input  regmode_type, indicating the format 
    --                                   of  the input std_ulogic_vector.   
    --                                   Default is TwosComp.
    --     
    --     NOTE           : 
    --                      The inputs may be of any length and may be of differing 
    --                      lengths. 
    --
    --                      Temporary result and remainder values are computed with 
    --                      same length as the dividend. This computed value is 
    --                      extended or truncated to match the widths of 'result' 
    --                      and 'remainder'. When truncated, the low order bits are 
    --                      returned.
    --
    --                      The remainder has the same sign as the dividend.
    --     Use            : 
    --                      SIGNAL x, y, res, rem : std_ulogic_vector ( 15 DOWNTO 0);
    --                      SIGNAL Zflag : std_ulogic;
    --
    --                      SregDiv ( res, rem, Zflag, x, y, TwosComp );
    --     
    --     See Also       : SregAdd, SregSub, SregMult, SregMod, SregRem
    -------------------------------------------------------------------------------
    PROCEDURE SregDiv ( SIGNAL result       : OUT std_ulogic_vector;
                        SIGNAL remainder    : OUT std_ulogic_vector;
                        SIGNAL ZeroDivide   : OUT std_ulogic;  
                        CONSTANT dividend   :  IN std_ulogic_vector;
                        CONSTANT divisor    :  IN std_ulogic_vector;
                        CONSTANT SrcRegMode    :  IN regmode_type := DefaultRegMode
                      );

--+-----------------------------------------------------------------------------
--|     Function Name  : SregMod
--| 1.5.17  
--|     Overloading    : None
--| 
--|     Purpose        : Modulus operation of  BIT_VECTORS.
--| 
--|     Parameters     :
--|                      result     - output BIT_VECTOR,
--|                      ZeroDivide - output BIT,
--|                                   set to '1' when  divide by zero occurred
--|                                          '0'  divide by zero did not occur  
--|                      dividend   - input  BIT_VECTOR,
--|                      modulus    - input  BIT_VECTOR,
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input BIT_VECTOR.   Default is TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|                      Temporary quotient and modulus values are computed with
--|                      same length as the dividend. This computed value is
--|                      extended or truncated to match the widths of 'result'
--|                      When truncated, the low order bits are
--|                      returned.
--|
--|                      The mod has the same sign as the modulus operator.
--|
--|     Use            :
--|                      SIGNAL x, y, res: BIT_VECTOR ( 15 DOWNTO 0);
--|                      SIGNAL Zflag : std_ulogic;
--|
--|                      SregMod ( res, Zflag, x, y, TwosComp );
--|
--|     See Also       : SregAdd, SregSub, SregMult, SregDiv
--|-----------------------------------------------------------------------------
    PROCEDURE SregMod  ( SIGNAL result     : OUT BIT_VECTOR;
                        SIGNAL ZeroDivide   : OUT BIT;
                        CONSTANT dividend   : IN BIT_VECTOR;
                        CONSTANT modulus    : IN BIT_VECTOR;
                        CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                      );
    -------------------------------------------------------------------------------
    --     Function Name  : SregMod
    -- 1.5.18  
    --     Overloading    : None
    --
    --     Purpose        : Modulus  operation of std_logic_vectors.
    --
    --     Parameters     :
    --                      result     - output std_logic_vector,
    --                      ZeroDivide - output std_ulogic,
    --                                   set to '1' when  divide by zero occurred
    --                                          '0'  divide by zero did not occur  
    --                      dividend   - input  std_logic_vector,
    --                      modulus    - input  std_logic_vector,
    --                      SrcRegMode - input  regmode_type, indicating the format
    --                                    of the input std_logic_vector.   
    --                                    Default is DefaultRegMode.
    --
    --     NOTE           :
    --                      The inputs may be of any length and may be of differing
    --                      lengths.
    --
    --                      Temporary quotient and modulus values are computed with
    --                      same length as the dividend. This computed value is
    --                      extended or truncated to match the widths of 'result'
    --                      When truncated, the low order bits are
    --                      returned.
    --
    --                      The mod has the same sign as the modulus operator.
    --
    --     Use            :
    --                      SIGNAL x, y, res : std_logic_vector ( 15 DOWNTO 0);
    --                      SIGNAL Zflag : std_ulogic;
    --
    --                      SregMod ( res, Zflag, x, y, TwosComp );
    --
    --     See Also       : SregAdd, SregSub, SregMult, SregDiv, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    PROCEDURE SregMod  (SIGNAL result       : OUT std_logic_vector;
                        SIGNAL ZeroDivide   : OUT std_ulogic;  
                        CONSTANT dividend   :  IN std_logic_vector;
                        CONSTANT modulus    :  IN std_logic_vector;
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      );
    -------------------------------------------------------------------------------
    --     Function Name  : SregMod
    --   
    --     Overloading    : None
    --
    --     Purpose        : Modulus  operation of std_ulogic_vectors.
    --
    --     Parameters     :
    --                      result     - output std_ulogic_vector,
    --                      ZeroDivide - output std_ulogic,
    --                                   set to '1' when  divide by zero occurred
    --                                          '0'  divide by zero did not occur  
    --                      dividend   - input  std_ulogic_vector,
    --                      modulus    - input  std_ulogic_vector,
    --                      SrcRegMode - input  regmode_type, indicating the format
    --                                    of the input std_ulogic_vector.   
    --                                    Default is DefaultRegMode.
    --
    --     NOTE           :
    --                      The inputs may be of any length and may be of differing
    --                      lengths.
    --
    --                      Temporary quotient and modulus values are computed with
    --                      same length as the dividend. This computed value is
    --                      extended or truncated to match the widths of 'result'
    --                      When truncated, the low order bits are
    --                      returned.
    --
    --                      The mod has the same sign as the modulus operator.
    --
    --     Use            :
    --                      SIGNAL x, y, res : std_ulogic_vector ( 15 DOWNTO 0);
    --                      SIGNAL Zflag : std_ulogic;
    --
    --                      SregMod ( res, Zflag, x, y, TwosComp );
    --
    --     See Also       : SregAdd, SregSub, SregMult, SregDiv, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
    PROCEDURE SregMod  ( SIGNAL result     : OUT std_ulogic_vector;
                        SIGNAL ZeroDivide   : OUT std_ulogic;  
                        CONSTANT dividend   :  IN std_ulogic_vector;
                        CONSTANT modulus    :  IN std_ulogic_vector;
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      );
--+-----------------------------------------------------------------------------
--|     Function Name  : SregRem
--| 1.5.25
--|     Overloading    : None
--|
--|     Purpose        : Remainder operation of  BIT_VECTORS.
--|
--|     Parameters     :
--|                      result     - output BIT_VECTOR,
--|                      ZeroDivide - output BIT
--|                                   set to '1' when  divide by zero occurred
--|                                          '0'  divide by zero did not occur  
--|                      dividend   - input  BIT_VECTOR,
--|                      divisor    - input  BIT_VECTOR,
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input BIT_VECTOR.   Default is TwosComp.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|                      Temporary quotient and remainder values are computed with
--|                      same length as the dividend. This computed value is
--|                      extended or truncated to match the widths of 'result'
--|                      When truncated, the low order bits are
--|                      returned.
--|
--|                      The remainder has the same sign as the dividend.
--|
--|     Use            :
--|                      SIGNAL x, y, res : BIT_VECTOR ( 15 DOWNTO 0);
--|                      SIGNAL Zflag : BIT;
--|
--|                      RegRem ( res, Zflag, x, y, TwosComp );
--|
--|     See Also       : SregAdd, SregSub, SregMult, SregDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE SregRem ( SIGNAL result       : OUT BIT_VECTOR;
                        SIGNAL ZeroDivide   : OUT BIT;
                        CONSTANT dividend   :  IN BIT_VECTOR;
                        CONSTANT divisor    :  IN BIT_VECTOR;
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      );
    -------------------------------------------------------------------------------
    --     Function Name  : SregRem
    -- 1.5.26
    --     Overloading    : None
    --
    --     Purpose        :Remainder operation of std_logic_vectorS. 
    --
    --     Parameters     :
    --                      result     - output std_logic_vector,
    --                      ZeroDivide - output std_ulogic,
    --                                   set to '1' when  divide by zero occurred
    --                                          '0'  divide by zero did not occur  
    --                      dividend   - input  std_logic_vector,
    --                      divisor    - input  std_logic_vector,
    --                      SrcRegMode - input  regmode_type, indicating the format
    --                                    of the input std_logic_vector.   
    --                                     Default is StdRegMode.
    --
    --     NOTE           :
    --                      The inputs may be of any length and may be of differing
    --                      lengths.
    --
    --                      Temporary quotient and remainder values are computed with
    --                      same length as the dividend. This computed value is
    --                      extended or truncated to match the widths of 'result'
    --                      When truncated, the low order bits are
    --                      returned.
    --                      The remainder has the same sign as the dividend.
    --
    --
    --     Use            :
    --                      SIGNAL x, y, res, ovf : std_logic_vector ( 15 DOWNTO 0);
    --                      SIGNAL Zflag : std_ulogic;
    --
    --                      SregRem ( res, Zflag, x, y, TwosComp );
    --
    --     See Also       : SregAdd, SregSub, SregMult, SregDiv, RegInc,  RegNegate
    -------------------------------------------------------------------------------
    PROCEDURE SregRem ( SIGNAL result       : OUT std_logic_vector;
                        SIGNAL ZeroDivide   : OUT std_ulogic;  
                        CONSTANT dividend   :  IN std_logic_vector;
                        CONSTANT divisor    :  IN std_logic_vector;
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      );
    -------------------------------------------------------------------------------
    --     Function Name  : SregRem
    -- 
    --     Overloading    : None
    --
    --     Purpose        :Remainder operation of std_ulogic_vectorS. 
    --
    --     Parameters     :
    --                      result     - output std_ulogic_vector,
    --                      ZeroDivide - output std_ulogic,
    --                                   set to '1' when  divide by zero occurred
    --                                          '0'  divide by zero did not occur  
    --                      dividend   - input  std_ulogic_vector,
    --                      divisor    - input  std_ulogic_vector,
    --                      SrcRegMode - input  regmode_type, indicating the format
    --                                    of the input std_ulogic_vector.   
    --                                     Default is StdRegMode.
    --
    --     NOTE           :
    --                      The inputs may be of any length and may be of differing
    --                      lengths.
    --
    --                      Temporary quotient and remainder values are computed with
    --                      same length as the dividend. This computed value is
    --                      extended or truncated to match the widths of 'result'
    --                      When truncated, the low order bits are
    --                      returned.
    --
    --                      The remainder has the same sign as the dividend.
    --
    --
    --     Use            :
    --                      SIGNAL x, y, res, ovf : std_ulogic_vector ( 15 DOWNTO 0);
    --                      SIGNAL Zflag : std_ulogic;
    --
    --                      RegRem ( res, Zflag, x, y, TwosComp );
    --
    --     See Also       : SregAdd, SregSub, SregMult, SregDiv, RegInc,  RegNegate
    -------------------------------------------------------------------------------
    PROCEDURE SregRem ( SIGNAL result       : OUT std_ulogic_vector;
                        SIGNAL ZeroDivide   : OUT std_ulogic;  
                        CONSTANT dividend   :  IN std_ulogic_vector;
                        CONSTANT divisor    :  IN std_ulogic_vector;
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      );
--+-----------------------------------------------------------------------------
--|     Function Name  : SregExp
--| 1.6.1 
--|     Overloading    : None
--|
--|     Purpose        : Exponentiation of BIT_VECTORS.
--|
--|     Parameters     :
--|                      result     - output BIT_VECTOR, 
--|                      overflow   - output BIT, overflow condition
--|                      base       - input BIT_VECTOR,
--|                      exponent   -  input BIT_VECTOR,
--|                      SrcRegMode - input  regmode_type, indicating the format
--|                                   of the input BIT_VECTOR.  
--|                                    Default is DefaultRegMode.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|                      This computed value is extended or truncated to match
--|                      the width of 'result'. If truncated, the low order bits
--|                      are returned.
--|
--|     Limitations:     This procedure converts the exponent to integer and
--|                      uses repeated multiplications to calculate exponentiation.
--|                      Therefore, exponet cannot be large the maximum integer 
--|                      value of the system. 
--|
--|     Use            :
--|                      SIGNAL x, y, expo : BIT_VECTOR ( 15 DOWNTO 0);
--|                      SIGNAL ovfl : BIT;
--|
--|                      SregExp ( expo, ovfl, x, y, TwosComp );
--|
--|     See Also       : SregMult, SregDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE SregExp (SIGNAL result       : OUT BIT_VECTOR;
                       SIGNAL overflow     : OUT BIT;
                       CONSTANT base       : IN BIT_VECTOR;
                       CONSTANT exponent   : IN BIT_VECTOR;
                       CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                     );
--+-----------------------------------------------------------------------------
--|     Function Name  : SregExp
--| 1.6.2
--|     Overloading    : None
--|
--|     Purpose        : Exponentiation of logic vectors.
--|
--|     Parameters     :
--|                      result     - output std_logic_vector,
--|                      overflow   - output std_ulogic, overflow condition
--|                      base       - input std_logic_vector,
--|                      exponent   -  input std_logic_vector,
--|                      SrcRegMode - input  regmode_type, indicating the format 
--|                                of the input std_logic_vector.  
--|                                Default is DefaultRegMode.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|                      This computed value is extended or truncated to match
--|                      the width of 'result'. If truncated, the low order bits
--|                      are returned.
--|
--|     Limitations:     This procedure converts the exponent to integer and
--|                      uses repeated multiplications to calculate exponentiation.
--|                      Therefore, exponet cannot be large the maximum integer 
--|                      value of the system. 
--|
--|     Use            :
--|                      SIGNAL x, y, expo : std_logic_vector ( 15 DOWNTO 0);
--|                      SIGNAL ovfl : std_ulogic;
--|
--|                      SregExp ( expo, ovfl, x, y, TwosComp );
--|
--|     See Also       : SregMult, SregDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE SregExp ( SIGNAL result     : OUT std_logic_vector;
                       SIGNAL overflow   : OUT std_ulogic;
                       CONSTANT base       : IN std_logic_vector;
                       CONSTANT exponent   : IN std_logic_vector;
                       CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                     );
--+-----------------------------------------------------------------------------
--|     Function Name  : SregExp
--| 
--|     Overloading    : None
--|
--|     Purpose        : Exponentiation of logic vectors.
--|
--|     Parameters     :
--|                      result     - output std_ulogic_vector,
--|                      overflow   - output std_ulogic, overflow condition
--|                      base       - input std_ulogic_vector,
--|                      exponent   -  input std_ulogic_vector,
--|                      SrcRegMode - input  regmode_type, indicating the format 
--|                                of the input std_ulogic_vector.  
--|                                Default is DefaultRegMode.
--|
--|     NOTE           :
--|                      The inputs may be of any length and may be of differing
--|                      lengths.
--|
--|                      This computed value is extended or truncated to match
--|                      the width of 'result'. If truncated, the low order bits
--|                      are returned.
--|
--|     Limitations:     This procedure converts the exponent to integer and
--|                      uses repeated multiplications to calculate exponentiation.
--|                      Therefore, exponet cannot be large the maximum integer 
--|                      value of the system. 
--|
--|     Use            :
--|                      SIGNAL x, y, expo : std_ulogic_vector ( 15 DOWNTO 0);
--|                      SIGNAL ovfl : std_ulogic;
--|
--|                      SregExp ( expo, ovfl, x, y, TwosComp );
--|
--|     See Also       : SregMod, SregRem,  SregMult, SregDiv
--|-----------------------------------------------------------------------------
    PROCEDURE SregExp ( SIGNAL result     : OUT std_ulogic_vector;
                       SIGNAL overflow   : OUT std_ulogic;
                       CONSTANT base       : IN std_ulogic_vector;
                       CONSTANT exponent   : IN std_ulogic_vector;
                       CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                     );
--+-----------------------------------------------------------------------------
--|     Function Name  : SregShift
--| 
--|     Overloading    : None
--|
--|     Purpose        : Bidirectional logical shift operator for   BIT_VECTORS.
--|
--|     Parameters     :
--|                      SrcReg      - input  BIT_VECTOR, vector to be shifted
--|                      DstReg      - inout, BIT_VECTOR, shifted result
--|                      ShiftO      - inout, BIT, holds the last bit shifted out 
--|                                          of register
--|                      direction   - input, BIT
--|                                     '0'  means right shift
--|                                     '1'  means left shift, default is left shift
--|                      FillVal     - input, BIT, value to fill register with. 
--|                                          default is '0'
--|                      Nbits       - input , NATURAL, number of positions to shift
--|                                          default is 1.
--|
--|     Result         : Shifted bit_vector
--|
--|     Use            :
--|                      SIGNAL acc   : BIT_VECTOR ( 15 DOWNTO 0);
--|                      SIGNAL carry : BIT;
--|
--|                      SregShift ( acc, acc, carry, '1', '0',3 );
--|
--|-----------------------------------------------------------------------------
   PROCEDURE SregShift ( CONSTANT SrcReg    : IN BIT_VECTOR;
                         SIGNAL DstReg      : INOUT BIT_VECTOR;
                         SIGNAL ShiftO      : INOUT BIT; 
                         CONSTANT direction : IN BIT     := '1';
                         CONSTANT FillVal   : IN BIT     := '0';
                         CONSTANT Nbits     : IN Natural := 1
                      ); 
--+-----------------------------------------------------------------------------
--|     Function Name  : SregShift
--| 
--|     Overloading    : None
--|
--|     Purpose        : Bidirectional logical shift operator for logic vector.
--|
--|     Parameters     :
--|                      SrcReg      - input  std_logic_vector, vector to be shifted
--|                      DstReg      - inout std_logic_vector, shifted result
--|                      ShiftO      - inout, std_ulogic, holds the 
--|                                            last bit shifted out 
--|                                          of register
--|                      direction   - input, Std_ulogic
--|                                         '0'  means right shift
--|                                         '1' | 'X'  means left shift, 
--|                                          default is left shift
--|                      FillVal     - input, Std_ulogic, value to fill register with. 
--|                                          default is '0'
--|                      Nbits       - input , NATURAL, number of positions to shift
--|                                          default is 1.
--|
--|     Result         : Shifted std_logic_vector
--|
--|     Use            :
--|                      SIGNAL acc   : std_logic_vector ( 15 DOWNTO 0);
--|                      SIGNAL carry : std_ulogic;
--|
--|                      SregShift ( acc, acc, carry, '1', '0',3 );
--|
--|-----------------------------------------------------------------------------
   PROCEDURE SregShift  ( CONSTANT SrcReg    : IN std_logic_vector;
                         SIGNAL DstReg       : INOUT std_logic_vector;
                         SIGNAL ShiftO       : INOUT std_ulogic; 
                         CONSTANT direction  : IN std_ulogic   := '1';
                         CONSTANT FillVal    : IN std_ulogic   := '0';
                         CONSTANT Nbits      : IN Natural      := 1
                      ); 
--+-----------------------------------------------------------------------------
--|     Function Name  : SregShift
--| 
--|     Overloading    : None
--|
--|     Purpose        : Bidirectional logical shift operator for ulogic vector.
--|
--|     Parameters     :
--|                      SrcReg      - input  std_ulogic_vector, vector to be shifted
--|                      DstReg      - inout, std_ulogic_vector, shifted result
--|                      ShiftO      - inout, std_ulogic, holds the last 
--|                                            bit shifted out 
--|                                          of register
--|                      direction   - input, Std_ulogic
--|                                         '0'  means right shift
--|                                         '1' | 'X'  means left shift, 
--|                                          default is left shift
--|                      FillVal     - input, Std_ulogic, value to fill register with. 
--|                                          default is '0'
--|                      Nbits       - input , NATURAL, number of positions to shift
--|                                          default is 1.
--|
--|     Result         : Shifted std_ulogic_vector
--|
--|     Use            :
--|                      SIGNAL acc   : std_ulogic_vector ( 15 DOWNTO 0);
--|                      SIGNAL carry : std_ulogic;
--|
--|                      SregShift ( acc, acc, carry, '1', '0',3 );
--|
--|-----------------------------------------------------------------------------
   PROCEDURE SregShift  ( CONSTANT SrcReg    : IN std_ulogic_vector;
                         SIGNAL DstReg	     : INOUT std_ulogic_vector;
                         SIGNAL ShiftO	     : INOUT std_ulogic; 
                         CONSTANT direction  : IN std_ulogic   := '1';
                         CONSTANT FillVal    : IN std_ulogic   := '0';
                         CONSTANT Nbits      : IN Natural      := 1
                      ); 

END std_regpak;          







