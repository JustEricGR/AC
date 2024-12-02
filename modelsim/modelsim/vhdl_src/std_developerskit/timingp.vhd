-- ----------------------------------------------------------------------------
--
--  Copyright (c) Mentor Graphics Corporation, 1982-1996, All Rights Reserved.
--                       UNPUBLISHED, LICENSED SOFTWARE.
--            CONFIDENTIAL AND PROPRIETARY INFORMATION WHICH IS THE
--          PROPERTY OF MENTOR GRAPHICS CORPORATION OR ITS LICENSORS.
--
--
-- PackageName :  STD_Timing  (stand alone)
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
-- Modification History :
-- ----------------------------------------------------------------------------
--   Version No:| Author:|  Mod. Date:| Changes Made:
--     v1.000   |  ****  |  09/16/91  | Production release
--     v1.010   |  wdb   |  10/24/91  | Production release update
--     v1.020   |  wdb   |  11/12/91  | Added default value to Refport on PeriodCheck
--     v1.100   |  wdb   |  12/29/91  | Production Release
--     v1.101   |  rjr   |  01/13/92  | general cleanup of violation watchdogs
--     v1.110   |  mkd   |  03/06/92  | fixing 32bit time problem
--     v1.110   |  mkd   |  03/06/92  | Production release
--     v1.120   |  wdb   |  03/17/92  | fix ffd, fs problems in derating eqs'n
--     v1.130   |  mkd   |  03/20/92  | fix fs problems in PulseCheck and SpikeCheck
--     v1.200   |  mkd   |  04/21/92  | stand alone version
--     v1.210   |  rjr   |  06/18/92  | Add overloaded CalcDelay, ReleaseViolation
--     v1.211   |  rjr   |  07/27/92  | Fix Soft Error detect in ReleaseViolation
--     v1.300   |  mkd   |  08/03/92  | production release update
--     v1.400   |  mkd   |  11/06/92  | production release update
--     v1.500   |  mkd   |  11/17/92  | fixed default 0 time
--     v1.600   |  mkd   |  02/11/93  | Production release update +
--              |  wdb   |  02/23/93  | VITAL enhancements
--     v1.610   |  wrm   |  03/30/93  | fixed bug in timingcheck assertion
--              |        |            | and spikecheck and pulsecheck and
--              |        |            | vantage bug fix to timingcheck
--     v1.700 B |  wrm   |  05/03/93  | beta release - no changes from 1.61
--     v1.700   |  wrm   |  05/25/93  | production release - minor change in assertions for timingcheck
--     v1.800   |  wrm   |  07/28/93  | combining into 1 file and mentor support, bug in timingcheck fixed
--     v2.000   |  wrm   |  07/21/94  | production release - addition of skew check, assorted upgrades
--     v2.001g  |  wrm   |  08/24/95  | Minor modification to vector form of TimingCheck to fix bug that 
--				      | causes violation not to be reported if Test Port and Ref. Port change
--				      | at same delta.  Also related changes to other timing procedures
--				      | to fix similar problem with transitions from X.
--     v2.100   |  wrm   |  01/10/96  | Production release
--				      | Initialization banner removed
--     v2.2     |  bmc   |  07/25/96  | Updated for Mentor Graphics Release
-- ----------------------------------------------------------------------------

LIBRARY IEEE;
USE     IEEE.Std_Logic_1164.ALL; -- Reference the STD_Logic system

PACKAGE Std_Timing IS
 -- ************************************************************************
 -- Display Banner
 -- ************************************************************************
    CONSTANT StdTimingBanner : BOOLEAN;
 

 -- ************************************************************************
 -- Standard Physical Types
 -- ************************************************************************
     -----------------------------------------------------------------------
     -- Note : Be aware that the span of values of the physical types
     -- may exceed its decared range. In the example below, 10 ghz
     -- exceeds the integer data type range of values
     --
     --     CONSTANT  radiowaves  : Frequency := 10 ghz ;
     -----------------------------------------------------------------------
     -----------------------------------------------------------------------
     -- Capacitance
     -----------------------------------------------------------------------
     TYPE Capacitance IS RANGE INTEGER'LOW TO INTEGER'HIGH
         UNITS
             ffd;               -- femtofarad ( sorry character type used FF )
             pf  = 1000 ffd;    -- picofarad
             nf  = 1000 pf;     -- nanofarad
         END UNITS;
     -----------------------------------------------------------------------
     -- Voltage
     -----------------------------------------------------------------------
     TYPE Voltage IS RANGE INTEGER'LOW TO INTEGER'HIGH
         UNITS
             uv;                -- microvolts
             mv  = 1000 uv;     -- millivolts
             v   = 1000 mv;     -- volts
         END UNITS;
     -----------------------------------------------------------------------
     -- Current
     -----------------------------------------------------------------------
     TYPE Current IS RANGE INTEGER'LOW TO INTEGER'HIGH
         UNITS
             na;                -- nanoamps
             ua  = 1000 na;     -- microamps
             ma  = 1000 ua;     -- milliamps
         END UNITS;
     -----------------------------------------------------------------------
     -- Temperature
     -----------------------------------------------------------------------
     TYPE Temperature IS RANGE  INTEGER'LOW TO INTEGER'HIGH
         UNITS
             mdegreesC;
             degreesC    = 1000 mdegreesC;
         END UNITS;
     -----------------------------------------------------------------------
     -- Frequency
     -----------------------------------------------------------------------
     TYPE Frequency IS RANGE INTEGER'LOW TO INTEGER'HIGH
         UNITS
             hz;                -- hertz
             khz = 1000 hz;     -- kilohertz
             mhz = 1000 khz;    -- megahertz
             ghz = 1000 mhz;    -- gigahertz
         END UNITS;


 -- ************************************************************************
 -- Timing Interface - Generic Parameter Types
 -- ************************************************************************
     -- ------------------------------------------------------------------------
     -- Pin-to-Pin Timing Generic Parameters
     -- ------------------------------------------------------------------------
     -- Objectives :
     --    (a) Provide burned-in (default) actual data
     --    (b) Provide ability for user to modify (override) burned-in data
     --    (c) Provide ability for user to add their own timing
     --    (d) Provide ability for user to switch between their
     --        own timing and the burned-in data.
     --    (e) Support passed timing values or Base/Increment
     -- ------------------------------------------------------------------------
     TYPE TimeModeType IS ( t_minimum, -- choose minimum time spec
                            t_typical, -- choose typical time spec
                            t_maximum, -- choose maximum time spec
                            t_special  -- choose user defined time delay
                          );
     -----------------------------------------------------------------------
     -- STYLE A : Straight-Forward Timing Values
     -----------------------------------------------------------------------
     -- Example ( generic declarations ) :
     --  tplh_a2_y2 : MinTypMaxTime := ( 12.0 ns, 17.0 ns, 32.0 ns, UnitDelay );
     --                                   ^^^      ^^^      ^^^        ^^^
     --                                   min      typ      max     user_defined
     -----------------------------------------------------------------------

     TYPE MinTypMaxTime IS ARRAY ( TimeModeType ) OF TIME;

     -- --------------------------------------------------------------------
     -- VITAL Compliant
     -- --------------------------------------------------------------------
     TYPE MTM is array (TimeModeType range <>) of TIME;
     Subtype MinTypMax is MTM (t_minimum to t_maximum);
 
     -----------------------------------------------------------------------
     -- Example ( generic declarations ) :
     --  tplh_a2_y2 : MinTypMax := (12.0 ns, 17.0 ns, 32.0 ns);
     --                               ^^^     ^^^     ^^^
     --                               min     typ     max
     -----------------------------------------------------------------------
     TYPE TvalType is array (Natural range <>) of MinTypMax;
     ------------------------------------------------------------------------
     -- Example
     -- CONSTANT Tdefault_chipname: TvalType(1 to 20) := (others => (0 ns, 0 ns, 0 ns));
     ------------------------------------------------------------------------

     -----------------------------------------------------------------------
     -- STYLE B : Base Delay / Incremental Delay Values
     -----------------------------------------------------------------------
     --
     -- Example ( generic declarations ) :
     --      tplh_clk_q : BaseIncrDelay := (t_minimum => ( 0.46 ns, 2.08 ns ),
     --                                     t_typical => ( 0.56 ns, 3.08 ns ),
     --                                     t_maximum => ( 0.68 ns, 5.08 ns ),
     --                                     t_special => UnitBIDelay
     --                                    );
     -----------------------------------------------------------------------
     TYPE BaseIncrType IS ( BaseDly, IncrDly );
     TYPE BaseIncrDlyPair IS ARRAY ( BaseIncrType ) OF TIME;
     TYPE BaseIncrDelay IS ARRAY ( TimeModeType ) OF BaseIncrDlyPair;

 -- ************************************************************************
 --  Type Declarations for facilitating this package
 -- ************************************************************************
     -------------------------------------------------------------------
     -- Propagation Delay Information
     -- Input Transition / Output Transition Format
     -------------------------------------------------------------------
     TYPE PropDelayElem IS ( Tp11,    -- Rising  Input - Certain Rising  Output
                             Tp10,    -- Rising  Input - Certain Falling Output
                             Tp01,    -- Falling Input - Certain Rising  Output
                             Tp00,    -- Falling Input - Certain Falling Output
                             Tp11x,   -- Rising  Input - Possible Rising  Output
                             Tp10x,   -- Rising  Input - Possible Falling Output
                             Tp01x,   -- Falling Input - Possible Rising  Output
                             Tp00x    -- Falling Input - Possible Falling Output
                           );
     TYPE PropDelayType  IS ARRAY ( PropDelayElem  ) OF TIME;
     TYPE DelayPair      IS ARRAY ( std_ulogic RANGE '1' DOWNTO '0' ) OF TIME;
     ----------------------------------------------------------------------
     -- Constant t_d_clk : DelayPair := ( 10.2 ns, 24.1 ns);
     -- t_d_clk('1') := tplh;
     -- t_d_clk('0') := tphl;
     -- Also if a given signal is known to be either '1' or '0', then
     -- the signal itself may be used to index into the DelayPair !
     ----------------------------------------------------------------------

     TYPE TransitionType IS ( tr01,
                              tr10,
                              tr0z,
                              trz0,
                              tr1z,
                              trz1 );
     SUBTYPE RiseFall    IS TransitionType RANGE tr01 TO tr10;

     --------------------------------------------------------------------------
     -- Unconstrained array declarations - For specification vector port Specs.
     --------------------------------------------------------------------------
     TYPE TIME_Vector          IS ARRAY ( NATURAL RANGE <>) OF TIME;
     TYPE BOOLEAN_vector       IS ARRAY ( NATURAL RANGE <>) OF BOOLEAN;
     TYPE PropDelayVector      IS ARRAY ( NATURAL RANGE <>) OF PropDelayType;
     TYPE BaseIncrDlyVector    IS ARRAY ( NATURAL RANGE <>) OF BaseIncrDelay;
     TYPE DelayPairVector      IS ARRAY ( NATURAL RANGE <>) OF DelayPair;

     TYPE CapacitanceVector    IS ARRAY ( NATURAL RANGE <>) OF Capacitance;

     TYPE MinTypMaxTimeVector  IS ARRAY ( NATURAL RANGE <>) OF MinTypMaxTime;

     -----------------------------------------------------------------------
     -- Data type for period check function
     -----------------------------------------------------------------------
     SUBTYPE PeriodCheckInfoType IS TIME_Vector (0 TO 3);

 -- ************************************************************************
 -- Constants
 -- ************************************************************************

     CONSTANT UnitDelay   : TIME;
     CONSTANT UnitBIDelay : BaseIncrDlyPair;




     CONSTANT NoDelayPath : TIME;    -- Delay indication for non-dependent
                                     --  input->output values combination

     CONSTANT PeriodCheckInfo_Init : PeriodCheckInfoType
                                   := ( -1 us, -1 us, 1 us, 1 us );

 -- ************************************************************************
 -- ATTRIBUTES
 -- ************************************************************************
     SUBTYPE NaturalReal IS REAL RANGE 0.0 TO REAL'HIGH;

     ATTRIBUTE FanoutDrive  : NaturalReal; -- number of DC loads that can be driven
     ATTRIBUTE FaninLoad    : NaturalReal; -- number of DC input loads

     ATTRIBUTE CLoad        : Capacitance; -- capacitive load of an input


--+ ****************************************************************************
--+ DERATING
--+ ****************************************************************************
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
     TYPE RealFactors IS ARRAY ( RiseFall ) OF REAL;
     TYPE PolynomialCoeff IS ARRAY ( 3 DOWNTO 0 ) OF REAL;
     TYPE CTV IS ( CapDerateCoeff_lh , CapDerateCoeff_hl,
                   TempDerateCoeff_lh, TempDerateCoeff_hl,
                   VoltageDerateCoeff_lh, VoltageDerateCoeff_hl );
     TYPE DerateCoeffArray IS ARRAY ( CTV ) OF PolynomialCoeff;

     TYPE RealFactorsVector    IS ARRAY ( NATURAL RANGE <>) OF RealFactors;


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
                            ) RETURN REAL;

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
                            ) RETURN REAL;

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
                            ) RETURN REAL;

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
 --+             tplh_a1_y1 : MinTypMaxTime := DefaultMinTypMaxTime
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
                                    ) RETURN RealFactors;
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
                CONSTANT SysDerCoeff: IN     DerateCoeffArray;      -- Derating Coefficients
                CONSTANT SysVoltage : IN     Voltage;           -- operating voltage
                CONSTANT SysTemp    : IN     Temperature;       -- operating temperature
                CONSTANT OutputLoad : IN     CapacitanceVector  -- capacitive load on output pin
                                    ) RETURN RealFactorsVector;


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
     --           Pathdelay_clk : DelayPair := DefaultDelayPair;                -- scalar
     --           Pathdelay_abus: DelayPairVector := (others=>DefaultDelayPair) -- vector
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
     --+ Assumption : SignalOut'length = newval'length = oldval'length
     --+
     --+ Example for scalar signals :
     --+
     --+ First, declare a generic parameter for the wire delays
     --+ of each input signal...
     --+
     --+ Generic (
     --+           Pathdelay_d : DelayPair := DefaultDelayPair; -- input path delay for d
     --+           Pathdelay_abus: DelayPairVector := (others => DefaultDelayPair) -- vector
     --+         );
     --+
     --+ Then in the architecture declaration section, declare an internal
     --+ signal corresponding to the path delayed input signal...
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
                               );
     PROCEDURE AssignPathDelay ( SIGNAL   SignalOut     : OUT   std_ulogic_vector; -- name of path delayed signal
                                 CONSTANT newval        : IN    std_ulogic_vector;
                                 CONSTANT oldval        : IN    std_ulogic_vector;
                                 CONSTANT PathDelay     : IN    DelayPairVector;
                                 CONSTANT StripStrength : IN    BOOLEAN
                               );
     PROCEDURE AssignPathDelay ( SIGNAL   SignalOut     : OUT   std_logic_vector; -- name of path delayed signal
                                 CONSTANT newval        : IN    std_logic_vector;
                                 CONSTANT oldval        : IN    std_logic_vector;
                                 CONSTANT PathDelay     : IN    DelayPairVector;
                                 CONSTANT StripStrength : IN    BOOLEAN
                               );


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
                                        ) RETURN TIME;
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
     --+   CONSTANT Tp01_a1_y1 : MinTypMaxTime
     --+                 := BaseIncrToMinTypeMaxTime (tphl_a1_y1, Cload_y1);
     --+---------------------------------------------------------------------------
        FUNCTION BaseIncrToMinTypMaxTime (
                    CONSTANT BIDelay    : IN     BaseIncrDelay;
                    CONSTANT CLoad      : IN     Capacitance
                                        ) RETURN MinTypMaxTime;

--+ ****************************************************************************
--+  Output Assignment with propagation Delay (+ out wire delay)
--+ ****************************************************************************
    ----------------------------------------------------------------------------
    -- CASE 1 : Simple Assignments
    ----------------------------------------------------------------------------
    -- In the simple case, we wish to assign an output with a delay which is
    -- based upon the OUTPUT value transitioning from its old value to its new value
    ----------------------------------------------------------------------------
    -----------------------------------------------------------------------
    -- Function   : CalcDelay
    -- Returns    : time
    -- Purpose    : This function determines the proper value of delay to
    --            : use given the newly assigned value and the existing
    --            : value on the signal or driver.
    --            :
    -- Overloading: This function is overloaded to provide a means of
    --            : specifying the delays in concise or verbose mode.
    --            :
    -- Arguments  : See the declarations below...
    --            :
    -- Defaults   : For the verbose form, not all of the parameters need
    --            : to be passed since defaults are provided for those
    --            : not passed.
    --            :
    -- Assumption : newval'length = oldval'length for vectored signals
    --
    -- Example :
    --
    --    In this example, we don't care what the old value is, hence the function
    --    will make the determination of which delay to select based upon the new
    --    value only.
    --
    --    y <= the_new_value AFTER CalcDelay ( newval => the_new_value,
    --                                         oldval => '-',
    --                                         tp01   => tplh_a_y,
    --                                         tp10   => tphl_a_y
    --                                         -- in this example the remaining
    --                                         -- parameters are not specified
    --                                       );
    --
    ----------------------------------------------------------------------------
    FUNCTION CalcDelay (
                         CONSTANT    value  : IN std_ulogic;        -- new value of signal
                         CONSTANT    Tp1    : IN TIME := UnitDelay; -- 0->1 delay value
                         CONSTANT    Tp0    : IN TIME := UnitDelay  -- 1->0 delay value
                       ) RETURN TIME;
    
------------------------------------------------------------------------
    FUNCTION CalcDelay (
                         CONSTANT    value  : IN std_logic_vector;  -- new value of signal
                         CONSTANT    Tp1    : IN TIME := UnitDelay; -- 0->1 delay value
                         CONSTANT    Tp0    : IN TIME := UnitDelay  -- 1->0 delay value
                       ) RETURN TIME_Vector;
------------------------------------------------------------------------
    FUNCTION CalcDelay (
                         CONSTANT    value  : IN std_ulogic_vector;  -- new value of signal
                         CONSTANT    Tp1    : IN TIME := UnitDelay; -- 0->1 delay value
                         CONSTANT    Tp0    : IN TIME := UnitDelay  -- 1->0 delay value
                       ) RETURN TIME_Vector;
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
                       ) RETURN TIME;
    FUNCTION CalcDelay (
                         CONSTANT    newval : IN std_logic_vector;  -- new value of signal
                         CONSTANT    oldval : IN std_logic_vector;  -- old value of signal
                         CONSTANT    Tp01   : IN TIME := UnitDelay; -- 0->1 delay value
                         CONSTANT    Tp10   : IN TIME := UnitDelay; -- 1->0 delay value
                         CONSTANT    tp0z   : IN TIME := UnitDelay; -- 0->z delay value
                         CONSTANT    tp1z   : IN TIME := UnitDelay; -- 1->z delay value
                         CONSTANT    tpz0   : IN TIME := UnitDelay; -- z->0 delay value
                         CONSTANT    tpz1   : IN TIME := UnitDelay  -- z->1 delay value
                       ) RETURN TIME_Vector;
    FUNCTION CalcDelay (
                         CONSTANT    newval : IN std_ulogic_vector; -- new value of signal
                         CONSTANT    oldval : IN std_ulogic_vector; -- old value of signal
                         CONSTANT    Tp01   : IN TIME := UnitDelay; -- 0->1 delay value
                         CONSTANT    Tp10   : IN TIME := UnitDelay; -- 1->0 delay value
                         CONSTANT    tp0z   : IN TIME := UnitDelay; -- 0->z delay value
                         CONSTANT    tp1z   : IN TIME := UnitDelay; -- 1->z delay value
                         CONSTANT    tpz0   : IN TIME := UnitDelay; -- z->0 delay value
                         CONSTANT    tpz1   : IN TIME := UnitDelay  -- z->1 delay value
                       ) RETURN TIME_Vector;

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
 --+               as Possable errors. This signal change will hide any True
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
                                      ) RETURN BOOLEAN;
 --+ ---------------------------------------------------------------------------
 --+  Procedure  Name : TimingCheck
 --+      parameters :
 --+         IN      : TestPort       -- SIGNAL    std_logic_vector
 --+         IN      : TestPortName   -- CONSTANT  string
 --+         IN      : RefPort        -- SIGNAL    std_logic
 --+         IN      : RefPortName    -- CONSTANT  string
 --+         IN      : t_setup_hi     -- CONSTANT  time
 --+         IN      : t_setup_lo     -- CONSTANT  time
 --+         IN      : t_hold_hi      -- CONSTANT  time
 --+         IN      : t_hold_lo      -- CONSTANT  time
 --+         IN      : condition      -- CONSTANT  boolean
 --+         IN      : HeaderMsg      -- CONSTANT  string
 --+         INOUT   : TestPortLastEvent -- VARIABLE  TIME_vector
 --+         INOUT   : Violation      -- VARIABLE  boolean
 --+	     IN	     : WarningsOn     -- CONSTANT  boolean
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
 --+               as Possable errors. This signal change will hide any True
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
            CONSTANT condition         : IN     BOOLEAN;	-- true ==> spec checked.
            CONSTANT HeaderMsg         : IN     STRING := " ";
            VARIABLE Violation         : INOUT  BOOLEAN;
	    CONSTANT WarningsOn	       : IN     BOOLEAN := TRUE -- IF TRUE assertions are generated
                                       );
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
	    CONSTANT WarningsOn	       : IN     BOOLEAN := TRUE   -- IF TRUE assertions are generated
                                       );
    PROCEDURE TimingCheck (
            SIGNAL   TestPort          : IN     std_ulogic_vector;-- SIGNAL being tested
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
	    CONSTANT WarningsOn	       : IN     BOOLEAN := TRUE   -- IF TRUE assertions are generated
                                       );

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
            CONSTANT condition    : IN     BOOLEAN;        -- IF true THEN the spec will be checked.
            CONSTANT HeaderMsg    : IN     STRING := " ";
	    CONSTANT WarningsOn   : IN     BOOLEAN := TRUE -- IF TRUE assertions are generated
                                  ) RETURN BOOLEAN;
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
                                      );
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
            CONSTANT condition    : IN     BOOLEAN;        -- IF true THEN the spec will be checked.
            CONSTANT HeaderMsg    : IN     STRING := " ";
	    CONSTANT WarningsOn   : IN     BOOLEAN := TRUE -- IF TRUE assertions are generated
                                  ) RETURN BOOLEAN;
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
                                  );

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
                CONSTANT DataPortVal  : IN     std_ulogic;     -- value being latched
                CONSTANT t_release_hi : IN     TIME := 0 ns;   -- release spec FOR data = '1'
                CONSTANT t_release_lo : IN     TIME := 0 ns;   -- release spec FOR data = '0'
                CONSTANT condition    : IN     BOOLEAN;        -- IF true THEN the spec will be checked.
                CONSTANT HeaderMsg    : IN     STRING := " ";
		CONSTANT WarningsOn   : IN     BOOLEAN := TRUE -- IF TRUE assertions are generated
                                      ) RETURN BOOLEAN;
    FUNCTION ReleaseViolation (
                SIGNAL   CtrlPort     : IN     std_ulogic;     -- SIGNAL being ctrled
                CONSTANT CtrlPortName : IN     STRING := "";   -- name OF the signal
                SIGNAL   RefPort      : IN     std_ulogic;     -- SIGNAL being referenced
                CONSTANT RefPortName  : IN     STRING := "";   -- name OF the ref signal
                CONSTANT DataPortVal  : IN     std_ulogic;     -- value being latched
                CONSTANT t_release_hi : IN     TIME := 0 ns;   -- release spec FOR data = '1'
                CONSTANT t_release_lo : IN     TIME := 0 ns;   -- release spec FOR data = '0'
                CONSTANT t_hold_hi    : IN     TIME ;          -- hold spec FOR data = '1'
                CONSTANT t_hold_lo    : IN     TIME ;          -- hold spec FOR data = '0'
                CONSTANT condition    : IN     BOOLEAN;        -- true ==> spec checked.
                CONSTANT HeaderMsg    : IN     STRING := " ";
		CONSTANT WarningsOn   : IN     BOOLEAN := TRUE -- IF TRUE assertions are generated
                                      ) RETURN BOOLEAN;

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
                                      );
    PROCEDURE ReleaseCheck (
            SIGNAL   CtrlPort          : IN     std_ulogic;   -- SIGNAL being ctrled
            CONSTANT CtrlPortName      : IN     STRING := ""; -- name OF the signal
            SIGNAL   RefPort           : IN     std_ulogic;   -- SIGNAL being referenced
            CONSTANT RefPortName       : IN     STRING := ""; -- name OF the ref signal
            CONSTANT DataPortVal       : IN     std_ulogic;   -- value being latched
            CONSTANT t_release_hi      : IN     TIME := 0 ns; -- release spec FOR data = '1'
            CONSTANT t_release_lo      : IN     TIME := 0 ns; -- release spec FOR data = '0'
            CONSTANT t_hold_hi         : IN     TIME ;        -- hold spec FOR data = '1'
            CONSTANT t_hold_lo         : IN     TIME ;        -- hold spec FOR data = '0'
            CONSTANT condition         : IN     BOOLEAN;      -- true ==> spec checked.
            CONSTANT HeaderMsg         : IN     STRING := " "
                                       );

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
 --+	     IN	     : WarningsOn     -- CONSTNAT  Boolean; if TRUE then assertions are generated
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
                                      );

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
 --+        However TestPort'DELAYED(0 ns)'LAST_EVENT does work.
 --+        [ timemark NO LONGER NEEDED ]
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
                                      );
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
                                      );

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
                                       );
				       	      
--+ ****************************************************************************
--+ UTILITY FUNCTIONS
--+ ****************************************************************************
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
        FUNCTION MAXIMUM ( CONSTANT t1,t2 : IN TIME ) RETURN TIME;
        FUNCTION MAXIMUM ( CONSTANT t1,t2,t3,t4 : IN TIME ) RETURN TIME;
        FUNCTION MAXIMUM ( CONSTANT tv    : IN TIME_Vector ) RETURN TIME;
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
        FUNCTION MINIMUM ( CONSTANT t1,t2 : IN TIME ) RETURN TIME;
        FUNCTION MINIMUM ( CONSTANT t1,t2,t3,t4 : IN TIME ) RETURN TIME;
        FUNCTION MINIMUM ( CONSTANT tv : IN TIME_Vector ) RETURN TIME;
 --+ ************************************************************************
 --+ Output Strength Determination
 --+ ************************************************************************
    TYPE TechnologyType IS ( cmos,            -- strongly driven
                             cmos_od,         -- open drain
                             ttl,             -- strongly driven
                             ttl_oc,          -- open collector
                             nmos,            -- strong '0', weak '1'
                             ecl,             -- weak '0', strong '1'
                             pullup,          -- weak '1'
                             pulldown         -- weak '0'
                           );
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
    FUNCTION Drive ( CONSTANT val  : IN std_ulogic;        -- new signal value
                     CONSTANT tech : TechnologyType        -- technology type
                   ) RETURN std_ulogic;

    FUNCTION Drive ( CONSTANT val  : IN std_logic_vector;  -- new signal value
                     CONSTANT tech : TechnologyType        -- technology type
                   ) RETURN std_logic_vector;

    FUNCTION Drive ( CONSTANT val  : IN std_ulogic_vector; -- new signal value
                     CONSTANT tech : TechnologyType        -- technology type
                   ) RETURN std_ulogic_vector;


END Std_Timing;
