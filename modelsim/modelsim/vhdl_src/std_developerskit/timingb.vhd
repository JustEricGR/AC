-- ----------------------------------------------------------------------------
--
--  Copyright (c) Mentor Graphics Corporation, 1982-1996, All Rights Reserved.
--                       UNPUBLISHED, LICENSED SOFTWARE.
--            CONFIDENTIAL AND PROPRIETARY INFORMATION WHICH IS THE
--          PROPERTY OF MENTOR GRAPHICS CORPORATION OR ITS LICENSORS.
--
--
-- PackageName :  Std_Timing
-- Title       :  Standard Timing Package
-- Purpose     :  This package defines a set of standard declarations
--             :  and subprograms used to model the timing, loading
--             :  and back-annotation information for ASIC cells and
--             :  standard part models.
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
--   Version No:| Author:|  Mod. Date:| Changes Made:
--     v1.000   |  ****  |  09/16/91  | Production release
--     v1.010   |  wdb   |  10/24/91  | Production release update
--     v1.020   |  wdb   |  11/12/91  | Added default value to Refport on PeriodCheck
--     v1.100   |  wdb   |  12/29/91  | Production Release
--     v1.101   |  rjr   |  01/13/92  | general cleanup of violation watchdogs
--     v1.110   |  mkd   |  03/06/92  | fixing 32bit time problem
--     v1.110   |  mkd   |  03/06/92  | Production release
--     v1.120   |  mkd   |  03/20/92  | fixed fs in PulseCheck and SpikeCheck
--     v1.210   |  rjr   |  06/18/92  | Add overloaded CalcDelay, ReleaseViolation
--     v1.211   |  rjr   |  07/27/92  | Fix Soft Error detect in ReleaseViolation
--     v1.130   |  mkd   |  09/03/92  | Production release update
--     v1.140   |  mkd   |  11/06/92  | Production release update
--     v1.500   |  mkd   |  11/17/92  | fixed default 0 time
--     v1.600   |  mkd   |  02/11/93  | Production release update
--              |  wdb   |  02/23/93  | VITAL enhancements
--     v1.610   |  wrm   |  03/30/93  | fixed bug in timingcheck assertion
--              |        |            | and spikecheck and pulsecheck and
--              |        |            | vantage bug fix to timingcheck
--     v1.700 B |  wrm   |  05/03/93  | beta release - no changes from 1.61
--     v1.700   |  wrm   |  05/25/93  | production release - minor change in assertions for timingcheck
--     v1.800   |  wrm   |  07/28/93  | combining into 1 file body and mentor support, bug in timingcheck fixed
--     v2.000   |  wrm   |  07/21/94  | production release - addition of skew check, assorted upgrades
--     v2.001g  |  wrm   |  08/24/95  | Minor modification to vector form of TimingCheck to fix bug that 
--				      | causes violation not to be reported if Test Port and Ref. Port change
--				      | at same delta.  Also related changes to other timing procedures
--				      | to fix similar problem with transitions from X.
--     v2.100   |  wrm   |  01/10/96  | Production release
--				      | Initialization banner removed
--     v2.2     |  bmc   |  07/25/96  | Updated for Mentor Graphics Release
-- ----------------------------------------------------------------------------

PACKAGE BODY Std_Timing IS

 -- ************************************************************************
 -- Set values for deffered constants
 -- ************************************************************************

     FUNCTION GetBaseTime return time is
        variable min_time_unit : time;
     BEGIN
        -- identify minimum time unit
        min_time_unit := 1 ns / 1000000;
        if ( min_time_unit > 0 ns ) then       -- fs
           return min_time_unit;
        else
           min_time_unit := 1 ns / 1000;
           if ( min_time_unit > 0 ns ) then    -- ps
              return min_time_unit;
           else		                  -- ns
              return 1 ns;
           end if;
        end if;
     END;


     CONSTANT UnitDelay   : TIME := GetBaseTime;

     CONSTANT UnitBIDelay : BaseIncrDlyPair := (UnitDelay, 0 ns);
     --                                        ^^^^^       ^^^^
     --                                        Base        Incremental


 -- ************************************************************************
 -- Display Banner
 -- ************************************************************************

    FUNCTION DisplayBanner return BOOLEAN is

    BEGIN
       ASSERT FALSE
           report LF &
		  "--  Initializing Std_Developerskit (Std_Timing package v2.10)" & LF &
		  "--  Copyright by Mentor Graphics Corporation" & LF &
		  "--  [Please ignore any warnings associated with this banner.]"
           severity NOTE;
       return TRUE;
    END;

    --CONSTANT StdTimingBanner : BOOLEAN := DisplayBanner;
    CONSTANT StdTimingBanner : BOOLEAN := TRUE;

 -- ************************************************************************
 -- Standard Physical Types
 -- ************************************************************************
    -- no code required in the package body to support these declarations

 -- ************************************************************************
 -- Timing Interface - Generic Parameter Types
 -- ************************************************************************
    -- no code required in the package body to support these declarations

 -- ************************************************************************
 --  Type Declarations for facilitating this package
 -- ************************************************************************
    -- no code required in the package body to support these declarations

    -- --------------------------------------------------------------------
    -- Package Local Declarations
    -- --------------------------------------------------------------------
    CONSTANT SMC_CR : STRING(1 TO 3) := ';' & CR & LF;
--
-- These are duplicated declaration from std_iopak.pkg.vhdl
--
    CONSTANT max_string_len : INTEGER := 256;
    TYPE INT8            IS RANGE 0 TO 7;
    TYPE time_unit_type  IS (t_fs, t_ps, t_ns, t_us, t_ms, t_sec, t_min, t_hr);
    TYPE hilo_str_type   IS ARRAY (std_ulogic range 'X' to '1') OF STRING(1 TO 2);
    CONSTANT hilo_str : hilo_str_type := ("X ", "LO", "HI" );


 -- ************************************************************************
 -- Local Routines
 -- ************************************************************************
    --+-----------------------------------------------------------------------------
    --|     Function Name  : D_Machine
    --| hidden
    --|     Overloading    : None
    --|
    --|     Purpose        : Finite State automaton to recognise integer format.
    --|                      format will be broken into field width, precision
    --|                      and justification (left or right).
    --|
    --|     Parameters     : fwidth        -- output, INTEGER, field width
    --|                      precision     -- output, INTEGER, Precision
    --|                      justify -- OUTPUT, BIT
    --|                                            '0' right justified,
    --|                                            '1' left justified
    --|                      format  - input  STRING, provides the
    --|                        conversion specifications.
    --|
    --|     Result         : INTEGER, length of output string.
    --|
    --|     NOTE           :
    --|                      This procedure is
    --|                      called in the funtion To_String  when need to
    --|                      a real number string.
    --|
    --|     Use            :
    --|                    VARIABLE   fmt : STRING(1 TO format'LENGTH) := format;
    --|                    VARIABLE fw       : INTEGER;
    --|                    VARIABLE precis   : INTEGER;
    --|                    VARIABLE justfy    : BIT;
    --|
    --|                    D_Machine(fw, precis, justy, fmt);
    --|
    --|-----------------------------------------------------------------------------
       PROCEDURE D_Machine ( VARIABLE fwidth     : OUT INTEGER;
                             VARIABLE precison   : OUT INTEGER;
                             VARIABLE justify    : OUT BIT;
                             CONSTANT format     : IN STRING
                           ) IS
         VARIABLE state :  INT8 := 0;      --  starting state
         VARIABLE fmt   : STRING(1 TO format'LENGTH) := format;
         VARIABLE ch    : CHARACTER;
         VARIABLE index : INTEGER := 1;
         VARIABLE fw    : INTEGER := 0;
         VARIABLE pr    : INTEGER := 0;

       BEGIN

       -- make sure first character is '%' if not error
         ch := fmt(index);
         IF (fmt(index) /= '%') THEN
               ASSERT FALSE
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
                              ELSIF (ch = 'd') THEN
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
                              ELSIF (ch = 'd') THEN
                                 state := 3;
                              ELSIF (ch = '.') THEN
                                 state := 4;
                              ELSE
                                 state := 6;
                              END IF;

                      WHEN 3  =>     -- d  state
                               -- fromat successfully recognized, exit now.
                               EXIT;

                      WHEN 4   =>   -- . state
                               IF (ch >= '0' AND ch <= '9') THEN
                                  pr :=  CHARACTER'POS(ch) - CHARACTER'POS('0'); -- to_digit
                                  state := 7;
                               ELSE
                                  state := 6;  -- error
                               END IF;

                      WHEN 5   =>   --  print %
                               EXIT;

                      WHEN 6  =>   -- error state
                                     -- print error message
                               ASSERT FALSE
                               REPORT " Format Error --- expected %f format. "
                               SEVERITY ERROR;
                               EXIT;

                      WHEN 7  =>
                                    -- precision
                               IF (ch >= '0' AND ch <= '9') THEN
                                  pr := pr * 10 + CHARACTER'POS(ch)
                                                - CHARACTER'POS('0'); -- to_digit
                                  state := 7;
                                ELSIF (ch = 'd') THEN
                                  state := 3;
                                ELSE
                                  state := 6;  -- error
                                END IF;
               END CASE;
            ELSE
    	   ASSERT FALSE
    	   REPORT " D-Machine ---- format error expected  %d  format"
               SEVERITY ERROR;
               EXIT;
            END IF;

         END LOOP;

         IF (fw > max_string_len) THEN
    	fwidth := max_string_len;
         ELSE
    	fwidth := fw;
         END IF;
    	precison := pr;
         RETURN;
       END;
    --+-----------------------------------------------------------------------------
    --|     Function Name  : To_String
    --| 1.1.5
    --|     Overloading    : None
    --|
    --|     Purpose        : Convert an integer  into a String according
    --|                      format specification.
    --|
    --|     Parameters     :
    --|                      val     - input  value,  INTEGER,
    --|                      format  - input  STRING, provides the
    --|                        conversion specifications.
    --|
    --|     Result         : STRING  representation of an integer.
    --|
    --|     NOTE           : Format string has same meaning a in C language.
    --|                      That if format is "%d " will convert an integer to
    --|                      a string of length equal to number of digits in the
    --|                      given inetger argument. While "%10d " return
    --|                      a string of length 10 and if the number of digits
    --|                      in the integer are less than 10 it will pad the
    --|                      string with blank on the left because default
    --|                      justification is right. if number of digits are
    --|                      larger than 10 it will return 10 leftmost digits.
    --|
    --|
    --|
    --|     USE            :
    --|                     VARIABLE str : STRING(1 TO 10);
    --|                     VARIABLE val   : INTEGER := 2750;
    --|
    --|                          str := TO_String(val, "%10d"),
    --|-----------------------------------------------------------------------------
        FUNCTION To_String ( CONSTANT val    : IN INTEGER;
                             CONSTANT format : IN STRING := "%d"
                           ) RETURN STRING IS
         	VARIABLE buf        : STRING(max_string_len DOWNTO 1) ; -- implicitly == NUL
            VARIABLE rbuf       : STRING(max_string_len DOWNTO 1) ;
            VARIABLE str_index  : INTEGER := 0;
            VARIABLE ival       : INTEGER;
            VARIABLE format_cpy : STRING(1 TO format'LENGTH) := format;
            VARIABLE fw         : INTEGER;  -- field width
            VARIABLE precis     : INTEGER;
            VARIABLE justy      : BIT := '0';

        BEGIN
        -- convert to positive number
          ival := ABS(val);
          IF ival = 0 THEN
    	str_index := str_index + 1;
            buf(str_index) := '0';
          ELSE
    	int_loop : LOOP
            	str_index := str_index + 1;
    		CASE (ival MOD 10) IS
                         WHEN 0 => buf (str_index) := '0';
                         WHEN 1 => buf (str_index) := '1';
                         WHEN 2 => buf (str_index) := '2';
                         WHEN 3 => buf (str_index) := '3';
                         WHEN 4 => buf (str_index) := '4';
                         WHEN 5 => buf (str_index) := '5';
                         WHEN 6 => buf (str_index) := '6';
                         WHEN 7 => buf (str_index) := '7';
                         WHEN 8 => buf (str_index) := '8';
                         WHEN 9 => buf (str_index) := '9';
                         WHEN OTHERS => NULL; -- do nothing
    		END CASE;
                    ival := ival / 10;
                    EXIT int_loop WHEN ival=0;
    	END LOOP;
          END IF;

            -- call procedure D_Machine to split the format string into
            -- field width, and justification(left or right) and precision
            D_Machine(fw, precis, justy, format_cpy);

            IF (precis > str_index) THEN      -- pad with zeros to make up precision
                buf(precis DOWNTO str_index + 1) := (OTHERS => '0');
                str_index := precis;
            END IF;

            -- Handle the negative numbers here...
            IF val < 0 THEN
                str_index := str_index + 1;
                buf (str_index) := '-';
            END IF;

    	-- return the result according to field width and justification
    	IF (fw > str_index) THEN
               CASE justy IS
                    WHEN '0' =>
                         buf(fw DOWNTO str_index + 1) := (OTHERS => ' ');
                         RETURN buf(fw DOWNTO 1);
    		WHEN '1' =>
                         rbuf(fw - str_index  DOWNTO  1) := (OTHERS => ' ');
                         RETURN (buf(str_index DOWNTO 1) & rbuf(fw - str_index DOWNTO 1));
                    WHEN OTHERS =>
                         ASSERT FALSE
                         REPORT " To_String  --- error in justification "
                         SEVERITY WARNING;
                         RETURN buf(str_index DOWNTO 1);
                END CASE;
    	ELSE           -- fw is lessthan or equal to std_index
    	    RETURN buf(str_index DOWNTO 1);
    	END IF;

           -- That's all
        END;

    -- ---------------------------------------------------------------------
    --  Function   : To_String
    --  Returns    : String
    --  Purpose    : This function converts std_ulogic to string format
    --             :
    --  Arguments  : CONSTANT s : std_ulogic
    --             :
    --  Assumption : none
    --  Example    :
    --             :
    --     Assert false report "Q := " & to_string ( Q );
    -- ---------------------------------------------------------------------
       FUNCTION To_String ( CONSTANT s : std_ulogic ) RETURN STRING IS
       BEGIN
           CASE s IS
               WHEN 'U' => RETURN "U";
               WHEN 'X' => RETURN "X";
               WHEN '0' => RETURN "0";
               WHEN '1' => RETURN "1";
               WHEN 'Z' => RETURN "Z";
               WHEN 'W' => RETURN "W";
               WHEN 'L' => RETURN "L";
               WHEN 'H' => RETURN "H";
               WHEN '-' => RETURN "-";
           END CASE;
       END To_String;
















-- part B of std_timing for t64

--+-----------------------------------------------------------------------------
--|     Function Name  : Default_Time
--| hidden
--|     Overloading    : None
--|

--|     Purpose        : Convert 64 bit Time value to a String with
--|                      default  length of 12.


--|
--|     Parameters     :
--|                      val     - input,  TIME,
--|
--|     Result         : STRING  representation of TIME.
--|                        
--|     NOTE           : This function converts input time to an appropriate
--|                      time units such that it can be represented in a string
--|                      length 7 (xxx.xxx). Then  4 places for unit

--|                      ( hr, min, sec, ms ps etc.) are needed and one more for

--|                       sign ( -/+ ). IF time is positive then sign position is 
--|                       left blank. This way this function will return a string
--|                       of length 12.
--|                        signXXX.XXX Unit  ( sign takes one location and units 3). 
--|
--|
--|-----------------------------------------------------------------------------


    FUNCTION Default_Time ( CONSTANT val    : IN TIME
                            )  RETURN STRING IS
            VARIABLE tval : time;
            VARIABLE ival : integer := 0;
            VARIABLE fval : integer := 0;
            VARIABLE same_unit : Boolean := false; 
            VARIABLE sign   : character := ' ';
            VARIABLE prefix : string(1 to 7) := "   .   ";
            VARIABLE suffix : string(1 to 4) := "    ";
            VARIABLE digit  : integer range 0 to 9;
            type char10 is array (Integer range 0 to 9) of character;
            CONSTANT lookup : char10 := ( '0','1','2','3','4','5','6','7','8','9');
        BEGIN
        --  Handling sign 
            IF    ( val < 0 ns  ) THEN 
                   sign := '-'; 
                   tval := - val;
            ELSE
                   sign := ' '; 
                   tval :=   val;
            END IF;
         -- selecting proper unit dynamically

         -- check for 0 time (whether input time is 0 fs, 0 ps, 0 ns etc)

         -- it will be treated as 0 ns / 1000000 internally. We will provide default
         -- time as 0.000 ns.
         --
           IF (tval = 0 ns) then
              ival   := 0;
              suffix := " ns "; 

           ELSIF  ( tval >= 1 hr  ) then
              ival :=  (tval / 1 min  ); -- gives it in terms of 60's 
                                                 -- of min
              suffix := " hr ";
              fval := (ival mod 60);
              ival := (1000 * (ival/60)) + ( fval * 1000 / 60);
           ELSIF ( tval >= 1 min ) then
              ival :=  (tval / 1 sec); -- gives it in terms of 60's of sec
              suffix := " min";
              fval := ival mod 60;
              ival := (1000 * (ival/60)) + (fval * 1000 / 60);

           ELSIF ( tval >= 1 sec ) then
              ival := tval / 1 ms; -- gives it in terms of 1000's of ms
              suffix := " sec";
           ELSIF ( tval >= 1 ms  ) then
              ival := tval / 1 us; -- gives it in terms of 1000's of us
              suffix := " ms ";


           ELSIF (tval >= 1 us) then  
              ival := tval / 1 ns; -- gives it in terms of 1000s of ns 
              suffix := " us ";


           ELSIF ( tval >= 1 ns) THEN
	      suffix := " ns ";
	      if ( (1 ns / 1000) = 0 ns ) then
	         ival := tval / (1 ns);
		 same_unit := TRUE;
	      else
                 ival := tval / (1 ns / 1000); -- gives it in terms of 1000s of 1 ns / 1000
	      end if;
              


           ELSIF ( tval >= (1 ns / 1000) ) THEN
	      suffix := " ps ";
	      if ( (1 ns / 1000000) = 0 ns ) then
	         ival := tval / (1 ns / 1000);
		 same_unit := TRUE;
              else
                 ival := tval / (1 ns / 1000000); -- gives it in terms of 1000s of 1 ns / 1000000
	      end if;

           ELSIF ( tval >= (1 ns / 1000000) ) THEN			
              ival := tval / (1 ns / 1000000); 
              suffix := " fs ";
              same_unit := TRUE;
           END IF;
         --  converting to XXX.XXX format 
           IF ( same_unit ) THEN
                prefix(5 TO 7) := (OTHERS => '0');
           ELSE
	        FOR i IN 7 DOWNTO 5 LOOP
        	        digit := ival mod 10;
                	ival := ival / 10;
	                prefix (i) := lookup(digit);
                END  LOOP;
           END IF;
           FOR i IN 3 DOWNTO  1 LOOP
                digit := ival mod 10;
                ival := ival / 10;
                prefix (i) := lookup(digit);
           END  LOOP;
         -- get rid of leading zero's
           leading_zero_kill : FOR i IN 1 to 2 LOOP
                exit leading_zero_kill WHEN (prefix(i) /= '0');
                IF (prefix(i) = '0') THEN 
                     prefix (i) := ' '; 
                 END IF;
           END LOOP;
	   if (prefix(2) = ' ') then
	      return ( "  " & sign & prefix(3 to 7) & suffix);
	   elsif (prefix(1) = ' ') then
	      return ( ' ' & sign & prefix(2 to 7) & suffix);
	   else
	      RETURN (sign & prefix & suffix);
	   end if;
        END Default_Time;


    --+-----------------------------------------------------------------------------
    --|     Procedure Name  : report_sig_error
    --|
    --|     Overloading    : None
    --|
    --|     Purpose        : Generate a standard timing error message
    --|
    --|     Parameters     :
    --|         IN      : headermsg     --  string
    --|         IN      : testportname  --  string
    --|         IN      : preamble      --  string
    --|         IN      : expected_time --  TIME
    --|         IN      : observed_time --  TIME
    --		IN      : AssertionsON	--  BOOLEAN
    --|
    --|     USE            :
    --|            IF    ((NOW - timemark) < t_pulse_hi) AND (To_X01(TestPort) = '0') THEN
    --|                report_sig_error ( HeaderMsg, TestPortName,
    --|                                   "SHORT HIGH PULSE WAS DETECTED"
    --|                                   t_pulse_hi, NOW - timemark );
    --|            END IF;
    --|
    --|-----------------------------------------------------------------------------
        PROCEDURE report_sig_error (
                    CONSTANT HeaderMsg     : IN STRING := " ";
                    CONSTANT TestPortName  : IN STRING := "";  -- name OF the signal
                    CONSTANT Preamble      : IN STRING := " ";
                    CONSTANT expected_time : IN TIME;
                    CONSTANT observed_time : IN TIME;
		    CONSTANT AssertionsOn  : IN BOOLEAN := TRUE
                  ) IS
        BEGIN
            ASSERT NOT AssertionsOn
            REPORT HeaderMsg & Preamble & " ON " & TestPortName & SMC_CR &
                   "  Expected := " & Default_Time (expected_time) &
                   "; Observed := " & Default_Time (observed_time) &
                   "; At : "        & Default_Time ( NOW )
            SEVERITY ERROR;
        END report_sig_error;
       

    -- part C of std_timing.pkg_body.v140
    
    CONSTANT AssertionFill : String(1 to 18) := "                  "; -- for Vantage Pretty Print
    --+-----------------------------------------------------------------------------
    --|     Procedure Name  : report_soft_error
    --|
    --|     Overloading    : None
    --|
    --|     Purpose        : Generate a standard error message for Strength Timing error
    --|
    --|     Parameters     :
    --|         IN      : headermsg     --  string
    --|         IN      : checkmsg      --  string
    --|         IN      : testX01       --  X01
    --|         IN      : testportname  --  string
    --|         IN      : refportname   --  string
    --|         IN      : expected_time --  TIME
    --|         IN      : observed_time --  TIME
    --|         IN      : lastvalue     --  std_logic
    --|         IN      : value         --  std_logic
    --|		IN	: AssertionsOn	--  BOOLEAN
    --|
    --|
    --|     USE            :
    --|                IF TestX01 = To_X01(TestPort)) THEN
    --|                    --------------------------------------------------------
    --|                    -- the "state" did not change, only the strength did
    --|                    --------------------------------------------------------
    --|                    report_soft_error (
    --|                                HeaderMsg, "HOLD  ", TestX01,
    --|                                TestPortName, RefPortName,
    --|                                expected_time, observed_time,
    --|                                TestPort'LAST_VALUE, TestPort );
    --|                ELSE
    --|                    --------------------------------------------------------
    --|                    -- the "state" changed ( hard ) violation
    --|                    --------------------------------------------------------
    --|                    report_error (
    --|                                HeaderMsg, "HOLD  ", TestX01,
    --|                                TestPortName, RefPortName,
    --|                                expected_time, observed_time );
    --|                END IF;
    --|
    --|-----------------------------------------------------------------------------
        PROCEDURE report_soft_error (
                    CONSTANT HeaderMsg     : IN STRING := " ";
                    CONSTANT CheckMsg      : IN STRING := " ";
                    CONSTANT TestX01       : IN std_logic;
                    CONSTANT TestPortName  : IN STRING := "";  -- name OF the signal
                    CONSTANT RefPortName   : IN STRING := "";  -- name OF the ref signal
                    CONSTANT expected_time : IN TIME;
                    CONSTANT observed_time : IN TIME;
                    CONSTANT lastvalue     : IN std_logic;
                    CONSTANT value         : IN std_logic;
		    CONSTANT AssertionsOn  : IN BOOLEAN := TRUE
                  ) IS
        BEGIN
            ASSERT NOT AssertionsOn
            REPORT HeaderMsg &
                   " Strength Change " & CheckMsg & hilo_str(TestX01) &
                   " VIOLATION ON " & TestPortName &
                   " WITH RESPECT TO " & RefPortName & SMC_CR & AssertionFill &
                   "  Expected := " & Default_Time (expected_time) &
                   "; Observed := " & Default_Time (observed_time) &
                   "; At : "        & Default_Time ( NOW ) & 
                   ";" & TestPortName & " CHANGED FROM " &
                   To_String (lastvalue) & " TO " & To_String (value)
            SEVERITY WARNING;
        END;

    --+-----------------------------------------------------------------------------
    --|     Procedure Name  : report_possible_error
    --|
    --|     Overloading    : None
    --|
    --|     Purpose        : Generate a standard error message for Possible timing
    --|                      errors (ie Setup violations within the -hold time )
    --|
    --|     Parameters     :
    --|         IN      : headermsg     --  string
    --|         IN      : checkmsg      --  string
    --|         IN      : testX01       --  X01
    --|         IN      : testportname  --  string
    --|         IN      : refportname   --  string
    --|         IN      : expected_time --  TIME
    --|         IN      : observed_time --  TIME
    --|         IN      : constrnt_time --  TIME
    --|		IN      : AssertionsOn	--  BOOLEAN
    --|
    --|
    --|     USE            :
    --|                IF (observed_time > constrnt_time) THEN
    --|                    --------------------------------------------------------
    --|                    -- Test signal change within negative hold window
    --|                    --------------------------------------------------------
    --|                    report_possible_error (
    --|                                    HeaderMsg, "SETUP ", TestX01,
    --|                                    TestPortName & "(" & To_String(i) & ")" &
    --|                                    RefPortName,
    --|                                    expected_time, observed_time,
    --|                                    constrnt_time );
    --|                END IF;
    --|
    --|-----------------------------------------------------------------------------
        PROCEDURE report_possible_error (
                    CONSTANT HeaderMsg     : IN STRING := " ";
                    CONSTANT CheckMsg      : IN STRING := " ";
                    CONSTANT TestX01       : IN std_logic;
                    CONSTANT TestPortName  : IN STRING := "";  -- name OF the signal
                    CONSTANT RefPortName   : IN STRING := "";  -- name OF the ref signal
                    CONSTANT expected_time : IN TIME;
                    CONSTANT observed_time : IN TIME;
                    CONSTANT constrnt_time : IN TIME;
		    CONSTANT AssertionsOn  : IN BOOLEAN := TRUE
                  ) IS
        BEGIN
            ASSERT NOT AssertionsOn
            REPORT HeaderMsg &
                   " Possible " & CheckMsg & hilo_str(TestX01) &
                   " VIOLATION ON " & TestPortName &
                   " WITH RESPECT TO " & RefPortName & SMC_CR & AssertionFill &
                   "  Expected := " & Default_Time (expected_time) &
                   "; Observed := " & Default_Time (observed_time) &
                   "; At : "        & Default_Time ( NOW ) & SMC_CR & AssertionFill &
                   " HOLD time := " & Default_Time (-constrnt_time)
            SEVERITY WARNING;
        END;

    --+-----------------------------------------------------------------------------
    --|     Procedure Name  : report_error
    --|
    --|     Overloading    : None
    --|
    --|     Purpose        : Generate a standard timing error message
    --|
    --|     Parameters     :
    --|         IN      : headermsg     --  string
    --|         IN      : checkmsg      --  string
    --|         IN      : testX01       --  X01
    --|         IN      : testportname  --  string
    --|         IN      : refportname   --  string
    --|         IN      : expected_time --  TIME
    --|         IN      : observed_time --  TIME
    --|		IN	: AssertionsOn	--  BOOLEAN
    --|
    --|     USE            :
    --|                IF TestX01 = To_X01(TestPort)) THEN
    --|                    --------------------------------------------------------
    --|                    -- the "state" did not change, only the strength did
    --|                    --------------------------------------------------------
    --|                    report_soft_error (
    --|                                HeaderMsg, "HOLD  ", TestX01,
    --|                                TestPortName, RefPortName,
    --|                                expected_time, observed_time,
    --|                                TestPort'LAST_VALUE, TestPort );
    --|                ELSE
    --|                    --------------------------------------------------------
    --|                    -- the "state" changed ( hard ) violation
    --|                    --------------------------------------------------------
    --|                    report_error (
    --|                                HeaderMsg, "HOLD  ", TestX01,
    --|                                TestPortName, RefPortName,
    --|                                expected_time, observed_time );
    --|                END IF;
    --|
    --|-----------------------------------------------------------------------------
        PROCEDURE report_error (
                    CONSTANT HeaderMsg     : IN STRING := " ";
                    CONSTANT CheckMsg      : IN STRING := " ";
                    CONSTANT TestX01       : IN std_logic;
                    CONSTANT TestPortName  : IN STRING := "";  -- name OF the signal
                    CONSTANT RefPortName   : IN STRING := "";  -- name OF the ref signal
                    CONSTANT expected_time : IN TIME;
                    CONSTANT observed_time : IN TIME;
		    CONSTANT AssertionsOn  : IN BOOLEAN := TRUE
                  ) IS
        BEGIN
            ASSERT NOT AssertionsOn
            REPORT HeaderMsg & " " &
                   CheckMsg & hilo_str(TestX01) &
                   " VIOLATION ON " & TestPortName &
                   " WITH RESPECT TO " & RefPortName & SMC_CR & AssertionFill &
                   "  Expected := " & Default_Time (expected_time) &
                   "; Observed := " & Default_Time (observed_time) &
                   "; At : "        & Default_Time ( NOW )
            SEVERITY ERROR;
        END;

 -- ************************************************************************
 -- Constants (deferred)
 -- ************************************************************************
    CONSTANT NoDelayPath : TIME := TIME'LOW / 2; -- trick to support vendors
                                                 -- who have limited TIME ranges

 -- ************************************************************************
 -- ATTRIBUTES
 -- ************************************************************************
    -- no code required in the package body to support these declarations


 -- ****************************************************************************
 -- DERATING
 -- ****************************************************************************
     --------------------------------------------------------------------------
     -- This package handles derating curves by providing a third order
     -- polynomial interpolator for matching the propagation delay vs.
     -- system parameter curves ( i.e. delay vs. voltage )
     --
     -- In most instances, there are separate curves for rising and falling
     -- delay values. And, the delays are generally dependent on Temperature,
     -- Voltage and Capacitive loading. Therefore, a record has been defined
     -- which includes all three "pairs" of rising/falling derating factors.
     --------------------------------------------------------------------------
     -- Coefficients of the polynomial match the equation
     --     f(x) := poly(3) * x**3 + poly(2) * x**2 + poly(1) * x + poly(0);
     --------------------------------------------------------------------------
     --+---------------------------------------------------------------------
     --+  Function   : DeratingFactor
     --+  Returns    : real
     --+  Purpose    : This function calculates a real value by evaluating
     --+             : the polynomial given the derating coefficients and
     --+             : the specific data value;
     --+
     --+  Arguments  ; CONSTANT Coefficients : PolynomialCoeff; -- 4 coefficients
     --+             : CONSTANT SysVoltage : Voltage; -- operating voltage of device
     --+
     --+  Assumption : Voltage in "volts"
     --+
     --+  Example    :
     --+
     --+  Constant   tplh_a_y_delay : time := tplh_a_y (TimeMode) *
     --+                DeratingFactor ( Coefficients => SysVoltageDerateCoeff_lh,
     --+                                 SysVoltage   => 5.1 v
     --+                               );
     --+
     --+---------------------------------------------------------------------
        FUNCTION DeratingFactor ( CONSTANT Coefficients : PolynomialCoeff;
                                  CONSTANT SysVoltage   : Voltage
                                ) RETURN REAL IS
            VARIABLE factor : REAL;
        BEGIN
            factor := Coefficients(3) * REAL(SysVoltage/v)**3 +
                      Coefficients(2) * REAL(SysVoltage/v)**2 +
                      Coefficients(1) * REAL(SysVoltage/v)    +
                      Coefficients(0) ;

            RETURN factor;

        END DeratingFactor;

     --+---------------------------------------------------------------------
     --+  Function   : DeratingFactor
     --+  Returns    : real
     --+  Purpose    : This function calculates a real value by evaluating
     --+             : the polynomial given the derating coefficients and
     --+             : the specific data value;
     --+
     --+  Arguments  ; CONSTANT Coefficients : PolynomialCoeff; -- 4 coefficients
     --+             : CONSTANT SysTemp      : Temperature;     -- operating temp in degreesC;
     --+
     --+  Assumption : Temperature in "degreesC"
     --+
     --+  Example    :
     --+
     --+  Constant   tplh_a_y_delay : time := tplh_a_y (TimeMode) *
     --+                DeratingFactor ( Coefficients => SysTempDerateCoeff_lh,
     --+                                 SysTemp      => 25 degreesC
     --+                               );
     --+
     --+---------------------------------------------------------------------
        FUNCTION DeratingFactor ( CONSTANT Coefficients : PolynomialCoeff;
                                  CONSTANT SysTemp      : Temperature
                                ) RETURN REAL IS
            VARIABLE factor : REAL;
        BEGIN
            factor := Coefficients(3) * REAL(SysTemp/degreesC)**3 +
                      Coefficients(2) * REAL(SysTemp/degreesC)**2 +
                      Coefficients(1) * REAL(SysTemp/degreesC)    +
                      Coefficients(0) ;

            RETURN factor;

        END DeratingFactor;

     --+---------------------------------------------------------------------
     --+  Function   : DeratingFactor
     --+  Returns    : real
     --+  Purpose    : This function calculates a real value by evaluating
     --+             : the polynomial given the derating coefficients and
     --+             : the specific data value;
     --+
     --+  Arguments  ; CONSTANT Coefficients : PolynomialCoeff; -- 4 coefficients
     --+             : CONSTANT SysLoad      : Capacitance;     -- load in pf
     --+
     --+  Assumption : Capacitance in "pf"
     --+
     --+  Example    :
     --+
     --+  Constant   tplh_a_y_delay : time := tplh_a_y (TimeMode) *
     --+                DeratingFactor ( Coefficients => SysCapDerateCoeff_lh,
     --+                                 SysLoad      => 2.1 pf
     --+                               );
     --+
     --+---------------------------------------------------------------------
        FUNCTION DeratingFactor ( CONSTANT Coefficients : PolynomialCoeff;
                                  CONSTANT SysLoad      : Capacitance
                                ) RETURN REAL IS
            VARIABLE factor : REAL;
        BEGIN
            factor := Coefficients(3) * REAL(SysLoad/pf)**3 +
                      Coefficients(2) * REAL(SysLoad/pf)**2 +
                      Coefficients(1) * REAL(SysLoad/pf)    +
                      Coefficients(0) ;

            RETURN factor;

        END DeratingFactor;

     --+---------------------------------------------------------------------
     --+  Function   : DerateOutput
     --+  Returns    : array of two real numbers
     --+  Purpose    : This function returns a pair of real derating factors.
     --+             : One element of this pair of factors is the tr01 derating
     --+             : factor and the other element is the tr10 derating factor.
     --+             : Each of the elements of the returned array can be
     --+             : obtained by indexing into the returned array.
     --+             :
     --+             : This function basically performs the operation of six
     --+             : calls to the function DeratingFactors();
     --+             :
     --+  Arguments  :
     --+             : CONSTANT SysDerCoeff: DerateCoeffArray;-- System Derating Coefficients
     --+             : CONSTANT SysVoltage : Voltage;     -- operating voltage     of device
     --+             : CONSTANT SysTemp    : Temperature; -- operating temperature of device
     --+             : CONSTANT OutputLoad : Capacitance  -- capacitive load on output pin
     --+             :
     --+  Assumption : capacitance in pf., voltage in volts, temp in degreesC.
     --+
     --+  Example    :
     --+
     --+   Generic (
     --+             tplh_a1_y1 : ModeDelay := DefaultModeDelay
     --+           );
     --+
     --+   CONSTANT tplh_a1_y1_Delay : time :=
     --+                 tplh_a1_y1(TimeMode) *                       -- "TimeMode"      generic parameter
     --+                 DerateOutput (SysDerCoeff => SysCoeff,       -- Global constant record from the Std_SimFlags package
     --+                               SysVoltage  => DeviceVoltage,  -- "DeviceVoltage" generic parameter
     --+                               SysTemp     => DeviceTemp,     -- "DeviceTemp"    generic parameter
     --+                               OutputLoad  => Cload_y1        -- "Cload_y1"      generic parameter
     --+                              )(tr01);                        -- choose the low ->high transition
     --+---------------------------------------------------------------------
        FUNCTION DerateOutput (
                    CONSTANT SysDerCoeff: IN     DerateCoeffArray;-- Derating Coefficients
                    CONSTANT SysVoltage : IN     Voltage;     -- operating voltage
                    CONSTANT SysTemp    : IN     Temperature; -- operating temperature
                    CONSTANT OutputLoad : IN     Capacitance  -- capacitive load on output pin
                                        ) RETURN RealFactors IS

            VARIABLE FactorTPLH : REAL;
            VARIABLE FactorTPHL : REAL;
        BEGIN
            --------------------------------------------------------------------------
            -- Calculate third order derating for each parameter
            --------------------------------------------------------------------------
            FactorTPLH :=(SysDerCoeff(CapDerateCoeff_lh)(3)     * REAL(OutputLoad/pf)**3 +
                          SysDerCoeff(CapDerateCoeff_lh)(2)     * REAL(OutputLoad/pf)**2 +
                          SysDerCoeff(CapDerateCoeff_lh)(1)     * REAL(OutputLoad/pf)    +
                          SysDerCoeff(CapDerateCoeff_lh)(0)
                         ) *
                         (SysDerCoeff(TempDerateCoeff_lh)(3)    * REAL(SysTemp/degreesC)**3    +
                          SysDerCoeff(TempDerateCoeff_lh)(2)    * REAL(SysTemp/degreesC)**2    +
                          SysDerCoeff(TempDerateCoeff_lh)(1)    * REAL(SysTemp/degreesC)       +
                          SysDerCoeff(TempDerateCoeff_lh)(0)
                         ) *
                         (SysDerCoeff(VoltageDerateCoeff_lh)(3) * REAL(SysVoltage/v)**3 +
                          SysDerCoeff(VoltageDerateCoeff_lh)(2) * REAL(SysVoltage/v)**2 +
                          SysDerCoeff(VoltageDerateCoeff_lh)(1) * REAL(SysVoltage/v)    +
                          SysDerCoeff(VoltageDerateCoeff_lh)(0)
                         );
            FactorTPHL :=(SysDerCoeff(CapDerateCoeff_hl)(3)     * REAL(OutputLoad/pf)**3 +
                          SysDerCoeff(CapDerateCoeff_hl)(2)     * REAL(OutputLoad/pf)**2 +
                          SysDerCoeff(CapDerateCoeff_hl)(1)     * REAL(OutputLoad/pf)    +
                          SysDerCoeff(CapDerateCoeff_hl)(0)
                         ) *
                         (SysDerCoeff(TempDerateCoeff_hl)(3)    * REAL(SysTemp/degreesC)**3    +
                          SysDerCoeff(TempDerateCoeff_hl)(2)    * REAL(SysTemp/degreesC)**2    +
                          SysDerCoeff(TempDerateCoeff_hl)(1)    * REAL(SysTemp/degreesC)       +
                          SysDerCoeff(TempDerateCoeff_hl)(0)
                         ) *
                         (SysDerCoeff(VoltageDerateCoeff_hl)(3) * REAL(SysVoltage/v)**3 +
                          SysDerCoeff(VoltageDerateCoeff_hl)(2) * REAL(SysVoltage/v)**2 +
                          SysDerCoeff(VoltageDerateCoeff_hl)(1) * REAL(SysVoltage/v)    +
                          SysDerCoeff(VoltageDerateCoeff_hl)(0)
                         );

            RETURN ( FactorTPLH, FactorTPHL );
        END DerateOutput;

     --+---------------------------------------------------------------------
     --+  Function   : DerateOutput
     --+  Returns    : array of array of two real numbers
     --+  Purpose    : This function creates an array (indexed from 1 to
     --+               the outwidth) of real derating value pairs (tr01, tr10).
     --+               The purpose of this function is to modify by means
     --+               of a derating factor, any propagation delays expressed
     --+               in vectored notation.
     --+               For example, there may be an 8-bit output bus Q,
     --+               and a corresponding array of capacitive loads on that
     --+               bus, one for each bus subelement. This function will then
     --+               take each subelement cload, and along with the
     --+               temperature and voltage, calculate the rise and fall
     --+               derating factors which can then be multiplied by any
     --+               propagation delays to yield the post-back-annotated
     --+               propagation delay for that particular output pin.
     --+             :
     --+             :
     --+  Arguments  :
     --+                CONSTANT outwidth   : IN     INTEGER;           -- Number of elements in the output vector
     --+                CONSTANT SysDerCoeff: IN     DerateCoeffArray;      -- Derating Coefficients
     --+                CONSTANT SysVoltage : IN     Voltage;           -- operating voltage
     --+                CONSTANT SysTemp    : IN     Temperature;       -- operating temperature
     --+                CONSTANT OutputLoad : IN     CapacitanceVector  -- capacitive load on output pin
     --+             :
     --+  Assumption : capacitance in pf., voltage in volts, temp in degreesC.
     --+             : Overloaded for derating vector
     --+  Example    :
     --+
     --+
     --+  *** In the entity declare the generic parameters....
     --+
     --+   Generic (
     --+             tplh_a_Q : ModeDelayVector (7 downto 0 ) := (others => DefaultModeDelay);
     --+             cload_Q  : CapacitanceVector ( 7 downto 0 ) :=
     --+                             ( 7 => 1.2 pf,  -- output Q7 capacitive load
     --+                               6 => 1.7 pf,  -- output Q6 capacitive load
     --+                               5 => 1.4 pf,  -- output Q5 capacitive load
     --+                               4 => 1.0 pf,  -- output Q4 capacitive load
     --+                               3 => 1.3 pf,  -- output Q3 capacitive load
     --+                               2 => 1.0 pf,  -- output Q2 capacitive load
     --+                               1 => 1.2 pf,  -- output Q1 capacitive load
     --+                               0 => 1.0 pf   -- output Q0 capacitive load
     --+                             )
     --+           );
     --+
     --+  *** Now in the architecture declarative region, declare a constant
     --+  and process the derating during the elaboration phase...
     --+
     --+   CONSTANT tplh_a_Q_Delay : time_vector :=
     --+                 tplh_a_Q(TimeMode) *                         -- "TimeMode"      generic parameter
     --+                 DerateOutput (outwidth    => Q'length,       -- As long as the output bus
     --+                               SysDerCoeff => SysCoeff,       -- Global constant record from the Std_SimFlags package
     --+                               SysVoltage  => DeviceVoltage,  -- "DeviceVoltage" generic parameter
     --+                               SysTemp     => DeviceTemp,     -- "DeviceTemp"    generic parameter
     --+                               OutputLoad  => Cload_Q         --
     --+                              )(tr01);                        -- choose the low ->high transition
     --+
     --+   *** Then in your architecture statement part, you can use the
     --+   derated load as follows...
     --+
     --+   Y(0) <= foo ( a(0) ) after tplh_a_Q_delay(0);
     --+
     --+---------------------------------------------------------------------
        FUNCTION DerateOutput (
                    CONSTANT outwidth   : IN     INTEGER;
                    CONSTANT SysDerCoeff: IN     DerateCoeffArray;-- Derating Coefficients
                    CONSTANT SysVoltage : IN     Voltage;     -- operating voltage
                    CONSTANT SysTemp    : IN     Temperature; -- operating temperature
                    CONSTANT OutputLoad : IN     CapacitanceVector  -- capacitive load on output pin
                                        ) RETURN RealFactorsVector IS

--            ALIAS l_OutputLoad : CapacitanceVector(1 TO OutputLoad'LENGTH) IS OutputLoad;
-- mentor does not support aliases
            VARIABLE l_OutputLoad : CapacitanceVector(1 to OutputLoad'LENGTH) := OutputLoad;
            VARIABLE result : RealFactorsVector(1 TO outwidth);
            VARIABLE factors : RealFactors := (1.0, 1.0);
            VARIABLE n : INTEGER := 1;
        BEGIN
            IF (0 < OutputLoad'LENGTH ) THEN
                factors := DerateOutput ( SysDerCoeff, SysVoltage, SysTemp, l_OutputLoad(1) );
            END IF;

            FOR nres IN 1 TO outwidth LOOP
                result(nres) := factors;
                IF (n < OutputLoad'LENGTH) THEN
                    n := n + 1;
                    factors := DerateOutput ( SysDerCoeff, SysVoltage, SysTemp, l_OutputLoad(n) );
                END IF;
            END LOOP;

            RETURN result;
        END DerateOutput;

--+ ****************************************************************************
--+  Wire Delay Utilities
--+ ****************************************************************************
     --------------------------------------------------------------------------
     -- Wire delays are modeled as a pair of rising/falling delay values per
     -- port. The modeler is required to declare a generic parameter for the
     -- wire delay paths in either one of two formats depending on whether the
     -- port is scalar or a vector.
     --
     -- Generic (
     --           Pathdelay_clk : DelayPair := DefaultDelayPair;   -- scalar
     --           Pathdelay_abus: DelayPairVector                  -- vector
     --         );
     --
     --------------------------------------------------------------------------
     --+---------------------------------------------------------------------
     --+ Procedure  : AssignPathDelay
     --+ Purpose    : 1. Optionally Strips off the strength yielding just U,X,0,1 values
     --+              2. TRANSPORT assigns the SignalIn value to the SignalOut
     --+                 signal with either tp01 or tp10 delay
     --+              3. No assignment takes place if the signal has not
     --+                 changed state.
     --+
     --+ Arguments  : SIGNAL    SignalOut     : OUT std_ulogic;
     --+              CONSTANT  newval        :  IN std_ulogic;
     --+              CONSTANT  oldval        :  IN std_ulogic;
     --+              CONSTANT  PathDelay     :  IN DelayPair;
     --+              CONSTANT  StripStrength :  IN BOOLEAN
     --+ Arguments  : SIGNAL    SignalOut     : OUT std_ulogic_vector;
     --+              CONSTANT  newval        :  IN std_ulogic_vector;
     --+              CONSTANT  oldval        :  IN std_ulogic_vector;
     --+              CONSTANT  PathDelay     :  IN DelayPairVector;
     --+              CONSTANT  StripStrength :  IN BOOLEAN
     --+ Arguments  : SIGNAL    SignalOut     : OUT std_logic_vector;
     --+              CONSTANT  newval        :  IN std_logic_vector;
     --+              CONSTANT  oldval        :  IN std_logic_vector;
     --+              CONSTANT  PathDelay     :  IN DelayPairVector;
     --+              CONSTANT  StripStrength :  IN BOOLEAN
     --+
     --+ Assumption : none
     --+
     --+ Example for scalar signals :
     --+
     --+ First, declare a generic parameter for the wire delay path
     --+ of each input signal...
     --+
     --+ Generic (
     --+           Pathdelay_d : DelayPair := DefaultDelayPair; -- input path delay for d
     --+           Pathdelay_abus: DelayPairVector := (others => DefaultDelayPair) -- vector
     --+         );
     --+
     --+ Then in the architecture declaration section, declare an internal
     --+ signal corresponding to the delayed input signal...
     --+
     --+ SIGNAL d_internal : std_logic;
     --+ SIGNAL abus_internal : std_logic_vector ( abus'length-1 downto 0 );
     --+
     --+ Now, in the architecture body, use this procedure as a
     --+ "concurrent procedure" to assign the wire delay to the
     --+ internal signal, thereby pre-delaying the signal.
     --+
     --+ AssignPathDelay ( SignalOut     => d_internal,
     --+                   newval        => d,
     --+                   oldval        => d'last_value,
     --+                   PathDelay     => PathDelay_d,
     --+                   StripStrength =>  TRUE );
     --+
     --+ AssignPathDelay ( SignalOut     => abus_internal,
     --+                   newval        => abus,
     --+                   oldval        => abus'last_value,
     --+                   PathDelay     => PathDelay_abus,
     --+                   StripStrength =>  TRUE );
     --+
     --+---------------------------------------------------------------------
     PROCEDURE AssignPathDelay ( SIGNAL   SignalOut     : OUT   std_ulogic; -- name of path delayed signal
                                 CONSTANT newval        : IN    std_ulogic;
                                 CONSTANT oldval        : IN    std_ulogic;
                                 CONSTANT PathDelay     : IN    DelayPair;
                                 CONSTANT StripStrength : IN    BOOLEAN
                               )  IS

            VARIABLE sigval     : std_ulogic;
            VARIABLE lastval    : std_ulogic := oldval;

            TYPE logic_UX01_table IS ARRAY (std_ulogic'LOW TO std_ulogic'HIGH) OF UX01;
            CONSTANT cvt_to_UX01 : logic_UX01_table := ('U','X','0','1','X','X','0','1','X');

     BEGIN

            IF (NOW = 0 ns) THEN lastval := 'U'; END IF;

            sigval := newval;
            IF StripStrength THEN sigval := cvt_to_UX01 ( newval ); END IF;

            IF lastval = sigval
                THEN NULL;
            ELSIF (sigval = '1')
                THEN SignalOut <= TRANSPORT sigval AFTER PathDelay ('1');
            ELSIF (sigval = '0')
                THEN SignalOut <= TRANSPORT sigval AFTER PathDelay ('0');
            ELSIF (lastval = '1')
                THEN SignalOut <= TRANSPORT sigval AFTER PathDelay ('1');
            ELSIF (lastval = '0')
                THEN SignalOut <= TRANSPORT sigval AFTER PathDelay ('0');
            ELSE
                     SignalOut <= TRANSPORT sigval AFTER MINIMUM (PathDelay ('0'),PathDelay ('1'));
            END IF;

     END AssignPathDelay;
     --+---------------------------------------------------------------------
     PROCEDURE AssignPathDelay ( SIGNAL   SignalOut     : OUT   std_ulogic_vector; -- name of path delayed signal
                                 CONSTANT newval        : IN    std_ulogic_vector;
                                 CONSTANT oldval        : IN    std_ulogic_vector;
                                 CONSTANT PathDelay     : IN    DelayPairVector;
                                 CONSTANT StripStrength : IN    BOOLEAN
                               ) IS

            VARIABLE sigval      : std_ulogic_vector (SignalOut'RANGE);
            VARIABLE lastval     : std_ulogic_vector (SignalOut'RANGE) := oldval;
            -- ALIAS    a_PathDelay : DelayPairVector   (SignalOut'RANGE) IS PathDelay;
            -- mentor does not support aliases
            Variable a_PathDelay : DelayPairVector(SignalOut'RANGE) := PathDelay;


            TYPE logic_UX01_table IS ARRAY (std_ulogic'LOW TO std_ulogic'HIGH) OF UX01;
            CONSTANT cvt_to_UX01 : logic_UX01_table := ('U','X','0','1','X','X','0','1','X');

     BEGIN
            ---------------------------------------------------------------
            -- Note : no error traps were designed in to catch mismatched
            -- lengths... In any event, the runtime bound checking "should"
            -- find this out
            ---------------------------------------------------------------
            IF (NOW = 0 ns) THEN lastval := (OTHERS => 'U'); END IF;

            sigval := newval;
            IF StripStrength THEN
                FOR i IN sigval'RANGE LOOP
                    sigval(i) := cvt_to_UX01 ( sigval(i) );
                END LOOP;
            END IF;

            FOR n IN SignalOut'RANGE LOOP
                IF lastval(n) = sigval(n)
                    THEN NULL;
                ELSIF (sigval(n) = '1')
                    THEN SignalOut(n) <= TRANSPORT sigval(n) AFTER a_PathDelay(n)('1');
                ELSIF (sigval(n) = '0')
                    THEN SignalOut(n) <= TRANSPORT sigval(n) AFTER a_PathDelay(n)('0');
                ELSIF (lastval(n) = '1')
                    THEN SignalOut(n) <= TRANSPORT sigval(n) AFTER a_PathDelay(n)('1');
                ELSIF (lastval(n) = '0')
                    THEN SignalOut(n) <= TRANSPORT sigval(n) AFTER a_PathDelay(n)('0');
                ELSE
                         SignalOut(n) <= TRANSPORT sigval(n) AFTER MINIMUM (a_PathDelay(n)('0'),a_PathDelay(n)('1'));
                END IF;
            END LOOP;

     END AssignPathDelay;
     --+---------------------------------------------------------------------
     PROCEDURE AssignPathDelay ( SIGNAL   SignalOut     : OUT   std_logic_vector; -- name of path delayed signal
                                 CONSTANT newval        : IN    std_logic_vector;
                                 CONSTANT oldval        : IN    std_logic_vector;
                                 CONSTANT PathDelay     : IN    DelayPairVector;
                                 CONSTANT StripStrength : IN    BOOLEAN
                               ) IS

            VARIABLE sigval      : std_logic_vector (SignalOut'RANGE);
            VARIABLE lastval     : std_logic_vector (SignalOut'RANGE) := oldval;
            --ALIAS    a_PathDelay : DelayPairVector   (SignalOut'RANGE) IS PathDelay;
            -- mentor does not support aliases
            Variable a_PathDelay : DelayPairVector(SignalOut'RANGE) := PathDelay;
            

            TYPE logic_UX01_table IS ARRAY (std_ulogic'LOW TO std_ulogic'HIGH) OF UX01;
            CONSTANT cvt_to_UX01 : logic_UX01_table := ('U','X','0','1','X','X','0','1','X');

     BEGIN
            ---------------------------------------------------------------
            -- Note : no error traps were designed in to catch mismatched
            -- lengths... In any event, the runtime bound checking "should"
            -- find this out
            ---------------------------------------------------------------
            IF (NOW = 0 ns) THEN lastval := (OTHERS => 'U'); END IF;

            sigval := newval;
            IF StripStrength THEN
                FOR i IN sigval'RANGE LOOP
                    sigval(i) := cvt_to_UX01 ( sigval(i) );
                END LOOP;
            END IF;

            FOR n IN SignalOut'RANGE LOOP
                IF lastval(n) = sigval(n)
                    THEN NULL;
                ELSIF (sigval(n) = '1')
                    THEN SignalOut(n) <= TRANSPORT sigval(n) AFTER a_PathDelay(n)('1');
                ELSIF (sigval(n) = '0')
                    THEN SignalOut(n) <= TRANSPORT sigval(n) AFTER a_PathDelay(n)('0');
                ELSIF (lastval(n) = '1')
                    THEN SignalOut(n) <= TRANSPORT sigval(n) AFTER a_PathDelay(n)('1');
                ELSIF (lastval(n) = '0')
                    THEN SignalOut(n) <= TRANSPORT sigval(n) AFTER a_PathDelay(n)('0');
                ELSE
                         SignalOut(n) <= TRANSPORT sigval(n) AFTER MINIMUM (a_PathDelay(n)('0'),a_PathDelay(n)('1'));
                END IF;
            END LOOP;

     END AssignPathDelay;


--+ ****************************************************************************
--+  Delay parameter calculation Utilities
--+ ****************************************************************************
     --+---------------------------------------------------------------------------
     --+  Function   : BaseIncrToTime
     --+  Returns    : time
     --+  Purpose    : Converts Base + Increment to nanoseconds
     --+  Arguments  : CONSTANT   BIDelay -- Base , Increment
     --+             : CONSTANT    Cload  -- capacitive load
     --+  Assumption : 1. Base Delay is expressed in ns/pf (type TIME)
     --+             : 2. Incremental Delay is expressed in nanoseconds
     --+             : 3. Capacitive load is expressed in picofarad
     --+  Example    :
     --+
     --+   CONSTANT Tp01_a1_y1 : time
     --+                 := BaseIncrToTime (tphllh_a1_y1(TimeMode), Cload_y1);
     --+---------------------------------------------------------------------------
        FUNCTION BaseIncrToTime (
                    CONSTANT BIDelay    : IN     BaseIncrDlyPair;
                    CONSTANT CLoad      : IN     Capacitance
                                        ) RETURN TIME IS

            VARIABLE result : TIME;
        BEGIN
            result := ((BIDelay(IncrDly) * (CLoad/ffd)) / (pf/ffd))
                        + BIDelay(BaseDly);
            RETURN result; -- returns nanoseconds
        END BaseIncrToTime;
     --+---------------------------------------------------------------------------
     --+  Function   : BaseIncrToMinTypMaxTime
     --+  Returns    : time
     --+  Purpose    : Converts BaseIncr to MinTypMaxTime format
     --+  Arguments  : CONSTANT   BIDelay -- Base , Increment Vector
     --+             : CONSTANT    Cload  -- capacitive load
     --+  Assumption : 1. Base Delay is expressed in ns/pf (type TIME)
     --+             : 2. Incremental Delay is expressed in nanoseconds
     --+             : 3. Capacitive load is expressed in picofarad
     --+  Example    :
     --+
     --+   CONSTANT Tp01_a1_y1 : time
     --+                 := BaseIncrToMinTypMaxTime (tphl_a1_y1, Cload_y1);
     --+---------------------------------------------------------------------------
        FUNCTION BaseIncrToMinTypMaxTime (
                    CONSTANT BIDelay    : IN     BaseIncrDelay;
                    CONSTANT CLoad      : IN     Capacitance
                                        ) RETURN MinTypMaxTime IS

            VARIABLE result : MinTypMaxTime;
        BEGIN
            result(t_minimum) := ((BIDelay(t_minimum)(IncrDly) * (CLoad/ffd)) / (pf/ffd))
                                 + BIDelay(t_minimum)(BaseDly);
            result(t_typical) := ((BIDelay(t_typical)(IncrDly) * (CLoad/ffd)) / (pf/ffd))
                                 + BIDelay(t_typical)(BaseDly);
            result(t_maximum) := ((BIDelay(t_maximum)(IncrDly) * (CLoad/ffd)) / (pf/ffd))
                                 + BIDelay(t_maximum)(BaseDly);
            result(t_special) := ((BIDelay(t_special)(IncrDly) * (CLoad/ffd)) / (pf/ffd))
                                 + BIDelay(t_special)(BaseDly);
            RETURN result;
        END BaseIncrToMinTypMaxTime;

--+ ****************************************************************************
--+  Output Assignment with propagation Delay (+ out wire delay)
--+ ****************************************************************************
    ----------------------------------------------------------------------------
    -- CASE 1 : Simple Assignments
    ----------------------------------------------------------------------------
    -- In the simple case, we wish to assign an output with a delay which is
    -- based upon the OUTPUT value transitioning from its old value to its new value
    ----------------------------------------------------------------------------
    --+ ---------------------------------------------------------------------
    --+ Function   : CalcDelay
    --+ Returns    : time
    --+ Purpose    : This function determines the proper value of delay to
    --+            : use given the newly assigned value and the existing
    --+            : value on the signal or driver.
    --+            :
    --+ Overloading: This function is overloaded to provide a means of
    --+            : specifying the delays in concise or verbose mode.
    --+            :
    --+ Arguments  : See the declarations below...
    --+            :
    --+ Defaults   : For the verbose form, not all of the parameters need
    --+            : to be passed since defaults are provided for those
    --+            : not passed.
    --+
    --+ Assumption : newval'length = oldval'length for vectored signals
    --+
    --+
    --+ Example :
    --+
    --+    In this example, we don't care what the old value is, hence the function
    --+    will make the determination of which delay to select based upon the new
    --+    value only.
    --+
    --+    y <= the_new_value AFTER CalcDelay ( newval => the_new_value,
    --+                                         oldval => '-',
    --+                                         tp01   => tplh_a_y,
    --+                                         tp10   => tphl_a_y
    --+                                         -- in this example the remaining
    --+                                         -- parameters are not specified
    --+                                       );
    --+
    --+ --------------------------------------------------------------------------
------------------------------------------------------------------------
    FUNCTION CalcDelay (
                         CONSTANT    newval : IN std_ulogic;        -- new value of signal
                         CONSTANT    oldval : IN std_ulogic;        -- old value of signal
                         CONSTANT    Tp01   : IN TIME := UnitDelay; -- 0->1 delay value
                         CONSTANT    Tp10   : IN TIME := UnitDelay; -- 1->0 delay value
                         CONSTANT    tp0z   : IN TIME := UnitDelay; -- 0->z delay value
                         CONSTANT    tp1z   : IN TIME := UnitDelay; -- 1->z delay value
                         CONSTANT    tpz0   : IN TIME := UnitDelay; -- z->0 delay value
                         CONSTANT    tpz1   : IN TIME := UnitDelay  -- z->1 delay value
                       ) RETURN TIME IS

        VARIABLE result : TIME;

    BEGIN
        CASE oldval IS
          WHEN '0' |
               'L'  =>  CASE newval IS
                            WHEN '0' |
                                 'L'    => result := tp10;
                            WHEN '1' |
                                 'H'    => result := tp01;
                            WHEN 'Z'    => result := tp0z;
                            WHEN OTHERS => result := MINIMUM(tp01, tp0z);
                        END CASE;
          WHEN '1' |     
               'H'  =>  CASE newval IS
                            WHEN '0' |
                                 'L'    => result := tp10;
                            WHEN '1' |
                                 'H'    => result := tp01;
                            WHEN 'Z'    => result := tp1z;
                            WHEN OTHERS => result := MINIMUM(tp10, tp1z);
                        END CASE;
          WHEN 'Z'  =>  CASE newval IS
                            WHEN '0' |
                                 'L'    => result := tpz0;
                            WHEN '1' |
                                 'H'    => result := tpz1;
                            WHEN 'Z'    => result := MAXIMUM (tp0z, tp1z);
                            WHEN OTHERS => result := MINIMUM (tpz1, tpz0);
                        END CASE;
          WHEN 'U' |
               'X' |
               'W' |
               '-'  =>  CASE newval IS
                            WHEN '0' |
                                 'L'    => result := MAXIMUM(tp10, tpz0);
                            WHEN '1' |
                                 'H'    => result := MAXIMUM(tp01, tpz1);
                            WHEN 'Z'    => result := MAXIMUM(tp1z, tp0z);
                            WHEN OTHERS => result := MAXIMUM(tp10, tp01);
                        END CASE;
          END CASE;
	  return result;
    END CalcDelay;
    --+ --------------------------------------------------------------------------
    FUNCTION CalcDelay (
                         CONSTANT    value  : IN std_ulogic;        -- new value of signal
                         CONSTANT    Tp1    : IN TIME := UnitDelay; -- 0->1 delay value
                         CONSTANT    Tp0    : IN TIME := UnitDelay  -- 1->0 delay value
                       ) RETURN TIME IS

        VARIABLE result : TIME;

    BEGIN
        result := CalcDelay ( newval => value,
		 	      oldval => '-',
			      Tp01   => tp1,
			      Tp10   => tp0,
			      tp0z   => tp1,
			      tp1z   => tp0,
			      tpz0   => tp0,
			      tpz1   => tp1 );
        RETURN result;
    END CalcDelay;
    
------------------------------------------------------------------------
    FUNCTION CalcDelay (
                         CONSTANT    value  : IN std_logic_vector;  -- new value of signal
                         CONSTANT    Tp1    : IN TIME := UnitDelay; -- 0->1 delay value
                         CONSTANT    Tp0    : IN TIME := UnitDelay  -- 1->0 delay value
                       ) RETURN TIME_Vector IS
        -- ALIAS a_value  : std_logic_vector ( 1 TO value'LENGTH ) IS value;
        -- mentor does not support aliases
        VARIABLE a_value : std_logic_vector(1 TO value'LENGTH) := value;
        VARIABLE result : TIME_Vector ( 1 TO value'LENGTH );
    BEGIN
        FOR i IN 1 TO value'LENGTH LOOP
            result(i) := CalcDelay ( value => a_value(i),
                                     Tp1   => Tp1,
                                     Tp0   => Tp0 );
        END LOOP;
        RETURN result;
    END CalcDelay;

------------------------------------------------------------------------
    FUNCTION CalcDelay (
                         CONSTANT    value  : IN std_ulogic_vector;  -- new value of signal
                         CONSTANT    Tp1    : IN TIME := UnitDelay; -- 0->1 delay value
                         CONSTANT    Tp0    : IN TIME := UnitDelay  -- 1->0 delay value
                       ) RETURN TIME_Vector IS
        -- ALIAS a_value  : std_ulogic_vector ( 1 TO value'LENGTH ) IS value;
        -- mentor does not support aliases
        VARIABLE a_value : std_ulogic_vector(1 TO value'LENGTH) := value;
        
        VARIABLE result : TIME_Vector ( 1 TO value'LENGTH );
    BEGIN
        FOR i IN 1 TO value'LENGTH LOOP
            result(i) := CalcDelay ( value => a_value(i),
                                     Tp1   => Tp1,
                                     Tp0   => Tp0 );
        END LOOP;
        RETURN result;
    END CalcDelay;

    ------------------------------------------------------------------------
    FUNCTION CalcDelay (
                         CONSTANT    newval : IN std_logic_vector;  -- new value of signal
                         CONSTANT    oldval : IN std_logic_vector;  -- old value of signal
                         CONSTANT    Tp01   : IN TIME := UnitDelay; -- 0->1 delay value
                         CONSTANT    Tp10   : IN TIME := UnitDelay; -- 1->0 delay value
                         CONSTANT    tp0z   : IN TIME := UnitDelay; -- 0->z delay value
                         CONSTANT    tp1z   : IN TIME := UnitDelay; -- 1->z delay value
                         CONSTANT    tpz0   : IN TIME := UnitDelay; -- z->0 delay value
                         CONSTANT    tpz1   : IN TIME := UnitDelay  -- z->1 delay value
                       ) RETURN TIME_Vector IS
        -- ALIAS a_newval  : std_logic_vector ( 1 TO newval'LENGTH ) IS newval;
        -- ALIAS a_oldval  : std_logic_vector ( 1 TO oldval'LENGTH ) IS oldval;
        -- mentor does not support aliases
        VARIABLE a_newval : std_logic_vector(1 TO newval'LENGTH) := newval;
        VARIABLE a_oldval : std_logic_vector(1 TO oldval'LENGTH) := oldval;
        VARIABLE result : TIME_Vector ( 1 TO newval'LENGTH );
    BEGIN
        FOR i IN 1 TO newval'LENGTH LOOP
            result(i) := CalcDelay ( newval => a_newval(i),
                                     oldval => a_oldval(i),
                                     Tp01   => Tp01,
                                     Tp10   => Tp10,
                                     tp0z   => tp0z,
                                     tp1z   => tp1z,
                                     tpz0   => tpz0,
                                     tpz1   => tpz1 );
        END LOOP;
        RETURN result;
    END CalcDelay;
    ------------------------------------------------------------------------
    FUNCTION CalcDelay (
                         CONSTANT    newval : IN std_ulogic_vector;  -- new value of signal
                         CONSTANT    oldval : IN std_ulogic_vector;  -- old value of signal
                         CONSTANT    Tp01   : IN TIME := UnitDelay; -- 0->1 delay value
                         CONSTANT    Tp10   : IN TIME := UnitDelay; -- 1->0 delay value
                         CONSTANT    tp0z   : IN TIME := UnitDelay; -- 0->z delay value
                         CONSTANT    tp1z   : IN TIME := UnitDelay; -- 1->z delay value
                         CONSTANT    tpz0   : IN TIME := UnitDelay; -- z->0 delay value
                         CONSTANT    tpz1   : IN TIME := UnitDelay  -- z->1 delay value
                       ) RETURN TIME_Vector IS
        -- ALIAS a_newval  : std_ulogic_vector ( 1 TO newval'LENGTH ) IS newval;
        -- ALIAS a_oldval  : std_ulogic_vector ( 1 TO oldval'LENGTH ) IS oldval;
        -- mentor does not support aliases
        VARIABLE a_newval : std_ulogic_vector(1 TO newval'LENGTH) := newval;
        VARIABLE a_oldval : std_ulogic_vector(1 TO oldval'LENGTH) := oldval;
        VARIABLE result : TIME_Vector ( 1 TO newval'LENGTH );
    BEGIN
        FOR i IN 1 TO newval'LENGTH LOOP
            result(i) := CalcDelay ( newval => a_newval(i),
                                     oldval => a_oldval(i),
                                     Tp01   => Tp01,
                                     Tp10   => Tp10,
                                     tp0z   => tp0z,
                                     tp1z   => tp1z,
                                     tpz0   => tpz0,
                                     tpz1   => tpz1 );
        END LOOP;
        RETURN result;

    END CalcDelay;

--+ ****************************************************************************
--+ VIOLATION WATCHDOGS
--+ ****************************************************************************

 --+ -----------------------------------------------------------------
 --+  Function  Name : TimingViolation
 --+      parameters :
 --+         IN      : TestPort       -- SIGNAL    std_logic
 --+         IN      : TestPortName   -- CONSTANT  string
 --+         IN      : RefPort        -- SIGNAL    std_logic
 --+         IN      : RefPortName    -- CONSTANT  string
 --+         IN      : t_setup_hi     -- CONSTANT  time
 --+         IN      : t_setup_lo     -- CONSTANT  time
 --+         IN      : t_hold_hi      -- CONSTANT  time
 --+         IN      : t_hold_lo      -- CONSTANT  time
 --+         IN      : condition      -- CONSTANT  boolean
 --+         IN      : HeaderMsg      -- CONSTANT  string
 --+	     IN	     : WarningsOn     -- CONSTANT  boolean
 --+
 --+  Returns : Boolean;  TRUE if a timing violation occurred
 --+
 --+  Assumption : For the vector overloaded function, it is
 --+               assumed that the value of the timing specifications
 --+               apply to all of the subelements of the Test port
 --+
 --+               Any change in the value of "RefPort" when "condition"
 --+               is TRUE is considered a triggering edge. This includes
 --+               changes only in the Strength of "RefPort".
 --+
 --+     Notes       :
 --+       In the formal parameter list of this routine, both the test
 --+       and reference signals are referenced along with their string
 --+       names.
 --+             _____________         ____________
 --+             _____________XXXXXXXXX____________XXXXXXXX  test signal
 --+             ____________________________
 --+                                         \_____________  ref signal
 --+                                      -->|     |<--- t_hold
 --+                               --->|     |<-----     t_setup
 --+
 --+             ___         ____________
 --+             ___XXXXXXXXX____________XXXXXXXXXXXXXX  test signal
 --+             ____________________________
 --+                                         \_________  ref signal
 --+                                  -->|***|<--  t_hold (negative)
 --+                     --->|               |<--  t_setup
 --+
 --+             _______________________         ____________
 --+             _______________________XXXXXXXXX____________XXXX  test signal
 --+             ____________________________
 --+                                         \___________________  ref signal
 --+                              t_hold  -->|               |<--
 --+                  (negative) t_setup  -->|  |<--
 --+
 --+ ---------------------------------------------------------------------------
 --+
 --+       t_setup_hi ::= minimum interval preceeding the triggering edge
 --+                      of the referenced signal for the high logic level
 --+                      data to latch in. Defaults to 0 ns.
 --+
 --+       t_setup_lo ::= minimum interval preceeding the triggering edge
 --+                      of the referenced signal for the low logic level
 --+                      data to latch in. Defaults to 0 ns.
 --+
 --+       t_hold_hi ::= minimum interval the high logic level input data
 --+                     must remain at its latching level after the active
 --+                     edge of the clock. Defaults to 0 ns.
 --+
 --+       t_hold_lo ::= minimum interval the low  logic level input data
 --+                     must remain at its latching level after the active
 --+                     edge of the clock. Defaults to 0 ns.
 --+
 --+       *** >>> Signal changes within the negative hold time are reported
 --+               as Possible errors. This signal change will hide any True
 --+               setup violations (within the setup time).
 --+
 --+       A high pulse with (width < t_hold_hi - t_hold_lo) or a low
 --+       pulse with (with < t_hold_lo - t_hold_hi) may generate a 
 --+       false HOLD violation.
 --+
 --+      USE        :
 --+
 --+       if TimingViolation    (
 --+                               TestPort       => D,     -- Data line
 --+                               TestPortName   => "D",   -- string
 --+                               RefPort        => CLK,   -- CLK signal
 --+                               RefPortName    => "CLK",
 --+                               t_setup_hi     => 23 ns,
 --+                               t_setup_lo     => 23 ns,
 --+                               t_hold_hi      => 5 ns,
 --+                               t_hold_lo      => 6 ns,
 --+                               condition      => (CLK = '1'),
 --+                               HeaderMsg      => InstanceHeader
 --+                             ) then
 --+           Q <= 'X';
 --+       END IF;
 --+
 --+ -----------------------------------------------------------------
    FUNCTION TimingViolation (
                SIGNAL   TestPort     : IN     std_ulogic;     -- SIGNAL being tested
                CONSTANT TestPortName : IN     STRING := "";   -- name OF the signal
                SIGNAL   RefPort      : IN     std_ulogic;     -- SIGNAL being referenced
                CONSTANT RefPortName  : IN     STRING := "";   -- name OF the ref signal
                CONSTANT t_setup_hi   : IN     TIME := 0 ns;   -- setup spec FOR test PORT = '1'
                CONSTANT t_setup_lo   : IN     TIME := 0 ns;   -- setup spec FOR test PORT = '0'
                CONSTANT t_hold_hi    : IN     TIME := 0 ns;   -- hold spec FOR test PORT = '1'
                CONSTANT t_hold_lo    : IN     TIME := 0 ns;   -- hold spec FOR test PORT = '0'
                CONSTANT condition    : IN     BOOLEAN;        -- true ==> spec checked.
                CONSTANT HeaderMsg    : IN     STRING := " ";
		CONSTANT WarningsOn   : IN     BOOLEAN := TRUE -- IF TRUE assertions are generated
                                      ) RETURN BOOLEAN IS

        VARIABLE Violation     : BOOLEAN := FALSE;
        VARIABLE observed_time : TIME;
        VARIABLE expected_time : TIME;
        VARIABLE constrnt_time : TIME;
        VARIABLE TestX01       : X01;
    BEGIN

    -- note : additional error checking can be coded regarding the defaulting of
    --        t_setup_lo or t_setup_hi such that one or the other could be used to
    --        specify the setup condition, however, IN the interest OF some code
    --        efficiency, the code was not provided. IF the ultimate protection
    --        IS  required, it can be written.
        IF condition AND (NOW > 0 ns) THEN
            -- -----------------------------------------------------------------
            -- Active edge of reference signal - check setup time
            -- -----------------------------------------------------------------
            IF RefPort'EVENT THEN
                TestX01 := To_X01(TestPort);
                IF (TestX01 = '1') THEN
                    expected_time :=  t_setup_hi;
                    constrnt_time := -t_hold_hi;
                ELSIF (TestX01 = '0') THEN
                    expected_time :=  t_setup_lo;
                    constrnt_time := -t_hold_lo;
                ELSE
                    expected_time := MINIMUM ( t_setup_lo,  t_setup_hi);
                    constrnt_time := MINIMUM (-t_hold_lo , -t_hold_hi ); -- bug fix 8/24/95
                END IF; -- setup was violated
                observed_time := TestPort'LAST_EVENT;
                --------------------------------------------------------------------
                -- some sort of setup violation occurred
                --------------------------------------------------------------------
                IF (observed_time < expected_time) THEN
                    Violation := TRUE;
                    IF (observed_time < constrnt_time) THEN
                        ------------------------------------------------------------
                        -- Test signal change within negative hold window
                        ------------------------------------------------------------
                        report_possible_error (
                                        HeaderMsg, "SETUP ", TestX01,
                                        TestPortName, RefPortName,
                                        expected_time, observed_time,
                                        constrnt_time, WarningsOn );
                    ELSIF (To_X01(TestPort'LAST_VALUE) = TestX01) THEN
                        ------------------------------------------------------------
                        -- the "state" did not change, only the strength did
                        ------------------------------------------------------------
                        report_soft_error (
                                        HeaderMsg, "SETUP ", TestX01,
                                        TestPortName, RefPortName,
                                        expected_time, observed_time,
                                        TestPort'LAST_VALUE, TestPort,
					WarningsOn );
                    ELSE
                        ------------------------------------------------------------
                        -- the "state" changed ( hard ) violation
                        ------------------------------------------------------------
                        report_error (  HeaderMsg, "SETUP ", TestX01,
                                        TestPortName, RefPortName,
                                        expected_time, observed_time,
					WarningsOn );
                    END IF;
                END IF;
            --------------------------------------------------------------------
            -- test signal change 
            -- Note: If time to previous TestPort change was available, only the
            --       first hold violation could be reported - but alas.
            --------------------------------------------------------------------
            ELSIF TestPort'EVENT THEN
                TestX01 := To_X01(TestPort'LAST_VALUE);
                IF    (TestX01 = '1') THEN
                    expected_time := t_hold_hi;
                    constrnt_time := -t_setup_hi;
                ELSIF (TestX01 = '0') THEN
                    expected_time := t_hold_lo;
                    constrnt_time := -t_setup_lo;
                ELSE
                    expected_time := MINIMUM (t_hold_lo, t_hold_hi);
                    constrnt_time := MINIMUM (-t_setup_lo , -t_setup_hi ); -- bug fix 8/24/95
                END IF;
                observed_time := RefPort'LAST_EVENT;
                ----------------------------------------------------------------
                -- some sort of hold violation occurred
                -- violation = hold_violation  AND
                --             violation not in negative setup window   AND
                ----------------------------------------------------------------
                IF (observed_time < expected_time) AND 
                   (observed_time > constrnt_time)
                THEN
                    Violation := TRUE;
                    IF TestX01 = To_X01(TestPort) THEN
                        --------------------------------------------------------
                        -- the "state" did not change, only the strength did
                        --------------------------------------------------------
                        report_soft_error (
                                    HeaderMsg, "HOLD  ", TestX01,
                                    TestPortName, RefPortName,
                                    expected_time, observed_time,
                                    TestPort'LAST_VALUE, TestPort,
				    WarningsOn );
                    ELSE
                        --------------------------------------------------------
                        -- the "state" changed ( hard ) violation
                        --------------------------------------------------------
                        report_error (
                                    HeaderMsg, "HOLD  ", TestX01,
                                    TestPortName, RefPortName,
                                    expected_time, observed_time,
				    WarningsOn );
                    END IF;
                END IF; -- Violation
            END IF;
        END IF; -- condition and NOW > 0 ns;
        RETURN (Violation);
    END TimingViolation;
 --+ ---------------------------------------------------------------------------
 --+  Procedure  Name : TimingCheck
 --+      parameters :
 --+         IN      : TestPort          -- SIGNAL    std_logic_vector
 --+         IN      : TestPortName	 -- CONSTANT  string
 --+         IN      : RefPort		 -- SIGNAL    std_logic
 --+         IN      : RefPortName	 -- CONSTANT  string
 --+         IN      : t_setup_hi	 -- CONSTANT  time
 --+         IN      : t_setup_lo	 -- CONSTANT  time
 --+         IN      : t_hold_hi	 -- CONSTANT  time
 --+         IN      : t_hold_lo	 -- CONSTANT  time
 --+         IN      : condition         -- CONSTANT  boolean
 --+         IN      : HeaderMsg         -- CONSTANT  string
 --+         INOUT   : TestPortLastEvent -- VARIABLE  TIME_vector
 --+         INOUT   : Violation         -- VARIABLE  boolean
 --+	     IN	     : WarningsOn	 -- CONSTANT  boolean
 --+
 --+
 --+  Assumption : For the vector overloaded function, it is
 --+               assumed that the value of the timing specifications
 --+               apply to all of the subelements of the Test port
 --+
 --+               Any change in the value of "RefPort" when "condition"
 --+               is TRUE is considered a triggering edge. This includes
 --+               changes only in the Strength of "RefPort".
 --+
 --+     Notes       :
 --+       In the formal parameter list of this routine, both the test
 --+       and reference signals are referenced along with their string
 --+       names.
 --+             _____________         ____________
 --+             _____________XXXXXXXXX____________XXXXXXXX  test signal
 --+             ____________________________
 --+                                         \_____________  ref signal
 --+                                      -->|     |<--- t_hold
 --+                               --->|     |<-----     t_setup
 --+
 --+             ___         ____________
 --+             ___XXXXXXXXX____________XXXXXXXXXXXXXX  test signal
 --+             ____________________________
 --+                                         \_________  ref signal
 --+                                  -->|***|<--  t_hold (negative)
 --+                     --->|               |<--  t_setup
 --+
 --+             _______________________         ____________
 --+             _______________________XXXXXXXXX____________XXXX  test signal
 --+             ____________________________
 --+                                         \___________________  ref signal
 --+                              t_hold  -->|               |<--
 --+                  (negative) t_setup  -->|  |<--
 --+
 --+ ---------------------------------------------------------------------------
 --+
 --+       t_setup_hi ::= minimum interval preceeding the triggering edge
 --+                      of the referenced signal for the high logic level
 --+                      data to latch in. Defaults to 0 ns.
 --+
 --+       t_setup_lo ::= minimum interval preceeding the triggering edge
 --+                      of the referenced signal for the low logic level
 --+                      data to latch in. Defaults to 0 ns.
 --+
 --+       t_hold_hi ::= minimum interval the high logic level input data
 --+                     must remain at its latching level after the active
 --+                     edge of the clock. Defaults to 0 ns.
 --+
 --+       t_hold_lo ::= minimum interval the low  logic level input data
 --+                     must remain at its latching level after the active
 --+                     edge of the clock. Defaults to 0 ns.
 --+
 --+       *** >>> Signal changes within the negative hold time are reported
 --+               as Possible errors. This signal change will hide any True
 --+               setup violations (within the setup time).
 --+
 --+      Example :
 --+
 --+       PROCESS (clk, DataBus)
 --+           VARIABLE Violation : BOOLEAN := False;
 --+           VARIABLE DataBusLastEvent : TIME_vector (DataBus'RANGE) := (others => -1000 ns);
 --+           VARIABLE DataBusLastValue : std_logic_vector (DataBus'RANGE);
 --+       BEGIN
 --+
 --+           TimingCheck    (
 --+                           TestPort       => DataBus,
 --+                           TestPortName   => "DataBus",
 --+                           RefPort        => CLK,
 --+                           RefPortName    => "CLK",
 --+                           t_setup_hi     => 23 ns,
 --+                           t_setup_lo     => 23 ns,
 --+                           t_hold_hi      => 5 ns,
 --+                           t_hold_lo      => 6 ns,
 --+                           condition      => (CLK = '1'),
 --+                           HeaderMsg      => InstanceHeader,
 --+                           TestPortLastEvent => DataBusLastEvent,
 --+                           TestPortLastValue => DataBusLastValue,
 --+                           Violation      => Violation
 --+
 --+                          );
 --+           If Violation THEN
 --+               Q <= (OTHERS=>'X');
 --+           ELSE
 --+               Q <= DataBus;
 --+           END IF;
 --+       END PROCESS;
 --+
 --+ ---------------------------------------------------------------------------
    PROCEDURE TimingCheck (
            SIGNAL   TestPort          : IN     std_ulogic;     -- SIGNAL being tested
            CONSTANT TestPortName      : IN     STRING := "";	-- name OF the signal
            SIGNAL   RefPort           : IN     std_ulogic;	-- SIGNAL being referenced
            CONSTANT RefPortName       : IN     STRING := "";	-- name OF the ref signal
            CONSTANT t_setup_hi        : IN     TIME := 0 ns;	-- setup spec FOR test PORT = '1'
            CONSTANT t_setup_lo        : IN     TIME := 0 ns;	-- setup spec FOR test PORT = '0'
            CONSTANT t_hold_hi         : IN     TIME := 0 ns;	-- hold spec FOR test PORT = '1'
            CONSTANT t_hold_lo         : IN     TIME := 0 ns;	-- hold spec FOR test PORT = '0'
            CONSTANT condition         : IN     BOOLEAN;        -- true ==> spec checked.
            CONSTANT HeaderMsg         : IN     STRING := " ";
            VARIABLE Violation         : INOUT  BOOLEAN;
	    CONSTANT WarningsOn	       : IN	BOOLEAN := TRUE -- IF TRUE assertions are generated
                                       ) IS

        VARIABLE LocalViolation : BOOLEAN := FALSE;
    BEGIN
        LocalViolation := TimingViolation ( TestPort,     TestPortName,
                                            RefPort,      RefPortName,
                                            t_setup_hi,   t_setup_lo,
                                            t_hold_hi,    t_hold_lo,
                                            condition,
                                            HeaderMsg,    WarningsOn
                                          );
--        Violation := Violation OR LocalViolation;
        Violation := LocalViolation;
    END TimingCheck;

    --------------------------------------------------------------------
    PROCEDURE TimingCheck (
            SIGNAL   TestPort          : IN     std_logic_vector; -- SIGNAL being tested
            CONSTANT TestPortName      : IN     STRING := "";     -- name OF the signal
            SIGNAL   RefPort           : IN     std_ulogic;       -- SIGNAL being referenced
            CONSTANT RefPortName       : IN     STRING := "";     -- name OF the ref signal
            CONSTANT t_setup_hi        : IN     TIME := 0 ns;     -- setup spec FOR test PORT = '1'
            CONSTANT t_setup_lo        : IN     TIME := 0 ns;     -- setup spec FOR test PORT = '0'
            CONSTANT t_hold_hi         : IN     TIME := 0 ns;     -- hold spec FOR test PORT = '1'
            CONSTANT t_hold_lo         : IN     TIME := 0 ns;     -- hold spec FOR test PORT = '0'
            CONSTANT condition         : IN     BOOLEAN;          -- true ==> spec checked.
            CONSTANT HeaderMsg         : IN     STRING := " ";
            VARIABLE TestPortLastEvent : INOUT  TIME_Vector;      -- records the last time
            VARIABLE TestPortLastValue : INOUT  std_logic_vector;
            VARIABLE Violation         : INOUT  BOOLEAN;
	    CONSTANT WarningsOn	       : IN	BOOLEAN := TRUE   -- IF TRUE assertions are generated
                                       ) IS

        VARIABLE observed_time : TIME;
        VARIABLE expected_time : TIME;
        VARIABLE constrnt_time : TIME;
        VARIABLE TestX01       : X01;
        VARIABLE TestPort_LAST_EVENT : TIME;
        VARIABLE TestPort_EVENT : BOOLEAN;
        VARIABLE TestPort_LastValue : std_logic_vector(TestPort'RANGE);
        VARIABLE vantage_kludge : std_logic_vector(1 to TestPort'Length + 1);
        VARIABLE ChangedAllAtOnce : Boolean := TRUE;
	VARIABLE TestPortGroupLastEvent : time;
        VARIABLE last_change : time;

    BEGIN

        -- note : additional error checking can be coded regarding the defaulting of
        --        t_setup_lo or t_setup_hi such that one or the other could be used to
        --        specify the setup condition, however, IN the interest OF some code
        --        efficiency, the code was not provided. IF the ultimate protection
        --        IS  required, it can be written.
        -- NOTE : TestPortLastEvent MUST be updated on each change of TestPort
        --        regardless of whether "Condition" is TRUE.
        -- note : TestPort_LAST_EVENT is actually TestPort'DELAYED(0 ns)'LAST_EVENT
        --        that is, it is not 0 ns when TestPort'EVENT is TRUE.

      violation := FALSE;
      -- vantage bug-fix
      vantage_kludge := TestPort'LAST_VALUE & "X";
      TestPort_LastValue := vantage_kludge(1 to TestPort'Length);

      -------------------------------------------------------------------------
      -- Check to see if the Bus subelements changed all at the same time.
      -- If so, then we can reduce the volume of error messages since we no
      -- longer have to report every subelement individually
      -------------------------------------------------------------------------

      if ( TestPortLastValue(TestPort'Left) /= TestPort(TestPort'Left) ) then
         TestPortGroupLastEvent := NOW;
      else
         TestPortGroupLastEvent := TestPortLastEvent(TestPort'Left);
      end if;
      FOR ii IN TestPort'RANGE Loop
         if ( TestPortLastValue(ii) /= TestPort(ii) ) then
            last_change := NOW;
         else
            last_change := TestPortLastEvent(ii);
         end if;
         if (last_change /= TestPortGroupLastEvent) then
            ChangedAllAtOnce := False;
            Exit;
        end if;
      END Loop;


      index_loop: FOR i IN TestPort'RANGE LOOP
        TestPort_LAST_EVENT := NOW - TestPortLastEvent(i);
        TestPort_EVENT := TestPortLastValue(i) /= TestPort(i);
        IF TestPort_EVENT THEN
            TestPortLastEvent(i) := NOW;
        END IF;

        IF condition AND (NOW > 0 ns) THEN
            -- -----------------------------------------------------------------
            -- Active edge of reference signal - check setup time
            -- -----------------------------------------------------------------
            IF RefPort'EVENT THEN
                TestX01 := To_X01(TestPort(i));
                IF (TestX01 = '1') THEN
                    expected_time :=  t_setup_hi;
                    constrnt_time := -t_hold_hi;
                ELSIF (TestX01 = '0') THEN
                    expected_time :=  t_setup_lo;
                    constrnt_time := -t_hold_lo;
                ELSE
                    expected_time := MINIMUM ( t_setup_lo,  t_setup_hi);
                    constrnt_time := MINIMUM (-t_hold_lo , -t_hold_hi ); -- bug fix 8/24/95
                END IF; -- setup was violated
                observed_time := TestPort_LAST_EVENT;
                ----------------------------------------------------------------
                -- some sort of setup violation occurred
                ----------------------------------------------------------------
                IF (observed_time < expected_time) THEN
                    Violation := TRUE;
		    ------------------------------------------------------------
		    -- Only report it on the first index for group changes
		    ------------------------------------------------------------
		    IF (ChangedAllAtOnce and (i = TestPort'LEFT)) then 

	                    IF (observed_time < constrnt_time) THEN
	                        --------------------------------------------------------
	                        -- Test signal change within negative hold window
	                        --------------------------------------------------------
	                        report_possible_error (
	                                        HeaderMsg, "SETUP ", TestX01,
	                                        TestPortName & "(...)",
	                                        RefPortName,
	                                        expected_time, observed_time,
	                                        constrnt_time, WarningsOn );
	                    ELSIF (To_X01(TestPort_LastValue(i)) = TestX01) THEN
	                        --------------------------------------------------------
	                        -- the "state" did not change, only the strength did
	                        --------------------------------------------------------
	                        report_soft_error (
	                                        HeaderMsg, "SETUP ", TestX01,
	                                        TestPortName & "(...)",
	                                        RefPortName,
	                                        expected_time, observed_time,
	                                        TestPort_LastValue(i), TestPort(i),
						WarningsOn );
	                    ELSE
	                        --------------------------------------------------------
	                        -- the "state" changed ( hard ) violation
	                        --------------------------------------------------------
	                        report_error (  HeaderMsg, "SETUP ", TestX01,
	                                        TestPortName & "(...)",
	                                        RefPortName,
	                                        expected_time, observed_time,
						WarningsOn );
	                    END IF;
		    ELSIF (not ChangedAllAtOnce) then
	                    IF (observed_time < constrnt_time) THEN
	                        --------------------------------------------------------
	                        -- Test signal change within negative hold window
	                        --------------------------------------------------------
	                        report_possible_error (
	                                        HeaderMsg, "SETUP ", TestX01,
	                                        TestPortName & "(" & To_String(i) & ")",
	                                        RefPortName,
	                                        expected_time, observed_time,
	                                        constrnt_time, WarningsOn );
	                    ELSIF (To_X01(TestPort_LastValue(i)) = TestX01) THEN
	                        --------------------------------------------------------
	                        -- the "state" did not change, only the strength did
	                        --------------------------------------------------------
	                        report_soft_error (
	                                        HeaderMsg, "SETUP ", TestX01,
	                                        TestPortName & "(" & To_String(i) & ")",
	                                        RefPortName,
	                                        expected_time, observed_time,
	                                        TestPort_LastValue(i), TestPort(i),
						WarningsOn );
	                    ELSE
	                        --------------------------------------------------------
	                        -- the "state" changed ( hard ) violation
	                        --------------------------------------------------------
	                        report_error (  HeaderMsg, "SETUP ", TestX01,
	                                        TestPortName & "(" & To_String(i) & ")",
	                                        RefPortName,
	                                        expected_time, observed_time,
						WarningsOn );
	                    END IF;
		    end if;
                END IF;
	    END IF;  -- bug fix to handle Test and Ref. ports changing at same delta
            --------------------------------------------------------------------
            -- test signal change 
            --------------------------------------------------------------------
           IF TestPort_EVENT THEN
                TestX01 := To_X01(TestPort_LastValue(i));
                IF    (TestX01 = '1') THEN
                    expected_time := t_hold_hi;
                    constrnt_time := -t_setup_hi;
                ELSIF (TestX01 = '0') THEN
                    expected_time := t_hold_lo;
                    constrnt_time := -t_setup_lo;
                ELSE
                    expected_time := MINIMUM (t_hold_lo, t_hold_hi);
                    constrnt_time := MINIMUM (-t_setup_lo , -t_setup_hi );  -- bug fix 8/24/95
                END IF;
                observed_time := RefPort'LAST_EVENT;
                ----------------------------------------------------------------
                -- some sort of hold violation occurred
                -- violation = hold_violation  AND
                --             violation not in negative setup window   AND
                --             violation is the first 
                ----------------------------------------------------------------
                IF (observed_time < expected_time) AND 
                   (observed_time > constrnt_time) AND
                   ((observed_time - TestPort_LAST_EVENT) <= constrnt_time)
                THEN
                    Violation := TRUE;
		    ------------------------------------------------------------
		    -- Only report it on the first index for group changes
		    ------------------------------------------------------------
		    IF (ChangedAllAtOnce and (i = TestPort'LEFT)) then 
	                    IF TestX01 = To_X01(TestPort(i)) THEN
	                        --------------------------------------------------------
	                        -- the "state" did not change, only the strength did
	                        --------------------------------------------------------
	                        report_soft_error (
	                                    HeaderMsg, "HOLD  ", TestX01,
	                                    TestPortName & "(...)",
	                                    RefPortName,
	                                    expected_time, observed_time,
	                                    TestPort_LastValue(i), TestPort(i),
					    WarningsOn );
	                    ELSE
	                        --------------------------------------------------------
	                        -- the "state" changed ( hard ) violation
	                        --------------------------------------------------------
	                        report_error (
	                                    HeaderMsg, "HOLD  ", TestX01,
	                                    TestPortName & "(...)",
	                                    RefPortName,
	                                    expected_time, observed_time,
					    WarningsOn );
	                    END IF;
		    ELSIF (not ChangedAllAtOnce) then
	                    IF TestX01 = To_X01(TestPort(i)) THEN
	                        --------------------------------------------------------
	                        -- the "state" did not change, only the strength did
	                        --------------------------------------------------------
	                        report_soft_error (
	                                    HeaderMsg, "HOLD  ", TestX01,
	                                    TestPortName & "(" & To_String(i) & ")",
	                                    RefPortName,
	                                    expected_time, observed_time,
	                                    TestPort_LastValue(i), TestPort(i),
					    WarningsOn );
	                    ELSE
	                        --------------------------------------------------------
	                        -- the "state" changed ( hard ) violation
	                        --------------------------------------------------------
	                        report_error (
	                                    HeaderMsg, "HOLD  ", TestX01,
	                                    TestPortName & "(" & To_String(i) & ")",
	                                    RefPortName,
	                                    expected_time, observed_time,
					    WarningsOn );
	                    END IF;
		    END IF;
                END IF; -- Violation
            END IF;
        END IF; -- condition and NOW > 0 ns;
        TestPortLastValue(i) := TestPort(i);
      END LOOP;      
    END TimingCheck;
    --------------------------------------------------------------------
    PROCEDURE TimingCheck (
            SIGNAL   TestPort          : IN     std_ulogic_vector; -- SIGNAL being tested
            CONSTANT TestPortName      : IN     STRING := "";     -- name OF the signal
            SIGNAL   RefPort           : IN     std_ulogic;       -- SIGNAL being referenced
            CONSTANT RefPortName       : IN     STRING := "";     -- name OF the ref signal
            CONSTANT t_setup_hi        : IN     TIME := 0 ns;     -- setup spec FOR test PORT = '1'
            CONSTANT t_setup_lo        : IN     TIME := 0 ns;     -- setup spec FOR test PORT = '0'
            CONSTANT t_hold_hi         : IN     TIME := 0 ns;     -- hold spec FOR test PORT = '1'
            CONSTANT t_hold_lo         : IN     TIME := 0 ns;     -- hold spec FOR test PORT = '0'
            CONSTANT condition         : IN     BOOLEAN;          -- true ==> spec checked.
            CONSTANT HeaderMsg         : IN     STRING := " ";
            VARIABLE TestPortLastEvent : INOUT  TIME_Vector;      -- records the last time
            VARIABLE TestPortLastValue : INOUT  std_ulogic_vector;
            VARIABLE Violation         : INOUT  BOOLEAN;
	    CONSTANT WarningsOn	       : IN	BOOLEAN := TRUE   -- IF TRUE assertions are generated
                                       ) IS

        VARIABLE observed_time : TIME;
        VARIABLE expected_time : TIME;
        VARIABLE constrnt_time : TIME;
        VARIABLE TestX01       : X01;
        VARIABLE TestPort_LAST_EVENT : TIME;
        VARIABLE TestPort_EVENT : BOOLEAN;
        VARIABLE TestPort_LastValue : std_ulogic_vector(TestPort'RANGE);
        VARIABLE vantage_kludge : std_ulogic_vector(1 to TestPort'Length + 1);
        VARIABLE ChangedAllAtOnce : Boolean := TRUE;
	VARIABLE TestPortGroupLastEvent : time;
        VARIABLE last_change : time;

    BEGIN

        -- note : additional error checking can be coded regarding the defaulting of
        --        t_setup_lo or t_setup_hi such that one or the other could be used to
        --        specify the setup condition, however, IN the interest OF some code
        --        efficiency, the code was not provided. IF the ultimate protection
        --        IS  required, it can be written.
        -- NOTE : TestPortLastEvent MUST be updated on each change of TestPort
        --        regardless of whether "Condition" is TRUE.
        -- note : TestPort_LAST_EVENT is actually TestPort'DELAYED(0 ns)'LAST_EVENT
        --        that is, it is not 0 ns when TestPort'EVENT is TRUE.

      violation := FALSE;
      -- vantage bug-fix
      vantage_kludge := TestPort'LAST_VALUE & "X";
      TestPort_LastValue := vantage_kludge(1 to TestPort'Length);

      -------------------------------------------------------------------------
      -- Check to see if the Bus subelements changed all at the same time.
      -- If so, then we can reduce the volume of error messages since we no
      -- longer have to report every subelement individually
      -------------------------------------------------------------------------

      if ( TestPortLastValue(TestPort'Left) /= TestPort(TestPort'Left) ) then
         TestPortGroupLastEvent := NOW;
      else
         TestPortGroupLastEvent := TestPortLastEvent(TestPort'Left);
      end if;
      FOR ii IN TestPort'RANGE Loop
         if ( TestPortLastValue(ii) /= TestPort(ii) ) then
            last_change := NOW;
         else
            last_change := TestPortLastEvent(ii);
         end if;
         if (last_change /= TestPortGroupLastEvent) then
            ChangedAllAtOnce := False;
            Exit;
        end if;
      END Loop;

      index_loop: FOR i IN TestPort'RANGE LOOP
        TestPort_LAST_EVENT := NOW - TestPortLastEvent(i);
        TestPort_EVENT := TestPortLastValue(i) /= TestPort(i);
        IF TestPort_EVENT THEN
            TestPortLastEvent(i) := NOW;
        END IF;

        IF condition AND (NOW > 0 ns) THEN
            -- -----------------------------------------------------------------
            -- Active edge of reference signal - check setup time
            -- -----------------------------------------------------------------
            IF RefPort'EVENT THEN
                TestX01 := To_X01(TestPort(i));
                IF (TestX01 = '1') THEN
                    expected_time :=  t_setup_hi;
                    constrnt_time := -t_hold_hi;
                ELSIF (TestX01 = '0') THEN
                    expected_time :=  t_setup_lo;
                    constrnt_time := -t_hold_lo;
                ELSE
                    expected_time := MINIMUM ( t_setup_lo,  t_setup_hi);
                    constrnt_time := MINIMUM (-t_hold_lo , -t_hold_hi );  -- bug fix 8/24/95
                END IF; -- setup was violated
                observed_time := TestPort_LAST_EVENT;
                ----------------------------------------------------------------
                -- some sort of setup violation occurred
                ----------------------------------------------------------------
                IF (observed_time < expected_time) THEN
                    Violation := TRUE;
		    ------------------------------------------------------------
		    -- Only report it on the first index for group changes
		    ------------------------------------------------------------
		    IF (ChangedAllAtOnce and (i = TestPort'LEFT)) then 

	                    IF (observed_time < constrnt_time) THEN
	                        --------------------------------------------------------
	                        -- Test signal change within negative hold window
	                        --------------------------------------------------------
	                        report_possible_error (
	                                        HeaderMsg, "SETUP ", TestX01,
	                                        TestPortName & "(...)",
	                                        RefPortName,
	                                        expected_time, observed_time,
	                                        constrnt_time, WarningsOn );
	                    ELSIF (To_X01(TestPort_LastValue(i)) = TestX01) THEN
	                        --------------------------------------------------------
	                        -- the "state" did not change, only the strength did
	                        --------------------------------------------------------
	                        report_soft_error (
	                                        HeaderMsg, "SETUP ", TestX01,
	                                        TestPortName & "(...)",
	                                        RefPortName,
	                                        expected_time, observed_time,
	                                        TestPort_LastValue(i), TestPort(i),
						WarningsOn );
	                    ELSE
	                        --------------------------------------------------------
	                        -- the "state" changed ( hard ) violation
	                        --------------------------------------------------------
	                        report_error (  HeaderMsg, "SETUP ", TestX01,
	                                        TestPortName & "(...)",
	                                        RefPortName,
	                                        expected_time, observed_time,
						WarningsOn );
	                    END IF;
		    ELSIF (not ChangedAllAtOnce) then
	                    IF (observed_time < constrnt_time) THEN
	                        --------------------------------------------------------
	                        -- Test signal change within negative hold window
	                        --------------------------------------------------------
	                        report_possible_error (
	                                        HeaderMsg, "SETUP ", TestX01,
	                                        TestPortName & "(" & To_String(i) & ")",
	                                        RefPortName,
	                                        expected_time, observed_time,
	                                        constrnt_time, WarningsOn );
	                    ELSIF (To_X01(TestPort_LastValue(i)) = TestX01) THEN
	                        --------------------------------------------------------
	                        -- the "state" did not change, only the strength did
	                        --------------------------------------------------------
	                        report_soft_error (
	                                        HeaderMsg, "SETUP ", TestX01,
	                                        TestPortName & "(" & To_String(i) & ")",
	                                        RefPortName,
	                                        expected_time, observed_time,
	                                        TestPort_LastValue(i), TestPort(i),
						WarningsOn );
	                    ELSE
	                        --------------------------------------------------------
	                        -- the "state" changed ( hard ) violation
	                        --------------------------------------------------------
	                        report_error (  HeaderMsg, "SETUP ", TestX01,
	                                        TestPortName & "(" & To_String(i) & ")",
	                                        RefPortName,
	                                        expected_time, observed_time,
						WarningsOn );
	                    END IF;
		    end if;
                END IF;
            END IF;  -- bug fix to handle Test and Ref. ports changing at same delta
            --------------------------------------------------------------------
            -- test signal change 
            --------------------------------------------------------------------
            IF TestPort_EVENT THEN
                TestX01 := To_X01(TestPort_LastValue(i));
                IF    (TestX01 = '1') THEN
                    expected_time := t_hold_hi;
                    constrnt_time := -t_setup_hi;
                ELSIF (TestX01 = '0') THEN
                    expected_time := t_hold_lo;
                    constrnt_time := -t_setup_lo;
                ELSE
                    expected_time := MINIMUM (t_hold_lo, t_hold_hi);
                    constrnt_time := MINIMUM (-t_setup_lo , -t_setup_hi );  -- bug fix 8/24/95
                END IF;
                observed_time := RefPort'LAST_EVENT;
                ----------------------------------------------------------------
                -- some sort of hold violation occurred
                -- violation = hold_violation  AND
                --             violation not in negative setup window   AND
                --             violation is the first 
                ----------------------------------------------------------------
                IF (observed_time < expected_time) AND 
                   (observed_time > constrnt_time) AND
                   ((observed_time - TestPort_LAST_EVENT) <= constrnt_time)
                THEN
                    Violation := TRUE;
		    ------------------------------------------------------------
		    -- Only report it on the first index for group changes
		    ------------------------------------------------------------
		    IF (ChangedAllAtOnce and (i = TestPort'LEFT)) then 
	                    IF TestX01 = To_X01(TestPort(i)) THEN
	                        --------------------------------------------------------
	                        -- the "state" did not change, only the strength did
	                        --------------------------------------------------------
	                        report_soft_error (
	                                    HeaderMsg, "HOLD  ", TestX01,
	                                    TestPortName & "(...)",
	                                    RefPortName,
	                                    expected_time, observed_time,
	                                    TestPort_LastValue(i), TestPort(i),
					    WarningsOn );
	                    ELSE
	                        --------------------------------------------------------
	                        -- the "state" changed ( hard ) violation
	                        --------------------------------------------------------
	                        report_error (
	                                    HeaderMsg, "HOLD  ", TestX01,
	                                    TestPortName & "(...)",
	                                    RefPortName,
	                                    expected_time, observed_time,
					    WarningsOn );
	                    END IF;
		    ELSIF (not ChangedAllAtOnce) then
	                    IF TestX01 = To_X01(TestPort(i)) THEN
	                        --------------------------------------------------------
	                        -- the "state" did not change, only the strength did
	                        --------------------------------------------------------
	                        report_soft_error (
	                                    HeaderMsg, "HOLD  ", TestX01,
	                                    TestPortName & "(" & To_String(i) & ")",
	                                    RefPortName,
	                                    expected_time, observed_time,
	                                    TestPort_LastValue(i), TestPort(i),
					    WarningsOn );
	                    ELSE
	                        --------------------------------------------------------
	                        -- the "state" changed ( hard ) violation
	                        --------------------------------------------------------
	                        report_error (
	                                    HeaderMsg, "HOLD  ", TestX01,
	                                    TestPortName & "(" & To_String(i) & ")",
	                                    RefPortName,
	                                    expected_time, observed_time,
					    WarningsOn );
	                    END IF;
		    END IF;
                END IF; -- Violation
            END IF;
        END IF; -- condition and NOW > 0 ns;
        TestPortLastValue(i) := TestPort(i);
      END LOOP;      
    END TimingCheck;


 --+ ---------------------------------------------------------------------------
 --+  Function       : SetupViolation
 --+      parameters :
 --+         IN      : TestPort       -- SIGNAL    std_ulogic
 --+         IN      : TestPortName   -- CONSTANT  string
 --+         IN      : RefPort        -- SIGNAL    std_ulogic
 --+         IN      : RefPortName    -- CONSTANT  string
 --+         IN      : t_setup_hi     -- CONSTANT  time
 --+         IN      : t_setup_lo     -- CONSTANT  time
 --+         IN      : condition      -- CONSTANT  boolean
 --+         IN      : HeaderMsg      -- CONSTANT  string
 --+	     IN	     : WarningsOn     -- CONSTANT  boolean
 --+
 --+     returns     : boolean        -- TRUE if a violation occurred
 --+
 --+  Assumption : For the vector overloaded function, it is
 --+               assumed that the value of the timing specifications
 --+               apply to all of the subelements of the Test port
 --+
 --+               Any change in the value of "RefPort" when "condition"
 --+               is TRUE is considered a triggering edge. This includes
 --+               a strength only change of "RefPort".
 --+
 --+               No setup violations are reported if a negative value is
 --+               specified for the Hold time. See the "TimingCheck"
 --+               Procedure if negative Setup values are intended as
 --+               constraints on Hold time.
 --+
 --+     Notes       :
 --+       In the formal parameter list of this routine, both the test
 --+       and reference signals are referenced along with their string
 --+       names.
 --+               _____________         ________________
 --+               _____________XXXXXXXXX________________  test signal
 --+               ____________________________
 --+                                           \_________  ref signal
 --+                                 --->|     |<-----
 --+                                     t_setup
 --+
 --+       t_setup_hi ::= minimum interval preceeding the triggering edge
 --+                      of the referenced signal for the high logic level
 --+                      data to latch in. Defaults to 0 ns.
 --+
 --+       t_setup_lo ::= minimum interval preceeding the triggering edge
 --+                      of the referenced signal for the low logic level
 --+                      data to latch in. Defaults to 0 ns.
 --+
 --+       Only the last change on the test signal preceeding the active
 --+       edge of the ref signal will potentially generate a setup violations.
 --+
 --+       This subprogram has been designed as a procedure to facilitate
 --+       its use both in sequential code, but also in concurrent code
 --+       as a passive concurrent procedure call.
 --+
 --+      USE        :
 --+
 --+       IF SetupViolation    (
 --+                               TestPort       => D,     -- Data line
 --+                               TestPortName   => "D",   -- string
 --+                               RefPort        => CLK,   -- CLK signal
 --+                               RefPortName    => "CLK",
 --+                               t_setup_hi     => 23 ns,
 --+                               t_setup_lo     => 23 ns,
 --+                               condition      => (CLK = '1'),
 --+                               HeaderMsg      => InstanceHeader
 --+                             ) then
 --+           Q <= 'X';
 --+
 --+       END IF;
 --+
 --+ ---------------------------------------------------------------------------
    FUNCTION SetupViolation (
            SIGNAL   TestPort     : IN     std_ulogic;     -- SIGNAL being tested
            CONSTANT TestPortName : IN     STRING := "";   -- name OF the signal
            SIGNAL   RefPort      : IN     std_ulogic;     -- SIGNAL being referenced
            CONSTANT RefPortName  : IN     STRING := "";   -- name OF the ref signal
            CONSTANT t_setup_hi   : IN     TIME := 0 ns;   -- setup spec FOR test PORT = '1'
            CONSTANT t_setup_lo   : IN     TIME := 0 ns;   -- setup spec FOR test PORT = '0'
            CONSTANT condition    : IN     BOOLEAN;        -- IF true THEN the
                                                           -- spec will be checked.
            CONSTANT HeaderMsg    : IN     STRING := " ";
	    CONSTANT WarningsOn	  : IN	   BOOLEAN := TRUE -- IF TRUE assertions are generated
                                  ) RETURN BOOLEAN IS

        VARIABLE Violation : BOOLEAN := FALSE;
        VARIABLE observed_time : TIME;
        VARIABLE expected_time : TIME;
        VARIABLE TestX01       : X01;
    BEGIN
    -- note : additional error checking can be coded regarding the defaulting of
    --        t_setup_lo or t_setup_hi such that one or the other could be used to
    --        specify the setup condition, however, IN the interest OF some code
    --        efficiency, the code was not provided. IF the ultimate protection
    --        IS  required, it can be written.

        -- ---------------------------------------------------------------------
        -- Active edge of reference signal
        -- ---------------------------------------------------------------------
        IF RefPort'EVENT AND condition AND (NOW > 0 ns) THEN
            TestX01 := To_X01(TestPort);
            IF (TestX01 = '1') THEN
                expected_time := t_setup_hi;
            ELSIF (TestX01 = '0') THEN
                expected_time := t_setup_lo;
            ELSE
                expected_time := MINIMUM (t_setup_lo, t_setup_hi);
            END IF; -- setup was violated
            observed_time := TestPort'LAST_EVENT;
            Violation     := (observed_time < expected_time);
            --------------------------------------------------------------------
            -- some sort of setup violation occurred
            --------------------------------------------------------------------
            IF Violation THEN
            --------------------------------------------------------------------
            -- since we have a state-strength logic system we need to handle
            -- weak '0' -> strong '0' transitions as potential (SOFT) setup
            -- violations rather than a true (hard) violation such as a
            -- '0' -> '1' transition within the setup time window
            --------------------------------------------------------------------
                IF (To_X01(TestPort'LAST_VALUE) = TestX01) THEN
                    ------------------------------------------------------------
                    -- the "state" did not change, only the strength did
                    ------------------------------------------------------------
                    report_soft_error (
                                    HeaderMsg, "SETUP ", TestX01,
                                    TestPortName, RefPortName,
                                    expected_time, observed_time,
                                    TestPort'LAST_VALUE, TestPort,
				    WarningsOn );
                ELSE
                    ------------------------------------------------------------
                    -- the "state" changed ( hard ) violation
                    ------------------------------------------------------------
                    report_error (  HeaderMsg, "SETUP ", TestX01,
                                    TestPortName, RefPortName,
                                    expected_time, observed_time,
				    WarningsOn );
                END IF;
            END IF;
        END IF;
        RETURN (Violation);
    END SetupViolation;

 --+ -----------------------------------------------------------------
 --+  Procedure Name : SetupCheck
 --+      parameters :
 --+         IN      : TestPort       -- SIGNAL    std_logic
 --+         IN      : TestPortName   -- CONSTANT  string
 --+         IN      : RefPort        -- SIGNAL    std_logic
 --+         IN      : RefPortName    -- CONSTANT  string
 --+         IN      : t_setup_hi     -- CONSTANT  time
 --+         IN      : t_setup_lo     -- CONSTANT  time
 --+         IN      : condition      -- CONSTANT  boolean
 --+         IN      : HeaderMsg      -- CONSTANT  string
 --+
 --+  Assumption :
 --+               Any change in the value of "RefPort" when "condition"
 --+               is TRUE is considered a triggering edge. This includes
 --+               changes only in the Strength of "RefPort".
 --+
 --+     Notes       :
 --+       In the formal parameter list of this routine, both the test
 --+       and reference signals are referenced along with their string
 --+       names.
 --+               _____________         ________________
 --+               _____________XXXXXXXXX________________  test signal
 --+               ____________________________
 --+                                           \_________  ref signal
 --+                                 --->|     |<-----
 --+                                     t_setup
 --+
 --+       t_setup_hi ::= minimum interval preceding the triggering edge
 --+                      of the referenced signal for the high logic level
 --+                      data to latch in. Defaults to 0 ns.
 --+
 --+       t_setup_lo ::= minimum interval preceding the triggering edge
 --+                      of the referenced signal for the low logic level
 --+                      data to latch in. Defaults to 0 ns.
 --+
 --+       This subprogram has been designed as a procedure to facilitate
 --+       its use both in sequential code, but also in concurrent code
 --+       as a passive concurrent procedure call.
 --+
 --+      USE        :
 --+
 --+       check_d : SetupCheck (
 --+                               TestPort       => D,     -- Data line
 --+                               TestPortName   => "D",   -- string
 --+                               RefPort        => CLK,   -- CLK signal
 --+                               RefPortName    => "CLK",
 --+                               t_setup_hi     => 23 ns,
 --+                               t_setup_lo     => 23 ns,
 --+                               condition      => (CLK = '1'),
 --+                               HeaderMsg      => InstanceHeader
 --+                             );
 --+ -----------------------------------------------------------------
    PROCEDURE SetupCheck (
                SIGNAL   TestPort     : IN     std_ulogic;    -- SIGNAL being tested
                CONSTANT TestPortName : IN     STRING := "";  -- name OF the signal
                SIGNAL   RefPort      : IN     std_ulogic;    -- SIGNAL being referenced
                CONSTANT RefPortName  : IN     STRING := "";  -- name OF the ref signal
                CONSTANT t_setup_hi   : IN     TIME := 0 ns;  -- setup spec FOR test PORT = '1'
                CONSTANT t_setup_lo   : IN     TIME := 0 ns;  -- setup spec FOR test PORT = '0'
                CONSTANT condition    : IN     BOOLEAN;       -- IF true THEN the
                                                      -- spec will be checked.
                CONSTANT HeaderMsg    : IN     STRING := " "
                                      ) IS

        VARIABLE Violation : BOOLEAN := FALSE;
    BEGIN
        Violation := SetupViolation ( TestPort,     TestPortName,
                                      RefPort,      RefPortName,
                                      t_setup_hi,   t_setup_lo,
                                      condition,
                                      HeaderMsg
                                     );
    END SetupCheck;

 --+ ---------------------------------------------------------------------------
 --+   Function      : HoldViolation
 --+      parameters :
 --+         IN      : TestPort       -- SIGNAL    std_logic
 --+         IN      : TestPortName   -- CONSTANT  string
 --+         IN      : RefPort        -- SIGNAL    std_logic
 --+         IN      : RefPortName    -- CONSTANT  string
 --+         IN      : t_hold_hi      -- CONSTANT  time
 --+         IN      : t_hold_lo      -- CONSTANT  time
 --+         IN      : condition      -- CONSTANT  boolean
 --+         IN      : HeaderMsg      -- CONSTANT  string
 --+	     IN	     : WarningsOn     -- CONSTANT  boolean
 --+                 :
 --+     Returns     : boolean        -- TRUE if violation exists
 --+
 --+  Assumption :
 --+               Any change in the value of "RefPort" when "condition"
 --+               is TRUE is considered a triggering edge. This includes
 --+               changes only in the Strength of "RefPort".
 --+
 --+               No hold violations are reported if a negative value is
 --+               specified for the Hold time. See the "TimingCheck"
 --+               Procedure if negative Hold values are intended as
 --+               constraints on Setup time.
 --+
 --+               Hold times must be less than the minimum active pulse
 --+               width of reference signal.
 --+
 --+     Notes       :
 --+       In the formal parameter list of this routine, both the test
 --+       and reference signals are referenced along with their string
 --+       names.
 --+               __________________         _________
 --+               __________________XXXXXXXXX_________  test signal
 --+               ____________
 --+                           \_________  ref signal
 --+                       --->|     |<-----
 --+                           t_hold
 --+
 --+
 --+       t_hold_hi ::= minimum interval the high logic level input data
 --+                     must remain at its latching level after the active
 --+                     edge of the clock. Defaults to 0 ns.
 --+
 --+       t_hold_lo ::= minimum interval the low  logic level input data
 --+                     must remain at its latching level after the active
 --+                     edge of the clock. Defaults to 0 ns.
 --+
 --+       A high pulse with (width < t_hold_hi - t_hold_lo) or a low
 --+       pulse with (with < t_hold_lo - t_hold_hi) may generate a 
 --+       false HOLD violation.
 --+
 --+       This subprogram has been designed as a procedure to facilitate
 --+       its use both in sequential code, but also in concurrent code
 --+       as a passive concurrent procedure call.
 --+
 --+      USE        :
 --+
 --+       IF HoldViolation    (
 --+                               TestPort       => D,     -- Data line
 --+                               TestPortName   => "D",   -- string
 --+                               RefPort        => CLK,   -- CLK signal
 --+                               RefPortName    => "CLK",
 --+                               t_hold_hi      => 23 ns,
 --+                               t_hold_lo      => 23 ns,
 --+                               condition      => (CLK = '1'),
 --+                               HeaderMsg      => InstanceHeader
 --+                             ) then
 --+           Q <= 'X';
 --+
 --+       END IF;
 --+ ---------------------------------------------------------------------------
    FUNCTION HoldViolation (
            SIGNAL   TestPort     : IN     std_ulogic;     -- SIGNAL being tested
            CONSTANT TestPortName : IN     STRING := "";   -- name OF the signal
            SIGNAL   RefPort      : IN     std_ulogic;     -- SIGNAL being referenced
            CONSTANT RefPortName  : IN     STRING := "";   -- name OF the ref signal
            CONSTANT t_hold_hi    : IN     TIME := 0 ns;   -- hold  specification
            CONSTANT t_hold_lo    : IN     TIME := 0 ns;   -- hold  specification
            CONSTANT condition    : IN     BOOLEAN;        -- IF true THEN the
                                                           -- spec will be checked.
            CONSTANT HeaderMsg    : IN     STRING := " ";
	    CONSTANT WarningsOn	  : IN	   BOOLEAN := TRUE -- IF TRUE assertions are generated
                                  ) RETURN BOOLEAN IS

        VARIABLE Violation : BOOLEAN := FALSE;
        VARIABLE observed_time : TIME;
        VARIABLE expected_time : TIME;
        VARIABLE TestX01       : X01;
    BEGIN
    -- note : additional error checking can be coded regarding the defaulting of
    --        t_hold_lo or t_hold_hi such that one or the other could be used to
    --        specify the hold condition, however, IN the interest OF some code
    --        efficiency, the code was not provided. IF the ultimate protection
    --        IS  required, it can be written.

        IF condition AND (NOW > 0 ns) THEN
            --------------------------------------------------------------------
            -- test signal change
            -- Note: If time to previous TestPort change was available, only the
            --       first hold violation could be reported - but alas.
            --------------------------------------------------------------------
            IF TestPort'EVENT THEN
                TestX01 := To_X01(TestPort'LAST_VALUE);
                IF    (TestX01 = '1') THEN
                    expected_time := t_hold_hi;
                ELSIF (TestX01 = '0') THEN
                    expected_time := t_hold_lo;
                ELSE
                    expected_time := MINIMUM (t_hold_lo, t_hold_hi);
                END IF; -- hold was violated
                observed_time := RefPort'LAST_EVENT;
                Violation     := (observed_time < expected_time);
                ----------------------------------------------------------------
                -- some sort of hold violation occurred
                ----------------------------------------------------------------
                IF Violation THEN
                    ------------------------------------------------------------
                    -- since we have a state-strength logic system we need to
                    -- handle weak '0' -> strong '0' transitions as potential
                    -- (SOFT) hold violations rather than a true (hard)
                    -- violation such as a '0' -> '1' transition within the
                    -- hold time window
                    ------------------------------------------------------------
                    IF (TestX01 = To_X01(TestPort)) THEN
                        --------------------------------------------------------
                        -- the "state" did not change, only the strength did
                        --------------------------------------------------------
                        report_soft_error (
                                    HeaderMsg, "HOLD  ", TestX01,
                                    TestPortName, RefPortName,
                                    expected_time, observed_time,
                                    TestPort'LAST_VALUE, TestPort,
				    WarningsOn );
                    ELSE
                        --------------------------------------------------------
                        -- the "state" changed ( hard ) violation
                        --------------------------------------------------------
                        report_error (
                                    HeaderMsg, "HOLD  ", TestX01,
                                    TestPortName, RefPortName,
                                    expected_time, observed_time,
				    WarningsOn );
                    END IF;
                END IF; -- Violation
            END IF; -- Test event
        END IF; -- condition and > 0 ns
        RETURN (Violation);
    END HoldViolation;

 --+ ---------------------------------------------------------------------------
 --+  Procedure Name : HoldCheck
 --+    parameters :
 --+       IN      : TestPort       --+SIGNAL    std_ulogic
 --+       IN      : TestPortName   -- CONSTANT  string
 --+       IN      : RefPort        --+SIGNAL    std_ulogic
 --+       IN      : RefPortName    --+CONSTANT  string
 --+       IN      : t_hold_hi      --+CONSTANT  time
 --+       IN      : t_hold_lo      --+CONSTANT  time
 --+       IN      : condition      --+CONSTANT  boolean
 --+       IN      : HeaderMsg      --+CONSTANT  string
 --+
 --+  Assumption : For the vector overloaded function, it is
 --+               assumed that the value of the timing specifications
 --+               apply to all of the subelements of the Test port
 --+
 --+               Any change in the value of "RefPort" when "condition"
 --+               is TRUE is considered a triggering edge. This includes
 --+               changes only in the Strength of "RefPort".
 --+
 --+               No hold violations are reported if a negative value is
 --+               specified for the Hold time. See the "TimingCheck"
 --+               Procedure if negative Hold values are intended as
 --+               constraints on Setup time.
 --+
 --+               Hold times must be less than the minimum active pulse
 --+               width of reference signal.
 --+
 --+   Notes       :
 --+     In the formal parameter list of this routine, both the test
 --+     and reference signals are referenced along with their string
 --+     names.
 --+             __________________         _________
 --+             __________________XXXXXXXXX_________  test signal
 --+             ____________
 --+                         \_________  ref signal
 --+                     --->|     |<-----
 --+                         t_hold
 --+
 --+
 --+     t_hold_hi ::= minimum interval the high logic level input data
 --+                   must remain at its latching level after the active
 --+                   edge of the clock. Defaults to 0 ns.
 --+
 --+     t_hold_lo ::= minimum interval the low  logic level input data
 --+                   must remain at its latching level after the active
 --+                   edge of the clock. Defaults to 0 ns.
 --+
 --+
 --+     This subprogram has been designed as a procedure to facilitate
 --+     its use both in sequential code, but also in concurrent code
 --+     as a passive concurrent procedure call.
 --+
 --+    USE        :
 --+
 --+     check_d :  HoldCheck (
 --+                             TestPort       => D,     --+Data line
 --+                             TestPortName   => "D",   --+string
 --+                             RefPort        => CLK,   --+CLK signal
 --+                             RefPortName    => "CLK",
 --+                             t_hold_hi      => 45 ns,
 --+                             t_hold_lo      => 45 ns,
 --+                             condition      => (CLK = '0'),
 --+                             HeaderMsg      => InstanceHeader
 --+                           );
 --+ ---------------------------------------------------------------------------
        PROCEDURE HoldCheck (
            SIGNAL   TestPort     : IN     std_ulogic;    -- SIGNAL being tested
            CONSTANT TestPortName : IN     STRING := "";  -- name OF the signal
            SIGNAL   RefPort      : IN     std_ulogic;    -- SIGNAL being referenced
            CONSTANT RefPortName  : IN     STRING := "";  -- name OF the ref signal
            CONSTANT t_hold_hi    : IN     TIME := 0 ns;  -- hold spec FOR test PORT = '1'
            CONSTANT t_hold_lo    : IN     TIME := 0 ns;  -- hold spec FOR test PORT = '0'
            CONSTANT condition    : IN     BOOLEAN;       -- IF true THEN the
                                                          -- spec will be checked.
            CONSTANT HeaderMsg    : IN     STRING := " "
                                  ) IS

        VARIABLE Violation : BOOLEAN := FALSE;
    BEGIN
        Violation := HoldViolation ( TestPort, TestPortName,
                                     RefPort,  RefPortName,
                                     t_hold_hi,t_hold_lo,
                                     condition,
                                     HeaderMsg
                                     );
    END HoldCheck;

 --+ -----------------------------------------------------------------
 --+  Function       : ReleaseViolation
 --+      parameters :
 --+         IN      : CtrlPort       -- SIGNAL    std_logic
 --+         IN      : CtrlPortName   -- CONSTANT  string
 --+         IN      : RefPort        -- SIGNAL    std_logic
 --+         IN      : RefPortName    -- CONSTANT  string
 --+         IN      : DataPortVal    -- CONSTANT  std_logic
 --+         IN      : t_release_hi   -- CONSTANT  time
 --+         IN      : t_release_lo   -- CONSTANT  time
 --+         IN      : condition      -- CONSTANT  boolean
 --+         IN      : HeaderMsg      -- CONSTANT  string
 --+	     IN	     : WarningsOn     -- CONSTANT  boolean
 --+
 --+     returns     : boolean        -- TRUE if a violation occurred
 --+
 --+  Assumption :
 --+               Any change in the value of "RefPort" when "condition"
 --+               is TRUE is considered a triggering edge. This includes
 --+               changes only in the Strength of "RefPort".
 --+
 --+     Notes       :
 --+       In the formal parameter list of this routine, both the control
 --+       and reference signals are referenced along with their string
 --+       names.
 --+               _____________         ________________
 --+               _____________XXXXXXXXX________________  ctrl signal
 --+               ____________________________
 --+                                           \_________  ref signal
 --+                                 --->|     |<-----
 --+                                     t_release
 --+
 --+       t_release_hi ::= minimum interval preceding the triggering edge
 --+                      of the referenced signal for the logic release
 --+                      of the control signal when a high logic level
 --+                      is on the Data Port. Defaults to 0 ns.
 --+
 --+       t_release_lo ::= minimum interval preceding the triggering edge
 --+                      of the referenced signal for the logic release
 --+                      of the control signal when a low logic level
 --+                      is on the Data Port. Defaults to 0 ns.
 --+
 --+       This subprogram has been designed with both a function and
 --+       procedure interface (see "ReleaseCheck" ) to facilitate
 --+       its use both in sequential code and in concurrent code.
 --+
 --+      USE        :  Sequential code
 --+
 --+       IF ReleaseViolation    (
 --+                               CtrlPort       => R,     -- Data line
 --+                               CtrlPortName   => "R",   -- string
 --+                               RefPort        => CLK,   -- CLK signal
 --+                               RefPortName    => "CLK",
 --+                               DataPortVal    => D
 --+                               t_release_hi   => 23 ns,
 --+                               t_release_lo   => 23 ns,
 --+                               condition      => (CLK = '1') AND (R /= '1'),
 --+                               HeaderMsg      => InstanceHeader
 --+                             ) then
 --+           Q <= 'X';
 --+
 --+       END IF;
 --+
 --+ -----------------------------------------------------------------
    FUNCTION ReleaseViolation (
                SIGNAL   CtrlPort     : IN     std_ulogic;     -- SIGNAL being ctrled
                CONSTANT CtrlPortName : IN     STRING := "";   -- name OF the signal
                SIGNAL   RefPort      : IN     std_ulogic;     -- SIGNAL being referenced
                CONSTANT RefPortName  : IN     STRING := "";   -- name OF the ref signal
                CONSTANT DataPortVal  : IN     std_ulogic;     -- value to latch in
                CONSTANT t_release_hi : IN     TIME := 0 ns;   -- release spec FOR data = '1'
                CONSTANT t_release_lo : IN     TIME := 0 ns;   -- release spec FOR data = '0'
                CONSTANT condition    : IN     BOOLEAN;        -- IF true THEN the spec will be checked.
                CONSTANT HeaderMsg    : IN     STRING := " ";
		CONSTANT WarningsOn   : IN     BOOLEAN := TRUE -- IF TRUE assertions are generated
                                      ) RETURN BOOLEAN IS
        VARIABLE observed_time : TIME;
        VARIABLE expected_time : TIME;
        VARIABLE TestX01       : X01;
        VARIABLE Violation : BOOLEAN := FALSE;
    BEGIN
    -- note : additional error checking can be coded regarding the defaulting of
    --        t_release_lo or t_release_hi such that one or the other could be used to
    --        specify the release condition, however, IN the interest OF some code
    --        efficiency, the code was not provided. IF the ultimate protection
    --        IS  required, it can be written.

        -- ---------------------------------------------------------------------
        -- Active edge of reference signal
        -- ---------------------------------------------------------------------
        IF RefPort'EVENT AND condition AND (NOW > 0 ns) THEN
            TestX01 := To_X01(DataPortVal);
            IF (TestX01 = '1') THEN
                expected_time := t_release_hi;
            ELSIF (TestX01 = '0') THEN
                expected_time := t_release_lo;
            ELSE
                expected_time := MINIMUM (t_release_lo, t_release_hi);
            END IF; -- setup was violated
            observed_time := CtrlPort'LAST_EVENT;
            Violation     := (observed_time < expected_time);
            IF Violation THEN
                -------------------------------------------------------------
                -- some sort OF release violation occurred
                -------------------------------------------------------------
                IF (To_X01(CtrlPort'LAST_VALUE) = To_X01(CtrlPort)) THEN
                    ---------------------------------------------------------
                    -- the "state" did not change, only the strength did
                    ---------------------------------------------------------
                    report_soft_error (
                                HeaderMsg, "RELEASE ", TestX01,
                                CtrlPortName, RefPortName,
                                expected_time, observed_time,
                                CtrlPort'LAST_VALUE, CtrlPort,
				WarningsOn );
                ELSE
                    ---------------------------------------------------------
                    -- the "state" changed ( hard ) violation
                    ---------------------------------------------------------
                    report_error (
                                HeaderMsg, "RELEASE ", TestX01,
                                CtrlPortName, RefPortName,
                                expected_time, observed_time,
				WarningsOn );
                END IF;
            END IF;
        END IF;
        RETURN (Violation);
    END ReleaseViolation;

    FUNCTION ReleaseViolation (
                SIGNAL   CtrlPort     : IN     std_ulogic;     -- SIGNAL being ctrled
                CONSTANT CtrlPortName : IN     STRING := "";   -- name OF the signal
                SIGNAL   RefPort      : IN     std_ulogic;     -- SIGNAL being referenced
                CONSTANT RefPortName  : IN     STRING := "";   -- name OF the ref signal
                CONSTANT DataPortVal  : IN     std_ulogic;     -- value being latched
                CONSTANT t_release_hi : IN     TIME := 0 ns;   -- release spec for DATA = '1'
                CONSTANT t_release_lo : IN     TIME := 0 ns;   -- release spec for DATA = '0'
                CONSTANT t_hold_hi    : IN     TIME ;          -- hold spec for DATA = '1'
                CONSTANT t_hold_lo    : IN     TIME ;          -- hold spec for DATA = '0'
                CONSTANT condition    : IN     BOOLEAN;        -- true ==> spec checked.
                CONSTANT HeaderMsg    : IN     STRING := " ";
		CONSTANT WarningsOn   : IN     BOOLEAN := TRUE -- IF TRUE assertions are generated
                                      ) RETURN BOOLEAN IS

        VARIABLE Violation     : BOOLEAN := FALSE;
        VARIABLE observed_time : TIME;
        VARIABLE expected_time : TIME;
        VARIABLE constrnt_time : TIME;
        VARIABLE TestX01       : X01;
    BEGIN

    -- note : additional error checking can be coded regarding the defaulting of
    --        t_release_lo or t_release_hi such that one or the other could be used to
    --        specify the release condition, however, IN the interest OF some code
    --        efficiency, the code was not provided. IF the ultimate protection
    --        IS  required, it can be written.
        IF condition AND (NOW > 0 ns) THEN
            -- -----------------------------------------------------------------
            -- Active edge of reference signal - check release time
            -- -----------------------------------------------------------------
            IF RefPort'EVENT THEN
                TestX01 := To_X01(DataPortVal);
                IF (TestX01 = '1') THEN
                    expected_time :=  t_release_hi;
                    constrnt_time := -t_hold_hi;
                ELSIF (TestX01 = '0') THEN
                    expected_time :=  t_release_lo;
                    constrnt_time := -t_hold_lo;
                ELSE
                    expected_time := MINIMUM ( t_release_lo,  t_release_hi);
                    constrnt_time := MINIMUM (-t_hold_lo , -t_hold_hi );
                END IF; -- release was violated
                observed_time := CtrlPort'LAST_EVENT;
                --------------------------------------------------------------------
                -- some sort of release violation occurred
                --------------------------------------------------------------------
                IF (observed_time < expected_time) THEN
                    Violation := TRUE;
                    IF (observed_time < constrnt_time) THEN
                        ------------------------------------------------------------
                        -- Test signal change within negative hold window
                        ------------------------------------------------------------
                        report_possible_error (
                                        HeaderMsg, "RELEASE ", TestX01,
                                        CtrlPortName, RefPortName,
                                        expected_time, observed_time,
                                        constrnt_time, WarningsOn );
                    ELSIF (To_X01(CtrlPort'LAST_VALUE) = To_X01(CtrlPort)) THEN
                        ------------------------------------------------------------
                        -- the "state" did not change, only the strength did
                        ------------------------------------------------------------
                        report_soft_error (
                                        HeaderMsg, "RELEASE ", TestX01,
                                        CtrlPortName, RefPortName,
                                        expected_time, observed_time,
                                        CtrlPort'LAST_VALUE, CtrlPort,
					WarningsOn );
                    ELSE
                        ------------------------------------------------------------
                        -- the "state" changed ( hard ) violation
                        ------------------------------------------------------------
                        report_error (  HeaderMsg, "RELEASE ", TestX01,
                                        CtrlPortName, RefPortName,
                                        expected_time, observed_time,
					WarningsOn );
                    END IF;
                END IF;
            --------------------------------------------------------------------
            -- test signal change 
            -- Note: If time to previous CtrlPort change was available, only the
            --       first hold violation could be reported - but alas.
            --------------------------------------------------------------------
            ELSIF CtrlPort'EVENT THEN
                TestX01 := To_X01(DataPortVal);
                IF    (TestX01 = '1') THEN
                    expected_time := t_hold_hi;
                    constrnt_time := -t_release_hi;
                ELSIF (TestX01 = '0') THEN
                    expected_time := t_hold_lo;
                    constrnt_time := -t_release_lo;
                ELSE
                    expected_time := MINIMUM (t_hold_lo, t_hold_hi);
                    constrnt_time := MINIMUM (-t_release_lo , -t_release_hi );
                END IF;
                observed_time := RefPort'LAST_EVENT;
                ----------------------------------------------------------------
                -- some sort of hold violation occurred
                -- violation = hold_violation  AND
                --             violation not in negative release window   AND
                ----------------------------------------------------------------
                IF (observed_time < expected_time) AND 
                   (observed_time > constrnt_time)
                THEN
                    Violation := TRUE;
                    IF (To_X01(CtrlPort'LAST_VALUE) = To_X01(CtrlPort)) THEN
                        --------------------------------------------------------
                        -- the "state" did not change, only the strength did
                        --------------------------------------------------------
                        report_soft_error (
                                    HeaderMsg, "HOLD  ", TestX01,
                                    CtrlPortName, RefPortName,
                                    expected_time, observed_time,
                                    CtrlPort'LAST_VALUE, CtrlPort,
				    WarningsOn );
                    ELSE
                        --------------------------------------------------------
                        -- the "state" changed ( hard ) violation
                        --------------------------------------------------------
                        report_error (
                                    HeaderMsg, "HOLD  ", TestX01,
                                    CtrlPortName, RefPortName,
                                    expected_time, observed_time,
				    WarningsOn );
                    END IF;
                END IF; -- Violation
            END IF;
        END IF; -- condition and NOW > 0 ns;
        RETURN (Violation);
    END ReleaseViolation;


 --+ -----------------------------------------------------------------
 --+  Procedure Name : ReleaseCheck
 --+      parameters :
 --+         IN      : CtrlPort       -- SIGNAL    std_ulogic
 --+         IN      : CtrlPortName   -- CONSTANT  string
 --+         IN      : RefPort        -- SIGNAL    std_ulogic
 --+         IN      : RefPortName    -- CONSTANT  string
 --+         IN      : DataPortVal    -- CONSTANT  std_ulogic
 --+         IN      : t_release_hi   -- CONSTANT  time
 --+         IN      : t_release_lo   -- CONSTANT  time
 --+         IN      : condition      -- CONSTANT  boolean
 --+         IN      : HeaderMsg      -- CONSTANT  string
 --+
 --+  Assumption :
 --+               Any change in the value of "RefPort" when "condition"
 --+               is TRUE is considered a triggering edge. This includes
 --+               changes only in the Strength of "RefPort".
 --+
 --+     Notes       : See "ReleaseViolation"
 --+
 --+      USE        : Concurrent code
 --+
 --+       check_d : ReleaseCheck (
 --+                                 CtrlPort       => R,     -- Data line
 --+                                 CtrlPortName   => "R",   -- string
 --+                                 RefPort        => CLK,   -- CLK signal
 --+                                 RefPortName    => "CLK",
 --+                                 DataPortVal    => D
 --+                                 t_release_hi   => 23 ns,
 --+                                 t_release_lo   => 23 ns,
 --+                                 condition      => (CLK = '1') AND (R /= '1'),
 --+                                 HeaderMsg      => InstanceHeader
 --+                                );
 --+ -----------------------------------------------------------------
    PROCEDURE ReleaseCheck (
                SIGNAL   CtrlPort     : IN     std_ulogic;    -- SIGNAL being ctrled
                CONSTANT CtrlPortName : IN     STRING := "";  -- name OF the signal
                SIGNAL   RefPort      : IN     std_ulogic;    -- SIGNAL being referenced
                CONSTANT RefPortName  : IN     STRING := "";  -- name OF the ref signal
                CONSTANT DataPortVal  : IN     std_ulogic;    -- value to latch in
                CONSTANT t_release_hi : IN     TIME := 0 ns;  -- release spec FOR data = '1'
                CONSTANT t_release_lo : IN     TIME := 0 ns;  -- release spec FOR data = '0'
                CONSTANT condition    : IN     BOOLEAN;       -- IF true THEN the
                CONSTANT HeaderMsg    : IN     STRING := " "
                                      ) IS

        VARIABLE Violation : BOOLEAN := FALSE;
    BEGIN
        Violation := ReleaseViolation ( CtrlPort,      CtrlPortName,
                                        RefPort,       RefPortName,
                                        DataPortVal,
                                        t_release_hi,  t_release_lo,
                                        condition,
                                        HeaderMsg
                                       );
    END ReleaseCheck;

    PROCEDURE ReleaseCheck (
            SIGNAL   CtrlPort          : IN     std_ulogic;   -- signal being ctrled
            CONSTANT CtrlPortName      : IN     STRING := ""; -- name of the signal
            SIGNAL   RefPort           : IN     std_ulogic;   -- signal being referenced
            CONSTANT RefPortName       : IN     STRING := ""; -- name of the ref signal
            CONSTANT DataPortVal       : IN     std_ulogic;   -- value being latched
            CONSTANT t_release_hi      : IN     TIME := 0 ns; -- release spec for DATA = '1'
            CONSTANT t_release_lo      : IN     TIME := 0 ns; -- release spec for DATA = '0'
            CONSTANT t_hold_hi         : IN     TIME ;        -- hold spec for DATA = '1'
            CONSTANT t_hold_lo         : IN     TIME ;        -- hold spec for DATA = '0'
            CONSTANT condition         : IN     BOOLEAN;      -- true ==> spec checked.
            CONSTANT HeaderMsg         : IN     STRING := " "
                                       ) IS

        VARIABLE LocalViolation : BOOLEAN := FALSE;
    BEGIN
        LocalViolation := ReleaseViolation ( CtrlPort,     CtrlPortName,
                                              RefPort,      RefPortName,
                                              DataPortVal,
                                              t_release_hi, t_release_lo,
                                              t_hold_hi,    t_hold_lo,
                                              condition,
                                              HeaderMsg
                                          );
    END ReleaseCheck;

 --+ -----------------------------------------------------------------
 --+  Procedure Name : PeriodCheck
 --+      parameters :
 --+         IN      : TestPort       -- SIGNAL    being tested for periodicity
 --+         IN      : TestPortName   -- CONSTANT  string representing the name of the tested signal
 --+         IN      : RefPort        -- CONSTANT  SIGNAL or VALUE which adds a data dependent condition to the test
 --+         IN      : RefPortName    -- CONSTANT  string ::= name of the signal whose value affects the test
 --+         IN      : period_min     -- CONSTANT  time ::= minimum period
 --+         IN      : period_max     -- CONSTANT  time ::= maximum period
 --+         IN      : pw_hi_min_hi   -- CONSTANT  time ::= minimum high pulse width when RefPort  = '1'
 --+         IN      : pw_hi_min_lo   -- CONSTANT  time ::= minimum high pulse width when RefPort  = '0'
 --+         IN      : pw_hi_max      -- CONSTANT  time ::= maximum high pulse width
 --+         IN      : pw_lo_min_hi   -- CONSTANT  time ::= maximum low  pulse width when RefPort  = '1'
 --+         IN      : pw_lo_min_lo   -- CONSTANT  time ::= maximum high pulse width when RefPort  = '0'
 --+         IN      : pw_lo_max      -- CONSTANT  time ::= maximum low  pulse width
 --+         INOUT   : info           -- VARIABLE  -- retains time info from one cycle to the next
 --+         OUT     : violation      -- VARIABLE  Boolean; TRUE if violation occurred
 --+         IN      : HeaderMsg      -- CONSTANT  string ::= device hierarchical path
 --+	     IN	     : WarningsOn     -- CONSTANT  Boolean; if TRUE then assertions are generated
 --+
 --+
 --+     Notes       :
 --+
 --+                    _______________         __________
 --+       ____________|               |_______|
 --+
 --+                   |<--- pw_hi --->|
 --+                   |<-------- period ----->|
 --+                                -->| pw_lo |<--
 --+
 --+      USE        : This procedure must be used in conjunction
 --+                   with a process statement in order to retain
 --+                   the transition times to '0' and '1'
 --+
 --+        check_clk : Process (clk)
 --+              variable PeriodCheckInfo : PeriodCheckInfoType := PeriodCheckInfo_Init;
 --+              variable violation : boolean := false;
 --+        begin
 --+                PeriodCheck (
 --+                               TestPort       => CLK,
 --+                               TestPortName   => "CLK",
 --+                               RefPort        => J,
 --+                               RefPortName    => "J",
 --+                               period_min     => 50 ns,
 --+                               period_max     => 10 us,
 --+                               pw_hi_min_hi   => 10 ns,
 --+                               pw_hi_min_lo   => 10 ns,
 --+                               pw_hi_max      =>  5 us,
 --+                               pw_lo_min_hi   => 20 ns,
 --+                               pw_lo_min_lo   => 20 ns,
 --+                               pw_lo_max      =>  5 us,
 --+                               info           => PeriodCheckInfo,
 --+                               violation      => violation,
 --+                               HeaderMsg      => InstanceHeader
 --+                             );
 --+                if violation then
 --+                     Q <= 'X';
 --+                end if;
 --+        end process check_clk;
 --+
 --+ -----------------------------------------------------------------
    PROCEDURE PeriodCheck  (
                SIGNAL   TestPort     : IN     std_ulogic;
                CONSTANT TestPortName : IN     STRING := "";
                CONSTANT RefPort      : IN     std_ulogic := 'X';    -- SIGNAL being referenced
                CONSTANT RefPortName  : IN     STRING := "";  -- name OF the ref signal
                CONSTANT PeriodMin    : IN     TIME := 0 ns;
                CONSTANT PeriodMax    : IN     TIME := TIME'HIGH;
                CONSTANT pw_hi_min_hi : IN     TIME := 0 ns;
                CONSTANT pw_hi_min_lo : IN     TIME := 0 ns;
                CONSTANT pw_hi_max    : IN     TIME := TIME'HIGH;
                CONSTANT pw_lo_min_hi : IN     TIME := 0 ns;
                CONSTANT pw_lo_min_lo : IN     TIME := 0 ns;
                CONSTANT pw_lo_max    : IN     TIME := TIME'HIGH;
                VARIABLE info         : INOUT  PeriodCheckInfoType;
                VARIABLE Violation    : OUT    BOOLEAN;
                CONSTANT HeaderMsg    : IN     STRING := " ";
		CONSTANT WarningsOn   : IN     BOOLEAN := TRUE -- IF TRUE assertions are generated
                                      ) IS
        CONSTANT t0    : INTEGER := 0;
        CONSTANT t1    : INTEGER := 1;

        VARIABLE observed_time : TIME;
        VARIABLE expected_time : TIME;
        VARIABLE period  : TIME;
        VARIABLE ref_val : STRING(1 TO 7) := " = 'X')";

    BEGIN

        Violation := FALSE;
        period := PeriodMin;
        IF NOW = 0 ns THEN
            info(t0) := 0 ns;
            info(t1) := 0 ns;

        ELSIF    rising_edge (TestPort) THEN
            -- -----------------------------------------------------------------
            -- Compute period and record Rising Time
            -- -----------------------------------------------------------------
            period   := NOW - info(t1);
            info(t1) := NOW;
            -- -----------------------------------------------------------------
            -- Validate Pulse LOW width
            -- -----------------------------------------------------------------
            observed_time := info(t1) - info(t0);
            IF ( observed_time > pw_lo_max ) THEN
                Violation := TRUE;
                report_sig_error (
                            HeaderMsg, TestPortName,
                            " LOW PULSE WIDTH IS TOO LONG",
                            pw_lo_max, observed_time,
			    WarningsOn );
            END IF;

            IF    (To_X01(RefPort) = '0') THEN
                expected_time := pw_lo_min_lo;
                ref_val(5) := '0';
            ELSIF (To_X01(RefPort) = '1') THEN
                expected_time := pw_lo_min_hi;
                ref_val(5) := '1';
            ELSE
                expected_time := MINIMUM (pw_lo_min_lo,pw_lo_min_hi);
                ref_val(5) := 'X';
            END IF;
            IF ( observed_time < expected_time ) AND
               ( NOW >= pw_lo_min_hi )               -- ignore 1st edge
            THEN
                Violation := TRUE;
                report_sig_error ( 
                            HeaderMsg, TestPortName,
                            " SHORT LOW PULSE (with " & RefPortName & ref_val,
                            expected_time, observed_time, WarningsOn );
            END IF;

        ELSIF falling_edge (TestPort) THEN

            -- -----------------------------------------------------------------
            -- Compute period and record Falling Time
            -- -----------------------------------------------------------------
            period   := NOW - info(t0);
            info(t0) := NOW;
            -- -----------------------------------------------------------------
            -- Validate Pulse HIGH width
            -- -----------------------------------------------------------------
            observed_time := info(t0) - info(t1);
            IF ( observed_time > pw_hi_max ) THEN
                Violation := TRUE;
                report_sig_error (
                            HeaderMsg, TestPortName,
                            " HIGH PULSE WIDTH IS TOO LONG",
                            pw_hi_max, observed_time, WarningsOn );
            END IF;

            IF    (To_X01(RefPort) = '0') THEN
                expected_time := pw_hi_min_lo;
                ref_val(5) := '0';
            ELSIF (To_X01(RefPort) = '1') THEN
                expected_time := pw_hi_min_hi;
                ref_val(5) := '1';
            ELSE
                expected_time := MINIMUM (pw_hi_min_lo,pw_hi_min_hi);
                ref_val(5) := 'X';
            END IF;
            IF ( observed_time < expected_time ) AND
               ( NOW >= pw_lo_min_hi )               -- ignore 1st edge
            THEN
                Violation := TRUE;
                report_sig_error ( 
                            HeaderMsg, TestPortName,
                            " SHORT HIGH PULSE (with " & RefPortName & ref_val,
                            expected_time, observed_time, WarningsOn );
            END IF;
        END IF;
        -- ---------------------------------------------------------------------
        -- Validate the Period
        -- ---------------------------------------------------------------------
        IF (period > PeriodMax) THEN
            Violation := TRUE;
            report_sig_error ( HeaderMsg, TestPortName,
                               " PERIOD IS TOO LONG",
                               PeriodMax, period, WarningsOn );
        END IF;

        IF ( period < PeriodMin ) AND ( NOW > PeriodMin ) THEN  -- prevent startup messages
            report_sig_error ( HeaderMsg, TestPortName,
                               " PERIOD IS TOO SHORT",
                               PeriodMin, period, WarningsOn );
            Violation := TRUE;
        END IF;

    END PeriodCheck;

 --+ -----------------------------------------------------------------
 --+  Procedure Name : PulseCheck
 --+      parameters :
 --+         IN      : TestPort       -- SIGNAL    std_ulogic
 --+         IN      : TestPortName   -- CONSTANT  string
 --+         IN      : t_pulse_hi     -- CONSTANT  time
 --+         IN      : t_pulse_lo     -- CONSTANT  time
 --+         INOUT   : timemark       -- VARIABLE  time
 --+         IN      : HeaderMsg      -- CONSTANT  string
 --+
 --+     Notes       :
 --+       This procedure tests for pulses of less than the specified
 --+       width which occur on the test signal.
 --+       A pulse is defined as two EVENTs which occur in close time
 --+       proximity to one another such that the time interval between
 --+       events is less than some specified time.
 --+
 --+       (TestPort 'LAST_EVENT is not useful since 'LAST_EVENT = 0 ns
 --+       when test_port'EVENT is TRUE )
 --+
 --+       Two specifications apply :
 --+
 --+                       ___________          _______
 --+             _____XXXXX           XXX______/        ref signal
 --+
 --+                   -->|           |<---             high pulse width
 --+                                 -->|      |<---    low  pulse width
 --+
 --+
 --+       t_pulse_hi ::= minimum allowable time between the last time
 --+                      the test port changed value and the current
 --+                      time when the new TestPort  values is '0'.
 --+
 --+       t_pulse_hi ::= minimum allowable time between the last time
 --+                      the test port changed value and the current
 --+                      time when the new TestPort  values is '1'.
 --+
 --+      example of use :
 --+
 --+       check_clr : process ( clr )
 --+                       variable timemark : time;
 --+                   begin
 --+                        PulseCheck (
 --+                               TestPort       => CLR,   -- Clear line
 --+                               TestPortName   => "CLR", -- string
 --+                               t_pulse_hi     => 23 ns,
 --+                               t_pulse_lo     => 23 ns,
 --+                               timemark       => timemark,
 --+                               HeaderMsg      => InstanceHeader
 --+                             );
 --+                   end process check_clr;
 --+
 --+
 --+ -----------------------------------------------------------------
    PROCEDURE PulseCheck (
                SIGNAL   TestPort     : IN     std_ulogic;     -- SIGNAL being tested
                CONSTANT TestPortName : IN     STRING := "";   -- name OF the signal
                CONSTANT t_pulse_hi   : IN     TIME := TIME'HIGH; --
                CONSTANT t_pulse_lo   : IN     TIME := TIME'HIGH; --
                VARIABLE timemark     : INOUT  TIME;        -- time variable
                CONSTANT HeaderMsg    : IN     STRING := " "
                                      ) IS
        VARIABLE observed_time : TIME;
    BEGIN

        IF NOW = 0 ns THEN
            timemark      := NOW;
        ELSIF (TestPort'EVENT) THEN
            observed_time := NOW - timemark;
            timemark      := NOW;
            -----------------------------------------------------------
            -- high values
            -----------------------------------------------------------
            IF    (To_X01(TestPort'LAST_VALUE) = '1') AND
                  ( observed_time < t_pulse_hi)
            THEN
                report_sig_error ( HeaderMsg, TestPortName,
                                   "SHORT HIGH PULSE WAS DETECTED",
                                   t_pulse_hi, observed_time );

            -----------------------------------------------------------
            -- low values
            -----------------------------------------------------------
            ELSIF (To_X01(TestPort'LAST_VALUE) = '0') AND
                  ( observed_time < t_pulse_lo)
            THEN
                report_sig_error ( HeaderMsg, TestPortName,
                                   "SHORT LOW PULSE WAS DETECTED",
                                   t_pulse_lo, observed_time );
            END IF;
        END IF;
    END PulseCheck;

 --+ -----------------------------------------------------------------
 --+  Procedure Name : SpikeCheck
 --+      parameters :
 --+         IN      : TestPort       -- SIGNAL    std_logic
 --+         IN      : TestPortName   -- CONSTANT  string
 --+         IN      : t_spike_hi     -- CONSTANT  time
 --+         IN      : t_spike_lo     -- CONSTANT  time
 --+         INOUT   : timemark       -- VARIABLE  time
 --+         IN      : HeaderMsg      -- CONSTANT  string
 --+
 --+     Notes       :
 --+       This procedure tests for spikes which occur on the test signal
 --+       A spike is defined as two EVENTs which occur in close time
 --+       proximity to one another such that the time interval between
 --+       events is less than some specified time.
 --+
 --+       (test_port'LAST_EVENT is not useful since 'LAST_EVENT = 0 ns
 --+       when test_port'EVENT is TRUE )
 --+
 --+       Two specifications apply :
 --+
 --+       t_spike_hi ::= minimum allowable time between the last time
 --+                      the test port changed value and the current
 --+                      time when the test port is '1'.
 --+
 --+       t_spike_lo ::= minimum allowable time between the last time
 --+                      the test port changed value and the current
 --+                      time when the test port is '0'.
 --+
 --+      example of use :
 --+
 --+       check_clr : process
 --+                       variable timemark : time;
 --+                   begin
 --+                        SpikeCheck (
 --+                               TestPort       => CLR,   -- Clear line
 --+                               TestPortName   => "CLR", -- string
 --+                               t_spike_hi     => 23 ns,
 --+                               t_spike_lo     => 23 ns,
 --+                               timemark       => timemark,
 --+                               HeaderMsg      => InstanceHeader
 --+                             );
 --+                   end process check_clr;
 --+
 --+
 --+ -----------------------------------------------------------------
    PROCEDURE SpikeCheck (
                SIGNAL   TestPort     : IN     std_ulogic;     -- SIGNAL being tested
                CONSTANT TestPortName : IN     STRING := "";   -- name OF the signal
                CONSTANT t_spike_hi   : IN     TIME := TIME'HIGH; --
                CONSTANT t_spike_lo   : IN     TIME := TIME'HIGH; --
                VARIABLE timemark     : INOUT  TIME;        -- time variable
                CONSTANT HeaderMsg    : IN     STRING := " "
                                      ) IS
        VARIABLE observed_time : TIME;
    BEGIN

        IF NOW = 0 ns THEN
            timemark      := NOW;
        ELSIF (TestPort'EVENT) THEN
            observed_time := NOW - timemark;
            timemark      := NOW;
            -----------------------------------------------------------
            -- high values
            -----------------------------------------------------------
            IF    (To_X01(TestPort'LAST_VALUE) = '1') AND
                  ( observed_time < t_spike_hi)
            THEN
                report_sig_error ( HeaderMsg, TestPortName,
                                   "HIGH SPIKE DETECTED",
                                   t_spike_hi, observed_time );

            -----------------------------------------------------------
            -- low values
            -----------------------------------------------------------
            ELSIF (To_X01(TestPort'LAST_VALUE) = '0') AND
                  ( observed_time < t_spike_lo)
            THEN
                report_sig_error ( HeaderMsg, TestPortName,
                                   "LOW SPIKE DETECTED",
                                   t_spike_lo, observed_time );
            END IF;
        END IF;
    END SpikeCheck;

 --+ ---------------------------------------------------------------------------
 --+  Procedure  Name : SkewCheck
 --+      parameters :
 --+         IN      : TestPort          -- SIGNAL    std_logic_vector
 --+         IN      : TestPortName	 -- CONSTANT  string
 --+         IN      : RefPort		 -- SIGNAL    std_logic
 --+         IN      : RefPortName	 -- CONSTANT  string
 --+	     IN	     : tskew		 -- CONSTANT  time
 --+	     IN	     : CheckEnabled	 -- CONSTANT  boolean
 --+         IN      : HeaderMsg         -- CONSTANT  string
 --+	     INOUT   : CheckForSkew	 -- VARIABLE  boolean
 --+	     INOUT   : Violation	 -- VARIABLE  boolean
 --+	     IN	     : WarningsOn	 -- CONSTANT  boolean
 --+
 --+  NOTE:  If CheckEnabled is FALSE no check is performed.
 --+
 --+     Notes       :
 --+       In the formal parameter list of this routine, both the test
 --+       and reference signals are referenced along with their string
 --+       names.
 --+             _____________         ____________
 --+             _____________XXXXXXXXX____________XXXXXXXX  test signal
 --+             ____________________________
 --+                                         \_____________  ref signal
 --+                                      -->|     |<--- + tskew
 --+                               --->|     |<-----     - tskew
 --+	         **** error region ****|           |**** error region ****      
 --+ ---------------------------------------------------------------------------
 --+
 --+       tskew ::= maximum interval preceeding and following the triggering 
 --+                 edge of the referenced signal in which the test signal
 --+		     is allowed to change
 --+ ---------------------------------------------------------------------------
    PROCEDURE SkewCheck (
            SIGNAL   TestPort          : IN     std_ulogic;     -- SIGNAL being tested
            CONSTANT TestPortName      : IN     STRING := "";	-- name OF the signal
            SIGNAL   RefPort           : IN     std_ulogic;	-- SIGNAL being referenced
            CONSTANT RefPortName       : IN     STRING := "";	-- name OF the ref signal
            CONSTANT tskew	       : IN     TIME := 0 ns;	-- skew spec.
	    CONSTANT CheckEnabled      : IN	BOOLEAN;	-- if true then spec. is checked
            CONSTANT HeaderMsg         : IN     STRING := " ";
	    VARIABLE CheckForSkew      : INOUT  BOOLEAN;    	-- not to be modified by user
	    VARIABLE Violation	       : INOUT  BOOLEAN;    	-- TRUE if violation occurs
	    CONSTANT WarningsOn	       : IN	BOOLEAN := TRUE -- if true then assertions are generated
                                       ) IS


       variable expected_time, observed_time : time;

    BEGIN
       Violation := FALSE;
       if CheckEnabled then
	  expected_time := abs(tskew);
	  if (TestPort'Event or RefPort'Event) then
	     CheckForSkew := NOT CheckForSkew;
	  end if;
	  if (CheckForSkew and (TestPort'Event or RefPort'Event)) then
	     observed_time := abs(TestPort'LAST_EVENT - RefPort'LAST_EVENT);
	     if (observed_time > expected_time) then
	        Violation := TRUE;
		assert NOT WarningsOn
		   report HeaderMsg & " " & "SKEW VIOLATION ON " & TestPortName &
			  " WITH RESPECT TO " & RefPortName & SMC_CR & AssertionFill &
			  "  Expected := " & Default_Time (expected_time) &
			  "; Observed := " & Default_Time (observed_time) &
			  "; At : "        & Default_Time ( NOW )
		   SEVERITY ERROR;
	     end if;
	  end if;
       end if;
    END SkewCheck;
    
-- ****************************************************************************
-- Time Related Functions
-- ****************************************************************************

     --+ ---------------------------------------------------------------------
     --+  Function   : MAXIMUM
     --+  Returns    : time
     --+  Purpose    : This function returns the maximum of a set of time
     --+             : values.
     --+             :
     --+  Overloading: This function is overloaded to provide...
     --+             : 1. MAXIMUM of two time values
     --+             : 2. MAXIMUM of any element of an aggregate of values
     --+             :
     --+  Arguments  : As shown below...
     --+             :
     --+  Assumption : none
     --+  Example    :
     --+             :
     --+     SUBTYPE tv4 is time_vector ( 1 to 4 );
     --+     CONSTANT t_max  : time := MAXIMUM ( tplh, tphl );
     --+     CONSTANT t_maxv : time := MAXIMUM ( tv4'(tp01, tp02, tp03, tp04 ));
     --+ ---------------------------------------------------------------------
        FUNCTION MAXIMUM ( CONSTANT t1,t2 : IN TIME ) RETURN TIME IS
        BEGIN
            IF ( t1 > t2 ) THEN RETURN (t1); ELSE RETURN (t2); END IF;
        END MAXIMUM;
     --+ ---------------------------------------------------------------------
        FUNCTION MAXIMUM ( CONSTANT t1,t2,t3,t4 : IN TIME ) RETURN TIME IS
          VARIABLE result : TIME;
        BEGIN
            result := t1;
            IF ( t2 > result ) THEN result := t2; END IF;
            IF ( t3 > result ) THEN result := t3; END IF;
            IF ( t4 > result ) THEN result := t4; END IF;
            RETURN result;
        END MAXIMUM;
     --+ ---------------------------------------------------------------------
        FUNCTION MAXIMUM ( CONSTANT tv    : IN TIME_Vector ) RETURN TIME IS
            VARIABLE result : TIME := TIME'LOW;
        BEGIN
            FOR i IN tv'RANGE LOOP
                IF tv(i) > result THEN
                    result := tv(i);
                END IF;
            END LOOP;
            RETURN (result);
        END MAXIMUM;

     --+ ---------------------------------------------------------------------
     --+  Function   : MINIMUM
     --+  Returns    : time
     --+  Purpose    : This function returns the minimum of a set of time
     --+             : values.
     --+             :
     --+  Overloading: This function is overloaded to provide...
     --+             : 1. MINIMUM of two time values
     --+             : 2. MINIMUM of any element of an aggregate of values
     --+             :
     --+  Arguments  : As shown below...
     --+             :
     --+  Assumption : none
     --+  Example    :
     --+             :
     --+     SUBTYPE tv4 is time_vector ( 1 to 4 );
     --+     CONSTANT t_min  : time := MINIMUM ( tplh, tphl );
     --+     CONSTANT t_minv : time := MINIMUM ( tv4'(tp01, tp02, tp03, tp04 ));
     --+ ---------------------------------------------------------------------
        FUNCTION MINIMUM ( CONSTANT t1,t2 : IN TIME ) RETURN TIME IS
        BEGIN
            IF ( t1 < t2 ) THEN RETURN (t1); ELSE RETURN (t2); END IF;
        END MINIMUM;
     --+ ---------------------------------------------------------------------
        FUNCTION MINIMUM ( CONSTANT t1,t2,t3,t4 : IN TIME ) RETURN TIME IS
          VARIABLE result : TIME;
        BEGIN
            result := t1;
            IF ( t2 < result ) THEN result := t2; END IF;
            IF ( t3 < result ) THEN result := t3; END IF;
            IF ( t4 < result ) THEN result := t4; END IF;
            RETURN result;
        END MINIMUM;
     --+ ---------------------------------------------------------------------
        FUNCTION MINIMUM ( CONSTANT tv : IN TIME_Vector ) RETURN TIME IS
            VARIABLE result : TIME := TIME'HIGH;
        BEGIN
            FOR i IN tv'RANGE LOOP
                IF tv(i) < result THEN
                    result := tv(i);
                END IF;
            END LOOP;
            RETURN (result);
        END MINIMUM;

 --+ ************************************************************************
 --+ Output Strength Determination
 --+ ************************************************************************
        -----------------------------------------------------------------------
        -- Function   : Drive
        -- Returns    : std_ulogic, atd_ulogic_vector, std_logic_vector
        -- Purpose    : This function determines the proper strength of a
        --            : given output state depending upon the technology
        --            : begin modeled. This allows the user to develop a
        --            : technology independent model.
        --            :
        -- Overloading: This function is overloaded to provide a means of
        --            : specifying the strenghts for vectored and scalar signals
        --            :
        -- Arguments  : CONSTANT val  : IN <signal_type>
        --            : CONSTANT tech : IN TechnologyType
        --            :
        -- Assumption : none
        -- Example    : ( for an O/C NAND gate ) :
        --            :
        --    Y <= Drive(Convert_to_UX01(A) nand Convert_to_UX01(B)), ttl_oc );
        -----------------------------------------------------------------------

        TYPE stdlogic_1d IS ARRAY (std_ulogic) OF std_ulogic;
        TYPE TechnologyTable IS ARRAY( TechnologyType ) OF stdlogic_1d;
        -- This forcing function only applies over 'U' -> 'Z'
        CONSTANT TechnologyMap : TechnologyTable := (
            ( 'U','X','0','1','Z','W','L','H','-'), -- cmos
            ( 'U','X','0','Z','Z','W','L','H','-'), -- cmos_od
            ( 'U','X','0','1','Z','W','L','H','-'), -- ttl
            ( 'U','X','0','Z','Z','W','L','H','-'), -- ttl_od
            ( 'U','X','0','H','Z','W','L','H','-'), -- nmos
            ( 'U','X','L','1','Z','W','L','H','-'), -- ecl
            ( 'U','W','L','H','Z','W','L','H','-'), -- pullup
            ( 'U','W','L','H','Z','W','L','H','-')  -- pulldown
        );


        FUNCTION Drive ( CONSTANT val  : IN std_ulogic;        -- new signal value
                         CONSTANT tech : TechnologyType        -- technology type
                       ) RETURN std_ulogic IS
        BEGIN
            RETURN (TechnologyMap( tech )( val ));
        END Drive; -- std_ulogic

        -----------------------------------------------------------------------
        FUNCTION Drive ( CONSTANT val  : IN std_logic_vector;  -- new signal value
                         CONSTANT tech : TechnologyType        -- technology type
                       ) RETURN std_logic_vector IS
            VARIABLE result : std_logic_vector ( 1 TO val'LENGTH ) := val;
        BEGIN
            FOR i IN result'RANGE LOOP
                result(i) := TechnologyMap( tech )( result(i));
            END LOOP;
            RETURN ( result );
        END Drive; -- std_logic_vector

        -----------------------------------------------------------------------
        FUNCTION Drive ( CONSTANT val  : IN std_ulogic_vector; -- new signal value
                         CONSTANT tech : TechnologyType        -- technology type
                       ) RETURN std_ulogic_vector IS
            VARIABLE result : std_ulogic_vector ( 1 TO val'LENGTH ) := val;
        BEGIN
            FOR i IN result'RANGE LOOP
                result(i) := TechnologyMap( tech )( result(i));
            END LOOP;
            RETURN ( result );
        END Drive; -- std_ulogic_vector

END Std_Timing;
