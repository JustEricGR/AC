-------------------------------------------------------------------------
--
-- File name   :  timing_b.vhd
-- PackageName :  VITAL_TIMING
-- Title       :  Standard VITAL TIMING Package
-- Library     :  This package shall be compiled into a library
--             :  symbolically named VITAL.
--             :
-- Purpose     :  This packages defines a standard for designers
--             :  to use in developing ASIC models.
--             :
-- Comments    :  
--             :
-- Assumptions : none
-- Limitations : PulseWidthLimit is NOT IMPLEMENTED in this release. Implementation
--               depends upon the release of 1992 compliant simulators.
-- Known Errors: none
-- Developers  :  VITAL working group
--             :      Technical Director   : William Billowitch
--             :      European Coordinator : Eric Huyskens
--             :      U.S. Coordinator     : Steve Schulz
--             :
-- Note        :  No declarations or definitions shall be included in,
--             :  or excluded from this package. The "package declaration"
--             :  defines the types, subtypes and declarations of the
--             :  VITAL_TIMING. The VITAL_TIMING package body shall be
--             :  considered the formal definition of the semantics of
--             :  this package. Tool developers may choose to implement
--             :  the package body in the most efficient manner available
--             :  to them.
-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- This package is hereby released into the public domain. 

-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>> Derivative Works NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- Portions of the software provided in this package have been contributed
-- by the VHDL Technology Group. The contributed portions are hereby released into
-- the public domain. The VHDL Technology Group retains the right to include
-- the same contributed portions with its Std_Timing or other product offerings.
-- Contributed declarations have the designator {TVTG} affixed as a comment.

-- Portions of the software provided in this package have been contributed
-- by Ryan & Ryan. The contributed portions are hereby released into
-- the public domain.  Ryan & Ryan retains the right to include
-- the same contributed portions with its product offerings.
-- Contributed declarations have the designator {R&R} affixed as a comment.

-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>> Warrantee <<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- No warrantees, expressed or implied are given.
-- ----------------------------------------------------------------------------
-- Modification History :
-- ----------------------------------------------------------------------------
--   Version No:| Author:|  Mod. Date:| Changes Made:
--     v0.000   |   wdb  |  06/24/93  | THIS IS WORK-IN-PROGRESS (DO NOT DISTRIBUTE!!!)
--     v0.002   |   rjr  |  08/10/93  | THIS IS WORK-IN-PROGRESS (DO NOT DISTRIBUTE!!!)
--     v0.810   |   wdb  |  08/17/93  | Alpha Release
--     v0.900   |   wdb  |  09/08/93  | Beta Release
--     v0.901   |   rjr  |  09/17/93  | Beta Release - fix/update VitalGlitchOn... procedures
--     v0.902   |   rjr  |  10/06/93  | Fixes / updates related to primitives
--     v0.903   |   wdb  |  10/08/93  | Added UnitDelay constants + bug fixes
--     v0.904   |   wdb  |  11/03/93  | Bug fix to VitalGlitchOnEvent, add Condition param to VitalPeriodCheck
--     v0.905   |   wdb  |  11/12/93  | Minor speed up on VitalCalcDelay for 6-element delays
--     v0.906   |   wdb  |  11/30/93  | Added VITAL_LEVEL1 attribute
--     v0.907   |   rz   |  01/24/94  | Vital procedures and function names have been
--              |        |            |   extended by a leading <Vital>
--              |        |            | Parameter PulseRejectLimit removed from and bugs fixed in
--              |        |            |   procedure VitalGlitchOnEvent and
--              |        |            |   procedure VitalGlitchOnDetect
--              |        |            | Procedure VitalPropagatePathDelay included
--              |        |            | Procedure VitalPropagateWireelay added
--     v0.908   |   wrm  |  01/26/94  | Removed edge types and procedures
--     v0.909   |   wrm  |  02/25/94  | Removed most concurrent procedures.  Removed currentvalue function.
--              |        |            | Removed VitalTimingViolation.  Also, modified VitalSetupHoldCheck,
--              |        |            | VitalTimingCheck, and VitalPropagateWireDelay to deal with negative
--              |        |            | hold times.  VitalPropagateWireDelay also modified to assist those
--              |        |            | routines with negative hold times.
--     v0.910   |   wrm  |  03/02/94  | minor bug in VitalPeriodCheck assertion fixed. TimeMarketInit removed.
--     v0.911   |   sn   |  06/13/94  | Bug fixes for:
--                                      - VitalGlitchOnEvent for "MessageOnly"
--                                      - VitalPropagatePathDelay for "Noglitch"
--                                      - VitalPropagatePathDelay checks if
--                                        there is a new output value to be
--                                        scheduled. This fixes many existing
--                                        bugs, regarding 
--                                        - Incorrect Tpath < Tlast warnings
--                                        - Extra glitch messages in some cases
--                                      - VitalTimingCheck for run-time
--                                        integer-overflow error
--                                      - VitalGlitchOnEvent/VitalGlitchOnDetect
--                                        when new value is 'X'
--                                      - GetCheckTimes for negative constraints
--                                      Additions:
--                                      - VitalPeriodCheck overloaded for 
--                                        violation flag of type X01.
--                                      Cleanups:
--                                      - The info parameter to the PeriodCheck
--                                        procedure is of a predefined subtype
--                                      - GlitchKind On_Detect has been changed
--                                        to OnDetect (to make it consistent
--                                        with OnEvent)
--                                      - Condition parameter in VitalPerioCheck
--                                        has been renamed to CheckEnabled
--                                      Known Bugs:
--                                      - For some cases of negative hold/setup checks
-- ----------------------------------------------------------------------------
-- Notes:
--      1) The order of the values in TransitionType is different from the
--         order of these values in SDF
--      2) A Generic parameter (ie tpd_EN_Q ) for the delay from a 3-state
--         enable to the output only uses [tr0z,trz0,tr1z,trz1]
-- ----------------------------------------------------------------------------

LIBRARY STD;
USE STD.TEXTIO.all;

PACKAGE BODY VITAL_Timing IS

    FUNCTION PrintBanner RETURN boolean is
    BEGIN
        assert false
        report LF & "------------------------------------------------" &
               LF & "--  Initializing: VITAL_TIMING package v0.910 --" &
               LF & "------------------------------------------------"
        severity NOTE;
        RETURN true;
    END;
    CONSTANT PrintIt : Boolean := PrintBanner;
    
    -- --------------------------------------------------------------------
    -- Package Local Declarations
    -- --------------------------------------------------------------------
    CONSTANT SMC_CR       : STRING(1 TO 2) := ';' & LF; --{TVTG}
    TYPE MVL9CvtTableType is Array (Std_ulogic) of character; -- {TVTG}
    CONSTANT MVL9CvtTable : MVL9CvtTableType := ( 'U', 'X', '0', '1', 'Z', 'W', 'L', 'H', '-'); -- {TVTG}
    TYPE hilo_str_type   IS ARRAY (std_ulogic range 'X' to '1') OF STRING(1 TO 2); -- {TVTG}
    CONSTANT hilo_str     : hilo_str_type := ("X ", "LO", "HI" ); -- {TVTG}    

    ---------------------------------------------------------------------------
    -- examples of usage:
    ---------------------------------------------------------------------------
    -- tpd_CLK_Q : DelayTypeXX       := 5 ns;
    -- tpd_CLK_Q ; DelayType01       := (tr01 => 2 ns, tr10 => 3 ns);
    -- tpd_CLK_Q ; DelayType01Z      := ( 1 ns, 2 ns, 3 ns, 4 ns, 5 ns, 6 ns );
    -- tpd_CLK_Q : DelayArrayTypeXX(0 to 1)  := (0 => 5 ns, 
    --                                           1 => 6 ns);
    -- tpd_CLK_Q ; DelayArrayType01(0 to 1)  := (0 => (tr01 => 2 ns, tr10 => 3 ns),
    --                                           1 => (tr01 => 2 ns, tr10 => 3 ns));
    -- tpd_CLK_Q ; DelayArrayType01Z(0 to 1) := (0 => ( 1 ns, 2 ns, 3 ns, 4 ns, 5 ns, 6 ns ),
    --                                           1 => ( 1 ns, 2 ns, 3 ns, 4 ns, 5 ns, 6 ns ));

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    -- Misc Utilities Local Utilities
    ---------------------------------------------------------------------------
    -----------------------------------------------------------------------
        FUNCTION MINIMUM ( CONSTANT t1,t2 : IN TIME ) RETURN TIME IS
        BEGIN
            IF ( t1 < t2 ) THEN RETURN (t1); ELSE RETURN (t2); END IF;
        END MINIMUM;
    -----------------------------------------------------------------------
        FUNCTION MAXIMUM ( CONSTANT t1,t2 : IN TIME ) RETURN TIME IS
        BEGIN
            IF ( t1 > t2 ) THEN RETURN (t1); ELSE RETURN (t2); END IF;
        END MAXIMUM;

    ---------------------------------------------------------------------------

    FUNCTION GlitchMinTime ( CONSTANT time1, time2 : IN TIME ) RETURN TIME IS   -- {R&R}
    BEGIN
        IF ( time1 > NOW ) THEN
                IF ( time2 > NOW ) THEN
                  RETURN MINIMUM ( time1, time2);
                ELSE 
                  RETURN time1;
                END IF;
        ELSE 
                IF ( time2 > NOW ) THEN
                   RETURN time2;
                ELSE 
                   RETURN 0 ns;
                END IF;
        END IF;
    END;
    
    ---------------------------------------------------------------------------
    -- Time Delay Assignment Subprograms
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    -- Function   : VitalExtendToFillDelay
    -- Returns    : A six element array of time values which follow the Verilog
    --              default <path_delay_expression> assignment rules.
    -- Purpose    : To provide a set of six transition dependent time values
    --              for use in delay assignments even though only 1,2 or 3 values
    --              of delay may have been provided.
    -- Arguments  : See the declarations below...
    ---------------------------------------------------------------------------
    FUNCTION VitalExtendToFillDelay ( delay : IN TransitionArrayType ) RETURN DelayType01Z IS
            VARIABLE d_val  : DelayType01Z;
    BEGIN
        CASE delay'length IS
          WHEN  1  =>   d_val := (others => delay(tr01));
          WHEN  2  =>   d_val(tr01) := delay(tr01);
                        d_val(tr0z) := delay(tr01);
                        d_val(trz1) := delay(tr01);
                        d_val(tr10) := delay(tr10);
                        d_val(tr1z) := delay(tr10);
                        d_val(trz0) := delay(tr10);
          WHEN  3  =>   d_val(tr01) := delay(tr01);
                        d_val(trz1) := delay(tr01);
                        d_val(tr10) := delay(tr10);
                        d_val(trz0) := delay(tr10);
                        d_val(tr0z) := delay(tr0z);
                        d_val(tr1z) := delay(tr0z);
          WHEN  6  =>   d_val := delay;
          WHEN  others  => assert false report "VitalExtendToFillDelay(delay'length /= [1,2,3,6])" SEVERITY ERROR; 
        END CASE;
        RETURN (d_val);
    END VitalExtendToFillDelay;
    ---------------------------------------------------------------------------
    -- Function   : VitalCalcDelay
    -- Returns    : A scalar time value or a vector of time values, one for each subelement
    -- Purpose    : This function determines the proper value of delay to
    --            : use given the newly assigned value and the existing
    --            : value on the signal or driver.
    --            :
    -- Overloading: This function is overloaded to provide 
    --            : (a) transition dependent delays for a scalar
    --            : (b) non-transition dependent (i.e. newval only-dependent) delay for a scalar
    --            : (c) transition dependent delays for a std_ulogic_vector 
    --            : (d) non-transition dependent (i.e. newval only-dependent) delay for a std_ulogic_vector
    --            : (e) transition dependent delays for a std_logic_vector 
    --            : (f) non-transition dependent (i.e. newval only-dependent) delay for a std_logic_vector 
    --            :
    -- Arguments  : See the declarations below...
    --            :
    -- Defaults   : Notice that the routines will autorange the delay parameter
    --            : such that if a (tr01, tr10) subarray is passed, then the values
    --            : for tr0z, trz0, tr1z, and trz1 will be derived.
    -- Assumption : newval'length = oldval'length for vectored signals
    --
    -- Note       : (a) transitions from a known state -> x occur as quickly as possible
    --            : (b) transitions from 'X' to a known state occur as slowly as possible
    ---------------------------------------------------------------------------
    -- Returns a single value of time dependent upon the transition
    ---------------------------------------------------------------------------
    FUNCTION VitalCalcDelay (
                         CONSTANT    newval : IN std_ulogic;        -- new value of signal
                         CONSTANT    oldval : IN std_ulogic;        -- old value of signal
                         CONSTANT    delay  : IN TransitionArrayType := UnitDelay
                       ) RETURN DelayTypeXX IS -- {TVTG}
            VARIABLE result : time;
            VARIABLE d_val  : DelayType01Z;
    BEGIN
        -- Only expand those which require it.
        if (delay'LENGTH /= 6) then
            d_val := VitalExtendToFillDelay(delay);
        else
            d_val := delay;
        end if;
        CASE oldval IS
          WHEN '0' |
               'L'  =>  CASE newval IS
                            WHEN '0' |
                                 'L'    => result := d_val(tr10);
                            WHEN '1' |
                                 'H'    => result := d_val(tr01);
                            WHEN 'Z'    => result := d_val(tr0z);
                            WHEN OTHERS => result := MINIMUM(d_val(tr01), d_val(tr0z));
                        END CASE;
          WHEN '1' |     
               'H'  =>  CASE newval IS
                            WHEN '0' |
                                 'L'    => result := d_val(tr10);
                            WHEN '1' |
                                 'H'    => result := d_val(tr01);
                            WHEN 'Z'    => result := d_val(tr1z);
                            WHEN OTHERS => result := MINIMUM(d_val(tr10), d_val(tr1z));
                        END CASE;
          WHEN 'Z'  =>  CASE newval IS
                            WHEN '0' |
                                 'L'    => result := d_val(trz0);
                            WHEN '1' |
                                 'H'    => result := d_val(trz1);
                            WHEN 'Z'    => result := MAXIMUM (d_val(tr0z), d_val(tr1z));
                            WHEN OTHERS => result := MINIMUM (d_val(trz1), d_val(trz0));
                        END CASE;
          WHEN 'U' |
               'X' |
               'W' |
               '-'  =>  CASE newval IS
                            WHEN '0' |
                                 'L'    => result := MAXIMUM(d_val(tr10), d_val(trz0));
                            WHEN '1' |
                                 'H'    => result := MAXIMUM(d_val(tr01), d_val(trz1));
                            WHEN 'Z'    => result := MAXIMUM(d_val(tr1z), d_val(tr0z));
                            WHEN OTHERS => result := MAXIMUM(d_val(tr10), d_val(tr01));
                        END CASE;
          END CASE;
          RETURN result;
    END VitalCalcDelay;
    ---------------------------------------------------------------------------
    FUNCTION VitalCalcDelay (
                         CONSTANT    newval : IN std_ulogic;        -- new value of signal
                         CONSTANT    delay  : IN TransitionArrayType := UnitDelay 
                       ) RETURN DelayTypeXX IS -- {TVTG}

    BEGIN
        Return (VitalCalcDelay (newval, '-', delay));
    END VitalCalcDelay;
	

    ---------------------------------------------------------------------------
    -- Procedure  : VitalPropagatePathDelay
    -- Purpose    : Calculate output delays based upon the signal values
    --            : 
    -- Arguments  : See the declarations below...
    --            :
    -- Example    :
    --
    --      Path_QN : Process (QN_zd)
    --          Variable GlitchData : GlitchDataType;
    --      begin
    --      VitalPropagatePathDelay(
    --          OutSignal                => QN,       -- Actual OUTPUT signal
    --          OutSignalName            => ÒQNÓ,
    --          OutTemp                  => QN_zd,    -- Zero delayed internal Output signal
    --
    --          -- First of four input pins which affect the output 
    --          Paths(0).InputChangeTime => CLK_ipdÕlast_event,
    --          Paths(0).PathDelay       => tpd_CLK_QN,
    --          Paths(0).Condition       => TRUE,
    --
    --          -- Second of four input pins which affect the output 
    --          Paths(1).InputChangeTime => PN_ipdÕlast_event,
    --          Paths(1).PathDelay       => tpd_PN_QN,
    --          Paths(1).Condition       => TRUE,
    --
    --          -- Third of four input pins which affect the output 
    --          Paths(2).InputChangeTime => CN_ipdÕlast_event,
    --          Paths(2).PathDelay       => tpd_CN_QN,
    --          Paths(2).Condition       => TRUE,
    --
    --          -- Fourth of four input pins which affect the output 
    --          Paths(3).InputChangeTime => 0 ns,
    --          Paths(3).PathDelay       => tpd_zero,
    --          Paths(3).Condition       => ViolationFlag = Õ1Õ),
    --
    --          GlitchData               => GLitchData,
    --          GlitchMode               => Xonly,
    --          GlitchKind               => OnEvent);
    --      end process Path_QN;
    --
    ---------------------------------------------------------------------------
    
    PROCEDURE VitalPropagatePathDelay (
        SIGNAL   OutSignal     : OUT   std_logic;  -- output signal
        CONSTANT OutSignalName : IN    string;     -- name of the output signal
        CONSTANT OutTemp       : IN    std_logic;  -- 0-delay output
        CONSTANT Paths         : IN    PathArrayType;  -- all possible paths
        VARIABLE GlitchData    : INOUT GlitchDataType;
        CONSTANT GlitchMode    : IN    GlitchModeType;
        CONSTANT GlitchKind    : IN    GlitchKind := OnEvent -- glitch kind 
        ) IS

        variable Tlast, Tpath, T1:  TIME := TIME'RIGHT;

    BEGIN
        -- Check if the new value to be scheduled is different than the 
        -- previously scheduled value

        IF (GlitchData.LastSchedValue = OutTemp) 
             THEN RETURN;
        END IF;

        FOR i IN Paths'RANGE LOOP
            if Paths(i).PathCondition = TRUE then
                if Paths(i).InputChangeTime < Tlast then
                    -- Get the delay from the most recent input change
                    Tpath := VitalCalcDelay(OutTemp, GlitchData.LastSchedValue,
                                            Paths(i).PathDelay);
                    Tlast  := Paths(i).InputChangeTime;
                elsif Paths(i).InputChangeTime = Tlast then
                    -- Simultaneous inputs change
                    T1 := VitalCalcDelay(OutTemp, GlitchData.LastSchedValue,
                                         Paths(i).PathDelay);
                    if T1 <= Tpath then -- This is the shortest path
                        Tpath := T1;
                    end if;
                end if;
            end if;
        END LOOP;
        -- Ensure that the correct delay is selected
        if (Tpath  = TIME'HIGH ) then
            -- Check if none of the condition for this output path are TRUE.
            -- Issue WARNING and schedule after 0 ns.
            assert FALSE report
             "No PathCondition TRUE for output path " & OutSignalName & 
             ".  Using 0-delay"
             severity WARNING;
            Tpath := 0 ns;
        elsif (Tpath >= Tlast) then
            -- Use the delay from the most recently changed input signal
            Tpath := Tpath-Tlast;
        elsif (Tpath < Tlast) then
            -- Issue warning and schedule at the current time.
            assert FALSE report
             "Path length for " & OutSignalName &
             " is shorter than last input change. Using 0-delay"
             severity WARNING;
            Tpath := 0 ns;
        end if;
 
        -- Call VITAL glitch handler
        -- Assumption: It will be modified to take care of the Reject and XLimit
        --             cases. Else, we might have to write our own version of
        --             this procedure.
 
        if GlitchKind = OnEvent then
            VitalGlitchOnEvent (OutSignal, OutSignalName, GlitchData, OutTemp,
                           Tpath, GlitchMode, 0 ns);  -- GlitchDelay := 0 ns
        else
            VitalGlitchOnDetect (OutSignal, OutSignalName, GlitchData, OutTemp,
                           Tpath, GlitchMode, 0 ns); -- GlitchDelay := 0 ns
        end if;
    END VitalPropagatePathDelay;


    ---------------------------------------------------------------------------------
    -- Procedure   : VitalPropagateWireDelay
    -- Purpose     : Delay an input or output port by the appropriate wire delay
    --             : 
    -- Arguments   : See the declarations below...
    --             :
    -- Description : outsig <= TRANSPORT insig after VitalCalcDelay( insig, twire );
    --
    ----------------------------------------------------------------------------------

    PROCEDURE VitalPropagateWireDelay (
        SIGNAL   OutSig        : OUT   std_ulogic;    -- output signal delayed by port or net delay
        SIGNAL   InSig         : IN    std_ulogic;    -- input signal
        CONSTANT twire         : IN    DelayType01Z;  -- wire delay
        CONSTANT t_hold_hi     : IN    TIME := 0 ns;  -- hold spec FOR test PORT = '1'
        CONSTANT t_hold_lo     : IN    TIME := 0 ns   -- hold spec FOR test PORT = '0'
        ) IS

       variable delay : time := 0 ns;
       variable t_insig    : std_ulogic := To_X01(InSig);

    BEGIN
        if ( (t_hold_hi < 0 ns) or (t_hold_lo < 0 ns) ) then
           delay := ABS(MINIMUM(t_hold_hi, t_hold_lo));
        end if;
        outsig <= TRANSPORT insig after (VitalCalcDelay( insig, insig'LAST_VALUE, twire ) + delay);
    END VitalPropagateWireDelay;    
	

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    -- Setup and Hold Time Check Routine 
    ---------------------------------------------------------------------------
    SUBTYPE string9 IS STRING(1 TO 9);
    SUBTYPE string7 IS STRING(1 TO 7);
    TYPE RR_strings IS ARRAY (ViolationType) OF string9;
    TYPE SH_strings IS ARRAY (ViolationType) OF string7;
    CONSTANT SH_messages : SH_strings := (" NoVio ", " SETUP ", " HOLD  " );
    CONSTANT RR_messages : RR_strings := (" NoVio   ", " RELEASE ", " REMOVAL " );
    
    ----------------------------------------------------------------------------------------
    PROCEDURE VitalReportSetupHoldViolation (
            CONSTANT TestPortName      : IN string := "";     -- name OF the signal
            CONSTANT RefPortName       : IN string := "";     -- name OF the ref signal
            CONSTANT HeaderMsg         : IN string := " ";
            CONSTANT TimingInfo        : IN TimingInfoType    -- Timing Violation Information
    ) IS
        VARIABLE StrPtr1, StrPtr2, StrPTr3 : LINE;
    BEGIN
        IF (TimingInfo.Violation = NoViolation) THEN RETURN; END IF;

        Write (StrPtr1, TimingInfo.ExpectedTime);
        Write (StrPtr2, TimingInfo.ObservedTime);
        Write (StrPtr3, NOW);

        ASSERT FALSE
          REPORT HeaderMsg & SH_messages(TimingInfo.Violation) & 
                 HiLo_str(TimingInfo.State) & 
                 " VIOLATION ON " & TestPortName &
                 " WITH RESPECT TO " & RefPortName & SMC_CR &
                 "  Expected := " & StrPtr1.all &
                 "; Observed := " & StrPtr2.all &
                 "; At : "        & StrPtr3.all
          SEVERITY ERROR;

        DEALLOCATE (StrPtr1);
        DEALLOCATE (StrPtr2);
        DEALLOCATE (StrPtr3);
    END VitalReportSetupHoldViolation;

    PROCEDURE VitalReportRlseRmvlViolation (
            CONSTANT TestPortName      : IN string := "";     -- name OF the signal
            CONSTANT RefPortName       : IN string := "";     -- name OF the ref signal
            CONSTANT HeaderMsg         : IN string := " ";
            CONSTANT TimingInfo        : IN TimingInfoType    -- Timing Violation Information
    ) IS
        VARIABLE StrPtr1, StrPtr2, StrPTr3 : LINE;
    BEGIN
        IF (TimingInfo.Violation = NoViolation) THEN RETURN; END IF;

        Write (StrPtr1, TimingInfo.ExpectedTime);
        Write (StrPtr2, TimingInfo.ObservedTime);
        Write (StrPtr3, NOW);

        ASSERT FALSE
          REPORT HeaderMsg & RR_messages(TimingInfo.Violation) &
                 HiLo_str(TimingInfo.State) & 
                 " VIOLATION ON " & TestPortName &
                 " WITH RESPECT TO " & RefPortName & SMC_CR & 
                 "  Expected := " & StrPtr1.all &
                 "; Observed := " & StrPtr2.all &
                 "; At : "        & StrPtr3.all
          SEVERITY ERROR;

        DEALLOCATE (StrPtr1);
        DEALLOCATE (StrPtr2);
        DEALLOCATE (StrPtr3);
    END VitalReportRlseRmvlViolation;

    PROCEDURE GetCheckTimes ( 
            VARIABLE TimingInfo    : INOUT TimingInfoType;
            CONSTANT Violation     : IN    ViolationType;
            CONSTANT expected_hi   : IN    TIME := 0 ns;    -- expected  spec FOR TestPort = '1'
            CONSTANT expected_lo   : IN    TIME := 0 ns;    -- expected  spec FOR TestPort = '0'
            CONSTANT constrnt_hi   : IN    TIME := 0 ns;    -- constraint spec FOR TestPort = '1'
            CONSTANT constrnt_lo   : IN    TIME := 0 ns     -- constraint spec FOR TestPort = '0'
    ) IS
    BEGIN
        IF    (TimingInfo.State = '1') THEN
            TimingInfo.ExpectedTime :=  expected_hi;
            TimingInfo.ConstrntTime := -constrnt_lo;
        ELSIF (TimingInfo.State = '0') THEN
            TimingInfo.ExpectedTime :=  expected_lo;
            TimingInfo.ConstrntTime := -constrnt_hi;
        ELSE
            TimingInfo.ExpectedTime := MINIMUM ( expected_lo,   expected_hi );
            TimingInfo.ConstrntTime := MINIMUM (-constrnt_lo , -constrnt_hi );
        END IF;
        -- -------------------------------------------------------------------
        -- Check if Test signal changed illegally within the No-change window
        -- -------------------------------------------------------------------
        IF (TimingInfo.ObservedTime < TimingInfo.ExpectedTime) AND
           (TimingInfo.ObservedTime > TimingInfo.ConstrntTime)
            THEN TimingInfo.Violation := Violation;
        END IF;
    END;

  ----------------------------------------------------------------------------------------

    PROCEDURE SetupHoldCheck_Internal (
            CONSTANT TestPort            : IN    std_ulogic;     -- SIGNAL being tested
            SIGNAL   RefPort             : IN    std_ulogic;     -- SIGNAL being referenced
            CONSTANT t_setup_hi          : IN    TIME := 0 ns;   -- setup spec FOR TestPort = '1'
            CONSTANT t_setup_lo          : IN    TIME := 0 ns;   -- setup spec FOR TestPort = '0'
            CONSTANT t_hold_hi           : IN    TIME := 0 ns;   -- hold  spec FOR TestPort = '1'
            CONSTANT t_hold_lo           : IN    TIME := 0 ns;   -- hold  spec FOR TestPort = '0'
            CONSTANT CheckEnabled        : IN    BOOLEAN;        -- spec checked if true
            CONSTANT RefTransition       : IN    BOOLEAN;        -- specify reference edge
                                                                 -- i.e. CLK = '1' for rising edge
            VARIABLE RefTimeMarker       : INOUT Time;           -- holds time of last reference transition
            VARIABLE HoldCheckPassed     : INOUT Time;           -- last time a hold check passed
            VARIABLE LockOutCheck        : INOUT BOOLEAN;        -- Locks out further checks is a violation
                                                                 -- occurred and there is a neg. hold time
                                                                 -- Checks are reenabled at the ref. transition.
            VARIABLE TimingInfo          : INOUT TimingInfoType; -- timing violation ?
            CONSTANT TestPort_Event      : IN    BOOLEAN;        -- equivalent to TestPort'Event
            CONSTANT TestPort_Last_Event : IN    TIME;           -- equivalent to TestPort'Last_Event
            CONSTANT TestPort_Last_Value : IN    std_ulogic      -- equivalent to TestPort'Last_Value
    ) IS

       variable setup_hi, setup_lo, hold_hi, hold_lo, delay, hold_time  : time;

    BEGIN
    -- note : additional error checking can be coded regarding the defaulting of
    --        t_setup_lo or t_setup_hi such that one or the other could be used to
    --        specify the setup condition, however, IN the interest OF some code
    --        efficiency, the code was not provided. IF the ultimate protection
    --        IS  required, it can be written.
        TimingInfo.violation := NoViolation;
        if (RefPort'EVENT ) then  -- reenable checks at the reference edge
           LockOutCheck := FALSE;
        end if;
        if (CheckEnabled and not LockOutCheck)then
            if ( (t_hold_hi < 0 ns) or (t_hold_lo < 0 ns) ) then
               delay := ABS(MINIMUM(t_hold_hi, t_hold_lo));
               setup_hi := t_setup_hi - delay;
               setup_lo := t_setup_lo - delay;
               hold_lo := t_hold_lo + delay;
               hold_hi := t_hold_hi + delay;
            else
               delay := 0 ns;
               setup_hi := t_setup_hi;
               setup_lo := t_setup_lo;
               hold_hi := t_hold_hi;
               hold_lo := t_hold_lo;
            end if;
            -- -----------------------------------------------------------------
            -- Active edge of reference signal - check setup time
            -- -----------------------------------------------------------------
            IF (NOW > 0 ns) and RefPort'EVENT THEN
               TimingInfo.State := To_X01(TestPort);
               TimingInfo.ObservedTime :=  TestPort_Last_Event;
               GetCheckTimes ( TimingInfo, SetupViolation,
                               setup_hi, setup_lo, hold_hi, hold_lo );
            --------------------------------------------------------------------
            -- test signal change
            -- Note: If time to previous TestPort change was available, only the
            --       first hold violation could be reported - but alas.
            --------------------------------------------------------------------
            ELSIF TestPort_EVENT and (NOW > 0 ns) THEN
                TimingInfo.State        := To_X01(TestPort_LAST_VALUE);
                TimingInfo.ObservedTime := NOW - RefTimeMarker;
                if (HoldCheckPassed < RefTimeMarker) then  -- don't check for hold time if it already passed
                   GetCheckTimes ( TimingInfo, HoldViolation,
                                   hold_hi, hold_lo, setup_hi, setup_lo );
                   if (To_X01(TestPort_LAST_VALUE) = '0') then
                      hold_time := hold_lo;
                   elsif (To_X01(TestPort_LAST_VALUE) = '0') then
                      hold_time := hold_hi;
                   else
                      hold_time := MAXIMUM(hold_lo, hold_hi);
                   end if;
                   if ( (TimingInfo.Violation = NoViolation) and (NOW >= RefTimeMarker + hold_time) ) then
                      HoldCheckPassed := NOW;
                   end if;
                end if;
            END IF;
            if (TimingInfo.Violation /= NoViolation) then
               if ( (t_hold_hi < 0 ns) or (t_hold_lo < 0 ns) ) then
                  -- lock out further checks if a violation occurred and there was a negative hold time
                  LockOutCheck := TRUE;
               end if;
               if ( TestPort_Event and  (NOW < RefTimeMarker + delay) and (To_X01(TestPort) = '1') ) then
                  -- if hold_hi violation and negative hold then adjust report parameters to setup violation
                  TimingInfo.Violation := SetupViolation;
                  TimingInfo.ExpectedTime := t_setup_hi;
                  TimingInfo.ObservedTime := ABS(TimingInfo.ObservedTime - delay);
                  TimingInfo.State := '1';
               elsif ( TestPort_Event and  (NOW < RefTimeMarker + delay) and (To_X01(TestPort) = '0') ) then
                  -- if hold_lo violation and negative hold then adjust report parameters to setup violation
                  TimingInfo.Violation := SetupViolation;
                  TimingInfo.ExpectedTime := t_setup_lo;
                  TimingInfo.ObservedTime := ABS(TimingInfo.ObservedTime - delay);
                  TimingInfo.State := '0';
               elsif (TimingInfo.Violation = HoldViolation) then
                  -- adjust report paramter to proper values for hold time
                  TimingInfo.ExpectedTime := TimingInfo.ExpectedTime - delay;
                  TimingInfo.ObservedTime := TimingInfo.ObservedTime - delay;
               else
                  -- adjust report parameters to proper values
                  TimingInfo.ExpectedTime := TimingInfo.ExpectedTime + delay;
                  TimingInfo.ObservedTime := TimingInfo.ObservedTime + delay;
               end if;
            end if;
        end if; -- CheckEnabled
        if RefPort'Event and RefTransition then
           RefTimeMarker := NOW;
        end if;
    END SetupHoldCheck_Internal;

    PROCEDURE VitalSetupHoldCheck (
            SIGNAL   TestPort            : IN    std_ulogic;     -- SIGNAL being tested
            SIGNAL   RefPort             : IN    std_ulogic;     -- SIGNAL being referenced
            CONSTANT t_setup_hi          : IN    TIME := 0 ns;   -- setup spec FOR TestPort = '1'
            CONSTANT t_setup_lo          : IN    TIME := 0 ns;   -- setup spec FOR TestPort = '0'
            CONSTANT t_hold_hi           : IN    TIME := 0 ns;   -- hold  spec FOR TestPort = '1'
            CONSTANT t_hold_lo           : IN    TIME := 0 ns;   -- hold  spec FOR TestPort = '0'
            CONSTANT CheckEnabled        : IN    BOOLEAN;        -- spec checked if true
            CONSTANT RefTransition       : IN    BOOLEAN;        -- specify reference edge
                                                                 -- i.e. CLK = '1' for rising edge
            VARIABLE TimeMarker          : INOUT TimeMarkerType; -- holds time of last reference transiton
                                                                 -- and last time hold check passed
            VARIABLE TimingInfo          : INOUT TimingInfoType  -- timing violation ?
    ) is

    BEGIN
       if (TimeMarker.HoldCheckPassed = NULL) then
          TimeMarker.HoldCheckPassed := new TimeArray2(0 to 0);
          TimeMarker.LockOutCheck := new BoolArray(0 to 0);
       end if;
       SetupHoldCheck_Internal (
          TestPort            => TestPort,
          RefPort             => RefPort,
          t_setup_hi          => t_setup_hi,
          t_setup_lo          => t_setup_lo,
          t_hold_hi           => t_hold_hi,
          t_hold_lo           => t_hold_lo,
          CheckEnabled        => CheckEnabled,
          RefTransition       => RefTransition,
          RefTimeMarker       => TimeMarker.RefTimeMarker,
          HoldCheckPassed     => TimeMarker.HoldCheckPassed(0),
          LockOutCheck        => TimeMarker.LockOutCheck(0),
          TimingInfo          => TimingInfo,
          TestPort_Event      => TestPort'Event,
          TestPort_Last_Event => TestPort'Last_Event,
          TestPort_Last_value => TestPort'Last_Value
          );
    END VitalSetupHoldCheck;

    ---------------------------------------------------------------------------
    -- Function   : VitalTimingCheck
    -- Purpose    : This procedure (a) detects the presence of a setup or hold violation 
    --            : on the "TestPort" signal with respect to the "RefPort", (b) sets a flag
    --            : named "violation" accordingly and (c) issues an appropriate error message. 
    --            :
    -- Example    : ( Positive Hold Time )
    --            :
    --            ___________________________________________________________________
    -- TestPort   XXXXXXXXXXXX____________________________XXXXXXXXXXXXXXXXXXXXXXX____
    --            :
    --            :        -->|       error region       |<--
    --            :
    --            _______________________________  
    -- RefPort                                   \_______________________________________
    --            :           |                  |       |
    --            :           |               -->|       |<-- t_hold (e.g. positive hold time 
    --            :        -->|     t_setup      |<-- 
    --            :      (e.g. a positive setup time is shown)
    --            :
    --            :
    -- Example    : ( Negative Hold Time )
    --            :
    --            ___________________________________________________________________
    -- TestPort   XXXXXXXX____________________XXXXXXXXXXXXXXXXX______________________
    --            :
    --            :        -->| error region |<--
    --            :
    --            _______________________________  
    -- RefPort                                   \_______________________________________
    --            :           |              |   |
    --            :           |           -->|   |<-- t_hold (e.g. a negative hold time is shown
    --            :        -->|     t_setup      |<-- 
    --            :      (e.g. a positive setup time is shown)
    --            :
    --            :
    -- Parameters :
    --            :
    --            : t_setup_hi     ::= Absolute minimum time duration before the transition of 
    --            :                    the RefPort for which transitions of TestPort are allowed
    --            :                    to proceed to the '1' state without causing a setup violation.
    --            :
    --            : t_setup_lo     ::= Absolute minimum time duration before the transition of 
    --            :                    the RefPort for which transitions of TestPort are allowed
    --            :                    to proceed to the '0' state without causing a setup violation.
    --            :
    --            : t_hold_hi      ::= Absolute minimum time duration after the transition of 
    --            :                    the RefPort for which transitions of TestPort are allowed
    --            :                    to proceed to the '1' state without causing a hold violation.
    --            :
    --            : t_hold_lo      ::= Absolute minimum time duration after the transition of 
    --            :                    the RefPort for which transitions of TestPort are allowed
    --            :                    to proceed to the '0' state without causing a hold violation.
    --            :
    --            : CheckEnabled   ::= The function immediately checks CheckEnabled for a TRUE
    --            :                    value. If the value is FALSE, the FUNCTION immediately
    --            :                    returns with the value of FALSE ('X' or Violation of
    --            :                    subtype X01).
    --            :
    --            : RefTransition  ::= This specifies the condition on with an event on the
    --            :                    RefPort will be considered to be the reference event.
    --            :                    for instance CLK = '1' means that the reference event
    --            :                    is any transition to '1' by the signal CLK.
    --            :
    --            : HeaderMsg      ::= This HeaderMsg string will accompany any assertion
    --            :                    messages produced by this function.
    --            :
    --            : TimeMarker     ::= Holds the time of the last reference transition and the
    --            :                    last time that a hold check passed.  Must be associated
    --            :                    with an aggregate for initialization (-500 ns, NULL, NULL)
    --            :                    The user should never change the state of that variable
    --            :
    --            : Violation      ::= This routine will set the flag TRUE if a violation exists
    --            :                    and will set the flag FALSE if no violation exists.  For
    --            :                    Violation with X01 subtype then the flag is set to 'X' if
    --            :                    a violation occurred and to '0' if no violation occurred.
    --            :
    -- For vectors:
    --            :
    --            :
    --            : TestPortLastEvent ::= This VARIABLE is used to store the last time in
    --            :                       which TestPort changed value.
    --            :
    --            : TestPortLastValue ::= This VARIABLE is used to store the last value 
    --            :                       taken on by TestPort prior to its current value.
    --            :
    --            :
    --            : NOTE:              For positive hold times both a setup and a hold
    --            :                    error may be reported.  For both hold times negative
    --            :                    only one error may be reported per clock cycle and that
    --            :                    error will be a setup error.  For one negative hold time
    --            :                    the procedure will only report one error (setup or hold)
    --            :                    per clock cycle.  Negative setup times are not allowed.
    ---------------------------------------------------------------------------
    PROCEDURE VitalTimingCheck (
            SIGNAL   TestPort          : IN     std_ulogic;     -- SIGNAL being tested
            CONSTANT TestPortName      : IN     STRING := "";   -- name OF the signal
            SIGNAL   RefPort           : IN     std_ulogic;     -- SIGNAL being referenced
            CONSTANT RefPortName       : IN     STRING := "";   -- name OF the ref signal
            CONSTANT t_setup_hi        : IN     TIME := 0 ns;   -- setup spec FOR test PORT = '1'
            CONSTANT t_setup_lo        : IN     TIME := 0 ns;   -- setup spec FOR test PORT = '0'
            CONSTANT t_hold_hi         : IN     TIME := 0 ns;   -- hold spec FOR test PORT = '1'
            CONSTANT t_hold_lo         : IN     TIME := 0 ns;   -- hold spec FOR test PORT = '0'
            CONSTANT CheckEnabled      : IN     BOOLEAN;        -- true ==> spec checked.
            CONSTANT RefTransition     : IN     BOOLEAN;        -- specify reference edge
                                                                -- i.e. CLK = '1' for rising edge
            CONSTANT HeaderMsg         : IN     STRING := " ";
            VARIABLE TimeMarker        : INOUT  TimeMarkerType; -- holds time of last reference transition
                                                                -- and the last time a hold check passed
            VARIABLE Violation         : OUT    BOOLEAN
                                       ) IS -- {TVTG}

       variable TimingInfo : TimingInfoType;
                                       
    BEGIN
	   if NOW <= 0 ns then
		  TimeMarker.RefTimeMarker := -(MAXIMUM(ABS(t_hold_hi), ABS(t_hold_lo)));
       end if;

       if (TimeMarker.HoldCheckPassed = NULL) then
          TimeMarker.HoldCheckPassed := new TimeArray2(0 to 0);
          TimeMarker.LockOutCheck := new BoolArray(0 to 0);
       end if;
       SetupHoldCheck_Internal (
          TestPort            => TestPort,
          RefPort             => RefPort,
          t_setup_hi          => t_setup_hi,
          t_setup_lo          => t_setup_lo,
          t_hold_hi           => t_hold_hi,
          t_hold_lo           => t_hold_lo,
          CheckEnabled        => CheckEnabled,
          RefTransition       => RefTransition,
          RefTimeMarker       => TimeMarker.RefTimeMarker,
          HoldCheckPassed     => TimeMarker.HoldCheckPassed(0),
          LockOutCheck        => TimeMarker.LockOutCheck(0),
          TimingInfo          => TimingInfo,
          TestPort_Event      => TestPort'Event,
          TestPort_Last_Event => TestPort'Last_Event,
          TestPort_Last_value => TestPort'Last_Value
          );
        VitalReportSetupHoldViolation ( TestPortName, RefPortName, HeaderMsg, TimingInfo);
        Violation :=  TimingInfo.Violation /= NoViolation;
    END VitalTimingCheck;
    ---------------------------------------------------------------------------
    PROCEDURE VitalTimingCheck (
            SIGNAL   TestPort          : IN     std_ulogic;     -- SIGNAL being tested
            CONSTANT TestPortName      : IN     STRING := "";   -- name OF the signal
            SIGNAL   RefPort           : IN     std_ulogic;     -- SIGNAL being referenced
            CONSTANT RefPortName       : IN     STRING := "";   -- name OF the ref signal
            CONSTANT t_setup_hi        : IN     TIME := 0 ns;   -- setup spec FOR test PORT = '1'
            CONSTANT t_setup_lo        : IN     TIME := 0 ns;   -- setup spec FOR test PORT = '0'
            CONSTANT t_hold_hi         : IN     TIME := 0 ns;   -- hold spec FOR test PORT = '1'
            CONSTANT t_hold_lo         : IN     TIME := 0 ns;   -- hold spec FOR test PORT = '0'
            CONSTANT CheckEnabled      : IN     BOOLEAN;        -- true ==> spec checked.
            CONSTANT RefTransition     : IN     BOOLEAN;        -- specify reference edge
                                                                -- i.e. CLK = '1' for rising edge
            CONSTANT HeaderMsg         : IN     STRING := " ";
            VARIABLE TimeMarker        : INOUT  TimeMarkerType; -- holds time of last reference transition
                                                                -- and the last time a hold check passed
            VARIABLE Violation         : OUT    X01
                                       ) IS -- {TVTG}

       variable TimingInfo : TimingInfoType;
                                       
    BEGIN
	   if NOW <= 0 ns then
	   TimeMarker.RefTimeMarker := -(MAXIMUM(ABS(t_hold_hi), ABS(t_hold_lo)));
       end if;
       if (TimeMarker.HoldCheckPassed = NULL) then
          TimeMarker.HoldCheckPassed := new TimeArray2(0 to 0);
          TimeMarker.LockOutCheck := new BoolArray(0 to 0);
       end if;
       SetupHoldCheck_Internal (
          TestPort            => TestPort,
          RefPort             => RefPort,
          t_setup_hi          => t_setup_hi,
          t_setup_lo          => t_setup_lo,
          t_hold_hi           => t_hold_hi,
          t_hold_lo           => t_hold_lo,
          CheckEnabled        => CheckEnabled,
          RefTransition       => RefTransition,
          RefTimeMarker       => TimeMarker.RefTimeMarker,
          HoldCheckPassed     => TimeMarker.HoldCheckPassed(0),
          LockOutCheck        => TimeMarker.LockOutCheck(0),
          TimingInfo          => TimingInfo,
          TestPort_Event      => TestPort'Event,
          TestPort_Last_Event => TestPort'Last_Event,
          TestPort_Last_value => TestPort'Last_Value
          );
        VitalReportSetupHoldViolation ( TestPortName, RefPortName, HeaderMsg, TimingInfo);
        if (TimingInfo.Violation = NoViolation) then
           Violation := '0';
        else
           Violation := 'X';
        end if;
    END VitalTimingCheck;
    ------------------------------------------------------------------------------------
    PROCEDURE VitalTimingCheck (
            SIGNAL   TestPort          : IN     std_ulogic_vector; -- SIGNAL being tested
            CONSTANT TestPortName      : IN     STRING := "";      -- name OF the signal
            SIGNAL   RefPort           : IN     std_ulogic;        -- SIGNAL being referenced
            CONSTANT RefPortName       : IN     STRING := "";      -- name OF the ref signal
            CONSTANT t_setup_hi        : IN     TIME := 0 ns;      -- setup spec FOR test PORT = '1'
            CONSTANT t_setup_lo        : IN     TIME := 0 ns;      -- setup spec FOR test PORT = '0'
            CONSTANT t_hold_hi         : IN     TIME := 0 ns;      -- hold spec FOR test PORT = '1'
            CONSTANT t_hold_lo         : IN     TIME := 0 ns;      -- hold spec FOR test PORT = '0'
            CONSTANT CheckEnabled      : IN     BOOLEAN;           -- true ==> spec checked.
            CONSTANT RefTransition     : IN     BOOLEAN;           -- specify reference edge
            CONSTANT HeaderMsg         : IN     STRING := " ";
            VARIABLE TimeMarker        : INOUT  TimeMarkerType;    -- holds time of last Reference transition
                                                                   -- and the last time a hold check passed
            VARIABLE TestPortLastEvent : INOUT  DelayArrayTypeXX;  -- records time of test port events
            VARIABLE TestPortLastValue : INOUT  std_ulogic_vector; -- records previous test port values
            VARIABLE Violation         : OUT    BOOLEAN
                                       ) IS -- {TVTG}

        VARIABLE TimingInfo             : TimingInfoType;
        VARIABLE TestPort_LAST_EVENT    : TIME;
        VARIABLE TestPort_EVENT         : BOOLEAN;
        VARIABLE TestPort_LastValue     : std_ulogic_vector(TestPort'RANGE);
        VARIABLE simvendor_kludge       : std_ulogic_vector(1 to TestPort'Length + 1);
        VARIABLE ChangedAllAtOnce       : Boolean := TRUE;
        VARIABLE TestPortGroupLastEvent : time;
        VARIABLE last_change            : time;
        VARIABLE StrPtr1 : LINE;
    BEGIN
	   if NOW <= 0 ns then
		  TimeMarker.RefTimeMarker := -(MAXIMUM(ABS(t_hold_hi), ABS(t_hold_lo))); 
       end if;
      if (TimeMarker.HoldCheckPassed = NULL) then
         TimeMarker.HoldCheckPassed := new TimeArray2(TestPort'Range);
         TimeMarker.LockOutCheck := new BoolArray(TestPort'Range);
      end if;

      Violation := FALSE;

        -- note : additional error checking can be coded regarding the defaulting of
        --        t_setup_lo or t_setup_hi such that one or the other could be used to
        --        specify the setup condition, however, IN the interest OF some code
        --        efficiency, the code was not provided. IF the ultimate protection
        --        IS  required, it can be written.
        -- NOTE : TestPortLastEvent MUST be updated on each change of TestPort
        --        regardless of whether "Condition" is TRUE.
        -- note : TestPort_LAST_EVENT is actually TestPort'DELAYED(0 ns)'LAST_EVENT
        --        that is, it is not 0 ns when TestPort'EVENT is TRUE.
  
      -- simvendor bug-fix
      simvendor_kludge := TestPort'LAST_VALUE & "X";
      TestPort_LastValue := simvendor_kludge(1 to TestPort'Length);
 
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
        SetupHoldCheck_Internal (
           TestPort            => TestPort(i),
           RefPort             => RefPort,
           t_setup_hi          => t_setup_hi,
           t_setup_lo          => t_setup_lo,
           t_hold_hi           => t_hold_hi,
           t_hold_lo           => t_hold_lo,
           CheckEnabled        => CheckEnabled,
           RefTransition       => RefTransition,
           RefTimeMarker       => TimeMarker.RefTimeMarker,
           HoldCHeckPassed     => TimeMarker.HoldCheckPassed(i),
           LockOutCheck        => TimeMarker.LockOutCheck(i),
           TimingInfo          => TimingInfo,
           TestPort_Event      => TestPort_Event,
           TestPort_Last_Event => TestPort_Last_Event,
           TestPort_Last_Value => TestPortLastValue(i)
           );
           if (TimingInfo.Violation /= NoViolation) then
              Violation := TRUE;
              if ( ChangedAllAtOnce and (i = TestPort'Left) ) then
                 VitalReportSetupHoldViolation ( TestPortName => TestPortName & "(...)",
                                                 RefPortName  => RefPortName,
                                                 HeaderMsg    => HeaderMsg,
                                                 TimingInfo   => TimingInfo
                                               );
              elsif (not ChangedAllAtOnce) then
                 Write (strPtr1, i);
                 VitalReportSetupHoldViolation ( TestPortName => TestPortName & "(" & StrPtr1.all & ")",
                                                 RefPortName  => RefPortName,
                                                 HeaderMsg    => HeaderMsg,
                                                 TimingInfo   => TimingInfo
                                               );
              end if;
           end if;
        TestPortLastValue(i) := TestPort(i);
        DEALLOCATE (StrPtr1);
      END LOOP;
    END VitalTimingCheck;
    
    ------------------------------------------------------------------------------------
    PROCEDURE VitalTimingCheck (
            SIGNAL   TestPort          : IN     std_ulogic_vector; -- SIGNAL being tested
            CONSTANT TestPortName      : IN     STRING := "";      -- name OF the signal
            SIGNAL   RefPort           : IN     std_ulogic;        -- SIGNAL being referenced
            CONSTANT RefPortName       : IN     STRING := "";      -- name OF the ref signal
            CONSTANT t_setup_hi        : IN     TIME := 0 ns;      -- setup spec FOR test PORT = '1'
            CONSTANT t_setup_lo        : IN     TIME := 0 ns;      -- setup spec FOR test PORT = '0'
            CONSTANT t_hold_hi         : IN     TIME := 0 ns;      -- hold spec FOR test PORT = '1'
            CONSTANT t_hold_lo         : IN     TIME := 0 ns;      -- hold spec FOR test PORT = '0'
            CONSTANT CheckEnabled      : IN     BOOLEAN;           -- true ==> spec checked.
            CONSTANT RefTransition     : IN     BOOLEAN;           -- specify reference edge
            CONSTANT HeaderMsg         : IN     STRING := " ";
            VARIABLE TimeMarker        : INOUT  TimeMarkerType;    -- holds time of last Reference transition
                                                                   -- and the last time a hold check passed
            VARIABLE TestPortLastEvent : INOUT  DelayArrayTypeXX;  -- records time of test port events
            VARIABLE TestPortLastValue : INOUT  std_ulogic_vector; -- records previous test port values
            VARIABLE Violation         : OUT    X01
                                       ) IS -- {TVTG}

       Variable temp : BOOLEAN;

    BEGIN
       VitalTimingCheck (
          TestPort          => TestPort,
          TestPortName      => TestPortName,
          RefPort           => RefPort,
          RefPortName       => RefPortName,
          t_setup_hi        => t_setup_hi,
          t_setup_lo        => t_setup_lo,
          t_hold_hi         => t_hold_hi,
          t_hold_lo         => t_hold_lo,
          CheckEnabled      => CheckEnabled,
          RefTransition     => RefTransition,
          HeaderMsg         => HeaderMsg,
          TimeMarker        => TimeMarker,
          TestPortLastEvent => TestPortLastEvent,
          TestPortLastValue => TestPortLastValue,
          Violation         => temp
       );
       if temp then
          Violation := 'X';
       else
          Violation := '0';
       end if;
    END;

    ------------------------------------------------------------------------------------
    PROCEDURE VitalTimingCheck (
            SIGNAL   TestPort          : IN     std_logic_vector;  -- SIGNAL being tested
            CONSTANT TestPortName      : IN     STRING := "";      -- name OF the signal
            SIGNAL   RefPort           : IN     std_ulogic;        -- SIGNAL being referenced
            CONSTANT RefPortName       : IN     STRING := "";      -- name OF the ref signal
            CONSTANT t_setup_hi        : IN     TIME := 0 ns;      -- setup spec FOR test PORT = '1'
            CONSTANT t_setup_lo        : IN     TIME := 0 ns;      -- setup spec FOR test PORT = '0'
            CONSTANT t_hold_hi         : IN     TIME := 0 ns;      -- hold spec FOR test PORT = '1'
            CONSTANT t_hold_lo         : IN     TIME := 0 ns;      -- hold spec FOR test PORT = '0'
            CONSTANT CheckEnabled      : IN     BOOLEAN;           -- true ==> spec checked.
            CONSTANT RefTransition     : IN     BOOLEAN;           -- specify reference edge
            CONSTANT HeaderMsg         : IN     STRING := " ";
            VARIABLE TimeMarker        : INOUT  TimeMarkerType;    -- holds time of last Reference transition
                                                                   -- and the last time a hold check passed
            VARIABLE TestPortLastEvent : INOUT  DelayArrayTypeXX;  -- records time of test port events
            VARIABLE TestPortLastValue : INOUT  std_logic_vector;  -- records previous test port values
            VARIABLE Violation         : OUT    BOOLEAN
                                       ) IS -- {TVTG}

        VARIABLE TimingInfo             : TimingInfoType;
        VARIABLE TestPort_LAST_EVENT    : TIME;
        VARIABLE TestPort_EVENT         : BOOLEAN;
        VARIABLE TestPort_LastValue     : std_logic_vector(TestPort'RANGE);
        VARIABLE simvendor_kludge       : std_logic_vector(1 to TestPort'Length + 1);
        VARIABLE ChangedAllAtOnce       : Boolean := TRUE;
        VARIABLE TestPortGroupLastEvent : time;
        VARIABLE last_change            : time;
        VARIABLE StrPtr1 : LINE;
    BEGIN
	   if NOW <= 0 ns then
		  TimeMarker.RefTimeMarker := -(MAXIMUM(ABS(t_hold_hi), ABS(t_hold_lo))); 
       end if;
      if (TimeMarker.HoldCheckPassed = NULL) then
         TimeMarker.HoldCheckPassed := new TimeArray2(TestPort'Range);
         TimeMarker.LockOutCheck := new BoolArray(TestPort'Range);
      end if;

      Violation := FALSE;

        -- note : additional error checking can be coded regarding the defaulting of
        --        t_setup_lo or t_setup_hi such that one or the other could be used to
        --        specify the setup condition, however, IN the interest OF some code
        --        efficiency, the code was not provided. IF the ultimate protection
        --        IS  required, it can be written.
        -- NOTE : TestPortLastEvent MUST be updated on each change of TestPort
        --        regardless of whether "Condition" is TRUE.
        -- note : TestPort_LAST_EVENT is actually TestPort'DELAYED(0 ns)'LAST_EVENT
        --        that is, it is not 0 ns when TestPort'EVENT is TRUE.
  
      -- simvendor bug-fix
      simvendor_kludge := TestPort'LAST_VALUE & "X";
      TestPort_LastValue := simvendor_kludge(1 to TestPort'Length);
 
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
        SetupHoldCheck_Internal (
           TestPort            => TestPort(i),
           RefPort             => RefPort,
           t_setup_hi          => t_setup_hi,
           t_setup_lo          => t_setup_lo,
           t_hold_hi           => t_hold_hi,
           t_hold_lo           => t_hold_lo,
           CheckEnabled        => CheckEnabled,
           RefTransition       => RefTransition,
           RefTimeMarker       => TimeMarker.RefTimeMarker,
           HoldCheckPassed     => TimeMarker.HoldCheckPassed(i),
           LockOutCheck        => TimeMarker.LockOutCheck(i),
           TimingInfo          => TimingInfo,
           TestPort_Event      => TestPort_Event,
           TestPort_Last_Event => TestPort_Last_Event,
           TestPort_Last_Value => TestPortLastValue(i)
           );
           if (TimingInfo.Violation /= NoViolation) then
              Violation := TRUE;
              if ( ChangedAllAtOnce and (i = TestPort'Left) ) then
                 VitalReportSetupHoldViolation ( TestPortName => TestPortName & "(...)",
                                                 RefPortName  => RefPortName,
                                                 HeaderMsg    => HeaderMsg,
                                                 TimingInfo   => TimingInfo
                                               );
              elsif (not ChangedAllAtOnce) then
                 Write (strPtr1, i);
                 VitalReportSetupHoldViolation ( TestPortName => TestPortName & "(" & StrPtr1.all & ")",
                                                 RefPortName  => RefPortName,
                                                 HeaderMsg    => HeaderMsg,
                                                 TimingInfo   => TimingInfo
                                               );
              end if;
           end if;
        TestPortLastValue(i) := TestPort(i);
        DEALLOCATE (StrPtr1);
      END LOOP;
    END VitalTimingCheck;
    
    ------------------------------------------------------------------------------------
    PROCEDURE VitalTimingCheck (
            SIGNAL   TestPort          : IN     std_logic_vector;  -- SIGNAL being tested
            CONSTANT TestPortName      : IN     STRING := "";      -- name OF the signal
            SIGNAL   RefPort           : IN     std_ulogic;        -- SIGNAL being referenced
            CONSTANT RefPortName       : IN     STRING := "";      -- name OF the ref signal
            CONSTANT t_setup_hi        : IN     TIME := 0 ns;      -- setup spec FOR test PORT = '1'
            CONSTANT t_setup_lo        : IN     TIME := 0 ns;      -- setup spec FOR test PORT = '0'
            CONSTANT t_hold_hi         : IN     TIME := 0 ns;      -- hold spec FOR test PORT = '1'
            CONSTANT t_hold_lo         : IN     TIME := 0 ns;      -- hold spec FOR test PORT = '0'
            CONSTANT CheckEnabled      : IN     BOOLEAN;           -- true ==> spec checked.
            CONSTANT RefTransition     : IN     BOOLEAN;           -- specify reference edge
            CONSTANT HeaderMsg         : IN     STRING := " ";
            VARIABLE TimeMarker        : INOUT  TimeMarkerType;    -- holds time of last Reference transition
                                                                   -- and the last time a hold check passed
            VARIABLE TestPortLastEvent : INOUT  DelayArrayTypeXX;  -- records time of test port events
            VARIABLE TestPortLastValue : INOUT  std_logic_vector;  -- records previous test port values
            VARIABLE Violation         : OUT    X01
                                       ) IS -- {TVTG}

       Variable temp : BOOLEAN;

    BEGIN
       VitalTimingCheck (
          TestPort          => TestPort,
          TestPortName      => TestPortName,
          RefPort           => RefPort,
          RefPortName       => RefPortName,
          t_setup_hi        => t_setup_hi,
          t_setup_lo        => t_setup_lo,
          t_hold_hi         => t_hold_hi,
          t_hold_lo         => t_hold_lo,
          CheckEnabled      => CheckEnabled,
          RefTransition     => RefTransition,
          HeaderMsg         => HeaderMsg,
          TimeMarker        => TimeMarker,
          TestPortLastEvent => TestPortLastEvent,
          TestPortLastValue => TestPortLastValue,
          Violation         => temp
       );
       if temp then
          Violation := 'X';
       else
          Violation := '0';
       end if;
    END;
    
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    --  Period Check
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    PROCEDURE VitalPeriodCheck  (
                SIGNAL   TestPort     : IN     std_ulogic;
                CONSTANT TestPortName : IN     STRING := "";
                CONSTANT PeriodMin    : IN     TIME := 0 ns;        -- minimum allowable period
                CONSTANT PeriodMax    : IN     TIME := TIME'HIGH;   -- maximum allowable period
                CONSTANT pw_hi_min    : IN     TIME := 0 ns;        -- min. allowable HI pulse
                CONSTANT pw_hi_max    : IN     TIME := TIME'HIGH;   -- max. allowable HI pulse
                CONSTANT pw_lo_min    : IN     TIME := 0 ns;        -- min. allowable LO pulse
                CONSTANT pw_lo_max    : IN     TIME := TIME'HIGH;   -- max. allowable LO pulse
                VARIABLE info         : INOUT  PeriodCheckInfoType;       
                VARIABLE Violation    : OUT    BOOLEAN;
                CONSTANT HeaderMsg    : IN     STRING := " ";
                CONSTANT CheckEnabled : IN     BOOLEAN := True
                                      ) IS -- {TVTG}
        CONSTANT t0    : INTEGER := 0;
        CONSTANT t1    : INTEGER := 1;

        VARIABLE observed_time : TIME;
        VARIABLE period  : TIME;
        VARIABLE StrPtr1, StrPtr2, StrPtr3 : LINE;

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
            IF CheckEnabled and ( observed_time > pw_lo_max ) THEN
                Violation := TRUE;
                Write (StrPtr1, pw_lo_max);
                Write (StrPtr2, observed_time);
                Write (StrPtr3, NOW);
                ASSERT false
                REPORT HeaderMsg & " LOW PULSE WIDTH IS TOO LONG ON " & TestPortName & SMC_CR &
                       "  Expected := " & StrPtr1.all &
                       "; Observed := " & StrPtr2.all &
                       "; At : "        & StrPtr3.all
                SEVERITY ERROR;
                DEALLOCATE (StrPtr1);
                DEALLOCATE (StrPtr2);
                DEALLOCATE (StrPtr3);
            END IF;

            IF CheckEnabled AND 
               ( observed_time < pw_lo_min ) AND
               ( NOW >= pw_lo_min )               -- ignore 1st edge
            THEN
                Violation := TRUE;
                Write (StrPtr1, pw_lo_min);
                Write (StrPtr2, observed_time);
                Write (StrPtr3, NOW);
                ASSERT false
                REPORT HeaderMsg & " LOW PULSE WIDTH IS TOO SHORT ON " & TestPortName & SMC_CR &
                       "  Expected := " & StrPtr1.all &
                       "; Observed := " & StrPtr2.all &
                       "; At : "        & StrPtr3.all
                SEVERITY ERROR;
                DEALLOCATE (StrPtr1);
                DEALLOCATE (StrPtr2);
                DEALLOCATE (StrPtr3);
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
            IF CheckEnabled AND ( observed_time > pw_hi_max ) THEN
                Violation := TRUE;
                Write (StrPtr1, pw_hi_max);
                Write (StrPtr2, observed_time);
                Write (StrPtr3, NOW);
                ASSERT FALSE
                REPORT HeaderMsg & " HIGH PULSE WIDTH IS TOO LONG ON " & TestPortName & SMC_CR &
                       "  Expected := " & StrPtr1.all &
                       "; Observed := " & StrPtr2.all &
                       "; At : "        & StrPtr3.all
                SEVERITY ERROR;
                DEALLOCATE (StrPtr1);
                DEALLOCATE (StrPtr2);
                DEALLOCATE (StrPtr3);                
            END IF;
 
            IF CheckEnabled AND ( observed_time < pw_hi_min ) AND
               ( NOW >= pw_hi_min )               -- ignore 1st edge
            THEN
                Violation := TRUE;
                Write (StrPtr1, pw_hi_min);
                Write (StrPtr2, observed_time);
                Write (StrPtr3, NOW);
                ASSERT FALSE
                REPORT HeaderMsg & " HIGH PULSE WIDTH IS TOO SHORT ON " & TestPortName & SMC_CR &
                       "  Expected := " & StrPtr1.all &
                       "; Observed := " & StrPtr2.all &
                       "; At : "        & StrPtr3.all
                SEVERITY ERROR;
                DEALLOCATE (StrPtr1);
                DEALLOCATE (StrPtr2);
                DEALLOCATE (StrPtr3);                
            END IF;
        END IF;
        -- ---------------------------------------------------------------------
        -- Validate the Period
        -- ---------------------------------------------------------------------
        IF CheckEnabled AND (period > PeriodMax) THEN
            Violation := TRUE;
                Write (StrPtr1, PeriodMax);
                Write (StrPtr2, period);
                Write (StrPtr3, NOW);
                ASSERT FALSE
                REPORT HeaderMsg & " PERIOD IS TOO LONG ON " & TestPortName & SMC_CR &
                       "  Expected := " & StrPtr1.all &
                       "; Observed := " & StrPtr2.all &
                       "; At : "        & StrPtr3.all
                SEVERITY ERROR;
                DEALLOCATE (StrPtr1);
                DEALLOCATE (StrPtr2);
                DEALLOCATE (StrPtr3);                
        END IF;

        IF CheckEnabled AND 
           ( period < PeriodMin ) AND 
           ( NOW > PeriodMin )    THEN  -- prevent startup messages
            Violation := TRUE;
                Write (StrPtr1, PeriodMin);
                Write (StrPtr2, period);
                Write (StrPtr3, NOW);
                ASSERT FALSE
                REPORT HeaderMsg & " PERIOD IS TOO SHORT ON " & TestPortName & SMC_CR &
                       "  Expected := " & StrPtr1.all &
                       "; Observed := " & StrPtr2.all &
                       "; At : "        & StrPtr3.all
                SEVERITY ERROR;
                DEALLOCATE (StrPtr1);
                DEALLOCATE (StrPtr2);
                DEALLOCATE (StrPtr3);                
        END IF;
    END VitalPeriodCheck;
	---------------------------------------------------------------------------
    PROCEDURE VitalPeriodCheck  (
                SIGNAL   TestPort     : IN     std_ulogic;
                CONSTANT TestPortName : IN     STRING := "";
                CONSTANT PeriodMin    : IN     TIME := 0 ns;        -- minimum allowable period
                CONSTANT PeriodMax    : IN     TIME := TIME'HIGH;   -- maximum allowable period
                CONSTANT pw_hi_min    : IN     TIME := 0 ns;        -- min. allowable HI pulse
                CONSTANT pw_hi_max    : IN     TIME := TIME'HIGH;   -- max. allowable HI pulse
                CONSTANT pw_lo_min    : IN     TIME := 0 ns;        -- min. allowable LO pulse
                CONSTANT pw_lo_max    : IN     TIME := TIME'HIGH;   -- max. allowable LO pulse
                VARIABLE info         : INOUT  PeriodCheckInfoType;       
                VARIABLE Violation    : OUT    X01;
                CONSTANT HeaderMsg    : IN     STRING := " ";
                CONSTANT CheckEnabled : IN     BOOLEAN := True
                                      ) IS -- {TVTG}

		variable violation_flag : boolean := false;
    BEGIN
		VitalPeriodCheck(TestPort,TestPortName,PeriodMin,PeriodMax,pw_hi_min,pw_hi_max,
						 pw_lo_min,pw_lo_max,info,Violation_flag,HeaderMsg,CheckEnabled);

		if Violation_flag then
				 Violation := 'X';
        else
				 Violation := '0';
        end if;
    END VitalPeriodCheck;
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    -- Glitch Handlers
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    PROCEDURE ReportGlitch ( 
            CONSTANT GlitchRoutine  : IN  string;           -- name of glitch detection procedure
            CONSTANT OutSignalName  : IN  string;           -- name of the signal
            CONSTANT PreemptedTime  : IN  TIME;             -- preempted time
            CONSTANT PreemptedValue : IN  std_ulogic;       -- preempted value
            CONSTANT NewTime        : IN  TIME;             -- New value time
            CONSTANT NewValue       : IN  std_ulogic;       -- New value
            CONSTANT index          : IN  INTEGER := 0;     -- index to array signal
            CONSTANT IsArraySignal  : IN  BOOLEAN := FALSE  -- Flag indicating if Index name
            ) IS
        VARIABLE StrPtr1, StrPtr2, StrPtr3, StrPtr4, StrPtr5 : LINE;
    BEGIN

        Write (StrPtr1, PreemptedTime );
        Write (StrPtr2, NewTime);
        Write (StrPtr3, MVL9CvtTable(PreemptedValue));
        Write (StrPtr4, MVL9CvtTable(NewValue));
        IF IsArraySignal THEN
          Write (StrPtr5, STRING'( "(" ) );
          Write (StrPtr5, index);
          Write (StrPtr5, STRING'( ")" ) );
        ELSE
          Write (StrPtr5, STRING'( " " ) );
        END IF;

        ASSERT PreemptedTime >  NewTime        -- Issue Report only if Preemted value has not been
                                               --  removed from event queue
          REPORT GlitchRoutine & ": GLITCH Detected on port " & 
                 OutSignalName & StrPtr5.all &
                 "; Preempted Future Value := " & StrPtr3.all &
                 " @ " & StrPtr1.all &
                 "; Newly Scheduled Value := " & StrPtr4.all &
                 " @ " & StrPtr2.all &
                 ";"
          SEVERITY WARNING;

        DEALLOCATE(StrPtr1);
        DEALLOCATE(StrPtr2);
        DEALLOCATE(StrPtr3);
        DEALLOCATE(StrPtr4); 
        DEALLOCATE(StrPtr5); 
        RETURN;
    END;

    PROCEDURE VitalGlitchOnEvent (
            SIGNAL   OutSignal        : OUT   std_logic;       -- signal being driven
            CONSTANT OutSignalName    : IN    string;          -- name of the signal
            VARIABLE GlitchData       : INOUT GlitchDataType;  -- Internal glitch data
            CONSTANT NewValue         : IN    std_logic;       -- value being assigned
            CONSTANT NewDelay         : IN    TIME  := 0 ns;   -- delay value
            CONSTANT GlitchMode       : IN    GlitchModeType := MessagePlusX;
            CONSTANT GlitchDelay      : IN    TIME  := 0 ns    -- delay to possible glitch
--            CONSTANT PulseRejectLimit : IN    TIME := 0 ns
            ) IS
    -- ----------------------------------------------------------------------------
    -- NOTE: 1) glitch on event cannot generate a glitch for a new transaction
    --          with occurs prior to the current pending transaction - in this case
    --          the glitch maturity (start of the glitch) would occur after the
    --          good final value.
    -- ----------------------------------------------------------------------------
        VARIABLE no_glitch  : BOOLEAN := FALSE;
        VARIABLE old_glitch : BOOLEAN := FALSE;
        VARIABLE dly        : TIME    := NewDelay;

    BEGIN
        -- If nothing to schedule, just return
        IF NewDelay < 0 ns
          THEN  ASSERT NewValue = GlitchData.LastSchedValue 
                REPORT "Signal scheduling error, -delay for change on: " & OutSignalName
                SEVERITY WARNING;
        ELSE 
            -- If nothing currently scheduled
            IF GlitchData.LastSchedTransaction <= NOW THEN
                GlitchData.CurrentValue := GlitchData.LastSchedValue;
                IF (GlitchDelay <= 0 ns) THEN
                    IF (NewValue = GlitchData.LastSchedValue) THEN RETURN; END IF;
                    no_glitch := TRUE;
                END IF;
     
            -- Transaction currently scheduled - if glitch already happened
            ELSIF GlitchData.LastGlitchSchedTime <= NOW THEN
                GlitchData.CurrentValue := 'X';
                old_glitch := TRUE;
     
            -- Transaction currently scheduled (no glitch if same value)
            ELSIF (GlitchData.LastSchedValue = NewValue)
                  AND (GlitchData.LastSchedTransaction = GlitchData.LastGlitchSchedTime)
                  AND (GlitchDelay <= 0 ns) THEN
                no_glitch := TRUE;
                dly := MINIMUM( GlitchData.LastSchedTransaction-NOW, NewDelay );

            END IF;
     
            GlitchData.LastSchedTransaction := NOW+dly;
            IF old_glitch THEN
-- 1992 ver     OutSignal <= REJECT PulseWidthLimit INERTIAL NewValue AFTER dly;
                OutSignal <= NewValue AFTER dly;
            ELSIF no_glitch THEN
                GlitchData.LastGlitchSchedTime := NOW+dly;
-- 1992 ver     OutSignal <= REJECT PulseWidthLimit INERTIAL NewValue AFTER dly;
                OutSignal <= NewValue AFTER dly;
            ELSE -- new glitch
            GlitchData.LastGlitchSchedTime := GlitchMinTime ( GlitchData.LastGlitchSchedTime, NOW+GlitchDelay );
--                IF (GlitchData.LastSchedTransaction-GlitchData.LastGlitchSchedTime) <= PulseRejectLimit THEN
--                    GlitchData.LastGlitchSchedTime := NOW+dly;
-- 1992 ver           OutSignal <= REJECT PulseWidthLimit INERTIAL NewValue AFTER dly;
--                    OutSignal <= NewValue AFTER dly;
--                ELSE        -- glitch generated
                    IF (GlitchMode = MessagePlusX) OR (GlitchMode = MessageOnly) THEN
                        ReportGlitch ( "VitalGlitchOnEvent", OutSignalName,
                                       GlitchData.LastGlitchSchedTime, GlitchData.LastSchedValue,
                                       (dly + NOW), NewValue );
                    END IF;
                    IF (GlitchMode = MessagePlusX) OR (GlitchMode = XOnly) THEN
-- 1992 ver.            OutSignal <= REJECT PulseWidthLimit INERTIAL 'X' AFTER GlitchData.LastGlitchSchedTime-NOW;
-- 1992 ver.            OutSignal <= REJECT PulseWidthLimit INERTIAL NewValue AFTER dly;
                        OutSignal <= 'X' AFTER GlitchData.LastGlitchSchedTime-NOW;
                        OutSignal <=  TRANSPORT NewValue AFTER dly;
                    ELSE
-- 1992 ver             OutSignal <= REJECT PulseWidthLimit INERTIAL NewValue AFTER dly;
                        OutSignal <= NewValue AFTER dly;
                    END IF;
--                END IF;
            END IF;
            GlitchData.LastSchedValue := NewValue;
        END IF;
        RETURN;
    END;
 
    ----------------------------------------------------------------------------------------
    PROCEDURE VitalGlitchOnDetect (
            SIGNAL   OutSignal        : OUT   std_logic;       -- signal being driven
            CONSTANT OutSignalName    : IN    string;          -- name of the signal
            VARIABLE GlitchData       : INOUT GlitchDataType;  -- Internal glitch data
            CONSTANT NewValue         : IN    std_logic;       -- value being assigned
            CONSTANT NewDelay         : IN    TIME  := 0 ns;   -- delay value
            CONSTANT GlitchMode       : IN    GlitchModeType := MessagePlusX;
            CONSTANT GlitchDelay      : IN    TIME  := 0 ns    -- delay to possible glitch
--            CONSTANT PulseRejectLimit : IN    TIME := 0 ns
            ) IS
    -- ----------------------------------------------------------------------------
    -- NOTE: 1) Since glitch on detect generates a glitch for any pending transaction
    --          when a new transaction is schedule, in the case when the pending transaction
    --          would occur after the new transaction, a glitch is generated when NO
    --          glitch is generated by glitch on event (maturity).
    -- ----------------------------------------------------------------------------
        VARIABLE no_glitch  : BOOLEAN := FALSE;
        VARIABLE old_glitch : BOOLEAN := FALSE;
        VARIABLE dly : TIME := NewDelay;

    BEGIN
        -- If nothing to schedule, just return
        IF NewDelay < 0 ns
          THEN  ASSERT NewValue = GlitchData.LastSchedValue 
                REPORT "Signal scheduling error, -delay for change on: " & OutSignalName
                SEVERITY WARNING;
        ELSE
            -- If nothing currently scheduled (i.e. last scheduled transaction already occurred)
            IF GlitchData.LastSchedTransaction <= NOW THEN
                GlitchData.CurrentValue := GlitchData.LastSchedValue;   -- update current value
                IF (GlitchDelay <= 0 ns) THEN
                    IF (NewValue = GlitchData.LastSchedValue) THEN RETURN; END IF; -- return if no change in value
                    no_glitch := TRUE;  -- since last transaction already occurred there is no glitch
                END IF;
    
            -- Transaction currently scheduled - if glitch already happened
            ELSIF GlitchData.LastGlitchSchedTime <= NOW THEN  -- check on previously scheduled glitch
                GlitchData.CurrentValue := 'X';
                old_glitch := TRUE;
     
            -- Transaction currently scheduled
            ELSIF (GlitchData.LastSchedValue = NewValue)
                  AND (GlitchData.LastSchedTransaction = GlitchData.LastGlitchSchedTime)
                  AND (GlitchDelay <= 0 ns) THEN
                no_glitch := TRUE;
                dly := MINIMUM( GlitchData.LastSchedTransaction-NOW, NewDelay );

            END IF;
    
            GlitchData.LastSchedTransaction := NOW+dly;  -- update last scheduled transaction
            IF old_glitch THEN
-- 1992 ver:    OutSignal <= REJECT PulseRejectLimit INERTIAL NewValue AFTER dly;
                OutSignal <= NewValue AFTER dly;
            ELSIF no_glitch THEN
                GlitchData.LastGlitchSchedTime := NOW+dly;  -- if no glitch then update last glitch time and outsignal
-- 1992 ver:    OutSignal <= REJECT PulseRejectLimit INERTIAL NewValue AFTER dly;
                OutSignal <= NewValue AFTER dly;
            ELSE   -- new glitch
                GlitchData.LastGlitchSchedTime := GlitchMinTime ( GlitchData.LastGlitchSchedTime, NOW+GlitchDelay );
--                IF (GlitchData.LastSchedTransaction-GlitchData.LastGlitchSchedTime) < PulseRejectLimit THEN
--                    GlitchData.LastGlitchSchedTime := NOW+dly;
-- 1992 version:      OutSignal <= REJECT PulseRejectLimit INERTIAL NewValue AFTER dly;
--                    OutSignal <= NewValue AFTER dly;
--                ELSE        -- glitch generated
                    IF (GlitchMode = MessagePlusX) OR (GlitchMode = MessageOnly) THEN
                        ReportGlitch ( "VitalGlitchOnDetect", OutSignalName,
                                       GlitchData.LastGlitchSchedTime, GlitchData.LastSchedValue,
                                       (dly + NOW), NewValue );
                    END IF;
                    IF (GlitchMode = MessagePlusX) OR (GlitchMode = XOnly) THEN
                        IF NOW+dly > GlitchData.LastGlitchSchedTime THEN 
-- 1992 ver.                OutSignal <= REJECT PulseWidthLimit INERTIAL 'X';
-- 1992 ver.                OutSignal <= REJECT PulseWidthLimit INERTIAL NewValue AFTER dly;
                            OutSignal <= 'X';
                            OutSignal <= TRANSPORT NewValue AFTER dly;
                        ELSE -- Glitch gets preemted
-- 1992 ver.                OutSignal <= REJECT PulseWidthLimit INERTIAL NewValue AFTER dly;
                            OutSignal <= NewValue AFTER dly;
                       END IF;
                    ELSE
-- 1992 ver             OutSignal <= REJECT PulseWidthLimit INERTIAL NewValue AFTER dly;
                        OutSignal <= NewValue AFTER dly;
                    END IF;
--                END IF;
            END IF;
            GlitchData.LastSchedValue := NewValue;
        END IF;
        RETURN;
    END;
 
    ----------------------------------------------------------------------------------------
    PROCEDURE VitalGlitchOnEvent (
            SIGNAL   OutSignal        : OUT   std_logic_vector; -- signal being driven
            CONSTANT OutSignalName    : IN    string;           -- name of the signal
            VARIABLE GlitchData       : INOUT GlitchDataArrayType;      -- Internal glitch data
            CONSTANT NewValue         : IN    std_logic_vector; -- value being assigned
            CONSTANT NewDelay         : IN    TimeArray;        -- delay values
            CONSTANT GlitchMode       : IN    GlitchModeType := MessagePlusX;
            CONSTANT GlitchDelay      : IN    TimeArray         -- delay to possible glitch
--            CONSTANT PulseRejectLimit : IN    TIME := 0 ns
            ) IS

       ALIAS GlitchData_alias   : GlitchDataArrayType(1 to GlitchData'LENGTH) is GlitchData;
       ALIAS NewValue_alias     : std_logic_vector(1 to NewValue'LENGTH) is NewValue;
       ALIAS NewDelay_alias     : TimeArray(1 to NewDelay'LENGTH) is NewDelay;
       ALIAS GlitchDelay_alias  : TimeArray(1 to GlitchDelay'LENGTH) is GlitchDelay;
       VARIABLE actual_index    : integer := OutSignal'LEFT;
       VARIABLE direction       : integer;
       VARIABLE no_glitch       : BOOLEAN;
       VARIABLE old_glitch      : BOOLEAN;
       VARIABLE dly             : TIME;

    BEGIN
       if (OutSignal'LEFT > OutSignal'Right) then
          direction := -1;
       else
          direction := 1;
       end if;
       if ( (OutSignal'LENGTH /= GlitchData'LENGTH) or (OutSignal'Length /= NewValue'LENGTH) or
            (OutSignal'LENGTH /= NewDelay'LENGTH) or (OutSignal'Length /= GlitchDelay'LENGTH) ) then
          assert FALSE
             report "VitalGlitchOnEvent (std_logic_vector):  All vectors passed to this procedure must have same length."
             severity FAILURE;
          RETURN;
       end if;
       for n in 1 to OutSignal'LENGTH loop
          -- a call to the std_logic function cannot be made since the actual associated with a signal
          -- parameter must be static

          no_glitch := FALSE;
          old_glitch := FALSE;
          dly := NewDelay_alias(n);
          -- If nothing to schedule, just skip to next loop iteration
          IF NewDelay_alias(n) < 0 ns
            THEN  ASSERT NewValue_alias(n) = GlitchData_alias(n).LastSchedValue 
                  REPORT "Signal scheduling error, -delay for change on: " & OutSignalName
                  SEVERITY WARNING;
          ELSE
              -- If nothing currently scheduled (i.e. last scheduled transaction already occurred)
              IF GlitchData_alias(n).LastSchedTransaction <= NOW THEN
                  GlitchData_alias(n).CurrentValue := GlitchData_alias(n).LastSchedValue;   -- update current value
                  IF (GlitchDelay_alias(n) <= 0 ns) THEN
                      IF (NewValue_alias(n) = GlitchData_alias(n).LastSchedValue) THEN -- Next iteration if no change in value
                          actual_index := actual_index + direction;
                          NEXT; 
                      END IF; 
                      no_glitch := TRUE;  -- since last transaction already occurred there is no glitch
                  END IF;

              -- Transaction currently scheduled - if glitch already happened
              ELSIF GlitchData_alias(n).LastGlitchSchedTime <= NOW THEN  -- check on previously scheduled glitch
                  GlitchData_alias(n).CurrentValue := 'X';
                  old_glitch := TRUE;

              -- Transaction currently scheduled
              ELSIF (GlitchData_alias(n).LastSchedValue = NewValue_alias(n))
                    AND (GlitchData_alias(n).LastSchedTransaction = GlitchData_alias(n).LastGlitchSchedTime)
                    AND (GlitchDelay_alias(n) <= 0 ns) THEN
                  no_glitch := TRUE;
                  dly := MINIMUM( GlitchData_alias(n).LastSchedTransaction-NOW, NewDelay_alias(n) );

              END IF;

              GlitchData_alias(n).LastSchedTransaction := NOW+dly;  -- update last scheduled transaction
              IF old_glitch THEN
-- 1992 ver        (n) <= REJECT PulseRejectLimit INERTIAL NewValue_alias(n) AFTER dly;
                  OutSignal(actual_index) <= NewValue_alias(n) AFTER dly;
              ELSIF no_glitch THEN
                  GlitchData_alias(n).LastGlitchSchedTime := NOW+dly;  -- if no glitch then update last glitch time and OutSignal(actual_index)
-- 1992 ver       OutSignal(actual_index) <= REJECT PulseRejectLimit INERTIAL NewValue_alias(n) AFTER dly;
                  OutSignal(actual_index) <= NewValue_alias(n) AFTER dly;
              ELSE   -- new glitch
                  GlitchData_alias(n).LastGlitchSchedTime := GlitchMinTime ( GlitchData_alias(n).LastGlitchSchedTime, NOW+GlitchDelay_alias(n) );
--                  IF (GlitchData_alias(n).LastSchedTransaction-GlitchData_alias(n).LastGlitchSchedTime) <= PulseRejectLimit THEN
--                      GlitchData_alias(n).LastGlitchSchedTime := NOW+dly;
-- 1992 ver             OutSignal(actual_index) <= REJECT PulseRejectLimit INERTIAL NewValue_alias(n) AFTER dly;
--                      OutSignal(actual_index) <= NewValue_alias(n) AFTER dly;
--                  ELSE        -- glitch generated
                      IF (GlitchMode = MessagePlusX) OR (GlitchMode = MessageOnly) THEN
                          ReportGlitch ( "VitalGlitchOnEvent", OutSignalName,
                                         GlitchData_alias(n).LastGlitchSchedTime, GlitchData_alias(n).LastSchedValue,
                                         (dly + NOW), NewValue_alias(n), actual_index, TRUE );
                      END IF;
                      IF (GlitchMode = MessagePlusX) OR (GlitchMode = XOnly) THEN
-- 1992 vers.             OutSignal(actual_index) <= REJECT PulseRejectLimit INERTIAL 'X' AFTER GlitchData_alias(n).LastGlitchSchedTime - NOW;
-- 1992 vers.             OutSignal(actual_index) <= REJECT PulseRejectLimit INERTIAL NewValue_alias(n) AFTER dly;
                          OutSignal(actual_index) <= 'X' AFTER GlitchData_alias(n).LastGlitchSchedTime - NOW;
                          OutSignal(actual_index) <= TRANSPORT NewValue_alias(n) AFTER dly;
                      ELSE
-- 1992 vers.             OutSignal(actual_index) <= REJECT PulseRejectLimit INERTIAL NewValue_alias(n) AFTER dly;
                          OutSignal(actual_index) <= NewValue_alias(n) AFTER dly;
                      END IF;
--                  END IF;
              END IF;
              GlitchData_alias(n).LastSchedValue := NewValue_alias(n);
          END IF;
          actual_index := actual_index + direction;
       end loop;
       RETURN;
    END;
    ---------------------------------------------------------------------------------------
    PROCEDURE VitalGlitchOnDetect (
            SIGNAL   OutSignal        : OUT   std_logic_vector; -- signal being driven
            CONSTANT OutSignalName    : IN    string;           -- name of the signal
            VARIABLE GlitchData       : INOUT GlitchDataArrayType;      -- Internal glitch data
            CONSTANT NewValue         : IN    std_logic_vector; -- value being assigned
            CONSTANT NewDelay         : IN    TimeArray;        -- delay values
            CONSTANT GlitchMode       : IN    GlitchModeType := MessagePlusX;
            CONSTANT GlitchDelay      : IN    TimeArray         -- delay to possible glitch
--            CONSTANT PulseRejectLimit : IN    TIME := 0 ns
            ) IS

       ALIAS GlitchData_alias  : GlitchDataArrayType(1 to GlitchData'LENGTH) is GlitchData;
       ALIAS NewValue_alias    : std_logic_vector(1 to NewValue'LENGTH) is NewValue;
       ALIAS NewDelay_alias    : TimeArray(1 to NewDelay'LENGTH) is NewDelay;
       ALIAS GlitchDelay_alias : TimeArray(1 to GlitchDelay'LENGTH) is GlitchDelay;
       VARIABLE actual_index   : integer := OutSignal'LEFT;
       VARIABLE direction      : integer;
       VARIABLE StrPtr         : LINE;
       VARIABLE no_glitch      : BOOLEAN;
       VARIABLE old_glitch     : BOOLEAN;
       VARIABLE dly            : TIME;

    BEGIN
       if (OutSignal'LEFT > OutSignal'Right) then
          direction := -1;
       else
          direction := 1;
       end if;
       if ( (OutSignal'LENGTH /= GlitchData'LENGTH) or (OutSignal'Length /= NewValue'LENGTH) or
            (OutSignal'LENGTH /= NewDelay'LENGTH) or (OutSignal'Length /= GlitchDelay'LENGTH) ) then
          assert FALSE
             report "VitalGlitchOnDetect (std_logic_vector):  All vectors passed to this procedure must have same length."
             severity FAILURE;
          RETURN;
       end if;
       for n in 1 to OutSignal'LENGTH loop
          -- a call to the std_logic function cannot be made since the actual associated with a signal
          -- parameter must be static

          no_glitch := FALSE;
          old_glitch := FALSE;
          dly := NewDelay_alias(n);
          -- If nothing to schedule, just skip to next loop iteration
          IF NewDelay_alias(n) < 0 ns
            THEN  ASSERT NewValue_alias(n) = GlitchData_alias(n).LastSchedValue 
                  REPORT "Signal scheduling error, -delay for change on: " & OutSignalName
                  SEVERITY WARNING;
          ELSE
              -- If nothing currently scheduled (i.e. last scheduled transaction already occurred)
              IF GlitchData_alias(n).LastSchedTransaction <= NOW THEN
                  GlitchData_alias(n).CurrentValue := GlitchData_alias(n).LastSchedValue;   -- update current value
                  IF (GlitchDelay_alias(n) <= 0 ns) THEN
                      IF (NewValue_alias(n) = GlitchData_alias(n).LastSchedValue) THEN -- skip iteration if no change in value
                          actual_index := actual_index + direction;
                          NEXT; 
                      END IF; 
                      no_glitch := TRUE;  -- since last transaction already occurred there is no glitch
                  END IF;

              -- Transaction currently scheduled - if glitch already happened
              ELSIF GlitchData_alias(n).LastGlitchSchedTime <= NOW THEN  -- check on previously scheduled glitch
                  GlitchData_alias(n).CurrentValue := 'X';
                  old_glitch := TRUE;

              -- Transaction currently scheduled
              ELSIF (GlitchData_alias(n).LastSchedValue = NewValue_alias(n))
                    AND (GlitchData_alias(n).LastSchedTransaction = GlitchData_alias(n).LastGlitchSchedTime)
                    AND (GlitchDelay_alias(n) <= 0 ns) THEN
                  no_glitch := TRUE;
                  dly := MINIMUM( GlitchData_alias(n).LastSchedTransaction-NOW, NewDelay_alias(n) );

              END IF;

              GlitchData_alias(n).LastSchedTransaction := NOW+dly;  -- update last scheduled transaction
              IF old_glitch THEN
-- 1992 ver       OutSignal(actual_index) <= REJECT PulseWidthLimit INERTIAL NewValue_alias(n) AFTER dly;
                  OutSignal(actual_index) <= NewValue_alias(n) AFTER dly;
              ELSIF no_glitch THEN
                  GlitchData_alias(n).LastGlitchSchedTime := NOW+dly;  -- if no glitch then update last glitch time and OutSignal(actual_index)
-- 1992 ver       OutSignal(actual_index) <= REJECT PulseWidthLimit INERTIAL NewValue_alias(n) AFTER dly;
                  OutSignal(actual_index) <= NewValue_alias(n) AFTER dly;
              ELSE   -- new glitch
                  GlitchData_alias(n).LastGlitchSchedTime := GlitchMinTime ( GlitchData_alias(n).LastGlitchSchedTime, NOW+GlitchDelay_alias(n) );
--                  IF (GlitchData_alias(n).LastSchedTransaction-GlitchData_alias(n).LastGlitchSchedTime) < PulseRejectLimit THEN
--                      GlitchData_alias(n).LastGlitchSchedTime := NOW+dly;
-- 1992 ver             OutSignal(actual_index) <= REJECT PulseWidthLimit INERTIAL NewValue_alias(n) AFTER dly;
--                      OutSignal(actual_index) <= NewValue_alias(n) AFTER dly;
--                  ELSE        -- glitch generated
                      IF (GlitchMode = MessagePlusX) OR (GlitchMode = MessageOnly) THEN
                          ReportGlitch ( "VitalGlitchOnDetect", OutSignalName,
                                         GlitchData_alias(n).LastGlitchSchedTime, GlitchData_alias(n).LastSchedValue,
                                         (dly + NOW), NewValue_alias(n), actual_index, TRUE );
                      END IF;
                      IF (GlitchMode = MessagePlusX) OR (GlitchMode = XOnly) THEN
                          IF NOW+dly > GlitchData_alias(n).LastGlitchSchedTime THEN 
-- 1992 ver                   OutSignal(actual_index) <= REJECT PulseWidthLimit INERTIAL 'X;
-- 1992 ver                   OutSignal(actual_index) <= REJECT PulseWidthLimit INERTIAL NewValue_alias(n) AFTER dly;
                              OutSignal(actual_index) <= 'X';
                              OutSignal(actual_index) <= TRANSPORT NewValue_alias(n) AFTER dly;
                          ELSE -- Glitch gets preemted
-- 1992 ver                   OutSignal(actual_index) <= REJECT PulseWidthLimit INERTIAL NewValue_alias(n) AFTER dly;
                              OutSignal(actual_index) <= NewValue_alias(n) AFTER dly;
                          END IF;
                      ELSE
-- 1992 ver               OutSignal(actual_index) <= REJECT PulseRejectLimit INERTIAL NewValue_alias(n) AFTER dly;
                          OutSignal(actual_index) <= NewValue_alias(n) AFTER dly;
                      END IF;
--                  END IF;
              END IF;
              GlitchData_alias(n).LastSchedValue := NewValue_alias(n);
          END IF;
          actual_index := actual_index + direction;
       end loop;
       RETURN;
    END;
 
END VITAL_Timing;

