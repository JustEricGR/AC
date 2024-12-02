--------------------------------------------------------------------------
--
-- File name   :  timing_p.vhd
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
--     v0.800   |   wdb  |  08/17/93  | Alpha Release
--     v0.900   |   wdb  |  09/08/93  | Beta Release
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
--              |        |            | Procedure VitalPropagateWireDelay added
--     v0.908   |   wrm  |  01/26/94  | Removed edge types and procedures
--     v0.909   |   wrm  |  02/25/94  | Removed most concurrent procedures.  Removed currentvalue function.
--              |        |            | Removed VitalTimingViolation.  Also, modified VitalSetupHoldCheck,
--              |        |            | VitalTimingCheck, and VitalPropagateWireDelay to deal with negative
--              |        |            | hold times.  VitalPropagateWireDelay also modified to assist those
--              |        |            | routines with negative hold times.
--     v0.910   |   wrm  |  03/02/94  | minor bug in VitalPeriodCheck assertion fixed. TimeMarkerInit removed.
--     v0.911   |   sn   |  06/13/94  | Bug fixes in the package body.
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
-- ----------------------------------------------------------------------------
-- Notes:
--      1) The order of the values in TransitionType is different from the
--         order of these values in SDF
--      2) A Generic parameter (ie tpd_EN_Q ) for the delay from a 3-state
--         enable to the output only uses [tr0z,trz0,tr1z,trz1]
-- ----------------------------------------------------------------------------

LIBRARY IEEE;
USE     IEEE.Std_logic_1164.all;

PACKAGE VITAL_Timing IS
    TYPE    TransitionType        IS ( tr01, tr10, tr0z, trz1, tr1z, trz0 );  -- {TVTG}
    TYPE    TransitionIOType      IS ( trll, trlh, trhl, trhh );              -- (R&R)
    TYPE    TransitionArrayType   IS ARRAY (TransitionType range <>) of TIME; 
    TYPE    TransitionIOArrayType IS ARRAY (TransitionIOType range <>) of TIME; 
    SUBTYPE DelayTypeXX           is TIME;
    SUBTYPE DelayType01           is TransitionArrayType (tr01 to tr10);
    SUBTYPE DelayType01Z          is TransitionArrayType (tr01 to trz0);
    SUBTYPE DelayTypeIO           is TransitionIOArrayType (trll to trhh);
    TYPE    DelayArrayTypeXX      is ARRAY (natural range <>) of DelayTypeXX;
    TYPE    DelayArrayType01      is ARRAY (natural range <>) of DelayType01;
    TYPE    DelayArrayType01Z     is ARRAY (natural range <>) of DelayType01Z;
    TYPE    DelayArrayTypeIO      is ARRAY (natural range <>) of DelayTypeIO ;
    TYPE    TimeArray             IS ARRAY ( NATURAL RANGE <> ) OF TIME;    
    -- ----------------------------------------------------------------------
    -- ***********************************************************************
    -- ----------------------------------------------------------------------

    CONSTANT UnitDelay       : TransitionArrayType := ( 1 ns, 1 ns, 1 ns, 1 ns, 1 ns, 1 ns);
 
    CONSTANT ZeroDelay01  : DelayType01  := ( 0 ns, 0 ns );
    CONSTANT ZeroDelay01Z : DelayType01Z := ( 0 ns, 0 ns, 0 ns, 0 ns, 0 ns, 0 ns );
    CONSTANT ZeroDelayIO  : DelayTypeIO  := ( 0 ns, 0 ns, 0 ns, 0 ns );
 
    CONSTANT UnitDelay01  : DelayType01  := ( 1 ns, 1 ns );
    CONSTANT UnitDelay01Z : DelayType01Z := ( 1 ns, 1 ns, 1 ns, 1 ns, 1 ns, 1 ns );
    CONSTANT UnitDelayIO  : DelayTypeIO  := ( 1 ns, 1 ns, 1 ns, 1 ns );
 

    ---------------------------------------------------------------------------
    -- examples of usage:
    ---------------------------------------------------------------------------
    -- tpd_CLK_Q : DelayTypeXX               := 5 ns;
    -- tpd_CLK_Q : DelayType01               := (tr01 => 2 ns, tr10 => 3 ns);
    -- tpd_CLK_Q : DelayType01Z              := ( 1 ns, 2 ns, 3 ns, 4 ns, 5 ns, 6 ns );
    -- tpd_CLK_Q : DelayArrayTypeXX(0 to 1)  := (0 => 5 ns, 
    --                                           1 => 6 ns);
    -- tpd_CLK_Q : DelayArrayType01(0 to 1)  := (0 => (tr01 => 2 ns, tr10 => 3 ns),
    --                                           1 => (tr01 => 2 ns, tr10 => 3 ns));
    -- tpd_CLK_Q : DelayArrayType01Z(0 to 1) := (0 => ( 1 ns, 2 ns, 3 ns, 4 ns, 5 ns, 6 ns ),
    --                                           1 => ( 1 ns, 2 ns, 3 ns, 4 ns, 5 ns, 6 ns ));
    ---------------------------------------------------------------------------
    ATTRIBUTE VITAL_LEVEL1 : Boolean; -- user shall set TRUE if model is LEVEL1 compliant

    SUBTYPE std_logic_vector2 IS std_logic_vector(1 DOWNTO 0);
    SUBTYPE std_logic_vector3 IS std_logic_vector(2 DOWNTO 0);
    SUBTYPE std_logic_vector4 IS std_logic_vector(3 DOWNTO 0);
    SUBTYPE std_logic_vector8 IS std_logic_vector(7 DOWNTO 0);

    TYPE ViolationType is ( NoViolation, SetupViolation, HoldViolation );
    TYPE TimingInfoType is RECORD
            Violation    : ViolationType;
            ObservedTime : time;
            ExpectedTime : time;
            ConstrntTime : time;
            State        : X01;
    END RECORD;

    Type TimeArray2 is array (INTEGER range <>) of Time;
    Type TimeArray2_Ptr_Type is access TimeArray2;
    Type BoolArray is array (INTEGER range <>) of BOOLEAN;
    Type BoolArray_Ptr_type is access BoolArray;
    TYPE TimeMarkerType is RECORD
       RefTimeMarker   : TIME;
       HoldCheckPassed : TimeArray2_Ptr_type;
       LockOutCheck    : BoolArray_Ptr_type;
    END RECORD;


    TYPE GlitchModeType is ( MessagePlusX, MessageOnly, XOnly, NoGlitch);

    TYPE GlitchDataType IS
      RECORD
        LastSchedTransaction  : TIME;         
        LastGlitchSchedTime   : TIME;
        LastSchedValue        : std_ulogic;
        CurrentValue          : std_ulogic; 
      END RECORD;
    TYPE GlitchDataArrayType IS ARRAY (natural range <>) of GlitchDataType ;

    ---------------------------------------------------------------------------
    -- Time Delay Assignment Subprograms
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    -- Function   : VitalExtendToFillDelay
    -- Returns    : A six element array of time values which follow the Verilog
    --              default <[ath_delay_expression> assignment rules.
    -- Purpose    : To provide a set of six transition dependent time values
    --              for use in delay assignments even though only 1,2 or 3 values
    --              of delay may have been provided.
    -- Arguments  : See the declarations below...
    ---------------------------------------------------------------------------
    FUNCTION VitalExtendToFillDelay ( delay : IN TransitionArrayType ) RETURN DelayType01Z;

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
    --            :
    -- Arguments  : See the declarations below...
    --            :
    -- Defaults   : Notice that the routines will autorange the delay parameter
    --            : such that if a (tr01, tr10) subarray is passed, then the values
    --            : for tr0z, trz0, tr1z, and trz1 will be derived.
    --            :
    -- Assumption : newval'length = oldval'length for vectored signals
    --
    ---------------------------------------------------------------------------
    -- Returns a single value of time dependent upon the transition
    ---------------------------------------------------------------------------
    FUNCTION VitalCalcDelay (
                         CONSTANT    newval : IN std_ulogic;        -- new value of signal
                         CONSTANT    oldval : IN std_ulogic;        -- old value of signal
                         CONSTANT    delay  : IN TransitionArrayType := UnitDelay
                       ) RETURN DelayTypeXX; -- {TVTG}
    FUNCTION VitalCalcDelay (
                         CONSTANT    newval : IN std_ulogic;        -- new value of signal
                         CONSTANT    delay  : IN TransitionArrayType := UnitDelay 
                       ) RETURN DelayTypeXX; -- {TVTG}
                       


    -- PathType: for handling simple PathDelay info

    TYPE PathType IS RECORD
        InputChangeTime : time;        -- timestamp for path input signal
        PathDelay       : DelayType01Z;-- delay for this path 
        PathCondition   : boolean;     -- condition which sensitizes this path
    END RECORD;

    -- For representing multiple paths to an output, define 
    -- array of PathType

    TYPE PathArrayType is array (natural range <> ) of PathType;

    -- Type for specifying the kind of Glitch handling to use

    TYPE GlitchKind is (OnEvent, On_Detect);

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
        SIGNAL   OutSignal     : OUT   std_logic;            -- output signal
        CONSTANT OutSignalName : IN    string;               -- name of the output signal
        CONSTANT OutTemp       : IN    std_logic;            -- intermediate 0-delay output
        CONSTANT Paths         : IN    PathArrayType;        -- all possible paths
        VARIABLE GlitchData    : INOUT GlitchDataType;
        CONSTANT GlitchMode    : IN    GlitchModeType;
        CONSTANT GlitchKind    : IN    GlitchKind := OnEvent -- glitch kind to be used
        );
                   

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
        );

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    -- Setup and Hold Time Check Routine 
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
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
    --            : t_setup_hi ::= Absolute minimum time duration before the transition of 
    --            :                the RefPort for which transitions of TestPort are allowed
    --            :                to proceed to the '1' state without causing a setup violation.
    --            :
    --            : t_setup_lo ::= Absolute minimum time duration before the transition of 
    --            :                the RefPort for which transitions of TestPort are allowed
    --            :                to proceed to the '0' state without causing a setup violation.
    --            :
    --            : t_hold_hi  ::= Absolute minimum time duration after the transition of 
    --            :                the RefPort for which transitions of TestPort are allowed
    --            :                to proceed to the '1' state without causing a hold violation.
    --            :
    --            : t_hold_lo  ::= Absolute minimum time duration after the transition of 
    --            :                the RefPort for which transitions of TestPort are allowed
    --            :                to proceed to the '0' state without causing a hold violation.
    --   
    --            : condition  ::= The function immediately checks the condition for a TRUE
    --            :                value. If the value is FALSE, the FUNCTION immediately
    --            :                returns with the value of FALSE.
    --            :
    --            : HeaderMsg  ::= This HeaderMsg string will accompany any assertion
    --            :                messages produced by this function.
    --            :
    --            : TimeMarker ::= Holds the time of the last reference transition and the
    --            :                last time that a hold check passed.  Must be associated
    --            :                with an aggregate which initializes this variable.
    --            :                TimeMarker => (-500 ns, NULL, NULL) 
    --            :                The user should never change the state of that variable
    --            :
    --            : Violation  ::= This routine will set the flag TRUE if a violation exists
    --            ;                and will set the flag FALSE if no violation exists.
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
    --            :
    ---------------------------------------------------------------------------


    PROCEDURE VitalReportSetupHoldViolation (
            CONSTANT TestPortName      : IN string := "";     -- name OF the signal
            CONSTANT RefPortName       : IN string := "";     -- name OF the ref signal
            CONSTANT HeaderMsg         : IN string := " ";
            CONSTANT TimingInfo        : IN TimingInfoType    -- Timing Violation Information
                                       );

    PROCEDURE VitalReportRlseRmvlViolation (
            CONSTANT TestPortName      : IN string := "";     -- name OF the signal
            CONSTANT RefPortName       : IN string := "";     -- name OF the ref signal
            CONSTANT HeaderMsg         : IN string := " ";
            CONSTANT TimingInfo        : IN TimingInfoType    -- Timing Violation Information
                                       );

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
                                                                 -- and the last time a hold check passed
            VARIABLE TimingInfo          : INOUT TimingInfoType  -- timing violation ?
    );
    
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
                                       ); -- {TVTG}

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
                                       ); -- {TVTG}

    PROCEDURE VitalTimingCheck (
            SIGNAL   TestPort          : IN     std_logic_vector; -- SIGNAL being tested
            CONSTANT TestPortName      : IN     STRING := "";     -- name OF the signal
            SIGNAL   RefPort           : IN     std_ulogic;       -- SIGNAL being referenced
            CONSTANT RefPortName       : IN     STRING := "";     -- name OF the ref signal
            CONSTANT t_setup_hi        : IN     TIME := 0 ns;     -- setup spec FOR test PORT = '1'
            CONSTANT t_setup_lo        : IN     TIME := 0 ns;     -- setup spec FOR test PORT = '0'
            CONSTANT t_hold_hi         : IN     TIME := 0 ns;     -- hold spec FOR test PORT = '1'
            CONSTANT t_hold_lo         : IN     TIME := 0 ns;     -- hold spec FOR test PORT = '0'
            CONSTANT CheckEnabled      : IN     BOOLEAN;          -- true ==> spec checked.
            CONSTANT RefTransition     : IN     BOOLEAN;          -- specify reference edge
            CONSTANT HeaderMsg         : IN     STRING := " ";
            VARIABLE TimeMarker        : INOUT  TimeMarkerType;   -- holds time of last Reference transition
                                                                  -- and the last time a hold check passed
            VARIABLE TestPortLastEvent : INOUT  DelayArrayTypeXX; -- records time of test port events
            VARIABLE TestPortLastValue : INOUT  std_logic_vector; -- records previous test port values
            VARIABLE Violation         : OUT    BOOLEAN
                                       ); -- {TVTG}

    PROCEDURE VitalTimingCheck (
            SIGNAL   TestPort          : IN     std_logic_vector; -- SIGNAL being tested
            CONSTANT TestPortName      : IN     STRING := "";     -- name OF the signal
            SIGNAL   RefPort           : IN     std_ulogic;       -- SIGNAL being referenced
            CONSTANT RefPortName       : IN     STRING := "";     -- name OF the ref signal
            CONSTANT t_setup_hi        : IN     TIME := 0 ns;     -- setup spec FOR test PORT = '1'
            CONSTANT t_setup_lo        : IN     TIME := 0 ns;     -- setup spec FOR test PORT = '0'
            CONSTANT t_hold_hi         : IN     TIME := 0 ns;     -- hold spec FOR test PORT = '1'
            CONSTANT t_hold_lo         : IN     TIME := 0 ns;     -- hold spec FOR test PORT = '0'
            CONSTANT CheckEnabled      : IN     BOOLEAN;          -- true ==> spec checked.
            CONSTANT RefTransition     : IN     BOOLEAN;          -- specify reference edge
            CONSTANT HeaderMsg         : IN     STRING := " ";
            VARIABLE TimeMarker        : INOUT  TimeMarkerType;   -- holds time of last Reference transition
                                                                  -- and the last time a hold check passed
            VARIABLE TestPortLastEvent : INOUT  DelayArrayTypeXX; -- records time of test port events
            VARIABLE TestPortLastValue : INOUT  std_logic_vector; -- records previous test port values
            VARIABLE Violation         : OUT    X01
                                       ); -- {TVTG}

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
                                       ); -- {TVTG}

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
                                       ); -- {TVTG}

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    -- Pulse Width and Period Checks
    ---------------------------------------------------------------------------

    SUBTYPE PeriodCheckInfoType IS DelayArrayTypeXX(0 to 1);
    CONSTANT PeriodCheckInfoInit : PeriodCheckInfoType := (1 us, 1 us);

    -- -----------------------------------------------------------------
    --  Procedure Name : VitalPeriodCheck
    --      parameters :
    --         IN      : TestPort       -- SIGNAL    being tested for periodicity
    --         IN      : TestPortName   -- CONSTANT  string representing the name of the tested signal
    --         IN      : PeriodMin      -- CONSTANT  time ::= minimum period
    --         IN      : PeriodMax      -- CONSTANT  time ::= maximum period
    --         IN      : pw_hi_min      -- CONSTANT  time ::= minimum high pulse width 
    --         IN      : pw_hi_max      -- CONSTANT  time ::= maximum high pulse width
    --         IN      : pw_lo_min      -- CONSTANT  time ::= maximum low  pulse width 
    --         IN      : pw_lo_max      -- CONSTANT  time ::= maximum low  pulse width
    --         INOUT   : info           -- VARIABLE  -- retains time info from one cycle to the next
    --         OUT     : Violation      -- VARIABLE  Boolean; TRUE if violation occurred
    --         IN      : HeaderMsg      -- CONSTANT  string ::= device hierarchical path
    --
    --
    --     Notes       :   
    --
    --                    _______________         __________
    --       ____________|               |_______|
    --
    --                   |<--- pw_hi --->|
    --                   |<-------- period ----->|
    --                                -->| pw_lo |<--
    --             
    --      USE        : This procedure must be used in conjunction
    --                   with a process statement in order to retain
    --                   the transition times to '0' and '1'
    --
    --        check_clk : Process (clk)
    --              variable PeriodCheckInfo : DelayArrayTypeXX(0 to 1) := PeriodCheckInfo_Init;
    --              variable violation : boolean := false;
    --        begin
    --                VitalPeriodCheck (
    --                               TestPort       => CLK,
    --                               TestPortName   => "CLK",
    --                               PeriodMin      => 50 ns,
    --                               PeriodMax      => 10 us,
    --                               pw_hi_min      => 10 ns,
    --                               pw_hi_max      =>  5 us,
    --                               pw_lo_min      => 20 ns,
    --                               pw_lo_max      =>  5 us,
    --                               info           => PeriodCheckInfo,
    --                               violation      => violation,
    --                               HeaderMsg      => InstanceHeader
    --                             );
    --                if violation then
    --                     Q <= 'X';
    --                end if;
    --        end process check_clk;
    --
    -- ------------------------------------------------------------------------
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
                                      ); -- {TVTG}
    --------------------------------------------------------------------------
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
                                      ); -- {TVTG}
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    -- Glitch Handlers
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
 
    -------------------------------------------------------------------------------------
    -- Procedure  : VitalGlitchOnEvent, GlitchOnDetect
    --
    -- Purpose    : A GLITCH is said to occur whenever a new assignment is scheduled
    --              to occur at an absolute time which is less than the absolute time
    --              of a previously scheduled pending event. 
    --                             _______________________________
    --            Signal_A: _______|
    --                                    ________________________
    --            Signal_B: ______________|
    --       
    --                       events caused by...  A^        B^
    --                                             __________
    --            Output_C: _______________________|         |_________  without glitch handling
    --                                                       
    --            Output_C: ______________XXXXXXXXXXXXXXXXXXX|_________  GlitchOnDetect
    --                                                       
    --            Output_C: _______________________XXXXXXXXXX|_________  GlitchOnEvent   
    -- 
    -- Parameters : OutSignal ............ signal being driven
    --            : OutSignalName......... name of the driven signal
    --            : GlitchData............ internal data required by the procedure
    --            : NewValue.............. new value being assigned
    --            : NewDelay.............. Delay accompanying the assignment
    --                                     (Note: for vectors, this is an array)
    --            : GlitchMode............ either ( MessagePlusX, MessageOnly, XOnly, NoGlitch )
    --            : GlitchDelay........... if <= 0 ns , then there will be no Glitch
    --                                     if >  NewDelay, then there is no Glitch,
    --                                     otherwise, this is the time when a FORCED
    --                                     generation of a glitch will occur. 
    -------------------------------------------------------------------------------------
    PROCEDURE VitalGlitchOnEvent (
            SIGNAL   OutSignal        : OUT   std_logic;       -- signal being driven
            CONSTANT OutSignalName    : IN    string;          -- name of the signal
            VARIABLE GlitchData       : INOUT GlitchDataType;  -- Internal glitch data
            CONSTANT NewValue         : IN    std_logic;       -- value being assigned
            CONSTANT NewDelay         : IN    TIME  := 0 ns;   -- delay value
            CONSTANT GlitchMode       : IN    GlitchModeType := MessagePlusX;
            CONSTANT GlitchDelay      : IN    TIME  := 0 ns    -- delay to possible glitch
--            CONSTANT PulseRejectLimit : IN    TIME := 0 ns
            );
 
    PROCEDURE VitalGlitchOnDetect (
            SIGNAL   OutSignal        : OUT   std_logic;       -- signal being driven
            CONSTANT OutSignalName    : IN    string;          -- name of the signal
            VARIABLE GlitchData       : INOUT GlitchDataType;  -- Internal glitch data
            CONSTANT NewValue         : IN    std_logic;       -- value being assigned
            CONSTANT NewDelay         : IN    TIME  := 0 ns;   -- delay value
            CONSTANT GlitchMode       : IN    GlitchModeType := MessagePlusX;
            CONSTANT GlitchDelay      : IN    TIME  := 0 ns    -- delay to possible glitch
--            CONSTANT PulseRejectLimit : IN    TIME := 0 ns
            );
 
    PROCEDURE VitalGlitchOnEvent (
            SIGNAL   OutSignal        : OUT   std_logic_vector; -- signal being driven
            CONSTANT OutSignalName    : IN    string;           -- name of the signal
            VARIABLE GlitchData       : INOUT GlitchDataArrayType;      -- Internal glitch data
            CONSTANT NewValue         : IN    std_logic_vector; -- value being assigned
            CONSTANT NewDelay         : IN    TimeArray;        -- delay values
            CONSTANT GlitchMode       : IN    GlitchModeType := MessagePlusX;
            CONSTANT GlitchDelay      : IN    TimeArray         -- delay to possible glitch
--            CONSTANT PulseRejectLimit : IN    TIME := 0 ns
            );
 
    PROCEDURE VitalGlitchOnDetect (
            SIGNAL   OutSignal        : OUT   std_logic_vector; -- signal being driven
            CONSTANT OutSignalName    : IN    string;           -- name of the signal
            VARIABLE GlitchData       : INOUT GlitchDataArrayType;      -- Internal glitch data
            CONSTANT NewValue         : IN    std_logic_vector; -- value being assigned
            CONSTANT NewDelay         : IN    TimeArray;        -- delay values
            CONSTANT GlitchMode       : IN    GlitchModeType := MessagePlusX;
            CONSTANT GlitchDelay      : IN    TimeArray         -- delay to possible glitch
--            CONSTANT PulseRejectLimit : IN    TIME := 0 ns
            );
 
END VITAL_Timing;

