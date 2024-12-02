-- ----------------------------------------------------------------------------
--
--  Copyright (c) Mentor Graphics Corporation, 1982-1996, All Rights Reserved.
--                       UNPUBLISHED, LICENSED SOFTWARE.
--            CONFIDENTIAL AND PROPRIETARY INFORMATION WHICH IS THE
--          PROPERTY OF MENTOR GRAPHICS CORPORATION OR ITS LICENSORS.
--
--
-- PackageName :  STD_Regpak  (stand alone)
-- Title       :  Standard Register Package
-- Purpose     :  This packages defines a set of standard declarations
--             :  and subprograms used to model digital components at
--             :  the RTL level.
--             :
-- Comments    : 
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
--                                            | RegMod, RegRem procedures
--     v1.110    | M.K. Dhodhi   |  03/06/92  | production release
--     v1.200    | M.K. Dhodhi   |  04/21/92  | stand alone version 
--     v1.210    | M.K. Dhodhi   |  07/10/92  | fixing Mem-alloc bug for synopsys
--     v1.300    | M.K. Dhodhi   |  08/03/92  | production release
--     v1.400    | M.K. Dhodhi   |  11/06/92  | Fixed compare. No need to 
--                               |            | complement MSB for Unsigned.
--     v1.500    | M.K. Dhodhi   |  11/17/92  | Production release
--     v1.600    | M.K. Dhodhi   |  02/11/93  | fixed To_StdUlogicVector,
--                                            | To_StdLogicVector, To_BitVector
--     v1.610    | W.R. Migatz   |  04/14/93  | production release - no change from v1.60
--     v1.700 B  | W.R. Migatz   |  05/3/93   | Beta release - no change from v1.60
--     v1.700    | W.R. Migatz   |  05/25/93  | production release - no changes
--     v1.800    | W.R. Migatz   |  07/27/93  | mentor support and bug fix to compare function 
--                                            | to handle 2 zeros and to add don't cares into
--                                            | RegEqual, RegNotEqual, =, and /=
--     v2.000    | W.R. Migatz   |  07/21/94  | Fixed bug in To_Integer (didn't work with 'L's 
--                                            | or 'H's).  Added mixed (slv, sul), (sulv, sul), 
--                                            | and (bv, bit) operators to the overloaded "+" 
--                                            | and "-" operators.  Replaced RegShift with new
--                                            | RegShift. - production release
--     v2.100    | W.R. Migatz   |  01/10/96  | Production release
--                                            | Initialization banner removed
--     v2.2      | B. Caslis     |  07/25/96  | Updated for Mentor Graphics Release
-- -----------------------------------------------------------------------------
 PACKAGE BODY std_regpak IS

 -- ************************************************************************
 -- Display Banner
 -- ************************************************************************

    FUNCTION DisplayBanner return BOOLEAN is

    BEGIN
       ASSERT FALSE
           report LF &
		  "--  Initializing Std_Developerskit (Std_Regpak package v2.10)" & LF &
		  "--  Copyright by Mentor Graphics Corporation" & LF &
		  "--  [Please ignore any warnings associated with this banner.]"
           severity NOTE;
       return TRUE;
    END;

    --CONSTANT StdRegpakBanner : BOOLEAN := DisplayBanner;
    CONSTANT StdRegpakBanner : BOOLEAN := TRUE;

     SUBTYPE INT8 is INTEGER RANGE 0 to 7;        -- used in  S_machine
     CONSTANT IntegerBitLength : INTEGER := 32;   -- Implementation Length of Integers;
   -- ----------------------------------------------------------------------------
   --      USER:
   --      Importants NOTE:
   --
   --            1) Default register mode (DefaultRegMode) is assumed
   --               Two's Complement. If you need to perform an operation in any
   --               other mode (Unsigned, One's Complement or Sign-Magnitude,
   --               you can change it accordingly.
   --        
   --            2) WarningsOn is set to TRUE. It means all the warning assertion
   --               will be printed. If the user does not want the warnings to
   --               to be displayed, then set the WarnigsOn flag to false.  
   --
   --            3) DefaultSregDelay is set to 0 ns . It means all the signal 
   --               assignments in the procedures SregAdd, SregSub, SregMult, SregDiv,
   --               SregMod, SregRem, SregExp, SregShift will take place in 0 ns
   --               delay. The user can change this default to any desired value.
   -- --------------------------------------------------------------------------- 
     CONSTANT DefaultRegMode   : regmode_type := TwosComp;
     CONSTANT WarningsOn       : BOOLEAN      := TRUE;    
     CONSTANT DefaultSregDelay : TIME         := 0 ns; 
    
     TYPE X01_map2  IS ARRAY(std_ulogic, std_ulogic ) OF X01;
     TYPE map2_01   IS ARRAY(BIT, BIT) OF BIT;

     CONSTANT tbl_lt : X01_map2 := (
    --      ---------------------------------------------------------
    --      |  U    X    0    1    Z    W    L    H    -        |   |  
    --      ---------------------------------------------------------
            ( 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | U |
            ( 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | X |
            ( 'X', 'X', '0', '1', 'X', 'X', '0', '1', 'X' ), -- | 0 |
            ( 'X', 'X', '0', '0', 'X', 'X', '0', '0', 'X' ), -- | 1 |
            ( 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | Z |
            ( 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | W |
            ( 'X', 'X', '0', '1', 'X', 'X', '0', '1', 'X' ), -- | L |
            ( 'X', 'X', '0', '0', 'X', 'X', '0', '0', 'X' ), -- | H |
            ( 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' )  -- | - |
        );

     CONSTANT tbl_eq : X01_map2 := (
    --      ---------------------------------------------------------
    --      |  U    X    0    1    Z    W    L    H    -        |   |  
    --      ---------------------------------------------------------
            ( 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | U |
            ( 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | X |
            ( 'X', 'X', '1', '0', 'X', 'X', '1', '0', 'X' ), -- | 0 |
            ( 'X', 'X', '0', '1', 'X', 'X', '0', '1', 'X' ), -- | 1 |
            ( 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | Z |
            ( 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | W |
            ( 'X', 'X', '1', '0', 'X', 'X', '1', '0', 'X' ), -- | L |
            ( 'X', 'X', '0', '1', 'X', 'X', '0', '1', 'X' ), -- | H |
            ( 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' )  -- | - |
        );


     CONSTANT tbl_gt : X01_map2 := (
    --      ---------------------------------------------------------
    --      |  U    X    0    1    Z    W    L    H    -        |   |  
    --      ---------------------------------------------------------
            ( 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | U |
            ( 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | X |
            ( 'X', 'X', '0', '0', 'X', 'X', '0', '0', 'X' ), -- | 0 |
            ( 'X', 'X', '1', '0', 'X', 'X', '1', '0', 'X' ), -- | 1 |
            ( 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | Z |
            ( 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ), -- | W |
            ( 'X', 'X', '0', '0', 'X', 'X', '0', '0', 'X' ), -- | L |
            ( 'X', 'X', '1', '0', 'X', 'X', '1', '0', 'X' ), -- | H |
            ( 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' )  -- | - |
        );

     TYPE slv_to_x01d_type IS ARRAY(std_ulogic'LOW to std_ulogic'HIGH) of std_ulogic;

     -- -------------------------------------------------------------------------------------
     --                                           'U'  'X'  '0'  '1'  'Z'  'W'  'L'  'H'  '-'
     -- -------------------------------------------------------------------------------------
     CONSTANT slv_to_x01d : slv_to_x01d_type := ( 'X', 'X', '0', '1', 'X', 'X', '0', '1', '-' );


     -- ------------------------------------------------------------------------------
     -- ------------------------------------------------------------------------------
     --        P L E A S E       N O T E 
     --    Following routines are hidden, they are not visible to the user of
     --    this package but are used internally 
     -- -----------------------------------------------------------------------------
     ---------------------------------------------------------------------------------
     --     Function Name  : MAXIMUM
     -- hidden
     --     Overloading    :
     --
     --     Purpose        : To determine the max of two inetgers
     --
     --     Parameters     : i1    - input  integer
     --                      i2    - input integer
     --
     --     Result        : Integer, max of i1 , i2
     --
     -- ------------------------------------------------------------------------------
     FUNCTION MAXIMUM  ( CONSTANT i1 : IN INTEGER;
			 CONSTANT i2 : IN INTEGER
		       ) RETURN INTEGER IS
     BEGIN
	IF i1 < i2 THEN 
	   RETURN i2; 
	END IF;
	RETURN i1;
     END MAXIMUM;
     ---------------------------------------------------------------------------------
     --     Function Name  : MINIMUM
     -- hidden
     --     Overloading    :
     --
     --     Purpose        : To determine the min of two inetgers
     --
     --     Parameters     : i1    - input  integer
     --                      i2    - input integer
     --
     --     Result        : Integer, min of i1 , i2
     --
     -- ------------------------------------------------------------------------------
     FUNCTION MINIMUM  ( CONSTANT i1 : IN INTEGER;
			 CONSTANT i2 : IN INTEGER
		       ) RETURN INTEGER IS
     BEGIN
	IF i1 > i2 THEN 
	    RETURN i2; 
	END IF;
	RETURN i1;
     END MINIMUM;
     -- ------------------------------------------------------------------------------
     FUNCTION All_Zero   ( CONSTANT bv : IN bit_vector
                 	 ) RETURN boolean IS
	VARIABLE bv_copy : BIT_VECTOR(bv'LENGTH -1 DOWNTO 0) := bv;
	VARIABLE result  : BOOLEAN := TRUE;
     BEGIN
	convt_loop: FOR I in bv'LENGTH - 1 DOWNTO 0 LOOP
		IF (bv_copy(i) /= '0') THEN
			result := FALSE;
			EXIT convt_loop;
		END IF;
 	end LOOP convt_loop;
	return result;
     END All_Zero;
     -- ------------------------------------------------------------------------------
     FUNCTION All_Zero   ( CONSTANT sv : IN std_logic_vector
                 	 ) RETURN boolean IS
	VARIABLE sv_copy : std_logic_vector(sv'LENGTH -1 DOWNTO 0) := sv;
	VARIABLE result  : BOOLEAN := TRUE;
     BEGIN
	convt_loop: FOR I in sv'LENGTH - 1 DOWNTO 0 LOOP
		IF (sv_copy(i) /= '0') THEN
			result := FALSE;
			EXIT convt_loop;
		END IF;
 	end LOOP convt_loop;
	return result;
     END All_Zero;
     -- ------------------------------------------------------------------------------
     FUNCTION All_Zero   ( CONSTANT sv : IN std_ulogic_vector
                 	 ) RETURN boolean IS
	VARIABLE sv_copy : std_ulogic_vector(sv'LENGTH -1 DOWNTO 0) := sv;
	VARIABLE result  : BOOLEAN := TRUE;
     BEGIN
	convt_loop: FOR I in sv'LENGTH - 1 DOWNTO 0 LOOP
		IF (sv_copy(i) /= '0') THEN
			result := FALSE;
			EXIT convt_loop;
		END IF;
 	end LOOP convt_loop;
	return result;
     END All_Zero;
     -- ------------------------------------------------------------------------------
     -- return true if no one ecnountered 
     -- false otherwise
     FUNCTION No_One   ( CONSTANT bv : IN bit_vector
                 	 ) RETURN boolean IS
	VARIABLE bv_copy : bit_vector(bv'LENGTH -1 DOWNTO 0) := bv;
	VARIABLE result  : BOOLEAN := TRUE;
     BEGIN
	convt_loop: FOR I in bv'LENGTH - 1 DOWNTO 0 LOOP
		IF (bv_copy(i) = '1') THEN
			result := FALSE;
			EXIT convt_loop;
		END IF;
 	end LOOP convt_loop;
	return result;
     END No_One;
     -- ------------------------------------------------------------------------------
     -- return true if no one ecnountered 
     -- false otherwise
     FUNCTION No_One   ( CONSTANT sv : IN std_logic_vector
                 	 ) RETURN boolean IS
	VARIABLE sv_copy : std_logic_vector(sv'LENGTH -1 DOWNTO 0) := sv;
	VARIABLE result  : BOOLEAN := TRUE;
     BEGIN
	convt_loop: FOR I in sv'LENGTH - 1 DOWNTO 0 LOOP
		IF (sv_copy(i) = '1') THEN
			result := FALSE;
			EXIT convt_loop;
		END IF;
 	end LOOP convt_loop;
	return result;
     END No_One;
     -- ------------------------------------------------------------------------------
     -- return true if no one ecnountered 
     -- false otherwise
     FUNCTION No_One   ( CONSTANT sv : IN std_ulogic_vector
                 	 ) RETURN boolean IS
	VARIABLE sv_copy : std_ulogic_vector(sv'LENGTH -1 DOWNTO 0) := sv;
	VARIABLE result  : BOOLEAN := TRUE;
     BEGIN
	convt_loop: FOR I in sv'LENGTH - 1 DOWNTO 0 LOOP
		IF (sv_copy(i) = '1') THEN
			result := FALSE;
			EXIT convt_loop;
		END IF;
 	end LOOP convt_loop;
	return result;
     END No_One;
     -- ------------------------------------------------------------------------------
     FUNCTION Propagate_X   ( CONSTANT sv : IN std_logic_vector
                 	    ) RETURN  std_logic_vector IS
	VARIABLE sv_copy : std_logic_vector(sv'LENGTH -1 DOWNTO 0) := sv;
	VARIABLE result  : std_logic_vector(sv'LENGTH - 1 DOWNTO 0);
        VARIABLE index   : integer := 0;   
     BEGIN
	convt_loop: FOR I in 0 TO  sv'LENGTH - 1  LOOP
		    Exit convt_loop WHEN (Is_X(sv(i)));
                    result(i) := sv_copy(i);
                    index := index + 1;
 	end LOOP convt_loop;
        for  i in index to sv'Length - 1 LOOP
        	result(i) := 'X';
        end loop;
	return result;
     END Propagate_X;
     -- ---------------------------------------------------------------------------
     FUNCTION Propagate_X   ( CONSTANT sv : IN std_ulogic_vector
                 	    ) RETURN  std_ulogic_vector IS
	VARIABLE sv_copy : std_ulogic_vector(sv'LENGTH -1 DOWNTO 0) := sv;
	VARIABLE result  : std_ulogic_vector(sv'LENGTH - 1 DOWNTO 0);
        VARIABLE index   : integer := 0;   
     BEGIN
	convt_loop: FOR I in 0 TO  sv'LENGTH - 1  LOOP
		    Exit convt_loop WHEN (Is_X(sv(i)));
                    result(i) := sv_copy(i);
                    index := index + 1;
 	end LOOP convt_loop;
        for  i in index to sv'Length - 1 LOOP
        	result(i) := 'X';
        end loop;
	return result;
     END Propagate_X;
     -------------------------------------------------------------------------------
     --     Function Name  : To_Boolean
     -- hidden
     --     Overloading    : 
     --
     --     Purpose        : Translate an std_ulogic or a BIT into boolean.
     --
     --     Parameters     :  b    - input  std_ulogic  | BIT, value  to be translated.
     --
     --     Result        : Boolean,
     --
     --
     --     Use            :
     --                      VARIABLE  lt : Boolean ;
     --                      VARIABLE  ok : std_ulogic;
     --
     --                        lt := To_Boolean(ok);
     --
     -- ------------------------------------------------------------------------------
     FUNCTION To_Boolean ( b:BIT
		      ) RETURN Boolean IS
     BEGIN
	case b is
	     when '0' => return(FALSE);
	     when '1' => return(TRUE);
	     when others => return(FALSE);
	end case;
     --  That's all

     END To_Boolean;
 -- ----------------------------------------------------------------------------------
     FUNCTION To_Boolean( v : std_ulogic
		     ) RETURN BOOLEAN IS
     BEGIN            
	  case v is
	      when '0' | 'L'   => return (FALSE);
	      when '1' | 'H'   => return (TRUE);
	      when others      => return (FALSE);
	  end case;
     -- That's all

     END To_Boolean;
--+-----------------------------------------------------------------------------
--|     Function Name  : S_Machine 
--| hidden
--|     Overloading    : None
--|
--|     Purpose        : Finite State automaton to recognise a string format.
--|                      format will be broken into field width, precision
--|                      and justification (left or right).
--|
--|     Parameters     : fwidth        -- output, INTEGER, field width
--|                      precision     -- output, INTEGER, precison 
--|                      justify       -- OUTPUT, BIT 
--|                                       '0' right justified,
--|                                       '1' left justified 
--|                      format        -- input  STRING, provides the
--|                                       conversion specifications.
--|
--|     Result         :  
--|
--|     NOTE           :
--|                      This procedure is
--|                      called in the function To_String.  
--|
--|     Use            :
--|                    VARIABLE fmt     : STRING(1 TO format'LENGTH) := format;
--|                    VARIABLE fw      : INTEGER;
--|                    VARIABLE precis  : INTEGER;
--|                    VARIABLE justfy  : BIT; 
--|
--|                    S_Machine(fw, precis, justy, fmt); 
--|
--|-----------------------------------------------------------------------------
   PROCEDURE S_Machine ( VARIABLE fwidth     : OUT INTEGER;
                         VARIABLE precison   : OUT INTEGER;
                         VARIABLE justify    : OUT BIT;
                         CONSTANT format     : IN STRING 
                       ) IS
    VARIABLE state : INT8 := 0;
    VARIABLE fmt   : STRING(1 TO format'LENGTH) := format;
    VARIABLE ch    : CHARACTER;
    VARIABLE index : INTEGER := 1;
    VARIABLE fw    : INTEGER := 0;
    VARIABLE pr    : INTEGER := 0;

   BEGIN
   -- make sure first character is '%' if not error
     ch := fmt(index);
     IF (fmt(index) /= '%') THEN
          ASSERT false
          REPORT " Format Error  --- first character of format " & 
                 " is not '%' as expected." 
          SEVERITY ERROR;
          RETURN;
     END IF;
     justify := '0';  -- default is right justification

     WHILE (state /= 3) LOOP 
        IF (index < format'LENGTH) THEN
           index := index + 1;
           ch := fmt(index);
           CASE state IS
                WHEN 0   =>
                         IF (ch ='-') THEN
                           state := 1;           -- justify
                         ELSIF (ch >= '0'  AND ch <= '9') THEN
                           fw :=  CHARACTER'POS(ch) - CHARACTER'POS('0'); -- to_digit
                           state := 2;            -- digits
                         ELSIF (ch = 's') THEN
                           state := 3;            -- end state
                         ELSIF (ch = '.') THEN
                           state := 4;
                         ELSIF (ch = '%') THEN
                           state := 5;
                         ELSE 	
                           state := 6;    -- error       
                         END IF;

                WHEN 1   =>
                         justify := '1';      -- left justfy
                         IF (ch >= '0' AND ch <= '9') THEN
                           fw :=  CHARACTER'POS(ch) - CHARACTER'POS('0'); -- to_digit
                           state := 2;
                         ELSIF (ch = '.') THEN
                           state := 4;
                         ELSE
                            state := 6;    -- error
                         END IF;

                WHEN 2   =>    -- 
                          IF (ch >= '0' AND ch <= '9') THEN
                            fw := fw * 10 + CHARACTER'POS(ch)
                                          - CHARACTER'POS('0');
                            state := 2;
                          ELSIF (ch = 's') THEN
                            state := 3;
                          ELSIF (ch = '.') THEN
                            state := 4;
                          ELSE
                            state := 6;      -- error
                          END IF;

                WHEN 3   =>     -- s  state 
                        -- s format successfully recognized exit now.
                          EXIT;
 
                WHEN 4   =>   -- . state
                          IF (ch >= '0' AND ch <= '9') THEN
                            pr := CHARACTER'POS(ch) - CHARACTER'POS('0'); -- to_digit
                            state := 7;
                          ELSE
                            state := 6;  -- error
                          END IF; 
                   
                WHEN 5   =>   --  print %  
                          EXIT;

                WHEN 6  =>   -- error state
                         -- print error message
                           ASSERT false
                           REPORT " Format error  --- expected %s format " 
                           SEVERITY ERROR;
                           EXIT;

                WHEN 7  =>
                        -- precision
                          IF (ch >= '0' AND ch <= '9') THEN
                            pr := pr * 10 + CHARACTER'POS(ch)
                                          - CHARACTER'POS('0'); 
                            state := 7; 
                          ELSIF (ch = 's') THEN
                            state := 3;
                          ELSE
                            state := 6;  -- error
                          END IF;
           END CASE;
        ELSE 
	   assert false
	   report " Format Error:   Observed =" & fmt &LF &CR
                & "                 Expected = %s    (detected by S_Machine) "
           severity ERROR;
           exit;
        END IF;    

     END LOOP;

     IF (fw > max_string_len) THEN
           fwidth := max_string_len;
     ELSE
           fwidth := fw;
     END IF;

     precison := pr;
     RETURN;
   END S_Machine;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_String
--| hidden
--|     Overloading    : None
--|
--|     Purpose        : Convert a bit_vector to a String.
--|
--|     Parameters     :
--|                      val     - input,  BIT_VECTOR,
--|
--|     Result         : STRING  representation of a bit_vector.
--|
--|     USE            : 
--|                     VARIABLE str    : STRING(1 TO 16);
--|                     VARIABLE vect   : BIT_VECTOR (7 DOWNTO 0);
--|
--|                          str := TO_String(vect, "%16s"), 
--|
--|-----------------------------------------------------------------------------
   FUNCTION To_String ( CONSTANT val      : IN BIT_VECTOR;
                         CONSTANT format   : IN STRING := "%s"
                       )  RETURN STRING IS
      CONSTANT reslen     : INTEGER := val'LENGTH;
      VARIABLE loc_result : STRING(1 TO reslen);
      VARIABLE bv         : BIT_VECTOR(1 TO reslen) := val;
      VARIABLE fmt        : STRING(1 TO format'LENGTH) := format;
      VARIABLE result     : STRING(1 TO max_string_len);
      VARIABLE fw         : INTEGER;
      VARIABLE precis     : INTEGER;
      VARIABLE justfy     : BIT;
      VARIABLE index      : INTEGER;

   BEGIN
     -- call procedure SOX_Machine to split the format string into
     -- field width, precision, and justification(left or right), and 
     -- string_type ( binary, octal or hex)
        S_Machine(fw, precis, justfy, fmt);
	-- convert Bit_Vector to string without taking care of format 
        FOR i IN reslen DOWNTO 1 LOOP
		IF ( bv(i) = '1') THEN 
	         	 loc_result(i) := '1';
                 ELSE                   -- bv(i) = '0' 
                         loc_result(i) := '0';
                 END IF;
        END LOOP;
        -- set the field width and precison propoerly
        IF ((precis = 0) OR (precis > reslen)) THEN
        	precis := reslen;
        END IF;

        IF (fw < val'LENGTH) THEN
	       	fw := val'LENGTH;
        END IF;
        IF (precis >= fw) THEN
		return(loc_result(1 TO precis));
        ELSE
                result(precis+1 TO fw) := (OTHERS => ' ');
        END IF;

        -- Now according to justification return the result;
        IF (justfy = '1') THEN                    -- left justify
               return (loc_result(1 TO precis) & result(precis+1 TO fw));
        ELSE                                      -- right justify
               return( result(precis+1 TO fw) & loc_result(1 TO precis));
        END IF;

   END To_String;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_String
--| hidden
--|     Overloading    : None
--|
--|     Purpose        : Convert a bit Value to a String.
--|
--|     Parameters     :
--|                      val     - input   bit.
--|                      format  - input  STRING, provides the
--|                        conversion specifications.
--|
--|     Result         : STRING  representation of a bit.
--|
--|
--|     Use            :
--|                      VARIABLE bit_string : String(1 TO 5); 
--|
--|                        bit_string := To_String ( '1', "%1s");
--|-----------------------------------------------------------------------------
    FUNCTION To_String     ( CONSTANT val      : IN BIT;
                             CONSTANT format   : IN STRING := "%s"
                           ) RETURN STRING IS
       VARIABLE fmt     : STRING(1 TO format'LENGTH) := format;
       VARIABLE result  : STRING(1 TO max_string_len);
       VARIABLE fw      : INTEGER;
       VARIABLE precis  : INTEGER;
       VARIABLE justfy  : BIT; 
 
    BEGIN
    --
    -- call procedure S_Machine to split the format string into
    -- field width, precision, and justification(left or right).
    --
       S_Machine(fw, precis, justfy, fmt);
        
       IF (fw < 1) THEN
           fw := 1;
       END IF;
    -- fill result from 1 to fw with blanks
         result(1 TO fw) := (OTHERS => ' ');
 
       CASE val IS
        
          WHEN '1'  => 
                          IF (justfy = '1') THEN     -- left justify
                                result(1)  := '1';
                           ELSE                       -- right justify
                                result (fw) := '1';
                           END if;

          WHEN '0'  =>     IF (justfy = '1') THEN     -- left justify
                                result(1)  := '0';
                           ELSE                       -- right justify
                                result (fw) := '0';
                           END if;
       END CASE;
       RETURN result(1 TO fw);   -- return a slice.
    END To_String;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_String
--| hidden
--|     Overloading    : None
--|  
--|     Purpose        : Convert an std_ulogic to a String.
--|  
--|     Parameters     :
--|                      val    - input   std_ulogic.
--|
--|     Result         : STRING  representation of std_ulogic.
--|
--|     Use            : 
--|                     VARIABLE str_ovf    : STRING(1 TO 4);
--|                     VARIABLE overflow   : std_ulogic;
--|
--|                          str_ovf := TO_String(vect, "%4s"), 
--|-----------------------------------------------------------------------------
    FUNCTION To_String     ( CONSTANT val      : IN std_ulogic;
                             CONSTANT format   : IN STRING := "%s"
                           ) RETURN STRING IS
   
       VARIABLE fmt     : STRING(1 TO format'LENGTH) := format;
       VARIABLE result  : STRING(1 TO max_string_len);
       VARIABLE fw      : INTEGER;
       VARIABLE precis  : INTEGER;
       VARIABLE justify : BIT;
 
    BEGIN
    -- call procedure S_Machine to split the format string into
    -- field width, precision, and justification(left or right).
    --
       S_Machine(fw, precis, justify, fmt);
  
       IF (fw < 1) THEN
          fw := 1;
       END IF;
    -- fill result from 1 to fw with blanks
      result(1 TO fw) := (OTHERS => ' ');
      CASE val IS
          WHEN 'U'      => IF (justify = '1') THEN   -- left justify
                                result(1) := 'U';
                           ELSE                      -- right justify
                                result(fw) := 'U';
                           END IF;

          WHEN 'X'      => IF (justify = '1') THEN   -- left justify
                                result(1) := 'X';
                           ELSE                      -- right justify
                                result(fw) := 'X';
                           END IF;

          WHEN '0'      => IF (justify = '1') THEN   -- left justify
                                result(1) := '0';
                           ELSE                      -- right justify
                                result(fw) := '0';
                           END IF;

          WHEN '1'      => IF (justify = '1') THEN   -- left justify
                                result(1) := '1';
                           ELSE                      -- right justify
                                result(fw) := '1';
                           END IF;

          WHEN 'Z'      => IF (justify = '1') THEN   -- left justify
                                result(1) := 'Z';
                           ELSE                      -- right justify
                                result(fw) := 'Z';
                           END IF;

          WHEN 'W'      => IF (justify = '1') THEN   -- left justify
                                result(1) := 'W';
                           ELSE                      -- right justify
                                result(fw) := 'W';
                           END IF;

          WHEN 'L'      => IF (justify = '1') THEN   -- left justify
                                result(1) := 'L';
                           ELSE                      -- right justify
                                result(fw) := 'L';
                           END IF;

          WHEN 'H'      => IF (justify = '1') THEN   -- left justify
                                result(1) := 'H';
                           ELSE                      -- right justify
                                result(fw) := 'H';
                           END IF;

          WHEN '-'      => IF (justify = '1') THEN   -- left justify
                                result(1) := '-';
                           ELSE                      -- right justify
                                result(fw) := '-';
                           END IF;

          WHEN OTHERS   => -- An unknown std_ulogic value was passed
                           ASSERT FALSE
                           REPORT "To_String - Unknown std_ulogic value"
                           SEVERITY ERROR;
        END CASE;
        RETURN result(1 TO fw);
    END To_String;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_String
--| hidden
--|     Overloading    : None
--|  
--|     Purpose        : Convert an std_logic_vector to a String.
--|  
--|     Parameters     :
--|                      val     - input   std_logic_vector.
--|
--|     Result         : STRING  representation of std_logic_vector.
--|
--|     USE            : 
--|                     VARIABLE str    : STRING(1 TO 16);
--|                     VARIABLE vect   : std_logic_vector (7 DOWNTO 0);
--|
--|                          str := TO_String(vect, "%16s"), 
--|
--|-----------------------------------------------------------------------------
    FUNCTION To_String     ( CONSTANT val      : IN std_logic_vector;
                             CONSTANT format   : IN STRING := "%s"
                           ) RETURN STRING IS
      CONSTANT reglen     : INTEGER := val'LENGTH;
      VARIABLE loc_result : STRING(1 TO reglen);
      VARIABLE slv         : std_logic_vector(1 TO reglen) := val;
      VARIABLE fmt        : STRING(1 TO format'LENGTH) := format;
      VARIABLE result     : STRING(1 TO max_string_len);
      VARIABLE fw         : INTEGER;
      VARIABLE precis     : INTEGER;
      VARIABLE justfy     : BIT;
 
    BEGIN
    -- Convert to string without taking care of the format.
      FOR i IN reglen  DOWNTO 1 LOOP
         CASE slv(i) IS
            WHEN 'U'      => loc_result(i) := 'U';
            WHEN 'X'      => loc_result(i) := 'X';
            WHEN '0'      => loc_result(i) := '0';
            WHEN '1'      => loc_result(i) := '1';
            WHEN 'Z'      => loc_result(i) := 'Z';
            WHEN 'W'      => loc_result(i) := 'W';
            WHEN 'L'      => loc_result(i) := 'L';
            WHEN 'H'      => loc_result(i) := 'H';
            WHEN '-'      => loc_result(i) := '-';
            WHEN OTHERS   => -- An unknown std_logic value was passed
                             ASSERT FALSE
                             REPORT "To_String -- Unknown std_logic_vector value"
                             SEVERITY ERROR;
         END CASE;
      END LOOP;
    -- call procedure S_Machine to split the format string into
    -- field width, precision, and justification(left or right).
    --
      S_Machine(fw, precis, justfy, fmt);
    -- set the field width and precison propoerly
      IF ((precis = 0) OR (precis > reglen)) THEN
      	   precis := reglen;
      END IF;
      IF (fw < val'LENGTH) THEN
           fw := val'LENGTH;
      END IF;
      IF (precis >= fw) THEN
	  return(loc_result(1 TO precis));
      ELSE
          result(precis+1 TO fw) := (OTHERS => ' ');
      END IF;
    -- Now according to justification return the result;
      IF (justfy = '1') THEN                    -- left justify
           return (loc_result(1 TO precis) & result(precis+1 TO fw));
      ELSE                                      -- right justify
           return( result(precis+1 TO fw) & loc_result(1 TO precis));
      END IF;
    END To_String;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_String
--| hidden
--|     Overloading    : None
--|  
--|     Purpose        : Convert an std_ulogic_vector to a String.
--|  
--|     Parameters     :
--|                      val     - input   std_ulogic_vector.
--|
--|     Result         : STRING  representation of std_ulogic_vector.
--|
--|     USE            : 
--|                     VARIABLE str    : STRING(1 TO 16);
--|                     VARIABLE vect   : std_ulogic_vector (7 DOWNTO 0);
--|
--|                          str := TO_String(vect, "%16s"), 
--|
--|-----------------------------------------------------------------------------
    FUNCTION To_String     ( CONSTANT val    : IN std_ulogic_vector;
                             CONSTANT format : IN STRING := "%s"
                           ) RETURN STRING IS
      CONSTANT reglen : INTEGER := val'LENGTH;
      VARIABLE loc_result : STRING(1 TO reglen);
      VARIABLE slv        : std_ulogic_vector(1 TO reglen) := val;
      VARIABLE fmt        : STRING(1 TO format'LENGTH) := format;
      VARIABLE result     : STRING(1 TO max_string_len);
      VARIABLE fw         : INTEGER;
      VARIABLE precis     : INTEGER;
      VARIABLE justfy     : BIT;
 
    BEGIN
    -- Convert to string without taking care of the format.
        FOR i IN reglen  DOWNTO 1 LOOP
          CASE slv(i) IS
            WHEN 'U'      => loc_result(i) := 'U';
            WHEN 'X'      => loc_result(i) := 'X';
            WHEN '0'      => loc_result(i) := '0';
            WHEN '1'      => loc_result(i) := '1';
            WHEN 'Z'      => loc_result(i) := 'Z';
            WHEN 'W'      => loc_result(i) := 'W';
            WHEN 'L'      => loc_result(i) := 'L';
            WHEN 'H'      => loc_result(i) := 'H';
            WHEN '-'      => loc_result(i) := '-';
            WHEN OTHERS   => -- An unknown std_logic value was passed
                             ASSERT FALSE
                             REPORT "To_String -- Unknown std_logic_vector value"
                             SEVERITY ERROR;
          END CASE;
       END LOOP;
     -- call procedure S_Machine to split the format string into
     -- field width, precision, and justification(left or right).
     --
       S_Machine(fw, precis, justfy, fmt);
    -- set the field width and precison propoerly
      IF ((precis = 0) OR (precis > reglen)) THEN
      	   precis := reglen;
      END IF;
      IF (fw < val'LENGTH) THEN
           fw := val'LENGTH;
      END IF;
      IF (precis >= fw) THEN
	  return(loc_result(1 TO precis));
      ELSE
          result(precis+1 TO fw) := (OTHERS => ' ');
      END IF;
    -- Now according to justification return the result;
      IF (justfy = '1') THEN                    -- left justify
           return (loc_result(1 TO precis) & result(precis+1 TO fw));
      ELSE                                      -- right justify
           return( result(precis+1 TO fw) & loc_result(1 TO precis));
      END IF;
    END To_String;

     -------------------------------------------------------------------------------
     --     FUNCTION Name : comp_sign_extend
     --  hidden
     --
     --     Purpose        : to be used with compare.  This func. sign extends numbers
     --                      without doing a To_X01.  
     --
     --     Parameters     : len         - length to
     --                      vect        - vector to be extended
     --                      SrcRegMode  - register mode
     --
     --     Result         : std_logic_vector 
     --
     --     NOTE           : vect must have a non-zero length.
     --                      len must be >= vect'length
     --
     -----------------------------------------------------------------------------

     FUNCTION comp_sign_extend ( CONSTANT len        : IN Integer;
                                 CONSTANT vect       : IN std_logic_vector;
                                 CONSTANT SrcRegMode : regmode_type
                               ) return std_logic_vector is

        VARIABLE vlen : integer :=vect'length;
        VARIABLE alias_vect : std_logic_vector(vlen - 1 downto 0) := vect;
        VARIABLE result : std_logic_vector(len - 1 downto 0);
        VARIABLE sign : std_ulogic := alias_vect(vlen - 1);
        
                               
     BEGIN
        if (vlen < len) then
           result (vlen - 1 downto 0) := vect;
           case SrcRegMode IS
              when TwosComp | OnesComp =>
                 for i in len - 1 downto vlen loop
                    result(i) := sign;
                 end loop;
              when SignMagnitude =>
                 for i in len - 2 downto vlen - 1 loop
                    result(i) := '0';
                 end loop;
                 result(len - 1) := sign;
              when Unsigned =>
                 for i in len - 1 downto vlen loop
                    result(i) := '0';
                 end loop;
              when others =>
                 assert FALSE
                    report "Compare:  Unknown regmode"
                    severity ERROR;
           end case;
           return result;
        end if;
        return vect;       
     END;

     -------------------------------------------------------------------------------
     --     FUNCTION Name : To_X01d
     --  hidden
     --
     --     Purpose        : to be used with compare.  This func. converts a 
     --                      std_logic_vector to 'X', '0', '1', and '-'
     --
     --     Parameters     : vect  - vector to be converted
     --
     --     Result         : std_logic_vector 
     --
     -----------------------------------------------------------------------------

     FUNCTION To_X01d ( CONSTANT vect : IN std_logic_vector ) RETURN std_logic_vector is

        VARIABLE alias_vect : std_logic_vector(1 to vect'length) := vect;
        VARIABLE result : std_logic_vector(1 to vect'length);
        
     BEGIN
        for i in result'RANGE loop
           result(i) := slv_to_x01d(alias_vect(i));
        end loop;
        return result;
     END;
     
    
     -------------------------------------------------------------------------------
     --     Procedure Name : compare
     --  hidden
     --
     --     Overloading    : 
     --
     --     Purpose        : Compute the relations less, equal, greater between two
     --                      std_logic_vectors
     --
     --     Parameters     : lt         - output std_ulogic, 
     --                      eq         - output std_ulogic,
     --                      gt         - output std_ulogic,
     --                      l          - input  std_logic_vector  
     --                      r          - input  std_logic_vector 
     --                      SrcRegMode - input  regmode_type, indicating the format of
     --                                   the std_logic_vector operands (l,r).
     --                                    Default is TwosComp.
     --                      equal_check- true if checking for equality or inequality only
     --                                   (not for >= or <=)
     --
     --     NOTE           : The operands may be of any length, and may be different
     --                      lengths.
     --
     --     Use            :
     --                      VARIABLE a, b : std_logic_vector ( 7 DOWNTO 0 );
     --                      VARIABLE lt, eq, gt : std_ulogic;
     --                      Compare ( lt, eq, gt, l, r, TwosComp );
     --
     --     See Also       : compare, RegLessThan, RegLessThanOrEqual, RegGreaterThan,
     --                      RegGreaterThanOrEqual.
     -----------------------------------------------------------------------------
     PROCEDURE compare      ( VARIABLE lt,eq,gt    : OUT std_ulogic;
			      CONSTANT l           : IN  std_logic_vector;
			      CONSTANT r           : IN  std_logic_vector;
			      CONSTANT SrcRegMode  : IN  regmode_type := DefaultRegMode;
                              CONSTANT equal_check : BOOLEAN := FALSE
			    ) IS
       CONSTANT resltlen : INTEGER := MAXIMUM (l'LENGTH, r'LENGTH);
       VARIABLE vl, vr : std_logic_vector (resltlen - 1 DOWNTO 0);
       VARIABLE indx    : INTEGER;
       VARIABLE alt_ones_comp_zero : std_logic_vector(resltlen - 1 DOWNTO 0) := (others => '1');
       VARIABLE alt_sign_mag_zero : std_logic_vector(resltlen - 1 DOWNTO 0);
       
     BEGIN
         alt_sign_mag_zero := (others => '0');
         alt_sign_mag_zero(resltlen - 1) := '1';
      --
      -- Null range check
        IF ( (l'LENGTH = 0) AND (r'LENGTH = 0) ) THEN   
             ASSERT false 
             REPORT "  --- Both left and right vectors have null range "
             SEVERITY ERROR;
              lt := '0';
              eq := '1';              -- considered equal
              gt := '0';    
             RETURN;

        ELSIF( l'LENGTH = 0) THEN        -- left input is of null range
            ASSERT false
            REPORT " --- left input has null range "
            SEVERITY ERROR;
             lt := '1';            -- left is less than right
             eq := '0';
             gt := '0';
             RETURN;

        ELSIF( r'LENGTH = 0) THEN        -- right  input is of null range
            ASSERT false
            REPORT " --- right input has null range "
            SEVERITY ERROR;
             lt := '0';       
             eq := '0';
             gt := '1';          -- left input is greater than right input
             RETURN;

        ELSE
               -- convert to x01- and 
               -- inputs are not null so sign extend them to the same length
               -- and complement the sign bit if it is not Unsigned Mode.

              vl := comp_sign_extend (resltlen, To_X01d(l), SrcRegMode);
              vr := comp_sign_extend (resltlen, To_X01d(r), SrcRegMode);

              -- check for alternate zeros in onescomp and signmag modes
              -- if they exist then convert them to all zeros
              if ( ((SrcRegMode = OnesComp) and (vl = alt_ones_comp_zero)) or
                   ((SrcRegMode = SignMagnitude) and (vl = alt_sign_mag_zero)) ) then
                 vl := (others => '0');
              end if;
              if ( ((SrcRegMode = OnesComp) and (vr = alt_ones_comp_zero)) or
                   ((SrcRegMode = SignMagnitude) and (vr = alt_sign_mag_zero)) ) then
                 vr := (others => '0');
              end if;

              if  (SrcRegMode /= Unsigned) then
                 if ( vl(resltlen - 1) /= '-' ) then
                      vl(resltlen - 1) := NOT vl(resltlen - 1);
                 end if;
                 if ( vr(resltlen - 1) /= '-' ) then
                      vr(resltlen - 1) := NOT vr(resltlen - 1);
                 end if;
              end if;
        END IF;        

        -- perform comparison in a short circuit fashion
        -- Find the most significant differing bit : If equal use LSB
        if (equal_check) then  
           FOR i IN resltlen - 1 DOWNTO 0 LOOP
              indx := i;
              NEXT WHEN ( (vl(i) = '-') or (vr(i) = '-') );
              EXIT WHEN ( vl(i) /= vr(i) OR vl(i) = 'X' OR vr(i) = 'X' );
           END LOOP;
           -- Compute the relationships based on the value of the differing bit
           --  'X' in a vector will give indeterminate
           lt := tbl_lt ( vl(indx), vr(indx) ); 
           eq := tbl_eq ( vl(indx), vr(indx) );
           gt := tbl_gt ( vl(indx), vr(indx) );
           if ( vl(indx) = '-' or vr(indx) = '-' ) then
              eq := '1';
           end if;
        else
           FOR i IN resltlen - 1 DOWNTO 0 LOOP
              indx := i;
              -- treat don't cares as Xs
              EXIT WHEN ( vl(i) /= vr(i) OR vl(i) = 'X' OR vr(i) = 'X' OR vl(i) = '-' OR vr(i) = '-');
           END LOOP;
           -- Compute the relationships based on the value of the differing bit
           --  'X' in a vector will give indeterminate
           lt := tbl_lt ( vl(indx), vr(indx) ); 
           eq := tbl_eq ( vl(indx), vr(indx) );
           gt := tbl_gt ( vl(indx), vr(indx) );
        end if;

        RETURN;
     END Compare;

     -------------------------------------------------------------------------------
     --     Procedure Name : Compare
     --  hidden
     --
     --     Overloading    : 
     --
     --     Purpose        : Compute the relations less, equal, greater between two
     --                      std_ulogic_vectors
     --
     --     Parameters     : lt         - output std_ulogic, 
     --                      eq         - output std_ulogic,
     --                      gt         - output std_ulogic,
     --                      l          - input  std_ulogic_vector  
     --                      r          - input  std_ulogic_vector 
     --                      SrcRegMode - input  regmode_type, indicating the format of
     --                                   the std_logic_vector operands (l,r).
     --                                    Default is TwosComp.
     --                      equal_check- true if checking for equality or inequality only
     --                                   ( not for >= or <= )
     --
     --     NOTE           : The operands may be of any length, and may be different
     --                      lengths.
     --
     --     Use            :
     --                      VARIABLE a, b : std_ulogic_vector ( 7 DOWNTO 0 );
     --                      VARIABLE lt, eq, gt : std_ulogic;
     --                      Compare ( lt, eq, gt, l, r, TwosComp );
     --
     --     See Also       : compare, RegLessThan, RegLessThanOrEqual, RegGreaterThan,
     --                      RegGreaterThanOrEqual.
     -----------------------------------------------------------------------------
     PROCEDURE compare      ( VARIABLE lt,eq,gt    : OUT std_ulogic;
			      CONSTANT l           : IN  std_ulogic_vector;
			      CONSTANT r           : IN  std_ulogic_vector;
			      CONSTANT SrcRegMode  : IN  regmode_type := DefaultRegMode;
                              CONSTANT equal_check : BOOLEAN := FALSE
			    ) IS
     BEGIN
         compare ( lt => lt,
                   eq => eq,
                   gt => gt,
                   l => To_StdLogicVector(l),
                   r => To_StdLogicVector(r),
                   SrcRegMode => SrcRegMode,
                   equal_check => equal_check
                   );
	 RETURN;
     END compare;

 --+-----------------------------------------------------------------------------
 --|     Procedure Name : compare
 --|  hidden
 --|     Overloading    :
 --|
 --|     Purpose        : Compute the relations less, equal, greater between two
 --|                      BIT_VECTORS.
 --|
 --|     Parameters     : lt         - output bit, 
 --|                      eq         - output bit,
 --|                      gt         - output bit
 --|                      l          - input  BIT_VECTOR 
 --|                      r          - input  BIT_VECTOR 
 --|                      SrcRegMode - input  regmode_type, indicating the format 
 --|                                   of  the BIT_VECTOR operands (l,r).
 --|                                   Default is TwosComp.
 --|                      equal_check- has no effect for bit vectors - kept only for consistency
 --|
 --|     NOTE           : The operands may be of any length, and may be different
 --|                      lengths.
 --|
 --|     Use            :
 --|                      VARIABLE a, b : BIT_VECTOR ( 7 DOWNTO 0 );
 --|                      VARIABLE lt, eq, gt : bit;
 --|                      Compare ( lt, eq, gt, l, r, TwosComp );
 --|
 --|     See Also       : RegLessThan, RegLessThanOrEqual, RegGreaterThan,
 --|                      RegGreaterThanOrEqual.
 --|-----------------------------------------------------------------------------
     PROCEDURE compare      ( VARIABLE lt,eq,gt   : OUT BIT;
			      CONSTANT l          : IN  BIT_VECTOR;
			      CONSTANT r          : IN  BIT_VECTOR;
			      CONSTANT SrcRegMode : IN  regmode_type := DefaultRegMode;
                              CONSTANT equal_check : BOOLEAN := FALSE
			     ) IS

        VARIABLE t_lt, t_eq, t_gt : std_ulogic;

     BEGIN
         compare ( lt =>          t_lt,
                   eq =>          t_eq,
                   gt =>          t_gt,
                   l =>           To_StdLogicVector(l),
                   r =>           To_StdLogicVector(r),
                   SrcRegMode =>  SrcRegMode,
                   equal_check => equal_check
                   );
         lt := To_bit(t_lt);
         eq := To_bit(t_eq);
         gt := To_bit(t_gt);
	 RETURN;
     END compare;

     -------------------------------------------------------------------------------
     --     Function Name : is_zero
     -- hidden
     --     Purpose       : Check for multiple zero vectors
     --     
     --     Parameters    : vector     : IN std_logic_vector
     --                     SrcRegMode : IN RegMode_Type 
     --     
     --     NOTE          :  Checks that the vector is a zero vector for the 
     --                      appropriate RegMode_Type
     --                     
     --                      overloaded for bit_vectors, std_logic_vectors,
     --                      and std_ulogic_vectors
     --
     -------------------------------------------------------------------------------

     FUNCTION is_zero ( CONSTANT vector     : IN std_logic_vector;
                        CONSTANT SrcRegMode : IN RegMode_Type
                      ) RETURN BOOLEAN is

        variable v_copy : std_logic_vector (vector'LENGTH - 1 downto 0) := TO_X01 (vector);
        variable z1 : std_logic_vector (vector'LENGTH - 1 downto 0) := (others => '0');
        variable z2 : std_logic_vector (vector'LENGTH - 1 downto 0);
        
     begin        
        case SrcRegMode is
           when TwosComp      =>
                                  return ( v_copy = z1);

           when OnesComp      =>
                                  z2 := (others => '1');
                                  return ( (v_copy = z1) or (v_copy = z2) );

           when SignMagnitude =>  z2 := (others => '0');
                                  z2(vector'left) := '1';
                                  return ( (v_copy = z1) or (v_copy = z2) );
                                  
           when Unsigned      =>
                                  return ( v_copy = z1);
           
        end case;
     end;

     FUNCTION is_zero ( CONSTANT vector     : IN bit_vector;
                        CONSTANT SrcRegMode : IN RegMode_Type
                      ) RETURN BOOLEAN is

     begin
        return ( is_zero ( TO_StdLogicVector(vector), SrcRegMode) );
     end;
     
     FUNCTION is_zero ( CONSTANT vector     : IN std_ulogic_vector;
                        CONSTANT SrcRegMode : IN RegMode_Type
                      ) RETURN BOOLEAN is

     begin
        return ( is_zero ( TO_StdLogicVector(vector), SrcRegMode) );
     end;
     

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
		   ) RETURN std_logic_vector IS
       CONSTANT reslen    : INTEGER := MAXIMUM (addend'LENGTH, augend'LENGTH);
       VARIABLE result    : std_logic_vector (reslen - 1 DOWNTO 0); 
       VARIABLE carry_out : std_ulogic;
       VARIABLE overflow  : std_ulogic;
     BEGIN
     --
     -- Use the RegAdd procedure with default no carry in and twoscomp notation
	 RegAdd ( result, carry_out, overflow,  addend, augend, '0', DefaultRegMode );
	 RETURN result;
     END;

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
		   ) RETURN std_logic_vector IS
       CONSTANT reslen    : INTEGER := addend'LENGTH;
       VARIABLE result    : std_logic_vector (reslen - 1 DOWNTO 0); 
       VARIABLE carry_out : std_ulogic;
       VARIABLE overflow  : std_ulogic;
       VARIABLE augendSLV : std_logic_vector (reslen - 1 DOWNTO 0);  
     BEGIN
     --  
     -- Convert addend from Integer to std_logic_vector
	 augendSLV := To_StdLogicVector(augend, reslen, DefaultRegMode); 
     -- Use the RegAdd procedure with default no carry in and twoscomp notation
	 RegAdd ( result, carry_out, overflow, addend, augendSLV, '0', DefaultRegMode );
	 RETURN result;
     END;

     -------------------------------------------------------------------------------
     --     Function Name : Overloaded "+" operator
     --  1.3.5
     --     Purpose       : Addition operator for logic vectors.
     --
     --     Parameters    :     result         left       right
     --                       std_logic_vector   Integer   std_logic_vector
     --
     --     NOTE          : The addition operation is performed assuming all
     --                     operands and results are signed Two's complement integers.
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
		   ) RETURN std_logic_vector IS
       CONSTANT reslen    : INTEGER := augend'LENGTH;
       VARIABLE result 	 : std_logic_vector (reslen - 1 DOWNTO 0); 
       VARIABLE carry_out : std_ulogic;
       VARIABLE overflow  : std_ulogic;
       VARIABLE addendSLV : std_logic_vector (reslen - 1 DOWNTO 0);  
     BEGIN
     --  
     -- Convert addend from Integer to std_logic_vector
	 addendSLV := To_StdLogicVector(addend, reslen, DefaultRegMode); 
     -- Use the RegAdd procedure with default no carry in and twoscomp notation
	 RegAdd ( result, carry_out,  overflow, addendSLV, augend, '0', DefaultRegMode );
	 RETURN result;
     END;


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
		   ) RETURN std_logic_vector IS
       CONSTANT reslen    : INTEGER := MAXIMUM (addend'LENGTH, 1);
       VARIABLE result    : std_logic_vector (reslen - 1 DOWNTO 0); 
       VARIABLE carry_out : std_ulogic;
       VARIABLE overflow  : std_ulogic;
       VARIABLE t_augend  : std_logic_vector(reslen - 1 downto 0) := (others => '0');
     BEGIN
     --
     -- Use the RegAdd procedure with default no carry in and twoscomp notation
         t_augend(0) := augend;
	 RegAdd ( result, carry_out, overflow,  addend, t_augend, '0', DefaultRegMode );
	 RETURN result;
     END;

     
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
		   ) RETURN std_logic_vector IS
       CONSTANT reslen    : INTEGER := MAXIMUM (1, augend'LENGTH);
       VARIABLE result    : std_logic_vector (reslen - 1 DOWNTO 0); 
       VARIABLE carry_out : std_ulogic;
       VARIABLE overflow  : std_ulogic;
       VARIABLE t_addend  : std_logic_vector(reslen - 1 downto 0) := (others => '0');
     BEGIN
     --
     -- Use the RegAdd procedure with default no carry in and twoscomp notation
         t_addend(0) := addend;
	 RegAdd ( result, carry_out, overflow,  t_addend, augend, '0', DefaultRegMode );
	 RETURN result;
     END;

     
     -------------------------------------------------------------------------------
     --     Function Name : Overloaded "+" operator
     -- 1.3.3    
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
		   ) RETURN std_ulogic_vector IS
       CONSTANT reslen    : INTEGER := MAXIMUM (addend'LENGTH, augend'LENGTH);
       VARIABLE result    : std_ulogic_vector (reslen - 1 DOWNTO 0); 
       VARIABLE carry_out : std_ulogic;
       VARIABLE overflow  : std_ulogic;
     BEGIN
     --
     -- Use the RegAdd procedure with default no carry in and twoscomp notation
	 RegAdd ( result, carry_out, overflow,  addend, augend, '0', DefaultRegMode );
	 RETURN result;
     END;

     -------------------------------------------------------------------------------
     --     Function Name : Overloaded "+" operator
     -- 1.3.4
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
		   ) RETURN std_ulogic_vector IS
       CONSTANT reslen    : INTEGER := addend'LENGTH;
       VARIABLE result    : std_ulogic_vector (reslen - 1 DOWNTO 0); 
       VARIABLE carry_out : std_ulogic;
       VARIABLE overflow  : std_ulogic;
       VARIABLE augendSLV : std_ulogic_vector (reslen - 1 DOWNTO 0);  
     BEGIN
     --  
     -- Convert addend from Integer to std_logic_vector
	 augendSLV := To_StdULogicVector(augend, reslen, DefaultRegMode); 

     -- Use the RegAdd procedure with default no carry in
	 RegAdd ( result, carry_out, overflow, addend, augendSLV, '0', DefaultRegMode );
	 RETURN result;
     END;

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
		   ) RETURN std_ulogic_vector IS
       CONSTANT reslen    : INTEGER := augend'LENGTH;
       VARIABLE result 	 : std_ulogic_vector (reslen - 1 DOWNTO 0); 
       VARIABLE carry_out : std_ulogic;
       VARIABLE overflow  : std_ulogic;
       VARIABLE addendSLV : std_ulogic_vector (reslen - 1 DOWNTO 0);  
     BEGIN
     --  
     -- Convert addend from Integer to std_ulogic_vector
	 addendSLV := To_StdULogicVector(addend, reslen, DefaultRegMode); 

     -- Use the RegAdd procedure with default no carry in
	 RegAdd ( result, carry_out,  overflow, addendSLV, augend, '0', DefaultRegMode );
	-- if overflow  occurrs assert a warning .
	 RETURN result;
     END;

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
     --                     The length of the result equals the length of the left
     --                     operator.
     --     
     --                     Any overflow condition and carry_out is ignored
     --     
     --     Use           : 
     --                      VARIABLE a, c : std_ulogic_vector ( 7 downto 0 );
     --                      VARIABLE b : std_ulogic;
     --                      c := a + b;
     --
     --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
     -------------------------------------------------------------------------------
     FUNCTION  "+" ( CONSTANT addend       : IN std_ulogic_vector;
		     CONSTANT augend       : IN std_ulogic
		   ) RETURN std_ulogic_vector IS
       CONSTANT reslen    : INTEGER := MAXIMUM (addend'LENGTH, 1);
       VARIABLE result    : std_ulogic_vector (reslen - 1 DOWNTO 0); 
       VARIABLE carry_out : std_ulogic;
       VARIABLE overflow  : std_ulogic;
       VARIABLE t_augend  : std_ulogic_vector(reslen - 1 downto 0) := (others => '0');
     BEGIN
     --
     -- Use the RegAdd procedure with default no carry in and twoscomp notation
         t_augend(0) := augend;
	 RegAdd ( result, carry_out, overflow,  addend, t_augend, '0', DefaultRegMode );
	 RETURN result;
     END;

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
     --                     The length of the result equals the length of the right
     --                     operator.
     --     
     --                     Any overflow condition and carry_out is ignored
     --     
     --     Use           : 
     --                      VARIABLE b, c : std_ulogic_vector ( 7 downto 0 );
     --                      VARIABLE a : std_ulogic;
     --                      c := a + b;
     --
     --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
     -------------------------------------------------------------------------------
     FUNCTION  "+" ( CONSTANT addend       : IN std_ulogic;
		     CONSTANT augend       : IN std_ulogic_vector
		   ) RETURN std_ulogic_vector IS
       CONSTANT reslen    : INTEGER := MAXIMUM (1, augend'LENGTH);
       VARIABLE result    : std_ulogic_vector (reslen - 1 DOWNTO 0); 
       VARIABLE carry_out : std_ulogic;
       VARIABLE overflow  : std_ulogic;
       VARIABLE t_addend  : std_ulogic_vector(reslen - 1 downto 0) := (others => '0');
     BEGIN
     --
     -- Use the RegAdd procedure with default no carry in and twoscomp notation
         t_addend(0) := addend;
	 RegAdd ( result, carry_out, overflow,  t_addend, augend, '0', DefaultRegMode );
	 RETURN result;
     END;

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
		   ) RETURN bit_vector IS
       CONSTANT reslen : INTEGER := MAXIMUM (addend'LENGTH, augend'LENGTH);
       VARIABLE result : bit_vector (reslen - 1  DOWNTO 0);
       VARIABLE carry_out : bit;
       VARIABLE overflow  : bit;
     BEGIN
     --
     -- Use the RegAdd procedure with default no carry in and twoscomp notation
	 RegAdd ( result, carry_out, overflow, addend, augend, '0', DefaultRegMode );
	 RETURN result;
     END;


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
		   ) RETURN bit_vector IS
       CONSTANT reslen    : INTEGER := addend'LENGTH;
       VARIABLE augendBV  :  bit_vector (reslen - 1 DOWNTO 0); 
       VARIABLE result    : bit_vector (reslen - 1  DOWNTO 0);
       VARIABLE carry_out : bit;
       VARIABLE overflow  : bit;
     BEGIN
     --
     -- Convert addend from Integer to bit_vector
	 augendBV := To_BitVector(augend, reslen, DefaultRegMode); 

     -- Use the RegAdd procedure with DefaultRegMode and  no carry in 
	 RegAdd ( result, carry_out, overflow, addend, augendBV, '0', DefaultRegMode );
	 RETURN result;
     END;
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
		   ) RETURN bit_vector IS
       CONSTANT reslen : INTEGER := augend'LENGTH;
       VARIABLE addendBV :  bit_vector (reslen - 1 DOWNTO 0); 
       VARIABLE result : bit_vector (reslen - 1  DOWNTO 0);
       VARIABLE carry_out : bit;
       VARIABLE overflow  : bit;
     BEGIN
     --
     -- Convert addend from Integer to bit_vector
	 addendBV := To_BitVector(addend, reslen, DefaultRegMode); 

     -- Use the RegAdd procedure with default no carry in
	 RegAdd ( result, carry_out,  overflow, addendBV, augend, '0', DefaultRegMode );
	 RETURN result;
     END;

     ---------------------------------------------------------------------------------
     --     Function Name : Overloaded "+" operator
     -- 1.3.6 
     --     Purpose       : Addition operator for bit vectors.
     --
     --     Parameters    :     result         left       right
     --                         bit_vector    bit_vector   bit
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
     --                      VARIABLE b    : bit;
     --                      c := a + b;
     --
     --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
    -------------------------------------------------------------------------------
     FUNCTION  "+" ( CONSTANT addend       : IN bit_vector;
		     CONSTANT augend       : IN bit
		   ) RETURN bit_vector IS
		   
       CONSTANT reslen    : INTEGER := MAXIMUM (addend'LENGTH, 1);
       VARIABLE result    : bit_vector (reslen - 1  DOWNTO 0);
       VARIABLE carry_out : bit;
       VARIABLE overflow  : bit;
       VARIABLE t_augend  : bit_vector(reslen - 1 downto 0) := (others => '0');
       
     BEGIN
     --
     -- Use the RegAdd procedure with default no carry in and twoscomp notation
	 t_augend(0) := augend;
	 RegAdd ( result, carry_out, overflow, addend, t_augend, '0', DefaultRegMode );
	 RETURN result;
     END;


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
		   ) RETURN bit_vector IS
       CONSTANT reslen    : INTEGER := MAXIMUM (1, augend'LENGTH);
       VARIABLE result    : bit_vector (reslen - 1  DOWNTO 0);
       VARIABLE carry_out : bit;
       VARIABLE overflow  : bit;
       VARIABLE t_addend  : bit_vector( reslen - 1 downto 0) := (others => '0');
       
     BEGIN
     --
     -- Use the RegAdd procedure with default no carry in and twoscomp notation
	 t_addend(0) := addend;
	 RegAdd ( result, carry_out, overflow, t_addend, augend, '0', DefaultRegMode );
	 RETURN result;
     END;


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
		   ) RETURN std_logic_vector IS
       CONSTANT reslen     : INTEGER := MAXIMUM (minuend'LENGTH, subtrahend'LENGTH);
       VARIABLE result     : std_logic_vector (reslen - 1 DOWNTO 0); 
       VARIABLE borrow_out : std_ulogic;
       VARIABLE overflow   : std_ulogic;

     BEGIN
     -- Use the RegSub procedure with default no borrow in and twoscomp notation
	RegSub ( result, borrow_out, overflow, minuend, subtrahend, '0', DefaultRegMode );
	RETURN result;
     END;

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
		   ) RETURN std_logic_vector IS
       CONSTANT reslen     : INTEGER := subtrahend'LENGTH;
       VARIABLE result     : std_logic_vector (reslen - 1 DOWNTO 0); 
       VARIABLE borrow_out : std_ulogic;
       VARIABLE overflow   : std_ulogic;
       VARIABLE minuendSLV : std_logic_vector (reslen - 1 DOWNTO 0);

     BEGIN
     --
     -- Convert minuend from Integer to std_logic_vector
	minuendSLV := To_StdLogicVector(minuend, reslen, DefaultRegMode);
     --   
     -- Use the RegSub procedure with default no borrow in and twoscomp notation
       RegSub (result, borrow_out, overflow, minuendSLV, subtrahend, '0', DefaultRegMode);
       RETURN result;
     END;

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
		   ) RETURN std_logic_vector IS
       CONSTANT reslen        : INTEGER := minuend'LENGTH;
       VARIABLE result        : std_logic_vector (reslen - 1 DOWNTO 0); 
       VARIABLE borrow_out    : std_ulogic;
       VARIABLE overflow      : std_ulogic;
       VARIABLE subtrahendSLV : std_logic_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert subtrahend from Integer to std_logic_vector
       subtrahendSLV := To_StdLogicVector(subtrahend, reslen, DefaultRegMode);
     --
     -- Use the RegSub procedure with default no borrow in and twoscomp notation
       RegSub (result, borrow_out,  overflow, minuend, subtrahendSLV, '0', DefaultRegMode);
       RETURN result;
     END;

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
     --                      VARIABLE b    : std_ulogic;
     --                      c := a - b;
     --     
     --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
     -------------------------------------------------------------------------------
     FUNCTION  "-" ( CONSTANT minuend      : IN std_logic_vector;
		     CONSTANT subtrahend   : IN std_ulogic
		   ) RETURN std_logic_vector IS
       CONSTANT reslen     : INTEGER := MAXIMUM (minuend'LENGTH, 1);
       VARIABLE result     : std_logic_vector (reslen - 1 DOWNTO 0); 
       VARIABLE borrow_out : std_ulogic;
       VARIABLE overflow   : std_ulogic;
       VARIABLE t_subtrahend : std_logic_vector(reslen - 1 downto 0) := (others => '0');

     BEGIN
     -- Use the RegSub procedure with default no borrow in and twoscomp notation
        t_subtrahend(0) := subtrahend;
	RegSub ( result, borrow_out, overflow, minuend, t_subtrahend, '0', DefaultRegMode );
	RETURN result;
     END;

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
     --                      VARIABLE a    : std_ulogic;
     --                      c := a - b;
     --     
     --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
     -------------------------------------------------------------------------------
     FUNCTION  "-" ( CONSTANT minuend      : IN std_ulogic;
		     CONSTANT subtrahend   : IN std_logic_vector
		   ) RETURN std_logic_vector IS
       CONSTANT reslen     : INTEGER := MAXIMUM (1, subtrahend'LENGTH);
       VARIABLE result     : std_logic_vector (reslen - 1 DOWNTO 0); 
       VARIABLE borrow_out : std_ulogic;
       VARIABLE overflow   : std_ulogic;
       VARIABLE t_minuend : std_logic_vector(reslen - 1 downto 0) := (others => '0');

     BEGIN
     -- Use the RegSub procedure with default no borrow in and twoscomp notation
        t_minuend(0) := minuend;
	RegSub ( result, borrow_out, overflow, t_minuend, subtrahend, '0', DefaultRegMode );
	RETURN result;
     END;

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
		   ) RETURN std_ulogic_vector IS
       CONSTANT reslen     : INTEGER := MAXIMUM (minuend'LENGTH, subtrahend'LENGTH);
       VARIABLE result     : std_ulogic_vector (reslen - 1 DOWNTO 0); 
       VARIABLE borrow_out : std_ulogic;
       VARIABLE overflow   : std_ulogic;

     BEGIN
     -- Use the RegSub procedure with default no borrow in and twoscomp notation
	RegSub ( result, borrow_out, overflow, minuend, subtrahend, '0', DefaultRegMode );
	RETURN result;
     END;

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
		   ) RETURN std_ulogic_vector IS
       CONSTANT reslen      : INTEGER := subtrahend'LENGTH;
       VARIABLE result      : std_ulogic_vector (reslen - 1 DOWNTO 0); 
       VARIABLE borrow_out  : std_ulogic;
       VARIABLE overflow    : std_ulogic;
       VARIABLE minuendSLV  : std_ulogic_vector (reslen - 1 DOWNTO 0);

     BEGIN
     --
     -- Convert minuend from Integer to std_ulogic_vector
	 minuendSLV := To_StdULogicVector(minuend, reslen, DefaultRegMode);
     --   
     -- Use the RegSub procedure with default no borrow in and twoscomp notation
	 RegSub ( result, borrow_out, overflow, minuendSLV, subtrahend, '0', DefaultRegMode);
	 RETURN result;
     END;

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
		   ) RETURN std_ulogic_vector IS
       CONSTANT reslen        : INTEGER := minuend'LENGTH;
       VARIABLE result        : std_ulogic_vector (reslen - 1 DOWNTO 0); 
       VARIABLE borrow_out    : std_ulogic;
       VARIABLE overflow      : std_ulogic;
       VARIABLE subtrahendSLV : std_ulogic_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert subtrahend from Integer to std_logic_vector
	 subtrahendSLV := To_StdULogicVector(subtrahend, reslen, DefaultRegMode);
     --
     -- Use the RegSub procedure with default no borrow in and twoscomp notation
       RegSub ( result, borrow_out,  overflow, minuend, subtrahendSLV, '0', DefaultRegMode);
	 RETURN result;
     END;

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
		   ) RETURN std_ulogic_vector IS
       CONSTANT reslen     : INTEGER := MAXIMUM (minuend'LENGTH, 1);
       VARIABLE result     : std_ulogic_vector (reslen - 1 DOWNTO 0); 
       VARIABLE borrow_out : std_ulogic;
       VARIABLE overflow   : std_ulogic;
       VARIABLE t_subtrahend : std_ulogic_vector(reslen - 1 downto 0) := (others => '0');

     BEGIN
     -- Use the RegSub procedure with default no borrow in and twoscomp notation
        t_subtrahend(0) := subtrahend;
	RegSub ( result, borrow_out, overflow, minuend, t_subtrahend, '0', DefaultRegMode );
	RETURN result;
     END;

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
		   ) RETURN std_ulogic_vector IS
       CONSTANT reslen     : INTEGER := MAXIMUM (1, subtrahend'LENGTH);
       VARIABLE result     : std_ulogic_vector (reslen - 1 DOWNTO 0); 
       VARIABLE borrow_out : std_ulogic;
       VARIABLE overflow   : std_ulogic;
       VARIABLE t_minuend : std_ulogic_vector(reslen - 1 downto 0) := (others => '0');

     BEGIN
     -- Use the RegSub procedure with default no borrow in and twoscomp notation
        t_minuend(0) := minuend;
	RegSub ( result, borrow_out, overflow, t_minuend, subtrahend, '0', DefaultRegMode );
	RETURN result;
     END;

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
		   ) RETURN bit_vector IS
       CONSTANT reslen     : INTEGER := MAXIMUM (minuend'LENGTH, subtrahend'LENGTH);
       VARIABLE result     : bit_vector (reslen - 1  DOWNTO 0);
       VARIABLE borrow_out : bit;
       VARIABLE overflow   : bit;

     BEGIN
     -- Use the RegSub procedure with default no borrow in and twoscomp notation
	 RegSub ( result, borrow_out, overflow, minuend, subtrahend, '0', DefaultRegMode);
	 RETURN result;
     END;

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
		   ) RETURN bit_vector IS
       CONSTANT reslen       : INTEGER := minuend'LENGTH;
       VARIABLE result       : bit_vector (reslen - 1  DOWNTO 0);
       VARIABLE borrow_out   : bit;
       VARIABLE overflow     : bit;
       VARIABLE subtrahendBV : bit_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert subtrahend from Integer to bit_vector
	 subtrahendBV := To_BitVector(subtrahend, reslen, DefaultRegMode);
     --
     -- Use the RegSub procedure with default no borrow in and twoscomp notation
	 RegSub ( result, borrow_out, overflow, minuend, subtrahendBV, '0', DefaultRegMode);
	 RETURN result;
     END;

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
		   ) RETURN bit_vector IS
       CONSTANT reslen     : INTEGER := subtrahend'LENGTH;
       VARIABLE result     : bit_vector (reslen - 1  DOWNTO 0);
       VARIABLE borrow_out : bit;
       VARIABLE overflow   : bit;
       VARIABLE minuendBV  : bit_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert minuend from Integer to bit_vector
	 minuendBV := To_BitVector(minuend, reslen, DefaultRegMode);
     --
     -- Use the RegSub procedure with default no borrow in and twoscomp notation
	 RegSub ( result, borrow_out, overflow, minuendBV, subtrahend, '0', DefaultRegMode);
	 RETURN result;
     END;

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
     --                      VARIABLE b    : bit;
     --                      c := a - b;
     --     
     --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
     -------------------------------------------------------------------------------
     FUNCTION  "-" ( CONSTANT minuend      : IN bit_vector;
		     CONSTANT subtrahend   : IN bit
		   ) RETURN bit_vector IS
       CONSTANT reslen     : INTEGER := MAXIMUM (minuend'LENGTH, 1);
       VARIABLE result     : bit_vector (reslen - 1 DOWNTO 0); 
       VARIABLE borrow_out : bit;
       VARIABLE overflow   : bit;
       VARIABLE t_subtrahend : bit_vector(reslen - 1 downto 0) := (others => '0');

     BEGIN
     -- Use the RegSub procedure with default no borrow in and twoscomp notation
        t_subtrahend(0) := subtrahend;
	RegSub ( result, borrow_out, overflow, minuend, t_subtrahend, '0', DefaultRegMode );
	RETURN result;
     END;

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
     --                      VARIABLE a    : bit;
     --                      c := a - b;
     --     
     --     See Also      : RegAdd, RegSub, RegInc, RegDec, RegNegate
     -------------------------------------------------------------------------------
     FUNCTION  "-" ( CONSTANT minuend      : IN bit;
		     CONSTANT subtrahend   : IN bit_vector
		   ) RETURN bit_vector IS
       CONSTANT reslen     : INTEGER := MAXIMUM (1, subtrahend'LENGTH);
       VARIABLE result     : bit_vector (reslen - 1 DOWNTO 0); 
       VARIABLE borrow_out : bit;
       VARIABLE overflow   : bit;
       VARIABLE t_minuend  : bit_vector(reslen - 1 downto 0) := (others => '0');

     BEGIN
     -- Use the RegSub procedure with default no borrow in and twoscomp notation
        t_minuend(0) := minuend;
	RegSub ( result, borrow_out, overflow, t_minuend, subtrahend, '0', DefaultRegMode );
	RETURN result;
     END;

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
		   ) RETURN bit_vector IS
       CONSTANT reglen : INTEGER := subtrahend'LENGTH;
       VARIABLE reg    : bit_vector (reglen - 1  DOWNTO 0):= subtrahend;
       VARIABLE result : bit_vector (reglen - 1  DOWNTO 0);
     BEGIN
        case DefaultRegMode is
	    when   TwosComp =>  IF ((reg(reglen - 1) /= '0') AND
                                    (No_One(reg(reglen - 2 downto 0)))) THEN
                                      result := reg;
                                      ASSERT false
                                      REPORT "Unary '-'   ---  2's comp bit_vector   (" & TO_String(reg) 
                                       & ")   cannot be converted. Returning the same vector."
                                       SEVERITY Error;   
                                    ELSE
                                     -- Use the RegNegate procedure with default  TwosComp notation
                            	       result := RegNegate (subtrahend,  DefaultRegMode);
                                 END IF;

             when OnesComp | Unsigned | SignMagnitude => 
                                    -- Use the RegNegate procedure with default  
                         	    result := RegNegate (subtrahend,  DefaultRegMode);

             when OTHERS      =>                                Null;
        end case;     
        RETURN result;
     END;

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
		   ) RETURN std_logic_vector IS
       CONSTANT reglen : INTEGER := subtrahend'LENGTH;
       VARIABLE reg    : std_logic_vector(subtrahend'length - 1 DOWNTO 0) := subtrahend;
       VARIABLE result : std_logic_vector (reglen - 1  DOWNTO 0);
     BEGIN
        case DefaultRegMode is
	    when   TwosComp =>  IF ( (reg(reglen - 1) /= '0') AND 
                                     (No_One(reg(reglen - 2 downto 0)))) THEN
                                      ASSERT false
                                      REPORT "Unary '-'   ---  2's comp std_logic_vector   (" & TO_String(reg) 
                                      & ")   cannot be converted. "
                                      SEVERITY Error;   
                                      result:=Propagate_X(reg);
                                ELSE
                                   -- Use the RegNegate procedure with default  TwosComp notation
                        	    result := RegNegate (subtrahend,  DefaultRegMode);
                                END IF;

             when OnesComp | Unsigned | SignMagnitude => 
                                    -- Use the RegNegate procedure with default  
                         	    result := RegNegate (subtrahend,  DefaultRegMode);

             when OTHERS      =>     Null;
        end case;     
        RETURN result;
     END;

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
		   ) RETURN std_ulogic_vector IS
       CONSTANT reglen : INTEGER := subtrahend'LENGTH;
       VARIABLE reg    : std_ulogic_vector(subtrahend'length - 1 DOWNTO 0) := subtrahend;
       VARIABLE result : std_ulogic_vector (reglen - 1  DOWNTO 0);
     BEGIN
        case DefaultRegMode is
	    when   TwosComp =>  IF ( (reg(reglen - 1) /= '0') AND 
                                     (No_One(reg(reglen - 2 downto 0)))) THEN
                                     ASSERT false
                                     REPORT "Unary '-'   ---  2's comp std_logic_vector   (" & TO_String(reg) 
                                      & ")   cannot be converted. "
                                      SEVERITY Error;   
                                     result:=Propagate_X(reg);
                                ELSE
                                   -- Use the RegNegate procedure with default  TwosComp notation
                        	    result := RegNegate (subtrahend,  DefaultRegMode);
                                END IF;

             when OnesComp | Unsigned | SignMagnitude => 
                                    -- Use the RegNegate procedure with default  
                         	    result := RegNegate (subtrahend,  DefaultRegMode);

             when OTHERS      =>     Null;
        end case;     
        RETURN result;
     END;
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
		   ) RETURN std_logic_vector IS
       CONSTANT reslen   : INTEGER := MAXIMUM (multiplicand'LENGTH, multiplier'LENGTH);
       VARIABLE result   : std_logic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE overflow : std_ulogic;
     BEGIN
     --
     -- Use the general multiplication procedure
	 RegMult ( result, overflow, multiplicand, multiplier, DefaultRegMode );
	 RETURN result;
     END;

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
		   ) RETURN std_logic_vector IS
       CONSTANT reslen        :INTEGER := multiplicand'LENGTH; 
       VARIABLE result        : std_logic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE overflow      : std_ulogic;
       VARIABLE multiplierSLV : std_logic_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert multiplier from Integer to std_logic_vector
	 multiplierSLV := To_StdLogicVector(multiplier, reslen, DefaultRegMode);
     --
     -- Use the general multiplication procedure
	 RegMult ( result, overflow, multiplicand, multiplierSLV,DefaultRegMode);
	 RETURN result;
     END;

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
		   ) RETURN std_logic_vector IS
       CONSTANT reslen          :INTEGER := multiplier'LENGTH; 
       VARIABLE result          : std_logic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE overflow        : std_ulogic;
       VARIABLE multiplicandSLV : std_logic_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert multiplicand from Integer to std_logic_vector
	 multiplicandSLV := To_StdLogicVector(multiplicand, reslen, DefaultRegMode);
     --
     -- Use the general multiplication procedure
	 RegMult ( result, overflow, multiplicandSLV, multiplier, DefaultRegMode);
	 RETURN result;
     END;

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
		   ) RETURN std_ulogic_vector IS
       CONSTANT reslen   : INTEGER := MAXIMUM (multiplicand'LENGTH, multiplier'LENGTH);
       VARIABLE result   : std_ulogic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE overflow : std_ulogic;
     BEGIN
     --
     -- Use the general multiplication procedure
	 RegMult ( result, overflow, multiplicand, multiplier, DefaultRegMode );
	 RETURN result;
     END;

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
		   ) RETURN std_ulogic_vector IS
       CONSTANT reslen        :INTEGER := multiplicand'LENGTH; 
       VARIABLE result        : std_ulogic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE overflow      : std_ulogic;
       VARIABLE multiplierSLV : std_ulogic_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert multiplier from Integer to std_ulogic_vector
	 multiplierSLV := To_StdULogicVector(multiplier, reslen, DefaultRegMode);
     --
     -- Use the general multiplication procedure
	 RegMult ( result, overflow, multiplicand, multiplierSLV,DefaultRegMode);
	 RETURN result;
     END;

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
		   ) RETURN std_ulogic_vector IS
       CONSTANT reslen          :INTEGER := multiplier'LENGTH; 
       VARIABLE result          : std_ulogic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE overflow        : std_ulogic;
       VARIABLE multiplicandSLV : std_ulogic_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert multiplicand from Integer to std_ulogic_vector
	 multiplicandSLV := To_StdULogicVector(multiplicand, reslen, DefaultRegMode);
     --
     -- Use the general multiplication procedure
	 RegMult ( result, overflow, multiplicandSLV, multiplier, DefaultRegMode);
	 RETURN result;
     END;

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
		   ) RETURN BIT_VECTOR IS
       CONSTANT reslen   : INTEGER := MAXIMUM (multiplicand'LENGTH, multiplier'LENGTH);
       VARIABLE result   : BIT_VECTOR ( reslen - 1 DOWNTO 0 );
       VARIABLE overflow : BIT;
     BEGIN
     --
     -- Use the general multiplication procedure
	 RegMult ( result, overflow, multiplicand, multiplier, DefaultRegMode );
	 RETURN result;
     END;
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
		   ) RETURN BIT_VECTOR IS
       CONSTANT reslen       : INTEGER := multiplicand'LENGTH;
       VARIABLE result       : BIT_VECTOR ( reslen - 1 DOWNTO 0 );
       VARIABLE overflow     : BIT;
       VARIABLE multiplierBV : BIT_VECTOR (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert multiplier from Integer to BIT_VECTOR
	 multiplierBV := To_BitVector(multiplier, reslen, DefaultRegMode);
     --
     -- Use the general multiplication procedure
	 RegMult ( result, overflow, multiplicand, multiplierBV, DefaultRegMode );
	 RETURN result;
     END;

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
		   ) RETURN BIT_VECTOR IS
       CONSTANT reslen         : INTEGER := multiplier'LENGTH;
       VARIABLE result         : BIT_VECTOR ( reslen - 1 DOWNTO 0 );
       VARIABLE overflow       : BIT;
       VARIABLE multiplicandBV : BIT_VECTOR (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert multiplicand from Integer to BIT_VECTOR
	 multiplicandBV := To_BitVector(multiplicand, reslen, DefaultRegMode);
     --
     -- Use the general multiplication procedure
	 RegMult ( result, overflow, multiplicandBV, multiplier, DefaultRegMode );
	 RETURN result;
     END;

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
     ----------------------------------------------------------------------------------
     FUNCTION  "/" ( CONSTANT dividend     : IN std_logic_vector;
		     CONSTANT divisor      : IN std_logic_vector
		   ) RETURN std_logic_vector IS
       CONSTANT reslen    : INTEGER := MAXIMUM (dividend'LENGTH, divisor'LENGTH);
       VARIABLE result    : std_logic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE remainder : std_logic_vector(reslen - 1 DOWNTO 0);
       VARIABLE zflag     : std_ulogic;
     BEGIN
     -- Use the general division procedure 
	 RegDiv ( result, remainder, zflag, dividend, divisor, DefaultRegMode); 
	 RETURN result; 
     END;

     -------------------------------------------------------------------------------
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
		   ) RETURN std_logic_vector IS
       CONSTANT reslen     : INTEGER := dividend'LENGTH;
       VARIABLE result     : std_logic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE remainder  : std_logic_vector(reslen - 1 DOWNTO 0);
       VARIABLE zflag      : std_ulogic;
       VARIABLE divisorSLV : std_logic_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert divisor from Integer to std_logic_vector
	 divisorSLV := To_StdLogicVector(divisor, reslen, DefaultRegMode);
     --
     -- Use the general division procedure
	 RegDiv ( result, remainder, zflag, dividend, divisorSLV, DefaultRegMode );
	 RETURN result;
     END;

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
		   ) RETURN std_logic_vector IS
       CONSTANT reslen      : INTEGER := divisor'LENGTH;
       VARIABLE result      : std_logic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE remainder   : std_logic_vector(reslen - 1 DOWNTO 0);
       VARIABLE zflag       : std_ulogic;
       VARIABLE dividendSLV : std_logic_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert dividend from Integer to std_logic_vector
	 dividendSLV := To_StdLogicVector(dividend, reslen, DefaultRegMode);
     --
     -- Use the general division procedure
	 RegDiv ( result, remainder,zflag, dividendSLV, divisor, DefaultRegMode );
	 RETURN result;
     END;

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
     ---------------------------------------------------------------------------------
     FUNCTION  "/" ( CONSTANT dividend     : IN std_ulogic_vector;
		     CONSTANT divisor      : IN std_ulogic_vector
		   ) RETURN std_ulogic_vector IS
       CONSTANT reslen    : INTEGER := MAXIMUM (dividend'LENGTH, divisor'LENGTH);
       VARIABLE result    : std_ulogic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE remainder : std_ulogic_vector(reslen - 1 DOWNTO 0);
       VARIABLE zflag     : std_ulogic;
     BEGIN
     -- Use the general division procedure 
	 RegDiv ( result, remainder, zflag, dividend, divisor, DefaultRegMode); 
	 RETURN result; 
     END;

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
		   ) RETURN std_ulogic_vector IS
       CONSTANT reslen     : INTEGER := dividend'LENGTH;
       VARIABLE result     : std_ulogic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE remainder  : std_ulogic_vector(reslen - 1 DOWNTO 0);
       VARIABLE zflag      : std_ulogic;
       VARIABLE divisorSLV : std_ulogic_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert divisor from Integer to std_ulogic_vector
	 divisorSLV := To_StdULogicVector(divisor, reslen, DefaultRegMode);
     --
     -- Use the general division procedure
	 RegDiv ( result, remainder, zflag,dividend, divisorSLV, DefaultRegMode );
	 RETURN result;
     END;

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
		   ) RETURN std_ulogic_vector IS
       CONSTANT reslen      : INTEGER := divisor'LENGTH;
       VARIABLE result      : std_ulogic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE remainder   : std_ulogic_vector(reslen - 1 DOWNTO 0);
       VARIABLE zflag       : std_ulogic;
       VARIABLE dividendSLV : std_ulogic_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert dividend from Integer to std_ulogic_vector
	 dividendSLV := To_StdULogicVector(dividend, reslen, DefaultRegMode);
     --
     -- Use the general division procedure
	 RegDiv ( result, remainder, zflag, dividendSLV, divisor, DefaultRegMode );
	 RETURN result;
     END;

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
		   ) RETURN BIT_VECTOR IS
       CONSTANT reslen    : INTEGER := MAXIMUM (dividend'LENGTH, divisor'LENGTH);
       VARIABLE result    : BIT_VECTOR ( reslen - 1 DOWNTO 0 );
       VARIABLE remainder : BIT_VECTOR(reslen - 1 DOWNTO 0);
       VARIABLE zflag     : BIT;
     BEGIN
     -- Use the general division procedure
	 RegDiv ( result, remainder, zflag, dividend, divisor, DefaultRegMode );
	 RETURN result;
     END;
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
		   ) RETURN BIT_VECTOR IS
       CONSTANT reslen    : INTEGER := dividend'LENGTH;
       VARIABLE result    : BIT_VECTOR ( reslen - 1 DOWNTO 0 );
       VARIABLE remainder : BIT_VECTOR(reslen - 1 DOWNTO 0);
       VARIABLE zflag     : BIT;
       VARIABLE divisorBV : BIT_VECTOR (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert divisor from Integer to bit_vector
	 divisorBV := To_BitVector(divisor, reslen, DefaultRegMode);
     --
     -- Use the general division procedure
	 RegDiv ( result, remainder, zflag,dividend, divisorBV, DefaultRegMode );
	 RETURN result;
     END;
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
		   ) RETURN BIT_VECTOR IS
       CONSTANT reslen     : INTEGER := divisor'LENGTH; 
       VARIABLE result     : BIT_VECTOR(reslen - 1 DOWNTO 0);
       VARIABLE remainder  : BIT_VECTOR(reslen - 1 DOWNTO 0);
       VARIABLE zflag      : BIT;
       VARIABLE dividendBV : BIT_VECTOR (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert dividend from Integer to bit_vector
	 dividendBV := To_BitVector(dividend, reslen, DefaultRegMode);
     --
     -- Use the general divison procedure
	 RegDiv ( result, remainder, zflag, dividendBV, divisor, DefaultRegMode );
	 RETURN result;
     END;

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
     -------------------------------------------------------------------------------
     FUNCTION  "mod" ( CONSTANT dividend     : IN std_logic_vector;
		       CONSTANT modulus      : IN std_logic_vector
		     ) RETURN std_logic_vector IS
       CONSTANT reslen   : INTEGER := MAXIMUM (dividend'LENGTH, modulus'LENGTH);
       VARIABLE result   : std_logic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE zflag    : std_ulogic;
     BEGIN
     -- Use the general modulus procedure
	 RegMod ( result, zflag, dividend, modulus, DefaultRegMode );
	 RETURN result;
     END;

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
		     ) RETURN std_logic_vector IS
       CONSTANT reslen     : INTEGER := dividend'LENGTH;
       VARIABLE result     : std_logic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE zflag      : std_ulogic;
       VARIABLE modulusSLV : std_logic_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert modulus from Integer to std_logic_vector
	 modulusSLV := To_StdLogicVector(modulus, reslen, DefaultRegMode);
     --
     -- Use the general modulus procedure
	 RegMod ( result, zflag, dividend, modulusSLV,DefaultRegMode );
	 RETURN result;
     END;

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
		     ) RETURN std_logic_vector IS
       CONSTANT reslen      : INTEGER := modulus'LENGTH;
       VARIABLE result      : std_logic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE zflag       : std_ulogic;
       VARIABLE dividendSLV : std_logic_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert dividend from Integer to std_logic_vector
	 dividendSLV := To_StdLogicVector(dividend, reslen, DefaultRegMode);
     --
     -- Use the general modulus procedure
	 RegMod ( result, zflag, dividendSLV, modulus, DefaultRegMode );
	 RETURN result;
     END;

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
		     ) RETURN std_ulogic_vector IS
       CONSTANT reslen   : INTEGER := MAXIMUM (dividend'LENGTH, modulus'LENGTH);
       VARIABLE result   : std_ulogic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE zflag    : std_ulogic;
     BEGIN
     -- Use the general modulus procedure
	 RegMod ( result, zflag, dividend, modulus, DefaultRegMode );
	 RETURN result;
     END;

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
		     ) RETURN std_ulogic_vector IS
       CONSTANT reslen     : INTEGER := dividend'LENGTH;
       VARIABLE result     : std_ulogic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE zflag      : std_ulogic;
       VARIABLE modulusSLV : std_ulogic_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert modulus from Integer to std_ulogic_vector
	 modulusSLV := To_StdULogicVector(modulus, reslen, DefaultRegMode);
     --
     -- Use the general modulus procedure
	 RegMod ( result, zflag, dividend, modulusSLV,DefaultRegMode );
	 RETURN result;
     END;

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
		     ) RETURN std_ulogic_vector IS
       CONSTANT reslen      : INTEGER := modulus'LENGTH;
       VARIABLE result      : std_ulogic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE zflag       : std_ulogic;
       VARIABLE dividendSLV : std_ulogic_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert dividend from Integer to std_ulogic_vector
	 dividendSLV := To_StdULogicVector(dividend, reslen, DefaultRegMode);
     --
     -- Use the general modulus procedure
	 RegMod ( result, zflag,dividendSLV, modulus, DefaultRegMode );
	 RETURN result;
     END;

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
     ---------------------------------------------------------------------------------
     FUNCTION  "mod" ( CONSTANT dividend     : IN bit_vector;
		       CONSTANT modulus      : IN bit_vector
		     ) RETURN bit_vector IS
       CONSTANT reslen   : INTEGER := MAXIMUM (dividend'LENGTH, modulus'LENGTH);
       VARIABLE result   : bit_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE zflag    : BIT;
     BEGIN
     -- Use the general modulus procedure
	 RegMod ( result, zflag, dividend, modulus, DefaultRegMode );
	 RETURN result;
     END;

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
		     ) RETURN bit_vector IS
       CONSTANT reslen    : INTEGER := dividend'LENGTH;
       VARIABLE result    : bit_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE zflag     : BIT;
       VARIABLE modulusBV : bit_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert modulus from Integer to bit_vector
	 modulusBV := To_BitVector(modulus, reslen, DefaultRegMode);
     --
     -- Use the general modulus procedure
	 RegMod ( result, zflag, dividend, modulusBV, DefaultRegMode );
	 RETURN result;
     END;

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
		     ) RETURN bit_vector IS
       CONSTANT reslen     : INTEGER := modulus'LENGTH;
       VARIABLE result     : bit_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE zflag      : BIT;
       VARIABLE dividendBV : bit_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert dividend from Integer to bit_vector
	 dividendBV := To_BitVector(dividend, reslen, DefaultRegMode);
     --
     -- Use the general division procedure
	 RegMod ( result, zflag, dividendBV, modulus, DefaultRegMode);
	 RETURN result;
     END;

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
		     ) RETURN std_logic_vector IS
       CONSTANT reslen   : INTEGER := MAXIMUM (dividend'LENGTH, divisor'LENGTH);
       VARIABLE result   : std_logic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE zflag    : std_ulogic;

     BEGIN
     -- Use the general remainder procedure
	 RegRem ( result,zflag,  dividend, divisor, DefaultRegMode );
	 RETURN result;
     END;

     ---------------------------------------------------------------------------------
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
     --------------------------------------------------------------------------------
     FUNCTION  "rem" ( CONSTANT dividend     : IN std_logic_vector;
		       CONSTANT divisor      : IN INTEGER
		     ) RETURN std_logic_vector IS
       CONSTANT reslen     : INTEGER := dividend'LENGTH;
       VARIABLE result     : std_logic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE zflag      : std_ulogic;
       VARIABLE divisorSLV : std_logic_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert divisor from Integer to std_logic_vector
	 divisorSLV := To_StdLogicVector(divisor, reslen, DefaultRegMode);
     --
     -- Use the general remainder procedure
	 RegRem ( result, zflag, dividend, divisorSLV, DefaultRegMode );
	 RETURN result;
     END;

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
		     ) RETURN std_logic_vector IS
       CONSTANT reslen      : INTEGER := divisor'LENGTH;
       VARIABLE result      : std_logic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE zflag       : std_ulogic;
       VARIABLE dividendSLV : std_logic_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert dividend from Integer to std_logic_vector
	 dividendSLV := To_StdLogicVector(dividend, reslen, DefaultRegMode);
     --
     -- Use the general remainder procedure
	 RegRem ( result, zflag, dividendSLV, divisor, DefaultRegMode );
	 RETURN result;
     END;

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
		     ) RETURN std_ulogic_vector IS
       CONSTANT reslen   : INTEGER := MAXIMUM (dividend'LENGTH, divisor'LENGTH);
       VARIABLE result   : std_ulogic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE zflag    : std_ulogic;

     BEGIN
     -- Use the general remainder procedure
	 RegRem ( result, zflag, dividend, divisor, DefaultRegMode );
	 RETURN result;
     END;

     -------------------------------------------------------------------------------
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
     -------------------------------------------------------------------------------
     FUNCTION  "rem" ( CONSTANT dividend     : IN std_ulogic_vector;
		       CONSTANT divisor      : IN INTEGER
		     ) RETURN std_ulogic_vector IS
       CONSTANT reslen     : INTEGER := dividend'LENGTH;
       VARIABLE result     : std_ulogic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE zflag      : std_ulogic;
       VARIABLE divisorSLV : std_ulogic_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert divisor from Integer to std_ulogic_vector
	 divisorSLV := To_StdULogicVector(divisor, reslen, DefaultRegMode);
     --
     -- Use the general remainder procedure
	 RegRem ( result, zflag,  dividend, divisorSLV, DefaultRegMode );
	 RETURN result;
     END;

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
		     ) RETURN std_ulogic_vector IS
       CONSTANT reslen      : INTEGER := divisor'LENGTH;
       VARIABLE result      : std_ulogic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE zflag       : std_ulogic;
       VARIABLE dividendSLV : std_ulogic_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert dividend from Integer to std_ulogic_vector
	 dividendSLV := To_StdULogicVector(dividend, reslen, DefaultRegMode);
     --
     -- Use the general remainder procedure
	 RegRem ( result, zflag, dividendSLV, divisor, DefaultRegMode );
	 RETURN result;
     END;

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
		     ) RETURN BIT_VECTOR IS
       CONSTANT reslen   : INTEGER := MAXIMUM (dividend'LENGTH, divisor'LENGTH);
       VARIABLE result   : BIT_VECTOR ( reslen - 1 DOWNTO 0 );
       VARIABLE zflag    : BIT;
     BEGIN
     -- Use the general remainder procedure
	 RegRem ( result, zflag, dividend, divisor, DefaultRegMode );
	 RETURN result;
     END;

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
		     ) RETURN BIT_VECTOR IS
       CONSTANT reslen    : INTEGER := dividend'LENGTH;
       VARIABLE result    : BIT_VECTOR ( reslen - 1 DOWNTO 0 );
       VARIABLE zflag     : BIT;
       VARIABLE divisorBV : BIT_VECTOR (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert divisor from Integer to bit_vector
	 divisorBV := To_BitVector(divisor, reslen, DefaultRegMode);
     --
     -- Use the general remainder procedure
	 RegRem ( result, zflag, dividend, divisorBV, DefaultRegMode );
	 RETURN result;
     END;

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
		     ) RETURN BIT_VECTOR IS
       CONSTANT reslen     : INTEGER := divisor'LENGTH;
       VARIABLE result     : BIT_VECTOR(reslen - 1 DOWNTO 0);
       VARIABLE zflag      : BIT;
       VARIABLE dividendBV : BIT_VECTOR (reslen - 1 DOWNTO 0);

     BEGIN
     --
     -- Convert dividend from Integer to bit_vector
	 dividendBV := To_BitVector(dividend, reslen, DefaultRegMode);
     --
     -- Use the general remainder procedure
	 RegRem ( result, zflag, dividendBV, divisor, DefaultRegMode );
	 RETURN result;
     END;

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
		    ) RETURN std_logic_vector IS
       CONSTANT reslen   : INTEGER := base'LENGTH;
       VARIABLE result   : std_logic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE overflow : std_ulogic;
     BEGIN
     --
     -- Use the general exponentiation procedure
	 RegExp ( result, overflow, base, exponent, DefaultRegMode );
	 RETURN result;
     END;

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
     --     See Also      : RegMult, RegExp
     --------------------------------------------------------------------------------
     FUNCTION  "**" ( CONSTANT base : IN std_logic_vector;
		      CONSTANT exponent : IN Integer
		    ) RETURN std_logic_vector IS
       CONSTANT reslen      : INTEGER := base'LENGTH;
       VARIABLE result      : std_logic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE overflow    : std_ulogic;
       VARIABLE exponentSLV : std_logic_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert exponent from Integer to std_logic_vector
	 exponentSLV := To_StdLogicVector(exponent, reslen, DefaultRegMode);
     --
     -- Use the general exponentiation procedure
	 RegExp ( result, overflow, base, exponentSLV,DefaultRegMode);
	 RETURN result;
     END;

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
     FUNCTION  "**" ( CONSTANT base     : IN Integer;
		      CONSTANT exponent : IN std_logic_vector
		    ) RETURN std_logic_vector IS
       CONSTANT reslen      : INTEGER := IntegerBitLength;
       VARIABLE result      : std_logic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE overflow    : std_ulogic;
       VARIABLE baseSLV     : std_logic_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert base from Integer to std_logic_vector
	 baseSLV := To_StdLogicVector(base, reslen, DefaultRegMode);
     --
     -- Use the general exponentiation procedure
	 RegExp ( result, overflow, baseSLV, exponent, DefaultRegMode);

	 RETURN result;
     END; 

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
		    ) RETURN std_ulogic_vector IS
       CONSTANT reslen   : INTEGER := base'LENGTH;
       VARIABLE result   : std_ulogic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE overflow : std_ulogic;
     BEGIN
     --
     -- Use the general exponentiation procedure
	 RegExp ( result, overflow, base, exponent, DefaultRegMode );
	 RETURN result;
     END;

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
     FUNCTION  "**" ( CONSTANT base : IN std_ulogic_vector;
		      CONSTANT exponent : IN Integer
		    ) RETURN std_ulogic_vector IS
       CONSTANT reslen      : INTEGER := base'LENGTH;
       VARIABLE result      : std_ulogic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE overflow    : std_ulogic;
       VARIABLE exponentSLV : std_ulogic_vector (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert exponent from Integer to std_ulogic_vector
	 exponentSLV := To_StdULogicVector(exponent, reslen, DefaultRegMode);
     --
     -- Use the general exponentiation procedure
	 RegExp ( result, overflow, base, exponentSLV,DefaultRegMode);
	 RETURN result;
     END;

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
     FUNCTION  "**" ( CONSTANT base     : IN Integer;
		      CONSTANT exponent : IN std_ulogic_vector
		    ) RETURN std_ulogic_vector IS
       CONSTANT reslen       : INTEGER := IntegerBitLength;
       VARIABLE result       : std_ulogic_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE overflow     : std_ulogic;
       VARIABLE baseSLV      : std_ulogic_vector (reslen - 1 DOWNTO 0);

     BEGIN
     --
     -- Convert base from Integer to std_ulogic_vector
	 baseSLV := To_StdULogicVector(base, reslen, DefaultRegMode);
     --
     -- Use the general exponentiation procedure
	 RegExp ( result, overflow, baseSLV, exponent, DefaultRegMode);

	 RETURN result;
     END; 

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
     FUNCTION  "**" ( CONSTANT base     : IN bit_vector;
		      CONSTANT exponent : IN bit_vector
		    ) RETURN bit_vector IS
       CONSTANT reslen   : INTEGER := base'LENGTH;
       VARIABLE result   : bit_vector ( reslen - 1 DOWNTO 0 );
       VARIABLE overflow : bit;
     BEGIN
     --
     -- Use the general exponentiation procedure
	 RegExp ( result, overflow, base, exponent, DefaultRegMode );
	 RETURN result;
     END;

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
		   ) RETURN BIT_VECTOR IS
       CONSTANT reslen     : INTEGER := base'LENGTH;
       VARIABLE result     : BIT_VECTOR ( reslen - 1 DOWNTO 0 );
       VARIABLE overflow   : BIT;
       VARIABLE exponentBV : BIT_VECTOR (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert exponent from Integer to BIT_VECTOR
	 exponentBV := To_BitVector(exponent, reslen, DefaultRegMode);
     --
     -- Use the general exponentiation procedure
	 RegExp ( result, overflow, base, exponentBV, DefaultRegMode );
	 RETURN result;
     END;

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
		   ) RETURN BIT_VECTOR IS
       CONSTANT reslen     : INTEGER := IntegerBitLength;
       VARIABLE result     : BIT_VECTOR ( reslen - 1 DOWNTO 0 );
       VARIABLE overflow   : BIT;
       VARIABLE baseBV     : BIT_VECTOR (reslen - 1 DOWNTO 0);
     BEGIN
     --
     -- Convert base from Integer to BIT_VECTOR
	 baseBV := To_BitVector(base, reslen, DefaultRegMode);
     --
     -- Use the general exponentiatioin procedure
	 RegExp ( result, overflow, baseBV, exponent, DefaultRegMode );
	 RETURN result;
     END;

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
		     ) RETURN std_logic_vector IS
       CONSTANT reslen   : INTEGER := operand'LENGTH;
       VARIABLE result   : std_logic_vector ( reslen - 1 DOWNTO 0 );
     BEGIN
     --
     -- Use the general absolute value  procedure
	 RegAbs ( result, operand, DefaultRegMode );
	 RETURN result;
     END;

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
		     ) RETURN std_ulogic_vector IS
       CONSTANT reslen   : INTEGER := operand'LENGTH;
       VARIABLE result   : std_ulogic_vector ( reslen - 1 DOWNTO 0 );
     BEGIN
     --
     -- Use the general absolute value  procedure
	 RegAbs ( result, operand, DefaultRegMode );
	 RETURN result;
     END;

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
		     ) RETURN bit_vector IS
       CONSTANT reslen   : INTEGER := operand'LENGTH;
       VARIABLE result   : bit_vector ( reslen - 1 DOWNTO 0 );
     BEGIN
     --
     -- Use the general absolute value  procedure
	 RegAbs ( result, operand, DefaultRegMode );
	 RETURN result;
     END;

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
		   ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     --
     -- Use general std_logic_vector comparison  for the calculation.
       compare (lt,eq,gt, l,r, DefaultRegMode, TRUE);
	 RETURN eq;
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "=" ( CONSTANT l  : std_logic_vector;
		     CONSTANT r  : INTEGER
		   ) RETURN BOOLEAN IS
       VARIABLE temp_int  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.

       temp_int := To_StdLogicVector (r, IntegerBitLength, DefaultRegMode);
       compare ( lt,eq,gt, l, temp_int, DefaultRegMode, TRUE );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (eq = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded = --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "=" ( CONSTANT l  : INTEGER   ;
		     CONSTANT r  : std_logic_vector 
		   ) RETURN BOOLEAN IS
       VARIABLE temp1    : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.

       temp1 := To_StdLogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp1,r, DefaultRegMode, TRUE );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (eq = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded = --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;
       RETURN To_Boolean(eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "=" ( CONSTANT l  : std_logic_vector;
		     CONSTANT r  : INTEGER
		   ) RETURN std_ulogic IS
       VARIABLE temp_int1  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.
	 temp_int1 := To_StdLogicVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int1, DefaultRegMode, TRUE );
	 RETURN eq;
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "=" ( CONSTANT l  : INTEGER   ;
		     CONSTANT r  : std_logic_vector 
		   ) RETURN std_ulogic IS
       VARIABLE temp2    : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.

       temp2 := To_StdLogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp2,r, DefaultRegMode, TRUE );
       RETURN eq;
     END;

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
		   ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     --
     -- Use general std_ulogic_vector comparison  for the calculation.
       compare (lt,eq,gt, l,r, DefaultRegMode, TRUE );
	 RETURN eq;
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "=" ( CONSTANT l  : std_ulogic_vector;
		     CONSTANT r  : INTEGER
		   ) RETURN BOOLEAN IS
       VARIABLE temp_int  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.

       temp_int := To_StdULogicVector (r, IntegerBitLength, DefaultRegMode);
       compare ( lt,eq,gt, l, temp_int, DefaultRegMode, TRUE );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (eq = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded = --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "=" ( CONSTANT l  : INTEGER   ;
		     CONSTANT r  : std_ulogic_vector 
		   ) RETURN BOOLEAN IS
       VARIABLE temp1    : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.

       temp1 := To_StdULogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp1,r, DefaultRegMode, TRUE );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (eq = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded = --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "=" ( CONSTANT l  : std_ulogic_vector;
		     CONSTANT r  : INTEGER
		   ) RETURN std_ulogic IS
       VARIABLE temp_int1  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.
	 temp_int1 := To_StdULogicVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int1, DefaultRegMode, TRUE );
	 RETURN eq;
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "=" ( CONSTANT l  : INTEGER   ;
		     CONSTANT r  : std_ulogic_vector 
		   ) RETURN std_ulogic IS
       VARIABLE temp2    : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.

       temp2 := To_StdULogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp2,r, DefaultRegMode, TRUE );
       RETURN eq;
     END;

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
		   ) RETURN bit IS
       VARIABLE lt,eq,gt : bit;

     BEGIN
     --
     -- Use general bit_vector comparison  for the calculation.
       compare (lt,eq,gt, l,r, DefaultRegMode, TRUE );
	 RETURN eq;
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "=" ( CONSTANT l  : bit_vector;
		     CONSTANT r  : INTEGER
		   ) RETURN BOOLEAN IS
       VARIABLE temp_int  : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : bit;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
	 temp_int := To_BitVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int, DefaultRegMode, TRUE );
	 RETURN To_Boolean(eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "=" ( CONSTANT l  : INTEGER   ;
		     CONSTANT r  : bit_vector 
		   ) RETURN BOOLEAN IS
       VARIABLE temp1    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp1 := To_BitVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp1,r, DefaultRegMode, TRUE );
       RETURN To_Boolean(eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "=" ( CONSTANT l  : bit_vector;
		     CONSTANT r  : INTEGER
		   ) RETURN bit IS
       VARIABLE temp_int2 : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : bit;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
	 temp_int2 := To_BitVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int2, DefaultRegMode, TRUE );
	 RETURN eq;
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "=" ( CONSTANT l  : INTEGER   ;
		     CONSTANT r  : bit_vector 
		   ) RETURN bit IS
       VARIABLE temp3    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp3 := To_BitVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp3,r, DefaultRegMode, TRUE );
       RETURN eq;
     END;


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
		   ) RETURN bit IS
       VARIABLE lt,eq,gt : bit;

     BEGIN
     --
     -- Use general std_logic_vector comparison  for the calculation.
       compare (lt,eq,gt, l,r, DefaultRegMode, TRUE );
	 RETURN  NOT eq;
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "/=" ( CONSTANT l  : bit_vector;
		      CONSTANT r  : INTEGER
		    ) RETURN BOOLEAN IS
       VARIABLE temp_int  : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : bit;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
	 temp_int := To_BitVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int, DefaultRegMode, TRUE );
	 RETURN To_Boolean(NOT eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "/=" ( CONSTANT l  : INTEGER   ;
		      CONSTANT r  : bit_vector 
		    ) RETURN BOOLEAN IS
       VARIABLE temp1    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp1 := To_BitVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp1,r, DefaultRegMode, TRUE );
       RETURN To_Boolean(NOT eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "/=" ( CONSTANT l  : bit_vector;
		     CONSTANT r  : INTEGER
		   ) RETURN bit IS
       VARIABLE temp_int2 : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : bit;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
	 temp_int2 := To_BitVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int2, DefaultRegMode, TRUE );
	 RETURN  NOT eq;
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "/=" ( CONSTANT l  : INTEGER   ;
		      CONSTANT r  : bit_vector 
		    ) RETURN bit IS
       VARIABLE temp3    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp3 := To_BitVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp3,r, DefaultRegMode, TRUE );
       RETURN  NOT eq;
     END;

     -------------------------------------------------------------------------------
     --     Function Name : Overloaded "/=" operator
     --   1.2.9 and 1.2.11 
     --     Purpose       : Inequality relational operator for 
     --                     std_logic_vector : integer.
     --     
     --     Parameters    :     result         left            right
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
     --     See Also      : compare, RegLessThan, RegGreaterThan,
     -------------------------------------------------------------------------------
     FUNCTION "/=" ( CONSTANT l  : std_logic_vector;
		     CONSTANT r  : std_logic_vector
		   ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     --
     -- Use general std_logic_vector comparison  for the calculation.
       compare (lt,eq,gt, l,r, DefaultRegMode, TRUE );
	 RETURN  (NOT eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "/=" ( CONSTANT l  : std_logic_vector;
		     CONSTANT r  : INTEGER
		    ) RETURN BOOLEAN IS
       VARIABLE temp_int  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.

	temp_int := To_StdLogicVector (r, IntegerBitLength, DefaultRegMode);
	compare ( lt,eq,gt, l, temp_int, DefaultRegMode, TRUE );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
       --  note when eq is 'X'     then NOT eq is also 'X'
	 IF (eq = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded /= --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

	 RETURN To_Boolean( NOT eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "/=" ( CONSTANT l  : INTEGER   ;
		     CONSTANT r  : std_logic_vector 
		   ) RETURN BOOLEAN IS
       VARIABLE temp1    : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.

       temp1 := To_StdLogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp1,r, DefaultRegMode, TRUE );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
       --  note when eq is 'X'     then NOT eq is also 'X'
	 IF (eq = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded /= --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(NOT eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "/=" ( CONSTANT l  : std_logic_vector;
		     CONSTANT r  : INTEGER
		   ) RETURN std_ulogic IS
       VARIABLE temp_int1  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.
	 temp_int1 := To_StdLogicVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int1, DefaultRegMode, TRUE );
	 RETURN (NOT eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "/=" ( CONSTANT l  : INTEGER   ;
		      CONSTANT r  : std_logic_vector 
		    ) RETURN std_ulogic IS
       VARIABLE temp2    : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.

       temp2 := To_StdLogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp2,r, DefaultRegMode, TRUE );
       RETURN (NOT eq);
     END;


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
     --     See Also      : compare, RegLessThan, RegGreaterThan,
     -------------------------------------------------------------------------------
     FUNCTION "/=" ( CONSTANT l  : std_ulogic_vector;
		     CONSTANT r  : std_ulogic_vector
		   ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     --
     -- Use general std_ulogic_vector comparison  for the calculation.
       compare (lt,eq,gt, l,r, DefaultRegMode, TRUE );
	 RETURN  (NOT eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "/=" ( CONSTANT l  : std_ulogic_vector;
		      CONSTANT r  : INTEGER
		    ) RETURN BOOLEAN IS
       VARIABLE temp_int  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.

	temp_int := To_StdULogicVector (r, IntegerBitLength, DefaultRegMode);
	compare ( lt,eq,gt, l, temp_int, DefaultRegMode, TRUE );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
       --  note when eq is 'X'     then NOT eq is also 'X'
	 IF (eq = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded /= --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

	 RETURN To_Boolean( NOT eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "/=" ( CONSTANT l  : INTEGER   ;
		      CONSTANT r  : std_ulogic_vector 
		    ) RETURN BOOLEAN IS
       VARIABLE temp1    : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.

       temp1 := To_StdULogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp1,r, DefaultRegMode, TRUE );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
       --  note when eq is 'X'     then NOT eq is also 'X'
	 IF (eq = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded /= --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(NOT eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "/=" ( CONSTANT l  : std_ulogic_vector;
		      CONSTANT r  : INTEGER
		    ) RETURN std_ulogic IS
       VARIABLE temp_int1  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.
	 temp_int1 := To_StdULogicVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int1, DefaultRegMode, TRUE );
	 RETURN (NOT eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "/=" ( CONSTANT l  : INTEGER   ;
		      CONSTANT r  : std_ulogic_vector 
		    ) RETURN std_ulogic IS
       VARIABLE temp2    : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.

       temp2 := To_StdULogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp2,r, DefaultRegMode, TRUE );
       RETURN (NOT eq);
     END;


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
		   ) RETURN bit IS
       VARIABLE lt,eq,gt : bit;

     BEGIN
     --
     -- Use general std_logic_vector comparison  for the calculation.
       compare (lt,eq,gt, l,r, DefaultRegMode );
	 RETURN lt;
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "<" ( CONSTANT l  : bit_vector;
		     CONSTANT r  : INTEGER
		   ) RETURN BOOLEAN IS
       VARIABLE temp_int  : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : bit;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
	 temp_int := To_BitVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int, DefaultRegMode );
	 RETURN To_Boolean(lt);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "<" ( CONSTANT l  : INTEGER   ;
		     CONSTANT r  : bit_vector 
		   ) RETURN BOOLEAN IS
       VARIABLE temp1    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp1 := To_BitVector ( l, IntegerBitLength, DefaultRegMode );
       compare (lt,eq,gt, temp1,r, DefaultRegMode );
       RETURN To_Boolean(lt);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "<" ( CONSTANT l  : bit_vector;
		     CONSTANT r  : INTEGER
		   ) RETURN bit IS
       VARIABLE temp_int2 : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : bit;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
	 temp_int2 := To_BitVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int2, DefaultRegMode );
	 RETURN lt;
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "<" ( CONSTANT l  : INTEGER   ;
		     CONSTANT r  : bit_vector 
		   ) RETURN bit IS
       VARIABLE temp3    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp3 := To_BitVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp3,r, DefaultRegMode );
       RETURN lt;
     END;

     -------------------------------------------------------------------------------
     --     Function Name : Overloaded "<" operator
     --
     --     Purpose       : Less-than relational operator for std_logic_vectors.
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
     --                      IF ( a < b )  THEN
     --
     --     See Also      : compare, RegLessThan, RegGreaterThan,
     -------------------------------------------------------------------------------
     FUNCTION  "<" ( CONSTANT l  : std_logic_vector;
		     CONSTANT r  : std_logic_vector
		   ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     --
     -- Use general std_logic_vector comparison  for the calculation.
       compare (lt,eq,gt, l,r, DefaultRegMode );
	 RETURN lt;
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "<" ( CONSTANT l  : std_logic_vector;
		     CONSTANT r  : INTEGER
		   ) RETURN BOOLEAN IS
       VARIABLE temp_int  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.
       temp_int := To_StdLogicVector (r, IntegerBitLength, DefaultRegMode);
       compare ( lt,eq,gt, l, temp_int, DefaultRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (lt = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded < --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

	 RETURN To_Boolean(lt);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "<" ( CONSTANT l  : INTEGER   ;
		     CONSTANT r  : std_logic_vector 
		   ) RETURN BOOLEAN IS
       VARIABLE temp1    : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.

       temp1 := To_StdLogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp1,r, DefaultRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (lt = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded < --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(lt);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "<" ( CONSTANT l  : std_logic_vector;
		     CONSTANT r  : INTEGER
		   ) RETURN std_ulogic IS
       VARIABLE temp_int1  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt   : std_ulogic;
     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.
	 temp_int1 := To_StdLogicVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int1, DefaultRegMode );
	 RETURN lt;
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "<" ( CONSTANT l  : INTEGER   ;
		     CONSTANT r  : std_logic_vector 
		   ) RETURN std_ulogic IS
       VARIABLE temp2    : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.

       temp2 := To_StdLogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp2,r, DefaultRegMode );
       RETURN lt;
     END;


     -------------------------------------------------------------------------------
     --     Function Name : Overloaded "<" operator
     --
     --     Purpose       : Less-than relational operator for std_logic_vectors.
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
     --                      IF ( a < b )  THEN
     --
     --     See Also      : compare, RegLessThan, RegGreaterThan,
     -------------------------------------------------------------------------------
     FUNCTION  "<" ( CONSTANT l  : std_ulogic_vector;
		     CONSTANT r  : std_ulogic_vector
		   ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     --
     -- Use general std_ulogic_vector comparison  for the calculation.
       compare (lt,eq,gt, l,r, DefaultRegMode );
	 RETURN lt;
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "<" ( CONSTANT l  : std_ulogic_vector;
		     CONSTANT r  : INTEGER
		   ) RETURN BOOLEAN IS
       VARIABLE temp_int  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.
       temp_int := To_StdULogicVector (r, IntegerBitLength, DefaultRegMode);
       compare ( lt,eq,gt, l, temp_int, DefaultRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (lt = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded < --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

	 RETURN To_Boolean(lt);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "<" ( CONSTANT l  : INTEGER   ;
		     CONSTANT r  : std_ulogic_vector 
		   ) RETURN BOOLEAN IS
       VARIABLE temp1    : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.

       temp1 := To_StdULogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp1,r, DefaultRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (lt = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded < --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(lt);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "<" ( CONSTANT l  : std_ulogic_vector;
		     CONSTANT r  : INTEGER
		   ) RETURN std_ulogic IS
       VARIABLE temp_int1  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt   : std_ulogic;
     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.
	 temp_int1 := To_StdULogicVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int1, DefaultRegMode );
	 RETURN lt;
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "<" ( CONSTANT l  : INTEGER   ;
		     CONSTANT r  : std_ulogic_vector 
		   ) RETURN std_ulogic IS
       VARIABLE temp2    : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.

       temp2 := To_StdULogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp2,r, DefaultRegMode );
       RETURN lt;
     END;



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
		   ) RETURN bit IS
       VARIABLE lt,eq,gt : bit;

     BEGIN
     --
     -- Use general std_logic_vector comparison  for the calculation.
       compare (lt,eq,gt, l,r, DefaultRegMode );
	 RETURN lt OR eq ;
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "<=" ( CONSTANT l  : bit_vector;
		      CONSTANT r  : INTEGER
		    ) RETURN BOOLEAN IS
       VARIABLE temp_int  : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : bit;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
	 temp_int := To_BitVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int, DefaultRegMode );
	 RETURN To_Boolean(lt OR eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "<=" ( CONSTANT l  : INTEGER   ;
		      CONSTANT r  : bit_vector 
		    ) RETURN BOOLEAN IS
       VARIABLE temp1    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp1 := To_BitVector ( l, IntegerBitLength, DefaultRegMode );
       compare (lt,eq,gt, temp1,r, DefaultRegMode );
       RETURN To_Boolean(lt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "<=" ( CONSTANT l  : bit_vector;
		      CONSTANT r  : INTEGER
		    ) RETURN bit IS
       VARIABLE temp_int2 : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : bit;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
	 temp_int2 := To_BitVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int2, DefaultRegMode );
	 RETURN lt OR eq;
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "<=" ( CONSTANT l  : INTEGER   ;
		      CONSTANT r  : bit_vector 
		    ) RETURN bit IS
       VARIABLE temp3    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp3 := To_BitVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp3,r, DefaultRegMode );
       RETURN lt OR eq;
     END;

     -------------------------------------------------------------------------------
     --     Function Name : Overloaded "<=" operator
     --    
     --     Purpose       : Less-than-or-equal relational operator for 
     --                     std_logic_vectors.
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
		    ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     --
     -- Use general std_logic_vector comparison  for the calculation.
       compare (lt,eq,gt, l,r, DefaultRegMode );
	 RETURN (lt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "<=" ( CONSTANT l  : std_logic_vector;
		      CONSTANT r  : INTEGER
		    ) RETURN BOOLEAN IS
       VARIABLE temp_int  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.
       temp_int := To_StdLogicVector (r, IntegerBitLength, DefaultRegMode);
       compare ( lt,eq,gt, l, temp_int, DefaultRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false

	  IF ( (lt OR eq) = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded <= --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

	 RETURN To_Boolean(lt OR eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "<=" ( CONSTANT l  : INTEGER   ;
		      CONSTANT r  : std_logic_vector 
		    ) RETURN BOOLEAN IS
       VARIABLE temp1    : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;
       VARIABLE lt_eq    : std_ulogic;

     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.

       temp1 := To_StdLogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp1,r, DefaultRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF ((lt OR eq) = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded <=  --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(lt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "<=" ( CONSTANT l  : std_logic_vector;
		      CONSTANT r  : INTEGER
		    ) RETURN std_ulogic IS
       VARIABLE temp_int1  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt   : std_ulogic;
     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.
	 temp_int1 := To_StdLogicVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int1, DefaultRegMode );
	 RETURN lt OR eq;
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "<=" ( CONSTANT l  : INTEGER   ;
		      CONSTANT r  : std_logic_vector 
		    ) RETURN std_ulogic IS
       VARIABLE temp2    : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.

       temp2 := To_StdLogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp2,r, DefaultRegMode );
       RETURN lt OR eq;
     END;

     -------------------------------------------------------------------------------
     --     Function Name : Overloaded "<=" operator
     --    
     --     Purpose       : Less-than-or-equal relational operator for 
     --                     std_ulogic_vectors.
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
		    ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     --
     -- Use general std_ulogic_vector comparison  for the calculation.
       compare (lt,eq,gt, l,r, DefaultRegMode );
	 RETURN (lt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "<=" ( CONSTANT l  : std_ulogic_vector;
		      CONSTANT r  : INTEGER
		    ) RETURN BOOLEAN IS
       VARIABLE temp_int  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.
       temp_int := To_StdULogicVector (r, IntegerBitLength, DefaultRegMode);
       compare ( lt,eq,gt, l, temp_int, DefaultRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false

	  IF ( (lt OR eq) = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded <= --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

	 RETURN To_Boolean(lt OR eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "<=" ( CONSTANT l  : INTEGER   ;
		      CONSTANT r  : std_ulogic_vector 
		    ) RETURN BOOLEAN IS
       VARIABLE temp1    : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;
       VARIABLE lt_eq    : std_ulogic;

     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.

       temp1 := To_StdULogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp1,r, DefaultRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF ((lt OR eq) = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded <=  --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(lt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  "<=" ( CONSTANT l  : std_ulogic_vector;
		      CONSTANT r  : INTEGER
		    ) RETURN std_ulogic IS
       VARIABLE temp_int1  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt   : std_ulogic;
     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.
	 temp_int1 := To_StdULogicVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int1, DefaultRegMode );
	 RETURN lt OR eq;
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  "<=" ( CONSTANT l  : INTEGER   ;
		      CONSTANT r  : std_ulogic_vector 
		    ) RETURN std_ulogic IS
       VARIABLE temp2    : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.

       temp2 := To_StdULogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp2,r, DefaultRegMode );
       RETURN lt OR eq;
     END;


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
		   ) RETURN bit IS
       VARIABLE lt,eq,gt : bit;

     BEGIN
     --
     -- Use general std_logic_vector comparison  for the calculation.
       compare (lt,eq,gt, l,r, DefaultRegMode );
	 RETURN gt;
     END;
     -------------------------------------------------------------------------------
     FUNCTION  ">" ( CONSTANT l  : bit_vector;
		     CONSTANT r  : INTEGER
		   ) RETURN BOOLEAN IS
       VARIABLE temp_int  : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : bit;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
	 temp_int := To_BitVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int, DefaultRegMode );
	 RETURN To_Boolean(gt);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  ">" ( CONSTANT l  : INTEGER   ;
		     CONSTANT r  : bit_vector 
		   ) RETURN BOOLEAN IS
       VARIABLE temp1    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp1 := To_BitVector ( l, IntegerBitLength, DefaultRegMode );
       compare (lt,eq,gt, temp1,r, DefaultRegMode );
       RETURN To_Boolean(gt);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  ">" ( CONSTANT l  : bit_vector;
		     CONSTANT r  : INTEGER
		   ) RETURN bit IS
       VARIABLE temp_int2 : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : bit;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
	 temp_int2 := To_BitVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int2, DefaultRegMode );
	 RETURN gt;
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  ">" ( CONSTANT l  : INTEGER   ;
		     CONSTANT r  : bit_vector 
		   ) RETURN bit IS
       VARIABLE temp3    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp3 := To_BitVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp3,r, DefaultRegMode );
       RETURN gt;
     END;

     -------------------------------------------------------------------------------
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
     --     See Also      : compare, RegLessThan, RegGreaterThan,
     -------------------------------------------------------------------------------
     FUNCTION  ">" ( CONSTANT l  : std_logic_vector;
		     CONSTANT r  : std_logic_vector
		   ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     --
     -- Use general std_logic_vector comparison  for the calculation.
       compare (lt,eq,gt, l,r, DefaultRegMode );
	 RETURN gt;
     END;
     -------------------------------------------------------------------------------
     FUNCTION  ">" ( CONSTANT l  : std_logic_vector;
		     CONSTANT r  : INTEGER
		   ) RETURN BOOLEAN IS
       VARIABLE temp_int  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.
       temp_int := To_StdLogicVector (r, IntegerBitLength, DefaultRegMode);
       compare ( lt,eq,gt, l, temp_int, DefaultRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF ( gt = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded >  --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

	 RETURN To_Boolean(gt);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  ">" ( CONSTANT l  : INTEGER   ;
		     CONSTANT r  : std_logic_vector 
		   ) RETURN BOOLEAN IS
       VARIABLE temp1    : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.

       temp1 := To_StdLogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp1,r, DefaultRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (gt = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded >  --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(gt);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  ">" ( CONSTANT l  : std_logic_vector;
		     CONSTANT r  : INTEGER
		   ) RETURN std_ulogic IS
       VARIABLE temp_int1  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt   : std_ulogic;
     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.
	 temp_int1 := To_StdLogicVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int1, DefaultRegMode );
	 RETURN gt;
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  ">" ( CONSTANT l  : INTEGER   ;
		     CONSTANT r  : std_logic_vector 
		   ) RETURN std_ulogic IS
       VARIABLE temp2    : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.

       temp2 := To_StdLogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp2,r, DefaultRegMode );
       RETURN gt;
     END;


     -------------------------------------------------------------------------------
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
     --     See Also      : compare, RegLessThan, RegGreaterThan,
     -------------------------------------------------------------------------------
     FUNCTION  ">" ( CONSTANT l  : std_ulogic_vector;
		     CONSTANT r  : std_ulogic_vector
		   ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     --
     -- Use general std_ulogic_vector comparison  for the calculation.
       compare (lt,eq,gt, l,r, DefaultRegMode );
	 RETURN gt;
     END;
     -------------------------------------------------------------------------------
     FUNCTION  ">" ( CONSTANT l  : std_ulogic_vector;
		     CONSTANT r  : INTEGER
		   ) RETURN BOOLEAN IS
       VARIABLE temp_int  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.
       temp_int := To_StdULogicVector (r, IntegerBitLength, DefaultRegMode);
       compare ( lt,eq,gt, l, temp_int, DefaultRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF ( gt = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded >  --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

	 RETURN To_Boolean(gt);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  ">" ( CONSTANT l  : INTEGER   ;
		     CONSTANT r  : std_ulogic_vector 
		   ) RETURN BOOLEAN IS
       VARIABLE temp1    : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.

       temp1 := To_StdULogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp1,r, DefaultRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (gt = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded >  --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(gt);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  ">" ( CONSTANT l  : std_ulogic_vector;
		     CONSTANT r  : INTEGER
		   ) RETURN std_ulogic IS
       VARIABLE temp_int1  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt   : std_ulogic;
     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.
	 temp_int1 := To_StdULogicVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int1, DefaultRegMode );
	 RETURN gt;
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  ">" ( CONSTANT l  : INTEGER   ;
		     CONSTANT r  : std_ulogic_vector 
		   ) RETURN std_ulogic IS
       VARIABLE temp2    : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.

       temp2 := To_StdULogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp2,r, DefaultRegMode );
       RETURN gt;
     END;

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
		    ) RETURN bit IS
       VARIABLE lt,eq,gt : bit;

     BEGIN
     --
     -- Use general std_logic_vector comparison  for the calculation.
       compare (lt,eq,gt, l,r, DefaultRegMode );
	 RETURN gt OR eq ;
     END;
     -------------------------------------------------------------------------------
     FUNCTION  ">=" ( CONSTANT l  : bit_vector;
		      CONSTANT r  : INTEGER
		    ) RETURN BOOLEAN IS
       VARIABLE temp_int  : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : bit;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
       temp_int := To_BitVector (r, IntegerBitLength, DefaultRegMode);
       compare ( lt,eq,gt, l, temp_int, DefaultRegMode );

       RETURN To_Boolean(gt OR eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  ">=" ( CONSTANT l  : INTEGER   ;
		      CONSTANT r  : bit_vector 
		    ) RETURN BOOLEAN IS
       VARIABLE temp1    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.
       temp1 := To_BitVector ( l, IntegerBitLength, DefaultRegMode );
       compare (lt,eq,gt, temp1,r, DefaultRegMode );

       RETURN To_Boolean(gt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  ">=" ( CONSTANT l  : bit_vector;
		      CONSTANT r  : INTEGER
		    ) RETURN bit IS
       VARIABLE temp_int2 : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : bit;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .

       temp_int2 := To_BitVector (r, IntegerBitLength, DefaultRegMode);
       compare ( lt,eq,gt, l, temp_int2, DefaultRegMode );
       RETURN gt OR eq;

     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  ">=" ( CONSTANT l  : INTEGER   ;
		      CONSTANT r  : bit_vector 
		    ) RETURN bit IS
       VARIABLE temp3    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp3 := To_BitVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp3,r, DefaultRegMode );
       RETURN gt OR eq;

     END;
     -------------------------------------------------------------------------------
     --     Function Name : Overloaded ">=" operator
     --    
     --     Purpose       : greater-than-or-equal relational operator
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
		    ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     --
     -- Use general std_logic_vector comparison  for the calculation.
       compare (lt,eq,gt, l,r, DefaultRegMode );
	 RETURN (gt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  ">=" ( CONSTANT l  : std_logic_vector;
		      CONSTANT r  : INTEGER
		    ) RETURN BOOLEAN IS
       VARIABLE temp_int  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.
       temp_int := To_StdLogicVector (r, IntegerBitLength, DefaultRegMode);
       compare ( lt,eq,gt, l, temp_int, DefaultRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF ((gt OR eq) = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded >  --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

	 RETURN To_Boolean(gt OR eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  ">=" ( CONSTANT l  : INTEGER   ;
		      CONSTANT r  : std_logic_vector 
		    ) RETURN BOOLEAN IS
       VARIABLE temp1    : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.

       temp1 := To_StdLogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp1,r, DefaultRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF ((gt OR eq) = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded >  --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(gt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  ">=" ( CONSTANT l  : std_logic_vector;
		      CONSTANT r  : INTEGER
		    ) RETURN std_ulogic IS
       VARIABLE temp_int1  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt   : std_ulogic;
     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.
	 temp_int1 := To_StdLogicVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int1, DefaultRegMode );
	 RETURN gt OR eq;
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  ">=" ( CONSTANT l  : INTEGER   ;
		      CONSTANT r  : std_logic_vector 
		    ) RETURN std_ulogic IS
       VARIABLE temp2    : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_logic_vectors for comparison to allow any length input vector.
     -- Use general std_logic_vector comparison  for the calculation.

       temp2 := To_StdLogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp2,r, DefaultRegMode );
       RETURN gt OR eq;
     END;

     -------------------------------------------------------------------------------
     --     Function Name : Overloaded ">=" operator
     --    
     --     Purpose       : greater-than-or-equal relational operator
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
		    ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     --
     -- Use general std_ulogic_vector comparison  for the calculation.
       compare (lt,eq,gt, l,r, DefaultRegMode );
	 RETURN (gt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  ">=" ( CONSTANT l  : std_ulogic_vector;
		      CONSTANT r  : INTEGER
		    ) RETURN BOOLEAN IS
       VARIABLE temp_int  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.
       temp_int := To_StdULogicVector (r, IntegerBitLength, DefaultRegMode);
       compare ( lt,eq,gt, l, temp_int, DefaultRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF ((gt OR eq) = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded >  --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

	 RETURN To_Boolean(gt OR eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  ">=" ( CONSTANT l  : INTEGER   ;
		      CONSTANT r  : std_ulogic_vector 
		    ) RETURN BOOLEAN IS
       VARIABLE temp1    : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.

       temp1 := To_StdULogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp1,r, DefaultRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF ((gt OR eq) = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " Overloaded >  --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(gt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION  ">=" ( CONSTANT l  : std_ulogic_vector;
		      CONSTANT r  : INTEGER
		    ) RETURN std_ulogic IS
       VARIABLE temp_int1  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt   : std_ulogic;
     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.
	 temp_int1 := To_StdULogicVector (r, IntegerBitLength, DefaultRegMode);
	 compare ( lt,eq,gt, l, temp_int1, DefaultRegMode );
	 RETURN gt OR eq;
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION  ">=" ( CONSTANT l  : INTEGER   ;
		      CONSTANT r  : std_ulogic_vector 
		    ) RETURN std_ulogic IS
       VARIABLE temp2    : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : std_ulogic;

     BEGIN
     -- Convert to std_ulogic_vectors for comparison to allow any length input vector.
     -- Use general std_ulogic_vector comparison  for the calculation.

       temp2 := To_StdULogicVector ( l, IntegerBitLength, DefaultRegMode );
       compare ( lt,eq,gt, temp2,r, DefaultRegMode );
       RETURN gt OR eq;
     END;

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
			   ) RETURN bit IS
       VARIABLE lt,eq,gt : bit;
     BEGIN
     -- Use general bit_vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode, TRUE );

       RETURN eq;
     END;
     -----------------------------------------------------------------------------
     FUNCTION RegEqual    (  CONSTANT l        : IN bit_vector;
			     CONSTANT r        : IN bit_vector;
			     CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
			   ) RETURN BOOLEAN IS
       VARIABLE lt,eq,gt : bit;
     BEGIN
     -- Use general bit_vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode, TRUE );

       RETURN To_Boolean(eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION RegEqual     ( CONSTANT l          : IN bit_vector;
			     CONSTANT r          : IN INTEGER;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN BOOLEAN IS
       VARIABLE temp1    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.
       temp1 := To_BitVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp1, SrcRegMode, TRUE );

       RETURN To_Boolean(eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegEqual    (  CONSTANT l          : IN INTEGER;
			     CONSTANT r          : IN bit_vector;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN BOOLEAN IS
       VARIABLE temp_int2 : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : bit;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
       temp_int2 := To_BitVector (l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt, temp_int2, r, SrcRegMode, TRUE );

       RETURN To_Boolean(eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegEqual     ( CONSTANT l          : IN bit_vector;
			     CONSTANT r          : IN INTEGER;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN bit IS
       VARIABLE temp2    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp2 := To_BitVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp2, SrcRegMode, TRUE);

       RETURN eq;
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegEqual    (  CONSTANT l          : IN INTEGER;
			     CONSTANT r          : IN bit_vector;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN bit IS
       VARIABLE temp3    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.

       temp3 := To_BitVector ( l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt, temp3,r, SrcRegMode, TRUE );
       RETURN eq;
     END;

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
     --     Result        : BOOLEAN relation. A TRUE value is returned if: l < r
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
			   ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode, TRUE );

       RETURN eq;
     END;
     -----------------------------------------------------------------------------
     FUNCTION RegEqual    (  CONSTANT l          : IN std_logic_vector;
			     CONSTANT r          : IN std_logic_vector;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN BOOLEAN IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode, TRUE );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (eq = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION RegEqual     ( CONSTANT l          : IN std_logic_vector;
			     CONSTANT r          : IN INTEGER;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN BOOLEAN IS
       VARIABLE temp_std  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.
       temp_std := To_StdLogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std, SrcRegMode, TRUE );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (eq = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegEqual    (  CONSTANT l          : IN INTEGER;
			     CONSTANT r          : IN std_logic_vector;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN BOOLEAN IS
       VARIABLE temp_std1  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
       temp_std1 := To_StdLogicVector (l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt,temp_std1, r, SrcRegMode, TRUE);

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (eq = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegEqual     ( CONSTANT l          : IN std_logic_vector;
			     CONSTANT r          : IN INTEGER;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN std_ulogic IS
       VARIABLE temp_std2 : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to logic vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp_std2 := To_StdLogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std2, SrcRegMode, TRUE );

       RETURN eq;
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegEqual    (  CONSTANT l          : IN INTEGER;
			     CONSTANT r          : IN std_logic_vector;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN std_ulogic IS
       VARIABLE temp_std3    : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt     : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.

       temp_std3 := To_StdLogicVector ( l, IntegerBitLength, SrcRegMode );
       compare ( lt,eq,gt, temp_std3,r, SrcRegMode, TRUE );

       RETURN eq;
     END;


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
     --     Result        : BOOLEAN relation. A TRUE value is returned if: l < r
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
     --     See Also      : RegLessThan, RegLessThanOrEqual, RegGreaterThan, 
     --                     RegGreaterThanOrEqual.

     -------------------------------------------------------------------------------
     FUNCTION RegEqual     ( CONSTANT l          : IN std_ulogic_vector;
			     CONSTANT r          : IN std_ulogic_vector;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode, TRUE );

       RETURN eq;
     END;
     -----------------------------------------------------------------------------
     FUNCTION RegEqual    (  CONSTANT l          : IN std_ulogic_vector;
			     CONSTANT r          : IN std_ulogic_vector;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN BOOLEAN IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode, TRUE );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (eq = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION RegEqual     ( CONSTANT l          : IN std_ulogic_vector;
			     CONSTANT r          : IN INTEGER;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN BOOLEAN IS
       VARIABLE temp_std  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.
       temp_std := To_StdULogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std, SrcRegMode, TRUE );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (eq = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegEqual    (  CONSTANT l          : IN INTEGER;
			     CONSTANT r          : IN std_ulogic_vector;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN BOOLEAN IS
       VARIABLE temp_std1  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
       temp_std1 := To_StdULogicVector (l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt,temp_std1, r, SrcRegMode, TRUE);

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (eq = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegEqual     ( CONSTANT l          : IN std_ulogic_vector;
			     CONSTANT r          : IN INTEGER;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN std_ulogic IS
       VARIABLE temp_std2 : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to logic vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp_std2 := To_StdULogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std2, SrcRegMode, TRUE );

       RETURN eq;
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegEqual    (  CONSTANT l          : IN INTEGER;
			     CONSTANT r          : IN std_ulogic_vector;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN std_ulogic IS
       VARIABLE temp_std3    : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt     : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.

       temp_std3 := To_StdULogicVector ( l, IntegerBitLength, SrcRegMode );
       compare ( lt,eq,gt, temp_std3,r, SrcRegMode, TRUE );

       RETURN eq;
     END;

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
     FUNCTION RegNotEqual        ( CONSTANT l          : IN bit_vector;
				   CONSTANT r          : IN bit_vector;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN bit IS
       VARIABLE lt,eq,gt : bit;
     BEGIN
     -- Use general bit_vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode, TRUE );

       RETURN NOT eq;
     END;
     -----------------------------------------------------------------------------
     FUNCTION RegNotEqual        ( CONSTANT l          : IN bit_vector;
				   CONSTANT r          : IN bit_vector;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN BOOLEAN IS
       VARIABLE lt,eq,gt : bit;
     BEGIN
     -- Use general bit_vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode, TRUE );

       RETURN To_Boolean(Not eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION RegNotEqual        ( CONSTANT l          : IN bit_vector;
				   CONSTANT r          : IN INTEGER;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN BOOLEAN IS
       VARIABLE temp1    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.
       temp1 := To_BitVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp1, SrcRegMode, TRUE );

       RETURN To_Boolean(NOT eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegNotEqual        ( CONSTANT l          : IN INTEGER;
				   CONSTANT r          : IN bit_vector;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN BOOLEAN IS
       VARIABLE temp_int2 : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : bit;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
       temp_int2 := To_BitVector (l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt,temp_int2, r, SrcRegMode, TRUE );

       RETURN To_Boolean(NOT eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegNotEqual        ( CONSTANT l          : IN bit_vector;
				   CONSTANT r          : IN INTEGER;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN bit IS
       VARIABLE temp2    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp2 := To_BitVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp2, SrcRegMode, TRUE);

       RETURN NOT eq;
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegNotEqual        ( CONSTANT l          : IN INTEGER;
				   CONSTANT r          : IN bit_vector;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN bit IS
       VARIABLE temp3    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.

       temp3 := To_BitVector ( l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt, temp3,r, SrcRegMode, TRUE );
       RETURN  NOT eq;
     END;

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
     --     Result        : Boolean | std_ulogic 
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
     --     See Also      : RegLessThan, RegLessThanOrEqual, RegGreaterThan, 
     --                     RegGreaterThanOrEqual.
     -------------------------------------------------------------------------------
     FUNCTION RegNotEqual  ( CONSTANT l          : IN std_logic_vector;
			     CONSTANT r          : IN std_logic_vector;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode, TRUE );

       RETURN  NOT eq;
     END;
     -----------------------------------------------------------------------------
     FUNCTION RegNotEqual ( CONSTANT l          : IN std_logic_vector;
			    CONSTANT r          : IN std_logic_vector;
			    CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			  ) RETURN BOOLEAN IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode, TRUE );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
       -- note when eq is 'X'   not eq is also 'X'
	 IF (eq = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegNotEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(NOT eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION RegNotEqual ( CONSTANT l          : IN std_logic_vector;
			    CONSTANT r          : IN INTEGER;
			    CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			  ) RETURN BOOLEAN IS
       VARIABLE temp_std  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.
       temp_std := To_StdLogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std, SrcRegMode, TRUE );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
       -- note when eq is 'X'   not eq is also 'X'
	 IF (eq = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegNotEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(NOT eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegNotEqual ( CONSTANT l          : IN INTEGER;
			    CONSTANT r          : IN std_logic_vector;
			    CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			  ) RETURN BOOLEAN IS
       VARIABLE temp_std1  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
       temp_std1 := To_StdLogicVector (l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt,temp_std1, r, SrcRegMode, TRUE);

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
       -- note when eq is 'X'   not eq is also 'X'
	 IF (eq = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegNotEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(NOT eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegNotEqual ( CONSTANT l          : IN std_logic_vector;
			    CONSTANT r          : IN INTEGER;
			    CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			  ) RETURN std_ulogic IS
       VARIABLE temp_std2 : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to logic vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp_std2 := To_StdLogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std2, SrcRegMode, TRUE );

       RETURN NOT eq;
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegNotEqual ( CONSTANT l          : IN INTEGER;
			    CONSTANT r          : IN std_logic_vector;
			    CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			  ) RETURN std_ulogic IS
       VARIABLE temp_std3    : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt     : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.

       temp_std3 := To_StdLogicVector ( l, IntegerBitLength, SrcRegMode );
       compare ( lt,eq,gt, temp_std3,r, SrcRegMode, TRUE );

       RETURN  eq;
     END;

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
     --     Result        : 
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
     --     See Also      : RegLessThan, RegLessThanOrEqual, RegGreaterThan, 
     --                     RegGreaterThanOrEqual.
     -------------------------------------------------------------------------------
     FUNCTION RegNotEqual ( CONSTANT l          : IN std_ulogic_vector;
			    CONSTANT r          : IN std_ulogic_vector;
			    CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			  ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode, TRUE );

       RETURN  NOT eq;
     END;
     -----------------------------------------------------------------------------
     FUNCTION RegNotEqual ( CONSTANT l          : IN std_ulogic_vector;
			    CONSTANT r          : IN std_ulogic_vector;
			    CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			  ) RETURN BOOLEAN IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode, TRUE );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
       -- note when eq is 'X'   not eq is also 'X'
	 IF (eq = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegNotEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(NOT eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION RegNotEqual ( CONSTANT l          : IN std_ulogic_vector;
			    CONSTANT r          : IN INTEGER;
			    CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			  ) RETURN BOOLEAN IS
       VARIABLE temp_std  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.
       temp_std := To_StdULogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std, SrcRegMode, TRUE );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
       -- note when eq is 'X'   not eq is also 'X'
	 IF (eq = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegNotEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(NOT eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegNotEqual ( CONSTANT l          : IN INTEGER;
			    CONSTANT r          : IN std_ulogic_vector;
			    CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			  ) RETURN BOOLEAN IS
       VARIABLE temp_std1  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
       temp_std1 := To_StdULogicVector (l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt,temp_std1, r, SrcRegMode, TRUE);

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
       -- note when eq is 'X'   not eq is also 'X'
	 IF (eq = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegNotEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(NOT eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegNotEqual ( CONSTANT l          : IN std_ulogic_vector;
			    CONSTANT r          : IN INTEGER;
			    CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			  ) RETURN std_ulogic IS
       VARIABLE temp_std2 : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to logic vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp_std2 := To_StdULogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std2, SrcRegMode, TRUE );

       RETURN NOT eq;
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegNotEqual ( CONSTANT l          : IN INTEGER;
			    CONSTANT r          : IN std_ulogic_vector;
			    CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			  ) RETURN std_ulogic IS
       VARIABLE temp_std3    : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt     : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.

       temp_std3 := To_StdULogicVector ( l, IntegerBitLength, SrcRegMode );
       compare ( lt,eq,gt, temp_std3,r, SrcRegMode, TRUE );

       RETURN  eq;
     END;

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
			   ) RETURN bit IS
       VARIABLE lt,eq,gt : bit;
     BEGIN
     -- Use general bit_vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       RETURN lt;
     END;
     -----------------------------------------------------------------------------
     FUNCTION RegLessThan (  CONSTANT l        : IN bit_vector;
			     CONSTANT r        : IN bit_vector;
			     CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
			   ) RETURN BOOLEAN IS
       VARIABLE lt,eq,gt : bit;
     BEGIN
     -- Use general bit_vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       RETURN To_Boolean(lt);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION RegLessThan  ( CONSTANT l          : IN bit_vector;
			     CONSTANT r          : IN INTEGER;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN BOOLEAN IS
       VARIABLE temp1    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.
       temp1 := To_BitVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp1, SrcRegMode );

       RETURN To_Boolean(lt);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegLessThan (  CONSTANT l          : IN INTEGER;
			     CONSTANT r          : IN bit_vector;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN BOOLEAN IS
       VARIABLE temp_int2 : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : bit;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
       temp_int2 := To_BitVector (l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt, temp_int2, r, SrcRegMode );

       RETURN To_Boolean(lt);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegLessThan  ( CONSTANT l          : IN bit_vector;
			     CONSTANT r          : IN INTEGER;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN bit IS
       VARIABLE temp2    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp2 := To_BitVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp2, SrcRegMode);

       RETURN lt;
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegLessThan (  CONSTANT l          : IN INTEGER;
			     CONSTANT r          : IN bit_vector;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN bit IS
       VARIABLE temp3    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.

       temp3 := To_BitVector ( l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt, temp3,r, SrcRegMode );
       RETURN lt;
     END;

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
     --     Result        : BOOLEAN | std_ulogic
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
			   ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       RETURN lt;
     END;
     -----------------------------------------------------------------------------
     FUNCTION RegLessThan (  CONSTANT l          : IN std_logic_vector;
			     CONSTANT r          : IN std_logic_vector;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN BOOLEAN IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (lt = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegLessThan --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(lt);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION RegLessThan  ( CONSTANT l          : IN std_logic_vector;
			     CONSTANT r          : IN INTEGER;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN BOOLEAN IS
       VARIABLE temp_std  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.
       temp_std := To_StdLogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std, SrcRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (lt = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegLessThan --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(lt);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegLessThan (  CONSTANT l          : IN INTEGER;
			     CONSTANT r          : IN std_logic_vector;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN BOOLEAN IS
       VARIABLE temp_std1  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
       temp_std1 := To_StdLogicVector (l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt,temp_std1, r, SrcRegMode);

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (lt = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegLessThan --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(lt);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegLessThan  ( CONSTANT l          : IN std_logic_vector;
			     CONSTANT r          : IN INTEGER;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN std_ulogic IS
       VARIABLE temp_std2 : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to logic vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp_std2 := To_StdLogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std2, SrcRegMode );

       RETURN lt;
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegLessThan (  CONSTANT l          : IN INTEGER;
			     CONSTANT r          : IN std_logic_vector;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN std_ulogic IS
       VARIABLE temp_std3    : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt     : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.

       temp_std3 := To_StdLogicVector ( l, IntegerBitLength, SrcRegMode );
       compare ( lt,eq,gt, temp_std3,r, SrcRegMode );

       RETURN lt;
     END;

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
     --     Result        : BOOLEAN | std_ulogic
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
     --     See Also      :  RegLessThan, RegLessThanOrEqual, RegGreaterThan, 
     --                     RegGreaterThanOrEqual.

     -------------------------------------------------------------------------------
     FUNCTION RegLessThan  ( CONSTANT l          : IN std_ulogic_vector;
			     CONSTANT r          : IN std_ulogic_vector;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       RETURN lt;
     END;
     -----------------------------------------------------------------------------
     FUNCTION RegLessThan (  CONSTANT l          : IN std_ulogic_vector;
			     CONSTANT r          : IN std_ulogic_vector;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN BOOLEAN IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (lt = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegLessThan --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(lt);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION RegLessThan  ( CONSTANT l          : IN std_ulogic_vector;
			     CONSTANT r          : IN INTEGER;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN BOOLEAN IS
       VARIABLE temp_std  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.
       temp_std := To_StdULogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std, SrcRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (lt = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegLessThan --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(lt);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegLessThan (  CONSTANT l          : IN INTEGER;
			     CONSTANT r          : IN std_ulogic_vector;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN BOOLEAN IS
       VARIABLE temp_std1  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
       temp_std1 := To_StdULogicVector (l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt,temp_std1, r, SrcRegMode);

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (lt = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegLessThan --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(lt);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegLessThan  ( CONSTANT l          : IN std_ulogic_vector;
			     CONSTANT r          : IN INTEGER;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN std_ulogic IS
       VARIABLE temp_std2 : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to logic vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp_std2 := To_StdULogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std2, SrcRegMode );

       RETURN lt;
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegLessThan (  CONSTANT l          : IN INTEGER;
			     CONSTANT r          : IN std_ulogic_vector;
			     CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			   ) RETURN std_ulogic IS
       VARIABLE temp_std3    : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt     : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.

       temp_std3 := To_StdULogicVector ( l, IntegerBitLength, SrcRegMode );
       compare ( lt,eq,gt, temp_std3,r, SrcRegMode );

       RETURN lt;
     END;

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
				 ) RETURN bit IS
       VARIABLE lt,eq,gt : bit;
     BEGIN
     -- Use general bit_vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       RETURN lt OR eq;
     END;
     -----------------------------------------------------------------------------
     FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN bit_vector;
				   CONSTANT r          : IN bit_vector;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN BOOLEAN IS
       VARIABLE lt,eq,gt : bit;
     BEGIN
     -- Use general bit_vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       RETURN To_Boolean(lt OR eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN bit_vector;
				   CONSTANT r          : IN INTEGER;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN BOOLEAN IS
       VARIABLE temp1    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.
       temp1 := To_BitVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp1, SrcRegMode );

       RETURN To_Boolean(lt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN INTEGER;
				   CONSTANT r          : IN bit_vector;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN BOOLEAN IS
       VARIABLE temp_int2 : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : bit;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
       temp_int2 := To_BitVector (l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt,temp_int2, r, SrcRegMode );

       RETURN To_Boolean(lt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN bit_vector;
				   CONSTANT r          : IN INTEGER;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN bit IS
       VARIABLE temp2    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp2 := To_BitVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp2, SrcRegMode);

       RETURN lt OR eq;
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN INTEGER;
				   CONSTANT r          : IN bit_vector;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN bit IS
       VARIABLE temp3    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.

       temp3 := To_BitVector ( l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt, temp3,r, SrcRegMode );
       RETURN lt OR eq;
     END;

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
     --     See Also      : RegLessThan, RegLessThanOrEqual, RegGreaterThan, 
     --                     RegGreaterThanOrEqual.
     -------------------------------------------------------------------------------
     FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN std_logic_vector;
				   CONSTANT r          : IN std_logic_vector;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       RETURN lt OR eq;
     END;
     -----------------------------------------------------------------------------
     FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN std_logic_vector;
				   CONSTANT r          : IN std_logic_vector;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN BOOLEAN IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF ((lt OR eq) = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegLessThanOrEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(lt Or eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN std_logic_vector;
				   CONSTANT r          : IN INTEGER;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN BOOLEAN IS
       VARIABLE temp_std  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.
       temp_std := To_StdLogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std, SrcRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF ((lt OR eq) = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegLessThanOrEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(lt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN INTEGER;
				   CONSTANT r          : IN std_logic_vector;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN BOOLEAN IS
       VARIABLE temp_std1  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
       temp_std1 := To_StdLogicVector (l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt,temp_std1, r, SrcRegMode);

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF ((lt Or eq) = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegLessThanOrEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(lt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN std_logic_vector;
				   CONSTANT r          : IN INTEGER;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN std_ulogic IS
       VARIABLE temp_std2 : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to logic vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp_std2 := To_StdLogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std2, SrcRegMode );

       RETURN lt OR eq;
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN INTEGER;
				   CONSTANT r          : IN std_logic_vector;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN std_ulogic IS
       VARIABLE temp_std3    : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt     : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.

       temp_std3 := To_StdLogicVector ( l, IntegerBitLength, SrcRegMode );
       compare ( lt,eq,gt, temp_std3,r, SrcRegMode );

       RETURN lt OR eq;
     END;

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
     --     See Also      : RegLessThan, RegLessThanOrEqual, RegGreaterThan, 
     --                     RegGreaterThanOrEqual.
     -------------------------------------------------------------------------------
     FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN std_ulogic_vector;
				   CONSTANT r          : IN std_ulogic_vector;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       RETURN lt OR eq;
     END;
     -----------------------------------------------------------------------------
     FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN std_ulogic_vector;
				   CONSTANT r          : IN std_ulogic_vector;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN BOOLEAN IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF ((lt OR eq) = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegLessThanOrEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(lt Or eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN std_ulogic_vector;
				   CONSTANT r          : IN INTEGER;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN BOOLEAN IS
       VARIABLE temp_std  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.
       temp_std := To_StdULogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std, SrcRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF ((lt OR eq) = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegLessThanOrEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(lt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN INTEGER;
				   CONSTANT r          : IN std_ulogic_vector;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN BOOLEAN IS
       VARIABLE temp_std1  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
       temp_std1 := To_StdULogicVector (l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt,temp_std1, r, SrcRegMode);

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF ((lt Or eq) = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegLessThanOrEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(lt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN std_ulogic_vector;
				   CONSTANT r          : IN INTEGER;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN std_ulogic IS
       VARIABLE temp_std2 : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to logic vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp_std2 := To_StdULogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std2, SrcRegMode );

       RETURN lt OR eq;
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegLessThanOrEqual ( CONSTANT l          : IN INTEGER;
				   CONSTANT r          : IN std_ulogic_vector;
				   CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				 ) RETURN std_ulogic IS
       VARIABLE temp_std3    : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt     : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.

       temp_std3 := To_StdULogicVector ( l, IntegerBitLength, SrcRegMode );
       compare ( lt,eq,gt, temp_std3,r, SrcRegMode );

       RETURN lt OR eq;
     END;

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
     --     See Also      : compare, RegLessThan, RegLessThanOrEqual, RegGreaterThan,
     --                     RegGreaterThanOrEqual.
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThan ( CONSTANT l          : IN bit_vector;
			       CONSTANT r          : IN bit_vector;
			       CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			     ) RETURN bit IS
       VARIABLE lt,eq,gt : bit;
     BEGIN
     -- Use general bit_vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       RETURN gt;
     END;
     -----------------------------------------------------------------------------
     FUNCTION RegGreaterThan ( CONSTANT l           : IN bit_vector;
			       CONSTANT r           : IN bit_vector;
			       CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
			     ) RETURN BOOLEAN IS
       VARIABLE lt,eq,gt : bit;
     BEGIN
     -- Use general bit_vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       RETURN To_Boolean(gt);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION RegGreaterThan ( CONSTANT l          : IN bit_vector;
			       CONSTANT r          : IN INTEGER;
			       CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			     ) RETURN BOOLEAN IS
       VARIABLE temp1    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.
       temp1 := To_BitVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp1, SrcRegMode );

       RETURN To_Boolean(gt);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThan ( CONSTANT l          : IN INTEGER;
			       CONSTANT r          : IN bit_vector;
			       CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			     ) RETURN BOOLEAN IS
       VARIABLE temp_int2 : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : bit;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
       temp_int2 := To_BitVector (l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt,temp_int2, r, SrcRegMode );

       RETURN To_Boolean(gt);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThan  ( CONSTANT l          : IN bit_vector;
				CONSTANT r          : IN INTEGER;
				CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			      ) RETURN bit IS
       VARIABLE temp2    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp2 := To_BitVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp2, SrcRegMode);

       RETURN gt;
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThan (  CONSTANT l          : IN INTEGER;
				CONSTANT r          : IN bit_vector;
				CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			      ) RETURN bit IS
       VARIABLE temp3    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.

       temp3 := To_BitVector ( l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt, temp3,r, SrcRegMode );
       RETURN gt;
     END;

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
     --     See Also      : RegLessThan, RegLessThanOrEqual, RegGreaterThan, 
     --                     RegGreaterThanOrEqual.
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThan  ( CONSTANT l          : IN std_logic_vector;
				CONSTANT r          : IN std_logic_vector;
				CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			      ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       RETURN gt;
     END;
     -----------------------------------------------------------------------------
     FUNCTION RegGreaterThan (  CONSTANT l          : IN std_logic_vector;
				CONSTANT r          : IN std_logic_vector;
				CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			      ) RETURN BOOLEAN IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (gt = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegGreaterThan --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(gt);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION RegGreaterThan  ( CONSTANT l          : IN std_logic_vector;
				CONSTANT r          : IN INTEGER;
				CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			      ) RETURN BOOLEAN IS
       VARIABLE temp_std  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.
       temp_std := To_StdLogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std, SrcRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (gt = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegGreaterThan --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(gt);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThan (  CONSTANT l          : IN INTEGER;
				CONSTANT r          : IN std_logic_vector;
				CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			      ) RETURN BOOLEAN IS
       VARIABLE temp_std1  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
       temp_std1 := To_StdLogicVector (l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt, temp_std1, r, SrcRegMode);

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (gt = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegGreaterThan --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(gt);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThan  ( CONSTANT l          : IN std_logic_vector;
				CONSTANT r          : IN INTEGER;
				CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			      ) RETURN std_ulogic IS
       VARIABLE temp_std2 : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to logic vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp_std2 := To_StdLogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std2, SrcRegMode );

       RETURN gt;
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThan (  CONSTANT l          : IN INTEGER;
				CONSTANT r          : IN std_logic_vector;
				CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			      ) RETURN std_ulogic IS
       VARIABLE temp_std3    : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt     : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.

       temp_std3 := To_StdLogicVector ( l, IntegerBitLength, SrcRegMode );
       compare ( lt,eq,gt, temp_std3,r, SrcRegMode );

       RETURN gt;
     END;

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
     --     See Also      : RegLessThan, RegLessThanOrEqual, RegGreaterThan, 
     --                     RegGreaterThanOrEqual.
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThan  ( CONSTANT l          : IN std_ulogic_vector;
				CONSTANT r          : IN std_ulogic_vector;
				CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			      ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       RETURN gt;
     END;
     -----------------------------------------------------------------------------
     FUNCTION RegGreaterThan (  CONSTANT l          : IN std_ulogic_vector;
				CONSTANT r          : IN std_ulogic_vector;
				CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			      ) RETURN BOOLEAN IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (gt = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegGreaterThan --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(gt);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION RegGreaterThan  ( CONSTANT l          : IN std_ulogic_vector;
				CONSTANT r          : IN INTEGER;
				CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			      ) RETURN BOOLEAN IS
       VARIABLE temp_std  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.
       temp_std := To_StdULogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std, SrcRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (gt = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegGreaterThan --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(gt);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThan (  CONSTANT l          : IN INTEGER;
				CONSTANT r          : IN std_ulogic_vector;
				CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			      ) RETURN BOOLEAN IS
       VARIABLE temp_std1  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
       temp_std1 := To_StdULogicVector (l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt, temp_std1, r, SrcRegMode);

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF (gt = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegGreaterThan --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(gt);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThan  ( CONSTANT l          : IN std_ulogic_vector;
				CONSTANT r          : IN INTEGER;
				CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			      ) RETURN std_ulogic IS
       VARIABLE temp_std2 : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to logic vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp_std2 := To_StdULogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std2, SrcRegMode );

       RETURN gt;
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThan (  CONSTANT l          : IN INTEGER;
				CONSTANT r          : IN std_ulogic_vector;
				CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
			      ) RETURN std_ulogic IS
       VARIABLE temp_std3    : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt     : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.

       temp_std3 := To_StdULogicVector ( l, IntegerBitLength, SrcRegMode );
       compare ( lt,eq,gt, temp_std3,r, SrcRegMode );

       RETURN gt;
     END;

     -------------------------------------------------------------------------------
     --     Function Name : RegGreaterThanOrEqual
     -- 1.2.55
     --     Overloading   : Input parameter TYPEs.
     --
     --     Purpose       : Compute a greater than or equal relation for std_logic_vectors
     --
     --     Parameters    : l       - input bit_vector | INTEGER
     --                     r       - input bit_vector | INTEGER
     --                     SrcRegMode - input regmode_type, indicating the format of
     --                               the bit_vector operands (l,r).
     --                               Default is TwosComp.
     --
     --     Result        : BOOLEAN relation. A TRUE value is returned if: l >= r
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
     --     See Also      : compare, RegLessThan, RegLessThanOrEqual, RegGreaterThan,
     --                     RegGreaterThanOrEqual.
    -------------------------------------------------------------------------------
     FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN bit_vector;
				      CONSTANT r          : IN bit_vector;
				      CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				    ) RETURN bit IS
       VARIABLE lt,eq,gt : bit;
     BEGIN
     -- Use general bit_vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       RETURN gt OR eq;
     END;
     -----------------------------------------------------------------------------
     FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN bit_vector;
				      CONSTANT r          : IN bit_vector;
				      CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				   ) RETURN BOOLEAN IS
       VARIABLE lt,eq,gt : bit;
     BEGIN
     -- Use general bit_vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       RETURN To_Boolean(gt OR eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN bit_vector;
				      CONSTANT r          : IN INTEGER;
				      CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				    ) RETURN BOOLEAN IS
       VARIABLE temp1    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.
       temp1 := To_BitVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp1, SrcRegMode );

       RETURN To_Boolean(gt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN INTEGER;
				      CONSTANT r          : IN bit_vector;
				      CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				   ) RETURN BOOLEAN IS
       VARIABLE temp_int2 : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : bit;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
       temp_int2 := To_BitVector (l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt, temp_int2, r, SrcRegMode );

       RETURN To_Boolean(gt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN bit_vector;
				      CONSTANT r          : IN INTEGER;
				      CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				    ) RETURN bit IS
       VARIABLE temp2    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp2 := To_BitVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp2, SrcRegMode);

       RETURN gt OR eq;
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN INTEGER;
				      CONSTANT r          : IN bit_vector;
				      CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				    ) RETURN bit IS
       VARIABLE temp3    : bit_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt : bit;

     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.

       temp3 := To_BitVector ( l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt, temp3,r, SrcRegMode );
       RETURN gt OR eq;
     END;

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
				    ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       RETURN gt OR eq;
     END;
     -----------------------------------------------------------------------------
     FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN std_logic_vector;
				      CONSTANT r          : IN std_logic_vector;
				      CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				    ) RETURN BOOLEAN IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF ((gt OR eq) = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegGreaterThanOrEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(gt Or eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN std_logic_vector;
				      CONSTANT r          : IN INTEGER;
				      CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				    ) RETURN BOOLEAN IS
       VARIABLE temp_std  : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.
       temp_std := To_StdLogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std, SrcRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF ((gt OR eq) = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegGreaterThanOrEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(gt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN INTEGER;
				      CONSTANT r          : IN std_logic_vector;
				      CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				    ) RETURN BOOLEAN IS
       VARIABLE temp_std1 : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
       temp_std1 := To_StdLogicVector (l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt, temp_std1, r, SrcRegMode);

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF ((gt Or eq) = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegGreaterThanOrEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(gt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN std_logic_vector;
				      CONSTANT r          : IN INTEGER;
				      CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				    ) RETURN std_ulogic IS
       VARIABLE temp_std2 : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to logic vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp_std2 := To_StdLogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std2, SrcRegMode );

       RETURN gt OR eq;
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN INTEGER;
				      CONSTANT r          : IN std_logic_vector;
				      CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				    ) RETURN std_ulogic IS
       VARIABLE temp_std3    : std_logic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt     : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.

       temp_std3 := To_StdLogicVector ( l, IntegerBitLength, SrcRegMode );
       compare ( lt,eq,gt, temp_std3,r, SrcRegMode );

       RETURN gt OR eq;
     END;

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
     --     See Also      : RegLessThan, RegLessThanOrEqual, RegGreaterThan, 
     --                     RegGreaterThanOrEqual.
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN std_ulogic_vector;
				      CONSTANT r          : IN std_ulogic_vector;
				      CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				    ) RETURN std_ulogic IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       RETURN gt OR eq;
     END;
     -----------------------------------------------------------------------------
     FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN std_ulogic_vector;
				      CONSTANT r          : IN std_ulogic_vector;
				      CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				    ) RETURN BOOLEAN IS
       VARIABLE lt,eq,gt : std_ulogic;
     BEGIN
     -- Use general logic vector comparison  procedure.
       compare ( lt, eq, gt, l, r, SrcRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF ((gt OR eq) = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegGreaterThanOrEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(gt Or eq);
     END;
     -- -----------------------------------------------------------------------------
     FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN std_ulogic_vector;
				      CONSTANT r          : IN INTEGER;
				      CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				    ) RETURN BOOLEAN IS
       VARIABLE temp_std  : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.
       temp_std := To_StdULogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std, SrcRegMode );

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF ((gt OR eq) = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegGreaterThanOrEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(gt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN INTEGER;
				      CONSTANT r          : IN std_ulogic_vector;
				      CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				    ) RETURN BOOLEAN IS
       VARIABLE temp_std1 : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;
     BEGIN
     -- Convert to bit_vector for comparison to allow any length input vector.
     -- Use general comparison procedure .
       temp_std1 := To_StdULogicVector (l, IntegerBitLength, SrcRegMode);
       compare ( lt,eq,gt, temp_std1, r, SrcRegMode);

       -- if comparison is indeterminate ( 'X' ). It is converted to a boolean false
	 IF ((gt Or eq) = 'X') THEN
	    ASSERT NOT WarningsOn
	    REPORT " RegGreaterThanOrEqual --- Comparison is indeterminate returning FALSE "
	    SEVERITY WARNING;
	 END IF;

       RETURN To_Boolean(gt OR eq);
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN std_ulogic_vector;
				      CONSTANT r          : IN INTEGER;
				      CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				    ) RETURN std_ulogic IS
       VARIABLE temp_std2 : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt  : std_ulogic;

     BEGIN
     -- Convert to logic vector for comparison to allow any length input vector.
     -- Use general  comparison  for the calculation.

       temp_std2 := To_StdULogicVector ( r, IntegerBitLength, SrcRegMode );
       compare (lt,eq,gt, l, temp_std2, SrcRegMode );

       RETURN gt OR eq;
     END;
     -------------------------------------------------------------------------------
     FUNCTION RegGreaterThanOrEqual ( CONSTANT l          : IN INTEGER;
				      CONSTANT r          : IN std_ulogic_vector;
				      CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
				    ) RETURN std_ulogic IS
       VARIABLE temp_std3    : std_ulogic_vector(IntegerBitLength - 1 DOWNTO 0);
       VARIABLE lt,eq,gt     : std_ulogic;

     BEGIN
     -- Convert to  logic vector for comparison to allow any length input vector.
     -- Use general  comparison  procedure.

       temp_std3 := To_StdULogicVector ( l, IntegerBitLength, SrcRegMode );
       compare ( lt,eq,gt, temp_std3,r, SrcRegMode );

       RETURN gt OR eq;
     END;

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
                          ) RETURN bit_vector IS
      CONSTANT reslen   : INTEGER := DstLength;
      VARIABLE result   : bit_vector (reslen - 1 DOWNTO 0) := (OTHERS => '0');
      VARIABLE reg      : bit_vector (SrcReg'LENGTH - 1 DOWNTO 0) := SrcReg;
      VARIABLE sign     : bit;
      VARIABLE sign_pos : NATURAL; 
    --
    BEGIN
    --  null range check
      IF (SrcReg'LENGTH = 0) THEN
         IF (DstLength = 0) THEN
            ASSERT FALSE
            REPORT " SignExtend --- input register has null range" &
                " Destination has also null range "
            SEVERITY ERROR;
            RETURN result ;
         ELSE 
            ASSERT FALSE
            REPORT " SignExtend --- input register has null range" 
            SEVERITY ERROR;
            RETURN result ;
         END IF;

      ELSIF (DstLength = 0) THEN
          ASSERT false
          REPORT "SignExtend --- Destination length of zero was passed "
          SEVERITY ERROR;
          RETURN result;
     
      ELSIF (DstLength <= SrcReg'LENGTH) THEN
                        -- no need to sign extend
         ASSERT (DstLength = SrcReg'LENGTH) 
         REPORT " SignExtend ---  Destination length is not greater than source"
         SEVERITY ERROR;
         RETURN reg;            -- returns the input data without any change
      
      ELSIF ((SignBitPos < SrcReg'LOW ) OR ( SignBitPos > SrcReg'HIGH)) THEN
              ASSERT FALSE 
              REPORT " SignExtend --- Sign Position out of range "
              SEVERITY ERROR;   
                                --         result filled with zeros will be returned
      ELSE
        --  save the sign bit 
         sign := SrcReg(SignBitPos);
     
        --  calculate sign position sign-pos which will take care of
        --  ascending range as well as descinging range.
          sign_pos := (( (SrcReg'LENGTH - 1) - ABS ( SrcReg'LEFT - SignBitPos)));
         
        -- Copy the source register to variable result up to the sign position - 1.
             For i IN sign_pos - 1 DOWNTO 0 LOOP
                result(i) := reg(i);
             END LOOP;
 
          -- Extend the sign depending on the regmode.    
           CASE SrcRegMode IS
            WHEN TwosComp | OnesComp 
                          =>
                         For i IN reslen - 1 DOWNTO sign_pos Loop
                             result(i) := sign;
                         END LOOP;

            WHEN SignMagnitude 
                         =>
                         For i IN reslen - 2 DOWNTO sign_pos LOOP
                             result(i) := '0';
                         END LOOP;
                         result(reslen - 1) := sign;
            WHEN Unsigned
                       =>
                        -- when unsigned vector is passed just fill with    0's.
                        result := RegFill(SrcReg, reslen, '0');    
            WHEN OTHERS
                      => 
                         -- An unknown SrcRegMode value was passed
                        ASSERT FALSE
                          REPORT "SignExtend - Unknown vector mode"
                          SEVERITY ERROR;
           END CASE;
      END IF;
      RETURN result;
    END;

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
    --                      SrcRegMode    - input  regmode_type, indicating the format of
    --                                   the input std_logic_vector.   Default is TwosComp.
    --
    --     Result         : std_logic_vector, the extened std_logic_vector
    --
    --     NOTE           : The length of the return logic vector  is specified by the
    --                      parameter 'DstLength'. The input logic vector will 
    --                      be sign extended. 
    --
    --     Use            :
    --                      VARIABLE vect : std_logic_vector ( 15 DOWNTO 0 );
    --                      vect := SignExtend ( B"11111101", 16, 8, TwosComp ); -- set to -4
    --
    --     See Also       : RegFill
    -------------------------------------------------------------------------------
    FUNCTION SignExtend   ( CONSTANT SrcReg      : IN std_logic_vector;
                            CONSTANT DstLength   : IN NATURAL;
                            CONSTANT SignBitPos  : IN NATURAL;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN std_logic_vector IS
      CONSTANT reslen   : INTEGER := DstLength;
      VARIABLE result   : std_logic_vector (reslen - 1 DOWNTO 0) := (OTHERS => '0');
      VARIABLE reg      : std_logic_vector (SrcReg'LENGTH - 1 DOWNTO 0) := SrcReg;
      VARIABLE sign     : std_ulogic;
      VARIABLE sign_pos : NATURAL;
    --
    BEGIN
     --  null range check
      IF (SrcReg'LENGTH = 0) THEN
         IF (DstLength = 0) THEN
            ASSERT FALSE
            REPORT " SignExtend --- input register has null range" &
                " Destination has also null range "
            SEVERITY ERROR;
            RETURN result ;
         ELSE 
            ASSERT FALSE
            REPORT " SignExtend --- input register has null range" 
            SEVERITY ERROR;
            RETURN result ;
         END IF;

      ELSIF (DstLength = 0) THEN
          ASSERT false
          REPORT "SignExtend --- Destination length of zero was passed "
          SEVERITY ERROR;
          RETURN result;

      ELSIF (DstLength <= SrcReg'LENGTH) THEN
                        -- no need to sign extend
         ASSERT (DstLength = SrcReg'LENGTH)
         REPORT " SignExtend ---  Destination length is not greater than source"
         SEVERITY ERROR;
         RETURN To_X01(reg);        -- return the input data without any change
 
      ELSIF ((SignBitPos < SrcReg'LOW ) OR ( SignBitPos > SrcReg'HIGH)) THEN
              ASSERT FALSE 
              REPORT " SignExtend --- Sign Position out of range "
              SEVERITY ERROR;  
                                  -- result filled with zeros will be returned.
      ELSE
 
         --  save the sign bit
          sign := SrcReg(SignBitPos);
      
         --  calculate sign position sign-pos which will take care of
         --  ascending range as well as descinging range.
           sign_pos :=( (SrcReg'LENGTH - 1) - ABS ( SrcReg'LEFT - SignBitPos));
          
         -- Copy the source register to variable result up to the sign position - 1.
            For i IN sign_pos - 1 DOWNTO 0 LOOP
               result(i) := reg(i);
            END LOOP;
      
         -- Extend the sign depending on the regmode.
           CASE SrcRegMode IS
             WHEN TwosComp | OnesComp
                          =>
                         For i IN reslen - 1 DOWNTO sign_pos Loop
                             result(i) := sign;
                         END LOOP;
 
            WHEN SignMagnitude
                         =>
                         For i IN reslen - 2 DOWNTO sign_pos LOOP
                             result(i) := '0';
                         END LOOP;
                         result(reslen - 1) := sign;
            WHEN Unsigned
                       =>
                        -- when unsigned vector is passed just fill with    0's.
                        result := RegFill(SrcReg, reslen, '0');
            WHEN OTHERS
                       => 
                         -- An unknown SrcRegMode value was passed
                        ASSERT FALSE
                          REPORT "SignExtend - Unknown vector mode"
                          SEVERITY ERROR;
          END CASE;
      END IF;
      -- convert to X01
         result := To_X01(result);
      RETURN result;
    END;

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
    --                      SrcRegMode    - input  regmode_type, indicating the format of
    --                                   the input std_ulogic_vector.   Default is TwosComp.
    --
    --     Result         : std_ulogic_vector, the extened std_ulogic_vector
    --
    --     NOTE           : The length of the return logic vector  is specified by the
    --                      parameter 'DstLength'. The input logic vector will 
    --                      be sign extended. 
    --
    --     Use            :
    --                      VARIABLE vect : std_ulogic_vector ( 15 DOWNTO 0 );
    --                      vect := SignExtend ( B"11111101", 16, 8, TwosComp ); -- set to -4
    --
    --     See Also       : RegFill
    -------------------------------------------------------------------------------
    FUNCTION SignExtend   ( CONSTANT SrcReg      : IN std_ulogic_vector;
                            CONSTANT DstLength   : IN NATURAL;
                            CONSTANT SignBitPos  : IN NATURAL;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic_vector IS
      CONSTANT reslen   : INTEGER := DstLength;
      VARIABLE result   : std_ulogic_vector (reslen - 1 DOWNTO 0) := (OTHERS => '0');
      VARIABLE reg      : std_ulogic_vector (SrcReg'LENGTH - 1 DOWNTO 0) := SrcReg;
      VARIABLE sign     : std_ulogic;
      VARIABLE sign_pos : NATURAL;
    --
    BEGIN
     --  null range check
      IF (SrcReg'LENGTH = 0) THEN
         IF (DstLength = 0) THEN
            ASSERT FALSE
            REPORT " SignExtend --- input register has null range" &
                " Destination has also null range "
            SEVERITY ERROR;
            RETURN result ;
         ELSE 
            ASSERT FALSE
            REPORT " SignExtend --- input register has null range" 
            SEVERITY ERROR;
            RETURN result ;
         END IF;

      ELSIF (DstLength = 0) THEN
          ASSERT false
          REPORT "SignExtend --- Destination length of zero was passed "
          SEVERITY ERROR;
          RETURN result;

      ELSIF (DstLength <= SrcReg'LENGTH) THEN
                        -- no need to sign extend
         ASSERT (DstLength = SrcReg'LENGTH)
         REPORT " SignExtend ---  Destination length is not greater than source"
         SEVERITY ERROR;
         RETURN To_X01(reg);        -- return the input data without any change
 
      ELSIF ((SignBitPos < SrcReg'LOW ) OR ( SignBitPos > SrcReg'HIGH)) THEN
              ASSERT FALSE 
              REPORT " SignExtend --- Sign Position out of range "
              SEVERITY ERROR;  
                                  -- result filled with zeros will be returned.
      ELSE
 
         --  save the sign bit
          sign := SrcReg(SignBitPos);
      
         --  calculate sign position sign-pos which will take care of
         --  ascending range as well as descinging range.
           sign_pos :=( (SrcReg'LENGTH - 1) - ABS ( SrcReg'LEFT - SignBitPos));
          
         -- Copy the source register to variable result up to the sign position - 1.
            For i IN sign_pos - 1 DOWNTO 0 LOOP
               result(i) := reg(i);
            END LOOP;
      
         -- Extend the sign depending on the regmode.
           CASE SrcRegMode IS
             WHEN TwosComp | OnesComp
                          =>
                         For i IN reslen - 1 DOWNTO sign_pos Loop
                             result(i) := sign;
                         END LOOP;
 
            WHEN SignMagnitude
                         =>
                         For i IN reslen - 2 DOWNTO sign_pos LOOP
                             result(i) := '0';
                         END LOOP;
                         result(reslen - 1) := sign;
            WHEN Unsigned
                       =>
                        -- when unsigned vector is passed just fill with    0's.
                        result := RegFill(SrcReg, reslen, '0');
            WHEN OTHERS
                       => 
                         -- An unknown SrcRegMode value was passed
                        ASSERT FALSE
                          REPORT "SignExtend - Unknown vector mode"
                          SEVERITY ERROR;
          END CASE;
      END IF;
      -- convert to X01
         result := To_X01(result);
      RETURN result;
    END;

    -------------------------------------------------------------------------------
    --     Function Name  : RegFill
    -- 1.7.3
    --     Overloading    : None
    --
    --     Purpose        : Fill the most significant bits of a register with a given value
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
                       ) RETURN bit_vector IS
      CONSTANT reslen : INTEGER := DstLength;
      VARIABLE result : bit_vector (reslen - 1 DOWNTO 0) := (OTHERS => '0');
      VARIABLE  reg   : bit_vector (SrcReg'LENGTH - 1 DOWNTO 0) := SrcReg;
    --
    BEGIN
      --  null range check
      IF (SrcReg'LENGTH = 0) THEN
         IF (DstLength = 0) THEN
            ASSERT FALSE
            REPORT " RegFill --- input  has null range and" &
                " Destination also has null range. "
            SEVERITY ERROR;
            RETURN result ;
         ELSE
            ASSERT FALSE
            REPORT " RegFill --- input  has null range"
            SEVERITY ERROR;
            result := (OTHERS => FillVal);
            RETURN result ;
         END IF;
 
      ELSIF (DstLength = 0) THEN
          ASSERT false
          REPORT "RegFill --- Destination has null range "
          SEVERITY ERROR;
          RETURN result;
 
      ELSIF (DstLength <= SrcReg'LENGTH) THEN
                        -- no need to sign extend
         ASSERT (DstLength = SrcReg'LENGTH)
         REPORT " RegFill ---  Destination length is less than source"
         SEVERITY ERROR;
         RETURN reg;        -- return the input data without any change

       ELSE
           result(SrcReg'LENGTH - 1 DOWNTO 0) := reg;
        -- Fill the MSB's of result with the given fill value.
          For i IN reslen - 1 DOWNTO SrcReg'LENGTH  Loop
             result(i) := FillVal;
          END LOOP;
       END IF;
    
    -- That's all
       RETURN result;
    END;

 
    -------------------------------------------------------------------------------
    --     Function Name  : RegFill
    -- 1.7.4
    --     Overloading    : None
    --
    --     Purpose        : Fill an std_logic_vector with a given value
    --
    --     Parameters     :
    --                      SrcReg     - input  std_logic_vector, the  logic vector to be read.
    --                      DstLength  - input  NATURAL, length of the return logic vector.
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
   -------------------------------------------------------------------------------
    FUNCTION RegFill   ( CONSTANT SrcReg      : IN std_logic_vector;
                         CONSTANT DstLength   : IN NATURAL;
                         CONSTANT FillVal     : IN std_ulogic   := '0'
                       ) RETURN std_logic_vector IS
      CONSTANT reslen : INTEGER := DstLength;
      VARIABLE result : std_logic_vector (reslen - 1 DOWNTO 0) := (OTHERS => '0');
      VARIABLE reg    : std_logic_vector (SrcReg'LENGTH - 1 DOWNTO 0) := SrcReg;
    BEGIN
     --  null range check
      IF (SrcReg'LENGTH = 0) THEN
         IF (DstLength = 0) THEN
            ASSERT FALSE
            REPORT " RegFill --- input  has null range and" &
                " Destination also has null range. "
            SEVERITY ERROR;
            RETURN result ; 
         ELSE
            ASSERT FALSE
            REPORT " RegFill --- input  has null range"
            SEVERITY ERROR;
            result := (OTHERS => FillVal);
            RETURN result ; 
         END IF;
 
      ELSIF (DstLength = 0) THEN
          ASSERT false
          REPORT "RegFill --- Destination has null range "
          SEVERITY ERROR;
          RETURN result;   
 
      ELSIF (DstLength <= SrcReg'LENGTH) THEN
                        -- no need to sign extend
         ASSERT (DstLength = SrcReg'LENGTH)
         REPORT " RegFill ---  Destination length is less than source"
         SEVERITY ERROR;
         RETURN reg;        -- return the input data without any change
 
      ELSE
           result(SrcReg'LENGTH - 1 DOWNTO 0) := reg;
        -- Fill the MSB's of result with the given fill value.
          For i IN reslen - 1 DOWNTO SrcReg'LENGTH  Loop
             result(i) := FillVal;
          END LOOP;
      END IF;
    
      -- convert to X01
         result := To_X01(result);
    -- That's all
       RETURN result;
    END;


    -------------------------------------------------------------------------------
    --     Function Name  : RegFill
    -- 
    --     Overloading    : None
    --
    --     Purpose        : Fill an std_ulogic_vector with a given value
    --
    --     Parameters     :
    --                      SrcReg     - input  std_ulogic_vector, the  logic vector to be read.
    --                      DstLength  - input  NATURAL, length of the return logic vector.
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
                       ) RETURN std_ulogic_vector IS
      CONSTANT reslen : INTEGER := DstLength;
      VARIABLE result : std_ulogic_vector (reslen - 1 DOWNTO 0) := (OTHERS => '0');
      VARIABLE reg    : std_ulogic_vector (SrcReg'LENGTH - 1 DOWNTO 0) := SrcReg;
    BEGIN
     --  null range check
      IF (SrcReg'LENGTH = 0) THEN
         IF (DstLength = 0) THEN
            ASSERT FALSE
            REPORT " RegFill --- input  has null range and" &
                " Destination also has null range. "
            SEVERITY ERROR;
            RETURN result ; 
         ELSE
            ASSERT FALSE
            REPORT " RegFill --- input  has null range"
            SEVERITY ERROR;
            result := (OTHERS => FillVal);
            RETURN result ; 
         END IF;
 
      ELSIF (DstLength = 0) THEN
          ASSERT false
          REPORT "RegFill --- Destination length of zero was passed "
          SEVERITY ERROR;
          RETURN result;   
 
      ELSIF (DstLength <= SrcReg'LENGTH) THEN
                        -- no need to sign extend
         ASSERT (DstLength = SrcReg'LENGTH)
         REPORT " RegFill ---  Destination length is less than source"
         SEVERITY ERROR;
         RETURN reg;        -- return the input data without any change
 
      ELSE
           result(SrcReg'LENGTH - 1 DOWNTO 0) := reg;
        -- Fill the MSB's of result with the given fill value.
          For i IN reslen - 1 DOWNTO SrcReg'LENGTH  Loop
             result(i) := FillVal;
          END LOOP;
      END IF;
    
      -- convert to X01
         result := To_X01(result);
    -- That's all
       RETURN result;
    END;

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
                          ) RETURN BIT_VECTOR IS
      VARIABLE result : BIT_VECTOR (SrcReg'LENGTH - 1 DOWNTO  0);
    --
    BEGIN
    --
    --  call appropriate function depending on destination mode.
       CASE DstRegMode IS
          WHEN TwosComp
                        =>
                         result := To_TwosComp(SrcReg, SrcRegMode);
          WHEN OnesComp
                        =>
                          result := To_OnesComp(SrcReg, SrcRegMode); 
 
          WHEN SignMagnitude
                        =>
                          result := To_SignMag(SrcReg, SrcRegMode);
 
          WHEN Unsigned
                        =>
                        result := To_Unsign(SrcReg, SrcRegMode); 
          WHEN OTHERS
                        =>
                        -- An unknown SrcRegMode value was passed
                        ASSERT FALSE
                          REPORT "ConvertMode - Unknown DstRegMode passed."
                          SEVERITY ERROR;
        END CASE;
        RETURN result;
    END;
 
--+-----------------------------------------------------------------------------
--|     Function Name  : ConvertMode
--| 1.8.1
--|     Overloading    : None
--| 
--|     Purpose        : Convert a std_logic_vector  from source mode to destination mode. 
--| 
--|     Parameters     :
--|                      SrcReg     - input  std_logic_vector, the vector to be read.
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                   the input std_logic_vector.   Default is TwosComp.
--|                      DstRegMode - input regmode_type, indicating the format of
--|                                   the output std_logic_vector.
--|
--|     Result         : std_logic_vector, the vector in the notation specified 
--|                      by  the destination mode.
--|
--|
--|     Use            :
--|                      VARIABLE vect : std_logic_vector ( 15 DOWNTO 0 );
--|                      vect := ConvertMode ( B"0101",UnSigned, TwosComp ); -- set to +5
--|
--|     See Also       : To_TwosComp, To_OnesComp, To_Unsign, To_SignMag
--|-----------------------------------------------------------------------------
    FUNCTION ConvertMode  ( CONSTANT SrcReg      : IN std_logic_vector;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode;
                            CONSTANT DstRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN std_logic_vector IS
      VARIABLE result : std_logic_vector (SrcReg'LENGTH - 1 DOWNTO 0);
    
    BEGIN
    --
    -- call appropraite function depending on the destination mode

       CASE DstRegMode IS
          WHEN TwosComp
                        =>
                         result := To_TwosComp(SrcReg, SrcRegMode);
          WHEN OnesComp
                        =>
                          result := To_OnesComp(SrcReg, SrcRegMode);
 
          WHEN SignMagnitude
                        =>
                          result := To_SignMag(SrcReg, SrcRegMode);
 
          WHEN Unsigned
                        =>
                        result := To_Unsign(SrcReg, SrcRegMode);
          WHEN OTHERS
                        =>
                        -- An unknown SrcRegMode value was passed
                          ASSERT FALSE
                          REPORT "ConvertMode - Unknown DstRegMode passed."
                          SEVERITY ERROR;
        END CASE;
        RETURN result;
    END;

--+-----------------------------------------------------------------------------
--|     Function Name  : ConvertMode
--| 1.8.1
--|     Overloading    : None
--| 
--|     Purpose        : Convert an std_ulogic_vector from source mode to destination mode. 
--| 
--|     Parameters     :
--|                      SrcReg     - input  std_ulogic_vector, the vector to be read.
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                   the input std_ulogic_vector.   Default is TwosComp.
--|                      DstRegMode - input regmode_type, indicating the format of
--|                                   the output std_ulogic_vector.
--|
--|     Result         : std_ulogic_vector, the vector in the notation specified 
--|                      by  the destination mode.
--|
--|
--|     Use            :
--|                      VARIABLE vect : std_ulogic_vector ( 15 DOWNTO 0 );
--|                      vect := ConvertMode ( "0101",UnSigned, TwosComp ); -- set to +5
--|
--|     See Also       : To_TwosComp, To_OnesComp, To_Unsign, To_SignMag
--|-----------------------------------------------------------------------------
    FUNCTION ConvertMode  ( CONSTANT SrcReg      : IN std_ulogic_vector;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode;
                            CONSTANT DstRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN std_ulogic_vector IS
      VARIABLE result : std_ulogic_vector (SrcReg'LENGTH - 1 DOWNTO 0);
    
    BEGIN
    --
    -- call appropraite function depending on the destination mode

       CASE DstRegMode IS
          WHEN TwosComp
                        =>
                         result := To_TwosComp(SrcReg, SrcRegMode);
          WHEN OnesComp
                        =>
                          result := To_OnesComp(SrcReg, SrcRegMode);
 
          WHEN SignMagnitude
                        =>
                          result := To_SignMag(SrcReg, SrcRegMode);
 
          WHEN Unsigned
                        =>
                        result := To_Unsign(SrcReg, SrcRegMode);
          WHEN OTHERS
                        =>
                        -- An unknown SrcRegMode value was passed
                          ASSERT FALSE
                          REPORT "ConvertMode - Unknown DstRegMode passed."
                          SEVERITY ERROR;
        END CASE;
        RETURN result;
    END;
 
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
--|     See Also       : To_BitVector, To_Integer, To_TwosComp
--|-----------------------------------------------------------------------------
    FUNCTION To_TwosComp  ( CONSTANT SrcReg      : IN BIT_VECTOR;
                            CONSTANT SrcRegMode  : IN regmode_type := DefaultRegMode
                          ) RETURN BIT_VECTOR IS
      CONSTANT reglen    : INTEGER := SrcReg'LENGTH;
      VARIABLE reg_copy  : BIT_VECTOR (reglen - 1 DOWNTO 0) := SrcReg;
      VARIABLE result    : BIT_VECTOR (reglen - 1 DOWNTO 0);

    --
    BEGIN
  
    --  Check for null input
      IF (SrcReg'LENGTH = 0) THEN
          ASSERT false
          REPORT " To_TwosComp --- input register has zero length,  "
	     & " Returning vector with zero length "
          SEVERITY ERROR;
          RETURN reg_copy;

      ELSE
          result := reg_copy;

          -- convert to two,s complement representation.
          CASE SrcRegMode IS
             WHEN TwosComp   =>  -- no translation required
                        NULL;

             WHEN OnesComp  => -- if a negative value, increment in 1's comp
                               -- representation to form the 2's comp rep.
                             IF (reg_copy(reglen - 1) /= '0') THEN
                               result := RegInc (reg_copy, TwosComp);
                             END IF;
 
             WHEN SignMagnitude   =>  -- if a negative value, clear the sign bit (forming
                                      -- a positive 2's comp value, and then negate this value
                             IF (reg_copy(reglen - 1) /= '0') THEN
                                 reg_copy(reglen - 1) := '0';
                                 result := RegNegate ( reg_copy, TwosComp );
                             END IF;
 
             WHEN Unsigned  => -- if MSB is '1' then the number is larger than what
                               -- could be accommodated in the  register. 
                             IF (reg_copy(reglen - 1) /= '0') THEN
                               ASSERT false
                               REPORT "To_TwosComp - MSB of unsigned bit_vector   (" 
                                      & TO_String(reg_copy)  & ") is not '0'. it cannot be converted "
                               SEVERITY Error; 
                             END IF;

             WHEN OTHERS    =>  -- An unknown SrcRegMode value was passed
                              ASSERT FALSE
                              REPORT "To_TwosComp - Unknown vector mode"
                              SEVERITY ERROR;
           END CASE;
        END IF;
        RETURN result;
    END To_TwosComp;
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
                          ) RETURN std_logic_vector IS
      CONSTANT reglen    : INTEGER := SrcReg'LENGTH;
      VARIABLE reg_copy : std_logic_vector (reglen - 1 DOWNTO 0) := SrcReg;
      VARIABLE result    : std_logic_vector (reglen - 1 DOWNTO 0);
    --
    BEGIN
    --  Check for null input
      IF (SrcReg'LENGTH = 0) THEN
          ASSERT false
          REPORT " To_TwosComp --- input register has null range "
          SEVERITY ERROR;
          RETURN reg_copy;

      ELSE
          result := reg_copy;

          -- convert to two's complement representation.
          CASE SrcRegMode IS
             WHEN TwosComp    =>   -- no translation required
                                NULL;

             WHEN OnesComp    =>  -- if a negative value, increment in 1's comp
                                  -- representation to form the 2's comp rep.
                               IF (reg_copy(reglen - 1) /= '0') THEN
                                 result := RegInc (reg_copy, TwosComp);
                               END IF;

             WHEN SignMagnitude  => -- if a negative value, clear the sign bit (forming
                                    -- a positive 2's comp value, and then negate this value
                               IF (reg_copy(reglen - 1) /= '0') THEN
                                  reg_copy(reglen - 1) := '0';
                                  result := RegNegate ( reg_copy, TwosComp );
                               END IF;

              WHEN Unsigned      =>  -- if MSB is '1' or 'X' then the number is larger than what
                                     -- could be accommodated in the  register.
                               IF (reg_copy(reglen -1) /= '0') THEN
                                   ASSERT false
                                   REPORT "To_TwosComp - MSB of unsigned std_logic_vector   (" 
                                     & To_String(reg_copy)  & ") is not '0'. it cannot be converted "
                                   SEVERITY ERROR;
                               END IF;

             WHEN OTHERS         =>   -- An unknown SrcRegMode value was passed
                               ASSERT FALSE 
                               REPORT "To_TwosComp - Unknown vector mode"
                               SEVERITY ERROR;
            END CASE;
        END IF;
        RETURN result;
    END To_TwosComp;
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
                          ) RETURN std_ulogic_vector IS
      CONSTANT reglen    : INTEGER := SrcReg'LENGTH;
      VARIABLE reg_copy : std_ulogic_vector (reglen - 1 DOWNTO 0) := SrcReg;
      VARIABLE result    : std_ulogic_vector (reglen - 1 DOWNTO 0);
    --
    BEGIN
    --  Check for null input
      IF (SrcReg'LENGTH = 0) THEN
          ASSERT false
          REPORT " To_TwosComp --- input register has null range "
          SEVERITY ERROR;
          RETURN reg_copy;

      ELSE
          result := reg_copy;

          -- convert to two's complement representation.
          CASE SrcRegMode IS
             WHEN TwosComp     => -- no translation required
                               NULL;

             WHEN OnesComp     => -- if a negative value, increment in 1's comp
                                  -- representation to form the 2's comp rep.
                                 IF (reg_copy(reglen - 1) /= '0') THEN
                                   result := RegInc (reg_copy, TwosComp);
                                 END IF;

             WHEN SignMagnitude  => -- if a negative value, clear the sign bit (forming
                                    -- a positive 2's comp value, and then negate this value
                                 IF (reg_copy(reglen - 1) /= '0') THEN
                                    reg_copy(reglen - 1) := '0';
                                    result := RegNegate ( reg_copy, TwosComp );
                                 END IF;

              WHEN Unsigned       => -- if MSB is '1'  or 'X' then the number is larger than 
                                     --  what could be accommodated in the  register.
                                 IF (reg_copy(reglen -1) /= '0') THEN
                                    ASSERT false
                                    REPORT "To_TwosComp - MSB of unsigned std_ulogic_vector   (" 
                                    & To_String(reg_copy)  & ") is not '0'. it cannot be converted "
                                    SEVERITY ERROR;
                                 END IF;

             WHEN OTHERS         =>  -- An unknown SrcRegMode value was passed
                                ASSERT FALSE 
                                REPORT "To_TwosComp - Unknown vector mode"
                               SEVERITY ERROR;
            END CASE;
        END IF;
        RETURN result;
    END To_TwosComp;

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
                          ) RETURN BIT_VECTOR IS
      CONSTANT reglen    : INTEGER := SrcReg'LENGTH;
      VARIABLE reg_copy  : BIT_VECTOR (reglen - 1 DOWNTO 0) := SrcReg;
      VARIABLE result    : BIT_VECTOR (reglen - 1 DOWNTO 0);

    --
    BEGIN
  
    --  Check for null input
      IF (SrcReg'LENGTH = 0) THEN
          ASSERT false
          REPORT " To_OnesComp --- input register has null range "
          SEVERITY ERROR;
          RETURN reg_copy;

      ELSE
          result := reg_copy;

          -- convert to one's complement representation.
          CASE SrcRegMode IS
             WHEN TwosComp     => -- if a negative value, decrement in Two's comp
                                  -- representation to form the One's comp rep. 
                                  -- Twos Comp can have one more -ve number than ones
                                  -- test for largest negative number if it happen    
                                  -- wrap around to largest positive and print a message.
                               IF (reg_copy(reglen - 1) /= '0') THEN
				   IF (All_Zero(reg_copy(reglen-2 DOWNTO 0))) THEN
					assert Not WarningsOn
					report " To_OnesComp --- largest negative TwosComp number" 
					  	& " will be wrapped around to largest positive number" 
                                                & " when converted to OnesComp notation. " 
                                        severity Warning;
					result := (others => '1');
					result(result'LEFT) := '0';
                                   ELSE
                                        result := RegDec (reg_copy, OnesComp);
                                   END IF;

                               END IF;

             WHEN OnesComp      =>  -- no translation required
                               NULL;
 
             WHEN SignMagnitude => -- if a negative value, clear the sign bit (forming
                                    -- a positive One's comp value, and then negate this value
                               IF (reg_copy(reglen - 1) /= '0') THEN
                                  reg_copy(reglen - 1) := '0';
                                  result := RegNegate ( reg_copy, OnesComp );
                               END IF;
 
             WHEN Unsigned      =>  -- if MSB is '1' then the number is larger than what
                                    -- could be accommodated in the  register.
                                IF (reg_copy(reglen - 1) /= '0') THEN
                                   ASSERT false
                                   REPORT "To_OnesComp - MSB of unsigned bit_vector   (" 
                                     & To_String(reg_copy)  & ") is not '0'. it cannot be converted "
                                   SEVERITY ERROR;
                                END IF;

              WHEN OTHERS       =>  -- An unknown SrcRegMode value was passed
                                ASSERT FALSE
                                REPORT "To_OnesComp - Unknown vector mode "
                               SEVERITY ERROR;
          END CASE;
        END IF;
        RETURN result;
    END To_OnesComp;
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
                          ) RETURN std_logic_vector IS
      CONSTANT reglen    : INTEGER := SrcReg'LENGTH;
      VARIABLE reg_copy : std_logic_vector (reglen - 1 DOWNTO 0) := SrcReg;
      VARIABLE result    : std_logic_vector (reglen - 1 DOWNTO 0);
    --
    BEGIN
    --  Check for null input
      IF (SrcReg'LENGTH = 0) THEN
          ASSERT false
          REPORT " To_OnesComp --- input register has null range "
          SEVERITY ERROR;
          RETURN reg_copy;

      ELSE
          result := reg_copy;

          -- convert to one's complement representation.
          CASE SrcRegMode IS
             WHEN TwosComp  =>  -- if a negative value, decrement in Two's comp
                                  -- representation to form the One's comp rep. 
                                  -- Twos Comp can have one more -ve number than ones
                                  -- test for largest negative number if it happen    
                                  -- wrap around to largest positive and print a message.
                               IF (reg_copy(reglen - 1) /= '0') THEN
				   IF (All_Zero(reg_copy(reglen-2 DOWNTO 0))) THEN
					assert Not WarningsOn
					report " To_OnesComp --- largest negative TwosComp number" 
  			  	         & " will be wrapped around to largest positive number" 
                                         & " when converted to OnesComp notation. " 
                                        severity Warning;
					result := (others => '1');
					result(result'LEFT) := '0';
                                   ELSE
                                        result := RegDec (reg_copy, OnesComp);
                                   END IF;

                               END IF;

             WHEN OnesComp   => -- no translation required
                           NULL;
 
             WHEN SignMagnitude  => -- if a negative value, clear the sign bit (forming
                                    -- a positive One's comp value, and then negate this value
                          IF (reg_copy(reglen - 1) /= '0') THEN
                            reg_copy(reglen - 1) := '0';
                            result := RegNegate ( reg_copy, OnesComp );
                          END IF;
 
             WHEN Unsigned  =>  -- if MSB is '1' or X then the number is larger than what
                                -- could be accommodated in the  register.
                          IF (reg_copy(reglen - 1) /= '0') THEN  
                            ASSERT false
                            REPORT "To_OnesComp - MSB of unsigned std_logic_vector   (" 
                                   & To_String(reg_copy)  & ") is not '0'. it cannot be converted "
                             SEVERITY ERROR;
                          END IF;

             WHEN OTHERS    =>  -- An unknown SrcRegMode value was passed
                          ASSERT FALSE
                          REPORT "To_OnesComp - Unknown vector mode"
                          SEVERITY ERROR;
          END CASE;
        END IF;
        RETURN result;
    END To_OnesComp;
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
                          ) RETURN std_ulogic_vector IS
      CONSTANT reglen    : INTEGER := SrcReg'LENGTH;
      VARIABLE reg_copy : std_ulogic_vector (reglen - 1 DOWNTO 0) := SrcReg;
      VARIABLE result    : std_ulogic_vector (reglen - 1 DOWNTO 0);
    --
    BEGIN
    --  Check for null input
      IF (SrcReg'LENGTH = 0) THEN
          ASSERT false
          REPORT " To_OnesComp --- input register has null range "
          SEVERITY ERROR;
          RETURN reg_copy;

      ELSE
          result := reg_copy;
          -- convert to one's complement representation.
          CASE SrcRegMode IS
             WHEN TwosComp    =>  -- if a negative value, decrement in Two's comp
                                  -- representation to form the One's comp rep. 
                                  -- Twos Comp can have one more -ve number than ones
                                  -- test for largest negative number if it happen    
                                  -- wrap around to largest positive and print a message.
                               IF (reg_copy(reglen - 1) /= '0') THEN
				   IF (All_Zero(reg_copy(reglen-2 DOWNTO 0))) THEN
					assert Not WarningsOn
					report " To_OnesComp --- largest negative TwosComp number" 
					  & " will be wrapped around to largest positive number" 
                                          & " when converted to OnesComp notation. " 
                                        severity Warning;
					result := (others => '1');
					result(result'LEFT) := '0';
                                   ELSE
                                        result := RegDec (reg_copy, OnesComp);
                                   END IF;
                               END IF;

             WHEN OnesComp     =>  -- no translation required
                              NULL;
 
             WHEN SignMagnitude   =>
                                -- if a negative value, clear the sign bit (forming
                                -- a positive One's comp value, and then negate this value
                                IF (reg_copy(reglen - 1) /= '0') THEN
                                   reg_copy(reglen - 1) := '0';
                                   result := RegNegate ( reg_copy, OnesComp );
                                END IF;
 
             WHEN Unsigned     =>  -- if MSB is '1' or X then the number is larger than what
                                   -- could be accommodated in the  register.
                                IF (reg_copy(reglen - 1) /= '0') THEN  
                                   ASSERT false
                                   REPORT "To_OnesComp - MSB of unsigned std_ulogic_vector   (" 
                                   & To_String(reg_copy)  & ") is not '0'. it cannot be converted "
                                   SEVERITY ERROR;
                                END IF;

             WHEN OTHERS       =>  -- An unknown SrcRegMode value was passed
                               ASSERT FALSE
                               REPORT "To_OnesComp - Unknown vector mode"
                               SEVERITY ERROR;
          END CASE;
        END IF;
        RETURN result;
    END To_OnesComp;
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
                          ) RETURN BIT_VECTOR IS
      CONSTANT reglen    : INTEGER := SrcReg'LENGTH;
      VARIABLE reg_copy : BIT_VECTOR (reglen - 1 DOWNTO 0) := SrcReg;
      VARIABLE result    : BIT_VECTOR (reglen - 1 DOWNTO 0);

    --
    BEGIN
  
    --  Check for null input
      IF (SrcReg'LENGTH = 0) THEN
          ASSERT false
          REPORT " To_Unsign --- input register has null range "
          SEVERITY ERROR;
          RETURN reg_copy;

      ELSE
          result := reg_copy;

          -- convert to unsigned representation.
          CASE SrcRegMode IS
             WHEN TwosComp   =>	  -- if a negative value, take two's comp it
                                   -- will become unsigned
                              IF (reg_copy(reglen - 1) /= '0') THEN
                                  -- if largest negative number then no conversion required
    	    		   	  IF (NOT All_Zero(reg_copy(reglen-2 DOWNTO 0))) THEN
                                     result := RegNegate ( reg_copy, TwosComp);
                                  END IF;   
                              END IF;

             WHEN OnesComp    =>  -- if a negative value, take one's comp
                                  -- it will become unsigned.
                              IF (reg_copy(reglen - 1) /= '0') THEN
                                result := RegNegate (reg_copy, OnesComp);
                              END IF;
 
             WHEN SignMagnitude   =>  -- if a negative value, clear the sign bit 
                                      -- ( forming the unsigned) 
                                  IF (result(reglen - 1) /= '0') THEN
                                    result(reglen - 1) := '0';
                                  END IF;
 
             WHEN unsigned   =>  --  no translation required.
                               NULL;
       
             WHEN OTHERS     =>   -- An unknown SrcRegMode value was passed
                              ASSERT FALSE
                              REPORT "To_Unsign - Unknown vector mode"
                              SEVERITY ERROR;
           END CASE;
        END IF;
        RETURN result;
    END To_Unsign;
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
                          ) RETURN std_logic_vector IS
      CONSTANT reglen    : INTEGER := SrcReg'LENGTH;
      VARIABLE reg_copy : std_logic_vector (reglen - 1 DOWNTO 0) := SrcReg;
      VARIABLE result    : std_logic_vector (reglen - 1 DOWNTO 0);
    --
    BEGIN
    --  Check for null input
      IF (SrcReg'LENGTH = 0) THEN
          ASSERT false
          REPORT " To_Unsign --- input register has null range "
          SEVERITY ERROR;
          RETURN reg_copy;

      ELSE
          result := reg_copy;
          -- convert to unsigned representation.
          CASE SrcRegMode IS
             WHEN TwosComp     => -- if a negative value, take two's comp it
                                   -- will become unsigned
                              IF (reg_copy(reglen - 1) /= '0') THEN
                                  -- if largest negative number then no conversion required
    	    		   	  IF (NOT All_Zero(reg_copy(reglen-2 DOWNTO 0))) THEN
                                     result := RegNegate ( reg_copy, TwosComp);
                                  END IF;   
                              END IF;

             WHEN OnesComp     =>  -- if a negative value, RegNegate 
                                   -- it will become unsigned.
                               IF (reg_copy(reglen - 1) /= '0') THEN
                                result := RegNegate (reg_copy, OnesComp);
                               END IF;
 
             WHEN SignMagnitude
                             =>
                        -- if a negative value, clear the sign bit (forming
                        -- the unsigned) 
                        IF (result(reglen - 1) /= '0') THEN
                          result(reglen - 1) := '0';
                        END IF;
 
             WHEN unsigned
                           =>
                        --  no translation required.
                        NULL;
             WHEN OTHERS
                           =>
                        -- An unknown SrcRegMode value was passed
                        ASSERT FALSE
                          REPORT "To_Unsign - Unknown vector mode"
                          SEVERITY ERROR;
           END CASE;
        END IF;
        RETURN result;
    END To_Unsign;

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
                          ) RETURN std_ulogic_vector IS
      CONSTANT reglen    : INTEGER := SrcReg'LENGTH;
      VARIABLE reg_copy : std_ulogic_vector (reglen - 1 DOWNTO 0) := SrcReg;
      VARIABLE result    : std_ulogic_vector (reglen - 1 DOWNTO 0);
    --
    BEGIN
    --  Check for null input
      IF (SrcReg'LENGTH = 0) THEN
          ASSERT false
          REPORT " To_Unsign --- input register has null range "
          SEVERITY ERROR;
          RETURN reg_copy;

      ELSE
          result := reg_copy;
          -- convert to unsigned representation.
          CASE SrcRegMode IS
             WHEN TwosComp     => -- if a negative value, take two's comp it
                                   -- will become unsigned
                              IF (reg_copy(reglen - 1) /= '0') THEN
                                  -- if largest negative number then no conversion required
    	    		   	  IF (NOT All_Zero(reg_copy(reglen-2 DOWNTO 0))) THEN 
                                     result := RegNegate ( reg_copy, TwosComp);
                                  END IF;   
                              END IF;

             WHEN OnesComp    =>  -- if a negative value, RegNegate 
                                  -- it will become unsigned.
                              IF (reg_copy(reglen - 1) /= '0') THEN
                                result := RegNegate (reg_copy, OnesComp);
                              END IF;
 
             WHEN SignMagnitude  =>  -- if a negative value, clear the sign bit (forming
                                     -- the unsigned) 
                               IF (result(reglen - 1) /= '0') THEN
                                  result(reglen - 1) := '0';
                               END IF;
 
             WHEN unsigned      =>   --  no translation required.
                               NULL;

             WHEN OTHERS        =>   -- An unknown SrcRegMode value was passed
                                ASSERT FALSE
                                REPORT "To_Unsign - Unknown vector mode"
                               SEVERITY ERROR;
           END CASE;
        END IF;
        RETURN result;
    END To_Unsign;
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
                          ) RETURN BIT_VECTOR IS
      CONSTANT reglen    : INTEGER := SrcReg'LENGTH;
      VARIABLE reg_copy : BIT_VECTOR (reglen - 1 DOWNTO 0) := SrcReg;
      VARIABLE result    : BIT_VECTOR (reglen - 1 DOWNTO 0);

    --
    BEGIN
  
    --  Check for null input
      IF (SrcReg'LENGTH = 0) THEN
          ASSERT false
          REPORT " To_SignMag --- input register has null range "
          SEVERITY ERROR;
          RETURN reg_copy;

      ELSE
          result := reg_copy;

          -- convert to signmagnitude representation.
          CASE SrcRegMode IS
             WHEN TwosComp     => -- if a negative value, take two's comp it
                                   -- will become unsigned
                              IF (reg_copy(reglen - 1) /= '0') THEN
                                  -- if largest negative number then no conversion required
    	    		   	  IF (NOT All_Zero(reg_copy(reglen-2 DOWNTO 0))) THEN 
                                     result := RegNegate ( reg_copy, TwosComp);
                                     result(reglen - 1) := '1'; 
                                  END IF;   
                              END IF;

              WHEN OnesComp  =>  -- if a negative value, take RegNegate
                                 -- it will become a positive number, cahnge the sign bit.
                             IF (reg_copy(reglen - 1) /= '0') THEN
                                result := RegNegate (reg_copy, OnesComp);
                                result(reglen - 1) := '1'; 
                             END IF;
 
              WHEN SignMagnitude  => -- no translation required.
                             NULL; 

              WHEN Unsigned       => -- if MSB is '1' then the number is larger than what
                                     -- could be accommodated in the  register.
                                 IF (reg_copy(reglen - 1) /='0') THEN
                                    ASSERT false
                                    REPORT "To_SignMag - MSB of unsigned Bit_Vector   (" 
                                     & To_String(reg_copy)  & ") is not '0'. it cannot be converted "
                                    SEVERITY ERROR;
                                  END IF;

              WHEN OTHERS         =>  -- An unknown SrcRegMode value was passed
                                  ASSERT FALSE
                                  REPORT "To_SignMag - Unknown vector mode"
                                 SEVERITY ERROR;
           END CASE;
        END IF;
        RETURN result;
    END To_SignMag;
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
                          ) RETURN std_logic_vector IS
      CONSTANT reglen    : INTEGER := SrcReg'LENGTH;
      VARIABLE reg_copy : std_logic_vector (reglen - 1 DOWNTO 0) := SrcReg;
      VARIABLE result    : std_logic_vector (reglen - 1 DOWNTO 0);
    --
    BEGIN
    --  Check for null input
      IF (SrcReg'LENGTH = 0) THEN
          ASSERT false
          REPORT " To_SignMag --- input register has null range "
          SEVERITY ERROR;
          RETURN reg_copy;

      ELSE
          result := reg_copy;

          -- convert to signmagnitude representation.
          CASE SrcRegMode IS

             WHEN TwosComp     => -- if a negative value, take two's comp it
                                   -- will become unsigned
                              IF (reg_copy(reglen - 1) /= '0') THEN
                                  -- if largest negative number then no conversion required
    	    		   	  IF (NOT All_Zero(reg_copy(reglen-2 DOWNTO 0))) THEN 
                                     result := RegNegate ( reg_copy, TwosComp);
                                     result(reglen - 1) := '1'; 
                                  END IF;   
                              END IF;
 
              WHEN OnesComp    =>  -- if a negative value, take RegNegate
                                   -- it will become a positive number, cahnge the sign bit.
                              IF (reg_copy(reglen - 1) /= '0') THEN
                                 result := RegNegate (reg_copy, OnesComp);
                                 result(reglen - 1) := '1'; 
                              END IF;
 
              WHEN SignMagnitude  => -- no translation required.
                              NULL;  
       
              WHEN Unsigned        => -- if MSB is '1' then the number is larger than what
                                      -- could be accommodated in the  register.
                               IF (reg_copy(reglen - 1) /='0') THEN
                                 ASSERT false
                                  REPORT "To_SignMag - MSB of unsigned std_logic_vector   (" 
                                  & To_String(reg_copy)  & ") is not '0'. it cannot be converted "
                                  SEVERITY ERROR;
                               END IF;

              WHEN OTHERS        =>  -- An unknown SrcRegMode value was passed
                               ASSERT FALSE
                               REPORT "To_SignMag - Unknown vector mode"
                               SEVERITY ERROR;
           END CASE;
        END IF;
        RETURN result;
    END To_SignMag;
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
                          ) RETURN std_ulogic_vector IS
      CONSTANT reglen    : INTEGER := SrcReg'LENGTH;
      VARIABLE reg_copy : std_ulogic_vector (reglen - 1 DOWNTO 0) := SrcReg;
      VARIABLE result    : std_ulogic_vector (reglen - 1 DOWNTO 0);
    --
    BEGIN
    --  Check for null input
      IF (SrcReg'LENGTH = 0) THEN
          ASSERT false
          REPORT " To_SignMag --- input register has null range "
          SEVERITY ERROR;
          RETURN reg_copy;

      ELSE
          result := reg_copy;
          -- convert to signmagnitude representation.
          CASE SrcRegMode IS
             WHEN TwosComp     => -- if a negative value, take two's comp it
                                   -- will become unsigned
                              IF (reg_copy(reglen - 1) /= '0') THEN
                                  -- if largest negative number then no conversion required
    	    		   	  IF (NOT All_Zero(reg_copy(reglen-2 DOWNTO 0))) THEN 
                                     result := RegNegate ( reg_copy, TwosComp);
                                     result(reglen - 1) := '1'; 
                                  END IF;   
                              END IF;

              WHEN OnesComp     => -- if a negative value, take RegNegate
                                   -- it will become a positive number, cahnge the sign bit.
                              IF (reg_copy(reglen - 1) /= '0') THEN
                                result := RegNegate (reg_copy, OnesComp);
                                result(reglen - 1) := '1'; 
                              END IF;
 
              WHEN SignMagnitude  =>  -- no translation required.
                               NULL; 

              WHEN Unsigned       => -- if MSB is '1' then the number is larger than what
                                     -- could be accommodated in the  register.
                               IF (reg_copy(reglen - 1) /='0') THEN
                                 ASSERT false
                                  REPORT "To_SignMag - MSB of unsigned std_ulogic_vector   (" 
                                   & To_String(reg_copy)  & ") is not '0'. it cannot be converted "
                                  SEVERITY ERROR;
                                END IF;

              WHEN OTHERS         =>  -- An unknown SrcRegMode value was passed
                                ASSERT FALSE
                                REPORT "To_SignMag - Unknown vector mode"
                                SEVERITY ERROR;
           END CASE;
        END IF;
        RETURN result;
    END To_SignMag;
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
    --     See Also       : To_StdLogicVector, To_Integer, To_TwosComp
    -------------------------------------------------------------------------------
    FUNCTION To_StdLogicVector ( CONSTANT intg       : IN INTEGER;
                                 CONSTANT width      : IN NATURAL      := 0;
                                 CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                               ) RETURN std_logic_vector IS
      variable len          : integer := Maximum (width, IntegerBitLength);
      variable r            : std_logic_vector(len - 1 downto 0) := (OTHERS =>'0');
      VARIABLE result       : std_logic_vector (width - 1 DOWNTO 0);
      VARIABLE value        : INTEGER := intg;
      VARIABLE maglen, temp : INTEGER;
      VARIABLE negative     : BOOLEAN := FALSE;
      CONSTANT bmap         : std_logic_vector(0 TO 1) := "01";
    BEGIN
     if (width = 0) then
        assert false
        report " To_StdLogicVector ---  specified width is zero "
        severity ERROR;
        return result(width - 1 downto 0);
     end if;
     
    -- if formatting the logic vector as an unsigned number, the full vector
    -- can be used for the magnitude of the value. Otherwise reduce the size
    -- of the magnitude by 1 to allow for the sign bit.
      IF (SrcRegMode = unsigned) THEN
        maglen := width;
      ELSE
        maglen := width - 1;
      END IF;
 
    -- if the input integer value is negative, set the NEGATIVE flag true
    -- and use the absolute value of the integer. Furthermore, if the logic vector
    -- is to be formatted as an unsigned value, set the GOOD status to FALSE.  

      IF (value < 0) Then
          negative := TRUE;                -- set negative flag
          value    := - value;             -- make value positive
          IF (SrcRegMode = Unsigned) THEN
               ASSERT not WarningsOn 
               REPORT " To_StdLogicVector --- negative integer with unsigned mode "
               SEVERITY WARNING;
          END IF;
       END IF;

       -- Convert the positive integer value to an unsigned logic vector
    -- NOTE: for positive numbers, all formats are the same
    -- if the integer is to big for the return register set GOOD to FALSE.

      FOR i IN 0 TO IntegerBitLength - 1 LOOP
         EXIT WHEN value <= 0;
         temp := value / 2;
         r(i) := bmap(value - (temp*2));
         value := temp;
      END LOOP;
      ASSERT value=0 
      REPORT "To_StdLogicVector ---  IntegerBitLength too small to hold " &
             " the std_logic  value of the input integer "
      SEVERITY FAILURE;
      
      if (width <= IntegerBitLength) then
            result := r(width - 1 downto 0);
      else
            result := RegFill(r, width,  '0');
      end if;
            
      IF negative THEN
          result := RegNegate(result, SrcRegMode);
      END IF;
      RETURN result;
    END To_StdLogicVector;
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
    --                                   of the output std_ulogic_vector.   Default 
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
    --                      VARIABLE vect : std_ulogic_vector ( 15 DOWNTO 0 );
    --
    --                      vect := To_StdULogicVector ( -294, 16, TwosComp );
    --
    --     See Also       : To_StdLogicVector, To_Integer, To_TwosComp
    -------------------------------------------------------------------------------
    FUNCTION To_StdULogicVector ( CONSTANT intg       : IN INTEGER;
                                  CONSTANT width      : IN NATURAL      := 0;
                                  CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                                ) RETURN std_ulogic_vector IS
      variable len          : integer := Maximum (width, IntegerBitLength);
      VARIABLE r            : std_ulogic_vector (len - 1 DOWNTO 0) := (OTHERS=>'0');
      VARIABLE result       : std_ulogic_vector (width - 1 DOWNTO 0);
      VARIABLE value        : INTEGER := intg;
      VARIABLE maglen, temp : INTEGER;
      VARIABLE negative     : BOOLEAN := FALSE;
      CONSTANT bmap         : std_ulogic_vector(0 TO 1) := "01";
    BEGIN
     if (width = 0) then
        assert false
        report " To_StdULogicVector ---  specified width is zero "
        severity ERROR;
        return result(width - 1 downto 0);
     end if;
     
    -- if formatting the logic vector as an unsigned number, the full vector
    -- can be used for the magnitude of the value. Otherwise reduce the size
    -- of the magnitude by 1 to allow for the sign bit.
      IF (SrcRegMode = unsigned) THEN
        maglen := width;
      ELSE
        maglen := width - 1;
      END IF;
 
    -- if the input integer value is negative, set the NEGATIVE flag true
    -- and use the absolute value of the integer. Furthermore, if the logic vector
    -- is to be formatted as an unsigned value, set the GOOD status to FALSE.  

      IF (value < 0) Then
          negative := TRUE;                -- set negative flag
          value    := - value;             -- make value positive
          IF (SrcRegMode = Unsigned) THEN
               ASSERT not WarningsOn 
               REPORT " To_StdULogicVector --- negative integer with unsigned mode "
               SEVERITY WARNING;
          END IF;
       END IF;

       -- Convert the positive integer value to an unsigned logic vector
    -- NOTE: for positive numbers, all formats are the same
    -- if the integer is to big for the return register set GOOD to FALSE.

      FOR i IN 0 TO IntegerBitLength - 1 LOOP
         EXIT WHEN value <= 0;
         temp := value / 2;
         r(i) := bmap(value - (temp*2));
         value := temp;
      END LOOP;
      ASSERT value=0 
      REPORT "To_StdULogicVector ---  IntegerBitLength too small to hold " &
             " the std_logic  value of the input integer "
      SEVERITY FAILURE;

      if (width <= IntegerBitLength) then
            result := r(width - 1 downto 0);
      else
            result := RegFill(r, width,  '0');
      end if;
      
      IF negative THEN
          result := RegNegate(result, SrcRegMode);
      END IF;
      RETURN result;
    END To_StdUlogicVector;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_BitVector
--|
--|     Overloading    : 
--|
--|     Purpose        : Translate an INTEGER into a BIT_VECTOR.
--|
--|     Parameters     : intg    - input  INTEGER, the value to be translated.
--|                      width   - input  NATURAL, length of the return vector.
--|                            Default is IntegerBitLength (Machine integer length).
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
--|     See Also       : To_BitVector, To_Integer, To_TwosComp
--|-----------------------------------------------------------------------------
    FUNCTION To_BitVector ( CONSTANT intg       : IN INTEGER;
                            CONSTANT width      : IN Natural;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN BIT_VECTOR IS
      variable len          : integer := Maximum (width, IntegerBitLength);
      VARIABLE r       : bit_vector (len - 1 DOWNTO 0) := (OTHERS=>'0');
      VARIABLE result  : bit_vector (width - 1 DOWNTO 0);
      VARIABLE value    : INTEGER := intg;
      VARIABLE maglen   : Integer;     -- magnitude length
      VARIABLE temp     : Integer;
      VARIABLE negative : Boolean := false;
      CONSTANT bmap     : bit_vector(0 TO 1) := "01";
    BEGIN
      if (width = 0) then
         assert false
         report " To_BitVector ---  specified width is zero "
         severity ERROR;
         return result;
      end if;


      IF (SrcRegMode = Unsigned) Then 
           maglen := width;
      ELSE
           maglen := width - 1;
      END IF;

      IF (value < 0) Then
          negative := TRUE;                -- set negative flag
          value    := - value;             -- make value positive
          IF (SrcRegMode = Unsigned) THEN
               ASSERT not WarningsOn 
               REPORT " To_BitVector --- negative integer with unsigned mode "
               SEVERITY WARNING;
          END IF;
       END IF;

       -- Convert the positive integer value to an unsigned bit vector
    -- NOTE: for positive numbers, all formats are the same

      FOR i IN 0 TO IntegerBitLength - 1 LOOP
         EXIT WHEN value <= 0;
         temp := value / 2;
         r(i) := BIT'VAL(value - (temp*2));
         value := temp;
      END LOOP;
      ASSERT value=0 
      REPORT "To_BitVector ---  IntegerBitLength too small to hold " &
             " the binary value of the input integer "
      SEVERITY FAILURE;

      if (width <= IntegerBitLength) then
            result := r(width - 1 downto 0);
      else
            result := RegFill(r, width,  '0');
      end if;
      
      IF negative THEN
          result := RegNegate(result, SrcRegMode);
      END IF;

      RETURN result;
    END To_BitVector;
    -------------------------------------------------------------------------------
    --     Procedure Name : To_Integer
    --
    --     Overloading    : Procedure and Function.
    --    
    --     Purpose        : Interpret std_logic_vector as an INTEGER.
    --     
    --     Parameters     : 
    --                      SrcReg     - input  std_logic_vector, the vector to be 
    --                                          converted.
    --                      SrcRegMode - input  regmode_type, indicating the format 
    --                                    of the input std_logic_vector.   
    --                                    Default is DefaultRegMode.
    --     
    --     NOTE           : 
    --                      * Magnitude of the computed integer is too large. The 
    --                        input value is considered to large if after removing
    --                        leading 0's (1's for negative numbers)  the length
    --                        of the remaining vector is > IntegerBitLength-1.
    --                        (ie the machine integer length).
    --                      The error return value is INTEGER'LEFT.
    --
    --     Use            : 
    --                      VARIABLE vect : std_logic_vector ( 15 DOWNTO 0 );
    --
    --                      To_Integer ( vect, TwosComp );
    --     
    --     See Also       :  To_Integer, To_TwosComp, To_OnesComp
    -------------------------------------------------------------------------------
    FUNCTION To_Integer   ( CONSTANT SrcReg     : IN std_logic_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) RETURN INTEGER IS
                             
	VARIABLE reg_copy : std_logic_vector(SrcReg'LENGTH - 1 DOWNTO 0) := To_X01(SrcReg);
        VARIABLE result   : INTEGER := 0;
      	VARIABLE leng     : INTEGER := SrcReg'LENGTH;
	VARIABLE good     : boolean := FALSE;
    BEGIN
     --
     --  Check for null input
	IF (SrcReg'LENGTH = 0) THEN
          ASSERT false
          REPORT " To_Integer --- input register has null range. " 
                 & "  Returning zero  result."
          SEVERITY ERROR;
          RETURN result;
	ELSIF  (Is_X(reg_copy)) THEN
	  assert false 
	  report " To_Integer ---  'X' encountered in the input vector. "
	       & " Returning zero result."
	  severity error;
	  return result;
        END IF;

        convert_loop: LOOP
          -- if the input vector is unsigned, the leading bit is data. Transfer this
          -- bit to the result now - to simplify the conversion loop below, 
          IF (  SrcRegMode = unsigned ) THEN
  	     IF ((reg_copy(leng - 1) = '1' ) AND (leng >= IntegerBitLength)) THEN
		assert false
		report " To_Integer --- attempt to convert a vector "
		       & "that is too large to be represented as an integer."
		severity error;
                EXIT convert_loop; 
             END IF;
             result := std_logic'POS(reg_copy(leng - 1)) - 2;
           END IF;

         -- now convert the magnitude part of the logic vector to a positive integer.
         -- if the magnitude part is positive convert with this loop
           IF ((reg_copy(leng - 1)='0') OR (SrcRegMode=unsigned) OR (SrcRegMode=SignMagnitude)) THEN
              -- Convert Unsigned
              FOR i IN leng-2 DOWNTO 0 LOOP
                                            -- number too big
                  IF ((i>=IntegerBitLength - 1) AND (reg_copy(i)='1'))   THEN 
         	       assert false
		       report " To_Integer --- attempt to convert a vector "
			      & "that is too large to be represented as an integer."
	               severity error;
                       EXIT convert_loop; 
                  END IF;		
                  result := result + result + std_logic'POS(reg_copy(i)) - 2;  -- shift and add
               END LOOP;
        
            -- if input was a negative SignMagnitude number, negate the computed value
              IF ((SrcRegMode=SignMagnitude) AND (reg_copy(leng - 1)='1')) THEN
                 result := - result;
              END IF;

          -- if the magnitude part is negative convert with this loop 
          -- (the bits of the input vector are complemented)
           ELSE  -- Convert Negative number
              FOR i IN leng - 2 DOWNTO 0 LOOP
                  IF ((i>=IntegerBitLength - 1) AND (reg_copy(i)='0'))   THEN 
         	       assert false
		       report " To_Integer --- attempt to convert a vector "
			      & "that is too large to be represented as an integer."
	               severity error;
                       EXIT convert_loop; 
                  END IF;		
                  -- shift and add complemented bit
                  result := result + result - std_logic'POS(reg_copy(i)) + 3; 
              END LOOP;
             -- adjust (add 1) for 2's comp numbers
              IF ( SrcRegMode = TwosComp ) THEN
                 IF (result = INTEGER'HIGH) THEN              -- number to big
         	       assert false
		       report " To_Integer --- attempt to convert a vector "
			      & "that is too large to be represented as an integer."
	               severity error;
                       EXIT convert_loop; 
                 END IF;		
                 result := result + 1;
              END IF;
            -- since this is a negative number, make it so.
              result := - result;
            END IF;
           -- conversion complete - set success exit condition and exit the error loop
            good := TRUE;
            EXIT convert_loop;
         END LOOP convert_loop;

         if (good) THEN
 	     return result;
         else
             return 0;
         end if;		
    END To_Integer;
--+-----------------------------------------------------------------------------
--|     Procedure Name : To_Integer
--|
--|     Overloading    : 
--|
--|     Purpose        : Interpret BIT_VECTOR as an INTEGER.
--|
--|     Parameters     :
--|                      SrcReg     - input  BIT_VECTOR, the vector to be read.
--|                      SrcRegMode - input  regmode_type, indicating the format of
--|                                the input BIT_VECTOR.   Default is TwosComp.
--|
--|     NOTE           : 
--|                       * Magnitude of the computed integer is to large. The
--|                         input value is considered to large if after removing
--|                         leading 0's (1's for negative numbers) the length
--|                         of the remaining vector is > IntegerBitLength - 1.
--|                         (ie the machine integer length).
--|                      The error return value is INTEGER'LEFT.
--|
--|     Use            :
--|                      VARIABLE vect : BIT_VECTOR ( 15 DOWNTO 0 );
--|
--|                      To_Integer ( vect, TwosComp );
--|
--|     See Also       : To_BitVector, To_Integer, To_TwosComp 
--|-----------------------------------------------------------------------------
     FUNCTION To_Integer  ( CONSTANT SrcReg     : IN BIT_VECTOR;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          ) return INTEGER IS
 
    BEGIN
       return To_Integer ( SrcReg     => To_StdLogicVector(SrcReg),
		           SrcRegMode => SrcRegMode
		         );
    END To_Integer;
    
    -------------------------------------------------------------------------------
    --     Procedure Name : To_Integer
    --
    --     Overloading    : Procedure and Function.
    --    
    --     Purpose        : Interpret std_ulogic_vector as an INTEGER.
    --     
    --     Parameters     : 
    --                      SrcReg     - input  std_ulogic_vector, the vector to be 
    --                                          converted.
    --                      SrcRegMode - input  regmode_type, indicating the format 
    --                                    of the input std_ulogic_vector.   
    --                                    Default is DefaultRegMode.
    --     
    --     NOTE           : 
    --                      * Magnitude of the computed integer is too large. The 
    --                        input value is considered to large if after removing
    --                        leading 0's (1's for negative numbers)  the length
    --                        of the remaining vector is > IntegerBitLength-1.
    --                        (ie the machine integer length).
    --                      The error return value is INTEGER'LEFT.
    --
    --     Use            : 
    --                      VARIABLE vect : std_ulogic_vector ( 15 DOWNTO 0 );
    --
    --                      To_Integer ( vect, TwosComp );
    --     
    --     See Also       : To_StdLogicVector, To_Integer, To_TwosComp, To_OnesComp
    -------------------------------------------------------------------------------
    FUNCTION To_Integer   ( CONSTANT SrcReg     : IN std_ulogic_vector;
                            CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                          )  RETURN INTEGER IS
 
    BEGIN
       return To_Integer ( SrcReg     => std_logic_vector(SrcReg),
			   SrcRegMode => SrcRegMode
			 );
    END To_Integer;
--+-----------------------------------------------------------------------------
--|     Function Name  : Add_TwosComp
--|  hidden procedure 
--|     Overloading    : None
--|
--|     Purpose        : Two's Complement Addition of BIT_VECTORS.
--|
--|     Parameters     :
--|                      result     - output BIT_VECTOR, the computed sum
--|                      carry_out   - output BIT, 
--|                      overflow   - output BIT, overflow condition
--|                      addend     - input  BIT_VECTOR,
--|                      augend     - input  BIT_VECTOR,
--|                      carry_in   - input BIT, 
--|     NOTE           : 
--|                      This procedure is implemented based on hardware design of a
--|                      Two's complement adder.
--|                      The inputs may be of any length  but both addend and augend
--|                      must have same lengths.
--|
--|     Use            :
--|                      VARIABLE x, y, sum : BIT_VECTOR ( 15 DOWNTO 0);
--|                      VARIABLE carry, ovf : BIT;
--|
--|                      Add_TwosComp ( sum, carry, ovf, x, y, '0' );
--| 
--|
--|-----------------------------------------------------------------------------
    PROCEDURE Add_TwosComp  ( VARIABLE result     : OUT BIT_VECTOR;
                              VARIABLE carry_out  : OUT BIT;
                              VARIABLE overflow   : OUT BIT;
                              CONSTANT addend     :  IN BIT_VECTOR;
                              CONSTANT augend     :  IN BIT_VECTOR;
                              CONSTANT carry_in   :  IN BIT := '0'
                             ) IS 
 
      CONSTANT reglen   : INTEGER := addend'LENGTH;
      VARIABLE a        : BIT_VECTOR ( reglen - 1  DOWNTO 0 ) := addend;
      VARIABLE b        : BIT_VECTOR ( augend'LENGTH - 1  DOWNTO 0 ) := augend;
      VARIABLE r        : BIT_VECTOR ( reglen - 1  DOWNTO 0 );
      VARIABLE p        : BIT := '1';
      VARIABLE g        : BIT := '0';
      VARIABLE c_iminus : BIT;
      VARIABLE carry    : BIT :=carry_in;
    BEGIN
 
    -- check the length of addend and augend 
      ASSERT   (addend'LENGTH = augend'LENGTH)
      REPORT " AddSub_TwosComp --- operand lenght not same "
      SEVERITY ERROR;

    -- perform the add using a simple ripple carry bit wise add.
      FOR n IN 0 TO reglen - 1 LOOP
             c_iminus := carry;
             p := p AND (a(n) OR b(n));                        -- Cpropagate
             g := (a(n) AND b(n)) OR ( g AND (a(n) OR b(n)));  -- Cgenerate
          r(n) :=  a(n) XOR b(n) XOR carry;                    -- individual bit sums
         carry :=  g OR (p AND carry);                         -- carry
      END LOOP;
      carry_out := carry;
    -- set overflow if carry_in and carry_out of sign bit are different.
         overflow := c_iminus XOR carry;
           result(reglen-1 DOWNTO 0) := r;

    -- that's all
       RETURN;
    END Add_TwosComp;
--+-----------------------------------------------------------------------------
--|     Function Name  : Add_TwosComp
--|  hidden procedure
--|     Overloading    : None
--|
--|     Purpose        : Two's Complement Addition of LOGIC VECTORS.
--|
--|     Parameters     :
--|                      result     - output std_logic_vector, the computed sum
--|                      carry_out  - output std_logic, 
--|                      overflow   - output std_logic, overflow condition
--|                      addend     - input  std_logic_vector,
--|                      augend     - input  std_logic,
--|                      carry_in   - input std_logic,
--|     NOTE           :
--|                      This procedure is implemented based on hardware design of a
--|                      Two's complement adder. 
--|                      The inputs may be of any length  but both addend and augend
--|                      must have same lengths.
--|
--|     Use            :
--|                      VARIABLE x, y, sum : std_logic_vector ( 15 DOWNTO 0);
--|                      VARIABLE carry, ovf : std_ulogic;
--|
--|                      Add_TwosComp ( sum, carry, ovf, x, y, '0' );
--| 
--|-----------------------------------------------------------------------------
    PROCEDURE Add_TwosComp  ( VARIABLE result     : OUT std_logic_vector;
                              VARIABLE carry_out  : OUT std_ulogic;
                              VARIABLE overflow   : OUT std_ulogic;
                              CONSTANT addend     :  IN std_logic_vector;
                              CONSTANT augend     :  IN std_logic_vector;
                              CONSTANT carry_in   :  IN std_ulogic:= '0'
                             ) IS

      CONSTANT reglen   : INTEGER := addend'LENGTH;
      VARIABLE a        : std_logic_vector ( reglen - 1  DOWNTO 0 ) := addend;
      VARIABLE b        : std_logic_vector ( augend'LENGTH - 1  DOWNTO 0 ) := augend;
      VARIABLE r        : std_logic_vector ( reglen - 1  DOWNTO 0 );
      VARIABLE p        : std_ulogic:= '1';
      VARIABLE g        : std_ulogic:= '0';
      VARIABLE c_iminus : std_ulogic;
      VARIABLE carry    : std_ulogic:= carry_in;
    BEGIN

    -- check the length of addend and augend
      ASSERT   (addend'LENGTH = augend'LENGTH)
      REPORT " AddSub_TwosComp --- operand lenght not same "
      SEVERITY ERROR;

    -- perform the add using a simple ripple carry bit wise add.
      FOR n IN 0 TO reglen - 1 LOOP
           c_iminus := carry;
             p := p AND (a(n) OR b(n));                        -- Cpropagate
             g := (a(n) AND b(n)) OR ( g AND (a(n) OR b(n)));  -- Cgenerate
          r(n) :=  a(n) XOR b(n) XOR carry;                    -- individual bit sums
         carry :=  g OR (p AND carry);                         -- carry
      END LOOP;
      carry_out := carry;
    -- set overflow if carry_in and carry_out of sign bit are different.
         overflow := c_iminus XOR carry;
         result(reglen-1 DOWNTO 0) := r;
 
    -- that's all
       RETURN;
    END Add_TwosComp;
--+-----------------------------------------------------------------------------
--|     Function Name  : Add_TwosComp
--|  hidden procedure
--|     Overloading    : None
--|
--|     Purpose        : Two's Complement Addition of ULOGIC VECTORS.
--|
--|     Parameters     :
--|                      result     - output std_ulogic_vector, the computed sum
--|                      carry_out  - output std_logic, 
--|                      overflow   - output std_logic, overflow condition
--|                      addend     - input  std_ulogic_vector,
--|                      augend     - input  std_logic,
--|                      carry_in   - input std_logic,
--|     NOTE           :
--|                      This procedure is implemented based on hardware design of a
--|                      Two's complement adder. 
--|                      The inputs may be of any length  but both addend and augend
--|                      must have same lengths.
--|
--|     Use            :
--|                      VARIABLE x, y, sum : std_ulogic_vector ( 15 DOWNTO 0);
--|                      VARIABLE carry, ovf : std_ulogic;
--|
--|                      Add_TwosComp ( sum, carry, ovf, x, y, '0' );
--| 
--|-----------------------------------------------------------------------------
    PROCEDURE Add_TwosComp  ( VARIABLE result     : OUT std_ulogic_vector;
                              VARIABLE carry_out  : OUT std_ulogic;
                              VARIABLE overflow   : OUT std_ulogic;
                              CONSTANT addend     :  IN std_ulogic_vector;
                              CONSTANT augend     :  IN std_ulogic_vector;
                              CONSTANT carry_in   :  IN std_ulogic:= '0'
                             ) IS

      CONSTANT reglen   : INTEGER := addend'LENGTH;
      VARIABLE a        : std_ulogic_vector ( reglen - 1  DOWNTO 0 ) := addend;
      VARIABLE b        : std_ulogic_vector ( augend'LENGTH - 1  DOWNTO 0 ) := augend;
      VARIABLE r        : std_ulogic_vector ( reglen - 1  DOWNTO 0 );
      VARIABLE p        : std_ulogic:= '1';
      VARIABLE g        : std_ulogic:= '0';
      VARIABLE c_iminus : std_ulogic;
      VARIABLE carry    : std_ulogic:= carry_in;
    BEGIN
    -- check the length of addend and augend
      ASSERT   (addend'LENGTH = augend'LENGTH)
      REPORT " AddSub_TwosComp --- operand lenght not same "
      SEVERITY ERROR;
    -- perform the add using a simple ripple carry bit wise add.
      FOR n IN 0 TO reglen - 1 LOOP
           c_iminus := carry;
             p := p AND (a(n) OR b(n));                        -- Cpropagate
             g := (a(n) AND b(n)) OR ( g AND (a(n) OR b(n)));  -- Cgenerate
          r(n) :=  a(n) XOR b(n) XOR carry;                    -- individual bit sums
         carry :=  g OR (p AND carry);                         -- carry
      END LOOP;
      carry_out := carry;
    -- set overflow if carry_in and carry_out of sign bit are different.
       overflow := c_iminus XOR carry;
       result(reglen-1 DOWNTO 0) := r;
       RETURN;
    END Add_TwosComp;
 --+-----------------------------------------------------------------------------
--|     Function Name  : Add_Unsigned
--|  hidden procedure
--|     Overloading    : None
--|
--|     Purpose        :  Addition  of unsigned BIT_VECTORS.
--|
--|     Parameters     :
--|                      result     - output BIT_VECTOR, the computed sum
--|                      carry_out   - output BIT,
--|                      overflow   - output BIT,
--|                      addend     - input  BIT_VECTOR,
--|                      augend     - input  BIT_VECTOR,
--|                      carry_in   - input BIT,
--|     NOTE           :
--|                      The inputs may be of any length  but both addend and augend
--|                      must have same lengths.
--|          
--|                      carry_out '1' is considered overflow
--|     Use            :
--|                      VARIABLE x, y, sum : BIT_VECTOR ( 15 DOWNTO 0);
--|                      VARIABLE carry, ovf : BIT;
--|
--|                      Add_TwosComp ( sum, carry, ovf, x, y, '0' );
--| 
--|-----------------------------------------------------------------------------
    PROCEDURE Add_Unsigned  ( VARIABLE result     : OUT BIT_VECTOR;
                              VARIABLE carry_out  : OUT BIT;
                              VARIABLE overflow   : OUT BIT;
                              CONSTANT addend     :  IN BIT_VECTOR;
                              CONSTANT augend     :  IN BIT_VECTOR;
                              CONSTANT carry_in   :  IN BIT := '0'
                             ) IS

      CONSTANT reglen : INTEGER := addend'LENGTH;
      VARIABLE a      : BIT_VECTOR ( reglen - 1  DOWNTO 0 ) := addend;
      VARIABLE b      : BIT_VECTOR ( augend'LENGTH - 1  DOWNTO 0 ) := augend;
      VARIABLE r      : BIT_VECTOR ( reglen - 1  DOWNTO 0 );
      VARIABLE p      : BIT := '1';
      VARIABLE g      : BIT := '0';
      VARIABLE carry  : BIT :=carry_in;
      VARIABLE n      : INTEGER;
    BEGIN
    -- check the length of addend and augend
      ASSERT   (addend'LENGTH = augend'LENGTH)
      REPORT " Add_Unsigned --- operand lenght not same "
      SEVERITY ERROR;
    -- perform the add using a simple ripple carry bit wise add.
      FOR n IN 0 TO reglen - 1 LOOP
             p := p AND (a(n) OR b(n));                        -- Cpropagate
             g := (a(n) AND b(n)) OR ( g AND (a(n) OR b(n)));  -- Cgenerate
          r(n) :=  a(n) XOR b(n) XOR carry;                    -- individual bit sums
         carry :=  g OR (p AND carry);                         -- carry
      END LOOP;
      carry_out := carry;
    -- set overflow if carry_in and carry_out of last bit postition are different.
       overflow :=  carry;
       result(reglen-1 DOWNTO 0) := r;
       RETURN;
    END Add_Unsigned;
--+-----------------------------------------------------------------------------
--|     Function Name  : Add_Unsigned
--|  hidden procedure
--|     Overloading    : None
--|
--|     Purpose        : Addition of LOGIC VECTORS in unsigned mode.
--|
--|     Parameters     :
--|                      result     - output std_logic_vector, the computed sum
--|                      carry_out  - output std_logic,
--|                      overflow   - output std_logic, overflow condition
--|                      addend     - input  std_logic_vector,
--|                      augend     - input  std_logic,
--|                      carry_in   - input std_logic,
--|     NOTE           :
--|                      The inputs may be of any length  but both addend and augend
--|                      must have same lengths.
--|
--|     Use            :
--|                      VARIABLE x, y, sum : std_logic_vector ( 15 DOWNTO 0);
--|                      VARIABLE carry, ovf : std_ulogic;
--|
--|                      Add_Unsigned ( sum, carry, ovf, x, y, '0' );
--|
--|-----------------------------------------------------------------------------
    PROCEDURE Add_Unsigned  ( VARIABLE result     : OUT std_logic_vector;
                              VARIABLE carry_out  : OUT std_ulogic;
                              VARIABLE overflow   : OUT std_ulogic;
                              CONSTANT addend     :  IN std_logic_vector;
                              CONSTANT augend     :  IN std_logic_vector;
                              CONSTANT carry_in   :  IN std_ulogic:= '0'
                             ) IS
 
      CONSTANT reglen : INTEGER := addend'LENGTH;
      VARIABLE a      : std_logic_vector ( reglen - 1  DOWNTO 0 ) := addend;
      VARIABLE b      : std_logic_vector ( augend'LENGTH - 1  DOWNTO 0 ) := augend;
      VARIABLE r      : std_logic_vector ( reglen - 1  DOWNTO 0 );
      VARIABLE p      : std_ulogic:= '1';
      VARIABLE g      : std_ulogic:= '0';
      VARIABLE carry  : std_ulogic:= carry_in;
    BEGIN
    -- check  the length of addend and augend
      ASSERT   (addend'LENGTH = augend'LENGTH)
      REPORT " AddSub_TwosComp --- operand lenght not same "
      SEVERITY ERROR;
    -- perform the add using a simple ripple carry bit wise add.
      FOR n IN 0 TO reglen - 1 LOOP
             p := p AND (a(n) OR b(n));                        -- Cpropagate
             g := (a(n) AND b(n)) OR ( g AND (a(n) OR b(n)));  -- Cgenerate
          r(n) :=  a(n) XOR b(n) XOR carry;                    -- individual bit sums
         carry :=  g OR (p AND carry);                         -- carry
      END LOOP;
      carry_out := carry;
    -- set overflow if carry_in and carry_out of last bit postition are different.
       overflow :=  carry;
       result(reglen-1 DOWNTO 0) := r;
       RETURN;
    END Add_Unsigned;
 --+-----------------------------------------------------------------------------
--|     Function Name  : Add_Unsigned
--|  hidden procedure
--|     Overloading    : None
--|
--|     Purpose        : Addition of ULOGIC VECTORS in unsigned mode.
--|
--|     Parameters     :
--|                      result     - output std_ulogic_vector, the computed sum
--|                      carry_out  - output std_logic,
--|                      overflow   - output std_logic, overflow condition
--|                      addend     - input  std_ulogic_vector,
--|                      augend     - input  std_logic,
--|                      carry_in   - input std_logic,
--|     NOTE           :
--|                      The inputs may be of any length  but both addend and augend
--|                      must have same lengths.
--|
--|     Use            :
--|                      VARIABLE x, y, sum : std_ulogic_vector ( 15 DOWNTO 0);
--|                      VARIABLE carry, ovf : std_ulogic;
--|
--|                      Add_Unsigned ( sum, carry, ovf, x, y, '0' );
--|
--|-----------------------------------------------------------------------------
    PROCEDURE Add_Unsigned  ( VARIABLE result     : OUT std_ulogic_vector;
                              VARIABLE carry_out  : OUT std_ulogic;
                              VARIABLE overflow   : OUT std_ulogic;
                              CONSTANT addend     :  IN std_ulogic_vector;
                              CONSTANT augend     :  IN std_ulogic_vector;
                              CONSTANT carry_in   :  IN std_ulogic:= '0'
                             ) IS
 
      CONSTANT reglen : INTEGER := addend'LENGTH;
      VARIABLE a      : std_ulogic_vector ( reglen - 1  DOWNTO 0 ) := addend;
      VARIABLE b      : std_ulogic_vector ( augend'LENGTH - 1  DOWNTO 0 ) := augend;
      VARIABLE r      : std_ulogic_vector ( reglen - 1  DOWNTO 0 );
      VARIABLE p      : std_ulogic:= '1';
      VARIABLE g      : std_ulogic:= '0';
      VARIABLE carry  : std_ulogic:= carry_in;
    BEGIN
    -- check  the length of addend and augend
      ASSERT   (addend'LENGTH = augend'LENGTH)
      REPORT " AddSub_TwosComp --- operand lenght not same "
      SEVERITY ERROR;
    -- perform the add using a simple ripple carry bit wise add.
      FOR n IN 0 TO reglen - 1 LOOP
             p := p AND (a(n) OR b(n));                        -- Cpropagate
             g := (a(n) AND b(n)) OR ( g AND (a(n) OR b(n)));  -- Cgenerate
          r(n) :=  a(n) XOR b(n) XOR carry;                    -- individual bit sums
         carry :=  g OR (p AND carry);                         -- carry
      END LOOP;
      carry_out := carry;
    -- set overflow if carry_in and carry_out of last bit postition are different.
       overflow :=  carry;
       result(reglen-1 DOWNTO 0) := r;
       RETURN;
    END Add_Unsigned;
 --+-----------------------------------------------------------------------------
--|     Function Name  : AddSub_OnesComp
--|  hidden procedure 
--|     Overloading    : None
--|
--|     Purpose        : One's Complement Addition/subtraction of BIT_VECTORS.
--|
--|     Parameters     :
--|                      result     - output BIT_VECTOR, the computed sum
--|                      carry_out   - output BIT, 
--|                      overflow   - output BIT, overflow condition
--|                      addend     - input  BIT_VECTOR,
--|                      augend     - input  BIT_VECTOR,
--|                      M          - input BIT, mode control
--|     NOTE           :
--|                      This procedure is implemented based on hardware design of a
--|                      One's complement adder/subtractor.
--|                      The inputs may be of any length  but both addend and augend
--|                      must have same lengths.
--|
--|     Use            :
--|                      VARIABLE x, y, sum : BIT_VECTOR ( 15 DOWNTO 0);
--|                      VARIABLE  ovf : BIT;
--|  
--|                      AddSub_OnesComp ( sum, ovf, x, y, '0' );
--| 
--|-----------------------------------------------------------------------------
    PROCEDURE AddSub_OnesComp  ( VARIABLE result     : OUT BIT_VECTOR;
                                 VARIABLE carry_out  : OUT BIT;
                                 VARIABLE overflow   : OUT BIT;
                                 CONSTANT addend     :  IN BIT_VECTOR;
                                 CONSTANT augend     :  IN BIT_VECTOR;
                                 CONSTANT M          :  IN BIT := '0'
                                ) IS
 
      CONSTANT reglen   : INTEGER := addend'LENGTH;
      VARIABLE a        : BIT_VECTOR ( reglen - 1  DOWNTO 0 ) := addend;
      VARIABLE b        : BIT_VECTOR ( augend'LENGTH - 1  DOWNTO 0 ) := augend;
      VARIABLE r        : BIT_VECTOR ( reglen - 1  DOWNTO 0 );
      VARIABLE p        : BIT := '1';
      VARIABLE g        : BIT := '0';
      VARIABLE c_iminus : BIT;
      VARIABLE carry1    : BIT;
      VARIABLE carry_end : BIT := '0';
    BEGIN
     -- check the length of addend and augend
      ASSERT   (addend'LENGTH = augend'LENGTH)
      REPORT " AddSub_OnesComp --- operand lenght not same "
      SEVERITY ERROR;
 
    -- if the mode is subtract then invert vector b.
      IF ( M = '1') THEN
          b := NOT b;       --  this if and not is equivlent to XOR.
      END IF;
 
    -- perform the add using a simple ripple carry bit wise add.
    --  add end around carry.
     
      While true LOOP    -- to take care of end arround carry 
         carry1 := carry_end;
         FOR n IN 0 TO reglen - 1 LOOP
             c_iminus := carry1;
             p := p AND (a(n) OR b(n));                        -- Cpropagate
             g := (a(n) AND b(n)) OR ( g AND (a(n) OR b(n)));  -- Cgenerate
             r(n) :=  a(n) XOR b(n) XOR carry1;                    -- individual bit sums
             carry1 :=  g OR (p AND carry1);                         -- carry
         END LOOP;
         exit when (carry1 = carry_end);
         carry_end := carry1;
     END LOOP;
       carry_out := carry1;
    -- set overflow if carry_in and carry_out of sign bit are different.
       overflow := c_iminus XOR carry1;
       result(reglen-1 DOWNTO 0) := r;
       RETURN;
    END AddSub_OnesComp;
--+-----------------------------------------------------------------------------
--|     Function Name  : AddSub_OnesComp
--|  hidden procedure
--|     Overloading    : None
--|  
--|     Purpose        : Ones's Complement Addition/subtraction of LOGIC VECTORS.
--|  
--|     Parameters     :
--|                      result     - output std_logic_vector, the computed sum
--|                      carry_out   - output std_logic, 
--|                      overflow   - output std_logic, overflow condition
--|                      addend     - input  std_logic_vector,
--|                      augend     - input  std_logic,
--|                      M          - input BIT, mode control
--|     NOTE           :
--|                      This procedure is implemented based on hardware design of a
--|                      One's complement adder/subtractor.
--|                      The inputs may be of any length  but both addend and augend
--|                      must have same lengths.
--|  
--|     Use            :
--|                      VARIABLE x, y, sum : std_logic_vector ( 15 DOWNTO 0);
--|                      VARIABLE ovf : std_ulogic;
--|  
--|                      AddSub_OnesComp ( sum, ovf, x, y, '0' );
--| 
--|-----------------------------------------------------------------------------
    PROCEDURE AddSub_OnesComp  ( VARIABLE result     : OUT std_logic_vector;
                                 VARIABLE carry_out  : OUT std_ulogic;
                                 VARIABLE overflow   : OUT std_ulogic;
                                 CONSTANT addend     :  IN std_logic_vector;
                                 CONSTANT augend     :  IN std_logic_vector;
                                 CONSTANT M          :  IN BIT := '0'
                                ) IS
 
      CONSTANT reglen    : INTEGER := addend'LENGTH;
      VARIABLE a         : std_logic_vector ( reglen - 1  DOWNTO 0 ) := addend;
      VARIABLE b         : std_logic_vector ( augend'LENGTH - 1  DOWNTO 0 ) := augend;
      VARIABLE r         : std_logic_vector ( reglen - 1  DOWNTO 0 );
      VARIABLE p         : std_ulogic:= '1';
      VARIABLE g         : std_ulogic:= '0';
      VARIABLE c_iminus  : std_ulogic;
      VARIABLE carry     : std_ulogic;
      VARIABLE carry_end : std_ulogic:= '0';
    BEGIN
    -- check the length of addend and augend
      ASSERT   (addend'LENGTH = augend'LENGTH)
      REPORT " AddSub_OnesComp --- operand lenght not same "
      SEVERITY ERROR;
 
    -- if the mode is subtract then invert vector b.
      IF ( M = '1') THEN
          b := NOT b;       --  this if and not is equivlent to XOR.
          carry := '1';
      ELSE
          carry := '0';
      END IF;

   -- perform the add using a simple ripple carry bit wise add.
    --  add end around carry.
 
     While true LOOP    -- to take care of end arround carry
         carry := carry_end;
         FOR n IN 0 TO reglen - 1 LOOP
             c_iminus := carry;
             p := p AND (a(n) OR b(n));                        -- Cpropagate
             g := (a(n) AND b(n)) OR ( g AND (a(n) OR b(n)));  -- Cgenerate
             r(n) :=  a(n) XOR b(n) XOR carry;                    -- individual bit sums
             carry :=  g OR (p AND carry);                         -- carry
         END LOOP;
         EXIT WHEN (carry = carry_end);
         carry_end := carry;
      END LOOP;
      carry_out := carry;
      -- set overflow if carry_in and carry_out of sign bit are different.
      overflow := c_iminus XOR carry;
      result(reglen-1 DOWNTO 0) := r;
      RETURN;
    END AddSub_OnesComp;
--+-----------------------------------------------------------------------------
--|     Function Name  : AddSub_OnesComp
--|  hidden procedure
--|     Overloading    : None
--|  
--|     Purpose        : Ones's Complement Addition/subtraction of ulogic vectors.
--|  
--|     Parameters     :
--|                      result     - output std_ulogic_vector, the computed sum
--|                      carry_out   - output std_logic, 
--|                      overflow   - output std_logic, overflow condition
--|                      addend     - input  std_ulogic_vector,
--|                      augend     - input  std_logic,
--|                      M          - input BIT, mode control
--|     NOTE           :
--|                      This procedure is implemented based on hardware design of a
--|                      One's complement adder/subtractor.
--|                      The inputs may be of any length  but both addend and augend
--|                      must have same lengths.
--|  
--|     Use            :
--|                      VARIABLE x, y, sum : std_ulogic_vector ( 15 DOWNTO 0);
--|                      VARIABLE ovf : std_ulogic;
--|  
--|                      AddSub_OnesComp ( sum, ovf, x, y, '0' );
--| 
--|-----------------------------------------------------------------------------
    PROCEDURE AddSub_OnesComp  ( VARIABLE result     : OUT std_ulogic_vector;
                                 VARIABLE carry_out  : OUT std_ulogic;
                                 VARIABLE overflow   : OUT std_ulogic;
                                 CONSTANT addend     :  IN std_ulogic_vector;
                                 CONSTANT augend     :  IN std_ulogic_vector;
                                 CONSTANT M          :  IN BIT := '0'
                                ) IS
 
      CONSTANT reglen    : INTEGER := addend'LENGTH;
      VARIABLE a         : std_ulogic_vector ( reglen - 1  DOWNTO 0 ) := addend;
      VARIABLE b         : std_ulogic_vector ( augend'LENGTH - 1  DOWNTO 0 ) := augend;
      VARIABLE r         : std_ulogic_vector ( reglen - 1  DOWNTO 0 );
      VARIABLE p         : std_ulogic:= '1';
      VARIABLE g         : std_ulogic:= '0';
      VARIABLE c_iminus  : std_ulogic;
      VARIABLE carry     : std_ulogic;
      VARIABLE carry_end : std_ulogic:= '0';
    BEGIN
    -- check the length of addend and augend
      ASSERT   (addend'LENGTH = augend'LENGTH)
      REPORT " AddSub_OnesComp --- operand lenght not same "
      SEVERITY ERROR;
 
    -- if the mode is subtract then invert vector b.
      IF ( M = '1') THEN
          b := NOT b;       --  this if and not is equivlent to XOR.
          carry := '1';
      ELSE
          carry := '0';
      END IF;

   -- perform the add using a simple ripple carry bit wise add.
    --  add end around carry.
 
     While true LOOP    -- to take care of end arround carry
         carry := carry_end;
         FOR n IN 0 TO reglen - 1 LOOP
             c_iminus := carry;
             p := p AND (a(n) OR b(n));                        -- Cpropagate
             g := (a(n) AND b(n)) OR ( g AND (a(n) OR b(n)));  -- Cgenerate
             r(n) :=  a(n) XOR b(n) XOR carry;                    -- individual bit sums
             carry :=  g OR (p AND carry);                         -- carry
         END LOOP;
         EXIT WHEN (carry = carry_end);
         carry_end := carry;
     END LOOP;
         carry_out := carry;

    -- set overflow if carry_in and carry_out of sign bit are different.
         overflow := c_iminus XOR carry;
         result(reglen-1 DOWNTO 0) := r;
 
    -- that's all
       RETURN;
    END AddSub_OnesComp;
 --+-----------------------------------------------------------------------------
--|     Function Name  : AddSub_SignMagnitude
--|  hidden procedure
--|     Overloading    : None
--| 
--|     Purpose        : Sign-Magnitude  Addition/subtraction of BIT_VECTORS.
--| 
--|     Parameters     :
--|                      result     - output BIT_VECTOR, the computed sum
--|                      carry_out   - output BIT, 
--|                      overflow   - output BIT, overflow condition
--|                      addend     - input  BIT_VECTOR,
--|                      augend     - input  BIT_VECTOR,
--|                      M          - input BIT, mode control
--|     NOTE           :
--|                      This procedure is implemented based on hardware design of a
--|                      Sign-Magnitude adder/subtractor.
--|                      The inputs may be of any length  but both addend and augend
--|                      must have same lengths.
--| 
--|     Use            :
--|                      VARIABLE x, y, sum : BIT_VECTOR ( 15 DOWNTO 0);
--|                      VARIABLE  ovf : BIT;
--|
--|                      AddSub_SignMagnitude ( sum, ovf, x, y, '0' );
--| 
--|-----------------------------------------------------------------------------
    PROCEDURE AddSub_SignMagnitude  ( VARIABLE result     : OUT BIT_VECTOR;
                                      VARIABLE carry_out  : OUT BIT;
                                      VARIABLE overflow   : OUT BIT;
                                      CONSTANT addend     :  IN BIT_VECTOR;
                                      CONSTANT augend     :  IN BIT_VECTOR;
                                      CONSTANT M          :  IN BIT := '0'
                                    ) IS
 
      CONSTANT reglen    : INTEGER := addend'LENGTH;
      VARIABLE a         : BIT_VECTOR ( reglen - 1  DOWNTO 0 ) := addend;
      VARIABLE b         : BIT_VECTOR ( augend'LENGTH - 1  DOWNTO 0 ) := augend;
      VARIABLE r         : BIT_VECTOR ( reglen - 1  DOWNTO 0 );
      VARIABLE p         : BIT := '1';
      VARIABLE g         : BIT := '0';
      VARIABLE carry     : BIT := M;
      VARIABLE carry_end : BIT := '0';
      VARIABLE sign_a    : BIT;
      VARIABLE sign_b    : BIT;
      VARIABLE P_cont    : BIT;
      VARIABLE Q         : BIT;

    BEGIN
 
    -- check the length of addend and augend
      ASSERT   (addend'LENGTH = augend'LENGTH)
      REPORT " AddSub_TwosComp --- operand lenght not same "
      SEVERITY ERROR;
      
      sign_b := M XOR b(reglen - 1);
      sign_a := a(reglen - 1);
      P_cont := sign_a XOR sign_b;
 
    -- if the mode is subtract then  invert the vector b.
      IF ( P_cont = '1') THEN
          b(reglen - 2 DOWNTO 0) := NOT b(reglen - 2 DOWNTO 0);  
                                          --  this if and not is equivlent to XOR.
      END IF;
 
    -- perform the add using a simple ripple carry bit wise add.
     WHILE true LOOP
         carry := carry_end;
         FOR n IN 0 TO reglen - 2 LOOP
             p := p AND (a(n) OR b(n));                        -- Cpropagate
             g := (a(n) AND b(n)) OR ( g AND (a(n) OR b(n)));  -- Cgenerate
          r(n) :=  a(n) XOR b(n) XOR carry;                    -- individual bit sums
         carry :=  g OR (p AND carry);                         -- carry
        END LOOP;
        EXIT WHEN (carry = carry_end);
        carry_end := carry;
     END LOOP;
          carry_out := carry;
       -- Multiplexor
            IF (carry = '1') THEN 
              r(reglen - 1) := sign_a;
            ELSE
              r(reglen - 1) := sign_b;
            END IF;
        -- post add/sub complementation and overflow 
           overflow := carry AND (NOT P_cont);
           Q := P_cont AND ( NOT carry);
           IF ( q= '1') THEN
                r(reglen-2 DOWNTO 0) := NOT r(reglen - 2 DOWNTO 0);
           END IF;
        
           result(reglen-1 DOWNTO 0) := r;
       RETURN;
    END AddSub_SignMagnitude;
--+-----------------------------------------------------------------------------
--|     Function Name  : AddSub_SignMagnitude
--|  hidden procedure
--|     Overloading    : None
--|
--|     Purpose        : Sign-Magnitude Addition/subtraction of LOGIC VECTORS.
--|
--|     Parameters     :
--|                      result     - output std_logic_vector, the computed sum
--|                      carry_out   - output std_logic, overflow condition
--|                      overflow   - output std_logic, overflow condition
--|                      addend     - input  std_logic_vector,
--|                      augend     - input  std_logic,
--|                      M          - input BIT, mode control
--|     NOTE           :
--|                      This procedure is implemented based on hardware design of a
--|                      Sign-Magnitude adder/subtractor.
--|                      The inputs may be of any length  but both addend and augend
--|                      must have same lengths.
--|
--|     Use            :
--|                      VARIABLE x, y, sum : std_logic_vector ( 15 DOWNTO 0);
--|                      VARIABLE ovf : std_ulogic;
--|
--|                      AddSub_SignMagnitude ( sum,  ovf, x, y, '0' );
--| 
--|-----------------------------------------------------------------------------
    PROCEDURE AddSub_SignMagnitude  ( VARIABLE result     : OUT std_logic_vector;
                                      VARIABLE carry_out  : OUT std_ulogic;
                                      VARIABLE overflow   : OUT std_ulogic;
                                      CONSTANT addend     :  IN std_logic_vector;
                                      CONSTANT augend     :  IN std_logic_vector;
                                      CONSTANT M          :  IN BIT := '0'
                                    ) IS
 
      CONSTANT reglen    : INTEGER := addend'LENGTH;
      VARIABLE a         : std_logic_vector ( reglen - 1  DOWNTO 0 ) := addend;
      VARIABLE b         : std_logic_vector ( augend'LENGTH - 1  DOWNTO 0 ) := augend;
      VARIABLE r         : std_logic_vector ( reglen - 1  DOWNTO 0 );
      VARIABLE p         : std_ulogic:= '1';
      VARIABLE g         : std_ulogic:= '0';
      VARIABLE c_iminus  : std_ulogic;
      VARIABLE carry     : std_ulogic;
      VARIABLE carry_end : std_ulogic:='0';
      VARIABLE sign_a    : std_ulogic;
      VARIABLE sign_b    : std_ulogic;
      VARIABLE P_cont    : std_ulogic;
      VARIABLE Q         : std_ulogic;
    BEGIN
   -- check the length of addend and augend
      ASSERT   (addend'LENGTH = augend'LENGTH)
      REPORT " AddSub_TwosComp --- operand lenght not same "
      SEVERITY ERROR;
         --              because M is a bit                     
      IF ( M = '1') THEN
        sign_b := NOT b(reglen - 1);
      ELSE
        sign_b := b(reglen - 1);
      END IF;   
      sign_a := a(reglen - 1);
           P_cont := sign_a XOR sign_b;
 
    -- Pre-add/sub inversion of vector b.
       FOR j IN reglen - 2 DOWNTO 0 LOOP
            b(j) := P_cont XOR b(j);
       END LOOP;
 
    -- perform the add using a simple ripple carry bit wise add.
     WHILE true LOOP
         carry := carry_end;
         FOR n IN 0 TO reglen - 2 LOOP
             p := p AND (a(n) OR b(n));                        -- Cpropagate
             g := (a(n) AND b(n)) OR ( g AND (a(n) OR b(n)));  -- Cgenerate
          r(n) :=  a(n) XOR b(n) XOR carry;                    -- individual bit sums
         carry :=  g OR (p AND carry);                         -- carry
        END LOOP;
        EXIT WHEN (carry = carry_end);
        carry_end := carry;
     END LOOP;
          carry_out := carry;
       -- Multiplexor for calculating the sign
           r(reglen - 1) := ((carry AND sign_a) OR ((NOT carry) AND sign_b));

        -- post add/sub complementation and overflow
           overflow := carry AND (NOT P_cont);
           Q := P_cont AND ( NOT carry);
           FOR j IN reglen - 2 DOWNTO 0 LOOP
              r(j) := Q XOR r(j);
           END LOOP;
           result(reglen-1 DOWNTO 0) := r;
 
    -- that's all
       RETURN;
    END;

--+-----------------------------------------------------------------------------
--|     Function Name  : AddSub_SignMagnitude
--|  hidden procedure
--|     Overloading    : None
--|
--|     Purpose        : Sign-Magnitude Addition/subtraction of ulogic vectors.
--|
--|     Parameters     :
--|                      result     - output std_ulogic_vector, the computed sum
--|                      carry_out   - output std_logic, overflow condition
--|                      overflow   - output std_logic, overflow condition
--|                      addend     - input  std_ulogic_vector,
--|                      augend     - input  std_logic,
--|                      M          - input BIT, mode control
--|     NOTE           :
--|                      This procedure is implemented based on hardware design of a
--|                      Sign-Magnitude adder/subtractor.
--|                      The inputs may be of any length  but both addend and augend
--|                      must have same lengths.
--|
--|     Use            :
--|                      VARIABLE x, y, sum : std_ulogic_vector ( 15 DOWNTO 0);
--|                      VARIABLE ovf : std_ulogic;
--|
--|                      AddSub_SignMagnitude ( sum,  ovf, x, y, '0' );
--| 
--|-----------------------------------------------------------------------------
    PROCEDURE AddSub_SignMagnitude  ( VARIABLE result     : OUT std_ulogic_vector;
                                      VARIABLE carry_out  : OUT std_ulogic;
                                      VARIABLE overflow   : OUT std_ulogic;
                                      CONSTANT addend     :  IN std_ulogic_vector;
                                      CONSTANT augend     :  IN std_ulogic_vector;
                                      CONSTANT M          :  IN BIT := '0'
                                    ) IS
 
      CONSTANT reglen    : INTEGER := addend'LENGTH;
      VARIABLE a         : std_ulogic_vector ( reglen - 1  DOWNTO 0 ) := addend;
      VARIABLE b         : std_ulogic_vector ( augend'LENGTH - 1  DOWNTO 0 ) := augend;
      VARIABLE r         : std_ulogic_vector ( reglen - 1  DOWNTO 0 );
      VARIABLE p         : std_ulogic:= '1';
      VARIABLE g         : std_ulogic:= '0';
      VARIABLE c_iminus  : std_ulogic;
      VARIABLE carry     : std_ulogic;
      VARIABLE carry_end : std_ulogic:='0';
      VARIABLE sign_a    : std_ulogic;
      VARIABLE sign_b    : std_ulogic;
      VARIABLE P_cont    : std_ulogic;
      VARIABLE Q         : std_ulogic;
    BEGIN
   -- check the length of addend and augend
      ASSERT   (addend'LENGTH = augend'LENGTH)
      REPORT " AddSub_TwosComp --- operand lenght not same "
      SEVERITY ERROR;
         --              because M is a bit                     
      IF ( M = '1') THEN
        sign_b := NOT b(reglen - 1);
      ELSE
        sign_b := b(reglen - 1);
      END IF;   
      sign_a := a(reglen - 1);
           P_cont := sign_a XOR sign_b;
 
    -- Pre-add/sub inversion of vector b.
       FOR j IN reglen - 2 DOWNTO 0 LOOP
            b(j) := P_cont XOR b(j);
       END LOOP;
 
    -- perform the add using a simple ripple carry bit wise add.
     WHILE true LOOP
         carry := carry_end;
         FOR n IN 0 TO reglen - 2 LOOP
             p := p AND (a(n) OR b(n));                        -- Cpropagate
             g := (a(n) AND b(n)) OR ( g AND (a(n) OR b(n)));  -- Cgenerate
          r(n) :=  a(n) XOR b(n) XOR carry;                    -- individual bit sums
         carry :=  g OR (p AND carry);                         -- carry
        END LOOP;
        EXIT WHEN (carry = carry_end);
        carry_end := carry;
     END LOOP;
          carry_out := carry;
       -- Multiplexor for calculating the sign
           r(reglen - 1) := ((carry AND sign_a) OR ((NOT carry) AND sign_b));

        -- post add/sub complementation and overflow
           overflow := carry AND (NOT P_cont);
           Q := P_cont AND ( NOT carry);
           FOR j IN reglen - 2 DOWNTO 0 LOOP
              r(j) := Q XOR r(j);
           END LOOP;
           result(reglen-1 DOWNTO 0) := r;
 
    -- that's all
       RETURN;
    END;

    -------------------------------------------------------------------------------
    --     Procedure Name : RegAbs
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
    --                      VARIABLE reslt, vect : std_logic_vector ( 15 DOWNTO 0 );
    --
    --                       RegAbs ( reslt,  vect, TwosComp );
    --
    -------------------------------------------------------------------------------
    PROCEDURE RegAbs  ( VARIABLE result     : INOUT std_logic_vector;
                        CONSTANT SrcReg     : IN std_logic_vector;
                        CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                      ) IS
       VARIABLE reglen       : INTEGER := SrcReg'LENGTH;
       VARIABLE result_copy : std_logic_vector (result'LENGTH - 1 DOWNTO 0) := result;
       VARIABLE reg          : std_logic_vector (SrcReg'LENGTH - 1 DOWNTO 0);
    --
    BEGIN
    --
    --   Null range check
    --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegAbs ---  Destination has null range. "
             SEVERITY ERROR;
             RETURN;
       END IF;
    
     -- if the input is of null range 
       IF (SrcReg'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegAbs --- input has null range "
             SEVERITY ERROR;
             result_copy := (OTHERS => '0');
             result := result_copy;
             RETURN;
             
       ELSE
            reg := SrcReg;
            CASE SrcRegMode IS
               WHEN TwosComp   => -- if a negative value, take two's comp it
                                   -- will become absolute
                                IF (reg(reglen - 1) /= '0') THEN
                                    -- if not largest negative number
                                    IF ( No_One(reg(reglen - 2 downto 0))) THEN
                                        ASSERT false
                                        REPORT "RegAbs  --  2's comp std_logic_vector   (" & TO_String(reg) 
                                         & ")   cannot be converted. "
                                        SEVERITY Error;   
                                        reg := Propagate_X(reg);
                                     ELSE
                                        reg := RegNegate ( reg, TwosComp);
                                     END IF;
                                END IF;
              WHEN OnesComp   => -- if a negative value, take RegNegate
                                 -- it will become absolute.
                                 IF (reg(reglen - 1) /= '0') THEN
                                    reg := RegNegate (reg, OnesComp);
                                 END IF;
 
              WHEN SignMagnitude
                           =>
                           -- if a negative value, clear the sign bit (forming
                           -- the absolute)
                             IF (reg(reglen - 1) /= '0') THEN
                                reg(reglen - 1) := '0';
                             END IF;
 
               WHEN unsigned
                             =>
                            --  no translation required.
                             NULL;
               WHEN OTHERS
                             =>
                             -- An unknown SrcRegMode value was passed
                               ASSERT FALSE
                               REPORT "RegAbs - Unknown vector mode"
                               SEVERITY ERROR;
          END CASE;
       END IF;
   
       IF (result'LENGTH < reglen) THEN
              ASSERT NOT WarningsOn
              REPORT " RegAbs --- Destination Length smaller than the " &
                       " source length   "
              SEVERITY WARNING;
       ELSIF ( result'LENGTH > reglen ) THEN
              ASSERT NOT WarningsOn
              REPORT " RegAbs --- Destination Length larger than the " &
                       " source length. "
              SEVERITY WARNING;
       END IF;

       reglen := MINIMUM (reglen, result'LENGTH);
       result_copy ( reglen - 1 downto 0 ) := To_X01(reg ( reglen - 1 downto 0 ));
       result := result_copy;

       RETURN;
    END;

    -------------------------------------------------------------------------------
    --     Procedure Name : RegAbs
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
    --                      VARIABLE reslt, vect : std_ulogic_vector ( 15 DOWNTO 0 );
    --
    --                       RegAbs ( reslt,  vect, TwosComp );
    --
    -------------------------------------------------------------------------------
    PROCEDURE RegAbs  ( VARIABLE result     : INOUT std_ulogic_vector;
                        CONSTANT SrcReg     : IN std_ulogic_vector;
                        CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                      ) IS
       VARIABLE reglen       : INTEGER := SrcReg'LENGTH;
       VARIABLE reslt_copy  : std_ulogic_vector (result'LENGTH - 1 DOWNTO 0) := result;
       VARIABLE reg          : std_ulogic_vector (SrcReg'LENGTH - 1 DOWNTO 0);
    --
    BEGIN
    --
    --   Null range check
    --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegAbs ---  Destination has null range. "
             SEVERITY ERROR;
             RETURN;
       END IF;
    
     -- if the input is of null range 
       IF (SrcReg'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegAbs --- input has null range "
             SEVERITY ERROR;
             reslt_copy := (OTHERS => '0');
             result := reslt_copy;
             RETURN;
             
       ELSE
            reg := SrcReg;
            CASE SrcRegMode IS

               WHEN TwosComp   => -- if a negative value, take two's comp it
                                   -- will become absolute
                                IF (reg(reglen - 1) /= '0') THEN
                                    -- if not largest negative number
                                    IF (No_One(reg(reglen - 2 downto 0))) THEN
                                        ASSERT false
                                        REPORT "RegAbs  --  2's comp std_ulogic_vector   (" & TO_String(reg) 
                                         & ")   cannot be converted. "
                                        SEVERITY Error;   
                                        reg := Propagate_X(reg);
                                    ELSE  
                                        reg := RegNegate ( reg, TwosComp);
                                    END IF; 
                                END IF;

              WHEN OnesComp
                           =>
                           -- if a negative value, take RegNegate
                           -- it will become absolute.
                             IF (reg(reglen - 1) /= '0') THEN
                                reg := RegNegate (reg, OnesComp);
                             END IF;
 
              WHEN SignMagnitude
                           =>
                           -- if a negative value, clear the sign bit (forming
                           -- the absolute)
                             IF (reg(reglen - 1) /= '0') THEN
                                reg(reglen - 1) := '0';
                             END IF;
 
               WHEN unsigned
                             =>
                            --  no translation required.
                             NULL;
               WHEN OTHERS
                             =>
                             -- An unknown SrcRegMode value was passed
                               ASSERT FALSE
                               REPORT "RegAbs - Unknown vector mode"
                               SEVERITY ERROR;
          END CASE;
       END IF;
   
       IF (result'LENGTH < reglen) THEN
              ASSERT NOT WarningsOn
              REPORT " RegAbs --- Destination Length smaller than the " &
                       " source length   "
              SEVERITY WARNING;
       ELSIF ( result'LENGTH > reglen ) THEN
              ASSERT NOT WarningsOn
              REPORT " RegAbs --- Destination Length larger than the " &
                       " source length. "
              SEVERITY WARNING;
       END IF;

       reglen := MINIMUM (reglen, result'LENGTH);
       reslt_copy ( reglen - 1 downto 0 ) := To_X01(reg ( reglen-1 downto 0 ));
       result := reslt_copy;
       RETURN;
    END;
    
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
    --                      result     - input-output  bit_vector, 
    --                      SrcReg     - input  bit_vector, the vector to be read.
    --                      SrcRegMode - input  regmode_type, indicating the format of
    --                                the input bit_vector.   Default is TwosComp.
    --
    --
    --     Use            :
    --                      VARIABLE reslt, vect : bit_vector ( 15 DOWNTO 0 );
    --
    --                       RegAbs ( reslt,  vect, TwosComp );
    --
    -------------------------------------------------------------------------------
    PROCEDURE RegAbs  ( VARIABLE result     : INOUT bit_vector;
                        CONSTANT SrcReg     : IN bit_vector;
                        CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                      ) IS
    VARIABLE reglen       : INTEGER := SrcReg'LENGTH;
    VARIABLE result_copy : BIT_VECTOR (result'LENGTH - 1 DOWNTO 0) := result;
    VARIABLE reg          : BIT_VECTOR (SrcReg'LENGTH - 1 DOWNTO 0);
    --
    BEGIN
    --
    --  Null range check
    --  if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegAbs ---  Destination has null range. "
             SEVERITY ERROR;
             RETURN;
       END IF;

    --  if the input is of null range 
       IF (SrcReg'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegAbs --- input has null range "
             SEVERITY ERROR;
             result_copy := (OTHERS => '0');
             result := result_copy;
             RETURN;
             
       ELSE
            reg := SrcReg;
            CASE SrcRegMode IS
               WHEN TwosComp  =>  -- if a negative value, take RegNegate
                                  -- will become absolute
                                IF (reg(reglen - 1) /= '0') THEN
                                    IF (No_One(reg(reglen - 2 downto 0))) THEN
                                        ASSERT false
                                        REPORT "RegAbs  --  2's comp bit_vector   (" & TO_String(reg) 
                                         & ")   cannot be converted.  "
                                        SEVERITY Error;   
                                    ELSE
                                        reg := RegNegate ( reg, TwosComp);
                                    END IF;
                                END IF;

                WHEN OnesComp
                             =>
                             -- if a negative value, take RegNegate
                             -- it will become absolute.
                               IF (reg(reglen - 1) /= '0') THEN
                                  reg := RegNegate (reg, OnesComp);
                               END IF;
 
                WHEN SignMagnitude
                              =>
                             -- if a negative value, clear the sign bit (forming
                             -- the absolute)
                               IF (reg(reglen - 1) /= '0') THEN
                                  reg(reglen - 1) := '0';
                               END IF;
 
                WHEN unsigned
                              =>
                              --  no translation required.
                              NULL;
                WHEN OTHERS
                              =>
                             -- An unknown SrcRegMode value was passed
                              ASSERT FALSE
                              REPORT "RegAbs - Unknown vector mode"
                              SEVERITY ERROR;
            END CASE;
       END IF;  

       IF (result'LENGTH < reglen) THEN
              ASSERT NOT WarningsOn
              REPORT " RegAbs --- Destination Length smaller than the " &
                       " source length   "
              SEVERITY WARNING;
       ELSIF ( result'LENGTH > reglen ) THEN
              ASSERT NOT WarningsOn
              REPORT " RegAbs --- Destination Length larger than the " &
                       " source length. "
              SEVERITY WARNING;
       END IF;

       reglen := MINIMUM (reglen, result'LENGTH);
       result_copy ( reglen - 1 downto 0 ) := reg ( reglen - 1 downto 0 );
       result := result_copy;

       RETURN;
    END;
 
--+-----------------------------------------------------------------------------
--|     Function Name  : RegAdd
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
                      ) IS
      VARIABLE reslen       : INTEGER := MAXIMUM ( addend'LENGTH, augend'LENGTH );
      VARIABLE a, b, r      : BIT_VECTOR ( reslen - 1 DOWNTO 0 );
      VARIABLE result_copy  : BIT_VECTOR ( result'length-1 downto 0 ) := result;
      variable reslen2      : integer;

     BEGIN 
     --  
     --   Null range check
     --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegAdd ---  Destination has null range. "
             SEVERITY ERROR;
             RETURN;
     --   if addend or augned or both have null range no need to add
       ELSIF (addend'LENGTH = 0) AND (augend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegAdd --- both addend  and augend has null range "
             SEVERITY ERROR;
             result_copy :=  (OTHERS => '0');
             IF (carry_in = '1') THEN
                 IF (SrcRegMode = TwosComp OR SrcRegMode = Unsigned) THEN
                        result_copy(0) := '1';
                 END IF;
             END IF;
             result := result_copy; 
             carry_out := '0';
             overflow := '0';       
             RETURN;      
       END IF;

     -- if one of the addend or augend is null 
       IF (addend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegAdd --- addend has null range "
             SEVERITY ERROR;
             a :=  ( OTHERS => '0');     -- treat it as	zero's            
             b := augend;

       ELSIF (augend'LENGTH = 0) THEN 
             ASSERT false
             REPORT " RegAdd ---  augend has null range "
             SEVERITY ERROR;
             b :=  (OTHERS => '0');                 
             a := addend;
              
                 -- inputs are  not null so sign extend them to the same length.  
       ELSE
             a := SignExtend(addend , reslen, addend'LEFT, SrcRegMode);
             b := SignExtend(augend , reslen, augend'LEFT, SrcRegMode);

       END IF;	

     -- Perform addition operation.
     --
       CASE SrcRegMode IS
               WHEN TwosComp
                        => 
                          Add_TwosComp(r,carry_out, overflow,a, b, carry_in); 
         
               WHEN OnesComp 
                         =>
                         -- ignore carry_in istead pass mode M as '0'
                          AddSub_OnesComp(r, carry_out,overflow,a,b, '0');
        
               WHEN SignMagnitude 
                          =>
                         -- ignore carry_in istead pass mode M as '0'
                           AddSub_SignMagnitude(r, carry_out, overflow, a, b, '0');
        
               WHEN Unsigned 
                          =>
                           Add_Unsigned(r, carry_out,overflow, a, b, carry_in);
                 
               WHEN OTHERS 
                          =>
                           ASSERT FALSE
                           REPORT " RegAdd ---- Unknown mode was passed "
                           SEVERITY ERROR;
       END CASE;
         
       IF (result'LENGTH < reslen) THEN
              ASSERT NOT WarningsOn  
              REPORT " RegAdd --- Destination Length smaller than the " &
                       " calculated value. "
              SEVERITY WARNING;
       ELSIF ( result'LENGTH > reslen ) THEN
              ASSERT NOT WarningsOn  
              REPORT " RegAdd --- Destination Length larger than the " &
                       " calculated value. "
              SEVERITY WARNING;
       END IF; 

       reslen2 := MINIMUM ( reslen, result'length );
       result_copy(reslen2 - 1 downto 0 ) := r(reslen2 - 1 downto 0);
       result := result_copy;

     -- That's all
       RETURN;
     END;

--+-----------------------------------------------------------------------------
--|     Function Name  : RegAdd
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
                      ) IS
      VARIABLE reslen       : INTEGER := MAXIMUM ( addend'LENGTH, augend'LENGTH );
      VARIABLE a, b, r      : std_logic_vector ( reslen - 1 DOWNTO 0 );
      VARIABLE reslt_copy   : std_logic_vector ( result'length-1 downto 0 ) := result;
      VARIABLE carry_loc    : std_ulogic; 
      VARIABLE overflow_loc : std_ulogic;
      VARIABLE reslen2      : INTEGER;
     BEGIN
     --  
     --   Null range check
     --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegAdd ---  Destination has null range. " &
                    " cannot save result. "
             SEVERITY ERROR;
             RETURN;
     --   if addend or augned or both have null range no need to add
       ELSIF (addend'LENGTH = 0) AND (augend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegAdd --- both addend  and augend has null range "
             SEVERITY ERROR;
             reslt_copy :=  (OTHERS => '0');
             IF (carry_in = '1') THEN
                 IF (SrcRegMode = TwosComp OR SrcRegMode = Unsigned) THEN
                        reslt_copy(0) := '1';
                 END IF;
             END IF;
             result := reslt_copy; 
             carry_out := '0';
             overflow := '0';       
             RETURN;      
       END IF;

     -- if one of the addend or augend is null 
       IF (addend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegAdd --- addend has null range "
             SEVERITY ERROR;
             a :=  ( OTHERS => '0');     -- treat it as	zero's            
             b := augend;

       ELSIF (augend'LENGTH = 0) THEN 
             ASSERT false
             REPORT " RegAdd ---  augend has null range "
             SEVERITY ERROR;
             b :=  (OTHERS => '0');           -- treat augend as zero      
             a := addend;
              
                 -- inputs are  not null so sign extend them to the same length.  
       ELSE
             a := SignExtend(addend, reslen, addend'LEFT, SrcRegMode);
             b := SignExtend(augend, reslen, augend'LEFT, SrcRegMode);

       END IF;	

     -- Perform addition operation.
       CASE SrcRegMode IS
               WHEN TwosComp
                        => 
                          Add_TwosComp(r,carry_loc, overflow_loc,a,b, carry_in); 
         
               WHEN OnesComp 
                         =>
                         -- ignore carry_in istead pass mode M as '0'
                          AddSub_OnesComp(r, carry_loc,overflow_loc,a,b, '0');
        
               WHEN SignMagnitude 
                          =>
                         -- ignore carry_in istead pass mode M as '0'
                           AddSub_SignMagnitude(r, carry_loc, overflow_loc, a, b, '0');
        
               WHEN Unsigned 
                          =>
                           Add_Unsigned(r, carry_loc,overflow_loc, a, b, carry_in);
                 
               WHEN OTHERS 
                          =>
                           ASSERT FALSE
                           REPORT " RegAdd ---- Unknown mode was passed "
                           SEVERITY ERROR;
       END CASE;
         
       IF (result'LENGTH < reslen) THEN
              ASSERT NOT WarningsOn  
              REPORT " RegAdd --- Destination Length smaller than the " &
                       " calculated value. "
              SEVERITY WARNING;
       ELSIF ( result'LENGTH > reslen ) THEN
              ASSERT NOT WarningsOn  
              REPORT " RegAdd --- Destination Length larger than the " &
                       " calculated value. "
              SEVERITY WARNING;
       END IF; 

       reslen2 := MINIMUM ( reslen, result'length );
       reslt_copy( reslen2-1 downto 0 ) := To_X01(r( reslen2-1 downto 0 ));
       result := reslt_copy;
       carry_out := To_X01(carry_loc);
       overflow := To_X01(overflow_loc);

     -- That's all
       RETURN;
     END;

--+-----------------------------------------------------------------------------
--|     Function Name  : RegAdd
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
                      ) IS
      VARIABLE reslen       : INTEGER := MAXIMUM ( addend'LENGTH, augend'LENGTH );
      VARIABLE a, b, r      : std_ulogic_vector ( reslen - 1 DOWNTO 0 );
      VARIABLE result_copy  : std_ulogic_vector ( result'length-1 downto 0 ) := result;
      VARIABLE carry_loc    : std_ulogic; 
      VARIABLE overflow_loc : std_ulogic;
      VARIABLE reslen2      : INTEGER;

     BEGIN
     --  
     --   Null range check
     --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegAdd ---  Destination has null range. " &
                    " cannot save result. "
             SEVERITY ERROR;
             RETURN;
     --   if addend or augned or both have null range no need to add
       ELSIF (addend'LENGTH = 0) AND (augend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegAdd --- both addend  and augend has null range "
             SEVERITY ERROR;
             result_copy :=  (OTHERS => '0');
             IF (carry_in = '1') THEN
                 IF (SrcRegMode = TwosComp OR SrcRegMode = Unsigned) THEN
                        result_copy(0) := '1';
                 END IF;
             END IF;
             result := result_copy; 
             carry_out := '0';
             overflow := '0';       
             RETURN;      
       END IF;

     -- if one of the addend or augend is null 
       IF (addend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegAdd --- addend has null range "
             SEVERITY ERROR;
             a :=  ( OTHERS => '0');     -- treat it as	zero's            
             b := augend;

       ELSIF (augend'LENGTH = 0) THEN 
             ASSERT false
             REPORT " RegAdd ---  augend has null range "
             SEVERITY ERROR;
             b :=  (OTHERS => '0');           -- treat augend as zero      
             a := addend;
              
                 -- inputs are  not null so sign extend them to the same length.  
       ELSE
             a := SignExtend(addend, reslen, addend'LEFT, SrcRegMode);
             b := SignExtend(augend, reslen, augend'LEFT, SrcRegMode);

       END IF;	

     -- Perform addition operation.
       CASE SrcRegMode IS
               WHEN TwosComp
                        => 
                          Add_TwosComp(r,carry_loc, overflow_loc,a,b, carry_in); 
         
               WHEN OnesComp 
                         =>
                         -- ignore carry_in istead pass mode M as '0'
                          AddSub_OnesComp(r, carry_loc,overflow_loc,a,b, '0');
        
               WHEN SignMagnitude 
                          =>
                         -- ignore carry_in istead pass mode M as '0'
                           AddSub_SignMagnitude(r, carry_loc, overflow_loc, a, b, '0');
        
               WHEN Unsigned 
                          =>
                           Add_Unsigned(r, carry_loc,overflow_loc, a, b, carry_in);
                 
               WHEN OTHERS 
                          =>
                           ASSERT FALSE
                           REPORT " RegAdd ---- Unknown mode was passed "
                           SEVERITY ERROR;
       END CASE;
         
       IF (result'LENGTH < reslen) THEN
              ASSERT NOT WarningsOn  
              REPORT " RegAdd --- Destination Length smaller than the " &
                       " calculated value. "
              SEVERITY WARNING;
       ELSIF ( result'LENGTH > reslen ) THEN
              ASSERT NOT WarningsOn  
              REPORT " RegAdd --- Destination Length larger than the " &
                       " calculated value. "
              SEVERITY WARNING;
       END IF; 

       reslen2 := MINIMUM ( reslen, result'length );
       result_copy( reslen2-1 downto 0 ) := To_X01(r( reslen2-1 downto 0 ));
       result := result_copy;
       carry_out := To_X01(carry_loc);
       overflow := To_X01(overflow_loc);

     -- That's all
       RETURN;
     END;
          
--+-----------------------------------------------------------------------------
--|     Function Name  : Sub_TwosComp
--|  hidden procedure
--|     Overloading    : None
--|
--|     Purpose        : Two's Complement subtraction of BIT_VECTORS.
--|
--|     Parameters     :
--|                      result     - output BIT_VECTOR, the computed sum
--|                      borrow_out   - output BIT,
--|                      overflow   - output BIT, overflow condition
--|                      addend     - input  BIT_VECTOR,
--|                      augend     - input  BIT_VECTOR,
--|                      borrow_in   - input BIT,
--|     NOTE           :
--|                      This procedure is implemented based on hardware design of a
--|                      Two's complement subtractor described in [HWANG 79].
--|                      The inputs may be of any length  but both addend and augend
--|                      must have same lengths.
--|
--|     Use            :
--|                      VARIABLE x, y, sum : BIT_VECTOR ( 15 DOWNTO 0);
--|                      VARIABLE borrow, ovf : BIT;
--|
--|                      Sub_TwosComp ( sum, borrow, ovf, x, y, '0' );
--| 
--|   Reference        :
--|                      Computer Arithmetic Principles, Architecture, and Design
--|                            by    Kai Hwang
--|
--|-----------------------------------------------------------------------------
    PROCEDURE Sub_TwosComp  ( VARIABLE result     : OUT BIT_VECTOR;
                              VARIABLE borrow_out : OUT BIT;
                              VARIABLE underflow  : OUT BIT;
                              CONSTANT minuend    : IN BIT_VECTOR;
                              CONSTANT subtrahend : IN BIT_VECTOR;
                              CONSTANT borrow_in  : IN BIT          := '0'
                             ) IS
      CONSTANT reglen   : INTEGER :=  minuend'LENGTH;
      VARIABLE a        : BIT_VECTOR ( reglen - 1  DOWNTO 0 ) := minuend;
      VARIABLE b        : BIT_VECTOR ( subtrahend'LENGTH - 1  DOWNTO 0 ) := subtrahend;
      VARIABLE r        : BIT_VECTOR ( reglen - 1  DOWNTO 0 );
      VARIABLE p        : BIT := '1';
      VARIABLE g        : BIT := '0';
      VARIABLE carry    : BIT;
      VARIABLE c_iminus : BIT;
    BEGIN

 -- check the length of minuend and subtrahend
      ASSERT   (minuend'LENGTH = subtrahend'LENGTH)
      REPORT " Sub_TwosComp --- operand length not same "
      SEVERITY ERROR;
 
 
    -- The operation of (a - b - borrow_in) when a,b are Two's complement
    -- numbers can be computed
    --  as   a + (NOT b + 1) - borrow_in
    --  or   a + (NOT b) + (1-borrow_in)
    --  or   a + (NOT b) + (NOT borrow_in)
 
    -- perform the subtract
      carry := NOT borrow_in;
      FOR n IN 0 TO reglen - 1 LOOP
          c_iminus := carry;
          b(n) := NOT b(n);
             p := p AND (a(n) OR b(n));                         -- Cpropagate
             g := (a(n) AND b(n)) OR ( g AND (a(n) OR b(n)));   -- Cgenerate
          r(n) :=  a(n) XOR b(n) XOR carry;                     -- individual bit sums
         carry :=  g OR (p AND carry);                         -- carry
      END LOOP;
      borrow_out := NOT carry;
-- set overflow if carry_in and carry_out of sign bit are different.
         underflow := c_iminus XOR carry;
         result(reglen-1 DOWNTO 0) := r;
 
    -- that's all
       RETURN;
    END; 

--+-----------------------------------------------------------------------------
--|     Function Name  : Sub_TwosComp
--|  hidden procedure
--|     Overloading    : None
--|
--|     Purpose        : Two's Complement subtraction of logic vectors.
--|
--|     Parameters     :
--|                      result     - output std_logic_vector, the computed sum
--|                      borrow_out   - output std_logic,
--|                      underflow   - output std_logic, overflow condition
--|                      addend     - input  std_logic_vector,
--|                      augend     - input  std_logic_vector,
--|                      borrow_in   - input std_logic,
--|     NOTE           :
--|                      This procedure is implemented based on hardware design of a
--|                      Two's complement subtractor described in [HWANG 79].
--|                      The inputs may be of any length  but both addend and augend
--|                      must have same lengths.
--|
--|     Use            :
--|                      VARIABLE x, y, sum : std_logic_vector ( 15 DOWNTO 0);
--|                      VARIABLE borrow, ovf : std_ulogic;
--|
--|                      Sub_TwosComp ( sum, borrow, ovf, x, y, '0' );
--|
--|   Reference        :
--|                      Computer Arithmetic Principles, Architecture, and Design
--|                            by    Kai Hwang
--|
--|-----------------------------------------------------------------------------
    PROCEDURE Sub_TwosComp  ( VARIABLE result     : OUT std_logic_vector;
                              VARIABLE borrow_out : OUT std_ulogic;
                              VARIABLE underflow  : OUT std_ulogic;
                              CONSTANT minuend    :  IN std_logic_vector;
                              CONSTANT subtrahend :  IN std_logic_vector;
                              CONSTANT borrow_in  :  IN std_ulogic         := '0'
                             ) IS
      CONSTANT reglen   : INTEGER :=  minuend'LENGTH;
      VARIABLE a        : std_logic_vector ( reglen - 1  DOWNTO 0 ) := minuend;
      VARIABLE b        : std_logic_vector ( subtrahend'LENGTH - 1  DOWNTO 0 ) := subtrahend;
      VARIABLE r        : std_logic_vector ( reglen - 1  DOWNTO 0 );
      VARIABLE p        : std_ulogic:= '1';
      VARIABLE g        : std_ulogic:= '0';
      VARIABLE c_iminus : std_ulogic;
      VARIABLE carry    : std_ulogic;
    BEGIN
-- check the length of minuend and subtrahend
      ASSERT   (minuend'LENGTH = subtrahend'LENGTH)
      REPORT " Sub_TwosComp --- operand length not same "
      SEVERITY ERROR;
 
 
    -- The operation of (a - b - borrow_in) when a,b are Two's complement
    -- numbers can be computed
    --  as   a + (NOT b + 1) - borrow_in
    --  or   a + (NOT b) + (1-borrow_in)
    --  or   a + (NOT b) + (NOT borrow_in)
 
    -- perform the subtract
      carry := NOT borrow_in;
      FOR n IN 0 TO reglen - 1 LOOP
          c_iminus := carry;
          b(n) := NOT b(n);
             p := p AND (a(n) OR b(n));                         -- Cpropagate
             g := (a(n) AND b(n)) OR ( g AND (a(n) OR b(n)));   -- Cgenerate
          r(n) :=  a(n) XOR b(n) XOR carry;                     -- individual bit sums
         carry :=  g OR (p AND carry);                         -- carry
      END LOOP;
      borrow_out := NOT carry;
-- set overflow if carry_in and carry_out of sign bit are different.
         underflow := c_iminus XOR carry;
         result(reglen-1 DOWNTO 0) := r;
 
    -- that's all
       RETURN;
    END;

--+-----------------------------------------------------------------------------
--|     Function Name  : Sub_TwosComp
--|  hidden procedure
--|     Overloading    : None
--|
--|     Purpose        : Two's Complement subtraction of ulogic vectors.
--|
--|     Parameters     :
--|                      result     - output std_ulogic_vector, the computed sum
--|                      borrow_out   - output std_logic,
--|                      underflow   - output std_logic, overflow condition
--|                      addend     - input  std_ulogic_vector,
--|                      augend     - input  std_ulogic_vector,
--|                      borrow_in   - input std_logic,
--|     NOTE           :
--|                      This procedure is implemented based on hardware design of a
--|                      Two's complement subtractor described in [HWANG 79].
--|                      The inputs may be of any length  but both addend and augend
--|                      must have same lengths.
--|
--|     Use            :
--|                      VARIABLE x, y, sum : std_ulogic_vector ( 15 DOWNTO 0);
--|                      VARIABLE borrow, ovf : std_ulogic;
--|
--|                      Sub_TwosComp ( sum, borrow, ovf, x, y, '0' );
--|
--|   Reference        :
--|                      Computer Arithmetic Principles, Architecture, and Design
--|                            by    Kai Hwang
--|
--|-----------------------------------------------------------------------------
    PROCEDURE Sub_TwosComp  ( VARIABLE result     : OUT std_ulogic_vector;
                              VARIABLE borrow_out : OUT std_ulogic;
                              VARIABLE underflow  : OUT std_ulogic;
                              CONSTANT minuend    :  IN std_ulogic_vector;
                              CONSTANT subtrahend :  IN std_ulogic_vector;
                              CONSTANT borrow_in  :  IN std_ulogic         := '0'
                             ) IS
      CONSTANT reglen   : INTEGER :=  minuend'LENGTH;
      VARIABLE a        : std_ulogic_vector ( reglen - 1  DOWNTO 0 ) := minuend;
      VARIABLE b        : std_ulogic_vector ( subtrahend'LENGTH - 1  DOWNTO 0 ) := subtrahend;
      VARIABLE r        : std_ulogic_vector ( reglen - 1  DOWNTO 0 );
      VARIABLE p        : std_ulogic:= '1';
      VARIABLE g        : std_ulogic:= '0';
      VARIABLE c_iminus : std_ulogic;
      VARIABLE carry    : std_ulogic;
    BEGIN
-- check the length of minuend and subtrahend
      ASSERT   (minuend'LENGTH = subtrahend'LENGTH)
      REPORT " Sub_TwosComp --- operand length not same "
      SEVERITY ERROR;
 
 
    -- The operation of (a - b - borrow_in) when a,b are Two's complement
    -- numbers can be computed
    --  as   a + (NOT b + 1) - borrow_in
    --  or   a + (NOT b) + (1-borrow_in)
    --  or   a + (NOT b) + (NOT borrow_in)
 
    -- perform the subtract
      carry := NOT borrow_in;
      FOR n IN 0 TO reglen - 1 LOOP
          c_iminus := carry;
          b(n) := NOT b(n);
             p := p AND (a(n) OR b(n));                         -- Cpropagate
             g := (a(n) AND b(n)) OR ( g AND (a(n) OR b(n)));   -- Cgenerate
          r(n) :=  a(n) XOR b(n) XOR carry;                     -- individual bit sums
         carry :=  g OR (p AND carry);                         -- carry
      END LOOP;
      borrow_out := NOT carry;
-- set overflow if carry_in and carry_out of sign bit are different.
         underflow := c_iminus XOR carry;
         result(reglen-1 DOWNTO 0) := r;
 
    -- that's all
       RETURN;
    END;
 
--+-----------------------------------------------------------------------------
--|     Function Name  : Sub_Unsigned
--|  hidden procedure
--|     Overloading    : None
--|
--|     Purpose        : Subtraction of BIT_VECTORS.
--|
--|     Parameters     :
--|                      result     - output BIT_VECTOR, the computed sum in two's
--|                                    complement form
--|                      borrow_out - output BIT,
--|                      underflow  - output BIT, underflow condition
--|                      minuend    - input  BIT_VECTOR,
--|                      subtrahend - input  BIT_VECTOR,
--|                      borrow_in  - input BIT,
--|
--|     Result         :  BiT_Vector in twos complement form. 
--|
--|     NOTE           :
--|                      The sunbraction of unsigned is same as 
--|                      their two's complement addition.
--|
--|                      The inputs may be of any length  but both addend and augend
--|                      must have same lengths.
--|                  
--|                       If the result of  subtraction cannot be accomodated, 
--|                       (e.g if minuend is integer 20 and subtrahend is 
--|                        integer 255 Then  (20 - 255) = -235 this cannot be 
--|                        accomodated in an 8 bit  register.
--|     Use            :
--|                      VARIABLE x, y, sum : BIT_VECTOR ( 15 DOWNTO 0);
--|                      VARIABLE borrow, ovf : BIT;
--|
--|                      Sub_Unsigned ( sum, borrow, ovf, x, y, '0' );
--| 
--|-----------------------------------------------------------------------------
    PROCEDURE Sub_Unsigned  ( VARIABLE result     : OUT BIT_VECTOR;
                              VARIABLE borrow_out : OUT BIT;
                              VARIABLE underflow  : OUT BIT;
                              CONSTANT minuend    : IN BIT_VECTOR;
                              CONSTANT subtrahend : IN BIT_VECTOR;
                              CONSTANT borrow_in  : IN BIT          := '0'
                            ) IS
      CONSTANT reglen : INTEGER :=  minuend'LENGTH;
      VARIABLE a      : BIT_VECTOR ( reglen - 1  DOWNTO 0 ) := minuend;
      VARIABLE b      : BIT_VECTOR ( subtrahend'LENGTH - 1  DOWNTO 0 ) := subtrahend;
      VARIABLE r      : BIT_VECTOR ( reglen - 1  DOWNTO 0 );
      VARIABLE p      : BIT := '1';
      VARIABLE g      : BIT := '0';
      VARIABLE carry  : BIT;
    BEGIN

 -- check the length of minuend and subtrahend
      ASSERT   (minuend'LENGTH = subtrahend'LENGTH)
      REPORT " Sub_Unsigned --- operand length not same "
      SEVERITY ERROR;
 
    -- In unsigned mode number is positive, two's comp of positive
    -- is same as unsigned number 
    -- The operation of (a - b - borrow_in) when a,b are Two's complement
    -- numbers can be computed
    --  as   a + (NOT b + 1) - borrow_in
    --  or   a + (NOT b) + (1-borrow_in)
    --  or   a + (NOT b) + (NOT borrow_in)
 
    -- perform the subtract
      carry := NOT borrow_in;
      FOR n IN 0 TO reglen - 1 LOOP
          b(n) := NOT b(n);
             p := p AND (a(n) OR b(n));                         -- Cpropagate
             g := (a(n) AND b(n)) OR ( g AND (a(n) OR b(n)));   -- Cgenerate
          r(n) :=  a(n) XOR b(n) XOR carry;                     -- individual bit sums
         carry :=  g OR (p AND carry);                         -- carry
      END LOOP;
      borrow_out := NOT carry;
-- set overflow if carry_in and carry_out of sign bit are different.
         underflow := NOT carry;
         result(reglen - 1 DOWNTO 0) := r;
     -- that's all
       RETURN;
    END; 

--+-----------------------------------------------------------------------------
--|     Function Name  : Sub_Unsigned
--|  hidden procedure
--|     Overloading    : None
--|
--|     Purpose        :Subtraction of logic vectors.
--|
--|     Parameters     :
--|                      result     - output std_logic_vector, the computed sum
--|                      borrow_out   - output std_logic,
--|                      underflow   - output std_logic, overflow condition
--|                      addend     - input  std_logic_vector,
--|                      augend     - input  std_logic_vector,
--|                      borrow_in   - input std_logic,
--|     NOTE           :
--|                      The inputs may be of any length  but both addend and augend
--|                      must have same lengths.
--|
--|     Use            :
--|                      VARIABLE x, y, sum : std_logic_vector ( 15 DOWNTO 0);
--|                      VARIABLE borrow, ovf : std_ulogic;
--|
--|                      Sub_Unsigned ( sum, borrow, ovf, x, y, '0' );
--|
--|   Reference        :
--|                      Computer Arithmetic Principles, Architecture, and Design
--|                            by    Kai Hwang
--|
--|-----------------------------------------------------------------------------
    PROCEDURE Sub_Unsigned  ( VARIABLE result     : OUT std_logic_vector;
                              VARIABLE borrow_out : OUT std_ulogic;
                              VARIABLE underflow  : OUT std_ulogic;
                              CONSTANT minuend    :  IN std_logic_vector;
                              CONSTANT subtrahend :  IN std_logic_vector;
                              CONSTANT borrow_in  :  IN std_ulogic         := '0'
                            ) IS
      CONSTANT reglen : INTEGER :=  minuend'LENGTH;
      VARIABLE a      : std_logic_vector ( reglen - 1  DOWNTO 0 ) := minuend;
      VARIABLE b      : std_logic_vector ( subtrahend'LENGTH - 1  DOWNTO 0 ) := subtrahend;
      VARIABLE r      : std_logic_vector ( reglen - 1  DOWNTO 0 );
      VARIABLE p      : std_ulogic:= '1';
      VARIABLE g      : std_ulogic:= '0';
      VARIABLE carry  : std_ulogic;
    BEGIN
-- check the length of minuend and subtrahend
      ASSERT   (minuend'LENGTH = subtrahend'LENGTH)
      REPORT " Sub_TwosComp --- operand length not same "
      SEVERITY ERROR;
 
 
    -- The operation of (a - b - borrow_in) when a,b are Two's complement
    -- numbers can be computed
    --  as   a + (NOT b + 1) - borrow_in
    --  or   a + (NOT b) + (1-borrow_in)
    --  or   a + (NOT b) + (NOT borrow_in)
 
    -- perform the subtract
      carry := NOT borrow_in;
      FOR n IN 0 TO reglen - 1 LOOP
          b(n) := NOT b(n);
             p := p AND (a(n) OR b(n));                         -- Cpropagate
             g := (a(n) AND b(n)) OR ( g AND (a(n) OR b(n)));   -- Cgenerate
          r(n) :=  a(n) XOR b(n) XOR carry;                     -- individual bit sums
         carry :=  g OR (p AND carry);                         -- carry
      END LOOP;
      borrow_out := NOT carry;
-- set overflow if carry_in and carry_out of sign bit are different.
         underflow := NOT carry;
         result(reglen-1 DOWNTO 0) := r;
 
    -- that's all
       RETURN;
    END;

--+-----------------------------------------------------------------------------
--|     Function Name  : Sub_Unsigned
--|  hidden procedure
--|     Overloading    : None
--|
--|     Purpose        :Subtraction of logic vectors.
--|
--|     Parameters     :
--|                      result     - output std_ulogic_vector, the computed sum
--|                      borrow_out   - output std_logic,
--|                      underflow   - output std_logic, overflow condition
--|                      addend     - input  std_ulogic_vector,
--|                      augend     - input  std_ulogic_vector,
--|                      borrow_in   - input std_logic,
--|     NOTE           :
--|                      The inputs may be of any length  but both addend and augend
--|                      must have same lengths.
--|
--|     Use            :
--|                      VARIABLE x, y, sum : std_ulogic_vector ( 15 DOWNTO 0);
--|                      VARIABLE borrow, ovf : std_ulogic;
--|
--|                      Sub_Unsigned ( sum, borrow, ovf, x, y, '0' );
--|
--|   Reference        :
--|                      Computer Arithmetic Principles, Architecture, and Design
--|                            by    Kai Hwang
--|
--|-----------------------------------------------------------------------------
    PROCEDURE Sub_Unsigned  ( VARIABLE result     : OUT std_ulogic_vector;
                              VARIABLE borrow_out : OUT std_ulogic;
                              VARIABLE underflow  : OUT std_ulogic;
                              CONSTANT minuend    :  IN std_ulogic_vector;
                              CONSTANT subtrahend :  IN std_ulogic_vector;
                              CONSTANT borrow_in  :  IN std_ulogic         := '0'
                            ) IS
      CONSTANT reglen : INTEGER :=  minuend'LENGTH;
      VARIABLE a      : std_ulogic_vector ( reglen - 1  DOWNTO 0 ) := minuend;
      VARIABLE b      : std_ulogic_vector ( subtrahend'LENGTH - 1  DOWNTO 0 ) := subtrahend;
      VARIABLE r      : std_ulogic_vector ( reglen - 1  DOWNTO 0 );
      VARIABLE p      : std_ulogic:= '1';
      VARIABLE g      : std_ulogic:= '0';
      VARIABLE carry  : std_ulogic;
    BEGIN
-- check the length of minuend and subtrahend
      ASSERT   (minuend'LENGTH = subtrahend'LENGTH)
      REPORT " Sub_TwosComp --- operand length not same "
      SEVERITY ERROR;
 
 
    -- The operation of (a - b - borrow_in) when a,b are Two's complement
    -- numbers can be computed
    --  as   a + (NOT b + 1) - borrow_in
    --  or   a + (NOT b) + (1-borrow_in)
    --  or   a + (NOT b) + (NOT borrow_in)
 
    -- perform the subtract
      carry := NOT borrow_in;
      FOR n IN 0 TO reglen - 1 LOOP
          b(n) := NOT b(n);
             p := p AND (a(n) OR b(n));                         -- Cpropagate
             g := (a(n) AND b(n)) OR ( g AND (a(n) OR b(n)));   -- Cgenerate
          r(n) :=  a(n) XOR b(n) XOR carry;                     -- individual bit sums
         carry :=  g OR (p AND carry);                         -- carry
      END LOOP;
      borrow_out := NOT carry;
  -- set overflow if carry_in and carry_out of sign bit are different.
         underflow := NOT carry;
         result(reglen-1 DOWNTO 0) := r;
 
    -- that's all
       RETURN;
    END;

--+-----------------------------------------------------------------------------
--|     Function Name  : RegSub
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
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode 
                      ) IS
      VARIABLE reslen       : INTEGER := MAXIMUM (minuend'LENGTH, subtrahend'LENGTH);
      VARIABLE a, b, r      : BIT_VECTOR ( reslen - 1 DOWNTO 0 );
      VARIABLE carry_o      : BIT;
      VARIABLE reslt_copy   : BIT_VECTOR ( result'length-1 downto 0 ) := result;
      VARIABLE reslen2      : INTEGER;

    BEGIN
     -- 
     --   Null range check
     --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegSub ---  Destination has null range. " &
                    " cannot save result. "
             SEVERITY ERROR;
             RETURN;

     --   if both minuend and subtrahend  have null range no need to subtract
       ELSIF  (minuend'LENGTH = 0) AND (subtrahend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegSub --- both minuend and subtrahend has null range "
             SEVERITY ERROR;
             reslt_copy :=  (OTHERS => '0');
             borrow_out := '0';
             IF (borrow_in /= '0') THEN
                 IF (SrcRegMode = TwosComp OR SrcRegMode = Unsigned) THEN
                        reslt_copy := (OTHERS =>'1');
                        borrow_out := '1';
                 END IF;
             END IF;
             result := reslt_copy;
             overflow := '0';
             RETURN;
       END IF;
 
     -- if one of the minuend or subtrahend is null
       IF (minuend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegSub --- minuend has null range "
             SEVERITY ERROR;
             a :=  ( OTHERS => '0');     -- treat it as zero's
             b :=  subtrahend ;
 
       ELSIF (subtrahend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegSub ---  subtrahend has null range "
             SEVERITY ERROR;
             b :=  (OTHERS => '0');
             a := minuend ;
  
                 -- inputs are  not null so sign extend them to the same length.
       ELSE
             a := SignExtend(minuend , reslen, minuend'LEFT, SrcRegMode);
             b := SignExtend(subtrahend , reslen, subtrahend'LEFT, SrcRegMode);
 
       END IF;

 
       CASE SrcRegMode IS
            WHEN TwosComp
                        =>
                           Sub_TwosComp(r,borrow_out, overflow,
                                                               a,b, borrow_in);
       
            WHEN OnesComp
                         =>
                           -- ignore borrow istead pass mode M as '1'
                            AddSub_OnesComp(r, carry_o,overflow,
                                                                  a,b, '1');
                            borrow_out := NOT carry_o;
       
            WHEN SignMagnitude
                          =>
                           -- ignore borrow_in istead pass mode M as '1'
                           AddSub_SignMagnitude(r, borrow_out, overflow,
                                                                         a,b, '1');
       
            WHEN Unsigned
                          =>
                           Sub_Unsigned(r, borrow_out,overflow,
                                                           a,b, borrow_in);
            WHEN OTHERS
                          =>
                           ASSERT FALSE
                           REPORT " RegSub ---- Unknown mode was passed "
                           SEVERITY ERROR;
      END CASE;

      IF (result'LENGTH < reslen) THEN
              ASSERT NOT WarningsOn  
              REPORT " RegSub --- Destination Length smaller than the " &
                       " calculated value. "
              SEVERITY WARNING;
       ELSIF ( result'LENGTH > reslen ) THEN
              ASSERT NOT WarningsOn  
              REPORT " RegSub --- Destination Length larger than the " &
                       " calculated value. "
              SEVERITY WARNING;
       END IF; 

       reslen2 := MINIMUM ( reslen, result'length );
       reslt_copy ( reslen2-1 downto 0 ) := r (reslen2-1 downto 0);
       result := reslt_copy;

     -- That's all
       RETURN;
    END;
 
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
                      ) IS
      VARIABLE reslen          : INTEGER := MAXIMUM (minuend'LENGTH, subtrahend'LENGTH);
      VARIABLE a, b, r         : std_logic_vector ( reslen - 1 DOWNTO 0 );    
      VARIABLE result_copy     : std_logic_vector ( result'length-1 downto 0 ) := result;
      VARIABLE borrow_out1     : std_ulogic;
      VARIABLE carry_o         : std_ulogic;
      VARIABLE overflow1       : std_ulogic;
      VARIABLE reslen2	       : INTEGER;
 
    BEGIN
     --
     --   Null range check
     --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegSub ---  Destination has null range. " &
                    " cannot save result. "
             SEVERITY ERROR;
             overflow := '1';
             borrow_out := '0';
             RETURN;
 
     --   if minuend or subtrahend or both have null range no need to subtract
       ELSIF  (minuend'LENGTH = 0) AND (subtrahend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegSub --- both minuend and subtrahend has null range "
             SEVERITY ERROR;
             result_copy :=  (OTHERS => '0');
             borrow_out := '0';
             IF (borrow_in /= '0') THEN
                 IF (SrcRegMode = TwosComp OR SrcRegMode = Unsigned) THEN
                        result_copy := (OTHERS =>'1');
                        borrow_out := '1';
                 END IF;
             END IF;
             result := result_copy;
             overflow := '0';
             RETURN;
       END IF;
 
     -- if one of the minuend or subtrahend is null
       IF (minuend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegSub --- minuend has null range "
             SEVERITY ERROR;
             a :=  ( OTHERS => '0');     -- treat it as zero's
             b := subtrahend ;
 
       ELSIF (subtrahend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegSub ---  subtrahend has null range "
             SEVERITY ERROR;
             b :=  (OTHERS => '0');
             a := minuend ;
 
                 -- inputs are  null so sign extend them to the same length.
       ELSE
             a := SignExtend(minuend , reslen, minuend 'LEFT, SrcRegMode);
             b := SignExtend(subtrahend , reslen, subtrahend 'LEFT, SrcRegMode);
 
       END IF;

 
       CASE SrcRegMode IS
            WHEN TwosComp
                        =>
                           Sub_TwosComp(r,borrow_out1, overflow1,
                                                               a,b, borrow_in);
       
            WHEN OnesComp
                         =>
                           -- ignore borrow istead pass mode M as '1'
                            AddSub_OnesComp(r, carry_o,overflow1,
                                                                  a,b, '1');
                            borrow_out1 := NOT carry_o;
       
            WHEN SignMagnitude
                          =>
                           -- ignore borrow_in istead pass mode M as '1'
                           AddSub_SignMagnitude(r, borrow_out1, overflow1,
                                                                         a,b, '1');
       
            WHEN Unsigned
                          =>
                           Sub_Unsigned(r, borrow_out1,overflow1,
                                                           a,b, borrow_in);
            WHEN OTHERS
                          =>
                           ASSERT FALSE
                           REPORT " RegSub ---- Unknown mode was passed "
                           SEVERITY ERROR;
      END CASE;

      IF (result'LENGTH < reslen) THEN
              ASSERT NOT WarningsOn  
              REPORT " RegSub --- Destination Length smaller than the " &
                       " calculated value. "
              SEVERITY WARNING;
       ELSIF ( result'LENGTH > reslen ) THEN
              ASSERT NOT WarningsOn  
              REPORT " RegSub --- Destination Length larger than the " &
                       " calculated value. "
              SEVERITY WARNING;
       END IF; 

       reslen2 := MINIMUM ( reslen, result'length );
       result_copy ( reslen2-1 downto 0 ) := To_X01(r (reslen2-1 downto 0 ));
       result := result_copy;
       borrow_out := To_X01(borrow_out1);
       overflow := To_X01(overflow1);
     
     -- That's all
       RETURN;
     END;

--+-----------------------------------------------------------------------------
--|     Function Name  : RegSub
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
                      ) IS
      VARIABLE reslen       : INTEGER := MAXIMUM (minuend'LENGTH, subtrahend'LENGTH);
      VARIABLE a, b, r      : std_ulogic_vector ( reslen - 1 DOWNTO 0 );    
      VARIABLE result_copy : std_ulogic_vector ( result'length-1 downto 0 ) := result;
      VARIABLE borrow_out1  : std_ulogic;
      VARIABLE carry_o      : std_ulogic;
      VARIABLE overflow1    : std_ulogic;
      VARIABLE reslen2      : INTEGER;
 
    BEGIN
     --
     --   Null range check
     --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegSub ---  Destination has null range. " &
                    " cannot save result. "
             SEVERITY ERROR;
             borrow_out := '0';
             overflow := '1';
             RETURN;
 
     --   if minuend or subtrahend or both have null range no need to subtract
       ELSIF  (minuend'LENGTH = 0) AND (subtrahend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegSub --- both minuend and subtrahend has null range "
             SEVERITY ERROR;
             result_copy :=  (OTHERS => '0');
             borrow_out := '0';
             IF (borrow_in /= '0') THEN
                 IF (SrcRegMode = TwosComp OR SrcRegMode = Unsigned) THEN
                        result_copy := (OTHERS =>'1');
                        borrow_out := '1';
                 END IF;
             END IF;
             result := result_copy;
             overflow := '0';
             RETURN;
       END IF;
 
     -- if one of the minuend or subtrahend is null
       IF (minuend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegSub --- minuend has null range "
             SEVERITY ERROR;
             a :=  ( OTHERS => '0');     -- treat it as zero's
             b := subtrahend;
 
       ELSIF (subtrahend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegSub ---  subtrahend has null range "
             SEVERITY ERROR;
             b :=  (OTHERS => '0');
             a := minuend;
 
                 -- inputs are  null so sign extend them to the same length.
       ELSE
             a := SignExtend(minuend, reslen, minuend'LEFT, SrcRegMode);
             b := SignExtend(subtrahend, reslen, subtrahend'LEFT, SrcRegMode);
 
       END IF;

 
       CASE SrcRegMode IS
            WHEN TwosComp
                        =>
                           Sub_TwosComp(r,borrow_out1, overflow1,
                                                               a,b, borrow_in);
       
            WHEN OnesComp
                         =>
                           -- ignore borrow istead pass mode M as '1'
                            AddSub_OnesComp(r, carry_o,overflow1,
                                                                  a,b, '1');
                            borrow_out1 := NOT carry_o;
       
            WHEN SignMagnitude
                          =>
                           -- ignore borrow_in istead pass mode M as '1'
                           AddSub_SignMagnitude(r, borrow_out1, overflow1,
                                                                         a,b, '1');
       
            WHEN Unsigned
                          =>
                           Sub_Unsigned(r, borrow_out1,overflow1,
                                                           a,b, borrow_in);
            WHEN OTHERS
                          =>
                           ASSERT FALSE
                           REPORT " RegSub ---- Unknown mode was passed "
                           SEVERITY ERROR;
      END CASE;

      IF (result'LENGTH < reslen) THEN
              ASSERT NOT WarningsOn  
              REPORT " RegSub --- Destination Length smaller than the " &
                       " calculated value. "
              SEVERITY WARNING;
       ELSIF ( result'LENGTH > reslen ) THEN
              ASSERT NOT WarningsOn  
              REPORT " RegSub --- Destination Length larger than the " &
                       " calculated value. "
              SEVERITY WARNING;
       END IF; 

       reslen2 := MINIMUM ( reslen, result'length );
       result_copy ( reslen2-1 downto 0 ) := To_X01(r (reslen2-1 downto 0 ));
       result := result_copy;
       borrow_out := To_X01(borrow_out1);
       overflow := To_X01(overflow1);
     
     -- That's all
       RETURN;
     END;

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
                      ) IS

      CONSTANT reslen      : INTEGER := multiplicand'LENGTH + multiplier'LENGTH;
      VARIABLE r           : BIT_VECTOR ( reslen - 1  DOWNTO 0 )       := (OTHERS=>'0');
      VARIABLE rega        : BIT_VECTOR ( multiplicand'LENGTH - 1 DOWNTO 0 ) := multiplicand;
      VARIABLE regb        : BIT_VECTOR ( multiplier'LENGTH -1  DOWNTO 0 )  := multiplier;
      VARIABLE carry       : BIT;
      VARIABLE nxt_c       : BIT;
      VARIABLE sign_bit    : BIT;
      VARIABLE overflo     : BIT := '0';  
      VARIABLE i           : INTEGER;
      VARIABLE reslt_copy : BIT_VECTOR ( result'length - 1 downto 0 );

     BEGIN 
     --  
     --   Null range check
     --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMult ---  Destination  to hold the product has null range. "
             SEVERITY ERROR;
             overflow := overflo;
             RETURN;
     --   if both multiplicand  and multiplier  have null range no need to multiply
       ELSIF (multiplicand'LENGTH = 0) AND (multiplier'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMult --- both multiplicand  and multiplier has null range "
             SEVERITY ERROR;
             reslt_copy :=  (OTHERS => '0');
             result := reslt_copy;                   -- result is filled with zeros
             overflow := overflo;       
             RETURN;      

     -- if one of the multiplicand  or multiplier is null 
       ELSIF (multiplicand'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMult --- multiplicand  has null range "
             SEVERITY ERROR;
                                 -- treat multiplicand as zero so result is zero 
             reslt_copy := (OTHERS => '0');
             result := reslt_copy;
             overflow := overflo;
             RETURN;
       ELSIF (multiplier'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMult --- multiplier  has null range "
             SEVERITY ERROR;
                                 -- treat multiplier as zero so result is zero 
             reslt_copy := (OTHERS => '0');
             result := reslt_copy;
             overflow := overflo;
             RETURN;
       END IF;
           
   -- 
   -- inputs are  not null so determine the sign and convert 
   -- the inputs to unsigned  representation.
      sign_bit := rega(rega'LEFT) XOR regb(regb'LEFT);    
      IF (rega(rega'LEFT) /= '0') THEN
          rega := To_Unsign (rega, SrcRegMode);     
      END IF;
      IF ( regb(regb'LEFT)  /= '0' ) THEN
          regb := To_Unsign (regb, SrcRegMode);      
      END IF;
 
    --
    -- perform the multiply using shift and add.
    -- for each bit of the multiplier
    --
      FOR k IN 0 TO multiplier'LENGTH - 1 LOOP
        -- if the multiplier bit is '1' then add the shifted multiplicand
        IF (regb(k) = '1') THEN
          i := k;                -- 'i' is LSB position in result for this add
          carry := '0';
          FOR n IN 0 TO multiplicand'LENGTH - 1 LOOP
            nxt_c := (rega(n) AND r(i)) OR ( carry AND (rega(n) OR r(i))); -- carry compute
             r(i) :=  rega(n) XOR r(i) XOR carry;                       -- bit sum
            carry := nxt_c;
                i := i + 1;
          END LOOP;
          r(i) := carry;            -- carry out is added to result
        END IF;
     END LOOP;
 
  -- if the result should be negative, then negate
  --
    IF ((sign_bit /='0')  AND  (SrcRegMode /= Unsigned)) THEN
              r := RegNegate (r, SrcRegMode);         
    END IF;

  --
  -- Determine the length of the result to be returned
  --
    IF (result'LENGTH < reslen)   THEN
        case SrcRegMode is 
          WHEN TwosComp =>
                reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
                IF (sign_bit = '0') THEN     -- positive result
                      FOR j IN result'LENGTH  - 1 TO reslen - 2 LOOP
                         if (r(j) = '1') THEN
                           overflo := '1';
                         END IF;
                         EXIT WHEN (r(j) = '1');
                      END LOOP;
                                              
                ELSE                          -- negative result  -128 is valid
                       FOR j IN result'LENGTH  TO reslen - 2 LOOP
                          if (r(j) = '0') THEN
                             overflo := '1';
                          END IF;
                         EXIT WHEN (r(j) = '0');
                       END LOOP;
                END IF;
                                         
          WHEN OnesComp =>
                reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
                IF (sign_bit = '0') THEN     -- positive result
                      FOR j IN result'LENGTH - 1 TO reslen - 2 LOOP
                         if (r(j) = '1') THEN
                           overflo := '1';
                         END IF;
                         EXIT WHEN (r(j) = '1');
                      END LOOP;
                                              
                ELSE                          -- negative result
                       FOR j IN result'LENGTH - 1 TO reslen - 2 LOOP
                          if (r(j) = '0') THEN
                             overflo := '1';
                          END IF;
                         EXIT WHEN (r(j) = '0');
                       END LOOP;
                END IF;

          WHEN Unsigned =>
               reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
               FOR j IN result'LENGTH  TO reslen - 1 LOOP
                   if (r(j) /= '0') THEN
                        overflo := '1';
                   END IF;
                   EXIT WHEN (r(j) /= '0');
               END LOOP;
    
          WHEN SignMagnitude  =>
               reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
               reslt_copy(result'LENGTH - 1) := r(reslen - 1);  -- sign bit
               FOR j IN result'LENGTH - 1 TO reslen - 2 LOOP
                   if (r(j) /= '0') THEN
                        overflo := '1';
                   END IF;
                   EXIT WHEN (r(j) /= '0');
               END LOOP;

          WHEN OTHERS =>
                      null;
        END CASE;
    ELSIF (result'LENGTH > reslen) THEN                -- sign extend the product
       reslt_copy := SignExtend(r, result'LENGTH, r'LEFT, SrcRegMode);
    ELSE
       reslt_copy := r;                              -- equal length
    END IF;
    result := reslt_copy;
    overflow := overflo;

    -- that's all
    RETURN;
    END;

--+-----------------------------------------------------------------------------
--|     Function Name  : RegMult
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
                      ) IS

      CONSTANT reslen      : INTEGER := multiplicand'LENGTH + multiplier'LENGTH;
      VARIABLE r           : std_logic_vector(reslen - 1  DOWNTO 0)   := (OTHERS=>'0');
      VARIABLE rega        : std_logic_vector(multiplicand'LENGTH - 1 DOWNTO 0) := multiplicand;
      VARIABLE regb        : std_logic_vector(multiplier'LENGTH - 1 DOWNTO 0) := multiplier;
      VARIABLE carry       : std_ulogic;
      VARIABLE nxt_c       : std_ulogic;
      VARIABLE sign_bit    : std_ulogic;
      VARIABLE overflo1    : std_ulogic := '0';
      VARIABLE i           : INTEGER;
      VARIABLE reslt_copy : std_logic_vector ( result'length - 1 downto 0 );

     BEGIN 
     --  
     --   Null range check
     --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMult ---  Destination  to hold the product has null range. "
             SEVERITY ERROR;
             overflow := overflo1;
             RETURN;
     --   if both multiplicand  and multiplier  have null range no need to multiply
       ELSIF (multiplicand'LENGTH = 0) AND (multiplier'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMult --- both multiplicand  and multiplier has null range "
             SEVERITY ERROR;
             reslt_copy :=  (OTHERS => '0');
             result := reslt_copy;                   -- result is filled with zeros
             overflow := overflo1;       
             RETURN;      

     -- if one of the multiplicand  or multiplier is null 
       ELSIF (multiplicand'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMult --- multiplicand  has null range "
             SEVERITY ERROR;
                                 -- treat multiplicand as zero so result is zero 
             reslt_copy := (OTHERS => '0');
             result := reslt_copy;
             overflow := overflo1;
             RETURN;
       ELSIF (multiplier'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMult --- multiplier  has null range "
             SEVERITY ERROR;
                                 -- treat multiplier as zero so result is zero 
             reslt_copy := (OTHERS => '0');
             result := reslt_copy;
             overflow := overflo1;
             RETURN;
       END IF;
           
   -- 
   -- inputs are  not null so determine the sign and convert 
   -- the inputs to unsigned  representation.
      sign_bit := rega(rega'LEFT) XOR regb(regb'LEFT);    
      IF (rega(rega'LEFT) /= '0') THEN
          rega := To_Unsign (rega, SrcRegMode);     
      END IF;
      IF ( regb(regb'LEFT)  /= '0' ) THEN
          regb := To_Unsign (regb, SrcRegMode);      
      END IF;
 
    --
    -- perform the multiply using shift and add.
    -- for each bit of the multiplier
    --
      FOR k IN 0 TO multiplier'LENGTH - 1 LOOP
        -- if the multiplier bit is '1' then add the shifted multiplicand
        IF (regb(k) = '1') THEN
          i := k;                -- 'i' is LSB position in result for this add
          carry := '0';
          FOR n IN 0 TO multiplicand'LENGTH - 1 LOOP
            nxt_c := (rega(n) AND r(i)) OR ( carry AND (rega(n) OR r(i))); -- carry compute
             r(i) :=  rega(n) XOR r(i) XOR carry;                       -- bit sum
            carry := nxt_c;
                i := i + 1;
          END LOOP;
          r(i) := carry;            -- carry out is added to result
        END IF;
     END LOOP;
 
  -- if the result should be negative, then negate
  --
    IF ((sign_bit /='0')  AND  (SrcRegMode /= Unsigned)) THEN
              r := RegNegate (r, SrcRegMode);         
    END IF;

  --
  -- Determine the length of the result to be returned
  --
    IF (result'LENGTH < reslen)   THEN
        case SrcRegMode is 
          WHEN TwosComp =>
                reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
                IF (sign_bit = '0') THEN     -- positive result
                      FOR j IN result'LENGTH  - 1 TO reslen - 2 LOOP
                         if (r(j) /= '0'  ) THEN
                           overflo1 := '1';
                         END IF;
                         EXIT WHEN (r(j) /= '0');
                      END LOOP;
                                              
                ELSE                          -- negative result  -128 is valid
                       FOR j IN result'LENGTH  TO reslen - 2 LOOP
                          if (r(j) = '0') THEN
                             overflo1 := '1';
                          END IF;
                         EXIT WHEN (r(j) = '0');
                       END LOOP;
                END IF;
                                         
          WHEN OnesComp =>
                reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
                IF (sign_bit = '0') THEN     -- positive result
                      FOR j IN result'LENGTH  - 1 TO reslen - 2 LOOP
                         if (r(j) /= '0') THEN
                           overflo1 := '1';
                         END IF;
                         EXIT WHEN (r(j) /= '0');
                      END LOOP;
                                              
                ELSE                          -- negative result
                       FOR j IN result'LENGTH - 1 TO reslen - 2 LOOP
                          if (r(j) = '0') THEN
                             overflo1 := '1';
                          END IF;
                         EXIT WHEN (r(j) = '0');
                       END LOOP;
                END IF;

          WHEN Unsigned =>
               reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
               FOR j IN result'LENGTH TO reslen - 1 LOOP
                   if (r(j) /= '0') THEN
                        overflo1 := '1';
                   END IF;
                   EXIT WHEN (r(j) /= '0');
               END LOOP;
    
          WHEN SignMagnitude  =>
               reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
               reslt_copy(result'LENGTH - 1) := r(reslen - 1);  -- sign bit
               FOR j IN result'LENGTH - 1 TO reslen - 2 LOOP
                   if (r(j) /= '0') THEN
                        overflo1 := '1';
                   END IF;
                   EXIT WHEN (r(j) /= '0');
               END LOOP;

          WHEN OTHERS =>
                      null;
        END CASE;
    ELSIF (result'LENGTH > reslen) THEN                -- sign extend the product
       reslt_copy := SignExtend(r, result'LENGTH, r'LEFT, SrcRegMode);
    ELSE
       reslt_copy := r;                              -- equal length
    END IF;
    result := reslt_copy;
    overflow := overflo1;

    -- that's all
    RETURN;
    END;

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
                      ) IS

      CONSTANT reslen      : INTEGER := multiplicand'LENGTH + multiplier'LENGTH;
      VARIABLE r           : std_ulogic_vector ( reslen - 1  DOWNTO 0 )  := (OTHERS=>'0');
      VARIABLE rega        : std_ulogic_vector(multiplicand'LENGTH - 1 DOWNTO 0) := multiplicand;
      VARIABLE regb        : std_ulogic_vector(multiplier'LENGTH - 1  DOWNTO 0) := multiplier;
      VARIABLE carry       : std_ulogic;
      VARIABLE nxt_c       : std_ulogic;
      VARIABLE sign_bit    : std_ulogic;
      VARIABLE overflo2    : std_ulogic := '0';
      VARIABLE i           : INTEGER;
      VARIABLE reslt_copy : std_ulogic_vector ( result'length - 1 downto 0 );

     BEGIN 


     --  
     --   Null range check
     --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMult ---  Destination  to hold the product has null range. "
             SEVERITY ERROR;
             overflow := overflo2;
             RETURN;
     --   if both multiplicand  and multiplier  have null range no need to multiply
       ELSIF (multiplicand'LENGTH = 0) AND (multiplier'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMult --- both multiplicand  and multiplier has null range "
             SEVERITY ERROR;
             reslt_copy :=  (OTHERS => '0');
             result := reslt_copy;                   -- result is filled with zeros
             overflow := overflo2;       
             RETURN;      

     -- if one of the multiplicand  or multiplier is null 
       ELSIF (multiplicand'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMult --- multiplicand  has null range "
             SEVERITY ERROR;
                                 -- treat multiplicand as zero so result is zero 
             reslt_copy := (OTHERS => '0');
             result := reslt_copy;
             overflow := overflo2;
             RETURN;
       ELSIF (multiplier'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMult --- multiplier  has null range "
             SEVERITY ERROR;
                                 -- treat multiplier as zero so result is zero 
             reslt_copy := (OTHERS => '0');
             result := reslt_copy;
             overflow := overflo2;
             RETURN;
       END IF;
           
   -- 
   -- inputs are  not null so determine the sign and convert 
   -- the inputs to unsigned  representation.
      sign_bit := rega(rega'LEFT) XOR regb(regb'LEFT);    
      IF (rega(rega'LEFT) /= '0') THEN
          rega := To_Unsign (rega, SrcRegMode);     
      END IF;
      IF ( regb(regb'LEFT)  /= '0' ) THEN
          regb := To_Unsign (regb, SrcRegMode);      
      END IF;
 
    --
    -- perform the multiply using shift and add.
    -- for each bit of the multiplier
    --
      FOR k IN 0 TO multiplier'LENGTH - 1 LOOP
        -- if the multiplier bit is '1' then add the shifted multiplicand
        IF (regb(k) = '1') THEN
          i := k;                -- 'i' is LSB position in result for this add
          carry := '0';
          FOR n IN 0 TO multiplicand'LENGTH - 1 LOOP
            nxt_c := (rega(n) AND r(i)) OR ( carry AND (rega(n) OR r(i))); -- carry compute
             r(i) :=  rega(n) XOR r(i) XOR carry;                       -- bit sum
            carry := nxt_c;
                i := i + 1;
          END LOOP;
          r(i) := carry;            -- carry out is added to result
        END IF;
     END LOOP;
 
  -- if the result should be negative, then negate
  --
    IF ((sign_bit /='0')  AND  (SrcRegMode /= Unsigned)) THEN
              r := RegNegate (r, SrcRegMode);         
    END IF;

  --
  -- Determine the length of the result to be returned
  --
    IF (result'LENGTH < reslen)   THEN
        case SrcRegMode is 
          WHEN TwosComp =>
                reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
                IF (sign_bit = '0') THEN     -- positive result
                      FOR j IN result'LENGTH  - 1 TO reslen - 2 LOOP
                         if (r(j) /= '0'  ) THEN
                           overflo2 := '1';
                         END IF;
                         EXIT WHEN (r(j) /= '0');
                      END LOOP;
                                              
                ELSE                          -- negative result  -128 is valid
                       FOR j IN result'LENGTH  TO reslen - 2 LOOP
                          if (r(j) = '0') THEN
                             overflo2 := '1';
                          END IF;
                         EXIT WHEN (r(j) = '0');
                       END LOOP;
                END IF;
                                         
          WHEN OnesComp =>
                reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
                IF (sign_bit = '0') THEN     -- positive result
                      FOR j IN result'LENGTH  - 1 TO reslen - 2 LOOP
                         if (r(j) /= '0') THEN
                           overflo2 := '1';
                         END IF;
                         EXIT WHEN (r(j) /= '0');
                      END LOOP;
                                              
                ELSE                          -- negative result
                       FOR j IN result'LENGTH - 1 TO reslen - 2 LOOP
                          if (r(j) = '0') THEN
                             overflo2 := '1';
                          END IF;
                         EXIT WHEN (r(j) = '0');
                       END LOOP;
                END IF;

          WHEN Unsigned =>
               reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
               FOR j IN result'LENGTH TO reslen - 1 LOOP
                   if (r(j) /= '0') THEN
                        overflo2 := '1';
                   END IF;
                   EXIT WHEN (r(j) /= '0');
               END LOOP;
    
          WHEN SignMagnitude  =>
               reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
               reslt_copy(result'LENGTH - 1) := r(reslen - 1);  -- sign bit
               FOR j IN result'LENGTH - 1 TO reslen - 2 LOOP
                   if (r(j) /= '0') THEN
                        overflo2 := '1';
                   END IF;
                   EXIT WHEN (r(j) /= '0');
               END LOOP;

          WHEN OTHERS =>
                      null;
        END CASE;
    ELSIF (result'LENGTH > reslen) THEN                -- sign extend the product
       reslt_copy := SignExtend(r, result'LENGTH, r'LEFT, SrcRegMode);
    ELSE
       reslt_copy := r;                              -- equal length
    END IF;
    result := reslt_copy;
    overflow := overflo2;

    -- that's all
    RETURN;
    END;

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
                      ) IS
      CONSTANT nd            : INTEGER := dividend'LENGTH;    
      CONSTANT len           : INTEGER := 2 * nd;
      VARIABLE res_copy      : BIT_VECTOR(result'LENGTH - 1 DOWNTO 0);
      VARIABLE rem_copy      : BIT_VECTOR(remainder'LENGTH - 1 DOWNTO 0);
      VARIABLE dividend_copy : BIT_VECTOR(dividend'LENGTH - 1 DOWNTO 0) := dividend;
      VARIABLE divisor_copy  : BIT_VECTOR(divisor'LENGTH - 1 DOWNTO 0) := divisor;
      VARIABLE regr          : BIT_VECTOR(len  DOWNTO 0) := (OTHERS => '0');
      VARIABLE rega          : BIT_VECTOR(len  DOWNTO 0) := (OTHERS => '0');
      VARIABLE regd          : BIT_VECTOR(len  DOWNTO 0) := (OTHERS => '0');
      VARIABLE regb          : BIT_VECTOR(nd - 1  DOWNTO 0);   -- quotient
      VARIABLE neg_res       : Boolean := FALSE;              -- sign of result
      VARIABLE neg_rem       : BOOLEAN := FALSE;              -- sign of remainder
      VARIABLE b_out         : BIT;
      VARIABLE uvflo         : BIT;
      VARIABLE shiftout      : BIT;

     BEGIN
     --   Null range check
     --   if result vector or remainder vector has a null range
       IF (( result'LENGTH = 0) OR (remainder'LENGTH = 0)) THEN
             ASSERT false
             REPORT " RegDiv  ---  Destination   has null range. "
             SEVERITY ERROR;
             RETURN;
     --   if both dividend  divisor  have null range no need to divide
       ELSIF (dividend'LENGTH = 0) AND (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegDiv --- both dividend  and divisor has null range "
             SEVERITY ERROR;
             res_copy :=  (OTHERS => '0');
             result := res_copy;                   -- result is filled with zeros
             rem_copy :=  (OTHERS => '0');
             remainder := rem_copy;                -- remainder is filled with zeros
             RETURN;      
     -- if one of the dividend  or divisor is null 
       ELSIF (dividend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegDiv ---  dividend  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             res_copy := (OTHERS => '0');
             result := res_copy;
             rem_copy :=  (OTHERS => '0');
             remainder := rem_copy;                -- remainder is filled with zeros
             RETURN;
       ELSIF (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegDiv --- divisor  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             res_copy := (OTHERS => '0');
             result := res_copy;
             rem_copy :=  (OTHERS => '0');
             remainder := rem_copy;                -- remainder is filled with zeros
             RETURN;
       END IF;

    -- check for divide by zero
      IF (is_zero(divisor_copy, SrcRegMode) )  THEN     -- applying the equality operator
          ASSERT false
          REPORT " RegDiv  ---  divide by zero  "
          SEVERITY ERROR;
          res_copy := (OTHERS => '0');
          result := res_copy;
             rem_copy :=  (OTHERS => '0');
             remainder := rem_copy;                -- remainder is filled with zeros
	     ZeroDivide := '1';	
          RETURN;
      END IF;

    -- put dividend to rega  and divisor to regd
      rega(dividend'LENGTH - 1 DOWNTO 0) := dividend_copy;          
      regd(divisor'LENGTH - 1 DOWNTO 0) := divisor_copy;  
   -- inputs are  not null so determine the sign and convert 
   -- the inputs to unsigned  representation.
     IF (SrcRegMode /= Unsigned) THEN
        IF (dividend_copy(dividend_copy'LEFT) /= '0') THEN
           neg_res := NOT neg_res;
           neg_rem := NOT neg_rem;          -- sign of dividend is sign of remainder
           rega(dividend'LENGTH - 1 DOWNTO 0) := To_Unsign (dividend_copy, SrcRegMode);     
        END IF;

        IF (divisor_copy(divisor_copy'LEFT) /= '0') THEN
           neg_res := NOT neg_res;
           regd(divisor'LENGTH - 1 DOWNTO 0) := To_Unsign(divisor_copy, SrcRegMode);  
        END IF;
     END IF;


   -- Perform division by binary restoring algorithm
   --    initialize 
   -- load rega to regr, 
   -- regd  gets regd shifted left by nd bits
   -- regb  gets all zerso
   -- 
       regr := rega;                
            -- left shift regd by nd ( length of divisor) bits, fill with zero's
       RegShift(regd, regd, shiftout, '1', '0', nd);
       regb := (OTHERS =>'0');

       For i IN 0 TO nd - 1 LOOP
                                                -- regr := 2*regr - regd
           RegShift(regr, regr, shiftout, '1', '0', 1);
           RegSub ( regr, b_out, uvflo,  regr,  regd, '0', TwosComp);                 
           IF (regr(regr'LEFT) /= '0')   THEN
                                               -- regr := regr + regd
                RegAdd(regr, b_out, uvflo, regr, regd, '0', TwosComp);
                RegShift(regb, regb, shiftout, '1', '0', 1);
           ELSE
                                                -- regb := 2*regb + 1;
                RegShift(regb, regb, shiftout, '1', '0', 1);
                regb := RegInc(regb, Unsigned);
           END IF;
      END LOOP;

      -- if the result and remainder should be negative 
        IF (neg_res AND (SrcRegMode /= Unsigned)) THEN
              regb := RegNegate(regb, SrcRegMode);
        END IF;

        IF (neg_rem AND (SrcRegMode /= Unsigned)) THEN
              regr := RegNegate(regr, SrcRegMode);
        END IF;

      -- determine the length of result
        IF (result'LENGTH <= dividend'LENGTH) THEN
           res_copy := regb(result'LENGTH - 1 DOWNTO 0);
           ASSERT (result'LENGTH = dividend'LENGTH) OR (NOT WarningsOn)
           REPORT " RegDiv --- length of result vector is shorter than dividend "
           SEVERITY WARNING;
        ELSE
                                                -- sign extend the quotient
           res_copy := SignExtend(regb, result'LENGTH, regb'LEFT, SrcRegMode);
        END IF;
                -- remainder is in most significant N bits, shift right N bits 
         RegShift(regr, regr, shiftout, '0', regr(len), nd);
      -- remainder length
        IF ( remainder'LENGTH <= len ) THEN 
            rem_copy := regr(remainder'LENGTH - 1 DOWNTO 0);
            IF (SrcRegMode /= Unsigned) THEN
               rem_copy(result'LENGTH - 1) := regr(result'LENGTH);  -- sign bit
            END IF;
        ELSE
            rem_copy := SignExtend(regr, remainder'LENGTH, regr'LEFT, SrcRegMode);
        END IF;

        result := res_copy;
        remainder := rem_copy;
        ZeroDivide := '0';	
    -- That's all
      RETURN;
    END;

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
    --                                   set to '1'  when divide by zero occureed
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
                      ) IS

      CONSTANT nd1        : INTEGER := dividend'LENGTH;    
      CONSTANT len       : INTEGER := 2 * nd1;
      VARIABLE res_copy : std_logic_vector(result'LENGTH - 1 DOWNTO 0);
      VARIABLE rem_copy : std_logic_vector(remainder'LENGTH - 1 DOWNTO 0);
      VARIABLE dividnd_copy : std_logic_vector(dividend'LENGTH - 1 DOWNTO 0) := dividend;
      VARIABLE divisr_copy  : std_logic_vector(divisor'LENGTH - 1 DOWNTO 0) := divisor;
      VARIABLE regr          : std_logic_vector(len  DOWNTO 0) := (OTHERS => '0');
      VARIABLE rega          : std_logic_vector(len  DOWNTO 0) := (OTHERS => '0');
      VARIABLE regd          : std_logic_vector(len  DOWNTO 0) := (OTHERS => '0');
      VARIABLE regb          : std_logic_vector(nd1 - 1 DOWNTO 0);   -- quotient
      VARIABLE neg_res       : Boolean := FALSE;              -- sign of result
      VARIABLE neg_rem       : BOOLEAN := FALSE;              -- sign of remainder
      VARIABLE b_out         : std_ulogic;
      VARIABLE uvflo1        : std_ulogic;
      VARIABLE shiftout      : std_ulogic;

     BEGIN 
     --   Null range check
     --   if result vector or remainder vector has a null range
       IF (( result'LENGTH = 0) OR (remainder'LENGTH = 0)) THEN
             ASSERT false
             REPORT " RegDiv  ---  Destination   has null range. "
             SEVERITY ERROR;
             RETURN;
     --   if both dividend  divisor  have null range no need to divide
       ELSIF (dividend'LENGTH = 0) AND (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegDiv --- both dividend  and divisor has null range "
             SEVERITY ERROR;
             res_copy :=  (OTHERS => '0');
             result := res_copy;                   -- result is filled with zeros
             rem_copy :=  (OTHERS => '0');
             remainder := rem_copy;                -- remainder is filled with zeros
             RETURN;      

     -- if one of the dividend  or divisor is null 
       ELSIF (dividend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegDiv ---  dividend  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             res_copy := (OTHERS => '0');
             result := res_copy;
             rem_copy :=  (OTHERS => '0');
             remainder := rem_copy;                -- remainder is filled with zeros
             RETURN;
       ELSIF (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegDiv --- divisor  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             res_copy := (OTHERS => '0');
             result := res_copy;
             rem_copy :=  (OTHERS => '0');
             remainder := rem_copy;                -- remainder is filled with zeros
             RETURN;
       END IF;
           
    -- check for divide by zero
      IF ( is_zero(divisr_copy, SrcRegMode) )  THEN     -- applying the equality operator
          ASSERT false
          REPORT " RegDiv  ---  divide by zero  "
          SEVERITY ERROR;
          res_copy := (OTHERS => '0');
          result := res_copy;
             rem_copy :=  (OTHERS => '0');
             remainder := rem_copy;                -- remainder is filled with zeros
	     ZeroDivide := '1';	
          RETURN;
      END IF;  

    -- put dividend to rega  and divisor to regd
      rega(dividend'LENGTH - 1 DOWNTO 0) := dividnd_copy;          
      regd(divisor'LENGTH - 1 DOWNTO 0) := divisr_copy;  

   -- inputs are  not null so determine the sign and convert 
   -- the inputs to unsigned  representation.
     IF (SrcRegMode /= Unsigned) THEN
        IF (dividnd_copy(dividnd_copy'LEFT) /= '0') THEN
           neg_res := NOT neg_res;
           neg_rem := NOT neg_rem;          -- sign of dividend is sign of remainder
           rega(dividend'LENGTH - 1 DOWNTO 0) := To_Unsign (dividnd_copy, SrcRegMode);     
        END IF;

        IF (divisr_copy(divisr_copy'LEFT) /= '0') THEN
           neg_res := NOT neg_res;
           regd(divisor'LENGTH - 1 DOWNTO 0) := To_Unsign(divisr_copy, SrcRegMode);  
        END IF;
     END IF;
 
   -- Perform division by binary restoring algorithm
   --    initialize 
   -- load rega to regr, 
   -- regd  gets regd shifted left by nd1 bits
   -- regb  gets all zerso
   -- 
       regr := rega;                
            -- left shift regd by nd ( length of divisor) bits, fill with zero's
       RegShift(regd, regd, shiftout, '1', '0', nd1);
       regb := (OTHERS =>'0');

       For i IN 0 TO nd1 - 1 LOOP
                                                -- regr := 2*regr - regd
           RegShift(regr, regr, shiftout, '1', '0', 1);
           RegSub (regr, b_out,  uvflo1,  regr, regd, '0', TwosComp );     
                                               -- if regr is negative, then restore
           IF (regr(regr'LEFT) /= '0')   THEN
                                               -- regr := regr + regd
                                               -- regb := 2*regb 
                RegAdd(regr, b_out, uvflo1, regr, regd, '0', TwosComp);
                RegShift(regb, regb, shiftout, '1', '0', 1);
           ELSE
                                                -- regb := 2*regb + 1;
                RegShift(regb, regb, shiftout, '1', '0', 1);
                regb := RegInc (regb, Unsigned );
           END IF;

      END LOOP;
     
      -- if the result and remainder should be negative 
        IF (neg_res AND (SrcRegMode /= Unsigned)) THEN
              regb := RegNegate(regb, SrcRegMode);
        END IF;

        IF (neg_rem AND (SrcRegMode /= Unsigned)) THEN
              regr := RegNegate(regr, SrcRegMode);
        END IF;

      -- determine the length of result
        IF (result'LENGTH <= dividend'LENGTH) THEN
           res_copy := regb(result'LENGTH - 1 DOWNTO 0);
            ASSERT (result'LENGTH = dividend'LENGTH) OR (NOT WarningsOn)
            REPORT " RegDiv --- length of result  is shorter than dividend "
            SEVERITY WARNING;
        ELSE
                                                -- sign extend the quotient
           res_copy := SignExtend(regb, result'LENGTH, regb'LEFT, SrcRegMode);
        END IF;
                -- remainder is in most significant N bits, shift right N bits 
         RegShift(regr, regr, shiftout, '0', regr(len), nd1);          
      -- remainder length
        IF ( remainder'LENGTH <= len ) THEN
            rem_copy := regr(remainder'LENGTH - 1 DOWNTO 0);
            IF (SrcRegMode /= Unsigned) THEN
               rem_copy(result'LENGTH - 1) := regr(result'LENGTH);  -- sign bit
            END IF;							
        ELSE
            rem_copy := SignExtend(regr, remainder'LENGTH, regr'LEFT, SrcRegMode);
        END IF;
        
        result    := To_X01(res_copy);
        remainder := To_X01(rem_copy);
        ZeroDivide := '0';	
    -- That's all
      RETURN;
    END;
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
                      ) IS

      CONSTANT nd2        : INTEGER := dividend'LENGTH;    
      CONSTANT len       : INTEGER := 2 * nd2;
      VARIABLE res_copy : std_ulogic_vector(result'LENGTH - 1 DOWNTO 0);
      VARIABLE rem_copy : std_ulogic_vector(remainder'LENGTH - 1 DOWNTO 0);
      VARIABLE dividend_copy : std_ulogic_vector(dividend'LENGTH - 1 DOWNTO 0) := dividend;
      VARIABLE divisor_copy  : std_ulogic_vector(divisor'LENGTH - 1 DOWNTO 0) := divisor;
      VARIABLE regr      : std_ulogic_vector(len  DOWNTO 0) := (OTHERS => '0');
      VARIABLE rega      : std_ulogic_vector(len DOWNTO 0) := (OTHERS => '0');
      VARIABLE regd      : std_ulogic_vector(len DOWNTO 0) := (OTHERS => '0');
      VARIABLE regb      : std_ulogic_vector(nd2- 1 DOWNTO 0);   -- quotient
      VARIABLE neg_res   : Boolean := FALSE;              -- sign of result
      VARIABLE neg_rem   : BOOLEAN := FALSE;              -- sign of remainder
      VARIABLE b_out     : std_ulogic;
      VARIABLE uvflo2    : std_ulogic;
      VARIABLE shiftout  : std_ulogic;

     BEGIN 
     --   Null range check
     --   if result vector or remainder vector has a null range
       IF (( result'LENGTH = 0) OR (remainder'LENGTH = 0)) THEN
             ASSERT false
             REPORT " RegDiv  ---  Destination   has null range. "
             SEVERITY ERROR;
             RETURN;
     --   if both dividend  divisor  have null range no need to divide
       ELSIF (dividend'LENGTH = 0) AND (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegDiv --- both dividend  and divisor has null range "
             SEVERITY ERROR;
             res_copy :=  (OTHERS => '0');
             result := res_copy;                   -- result is filled with zeros
             rem_copy :=  (OTHERS => '0');
             remainder := rem_copy;                -- remainder is filled with zeros
             RETURN;      

     -- if one of the dividend  or divisor is null 
       ELSIF (dividend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegDiv ---  dividend  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             res_copy := (OTHERS => '0');
             result := res_copy;
             rem_copy :=  (OTHERS => '0');
             remainder := rem_copy;                -- remainder is filled with zeros
             RETURN;
       ELSIF (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegDiv --- divisor  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             res_copy := (OTHERS => '0');
             result := res_copy;
             rem_copy :=  (OTHERS => '0');
             remainder := rem_copy;                -- remainder is filled with zeros
             RETURN;
       END IF;
           
    -- check for divide by zero
      IF ( is_zero(divisor_copy, SrcRegMode) )  THEN     -- applying the equality operator
          ASSERT false
          REPORT " RegDiv  ---  divide by zero  "
          SEVERITY ERROR;
          res_copy := (OTHERS => '0');
          result := res_copy;
             rem_copy :=  (OTHERS => '0');
             remainder := rem_copy;                -- remainder is filled with zeros
	     ZeroDivide := '1';	
          RETURN;
      END IF;  

    -- put dividend to rega  and divisor to regd
      rega(dividend'LENGTH - 1 DOWNTO 0) := dividend_copy;          
      regd(divisor'LENGTH - 1 DOWNTO 0) := divisor_copy;  

   -- inputs are  not null so determine the sign and convert 
   -- the inputs to unsigned  representation.
     IF (SrcRegMode /= Unsigned) THEN
        IF (dividend_copy(dividend_copy'LEFT) /= '0') THEN
           neg_res := NOT neg_res;
           neg_rem := NOT neg_rem;          -- sign of dividend is sign of remainder
           rega(dividend'LENGTH - 1 DOWNTO 0) := To_Unsign (dividend_copy, SrcRegMode);     
        END IF;

        IF (divisor_copy(divisor_copy'LEFT) /= '0') THEN
           neg_res := NOT neg_res;
           regd(divisor'LENGTH - 1 DOWNTO 0) := To_Unsign(divisor_copy, SrcRegMode);  
        END IF;
     END IF;
 
   -- Perform division by binary restoring algorithm
   --    initialize 
   -- load rega to regr, 
   -- regd  gets regd shifted left by nd2bits
   -- regb  gets all zerso
   -- 
       regr := rega;                
            -- left shift regd by nd2 ( length of dividend bits, fill with zero's
       RegShift(regd, regd, shiftout, '1', '0', nd2);
       regb := (OTHERS =>'0');

       For i IN 0 TO nd2 - 1 LOOP
                                                -- regr := 2*regr - regd
           RegShift(regr, regr, shiftout, '1', '0', 1);
           RegSub ( result     => regr, 
                    borrow_out => b_out, 
                    overflow   => uvflo2,  
                    minuend    => regr, 
                    subtrahend => regd, 
                    borrow_in  => '0',
                    SrcRegMode => TwosComp
                  );               
                                               -- if regr is negative, then restore
           IF (regr(regr'LEFT) /= '0')   THEN
                                               -- regr := regr + regd
                                               -- regb := 2*regb 
                RegAdd(regr, b_out, uvflo2, regr, regd, '0', TwosComp);
                RegShift(regb, regb, shiftout, '1', '0', 1);
           ELSE
                                                -- regb := 2*regb + 1;
                regShift(regb, regb, shiftout, '1', '0', 1);
                regb := RegInc (regb, Unsigned );
           END IF;

      END LOOP;
     
      -- if the result and remainder should be negative 
        IF (neg_res AND (SrcRegMode /= Unsigned)) THEN
              regb := RegNegate(regb, SrcRegMode);
        END IF;

        IF (neg_rem AND (SrcRegMode /= Unsigned)) THEN
              regr := RegNegate(regr, SrcRegMode);
        END IF;

      -- determine the length of result
        IF (result'LENGTH <= dividend'LENGTH) THEN
           res_copy := regb(result'LENGTH - 1 DOWNTO 0);
            ASSERT (result'LENGTH = dividend'LENGTH) OR (NOT WarningsOn)
            REPORT " RegDiv --- length of result is shorter than dividend "
            SEVERITY WARNING;
        ELSE
                                                -- sign extend the quotient
           res_copy := SignExtend(regb, result'LENGTH, regb'LEFT, SrcRegMode);
        END IF;
                -- remainder is in most significant N bits, shift right N bits 
         RegShift(regr, regr, shiftout, '0', regr(len), nd2);
      -- remainder length
        IF ( remainder'LENGTH <= len ) THEN
            rem_copy := regr(remainder'LENGTH - 1 DOWNTO 0);
            IF (SrcRegMode /= Unsigned) THEN
               rem_copy(result'LENGTH - 1) := regr(result'LENGTH);  -- sign bit
            END IF;	
        ELSE
            rem_copy := SignExtend(regr, remainder'LENGTH, regr'LEFT, SrcRegMode);
        END IF;
        result    := To_X01(res_copy);
        remainder := To_X01(rem_copy);
        ZeroDivide := '0';	
    
    -- That's all
      RETURN;
    END;

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
                      ) IS
      VARIABLE res_copy      : BIT_VECTOR(result'LENGTH - 1 DOWNTO 0);
      VARIABLE res           : BIT_VECTOR(result'LENGTH - 1 DOWNTO 0);
      VARIABLE remainderb     : BIT_VECTOR(result'LENGTH - 1 DOWNTO 0);
      VARIABLE divid_copy : BIT_VECTOR(dividend'LENGTH - 1 DOWNTO 0) := dividend;
      VARIABLE modulus_copy  : BIT_VECTOR(modulus'LENGTH - 1 DOWNTO 0) := modulus;
      VARIABLE zeroflag      : BIT;
      VARIABLE c_out         : BIT;
      VARIABLE uvflo         : BIT;

     BEGIN 
     --   Null range check
     --   if result vector or remainderb vector has a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMod  ---  Destination   has null range. "
             SEVERITY ERROR;
             RETURN;
     --   if both dividend   and modulus   have null range no need to divide
       ELSIF (dividend'LENGTH = 0) AND (modulus'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMod --- both dividend  and modulus has null range "
             SEVERITY ERROR;
             res_copy :=  (OTHERS => '0');
             result := res_copy;            -- result is filled with zeros
             RETURN;      

     -- if one of the dividend  or divisor is null 
       ELSIF (dividend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMod ---  dividend  has null range "
             SEVERITY ERROR;
                              -- treat dividend as zero so result is zero 
             res_copy := (OTHERS => '0');
             result := res_copy;
             RETURN;
       ELSIF (modulus'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMod --- modulus  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             res_copy := (OTHERS => '0');
             result := res_copy;
             RETURN;
       END IF;
           
    -- check for divide by zero
      IF ( is_zero(modulus_copy, SrcRegMode) )  THEN     -- applying the equality operator
          ASSERT false
          REPORT " RegMod  ---  divide by zero  "
          SEVERITY ERROR;
          res_copy := (OTHERS => '0');
          result := res_copy;
          ZeroDivide := '1';	
          RETURN;
      END IF;  

    -- Use procedure RegDiv to calculate the remainderb
    -- Then mod is calculated
    --
      RegDiv(res, remainderb, zeroflag, divid_copy, modulus_copy, SrcRegMode);

      res_copy := remainderb;
      IF ( (SrcRegMode /= Unsigned) AND ( divid_copy(divid_copy'LEFT) = '0')) THEN 
                                                                  -- dividend positive
          IF ( is_zero(remainderb, SrcRegMode) ) THEN
               null;
          ELSIF (modulus_copy(modulus_copy'LEFT) /= '0') THEN   -- negative modulus
                  RegAdd(res_copy, c_out, uvflo, modulus_copy, remainderb, '0', SrcRegMode); 
          END IF;
      ELSIF ((SrcRegMode /= Unsigned) AND (divid_copy(divid_copy'LEFT) /= '0')) THEN
                                      -- negative dividend
           IF ( is_zero(remainderb, SrcRegMode) ) THEN
              null;
           ELSIF (modulus_copy(modulus_copy'LEFT ) = '0') THEN      -- positive modulus
               RegAdd(res_copy, c_out, uvflo, modulus_copy, remainderb, '0', SrcRegMode);
           END IF;
      END IF;
      result := res_copy;    -- copy internal res_copy to result
      ZeroDivide := '0';	
    -- That's all
      RETURN;
    END;

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
                      ) IS
      VARIABLE res1_copy   : std_logic_vector(result'LENGTH - 1 DOWNTO 0);
      VARIABLE res         : std_logic_vector(result'LENGTH - 1 DOWNTO 0);
      VARIABLE remainderu  : std_logic_vector(result'LENGTH - 1 DOWNTO 0);
      VARIABLE dividnd_cpy : std_logic_vector(dividend'LENGTH - 1 DOWNTO 0) := dividend;
      VARIABLE mod_copy    : std_logic_vector(modulus'LENGTH - 1 DOWNTO 0) := modulus;
      VARIABLE zeroflag    : std_ulogic;
      VARIABLE c_out       : std_ulogic;
      VARIABLE uvflo       : std_ulogic;

     BEGIN 
     --   Null range check
     --   if result vector null range
       IF (result'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMod  ---  Destination   has null range. "
             SEVERITY ERROR;
             RETURN;
     --   if both dividend   and modulus   have null range no need to divide
       ELSIF (dividend'LENGTH = 0) AND (modulus'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMod --- both dividend  and modulus has null range "
             SEVERITY ERROR;
             res1_copy :=  (OTHERS => '0');
             result := res1_copy;                   -- result is filled with zeros
             RETURN;      

     -- if one of the dividend  or divisor is null 
       ELSIF (dividend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMod ---  dividend  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             res1_copy := (OTHERS => '0');
             result := res1_copy;
             RETURN;
       ELSIF (modulus'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMod --- modulus  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             res1_copy := (OTHERS => '0');
             result := res1_copy;
             RETURN;
       END IF;
           
      IF ( is_zero(mod_copy, SrcRegMode) )  THEN     -- applying the equality operator
          ASSERT false
          REPORT " RegMod  ---  divide by zero  "
          SEVERITY ERROR;
          res1_copy := (OTHERS => '0');
          result := res1_copy;
          ZeroDivide := '1';	
          RETURN;
      END IF;  

    -- Use procedure RegDiv to calculate the remainderu
    -- Then mod is calculated
    --
      RegDiv(res, remainderu, zeroflag, dividnd_cpy, mod_copy, SrcRegMode);
      res1_copy := remainderu;
      IF ( (SrcRegMode /= Unsigned) AND ( dividnd_cpy(dividnd_cpy'LEFT) = '0')) THEN 
                                                                  -- dividend positive
          IF ( is_zero(remainderu, SrcRegMode) ) THEN
               null;
          ELSIF (mod_copy(mod_copy'LEFT) /= '0') THEN   -- negative modulus
                  RegAdd(res1_copy, c_out, uvflo, mod_copy, remainderu, '0', SrcRegMode); 
          END IF;
      ELSIF ((SrcRegMode /= Unsigned) AND (dividnd_cpy(dividnd_cpy'LEFT) /= '0')) THEN
                                      -- negative dividend
           IF ( is_zero(remainderu, SrcRegMode) ) THEN
              null;
           ELSIF (mod_copy(mod_copy'LEFT) = '0')  THEN    -- positive modulus
               RegAdd(res1_copy, c_out, uvflo, mod_copy, remainderu, '0', SrcRegMode);
           END IF;
      END IF;
      result := To_X01(res1_copy);
      ZeroDivide := '0';	
    -- That's all
      RETURN;
    END;

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
                      ) IS
      VARIABLE res_copy    : std_ulogic_vector(result'LENGTH - 1 DOWNTO 0);
      VARIABLE res         : std_ulogic_vector(result'LENGTH - 1 DOWNTO 0);
      VARIABLE remainderul : std_ulogic_vector(result'LENGTH - 1 DOWNTO 0);
      VARIABLE dividnd_cpy : std_ulogic_vector(dividend'LENGTH - 1 DOWNTO 0) := dividend;
      VARIABLE mod_copy    : std_ulogic_vector(modulus'LENGTH - 1 DOWNTO 0) := modulus;
      VARIABLE zeroflag    : std_ulogic;
      VARIABLE c_out       : std_ulogic;
      VARIABLE uvflo       : std_ulogic;

     BEGIN 
     --   Null range check
     --   if result vector 
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMod  ---  Destination   has null range. "
             SEVERITY ERROR;
             RETURN;
     --   if both dividend   and modulus   have null range no need to divide
       ELSIF (dividend'LENGTH = 0) AND (modulus'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMod --- both dividend  and modulus has null range "
             SEVERITY ERROR;
             res_copy :=  (OTHERS => '0');
             result := res_copy;                   -- result is filled with zeros
             RETURN;      

     -- if one of the dividend  or divisor is null 
       ELSIF (dividend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMod ---  dividend  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             res_copy := (OTHERS => '0');
             result := res_copy;
             RETURN;
       ELSIF (modulus'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegMod --- modulus  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             res_copy := (OTHERS => '0');
             result := res_copy;
             RETURN;
       END IF;
           
    -- check for divide by zero
      IF ( is_zero(mod_copy, SrcRegMode) )  THEN     -- applying the equality operator
          ASSERT false
          REPORT " RegMod  ---  divide by zero  "
          SEVERITY ERROR;
          res_copy := (OTHERS => '0');
          result := res_copy;
          ZeroDivide := '1';	
          RETURN;
      END IF;  

    -- Use procedure RegDiv to calculate the remainderul
    -- Then mod is calculated
    --
      RegDiv(res, remainderul, zeroflag, dividnd_cpy, mod_copy, SrcRegMode);
      res_copy := remainderul;
      IF ( (SrcRegMode /= Unsigned) AND ( dividnd_cpy(dividnd_cpy'LEFT) = '0')) THEN 
                                                                  -- dividend positive
          IF ( is_zero(remainderul, SrcRegMode) ) THEN
               null;
          ELSIF (mod_copy(mod_copy'LEFT) /= '0') THEN   -- negative modulus
                  RegAdd(res_copy, c_out, uvflo, mod_copy, remainderul, '0', SrcRegMode); 
          END IF;
      ELSIF ((SrcRegMode /= Unsigned) AND (dividnd_cpy(dividnd_cpy'LEFT) /= '0')) THEN
                                      -- negative dividend
           IF ( is_zero(remainderul, SrcRegMode) ) THEN
              null;
           ELSIF (mod_copy(mod_copy'LEFT) = '0') THEN      -- positive modulus
               RegAdd(res_copy, c_out, uvflo, mod_copy, remainderul, '0', SrcRegMode);
           END IF;
      END IF;
      result := To_X01(res_copy);
      ZeroDivide := '0';	

    -- That's all
      RETURN;
    END;

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
                      ) IS
      CONSTANT nd        : INTEGER := dividend'LENGTH;    
      CONSTANT len       : INTEGER := 2 * nd;
      VARIABLE res_copy : BIT_VECTOR(result'LENGTH - 1 DOWNTO 0);
      VARIABLE dividend_copy : BIT_VECTOR(dividend'LENGTH - 1 DOWNTO 0) := dividend;
      VARIABLE divisor_copy  : BIT_VECTOR(divisor'LENGTH - 1 DOWNTO 0) := divisor;
      VARIABLE regr      : BIT_VECTOR(len  DOWNTO 0) := (OTHERS => '0');
      VARIABLE rega      : BIT_VECTOR(len  DOWNTO 0) := (OTHERS => '0');
      VARIABLE regd      : BIT_VECTOR(len  DOWNTO 0) := (OTHERS => '0');
      VARIABLE regb      : BIT_VECTOR(nd - 1 DOWNTO 0);   -- quotient
      VARIABLE neg_res   : Boolean := FALSE;              -- sign of result
      VARIABLE b_out     : BIT;
      VARIABLE uvflo     : BIT;
      VARIABLE shiftout  : BIT;

     BEGIN 
     --  
     --   Null range check
     --   if result vector null range
       IF ( result'LENGTH = 0)  THEN
             ASSERT false
             REPORT " RegRem  ---  Destination   has null range. "
             SEVERITY ERROR;
             RETURN;
     --   if both dividend   and divisor   have null range no need to divide
       ELSIF (dividend'LENGTH = 0) AND (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegRem --- both dividend  and divisor has null range "
             SEVERITY ERROR;
             res_copy :=  (OTHERS => '0');
             result := res_copy;                   -- result is filled with zeros
             RETURN;      

     -- if one of the dividend  or divisor is null 
       ELSIF (dividend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegRem ---  dividend  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             res_copy := (OTHERS => '0');
             result := res_copy;
             RETURN;
       ELSIF (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegRem --- divisor  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             res_copy := (OTHERS => '0');
             result := res_copy;
             RETURN;
       END IF;
           
    -- check for divide by zero
      IF ( is_zero(divisor_copy, SrcRegMode) )  THEN     -- applying the equality operator
          ASSERT false
          REPORT " RegRem  ---  divide by zero  "
          SEVERITY ERROR;
          res_copy := (OTHERS => '0');
          result := res_copy;
          ZeroDivide := '1';	
          RETURN;
      END IF;  

    -- put dividend to rega  and divisor to regd
      rega(dividend'LENGTH - 1 DOWNTO 0) := dividend_copy;          
      regd(divisor'LENGTH - 1 DOWNTO 0) := divisor_copy;  
   -- inputs are  not null so determine the sign and convert 
   -- the inputs to unsigned  representation.
     IF (SrcRegMode /= Unsigned) THEN
        IF (dividend_copy(dividend_copy'LEFT) /= '0') THEN
           neg_res := NOT neg_res;          -- sign od dividend is sign of result
           rega(dividend'LENGTH - 1 DOWNTO 0) := To_Unsign (dividend_copy, SrcRegMode);     
        END IF;

        IF (divisor_copy(divisor_copy'LEFT) /= '0') THEN
           regd(divisor'LENGTH - 1 DOWNTO 0) := To_Unsign(divisor_copy, SrcRegMode);  
        END IF;
     END IF;
 
   -- Perform division by binary restoring algorithm
   --    initialize 
   -- load rega to regr, 
   -- regd  gets regd shifted left by nd bits
   -- regb  gets all zerso
       regr := rega;                
            -- left shift regd by nd ( length of dividend) bits, fill with zero's
       RegShift(regd, regd, shiftout, '1', '0', nd);
       regb := (OTHERS => '0');

       For i IN 0 TO nd - 1 LOOP
                                                -- regr := 2*regr - regd
           RegShift(regr, regr, shiftout, '1', '0', 1);
           RegSub ( result     => regr, 
                    borrow_out => b_out, 
                    overflow   => uvflo,  
                    minuend    => regr, 
                    subtrahend => regd, 
                    borrow_in  => '0',
                    SrcRegMode => TwosComp
                  );               
                                               -- if regr is negative, then restore
           IF (regr(regr'LEFT) /= '0')   THEN
                                               -- regr := regr + regd
                                               -- regb := 2*regb 
                RegAdd(regr, b_out, uvflo, regr, regd, '0', TwosComp);
                RegShift(regb, regb, shiftout, '1', '0', 1);
           ELSE
                                                -- regb := 2*regb + 1;
                RegShift(regb, regb, shiftout, '1', '0', 1);
                regb := RegInc (regb, Unsigned);
           END IF;

      END LOOP;
      -- if the result and remainder should be negative 
        IF (neg_res AND (SrcRegMode /= Unsigned)) THEN
              regr := RegNegate(regr, SrcRegMode);
        END IF;
          -- most significant of regr holds result
         RegShift(regr, regr, shiftout, '0', regr(len), nd);
      -- determine the length of result
        IF (result'LENGTH <= len) THEN
           res_copy := regr(result'LENGTH - 1 DOWNTO 0);
           IF (SrcRegMode /= Unsigned) THEN
              res_copy(result'LENGTH - 1) := regr(result'LENGTH);  -- sign bit
           END IF;
            ASSERT (result'LENGTH = dividend'LENGTH) OR (NOT WarningsOn)
            REPORT " RegRem --- length of result  is shorter than dividend "
            SEVERITY WARNING;
        ELSE
                                                -- sign extend the remainder
           res_copy := SignExtend(regr, result'LENGTH, regr'LEFT, SrcRegMode);
        END IF;
        result := res_copy;
        ZeroDivide := '0';	
    
    -- That's all
      RETURN;
    END;

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
                      ) IS
      CONSTANT nd1        : INTEGER := dividend'LENGTH;    
      CONSTANT len       : INTEGER := 2 * nd1;
      VARIABLE res_copy : std_logic_vector(result'LENGTH - 1 DOWNTO 0);
      VARIABLE dividnd_copy : std_logic_vector(dividend'LENGTH - 1 DOWNTO 0) := dividend;
      VARIABLE divisr_copy  : std_logic_vector(divisor'LENGTH - 1 DOWNTO 0) := divisor;
      VARIABLE regr      : std_logic_vector(len DOWNTO 0) := (OTHERS => '0');
      VARIABLE rega      : std_logic_vector(len DOWNTO 0) := (OTHERS => '0');
      VARIABLE regd      : std_logic_vector(len DOWNTO 0) := (OTHERS => '0');
      VARIABLE regb      : std_logic_vector(nd1 - 1 DOWNTO 0);   -- quotient
      VARIABLE neg_res   : Boolean := FALSE;              -- sign of result
      VARIABLE b_out     : std_ulogic;
      VARIABLE uvflo     : std_ulogic;
      VARIABLE shiftout  : std_ulogic;

     BEGIN 
     --  
     --   Null range check
     --   if result vector null range
       IF ( result'LENGTH = 0)  THEN
             ASSERT false
             REPORT " RegRem  ---  Destination   has null range. "
             SEVERITY ERROR;
             RETURN;
     --   if both dividend   and divisor   have null range no need to divide
       ELSIF (dividend'LENGTH = 0) AND (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegRem --- both dividend  and divisor has null range "
             SEVERITY ERROR;
             res_copy :=  (OTHERS => '0');
             result := res_copy;                   -- result is filled with zeros
             RETURN;      

     -- if one of the dividend  or divisor is null 
       ELSIF (dividend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegRem ---  dividend  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             res_copy := (OTHERS => '0');
             result := res_copy;
             RETURN;
       ELSIF (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegRem --- divisor  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             res_copy := (OTHERS => '0');
             result := res_copy;
             RETURN;
       END IF;
           
    -- check for divide by zero
      IF ( is_zero(divisr_copy, SrcRegMode) )  THEN     -- applying the equality operator
          ASSERT false
          REPORT " RegRem  ---  divide by zero  "
          SEVERITY ERROR;
          res_copy := (OTHERS => '0');
          result := res_copy;
          ZeroDivide := '1';	
          RETURN;
      END IF;  

    -- put dividend to rega  and divisor to regd
      rega(dividend'LENGTH - 1 DOWNTO 0) := dividnd_copy;          
      regd(divisor'LENGTH - 1 DOWNTO 0) := divisr_copy;  
   -- inputs are  not null so determine the sign and convert 
   -- the inputs to unsigned  representation.
     IF (SrcRegMode /= Unsigned) THEN
        IF (dividnd_copy(dividnd_copy'LEFT) /= '0') THEN
           neg_res := NOT neg_res;          -- sign od dividend is sign of result
           rega(dividend'LENGTH - 1 DOWNTO 0) := To_Unsign (dividnd_copy, SrcRegMode);     
        END IF;

        IF (divisr_copy(divisr_copy'LEFT) /= '0') THEN
           regd(divisor'LENGTH - 1 DOWNTO 0) := To_Unsign(divisr_copy, SrcRegMode);  
        END IF;
     END IF;
 
   -- Perform division by binary restoring algorithm
   --    initialize 
   -- load rega to regr, 
   -- regd  gets regd shifted left by nd bits
   -- regb  gets all zerso
   -- 
       regr := rega;                
            -- left shift regd by nd ( length of dividend) bits, fill with zero's
       RegShift(regd, regd, shiftout, '1', '0', nd1);
       regb := (OTHERS => '0');

       For i IN 0 TO nd1 - 1 LOOP
                                                -- regr := 2*regr - regd
           RegShift(regr, regr, shiftout, '1', '0', 1);
           RegSub ( result     => regr, 
                    borrow_out => b_out, 
                    overflow   => uvflo,  
                    minuend    => regr,  
                    subtrahend => regd, 
                    borrow_in  => '0',
                    SrcRegMode => TwosComp
                  );               
                                               -- if regr is negative, then restore
           IF (regr(regr'LEFT) /= '0')   THEN
                                               -- regr := regr + regd
                                               -- regb := 2*regb 
                RegAdd(regr, b_out, uvflo, regr, regd, '0', TwosComp);
                RegShift(regb, regb, shiftout, '1', '0', 1);
           ELSE
                                                -- regb := 2*regb + 1;
                Regshift(regb, regb, shiftout, '1', '0', 1);
                regb := RegInc ( regb, Unsigned );
           END IF;

      END LOOP;
      -- if the result and remainder should be negative 
        IF (neg_res AND (SrcRegMode /= Unsigned)) THEN
              regr := RegNegate(regr, SrcRegMode);
        END IF;
          -- most significant of regr holds result
         RegShift(regr, regr, shiftout, '0', regr(len), nd1);
      -- determine the length of result
        IF (result'LENGTH <= len) THEN
           res_copy := regr(result'LENGTH - 1 DOWNTO 0);
           IF (SrcRegMode /= Unsigned) THEN
              res_copy(result'LENGTH - 1) := regr(result'LENGTH);  -- sign bit
           END IF;
            ASSERT (result'LENGTH = dividend'LENGTH) OR (NOT WarningsOn)
            REPORT " RegRem --- length of result  is shorter than dividend "
            SEVERITY WARNING;
        ELSE
                                                -- sign extend the remainder
           res_copy := SignExtend(regr, result'LENGTH, regr'LEFT, SrcRegMode);
        END IF;
        result   := To_X01(res_copy);
        ZeroDivide := '0';	
    -- That's all
      RETURN;
    END;
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
                      ) IS
      CONSTANT nd        : INTEGER := dividend'LENGTH;    
      CONSTANT len       : INTEGER := 2 * nd;
      VARIABLE res_copy : std_ulogic_vector(result'LENGTH - 1 DOWNTO 0);
      VARIABLE dividend_copy : std_ulogic_vector(dividend'LENGTH - 1 DOWNTO 0) := dividend;
      VARIABLE divisor_copy  : std_ulogic_vector(divisor'LENGTH - 1 DOWNTO 0) := divisor;
      VARIABLE regr      : std_ulogic_vector(len DOWNTO 0) := (OTHERS => '0');
      VARIABLE rega      : std_ulogic_vector(len DOWNTO 0) := (OTHERS => '0');
      VARIABLE regd      : std_ulogic_vector(len DOWNTO 0) := (OTHERS => '0');
      VARIABLE regb      : std_ulogic_vector(nd - 1 DOWNTO 0);   -- quotient
      VARIABLE neg_res   : Boolean := FALSE;              -- sign of result
      VARIABLE b_out     : std_ulogic;
      VARIABLE uvflo     : std_ulogic;
      VARIABLE shiftout  : std_ulogic;

     BEGIN 
     --   Null range check
     --   if result vector has a null range
       IF ( result'LENGTH = 0)  THEN
             ASSERT false
             REPORT " RegRem  ---  Destination   has null range. "
             SEVERITY ERROR;
             RETURN;
     --   if both dividend   and divisor   have null range no need to divide
       ELSIF (dividend'LENGTH = 0) AND (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegRem --- both dividend  and divisor has null range "
             SEVERITY ERROR;
             res_copy :=  (OTHERS => '0');
             result := res_copy;                   -- result is filled with zeros
             RETURN;      

     -- if one of the dividend  or divisor is null 
       ELSIF (dividend'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegRem ---  dividend  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             res_copy := (OTHERS => '0');
             result := res_copy;
             RETURN;
       ELSIF (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegRem --- divisor  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             res_copy := (OTHERS => '0');
             result := res_copy;
             RETURN;
       END IF;
           
    -- check for divide by zero
      IF ( is_zero(divisor_copy, SrcRegMode) )  THEN     -- applying the equality operator
          ASSERT false
          REPORT " RegRem  ---  divide by zero  "
          SEVERITY ERROR;
          res_copy := (OTHERS => '0');
          result := res_copy;
          ZeroDivide := '1';	
          RETURN;
      END IF;  

    -- put dividend to rega  and divisor to regd
      rega(dividend'LENGTH - 1 DOWNTO 0) := dividend_copy;          
      regd(divisor'LENGTH - 1 DOWNTO 0) := divisor_copy;  
   -- inputs are  not null so determine the sign and convert 
   -- the inputs to unsigned  representation.
     IF (SrcRegMode /= Unsigned) THEN
        IF (dividend_copy(dividend_copy'LEFT) /= '0') THEN
           neg_res := NOT neg_res;          -- sign od dividend is sign of result
           rega(dividend'LENGTH - 1 DOWNTO 0) := To_Unsign (dividend_copy, SrcRegMode);     
        END IF;

        IF (divisor_copy(divisor_copy'LEFT) /= '0') THEN
           regd(divisor'LENGTH - 1 DOWNTO 0) := To_Unsign(divisor_copy, SrcRegMode);  
        END IF;
     END IF;
   -- Perform division by binary restoring algorithm
   --    initialize 
   -- load rega to regr, 
   -- regd  gets regd shifted left by nd bits
   -- regb  gets all zerso
   -- 
       regr := rega;                
            -- left shift regd by nd ( length of dividend) bits, fill with zero's
       RegShift(regd, regd, shiftout, '1', '0', nd);
       regb := (OTHERS => '0');

       For i IN 0 TO nd - 1 LOOP
                                                -- regr := 2*regr - regd
           RegShift(regr, regr, shiftout, '1', '0', 1);
           RegSub ( result     => regr, 
                    borrow_out => b_out, 
                    overflow   => uvflo,  
                    minuend    => regr, 
                    subtrahend => regd, 
                    borrow_in  => '0',
                    SrcRegMode => TwosComp
                  );               
                                               -- if regr is negative, then restore
           IF (regr(regr'LEFT) /= '0')   THEN
                                               -- regr := regr + regd
                                               -- regb := 2*regb 
                RegAdd(regr, b_out, uvflo, regr, regd, '0', TwosComp);
                RegShift(regb, regb, shiftout, '1', '0', 1);
           ELSE
                                                -- regb := 2*regb + 1;
                RegShift(regb, regb, shiftout, '1', '0', 1);
                regb := RegInc (regb , Unsigned );
           END IF;

      END LOOP;
      -- if the result and remainder should be negative 
        IF (neg_res AND (SrcRegMode /= Unsigned)) THEN
              regr := RegNegate(regr, SrcRegMode);
        END IF;
          -- most significant of regr holds result
         RegShift(regr, regr, shiftout, '0', regr(len), nd);
      -- determine the length of result
        IF (result'LENGTH <= len) THEN
           res_copy := regr(result'LENGTH - 1 DOWNTO 0);
           IF (SrcRegMode /= Unsigned) THEN
              res_copy(result'LENGTH - 1) := regr(result'LENGTH);  -- sign bit
           END IF;
            ASSERT (result'LENGTH = dividend'LENGTH) OR (NOT WarningsOn)
            REPORT " RegRem --- length of result  is shorter than dividend "
            SEVERITY WARNING;
        ELSE
                                                -- sign extend the remainder
           res_copy := SignExtend(regr, result'LENGTH, regr'LEFT, SrcRegMode);
        END IF;
        result   := To_X01(res_copy);
        ZeroDivide := '0';	
    
    -- That's all
      RETURN;
    END;
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
                     ) IS
--      CONSTANT reslen        : INTEGER := IntegerBitLength;
	CONSTANT reslen        : INTEGER := result'length; 
	VARIABLE r             : BIT_VECTOR ( reslen - 1 DOWNTO 0 ) := (OTHERS =>'0');
	VARIABLE r2            : BIT_VECTOR ( reslen - 1 DOWNTO 0 ) := (OTHERS =>'0');
      	VARIABLE result_copy   : BIT_VECTOR (result'LENGTH - 1 DOWNTO 0);
      	VARIABLE base_copy     : BIT_VECTOR ( base'LENGTH - 1 DOWNTO 0 ) := base;
      	VARIABLE exponent_copy : BIT_VECTOR(exponent'LENGTH  - 1 DOWNTO 0) := exponent;
      	VARIABLE overflo1       : BIT := '0';
      	VARIABLE power          : INTEGER;
      	VARIABLE neg_result     : BOOLEAN := FALSE;
    BEGIN
     --   Null range check
     --   if result vector has a null range
       IF ( result'LENGTH = 0)  THEN
             ASSERT false
             REPORT " RegExp  ---  Destination   has null range. "
             SEVERITY ERROR;
             overflow := '1';
             RETURN;
     --   if both base    and exponent   have null range no need to divide
       ELSIF (base'LENGTH = 0) AND (exponent'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegExp --- both base  and exponent  has null range "
             SEVERITY ERROR;
             result_copy :=  (OTHERS => '0');
             result := result_copy;               -- result is filled with zeros
             overflow := overflo1;
             RETURN;      

     -- if one of the base  or exponet is null 
       ELSIF (base'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegExp ---  base  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             result_copy := (OTHERS => '0');
             result := result_copy;
             overflow := overflo1;
          
             RETURN;
       ELSIF (exponent'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegExp --- exponent  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             result_copy := (OTHERS => '0');
             result_copy(0) := '1';          -- base raised to the power 0 = 1
             result := result_copy;
             overflow := overflo1;
             RETURN;
       END IF;
           
    -- inputs are  not null so determine the sign and convert 
    -- base to unsigned  and exponent to integer
      power := To_Integer (exponent_copy, SrcRegMode );
      IF (( SrcRegMode /= Unsigned) AND (base(base'LEFT) = '1')) THEN
          base_copy := To_Unsign(base, SrcRegMode);
              -- base is a negative number and power is not an even multiple of 2
              -- the result should be negative
          IF ((power mod 2) /= 0) THEN  
              neg_result := NOT neg_result;
          END IF;
      END IF;
     -- multiply the base by itself for the number of times  absoulte 
    --  value of exponent. 
    -- if the exponet (power) is less than zero then
    -- result is zero. 
    -- if power is 0 then result is one

      IF (power < 0) THEN
          ASSERT NOT WarningsOn 
          REPORT " RegExp   ---  negative exponent, returning zero result "
          SEVERITY WARNING;
       ELSIF (power=0 ) THEN            -- result is 1
          r(0) := '1';
       ELSIF (power=1) THEN
          r (base'LENGTH - 1 DOWNTO 0) := base_copy;
       ELSIF (power > 1) THEN
                                     -- set r to 1 and
                                     --  use repeated multiplication
          r(0) := '1';
          FOR i IN 1 TO power LOOP
              RegMult(r2, overflo1, r, base_copy, Unsigned);
	      r := r2;
              EXIT WHEN (overflo1 /= '0');
          END LOOP;
       END IF;
    -- determine sign
     IF  (neg_result   AND (SrcRegMode /= Unsigned))THEN     
        r := RegNegate(r, SrcRegMode);
     END IF;
   -- determine the length of result
     IF (result'LENGTH < reslen) THEN
         result_copy := r(result'LENGTH - 1 DOWNTO 0);
     ELSIF (result'LENGTH = reslen) THEN
         result_copy := r;
     ELSE
                                                -- sign extend the r
         result_copy := SignExtend(r, result'LENGTH, r'LEFT, SrcRegMode);
     END IF;
     result   := result_copy;
     overflow := overflo1;
    
    -- That's all
      RETURN;
    END;
 
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
                     ) IS
--      CONSTANT reslen        : INTEGER := IntegerBitLength;
	CONSTANT reslen        : INTEGER := result'LENGTH;
      	VARIABLE r             : std_logic_vector ( reslen - 1 DOWNTO 0 ) := (OTHERS =>'0');
	VARIABLE r2            : std_logic_vector ( reslen - 1 DOWNTO 0 ) := (OTHERS =>'0');
      	VARIABLE result_copy   : std_logic_vector (result'LENGTH - 1 DOWNTO 0);
      	VARIABLE base_copy     : std_logic_vector ( base'LENGTH - 1 DOWNTO 0 ) := base;
      	VARIABLE exponent_copy : std_logic_vector(exponent'LENGTH - 1 DOWNTO 0) := exponent;
      	VARIABLE power         : INTEGER;
      	VARIABLE neg_result    : BOOLEAN := FALSE;
      	VARIABLE overflo       : std_ulogic :='0';
    BEGIN
     --   Null range check
          overflo := '0';
     --   if result vector has a null range
       IF ( result'LENGTH = 0)  THEN
             ASSERT false
             REPORT " RegExp  ---  Destination   has null range. "
             SEVERITY ERROR;
             overflow := '1';
             RETURN;
     --   if both base    and exponent   have null range no need to divide
       ELSIF (base'LENGTH = 0) AND (exponent'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegExp --- both base  and exponent  has null range "
             SEVERITY ERROR;
             result_copy :=  (OTHERS => '0');
             result := result_copy;               -- result is filled with zeros
             overflow := overflo;             
             RETURN;      

     -- if one of the base  or exponet is null 
       ELSIF (base'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegExp ---  base  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             result_copy := (OTHERS => '0');
             result := result_copy;
             overflow := overflo;
             RETURN;
       ELSIF (exponent'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegExp --- exponent  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             result_copy := (OTHERS => '0');
             result_copy(0) := '1';          -- base raised to the power 0 = 1
             result := result_copy;
             overflow := overflo;
             RETURN;
       END IF;
           
    -- inputs are  not null so determine the sign and convert 
    -- base to unsigned  and exponent to integer
      power := To_Integer (exponent_copy, SrcRegMode );
      IF (( SrcRegMode /= Unsigned) AND (base(base'LEFT) = '1')) THEN
          base_copy := To_Unsign(base, SrcRegMode);
              -- base is a negative number and power is not an even multiple of 2
              -- the result should be negative
          IF ((power mod 2) /= 0) THEN  
              neg_result := NOT neg_result;
          END IF;
     END IF;
     -- multiply the base by itself for the number of times  absoulte 
    --  value of exponent. 
    -- if the exponet (power) is less than zero then
    -- result is zero. 
    -- if power is 0 then result is one
      IF (power < 0) THEN
          ASSERT NOT WarningsOn 
          REPORT " RegExp   ---  negative exponent, returning zero result "
          SEVERITY WARNING;
       ELSIF (power=0 ) THEN            -- result is 1
          r(0) := '1';
       ELSIF (power=1) THEN
          r (base'LENGTH - 1 DOWNTO 0) := base_copy;
       ELSIF (power > 1) THEN
                                     -- set r to 1 and
                                     -- then use repeated multiplication
          r(0) := '1';
          FOR i IN 1 TO power LOOP
              RegMult(r2, overflo, r, base_copy, Unsigned);
	      r := r2;
              EXIT when (overflo /= '0');
          END LOOP;
      END IF;
    -- determine sign
     IF (neg_result  AND (SrcRegMode /= Unsigned))THEN     
        r := RegNegate(r, SrcRegMode);
     END IF;
      -- determine the length of result
        IF (result'LENGTH < reslen) THEN
           result_copy := r(result'LENGTH - 1 DOWNTO 0);
        ELSIF (result'LENGTH = reslen) THEN
            result_copy := r;
        ELSE
                                                -- sign extend the r
           result_copy := SignExtend(r, result'LENGTH, r'LEFT, SrcRegMode);
        END IF;
        result   := To_X01(result_copy);
        overflow := To_X01(overflo);
    
    -- That's all
      RETURN;
    END;
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
                     ) IS
--      CONSTANT reslen         : INTEGER := IntegerBitLength;
	CONSTANT reslen         : INTEGER := result'LENGTH;
      	VARIABLE r              : std_ulogic_vector ( reslen - 1 DOWNTO 0 ) := (OTHERS =>'0');
	VARIABLE r2             : std_ulogic_vector ( reslen - 1 DOWNTO 0 ) := (OTHERS =>'0');
      	VARIABLE result_copy    : std_ulogic_vector(result'LENGTH - 1 DOWNTO 0);
      	VARIABLE base_copy      : std_ulogic_vector( base'LENGTH - 1 DOWNTO 0 ) := base;
      	VARIABLE exponent_copy  : std_ulogic_vector(exponent'LENGTH - 1 DOWNTO 0) := exponent;
      	VARIABLE power          : INTEGER;
      	VARIABLE neg_result     : BOOLEAN := FALSE;
      	VARIABLE overflo2       : std_ulogic := '0';
    BEGIN
     --   Null range check
          overflo2 := '0';
     --   if result vector has a null range
       IF ( result'LENGTH = 0)  THEN
             ASSERT false
             REPORT " RegExp  ---  Destination   has null range. "
             SEVERITY ERROR;
             overflow := '1';
             RETURN;
     --   if both base    and exponent   have null range no need to divide
       ELSIF (base'LENGTH = 0) AND (exponent'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegExp --- both base  and exponent  has null range "
             SEVERITY ERROR;
             result_copy :=  (OTHERS => '0');
             result := result_copy;               -- result is filled with zeros
             overflow := overflo2;
             RETURN;      

     -- if one of the base  or exponet is null 
       ELSIF (base'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegExp ---  base  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             result_copy := (OTHERS => '0');
             result := result_copy;
             overflow := overflo2;
             RETURN;
       ELSIF (exponent'LENGTH = 0) THEN
             ASSERT false
             REPORT " RegExp --- exponent  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             result_copy := (OTHERS => '0');
             result_copy(0) := '1';          -- base raised to the power 0 = 1
             result := result_copy;
             overflow := overflo2;
             RETURN;
       END IF;
           
    -- inputs are  not null so determine the sign and convert 
    -- base to unsigned  and exponent to integer
      power := To_Integer (exponent_copy, SrcRegMode );
      IF (( SrcRegMode /= Unsigned) AND (base(base'LEFT) = '1')) THEN
          base_copy := To_Unsign(base, SrcRegMode);
              -- base is a negative number and power is not an even multiple of 2
              -- the result should be negative
          IF ((power mod 2) /= 0) THEN  
              neg_result := NOT neg_result;
          END IF;
     END IF;
     -- multiply the base by itself for the number of times  absoulte 
    --  value of exponent. 
    -- if the exponet (power) is less than zero then
    -- result is zero. 
    -- if power is 0 then result is one
      IF (power < 0) THEN
          ASSERT NOT WarningsOn 
          REPORT " RegExp   ---  negative exponent, returning zero result "
          SEVERITY WARNING;
       ELSIF (power = 0 ) THEN            -- result is 1
          r(0) := '1';
       ELSIF (power=1) THEN
          r (base'LENGTH - 1 DOWNTO 0) := base_copy;
       ELSIF (power > 1) THEN
                                     -- set r to 1 and
                                     -- then use repeated multiplication
          r(0) := '1';
          FOR i IN 1 TO power LOOP
              RegMult(r2, overflo2, r, base_copy, Unsigned);
	      r := r2;
              EXIT when (overflo2 /= '0');
          END LOOP;
      END IF;
   
    -- determine sign
     IF (neg_result  AND (SrcRegMode /= Unsigned))THEN     
        r := RegNegate(r, SrcRegMode);
     END IF;

  -- determine the length of result
    IF (result'LENGTH < reslen) THEN
         result_copy := r(result'LENGTH - 1 DOWNTO 0);
    ELSIF (result'LENGTH = reslen) THEN
         result_copy := r;
    ELSE
                                                -- sign extend the r
         result_copy := SignExtend(r, result'LENGTH, r'LEFT, SrcRegMode);
    END IF;
        result   := To_X01(result_copy);
        overflow := To_X01(overflo2);
    -- That's all
      RETURN;
    END;
    
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
                      ) IS 
      CONSTANT srclen    : INTEGER := SrcReg'LENGTH;
      CONSTANT dstlen    : INTEGER := DstReg'LENGTH;
      CONSTANT rlen      : INTEGER := maximum(2 * dstlen, 2 * srclen);
      VARIABLE shftbits  : INTEGER;
      VARIABLE r         : std_logic_vector ( rlen - 1 DOWNTO 0);
      VARIABLE src_copy  : std_logic_vector (srclen - 1 DOWNTO 0 ) := SrcReg;
      VARIABLE dst_copy  : std_logic_vector (DstReg'LENGTH - 1 DOWNTO 0 ) := DstReg;
      VARIABLE shift_out : std_ulogic;

   BEGIN
    
    --  Null range Check
    --  if input vector is of zero length
       IF ( srclen = 0) THEN
           ASSERT false
           REPORT " RegShift --- input std_logic_vector   is null  "
           SEVERITY ERROR;
           dst_copy := (OTHERS => FillVal);
           DstReg    := dst_copy;
	   IF (Nbits /= 0) THEN
              ShiftO := '0';
	   END IF;
           Return;
       END IF;
       -- set shift out bit
       IF (Nbits = 0) THEN
	  NULL;
       ELSIF (Nbits > srclen) THEN
           ShiftO := FillVal;
       ELSIF ( direction /= '0') THEN           -- shift left
	   ShiftO := src_copy(srclen - Nbits);
       ELSE                                     -- shift right
           ShiftO := src_copy(Nbits - 1);
       END IF;
       IF (DstReg'LENGTH = 0) THEN
           ASSERT false
           REPORT " RegShift --- output vector is  null  "
           SEVERITY ERROR;
           RETURN;
      END IF;

      shftbits := minimum(Nbits, dstlen);
      IF (direction /= '0') THEN  -- left shift
         r(srclen + shftbits - 1 downto shftbits) := src_copy(srclen -1 downto 0);
	 if (shftbits > 0) then
   	    r(shftbits - 1 downto 0) := (others => FillVal);
	 end if;
	 dst_copy(minimum(srclen + shftbits, dstlen) - 1 downto 0) := r(minimum(srclen + shftbits, dstlen) - 1 downto 0);
	 --dst_copy(srclen + shftbits - 1 downto 0) := r(dstlen - 1 downto 0);
      else                        -- right shift
         r(rlen - shftbits - 1 downto rlen - shftbits - srclen) := src_copy(srclen - 1 downto srclen - srclen);
	 if (shftbits > 0) then
  	    r(rlen - 1 downto rlen - shftbits) := (others => FillVal);
	 end if;
         dst_copy(dstlen - 1 downto maximum(dstlen - srclen - shftbits, 0)) := r(rlen - 1 downto rlen - minimum (srclen + shftbits, dstlen));
	 --dst_copy(rlen - 1 downto rlen - srclen - shftbits)  := r(rlen - 1 downto dstlen);
      end if;
      DstReg := dst_copy;
      RETURN;
   END;

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
                      ) IS

      variable temp : std_logic_vector(DstReg'RANGE) := std_logic_vector(DstReg);
		      
   BEGIN
      RegShift ( SrcReg    => std_logic_vector(SrcReg),
	         DstReg    => temp,
		 ShiftO	   => ShiftO,
		 direction => direction,
		 FillVal   => FillVal,
		 Nbits	   => Nbits );
      DstReg := std_ulogic_vector(temp);
   END;
   

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
--|                      VARIABLE acc   : BIT_VECTOR ( 15 DOWNTO 0);
--|                      VARIABLE carry : BIT;
--|
--|                      RegShift ( acc, acc, carry, '1', '0',3 );
--|
--|-----------------------------------------------------------------------------

   PROCEDURE RegShift  ( CONSTANT SrcReg    : IN bit_vector;
                         VARIABLE DstReg    : INOUT bit_vector;
                         VARIABLE ShiftO    : INOUT bit;
                         CONSTANT direction : IN bit   := '1';
                         CONSTANT FillVal   : IN bit   := '0';
                         CONSTANT Nbits     : IN Natural      := 1
                      ) IS

      variable temp : std_logic_vector(DstReg'RANGE) := To_StdLogicVector(DstReg);
      variable temp2 : std_ulogic := To_StdULogic(ShiftO);
		      
   BEGIN
      RegShift ( SrcReg    => To_StdLogicVector(SrcReg),
	         DstReg    => temp,
		 ShiftO	   => temp2,
		 direction => To_StdULogic(direction),
		 FillVal   => To_StdULogic(FillVal),
		 Nbits	   => Nbits );
      DstReg := To_BitVector(temp);
      ShiftO := To_Bit(temp2);
   END;


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
                     ) RETURN BIT_VECTOR IS
    
      VARIABLE  reslen : INTEGER := SrcReg'LENGTH;
      VARIABLE result  : BIT_VECTOR(reslen - 1 DOWNTO 0);
      VARIABLE reg     : BIT_VECTOR(reslen - 1 DOWNTO 0) := SrcReg;
      VARIABLE incby   : BIT_VECTOR(reslen - 1 DOWNTO 0) := (OTHERS => '0');
      VARIABLE overflo : BIT;
      VARIABLE carry   : BIT;
    BEGIN

    --  if input source register has null range then 
       IF (SrcReg'LENGTH = 0) THEN
           result := reg;
           ASSERT FALSE
           REPORT " RegInc --- Source register has null range "
           SEVERITY ERROR;
       ELSE 
       --  increment by 1
          incby(0) := '1';
          CASE SrcRegMode is
            WHEN TwosComp    => Add_TwosComp(result, carry, overflo, reg, incby, '0');
                        	IF (overflo /= '0') THEN
                                   ASSERT  NOT WarningsOn
	                           REPORT " RegInc (BitVector case) --- TwosComp overflow  "
        	                   SEVERITY WARNING;
                	         END IF;
            WHEN OnesComp     => AddSub_OnesComp(result, carry, overflo, reg, incby, '0');
                                 IF (overflo /= '0') THEN
                                   ASSERT  NOT WarningsOn
                                   REPORT " RegInc (BitVector case) --- OnesComp overflow "
                                   SEVERITY WARNING;
                                  END IF;

            WHEN Unsigned      => Add_Unsigned(result, carry, overflo, reg, incby, '0');
                                  IF (overflo /= '0') THEN
                                    ASSERT  NOT WarningsOn
                                    REPORT " RegInc (BitVector case) --- Unsigned overflow "
                                    SEVERITY WARNING;
                                  END IF;

            WHEN SignMagnitude => AddSub_SignMagnitude(result, carry, overflo, reg, incby, '0');
                                  IF (overflo /= '0') THEN
                                    ASSERT  NOT WarningsOn
                                    REPORT " RegInc (BitVector case) --- SignMagnitude overflow "
                                    SEVERITY WARNING;
                                  END IF;
            WHEN OTHERS       =>  NULL;
         END CASE;
       END IF;
    -- That's all
      RETURN result;
    END;
 
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
                      ) RETURN std_logic_vector IS
      VARIABLE  reslen : INTEGER := SrcReg'LENGTH;
      VARIABLE result  : std_logic_vector(reslen - 1 DOWNTO 0);
      VARIABLE reg     : std_logic_vector(reslen - 1 DOWNTO 0) := SrcReg;
      VARIABLE incby   : std_logic_vector(reslen - 1 DOWNTO 0) := (OTHERS => '0');
      VARIABLE overflo : std_ulogic;
      VARIABLE carry   : std_ulogic;
    BEGIN
    --  if input source register has null range then 
       IF (SrcReg'LENGTH = 0) THEN
          result := reg;
          ASSERT FALSE
          REPORT " RegInc --- Source register has null range "
          SEVERITY ERROR;
       ELSE 
       --  increment by 1
          incby(0) := '1';

          CASE SrcRegMode is
            WHEN TwosComp  =>  Add_TwosComp(result, carry, overflo, reg, incby, '0');
                            IF (overflo /= '0') THEN
                                ASSERT  NOT WarningsOn
                                REPORT " RegInc (Std_Logic_Vector case) --- TwosComp overflow "
                                SEVERITY WARNING;
                            END IF;

            WHEN OnesComp   => AddSub_OnesComp(result, carry, overflo, reg, incby, '0');
                            IF (overflo /= '0') THEN
                                ASSERT  NOT WarningsOn
                                REPORT " RegInc (std_logic_vector case) --- OnesComp overflow "
                                SEVERITY WARNING;
                            END IF;

            WHEN Unsigned   =>  Add_Unsigned(result, carry, overflo, reg, incby, '0');
                            IF (overflo /= '0') THEN
                                ASSERT  NOT WarningsOn
                                REPORT " RegInc  (std_logic_vector case) --- Unsigned overflow "
                                SEVERITY WARNING;
                            END IF;

            WHEN SignMagnitude => AddSub_SignMagnitude(result, carry, overflo, reg, incby, '0');
                           IF (overflo /= '0') THEN
                                ASSERT   NOT WarningsOn
                                REPORT " RegInc (std_logic_Vector case) --- SignMagnitude overflow "
                                SEVERITY WARNING;
                           END IF;
 
            WHEN OTHERS      =>  NULL;
          END CASE;
       END IF;
     -- convert to X01
      result := To_X01(result);
 
   -- That's all
     RETURN result;
    END;
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
                      ) RETURN std_ulogic_vector IS
      VARIABLE  reslen : INTEGER := SrcReg'LENGTH;
      VARIABLE result  : std_ulogic_vector(reslen - 1 DOWNTO 0);
      VARIABLE reg     : std_ulogic_vector(reslen - 1 DOWNTO 0) := SrcReg;
      VARIABLE incby   : std_ulogic_vector(reslen - 1 DOWNTO 0) := (OTHERS => '0');
      VARIABLE overflo : std_ulogic;
      VARIABLE carry   : std_ulogic;
    BEGIN
    --  if input source register has null range then 
       IF (SrcReg'LENGTH = 0) THEN
          result := reg;
          ASSERT FALSE
          REPORT " RegInc --- Source register has null range "
          SEVERITY ERROR;
       ELSE 
       --  increment by 1
          incby(0) := '1';

          CASE SrcRegMode is
            WHEN TwosComp => Add_TwosComp(result, carry, overflo, reg, incby, '0');
                            IF (overflo /= '0') THEN
                                ASSERT  NOT WarningsOn
                                REPORT " RegInc (std_ulogic_Vector case) --- TwosComp overflow "
                                SEVERITY WARNING;
                            END IF;

            WHEN OnesComp => AddSub_OnesComp(result, carry, overflo, reg, incby, '0');
                            IF (overflo /= '0') THEN
                                ASSERT  NOT WarningsOn
                                REPORT " RegInc (std_ulogic_Vector case)--- OnesComp overflow "
                                SEVERITY WARNING;
                            END IF;

            WHEN Unsigned =>  Add_Unsigned(result, carry, overflo, reg, incby, '0');
                            IF (overflo /= '0') THEN
                                ASSERT  NOT WarningsOn
                                REPORT " RegInc (std_ulogic_Vector case)--- Unsigned overflow "
                                SEVERITY WARNING;
                            END IF;

            WHEN SignMagnitude  => AddSub_SignMagnitude(result, carry, overflo, reg, incby, '0');
                            IF (overflo /= '0') THEN
                                ASSERT   NOT WarningsOn
                                REPORT " RegInc (std_ulogic_Vector case)--- SignMagnitude overflow "
                                SEVERITY WARNING;
                            END IF;
 
            WHEN OTHERS         =>    NULL;
          END CASE;
       END IF;
     -- convert to X01
      result := To_X01(result);
 
   -- That's all
     RETURN result;
   END;
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
                     ) RETURN BIT_VECTOR IS
      VARIABLE reslen    : INTEGER := SrcReg'LENGTH;
      VARIABLE result    : BIT_VECTOR(reslen - 1 DOWNTO 0);
      VARIABLE reg       : BIT_VECTOR(reslen - 1 DOWNTO 0) := SrcReg;
      VARIABLE decby     : BIT_VECTOR(reslen - 1 DOWNTO 0) := (OTHERS => '0');
      VARIABLE underflow : BIT;
      VARIABLE borrow    : BIT;
    BEGIN
    --  if input source register has null range then 
       IF (SrcReg'LENGTH = 0) THEN
          result := reg;
          ASSERT FALSE
          REPORT " RegDec --- Source register has null range "
          SEVERITY ERROR;

       ELSE 
       --  decrement by 1
         decby(0) := '1';
 
        CASE SrcRegMode is
           WHEN TwosComp  => Sub_TwosComp(result, borrow, underflow, reg, decby, '0');
                         IF (underflow /='0') THEN 
                             ASSERT NOT WarningsOn
                             REPORT " RegDec (BitVector case) --- TwosComp underflow " 
                             SEVERITY WARNING;
                         END IF;  

          WHEN OnesComp => AddSub_OnesComp(result, borrow, underflow, reg, decby, '1');
                         IF (underflow /='0') THEN 
                             ASSERT NOT WarningsOn
                             REPORT " RegDec (BitVector case) --- OnesComp underflow " 
                             SEVERITY WARNING;
                         END IF;  

          WHEN Unsigned => Sub_Unsigned(result, borrow, underflow, reg, decby, '0');
                         IF (underflow /='0') THEN 
                             ASSERT NOT WarningsOn
                             REPORT " RegDec  (BitVector case)--- Unsigned underflow " 
                             SEVERITY WARNING;
                         END IF;  

         WHEN SignMagnitude => AddSub_SignMagnitude(result, borrow, underflow, reg, decby, '1');
                         IF (underflow /='0') THEN 
                             ASSERT NOT WarningsOn
                             REPORT " RegDec (BitVector case) --- SignMagnitude underflow " 
                             SEVERITY WARNING;
                         END IF;  

         WHEN OTHERS       =>  NULL;
        END CASE;
     END IF;
  
  -- That's all
    RETURN result;
  END;

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
                      ) RETURN std_logic_vector IS
      VARIABLE  reslen   : INTEGER := SrcReg'LENGTH;
      VARIABLE result    : std_logic_vector(reslen - 1 DOWNTO 0);
      VARIABLE  reg      : std_logic_vector(reslen - 1 DOWNTO 0) := SrcReg;
      VARIABLE decby     : std_logic_vector(reslen - 1 DOWNTO 0) := (OTHERS => '0');
      VARIABLE underflow : std_ulogic;
      VARIABLE borrow    : std_ulogic;
    
    BEGIN
    --  if input source register has null range then 
       IF (SrcReg'LENGTH = 0) THEN
          result := reg;
          ASSERT FALSE
          REPORT " RegDec --- Source register has null range "
          SEVERITY ERROR;
       ELSE 
       --  decrement by 1
          decby(0) := '1';
 
          CASE SrcRegMode is
            WHEN TwosComp  => Sub_TwosComp(result, borrow, underflow, reg, decby, '0');
                         IF (underflow /='0') THEN 
                             ASSERT NOT WarningsOn
                             REPORT " RegDec (std_logic_Vector case) --- TwosComp underflow " 
                             SEVERITY WARNING;
                         END IF;  

            WHEN OnesComp  =>  AddSub_OnesComp(result, borrow, underflow, reg, decby, '1');
                         IF (underflow /='0') THEN 
                             ASSERT NOT WarningsOn
                             REPORT " RegDec (std_logic_Vector case) --- OnesComp underflow " 
                             SEVERITY WARNING;
                         END IF;  

            WHEN Unsigned  => Sub_Unsigned(result, borrow, underflow, reg, decby, '0');
                         IF (underflow /='0') THEN 
                             ASSERT NOT WarningsOn
                             REPORT " RegDec (std_logic_Vector case)--- Unsigned underflow " 
                             SEVERITY WARNING;
                         END IF;  

            WHEN SignMagnitude =>  AddSub_SignMagnitude(result, borrow, underflow, reg, decby, '1');
                         IF (underflow /='0') THEN 
                             ASSERT NOT WarningsOn
                             REPORT " RegDec (std_logic_Vector case)--- SignMagnitude underflow " 
                             SEVERITY WARNING;
                         END IF;  

            WHEN OTHERS       =>   NULL;
         END CASE;
      END IF;
      -- convert to X01
       result := To_X01(result);
  
    -- That's all
      RETURN result;
    END;

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
                      ) RETURN std_ulogic_vector IS
      VARIABLE  reslen   : INTEGER := SrcReg'LENGTH;
      VARIABLE result    : std_ulogic_vector(reslen - 1 DOWNTO 0);
      VARIABLE  reg      : std_ulogic_vector(reslen - 1 DOWNTO 0) := SrcReg;
      VARIABLE decby     : std_ulogic_vector(reslen - 1 DOWNTO 0) := (OTHERS => '0');
      VARIABLE underflow : std_ulogic;
      VARIABLE borrow    : std_ulogic;
    
    BEGIN
    --  if input source register has null range then 
       IF (SrcReg'LENGTH = 0) THEN
          result := reg;
          ASSERT FALSE
          REPORT " RegDec --- Source register has null range "
          SEVERITY ERROR;
       ELSE 
       --  decrement by 1
          decby(0) := '1';
 
          CASE SrcRegMode is
            WHEN TwosComp   => Sub_TwosComp(result, borrow, underflow, reg, decby, '0');
                         IF (underflow /='0') THEN 
                             ASSERT NOT WarningsOn
                             REPORT " RegDec (std_ulogic_Vector case) --- TwosComp underflow " 
                             SEVERITY WARNING;
                         END IF;  

            WHEN OnesComp   =>  AddSub_OnesComp(result, borrow, underflow, reg, decby, '1');
                         IF (underflow /='0') THEN 
                             ASSERT NOT WarningsOn
                             REPORT " RegDec (std_ulogic_Vector case)--- OnesComp underflow " 
                             SEVERITY WARNING;
                         END IF;  

            WHEN Unsigned  => Sub_Unsigned(result, borrow, underflow, reg, decby, '0');
                         IF (underflow /='0') THEN 
                             ASSERT NOT WarningsOn
                             REPORT " RegDec (std_ulogic_Vector case)--- Unsigned underflow " 
                             SEVERITY WARNING;
                         END IF;  

            WHEN SignMagnitude => AddSub_SignMagnitude(result, borrow, underflow, reg, decby, '1');
                         IF (underflow /='0') THEN 
                             ASSERT NOT WarningsOn
                             REPORT " RegDec (std_ulogic_Vector case)--- SignMagnitude underflow " 
                             SEVERITY WARNING;
                         END IF;  

            WHEN OTHERS        =>  NULL;
         END CASE;
      END IF;
      -- convert to X01
       result := To_X01(result);
  
    -- That's all
      RETURN result;
    END;
 
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
                        ) RETURN BIT_VECTOR IS
      CONSTANT reslen : INTEGER := SrcReg'LENGTH; 
      VARIABLE result : BIT_VECTOR(reslen - 1 DOWNTO 0);
      VARIABLE reg    : BIT_VECTOR(reslen - 1 DOWNTO 0)  := SrcReg; 
    BEGIN
    -- check for null range of SrcReg 
      IF (SrcReg'LENGTH = 0) THEN
          result := reg;
         ASSERT false
          REPORT " RegNegate --- source register has null range "
          SEVERITY ERROR; 
      ELSIF (SrcRegMode = SignMagnitude) THEN
          result := reg;
          result(reslen - 1) := NOT reg(reslen - 1);  -- complement the sign bit
      ELSE
    -- Complement each bit
        result := NOT reg;

        CASE SrcRegMode IS
          WHEN TwosComp    =>   -- want to incrment by 1 
                               result := RegInc(result, TwosComp);
                        
          WHEN OnesComp    => -- bitwise complement is all that's needed.
                               NULL;

          WHEN SignMagnitude  => -- can't happen: computed above.
                                 NULL;
 
          WHEN unsigned       =>  -- In some ways this is an error, however,
                                  -- taking a more general interpretation of
                                  -- "negation", use the bitwise "complement".
                                  NULL;

          WHEN OTHERS          =>   ASSERT FALSE
                                    REPORT " RegNegate - Unknown vector mode **"
                                    SEVERITY ERROR;
        END CASE;
       END IF;
     -- That's all
      RETURN result;
    END;
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
                         ) RETURN std_logic_vector IS
      CONSTANT reslen : INTEGER := SrcReg'LENGTH;
      VARIABLE result : std_logic_vector(reslen - 1 DOWNTO 0);
      VARIABLE reg    : std_logic_vector(reslen - 1 DOWNTO 0)  := SrcReg;
    BEGIN
    -- check for null range of SrcReg
      IF (SrcReg'LENGTH = 0) THEN
          result := reg;
          ASSERT false
          REPORT " RegNegate --- source register has null range "
          SEVERITY ERROR;
      ELSIF (SrcRegMode = SignMagnitude) THEN
          result := reg;
          result(reslen - 1) := NOT reg(reslen - 1);  -- complement the sign bit
      ELSE
    -- Complement each bit
        result := NOT reg;
 
        CASE SrcRegMode IS
          WHEN TwosComp     =>  -- add one to the complement
                               result := RegInc(result, TwosComp);
          WHEN OnesComp     =>  -- bitwise complement is all that's needed.
                               NULL;
        
          WHEN SignMagnitude => -- can't happen: computed above.
                               NULL;

          WHEN unsigned      => -- In some ways this is and error, however,
                                -- taking a more general interpretation of
                                -- "negation", use the bitwise "complement".
                                NULL;
          WHEN OTHERS        =>  -- An unknown SrcRegMode value was passed
                                 ASSERT FALSE 
                                 REPORT " RegNegate - Unknown vector mode **"
                                SEVERITY ERROR;
        END CASE;
      END IF;
    -- convert to X01
      result := To_X01(result);
    -- That's all
      RETURN result;
    END;
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
                         ) RETURN std_ulogic_vector IS
      CONSTANT reslen : INTEGER := SrcReg'LENGTH;
      VARIABLE result : std_ulogic_vector(reslen - 1 DOWNTO 0);
      VARIABLE reg    : std_ulogic_vector(reslen - 1 DOWNTO 0)  := SrcReg;
    BEGIN
    -- check for null range of SrcReg
      IF (SrcReg'LENGTH = 0) THEN
          result := reg;
          ASSERT false
          REPORT " RegNegate --- source register has null range "
          SEVERITY ERROR;
      ELSIF (SrcRegMode = SignMagnitude) THEN
          result := reg;
          result(reslen - 1) := NOT reg(reslen - 1);  -- complement the sign bit
      ELSE
    -- Complement each bit
        result := NOT reg;
 
        CASE SrcRegMode IS
          WHEN TwosComp     =>  -- add one to the complement
                               result := RegInc(result, TwosComp);

          WHEN OnesComp     =>  -- bitwise complement is all that's needed.
                                NULL;

          WHEN SignMagnitude => -- can't happen: computed above.
                                NULL;

          WHEN unsigned      => -- In some ways this is and error, however,
                                -- taking a more general interpretation of
                                -- "negation", use the bitwise "complement".
                               NULL;

          WHEN OTHERS        =>   -- An unknown SrcRegMode value was passed
                               ASSERT FALSE 
                               REPORT " RegNegate - Unknown vector mode **"
                              SEVERITY ERROR;
        END CASE;
      END IF;
    -- convert to X01
      result := To_X01(result);
   -- That's all
      RETURN result;
    END;
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
                      ) IS
       VARIABLE reglen       : INTEGER := SrcReg'LENGTH;
       variable result_copy  : std_logic_vector (result'LENGTH - 1 DOWNTO 0);
       variable reg          : std_logic_vector (reglen - 1 DOWNTO 0);
    --
    BEGIN
	result_copy := result;
    --
    --   Null range check
    --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregAbs ---  Destination has null range. "
             SEVERITY ERROR;
             RETURN;
       END IF;
    
     -- if the input is of null range 
       IF (SrcReg'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregAbs --- input has null range "
             SEVERITY ERROR;
             result_copy := (OTHERS => '0');
             result <= result_copy after DefaultSregDelay;
             RETURN;
             
       ELSE
            reg := SrcReg;
            CASE SrcRegMode IS

               WHEN TwosComp   => -- if a negative value, take two's comp it
                                   -- will become absolute
                                IF (reg(reglen - 1) /= '0') THEN
                                    -- if not largest negative number
                                    IF ( No_One(reg(reglen - 2 downto 0))) THEN
                                        ASSERT false
                                        REPORT " SregAbs  --  2's comp std_logic_vector   (" & TO_String(reg) 
                                         & ")   cannot be converted.  "
                                        SEVERITY Error;   
                                        reg := Propagate_X(reg);
                                    ELSE
                                        reg := RegNegate ( reg, TwosComp);
                                    END IF;
                                END IF;

              WHEN OnesComp
                           =>
                           -- if a negative value, take RegNegate
                           -- it will become absolute.
                             IF (reg(reglen - 1) /= '0') THEN
                                reg := RegNegate (reg, OnesComp);
                             END IF;
 
              WHEN SignMagnitude
                           =>
                           -- if a negative value, clear the sign bit (forming
                           -- the absolute)
                             IF (reg(reglen - 1) /= '0') THEN
                                reg(reglen - 1) := '0';
                             END IF;
 
               WHEN unsigned
                             =>
                            --  no translation required.
                             NULL;
               WHEN OTHERS
                             =>
                             -- An unknown SrcRegMode value was passed
                               ASSERT FALSE
                               REPORT "RegAbs - Unknown vector mode"
                               SEVERITY ERROR;
          END CASE;
       END IF;
   
       IF (result'LENGTH < reglen) THEN
              ASSERT NOT WarningsOn
              REPORT " SregAbs --- Destination Length smaller than the " &
                       " source length   "
              SEVERITY WARNING;
       ELSIF ( result'LENGTH > reglen ) THEN
              ASSERT NOT WarningsOn
              REPORT " SregAbs --- Destination Length larger than the " &
                       " source length. "
              SEVERITY WARNING;
       END IF;

       reglen := MINIMUM (reglen, result'LENGTH);
       result_copy ( reglen - 1 downto 0 ) := To_X01(reg ( reglen - 1 downto 0 ));
       result <= result_copy after DefaultSregDelay;

       RETURN;
    END;

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
                      ) IS
       VARIABLE reglen       : INTEGER := SrcReg'LENGTH;
       VARIABLE reslt_copy   : std_ulogic_vector (result'LENGTH - 1 DOWNTO 0);
       VARIABLE reg          : std_ulogic_vector (reglen - 1 DOWNTO 0);
    --
    BEGIN
	reslt_copy := result;
    --
    --   Null range check
    --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregAbs ---  Destination has null range. "
             SEVERITY ERROR;
             RETURN;
       END IF;
    
     -- if the input is of null range 
       IF (SrcReg'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregAbs --- input has null range "
             SEVERITY ERROR;
             reslt_copy := (OTHERS => '0');
             result <= reslt_copy after DefaultSregDelay;
             RETURN;
             
       ELSE
            reg := SrcReg;
            CASE SrcRegMode IS
               WHEN TwosComp   => -- if a negative value, take two's comp it
                                   -- will become absolute
                                IF (reg(reglen - 1) /= '0') THEN
                                    -- if not largest negative number
                                    IF ( No_One(reg(reglen - 2 downto 0))) THEN
                                        ASSERT false
                                        REPORT "SregAbs  --  2's comp std_ulogic_vector   (" & TO_String(reg) 
                                         & ")   cannot be converted. "
                                        SEVERITY Error;   
                                        reg := Propagate_X(reg);
                                     ELSE   
                                        reg := RegNegate ( reg, TwosComp);
                                     END IF;
                                END IF;

              WHEN OnesComp    =>  -- if a negative value, take RegNegate
                                   -- it will become absolute.
                                  IF (reg(reglen - 1) /= '0') THEN
                                      reg := RegNegate (reg, OnesComp);
                                  END IF;
 
              WHEN SignMagnitude
                           =>
                           -- if a negative value, clear the sign bit (forming
                           -- the absolute)
                             IF (reg(reglen - 1) /= '0') THEN
                                reg(reglen - 1) := '0';
                             END IF;
 
               WHEN unsigned
                             =>
                            --  no translation required.
                             NULL;
               WHEN OTHERS
                             =>
                             -- An unknown SrcRegMode value was passed
                               ASSERT FALSE
                               REPORT "RegAbs - Unknown vector mode"
                               SEVERITY ERROR;
          END CASE;
       END IF;
   
       IF (result'LENGTH < reglen) THEN
              ASSERT NOT WarningsOn
              REPORT " SregAbs --- Destination Length smaller than the " &
                       " source length   "
              SEVERITY WARNING;
       ELSIF ( result'LENGTH > reglen ) THEN
              ASSERT NOT WarningsOn
              REPORT " SregAbs --- Destination Length larger than the " &
                       " source length. "
              SEVERITY WARNING;
       END IF;

       reglen := MINIMUM (reglen, result'LENGTH);
       reslt_copy ( reglen - 1 downto 0 ) := To_X01(reg ( reglen-1 downto 0 ));
       result <= reslt_copy after DefaultSregDelay;
       RETURN;
    END;
    
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
                      ) IS
    VARIABLE reglen       : INTEGER := SrcReg'LENGTH;
    VARIABLE result_copy  : BIT_VECTOR (result'LENGTH - 1 DOWNTO 0);
    VARIABLE reg          : BIT_VECTOR (reglen - 1 DOWNTO 0);
    --
    BEGIN
	result_copy := result;
    --
    --  Null range check
    --  if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregAbs ---  Destination has null range. "
             SEVERITY ERROR;
             RETURN;
       END IF;

    --  if the input is of null range 
       IF (SrcReg'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregAbs --- input has null range "
             SEVERITY ERROR;
             result_copy := (OTHERS => '0');
             result <= result_copy after DefaultSregDelay;
             RETURN;
             
       ELSE
            reg := SrcReg;
            CASE SrcRegMode IS
               WHEN TwosComp   => -- if a negative value, take two's comp it
                                   -- will become absolute
                                IF (reg(reglen - 1) /= '0') THEN
                                    -- if not largest negative number
                                    IF ( No_One(reg(reglen - 2 downto 0))) THEN
                                        ASSERT false
                                        REPORT "SregAbs  --  2's comp bit_vector   (" & TO_String(reg) 
                                         & ")   cannot be converted.  "
                                        SEVERITY Error;   
                                    ELSE
                                        reg := RegNegate ( reg, TwosComp);
                                    END IF;
                                END IF;

                WHEN OnesComp
                             =>
                             -- if a negative value, take RegNegate
                             -- it will become absolute.
                               IF (reg(reglen - 1) /= '0') THEN
                                  reg := RegNegate (reg, OnesComp);
                               END IF;
 
                WHEN SignMagnitude
                              =>
                             -- if a negative value, clear the sign bit (forming
                             -- the absolute)
                               IF (reg(reglen - 1) /= '0') THEN
                                  reg(reglen - 1) := '0';
                               END IF;
 
                WHEN unsigned
                              =>
                              --  no translation required.
                              NULL;
                WHEN OTHERS
                              =>
                             -- An unknown SrcRegMode value was passed
                              ASSERT FALSE
                              REPORT "RegAbs - Unknown vector mode"
                              SEVERITY ERROR;
            END CASE;
       END IF;  

       IF (result'LENGTH < reglen) THEN
              ASSERT NOT WarningsOn
              REPORT " SregAbs --- Destination Length smaller than the " &
                       " source length   "
              SEVERITY WARNING;
       ELSIF ( result'LENGTH > reglen ) THEN
              ASSERT NOT WarningsOn
              REPORT " SregAbs --- Destination Length larger than the " &
                       " source length. "
              SEVERITY WARNING;
       END IF;

       reglen := MINIMUM (reglen, result'LENGTH);
       result_copy ( reglen - 1 downto 0 ) := reg ( reglen - 1 downto 0 );
       result <= result_copy after DefaultSregDelay;

       RETURN;
    END;
 
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
                      ) IS
      VARIABLE reslen       : INTEGER := MAXIMUM ( addend'LENGTH, augend'LENGTH );
      VARIABLE a, b, r      : BIT_VECTOR ( reslen - 1 DOWNTO 0 );
      VARIABLE result_copy  : BIT_VECTOR ( result'length-1 downto 0 );
      VARIABLE carry_loc    : BIT; 
      VARIABLE overflow_loc : BIT;
      VARIABLE reslen2      : INTEGER;

     BEGIN 
	result_copy := result;
     --  
     --   Null range check
     --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregAdd ---  Destination has null range. "
             SEVERITY ERROR;
             RETURN;
     --   if addend or augned or both have null range no need to add
       ELSIF (addend'LENGTH = 0) AND (augend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregAdd --- both addend  and augend has null range "
             SEVERITY ERROR;
             result_copy :=  (OTHERS => '0');
             IF (carry_in = '1') THEN
                 IF (SrcRegMode = TwosComp OR SrcRegMode = Unsigned) THEN
                        result_copy(0) := '1';
                 END IF;
             END IF;
             result <= result_copy after DefaultSregDelay; 
             carry_out <= '0' after DefaultSregDelay;
             overflow <= '0'  after DefaultSregDelay;       
             RETURN;      
       END IF;

     -- if one of the addend or augend is null 
       IF (addend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregAdd --- addend has null range "
             SEVERITY ERROR;
             a :=  ( OTHERS => '0');     -- treat it as	zero's            
             b := augend;

       ELSIF (augend'LENGTH = 0) THEN 
             ASSERT false
             REPORT " SregAdd ---  augend has null range "
             SEVERITY ERROR;
             b :=  (OTHERS => '0');                 
             a := addend;
              
                 -- inputs are  not null so sign extend them to the same length.  
       ELSE
             a := SignExtend(addend , reslen, addend'LEFT, SrcRegMode);
             b := SignExtend(augend , reslen, augend'LEFT, SrcRegMode);

       END IF;	

     -- Perform addition operation.
     --
       CASE SrcRegMode IS
               WHEN TwosComp
                        => 
                          Add_TwosComp(r,carry_loc, overflow_loc,a, b, carry_in); 
         
               WHEN OnesComp 
                         =>
                         -- ignore carry_in istead pass mode M as '0'
                          AddSub_OnesComp(r, carry_loc,overflow_loc,a,b, '0');
        
               WHEN SignMagnitude 
                          =>
                         -- ignore carry_in istead pass mode M as '0'
                           AddSub_SignMagnitude(r, carry_loc, overflow_loc, a, b, '0');
        
               WHEN Unsigned 
                          =>
                           Add_Unsigned(r, carry_loc,overflow_loc, a, b, carry_in);
                 
               WHEN OTHERS 
                          =>
                           ASSERT FALSE
                           REPORT " SregAdd ---- Unknown mode was passed "
                           SEVERITY ERROR;
       END CASE;
         
       IF (result'LENGTH < reslen) THEN
              ASSERT NOT WarningsOn  
              REPORT " SregAdd --- Destination Length smaller than the " &
                       " calculated value. "
              SEVERITY WARNING;
       ELSIF ( result'LENGTH > reslen ) THEN
              ASSERT NOT WarningsOn  
              REPORT " SregAdd --- Destination Length larger than the " &
                       " calculated value. "
              SEVERITY WARNING;
       END IF; 

       reslen2 := MINIMUM ( reslen, result'length );
       result_copy (reslen2 - 1 downto 0 ) := r (reslen2 - 1 downto 0);
       result <= result_copy after DefaultSregDelay;
       carry_out <= carry_loc after DefaultSregDelay;
       overflow <= overflow_loc after DefaultSregDelay;		

     -- That's all
       RETURN;
     END;

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
                      ) IS
      VARIABLE reslen       : INTEGER := MAXIMUM ( addend'LENGTH, augend'LENGTH );
      VARIABLE a, b, r      : std_logic_vector ( reslen - 1 DOWNTO 0 );
      VARIABLE reslt_copy   : std_logic_vector ( result'length-1 downto 0 );
      VARIABLE carry_loc    : std_ulogic; 
      VARIABLE overflow_loc : std_ulogic;
      VARIABLE reslen2      : INTEGER;
     BEGIN
	reslt_copy := result;
     --  
     --   Null range check
     --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregAdd ---  Destination has null range. " &
                    " cannot save result. "
             SEVERITY ERROR;
             RETURN;
     --   if addend or augned or both have null range no need to add
       ELSIF (addend'LENGTH = 0) AND (augend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregAdd --- both addend  and augend has null range "
             SEVERITY ERROR;
             reslt_copy :=  (OTHERS => '0');
             IF (carry_in = '1') THEN
                 IF (SrcRegMode = TwosComp OR SrcRegMode = Unsigned) THEN
                        reslt_copy(0) := '1';
                 END IF;
             END IF;
             result <= reslt_copy after DefaultSregDelay; 
             carry_out <= '0' after DefaultSregDelay;
             overflow <= '0' after DefaultSregDelay;       
             RETURN;      
       END IF;

     -- if one of the addend or augend is null 
       IF (addend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregAdd --- addend has null range "
             SEVERITY ERROR;
             a :=  ( OTHERS => '0');     -- treat it as	zero's            
             b := augend;

       ELSIF (augend'LENGTH = 0) THEN 
             ASSERT false
             REPORT " SregAdd ---  augend has null range "
             SEVERITY ERROR;
             b :=  (OTHERS => '0');           -- treat augend as zero      
             a := addend;
              
                 -- inputs are  not null so sign extend them to the same length.  
       ELSE
             a := SignExtend(addend, reslen, addend'LEFT, SrcRegMode);
             b := SignExtend(augend, reslen, augend'LEFT, SrcRegMode);

       END IF;	

     -- Perform addition operation.
       CASE SrcRegMode IS
               WHEN TwosComp
                        => 
                          Add_TwosComp(r,carry_loc, overflow_loc,a,b, carry_in); 
         
               WHEN OnesComp 
                         =>
                         -- ignore carry_in istead pass mode M as '0'
                          AddSub_OnesComp(r, carry_loc,overflow_loc,a,b, '0');
        
               WHEN SignMagnitude 
                          =>
                         -- ignore carry_in istead pass mode M as '0'
                           AddSub_SignMagnitude(r, carry_loc, overflow_loc, a, b, '0');
        
               WHEN Unsigned 
                          =>
                           Add_Unsigned(r, carry_loc,overflow_loc, a, b, carry_in);
                 
               WHEN OTHERS 
                          =>
                           ASSERT FALSE
                           REPORT " RegAdd ---- Unknown mode was passed "
                           SEVERITY ERROR;
       END CASE;
         
       IF (result'LENGTH < reslen) THEN
              ASSERT NOT WarningsOn  
              REPORT " RegAdd --- Destination Length smaller than the " &
                       " calculated value. "
              SEVERITY WARNING;
       ELSIF ( result'LENGTH > reslen ) THEN
              ASSERT NOT WarningsOn  
              REPORT " RegAdd --- Destination Length larger than the " &
                       " calculated value. "
              SEVERITY WARNING;
       END IF; 

       reslen2 := MINIMUM ( reslen, result'length );
       reslt_copy ( reslen2-1 downto 0 ) := To_X01(r ( reslen2-1 downto 0 ));
       result <= reslt_copy after DefaultSregDelay;
       carry_out <= To_X01(carry_loc) after DefaultSregDelay;
       overflow <= To_X01(overflow_loc) after DefaultSregDelay;

     -- That's all
       RETURN;
     END;

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
                      ) IS
      VARIABLE reslen       : INTEGER := MAXIMUM ( addend'LENGTH, augend'LENGTH );
      VARIABLE a, b, r      : std_ulogic_vector ( reslen - 1 DOWNTO 0 );
      VARIABLE result_copy  : std_ulogic_vector ( result'length-1 downto 0 );
      VARIABLE carry_loc    : std_ulogic; 
      VARIABLE overflow_loc : std_ulogic;
      VARIABLE reslen2      : INTEGER;

     BEGIN
	result_copy := result;
     --  
     --   Null range check
     --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregAdd ---  Destination has null range. " &
                    " cannot save result. "
             SEVERITY ERROR;
             RETURN;
     --   if addend or augned or both have null range no need to add
       ELSIF (addend'LENGTH = 0) AND (augend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregAdd --- both addend  and augend has null range "
             SEVERITY ERROR;
             result_copy :=  (OTHERS => '0');
             IF (carry_in = '1') THEN
                 IF (SrcRegMode = TwosComp OR SrcRegMode = Unsigned) THEN
                        result_copy(0) := '1';
                 END IF;
             END IF;
             result <= result_copy after DefaultSregDelay; 
             carry_out <= '0' after DefaultSregDelay;
             overflow <= '0' after DefaultSregDelay;       
             RETURN;      
       END IF;

     -- if one of the addend or augend is null 
       IF (addend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregAdd --- addend has null range "
             SEVERITY ERROR;
             a :=  ( OTHERS => '0');     -- treat it as	zero's            
             b := augend;

       ELSIF (augend'LENGTH = 0) THEN 
             ASSERT false
             REPORT " SregAdd ---  augend has null range "
             SEVERITY ERROR;
             b :=  (OTHERS => '0');           -- treat augend as zero      
             a := addend;
              
                 -- inputs are  not null so sign extend them to the same length.  
       ELSE
             a := SignExtend(addend, reslen, addend'LEFT, SrcRegMode);
             b := SignExtend(augend, reslen, augend'LEFT, SrcRegMode);

       END IF;	

     -- Perform addition operation.
       CASE SrcRegMode IS
               WHEN TwosComp
                        => 
                          Add_TwosComp(r,carry_loc, overflow_loc,a,b, carry_in); 
         
               WHEN OnesComp 
                         =>
                         -- ignore carry_in istead pass mode M as '0'
                          AddSub_OnesComp(r, carry_loc,overflow_loc,a,b, '0');
        
               WHEN SignMagnitude 
                          =>
                         -- ignore carry_in istead pass mode M as '0'
                           AddSub_SignMagnitude(r, carry_loc, overflow_loc, a, b, '0');
        
               WHEN Unsigned 
                          =>
                           Add_Unsigned(r, carry_loc,overflow_loc, a, b, carry_in);
                 
               WHEN OTHERS 
                          =>
                           ASSERT FALSE
                           REPORT " SregAdd ---- Unknown mode was passed "
                           SEVERITY ERROR;
       END CASE;
         
       IF (result'LENGTH < reslen) THEN
              ASSERT NOT WarningsOn  
              REPORT " SregAdd --- Destination Length smaller than the " &
                       " calculated value. "
              SEVERITY WARNING;
       ELSIF ( result'LENGTH > reslen ) THEN
              ASSERT NOT WarningsOn  
              REPORT " SregAdd --- Destination Length larger than the " &
                       " calculated value. "
              SEVERITY WARNING;
       END IF; 

       reslen2 := MINIMUM ( reslen, result'length );
       result_copy ( reslen2-1 downto 0 ) := To_X01(r ( reslen2-1 downto 0 ));
       result <= result_copy after DefaultSregDelay;
       carry_out <= To_X01(carry_loc) after DefaultSregDelay;
       overflow <= To_X01(overflow_loc) after DefaultSregDelay;

     -- That's all
       RETURN;
     END;

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
                      ) IS
      VARIABLE reslen       : INTEGER := MAXIMUM (minuend'LENGTH, subtrahend'LENGTH);
      VARIABLE a, b, r      : BIT_VECTOR ( reslen - 1 DOWNTO 0 );
      VARIABLE carry_o      : BIT;
      VARIABLE reslt_copy   : BIT_VECTOR ( result'length-1 downto 0 ); 
      VARIABLE borrow_loc   : BIT;
      VARIABLE overflow_loc : BIT;
      VARIABLE reslen2      : INTEGER;

    BEGIN
	reslt_copy := result;
     -- 
     --   Null range check
     --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregSub ---  Destination has null range. " &
                    " cannot save result. "
             SEVERITY ERROR;
             RETURN;

     --   if both minuend and subtrahend  have null range no need to subtract
       ELSIF  (minuend'LENGTH = 0) AND (subtrahend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregSub --- both minuend and subtrahend has null range "
             SEVERITY ERROR;
             reslt_copy :=  (OTHERS => '0');
             borrow_out <= '0' after DefaultSregDelay;
             IF (borrow_in /= '0') THEN
                 IF (SrcRegMode = TwosComp OR SrcRegMode = Unsigned) THEN
                        reslt_copy := (OTHERS =>'1');
                        borrow_out <= '1' after DefaultSregDelay;
                 END IF;
             END IF;
             result <= reslt_copy after DefaultSregDelay;
             overflow <= '0' after DefaultSregDelay;
             RETURN;
       END IF;
 
     -- if one of the minuend or subtrahend is null
       IF (minuend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregSub --- minuend has null range "
             SEVERITY ERROR;
             a :=  ( OTHERS => '0');     -- treat it as zero's
             b :=  subtrahend ;
 
       ELSIF (subtrahend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregSub ---  subtrahend has null range "
             SEVERITY ERROR;
             b :=  (OTHERS => '0');
             a := minuend ;
  
                 -- inputs are  not null so sign extend them to the same length.
       ELSE
             a := SignExtend(minuend , reslen, minuend'LEFT, SrcRegMode);
             b := SignExtend(subtrahend , reslen, subtrahend'LEFT, SrcRegMode);
 
       END IF;

 
       CASE SrcRegMode IS
            WHEN TwosComp
                        =>
                           Sub_TwosComp(r,borrow_loc, overflow_loc,
                                                               a,b, borrow_in);
       
            WHEN OnesComp
                         =>
                           -- ignore borrow istead pass mode M as '1'
                            AddSub_OnesComp(r, carry_o,overflow_loc,
                                                                  a,b, '1');
                            borrow_loc := NOT carry_o;
       
            WHEN SignMagnitude
                          =>
                           -- ignore borrow_in istead pass mode M as '1'
                           AddSub_SignMagnitude(r, borrow_loc, overflow_loc,
                                                                         a,b, '1');
       
            WHEN Unsigned
                          =>
                           Sub_Unsigned(r, borrow_loc,overflow_loc,
                                                           a,b, borrow_in);
            WHEN OTHERS
                          =>
                           ASSERT FALSE
                           REPORT " SregSub ---- Unknown mode was passed "
                           SEVERITY ERROR;
      END CASE;

      IF (result'LENGTH < reslen) THEN
              ASSERT NOT WarningsOn  
              REPORT " SregSub --- Destination Length smaller than the " &
                       " calculated value. "
              SEVERITY WARNING;
       ELSIF ( result'LENGTH > reslen ) THEN
              ASSERT NOT WarningsOn  
              REPORT " SregSub --- Destination Length larger than the " &
                       " calculated value. "
              SEVERITY WARNING;
       END IF; 

       reslen2 := MINIMUM ( reslen, result'length );
       reslt_copy ( reslen2-1 downto 0 ) := r (reslen2-1 downto 0);
       result <= reslt_copy after DefaultSregDelay;
       borrow_out <= borrow_loc after DefaultSregDelay;
       overflow <= overflow_loc after DefaultSregDelay;		

     -- That's all
       RETURN;
    END;
 
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
                      ) IS
      VARIABLE reslen          : INTEGER := MAXIMUM (minuend'LENGTH, subtrahend'LENGTH);
      VARIABLE a, b, r         : std_logic_vector ( reslen - 1 DOWNTO 0 );    
      VARIABLE result_copy     : std_logic_vector ( result'length-1 downto 0 );
      VARIABLE borrow_out1     : std_ulogic;
      VARIABLE carry_o         : std_ulogic;
      VARIABLE overflow1       : std_ulogic;
      VARIABLE reslen2	       : INTEGER;
 
    BEGIN
	result_copy := result;
     --
     --   Null range check
     --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregSub ---  Destination has null range. " &
                    " cannot save result. "
             SEVERITY ERROR;
             overflow <= '1' after DefaultSregDelay;
             borrow_out <= '0' after DefaultSregDelay;
             RETURN;
 
     --   if minuend or subtrahend or both have null range no need to subtract
       ELSIF  (minuend'LENGTH = 0) AND (subtrahend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregSub --- both minuend and subtrahend has null range "
             SEVERITY ERROR;
             result_copy :=  (OTHERS => '0');
             borrow_out <= '0' after DefaultSregDelay;
             IF (borrow_in /= '0') THEN
                 IF (SrcRegMode = TwosComp OR SrcRegMode = Unsigned) THEN
                        result_copy := (OTHERS =>'1');
                        borrow_out <= '1' after DefaultSregDelay;
                 END IF;
             END IF;
             result <= result_copy after DefaultSregDelay;
             overflow <= '0' after DefaultSregDelay;
             RETURN;
       END IF;
 
     -- if one of the minuend or subtrahend is null
       IF (minuend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregSub --- minuend has null range "
             SEVERITY ERROR;
             a :=  ( OTHERS => '0');     -- treat it as zero's
             b := subtrahend ;
 
       ELSIF (subtrahend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregSub ---  subtrahend has null range "
             SEVERITY ERROR;
             b :=  (OTHERS => '0');
             a := minuend ;
 
                 -- inputs are  null so sign extend them to the same length.
       ELSE
             a := SignExtend(minuend , reslen, minuend 'LEFT, SrcRegMode);
             b := SignExtend(subtrahend , reslen, subtrahend 'LEFT, SrcRegMode);
 
       END IF;

 
       CASE SrcRegMode IS
            WHEN TwosComp
                        =>
                           Sub_TwosComp(r,borrow_out1, overflow1,
                                                               a,b, borrow_in);
       
            WHEN OnesComp
                         =>
                           -- ignore borrow istead pass mode M as '1'
                            AddSub_OnesComp(r, carry_o,overflow1,
                                                                  a,b, '1');
                            borrow_out1 := NOT carry_o;
       
            WHEN SignMagnitude
                          =>
                           -- ignore borrow_in istead pass mode M as '1'
                           AddSub_SignMagnitude(r, borrow_out1, overflow1,
                                                                         a,b, '1');
       
            WHEN Unsigned
                          =>
                           Sub_Unsigned(r, borrow_out1,overflow1,
                                                           a,b, borrow_in);
            WHEN OTHERS
                          =>
                           ASSERT FALSE
                           REPORT " SregSub ---- Unknown mode was passed "
                           SEVERITY ERROR;
      END CASE;

      IF (result'LENGTH < reslen) THEN
              ASSERT NOT WarningsOn  
              REPORT " SregSub --- Destination Length smaller than the " &
                       " calculated value. "
              SEVERITY WARNING;
       ELSIF ( result'LENGTH > reslen ) THEN
              ASSERT NOT WarningsOn  
              REPORT " SregSub --- Destination Length larger than the " &
                       " calculated value. "
              SEVERITY WARNING;
       END IF; 

       reslen2 := MINIMUM ( reslen, result'length );
       result_copy ( reslen2-1 downto 0 ) := To_X01(r (reslen2-1 downto 0 ));
       result <= result_copy after DefaultSregDelay;
       borrow_out <= To_X01(borrow_out1) after DefaultSregDelay;
       overflow <= To_X01(overflow1) after DefaultSregDelay;
     
     -- That's all
       RETURN;
     END;

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
--|     See Also       : RegAdd, SregSub, RegMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE SregSub  (SIGNAL result       : INOUT std_ulogic_vector;
                        SIGNAL borrow_out   : OUT std_ulogic;
                        SIGNAL overflow     : OUT std_ulogic;
                        CONSTANT minuend    :  IN std_ulogic_vector;
                        CONSTANT subtrahend :  IN std_ulogic_vector;
                        CONSTANT borrow_in  :  IN std_ulogic         := '0';
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      ) IS
      VARIABLE reslen       : INTEGER := MAXIMUM (minuend'LENGTH, subtrahend'LENGTH);
      VARIABLE a, b, r      : std_ulogic_vector ( reslen - 1 DOWNTO 0 );    
      VARIABLE result_copy  : std_ulogic_vector ( result'length-1 downto 0 );
      VARIABLE borrow_out1  : std_ulogic;
      VARIABLE carry_o      : std_ulogic;
      VARIABLE overflow1    : std_ulogic;
      VARIABLE reslen2      : INTEGER;
 
    BEGIN
	result_copy := result;
     --
     --   Null range check
     --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregSub ---  Destination has null range. " &
                    " cannot save result. "
             SEVERITY ERROR;
             borrow_out <= '0' after DefaultSregDelay;
             overflow <= '1' after DefaultSregDelay;
             RETURN;
 
     --   if minuend or subtrahend or both have null range no need to subtract
       ELSIF  (minuend'LENGTH = 0) AND (subtrahend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregSub --- both minuend and subtrahend has null range "
             SEVERITY ERROR;
             result_copy :=  (OTHERS => '0');
             borrow_out <= '0' after DefaultSregDelay;
             IF (borrow_in /= '0') THEN
                 IF (SrcRegMode = TwosComp OR SrcRegMode = Unsigned) THEN
                        result_copy := (OTHERS =>'1');
                        borrow_out <= '1' after DefaultSregDelay;
                 END IF;
             END IF;
             result <= result_copy after DefaultSregDelay;
             overflow <= '0' after DefaultSregDelay;
             RETURN;
       END IF;
 
     -- if one of the minuend or subtrahend is null
       IF (minuend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregSub --- minuend has null range "
             SEVERITY ERROR;
             a :=  ( OTHERS => '0');     -- treat it as zero's
             b := subtrahend;
 
       ELSIF (subtrahend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregSub ---  subtrahend has null range "
             SEVERITY ERROR;
             b :=  (OTHERS => '0');
             a := minuend;
 
                 -- inputs are  null so sign extend them to the same length.
       ELSE
             a := SignExtend(minuend, reslen, minuend'LEFT, SrcRegMode);
             b := SignExtend(subtrahend, reslen, subtrahend'LEFT, SrcRegMode);
 
       END IF;

 
       CASE SrcRegMode IS
            WHEN TwosComp
                        =>
                           Sub_TwosComp(r,borrow_out1, overflow1,
                                                               a,b, borrow_in);
       
            WHEN OnesComp
                         =>
                           -- ignore borrow istead pass mode M as '1'
                            AddSub_OnesComp(r, carry_o,overflow1,
                                                                  a,b, '1');
                            borrow_out1 := NOT carry_o;
       
            WHEN SignMagnitude
                          =>
                           -- ignore borrow_in istead pass mode M as '1'
                           AddSub_SignMagnitude(r, borrow_out1, overflow1,
                                                                         a,b, '1');
       
            WHEN Unsigned
                          =>
                           Sub_Unsigned(r, borrow_out1,overflow1,
                                                           a,b, borrow_in);
            WHEN OTHERS
                          =>
                           ASSERT FALSE
                           REPORT " SregSub ---- Unknown mode was passed "
                           SEVERITY ERROR;
      END CASE;

      IF (result'LENGTH < reslen) THEN
              ASSERT NOT WarningsOn  
              REPORT " SregSub --- Destination Length smaller than the " &
                       " calculated value. "
              SEVERITY WARNING;
       ELSIF ( result'LENGTH > reslen ) THEN
              ASSERT NOT WarningsOn  
              REPORT " SregSub --- Destination Length larger than the " &
                       " calculated value. "
              SEVERITY WARNING;
       END IF; 

       reslen2 := MINIMUM ( reslen, result'length );
       result_copy ( reslen2-1 downto 0 ) := To_X01(r (reslen2-1 downto 0 ));
       result <= result_copy after DefaultSregDelay;
       borrow_out <= To_X01(borrow_out1) after DefaultSregDelay;
       overflow <= To_X01(overflow1) after DefaultSregDelay;
     
     -- That's all
       RETURN;
     END;

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
--|     See Also       : RegAdd, SregSub, SregMult, RegDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE SregMult (SIGNAL result         : OUT BIT_VECTOR;
                        SIGNAL overflow       : OUT BIT;
                        CONSTANT multiplicand : IN BIT_VECTOR;
                        CONSTANT multiplier   : IN BIT_VECTOR;
                        CONSTANT SrcRegMode   : IN regmode_type := DefaultRegMode 
                      ) IS

      CONSTANT reslen      : INTEGER := multiplicand'LENGTH + multiplier'LENGTH;
      VARIABLE r           : BIT_VECTOR ( reslen - 1  DOWNTO 0 )       := (OTHERS=>'0');
      VARIABLE rega        : BIT_VECTOR ( multiplicand'LENGTH - 1 DOWNTO 0 ) := multiplicand;
      VARIABLE regb        : BIT_VECTOR ( multiplier'LENGTH -1  DOWNTO 0 )  := multiplier;
      VARIABLE carry       : BIT;
      VARIABLE nxt_c       : BIT;
      VARIABLE sign_bit    : BIT;
      VARIABLE overflo     : BIT := '0';  
      VARIABLE i           : INTEGER;
      VARIABLE reslt_copy : BIT_VECTOR ( result'length - 1 downto 0 );

     BEGIN 
     --  
     --   Null range check
     --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMult ---  Destination  to hold the product has null range. "
             SEVERITY ERROR;
             overflow <= overflo after DefaultSregDelay;
             RETURN;
     --   if both multiplicand  and multiplier  have null range no need to multiply
       ELSIF (multiplicand'LENGTH = 0) AND (multiplier'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMult --- both multiplicand  and multiplier has null range "
             SEVERITY ERROR;
             reslt_copy :=  (OTHERS => '0');
             result <= reslt_copy after DefaultSregDelay; -- result is filled with zeros
             overflow <= overflo after DefaultSregDelay;       
             RETURN;      

     -- if one of the multiplicand  or multiplier is null 
       ELSIF (multiplicand'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMult --- multiplicand  has null range "
             SEVERITY ERROR;
                                 -- treat multiplicand as zero so result is zero 
             reslt_copy := (OTHERS => '0');
             result <= reslt_copy after DefaultSregDelay;
             overflow <= overflo after DefaultSregDelay;
             RETURN;
       ELSIF (multiplier'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMult --- multiplier  has null range "
             SEVERITY ERROR;
                                 -- treat multiplier as zero so result is zero 
             reslt_copy := (OTHERS => '0');
             result <= reslt_copy after DefaultSregDelay;
             overflow <= overflo after DefaultSregDelay;
             RETURN;
       END IF;
           
   -- 
   -- inputs are  not null so determine the sign and convert 
   -- the inputs to unsigned  representation.
      sign_bit := rega(rega'LEFT) XOR regb(regb'LEFT);    
      IF (rega(rega'LEFT) /= '0') THEN
          rega := To_Unsign (rega, SrcRegMode);     
      END IF;
      IF ( regb(regb'LEFT)  /= '0' ) THEN
          regb := To_Unsign (regb, SrcRegMode);      
      END IF;
 
    --
    -- perform the multiply using shift and add.
    -- for each bit of the multiplier
    --
      FOR k IN 0 TO multiplier'LENGTH - 1 LOOP
        -- if the multiplier bit is '1' then add the shifted multiplicand
        IF (regb(k) = '1') THEN
          i := k;                -- 'i' is LSB position in result for this add
          carry := '0';
          FOR n IN 0 TO multiplicand'LENGTH - 1 LOOP
            nxt_c := (rega(n) AND r(i)) OR ( carry AND (rega(n) OR r(i))); -- carry compute
             r(i) :=  rega(n) XOR r(i) XOR carry;                       -- bit sum
            carry := nxt_c;
                i := i + 1;
          END LOOP;
          r(i) := carry;            -- carry out is added to result
        END IF;
     END LOOP;
 
  -- if the result should be negative, then negate
  --
    IF ((sign_bit /='0')  AND  (SrcRegMode /= Unsigned)) THEN
              r := RegNegate (r, SrcRegMode);         
    END IF;

  --
  -- Determine the length of the result to be returned
  --
    IF (result'LENGTH < reslen)   THEN
        case SrcRegMode is 
          WHEN TwosComp =>
                reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
                IF (sign_bit = '0') THEN     -- positive result
                      FOR j IN result'LENGTH  - 1 TO reslen - 2 LOOP
                         if (r(j) = '1') THEN
                           overflo := '1';
                         END IF;
                         EXIT WHEN (r(j) = '1');
                      END LOOP;
                                              
                ELSE                          -- negative result  -128 is valid
                       FOR j IN result'LENGTH  TO reslen - 2 LOOP
                          if (r(j) = '0') THEN
                             overflo := '1';
                          END IF;
                         EXIT WHEN (r(j) = '0');
                       END LOOP;
                END IF;
                                         
          WHEN OnesComp =>
                reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
                IF (sign_bit = '0') THEN     -- positive result
                      FOR j IN result'LENGTH - 1 TO reslen - 2 LOOP
                         if (r(j) = '1') THEN
                           overflo := '1';
                         END IF;
                         EXIT WHEN (r(j) = '1');
                      END LOOP;
                                              
                ELSE                          -- negative result
                       FOR j IN result'LENGTH - 1 TO reslen - 2 LOOP
                          if (r(j) = '0') THEN
                             overflo := '1';
                          END IF;
                         EXIT WHEN (r(j) = '0');
                       END LOOP;
                END IF;

          WHEN Unsigned =>
               reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
               FOR j IN result'LENGTH  TO reslen - 1 LOOP
                   if (r(j) /= '0') THEN
                        overflo := '1';
                   END IF;
                   EXIT WHEN (r(j) /= '0');
               END LOOP;
    
          WHEN SignMagnitude  =>
               reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
               reslt_copy(result'LENGTH - 1) := r(reslen - 1);  -- sign bit
               FOR j IN result'LENGTH - 1 TO reslen - 2 LOOP
                   if (r(j) /= '0') THEN
                        overflo := '1';
                   END IF;
                   EXIT WHEN (r(j) /= '0');
               END LOOP;

          WHEN OTHERS =>
                      null;
        END CASE;
    ELSIF (result'LENGTH > reslen) THEN                -- sign extend the product
       reslt_copy := SignExtend(r, result'LENGTH, r'LEFT, SrcRegMode);
    ELSE
       reslt_copy := r;                              -- equal length
    END IF;
    result <= reslt_copy after DefaultSregDelay;
    overflow <= overflo after DefaultSregDelay;

    -- that's all
    RETURN;
    END;

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
                      ) IS

      CONSTANT reslen      : INTEGER := multiplicand'LENGTH + multiplier'LENGTH;
      VARIABLE r           : std_logic_vector(reslen - 1  DOWNTO 0)   := (OTHERS=>'0');
      VARIABLE rega        : std_logic_vector(multiplicand'LENGTH - 1 DOWNTO 0) := multiplicand;
      VARIABLE regb        : std_logic_vector(multiplier'LENGTH - 1 DOWNTO 0) := multiplier;
      VARIABLE carry       : std_ulogic;
      VARIABLE nxt_c       : std_ulogic;
      VARIABLE sign_bit    : std_ulogic;
      VARIABLE overflo1    : std_ulogic := '0';
      VARIABLE i           : INTEGER;
      VARIABLE reslt_copy : std_logic_vector ( result'length - 1 downto 0 );

     BEGIN 
     --  
     --   Null range check
     --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMult ---  Destination  to hold the product has null range. "
             SEVERITY ERROR;
             overflow <= overflo1;
             RETURN;
     --   if both multiplicand  and multiplier  have null range no need to multiply
       ELSIF (multiplicand'LENGTH = 0) AND (multiplier'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMult --- both multiplicand  and multiplier has null range "
             SEVERITY ERROR;
             reslt_copy :=  (OTHERS => '0');
             result <= reslt_copy after DefaultSregDelay;  -- result is filled with zeros
             overflow <= overflo1 after DefaultSregDelay;       
             RETURN;      

     -- if one of the multiplicand  or multiplier is null 
       ELSIF (multiplicand'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMult --- multiplicand  has null range "
             SEVERITY ERROR;
                                 -- treat multiplicand as zero so result is zero 
             reslt_copy := (OTHERS => '0');
             result <= reslt_copy after DefaultSregDelay;
             overflow <= overflo1 after DefaultSregDelay;
             RETURN;
       ELSIF (multiplier'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMult --- multiplier  has null range "
             SEVERITY ERROR;
                                 -- treat multiplier as zero so result is zero 
             reslt_copy := (OTHERS => '0');
             result <= reslt_copy after DefaultSregDelay;
             overflow <= overflo1 after DefaultSregDelay;
             RETURN;
       END IF;
           
   -- 
   -- inputs are  not null so determine the sign and convert 
   -- the inputs to unsigned  representation.
      sign_bit := rega(rega'LEFT) XOR regb(regb'LEFT);    
      IF (rega(rega'LEFT) /= '0') THEN
          rega := To_Unsign (rega, SrcRegMode);     
      END IF;
      IF ( regb(regb'LEFT)  /= '0' ) THEN
          regb := To_Unsign (regb, SrcRegMode);      
      END IF;
 
    --
    -- perform the multiply using shift and add.
    -- for each bit of the multiplier
    --
      FOR k IN 0 TO multiplier'LENGTH - 1 LOOP
        -- if the multiplier bit is '1' then add the shifted multiplicand
        IF (regb(k) = '1') THEN
          i := k;                -- 'i' is LSB position in result for this add
          carry := '0';
          FOR n IN 0 TO multiplicand'LENGTH - 1 LOOP
            nxt_c := (rega(n) AND r(i)) OR ( carry AND (rega(n) OR r(i))); -- carry compute
             r(i) :=  rega(n) XOR r(i) XOR carry;                       -- bit sum
            carry := nxt_c;
                i := i + 1;
          END LOOP;
          r(i) := carry;            -- carry out is added to result
        END IF;
     END LOOP;
 
  -- if the result should be negative, then negate
  --
    IF ((sign_bit /='0')  AND  (SrcRegMode /= Unsigned)) THEN
              r := RegNegate (r, SrcRegMode);         
    END IF;

  --
  -- Determine the length of the result to be returned
  --
    IF (result'LENGTH < reslen)   THEN
        case SrcRegMode is 
          WHEN TwosComp =>
                reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
                IF (sign_bit = '0') THEN     -- positive result
                      FOR j IN result'LENGTH  - 1 TO reslen - 2 LOOP
                         if (r(j) /= '0'  ) THEN
                           overflo1 := '1';
                         END IF;
                         EXIT WHEN (r(j) /= '0');
                      END LOOP;
                                              
                ELSE                          -- negative result  -128 is valid
                       FOR j IN result'LENGTH  TO reslen - 2 LOOP
                          if (r(j) = '0') THEN
                             overflo1 := '1';
                          END IF;
                         EXIT WHEN (r(j) = '0');
                       END LOOP;
                END IF;
                                         
          WHEN OnesComp =>
                reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
                IF (sign_bit = '0') THEN     -- positive result
                      FOR j IN result'LENGTH  - 1 TO reslen - 2 LOOP
                         if (r(j) /= '0') THEN
                           overflo1 := '1';
                         END IF;
                         EXIT WHEN (r(j) /= '0');
                      END LOOP;
                                              
                ELSE                          -- negative result
                       FOR j IN result'LENGTH - 1 TO reslen - 2 LOOP
                          if (r(j) = '0') THEN
                             overflo1 := '1';
                          END IF;
                         EXIT WHEN (r(j) = '0');
                       END LOOP;
                END IF;

          WHEN Unsigned =>
               reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
               FOR j IN result'LENGTH TO reslen - 1 LOOP
                   if (r(j) /= '0') THEN
                        overflo1 := '1';
                   END IF;
                   EXIT WHEN (r(j) /= '0');
               END LOOP;
    
          WHEN SignMagnitude  =>
               reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
               reslt_copy(result'LENGTH - 1) := r(reslen - 1);  -- sign bit
               FOR j IN result'LENGTH - 1 TO reslen - 2 LOOP
                   if (r(j) /= '0') THEN
                        overflo1 := '1';
                   END IF;
                   EXIT WHEN (r(j) /= '0');
               END LOOP;

          WHEN OTHERS =>
                      null;
        END CASE;
    ELSIF (result'LENGTH > reslen) THEN                -- sign extend the product
       reslt_copy := SignExtend(r, result'LENGTH, r'LEFT, SrcRegMode);
    ELSE
       reslt_copy := r;                              -- equal length
    END IF;
    result <= reslt_copy after DefaultSregDelay;
    overflow <= overflo1 after DefaultSregDelay;

    -- that's all
    RETURN;
    END;

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
                      ) IS

      CONSTANT reslen      : INTEGER := multiplicand'LENGTH + multiplier'LENGTH;
      VARIABLE r           : std_ulogic_vector ( reslen - 1  DOWNTO 0 )  := (OTHERS=>'0');
      VARIABLE rega        : std_ulogic_vector(multiplicand'LENGTH - 1 DOWNTO 0) := multiplicand;
      VARIABLE regb        : std_ulogic_vector(multiplier'LENGTH - 1  DOWNTO 0) := multiplier;
      VARIABLE carry       : std_ulogic;
      VARIABLE nxt_c       : std_ulogic;
      VARIABLE sign_bit    : std_ulogic;
      VARIABLE overflo2    : std_ulogic := '0';
      VARIABLE i           : INTEGER;
      VARIABLE reslt_copy : std_ulogic_vector ( result'length - 1 downto 0 );

     BEGIN 


     --  
     --   Null range check
     --   if result vector is a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMult ---  Destination  to hold the product has null range. "
             SEVERITY ERROR;
             overflow <= overflo2 after DefaultSregDelay;
             RETURN;
     --   if both multiplicand  and multiplier  have null range no need to multiply
       ELSIF (multiplicand'LENGTH = 0) AND (multiplier'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMult --- both multiplicand  and multiplier has null range "
             SEVERITY ERROR;
             reslt_copy :=  (OTHERS => '0');
             result <= reslt_copy after DefaultSregDelay;  -- result is filled with zeros
             overflow <= overflo2 after DefaultSregDelay;       
             RETURN;      

     -- if one of the multiplicand  or multiplier is null 
       ELSIF (multiplicand'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMult --- multiplicand  has null range "
             SEVERITY ERROR;
                                 -- treat multiplicand as zero so result is zero 
             reslt_copy := (OTHERS => '0');
             result <= reslt_copy after DefaultSregDelay;
             overflow <= overflo2 after DefaultSregDelay;
             RETURN;
       ELSIF (multiplier'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMult --- multiplier  has null range "
             SEVERITY ERROR;
                                 -- treat multiplier as zero so result is zero 
             reslt_copy := (OTHERS => '0');
             result <= reslt_copy after DefaultSregDelay;
             overflow <= overflo2 after DefaultSregDelay;
             RETURN;
       END IF;
           
   -- 
   -- inputs are  not null so determine the sign and convert 
   -- the inputs to unsigned  representation.
      sign_bit := rega(rega'LEFT) XOR regb(regb'LEFT);    
      IF (rega(rega'LEFT) /= '0') THEN
          rega := To_Unsign (rega, SrcRegMode);     
      END IF;
      IF ( regb(regb'LEFT)  /= '0' ) THEN
          regb := To_Unsign (regb, SrcRegMode);      
      END IF;
 
    --
    -- perform the multiply using shift and add.
    -- for each bit of the multiplier
    --
      FOR k IN 0 TO multiplier'LENGTH - 1 LOOP
        -- if the multiplier bit is '1' then add the shifted multiplicand
        IF (regb(k) = '1') THEN
          i := k;                -- 'i' is LSB position in result for this add
          carry := '0';
          FOR n IN 0 TO multiplicand'LENGTH - 1 LOOP
            nxt_c := (rega(n) AND r(i)) OR ( carry AND (rega(n) OR r(i))); -- carry compute
             r(i) :=  rega(n) XOR r(i) XOR carry;                       -- bit sum
            carry := nxt_c;
                i := i + 1;
          END LOOP;
          r(i) := carry;            -- carry out is added to result
        END IF;
     END LOOP;
 
  -- if the result should be negative, then negate
  --
    IF ((sign_bit /='0')  AND  (SrcRegMode /= Unsigned)) THEN
              r := RegNegate (r, SrcRegMode);         
    END IF;

  --
  -- Determine the length of the result to be returned
  --
    IF (result'LENGTH < reslen)   THEN
        case SrcRegMode is 
          WHEN TwosComp =>
                reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
                IF (sign_bit = '0') THEN     -- positive result
                      FOR j IN result'LENGTH  - 1 TO reslen - 2 LOOP
                         if (r(j) /= '0'  ) THEN
                           overflo2 := '1';
                         END IF;
                         EXIT WHEN (r(j) /= '0');
                      END LOOP;
                                              
                ELSE                          -- negative result  -128 is valid
                       FOR j IN result'LENGTH  TO reslen - 2 LOOP
                          if (r(j) = '0') THEN
                             overflo2 := '1';
                          END IF;
                         EXIT WHEN (r(j) = '0');
                       END LOOP;
                END IF;
                                         
          WHEN OnesComp =>
                reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
                IF (sign_bit = '0') THEN     -- positive result
                      FOR j IN result'LENGTH  - 1 TO reslen - 2 LOOP
                         if (r(j) /= '0') THEN
                           overflo2 := '1';
                         END IF;
                         EXIT WHEN (r(j) /= '0');
                      END LOOP;
                                              
                ELSE                          -- negative result
                       FOR j IN result'LENGTH - 1 TO reslen - 2 LOOP
                          if (r(j) = '0') THEN
                             overflo2 := '1';
                          END IF;
                         EXIT WHEN (r(j) = '0');
                       END LOOP;
                END IF;

          WHEN Unsigned =>
               reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
               FOR j IN result'LENGTH TO reslen - 1 LOOP
                   if (r(j) /= '0') THEN
                        overflo2 := '1';
                   END IF;
                   EXIT WHEN (r(j) /= '0');
               END LOOP;
    
          WHEN SignMagnitude  =>
               reslt_copy := r(result'LENGTH - 1 DOWNTO 0); 
               reslt_copy(result'LENGTH - 1) := r(reslen - 1);  -- sign bit
               FOR j IN result'LENGTH - 1 TO reslen - 2 LOOP
                   if (r(j) /= '0') THEN
                        overflo2 := '1';
                   END IF;
                   EXIT WHEN (r(j) /= '0');
               END LOOP;

          WHEN OTHERS =>
                      null;
        END CASE;
    ELSIF (result'LENGTH > reslen) THEN                -- sign extend the product
       reslt_copy := SignExtend(r, result'LENGTH, r'LEFT, SrcRegMode);
    ELSE
       reslt_copy := r;                              -- equal length
    END IF;
    result <= reslt_copy after DefaultSregDelay;
    overflow <= overflo2 after DefaultSregDelay;

    -- that's all
    RETURN;
    END;


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
--|     See Also       : SregAdd, SregSub, SregMult, SregMod, SregRem
--|-----------------------------------------------------------------------------
    PROCEDURE SregDiv ( SIGNAL result       : OUT BIT_VECTOR;
                        SIGNAL remainder    : OUT BIT_VECTOR;
                        SIGNAL ZeroDivide   : OUT BIT;
                        CONSTANT dividend   :  IN BIT_VECTOR;
                        CONSTANT divisor    :  IN BIT_VECTOR;
                        CONSTANT SrcRegMode    :  IN regmode_type := DefaultRegMode
                      ) IS
      CONSTANT nd            : INTEGER := dividend'LENGTH;    
      CONSTANT len           : INTEGER := 2 * nd;
      VARIABLE res_copy      : BIT_VECTOR(result'LENGTH - 1 DOWNTO 0);
      VARIABLE rem_copy      : BIT_VECTOR(remainder'LENGTH - 1 DOWNTO 0);
      VARIABLE dividend_copy : BIT_VECTOR(dividend'LENGTH - 1 DOWNTO 0) := dividend;
      VARIABLE divisor_copy  : BIT_VECTOR(divisor'LENGTH - 1 DOWNTO 0) := divisor;
      VARIABLE regr          : BIT_VECTOR(len  DOWNTO 0) := (OTHERS => '0');
      VARIABLE rega          : BIT_VECTOR(len  DOWNTO 0) := (OTHERS => '0');
      VARIABLE regd          : BIT_VECTOR(len  DOWNTO 0) := (OTHERS => '0');
      VARIABLE regb          : BIT_VECTOR(nd - 1  DOWNTO 0);   -- quotient
      VARIABLE neg_res       : Boolean := FALSE;              -- sign of result
      VARIABLE neg_rem       : BOOLEAN := FALSE;              -- sign of remainder
      VARIABLE b_out         : BIT;
      VARIABLE uvflo         : BIT;
      VARIABLE shiftout      : BIT;

     BEGIN 
     --  
     --   Null range check
     --   if result vector or remainder vector has a null range
       IF (( result'LENGTH = 0) OR (remainder'LENGTH = 0)) THEN
             ASSERT false
             REPORT " SregDiv  ---  Destination   has null range. "
             SEVERITY ERROR;
             RETURN;
     --   if both dividend  divisor  have null range no need to divide
       ELSIF (dividend'LENGTH = 0) AND (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregDiv --- both dividend  and divisor has null range "
             SEVERITY ERROR;
             res_copy :=  (OTHERS => '0');
             result <= res_copy after DefaultSregDelay;  -- result is filled with zeros
             rem_copy :=  (OTHERS => '0');
             remainder <= rem_copy after DefaultSregDelay; -- remainder is filled with zeros
             RETURN;      

     -- if one of the dividend  or divisor is null 
       ELSIF (dividend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregDiv ---  dividend  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             res_copy := (OTHERS => '0');
             result <= res_copy after DefaultSregDelay;
             rem_copy :=  (OTHERS => '0');
             remainder <= rem_copy after DefaultSregDelay; -- remainder is filled with zeros
             RETURN;
       ELSIF (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregDiv --- divisor  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             res_copy := (OTHERS => '0');
             result <= res_copy after DefaultSregDelay;
             rem_copy :=  (OTHERS => '0');
             remainder <= rem_copy after DefaultSregDelay; -- remainder is filled with zeros
             RETURN;
       END IF;
           
    -- check for divide by zero
      IF ( is_zero(divisor_copy, SrcRegMode) )  THEN     -- applying the equality operator
          ASSERT false
          REPORT " SregDiv  ---  divide by zero  "
          SEVERITY ERROR;
          res_copy := (OTHERS => '0');
          result <= res_copy after DefaultSregDelay;
             rem_copy :=  (OTHERS => '0');
             remainder <= rem_copy after DefaultSregDelay; -- remainder is filled with zeros
	     ZeroDivide <= '1' after DefaultSregDelay;	
          RETURN;
      END IF;  

    -- put dividend to rega  and divisor to regd
      rega(dividend'LENGTH - 1 DOWNTO 0) := dividend_copy;          
      regd(divisor'LENGTH - 1 DOWNTO 0) := divisor_copy;  
   -- inputs are  not null so determine the sign and convert 
   -- the inputs to unsigned  representation.
     IF (SrcRegMode /= Unsigned) THEN
        IF (dividend_copy(dividend_copy'LEFT) /= '0') THEN
           neg_res := NOT neg_res;
           neg_rem := NOT neg_rem;          -- sign of dividend is sign of remainder
           rega(dividend'LENGTH - 1 DOWNTO 0) := To_Unsign (dividend_copy, SrcRegMode);     
        END IF;

        IF (divisor_copy(divisor_copy'LEFT) /= '0') THEN
           neg_res := NOT neg_res;
           regd(divisor'LENGTH - 1 DOWNTO 0) := To_Unsign(divisor_copy, SrcRegMode);  
        END IF;
     END IF;

   -- Perform division by binary restoring algorithm
   --
   --    initialize 
   -- load rega to regr, 
   -- regd  gets regd shifted left by nd bits
   -- regb  gets all zerso
   -- 
       regr := rega;                
            -- left shift regd by nd ( length of divisor) bits, fill with zero's
       RegShift(regd, regd, shiftout, '1', '0', nd);
       regb := (OTHERS =>'0');

       For i IN 0 TO nd - 1 LOOP
                                                -- regr := 2*regr - regd
           RegShift(regr, regr, shiftout, '1', '0', 1);
           RegSub ( regr, b_out, uvflo,  regr,  regd, '0', TwosComp);                 
           IF (regr(regr'LEFT) /= '0')   THEN
                                               -- regr := regr + regd
                RegAdd(regr, b_out, uvflo, regr, regd, '0', TwosComp);
                RegShift(regb, regb, shiftout, '1', '0', 1);
           ELSE
                                                -- regb := 2*regb + 1;
                RegShift(regb, regb, shiftout, '1', '0', 1);
                regb := RegInc(regb, Unsigned);
           END IF;
      END LOOP;
     
      -- if the result and remainder should be negative 
        IF (neg_res AND (SrcRegMode /= Unsigned)) THEN
              regb := RegNegate(regb, SrcRegMode);
        END IF;

        IF (neg_rem AND (SrcRegMode /= Unsigned)) THEN
              regr := RegNegate(regr, SrcRegMode);
        END IF;

      -- determine the length of result
        IF (result'LENGTH <= dividend'LENGTH) THEN
           res_copy := regb(result'LENGTH - 1 DOWNTO 0);
           ASSERT (result'LENGTH = dividend'LENGTH) OR (NOT WarningsOn)
           REPORT " SregDiv --- length of result vector is shorter than dividend "
           SEVERITY WARNING;
        ELSE
                                                -- sign extend the quotient
           res_copy := SignExtend(regb, result'LENGTH, regb'LEFT, SrcRegMode);
        END IF;
                -- remainder is in most significant N bits, shift right N bits 
         RegShift(regr, regr, shiftout, '0', regr(len), nd);
      -- remainder length
        IF ( remainder'LENGTH <= len ) THEN 
            rem_copy := regr(remainder'LENGTH - 1 DOWNTO 0);
            IF (SrcRegMode /= Unsigned) THEN
               rem_copy(result'LENGTH - 1) := regr(result'LENGTH);  -- sign bit
            END IF;
        ELSE
            rem_copy := SignExtend(regr, remainder'LENGTH, regr'LEFT, SrcRegMode);
        END IF;
        
        result <= res_copy after DefaultSregDelay;
        remainder <= rem_copy after DefaultSregDelay;
        ZeroDivide <= '0' after DefaultSregDelay;	
    
    -- That's all
      RETURN;
    END;

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
    --     See Also       : SregAdd, SregSub, SregMult, SregMod, SregRem
    -------------------------------------------------------------------------------
    PROCEDURE SregDiv ( SIGNAL result       : OUT std_logic_vector;
                        SIGNAL remainder    : OUT std_logic_vector;
                        SIGNAL ZeroDivide   : OUT std_ulogic;  
                        CONSTANT dividend   :  IN std_logic_vector;
                        CONSTANT divisor    :  IN std_logic_vector;
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      ) IS

      CONSTANT nd1        : INTEGER := dividend'LENGTH;    
      CONSTANT len       : INTEGER := 2 * nd1;
      VARIABLE res_copy : std_logic_vector(result'LENGTH - 1 DOWNTO 0);
      VARIABLE rem_copy : std_logic_vector(remainder'LENGTH - 1 DOWNTO 0);
      VARIABLE dividnd_copy : std_logic_vector(dividend'LENGTH - 1 DOWNTO 0) := dividend;
      VARIABLE divisr_copy  : std_logic_vector(divisor'LENGTH - 1 DOWNTO 0) := divisor;
      VARIABLE regr          : std_logic_vector(len  DOWNTO 0) := (OTHERS => '0');
      VARIABLE rega          : std_logic_vector(len  DOWNTO 0) := (OTHERS => '0');
      VARIABLE regd          : std_logic_vector(len  DOWNTO 0) := (OTHERS => '0');
      VARIABLE regb          : std_logic_vector(nd1 - 1 DOWNTO 0);   -- quotient
      VARIABLE neg_res       : Boolean := FALSE;              -- sign of result
      VARIABLE neg_rem       : BOOLEAN := FALSE;              -- sign of remainder
      VARIABLE b_out         : std_ulogic;
      VARIABLE uvflo1        : std_ulogic;
      VARIABLE shiftout      : std_ulogic;

     BEGIN 
     --  
     --   Null range check
     --   if result vector or remainder vector has a null range
       IF (( result'LENGTH = 0) OR (remainder'LENGTH = 0)) THEN
             ASSERT false
             REPORT " SregDiv  ---  Destination   has null range. "
             SEVERITY ERROR;
             RETURN;
     --   if both dividend  divisor  have null range no need to divide
       ELSIF (dividend'LENGTH = 0) AND (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregDiv --- both dividend  and divisor has null range "
             SEVERITY ERROR;
             res_copy :=  (OTHERS => '0');
             result <= res_copy after DefaultSregDelay;  -- result is filled with zeros
             rem_copy :=  (OTHERS => '0');
             remainder <= rem_copy after DefaultSregDelay; -- remainder is filled with zeros
             RETURN;      

     -- if one of the dividend  or divisor is null 
       ELSIF (dividend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregDiv ---  dividend  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             res_copy := (OTHERS => '0');
             result <= res_copy after DefaultSregDelay;
             rem_copy :=  (OTHERS => '0');
             remainder <= rem_copy after DefaultSregDelay; -- remainder is filled with zeros
             RETURN;
       ELSIF (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregDiv --- divisor  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             res_copy := (OTHERS => '0');
             result <= res_copy after DefaultSregDelay;
             rem_copy :=  (OTHERS => '0');
             remainder <= rem_copy after DefaultSregDelay; -- remainder is filled with zeros
	     ZeroDivide <= '1' after DefaultSregDelay;	
             RETURN;
       END IF;
           
    -- check for divide by zero
      IF (is_zero(divisr_copy, SrcRegMode) )  THEN     -- applying the equality operator
          ASSERT false
          REPORT " SregDiv  ---  divide by zero  "
          SEVERITY ERROR;
          res_copy := (OTHERS => '0');
          result <= res_copy after DefaultSregDelay;
             rem_copy :=  (OTHERS => '0');
             remainder <= rem_copy after DefaultSregDelay; -- remainder is filled with zeros
          RETURN;
      END IF;  

    -- put dividend to rega  and divisor to regd
      rega(dividend'LENGTH - 1 DOWNTO 0) := dividnd_copy;          
      regd(divisor'LENGTH - 1 DOWNTO 0) := divisr_copy;  

   -- inputs are  not null so determine the sign and convert 
   -- the inputs to unsigned  representation.
     IF (SrcRegMode /= Unsigned) THEN
        IF (dividnd_copy(dividnd_copy'LEFT) /= '0') THEN
           neg_res := NOT neg_res;
           neg_rem := NOT neg_rem;          -- sign of dividend is sign of remainder
           rega(dividend'LENGTH - 1 DOWNTO 0) := To_Unsign (dividnd_copy, SrcRegMode);     
        END IF;

        IF (divisr_copy(divisr_copy'LEFT) /= '0') THEN
           neg_res := NOT neg_res;
           regd(divisor'LENGTH - 1 DOWNTO 0) := To_Unsign(divisr_copy, SrcRegMode);  
        END IF;
     END IF;
 
   -- Perform division by binary restoring algorithm
   --
   --    initialize 
   -- load rega to regr, 
   -- regd  gets regd shifted left by nd1 bits
   -- regb  gets all zerso
   -- 
       regr := rega;                
            -- left shift regd by nd ( length of divisor) bits, fill with zero's
       RegShift(regd, regd, shiftout, '1', '0', nd1);
       regb := (OTHERS =>'0');

       For i IN 0 TO nd1 - 1 LOOP
                                                -- regr := 2*regr - regd
           RegShift(regr, regr, shiftout, '1', '0', 1);
           RegSub (regr, b_out,  uvflo1,  regr, regd, '0', TwosComp );     
                                               -- if regr is negative, then restore
           IF (regr(regr'LEFT) /= '0')   THEN
                                               -- regr := regr + regd
                                               -- regb := 2*regb 
                RegAdd(regr, b_out, uvflo1, regr, regd, '0', TwosComp);
                RegShift(regb, regb, shiftout, '1', '0', 1);
           ELSE
                                                -- regb := 2*regb + 1;
                RegShift(regb, regb, shiftout, '1', '0', 1);
                regb := RegInc (regb, Unsigned );
           END IF;

      END LOOP;
     
      -- if the result and remainder should be negative 
        IF (neg_res AND (SrcRegMode /= Unsigned)) THEN
              regb := RegNegate(regb, SrcRegMode);
        END IF;

        IF (neg_rem AND (SrcRegMode /= Unsigned)) THEN
              regr := RegNegate(regr, SrcRegMode);
        END IF;

      -- determine the length of result
        IF (result'LENGTH <= dividend'LENGTH) THEN
           res_copy := regb(result'LENGTH - 1 DOWNTO 0);
            ASSERT (result'LENGTH = dividend'LENGTH) OR (NOT WarningsOn)
            REPORT " SregDiv --- length of result  is shorter than dividend "
            SEVERITY WARNING;
        ELSE
                                                -- sign extend the quotient
           res_copy := SignExtend(regb, result'LENGTH, regb'LEFT, SrcRegMode);
        END IF;
                -- remainder is in most significant N bits, shift right N bits 
         RegShift(regr, regr, shiftout, '0', regr(len), nd1);          
      -- remainder length
        IF ( remainder'LENGTH <= len ) THEN
            rem_copy := regr(remainder'LENGTH - 1 DOWNTO 0);
            IF (SrcRegMode /= Unsigned) THEN
               rem_copy(result'LENGTH - 1) := regr(result'LENGTH);  -- sign bit
            END IF;							
        ELSE
            rem_copy := SignExtend(regr, remainder'LENGTH, regr'LEFT, SrcRegMode);
        END IF;
        result    <= To_X01(res_copy) after DefaultSregDelay;
        remainder <= To_X01(rem_copy) after DefaultSregDelay;        
        ZeroDivide <= '0' after DefaultSregDelay;	
    
    -- That's all
      RETURN;
    END;

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
                      ) IS

      CONSTANT nd2       : INTEGER := dividend'LENGTH;    
      CONSTANT len       : INTEGER := 2 * nd2;
      VARIABLE res_copy  : std_ulogic_vector(result'LENGTH - 1 DOWNTO 0);
      VARIABLE rem_copy  : std_ulogic_vector(remainder'LENGTH - 1 DOWNTO 0);
      VARIABLE dividend_copy : std_ulogic_vector(dividend'LENGTH - 1 DOWNTO 0) := dividend;
      VARIABLE divisor_copy  : std_ulogic_vector(divisor'LENGTH - 1 DOWNTO 0) := divisor;
      VARIABLE regr      : std_ulogic_vector(len  DOWNTO 0) := (OTHERS => '0');
      VARIABLE rega      : std_ulogic_vector(len DOWNTO 0) := (OTHERS => '0');
      VARIABLE regd      : std_ulogic_vector(len DOWNTO 0) := (OTHERS => '0');
      VARIABLE regb      : std_ulogic_vector(nd2- 1 DOWNTO 0);   -- quotient
      VARIABLE neg_res   : Boolean := FALSE;              -- sign of result
      VARIABLE neg_rem   : BOOLEAN := FALSE;              -- sign of remainder
      VARIABLE b_out     : std_ulogic;
      VARIABLE uvflo2    : std_ulogic;
      VARIABLE shiftout  : std_ulogic;

     BEGIN 
     --  
     --   Null range check
     --   if result vector or remainder vector has a null range
       IF (( result'LENGTH = 0) OR (remainder'LENGTH = 0)) THEN
             ASSERT false
             REPORT " SregDiv  ---  Destination   has null range. "
             SEVERITY ERROR;
             RETURN;
     --   if both dividend  divisor  have null range no need to divide
       ELSIF (dividend'LENGTH = 0) AND (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregDiv --- both dividend  and divisor has null range "
             SEVERITY ERROR;
             res_copy :=  (OTHERS => '0');
             result <= res_copy after DefaultSregDelay;   -- result is filled with zeros
             rem_copy :=  (OTHERS => '0');
             remainder <= rem_copy after DefaultSregDelay; -- remainder is filled with zeros
             RETURN;      

     -- if one of the dividend  or divisor is null 
       ELSIF (dividend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregDiv ---  dividend  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             res_copy := (OTHERS => '0');
             result <= res_copy after DefaultSregDelay;
             rem_copy :=  (OTHERS => '0');
             remainder <= rem_copy after DefaultSregDelay; -- remainder is filled with zeros
             RETURN;
       ELSIF (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregDiv --- divisor  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             res_copy := (OTHERS => '0');
             result <= res_copy after DefaultSregDelay;
             rem_copy :=  (OTHERS => '0');
             remainder <= rem_copy after DefaultSregDelay; -- remainder is filled with zeros
             RETURN;
       END IF;
           
    -- check for divide by zero
      IF ( is_zero(divisor_copy, SrcRegMode) )  THEN     -- applying the equality operator
          ASSERT false
          REPORT " SregDiv  ---  divide by zero  "
          SEVERITY ERROR;
          res_copy := (OTHERS => '0');
          result <= res_copy after DefaultSregDelay;
             rem_copy :=  (OTHERS => '0');
             remainder <= rem_copy after DefaultSregDelay; -- remainder is filled with zeros
	     ZeroDivide <= '1' after DefaultSregDelay;	
          RETURN;
      END IF;  

    -- put dividend to rega  and divisor to regd
      rega(dividend'LENGTH - 1 DOWNTO 0) := dividend_copy;          
      regd(divisor'LENGTH - 1 DOWNTO 0) := divisor_copy;  

   -- inputs are  not null so determine the sign and convert 
   -- the inputs to unsigned  representation.
     IF (SrcRegMode /= Unsigned) THEN
        IF (dividend_copy(dividend_copy'LEFT) /= '0') THEN
           neg_res := NOT neg_res;
           neg_rem := NOT neg_rem;          -- sign of dividend is sign of remainder
           rega(dividend'LENGTH - 1 DOWNTO 0) := To_Unsign (dividend_copy, SrcRegMode);     
        END IF;

        IF (divisor_copy(divisor_copy'LEFT) /= '0') THEN
           neg_res := NOT neg_res;
           regd(divisor'LENGTH - 1 DOWNTO 0) := To_Unsign(divisor_copy, SrcRegMode);  
        END IF;
     END IF;
 
   -- Perform division by binary restoring algorithm
   --
   --    initialize 
   -- load rega to regr, 
   -- regd  gets regd shifted left by nd2bits
   -- regb  gets all zerso
   -- 
       regr := rega;                
            -- left shift regd by nd2 ( length of dividend bits, fill with zero's
       RegShift(regd, regd, shiftout, '1', '0', nd2);
       regb := (OTHERS =>'0');

       For i IN 0 TO nd2 - 1 LOOP
                                                -- regr := 2*regr - regd
           RegShift(regr, regr, shiftout, '1', '0', 1);
           RegSub ( result     => regr, 
                    borrow_out => b_out, 
                    overflow   => uvflo2,  
                    minuend    => regr, 
                    subtrahend => regd, 
                    borrow_in  => '0',
                    SrcRegMode => TwosComp
                  );               
                                               -- if regr is negative, then restore
           IF (regr(regr'LEFT) /= '0')   THEN
                                               -- regr := regr + regd
                                               -- regb := 2*regb 
                RegAdd(regr, b_out, uvflo2, regr, regd, '0', TwosComp);
                RegShift(regb, regb, shiftout, '1', '0', 1);
           ELSE
                                                -- regb := 2*regb + 1;
                regShift(regb, regb, shiftout, '1', '0', 1);
                regb := RegInc (regb, Unsigned );
           END IF;

      END LOOP;
     
      -- if the result and remainder should be negative 
        IF (neg_res AND (SrcRegMode /= Unsigned)) THEN
              regb := RegNegate(regb, SrcRegMode);
        END IF;

        IF (neg_rem AND (SrcRegMode /= Unsigned)) THEN
              regr := RegNegate(regr, SrcRegMode);
        END IF;

      -- determine the length of result
        IF (result'LENGTH <= dividend'LENGTH) THEN
           res_copy := regb(result'LENGTH - 1 DOWNTO 0);
            ASSERT (result'LENGTH = dividend'LENGTH) OR (NOT WarningsOn)
            REPORT " SregDiv --- length of result is shorter than dividend "
            SEVERITY WARNING;
        ELSE
                                                -- sign extend the quotient
           res_copy := SignExtend(regb, result'LENGTH, regb'LEFT, SrcRegMode);
        END IF;
                -- remainder is in most significant N bits, shift right N bits 
         RegShift(regr, regr, shiftout, '0', regr(len), nd2);
      -- remainder length
        IF ( remainder'LENGTH <= len ) THEN
            rem_copy := regr(remainder'LENGTH - 1 DOWNTO 0);
            IF (SrcRegMode /= Unsigned) THEN
               rem_copy(result'LENGTH - 1) := regr(result'LENGTH);  -- sign bit
            END IF;	
        ELSE
            rem_copy := SignExtend(regr, remainder'LENGTH, regr'LEFT, SrcRegMode);
        END IF;
        result    <= To_X01(res_copy) after DefaultSregDelay;
        remainder <= To_X01(rem_copy) after DefaultSregDelay;
        ZeroDivide <= '0' after DefaultSregDelay;	

    -- That's all
      RETURN;
    END;

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
--|                      SIGNAL Zflag : BIT;
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
                      ) IS
      VARIABLE res_copy     : BIT_VECTOR(result'LENGTH - 1 DOWNTO 0);
      VARIABLE res          : BIT_VECTOR(result'LENGTH - 1 DOWNTO 0);
      VARIABLE remainderb   : BIT_VECTOR(result'LENGTH - 1 DOWNTO 0);
      VARIABLE divid_copy   : BIT_VECTOR(dividend'LENGTH - 1 DOWNTO 0) := dividend;
      VARIABLE modulus_copy : BIT_VECTOR(modulus'LENGTH - 1 DOWNTO 0) := modulus;
      VARIABLE zeroflag     : BIT;
      VARIABLE c_out        : BIT;
      VARIABLE uvflo        : BIT;

     BEGIN 
     --  
     --   Null range check
     --   if result vector or remainderb vector has a null range
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMod  ---  Destination   has null range. "
             SEVERITY ERROR;
             RETURN;
     --   if both dividend   and modulus   have null range no need to divide
       ELSIF (dividend'LENGTH = 0) AND (modulus'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMod --- both dividend  and modulus has null range "
             SEVERITY ERROR;
             res_copy :=  (OTHERS => '0');
             result <= res_copy after DefaultSregDelay; -- result is filled with zeros
             RETURN;      

     -- if one of the dividend  or divisor is null 
       ELSIF (dividend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMod ---  dividend  has null range "
             SEVERITY ERROR;
                              -- treat dividend as zero so result is zero 
             res_copy := (OTHERS => '0');
             result <= res_copy after DefaultSregDelay;
             RETURN;
       ELSIF (modulus'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMod --- modulus  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             res_copy := (OTHERS => '0');
             result <= res_copy after DefaultSregDelay;
             RETURN;
       END IF;
           
    -- check for divide by zero
      IF ( is_zero(modulus_copy, SrcRegMode) )  THEN     -- applying the equality operator
          ASSERT false
          REPORT " SregMod  ---  divide by zero  "
          SEVERITY ERROR;
          res_copy := (OTHERS => '0');
          result <= res_copy after DefaultSregDelay;
          ZeroDivide <= '1' after DefaultSregDelay;	
          RETURN;
      END IF;  

    -- Use procedure SregDiv to calculate the remainderb
    -- Then mod is calculated
    --
      RegDiv(res, remainderb, zeroflag, divid_copy, modulus_copy, SrcRegMode);
      res_copy := remainderb;
      IF ( (SrcRegMode /= Unsigned) AND ( divid_copy(divid_copy'LEFT) = '0')) THEN 
                                                                  -- dividend positive
          IF ( is_zero(remainderb, SrcRegmode) ) THEN
               null;
          ELSIF (modulus_copy(modulus_copy'LEFT) /= '0') THEN   -- negative modulus
                  RegAdd(res_copy, c_out, uvflo, modulus_copy, remainderb, '0', SrcRegMode); 
          END IF;
      ELSIF ((SrcRegMode /= Unsigned) AND (divid_copy(divid_copy'LEFT) /= '0')) THEN
                                      -- negative dividend
           IF ( is_zero(remainderb, SrcRegmode) ) THEN
              null;
           ELSIF (modulus_copy(modulus_copy'LEFT ) = '0') THEN      -- positive modulus
               RegAdd(res_copy, c_out, uvflo, modulus_copy, remainderb, '0', SrcRegMode);
           END IF;
      END IF;
      result <= res_copy after DefaultSregDelay;  -- copy internal res_copy to result
      ZeroDivide <= '0' after DefaultSregDelay;	

    -- That's all
      RETURN;
    END;

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
    --                      SIGNAL x, y, res, ovf : std_logic_vector ( 15 DOWNTO 0);
    --                      SIGNAL Zflag : std_ulogic;
    --
    --                      SregMod ( res,Zflag, x, y, TwosComp );
    --
    --     See Also       : SregAdd, SregSub, SregMult, SregDiv
    -------------------------------------------------------------------------------
    PROCEDURE SregMod  (SIGNAL result       : OUT std_logic_vector;
                        SIGNAL ZeroDivide   : OUT std_ulogic;  
                        CONSTANT dividend   :  IN std_logic_vector;
                        CONSTANT modulus    :  IN std_logic_vector;
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      ) IS
      VARIABLE res1_copy   : std_logic_vector(result'LENGTH - 1 DOWNTO 0);
      VARIABLE res         : std_logic_vector(result'LENGTH - 1 DOWNTO 0);
      VARIABLE remainderu  : std_logic_vector(result'LENGTH - 1 DOWNTO 0);
      VARIABLE dividnd_cpy : std_logic_vector(dividend'LENGTH - 1 DOWNTO 0) := dividend;
      VARIABLE mod_copy    : std_logic_vector(modulus'LENGTH - 1 DOWNTO 0) := modulus;
      VARIABLE zeroflag    : std_ulogic;
      VARIABLE c_out       : std_ulogic;
      VARIABLE uvflo       : std_ulogic;

     BEGIN 
     --  
     --   Null range check
     --   if result vector null range
       IF (result'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMod  ---  Destination   has null range. "
             SEVERITY ERROR;
             RETURN;
     --   if both dividend   and modulus   have null range no need to divide
       ELSIF (dividend'LENGTH = 0) AND (modulus'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMod --- both dividend  and modulus has null range "
             SEVERITY ERROR;
             res1_copy :=  (OTHERS => '0');
             result <= res1_copy after DefaultSregDelay;  -- result is filled with zeros
             RETURN;      

     -- if one of the dividend  or divisor is null 
       ELSIF (dividend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMod ---  dividend  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             res1_copy := (OTHERS => '0');
             result <= res1_copy after DefaultSregDelay;
             RETURN;
       ELSIF (modulus'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMod --- modulus  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             res1_copy := (OTHERS => '0');
             result <= res1_copy after DefaultSregDelay;
             RETURN;
       END IF;
           
      IF ( is_zero(mod_copy, SrcRegMode) )  THEN     -- applying the equality operator
          ASSERT false
          REPORT " SregMod  ---  divide by zero  "
          SEVERITY ERROR;
          res1_copy := (OTHERS => '0');
          result <= res1_copy after DefaultSregDelay;
          ZeroDivide <= '1' after DefaultSregDelay;	
          RETURN;
      END IF;  

    -- Use procedure SregDiv to calculate the remainderu
    -- Then mod is calculated
    --
      RegDiv(res, remainderu, zeroflag, dividnd_cpy, mod_copy, SrcRegMode);
      res1_copy := remainderu;
      IF ( (SrcRegMode /= Unsigned) AND ( dividnd_cpy(dividnd_cpy'LEFT) = '0')) THEN 
                                                                  -- dividend positive
          IF ( is_zero(remainderu, SrcRegmode) ) THEN
               null;
          ELSIF (mod_copy(mod_copy'LEFT) /= '0') THEN   -- negative modulus
                  RegAdd(res1_copy, c_out, uvflo, mod_copy, remainderu, '0', SrcRegMode); 
          END IF;
      ELSIF ((SrcRegMode /= Unsigned) AND (dividnd_cpy(dividnd_cpy'LEFT) /= '0')) THEN
                                      -- negative dividend
           IF ( is_zero(remainderu, SrcRegmode) ) THEN
              null;
           ELSIF (mod_copy(mod_copy'LEFT) = '0')  THEN    -- positive modulus
               RegAdd(res1_copy, c_out, uvflo, mod_copy, remainderu, '0', SrcRegMode);
           END IF;
      END IF;
      result  <= To_X01(res1_copy) after DefaultSregDelay;
      ZeroDivide <= '0' after DefaultSregDelay;	    

    -- That's all
      RETURN;
    END;

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
    --                      SIGNAL x, y, res, ovf : std_ulogic_vector ( 15 DOWNTO 0);
    --                      SIGNAL Zflag : std_ulogic;
    --
    --                      SregMod ( res, Zflag, x, y, TwosComp );
    --
    --     See Also       : SregAdd, SregSub, SregMult, SregDiv
    -------------------------------------------------------------------------------
    PROCEDURE SregMod  ( SIGNAL result     : OUT std_ulogic_vector;
                        SIGNAL ZeroDivide   : OUT std_ulogic;  
                        CONSTANT dividend   :  IN std_ulogic_vector;
                        CONSTANT modulus    :  IN std_ulogic_vector;
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      ) IS
      VARIABLE res_copy    : std_ulogic_vector(result'LENGTH - 1 DOWNTO 0);
      VARIABLE res         : std_ulogic_vector(result'LENGTH - 1 DOWNTO 0);
      VARIABLE remainderul : std_ulogic_vector(result'LENGTH - 1 DOWNTO 0);
      VARIABLE dividnd_cpy : std_ulogic_vector(dividend'LENGTH - 1 DOWNTO 0) := dividend;
      VARIABLE mod_copy    : std_ulogic_vector(modulus'LENGTH - 1 DOWNTO 0) := modulus;
      VARIABLE zeroflag    : std_ulogic;
      VARIABLE c_out       : std_ulogic;
      VARIABLE uvflo       : std_ulogic;

     BEGIN 
     --  
     --   Null range check
     --   if result vector 
       IF ( result'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMod  ---  Destination   has null range. "
             SEVERITY ERROR;
             RETURN;
     --   if both dividend   and modulus   have null range no need to divide
       ELSIF (dividend'LENGTH = 0) AND (modulus'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMod --- both dividend  and modulus has null range "
             SEVERITY ERROR;
             res_copy :=  (OTHERS => '0');
             result <= res_copy after DefaultSregDelay; -- result is filled with zeros
             RETURN;      

     -- if one of the dividend  or divisor is null 
       ELSIF (dividend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMod ---  dividend  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             res_copy := (OTHERS => '0');
             result <= res_copy after DefaultSregDelay;
             RETURN;
       ELSIF (modulus'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregMod --- modulus  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             res_copy := (OTHERS => '0');
             result <= res_copy after DefaultSregDelay;
             RETURN;
       END IF;
           
    -- check for divide by zero
      IF ( is_zero(mod_copy, SrcRegMode) )  THEN     -- applying the equality operator
          ASSERT false
          REPORT " SregMod  ---  divide by zero  "
          SEVERITY ERROR;
          res_copy := (OTHERS => '0');
          result <= res_copy after DefaultSregDelay;
          ZeroDivide <= '1' after DefaultSregDelay;	
          RETURN;
      END IF;  

    -- Use procedure SregDiv to calculate the remainderul
    -- Then mod is calculated
    --
      RegDiv(res, remainderul, zeroflag, dividnd_cpy, mod_copy, SrcRegMode);
      res_copy := remainderul;
      IF ( (SrcRegMode /= Unsigned) AND ( dividnd_cpy(dividnd_cpy'LEFT) = '0')) THEN 
                                                                  -- dividend positive
          IF ( is_zero(remainderul, SrcRegmode) ) THEN
               null;
          ELSIF (mod_copy(mod_copy'LEFT) /= '0') THEN   -- negative modulus
                  RegAdd(res_copy, c_out, uvflo, mod_copy, remainderul, '0', SrcRegMode); 
          END IF;
      ELSIF ((SrcRegMode /= Unsigned) AND (dividnd_cpy(dividnd_cpy'LEFT) /= '0')) THEN
                                      -- negative dividend
           IF ( is_zero(remainderul, SrcRegmode) ) THEN
              null;
           ELSIF (mod_copy(mod_copy'LEFT) = '0') THEN      -- positive modulus
               RegAdd(res_copy, c_out, uvflo, mod_copy, remainderul, '0', SrcRegMode);
           END IF;
      END IF;
      result  <= To_X01(res_copy) after DefaultSregDelay;
      ZeroDivide <= '0' after DefaultSregDelay;	

    -- That's all
      RETURN;
    END;

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
--|     See Also       : SregAdd, SregSub, SregMult, SregDiv
--|-----------------------------------------------------------------------------
    PROCEDURE SregRem ( SIGNAL result       : OUT BIT_VECTOR;
                        SIGNAL ZeroDivide   : OUT BIT;
                        CONSTANT dividend   :  IN BIT_VECTOR;
                        CONSTANT divisor    :  IN BIT_VECTOR;
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      ) IS
      CONSTANT nd        : INTEGER := dividend'LENGTH;    
      CONSTANT len       : INTEGER := 2 * nd;
      VARIABLE res_copy : BIT_VECTOR(result'LENGTH - 1 DOWNTO 0);
      VARIABLE dividend_copy : BIT_VECTOR(dividend'LENGTH - 1 DOWNTO 0) := dividend;
      VARIABLE divisor_copy  : BIT_VECTOR(divisor'LENGTH - 1 DOWNTO 0) := divisor;
      VARIABLE regr      : BIT_VECTOR(len  DOWNTO 0) := (OTHERS => '0');
      VARIABLE rega      : BIT_VECTOR(len  DOWNTO 0) := (OTHERS => '0');
      VARIABLE regd      : BIT_VECTOR(len  DOWNTO 0) := (OTHERS => '0');
      VARIABLE regb      : BIT_VECTOR(nd - 1 DOWNTO 0);   -- quotient
      VARIABLE neg_res   : Boolean := FALSE;              -- sign of result
      VARIABLE b_out     : BIT;
      VARIABLE uvflo     : BIT;
      VARIABLE shiftout  : BIT;

     BEGIN 
     --  
     --   Null range check
     --   if result vector null range
       IF ( result'LENGTH = 0)  THEN
             ASSERT false
             REPORT " SregRem  ---  Destination   has null range. "
             SEVERITY ERROR;
             RETURN;
     --   if both dividend   and divisor   have null range no need to divide
       ELSIF (dividend'LENGTH = 0) AND (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregRem --- both dividend  and divisor has null range "
             SEVERITY ERROR;
             res_copy :=  (OTHERS => '0');
             result <= res_copy after DefaultSregDelay; -- result is filled with zeros
             RETURN;      

     -- if one of the dividend  or divisor is null 
       ELSIF (dividend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregRem ---  dividend  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             res_copy := (OTHERS => '0');
             result <= res_copy after DefaultSregDelay;
             RETURN;
       ELSIF (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregRem --- divisor  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             res_copy := (OTHERS => '0');
             result <= res_copy after DefaultSregDelay;
             RETURN;
       END IF;
           
    -- check for divide by zero
      IF ( is_zero(divisor_copy, SrcRegMode) )  THEN     -- applying the equality operator
          ASSERT false
          REPORT " SregRem  ---  divide by zero  "
          SEVERITY ERROR;
          res_copy := (OTHERS => '0');
          result <= res_copy after DefaultSregDelay;
          ZeroDivide <= '1' after DefaultSregDelay;	
          RETURN;
      END IF;  

    -- put dividend to rega  and divisor to regd
      rega(dividend'LENGTH - 1 DOWNTO 0) := dividend_copy;          
      regd(divisor'LENGTH - 1 DOWNTO 0) := divisor_copy;  

   -- inputs are  not null so determine the sign and convert 
   -- the inputs to unsigned  representation.
     IF (SrcRegMode /= Unsigned) THEN
        IF (dividend_copy(dividend_copy'LEFT) /= '0') THEN
           neg_res := NOT neg_res;          -- sign od dividend is sign of result
           rega(dividend'LENGTH - 1 DOWNTO 0) := To_Unsign (dividend_copy, SrcRegMode);     
        END IF;

        IF (divisor_copy(divisor_copy'LEFT) /= '0') THEN
           regd(divisor'LENGTH - 1 DOWNTO 0) := To_Unsign(divisor_copy, SrcRegMode);  
        END IF;
     END IF;
 
   -- Perform division by binary restoring algorithm
   --
   --    initialize 
   -- load rega to regr, 
   -- regd  gets regd shifted left by nd bits
   -- regb  gets all zerso
   -- 
       regr := rega;                
            -- left shift regd by nd ( length of dividend) bits, fill with zero's
       RegShift(regd, regd, shiftout, '1', '0', nd);
       regb := (OTHERS => '0');

       For i IN 0 TO nd - 1 LOOP
                                                -- regr := 2*regr - regd
           RegShift(regr, regr, shiftout, '1', '0', 1);
           RegSub ( result     => regr, 
                    borrow_out => b_out, 
                    overflow   => uvflo,  
                    minuend    => regr, 
                    subtrahend => regd, 
                    borrow_in  => '0',
                    SrcRegMode => TwosComp
                  );               
                                               -- if regr is negative, then restore
           IF (regr(regr'LEFT) /= '0')   THEN
                                               -- regr := regr + regd
                                               -- regb := 2*regb 
                RegAdd(regr, b_out, uvflo, regr, regd, '0', TwosComp);
                RegShift(regb, regb, shiftout, '1', '0', 1);
           ELSE
                                                -- regb := 2*regb + 1;
                RegShift(regb, regb, shiftout, '1', '0', 1);
                regb := RegInc (regb, Unsigned);
           END IF;

      END LOOP;
     
      -- if the result and remainder should be negative 
        IF (neg_res AND (SrcRegMode /= Unsigned)) THEN
              regr := RegNegate(regr, SrcRegMode);
        END IF;
          -- most significant of regr holds result
         RegShift(regr, regr, shiftout, '0', regr(len), nd);


      -- determine the length of result
        IF (result'LENGTH <= len) THEN
           res_copy := regr(result'LENGTH - 1 DOWNTO 0);
           IF (SrcRegMode /= Unsigned) THEN
              res_copy(result'LENGTH - 1) := regr(result'LENGTH);  -- sign bit
           END IF;
            ASSERT (result'LENGTH = dividend'LENGTH) OR (NOT WarningsOn)
            REPORT " SregRem --- length of result  is shorter than dividend "
            SEVERITY WARNING;
        ELSE
                                                -- sign extend the remainder
           res_copy := SignExtend(regr, result'LENGTH, regr'LEFT, SrcRegMode);
        END IF;
        result <= res_copy after DefaultSregDelay;
        ZeroDivide <= '0' after DefaultSregDelay;	    
    -- That's all
      RETURN;
    END;

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
    --                      SIGNAL x, y, res : std_logic_vector ( 15 DOWNTO 0);
    --                      SIGNAL Zflag : std_ulogic;
    --
    --                      SregRem ( res, Zflag, x, y, TwosComp );
    --
    --     See Also       : SregAdd, SregSub, SregMult, SregDiv
    -------------------------------------------------------------------------------
    PROCEDURE SregRem ( SIGNAL result       : OUT std_logic_vector;
                        SIGNAL ZeroDivide   : OUT std_ulogic;  
                        CONSTANT dividend   :  IN std_logic_vector;
                        CONSTANT divisor    :  IN std_logic_vector;
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      ) IS
      CONSTANT nd1        : INTEGER := dividend'LENGTH;    
      CONSTANT len       : INTEGER := 2 * nd1;
      VARIABLE res_copy : std_logic_vector(result'LENGTH - 1 DOWNTO 0);
      VARIABLE dividnd_copy : std_logic_vector(dividend'LENGTH - 1 DOWNTO 0) := dividend;
      VARIABLE divisr_copy  : std_logic_vector(divisor'LENGTH - 1 DOWNTO 0) := divisor;
      VARIABLE regr      : std_logic_vector(len DOWNTO 0) := (OTHERS => '0');
      VARIABLE rega      : std_logic_vector(len DOWNTO 0) := (OTHERS => '0');
      VARIABLE regd      : std_logic_vector(len DOWNTO 0) := (OTHERS => '0');
      VARIABLE regb      : std_logic_vector(nd1 - 1 DOWNTO 0);   -- quotient
      VARIABLE neg_res   : Boolean := FALSE;              -- sign of result
      VARIABLE b_out     : std_ulogic;
      VARIABLE uvflo     : std_ulogic;
      VARIABLE shiftout  : std_ulogic;

     BEGIN 
     --  
     --   Null range check
     --   if result vector null range
       IF ( result'LENGTH = 0)  THEN
             ASSERT false
             REPORT " SregRem  ---  Destination   has null range. "
             SEVERITY ERROR;
             RETURN;
     --   if both dividend   and divisor   have null range no need to divide
       ELSIF (dividend'LENGTH = 0) AND (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregRem --- both dividend  and divisor has null range "
             SEVERITY ERROR;
             res_copy :=  (OTHERS => '0');
             result <= res_copy after DefaultSregDelay; -- result is filled with zeros
             RETURN;      

     -- if one of the dividend  or divisor is null 
       ELSIF (dividend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregRem ---  dividend  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             res_copy := (OTHERS => '0');
             result <= res_copy after DefaultSregDelay;
             RETURN;
       ELSIF (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregRem --- divisor  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             res_copy := (OTHERS => '0');
             result <= res_copy after DefaultSregDelay;
             RETURN;
       END IF;
           
    -- check for divide by zero
      IF ( is_zero(divisr_copy, SrcRegMode) )  THEN     -- applying the equality operator
          ASSERT false
          REPORT " SregRem  ---  divide by zero  "
          SEVERITY ERROR;
          res_copy := (OTHERS => '0');
          result <= res_copy after DefaultSregDelay;
          ZeroDivide <= '1' after DefaultSregDelay;	
          RETURN;
      END IF;  

    -- put dividend to rega  and divisor to regd
      rega(dividend'LENGTH - 1 DOWNTO 0) := dividnd_copy;          
      regd(divisor'LENGTH - 1 DOWNTO 0) := divisr_copy;  

   -- inputs are  not null so determine the sign and convert 
   -- the inputs to unsigned  representation.
     IF (SrcRegMode /= Unsigned) THEN
        IF (dividnd_copy(dividnd_copy'LEFT) /= '0') THEN
           neg_res := NOT neg_res;          -- sign od dividend is sign of result
           rega(dividend'LENGTH - 1 DOWNTO 0) := To_Unsign (dividnd_copy, SrcRegMode);     
        END IF;

        IF (divisr_copy(divisr_copy'LEFT) /= '0') THEN
           regd(divisor'LENGTH - 1 DOWNTO 0) := To_Unsign(divisr_copy, SrcRegMode);  
        END IF;
     END IF;
 
   -- Perform division by binary restoring algorithm
   --
   --    initialize 
   -- load rega to regr, 
   -- regd  gets regd shifted left by nd bits
   -- regb  gets all zerso
   -- 
       regr := rega;                
            -- left shift regd by nd ( length of dividend) bits, fill with zero's
       RegShift(regd, regd, shiftout, '1', '0', nd1);
       regb := (OTHERS => '0');

       For i IN 0 TO nd1 - 1 LOOP
                                                -- regr := 2*regr - regd
           RegShift(regr, regr, shiftout, '1', '0', 1);
           RegSub ( result     => regr, 
                    borrow_out => b_out, 
                    overflow   => uvflo,  
                    minuend    => regr,  
                    subtrahend => regd, 
                    borrow_in  => '0',
                    SrcRegMode => TwosComp
                  );               
                                               -- if regr is negative, then restore
           IF (regr(regr'LEFT) /= '0')   THEN
                                               -- regr := regr + regd
                                               -- regb := 2*regb 
                RegAdd(regr, b_out, uvflo, regr, regd, '0', TwosComp);
                RegShift(regb, regb, shiftout, '1', '0', 1);
           ELSE
                                                -- regb := 2*regb + 1;
                Regshift(regb, regb, shiftout, '1', '0', 1);
                regb := RegInc ( regb, Unsigned );
           END IF;

      END LOOP;
     
      -- if the result and remainder should be negative 
        IF (neg_res AND (SrcRegMode /= Unsigned)) THEN
              regr := RegNegate(regr, SrcRegMode);
        END IF;
          -- most significant of regr holds result
         RegShift(regr, regr, shiftout, '0', regr(len), nd1);

      -- determine the length of result
        IF (result'LENGTH <= len) THEN
           res_copy := regr(result'LENGTH - 1 DOWNTO 0);
           IF (SrcRegMode /= Unsigned) THEN
              res_copy(result'LENGTH - 1) := regr(result'LENGTH);  -- sign bit
           END IF;
            ASSERT (result'LENGTH = dividend'LENGTH) OR (NOT WarningsOn)
            REPORT " SregRem --- length of result  is shorter than dividend "
            SEVERITY WARNING;
        ELSE
                                                -- sign extend the remainder
           res_copy := SignExtend(regr, result'LENGTH, regr'LEFT, SrcRegMode);
        END IF;
        result  <= To_X01(res_copy) after DefaultSregDelay;
        ZeroDivide <= '0' after DefaultSregDelay;	    
    -- That's all
      RETURN;
    END;

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
    --     See Also       : SregAdd, SregSub, SregMult, SregDiv
    -------------------------------------------------------------------------------
    PROCEDURE SregRem ( SIGNAL result       : OUT std_ulogic_vector;
                        SIGNAL ZeroDivide   : OUT std_ulogic;  
                        CONSTANT dividend   :  IN std_ulogic_vector;
                        CONSTANT divisor    :  IN std_ulogic_vector;
                        CONSTANT SrcRegMode :  IN regmode_type := DefaultRegMode
                      ) IS
      CONSTANT nd        : INTEGER := dividend'LENGTH;    
      CONSTANT len       : INTEGER := 2 * nd;
      VARIABLE res_copy : std_ulogic_vector(result'LENGTH - 1 DOWNTO 0);
      VARIABLE dividend_copy : std_ulogic_vector(dividend'LENGTH - 1 DOWNTO 0) := dividend;
      VARIABLE divisor_copy  : std_ulogic_vector(divisor'LENGTH - 1 DOWNTO 0) := divisor;
      VARIABLE regr      : std_ulogic_vector(len DOWNTO 0) := (OTHERS => '0');
      VARIABLE rega      : std_ulogic_vector(len DOWNTO 0) := (OTHERS => '0');
      VARIABLE regd      : std_ulogic_vector(len DOWNTO 0) := (OTHERS => '0');
      VARIABLE regb      : std_ulogic_vector(nd - 1 DOWNTO 0);   -- quotient
      VARIABLE neg_res   : Boolean := FALSE;              -- sign of result
      VARIABLE b_out     : std_ulogic;
      VARIABLE uvflo     : std_ulogic;
      VARIABLE shiftout  : std_ulogic;

     BEGIN 
     --  
     --   Null range check
     --   if result vector has a null range
       IF ( result'LENGTH = 0)  THEN
             ASSERT false
             REPORT " SregRem  ---  Destination   has null range. "
             SEVERITY ERROR;
             RETURN;
     --   if both dividend   and divisor   have null range no need to divide
       ELSIF (dividend'LENGTH = 0) AND (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregRem --- both dividend  and divisor has null range "
             SEVERITY ERROR;
             res_copy :=  (OTHERS => '0');
             result <= res_copy after DefaultSregDelay; -- result is filled with zeros
             RETURN;      

     -- if one of the dividend  or divisor is null 
       ELSIF (dividend'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregRem ---  dividend  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             res_copy := (OTHERS => '0');
             result <= res_copy after DefaultSregDelay;
             RETURN;
       ELSIF (divisor'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregRem --- divisor  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             res_copy := (OTHERS => '0');
             result <= res_copy after DefaultSregDelay;
             RETURN;
       END IF;
           
    -- check for divide by zero
      IF ( is_zero(divisor_copy, SrcRegMode) )  THEN     -- applying the equality operator
          ASSERT false
          REPORT " SregRem  ---  divide by zero  "
          SEVERITY ERROR;
          res_copy := (OTHERS => '0');
          result <= res_copy after DefaultSregDelay;
          ZeroDivide <= '1' after DefaultSregDelay;	
          RETURN;
      END IF;  

    -- put dividend to rega  and divisor to regd
      rega(dividend'LENGTH - 1 DOWNTO 0) := dividend_copy;          
      regd(divisor'LENGTH - 1 DOWNTO 0) := divisor_copy;  

   -- inputs are  not null so determine the sign and convert 
   -- the inputs to unsigned  representation.
     IF (SrcRegMode /= Unsigned) THEN
        IF (dividend_copy(dividend_copy'LEFT) /= '0') THEN
           neg_res := NOT neg_res;          -- sign od dividend is sign of result
           rega(dividend'LENGTH - 1 DOWNTO 0) := To_Unsign (dividend_copy, SrcRegMode);     
        END IF;

        IF (divisor_copy(divisor_copy'LEFT) /= '0') THEN
           regd(divisor'LENGTH - 1 DOWNTO 0) := To_Unsign(divisor_copy, SrcRegMode);  
        END IF;
     END IF;
 
   -- Perform division by binary restoring algorithm
   --
   --    initialize 
   -- load rega to regr, 
   -- regd  gets regd shifted left by nd bits
   -- regb  gets all zerso
   -- 
       regr := rega;                
            -- left shift regd by nd ( length of dividend) bits, fill with zero's
       RegShift(regd, regd, shiftout, '1', '0', nd);
       regb := (OTHERS => '0');

       For i IN 0 TO nd - 1 LOOP
                                                -- regr := 2*regr - regd
           RegShift(regr, regr, shiftout, '1', '0', 1);
           RegSub ( result     => regr, 
                    borrow_out => b_out, 
                    overflow   => uvflo,  
                    minuend    => regr, 
                    subtrahend => regd, 
                    borrow_in  => '0',
                    SrcRegMode => TwosComp
                  );               
                                               -- if regr is negative, then restore
           IF (regr(regr'LEFT) /= '0')   THEN
                                               -- regr := regr + regd
                                               -- regb := 2*regb 
                RegAdd(regr, b_out, uvflo, regr, regd, '0', TwosComp);
                RegShift(regb, regb, shiftout, '1', '0', 1);
           ELSE
                                                -- regb := 2*regb + 1;
                RegShift(regb, regb, shiftout, '1', '0', 1);
                regb := RegInc (regb , Unsigned );
           END IF;

      END LOOP;
     
      -- if the result and remainder should be negative 
        IF (neg_res AND (SrcRegMode /= Unsigned)) THEN
              regr := RegNegate(regr, SrcRegMode);
        END IF;
          -- most significant of regr holds result
         RegShift(regr, regr, shiftout, '0', regr(len), nd);

      -- determine the length of result
        IF (result'LENGTH <= len) THEN
           res_copy := regr(result'LENGTH - 1 DOWNTO 0);
           IF (SrcRegMode /= Unsigned) THEN
              res_copy(result'LENGTH - 1) := regr(result'LENGTH);  -- sign bit
           END IF;
            ASSERT (result'LENGTH = dividend'LENGTH) OR (NOT WarningsOn)
            REPORT " SregRem --- length of result  is shorter than dividend "
            SEVERITY WARNING;
        ELSE
                                                -- sign extend the remainder
           res_copy := SignExtend(regr, result'LENGTH, regr'LEFT, SrcRegMode);
        END IF;
        result  <= To_X01(res_copy) after DefaultSregDelay;
        ZeroDivide <= '0' after DefaultSregDelay;	    
    -- That's all
      RETURN;
    END;


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
                     ) IS
--      CONSTANT reslen         : INTEGER := IntegerBitLength;
      	CONSTANT reslen         : INTEGER := result'LENGTH;
      	VARIABLE r              : BIT_VECTOR ( reslen - 1 DOWNTO 0 ) := (OTHERS =>'0');
	VARIABLE r2             : BIT_VECTOR ( reslen - 1 DOWNTO 0 ) := (OTHERS =>'0');
      	VARIABLE result_copy    : BIT_VECTOR (result'LENGTH - 1 DOWNTO 0);
      	VARIABLE base_copy      : BIT_VECTOR ( base'LENGTH - 1 DOWNTO 0 ) := base;
      	VARIABLE exponent_copy  : BIT_VECTOR(exponent'LENGTH  - 1 DOWNTO 0) := exponent;
      	VARIABLE overflo1       : BIT := '0';
      	VARIABLE power          : INTEGER;
      	VARIABLE neg_result     : BOOLEAN := FALSE;
    BEGIN
     --   Null range check
     --   if result vector has a null range
       IF ( result'LENGTH = 0)  THEN
             ASSERT false
             REPORT " SregExp  ---  Destination   has null range. "
             SEVERITY ERROR;
             overflow <= '1' after DefaultSregDelay;
             RETURN;
     --   if both base    and exponent   have null range no need to divide
       ELSIF (base'LENGTH = 0) AND (exponent'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregExp --- both base  and exponent  has null range "
             SEVERITY ERROR;
             result_copy :=  (OTHERS => '0');
             result <= result_copy after DefaultSregDelay;  -- result is filled with zeros
             overflow <= overflo1 after DefaultSregDelay;
             RETURN;      

     -- if one of the base  or exponet is null 
       ELSIF (base'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregExp ---  base  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             result_copy := (OTHERS => '0');
             result <= result_copy after DefaultSregDelay;
             overflow <= overflo1 after DefaultSregDelay;
          
             RETURN;
       ELSIF (exponent'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregExp --- exponent  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             result_copy := (OTHERS => '0');
             result_copy(0) := '1';          -- base raised to the power 0 = 1
             result <= result_copy after DefaultSregDelay;
             overflow <= overflo1 after DefaultSregDelay;
             RETURN;
       END IF;
           
    -- inputs are  not null so determine the sign and convert 
    -- base to unsigned  and exponent to integer
      power := To_Integer (exponent_copy, SrcRegMode );
      IF (( SrcRegMode /= Unsigned) AND (base(base'LEFT) = '1')) THEN
          base_copy := To_Unsign(base, SrcRegMode);
              -- base is a negative number and power is not an even multiple of 2
              -- the result should be negative
          IF ((power mod 2) /= 0) THEN  
              neg_result := NOT neg_result;
          END IF;
     END IF;
     -- multiply the base by itself for the number of times  absoulte 
    --  value of exponent. 
    -- if the exponet (power) is less than zero then
    -- result is zero. 
    -- if power is 0 then result is one

      IF (power < 0) THEN
          ASSERT NOT WarningsOn 
          REPORT " SregExp   ---  negative exponent, returning zero result "
          SEVERITY WARNING;
       ELSIF (power=0 ) THEN            -- result is 1
          r(0) := '1';
       ELSIF (power=1) THEN
          r (base'LENGTH - 1 DOWNTO 0) := base_copy;
       ELSIF (power > 1) THEN
                                     -- set r to 1 and
                                     -- then use repeated multiplication
          r(0) := '1';
          FOR i IN 1 TO power LOOP
              RegMult(r2, overflo1, r, base_copy, Unsigned);
	      r := r2;
              EXIT WHEN (overflo1 /= '0');
          END LOOP;
       END IF;
   
    -- determine sign
     IF  (neg_result   AND (SrcRegMode /= Unsigned))THEN     
        r := RegNegate(r, SrcRegMode);
     END IF;


   -- determine the length of result
     IF (result'LENGTH < reslen) THEN
         result_copy := r(result'LENGTH - 1 DOWNTO 0);
     ELSIF (result'LENGTH = reslen) THEN
         result_copy := r;
     ELSE
                                                -- sign extend the r
         result_copy := SignExtend(r, result'LENGTH, r'LEFT, SrcRegMode);
     END IF;
     result <= result_copy after DefaultSregDelay;
     overflow <= overflo1 after DefaultSregDelay;
    
    -- That's all
      RETURN;
    END;
 
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
                     ) IS
--      CONSTANT reslen         : INTEGER := IntegerBitLength;
        CONSTANT reslen         : INTEGER := result'LENGTH;
      	VARIABLE r              : std_logic_vector ( reslen - 1 DOWNTO 0 ) := (OTHERS =>'0');
	VARIABLE r2             : std_logic_vector ( reslen - 1 DOWNTO 0 ) := (OTHERS =>'0');
      	VARIABLE result_copy    : std_logic_vector (result'LENGTH - 1 DOWNTO 0);
      	VARIABLE base_copy      : std_logic_vector ( base'LENGTH - 1 DOWNTO 0 ) := base;
      	VARIABLE exponent_copy  : std_logic_vector(exponent'LENGTH - 1 DOWNTO 0) := exponent;
      	VARIABLE power          : INTEGER;
      	VARIABLE neg_result     : BOOLEAN := FALSE;
      	VARIABLE overflo        : std_ulogic := '0';
    BEGIN
     --   Null range check
          overflo := '0';
     --   if result vector has a null range
       IF ( result'LENGTH = 0)  THEN
             ASSERT false
             REPORT " SregExp  ---  Destination   has null range. "
             SEVERITY ERROR;
             overflow <= '1' after DefaultSregDelay;
             RETURN;
     --   if both base    and exponent   have null range no need to divide
       ELSIF (base'LENGTH = 0) AND (exponent'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregExp --- both base  and exponent  has null range "
             SEVERITY ERROR;
             result_copy :=  (OTHERS => '0');
             result <= result_copy after DefaultSregDelay;  -- result is filled with zeros
             overflow <= overflo after DefaultSregDelay;             
             RETURN;      

     -- if one of the base  or exponet is null 
       ELSIF (base'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregExp ---  base  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             result_copy := (OTHERS => '0');
             result <= result_copy after DefaultSregDelay;
             overflow <= overflo after DefaultSregDelay;
             RETURN;
       ELSIF (exponent'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregExp --- exponent  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             result_copy := (OTHERS => '0');
             result_copy(0) := '1';          -- base raised to the power 0 = 1
             result <= result_copy after DefaultSregDelay;
             overflow <= overflo after DefaultSregDelay;
             RETURN;
       END IF;
           
    -- inputs are  not null so determine the sign and convert 
    -- base to unsigned  and exponent to integer
      power := To_Integer (exponent_copy, SrcRegMode );
      IF (( SrcRegMode /= Unsigned) AND (base(base'LEFT) = '1')) THEN
          base_copy := To_Unsign(base, SrcRegMode);
              -- base is a negative number and power is not an even multiple of 2
              -- the result should be negative
          IF ((power mod 2) /= 0) THEN  
              neg_result := NOT neg_result;
          END IF;
     END IF;
     -- multiply the base by itself for the number of times  absoulte 
    --  value of exponent. 
    -- if the exponet (power) is less than zero then
    -- result is zero. 
    -- if power is 0 then result is one
      IF (power < 0) THEN
          ASSERT NOT WarningsOn 
          REPORT " SregExp   ---  negative exponent, returning zero result "
          SEVERITY WARNING;
       ELSIF (power=0 ) THEN            -- result is 1
          r(0) := '1';
       ELSIF (power=1) THEN
          r (base'LENGTH - 1 DOWNTO 0) := base_copy;
       ELSIF (power > 1) THEN
                                     -- set r to 1 and
                                     -- then use repeated multiplication
          r(0) := '1';
          FOR i IN 1 TO power LOOP
              RegMult(r2, overflo, r, base_copy, Unsigned);
	      r := r2;
              EXIT when (overflo /= '0');
          END LOOP;
      END IF;
   
    -- determine sign
     IF (neg_result  AND (SrcRegMode /= Unsigned))THEN     
        r := RegNegate(r, SrcRegMode);
     END IF;


      -- determine the length of result
        IF (result'LENGTH < reslen) THEN
           result_copy := r(result'LENGTH - 1 DOWNTO 0);
        ELSIF (result'LENGTH = reslen) THEN
            result_copy := r;
        ELSE
                                                -- sign extend the r
           result_copy := SignExtend(r, result'LENGTH, r'LEFT, SrcRegMode);
        END IF;
        result   <= To_X01(result_copy) after DefaultSregDelay;
        overflow <= To_X01(overflo) after DefaultSregDelay;
    
    -- That's all
      RETURN;
    END;

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
--|     See Also       : SregMult, SregDiv, RegInc, RegDec, RegNegate
--|-----------------------------------------------------------------------------
    PROCEDURE SregExp ( SIGNAL result     : OUT std_ulogic_vector;
                       SIGNAL overflow   : OUT std_ulogic;
                       CONSTANT base       : IN std_ulogic_vector;
                       CONSTANT exponent   : IN std_ulogic_vector;
                       CONSTANT SrcRegMode : IN regmode_type := DefaultRegMode
                     ) IS
--      CONSTANT reslen         : INTEGER := IntegerBitLength;
      	CONSTANT reslen         : INTEGER := result'LENGTH;
      	VARIABLE r              : std_ulogic_vector ( reslen - 1 DOWNTO 0 ) := (OTHERS =>'0');
	VARIABLE r2             : std_ulogic_vector ( reslen - 1 DOWNTO 0 ) := (OTHERS =>'0');
      	VARIABLE result_copy    : std_ulogic_vector(result'LENGTH - 1 DOWNTO 0);
      	VARIABLE base_copy      : std_ulogic_vector( base'LENGTH - 1 DOWNTO 0 ) := base;
      	VARIABLE exponent_copy  : std_ulogic_vector(exponent'LENGTH - 1 DOWNTO 0) := exponent;
      	VARIABLE power          : INTEGER;
      	VARIABLE neg_result     : BOOLEAN := FALSE;
      	VARIABLE overflo2       : std_ulogic := '0';
    BEGIN
     --   Null range check
          overflo2 := '0';
     --   if result vector has a null range
       IF ( result'LENGTH = 0)  THEN
             ASSERT false
             REPORT " SregExp  ---  Destination   has null range. "
             SEVERITY ERROR;
             overflow <= '1' after DefaultSregDelay;
             RETURN;
     --   if both base    and exponent   have null range no need to divide
       ELSIF (base'LENGTH = 0) AND (exponent'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregExp --- both base  and exponent  has null range "
             SEVERITY ERROR;
             result_copy :=  (OTHERS => '0');
             result <= result_copy after DefaultSregDelay;               -- result is filled with zeros
             overflow <= overflo2 after DefaultSregDelay;
             RETURN;      

     -- if one of the base  or exponet is null 
       ELSIF (base'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregExp ---  base  has null range "
             SEVERITY ERROR;
                                 -- treat dividend as zero so result is zero 
             result_copy := (OTHERS => '0');
             result <= result_copy after DefaultSregDelay;
             overflow <= overflo2 after DefaultSregDelay;
             RETURN;
       ELSIF (exponent'LENGTH = 0) THEN
             ASSERT false
             REPORT " SregExp --- exponent  has null range "
             SEVERITY ERROR;
                                 -- treat result as zero 
             result_copy := (OTHERS => '0');
             result_copy(0) := '1';          -- base raised to the power 0 = 1
             result <= result_copy after DefaultSregDelay;
             overflow <= overflo2 after DefaultSregDelay;
             RETURN;
       END IF;
           
    -- inputs are  not null so determine the sign and convert 
    -- base to unsigned  and exponent to integer
      power := To_Integer (exponent_copy, SrcRegMode );
      IF (( SrcRegMode /= Unsigned) AND (base(base'LEFT) = '1')) THEN
          base_copy := To_Unsign(base, SrcRegMode);
              -- base is a negative number and power is not an even multiple of 2
              -- the result should be negative
          IF ((power mod 2) /= 0) THEN  
              neg_result := NOT neg_result;
          END IF;
     END IF;
     -- multiply the base by itself for the number of times  absoulte 
    --  value of exponent. 
    -- if the exponet (power) is less than zero then
    -- result is zero. 
    -- if power is 0 then result is one
      IF (power < 0) THEN
          ASSERT NOT WarningsOn 
          REPORT " SregExp   ---  negative exponent, returning zero result "
          SEVERITY WARNING;
       ELSIF (power = 0 ) THEN            -- result is 1
          r(0) := '1';
       ELSIF (power=1) THEN
          r (base'LENGTH - 1 DOWNTO 0) := base_copy;
       ELSIF (power > 1) THEN
                                     -- set r to 1 and
                                     -- then use repeated multiplication
          r(0) := '1';
          FOR i IN 1 TO power LOOP
              RegMult(r2, overflo2, r, base_copy, Unsigned);
	      r := r2;
              EXIT when (overflo2 /= '0');
          END LOOP;
      END IF;
   
    -- determine sign
     IF (neg_result  AND (SrcRegMode /= Unsigned))THEN     
        r := RegNegate(r, SrcRegMode);
     END IF;

  -- determine the length of result
    IF (result'LENGTH < reslen) THEN
         result_copy := r(result'LENGTH - 1 DOWNTO 0);
    ELSIF (result'LENGTH = reslen) THEN
         result_copy := r;
    ELSE
                                                -- sign extend the r
         result_copy := SignExtend(r, result'LENGTH, r'LEFT, SrcRegMode);
    END IF;
        result   <= To_X01(result_copy) after DefaultSregDelay;
        overflow <= To_X01(overflo2) after DefaultSregDelay;
    
    -- That's all
      RETURN;
    END;


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

   PROCEDURE SRegShift  ( CONSTANT SrcReg    : IN bit_vector;
                          SIGNAL   DstReg    : INOUT bit_vector;
                          SIGNAL   ShiftO    : INOUT bit; 
                          CONSTANT direction : IN bit   := '1';
                          CONSTANT FillVal   : IN bit   := '0';
                          CONSTANT Nbits     : IN Natural      := 1
                       ) IS

      variable temp1 : bit_vector(DstReg'RANGE) := DstReg;
      variable temp2 : bit := ShiftO;
		       
   BEGIN
      RegShift ( SrcReg    => SrcReg,
	         DstReg    => temp1,
		 ShiftO	   => temp2,
		 direction => direction,
		 FillVal   => FillVal,
		 Nbits	   => Nbits );
      DstReg <= temp1;
      ShiftO <= temp2;
   END;
   
--+-----------------------------------------------------------------------------
--|     Function Name  : SregShift
--| 
--|     Overloading    : None
--|
--|     Purpose        : Bidirectional logical shift operator for logic vector.
--|
--|     Parameters     :
--|                      SrcReg      - input  std_logic_vector, vector to be shifted
--|                      DstReg      - inout, std_logic_vector, shifted result
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

   PROCEDURE SRegShift  ( CONSTANT SrcReg    : IN std_logic_vector;
                          SIGNAL   DstReg    : INOUT std_logic_vector;
                          SIGNAL   ShiftO    : INOUT std_ulogic; 
                          CONSTANT direction : IN std_ulogic   := '1';
                          CONSTANT FillVal   : IN std_ulogic   := '0';
                          CONSTANT Nbits     : IN Natural      := 1
                       ) IS

      variable temp1 : std_logic_vector(DstReg'RANGE) := DstReg;
      variable temp2 : std_ulogic := ShiftO;
		       
   BEGIN
      RegShift ( SrcReg    => SrcReg,
	         DstReg    => temp1,
		 ShiftO	   => temp2,
		 direction => direction,
		 FillVal   => FillVal,
		 Nbits	   => Nbits );
      DstReg <= temp1;
      ShiftO <= temp2;
   END;   

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
 
   PROCEDURE SRegShift  ( CONSTANT SrcReg    : IN std_ulogic_vector;
                          SIGNAL   DstReg    : INOUT std_ulogic_vector;
                          SIGNAL   ShiftO    : INOUT std_ulogic; 
                          CONSTANT direction : IN std_ulogic   := '1';
                          CONSTANT FillVal   : IN std_ulogic   := '0';
                          CONSTANT Nbits     : IN Natural      := 1
                       ) IS

      variable temp1 : std_ulogic_vector(DstReg'RANGE) := DstReg;
      variable temp2 : std_ulogic := ShiftO;
		       
   BEGIN
      RegShift ( SrcReg    => SrcReg,
	         DstReg    => temp1,
		 ShiftO	   => temp2,
		 direction => direction,
		 FillVal   => FillVal,
		 Nbits	   => Nbits );
      DstReg <= temp1;
      ShiftO <= temp2;
   END;   


END std_regpak;          
