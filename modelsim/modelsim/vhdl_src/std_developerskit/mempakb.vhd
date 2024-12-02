-- ----------------------------------------------------------------------------
--
--  Copyright (c) Mentor Graphics Corporation, 1982-1996, All Rights Reserved.
--                       UNPUBLISHED, LICENSED SOFTWARE.
--            CONFIDENTIAL AND PROPRIETARY INFORMATION WHICH IS THE
--          PROPERTY OF MENTOR GRAPHICS CORPORATION OR ITS LICENSORS.
--
-- PackageName : std_mempak  (stand alone)
-- Title       : Standard Memory Package
-- Purpose     : This package supports the development of the following
--             : memory types :
--             : a. DRAMS
--             : b. SRAMS
--             : c. ROMS
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
--   Version No:| Author:    |  Mod. Date:| Changes Made:
--     v1.000   | wrm        |  12/02/91  | first version
--     v1.100   | wrm        |  01/11/92  | correction to sram and rom initialize
--     v1.102   | wrm        |  02/19/92  | correction to address_trans. so that it
--                                        |    properly handles address with mismatching
--                                        |    bit width
--                                        | correction to mem_load to handle default 
--                                        |    word of improper length
--                                        | correction to memdump - it sometimes missed
--                                        |    the last word
--                                        | minor modification to some assertion 
--                                        |    statements
--     v1.110   | mkd        |  03/06/92  | production release
--     v1.200   | mkd        |  04/21/92  | stand alone version
--     v1.300   | mkd        |  08/03/92  | production release
--     v1.310   | wrm        |  10/05/92  | modification to work around synopsys problems
--              |            |            | fix bug in mem_load's parser's error-handler
--     v1.400   | mkd        |  11/06/92  | production release
--     v1.500   | mkd        |  11/17/92  | production release
--     v1.600   | mkd        |  02/11/93  | production release
--     v1.610   | wrm        |  04/14/93  | production release - no change from v1.60
--     v1.700 B | wrm        |  05/03/93  | beta release  - fixed memory leakage problem
--     v1.700   | wrm        |  05/25/93  | production release  - fixed mti 4.0 B problem
--                                        | 'Length for NULL length arrays may not return 0
--                                        | added flag to mem_dump to allow header not to be printed
--     v1.800   | wrm        |  08/03/93  | from_hex_to_int bug fixed and modifications for mentor support
--     v1.810 B | wrm        |  11/15/93  | Video Ram addition - Beta Version
--                                        | addition of writing of sim time in Mem_Dump
--                           |  12/20/93  | Modification of Mem_Block_Write. RdTrans, Split_RdTrans
--                                        | return Xs when invalid row is specified.
--     v2.000   |            |  07/21/94  | production release - Video Rams added for all supported simulators
--     v2.100   | wrm        |  01/10/96  | Kludge for Synopsys 3.3b bug
--					  | Initialization banner removed
--     v2.2     | bmc        |  07/25/96  | Updated for Mentor Graphics Release
-- ----------------------------------------------------------------------------
 
Library ieee;
Use     ieee.STD_Logic_1164.all; -- Reference the STD_Logic system
Library STD;
Use     STD.TEXTIO.all;

PACKAGE BODY std_mempak is

 -- ************************************************************************
 -- Display Banner
 -- ************************************************************************

    FUNCTION DisplayBanner return BOOLEAN is

    BEGIN
       ASSERT FALSE
           report LF &
		  "--  Initializing Std_Developerskit (Std_Mempak package v2.10)" & LF &
		  "--  Copyright by Mentor Graphics Corporation" & LF &
		  "--  [Please ignore any warnings associated with this banner.]"
           severity NOTE;
       return TRUE;
    END;

    --CONSTANT StdMempakBanner : BOOLEAN := DisplayBanner;
    CONSTANT StdMempakBanner : BOOLEAN := TRUE;	

    Type D1_b_ulogic_type is array(bit) of std_ulogic;
    type hex_ray is array(1 to 16) of character;
    type IDENTIFIER is (HEX_NUM1, COMMENT1, WIDTH1, DEFAULT1, COLON1, DOTDOT1, BLANK1, SYN_ERROR1);
    type digit_to_hex_type is array(0 to 15) of character;

    -- mentor doesn't like the subtype UX01  -  "resolved sybyte cannot be used as a discrete range"
    type UX01_1DRAY is array(std_ulogic range 'U' to '1') of bit;

    -------------------------------------------------------------------------------------------
    --  THE FOLLOWING CONSTANTS MAY BE CHANGED BY THE USER TO CUSTOMIZE STD_MEMPAK
    -------------------------------------------------------------------------------------------

    -- defines the number of bits used to represent an integer on the machine used to run the vhdl simulator
    CONSTANT IntegerBitLength : INTEGER := 32;

    -- defines the maximum length of strings in this package

    CONSTANT MAX_STR_LEN : NATURAL := 256;

    -- constants used to map X's and U's  in an address to valid values
    
    CONSTANT ADDRESS_X_MAP : BIT := '1';
    CONSTANT ADDRESS_U_MAP : BIT := '1';
    CONSTANT ADDRESS_MAP : UX01_1DRAY :=
                           (ADDRESS_U_MAP, ADDRESS_X_MAP, '0', '1');

    -- constants used to map X's and U's in memory locations to a bit value 
    -- when a bit or a bit_vector is returned by the memory read operation
    
    CONSTANT DATA_X_MAP : BIT := '1';
    CONSTANT DATA_U_MAP : BIT := '1';
    CONSTANT DATA_MAP : UX01_1DRAY :=
                        (DATA_U_MAP, DATA_X_MAP, '0', '1');

    -- constants setting collumn size of SRAM's and ROM's so that entire
    -- memory does not have to be allocated if it is not used.
    
    CONSTANT SRAM_COL_SIZE : NATURAL := 1024;
    CONSTANT ROM_COL_SIZE : NATURAL := 1024;

    -- constant used to enable/disable certain warning assertions
    CONSTANT MEM_WARNINGS_ON : BOOLEAN := TRUE;

    -- constant used to determine how many words per line to output when doing a memory dump
    CONSTANT WORDS_PER_LINE : POSITIVE := 16;

    -- constant used to determine if the time of a memory dump is written to the output file when Mem_Dump is called
    CONSTANT MEM_DUMP_TIME : BOOLEAN := TRUE;

    -- constant that enables the use of write per bit, Mem_Set_WPB_Mask, Mem_Block_Write, Mem_Row_Write with memories other than VRAMs
    CONSTANT EXTENDED_OPS : BOOLEAN := FALSE;


    ----------------------------------------------------------------------------------------------------------
    -- CONSTANTS THAT SHOULD NOT BE MODIFIED
    -- These are used by the package to perform various conversions, comparisions, etc.
    ----------------------------------------------------------------------------------------------------------

    CONSTANT DIGIT_TO_HEX : digit_to_hex_type := ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
    CONSTANT hex : hex_ray := ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
    CONSTANT bit_to_std_ulogic : D1_b_ulogic_type := ('0', '1');
    CONSTANT SPACESTR : STRING(1 to 20) := "                    ";
    CONSTANT SPACE : CHARACTER :=  ' ';
    CONSTANT TAB   : CHARACTER := HT;

-- ------------------------------------------------------------------------------
-- This routines are used for a synopsys 3.3b bug fix
-- ------------------------------------------------------------------------------
FUNCTION Get_WPB_Mask( CONSTANT Width    : IN integer;
		       CONSTANT WPB_Mask : IN std_logic_vector ) return std_logic_vector IS

BEGIN
   return WPB_Mask(width - 1 downto 0);
END;

FUNCTION assign_wpb_mask ( CONSTANT wpb_mask : IN std_logic_vector;
			   CONSTANT width    : IN integer;
			   CONSTANT mem_word : IN std_logic_vector ) return std_logic_vector IS

	variable wpb_mask_alias : std_logic_vector(wpb_mask'length - 1 downto 0) := wpb_mask;
BEGIN
	wpb_mask_alias(width - 1 downto 0) := mem_word;
	return wpb_mask_alias;
END;
    


function StrLen1 ( Constant l_str : IN string ) return NATURAL is

Variable alias_l_str : string(1 to l_str'length) := l_str;
Variable i : integer := 1;

begin
    while ( (i <= l_str'length) and (alias_l_str(i) /= NUL) ) loop
        i := i + 1;
    end loop;
    i := i - 1;
    return i;
end;    

function to_str (Constant dd : IN std_logic) return Character is

begin
    case dd is
        when '1' => return '1';
        when '0' => return '0';
        when 'U' => return 'U';
        when 'X' => return 'X';
        when 'L' => return 'L';
        when 'H' => return 'H';
        when '-' => return '-';
        when 'Z' => return 'Z';
        when 'W' => return 'W';
    end case;
end;

function to_str (Constant dd : IN bit) return character is

begin
  if dd = '0' then
      return '0';
  else
      return '1';
  end if;
end;
    
function i_to_str (Constant int : IN integer) return string is

Constant length : integer := 33;
Variable i, len, pos : integer;
Variable str : string (1 to length);
Variable tint : integer := int;
Variable temp : Character;
Variable negative : BOOLEAN := FALSE;

begin
   for i in 1 to  length loop
     str(i) := ' ';
   end loop;
   if (tint < 0 ) then
      tint := -tint;
      negative := TRUE;
   end if;
   i := length;
   while (  (i >= 1 ) and (tint /= 0)) loop
       str(i) := CHARACTER'Val(48 + (tint mod 10));
       tint := tint/10;
       i := i - 1;
   end loop;
   if (NEGATIVE) then
      str(i) := '-';
      i := i - 1;
   end if;
   len := length - i;
   pos := i + 1;
   for i in 1 to len loop
     str(i) := str(pos);
     pos := pos + 1;
   end loop;
   if (len = 0) then
       len := 1;
       str(1) := '0';
   end if;
   return  (str(1 to len));
   
end;

function v_to_str  (Constant vect : IN bit_vector) return string is

Variable str : string( 1 to vect'length);
Variable alias_vect : bit_vector(1 to vect'length) := vect;
Variable i : integer;

begin
    for i in 1 to vect'length loop
        case alias_vect(i) is
          when '1' => str(i) := '1';
          when '0' => str(i) := '0';
        end case;
    end loop;
    return(str);
end;


function v_to_str  (Constant vect : IN std_logic_vector) return string is

Variable str : string( 1 to vect'length);
Variable alias_vect : std_logic_vector(1 to vect'length) := vect;
Variable i : integer;

begin
    for i in 1 to vect'length loop
        case alias_vect(i) is
          when '1' => str(i) := '1';
          when '0' => str(i) := '0';
          when 'U' => str(i) := 'U';
          when 'X' => str(i) := 'X';
          when 'L' => str(i) := 'L';
          when 'H' => str(i) := 'H';
          when '-' => str(i) := '-';
          when 'Z' => str(i) := 'Z';
          when 'W' => str(i) := 'W';
        end case;
    end loop;
    return(str);
end;

-- used to return a printable string for the memory name
function pstr ( Constant name : in string ) return string is

   variable j : integer;

begin
   j := 1;
   while ( (j < name'length) and (name(j) /= nul) ) loop
      j := j + 1;
   end loop;
   if (name(j) = nul) then
      j := j - 1;
   end if;
   return name(1 to j);
end;



    ---------------------------------------------------------------------------
    --    Function Name   :  minimum
    --
    --    PURPOSE         :  to determine the smaller of two integers
    --                       
    --    Parameters      :  int1 - first integer
    --                    :  int2 - second integer
    --
    --    Returned Value  :  integer - the smaller of int1 and int2
    --
    ---------------------------------------------------------------------------

    Function minimum ( Constant int1 : IN integer;
                       Constant int2 : IN integer
                     ) return integer is

    begin
         if (int1 < int2) then
            return int1;
        else
            return int2;
        end if;
    end;

--+-----------------------------------------------------------------------------
--|     Procedure Name : StrCpy1
--| 1.2.3
--|     Overloading    : None
--|
--|     Purpose        : Copy r_string to l_string.
--|
--|     Parameters     :
--|                      l_str    - output,  STRING, target string
--|                      r_str    - input, STRING, source string
--|
--|     Result         : 
--|
--|     NOTE           : If the length of target string is greater than
--|                      the source string, then target string is padded
--|                      with space characters on the right side and when
--|                      the length of target string is shorter than the 
--|                      length of source string only left most characters
--|                      of the source string will be be copied to the target.
--|                      
--| 
--|     USE            :
--|                      Variable s1: string(1 TO 8);
--|
--|                       StrCpy1(s1, "123456789A");
--|                       s1 will hold "12345678"      
--|-----------------------------------------------------------------------------
    PROCEDURE StrCpy1   ( VARIABLE l_str : OUT STRING;
                          CONSTANT r_str : IN  STRING) IS
       VARIABLE  l_len     : integer := l_str'LENGTH;
       VARIABLE  r_len     : integer := r_str'LENGTH;
       VARIABLE  r         : STRING ( 1 to r_len) := r_str;
       VARIABLE result     : STRING (1 to l_len);
       VARIABLE indx       : integer := 1;
    BEGIN
       assert (l_len > 0)
          report "StrCpy:  target string is of zero length "
          severity ERROR;
              
       while ( (indx <= r_len) and (indx <= l_len) and (r(indx) /= NUL) ) loop
          result(indx) := r(indx);
          indx := indx + 1;
       end loop;
       if (indx <= l_len) then
          result(indx) := NUL;
       end if;
       l_str := result;
       return;
    END StrCpy1;

    

--+---------------------------------------------------------------------------
--|     Procedure Name : fgetline1
--| 
--|     Overloading    : None
--|
--|     Purpose        : To read a line from the input TEXT file and 
--|                      save into a string. 
--|
--|     Parameters     :
--|                         l_str    -- output, STRING,
--|                         stream   -- input, TEXT, input file 
--|
--|     result         : string.
--|
--|     Note:          : The TEXT is defined in the package TEXTIO to be 
--|                      a  file of string.
--|     USE:           :
--|                      VARIABLE  line_buf : string(1 TO 256);
--|                      FILE      in_file : TEXT IS IN "file_text_in.dat";
--|                      
--|                        fgetline1(line_buf, in_file);
--|
--|                       Will read a line  from the file
--|                       file_text_in.dat  and place  into  line_buf.
--|
--|-----------------------------------------------------------------------------
   PROCEDURE fgetline1  ( VARIABLE l_str    : OUT STRING;
                         VARIABLE stream   : IN TEXT;
                         VARIABLE line_ptr : INOUT LINE
                       ) IS
        VARIABLE str_copy   : STRING(1 TO MAX_STR_LEN + 1);
        VARIABLE ch         : character;
        VARIABLE indx       : NATURAL := 0;
   BEGIN
      If ( (line_ptr /= NULL) and (line_ptr'LENGTH > 0) ) then
          NULL;
      elsif ( not ENDFILE(stream) ) then
         READLINE(stream, line_ptr);
      else
         assert NOT MEM_WARNINGS_ON
            report " fgetline1 --- end of file text,  no text read "
            severity WARNING;
         l_str(l_str'left) := NUL;
         return;
      end if;
      while ( (line_ptr /= NULL) and (line_ptr'length /= 0) ) loop
         READ(line_ptr,ch);
         indx := indx + 1;
         str_copy(indx) := ch;
      end loop;
      str_copy(indx + 1) := NUL;
      strcpy1(l_str, str_copy);
      return;
   END;

   

--+----------------------------------------------------------------------------- 
--|     Function Name  : Is_White1
--| hidden.
--|     Overloading    : None 
--|  
--|     Purpose        : Test whether a character is a blank, a tab or 
--|                      a newline character.
--|
--|     Parameters     : 
--|                      c     - input   Character.
--| 
--|     Result         :Booelan -- True if the argument c is a blank or a tab(HT), 
--|                     or a line feed (LF), or carriage return (CR). false otherwise.   
--| 
--| 
--|     See Also       : Is_Space
--|----------------------------------------------------------------------------- 
     FUNCTION  Is_White1  ( CONSTANT c    : IN CHARACTER
                         ) RETURN BOOLEAN IS
         VARIABLE result : BOOLEAN;
     BEGIN
        IF ( (c = ' ') OR (c = HT)  OR (c = CR) OR (c=LF) ) THEN
             result := TRUE;
        ELSE
             result := FALSE;
        END IF;
        RETURN result;

     END; 
    
--+-----------------------------------------------------------------------------
--|     Function Name  : Find_NonBlank1
--| hidden 
--|     Overloading    : None
--|
--|     Purpose        : Find first non_blank character in a string.
--|
--|     Parameters     :
--|                      str_in    - input ,  
--|
--|     Result         : Natural, index of non_blank character. If string
--|                      has all the white character then str_in'LENGTH is
--|                      returned;
--|
--|     NOTE           :
--|
--|     Use            :
--|                      VARIABLE s_flag : String(1 TO 10) := "      TRUE"; 
--|                      VARIABLE idx: Natural 
--|
--|                       idx := Find_NonBlank1 (s_flag);
--|
--|-----------------------------------------------------------------------------
   FUNCTION Find_NonBlank1  ( CONSTANT str_in   : IN STRING
                           ) RETURN NATURAL IS
      VARIABLE str_copy :  STRING (1 TO str_in'LENGTH) := str_in;
      VARIABLE index    :  Natural := 1;
      VARIABLE ch       :  character;
       
    BEGIN
          loop
            EXIT WHEN (index > str_in'LENGTH);
            if Is_White1(str_copy(index)) then
                index := index + 1;
            else
                EXIT;
            end if;
          end loop;
          return index;
--      
-- old code
-- 
--        ch := str_copy(index);
--        while ( ( index < str_in'LENGTH) AND (Is_White1(ch) ) ) LOOP
--        	index := index + 1;
--              ch := str_copy(index);
--        end LOOP;
--        return index;
    END;

--+----------------------------------------------------------------------------- 
--|     Function Name  : To_Upper1
--| 1.
--|     Overloading    : None 
--|  
--|     Purpose        :Convert a string to upper case.
--|
--|     Parameters     : 
--|                      val     - input, string to be converted   
--| 
--|     Result         :  string .
--| 
--| 
--|     See Also       : To_Lower, Is_Upper, Is_Lower
--|----------------------------------------------------------------------------- 
    FUNCTION  To_Upper1  ( CONSTANT  val    : IN String
                         ) RETURN STRING IS
        VARIABLE result   : string (1 TO val'LENGTH) := val;
        VARIABLE ch       : character;
    BEGIN
        FOR i IN 1 TO val'LENGTH LOOP
            ch := result(i);
            EXIT WHEN ((ch = NUL) OR (ch = nul));
            IF ( ch >= 'a' and ch <= 'z') THEN
    	          result(i) := CHARACTER'VAL( CHARACTER'POS(ch) 
                                       - CHARACTER'POS('a')
                                       + CHARACTER'POS('A') );
            END IF;
    	END LOOP;
    	RETURN result;
    END To_Upper1;
    
--+-----------------------------------------------------------------------------
--|     Function Name  : From_HexString1
--| 
--|     Overloading    : None
--|
--|     Purpose        : Convert  from a Hex String to a bit_vector.
--|
--|     Parameters     :
--|                      str     - input ,  Hex string to be converted,
--|
--|     Result         : bit_vector
--|
--|     NOTE           : 
--|
--|     Use            :
--|                      VARIABLE b_vect : bit_vector( 15 DOWNTO 4) ; 
--|
--|                       b_vect := From_HexString1 ("   3DD   1010");
--|                       This statement will set b_vect  equal to "001111011101".
--|
--|-----------------------------------------------------------------------------
    FUNCTION From_HexString1   ( CONSTANT str   : IN STRING
                               ) RETURN bit_vector IS

      CONSTANT len         : Integer := 4 * str'LENGTH;
      CONSTANT hex_dig_len : Integer := 4;
      VARIABLE str_copy    : STRING (1 TO str'LENGTH) := To_Upper1(str);
      VARIABLE index       : Natural;
      VARIABLE ch          : character;
      VARIABLE i, idx      : Integer;
      VARIABLE invalid     : boolean := false;
      VARIABLE r           : bit_vector(1 TO len) ;
      VARIABLE result      : bit_vector(len - 1 DOWNTO 0) ;
      CONSTANT BIT_ZERO    : bit_vector(1 to 4) := "0000";
      CONSTANT BIT_ONE     : bit_vector(1 to 4) := "0001";
      CONSTANT BIT_TWO     : bit_vector(1 to 4) := "0010";
      CONSTANT BIT_THREE   : bit_vector(1 to 4) := "0011";
      CONSTANT BIT_FOUR    : bit_vector(1 to 4) := "0100";
      CONSTANT BIT_FIVE    : bit_vector(1 to 4) := "0101";
      CONSTANT BIT_SIX     : bit_vector(1 to 4) := "0110";
      CONSTANT BIT_SEVEN   : bit_vector(1 to 4) := "0111";
      CONSTANT BIT_EIGHT   : bit_vector(1 to 4) := "1000";
      CONSTANT BIT_NINE    : bit_vector(1 to 4) := "1001";
      CONSTANT BIT_TEN     : bit_vector(1 to 4) := "1010";
      CONSTANT BIT_ELEVEN  : bit_vector(1 to 4) := "1011";
      CONSTANT BIT_TWELVE  : bit_vector(1 to 4) := "1100";
      CONSTANT BIT_THIRTEEN: bit_vector(1 to 4) := "1101";
      CONSTANT BIT_FOURTEEN: bit_vector(1 to 4) := "1110";
      CONSTANT BIT_FIFTEEN : bit_vector(1 to 4) := "1111";
       
    BEGIN
      -- Check for null input
        IF (str'LENGTH = 0) THEN
		assert false
		report " From_HexString1  --- input string has zero length ";
                RETURN "";

        ELSIF  (str(str'LEFT) = NUL) THEN
		assert false
		report " From_HexString1  --- input string has nul character"
                        & " at the LEFT position "
                severity ERROR;
                RETURN "";  -- null  bit_vector
	END IF;
        -- find the position of the first non_white character
        index := Find_NonBlank1(str_copy);
        IF (index > str'length) THEN
		assert false
		report " From_HexString1  --- input string is empty  ";
                RETURN ""; 
        ELSIF (str_copy(index)=NUL) THEN
		assert false report " From_HexString1  -- first non_white character is a NUL ";
                RETURN "";
        END IF;

        i := 0;
        FOR idx IN index TO  str'length LOOP
		ch := str_copy(idx);
                EXIT WHEN ((Is_White1(ch)) OR (ch = NUL));                
		CASE ch IS
	          WHEN '0'        => r(i+1 TO i+ hex_dig_len) := BIT_ZERO;
        	  WHEN '1'        => r(i+1 TO i+ hex_dig_len) := BIT_ONE;
        	  WHEN '2'        => r(i+1 TO i+ hex_dig_len) := BIT_TWO;
        	  WHEN '3'        => r(i+1 TO i+ hex_dig_len) := BIT_THREE;
        	  WHEN '4'        => r(i+1 TO i+ hex_dig_len) := BIT_FOUR;
        	  WHEN '5'        => r(i+1 TO i+ hex_dig_len) := BIT_FIVE;
        	  WHEN '6'        => r(i+1 TO i+ hex_dig_len) := BIT_SIX;
        	  WHEN '7'        => r(i+1 TO i+ hex_dig_len) := BIT_SEVEN;
        	  WHEN '8'        => r(i+1 TO i+ hex_dig_len) := BIT_EIGHT;
        	  WHEN '9'        => r(i+1 TO i+ hex_dig_len) := BIT_NINE;
        	  WHEN 'A' | 'a'  => r(i+1 TO i+ hex_dig_len) := BIT_TEN;
        	  WHEN 'B' | 'b'  => r(i+1 TO i+ hex_dig_len) := BIT_ELEVEN;
        	  WHEN 'C' | 'c'  => r(i+1 TO i+ hex_dig_len) := BIT_TWELVE;
        	  WHEN 'D' | 'd'  => r(i+1 TO i+ hex_dig_len) := BIT_THIRTEEN;
        	  WHEN 'E' | 'e'  => r(i+1 TO i+ hex_dig_len) := BIT_FOURTEEN;
        	  WHEN 'F' | 'f'  => r(i+1 TO i+ hex_dig_len) := BIT_FIFTEEN;
       	  	  WHEN NUL        => exit;
        	  WHEN OTHERS  	  => -- a non  binary value was passed
       	  	                     invalid := TRUE;
         	       		     ASSERT FALSE
                                     REPORT "From_HexString1(str(" & i_to_str(idx) & ") => " 
                                     & ch & ") is an invalid character"
	                	     SEVERITY ERROR;
       	       	END CASE;
                i := i + hex_dig_len;
	END LOOP;
     -- check for invalid character in the string
        if ( invalid ) THEN
           r(1 TO i) := (OTHERS => '0');
        end if;
        result(i - 1 DOWNTO 0) := r(1 TO i);
        return result(i - 1 DOWNTO 0);     -- return slice of result

    END;

    -------------------------------------------------------------------------------
    --     Function Name  : RegFill1
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
    --                      vect := RegFill1 ( "00000101", 16, 'U');
    --
    --     See Also       : SignExtend
   -------------------------------------------------------------------------------
    FUNCTION RegFill1   ( CONSTANT SrcReg      : IN std_logic_vector;
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
            REPORT " RegFill1 --- input  has null range and" &
                " Destination also has null range. "
            SEVERITY ERROR;
            RETURN result ; 
         ELSE
            ASSERT FALSE
            REPORT " RegFill1 --- input  has null range"
            SEVERITY ERROR;
            result := (OTHERS => FillVal);
            RETURN result ; 
         END IF;
 
      ELSIF (DstLength = 0) THEN
          ASSERT false
          REPORT "RegFill1 --- Destination has null range "
          SEVERITY ERROR;
          RETURN result;   
 
      ELSIF (DstLength <= SrcReg'LENGTH) THEN
                        -- no need to sign extend
         ASSERT (DstLength = SrcReg'LENGTH)
         REPORT " RegFill1 ---  Destination length is less than source"
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
  --|     Function Name  : bv_To_StdLogicVector
  --|
  --|     Overloading    : 
  --|
  --|     Purpose        : Translate a BIt_VECTOR into an std_logic_vector.
  --|
  --|     Parameters     : SrcVect - input  bit_vector , the value to be 
  --|                                       translated.
  --|                      width   - input  NATURAL, length of the return vector.
  --|                                Default is IntegerBitLength (Machine integer length).
  --|
  --|     Result        : Std_logic_vector.
  --|
  --|     NOTE          : ****** this function not visible to the user **********
  --|-----------------------------------------------------------------------------

  -- ****  function modified so as not to produce an assertion for a zero length vector
  
  FUNCTION bv_To_StdLogicVector ( CONSTANT SrcVect  : IN Bit_Vector;
                                  CONSTANT width    : IN Natural := 0
                                ) RETURN Std_Logic_Vector IS
                                
   VARIABLE len        : INTEGER := SrcVect'LENGTH;
   VARIABLE result     : Std_Logic_Vector(width - 1 DOWNTO 0) := (OTHERS=>'0');
   VARIABLE loc_res    : Std_Logic_Vector(len  - 1 DOWNTO 0) := (OTHERS =>'0');
   VARIABLE vect_copy : Bit_Vector(len - 1 DOWNTO 0) := SrcVect;
     
   BEGIN

       IF (SrcVect'LENGTH = 0) THEN

         return loc_res;

       ELSE
           FOR i IN 0 TO len - 1  LOOP
              CASE vect_copy(i) IS 
                 WHEN '0'   =>
                                loc_res(i) := '0';
                 WHEN '1'   =>
                                loc_res(i) := '1';
              END CASE;
           END LOOP;  
           
           IF (width = 0)  THEN
               return loc_res;
           ELSIF (width <= SrcVect'LENGTH) THEN
               result := loc_res(width - 1 DOWNTO 0);
           ELSIF (width > SrcVect'LENGTH) THEN
               result := RegFill1(loc_res, width, '0');
           END IF;
           RETURN result;
        
       END IF;

    END;
    

    FUNCTION bv_to_hexstr ( CONSTANT val      : IN BIT_VECTOR
                          )  RETURN STRING IS
                          
      CONSTANT hex_len : integer := (val'LENGTH + 3) / 4;
      VARIABLE bin_str : STRING(1 to val'LENGTH);
      VARIABLE hex_str : STRING(1 to hex_len);
      VARIABLE hex_char : STRING(1 to 4);
      VARIABLE bit_index : integer;
      VARIABLE extended_bin_str : STRING(1 to hex_len * 4) := (others => '0');

            
    BEGIN
      bin_str := v_to_str (val);
      if ( (val'LENGTH mod 4) /= 0 ) then
         extended_bin_str ( 5 - (val'LENGTH mod 4) to hex_len * 4 ) := bin_str;
      else
         extended_bin_str := bin_str;
      end if;
      FOR i IN 1 TO hex_len LOOP
        bit_index := ((i - 1) * 4) + 1;
        hex_char := extended_bin_str(bit_index To bit_index + 3);
        CASE hex_char IS
          WHEN "0000" => hex_str(i) := '0'; 
	  WHEN "0001" => hex_str(i) := '1'; 
	  WHEN "0010" => hex_str(i) := '2'; 
	  WHEN "0011" => hex_str(i) := '3'; 
	  WHEN "0100" => hex_str(i) := '4'; 
	  WHEN "0101" => hex_str(i) := '5'; 
	  WHEN "0110" => hex_str(i) := '6'; 
	  WHEN "0111" => hex_str(i) := '7'; 
          WHEN "1000" => hex_str(i) := '8'; 
          WHEN "1001" => hex_str(i) := '9'; 
	  WHEN "1010" => hex_str(i) := 'A'; 
	  WHEN "1011" => hex_str(i) := 'B'; 
	  WHEN "1100" => hex_str(i) := 'C'; 
	  WHEN "1101" => hex_str(i) := 'D'; 
          WHEN "1110" => hex_str(i) := 'E'; 
	  WHEN "1111" => hex_str(i) := 'F'; 
          WHEN OTHERS => null; 
        END CASE;
      END LOOP;
      return (hex_str);
 
    END;
    
    ---------------------------------------------------------------------------
    --    Function Name   :  vector_size
    --
    --    PURPOSE         :  to determine the maximum number of bits needed to
    --                       represent an integer
    --
    --    Parameters      :  int - integer whose bit width is determined
    --
    --    Returned Value  :  NATURAL - # of bits needed
    --
    ---------------------------------------------------------------------------    

    function vector_size ( Constant int : IN integer ) return natural is

    variable i : integer := int;
    variable size : integer := 0;

    begin
        while i > 0 loop
            i := i / 2;
            size := size + 1;
        end loop;
        return size;
    end;
    
    ---------------------------------------------------------------------------
    --    Function Name   :  from_natural
    --
    --    PURPOSE         :  convert a natural number to an unsigned vector
    --                       
    --
    --    Parameters      :  data  - Natural number to be converted
    --                       size  - length of bit vector to be returned
    --
    --    Returned Value  :  vector(size - 1 downto 0)
    --
    ---------------------------------------------------------------------------    

    Function from_natural ( Constant data : IN NATURAL;
                            Constant size : IN NATURAL
                          ) return bit_vector is

        variable vect : bit_vector(size - 1 downto 0);
        variable temp : NATURAL := data;
     begin
        for i in 0 to size - 1 loop
           if ( (temp mod 2) = 0 ) then
              vect(i) := '0';
           else
              vect(i) := '1';
           end if;
           temp := temp / 2;
        end loop;
        assert ( temp = 0 )
           report "From_Natural(bit_vector):  size of returned vector to small to represent natural number"
           severity ERROR;
        return vect;
     end;
                           
    Function from_natural ( Constant data : IN NATURAL;
                            Constant size : IN NATURAL
                          ) return std_logic_vector is

        variable vect : std_logic_vector(size - 1 downto 0);
        variable temp : NATURAL := data;
     begin
        for i in 0 to size - 1 loop
           if ( (temp mod 2) = 0 ) then
              vect(i) := '0';
           else
              vect(i) := '1';
           end if;
           temp := temp / 2;
        end loop;
        return vect;
        assert ( temp = 0 )
           report "From_Natural(std_logic_vector):  size of returned vector to small to represent natural number"
           severity ERROR;
     end;
                           
    Function from_natural ( Constant data : IN NATURAL;
                            Constant size : IN NATURAL
                          ) return std_ulogic_vector is

        variable vect : std_ulogic_vector(size - 1 downto 0);
        variable temp : NATURAL := data;
     begin
        for i in 0 to size - 1 loop
           if ( (temp mod 2) = 0 ) then
              vect(i) := '0';
           else
              vect(i) := '1';
           end if;
           temp := temp / 2;
        end loop;
        assert ( temp = 0 )
           report "From_Natural(std_ulogic_vector):  size of returned vector to small to represent natural number"
           severity ERROR;
        return vect;
     end;
                           
    ---------------------------------------------------------------------------
    --    Function Name   :  address_trans
    --
    --    Purpose         :  to translate an address in vector form to a
    --                       NATURAL.  Indicate if vector is too long or
    --                       too short to represent address
    --
    --    Parameters      :  mem_length  - size of address space
    --                       addr        - address to be translated
    --                       assert_name - name of address space
    --
    --    Returned Value  :  NATURAL - address as a natural number
    --
    --    NOTE            :  *****  this procedure is NOT user visible *******
    --
    --    Use             :  address_trans(addr)
    ---------------------------------------------------------------------------

    Function address_trans ( Constant mem_length  : IN POSITIVE;
                             Constant addr        : IN std_logic_vector;
                             Constant assert_name : IN string := "memory"
                           ) return NATURAL is

    Variable nad, power : NATURAL;
    Variable uonce : BOOLEAN := TRUE;
    Variable xonce : BOOLEAN := TRUE;
    Variable vect_size : integer := vector_size(mem_length - 1);
    Variable talias_addr : std_logic_vector(addr'length - 1 downto 0) := To_UX01(addr);
    Variable alias_addr : std_logic_vector(vect_size - 1 downto 0) := (others => To_StdULogic(ADDRESS_X_MAP));
    Variable temp_vect : bit_vector(vect_size - 1 downto 0);    
                                                      
    begin
        nad := 0;
        power := 1;
        alias_addr( minimum(vect_size, addr'length)  - 1 downto 0) :=
                                                 talias_addr( minimum(vect_size,addr'length) - 1 downto 0 );
        assert ( (vect_size >= addr'length) or NOT MEM_WARNINGS_ON )
            report "Width of vector greater than that needed to access the entire " & assert_name & " address space."
                   & LF & SPACESTR & "passed vector bit width:  " & i_to_str(addr'length)
                   & LF & SPACESTR & "required vector bit width:  " & i_to_str(vect_size)
            severity WARNING;
        assert ( (vect_size <= addr'length) or NOT MEM_WARNINGS_ON )
            report "Width of vector less than that needed to access the entire " & assert_name & " address space."
                   & LF & SPACESTR & "Resulting X's being mapped to:  " & to_str(ADDRESS_X_MAP)
                   & LF & SPACESTR & "passed vector bit width:  " & i_to_str(addr'length)
                   & LF & SPACESTR & "required vector bit width:  " & i_to_str(vect_size)
            severity WARNING;
            
        for i IN 0 to vect_size - 1 loop
            if ((alias_addr(i) = 'U') and MEM_WARNINGS_ON and uonce) then
                uonce := FALSE;
                assert FALSE
                   report "Address vector contains a U - it is being mapped to:  " & to_str(ADDRESS_U_MAP)
                          severity WARNING;
            end if;
            if ((alias_addr(i) = 'X') and MEM_WARNINGS_ON and xonce) then
                xonce := FALSE;
                assert false
                   report "Address vector contains an X - it is being mapped to:  " & to_str(ADDRESS_X_MAP)
                          severity WARNING;
            end if;
            temp_vect(i) := ADDRESS_MAP(alias_addr(i));
            nad := nad + (power * bit'pos(temp_vect(i)));
            power := power * 2;
        end loop;
        return nad;
    end;
           
    Function address_trans ( Constant mem_length  : IN POSITIVE;
                             Constant addr        : IN std_ulogic_vector;
                             Constant assert_name : IN STRING := "memory"
                           ) return NATURAL is

    Variable nad, power : NATURAL;
    Variable uonce : BOOLEAN := TRUE;
    Variable xonce : BOOLEAN := TRUE;
    Variable talias_addr : std_ulogic_vector(addr'length - 1 downto 0) := To_UX01(addr);    
    Variable vect_size : integer := vector_size(mem_length - 1);
    Variable alias_addr : std_ulogic_vector(vect_size - 1 downto 0) := (others => To_StdULogic(ADDRESS_X_MAP));
    Variable temp_vect : bit_vector(vect_size - 1 downto 0);
                                                      
    begin
        nad := 0;
        power := 1;
        alias_addr( minimum(vect_size, addr'length)  - 1 downto 0) :=
                                                       talias_addr( minimum(vect_size,addr'length) - 1 downto 0);
        assert ( (vect_size >= addr'length) or NOT MEM_WARNINGS_ON )
            report "Width of vector greater than that needed to access the entire " & assert_name & " address space."
                   & LF & SPACESTR & "passed vector bit width:  " & i_to_str(addr'length)
                   & LF & SPACESTR & "required vector bit width:  " & i_to_str(vect_size)
            severity WARNING;
        assert ( (vect_size <= addr'length) or NOT MEM_WARNINGS_ON )
            report "Width of vector less than that needed to access the entire " & assert_name & " address space."
                   & LF & SPACESTR & "Resulting X's being mapped to:  " & to_str(ADDRESS_X_MAP)            
                   & LF & SPACESTR & "passed vector bit width:  " & i_to_str(addr'length)
                   & LF & SPACESTR & "required vector bit width:  " & i_to_str(vect_size)
            severity WARNING;
            
        for i IN 0 to vect_size - 1 loop
            if ((alias_addr(i) = 'U') and MEM_WARNINGS_ON and uonce) then
                uonce := FALSE;
                assert false
                   report "Address vector contains a U - it is being mapped to:  " & to_str(ADDRESS_U_MAP)
                          severity WARNING;
            end if;
            if ((alias_addr(i) = 'X') and MEM_WARNINGS_ON and xonce) then
                xonce := FALSE;
                assert false
                   report "Address vector contains an X - it is being mapped to:  " & to_str(ADDRESS_X_MAP)
                          severity WARNING;
            end if;
            temp_vect(i) := ADDRESS_MAP(alias_addr(i));
            nad := nad + (power * bit'pos(temp_vect(i)));
            power := power * 2;
        end loop;
        return nad;
    end;                           

    Function address_trans ( Constant mem_length  : IN POSITIVE;
                             Constant addr        : IN bit_vector;
                             Constant assert_name : IN STRING := "memory"
                           ) return NATURAL is

    Variable nad, power : NATURAL;
    Variable vect_size : integer := vector_size(mem_length - 1);
    Variable talias_addr : bit_vector(addr'length - 1 downto 0) := addr;        
    Variable alias_addr : bit_vector(vect_size - 1 downto 0) := (others => ADDRESS_X_MAP);
                                                      
    begin
        nad := 0;
        power := 1;
        alias_addr( minimum(vect_size, addr'length)  - 1 downto 0) :=
                                                   talias_addr( minimum(vect_size,addr'length) - 1 downto 0);
        if ( MEM_WARNINGS_ON and (vect_size > addr'length) ) then
            assert false
                report "Width of vector less than that needed to access the entire " & assert_name & " address space."
                       & LF & SPACESTR & "Resulting X's being mapped to:  " & to_str(ADDRESS_X_MAP)
                       & LF & SPACESTR & "passed vector bit width:  " & i_to_str(addr'length)
                       & LF & SPACESTR & "required vector bit width:  " & i_to_str(vect_size)
                severity WARNING;
        elsif ( MEM_WARNINGS_ON and (vect_size < addr'length) ) then
            assert false
                report "Width of vector greater than that needed to access the entire " & assert_name & " address space."
                       & LF & SPACESTR & "passed vector bit width:  " & i_to_str(addr'length)
                       & LF & SPACESTR & "required vector bit width:  " & i_to_str(vect_size)
                severity WARNING;
        end if;
        for i in 0 to vect_size - 1 loop
            nad := nad + (power * bit'pos(alias_addr(i)));
            power := power * 2;
        end loop;
        return nad;
    end;
    
    ---------------------------------------------------------------------------
    --    Function Name   :  data_trans
    --
    --    Purpose         :  to translate memory data to a bit_vector
    --
    --    Parameters      :  data    - address to be translated
    --
    --    Returned Value  :  bit_vector translation of ROM data
    --
    --    NOTE            :  *****  this procedure is NOT user visible *******
    --
    --    Use             :  data_trans(addr)
    ---------------------------------------------------------------------------

    function data_trans (Constant data : IN std_logic_vector
                        ) return bit_vector is

    Constant alias_data  : std_logic_vector(data'length - 1 downto 0) := data;
    Variable temp_vect   : bit_vector(data'length - 1 downto 0);
    Variable uonce : BOOLEAN := TRUE;
    Variable xonce : BOOLEAN := TRUE;
    
    begin
        for i IN 0 to data'length - 1 loop
            if ((alias_data(i) = 'U') and  MEM_WARNINGS_ON and uonce) then
                uonce := FALSE;
                assert false
                   report "Memory data contains a U - it is being mapped to:  " & to_str(DATA_U_MAP)
                   severity WARNING;
            end if;
            if ((alias_data(i) = 'X') and  MEM_WARNINGS_ON and xonce) then
                xonce := FALSE;
                assert false
                   report "Memory data contains an X - it is being mapped to:  " & to_str(DATA_X_MAP)
                   severity WARNING;
            end if;
            temp_vect(i) := DATA_MAP(alias_data(i));
        end loop;
        return temp_vect;
    end;
    
    function data_trans (Constant data : IN std_ulogic
                        ) return bit is

    
    begin
        assert ((data /= 'U') or NOT MEM_WARNINGS_ON)
               report "Memory data contains a U - it is being mapped to:  "
                      & to_str(DATA_U_MAP)
                      severity WARNING;
        assert ((data /= 'X') or NOT MEM_WARNINGS_ON)
               report "Memory data contains an X - it is being mapped to:  "
                      & to_str(DATA_X_MAP)
                      severity WARNING;
        return DATA_MAP(data);
    end;                        


    ---------------------------------------------------------------------------
    --    Procedure Name  :  allocate_row
    --
    --    Purpose         :  to allocate a row of memory and initialize it
    --                       to the default value
    --
    --    Parameters      :  mem_id  -  ptr to memory data structure
    --                       row     -  row to be allocated
    --
    --    NOTE            :  allocate data space for 1 row of memory
    --                       ******  this procedure is NOT user visible *******
    --
    --    Use             :  allocate_row (ram1, 5);
    ---------------------------------------------------------------------------

    procedure allocate_row (  Variable mem_id  :  INOUT mem_id_type;
                              Constant row     :  IN NATURAL
                           ) is

        subtype constrained_matrix is
                     row_matrix (0 to mem_id.columns-1, 0 to mem_id.width-1);
        variable ptr : rowptr_type;
        variable i, j : integer;
        
    begin
        
        if mem_id.row_data_ptr(row).all_xs then    -- if row should be filled with X's then do so

            mem_id.row_data_ptr(row).rowptr := new constrained_matrix'( others => (others => 'X'));

        else                                       -- otherwise, row should be filled with the default

            mem_id.row_data_ptr(row).rowptr := new constrained_matrix;

            ptr := mem_id.row_data_ptr(row).rowptr;
            for i in 0 to mem_id.columns - 1 loop
                for j in 0 to mem_id.width - 1 loop
                    ptr(i,j) := To_UX01(mem_id.default(j));
                end loop;
            end loop;
        end if;
        -- no longer necessary to indicate that its filled with X's
        mem_id.row_data_ptr(row).all_xs := FALSE;   
    end;                           

    ---------------------------------------------------------------------------
    --    Procedure Name  :  validate_row
    --
    --    Purpose         :  if memory is a DRAM then check if refresh period
    --                       has expired.  If so, and space allocated, then
    --                       reset all locations to X's.  This is done by setting
    --                       the filed all_xs to TRUE
    --
    --    Parameters      :  mem_id   -  pointer to memory data structure
    --                       row      -  row to be validated
    --
    --    NOTE            :  ******  this procedure is NOT user visible *******
    --
    --    Use             :  validate_row (dram1, 5);
    ---------------------------------------------------------------------------

    Procedure validate_row (  Variable mem_id   : INOUT mem_id_type;
                              Constant row      : IN NATURAL
                           ) IS 

    Variable rowdat : row_data_ptr_type := mem_id.row_data_ptr;
    Variable i, j : INTEGER;
                           
    begin
        -- check that it is a dram or vram and that refresh period has expired
        if ( ((mem_id.memory_type = DRAM)  or (mem_id.memory_type = VRAM)) and (NOW > (rowdat(row).last_refresh + mem_id.refresh_period)) ) then
            if rowdat(row).all_xs then
                -- if all_xs is true already then only an assertion is necessray
                assert NOT MEM_WARNINGS_ON
                    report "Refresh time has expired on row " & i_to_str(row) & " of memory:  "
                           & pstr(mem_id.name(1 to mem_id.name'length)) & LF & SPACESTR & "however, row was not filled with valid data."
                    severity WARNING;
            elsif rowdat(row).rowptr = NULL then
                -- if all_xs is false and no space has been allocated for this row then it must be at default
                -- set all_xs to true and make an assertion
                rowdat(row).all_xs := TRUE;
                assert NOT MEM_WARNINGS_ON
                    report "Refresh time has expired on row " & i_to_str(row) & " of memory:  "
                           & pstr(mem_id.name(1 to mem_id.name'length)) & LF & SPACESTR & "Row was filled with default value."
                    severity WARNING;
            else
                -- row has valid, non-default data in it
                -- set all_xs to true and deallocate space for row
                rowdat(row).all_xs := TRUE;
                deallocate(mem_id.row_data_ptr(row).rowptr);
                mem_id.row_data_ptr(row).rowptr := NULL;
                assert NOT MEM_WARNINGS_ON
                    report "Refresh time has expired on row " & i_to_str(row) & " of memory:  "
                           & pstr(mem_id.name(1 to mem_id.name'length)) & LF & SPACESTR & "Data is lost."
                    severity WARNING;
            end if;
        end if;
    end;

    ---------------------------------------------------------------------------
    --    Procedure Name  :  refresh_row
    --
    --    Purpose         :  if memory is a DRAM then update the last_refresh
    --                       time along with last time used (last_init)
    --
    --    Parameters      :  mem_id   -  pointer to memory data structure
    --                       row      -  row to be refreshed
    --
    --    NOTE            :  ******  this procedure is NOT user visible *******
    --
    --    Use             :  refresh_row (dram1, 5);
    ---------------------------------------------------------------------------

    Procedure refresh_row ( VARIABLE mem_id  :  INOUT mem_id_type;
                            Constant row     :  IN NATURAL
                           ) is

    begin
        if ( ( (mem_id.memory_type = DRAM) or (mem_id.memory_type = VRAM)) and (mem_id.last_init + mem_id.refresh_period >= NOW)) then
            mem_id.row_data_ptr(row).last_refresh := NOW;
            mem_id.last_init := NOW;
        end if;
    end;

    ---------------------------------------------------------------------------
    --    Procedure       :  Mem_Row_Refresh
    --
    --    Purpose         :  if memory is a DRAM then refresh a row checking to
    --                       see if the refresh period has expired
    --
    --    Parameters      :  mem_id    -  pointer to memory data structure
    --                       row       -  row to be refreshed
    --
    --    NOTE            :  used in RAS only refresh
    --
    --    USE             :  Mem_Row_Refresh (dram_l1, "101011110");
                                      
    ---------------------------------------------------------------------------

    
    -- this is the basic procedure.  All other overloaded Mem_Row_Refreshes call this one
    
    Procedure Mem_Row_Refresh (  Variable mem_id     :  INOUT mem_id_type;
                                 Constant row        :  NATURAL
                              ) IS

    begin
        if (mem_id.memory_type = DRAM) or (mem_id.memory_type = VRAM) then  -- make sure that your refereshing a dram or vram
            if ( (mem_id.last_init + mem_id.refresh_period) >= NOW) then  -- make sure device is woken up
                if (row < mem_id.rows) then   -- make sure your refreshing a valid address
                    validate_row (mem_id, row);
                    refresh_row (mem_id, row);
                else
                    assert false
                        report "Mem_Row_Refresh:  specified row is greater than row range of memory:  "
                               & pstr(mem_id.name(1 to mem_id.name'length))
                        severity ERROR;
                end if;
            else
                assert NOT MEM_WARNINGS_ON
                    report "Mem_Row_Refresh:  Device wake-up time limit exceeded for memory:  "
                           & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR &
                           "Operation ignored, device must be woken up."
                    severity WARNING;
            end if;
        else
            assert false
                   report "Mem_Row_Refresh:  attempt to refresh a SRAM or ROM.  No operation will be performed."
                   severity ERROR;
        end if;
    end;
    
    Procedure Mem_Row_Refresh (  Variable mem_id     :  INOUT mem_id_type;
                                 Constant row        :  bit_vector
                              ) IS

    begin
        Mem_Row_Refresh (mem_id, address_trans(mem_id.rows, row) );
    end;
    
    Procedure Mem_Row_Refresh (  Variable mem_id     :  INOUT mem_id_type;
                                 Constant row        :  std_logic_vector
                              ) IS

    begin
        Mem_Row_Refresh (mem_id, address_trans(mem_id.rows, row) );
    end;
    
    Procedure Mem_Row_Refresh (  Variable mem_id     :  INOUT mem_id_type;
                                 Constant row        :  std_ulogic_vector
                              ) IS

    begin
        Mem_Row_Refresh (mem_id, address_trans(mem_id.rows, row) );
    end;

                                      
    ---------------------------------------------------------------------------    
    --    Function Name   :  DRAM_Initialize
    --
    --    Purpose         :  To create the data structure used to store a
    --                       dynamic RAM and to initialize it
    --
    --    Parameters      :  name    - string used to represent the memory
    --                       rows    - the # of rows in the memory
    --                       columns - the number of "words" in each row
    --                       width   - the length of a "word" of memory
    --                       refresh_period - max time between refresh of each
    --                                        row that will maintain valid data
    --                       default_word   - value to which each word of
    --                                        memory should be initialized
    --
    --    RETURNED VALUE  :  mem_id_type - pointer to memory record
    --
    --    NOTE            :  initially the data structure is empty with no
    --                       space being allocated for the memory
    --
    --    Use             :  dram1 := DRAM_Initialize ("lsb_of_RAM", 512, 2048, 1, 8 ms, "1");
    --                                        
    ---------------------------------------------------------------------------
        
    Function DRAM_Initialize ( Constant name            : IN string;
                               Constant rows            : IN POSITIVE;
                               Constant columns         : IN POSITIVE;
                               Constant width           : IN POSITIVE;
                               Constant refresh_period  : IN TIME;
                               Constant default_word    : IN std_logic_vector
                             ) return mem_id_type IS

    Variable i, name_len : INTEGER;
    Variable mem_id : mem_id_type;
    Variable alias_name : string (1 to name'length) := name;

    begin
        -- create and initialize data structure

        mem_id := new mem_id_rtype '( memory_type => DRAM,
                                      refresh_period => refresh_period,
                                      last_init => NOW - refresh_period - 100 ns,
                                      counter => 0,
                                      name => NULL,
                                      rows => rows,
                                      columns => columns,
                                      width => width,
                                      length => rows * columns,
                                      row_data_ptr => NULL,
                                      default => NULL,
                                      sam_columns => 1,
                                      sam_lower_tap => 0,
                                      sam_upper_tap => 0,
                                      serial_ptr => 0,
                                      block_size => 1,
                                      wpb_mask => NULL,
                                      sam_data => NULL                                      
                                     );

        -- put name of memory into data structure
        name_len := 1;
        while ( (name_len <= alias_name'length) and (alias_name(name_len) /= nul)) loop
           name_len := name_len + 1;
        end loop;
        name_len := name_len - 1;

        mem_id.name := new string(1 to name_len);

        for i in 1 to name_len loop
           mem_id.name(i) := alias_name(i);
        end loop;
        -- initialize row data

        mem_id.row_data_ptr := new row_data(0 to rows - 1);

        for i in 0 to rows - 1 loop
            mem_id.row_data_ptr(i) := (last_refresh => NOW,
                                       rowptr => NULL,
                                       all_xs => TRUE
                                      );
        end loop;
        -- set default word

        mem_id.default := new std_logic_vector(mem_id.width - 1 downto 0);

        if (default_word'length /= mem_id.width) then
            assert (default_word'length = 0)
                report "DRAM_INITIALIZE:  Default word width does not match word width of memory:  "
                       & pstr(mem_id.name(1 to mem_id.name'length)) & LF & SPACESTR 
                       & "default will be set to a word filled with 'U'"
                severity ERROR;
            for i in 0 to mem_id.width - 1 loop
                mem_id.default(i) := 'U';
            end loop;
        else

            mem_id.default.all := To_X01(default_word);

        end if;

        -- set wpb_mask

        mem_id.wpb_mask := new std_logic_vector(mem_id.width - 1 downto 0);

        for i in 0 to mem_id.width - 1 loop
           mem_id.wpb_mask(i) := '1';
        end loop;
        
        return mem_id;
           
    end;


    Function DRAM_Initialize ( Constant name            : IN string;
                               Constant rows            : IN POSITIVE;
                               Constant columns         : IN POSITIVE;
                               Constant width           : IN POSITIVE;
                               Constant refresh_period  : IN TIME;
                               Constant default_word    : IN std_ulogic_vector
                             ) return mem_id_type IS

    Variable mem_id : mem_id_type;

    begin
        mem_id := DRAM_Initialize ( name,
                                    rows,
                                    columns,
                                    width,
                                    refresh_period,
                                    std_logic_vector(default_word)
                                  );
        return mem_id;
    end;


    Function DRAM_Initialize ( Constant name            : IN string;
                               Constant rows            : IN POSITIVE;
                               Constant columns         : IN POSITIVE;
                               Constant width           : IN POSITIVE;
                               Constant refresh_period  : IN TIME;
                               Constant default_word    : IN bit_vector
                             ) return mem_id_type IS

    Variable mem_id : mem_id_type;

    begin


        mem_id := DRAM_Initialize ( name,
                                    rows,
                                    columns,
                                    width,
                                    refresh_period,
                                    bv_to_StdLogicVector(default_word, default_word'length)
                                  );
        return mem_id;
    end;

                                         
    ---------------------------------------------------------------------------
    --    Function Name   :  SRAM_Initialize
    --
    --    Purpose         :  To create the data structure used to store a
    --                       static RAM and to initialize it
    --
    --    Parameters      :  name    - string used to represent the memory
    --                       length  - the number of "words" in the memory
    --                       width   - the length of a "word" of memory
    --                       default_word   - value to which each word of
    --                                        memory should be initialized
    --
    --    RETURNED VALUE  :  mem_id_type - pointer to memory record
    --
    --    NOTE            :  initially the data structure is empty with no
    --                       space being allocated for the memory
    --
    --    Use             :  SRAM_Initialize (sram_l1,"lsb_of_RAM",1048576,1);
    ---------------------------------------------------------------------------
        
    Function SRAM_Initialize ( Constant name            : IN string;
                               Constant length          : IN POSITIVE;
                               Constant width           : IN POSITIVE;
                               Constant default_word    : IN std_logic_vector
                             ) return mem_id_type IS

    Variable i, name_len : INTEGER;
    Variable mem_id : mem_id_type;
    Variable alias_name : string (1 to name'length) := name;
                              
    begin
        -- create and initialize data structure

        mem_id := new mem_id_rtype '( memory_type => SRAM,
                                      refresh_period => 0.0 ns,
                                      last_init => 0.0 ns,
                                      counter => 0,
                                      name => NULL,
                                      rows => 1,
                                      columns => SRAM_COL_SIZE,
                                      width => width,
                                      length => length,
                                      row_data_ptr => NULL,
                                      default => NULL,
                                      sam_columns => 1,
                                      sam_lower_tap => 0,
                                      sam_upper_tap => 0,
                                      serial_ptr => 0,
                                      block_size => 1,
                                      wpb_mask => NULL,
                                      sam_data => NULL
                                     );

        if ( (length mod SRAM_COL_SIZE) /= 0) then
           mem_id.rows := (length/SRAM_COL_SIZE) + 1;
        else
           mem_id.rows := length/SRAM_COL_SIZE;
        end if;
        -- store name of memory
        name_len := 1;
        while ( (name_len <= alias_name'length) and (alias_name(name_len) /= nul)) loop
           name_len := name_len + 1;
        end loop;
        name_len := name_len - 1;

        mem_id.name := new string(1 to name_len);

        for i in 1 to name_len loop
           mem_id.name(i) := alias_name(i);
        end loop;
        -- create and initialize data structure for rows

        mem_id.row_data_ptr := new row_data(0 to mem_id.rows-1);

        for i in 0 to mem_id.rows - 1 loop
            mem_id.row_data_ptr(i) := (last_refresh => NOW,
                                       rowptr => NULL,
                                       all_xs => FALSE
                                      );
        end loop;
        -- set default word

        mem_id.default := new std_logic_vector(mem_id.width - 1 downto 0);

        if (default_word'length /= mem_id.width) then
            assert (default_word'length  = 0)
                report "SRAM_INITIALIZE:  Default word width does not match word width of memory:  "
                       & pstr(mem_id.name(1 to mem_id.name'length)) & LF & SPACESTR
                       & "default will be set to a word filled with 'U'"
                severity ERROR;
            for i in 0 to mem_id.width - 1 loop
                mem_id.default(i) := 'U';
            end loop;
        else

            mem_id.default.all := To_X01(default_word);

        end if;

        -- set wpb_mask

        mem_id.wpb_mask := new std_logic_vector(mem_id.width - 1 downto 0);

        for i in 0 to mem_id.width - 1 loop
           mem_id.wpb_mask(i) := '1';
        end loop;
        
        return mem_id;
    end;


    Function SRAM_Initialize (  Constant name            : IN string;
                                Constant length          : IN POSITIVE;
                                Constant width           : IN POSITIVE;
                                Constant default_word    : IN std_ulogic_vector
                              ) return mem_id_type IS

    Variable mem_id : mem_id_type;

    begin
        mem_id := SRAM_Initialize ( name,
                                    length,
                                    width,
                                    std_logic_vector (default_word)
                                  );
        return mem_id;
    end;

    

    Function SRAM_Initialize (  Constant name            : IN string;
                                Constant length          : IN POSITIVE;
                                Constant width           : IN POSITIVE;
                                Constant default_word    : IN bit_vector
                              ) return mem_id_type IS

    Variable mem_id : mem_id_type;

    begin
        mem_id := SRAM_Initialize ( name,
                                    length,
                                    width,
                                    bv_To_StdLogicVector (default_word, default_word'length)
                                  );
        return mem_id;
    end;
    
    ---------------------------------------------------------------------------
    --    Procedure Name  :  Mem_Wake_Up
    --
    --    Purpose         :  to initialize a DRAM for use
    --                       
    --    Parameters      :  mem_id    - ptr to memory data structure
    --
    --    NOTE            :  a DRAM must be woken up before it can be used or if
    --                       the refresh period passes without any operations
    --
    --    Use             :  Mem_Wake_Up (ROM_chip_1);
    ---------------------------------------------------------------------------

    Procedure Mem_Wake_Up (Variable mem_id     : INOUT mem_id_type) IS

    begin
        if ( (mem_id.memory_type = DRAM) or (mem_id.memory_type = VRAM) ) then
            mem_id.last_init := NOW;
        else
            assert false
                report "Mem_Wake_Up:  Memory:  " & pstr(mem_id.name(1 to mem_id.name'length)) & " is a ROM or an SRAM."
                        & LF & SPACESTR &
                       "This operation is not valid for SRAMs or ROMs, operation ignored."
                severity ERROR;
        end if;
    end;

    ---------------------------------------------------------------------------
    --    Procedure Name  :  Mem_Basic_Read
    --
    --    Purpose         :  To read a "word" from memory
    --
    --    Parameters      :  data           -  contents of memory location
    --                       mem_id         -  ptr to memory data structure
    --                       address        -  address to read from
    --                       refresh_enable -  if true a refresh is performed
    --                                         for DRAMs
    --
    --    NOTE            :  a read refreshes the corresponding row of a DRAM
    --                       ***** this procedure is not exteranlly visible ****
    --
    ---------------------------------------------------------------------------
    

    Procedure Mem_Basic_Read (  Variable data           : OUT std_logic_vector;
                                Variable mem_id         : INOUT mem_id_type;
                                Constant address        : IN NATURAL;
                                Constant refresh_enable : IN BOOLEAN := TRUE
                             ) IS

    Variable alias_data : std_logic_vector(data'length - 1 downto 0) := (others=>'X');
    Variable mem_word   : std_logic_vector(mem_id.width - 1 downto 0);
    Variable row : NATURAL := address/mem_id.columns;
    Variable column : NATURAL := address mod mem_id.columns;
    Variable limit : integer;
    Variable i : NATURAL;
    variable short_ptr : rowptr_type;
                       
    begin
        if address < mem_id.length then        -- check for valid address range
            -- if dram check if woken up and make assertion
            -- nothing else has to be done since data will be invalidated due to refresh period violation
            assert ( ((mem_id.memory_type /= DRAM) and (mem_id.memory_type /= VRAM)) or (NOT MEM_WARNINGS_ON) or 
                       ( (mem_id.last_init + mem_id.refresh_period) >= NOW) )   
                report "Mem_Read:  Device wake-up time limit exceeded for memory:  "
                           & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR &
                           "device must be woken up.  All reads will return X's or default word"
                severity WARNING;
            -- invalidate data if refresh period has expired
            validate_row (mem_id, row);
            -- now refresh row
            if refresh_enable then
                refresh_row (mem_id, row);
            end if;
            --  handle data of different width than memory
            assert ( (data'length = mem_id.width) OR NOT MEM_WARNINGS_ON)
                report "Mem_Read:  return data size does not match word size"
                       & " of mem:  " & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR &
                       "return data size:  " & i_to_str(data'length) & " bits"
                        & LF & SPACESTR & "memory word size:  " &
                       i_to_str(mem_id.width) & " bits"
                severity WARNING;
            if (mem_id.row_data_ptr(row).all_xs) then   -- if all xs then return x's
                mem_word := (others => 'X');
            elsif  (mem_id.row_data_ptr(row).rowptr = NULL) then   -- if not allocated return default

                mem_word := mem_id.default.all;

            else
                short_ptr := mem_id.row_data_ptr(row).rowptr;
                for i in 0 to mem_id.width - 1 loop         -- else return word at that location
                    -- mem_word(i) := mem_id.row_data_ptr(row).rowptr(column,i);
                    -- *************************************
                    -- this is a bug work around for synopsys
                    -- replaces line commented out above
                    mem_word(i) := short_ptr(column,i);
                    -- end bug fix
                    -- *************************************
                end loop;
            end if;
            if mem_id.width >= data'length then
                limit := data'length;
            else
                limit := mem_id.width;
            end if;
            for i in 0 to limit - 1 loop
                alias_data(i) := mem_word(i);
            end loop;
        else
            assert false
                 report "Mem_Read:  Passed address exceeds address " & 
                    "range of mem:  " & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR 
                    & "specified address:  " & i_to_str(address)  & LF &
                    SPACESTR & "address range:  0 to " & i_to_str(mem_id.length - 1)
                 severity ERROR;
                 alias_data := (others => 'X');
        end if;
        data := alias_data;
    end;

    Procedure Mem_Basic_Read (  Variable data           : OUT std_ulogic;
                                Variable mem_id         : INOUT mem_id_type;
                                Constant address        : IN NATURAL;
                                Constant refresh_enable : IN BOOLEAN := TRUE
                             ) IS

    Variable row : NATURAL := address/mem_id.columns;
    Variable column : NATURAL := address mod mem_id.columns;
    variable short_ptr : rowptr_type;
                       
    begin
        if address < mem_id.length then
            assert ( ((mem_id.memory_type /= DRAM) and (mem_id.memory_type /= VRAM)) or (NOT MEM_WARNINGS_ON) or
                       ( (mem_id.last_init + mem_id.refresh_period) >= NOW) )
                report "Mem_Read:  Device wake-up time limit exceeded for memory:  "
                           & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR &
                           "device must be woken up.  All reads will return X's or default word."
                severity WARNING;
            validate_row (mem_id, row);
            if refresh_enable then
                refresh_row (mem_id, row);
            end if;
            --  handle data of different width than memory
            assert ( (mem_id.width = 1) OR NOT MEM_WARNINGS_ON)
                report "Mem_Read:  return data size does not match word size" 
                       & " of mem:  " & pstr(mem_id.name(1 to mem_id.name'length))  & LF &
                       SPACESTR & "return data size:  1 bit" & LF & SPACESTR & "memory word size:  " &
                       i_to_str(mem_id.width) & " bits"
                severity WARNING;
            if (mem_id.row_data_ptr(row).all_xs) then
                data := 'X';
            elsif (mem_id.row_data_ptr(row).rowptr = NULL) then
                data := mem_id.default(0);
            else
                --data := mem_id.row_data_ptr(row).rowptr(column,0);
                -- *************************************
                -- this is a bug work around for synopsys
                -- replaces line commented out above
                short_ptr := mem_id.row_data_ptr(row).rowptr;
                data := short_ptr(column,0);
                -- end bug fix
                -- *************************************
            end if;
        else
            assert false
                 report "Mem_Read:  Passed address exceeds address " & 
                    "range of mem:  " & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR
                    & "specified address:  " & i_to_str(address)  & LF &
                    SPACESTR & "address range:  0 to "
                    & i_to_str(mem_id.length - 1)
                 severity ERROR;
                 data := 'X';
        end if;
    end;                                                  


    
    ---------------------------------------------------------------------------
    --    Procedure Name  :  Mem_Basic_Write
    --
    --    Purpose         :  To write a "word" to memory
    --                       this procedure will write to a ROM
    --
    --    Parameters      :  mem_id      - ptr to memory data structure
    --                       address     - address to read from
    --                       data        - "word" to be written to memory
    --                                     must first be converted to X01
    --                       wpb_mask    - write per bit mask
    --                       ingore_rom  - if true then write even if ROM
    --                       assert_name - name of procedure to be reported in assertions:
    --
    --    NOTE            :  a write refreshes row of a DRAM
    --                       ***** this procedure not user visible *******
    --
    ---------------------------------------------------------------------------

    
    Procedure Mem_Basic_Write (  Variable mem_id        : INOUT mem_id_type;
                                 Constant address       : IN NATURAL;
                                 Constant data          : IN std_logic_vector;
                                 Constant wpb_mask      : IN std_logic_vector;
                                 Constant write_per_bit : IN BOOLEAN := FALSE;
                                 Constant ignore_rom    : IN Boolean := FALSE;
                                 Constant assert_name   : IN STRING := "Mem_Write"
                              ) IS

    Constant alias_data : std_logic_vector (data'length - 1 downto 0) := To_X01(data);
    variable row, column, i : integer;
    variable short_ptr : rowptr_type;
    variable mem_word : std_logic_vector (mem_id.width - 1 downto 0)            -- word to be written to memory adjusted
                                                          := (others => 'X');   -- the size of the memory
    variable new_mem_word : std_logic_vector (mem_id.width - 1 downto 0);       -- actual word to be written to memory
                                                                                -- after masking with wpb
    begin
        if ( (mem_id.memory_type /= ROM) or (ignore_rom) ) then   -- make sure its not a rom
            if address < mem_id.length then                       -- check that its a valid address
                -- if memory is a dram or vram make sure that it has been woken up
                if ( (mem_id.memory_type = SRAM) or (mem_id.memory_type = ROM) or (mem_id.last_init + mem_id.refresh_period >= NOW)) then
                    -- calculate row and column
                    row := address/mem_id.columns;
                    column := address mod mem_id.columns;
                    -- validate address and report if refresh time exceeded
                    validate_row (mem_id, row);
                    -- refresh the row 
                    refresh_row (mem_id, row);
                    -- if row never allocated then allocate it
                    if (mem_id.row_data_ptr(row).rowptr = NULL) then
                        allocate_row(mem_id, row);
                    end if;
                    -- handle data of different width than memory
                    -- if data has less bits than memory than MSBs become Xs
                    assert ( (data'length = mem_id.width) OR NOT MEM_WARNINGS_ON)
                        report assert_name & ":  passed data size does not match word size"
                               & " of mem:  " & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR &
                               "passed data size:  " & i_to_str(data'length) & " bits"
                                & LF & SPACESTR & "memory word size:  " &
                               i_to_str(mem_id.width) & " bits"
                        severity WARNING;
                    if (mem_id.width >= data'length) then
                        mem_word (data'length - 1 downto 0) := alias_data;
                    else
                        mem_word := alias_data(mem_id.width-1 downto 0);
                    end if;
                    -- check for write per bit if VRAM
                    short_ptr := mem_id.row_data_ptr(row).rowptr;
                    assert ( (not ( write_per_bit and (mem_id.memory_type /= VRAM) and (NOT EXTENDED_OPS) )) or (not MEM_WARNINGS_ON) )
                       report assert_name & ":  Write Per Bit only valid for use with VRAMs." & LF & SPACESTR &
                              "Operation continuing without write per bit."
                       severity WARNING;
                    if ( ( (mem_id.memory_type = VRAM) or EXTENDED_OPS) and write_per_bit ) then
                       for i in 0 to mem_id.width - 1 loop
                          new_mem_word(i) := short_ptr(column,i);
                       end loop;
                       for ii in 0 to mem_id.width - 1 loop
                          if (wpb_mask(ii) = '1') then
                             new_mem_word(ii) := mem_word(ii);
                          end if;
                       end loop;
                    else
                       new_mem_word := mem_word;
                    end if;
                    -- write data to memory
                    for i IN 0 to mem_id.width - 1 loop
                        -- mem_id.row_data_ptr(row).rowptr(column,i) := new_mem_word(i);
                        -- *************************************
                        -- this is a bug work around for synopsys
                        -- replaces line commented out above
                        short_ptr(column,i) := new_mem_word(i);
                        -- end bug fix
                        -- *************************************
                    end loop;
                else
                    assert NOT MEM_WARNINGS_ON
                        report assert_name & ":  Device wake-up time limit exceeded for memory:  "
                               & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR &
                               "Operation ignored, device must be woken up."
                        severity WARNING;
                end if;
            else
                assert false
                     report assert_name & ":  Passed address exceeds address " 
                            & "range of mem:  " & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR
                            & "specified address:  " & i_to_str(address)  & LF &
                            SPACESTR & "address range:  0 to " & i_to_str(mem_id.length - 1)
                    severity ERROR;
          end if;
        else
            assert false
                report assert_name & ":  Attempt to write to memory:  " & pstr(mem_id.name(1 to mem_id.name'length))
                       & LF & SPACESTR & "Writes to ROMs are not allowed.  Operation ignored."
                severity ERROR;
        end if;
    end;

    
    Procedure Mem_Basic_Write (  Variable mem_id        : INOUT mem_id_type;
                                 Constant address       : IN NATURAL;
                                 Constant data          : IN std_ulogic;
                                 Constant wpb_mask      : IN std_logic_vector;
                                 Constant write_per_bit : IN BOOLEAN := FALSE;
                                 Constant ignore_rom    : IN Boolean := FALSE;
                                 Constant assert_name   : IN STRING := "Mem_Write"
                              ) IS

    variable row, column : integer;
    variable short_ptr : rowptr_type;
                        
    begin
        if ( (mem_id.memory_type /= ROM) or ignore_rom) then   -- make sure its a ROM
            if address < mem_id.length then                    -- make sure its a valid address
               -- if memory is a dram or vram, then make sure its been woken up
               if ( (mem_id.memory_type = SRAM) or (mem_id.memory_type = ROM) or (mem_id.last_init + mem_id.refresh_period >= NOW)) then
                    -- calculate row and column
                    row := address/mem_id.columns;
                    column := address mod mem_id.columns;
                    -- check if refresh period has expired and make appropriate assertions
                    validate_row (mem_id, row);
                    -- refresh this row
                    refresh_row (mem_id, row);
                    -- if the row has not been allocated then allocate it
                    if (mem_id.row_data_ptr(row).rowptr = NULL) then
                        allocate_row(mem_id, row);
                    end if;
                    --  handle data of different width than memory
                    assert ( (mem_id.width = 1) OR NOT MEM_WARNINGS_ON)
                        report assert_name & ":  passed data size does not match word size"
                               & " of mem:  " & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR &
                               "passed data size:  1 bit"
                                & LF & SPACESTR & "memory word size:  " &
                               i_to_str(mem_id.width) & " bits"
                        severity WARNING;
                    -- check for write per bit if VRAM
                    short_ptr := mem_id.row_data_ptr(row).rowptr;
                    assert ( (not ( write_per_bit and (mem_id.memory_type /= VRAM) and (NOT EXTENDED_OPS) )) or (not MEM_WARNINGS_ON) )
                       report assert_name & ":  Write Per Bit only valid for use with VRAMs." & LF & SPACESTR &
                              "Operation continuing without write per bit."
                       severity WARNING;
                    if ( ( (mem_id.memory_type = VRAM) or EXTENDED_OPS ) and write_per_bit ) then
                       for ii in 0 to mem_id.width - 1 loop
                          if (wpb_mask(ii) = '1') then
                             if ii = 0 then
                                short_ptr(column, 0) := To_X01(data);
                             else
                                short_ptr(column, 0) := 'X';
                             end if;
                          end if;
                       end loop;
                    else
                       short_ptr(column,0) := To_X01(data);
                       -- put xs in all but lsb
                       for i in 1 to mem_id.width-1 loop
                           --mem_id.row_data_ptr(row).rowptr(column,i) := 'X';
                           -- *************************************
                           -- this is a bug work around for synopsys
                           -- replaces line commented out above
                           short_ptr(column,i) := 'X';
                           -- end bug fix
                           -- *************************************
                       end loop;
                    end if;
               else
                assert NOT MEM_WARNINGS_ON
                     report assert_name & ":  Device wake-up time limit exceeded for memory:  "
                            & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR &
                            "Operation ignored, device must be woken up."
                     severity WARNING;
               end if;
            else
                assert false
                     report assert_name & ":  Passed address exceeds address " & 
                            "range of memory:  " & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR
                            & "Specified address:  " & i_to_str(address)  & LF &
                            SPACESTR & "address range:  0 to "
                            & i_to_str(mem_id.length - 1)
                     severity ERROR;
            end if;
        else
            assert false
                report assert_name & ":  Attempt to write to memory:  " & pstr(mem_id.name(1 to mem_id.name'length))
                       & LF & SPACESTR & "Writes to ROMs are not allowed.  Operation ignored."
                severity ERROR;
        end if;
    end;


    ---------------------------------------------------------------------------
    --    Procedure Name  :  Mem_All_Reset
    --
    --    Purpose         :  To set the contents of a memory to some predetermined
    --                       value.  The locations to reset are specified by a
    --                       range.
    --
    --    Parameters      :  mem_id       -  ptr to memory data structure
    --                       reset_value  -  value to reset memory to
    --                       start_addr   -  starting address within memory
    --                       end_addr     -  ending address withim memory
    --                       ROM_too      -  allows roms to be reset as well if true
    --
    --    NOTE            :  works for all mem types.  call by Mem_Reset
    --                       ****    NOT USER VISIBLE   *****
    --
    --    Use             :  Mem_ALL_Reset (RAM1, "1010", 2048, 4096, FALSE);
    ---------------------------------------------------------------------------
        
    procedure  Mem_ALL_Reset ( Variable mem_id          : INOUT mem_id_type;
                               Constant reset_value     : IN std_logic_vector;
                               Constant start_addr      : IN NATURAL := 0;
                               Constant end_addr        : IN NATURAL := integer'high;
                               Constant ROM_too         : IN BOOLEAN := FALSE
                             ) IS

    Variable real_end : NATURAL := end_addr;
    Variable start_row, start_col, end_row, end_col : NATURAL;
    Variable row, col, rstart_col, rend_col, bit_pos : NATURAL;
    Variable row_ptr : rowptr_type;
    Variable alias_reset : std_logic_vector (mem_id.width - 1 downto 0) := (others => 'U');
    Variable xvector : std_logic_vector (mem_id.width - 1 downto 0) := (others => 'X');
    Variable i : integer;
                        
    begin
        if (reset_value'length /= mem_id.width) then
           assert (reset_value'length <= 0)
                report "Mem_Reset:  reset value of memory does not match memory width " &
                       pstr(mem_id.name(1 to mem_id.name'length)) & LF & SPACESTR
                       & "Resetting memory to all 'U's."
                severity ERROR;
           alias_reset := (others => 'U');
        else
           alias_reset := To_X01(reset_value);
        end if;
        if ( (mem_id.memory_type /= ROM) or ROM_too) then          -- make sure its not a rom
            if (end_addr < start_addr) then   -- check address ranges
                assert false
                       report "Mem_Reset:  ending address is less than starting address."
                              & LF & SPACESTR & "No operation performed."
                       severity ERROR;
            elsif (start_addr >= mem_id.length) then
                assert false
                       report "Mem_Reset:  starting address outside of address "
                              & "range of memory:  " & pstr(mem_id.name(1 to mem_id.name'length))
                              & LF & SPACESTR & "No operation performed."
                       severity ERROR;
            else
                If (end_addr >= mem_id.length) then
                    assert ( (end_addr = integer'high) or (NOT MEM_WARNINGS_ON) )
                           report "Mem_Reset:  ending address outside address "
                                  & "range of memory:  " & pstr(mem_id.name(1 to mem_id.name'length)) & LF & SPACESTR
                                  & "Memory will be refreshed until end is reached."
                           severity WARNING;
                    real_end := mem_id.length - 1;
                end if;
                -- if memory is a dram, then wake it up
                if ((mem_id.memory_type = DRAM) or (mem_id.memory_type = VRAM)) then
                    Mem_Wake_Up (mem_id);
                end if;
                -- calculate row and column of starting address
                start_row := start_addr/mem_id.columns;
                start_col := start_addr mod mem_id.columns;
                -- calculate row and column of ending address
                end_row := real_end/mem_id.columns;
                end_col := real_end mod mem_id.columns;
                -- starting column of row presently being written to
                rstart_col := start_col;
                for row in start_row to end_row loop 
                    if row = end_row then       -- set ending collumn of row presently being written to
                        rend_col := end_col;
                    else
                        rend_col := mem_id.columns - 1;
                    end if;
                    --  check for expired time period on row 
                    if ( (rstart_col > 0) or (rend_col < mem_id.columns - 1) ) then
                        -- it is only necessary to validate row if only part of the row is being reset
                        validate_row (mem_id, row);
                    else
                       -- entire row being reset, check for expired refresh period
                       assert ( ((mem_id.memory_type /= DRAM) and (mem_id.memory_type /= VRAM)) or
                                ((mem_id.row_data_ptr(row).last_refresh + mem_id.refresh_period) >= NOW)
                                or NOT MEM_WARNINGS_ON )
                           report "Mem_Reset:  refresh period on row " &
                                  i_to_str(row) & " has expired but"
                                   & LF & SPACESTR
                                  & "no data lost since entire row is being reset"
                           severity WARNING;
                    end if;
                    -- if collumn not allocated & fill value is not the default or all x's then allocate

                    if ( (mem_id.row_data_ptr(row).rowptr = NULL) and (alias_reset /= mem_id.default.all)
                         and (alias_reset /= xvector) ) then

                        allocate_row (mem_id, row);
                    -- if filling partial row with default and currently is Xs then allocate

                    elsif ( (mem_id.row_data_ptr(row).rowptr = NULL) and (alias_reset = mem_id.default.all)
                            and mem_id.row_data_ptr(row).all_xs and
                            ( (rstart_col /= 0) or (rend_col /= mem_id.columns - 1)) ) then

                        allocate_row (mem_id, row);
                    -- if filling partial row with Xs and currently is default then allocate
                    elsif ( (mem_id.row_data_ptr(row).rowptr = NULL) and (alias_reset = xvector)
                            and (NOT mem_id.row_data_ptr(row).all_xs) and
                            ( (rstart_col /= 0) or (rend_col /= mem_id.columns - 1)) ) then
                        allocate_row (mem_id, row);
                    end if;                    
                    -- if filling entire collumn with default then deallocate it

                    If ( (alias_reset = mem_id.default.all) and (rstart_col = 0) and

                         (rend_col = mem_id.columns - 1) ) then
                        if (mem_id.row_data_ptr(row).rowptr /= NULL) then
                            Deallocate (mem_id.row_data_ptr(row).rowptr);
                            mem_id.row_data_ptr(row).rowptr := NULL;
                        end if;
                        mem_id.row_data_ptr(row).all_xs := FALSE;
                    -- if filling entire collumn with X's then deallocate it
                    elsif ( (alias_reset = xvector) and (rstart_col = 0) and (rend_col = mem_id.columns - 1) ) then
                          if (mem_id.row_data_ptr(row).rowptr /= NULL)  then
                             Deallocate (mem_id.row_data_ptr(row).rowptr);
                             mem_id.row_data_ptr(row).rowptr := NULL;
                         end if;
                         mem_id.row_data_ptr(row).all_xs := TRUE;
                    end if;
                    -- fill up the row if the entire row isn't being filled with Xs or default
                    row_ptr := mem_id.row_data_ptr(row).rowptr;
                    if (row_ptr /= NULL)  then
                        for col in rstart_col to rend_col loop
                            for bit_pos in 0 to mem_id.width - 1 loop
                                row_ptr(col,bit_pos) := alias_reset(bit_pos);
                            end loop;
                        end loop;
                    end if;
                    rstart_col := 0;              -- start at beginning of next collumn
                    refresh_row (mem_id, row);    -- refresh the current row
                end loop;
            end if;
        else
            assert false
                 report "Mem_Reset:   Reset of ROM not allowed.  Operation ignored"
                 severity ERROR;
        end if;
    end;


    --------------------------------------------------------------------------------------------------
    --  The following functions and procedures are used in the recursive descent parser that is used
    --  to parse the memory files.
    --  *****************************   THESE ROUTINES ARE NOTE USER VISIBLE   ***********************
    --------------------------------------------------------------------------------------------------    


    -- return true if character is upper case character
    function is_upper_case ( Constant ch : IN CHARACTER ) return BOOLEAN is

    begin
        return ( (ch >= 'A') and (ch <= 'Z') );
    end;

    -- return true if character is lower case character
    function is_lower_case ( Constant ch : IN CHARACTER ) return BOOLEAN is

    begin
        return ( (ch >= 'a') and (ch <= 'z') );
    end;

    -- return true if character is a decimal digit
    function is_dec_digit ( Constant ch : IN CHARACTER ) return BOOLEAN is

    begin
        return ( (ch >= '0') and (ch <= '9'));
    end;

    
    -- skip over blanks and tabs
    -- read characters and numbers until space, tab, or symbol is encountered
    -- get special identifiers such as :, --, or ..
    -- convert lower case to upper case
    -- update buffer index to point to first character after identifier that was read
    
    procedure read_word ( Variable out_str  : OUT STRING;
                          Constant in_str   : IN STRING;
                          Variable b_ind    : INOUT INTEGER
                        ) is

    Variable out_ind : integer := 1;

    begin
      -- skip over spaces and tabs
      while ( ( (in_str(b_ind) = ' ') or (in_str(b_ind) = HT) ) and (b_ind <= StrLen1(in_str)))  loop
          b_ind := b_ind + 1;
      end loop;
      if ( b_ind > StrLen1(in_str) ) then  -- return if blank line
          out_str(out_ind) := NUL;
          return;
      end if;
      -- check for --
      if ( (StrLen1(in_str) >= b_ind+1) and  (in_str(b_ind) = '-') and (in_str(b_ind + 1) = '-') ) then
          out_str(1) := '-';
          out_str(2) := '-';
          out_str(3) := NUL;
          b_ind := b_ind + 2;
          return;
      end if;
      -- check for ..
      if ( (StrLen1(in_str) >= b_ind+1) and (in_str(b_ind) = '.') and (in_str(b_ind + 1) = '.') ) then
          out_str(1) := '.';
          out_str(2) := '.';
          out_str(3) := NUL;
          b_ind := b_ind + 2;
          return;
      end if;
      -- check for :
      if ( (StrLen1(in_str) >= b_ind) and (in_str(b_ind) = ':') ) then
          out_str(1) := ':';
          out_str(2) := NUL;
          b_ind := b_ind  + 1;
          return;
      end if;
      -- get an identifier
      loop  -- accept at least one character no matter what is is
          if ( (in_str(b_ind) >= 'a') and (in_str(b_ind) <= 'z') ) then
              out_str(out_ind) := Character'Val( (Character'POS(in_str(b_ind))) - 32 );  -- convert to upper case
          else
              out_str(out_ind) := in_str(b_ind);
          end if;
          out_ind := out_ind + 1;  
          b_ind := b_ind + 1;
          exit when ( (b_ind > StrLen1(in_str)) or
                      not (is_upper_case (in_str(b_ind))  or is_lower_case(in_str(b_ind)) or
                            is_dec_digit(in_str(b_ind))
                          )
                    );
      end loop;
      out_str(out_ind) := NUL;
    end;

    -- make sure string is a valid hexadecimal number
    
    Function   valid_hex ( Constant str : IN STRING ) return BOOLEAN is

    variable i : integer;
    variable valid : BOOLEAN := TRUE;

    begin
        i := 1;
        while ( (i <= StrLen1(str)) and valid ) loop
            valid := ( (str(i) >= '0') and (str(i) <= '9') )  or
                     ( (str(i) >= 'a') and (str(i) <= 'z') ) or
                     ( (str(i) >= 'A') and (str(i) <= 'Z') );
            i := i + 1;
        end loop;
        return valid;
    end;

    -- determine what kind of identifier the sring is
    Function word_id (Constant str : IN STRING) return IDENTIFIER is

    begin
       if StrLen1(str) = 0 then
           -- assert false report "BLANK1" severity NOTE;
           return BLANK1;
       elsif ( (StrLen1(str) = 1) and (str(1) = ':') ) then
           -- assert false report "COLON1" severity NOTE;
           return COLON1;
       elsif ( (StrLen1(str) = 2) and (str(1) = '-') and (str(2) = '-') ) then
           -- assert false report "COMMENT1" severity NOTE;
           return COMMENT1;
       elsif ( (StrLen1(str) = 2) and (str(1) = '.') and (str(2) = '.') ) then
           -- assert false report "DOTDOT1" severity NOTE;
           return DOTDOT1;
       elsif ( (StrLen1(str) = 5) and (str(1 to 5) = "WIDTH") ) then
           -- assert false report "WIDTH1" severity NOTE;
           return WIDTH1;           
       elsif ( (StrLen1(str) = 7) and (str(1 to 7) = "DEFAULT") ) then
           -- assert false report "DEFAULT1" severity NOTE;
           return DEFAULT1;           
       elsif (valid_hex(str)) then
           -- assert false report "HEX_NUM1" severity NOTE;
           return HEX_NUM1;           
       else
           -- assert false report "SYN_ERROR1" severity NOTE;
           return SYN_ERROR1;           
       end if;
    end;

    -- force the parser to start parsing from the next line.
    -- Reset the string buffer index to the first element
    procedure new_line ( Variable str_buff   : INOUT string;
                         Variable b_index    : INOUT integer;
                         Variable file_error : INOUT integer;
                         Variable in_file    : IN TEXT;
                         Variable line_num   : INOUT integer
                       ) is

    Variable line_ptr : LINE;                       

    begin
        b_index := 1;
        if not endfile(in_file) then
            fgetline1(str_buff, in_file, line_ptr);
            line_num := line_num + 1;
        else
            file_error := 1;
        end if;
        DEALLOCATE(line_ptr);
    end;

    -- get the next symbol in the file going to the next line if necessary

    procedure get_sym ( Variable word       : INOUT string;
                        Variable str_buff   : INOUT string;
                        Variable b_index    : INOUT integer;
                        Variable file_error : INOUT integer;
                        Variable in_file    : IN TEXT;
                        Variable line_num   : INOUT integer
                     ) is

    Variable line_ptr : LINE;                         

    begin
        if ( b_index > StrLen1(str_buff) ) then  -- if end of line reached then get another line
           b_index := 1;
           if not endfile(in_file) then
               fgetline1(str_buff, in_file, line_ptr);
               line_num := line_num + 1;
           else
               file_error := 1;
           end if;
           word(1) := NUL;
        else
          read_word(word, str_buff, b_index);
        end if;
        DEALLOCATE(line_ptr);
    end;

    -- convert a hexadecimal string to an integer
    function from_hex_to_int (word : IN string) return integer is

    variable alias_word : string(1 to word'length) := word;
    variable digit, start, leng : integer;
    variable power : integer := 1;
    variable result : integer := 0;
    variable max_bit_num : integer := 0;  -- max number of bits needed to represent hex number
    
    begin
        leng := StrLen1(alias_word);
        start := 1;
        -- eliminate preceeding 0's
        while ( (alias_word(start) = '0') and (start < leng) ) loop  -- less than leng handles the 0 case
            start := start + 1;
        end loop;
        for i in leng downto start loop
            max_bit_num := max_bit_num + 4;
            if ( (alias_word(i) >= '0') and (alias_word(i) <= '9')) then
                digit := Character'Pos(alias_word(i)) - 48;
            else
                digit := Character'Pos(alias_word(i)) - 55;
            end if;
            if ( (max_bit_num >= IntegerBitLength) and (digit > 7) ) then
               assert FALSE
                  report "Mem_Read: hex value:  " & word & " is too large to represent as an integer on this machine"
                  severity ERROR;
               exit;  -- exit the loop
            end if;
            result := result + digit * power;
            if (i /= start) then           -- power will not be multiplied by 16 on the last iteration.
               power := power * 16;        -- This will prevent an integer overflow when dealing with 
            end if;                        -- the maximum number of hex digits the machine can represent.
        end loop;
        return result;
    end;

    -- parse a width statement
    procedure pwidth ( Variable word       : INOUT string;
                       Variable str_buff   : INOUT string;
                       Variable b_index    : INOUT integer;
                       Variable file_error : INOUT integer;
                       Variable in_file    : IN TEXT;
                       Variable file_width : INOUT integer;
                       Variable line_num   : INOUT integer
                     ) is

    Variable w_id : IDENTIFIER;
    variable error_line : integer;

    begin
        w_id := word_id(word);
        if (w_id /= WIDTH1) then
            file_error := 2;
            assert false
                 report "Mem_Load:  Width specification not first executable line in file.  File load aborted."
                        & LF & SPACESTR & "Occurred on line number " & i_to_str(line_num) & " of the input file."
                 severity ERROR;
        else
            get_sym (word, str_buff, b_index, file_error, in_file, line_num);
            w_id := word_id(word);
            if (w_id = COLON1) then
               get_sym (word, str_buff, b_index, file_error, in_file, line_num);
               w_id := word_id(word);
               if w_id = HEX_NUM1 then
                   file_width := from_hex_to_int(word);
                   get_sym (word, str_buff, b_index, file_error, in_file, line_num);
                   w_id := word_id(word);
                   error_line := line_num;
                   if w_id = COMMENT1 then
                        new_line (str_buff, b_index, file_error, in_file, line_num);
                   elsif w_id /= BLANK1 then
                        assert false
                            report "Mem_Load:  Additional information on width specification line ignored."
                                   & LF & SPACESTR & "File processing continuing."
                                   & LF & SPACESTR & "Occurred on line number " & i_to_str(line_num)
                                   & " of the input file."
                            severity ERROR;
                        new_line(str_buff, b_index, file_error, in_file, line_num);
                   end if;
                   if file_width = 0 then
                       file_error := 10;
                       assert false
                           report "Mem_load:  Width must be greater than 0.  File load aborted."
                                  & LF & SPACESTR & "Occurred on line number " & i_to_str(error_line)
                                  & " of the input file."
                           severity ERROR;
                   end if;
               else
                   file_error := 3;
               end if;
            else
                file_error := 3;
            end if;
        end if;
        if file_error = 3 then
            assert false
                report "Mem_load:  Syntax error in width specification.  File load aborted."
                       & LF & SPACESTR & "Occurred on line number " & i_to_str(line_num) & " of the input file."
                severity ERROR;
        end if;
    end;

    -- parse a default statement
    procedure pdefault ( Variable word       : INOUT string;          -- present word
                         Variable str_buff   : INOUT string;          -- string buffer
                         Variable b_index    : INOUT integer;         -- string buffer index
                         Variable file_error : INOUT integer;         -- error?
                         Variable in_file    : IN TEXT;               -- file
                         Variable file_width : IN integer;            -- width specified by file
                         Variable mem_id     : INOUT mem_id_type;     -- memory 
                         Constant hex_size   : IN integer;            -- number of hex digits expected
                         Constant rwidth     : IN integer;            -- # of bits to be written to memory
                         Variable line_num   : INOUT integer             -- line # of file 
                       ) is

    Variable w_id : IDENTIFIER;
    Variable tdata : bit_vector (file_width - 1 downto 0);
    Variable data : std_logic_vector (mem_id.width - 1 downto 0);
    

    begin
        get_sym (word, str_buff, b_index, file_error, in_file, line_num);
        w_id := word_id(word);
        if w_id = COLON1 then
            get_sym (word, str_buff, b_index, file_error, in_file, line_num);
            w_id := word_id(word);
            if w_id = HEX_NUM1 then
                if StrLen1(word) = hex_size then
                    data := (others => 'X');
                    tdata := From_HexString1(word)(file_width - 1 downto 0);
                    data(rwidth - 1 downto 0) := bv_To_StdLogicvector(tdata(rwidth - 1 downto 0));
                    if mem_id.default = NULL then

                        mem_id.default := new std_logic_vector(mem_id.width - 1 downto 0);

                    else
                        deallocate (mem_id.default);

                        mem_id.default := new std_logic_vector(mem_id.width - 1 downto 0);

                    end if;

                    mem_id.default.all := data;

                    get_sym (word, str_buff, b_Index, file_error, in_file, line_num);
                    w_id := word_id(word);
                    if w_id = COMMENT1 then
                        new_line (str_buff, b_index, file_error, in_file, line_num);
                    elsif w_id /= BLANK1 then
                         assert false
                             report "Mem_Load:  Additional information on default specification line ignored."
                                    & LF & SPACESTR & "File processing continuing."
                                    & LF & SPACESTR & "Occurred on line number " & i_to_str(line_num)
                                    & " of the input file."
                             severity ERROR;
                         new_line(str_buff, b_index, file_error, in_file, line_num);
                    end if;
                else
                    assert false
                        report "Mem_Load:  Default word length does not match file specification for width of memory. "
                               & " Default ignored."
                               & LF & SPACESTR & "Occurred on line number " & i_to_str(line_num)
                               & " of the input file."
                        severity ERROR;
                    new_line (str_buff, b_index, file_error, in_file, line_num);
                end if;
            
            else
                file_error := 4;
            end if;
        else
            file_error := 4;
        end if;
        if file_error = 4 then  
            assert false
                report "Mem_Load:  Syntax error in default word specification.  Line ignored."
                       & LF & SPACESTR & "Occurred on line number " & i_to_str(line_num) & " of the input file."
                severity ERROR;
           new_line (str_buff, b_index, file_error, in_file, line_num);
           file_error := 0;
        end if;
    end;

    -- parse an assignment statement
    procedure passign ( Variable addr1      : IN integer;               -- starting address of assignment
                        Variable word       : INOUT string;             -- current word
                        Variable str_buff   : INOUT string;             -- string buffer
                        Variable b_index    : INOUT integer;            -- string buffer index
                        Variable file_error : INOUT integer;            -- error?
                        Variable in_file    : IN TEXT;                  -- file
                        Variable file_width : IN integer;               -- width specified by file
                        Variable mem_id     : INOUT mem_id_type;        -- memory
                        Constant hex_size   : IN integer;               -- number of hex digits expected
                        Constant rwidth     : IN integer;               -- # of bits to be written to memory
                        Variable line_num   : INOUT integer             -- line # of file 
                       ) is

    Variable addr : integer := addr1;
    Variable w_id : IDENTIFIER := COLON1;
    Variable tdata : bit_vector (file_width - 1 downto 0);
    Variable data : std_logic_vector (mem_id.width - 1 downto 0);
                       
    begin
        while ( (file_error = 0) and (w_id /= BLANK1) and (w_id /= COMMENT1) ) loop
            get_sym (word, str_buff, b_Index, file_error, in_file, line_num);
            w_id := word_id(word);
            if w_id = HEX_NUM1 then
                if StrLen1(word) = hex_size then
                    data := (others => 'X');
                    tdata := From_HexString1(word)(file_width - 1 downto 0);
                    data(rwidth - 1 downto 0) := bv_To_StdLogicVector(tdata(rwidth - 1 downto 0));
                    Mem_Basic_Write (mem_id, addr, data, Get_WPB_Mask(mem_id.width, mem_id.wpb_mask.all), FALSE, TRUE);
                else
                    assert false
                        report "Mem_Load:  Data word length does not match width specification on line:  "
                               & i_to_str(line_num) & "." & LF & SPACESTR
                               & "Data byte skipped."
                        severity ERROR;
                end if;
                addr := addr + 1;
            elsif ( (w_id /= BLANK1) and (w_id /= COMMENT1) ) then
                file_error := 5;            
                assert false
                    report "Mem_Load:  Syntax error on assignment line. Line processed up to error." &
                           LF & SPACESTR & "Occurred on line number " & i_to_str(line_num) & " of the input file."
                    severity ERROR;
                new_line (str_buff, b_index, file_error, in_file, line_num);
            end if;
        end loop;
        if w_id = COMMENT1 then
            new_line (str_buff, b_index, file_error, in_file, line_num);
        end if;
        if file_error = 5 then
             file_error := 0;
        end if;
    end;

    -- parse a range assignment
    procedure prange ( Variable addr1      : IN integer;                -- strarting address
                       Variable word       : INOUT string;              -- current word
                       Variable str_buff   : INOUT string;              -- string buffer
                       Variable b_index    : INOUT integer;             -- string buffer index
                       Variable file_error : INOUT integer;             -- error?
                       Variable in_file    : IN TEXT;                   -- file
                       Variable file_width : IN integer;                -- width specified in file
                       Variable mem_id     : INOUT mem_id_type;         -- memory
                       Constant hex_size   : IN integer;                -- number of hex digits expected
                       Constant rwidth     : IN integer;                -- # of bits to be written to memory
                       Variable line_num   : INOUT integer              -- line # of file
                      ) is

    Variable addr2, addr : integer;
    Variable w_id : IDENTIFIER;
    Variable tdata : bit_vector (file_width - 1 downto 0);
    Variable data : std_logic_vector (mem_id.width - 1 downto 0);
    Variable error_line : integer;
    
    begin
        get_sym (word, str_buff, b_index, file_error, in_file, line_num);
        w_id := word_id(word);
        if w_id = HEX_NUM1 then
            addr2 := from_hex_to_int(word);
            if addr2 < addr1 then
                file_error := 7;
                error_line := line_num;
                new_line (str_buff, b_index, file_error, in_file, line_num);
            else
                get_sym (word, str_buff, b_index, file_error, in_file, line_num);
                w_id := word_id(word);
                if w_id = COLON1 then
                    get_sym (word, str_buff, b_index, file_error, in_file, line_num);
                    w_id := word_id(word);
                    if w_id = HEX_NUM1 then
                        if StrLen1(word) = hex_size then
                            data := (others => 'X');
                            tdata := From_HexString1(word)(file_width - 1 downto 0);
                            data(rwidth - 1 downto 0) := bv_To_StdLogicVector(tdata(rwidth - 1 downto 0));
                            Mem_ALL_Reset (mem_id, data, addr1, addr2, TRUE);
                            get_sym (word, str_buff, b_Index, file_error, in_file, line_num);
                            w_id := word_id(word);
                            if w_id = COMMENT1 then
                                new_line (str_buff, b_index, file_error, in_file, line_num);
                            elsif w_id /= BLANK1 then
                                 assert false
                                     report "Mem_Load:  Additional information on range assignment line ignored."
                                            & LF & SPACESTR & "File processing continuing."
                                            & LF & SPACESTR & "Occurred on line number " & i_to_str(line_num)
                                            & " of the input file."
                                     severity ERROR;
                                 new_line(str_buff, b_index, file_error, in_file, line_num);
                            end if;
                        else
                            assert false
                                report "Mem_Load:  Data word length does not match width specification."
                                       & LF & SPACESTR & "Line skipped"
                                       & LF & SPACESTR & "Occurred on line number " & i_to_str(line_num)
                                       & " of the input file."
                                severity ERROR;
                            new_line(str_buff, b_index, file_error, in_file, line_num);    
                        end if;
                        addr := addr + 1;
                    else 
                        assert false
                            report "Mem_Load:  Syntax Error on range assignment line.  Line skipped."
                                   & LF & SPACESTR & "Occurred on line number " & i_to_str(line_num)
                                   & " of the input file."
                            severity ERROR;
                        new_line(str_buff, b_index, file_error, in_file, line_num);    
                    end if;
                      -- get_sym (word, str_buff, b_index, file_error, in_file, line_num);
                      -- w_id := word_id(word);
                else
                     file_error := 6;
                     error_line := line_num;
                     new_line (str_buff, b_index, file_error, in_file, line_num);
                end if;
            end if;
        else
            file_error := 6;
            new_line (str_buff, b_index, file_error, in_file, line_num);
        end if;
        if file_error = 7 then
            assert false
                report "Mem_load:  Addr2 < Addr1 in range specification.  Line skipped."
                       & LF & SPACESTR & "Occurred on line number " & i_to_str(error_line) & " of the input file."
                severity ERROR;
            file_error := 0;
        end if;
        if file_error = 6 then
            assert false
               report "Mem_load:  Syntax error in range specification.  Line skipped."
                      & LF & SPACESTR & "Occurred on line number " & i_to_str(error_line) & " of the input file."
                severity ERROR;
           file_error := 0;
        end if;
    end;

    -- decide if current statement is a simple assignment of a range assignment
    -- then parse that statment
    procedure p_op_statement ( Variable word       : INOUT string;
                               Variable str_buff   : INOUT string;
                               Variable b_index    : INOUT integer;
                               Variable file_error : INOUT integer;
                               Variable in_file    : IN TEXT;
                               Variable file_width : IN integer;
                               Variable mem_id     : INOUT mem_id_type;
                               Constant hex_size   : IN integer;
                               Constant rwidth     : IN integer;
                               Variable line_num   : INOUT integer
                             ) is

    Variable addr1 : integer;
    Variable w_id : IDENTIFIER;               
    
    begin
        addr1 := from_hex_to_int(word);
        get_sym (word, str_buff, b_index, file_error, in_file, line_num);
        w_id := word_id(word);
        if w_id = COLON1 then
            passign ( addr1, word, str_buff, b_index, file_error, in_file,
                      file_width, mem_id, hex_size, rwidth, line_num);
        elsif w_id = DOTDOT1 then
            prange ( addr1, word, str_buff, b_index, file_error, in_file,
                     file_width, mem_id, hex_size, rwidth, line_num);
        else
            assert false
                report "Mem_Load:   Syntax error.  Line skipped."
                       & LF & SPACESTR & "Occurred on line number " & i_to_str(line_num) & " of the input file."
                severity ERROR;
            new_line (str_buff, b_index, file_error, in_file, line_num);
        end if;
    end;

    ---------------------------------------------------------------------------
    --    Procedure Name  :  Mem_Load
    --
    --    Purpose         :  to load a memory with data from a file
    --
    --    Parameters      :  mem_id    - ptr to memory data structure
    --                       file_name - name of the file used to load the ROM
    --
    --    RETURNED VALUE  :  mem_id_type - pointer to memory record
    --
    --    NOTE            :  any memory (ROM's, SRAM's, and DRAM's) can be 
    --                       loaded, however, the only real physical correspondence
    --                       is when it is used to load ROM's
    --
    --    Use             :  Mem_load (ROM_chip_1, "Rom1chip.dat");
    ---------------------------------------------------------------------------
        
    procedure Mem_Load (  Variable mem_id          : INOUT mem_id_type;
                          Constant file_name       : IN string
                       ) IS


    Variable str_buff, word : STRING (1 to MAX_STR_LEN + 1);   -- hold line and current word
    Variable b_index : INTEGER;                                -- index into line
    Variable file_error : INTEGER := 0;                        -- non-zero if error occurred
    Variable w_id : IDENTIFIER;                                -- type of current word
    Variable found_default : BOOLEAN := FALSE;                 -- true if a default has be processes
    Variable file_width : integer;                             -- width specification made in file
    Variable other_state : BOOLEAN := FALSE;                   
    Variable hex_size, rwidth : integer;                       
    File in_file : TEXT is IN file_name;
    Variable line_num : integer := 0;                          -- current line being processed
    Variable count : integer := 0;                             -- number of data lines read in

                       
    begin
        assert false
            report "Mem_Load:  Loading file:  " & file_name
            severity NOTE;
        new_line (str_buff, b_index, file_error, in_file, line_num);             --  get the first line
        get_sym (word, str_buff, b_index, file_error, in_file, line_num);        --  get the first word
        w_id := word_id(word);                                         --  identifier type
        -- skip over any blanks or comments
        while ( ((w_id = BLANK1) or (w_id = COMMENT1)) and (file_error = 0) ) loop
            new_line (str_buff, b_index, file_error, in_file, line_num);
            get_sym (word, str_buff, b_index, file_error, in_file, line_num);
            w_id := word_id(word);
        end loop;
        -- get the width
        if file_error = 0 then
            pwidth (word, str_buff, b_index, file_error, in_file, file_width, line_num);
            if  (file_error = 0) then
                assert ( (file_width = mem_id.width)  or (NOT MEM_WARNINGS_ON) )
                             report "Width of file does not match width of memory."
                                    & LF & SPACESTR & "memory width:  " & i_to_str(mem_id.width)
                                    & LF & SPACESTR & "file width:  " & i_to_str(file_width)
                             severity WARNING;
                if ((mem_id.memory_type = DRAM) or (mem_id.memory_type = VRAM)) then
                    Mem_Wake_Up (mem_id);
                end if;
                hex_size := (file_width + 3) / 4;   -- calculate the number of hex digits needed for each data word
                rwidth := file_width;               -- calculate number of bits needed to be written to memory
                if file_width > mem_id.width then
                    rwidth := mem_id.width;
                end if;
            end if;
            -- parse the rest of the file
            while file_error = 0 loop
                get_sym (word, str_buff, b_index, file_error, in_file, line_num);
                w_id := word_id(word);
                if (w_id = COMMENT1) then
                    new_line(str_buff, b_index, file_error, in_file, line_num);
                elsif (w_id = BLANK1) then
                    NULL;
                elsif ( w_id = HEX_NUM1) then
                    assert ( (count mod 50) /= 0)
                        report "Mem_load:  Loading address:  " & pstr(word) & " from file: " & file_name
                        severity NOTE;
                    count := (count + 1) mod 50;
                    p_op_statement ( word, str_buff, b_index, file_error, in_file,
                                     file_width, mem_id, hex_size, rwidth, line_num);
                    other_state := TRUE;
                elsif ( w_id = DEFAULT1 ) then
                    if (other_state) then
                        assert false
                            report "Mem_Load:  Default must be first non-comment statement following width."
                                   & LF & SPACESTR & "Default statement ignored."
                                   & LF & SPACESTR & "Occurred on line number " & i_to_str(line_num)
                                   & " of the input file."
                            severity ERROR;
                        new_line(str_buff, b_index, file_error, in_file, line_num);
                    else
                        pdefault ( word, str_buff, b_index, file_error, in_file, file_width,
                                   mem_id, hex_size, rwidth, line_num);
                    end if;
                else
                    assert false
                         report "Mem_load:  Syntax error.  Line ignored."
                                & LF & SPACESTR & "Occurred on line number " & i_to_str(line_num)
                                & " of the input file."
                         severity ERROR;
                    new_line(str_buff, b_index, file_error, in_file, line_num);
                end if;
            end loop;
        end if;
        assert (file_error /= 1)
           report "Mem_Load:  finished loading file:  " & file_name
            severity NOTE;
    end;
    
    -------------------------------------------------------------------------------------------------
    --    Function Name   :  ROM_Initialize
    --
    --    Purpose         :  To create the data structure used to store a
    --                       ROM and to initialize it
    --
    --    Parameters      :  name      - string used to represent the memory
    --                       length    - the number of "words" in the memory
    --                       width     - the length of a "word" of memory
    --                       default_word   - value to which each word of
    --                                        memory should be initialized
    --                       file_name - name of the file used to load the ROM    
    --
    --    RETURNED VALUE  :  mem_id_type - pointer to memory record
    --
    --    NOTE            :  initially the data structure is empty except
    --                       for the sections whose data is specified by the
    --                       input file
    --
    --    Use             :  rom_l1 := ROM_Initialize ("lsb_of_ROM", 1048576, 4, "0000", "romlsb");
    --                                       
    -------------------------------------------------------------------------------------------------
        
    Function ROM_Initialize (  Constant name            : IN string;
                               Constant length          : IN POSITIVE;
                               Constant width           : IN POSITIVE;
                               Constant default_word    : IN std_logic_vector;
                               Constant file_name       : IN string := ""
                             ) return mem_id_type IS

    Variable i, name_len : INTEGER;
    Variable mem_id : mem_id_type;
    Variable alias_name : string (1 to name'length) := name;
                              
    begin
        -- create and initialize data structure

        mem_id := new mem_id_rtype '( memory_type => ROM,
                                      refresh_period => 0.0 ns,
                                      last_init => 0.0 ns,
                                      counter => 0,
                                      name => NULL,
                                      rows => 1,
                                      columns => ROM_COL_SIZE,
                                      width => width,
                                      length => length,
                                      row_data_ptr => NULL,
                                      default => NULL,
                                      sam_columns => 1,
                                      sam_lower_tap => 0,
                                      sam_upper_tap => 0,
                                      serial_ptr => 0,
                                      block_size => 1,
                                      wpb_mask => NULL,
                                      sam_data => NULL
                                     );

        if ( (length mod ROM_COL_SIZE) /= 0) then
           mem_id.rows := (length/ROM_COL_SIZE) + 1;
        else
           mem_id.rows := length/ROM_COL_SIZE;
        end if;
        -- put name in data structure
        name_len := 1;
        while ( (name_len <= alias_name'length) and (alias_name(name_len) /= nul)) loop
           name_len := name_len + 1;
        end loop;
        name_len := name_len - 1;

        mem_id.name := new string(1 to name_len);

        for i in 1 to name_len loop
           mem_id.name(i) := alias_name(i);
        end loop;
        -- create and initialize data structure for rows

        mem_id.row_data_ptr := new row_data(0 to mem_id.rows-1);

        for i in 0 to mem_id.rows - 1 loop
            mem_id.row_data_ptr(i) := (last_refresh => NOW,
                                       rowptr => NULL,
                                       all_xs => FALSE
                                      );
        end loop;
        -- put default in data structure

        mem_id.default := new std_logic_vector(mem_id.width - 1 downto 0);

        if (default_word'length /= mem_id.width) then
            assert (default_word'length = 0)
                report "ROM_INITIALIZE:  Default word width does not match word width of memory:  "
                       & pstr(mem_id.name(1 to mem_id.name'length)) & LF & SPACESTR
                       & "default will be set to a word filled with 'U'"
                severity ERROR;
            for i in 0 to mem_id.width - 1 loop
               mem_id.default(i) := 'U';
            end loop;
        else

            mem_id.default.all := To_X01(default_word);

        end if;
        
        -- set wpb_mask

        mem_id.wpb_mask := new std_logic_vector(mem_id.width - 1 downto 0);

        for i in 0 to mem_id.width - 1 loop
           mem_id.wpb_mask(i) := '1';
        end loop;

        -- load memory from file
        if file_name /= "" then
            Mem_load (mem_id, file_name);
        end if;
        
        return mem_id;
    end;

    
    Function ROM_Initialize (  Constant name            : IN string;
                               Constant length          : IN POSITIVE;
                               Constant width           : IN POSITIVE;
                               Constant default_word    : IN std_ulogic_vector;
                               Constant file_name       : IN string := ""
                             ) return mem_id_type IS

    Variable mem_id : mem_id_type;

    begin
        mem_id := ROM_Initialize ( name,
                                   length,
                                   width,
                                   std_logic_vector (default_word),
                                   file_name
                                 );
        return mem_id;
    end;

    
    Function ROM_Initialize (  Constant name            : IN string;
                               Constant length          : IN POSITIVE;
                               Constant width           : IN POSITIVE;
                               Constant default_word    : IN bit_vector;
                               Constant file_name       : IN string := ""
                             ) return mem_id_type IS

    Variable mem_id : mem_id_type;

    begin
        mem_id := ROM_Initialize ( name,
                                   length,
                                   width,
                                   bv_To_StdLogicVector (default_word, default_word'length),
                                   file_name
                                 );
        return mem_id;
    end;

    

    -------------------------------------------------------------------------------------------------
    --    Function Name   :  from_int_to_hexstring
    --
    --    Purpose         :  to convert an integer to a hex string
    --
    --    Parameters      :  int      -  integer to be converted
    --                       format   -  length of string to be returned, if length not specified
    --                                   (or = 21) then length will be minimum necessary
    --
    --    RETURNED VALUE  :  string(1 to format)
    --
    --    NOTE            :  *** THIS FUNCTION NOT USER VISIBLE ***
    --
    -------------------------------------------------------------------------------------------------
    

    function from_int_to_hexstring ( Constant int    : IN integer;
                                     Constant format : IN integer := 21
                                   ) return string is

    Variable num : integer := int;
    Variable temp : string(1 to format);
    Variable i : integer;

    begin
        for i in format downto 1 loop
            temp(i) := DIGIT_TO_HEX(num mod 16);
            num := num / 16;
        end loop;
        if format /= 21 then
           return temp;
        else
            i := 1;
            while temp(i) = '0' loop
                 i := i + 1;
            end loop;
            return temp(i to format);
        end if;
    end;

                                        
    -------------------------------------------------------------------------------------------------
    --    Function Name   :  elim_spaces
    --
    --    Purpose         :  replace spaces in a string with 0's
    --
    --    Parameters      :  str - string operated on
    --
    --    RETURNED VALUE  :  string(1 to str'length)
    --
    --    NOTE            :  *** THIS FUNCTION NOT USER VISIBLE ***
    --
    -------------------------------------------------------------------------------------------------
                                    
    function elim_spaces  ( Constant str : IN STRING ) return string is

    Variable alias_str : string (1 to str'length) := str;
    Variable i : integer;

    begin
        for i in 1 to str'length loop
           if alias_str(i) = ' ' then
               alias_str(i) := '0';
           end if;
        end loop;
        return alias_str;
    end;
    
    -------------------------------------------------------------------------------------------------
    --    Procedure Name  :  dump_line
    --
    --    Purpose         :  write a data word to a memory file
    --                       if first word on the line then output the address first
    --
    --    Parameters      :  address            -- current address
    --                       data               -- data to be written
    --                       count              -- number of data words written to current line
    --                       out_file           -- output file
    --                       line_ptr           -- line ptr
    --                       data_format        -- format for data
    --                       addr_format        -- format for address
    --
    --    RETURNED VALUE  :  string(1 to str'length)
    --
    --    NOTE            :  *** THIS PROCEDURE NOT USER VISIBLE ***
    --
    -------------------------------------------------------------------------------------------------
    
    procedure dump_line ( Constant address        : IN Natural;
                          Constant data           : IN std_logic_vector;
                          Variable count          : INOUT integer;
                          Variable out_file       : OUT TEXT;
                          Variable line_ptr       : INOUT LINE;
                          Constant data_format    : IN STRING;   -- not needed in this version;
                          Constant addr_format    : IN integer
                        ) is

    begin
        if count = 0 then
            WRITE ( line_ptr, elim_spaces(from_int_to_hexstring(address, addr_format)) );
            WRITE ( line_ptr, ':' );
        end if;
        WRITE ( line_ptr, ' ' );
        WRITE ( line_ptr, elim_spaces(bv_to_hexstr( data_trans(data))) );
        count := (count + 1) mod WORDS_PER_LINE;
        if count = 0 then
            WRITELINE (out_file, line_ptr);
            DEALLOCATE(line_ptr);
        end if;
    end;
                        
    ---------------------------------------------------------------------------
    --    Procedure Name  :  Mem_Dump
    --
    --    Purpose         :  to dump the contents of memory to a file for 
    --                       later examination
    --
    --    Parameters      :  mem_id      - ptr to memory data structure
    --                       file_name   - name of the file used to load the ROM
    --                       start_addr  - starting address of dump
    --                       end_addr    - ending address of dump
    --                       header_flag - if true header is printed
    --
    --    NOTE            :  any memory (ROM's, SRAM's, and DRAM's) can be
    --                       dumped to a file
    --
    --    Use             :  Mem_Dump (DRAM_chip_1, "Ram1chip.dat", 1024, 2048)
    ---------------------------------------------------------------------------
        
    procedure Mem_Dump (  Variable mem_id          : INOUT mem_id_type;
                          Constant file_name       : IN string;
                          Constant start_addr      : IN Natural := 0;
                          Constant end_addr        : IN Natural := Natural'high;
                          Constant header_flag     : IN BOOLEAN := TRUE
                       ) IS

    Variable row, column, address : integer;    
    Variable count, i : integer;              -- count is number of data bytes written to the current line
    Variable e_addr : integer := end_addr;
    Variable ptr : rowptr_type;
    Variable data : std_logic_vector (mem_id.width -1 downto 0);
    Variable line_ptr : LINE;
    Variable addr_format : integer;
    Variable temp : string (1 to 3);
    Variable data_format : STRING(1 to 4) := "    ";
    Variable num_hex_digits : integer;
    file out_file : TEXT is OUT file_name;

    begin
        addr_format := StrLen1(from_int_to_hexstring(mem_id.length - 1)); -- # of hex chars in length of mem - 1
        num_hex_digits := (mem_id.width + 3) / 4;  -- # of hex chars in width of mem
        -- check address errors
        if start_addr > mem_id.length - 1 then
            assert false
                 report "Mem_Dump:  Starting address outside address space of memory:  " & pstr(mem_id.name(1 to mem_id.name'length))
                        & LF & SPACESTR & "Dumping aborted."
                 severity ERROR;
        elsif end_addr < start_addr then
            assert false
                report "Mem_Dump:  Starting address less than ending address of memory:  " & pstr(mem_id.name(1 to mem_id.name'length))
                       & LF & SPACESTR & "Dumping aborted."
                severity ERROR;
        else
            if end_addr > mem_id.length -1 then
                assert (end_addr = Natural'high)
                    report "Mem_Dump:  Ending address greater than maximum address of memory:  "
                           & pstr(mem_id.name(1 to mem_id.name'length)) & LF & SPACESTR & "Memory will be dumped until end."
                    severity ERROR;
                e_addr := mem_id.length - 1;
            end if;
            address := start_addr;            
            row := address / mem_id.columns;
            count := 0;
            -- output memory name, size, and width
            if ( header_flag ) then
               WRITE (line_ptr, STRING'("-- memory:  "));

               WRITE (line_ptr, mem_id.name(1 to mem_id.name'length));

               WRITELINE (out_file, line_ptr);
               DEALLOCATE(line_ptr);
               WRITE (line_ptr, STRING'("-- size (in decimal):  "));
               WRITE (line_ptr, i_to_str(mem_id.length) );
               WRITE (line_ptr, STRING'(" words "));
               WRITELINE (out_file, line_ptr);
               DEALLOCATE(line_ptr);
               if MEM_DUMP_TIME then
                  WRITE (line_ptr, STRING'("-- time:  "));
                  WRITE (line_ptr, NOW);
                  WRITELINE (out_file, line_ptr);
                  DEALLOCATE (line_ptr);
               end if;
               WRITE (line_ptr, STRING'("width: "));
               WRITE (line_ptr, from_int_to_hexstring(mem_id.width));
               WRITELINE (out_file, line_ptr);
               DEALLOCATE(line_ptr);
            end if;
            -- output data
            while address <= e_addr loop   -- loop by rows
                 assert false
                     report "Dumping memory:  " & pstr(mem_id.name(1 to mem_id.name'length)) & " to file:  " & file_name
                            & LF & SPACESTR & "Writing address:  " & i_to_str(address)
                     severity NOTE;
                 column := address mod mem_id.columns;     -- calcualte current column
                 validate_row(mem_id, row);
                 ptr := mem_id.row_data_ptr(row).rowptr;
                 if ptr = NULL then
                     if mem_id.row_data_ptr(row).all_xs then
                         data := (others => 'X');
                         while ( (column < mem_id.columns) and (address <= e_addr) ) loop
                              dump_line( address, data, count, out_file, line_ptr, data_format, addr_format);
                              column := column + 1;
                              address := address + 1;
                         end loop;
                     else

                         data := mem_id.default.all;

                         while ( (column < mem_id.columns) and (address <= e_addr) ) loop
                              dump_line( address, data, count, out_file, line_ptr, data_format, addr_format);
                              column := column + 1;
                              address := address + 1;
                         end loop;
                     end if;
                 else
                     while ( (column < mem_id.columns) and (address <= e_addr) ) loop
                         for i in 0 to mem_id.width - 1 loop
                             data(i) := ptr(column, i);
                         end loop;
                         dump_line ( address, data, count, out_file, line_ptr, data_format, addr_format);
                         column := column + 1;
                         address := address + 1;
                     end loop;
                 end if;
                 row := row + 1;
            end loop;
            WRITE (line_ptr, STRING'(""));
            WRITELINE (out_file, line_ptr);
            DEALLOCATE(line_ptr);
            assert false
                report "Mem_Dump:  Finished dumping memory:  " & pstr(mem_id.name(1 to mem_id.name'length)) & " to file:  " & file_name
                severity NOTE;
        end if;
    end;
                                                     
    ---------------------------------------------------------------------------
    --    Procedure Name  :  Mem_Reset
    --
    --    Purpose         :  To set the contents of a RAM to some predetermined
    --                       value.  The locations to reset are specified by a
    --                       range.
    --
    --    Parameters      :  mem_id       -  ptr to memory data structure
    --                       reset_value  -  value to reset memory to
    --                       start_addr   -  starting address within memory
    --                       end_addr     -  ending address withim memory
    --
    --    NOTE            :  Only works for DRAM's and SRAM's
    --
    --    Use             :  Mem_Reset (RAM, "1010", 2048, 4096);
    ---------------------------------------------------------------------------
    procedure  Mem_Reset ( Variable mem_id          : INOUT mem_id_type;
                           Constant reset_value     : IN std_logic_vector;
                           Constant start_addr      : IN NATURAL := 0;
                           Constant end_addr        : IN NATURAL := integer'high
                         ) IS

    begin
        Mem_All_Reset (mem_id, reset_value, start_addr, end_addr, FALSE);
    end;

    procedure  Mem_Reset ( Variable mem_id          : INOUT mem_id_type;
                           Constant reset_value     : IN std_ulogic_vector;
                           Constant start_addr      : IN NATURAL := 0;
                           Constant end_addr        : IN NATURAL := integer'high
                         ) IS

    begin
        Mem_All_Reset ( mem_id,
                        std_logic_vector (reset_value),
                        start_addr,
                        end_addr,
                        FALSE
                      );
    end;
             
    procedure  Mem_Reset ( Variable mem_id          : INOUT mem_id_type;
                           Constant reset_value     : IN bit_vector;
                           Constant start_addr      : IN NATURAL := 0;
                           Constant end_addr        : IN NATURAL := integer'high
                         ) IS

    begin
        Mem_All_Reset ( mem_id,
                        bv_To_StdLogicVector (reset_value, reset_value'length),
                        start_addr,
                        end_addr,
                        FALSE
                      );
    end;                         
                      
                                                          
    ---------------------------------------------------------------------------
    --    Procedure Name  :  Mem_Read
    --
    --    Purpose         :  To read a "word" from memory
    --
    --    Parameters      :  mem_id    -  ptr to memory data structure
    --                       address   -  address to read from
    --                       data      -  contents of memory location
    --                       
    --
    --    NOTE            :  a read refreshes row of a DRAM
    --
    --    Use             :  Mem_Read (ROM1, "100100111", data);
    ---------------------------------------------------------------------------

    Procedure Mem_Read (  Variable mem_id    : INOUT mem_id_type;
                          Constant address   : IN NATURAL;
                          Variable data      : OUT std_ulogic
                       ) IS

    begin
        Mem_Basic_Read (data, mem_id, address);
    end;                                                  

    Procedure Mem_Read (  Variable mem_id    : INOUT mem_id_type;
                          Constant address   : IN NATURAL;
                          Variable data      : OUT bit
                       ) IS

    Variable temp : std_ulogic;                   

    begin
        Mem_Basic_Read (temp, mem_id, address);
        data := data_trans(temp);
    end;                                                  
                       
    Procedure Mem_Read (  Variable mem_id    : INOUT mem_id_type;
                          Constant address   : IN bit_vector;
                          Variable data      : OUT bit
                       ) IS

    Variable temp : std_ulogic;                       
                       
    begin
        Mem_Basic_Read (temp, mem_id, address_trans(mem_id.length, address));
        data := data_trans(temp);
    end;                                                  

    Procedure Mem_Read (  Variable mem_id    : INOUT mem_id_type;
                          Constant address   : IN std_logic_vector;
                          Variable data      : OUT std_ulogic
                       ) IS
                       
    begin
        Mem_basic_Read (data, mem_id, address_trans(mem_id.length, address));
    end;                                                  

    Procedure Mem_Read (  Variable mem_id    : INOUT mem_id_type;
                          Constant address   : IN std_ulogic_vector;
                          Variable data      : OUT std_ulogic
                       ) IS
                       
    begin
        Mem_basic_Read (data, mem_id, address_trans(mem_id.length, address));
    end;                                                  

    Procedure Mem_Read (  Variable mem_id    : INOUT mem_id_type;
                          Constant address   : IN NATURAL;
                          Variable data      : OUT bit_vector
                       ) IS

    Variable Temp : std_logic_vector(data'length - 1 downto 0);     
                       
    begin
         Mem_Basic_Read (temp, mem_id, address);
         data := data_trans (temp);
    end;                                                  

    Procedure Mem_Read (  Variable mem_id    : INOUT mem_id_type;
                          Constant address   : IN NATURAL;
                          Variable data      : OUT std_logic_vector
                       ) IS

    begin
         Mem_Basic_Read (data, mem_id, address);
    end;
                           

    Procedure Mem_Read (  Variable mem_id    : INOUT mem_id_type;
                          Constant address   : IN NATURAL;
                          Variable data      : OUT std_ulogic_vector
                       ) IS

    Variable temp : std_logic_vector(data'length - 1 downto 0);         
                       
    begin
        Mem_Basic_Read (temp, mem_id, address);
        data := std_ulogic_vector(temp);
    end;                                                  

    Procedure Mem_Read (  Variable mem_id    : INOUT mem_id_type;
                          Constant address   : IN bit_vector;
                          Variable data      : OUT bit_vector
                       ) IS
                       
    Variable temp : std_logic_vector(data'length - 1 downto 0);

    begin
        Mem_Basic_Read (temp, mem_id, address_trans(mem_id.length, address));
        data := data_trans(temp);
    end;                                                  

    Procedure Mem_Read (  Variable mem_id    : INOUT mem_id_type;
                          Constant address   : IN std_logic_vector;
                          Variable data      : OUT std_logic_vector
                       ) IS
                       
    begin
        Mem_Basic_Read (data, mem_id, address_trans(mem_id.length, address));
    end;                                                  
                       
    Procedure Mem_Read (  Variable mem_id    : INOUT mem_id_type;
                          Constant address   : IN std_ulogic_vector;
                          Variable data      : OUT std_ulogic_vector
                       ) IS
                       
    Variable temp : std_logic_vector(data'length - 1 downto 0);

    begin
        Mem_Basic_Read (temp, mem_id, address_trans(mem_id.length, address));
        data := std_ulogic_vector (temp);
    end;                                                  

    
    ---------------------------------------------------------------------------
    --    Procedure Name  :  Mem_Write
    --
    --    Purpose         :  To write a "word" to memory
    --
    --    Parameters      :  mem_id        -  ptr to memory data structure
    --                       address       -  address to read from
    --                       data          -  "word" to be written to memory
    --                       write_per_bit -  enables write per bit for VRAMs if TRUE
    --
    --    NOTE            :  a write refreshes row of a DRAM
    --
    --    Use             :  Mem_Write (ROM1, "100100111", "10X1");
    ---------------------------------------------------------------------------
        
    Procedure Mem_Write (  Variable mem_id        : INOUT mem_id_type;
                           Constant address       : IN NATURAL;
                           Constant data          : IN std_ulogic;
                           Constant write_per_bit : IN BOOLEAN := FALSE
                        ) IS

    begin
        Mem_Basic_Write (mem_id, address, To_X01(data), Get_WPB_Mask(mem_id.width, mem_id.wpb_mask.all), write_per_bit);
    end;                                                  

    Procedure Mem_Write (  Variable mem_id        : INOUT mem_id_type;
                           Constant address       : IN NATURAL;
                           Constant data          : IN bit;
                           Constant write_per_bit : IN BOOLEAN := FALSE
                        ) IS

    begin
        Mem_Basic_Write (mem_id, address, bit_to_std_ulogic(data), Get_WPB_Mask(mem_id.width, mem_id.wpb_mask.all), write_per_bit );
    end;                                                  
                      
    Procedure Mem_Write (  Variable mem_id        : INOUT mem_id_type;
                           Constant address       : IN bit_vector;
                           Constant data          : IN bit;
                           Constant write_per_bit : IN BOOLEAN := FALSE
                        ) IS
                        
    begin
         Mem_Basic_Write ( mem_id,
                           address_trans (mem_id.length, address),
                           bit_to_std_ulogic (data),
                           Get_WPB_Mask(mem_id.width, mem_id.wpb_mask.all), 
                           write_per_bit
                         );
    end;                                                  
                      
    Procedure Mem_Write (  Variable mem_id        : INOUT mem_id_type;
                           Constant address       : IN std_logic_vector;
                           Constant data          : IN std_ulogic;
                           Constant write_per_bit : IN BOOLEAN := FALSE
                        ) IS
                        
    begin
         Mem_Basic_Write (  mem_id,
                            address_trans(mem_id.length, address),
                            To_X01 (data),
                            Get_WPB_Mask(mem_id.width, mem_id.wpb_mask.all), 
                            write_per_bit
                         );
    end;                                                  

    Procedure Mem_Write (  Variable mem_id        : INOUT mem_id_type;
                           Constant address       : IN std_ulogic_vector;
                           Constant data          : IN std_ulogic;
                           Constant write_per_bit : IN BOOLEAN := FALSE
                        ) IS
                        
    begin
        Mem_Basic_Write ( mem_id,
                          address_trans(mem_id.length, address),
                          To_X01 (data),
                          Get_WPB_Mask(mem_id.width, mem_id.wpb_mask.all), 
                          write_per_bit
                        );
    end;                                                  
                      
    Procedure Mem_Write (  Variable mem_id        : INOUT mem_id_type;
                           Constant address       : IN NATURAL;
                           Constant data          : IN bit_vector;
                           Constant write_per_bit : IN BOOLEAN := FALSE
                        ) IS


    begin
        Mem_Basic_Write (  mem_id,
                           address,
                           bv_To_StdLogicVector (data,data'length),
                           Get_WPB_Mask(mem_id.width, mem_id.wpb_mask.all), 
                           write_per_bit
                        );
    end;

    Procedure Mem_Write (  Variable mem_id        : INOUT mem_id_type;
                           Constant address       : IN NATURAL;
                           Constant data          : IN std_logic_vector;
                           Constant write_per_bit : IN BOOLEAN := FALSE
                        ) is
                        
    begin
        Mem_Basic_Write (mem_id, address, To_X01(data), Get_WPB_Mask(mem_id.width, mem_id.wpb_mask.all), write_per_bit);
    end;
                         
                        
    Procedure Mem_Write (  Variable mem_id        : INOUT mem_id_type;
                           Constant address       : IN NATURAL;
                           Constant data          : IN std_ulogic_vector;
                           Constant write_per_bit : IN BOOLEAN := FALSE
                        ) IS
                        
    begin
        Mem_Basic_Write (  mem_id,
                           address,
                           To_X01 (std_logic_vector (data)),
                           Get_WPB_Mask(mem_id.width, mem_id.wpb_mask.all), 
                           write_per_bit
                        );
    end;                                                  
                      
    Procedure Mem_Write (  Variable mem_id        : INOUT mem_id_type;
                           Constant address       : IN std_logic_vector;
                           Constant data          : IN std_logic_vector;
                           Constant write_per_bit : IN BOOLEAN := FALSE
                        ) IS

    begin
        Mem_Basic_Write (  mem_id,
                           Address_trans(mem_id.length, address),
                           To_X01 (data),
                           Get_WPB_Mask(mem_id.width, mem_id.wpb_mask.all), 
                           write_per_bit
                        );
    end;                                                  

    Procedure Mem_Write (  Variable mem_id        : INOUT mem_id_type;
                           Constant address       : IN std_ulogic_vector;
                           Constant data          : IN std_ulogic_vector;
                           Constant write_per_bit : IN BOOLEAN := FALSE
                        ) IS
                        
    begin
        Mem_Basic_Write (  mem_id,
                           Address_trans(mem_id.length, address),
                           To_X01(std_logic_vector(data)),
                           Get_WPB_Mask(mem_id.width, mem_id.wpb_mask.all), 
                           write_per_bit
                        );
    end;                                                  

    Procedure Mem_Write (  Variable mem_id        : INOUT mem_id_type;
                           Constant address       : IN bit_vector;
                           Constant data          : IN bit_vector;
                           Constant write_per_bit : IN BOOLEAN := FALSE
                        ) IS

    begin
        Mem_Basic_Write (  mem_id,
                           Address_trans(mem_id.length, address),
                           bv_To_StdLogicVector(data, data'length),
                           Get_WPB_Mask(mem_id.width, mem_id.wpb_mask.all), 
                           write_per_bit
                        );
    end;                                                  
                        
    ---------------------------------------------------------------------------
    --    Procedure Name  :  Mem_Refresh
    --
    --    Purpose         :  refresh a row of memory;
    --
    --    Parameters      :  mem_id    -  ptr to memory data structure
    --
    --    NOTE            :  refreshes a row of memory and  increments refresh
    --                       counter.  Valid only for DRAM's.
    --
    --    Use             :  Mem_Refresh (ROM1);
    ---------------------------------------------------------------------------

    Procedure Mem_Refresh (  Variable mem_id : INOUT mem_id_type) IS

    begin
        if ((mem_id.memory_type = DRAM) or (mem_id.memory_type = VRAM)) then
            if (mem_id.last_init+mem_id.refresh_period <  NOW) then
                assert NOT MEM_WARNINGS_ON         
                    report "Mem_Refresh:  Device wake-up time limit exceeded for memory:  "
                           & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR &
                           "operation ignored, device must be woken up"
                   severity WARNING;
            else
                validate_row (mem_id, mem_id.counter);
                refresh_row (mem_id, mem_id.counter);
                mem_id.counter := (mem_id.counter + 1) mod mem_id.rows;
            end if;
        else
            assert NOT MEM_WARNINGS_ON
                   report "Mem_Refesh:  attempt to refresh a SRAM or ROM."
                           & LF & SPACESTR &
                          "  No operation will be performed."
                   severity WARNING;
        end if;
    end;                                                  
                          
    ---------------------------------------------------------------------------
    --    Procedure Name   :  Mem_Valid
    --
    --    Purpose         :  Check if memory address contains a valid value
    --                       i.e. a '0' or a '1'
    --
    --    Parameters      :  mem_id    -  ptr to memory data structure
    --                       address   -  address of memory location to be
    --                                    checked
    --                       DataValid -  true if location contains a '0' or a
    --                                    '1' and refresh time not exceeded    
    --
    --    NOTE            :  if DRAM refresh time for Row is exceeded then
    --                       fill row with X's
    --
    --    Use             :  Mem_Valid (RAM1_id, "100X1101", good);
    ---------------------------------------------------------------------------

    Procedure Mem_Valid ( Variable mem_id     :  INOUT mem_id_type;
                          Constant address    :  IN NATURAL;
                          Variable DataValid  :  OUT BOOLEAN
                        ) IS
                        
    Variable data : std_logic_vector (mem_id.width - 1 downto 0);
    Variable i : NATURAL := 0;
                                  
    begin
        Mem_Basic_Read (data, mem_id, address, FALSE);
        while (( i< mem_id.width) and ((data(i) = '0') or (data(i) = '1'))) loop
             i := i + 1;
        end loop;
        DataValid := (i >= mem_id.width);
    end;                                                  

    Procedure Mem_Valid ( Variable mem_id     :  INOUT mem_id_type;
                          Constant address    :  IN bit_vector;
                          Variable DataValid  :  OUT BOOLEAN
                        ) IS
                        
    begin
         Mem_Valid (mem_id, address_trans(mem_id.length, address), DataValid);
    end;                                                  

    Procedure Mem_Valid ( Variable mem_id     :  INOUT mem_id_type;
                          Constant address    :  IN std_logic_vector;
                          Variable DataValid  :  OUT BOOLEAN
                        ) IS
                        
    begin
        Mem_Valid (mem_id, address_trans(mem_id.length, address), DataValid);
    end;                                                  

    Procedure Mem_Valid ( Variable mem_id     :  INOUT  mem_id_type;
                          Constant address    :  IN std_ulogic_vector;
                          Variable DataValid  :  OUT BOOLEAN
                        ) IS

    begin
        Mem_Valid (mem_id, address_trans(mem_id.length, address), DataValid);
    end;                                                  
                                                                         
    ---------------------------------------------------------------------------
    --    Procedure Name  :  Mem_Access
    --
    --    Purpose         :  To read a "word" from memory without doing a
    --                    :  refresh if memory is a dynamic ram
    --
    --    Parameters      :  mem_id    -  ptr to memory data structure
    --                       address   -  address to read from
    --                       data      -  contents of memory location
    --
    --    NOTE            :  same as Mem_Read but does not do a refresh if the
    --                       memory is a DRAM.  It does, however, set all
    --                       addresses in a row to 'X' if the refresh time
    --                       is exceeded.  To be used essentially for debug
    --                       purposes.
    --
    --    Use             :  Mem_Access (ROM1, "100100111", dbus);
    ---------------------------------------------------------------------------
        
    Procedure Mem_Access (  Variable mem_id    : INOUT mem_id_type;
                            Constant address   : IN NATURAL;
                            Variable data      : OUT std_ulogic
                         ) IS

    begin
        Mem_Basic_Read (data, mem_id, address, FALSE);
    end;                                                  

    Procedure Mem_Access (  Variable mem_id    : INOUT mem_id_type;
                            Constant address   : IN NATURAL;
                            Variable data      : OUT bit
                         ) IS

    Variable temp : std_ulogic;                   

    begin
        Mem_Basic_Read (temp, mem_id, address, FALSE);
        data := data_trans(temp);
    end;                                                  
                       
    Procedure Mem_Access (  Variable mem_id    : INOUT mem_id_type;
                            Constant address   : IN bit_vector;
                            Variable data      : OUT bit
                         ) IS

    Variable temp : std_ulogic;                       
                       
    begin
        Mem_Basic_Read (temp, mem_id, address_trans(mem_id.length, address), FALSE);
        data := data_trans(temp);
    end;                                                  

    Procedure Mem_Access (  Variable mem_id    : INOUT mem_id_type;
                            Constant address   : IN std_logic_vector;
                            Variable data      : OUT std_ulogic
                         ) IS
                       
    begin
        Mem_basic_Read (data, mem_id, address_trans(mem_id.length, address), FALSE);
    end;                                                  

    Procedure Mem_Access (  Variable mem_id    : INOUT mem_id_type;
                            Constant address   : IN std_ulogic_vector;
                            Variable data      : OUT std_ulogic
                         ) IS
                       
    begin
        Mem_basic_Read (data, mem_id, address_trans(mem_id.length, address), FALSE);
    end;                                                  

    Procedure Mem_Access (  Variable mem_id    : INOUT mem_id_type;
                            Constant address   : IN NATURAL;
                            Variable data      : OUT bit_vector
                         ) IS

    Variable Temp : std_logic_vector(data'length - 1 downto 0);     
                       
    begin
         Mem_Basic_Read (temp, mem_id, address, FALSE);
         data := data_trans (temp);
    end;                                                  

    Procedure Mem_Access (  Variable mem_id    : INOUT mem_id_type;
                            Constant address   : IN NATURAL;
                            Variable data      : OUT std_logic_vector
                         ) IS

    begin
         Mem_Basic_Read (data, mem_id, address, FALSE);
    end;
                           

    Procedure Mem_Access (  Variable mem_id    : INOUT mem_id_type;
                            Constant address   : IN NATURAL;
                            Variable data      : OUT std_ulogic_vector
                         ) IS

    Variable temp : std_logic_vector(data'length - 1 downto 0);         
                       
    begin
        Mem_Basic_Read (temp, mem_id, address, FALSE);
        data := std_ulogic_vector(temp);
    end;                                                  

    Procedure Mem_Access (  Variable mem_id    : INOUT mem_id_type;
                            Constant address   : IN bit_vector;
                            Variable data      : OUT bit_vector
                         ) IS
                       
    Variable temp : std_logic_vector(data'length - 1 downto 0);

    begin
        Mem_Basic_Read (temp, mem_id, address_trans(mem_id.length, address), FALSE);
        data := data_trans(temp);
    end;                                                  

    Procedure Mem_Access (  Variable mem_id    : INOUT mem_id_type;
                            Constant address   : IN std_logic_vector;
                            Variable data      : OUT std_logic_vector
                         ) IS
                       
    begin
        Mem_Basic_Read (data, mem_id, address_trans(mem_id.length, address), FALSE);
    end;                                                  
                       
    Procedure Mem_Access (  Variable mem_id    : INOUT mem_id_type;
                            Constant address   : IN std_ulogic_vector;
                            Variable data      : OUT std_ulogic_vector
                         ) IS
                       
    Variable temp : std_logic_vector(data'length - 1 downto 0);

    begin
        Mem_Basic_Read (temp, mem_id, address_trans(mem_id.length, address), FALSE);
        data := std_ulogic_vector (temp);
    end;


    --------------------------------------------------------------------------------
    -- ************************************************************************** --
    --------------------------------------------------------------------------------
    -- Video RAM Procedures
    --------------------------------------------------------------------------------
    -- ************************************************************************** --
    --------------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --    Function Name   :  powerof2
    --    HIDDEN
    --    Purpose         :  to determine if the input is a number that can be
    --                       represented by 2^n where n is a non-negative integer
    --
    --    Parameters      :  arg - value to be determined if it is a power of 2
    --
    --    RETURNED VALUE  :  BOOLEAN (true if arg is a power of 2)
    --
    ---------------------------------------------------------------------------

    Function powerof2 ( Constant arg : IN NATURAL ) return BOOLEAN is
       variable temp : NATURAL := arg;
    begin
       while temp > 0 loop
          if (temp mod 2 /= 0) then
             return FALSE;
          end if;
          temp := temp / 2;
       end loop;
       return TRUE;
    end;
    

    ---------------------------------------------------------------------------    
    --    Function Name   :  VRAM_Initialize
    --
    --    Purpose         :  To create the data structure used to store a
    --                       Video RAM and to initialize it
    --
    --    Parameters      :  name           - string used to represent the memory
    --                       rows           - the # of rows in the memory
    --                       columns        - the number of "words" in each row
    --                       width          - the length of a "word" of memory
    --                       sam_columns    - the number of columns (words) in the SAM
    --                       block_size     - the maxinum number of words written to when
    --                                        performing a block write
    --                       refresh_period - max time between refresh of each
    --                                        row that will maintain valid data
    --                       default_word   - value to which each word of
    --                                        memory should be initialized
    --
    --    RETURNED VALUE  :  mem_id_type - pointer to memory record
    --
    --    NOTE            :  initially the data structure is empty with no
    --                       space being allocated for the memory
    --
    ---------------------------------------------------------------------------
        
    Function VRAM_Initialize ( Constant name            : IN string;
                               Constant rows            : IN POSITIVE;
                               Constant columns         : IN POSITIVE;
                               Constant width           : IN POSITIVE;
                               Constant sam_columns     : IN POSITIVE;
                               Constant block_size      : IN POSITIVE := 1;
                               Constant refresh_period  : IN TIME;
                               Constant default_word    : IN std_logic_vector
                             ) return mem_id_type IS

    Variable i, name_len : INTEGER;
    Variable mem_id : mem_id_type;
    Variable alias_name : string (1 to name'length) := name;
    subtype constrained_matrix is
                 row_matrix (0 to sam_columns-1, 0 to width-1);

    begin
        -- create and initialize data structure

        mem_id := new mem_id_rtype '( memory_type => VRAM,
                                      refresh_period => refresh_period,
                                      last_init => NOW - refresh_period - 100 ns,
                                      counter => 0,
                                      name => NULL,
                                      rows => rows,
                                      columns => columns,
                                      width => width,
                                      length => rows * columns,
                                      row_data_ptr => NULL,
                                      default => NULL,
                                      sam_columns => sam_columns,
                                      sam_lower_tap => 0,
                                      sam_upper_tap => sam_columns/2,
                                      serial_ptr => 0,
                                      block_size => 1,
                                      wpb_mask => NULL,
                                      sam_data => NULL
                                     );

        
        -- put name of memory into data structure
        name_len := 1;
        while ( (name_len <= alias_name'length) and (alias_name(name_len) /= nul)) loop
           name_len := name_len + 1;
        end loop;
        name_len := name_len - 1;

        mem_id.name := new string(1 to name_len);

        for i in 1 to name_len loop
           mem_id.name(i) := alias_name(i);
        end loop;
        -- initialize row data

        mem_id.row_data_ptr := new row_data(0 to rows - 1);

        for i in 0 to rows - 1 loop
            mem_id.row_data_ptr(i) := (last_refresh => NOW,
                                       rowptr => NULL,
                                       all_xs => TRUE
                                      );
        end loop;
        -- handle block size
        mem_id.block_size := block_size;
        if powerof2(block_size) then
           assert false
              report "VRAM_Initialize:  Block size for Mem_Block_Write must be a power of 2." & LF & SPACESTR &
                     "Resetting block size to 1."
              severity ERROR;
           mem_id.block_size := 1;
        end if;
        if (mem_id.width mod block_size /= 0) then
           assert false
              report "VRAM_Initalize:  Block size for Mem_Block_Write must be a factor of the word width of the VRAM."
                     & LF & SPACESTR & "Resetting block size to 1."
              severity ERROR;
           mem_id.block_size := 1;
        end if;
        if (block_size > mem_id.width) then
           assert false
              report "VRAM_Initialize:  Block size for Mem_Block_Write must be less than the word width of the VRAM." 
                     & LF & SPACESTR & "Resetting block size to 1."
              severity ERROR;
           mem_id.block_size := 1;
        end if;
        if (block_size > mem_id.columns) then
           assert FALSE
              report "VRAM_Initialize:  BLock size for Mem_Block_Write must be no larger than the number of columns in the VRAM."
              & LF & SPACESTR & "Resetting block size to the number of columns."
           severity ERROR;
           mem_id.block_size := mem_id.columns;
        end if;
        -- set size of SAM
        if ( (sam_columns /= columns) and ( (2 * sam_columns) /= columns) ) then
           assert FALSE
              report "VRAM_Initialize:  Serial Access Memory size must be equal to # of DRAM columns"
                     & LF & SPACESTR & "or half that number."
              severity ERROR;
        end if;
        -- allocate memory for SAM

            mem_id.sam_data := new constrained_matrix;

        for i in 0 to sam_columns - 1 loop
            for j in 0 to mem_id.width - 1 loop
                mem_id.sam_data(i,j) := 'U';
            end loop;
        end loop;
        
        -- set default word

        mem_id.default := new std_logic_vector(mem_id.width - 1 downto 0);

        if (default_word'length /= mem_id.width) then
            assert (default_word'length = 0)
                report "VRAM_INITIALIZE:  Default word width does not match word width of memory:  "
                       & pstr(mem_id.name(1 to mem_id.name'length)) & LF & SPACESTR 
                       & "default will be set to a word filled with 'U'"
                severity ERROR;
            for i in 0 to mem_id.width - 1 loop
                mem_id.default(i) := 'U';
            end loop;
        else

            mem_id.default.all := To_X01(default_word);

        end if;
        -- set wpb_mask

        mem_id.wpb_mask := new std_logic_vector(mem_id.width - 1 downto 0);

        for i in 0 to mem_id.width - 1 loop
           mem_id.wpb_mask(i) := '1';
        end loop;
        
        return mem_id;
    end;


    Function VRAM_Initialize ( Constant name            : IN string;
                               Constant rows            : IN POSITIVE;
                               Constant columns         : IN POSITIVE;
                               Constant width           : IN POSITIVE;
                               Constant sam_columns     : IN POSITIVE;
                               Constant block_size      : IN POSITIVE := 1;
                               Constant refresh_period  : IN TIME;
                               Constant default_word    : IN std_ulogic_vector
                             ) return mem_id_type IS

    Variable mem_id : mem_id_type;

    begin
        mem_id := VRAM_Initialize ( name,
                                    rows,
                                    columns,
                                    width,
                                    sam_columns,
                                    block_size,
                                    refresh_period,
                                    std_logic_vector(default_word)
                                  );
        return mem_id;
    end;


    Function VRAM_Initialize ( Constant name            : IN string;
                               Constant rows            : IN POSITIVE;
                               Constant columns         : IN POSITIVE;
                               Constant width           : IN POSITIVE;
                               Constant sam_columns     : IN POSITIVE;
                               Constant block_size      : IN POSITIVE := 1;
                               Constant refresh_period  : IN TIME;
                               Constant default_word    : IN bit_vector
                             ) return mem_id_type IS

    Variable mem_id : mem_id_type;

    begin


        mem_id := VRAM_Initialize ( name,
                                    rows,
                                    columns,
                                    width,
                                    sam_columns,
                                    block_size,
                                    refresh_period,
                                    bv_to_StdLogicVector(default_word, default_word'length)
                                  );
        return mem_id;
    end;

    ---------------------------------------------------------------------------    
    --    Procedure Name  :  Mem_Set_WPB_Mask
    --
    --    Purpose         :  set write-per-bit mask for specified VRAM
    --                       
    --    Parameters      :  mem_id - ptr to memory data structure
    --                       mask   - mask for write-per-bit
    --                       
    --    NOTE            :  VRAM only
    --
    ---------------------------------------------------------------------------
                                      
    Procedure Mem_Set_WPB_Mask ( Variable mem_id : INOUT mem_id_type;
                                 Constant mask   : IN std_logic_vector
                               ) is
        constant alias_mask : std_logic_vector(mask'length - 1 downto 0) := mask;
        variable mem_word   : std_logic_vector(mem_id.width - 1 downto 0) := (others => 'X');
        variable found_x    : BOOLEAN := FALSE;
    begin
       if ( (mem_id.memory_type /= VRAM) and (NOT EXTENDED_OPS) ) then
          assert FALSE
             report "Mem_Set_WPB_Mask:  This operation is only valid for VRAMs." & LF & SPACESTR &
                    "Operation ignored."
             severity ERROR;
       else
          assert ( (mask'length >= mem_id.width) or NOT MEM_WARNINGS_ON )
             report "Mem_Set_WPB_Mask:  passed mask size less than  word size of memory:  "
                    & pstr(mem_id.name(1 to mem_id.name'length)) & LF & SPACESTR &
                    "passed mask size:  " & i_to_str(mask'length) & " bits"
                    & LF & SPACESTR & "memory word size:  " &
                    i_to_str(mem_id.width)  & " bits"
                    & LF & SPACESTR & "Expect an assertion for Xs in write per bit mask as a result."
             severity WARNING;
          assert ( (mask'length <= mem_id.width) or NOT MEM_WARNINGS_ON )
             report "Mem_Set_WPB_Mask:  passed mask size greater than word size of memory:  "
                    & pstr(mem_id.name(1 to mem_id.name'length)) & LF & SPACESTR &
                    "passed mask size:  " & i_to_str(mask'length) & " bits"
                    & LF & SPACESTR & "memory word size:  " &
                    i_to_str(mem_id.width)  & " bits"
             severity WARNING;
          if (mem_id.width >= mask'length) then
             mem_word(mask'LENGTH - 1 downto 0) := To_X01(alias_mask);
          else
             mem_word := To_X01(alias_mask(mem_id.width - 1 downto 0));
          end if;
          for ii in 0 to mem_id.width - 1 loop
             if (mem_word(ii) = 'X') then
                found_x := TRUE;
                mem_word(ii) := To_StdULogic(DATA_X_MAP);
             end if;
          end loop;
          assert ( (NOT found_x) or NOT MEM_WARNINGS_ON )
             report "Mem_Set_WPB_Mask:  X found in write per bit mask.  Mapping X to " & to_str(DATA_X_MAP)
             severity WARNING;          

          -- mem_id.wpb_mask(mem_id.width - 1 downto 0) := mem_word;
	  -- bug fix for synopsys 3.3b
	  mem_id.wpb_mask.all := assign_wpb_mask(mem_id.wpb_mask.all, mem_id.width, mem_word);

       end if;
    end;

    Procedure Mem_Set_WPB_Mask ( Variable mem_id : INOUT mem_id_type;
                                 Constant mask   : IN std_ulogic_vector
                               ) is
    begin
       Mem_Set_WPB_Mask ( mem_id => mem_id,
                          mask   => std_logic_vector(mask)
                        );
    end;
    
    Procedure Mem_Set_WPB_Mask ( Variable mem_id : INOUT mem_id_type;
                                 Constant mask   : IN bit_vector
                               ) is
    begin
       Mem_Set_WPB_Mask ( mem_id => mem_id,
                          mask   => bv_to_StdLogicVector(mask)
                        );
    end;
    
    ---------------------------------------------------------------------------    
    --    Procedure Name  :  get_cmask
    --    HIDDEN
    --    Purpose         :  to take the column mask and make it the proper length
    --                       and handle any Xs
    --                       
    --    Parameters      :  mask_out : std_logic_vector  
    --                       mask_in  : std_logic_vector
    --
    --    NOTE            :  for use with Mem_Block_Write
    --
    --                       Length or shorten column mask to proper length.
    --                       The proper length is the length of mask_out.
    --                       If its too short assume it specifies LSBs and
    --                       the MSBs are X's.
    --                       All Xs are converted to DATA_X_MAP.
    --
    ---------------------------------------------------------------------------

    Procedure get_cmask ( Variable mask_out : OUT std_logic_vector;
                          Constant mask_in  : IN  std_logic_vector;
                          Constant mem_name : IN  STRING
                        ) is

       constant out_len       : INTEGER := mask_out'LENGTH;
       variable result        : std_logic_vector(out_len - 1 downto 0) := (others => 'X');
       variable alias_mask_in : std_logic_vector(mask_in'LENGTH - 1 downto 0) := To_X01(mask_in);
       variable found_x       : BOOLEAN := FALSE;
    begin
       assert ( (mask_in'length >= out_len) or NOT MEM_WARNINGS_ON )
          report "Mem_Block_Write:  passed column mask size less than  word size of memory:  "
                 & mem_name & LF & SPACESTR &
                 "passed mask size:  " & i_to_str(mask_in'length) & " bits"
                 & LF & SPACESTR & "memory word size:  " &
                 i_to_str(out_len)  & " bits"
                 & LF & SPACESTR & "Expect an assertion for Xs in column mask as a result."
          severity WARNING;
       assert ( (mask_in'length <= out_len) or NOT MEM_WARNINGS_ON )
          report "Mem_Block_Write:  passed column mask size greater than word size of memory:  "
                 & mem_name & LF & SPACESTR &
                 "passed mask size:  " & i_to_str(mask_in'length) & " bits"
                 & LF & SPACESTR & "memory word size:  " &
                 i_to_str(out_len)  & " bits"
          severity WARNING;
       if (out_len >= mask_in'LENGTH) then
          result(mask_in'LENGTH - 1 downto 0) := To_X01(alias_mask_in);
       else
          result := To_X01(alias_mask_in(out_len - 1 downto 0));
       end if;
       for ii in 0 to out_len - 1 loop
          if (result(ii) = 'X') then
             found_x := TRUE;
             result(ii) := To_StdULogic(DATA_X_MAP);
          end if;
       end loop;
       assert ( (NOT found_x) or NOT MEM_WARNINGS_ON )
          report "Mem_Block_Write:  X found in column mask.  Mapping X to " & to_str(DATA_X_MAP)
          severity WARNING;          
       mask_out := result;
    end;

    ---------------------------------------------------------------------------    
    --    Function Name   :  explode_column_mask
    --    HIDDEN
    --    Purpose         :  to expand to column_mask for a particular column
    --                       so that it can be ANDed with the wpb mask
    --                       
    --    Parameters      :  column_mask  -  1s in mask specify columns to be written
    --                       block_size   -  max # of words to be written in a block write
    --                       column       -  column (from initial) currently being written
    --
    --    Return Value    :  std_logic_vector(mask_size - 1 downto 0)
    --                       exploded column mask for the specified column
    --                       
    --    NOTE            :  for use with Mem_Block_Write
    --
    --    EXAMPLE         :  if the memory has a width of 8 and the max #
    --                       of words that can be written during a block write
    --                       4 then given the column mask:
    --
    --                       column_mask = 1001 0011
    --
    --                       block size  = 4
    --                       
    --                       the following is the result of this procedure call
    --                       for the valid values of column
    --
    --                       column            result 
    --                       ------         ------------
    --                         0             1111 1111
    --                         1             0000 1111
    --                         2             0000 0000
    --                         3             1111 0000
    --
    ---------------------------------------------------------------------------

    Function explode_column_mask ( Constant column_mask : IN std_logic_vector;
                                   Constant block_size  : IN POSITIVE;
                                   Constant column      : IN NATURAL
                                 ) return std_logic_vector is

       variable result     : std_logic_vector(column_mask'RANGE) := (others => '1');
       variable num_blocks : integer := column_mask'LENGTH / block_size;
       variable base_index : integer;
    begin
       if (column >= block_size) then
          assert FALSE
             report "Mem_Block_Write:  Internal error in explode_column_mask."
             severity ERROR;
       else
          for i in 0 to num_blocks - 1 loop
             base_index := i * block_size;
             result(base_index + block_size - 1 downto base_index) := (others => column_mask(base_index + column));
          end loop;
       end if;
       return result;
    end;    

    ---------------------------------------------------------------------------    
    --    Procedure Name  :  Mem_Block_Write
    --
    --    Purpose         :  (VRAM) Write a word to a block of memory
    --                       
    --    Parameters      :  mem_id        - ptr to memory data structure
    --                       address       - address to start writing data to
    --                       data          - word to be written to DRAM
    --                       column_mask   - 1s in mask specify columns to be written to
    --                       write_per_bit - write per bit enabled if TRUE
    --                       
    --    NOTE            :  equivalent to block_size calls to Mem_Write
    --
    ---------------------------------------------------------------------------

    Procedure Mem_Block_Write ( Variable mem_id        : INOUT mem_id_type;
                                Constant address       : IN NATURAL;
                                Constant data          : IN std_logic_vector;
                                Constant column_mask   : IN std_logic_vector := "";
                                Constant write_per_bit : IN BOOLEAN := FALSE
                              ) is

       constant all_zeros        : std_logic_vector(mem_id.width - 1 downto 0) := (others => '0');
       constant all_ones         : std_logic_vector(mem_id.width - 1 downto 0) := (others => '1');
       variable new_mem_word     : std_logic_vector(mem_id.width - 1 downto 0) := (others => 'X');
       variable write_word       : std_logic_vector(mem_id.width - 1 downto 0) := (others => 'X');
       variable alias_data       : std_logic_vector(data'LENGTH - 1 downto 0) := TO_X01(data);
       variable twpb_mask        : std_logic_vector(mem_id.width - 1 downto 0) := (others => '1');
       variable wpb_mask         : std_logic_vector(mem_id.width - 1 downto 0) := (others => '1');
       variable alias_cmask      : std_logic_vector(mem_id.width - 1 downto 0) := (others => '1');
       variable tblock_size      : POSITIVE := mem_id.block_size;
       variable row, column      : INTEGER;
       variable short_ptr        : rowptr_type;
       variable rblock_size      : INTEGER;  -- synopsys bug fix

    begin
       if ( ((mem_id.memory_type /= VRAM) and (NOT EXTENDED_OPS)) or (mem_id.memory_type = ROM) ) then
          assert FALSE
             report "Mem_Block_Write:  This operation is only valid for VRAMs." & LF & SPACESTR &
                    "Operation ignored."
             severity ERROR;
       else
          if address >=  mem_id.length then
             assert FALSE
                report "Mem_Block_Write:  address out of address space of memory:  " & pstr(mem_id.name(1 to mem_id.name'length))
                       & LF & SPACESTR & "block write addresss:  " & i_to_str(address) & LF & SPACESTR &
                       "max address of memory:  " & i_to_str(mem_id.length - 1) & LF & SPACESTR &
                       "Operation ignored."
                severity ERROR;
          elsif (address mod mem_id.block_size /= 0) then
             assert FALSE
                report "Mem_Block_Write:  address must be a multiple of the block size of memory:  " &
                        pstr(mem_id.name(1 to mem_id.name'length)) & "." & LF & SPACESTR &
                        "Operation ignored."
                severity ERROR;
          else
             if (mem_id.last_init + mem_id.refresh_period >= NOW) or (mem_id.memory_type = SRAM) or (mem_id.memory_type = ROM) then
                if column_mask'LENGTH > 0 then  -- if column mask has zero length then it defaults to all 1's (i.e. its unspecified)
                   -- convert column mask to proper length and eliminate Xs
                   get_cmask (alias_cmask, column_mask, pstr(mem_id.name(1 to mem_id.name'length)));   
                end if;
                if (address + tblock_size >= mem_id.length) then
                   tblock_size := mem_id.length - address;
                   assert NOT Mem_WARNINGS_ON
                      report "Mem_Block_Write:  block to be written to spans past end of memory:  "
                             & pstr(mem_id.name(1 to mem_id.name'length)) & "."
                             & LF & SPACESTR & "Block write will terminate at end of memory."
                      severity WARNING;
                end if;
                -- take care of adjusting word to size of memory here avoids multiple assertions during Mem_Basic_Write
                assert ( (data'length = mem_id.width) or NOT MEM_WARNINGS_ON )
                   report "Mem_Block_Write:  passed data size does not match word size of memory:  "
                          & pstr(mem_id.name(1 to mem_id.name'length)) & LF & SPACESTR &
                          "passed data size:  " & i_to_str(data'length) & " bits"
                          & LF & SPACESTR & "memory word size:  " &
                          i_to_str(mem_id.width)  & " bits"
                   severity WARNING;
                if (mem_id.width >= data'length) then
                   new_mem_word(data'LENGTH - 1 downto 0) := To_X01(alias_data);
                else
                   new_mem_word := To_X01(alias_data(mem_id.width - 1 downto 0));
                end if;
                if write_per_bit then
                   wpb_mask := Get_WPB_Mask(mem_id.width, mem_id.wpb_mask.all);
                end if;
                -- calculate row
                row := address/mem_id.columns;
                -- validate address and  report if refresh time exceeded
                validate_row(mem_id, row);
                -- refresh the row
                refresh_row (mem_id,row);
                -- if row never allocated then allocate it
                if (mem_id.row_data_ptr(row).rowptr = NULL) then
                   allocate_row(mem_id, row);
                end if;
                short_ptr := mem_id.row_data_ptr(row).rowptr;
                for aa in address to address + tblock_size - 1 loop
                   -- AND write_per_bit mask with exploded column_mask to get resultant write per bit mask
                   rblock_size := mem_id.block_size;
                   twpb_mask := wpb_mask and explode_column_mask(alias_cmask, rblock_size, aa - address);
                   if (twpb_mask /= all_zeros) then
                      column := aa mod mem_id.columns;
                      if (twpb_mask /= all_ones) then  -- i.e. write per bit is false
                         for i in 0 to mem_id.width - 1 loop
                            write_word(i) := short_ptr(column,i);
                         end loop;
                         for ii in 0 to mem_id.width - 1 loop
                            if (twpb_mask(ii) = '1') then
                               write_word(ii) := new_mem_word(ii);
                            end if;
                         end loop;
                      else
                         write_word := new_mem_word;
                      end if;
                      for i in 0 to mem_id.width - 1 loop
                         short_ptr(column,i) := write_word(i);
                      end loop;
                   end if;
                end loop;
             else
                assert NOT MEM_WARNINGS_ON
                   report "Mem_Block_Write:  Device wake-up time limit exceeded for memory:  "
                          & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR &
                          "Operation ignored, device must be woken up."
                   severity WARNING;
             end if;
          end if;
       end if;
    end;
 
    Procedure Mem_Block_Write ( Variable mem_id        : INOUT mem_id_type;
                                Constant address       : IN NATURAL;
                                Constant data          : IN std_ulogic_vector;
                                Constant column_mask   : IN std_ulogic_vector := "";
                                Constant write_per_bit : IN BOOLEAN := FALSE
                              ) is
                          
   begin
      Mem_Block_Write ( mem_id,
                        address,
                        std_logic_vector(data),
                        std_logic_vector(column_mask),
                        write_per_bit
                      );
   end;
    
                          
    Procedure Mem_Block_Write ( Variable mem_id        : INOUT mem_id_type;
                                Constant address       : IN std_logic_vector;
                                Constant data          : IN std_logic_vector;
                                Constant column_mask   : IN std_logic_vector := "";
                                Constant write_per_bit : IN BOOLEAN := FALSE
                              ) is
                          
   begin
      Mem_Block_Write ( mem_id,
                        address_trans(mem_id.length, address),
                        data,
                        column_mask,
                        write_per_bit
                      );
   end;

   Procedure Mem_Block_Write ( Variable mem_id        : INOUT mem_id_type;
                               Constant address       : IN std_ulogic_vector;
                               Constant data          : IN std_ulogic_vector;
                               Constant column_mask   : IN std_ulogic_vector := "";
                               Constant write_per_bit : IN BOOLEAN := FALSE
                             ) is

   begin
      Mem_Block_Write ( mem_id,
                        address_trans(mem_id.length, address),
                        std_logic_vector(data),
                        std_logic_vector(column_mask),
                        write_per_bit
                      );
   end;

   Procedure Mem_Block_Write ( Variable mem_id        : INOUT mem_id_type;
                               Constant address       : IN NATURAL;
                               Constant data          : IN bit_vector;
                               Constant column_mask   : IN bit_vector := "";
                               Constant write_per_bit : IN BOOLEAN := FALSE
                             ) is

   begin
      Mem_Block_Write ( mem_id,
                        address, 
                        bv_To_StdLogicVector (data, data'length),
                        bv_To_StdLogicVector (column_mask, column_mask'length),
                        write_per_bit
                      );
   end;

   Procedure Mem_Block_Write ( Variable mem_id        : INOUT mem_id_type;
                               Constant address       : IN bit_vector;
                               Constant data          : IN bit_vector;
                               Constant column_mask   : IN bit_vector := "";
                               Constant write_per_bit : IN BOOLEAN := FALSE
                             ) is

   begin
      Mem_Block_Write ( mem_id,
                        address_trans(mem_id.length, address),
                        bv_To_StdLogicVector (data, data'length),
                        bv_To_StdLogicVector (column_mask, column_mask'length),
                        write_per_bit
                      );
   end;


    ---------------------------------------------------------------------------    
    --    Procedure Name  :  fill_row
    -- INVISIBLE
    --    Purpose         :  (VRAM) fill a row with the specified word
    --                       
    --    Parameters      :  mem_id        - ptr to memory data structure
    --                       row           - row to be written to
    --                       data          - word to write to row
    --                       write_per_bit - write per bit enabled if TRUE
    --                       
    --    NOTE            :  data must be same size as memory.
    --                       this just handles updating of row_data_type and matrix
    --                       Row is allocated if necessary
    --
    ---------------------------------------------------------------------------

    Procedure fill_row ( Variable mem_id        : INOUT mem_id_type;
                         Constant row           : IN Natural;
                         Constant data          : IN std_logic_vector;
                         Constant write_per_bit : IN BOOLEAN := FALSE
                       ) is
       variable mem_word     : std_logic_vector(mem_id.width - 1 downto 0) := data;
       variable x_vect       : std_logic_vector(mem_id.width - 1 downto 0) := (others => 'X');
       variable new_mem_word : std_logic_vector(mem_id.width - 1 downto 0) := (others => 'X'); -- used with write per bit
       variable short_ptr : rowptr_type;
       variable mask         : std_logic_vector(mem_id.width - 1 downto 0);
       variable word_by_word : BOOLEAN := FALSE;
       
    begin
       short_ptr := mem_id.row_data_ptr(row).rowptr;       
       if ( mem_word = x_vect ) then            -- if data is all Xs
          if write_per_bit then                
             if mem_id.row_data_ptr(row).all_xs then   -- if wpb and row is all Xs then 
                NULL;                                  -- do nothing
             else
                word_by_word := TRUE;                  -- else write to memory one word at a time
             end if;
          else                                         -- if not write per bit (data all Xs)
             if short_ptr /= NULL then                 -- deallocate row if its allocated
                Deallocate(short_ptr);                 -- set all_xs to TRUE
             end if;
             mem_id.row_data_ptr(row).all_xs := TRUE;
             mem_id.row_data_ptr(row).rowptr := NULL;
          end if;

       elsif ( mem_word = mem_id.default.all ) then -- if data is the default word

          if write_per_bit then                        
             if ( (not mem_id.row_data_ptr(row).all_xs) and (short_ptr = NULL) ) then 
                NULL;                                  -- if wpb and row is all default
             else                                      -- then do nothing
                word_by_word := TRUE;                  -- else write to memory one word at a time
             end if;
          else                                         -- if not wpb (data is all default)
             if short_ptr /= NULL then                 -- deallocate row if its allocated
                Deallocate(short_ptr);                 -- set all_xs to FALSE (set row to default word)
             end if;
             mem_id.row_data_ptr(row).all_xs := FALSE;
             mem_id.row_data_ptr(row).rowptr := NULL;
          end if;
       else
          word_by_word := TRUE;                        -- if data is not all_xs or default then write to memory 
       end if;                                         -- one word at a time
       if word_by_word then                           
          if (mem_id.row_data_ptr(row).rowptr = NULL) then     -- allocate row if necessary
             allocate_row(mem_id, row);
          end if;
          short_ptr := mem_id.row_data_ptr(row).rowptr;
          -- check for write per bit
          if  write_per_bit then
             mask := Get_WPB_Mask(mem_id.width, mem_id.wpb_mask.all);
             for column in 0 to mem_id.columns - 1 loop
                for i in 0 to mem_id.width - 1 loop
                   new_mem_word(i) := short_ptr(column,i);
                end loop;
                for ii in 0 to mem_id.width - 1 loop
                   if (mask(ii) = '1') then
                      new_mem_word(ii) := mem_word(ii);
                   end if;
                end loop;
                for i IN 0 to mem_id.width - 1 loop
                   short_ptr(column,i) := new_mem_word(i);
                end loop;
             end loop;
          else  -- write per bit not enabled
             for column in 0 to mem_id.columns - 1 loop
                for i IN 0 to mem_id.width - 1 loop
                   short_ptr(column,i) := mem_word(i);
                end loop;
             end loop;
          end if;
       end if;
    end;
      
    ---------------------------------------------------------------------------    
    --    Procedure Name  :  Mem_Row_Write
    --
    --    Purpose         :  (VRAM) Write a word to an entire row of the DRAM
    --                       
    --    Parameters      :  mem_id        - ptr to memory data structure
    --                       row           - row to be written to
    --                       data          - word to write to row
    --                       write_per_bit - write per bit enabled if TRUE
    --                       
    --    NOTE            :  Data written to each location of the specified row
    --                       of the DRAM.
    --
    ---------------------------------------------------------------------------


   Procedure Mem_Row_Write ( Variable mem_id        : INOUT mem_id_type;
                             Constant row           : IN Natural;
                             Constant data          : IN std_logic_vector;
                             Constant write_per_bit : IN BOOLEAN := FALSE
                           ) is

       variable alias_data   : std_logic_vector(data'LENGTH - 1 downto 0) := data;
       variable mem_word     : std_logic_vector(mem_id.width - 1 downto 0) := (others => 'X');        
       variable column       : NATURAL;
       
    begin
        if ( (mem_id.memory_type = VRAM) or (EXTENDED_OPS and (mem_id.memory_type /= ROM)) ) then   -- make sure its a VRAM
            if row < mem_id.rows then                             -- check that its a valid row
                -- if memory is a dram or vram make sure that it has been woken up
                if (mem_id.last_init + mem_id.refresh_period >= NOW) or (mem_id.memory_type = SRAM) or (mem_id.memory_type = ROM) then
                    -- validate row and report if refresh time exceeded
                    if ( ((mem_id.memory_type = DRAM)  or (mem_id.memory_type = VRAM))
                                                          and (NOW > (mem_id.row_data_ptr(row).last_refresh + mem_id.refresh_period)) ) then
                       mem_id.row_data_ptr(row).all_xs := TRUE;
                       if (mem_id.row_data_ptr(row).rowptr /= NULL) then
                          deallocate (mem_id.row_data_ptr(row).rowptr);
                          mem_id.row_data_ptr(row).rowptr := NULL;
                       end if;
                       assert NOT MEM_WARNINGS_ON
                          report "Mem_Row_Write:  Refresh time has expired on row " & i_to_str(row) & " of memory:  "
                                 & pstr(mem_id.name(1 to mem_id.name'length)) 
                          severity WARNING;
                    end if;
                    -- refresh the row 
                    refresh_row (mem_id, row);
                    -- handle data of different width than memory
                    -- if data has less bits than memory than MSBs become Xs
                    assert ( (data'length = mem_id.width) OR NOT MEM_WARNINGS_ON)
                        report "Mem_Row_Write:  passed data size does not match word size"
                               & " of mem:  " & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR &
                               "passed data size:  " & i_to_str(data'length) & " bits"
                                & LF & SPACESTR & "memory word size:  " &
                               i_to_str(mem_id.width) & " bits"
                        severity WARNING;
                    if (mem_id.width >= data'length) then
                        mem_word (data'length - 1 downto 0) := To_X01(alias_data);
                    else
                        mem_word := To_X01(alias_data(mem_id.width-1 downto 0));
                    end if;
                    fill_row (mem_id, row, mem_word, write_per_bit);
                else
                    assert NOT MEM_WARNINGS_ON
                        report "Mem_Row_Write:  Device wake-up time limit exceeded for memory:  "
                               & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR &
                               "Operation ignored, device must be woken up."
                        severity WARNING;
                end if;
            else
                assert false
                     report "Mem_Row_Write:  Passed row exceeds address " 
                            & "range of mem:  " & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR
                            & "specified row:  " & i_to_str(row)  & LF &
                            SPACESTR & "row range:  0 to " & i_to_str(mem_id.rows - 1)
                            & LF & SPACESTR & "Operation ignored."
                    severity ERROR;
            end if;
        else
            assert false
                report "Mem_Row_Write:  This operation is only valid from VRAMs." & LF & SPACESTR &
                       "Operation ignored."
                       
                severity ERROR;
        end if;
    end;

   Procedure Mem_Row_Write ( Variable mem_id        : INOUT mem_id_type;
                             Constant row           : IN Natural;
                             Constant data          : IN std_ulogic;
                             Constant write_per_bit : IN BOOLEAN := FALSE
                           ) is

       variable temp_data : std_logic_vector(0 to 0);
              
    begin
       temp_data(0) := data;
       Mem_Row_Write (mem_id, row, temp_data, write_per_bit);
    end;

    
   Procedure Mem_Row_Write ( Variable mem_id        : INOUT mem_id_type;
                             Constant row           : Natural;
                             Constant data          : std_ulogic_vector;
                             Constant write_per_bit : IN BOOLEAN := FALSE
                           ) is

   begin
      Mem_Row_Write ( mem_id,
                      row,
                      std_logic_vector(data),
                      write_per_bit
                    );
   end;

   Procedure Mem_Row_Write ( Variable mem_id        : INOUT mem_id_type;
                             Constant row           : std_logic_vector;
                             Constant data          : std_logic_vector;
                             Constant write_per_bit : IN BOOLEAN := FALSE
                           ) is

   begin
      Mem_Row_Write ( mem_id,
                      address_trans (mem_id.rows, row, "row"),
                      data,
                      write_per_bit
                    );
   end;
                         
   Procedure Mem_Row_Write ( Variable mem_id        : INOUT mem_id_type;
                             Constant row           : std_ulogic_vector;
                             Constant data          : std_ulogic_vector;
                             Constant write_per_bit : IN BOOLEAN := FALSE
                           ) is

   begin
      Mem_Row_Write ( mem_id,
                      address_trans (mem_id.rows, row, "row"),
                      std_ulogic_vector(data),
                      write_per_bit
                    );
   end;

   Procedure Mem_Row_Write ( Variable mem_id        : INOUT mem_id_type;
                             Constant row           : NATURAL;
                             Constant data          : bit_vector;
                             Constant write_per_bit : IN BOOLEAN := FALSE
                           ) is

   begin
      Mem_Row_Write ( mem_id,
                      row,
                      bv_To_StdLogicVector (data,data'length),
                      write_per_bit
                    );
   end;

   Procedure Mem_Row_Write ( Variable mem_id        : INOUT mem_id_type;
                             Constant row           : bit_vector;
                             Constant data          : bit_vector;
                             Constant write_per_bit : IN BOOLEAN := FALSE
                           ) is

   begin
      Mem_Row_Write ( mem_id,
                      address_trans (mem_id.rows, row, "row"),
                      bv_To_StdLogicVector (data,data'length),
                      write_per_bit
                   );
   end;

   Procedure Mem_Row_Write ( Variable mem_id        : INOUT mem_id_type;
                             Constant row           : NATURAL;
                             Constant data          : bit;
                             Constant write_per_bit : IN BOOLEAN := FALSE
                           ) is

   begin
      Mem_Row_Write ( mem_id,
                      row,
                      bit_to_std_ulogic(data),
                      write_per_bit
                    );
   end;

   Procedure Mem_Row_Write ( Variable mem_id        : INOUT mem_id_type;
                             Constant row           : bit_vector;
                             Constant data          : bit;
                             Constant write_per_bit : IN BOOLEAN := FALSE
                           ) is
                         
   begin
      Mem_Row_Write ( mem_id,
                      address_trans (mem_id.rows, row, "row"),
                      bit_to_std_ulogic(data),
                      write_per_bit
                    );
                
   end;

   Procedure Mem_Row_Write ( Variable mem_id        : INOUT mem_id_type;
                             Constant row           : std_logic_vector;
                             Constant data          : std_ulogic;
                             Constant write_per_bit : IN BOOLEAN := FALSE
                           ) is

   begin
      Mem_Row_Write ( mem_id,
                      address_trans (mem_id.rows, row, "row"),
                      data,
                      write_per_bit
                    );
   end;

   Procedure Mem_Row_Write ( Variable mem_id        : INOUT mem_id_type;
                             Constant row           : std_ulogic_vector;
                             Constant data          : std_ulogic;
                             Constant write_per_bit : IN BOOLEAN := FALSE
                           ) is

   begin
      Mem_Row_Write ( mem_id,
                      address_trans (mem_id.rows, row, "row"),
                      data,
                      write_per_bit
                    );
   end;

    ---------------------------------------------------------------------------    
    --    Procedure Name  :  load_sam
    --      INVISIBLE
    --
    --    Purpose         :  (VRAM) load portion of SAM from a row of DRAM
    --                       
    --
    --    Parameters      :  mem_id       - ptr to memory data structure
    --                       row          - row of DRAM to be copied
    --                       row_segment  - portion of row to be transfered
    --                       sam_segment  - portion of SAM to received row
    --
    --    NOTE            :  No error checking is done by this routine.
    --
    ---------------------------------------------------------------------------
   

   Procedure load_sam ( Variable mem_id      : INOUT mem_id_type;
                        Constant row         : IN NATURAL;
                        Constant row_segment : IN segment_type;
                        Constant sam_segment : IN sam_segment_type := FULL
                      ) is
                       
      variable short_ptr_dram, short_ptr_sam : rowptr_type;
      variable row_offset  : NATURAL;
      variable sam_offset  : NATURAL;
      variable data_length : NATURAL;

   begin
      if sam_segment = FULL then
         sam_offset := 0;
         data_length := mem_id.sam_columns;
      elsif sam_segment = UPPER_HALF then
         sam_offset := mem_id.sam_columns/2;
         data_length := mem_id.sam_columns/2;
      else -- lower half
         sam_offset := 0;
         data_length := mem_id.sam_columns/2;
      end if;
      case row_segment is
         when QUARTER1   => row_offset := 0;
         when QUARTER2   => row_offset := mem_id.columns/4;
         when QUARTER3   => row_offset := mem_id.columns/2;
         when QUARTER4   => row_offset := 3 * (mem_id.columns/4);
         when LOWER_HALF => row_offset := 0;
         when UPPER_HALF => row_offset := mem_id.columns/2;
         when FULL       => row_offset := 0;
      end case;
      short_ptr_sam := mem_id.sam_data;
      if ( mem_id.row_data_ptr(row).all_xs and (mem_id.row_data_ptr(row).rowptr = NULL ) ) then            -- if all X's
         for i in sam_offset to sam_offset + data_length - 1 loop
            for j in 0 to mem_id.width - 1 loop
                short_ptr_sam(i,j) := 'X';
            end loop;
         end loop;
      elsif ( (not mem_id.row_data_ptr(row).all_xs) and (mem_id.row_data_ptr(row).rowptr = NULL ) ) then   -- if all default word
         for i in sam_offset to sam_offset + data_length - 1 loop
            for j in 0 to mem_id.width - 1 loop
                short_ptr_sam(i,j) := To_UX01(mem_id.default(j));
            end loop;
         end loop;
      elsif ( (not mem_id.row_data_ptr(row).all_xs) and (mem_id.row_data_ptr(row).rowptr /= NULL ) ) then -- row filled with data
         short_ptr_dram := mem_id.row_data_ptr(row).rowptr;
         
         for i in 0 to data_length - 1 loop
            for j in 0 to mem_id.width - 1 loop
                short_ptr_sam(sam_offset + i,j) := short_ptr_dram(row_offset + i, j);
            end loop;
         end loop;
      else                                                                                               -- error
         assert FALSE
            report "Mem_RdTrans/Mem_Split_RdTrans:  Internal error.  Operation Failed."
            severity ERROR;
      end if;      
   end;

    ---------------------------------------------------------------------------    
    --    Procedure Name  :  Mem_RdTrans
    --
    --    Purpose         :  Transfer a portion of a DRAM row to SAM
    --                       
    --
    --    Parameters      :  mem_id      - ptr to memory data structure
    --                       row         - row to be transfered to SAM
    --                       Serial_Ptr  - sets serial ptr and tap address of SAM segment 
    --                       row_segment - portion of row to be transfered to SAM
    --
    --    NOTE            :  row_segment is FULL for full width SAM.
    --                       row_segment is LOWER_HALF or UPPER_HALF for half width SAM.
    --                       Serial_Ptr set serial ptr and tap address of the
    --                       appropriate SAM segment.
    --
    ---------------------------------------------------------------------------
   

   Procedure Mem_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                           Constant row         : IN NATURAL;
                           Constant Serial_Ptr  : IN NATURAL;
                           Constant row_segment : IN segment_type := FULL
                         ) is
                               
       Variable t_serial_ptr : NATURAL := Serial_Ptr;
       Variable t_row_segment : segment_type := row_segment;
       Variable short_ptr_sam : rowptr_type;
                               
    begin
       if (mem_id.memory_type = VRAM) then   -- make sure its a vram         
          assert (row < mem_id.rows)    -- check that its a valid row
             report "Mem_RdTrans:  Passed row exceeds address " 
                    & "range of mem:  " & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR
                    & "specified address:  " & i_to_str(row)  & LF &
                    SPACESTR & "row range:  0 to " & i_to_str(mem_id.rows - 1)
             severity ERROR;
          -- if memory is a vram make sure that it has been woken up
          assert NOT ( (MEM_WARNINGS_ON and (mem_id.last_init + mem_id.refresh_period < NOW)) and (row < mem_id.rows) )
             report "Mem_RdTrans:  Device wake-up time limit exceeded for memory:  "
                    & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR &
                    "device must be woken up.  SAM will be loaded with Xs"
             severity WARNING;
          if ( (mem_id.sam_columns = (mem_id.columns + 1)/2) and
                  ((row_segment /= UPPER_HALF) and (row_segment /= LOWER_HALF)) ) then
             assert FALSE
                report "Mem_RdTrans:  For half width SAM the upper or lower half of the row must be selected."
                       & LF & SPACESTR & "Operation ignored."
                severity ERROR;
          else
             if ( (mem_id.sam_columns = mem_id.columns) and (row_segment /= FULL) ) then
                assert not MEM_WARNINGS_ON
                   report "Mem_RdTrans:  For full width SAM the entire row must be read."
                          & LF & SPACESTR & "Using full row.  Specification for row_segment parameter ignored."
                          & LF & SPACESTR & "Operation continuing."
                   severity WARNING;
                t_row_segment := FULL;
             end if;
             -- adjust serial ptr and Tap address
             if (t_serial_ptr > mem_id.sam_columns - 1) then
                t_serial_ptr := mem_id.sam_columns - 1;
                assert not MEM_WARNINGS_ON
                   report "Mem_RdTrans:  Serial pointer larger then size of SAM." & LF & SPACESTR
                          & "Resetting serial pointer to maximum SAM address."
                   severity WARNING;
             end if;
             mem_id.serial_ptr := t_serial_ptr;
             if (t_serial_ptr >= mem_id.sam_columns/2) then
                mem_id.sam_upper_tap := t_serial_ptr;
             else
                mem_id.sam_lower_tap := t_serial_ptr;
             end if;
             if (row < mem_id.rows) then  -- if valid row then load SAM from row
                -- validate row and report if refresh time exceeded
                validate_row (mem_id, row);
                -- refresh the row 
                refresh_row (mem_id, row);                
                -- load SAM
                if (mem_id.sam_columns = mem_id.columns) then            -- FULL width SAM
                    load_sam (mem_id, row, t_row_segment, FULL);
                elsif (mem_id.sam_columns = (mem_id.columns + 1)/2) then -- HALF width SAM
                    load_sam (mem_id, row, t_row_segment, FULL);
                else
                    ASSERT FALSE
                       report "Mem_RdTrans: Internal Error - Illegal SAM width."
                              & LF & SPACESTR & "Operation aborted after starting."
                       severity ERROR;
                end if;
             else   -- if row not valid then fill SAM with X's
                short_ptr_sam := mem_id.sam_data;
                for i in 0 to mem_id.sam_columns - 1 loop
                   for j in 0 to mem_id.width - 1 loop
                      short_ptr_sam(i,j) :='X';
                   end loop;
                end loop;
             end if;
          end if;
       else
          assert false
              report "Mem_RdTrans:  This operation is only valid for VRAMs." & LF & SPACESTR &
                     "Operation ignored."
              severity ERROR;
       end if;
    end;

   Procedure Mem_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                           Constant row         : NATURAL;
                           Constant Serial_Ptr  : IN std_logic_vector;
                           Constant row_segment : IN segment_type := FULL
                         ) is

   begin
      Mem_RdTrans ( mem_id,
                    row,
                    address_trans (mem_id.sam_columns, serial_ptr, "SAM"),
                    row_segment
                  );
   end;

    

   Procedure Mem_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                           Constant row         : IN std_logic_vector;
                           Constant Serial_Ptr  : IN NATURAL;
                           Constant row_segment : IN segment_type := FULL
                         ) is

   begin
      Mem_RdTrans ( mem_id,
                    address_trans (mem_id.rows, row, "row"),
                    Serial_Ptr,
                    row_segment
                  );
   end;

   Procedure Mem_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                           Constant row         : IN std_logic_vector;
                           Constant Serial_Ptr  : IN std_logic_vector;
                           Constant row_segment : IN segment_type := FULL
                         ) is

   begin
      Mem_RdTrans ( mem_id,
                    address_trans (mem_id.rows, row, "row"),
                    address_trans (mem_id.sam_columns, serial_ptr, "SAM"),
                    row_segment
                  );
   end;

   Procedure Mem_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                           Constant row         : IN NATURAL;
                           Constant Serial_Ptr  : IN std_ulogic_vector;
                           Constant row_segment : IN segment_type := FULL
                         ) is

   begin
      Mem_RdTrans ( mem_id,
                    row,
                    address_trans (mem_id.sam_columns, serial_ptr, "SAM"),
                    row_segment
                  );
   end;

   Procedure Mem_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                           Constant row         : IN std_ulogic_vector;
                           Constant Serial_Ptr  : IN NATURAL;
                           Constant row_segment : IN segment_type := FULL
                         ) is

   begin
      Mem_RdTrans ( mem_id,
                    address_trans (mem_id.rows, row, "row"),
                    Serial_Ptr,
                    row_segment
                  );
   end;

   Procedure Mem_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                           Constant row         : IN std_ulogic_vector;
                           Constant Serial_Ptr  : IN std_ulogic_vector;
                           Constant row_segment : IN segment_type := FULL
                         ) is

   begin
      Mem_RdTrans ( mem_id,
                    address_trans (mem_id.rows, row, "row"),
                    address_trans (mem_id.sam_columns, serial_ptr, "SAM"),
                    row_segment
                  );
   end;

   Procedure Mem_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                           Constant row         : IN NATURAL;
                           Constant Serial_Ptr  : IN bit_vector;
                           Constant row_segment : IN segment_type := FULL
                         ) is

   begin
      Mem_RdTrans ( mem_id,
                    row,
                    address_trans (mem_id.sam_columns, serial_ptr, "SAM"),
                    row_segment
                  );
   end;

   Procedure Mem_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                           Constant row         : IN bit_vector;
                           Constant Serial_Ptr  : IN NATURAL;
                           Constant row_segment : IN segment_type := FULL
                         ) is

   begin
      Mem_RdTrans ( mem_id,
                    address_trans (mem_id.rows, row, "row"),
                    Serial_Ptr,
                    row_segment
                  );
   end;

   Procedure Mem_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                           Constant row         : IN bit_vector;
                           Constant Serial_Ptr  : IN bit_vector;
                           Constant row_segment : IN segment_type := FULL
                         ) is

   begin
      Mem_RdTrans ( mem_id,
                    address_trans (mem_id.rows, row, "row"),
                    address_trans (mem_id.sam_columns, serial_ptr, "SAM"),
                    row_segment
                  );
   end;

    ---------------------------------------------------------------------------    
    --    Procedure Name  :  Mem_Split_RdTrans
    --
    --    Purpose         :  Transfer a portion of a DRAM row to a half SAM
    --                       
    --
    --    Parameters      :  mem_id      - ptr to memory data structure
    --                       row         - row to be transfered to SAM
    --                       tap         - sets tap address of SAM segment (half)
    --                       row_segment - portion of row to be transfered to SAM
    --                       sam_segment - portion ot sam segment to be modified
    --
    --    NOTE            :  transfer LOWER_HALF or UPPER_HALF of row to 
    --                       LOWER_HALF or UPPER_HALF of SAM (full width SAM) 
    --                       transfer QUARTERX of row to LOWER_HALF or
    --                       UPPER_HALF of SAM (half width SAM)
    --
    ---------------------------------------------------------------------------
   

   Procedure Mem_Split_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                                 Constant row         : IN NATURAL;
                                 Constant tap         : IN NATURAL;
                                 Constant row_segment : IN segment_type;
                                 Constant sam_segment : IN sam_segment_type
                               ) is

       Variable t_tap : NATURAL := tap;
       Variable xstart : INTEGER;
       Variable short_ptr_sam : rowptr_type;

    begin
       if (mem_id.memory_type = VRAM) then   -- make sure its a vram
          assert (row < mem_id.rows)
             report "Mem_Split_RdTrans:  Passed row exceeds address " 
                    & "range of mem:  " & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR
                    & "specified row:  " & i_to_str(row)  & LF &
                    SPACESTR & "row range:  0 to " & i_to_str(mem_id.rows - 1)
             severity ERROR;
          -- if memory is a vram make sure that it has been woken up
          assert NOT ( (MEM_WARNINGS_ON and (mem_id.last_init + mem_id.refresh_period < NOW)) and (row < mem_id.rows) )
             report "Mem_Split_RdTrans:  Device wake-up time limit exceeded for memory:  "
                    & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR &
                    "device must be woken up.  Appropriate SAM half will be loaded with Xs."
             severity WARNING;
          if ( (mem_id.sam_columns = mem_id.columns/2) and
                 ((row_segment /= QUARTER1) and (row_segment /= QUARTER2) and
                   (row_segment /= QUARTER3) and (row_segment /= QUARTER4)) ) then
             assert FALSE
                report "Mem_Split_RdTrans:  For half width SAM one quarter of a row must be selected."
                       & LF & SPACESTR & "Operation ignored."
                severity ERROR;
          elsif ( (mem_id.sam_columns=mem_id.columns) and ((row_segment/=UPPER_HALF) and (row_segment/=LOWER_HALF)) ) then
             assert FALSE
                report "Mem_Split_RdTrans:  For full width SAM either the upper or lower half" & LF & SPACESTR &
                       "of the row must be selected."
                       & LF & SPACESTR & "Operation ignored."
                severity ERROR;
          elsif ( sam_segment = FULL ) then
             assert FALSE
                report "Mem_Split_RdTrans:  SAM segment must be either LOWER_HALF or UPPER_HALF for a"
                       & LF & SPACESTR & "split register transfer.  Operation ignored"
                severity ERROR;
          else
             -- set upper or lower tap address
             if (t_tap > (mem_id.sam_columns/2) - 1) then
                t_tap := (mem_id.sam_columns / 2) - 1;
                assert not MEM_WARNINGS_ON
                   report "Mem_Split_RdTrans:  Tap address larger then size of SAM half." & LF & SPACESTR
                          & "Resetting tap address to maximum half SAM address."
                   severity WARNING;
             end if;
             if (sam_segment = LOWER_HALF) then
                mem_id.sam_lower_tap := t_tap;
             else
                mem_id.sam_upper_tap := t_tap  + (mem_id.sam_columns / 2);
             end if;
             assert NOT ( MEM_WARNINGS_ON and ( ((sam_segment = UPPER_HALF) and (mem_id.serial_ptr >= mem_id.sam_columns/2)) or
                                                ((sam_segment = LOWER_HALF) and (mem_id.serial_ptr < mem_id.sam_columns/2)) )
                        )
                report "Mem_Split_RdTrans:  Transfer of data from DRAM is into active half of SAM" & LF & SPACESTR &
                       "Operation continuing."
                severity WARNING;
             if (row < mem_id.rows) then
                -- validate row and report if refresh time exceeded
                validate_row (mem_id, row);
                -- refresh the row 
                refresh_row (mem_id, row);
                -- load SAM
                if (mem_id.sam_columns = mem_id.columns) then            -- FULL width SAM
                    load_sam (mem_id, row, row_segment, sam_segment);
                elsif (mem_id.sam_columns = (mem_id.columns + 1)/2) then -- HALF width SAM
                    load_sam (mem_id, row, row_segment, sam_segment);
                else
                   ASSERT FALSE
                      report "Mem_Split_RdTrans: Internal Error - Illegal SAM width."
                             & LF & SPACESTR & "Operation aborted after starting."
                      severity ERROR;
                end if;
             else  -- if row not valid then fill with Xs
                if (sam_segment = LOWER_HALF) then
                   xstart := 0;
                else
                   xstart := mem_id.sam_columns/2;
                end if;
                short_ptr_sam := mem_id.sam_data;
                for i in xstart to xstart + (mem_id.sam_columns/2) - 1 loop
                   for j in 0 to mem_id.width - 1 loop
                      short_ptr_sam(i,j) :='X';
                   end loop;
                end loop;
             end if;
          end if;
       else
          assert false
              report "Split Read_Trans:  This operation is only valid for VRAMs." & LF & SPACESTR &
                     "Operation ignored."
              severity ERROR;
       end if;
    end;

   Procedure Mem_Split_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                                 Constant row         : IN std_logic_vector;
                                 Constant tap         : IN NATURAL;
                                 Constant row_segment : IN segment_type := FULL;
                                 Constant sam_segment : IN sam_segment_type
                               ) is

   begin
      Mem_Split_RdTrans ( mem_id,
                          address_trans(mem_id.rows, row, "row"),
                          tap,
                          row_segment,
                          sam_segment
                        );
   end;    

   Procedure Mem_Split_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                                 Constant row         : IN NATURAL;
                                 Constant tap         : IN std_logic_vector;
                                 Constant row_segment : IN segment_type := FULL;
                                 Constant sam_segment : IN sam_segment_type
                               ) is

   begin
      Mem_Split_RdTrans ( mem_id,
                          row,
                          address_trans(mem_id.sam_columns/2, tap, "half of SAM"),
                          row_segment,
                          sam_segment
                        );
   end;    

   Procedure Mem_Split_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                                 Constant row         : IN std_logic_vector;
                                 Constant tap         : IN std_logic_vector;
                                 Constant row_segment : IN segment_type := FULL;
                                 Constant sam_segment : IN sam_segment_type
                               ) is

   begin
      Mem_Split_RdTrans ( mem_id,
                          address_trans(mem_id.rows, row, "row"),
                          address_trans(mem_id.sam_columns/2, tap, "half of SAM"),
                          row_segment,
                          sam_segment
                        );
   end;    

   Procedure Mem_Split_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                                 Constant row         : IN std_ulogic_vector;
                                 Constant tap         : IN NATURAL;
                                 Constant row_segment : IN segment_type := FULL;
                                 Constant sam_segment : IN sam_segment_type
                               ) is

   begin
      Mem_Split_RdTrans ( mem_id,
                          address_trans(mem_id.rows, row, "row"),
                          tap,
                          row_segment,
                          sam_segment
                        );
   end;    

   Procedure Mem_Split_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                                 Constant row         : IN NATURAL;
                                 Constant tap         : IN std_ulogic_vector;
                                 Constant row_segment : IN segment_type := FULL;
                                 Constant sam_segment : IN sam_segment_type
                               ) is

   begin
      Mem_Split_RdTrans ( mem_id,
                          row,
                          address_trans(mem_id.sam_columns/2, tap, "half of SAM"),
                          row_segment,
                          sam_segment
                        );
   end;    

   Procedure Mem_Split_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                                 Constant row         : IN std_ulogic_vector;
                                 Constant tap         : IN std_ulogic_vector;
                                 Constant row_segment : IN segment_type := FULL;
                                 Constant sam_segment : IN sam_segment_type
                               ) is

   begin
      Mem_Split_RdTrans ( mem_id,
                          address_trans(mem_id.rows, row, "row"),
                          address_trans(mem_id.sam_columns/2, tap, "half of SAM"),
                          row_segment,
                          sam_segment
                        );
   end;

   Procedure Mem_Split_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                                 Constant row         : IN bit_vector;
                                 Constant tap         : IN NATURAL;
                                 Constant row_segment : IN segment_type := FULL;
                                 Constant sam_segment : IN sam_segment_type
                               ) is

   begin
      Mem_Split_RdTrans ( mem_id,
                          address_trans(mem_id.rows, row, "row"),
                          tap,
                          row_segment,
                          sam_segment
                        );
   end;    

   Procedure Mem_Split_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                                 Constant row         : IN NATURAL;
                                 Constant tap         : IN bit_vector;
                                 Constant row_segment : IN segment_type := FULL;
                                 Constant sam_segment : IN sam_segment_type
                               ) is

   begin
      Mem_Split_RdTrans ( mem_id,
                          row,
                          address_trans(mem_id.sam_columns/2, tap, "half of SAM"),
                          row_segment,
                          sam_segment
                        );
   end;    

   Procedure Mem_Split_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                                 Constant row         : IN bit_vector;
                                 Constant tap         : IN bit_vector;
                                 Constant row_segment : IN segment_type := FULL;
                                 Constant sam_segment : IN sam_segment_type
                               ) is

   begin
      Mem_Split_RdTrans ( mem_id,
                          address_trans(mem_id.rows, row, "row"),
                          address_trans(mem_id.sam_columns/2, tap, "half of SAM"),
                          row_segment,
                          sam_segment
                        );
   end;

    ---------------------------------------------------------------------------    
    --    Procedure Name  :  Mem_RdSAM
    --
    --    Purpose         :  (VRAM) Returns the word in the SAM that the serial
    --                       ptr points to.
    --
    --    Parameters      :  mem_id - ptr to memory data structure
    --                       data   - holds returned word
    --
    --    NOTE            :  Returns word in SAM pointed to by serial ptr.
    --                       Serial ptr incremented by 1 mod size of SAM.
    --
    ---------------------------------------------------------------------------
   
   
   Procedure Mem_RdSAM ( Variable mem_id : INOUT mem_id_type;
                         Variable data   : OUT   std_logic_vector
                       ) is

      variable alias_data : std_logic_vector(data'LENGTH - 1 downto 0) := (others => 'X');
      variable mem_word   : std_logic_vector(mem_id.width - 1 downto 0);

   begin
      if (mem_id.memory_type /= VRAM) then
         assert false
            report "Mem_RdSAM:  This operation is only valid for VRAMs." & LF & SPACESTR &
                   "Operation ignored."
            severity ERROR;
      else
         -- read data
         for ii in 0 to mem_id.width - 1 loop
            mem_word(ii) := mem_id.sam_data(mem_id.serial_ptr, ii);
         end loop;
         -- if serial_ptr = a tap then clear the tap
         if (mem_id.serial_ptr = mem_id.sam_lower_tap) then
            mem_id.sam_lower_tap := 0;
         end if;
         if (mem_id.serial_ptr = mem_id.sam_upper_tap) then
            mem_id.sam_upper_tap := mem_id.sam_columns/2;
         end if;
         -- increment serial ptr
         mem_id.serial_ptr := (mem_id.serial_ptr + 1) mod (mem_id.sam_columns);
         -- return data
         assert ( (data'length = mem_id.width) OR NOT MEM_WARNINGS_ON)
            report "Mem_RdSAM:  return data size does not match word size"
                   & " of mem:  " & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR &
                   "return data size:  " & i_to_str(data'length) & " bits"
                   & LF & SPACESTR & "memory word size:  " &
                   i_to_str(mem_id.width) & " bits"
            severity WARNING;
         if (data'LENGTH >= mem_id.width) then 
            alias_data(mem_id.width - 1 downto 0) := mem_word;
         else
            alias_data := mem_word(data'LENGTH - 1 downto 0);
         end if;
         data := alias_data;
      end if;
   end;
                             
   Procedure Mem_RdSAM ( Variable mem_id : INOUT mem_id_type;
                         Variable data   : OUT   std_ulogic
                       ) is

      variable temp_data : std_logic_vector(0 to 0);

   begin
      Mem_RdSAM (mem_id, temp_data);
      data := temp_data(0);
   end;
                             

                                
   Procedure Mem_RdSAM ( Variable mem_id : INOUT mem_id_type;
                         Variable data   : OUT   std_ulogic_vector
                       ) is

      variable temp : std_logic_vector(data'LENGTH - 1 downto 0);
                             
   begin
      Mem_RdSAM ( mem_id, temp);
      data := std_ulogic_vector(temp);
   end;

   Procedure Mem_RdSAM ( Variable mem_id : INOUT mem_id_type;
                         Variable data   : OUT   bit_vector
                       ) is

      variable temp : std_logic_vector(data'LENGTH - 1 downto 0);
                             
   begin
      Mem_RdSAM ( mem_id, temp);
      data := data_trans(temp);
   end;

   Procedure Mem_RdSAM ( Variable mem_id : INOUT mem_id_type;
                         Variable data   : OUT   bit
                       ) is

      variable temp : std_ulogic;
                             
   begin
      Mem_RdSAM ( mem_id, temp);
      data := data_trans(temp);
   end;

    ---------------------------------------------------------------------------    
    --    Procedure Name  :  Mem_Split_RdSAM
    --
    --    Purpose         :  (VRAM) To read a word from the SAM in split 
    --                       reigister mode.
    --
    --    Parameters      :  mem_id - ptr to memory data structure
    --                       data   - holds word read from SAM
    --
    --    NOTE            :  Returns word in SAM pointed to by serial pointer.
    --                       Serial pointer is incremented.  If the serial ptr
    --                       is incremented past the half SAM then it goes to
    --                       the tap address of the next half and resets that
    --                       tap address to the LSB of the half.
    --
    ---------------------------------------------------------------------------

   
   Procedure Mem_Split_RdSAM ( Variable mem_id : INOUT mem_id_type;
                               Variable data   : OUT   std_logic_vector
                             ) is

      variable alias_data : std_logic_vector(data'LENGTH - 1 downto 0) := (others => 'X');
      variable mem_word   : std_logic_vector(mem_id.width - 1 downto 0);

   begin
      if (mem_id.memory_type /= VRAM) then
         assert false
            report "Mem_Split_RdSAM:  This operation is only valid for VRAMs." & LF & SPACESTR &
                   "Operation ignored."
            severity ERROR;
      else
         -- read data
         for ii in 0 to mem_id.width - 1 loop
            mem_word(ii) := mem_id.sam_data(mem_id.serial_ptr, ii);
         end loop;
         -- if serial_ptr = tap then clear tap
         if (mem_id.serial_ptr = mem_id.sam_lower_tap) then
            mem_id.sam_lower_tap := 0;
         end if;
         if (mem_id.serial_ptr = mem_id.sam_upper_tap) then
            mem_id.sam_upper_tap := mem_id.sam_columns/2;
         end if;
         -- increment serial ptr
         mem_id.serial_ptr := mem_id.serial_ptr + 1;
         if mem_id.serial_ptr = (mem_id.sam_columns/2) then
            mem_id.serial_ptr := mem_id.sam_upper_tap;
         elsif mem_id.serial_ptr >= mem_id.sam_columns then
            mem_id.serial_ptr := mem_id.sam_lower_tap;
         else
            NULL;
         end if;
         -- return data
         assert ( (data'length = mem_id.width) OR NOT MEM_WARNINGS_ON)
            report "Mem_Split_RdSAM:  return data size does not match word size"
                   & " of mem:  " & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR &
                   "return data size:  " & i_to_str(data'length) & " bits"
                   & LF & SPACESTR & "memory word size:  " &
                   i_to_str(mem_id.width) & " bits"
            severity WARNING;
         if (data'LENGTH >= mem_id.width) then 
            alias_data(mem_id.width - 1 downto 0) := mem_word;
         else
            alias_data := mem_word(data'LENGTH - 1 downto 0);
         end if;
         data := alias_data;
      end if; 
   end;

   Procedure Mem_Split_RdSAM ( Variable mem_id : INOUT mem_id_type;
                               Variable data   : OUT   std_ulogic
                             ) is

      variable temp_data   : std_logic_vector(0 to 0);

   begin
      Mem_Split_RdSAM (mem_id, temp_data);
      data := temp_data(0);
   end;

   Procedure Mem_Split_RdSAM ( Variable mem_id : INOUT mem_id_type;
                               Variable data   : OUT   std_ulogic_vector
                             ) is

      variable temp : std_logic_vector(data'LENGTH - 1 downto 0);
      
   begin
      Mem_Split_RdSAM ( mem_id, temp );
      data := std_ulogic_vector(temp);
   end;

   Procedure Mem_Split_RdSAM ( Variable mem_id : INOUT mem_id_type;
                               Variable data   : OUT   bit_vector
                             ) is

      variable temp : std_logic_vector(data'LENGTH - 1 downto 0);
      
   begin
      Mem_Split_RdSAM ( mem_id, temp );
      data := data_trans(temp);
   end;

   Procedure Mem_Split_RdSAM ( Variable mem_id : INOUT mem_id_type;
                               Variable data   : OUT   bit
                             ) is

      variable temp : std_ulogic;
      
   begin
      Mem_Split_RdSAM ( mem_id, temp );
      data := data_trans(temp);
   end;

    ---------------------------------------------------------------------------    
    --    Procedure Name  :  Mem_Active_SAM_Half
    --
    --    Purpose         :  (VRAM) half is set to '1' if the serial ptr
    --                       is in the upper SAM half and '0' if its in the
    --                       lower SAM half
    --
    --    Parameters      :  mem_id  - ptr to memory data structure
    --                       half    - indicates half of SAM serial ptr is in
    --
    --    NOTE            :  
    --
    ---------------------------------------------------------------------------

   Procedure Mem_Active_SAM_Half ( Variable mem_id : INOUT mem_id_type;
                                   Variable half   : OUT std_ulogic
                                 ) is

   begin
      if (mem_id.memory_type /= VRAM) then
         assert false
            report "Mem_Active_SAM_Half:  This operation is only valid for VRAMs." & LF & SPACESTR &
                   "Operation ignored."
            severity ERROR;
      else      
         if (mem_id.serial_ptr >= mem_id.sam_columns/2) then
            half := '1';
         else
            half := '0';
         end if;
      end if;
   end;
                                                                                
   Procedure Mem_Active_SAM_Half ( Variable mem_id : INOUT mem_id_type;
                                   Variable half   : OUT bit
                                 ) is

   begin
      if (mem_id.memory_type /= VRAM) then
         assert false
            report "Mem_Active_SAM_Half:  This operation is only valid for VRAMs." & LF & SPACESTR &
                   "Operation ignored."
            severity ERROR;
      else      
         if (mem_id.serial_ptr >= mem_id.sam_columns/2) then
            half := '1';
         else
            half := '0';
         end if;
      end if;
   end;

    ---------------------------------------------------------------------------    
    --    Procedure Name  :  load_row
    --      INVISIBLE
    --
    --    Purpose         :  (VRAM) load a portion of a DRAM row from the SAM
    --                       
    --
    --    Parameters      :  mem_id        - ptr to memory data structure
    --                       row           - row of to dram to be loaded
    --                       row_segment   - portion of row to be loaded
    --                       sam_segment   - portion of SAM to be copied to DRAM
    --                       write_per_bit - enable write per bit
    --
    --    NOTE            :  No error checking is done by this routine.
    --
    ---------------------------------------------------------------------------
   

   Procedure load_row ( Variable mem_id        : INOUT mem_id_type;
                        Constant row           : IN NATURAL;
                        Constant row_segment   : IN segment_type;
                        Constant sam_segment   : IN sam_segment_type;
                        Constant write_per_bit : IN BOOLEAN
                            ) is

      subtype constrained_matrix is row_matrix (0 to mem_id.columns -1, 0 to mem_id.width - 1);
      variable short_ptr_dram, short_ptr_sam : rowptr_type;
      variable row_offset  : NATURAL;
      variable sam_offset  : NATURAL;
      variable data_length : NATURAL;
      variable mask : std_logic_vector(mem_id.width - 1 downto 0) := Get_WPB_Mask(mem_id.width, mem_id.wpb_mask.all);
      variable default : std_logic_vector(mem_id.width - 1 downto 0);

   begin

      default := mem_id.default.all;

      if sam_segment = FULL then
         sam_offset := 0;
         data_length := mem_id.sam_columns;
      elsif sam_segment = UPPER_HALF then
         sam_offset := mem_id.sam_columns/2;
         data_length := mem_id.sam_columns/2;
      else -- lower half
         sam_offset := 0;
         data_length := mem_id.sam_columns/2;
      end if;
      case row_segment is
         when QUARTER1   => row_offset := 0; 
         when QUARTER2   => row_offset := mem_id.columns/4;
         when QUARTER3   => row_offset := mem_id.columns/2;
         when QUARTER4   => row_offset := 3 * (mem_id.columns/4);
         when LOWER_HALF => row_offset := 0;
         when UPPER_HALF => row_offset := mem_id.columns/2;
         when FULL       => row_offset := 0;
      end case;
      short_ptr_sam := mem_id.sam_data;      
      if (mem_id.row_data_ptr(row).rowptr = NULL) then  -- if all X's or default word
         if ( row_segment = FULL ) then -- avoid filling entire row in allocate procedure and then refilling it here
            if mem_id.row_data_ptr(row).all_xs then
               default := (others => 'X');
            end if;
            mem_id.row_data_ptr(row).all_xs := FALSE;

            mem_id.row_data_ptr(row).rowptr := new constrained_matrix;

            if write_per_bit then
               short_ptr_dram := mem_id.row_data_ptr(row).rowptr;
               for i in 0 to mem_id.sam_columns - 1 loop
                  for j in 0 to mem_id.width - 1 loop
                     if (mask(j) = '1') then
                        short_ptr_dram(i,j) := short_ptr_sam(i,j);
                     else
                        short_ptr_dram(i,j) := default(j);
                     end if;
                  end loop;
               end loop;
            else

               mem_id.row_data_ptr(row).rowptr.all := short_ptr_sam.all;

            end if;
         else
            allocate_row (mem_id, row);
            short_ptr_dram := mem_id.row_data_ptr(row).rowptr;
            if write_per_bit then
               for i in 0 to data_length - 1 loop
                  for j in 0 to mem_id.width - 1 loop
                     if (mask(j) = '1') then
                        short_ptr_dram(row_offset + i, j) := short_ptr_sam(sam_offset + i, j);
                     end if;
                  end loop;
               end loop;
            else
               for i in 0 to data_length - 1 loop
                  for j in 0 to mem_id.width - 1 loop
                     short_ptr_dram(row_offset + i, j) := short_ptr_sam(sam_offset + i, j);
                  end loop;
               end loop;
            end if;
         end if;
      elsif ( (not mem_id.row_data_ptr(row).all_xs) and (mem_id.row_data_ptr(row).rowptr /= NULL) ) then -- row filled with data
         short_ptr_dram := mem_id.row_data_ptr(row).rowptr;
         if (row_segment = FULL) then
            if write_per_bit then
               for i in 0 to mem_id.sam_columns - 1 loop
                  for j in 0 to mem_id.width - 1 loop
                     if (mask(j) = '1') then
                        short_ptr_dram(i,j) := short_ptr_sam(i,j);
                     end if;
                  end loop;
               end loop;
            else

               short_ptr_dram.all := short_ptr_sam.all;

            end if;
         else
            if write_per_bit then
               for i in 0 to data_length - 1 loop
                  for j in 0 to mem_id.width - 1 loop
                     if (mask(j) = '1') then
                        short_ptr_dram(row_offset + i, j) := short_ptr_sam(sam_offset + i, j);
                     end if;
                  end loop;
               end loop;
            else 
               for i in 0 to data_length - 1 loop
                  for j in 0 to mem_id.width - 1 loop
                     short_ptr_dram(row_offset + i, j) := short_ptr_sam(sam_offset + i, j);
                  end loop;
               end loop;
            end if;
         end if;
      else                                                                                               -- error
         assert FALSE
            report "Mem_WrtTrans/Mem_Split_WrtTrans:  Internal error.  Operation Failed"
            severity ERROR;
      end if;
   end;

    ---------------------------------------------------------------------------    
    --    Procedure Name  :  Mem_WrtTrans
    --
    --    Purpose         :  Transfer a portion of a DRAM row to SAM
    --                       
    --
    --    Parameters      :  mem_id        - ptr to memory data structure
    --                       row           - row into which SAM is to be copied
    --                       Serial_Ptr    - sets serial ptr and tap address of SAM segment 
    --                       row_segment   - portion of row into which SAM is to be copied
    --                       write_per_bit - enable write per bit
    --
    --    NOTE            :  row_segment is FULL for full width SAM.
    --                       row_segment is LOWER_HALF or UPPER_HALF for half width SAM.
    --                       Seiral_Ptr set serial ptr and tap address of the
    --                       appropriate SAM segment.
    --
    ---------------------------------------------------------------------------
   

   Procedure Mem_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                            Constant row           : IN NATURAL;
                            Constant Serial_Ptr    : IN NATURAL;
                            Constant row_segment   : IN segment_type := FULL;
                            Constant write_per_bit : IN BOOLEAN := FALSE
                          ) is
                               
       Variable t_serial_ptr : NATURAL := Serial_Ptr;
       variable t_row_segment : segment_type := row_segment;
                               
    begin
       if (mem_id.memory_type = VRAM) then   -- make sure its a vram
           if row < mem_id.rows then                             -- check that its a valid row
              -- if memory is a vram make sure that it has been woken up
              if (mem_id.last_init + mem_id.refresh_period >= NOW) then
                 if ( (mem_id.sam_columns = mem_id.columns/2) and
                         ((row_segment /= UPPER_HALF) and (row_segment /= LOWER_HALF)) ) then
                    assert FALSE
                       report "Mem_RdTrans:  For half width SAM the upper or lower half of the row must be selected."
                              & LF & SPACESTR & "Operation ignored."
                       severity ERROR;
                 else
                    if ( (mem_id.sam_columns = mem_id.columns) and (row_segment /= FULL) ) then
                       assert not MEM_WARNINGS_ON
                          report "Mem_WrtTrans:  For full width SAM the entire row must be written."
                                 & LF & SPACESTR & "Using full row.  Specification for row_segment parameter ignored."
                                 & LF & SPACESTR & "Operation continuing."
                          severity WARNING;
                       t_row_segment := FULL;
                    end if;
                    -- validate row and report if refresh time exceeded
                    validate_row (mem_id, row);
                    -- refresh the row 
                    refresh_row (mem_id, row);
                    -- adjust serial ptr and Tap address
                    if (t_serial_ptr > mem_id.sam_columns - 1) then
                       t_serial_ptr := mem_id.sam_columns - 1;
                       assert not MEM_WARNINGS_ON
                          report "Mem_WrtTrans:  Serial pointer larger then size of SAM." & LF & SPACESTR
                                 & "Resetting serial pointer to maximum SAM address."
                          severity WARNING;
                    end if;
                    mem_id.serial_ptr := t_serial_ptr;
                    if (t_serial_ptr >= mem_id.sam_columns/2) then
                       mem_id.sam_upper_tap := t_serial_ptr;
                    else
                       mem_id.sam_lower_tap := t_serial_ptr;
                    end if;
                    -- load SAM
                    if (mem_id.sam_columns = mem_id.columns) then            -- FULL width SAM
                        load_row (mem_id, row, t_row_segment, FULL, write_per_bit);
                    elsif (mem_id.sam_columns = (mem_id.columns + 1)/2) then -- HALF width SAM
                        load_row (mem_id, row, t_row_segment, FULL, write_per_bit);
                    else
                        ASSERT FALSE
                           report "Mem_WrtTrans: Internal Error - Illegal SAM width."
                                  & LF & SPACESTR & "Operation aborted after starting."
                           severity ERROR;
                    end if;
                 end if;
              else
                 assert NOT MEM_WARNINGS_ON
                    report "Mem_WrtTrans:  Device wake-up time limit exceeded for memory:  "
                           & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR &
                           "Operation ignored, device must be woken up."
                    severity WARNING;
              end if;
           else
               assert false
                    report "Mem_WrtTrans:  Passed row exceeds address " 
                           & "range of mem:  " & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR
                           & "specified address:  " & i_to_str(row)  & LF &
                           SPACESTR & "row range:  0 to " & i_to_str(mem_id.rows - 1)
                           & LF & SPACESTR & "Operation ignored."
                   severity ERROR;
         end if;
       else
           assert false
               report "Mem_WrtTrans:  This operation is only valid for VRAMs." & LF & SPACESTR &
                      "Operation ignored."
               severity ERROR;
       end if;
    end;

   Procedure Mem_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                            Constant row           : NATURAL;
                            Constant Serial_Ptr    : IN std_logic_vector;
                            Constant row_segment   : IN segment_type := FULL;
                            Constant write_per_bit : IN BOOLEAN := FALSE
                          ) is

   begin
      Mem_WrtTrans ( mem_id,
                     row,
                     address_trans (mem_id.sam_columns, serial_ptr, "SAM"),
                     row_segment,
                     write_per_bit
                   );
   end;

    

   Procedure Mem_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                            Constant row           : IN std_logic_vector;
                            Constant Serial_Ptr    : IN NATURAL;
                            Constant row_segment   : IN segment_type := FULL;
                            Constant write_per_bit : IN BOOLEAN := FALSE
                          ) is

   begin
      Mem_WrtTrans ( mem_id,
                     address_trans (mem_id.rows, row, "row"),
                     Serial_Ptr,
                     row_segment,
                     write_per_bit
                   );
   end;

   Procedure Mem_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                            Constant row           : IN std_logic_vector;
                            Constant Serial_Ptr    : IN std_logic_vector;
                            Constant row_segment   : IN segment_type := FULL;
                            Constant write_per_bit : IN BOOLEAN := FALSE
                          ) is

   begin
      Mem_WrtTrans ( mem_id,
                     address_trans (mem_id.rows, row, "row"),
                     address_trans (mem_id.sam_columns, serial_ptr, "SAM"),
                     row_segment,
                     write_per_bit
                   );
   end; 

   Procedure Mem_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                            Constant row           : IN NATURAL;
                            Constant Serial_Ptr    : IN std_ulogic_vector;
                            Constant row_segment   : IN segment_type := FULL;
                            Constant write_per_bit : IN BOOLEAN := FALSE
                          ) is

   begin
      Mem_WrtTrans ( mem_id,
                     row,
                     address_trans (mem_id.sam_columns, serial_ptr, "SAM"),
                     row_segment,
                     write_per_bit
                   );
   end;

   Procedure Mem_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                            Constant row           : IN std_ulogic_vector;
                            Constant Serial_Ptr    : IN NATURAL;
                            Constant row_segment   : IN segment_type := FULL;
                            Constant write_per_bit : IN BOOLEAN := FALSE
                          ) is

   begin
      Mem_WrtTrans ( mem_id,
                     address_trans (mem_id.rows, row, "row"),
                     Serial_Ptr,
                     row_segment,
                     write_per_bit
                   );
   end;

   Procedure Mem_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                            Constant row           : IN std_ulogic_vector;
                            Constant Serial_Ptr    : IN std_ulogic_vector;
                            Constant row_segment   : IN segment_type := FULL;
                            Constant write_per_bit : IN BOOLEAN := FALSE
                          ) is

   begin
      Mem_WrtTrans ( mem_id,
                     address_trans (mem_id.rows, row, "row"),
                     address_trans (mem_id.sam_columns, serial_ptr, "SAM"),
                     row_segment,
                     write_per_bit
                   );
   end;

   
   Procedure Mem_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                            Constant row           : IN NATURAL;
                            Constant Serial_Ptr    : IN bit_vector;
                            Constant row_segment   : IN segment_type := FULL;
                            Constant write_per_bit : IN BOOLEAN := FALSE
                          ) is

   begin
      Mem_WrtTrans ( mem_id,
                     row,
                     address_trans (mem_id.sam_columns, serial_ptr, "SAM"),
                     row_segment,
                     write_per_bit
                         );
   end;

   Procedure Mem_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                            Constant row           : IN bit_vector;
                            Constant Serial_Ptr    : IN NATURAL;
                            Constant row_segment   : IN segment_type := FULL;
                            Constant write_per_bit : IN BOOLEAN := FALSE
                          ) is

   begin
      Mem_WrtTrans ( mem_id,
                     address_trans (mem_id.rows, row, "row"),
                     Serial_Ptr,
                     row_segment,
                     write_per_bit
                   );
   end;

   Procedure Mem_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                            Constant row           : IN bit_vector;
                            Constant Serial_Ptr    : IN bit_vector;
                            Constant row_segment   : IN segment_type := FULL;
                            Constant write_per_bit : IN BOOLEAN := FALSE
                          ) is

   begin
      Mem_WrtTrans ( mem_id,
                     address_trans (mem_id.rows, row, "row"),
                     address_trans (mem_id.sam_columns, serial_ptr, "SAM"),
                     row_segment,
                     write_per_bit
                   );
   end;

   
    ---------------------------------------------------------------------------    
    --    Procedure Name  :  Mem_Split_WrtTrans
    --
    --    Purpose         :  Transfer a portion of the SAM to a portion of a DRAM row
    --                       
    --
    --    Parameters      :  mem_id        - ptr to memory data structure
    --                       row           - row into which portion of SAM is to be copied
    --                       tap           - sets tap address of SAM segment (half)
    --                       row_segment   - portion of row into which SAM is copied
    --                       sam_segment   - portion ot sam segment to be copied
    --                       write_per_bit - enable write per bit
    --
    --    NOTE            :  transfer LOWER_HALF or UPPER_HALF of SAM to 
    --                       LOWER_HALF or UPPER_HALF of row (full width SAM)
    --                       transfer LOWER_HALF or UPPER_HALF of SAM to
    --                       QUARTERX of row (half width SAM)
    --
    ---------------------------------------------------------------------------
   

   Procedure Mem_Split_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                                  Constant row           : IN NATURAL;
                                  Constant tap           : IN NATURAL;
                                  Constant row_segment   : IN segment_type;
                                  Constant sam_segment   : IN sam_segment_type;
                                  Constant write_per_bit : IN BOOLEAN := FALSE
                                ) is

       variable t_tap : NATURAL := tap;

    begin
       if (mem_id.memory_type = VRAM) then   -- make sure its a vram
           if row < mem_id.rows then                             -- check that its a valid row
              -- if memory is a vram make sure that it has been woken up
              if (mem_id.last_init + mem_id.refresh_period >= NOW) then
                 if ( (mem_id.sam_columns = (mem_id.columns + 1)/2) and
                         ((row_segment /= QUARTER1) and (row_segment /= QUARTER2) and
                          (row_segment /= QUARTER3) and (row_segment /= QUARTER4)) ) then
                    assert FALSE
                       report "Mem_Split_WrtTrans:  For half width SAM one quarter of a row must be selected."
                              & LF & SPACESTR & "Operation ignored."
                       severity ERROR;
                 elsif ( (mem_id.sam_columns=mem_id.columns) and ((row_segment/=UPPER_HALF) and (row_segment/=LOWER_HALF)) ) then
                    assert FALSE
                       report "Mem_Split_WrtTrans:  For full width SAM either the upper or lower half" & LF & SPACESTR &
                              "of the row must be selected."
                              & LF & SPACESTR & "Operation ignored."
                       severity ERROR;
                 elsif ( sam_segment = FULL ) then
                    assert FALSE
                       report "Mem_Split_WrtTrans:  SAM segment must be either LOWER_HALF or UPPER_HALF for a"
                              & LF & SPACESTR & "split register transfer.  Operation ignored"
                       severity ERROR;
                 else
                    -- validate row and report if refresh time exceeded
                    validate_row (mem_id, row);
                    -- refresh the row 
                    refresh_row (mem_id, row);
                    -- set upper or lower tap address
                    if (t_tap > (mem_id.sam_columns/2) - 1) then
                       t_tap := (mem_id.sam_columns / 2) - 1;
                       assert not MEM_WARNINGS_ON
                          report "Mem_Split_WrtTrans:  Tap address larger then size of SAM half." & LF & SPACESTR
                                 & "Resetting tap address to maximum half SAM address."
                          severity WARNING;
                    end if;
                    if (sam_segment = LOWER_HALF) then
                       mem_id.sam_lower_tap := t_tap;
                    else
                       mem_id.sam_upper_tap := t_tap + (mem_id.sam_columns / 2);
                    end if;
                    assert NOT ( MEM_WARNINGS_ON and ( ((sam_segment = UPPER_HALF) and (mem_id.serial_ptr >= mem_id.sam_columns/2)) or
                                                       ((sam_segment = LOWER_HALF) and (mem_id.serial_ptr < mem_id.sam_columns/2)) )
                               )
                       report "Mem_Split_WrtTrans:  Transfer of data to DRAM is from active half of SAM" & LF & SPACESTR &
                              "Operation continuing."
                       severity WARNING;
                    -- load SAM
                    if (mem_id.sam_columns = mem_id.columns) then            -- FULL width SAM
                        load_row (mem_id, row, row_segment, sam_segment, write_per_bit);
                    elsif (mem_id.sam_columns = (mem_id.columns + 1)/2) then -- HALF width SAM
                        load_row (mem_id, row, row_segment, sam_segment, write_per_bit);
                    else
                        ASSERT FALSE
                           report "Mem_Split_WrtTrans: Internal Error - Illegal SAM width."
                                  & LF & SPACESTR & "Operation aborted after starting."
                           severity ERROR;
                    end if;
                 end if;
              else
                 assert NOT MEM_WARNINGS_ON
                    report "Mem_Split_WrtTrans:  Device wake-up time limit exceeded for memory:  "
                           & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR &
                           "Operation ignored, device must be woken up."
                    severity WARNING;
              end if;
           else
               assert false
                    report "Mem_Split_WrtTrans:  Passed row exceeds address " 
                           & "range of mem:  " & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR
                           & "specified row:  " & i_to_str(row)  & LF &
                           SPACESTR & "row range:  0 to " & i_to_str(mem_id.rows - 1)
                           & LF & SPACESTR & "Operation ignored."
                   severity ERROR;
         end if;
       else
           assert false
               report "Split Read_Trans:  This operation is only valid for VRAMs." & LF & SPACESTR &
                      "Operation ignored."
               severity ERROR;
       end if;
    end;

   Procedure Mem_Split_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                                  Constant row           : IN std_logic_vector;
                                  Constant tap           : IN NATURAL;
                                  Constant row_segment   : IN segment_type;
                                  Constant sam_segment   : IN sam_segment_type;
                                  Constant write_per_bit : IN BOOLEAN := FALSE
                                ) is

   begin
      Mem_Split_WrtTrans ( mem_id,
                           address_trans(mem_id.rows, row, "row"),
                           tap,
                           row_segment,
                           sam_segment,
                           write_per_bit
                         );
   end;     

   Procedure Mem_Split_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                                  Constant row           : IN NATURAL;
                                  Constant tap           : IN std_logic_vector;
                                  Constant row_segment   : IN segment_type;
                                  Constant sam_segment   : IN sam_segment_type;
                                  Constant write_per_bit : IN BOOLEAN := FALSE
                                ) is

   begin
      Mem_Split_WrtTrans ( mem_id,
                           row,
                           address_trans(mem_id.sam_columns/2, tap, "SAM"),
                           row_segment,
                           sam_segment,
                           write_per_bit
                         );
   end;    

   Procedure Mem_Split_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                                  Constant row           : IN std_logic_vector;
                                  Constant tap           : IN std_logic_vector;
                                  Constant row_segment   : IN segment_type;
                                  Constant sam_segment   : IN sam_segment_type;
                                  Constant write_per_bit : IN BOOLEAN := FALSE
                                ) is

   begin
      Mem_Split_WrtTrans ( mem_id,
                           address_trans(mem_id.rows, row, "row"),
                           address_trans(mem_id.sam_columns/2, tap, "SAM"),
                           row_segment,
                           sam_segment,
                           write_per_bit
                         );
   end;    

   Procedure Mem_Split_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                                  Constant row           : IN std_ulogic_vector;
                                  Constant tap           : IN NATURAL;
                                  Constant row_segment   : IN segment_type;
                                  Constant sam_segment   : IN sam_segment_type;
                                  Constant write_per_bit : IN BOOLEAN := FALSE
                                ) is

   begin
      Mem_Split_WrtTrans ( mem_id,
                           address_trans(mem_id.rows, row, "row"),
                           tap,
                           row_segment,
                           sam_segment,
                           write_per_bit
                         );
   end;    

   Procedure Mem_Split_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                                  Constant row           : IN NATURAL;
                                  Constant tap           : IN std_ulogic_vector;
                                  Constant row_segment   : IN segment_type;
                                  Constant sam_segment   : IN sam_segment_type;
                                  Constant write_per_bit : IN BOOLEAN := FALSE
                                ) is

   begin
      Mem_Split_WrtTrans ( mem_id,
                           row,
                           address_trans(mem_id.sam_columns/2, tap, "SAM"),
                           row_segment,
                           sam_segment,
                           write_per_bit
                         );
   end;    

   Procedure Mem_Split_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                                  Constant row           : IN std_ulogic_vector;
                                  Constant tap           : IN std_ulogic_vector;
                                  Constant row_segment   : IN segment_type;
                                  Constant sam_segment   : IN sam_segment_type;
                                  Constant write_per_bit : IN BOOLEAN := FALSE
                               ) is

   begin
      Mem_Split_WrtTrans ( mem_id,
                           address_trans(mem_id.rows, row, "row"),
                           address_trans(mem_id.sam_columns/2, tap, "SAM"),
                           row_segment,
                           sam_segment,
                           write_per_bit
                         );
   end;

   Procedure Mem_Split_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                                  Constant row           : IN bit_vector;
                                  Constant tap           : IN NATURAL;
                                  Constant row_segment   : IN segment_type;
                                  Constant sam_segment   : IN sam_segment_type;
                                  Constant write_per_bit : IN BOOLEAN := FALSE
                                ) is

   begin
      Mem_Split_WrtTrans ( mem_id,
                           address_trans(mem_id.rows, row, "row"),
                           tap,
                           row_segment,
                           sam_segment,
                           write_per_bit
                         );
   end;    

   Procedure Mem_Split_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                                  Constant row           : IN NATURAL;
                                  Constant tap           : IN bit_vector;
                                  Constant row_segment   : IN segment_type;
                                  Constant sam_segment   : IN sam_segment_type;
                                  Constant write_per_bit : IN BOOLEAN := FALSE
                                ) is

   begin
      Mem_Split_WrtTrans ( mem_id,
                           row,
                           address_trans(mem_id.sam_columns/2, tap, "SAM"),
                           row_segment,
                           sam_segment,
                           write_per_bit
                         );
   end;    

   Procedure Mem_Split_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                                  Constant row           : IN bit_vector;
                                  Constant tap           : IN bit_vector;
                                  Constant row_segment   : IN segment_type;
                                  Constant sam_segment   : IN sam_segment_type;
                                  Constant write_per_bit : IN BOOLEAN := FALSE
                                ) is

   begin
      Mem_Split_WrtTrans ( mem_id,
                           address_trans(mem_id.rows, row, "row"),
                           address_trans(mem_id.sam_columns/2, tap, "SAM"),
                           row_segment,
                           sam_segment,
                           write_per_bit
                         );
   end;

    ---------------------------------------------------------------------------    
    --    Procedure Name  :  Mem_WrtSAM
    --
    --    Purpose         :  Writes word to location of SAM pointed to by
    --                       the serial_ptr.
    --                       
    --
    --    Parameters      :  mem_id        - ptr to memory data structure
    --                       data          - holds word to be written
    --                       write_per_bit - enable write per bit
    --
    --    NOTE            :  Serial ptr incremented by 1 mod size of SAM.
    --
    ---------------------------------------------------------------------------
   
   Procedure Mem_WrtSAM ( Variable mem_id        : INOUT mem_id_type;
                          Constant data          : IN std_logic_vector;
                          Constant write_per_bit : IN BOOLEAN := FALSE
                        ) is

      variable alias_data : std_logic_vector(data'LENGTH - 1 downto 0) := To_X01(data);
      variable mem_word   : std_logic_vector(mem_id.width - 1 downto 0) := (others => 'X');
      variable mask       : std_logic_vector(mem_id.width - 1 downto 0);

   begin
      if (mem_id.memory_type /= VRAM) then
         assert false
            report "Mem_WrtSAM:  This operation is only valid for VRAMs." & LF & SPACESTR &
                   "Operation ignored."
            severity ERROR;
      else
         assert ( (data'length = mem_id.width) OR NOT MEM_WARNINGS_ON)
            report "Mem_WrtSAM:  passed data size does not match word size"
                   & " of mem:  " & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR &
                   "passed data size:  " & i_to_str(data'length) & " bits"
                   & LF & SPACESTR & "memory word size:  " &
                   i_to_str(mem_id.width) & " bits"
            severity WARNING;
         if (data'LENGTH >= mem_id.width) then 
            mem_word :=  alias_data(mem_id.width - 1 downto 0);
         else
            mem_word(data'LENGTH - 1 downto 0) := alias_data;
         end if;
         -- handle write per bit
         if write_per_bit then
            mask := Get_WPB_Mask(mem_id.width, mem_id.wpb_mask.all);
            for j in 0 to mem_id.width - 1 loop
               if (mask(j) /= '1') then        -- if mask is 1 then keep bit unchanged
                  mem_word(j) := mem_id.sam_data(mem_id.serial_ptr, j);
               end if;
            end loop;
         end if;
         -- write data
         for ii in 0 to mem_id.width - 1 loop
            mem_id.sam_data(mem_id.serial_ptr, ii) := mem_word(ii);
         end loop;
         -- if serial_ptr = a tap then clear the tap
         if (mem_id.serial_ptr = mem_id.sam_lower_tap) then
            mem_id.sam_lower_tap := 0;
         end if;
         if (mem_id.serial_ptr = mem_id.sam_upper_tap) then
            mem_id.sam_upper_tap := mem_id.sam_columns/2;
         end if;
         -- increment serial ptr
         mem_id.serial_ptr := (mem_id.serial_ptr + 1) mod (mem_id.sam_columns);
      end if;
   end;
                             
   Procedure Mem_WrtSAM ( Variable mem_id        : INOUT mem_id_type;
                          Constant data          : IN    std_ulogic;
                          Constant write_per_bit : IN BOOLEAN := FALSE
                        ) is

      variable temp_data : std_logic_vector(0 to 0);

   begin
      temp_data(0) := data;
      Mem_WrtSAM(mem_id, temp_data, write_per_bit);
   end;
                             

                                
   Procedure Mem_WrtSAM ( Variable mem_id        : INOUT mem_id_type;
                          Constant data          : IN    std_ulogic_vector;
                          Constant write_per_bit : IN BOOLEAN := FALSE
                        ) is

   begin
      Mem_WrtSAM ( mem_id, std_logic_vector(data), write_per_bit);
   end;

   Procedure Mem_WrtSAM ( Variable mem_id        : INOUT mem_id_type;
                          Constant data          : IN   bit_vector;
                          Constant write_per_bit : IN BOOLEAN := FALSE
                        ) is

   begin
      Mem_WrtSAM ( mem_id, bv_To_StdLogicVector(data, data'LENGTH), write_per_bit);
   end;

   Procedure Mem_WrtSAM ( Variable mem_id        : INOUT mem_id_type;
                          Constant data          : IN    bit;
                          Constant write_per_bit : IN BOOLEAN := FALSE
                        ) is

   begin
      Mem_WrtSAM ( mem_id, bit_to_std_ulogic(data), write_per_bit);
   end;

    ---------------------------------------------------------------------------    
    --    Procedure Name  :  Mem_Split_WrtSAM
    --
    --    Purpose         :  (VRAM) To write a word to the SAM in split 
    --                       reigister mode.
    --
    --    Parameters      :  mem_id        - ptr to memory data structure
    --                       data          - holds word to be written to SAM
    --                       write_per_bit - enable write per bit
    --
    --    NOTE            :  Write word to SAM location pointed to by serial pointer.
    --                       Serial pointer is incremented.  If the serial ptr
    --                       is incremented past the half SAM then it goes to
    --                       the tap address of the next half and resets that
    --                       tap address to the LSB of the half.
    --
    ---------------------------------------------------------------------------

   
   Procedure Mem_Split_WrtSAM ( Variable mem_id        : INOUT mem_id_type;
                                Constant data          : IN    std_logic_vector;
                                Constant write_per_bit : IN BOOLEAN := FALSE
                              ) is

      variable alias_data : std_logic_vector(data'LENGTH - 1 downto 0) := To_X01(data);
      variable mem_word   : std_logic_vector(mem_id.width - 1 downto 0) := (others => 'X');
      variable mask       : std_logic_vector(mem_id.width - 1 downto 0);

   begin
      if (mem_id.memory_type /= VRAM) then
         assert false
            report "Mem_Split_WrtSAM:  This operation is only valid for VRAMs." & LF & SPACESTR &
                   "Operation ignored."
            severity ERROR;
      else
         assert ( (data'length = mem_id.width) OR NOT MEM_WARNINGS_ON)
            report "Mem_Split_WrtSAM:  passed data size does not match word size"
                   & " of mem:  " & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR &
                   "passed data size:  " & i_to_str(data'length) & " bits"
                   & LF & SPACESTR & "memory word size:  " &
                   i_to_str(mem_id.width) & " bits"
            severity WARNING;
         if (data'LENGTH >= mem_id.width) then 
            mem_word :=  alias_data(mem_id.width - 1 downto 0);
         else
            mem_word(data'LENGTH - 1 downto 0) := alias_data;
         end if;
         -- handle write per bit
         if write_per_bit then
            mask := Get_WPB_Mask(mem_id.width, mem_id.wpb_mask.all);
            for j in 0 to mem_id.width - 1 loop
               if (mask(j) /= '1') then        -- if mask is 1 then keep bit unchanged
                  mem_word(j) := mem_id.sam_data(mem_id.serial_ptr, j);
               end if;
            end loop;
         end if;
         -- write data
         for ii in 0 to mem_id.width - 1 loop
            mem_id.sam_data(mem_id.serial_ptr, ii) := mem_word(ii);
         end loop;
         -- if serial_ptr = tap then clear tap
         if (mem_id.serial_ptr = mem_id.sam_lower_tap) then
            mem_id.sam_lower_tap := 0;
         end if;
         if (mem_id.serial_ptr = mem_id.sam_upper_tap) then
            mem_id.sam_upper_tap := mem_id.sam_columns/2;
         end if;
         -- increment serial ptr
         mem_id.serial_ptr := mem_id.serial_ptr + 1;
         if mem_id.serial_ptr = (mem_id.sam_columns/2) then
            mem_id.serial_ptr := mem_id.sam_upper_tap;
         elsif mem_id.serial_ptr >= mem_id.sam_columns then
            mem_id.serial_ptr := mem_id.sam_lower_tap;
         else
            NULL;
         end if;
      end if; 
   end;
 
   Procedure Mem_Split_WrtSAM ( Variable mem_id        : INOUT mem_id_type;
                                Constant data          : IN    std_ulogic;
                                Constant write_per_bit : IN BOOLEAN := FALSE
                              ) is

      variable temp_data : std_logic_vector(0 to 0);

   begin
      temp_data(0) := data;
      Mem_Split_WrtSAM (mem_id, temp_data, write_per_bit);
   end;

   Procedure Mem_Split_WrtSAM ( Variable mem_id        : INOUT mem_id_type;
                                Constant data          : IN    std_ulogic_vector;
                                Constant write_per_bit : IN BOOLEAN := FALSE
                              ) is

   begin
      Mem_Split_WrtSAM ( mem_id, std_logic_vector(data), write_per_bit);
   end;

   Procedure Mem_Split_WrtSAM ( Variable mem_id        : INOUT mem_id_type;
                                Constant data          : IN    bit_vector;
                                Constant write_per_bit : IN BOOLEAN := FALSE
                              ) is

   begin
      Mem_Split_WrtSAM ( mem_id, bv_To_StdLogicVector(data, data'LENGTH), write_per_bit);
   end;

   Procedure Mem_Split_WrtSAM ( Variable mem_id        : INOUT mem_id_type;
                                Constant data          : IN    bit;
                                Constant write_per_bit : IN BOOLEAN := FALSE
                              ) is
                               
   begin
      Mem_Split_WrtSAM ( mem_id, bit_to_std_ulogic(data), write_per_bit);
   end;

    ---------------------------------------------------------------------------    
    --    Procedure Name  :  Mem_Get_SPtr
    --
    --    Purpose         :  return serial_ptr of SAM
    --                       
    --    Parameters      :  mem_id     - ptr to memory data structure
    --                       serial_ptr - returned serial ptr
    --
    --    NOTE            :  returns value of serial_ptr
    --
    ---------------------------------------------------------------------------

   Procedure Mem_Get_SPtr ( Variable mem_id     : INOUT mem_id_type;
                            Variable serial_ptr : OUT NATURAL
                          ) is
      
   begin
      if (mem_id.memory_type /= VRAM) then
         assert FALSE
            report "Mem_Get_SPtr:  This operation is only valid for VRAMs." & LF & SPACESTR
                   & "Operation ignored."
            severity ERROR;
      else
         serial_ptr := mem_id.serial_ptr;
      end if;
   end;
   
   Procedure Mem_Get_SPtr ( Variable mem_id     : IN mem_id_type;
                            Variable serial_ptr : OUT std_logic_vector
                          ) is
                          
      constant sam_address_size : integer := vector_size(mem_id.sam_columns - 1);
      variable temp : std_logic_vector(sam_address_size - 1 downto 0);
      variable alias_ptr : std_logic_vector(serial_ptr'LENGTH - 1 downto 0) := (others => 'X');
   begin
      if (mem_id.memory_type /= VRAM) then
         assert FALSE
            report "Mem_Get_SPtr:  This operation is only valid for VRAMs." & LF & SPACESTR
                   & "Operation ignored."
            severity ERROR;
      else
         temp := from_natural(mem_id.serial_ptr, sam_address_size);
         assert ( (serial_ptr'length = sam_address_size) OR NOT MEM_WARNINGS_ON)
            report "Mem_Get_SPtr:  return data size does not match vector size needed to access entire SAM"
                   & " for memory:  " & pstr(mem_id.name(1 to mem_id.name'length))  & LF & SPACESTR &
                   "return data size:  " & i_to_str(serial_ptr'length) & " bits"
                   & LF & SPACESTR & "number of bits needed to address SAM:  " &
                   i_to_str(sam_address_size) & " bits"
            severity WARNING;
         if (serial_ptr'LENGTH >= temp'LENGTH) then 
            alias_ptr(temp'LENGTH - 1 downto 0) := temp;
         else
            alias_ptr := temp(alias_ptr'LENGTH - 1 downto 0);
         end if;
         serial_ptr := alias_ptr;
      end if;
   end;
   
   Procedure Mem_Get_SPtr ( Variable mem_id     : INOUT mem_id_type;
                            Variable serial_ptr : OUT std_ulogic_vector
                          ) is
      
      variable temp : std_logic_vector(serial_ptr'LENGTH - 1 downto 0);
      
   begin
      Mem_Get_SPtr(mem_id, temp);
      serial_ptr := std_ulogic_vector(temp);
   end;
   
   Procedure Mem_Get_SPtr ( Variable mem_id     : INOUT mem_id_type;
                            Variable serial_ptr : OUT bit_vector
                          ) is
      
      variable temp : std_logic_vector(serial_ptr'LENGTH - 1 downto 0);

   begin
      Mem_Get_SPtr(mem_id, temp);
      serial_ptr := data_trans(temp);
   end;

    ---------------------------------------------------------------------------    
    --    Procedure Name  :  Mem_Set_SPtr
    --
    --    Purpose         :  set value of serial_ptr of SAM
    --                       
    --    Parameters      :  mem_id     - ptr to memory data structure
    --                       serial_ptr - value serial ptr to be set to
    --
    --    NOTE            :  sets value of serial_ptr
    --
    ---------------------------------------------------------------------------

   Procedure Mem_Set_SPtr ( Variable mem_id     : INOUT mem_id_type;
                            Constant serial_ptr : IN NATURAL
                          ) is

   begin
      if (mem_id.memory_type /= VRAM) then
         assert FALSE
            report "Mem_Set_SPtr:  This operation is only valid for VRAMs." & LF & SPACESTR &
                   "Operation ignored."
            severity ERROR;
      else
         if (serial_ptr >= mem_id.sam_columns) then
            assert FALSE
               report "Mem_Set_SPtr:  Value of Serial Ptr greater than size of SAM." & LF & SPACESTR &
                      "Operation ignored"
               severity ERROR;
         else
            mem_id.serial_ptr := serial_ptr;
         end if;
      end if;
   end;                                                     
                                                                                   
   Procedure Mem_Set_SPtr ( Variable mem_id     : INOUT mem_id_type;
                            Constant serial_ptr : IN std_logic_vector
                          ) is

      variable temp : NATURAL;

   begin
      if (mem_id.memory_type /= VRAM) then
         assert FALSE
            report "Mem_Set_SPtr:  This operation is only valid for VRAMs." & LF & SPACESTR &
                   "Operation ignored."
            severity ERROR;
      else
         temp := address_trans (mem_id.sam_columns, To_X01(serial_ptr), "SAM");
         if (temp >= mem_id.sam_columns) then
            assert FALSE
               report "Mem_Set_SPtr:  Value of Serial Ptr greater than size of SAM." & LF & SPACESTR &
                      "Operation ignored"
               severity ERROR;
         else
            mem_id.serial_ptr := temp;
         end if;
      end if;
   end;
                                                                                   
   Procedure Mem_Set_SPtr ( Variable mem_id     : INOUT mem_id_type;
                            Constant serial_ptr : IN std_ulogic_vector
                          ) is

   begin
      Mem_Set_SPtr (mem_id, std_logic_vector(serial_ptr));
   end;
                                                                                   
   Procedure Mem_Set_SPtr ( Variable mem_id     : INOUT mem_id_type;
                            Constant serial_ptr : IN bit_vector
                          ) is

   begin
      Mem_Set_SPtr (mem_id, bv_To_StdLogicVector(serial_ptr, serial_ptr'LENGTH));
   end;

    ---------------------------------------------------------------------------    
    --    Function Name   :  To_Segment
    --
    --    Purpose         :  take a vector or a bit and return the
    --                       appropriate segment
    --                       
    --    Parameters      :  address  -  bit, std_ulogic or vector
    --
    --    Return Value    :  segment_type - corresponding segment
    --
    --    NOTE            :  input must be either a std_ulogic, a bit
    --                       or a vector of length 2
    --
    ---------------------------------------------------------------------------

    Function To_Segment ( Constant address : IN bit_vector ) return segment_type is

       variable alias_address : bit_vector(address'LENGTH - 1 downto 0) := address;
       variable case_address  : bit_vector(1 downto 0);
       variable segment : segment_type := LOWER_HALF;

    begin
       if (alias_address'LENGTH = 1) then
          if alias_address = "0" then
             segment := LOWER_HALF;
          else
             segment := UPPER_HALF;
          end if;
       elsif (alias_address'LENGTH = 2) then
          case_address := alias_address; -- case expression must have static subtype
          case case_address is
             when "00" => segment := QUARTER1;
             when "01" => segment := QUARTER2;
             when "10" => segment := QUARTER3;
             when "11" => segment := QUARTER4;
          end case;
       else
          assert FALSE
             report "To_Segment:  illegal vector length.  Returning LOWER_HALF"
             severity ERROR;
       end if;
       return segment;
    end;

    Function To_Segment ( Constant address : IN std_logic_vector ) return segment_type is

       variable alias_address : std_logic_vector(address'LENGTH - 1 downto 0) := To_UX01(address);
       variable bit_address : bit_vector(address'LENGTH - 1 downto 0);
       variable uonce : BOOLEAN := TRUE;
       variable xonce : BOOLEAN := TRUE;
    
    begin
        for i IN 0 to alias_address'LENGTH - 1 loop
            if ((alias_address(i) = 'U') and MEM_WARNINGS_ON and uonce) then
                uonce := FALSE;
                assert FALSE
                   report "To_Segment:  vector contains a U - it is being mapped to:  " & to_str(ADDRESS_U_MAP)
                          severity WARNING;
            end if;
            if ((alias_address(i) = 'X') and MEM_WARNINGS_ON and xonce) then
                xonce := FALSE;
                assert false
                   report "To_Segment: vector contains an X - it is being mapped to:  " & to_str(ADDRESS_X_MAP)
                          severity WARNING;
            end if;
            bit_address(i) := ADDRESS_MAP(alias_address(i));
        end loop;
        return(To_Segment(bit_address));
    end;

    Function To_Segment ( Constant address : IN std_ulogic_vector ) return segment_type is
        
    begin
       return(To_Segment(std_logic_vector(address)));       
    end;

    Function To_Segment ( Constant address : IN std_ulogic ) return segment_type is

       variable temp : std_logic_vector(0 downto 0);

    begin
       temp(0) := address;
       return(To_Segment(temp));
    end;
                                                                                   
    Function To_Segment ( Constant address : IN bit ) return segment_type is

       variable temp : bit_vector(0 downto 0);

    begin
       temp(0) := address;
       return(To_Segment(temp));
    end;
                                                                                   
END std_mempak;
