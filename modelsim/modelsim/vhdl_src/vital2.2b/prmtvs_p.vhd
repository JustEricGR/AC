--------------------------------------------------------------------------
--                                         Copyright 1993, 1994
--                                         VHDL Initiative Toward ASIC Libraries (VITAL)
--                                         All rights reserved.
--
-- File name   :  prmtvs_p.vhd
-- PackageName :  VITAL_PRIMITIVES
-- Title       :  Standard VITAL Primitives Package
-- Library     :  This package shall be compiled into a library
--             :  symbolically named VITAL.
--             :
-- Purpose     :  This packages contains the VITAL primitive set.
--             :
-- Comments    :  
--             :
-- Assumptions : none
-- Limitations : States must be scalar elements
-- Known Errors: none
-- Developers  :  VITAL working group
--             :      Technical Director   : William Billowitch
--             :      European Coordinator : Eric Huyskens
--             :      U.S. Coordinator     : Steve Schulz
--             :      Significant Technical Contributions : Ray Ryan
--             :
-- Note        :  No declarations or definitions shall be included in,
--             :  or excluded from this package. The "package declaration"
--             :  defines the types, subtypes and declarations of the
--             :  VITAL_PRIMITIVES package. The VITAL_PRIMITIVES package body
--             :  shall be considered the formal definition of the semantics
--             :  of this package. Tool developers may choose to implement
--             :  the package body in the most efficient manner available
--             :  to them.
-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- This source code is copyrighted by the VHDL Initiative Toward ASIC Libraries
-- (VITAL) project. This source code may be distributed in whole or in part,
-- and/or used in derivative works provided that (a) the VITAL copyright
-- notice is included and (b) that the contributors to each section be
-- acknowledged by comments as required below.
-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>> Derivative Works NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- Portions of the software provided in this package have been contributed
-- by the VHDL Technology Group. The contributed portions are hereby released
-- into the public domain. The VHDL Technology Group retains the right to
-- include the same contributed portions with its own products or services.
-- Contributed declarations have the designator {TVTG} affixed as a comment.

-- Portions of the software provided in this package have been contributed
-- by Ryan & Ryan. The contributed portions are hereby released into
-- the public domain.  Ryan & Ryan retains the right to include
-- the same contributed portions with its own products or services.
-- Contributed declarations have the designator {R&R} affixed as a comment.

-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>> Warrantee <<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- No warrantees, expressed or implied are given.
-- ----------------------------------------------------------------------------
-- Modification History :
-- ----------------------------------------------------------------------------
--   Version No:| Author:|  Mod. Date:| Changes Made:
--     v0.100   |   rjr  |  08/18/93  | Original Contributions
--     v0.200   |   wdb  |  09/13/93  | Informational Release
--     v0.300   |   rjr  |  10/06/93  | Alpha release
--     v0.301   |   rjr  |  10/25/93  | change scalars to std_ulogic,
--     v0.302   |   rjr  |  11/30/93  | Add VitalIDENT, remove sequential prims
--                                      add ResultMap param
--                                      fix TIME overflow in GetSchedDelay
--     v0.400   |   rjr  |  01/21/94  | Updates for 2.1e specification
--                                      move Delay selection utils to Body
--                                      merge State and Table primitives
--     v0.402   |   wrm  |  02/18/94  | Remove level sensitive dominance from
--                                      VitalStateTable.
--     v0.403   |   wdb  |  03/13/94  | GlitchMode was changed to GlitchDetect
--                                      to avoid confusion with the timing pkg.
--     v0.404   |   sn   |  05/23/94  | Bug fixes in packages body
-- ----------------------------------------------------------------------------
-- Notes:
--
-- ----------------------------------------------------------------------------
-- >>>>>> THE FOLLOWING IS A LIST OF DEVIATIONS FROM THE DOCUMENTATION <<<<<<<<
-- ----------------------------------------------------------------------------
-- This is a list of deviations from the documentation that were found to be
-- necessary.
--
-- In VitalStateTable and VitalTruthTable, the single bit versions of the
-- procedures have Result being of type std_logic.  This has not been changed,
-- but for consistency purposes it would probably be beneficial to change the
-- type to std_ulogic.
-- ----------------------------------------------------------------------------

LIBRARY IEEE;
USE     IEEE.Std_logic_1164.all;

LIBRARY VITAL;
USE     VITAL.VITAL_TIMING.all;

PACKAGE VITAL_PRIMITIVES is
    -- ----------------------------------------------------------------------------
    -- Type and Subtype Declarations
    -- ----------------------------------------------------------------------------
    -- ----------------------------------------------------------------------------
    -- All of these SUBTYPE declarations are defined in the VITAL_TIMING package
    -- but are repeated here for ease of readability. WARNING: Do Not Uncomment if
    -- you plan to USE both packages as this may render the SUBTYPE declarations
    -- invisible to the user due to mutual hiding.
    -- 
    -- SUBTYPE std_logic_vector2 IS std_logic_vector(1 DOWNTO 0);
    -- SUBTYPE std_logic_vector3 IS std_logic_vector(2 DOWNTO 0);
    -- SUBTYPE std_logic_vector4 IS std_logic_vector(3 DOWNTO 0);
    -- SUBTYPE std_logic_vector8 IS std_logic_vector(7 DOWNTO 0);
    -- ----------------------------------------------------------------------------

    -- Type used to select glitch detection mode
    TYPE GlitchDetectType IS ( OnEvent, OnDetect );

    -- Type for strength mapping of primitive outputs
    TYPE ResultMapType IS ARRAY ( UX01 ) OF std_ulogic;
    TYPE ResultZMapType IS ARRAY ( UX01Z ) OF std_ulogic;
    CONSTANT DefaultResultMap  : ResultMapType  := ( 'U', 'X', '0', '1' );
    CONSTANT DefaultResultZMap : ResultZMapType := ( 'U', 'X', '0', '1', 'Z' );

    TYPE VitalTableSymbolType IS (
       '/',              -- 0 -> 1                                              (input)
       '\',              -- 1 -> 0                                              (input)
       'P',              -- Union of '/' and '^'                                (input)
       'N',              -- Union of '\' and 'v'                                (input)
       'r',              -- 0 -> X                                              (input)
       'f',              -- 1 -> X                                              (input)
       'x',              -- Unknown edge
       'U',              -- Uninitialized level
       'X',              -- Unknown level                                       (input, output)
       '0',              -- low level                                           (input, output)
       '1',              -- high level                                          (input, output)
       '-',              -- don't care on any LEVEL (will match any level)      (input, output)
       'B',              -- 0 or 1                                              (input)
       'Z',              -- High Impedance                                      (output)
       'p',              -- '/' and 'r' (any edge from 0)                       (input)
       'n',              -- '\' and 'f' (any edge from 1)                       (input)
       'R',              -- '^' and 'p' (any possible rising edge)              (input)
       'F',              -- 'v' and 'n' (any possible falling edge)             (input)
       '^',              -- X -> 1                                              (input)
       'v',              -- X -> 0                                              (input)
       'E',              -- 'v' and '^' (any edge from X)                       (input)
       'A',              -- 0 -> X, X -> 1                                      (input)
       'D',              -- 1 -> X, X -> 0                                      (input)
       '*',              -- 'R" and 'F' (any edge)                              (input)
       'S'               -- if used as an input it represents as steady value   (input, output)
                         -- if used as an output, the output retains is
                         -- present value
    );

    -- B is to facilitate modelling of sparse truth tables. It may have others uses.
    -- S is to facillitate a clock value remaining the same (for input).
    --      to allow output to remain at its last value (for output).

    -- **********************************************************
    -- **********************************************************
    --
    -- NOTE:  For each state table it is necessary that at least one
    -- entry be made with an S for the clock.  This will let the
    -- Procedure VitalStateTable handle the case where the procedure
    -- gets activated but the clock did not change.  If not included
    -- the result will default to Xs in this case
    --
    -- NOTE:  To model Mealy machines it is recommended that
    -- VitalStateTable be used to model the state transition and
    -- VitalTruthTable be used to model the output function.
    --
    -- **********************************************************
    -- **********************************************************
 
    -------------------------------------------------------------------------------
    -- For Truth Tables
    -------------------------------------------------------------------------------
    -- Entries restricted for expressing combinational logic
    SUBTYPE VitalTruthTableSymbol IS VitalTableSymbolType RANGE 'X' TO 'Z';
 
    TYPE VitalTruthTableType IS ARRAY ( NATURAL RANGE <>, NATURAL RANGE <> )
         OF VitalTruthTableSymbol;

    -------------------------------------------------------------------------------
    -- For State Tables
    -------------------------------------------------------------------------------
    TYPE VitalStateTableType IS ARRAY ( NATURAL RANGE <>, NATURAL RANGE <> )
         OF VitalTableSymbolType;
         
    -- ---------------------------------
    -- Default values used by primitives
    -- ---------------------------------
    CONSTANT DefDelay01  : DelayType01;         -- Propagation delays
    CONSTANT DefDelay01Z : DelayType01Z;
    CONSTANT DefDelayIO  : DelayTypeIO;
 
    CONSTANT GlitchDetect   : GlitchDetectType;
    CONSTANT PrimGlitchMode : GlitchModeType;   -- Glitch detection/reporting mode

    -- ============================================================================
    -- Primitives
    -- ============================================================================

    -- ---------------------------------------------------------------------------
    -- N-bit wide Logical gates.
    -- ---------------------------------------------------------------------------
    FUNCTION VitalAND    ( CONSTANT       data :  IN std_logic_vector;
                           CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                         ) RETURN std_ulogic;
    FUNCTION VitalOR     ( CONSTANT       data :  IN std_logic_vector;
                           CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                         ) RETURN std_ulogic;      
    FUNCTION VitalXOR    ( CONSTANT       data :  IN std_logic_vector;
                           CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                         ) RETURN std_ulogic;     
    FUNCTION VitalNAND   ( CONSTANT       data :  IN std_logic_vector;
                           CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                         ) RETURN std_ulogic;     
    FUNCTION VitalNOR    ( CONSTANT       data :  IN std_logic_vector;
                           CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                         ) RETURN std_ulogic;     
    FUNCTION VitalXNOR   ( CONSTANT       data :  IN std_logic_vector;
                           CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                         ) RETURN std_ulogic;     

    PROCEDURE VitalAND   ( SIGNAL            q : OUT std_ulogic;                     
                           SIGNAL         data :  IN std_logic_vector;
                           CONSTANT tpd_data_q :  IN DelayArrayType01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalOR    ( SIGNAL            q : OUT std_ulogic;                    
                           SIGNAL         data :  IN std_logic_vector;
                           CONSTANT tpd_data_q :  IN DelayArrayType01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalXOR   ( SIGNAL            q : OUT std_ulogic;                  
                           SIGNAL         data :  IN std_logic_vector;
                           CONSTANT tpd_data_q :  IN DelayArrayType01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalNAND  ( SIGNAL            q : OUT std_ulogic;                   
                           SIGNAL         data :  IN std_logic_vector;
                           CONSTANT tpd_data_q :  IN DelayArrayType01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalNOR   ( SIGNAL            q : OUT std_ulogic;                  
                           SIGNAL         data :  IN std_logic_vector;
                           CONSTANT tpd_data_q :  IN DelayArrayType01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalXNOR  ( SIGNAL            q : OUT std_ulogic;                  
                           SIGNAL         data :  IN std_logic_vector;
                           CONSTANT tpd_data_q :  IN DelayArrayType01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
 
    -- ----------------------------------------------------------------------------
    -- Commonly used 2-bit Logical gates.
    -- ----------------------------------------------------------------------------
    FUNCTION VitalAND2   ( CONSTANT       a, b :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic;           
    FUNCTION VitalOR2    ( CONSTANT       a, b :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic;           
    FUNCTION VitalXOR2   ( CONSTANT       a, b :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic;           
    FUNCTION VitalNAND2  ( CONSTANT       a, b :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic;           
    FUNCTION VitalNOR2   ( CONSTANT       a, b :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic;           
    FUNCTION VitalXNOR2  ( CONSTANT       a, b :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic;           

    PROCEDURE VitalAND2  ( SIGNAL            q : OUT std_ulogic;                       
                           SIGNAL         a, b :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalOR2   ( SIGNAL            q : OUT std_ulogic;                      
                           SIGNAL         a, b :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalXOR2  ( SIGNAL            q : OUT std_ulogic;                       
                           SIGNAL         a, b :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalNAND2 ( SIGNAL            q : OUT std_ulogic;                     
                           SIGNAL         a, b :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalNOR2  ( SIGNAL            q : OUT std_ulogic;                    
                           SIGNAL         a, b :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalXNOR2 ( SIGNAL            q : OUT std_ulogic;                      
                           SIGNAL         a, b :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
 
    -- ----------------------------------------------------------------------------
    -- Commonly used 3-bit Logical gates.
    -- ----------------------------------------------------------------------------
    FUNCTION VitalAND3   ( CONSTANT    a, b, c :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic;        
    FUNCTION VitalOR3    ( CONSTANT    a, b, c :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic;       
    FUNCTION VitalXOR3   ( CONSTANT    a, b, c :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic;      
    FUNCTION VitalNAND3  ( CONSTANT    a, b, c :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic;     
    FUNCTION VitalNOR3   ( CONSTANT    a, b, c :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic;    
    FUNCTION VitalXNOR3  ( CONSTANT    a, b, c :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic;   
 
    PROCEDURE VitalAND3  ( SIGNAL            q : OUT std_ulogic;                     
                           SIGNAL      a, b, c :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalOR3   ( SIGNAL            q : OUT std_ulogic;                    
                           SIGNAL      a, b, c :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalXOR3  ( SIGNAL           q : OUT std_ulogic;                 
                           SIGNAL      a, b, c :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalNAND3 ( SIGNAL            q : OUT std_ulogic;                   
                           SIGNAL      a, b, c :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalNOR3  ( SIGNAL            q : OUT std_ulogic;                  
                           SIGNAL      a, b, c :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalXNOR3 ( SIGNAL            q : OUT std_ulogic;                
                           SIGNAL      a, b, c :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
 
    -- ----------------------------------------------------------------------------
    -- Commonly used 3-bit Logical gates.
    -- ----------------------------------------------------------------------------
    FUNCTION VitalAND4   ( CONSTANT a, b, c, d :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic;      
    FUNCTION VitalOR4    ( CONSTANT a, b, c, d :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic;      
    FUNCTION VitalXOR4   ( CONSTANT a, b, c, d :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic;      
    FUNCTION VitalNAND4  ( CONSTANT a, b, c, d :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic;      
    FUNCTION VitalNOR4   ( CONSTANT a, b, c, d :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic;      
    FUNCTION VitalXNOR4  ( CONSTANT a, b, c, d :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic;      
 
    PROCEDURE VitalAND4  ( SIGNAL            q : OUT std_ulogic;               
                           SIGNAL   a, b, c, d :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_d_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalOR4   ( SIGNAL            q : OUT std_ulogic;              
                           SIGNAL   a, b, c, d :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_d_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalXOR4  ( SIGNAL            q : OUT std_ulogic;           
                           SIGNAL   a, b, c, d :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_d_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalNAND4 ( SIGNAL            q : OUT std_ulogic;             
                           SIGNAL   a, b, c, d :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_d_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalNOR4  ( SIGNAL            q : OUT std_ulogic;          
                           SIGNAL   a, b, c, d :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_d_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalXNOR4 ( SIGNAL            q : OUT std_ulogic;            
                           SIGNAL   a, b, c, d :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_d_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );

    -- ----------------------------------------------------------------------------
    -- Buffers
    -- 		BUF    ......... standard non-inverting buffer
    -- 		BUFIF0 ......... non-inverting buffer Data passes thru if (Enable = '0')
    -- 		BUFIF1 ......... non-inverting buffer Data passes thru if (Enable = '1')
    -- 		IDENT  ......... identity delay buffer (propagates Z)
    -- ----------------------------------------------------------------------------
    FUNCTION VitalBUF    ( CONSTANT         data :  IN std_ulogic;
                           CONSTANT    ResultMap :  IN ResultMapType:= DefaultResultMap
                         ) RETURN std_ulogic;            
    FUNCTION VitalBUFIF0 ( CONSTANT data, enable :  IN std_ulogic;
                           CONSTANT    ResultMap :  IN ResultZMapType:= DefaultResultZMap
                         ) RETURN std_ulogic;    
    FUNCTION VitalBUFIF1 ( CONSTANT data, enable :  IN std_ulogic;
                           CONSTANT    ResultMap :  IN ResultZMapType:= DefaultResultZMap
                         ) RETURN std_ulogic;    
    FUNCTION VitalIDENT  ( CONSTANT         data :  IN std_ulogic;
                           CONSTANT    ResultMap :  IN ResultZMapType:= DefaultResultZMap
                         ) RETURN std_ulogic;            

    PROCEDURE VitalBUF   ( SIGNAL            q : OUT std_ulogic;       
                           SIGNAL            a :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
 
    PROCEDURE VitalBUFIF0 ( SIGNAL              q : OUT std_ulogic; 
                            SIGNAL           data :  IN std_ulogic;
                            SIGNAL         enable :  IN std_ulogic;
                            CONSTANT   tpd_data_q :  IN DelayType01    := DefDelay01;
                            CONSTANT tpd_enable_q :  IN DelayType01Z   := DefDelay01Z;
                            CONSTANT    ResultMap :  IN ResultZMapType := DefaultResultZMap);
 
    PROCEDURE VitalBUFIF1 ( SIGNAL              q : OUT std_ulogic; 
                            SIGNAL           data :  IN std_ulogic;
                            SIGNAL         enable :  IN std_ulogic;
                            CONSTANT   tpd_data_q :  IN DelayType01    := DefDelay01;
                            CONSTANT tpd_enable_q :  IN DelayType01Z   := DefDelay01Z;
                            CONSTANT    ResultMap :  IN ResultZMapType := DefaultResultZMap);

    PROCEDURE VitalIDENT ( SIGNAL            q : OUT std_ulogic;       
                           SIGNAL            a :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01Z   := DefDelay01Z;
                           CONSTANT  ResultMap :  IN ResultZMapType := DefaultResultZMap );

    -- ----------------------------------------------------------------------------
    -- Invertors
    -- 		INV    ......... standard inverting buffer
    -- 		INVIF0 ......... inverting buffer Data passes thru if (Enable = '0')
    -- 		INVIF1 ......... inverting buffer Data passes thru if (Enable = '1')
    -- ----------------------------------------------------------------------------
    FUNCTION VitalINV    ( CONSTANT         data :  IN std_ulogic;
                           CONSTANT    ResultMap :  IN ResultMapType:= DefaultResultMap
                         ) RETURN std_ulogic;            
    FUNCTION VitalINVIF0 ( CONSTANT data, enable :  IN std_ulogic;
                           CONSTANT    ResultMap :  IN ResultZMapType:= DefaultResultZMap
                         ) RETURN std_ulogic;    
    FUNCTION VitalINVIF1 ( CONSTANT data, enable :  IN std_ulogic;
                           CONSTANT    ResultMap :  IN ResultZMapType:= DefaultResultZMap
                         ) RETURN std_ulogic;    

    PROCEDURE VitalINV   ( SIGNAL            q : OUT std_ulogic;     
                           SIGNAL            a :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
 
    PROCEDURE VitalINVIF0 ( SIGNAL              q : OUT std_ulogic;
                            SIGNAL           data :  IN std_ulogic;
                            SIGNAL         enable :  IN std_ulogic;
                            CONSTANT   tpd_data_q :  IN DelayType01    := DefDelay01;
                            CONSTANT tpd_enable_q :  IN DelayType01Z   := DefDelay01Z;
                            CONSTANT    ResultMap :  IN ResultZMapType := DefaultResultZMap);
 
    PROCEDURE VitalINVIF1 ( SIGNAL              q : OUT std_ulogic;
                            SIGNAL           data :  IN std_ulogic;
                            SIGNAL         enable :  IN std_ulogic;
                            CONSTANT   tpd_data_q :  IN DelayType01    := DefDelay01;
                            CONSTANT tpd_enable_q :  IN DelayType01Z   := DefDelay01Z;
                            CONSTANT    ResultMap :  IN ResultZMapType := DefaultResultZMap);

    -- ----------------------------------------------------------------------------
    -- Multiplexor
    --          MUX   .......... result := data(dselect) 
    --          MUX2  .......... 2-input mux; result := data0 when (dselect = '0'), 
    --                                                  data1 when (dselect = '1'),
    --                                                  'X' when (dselect = 'X') and (data0 /= data1)
    --          MUX4  .......... 4-input mux; result := data(dselect)
    --          MUX8  .......... 8-input mux; result := data(dselect)
    -- ----------------------------------------------------------------------------
    FUNCTION VitalMUX   ( CONSTANT       data :  IN std_logic_vector;
                          CONSTANT    dselect :  IN std_logic_vector;
                          CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                        ) RETURN std_ulogic;                                            
    FUNCTION VitalMUX2  ( CONSTANT data1, data0 :  IN std_ulogic;
                          CONSTANT      dselect :  IN std_ulogic;
                          CONSTANT    ResultMap :  IN ResultMapType := DefaultResultMap
                        ) RETURN std_ulogic;                                            
    FUNCTION VitalMUX4  ( CONSTANT       data :  IN std_logic_vector4;
                          CONSTANT    dselect :  IN std_logic_vector2;
                          CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                        ) RETURN std_ulogic;                                            
    FUNCTION VitalMUX8  ( CONSTANT       data :  IN std_logic_vector8;
                          CONSTANT    dselect :  IN std_logic_vector3;
                          CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                        ) RETURN std_ulogic;                                            
 
    PROCEDURE VitalMUX   ( SIGNAL            q : OUT std_ulogic;            
                           SIGNAL         data :  IN std_logic_vector;
                           SIGNAL         dsel :  IN std_logic_vector;
                           CONSTANT tpd_data_q :  IN DelayArrayType01;
                           CONSTANT tpd_dsel_q :  IN DelayArrayType01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalMUX2  ( SIGNAL            q : OUT std_ulogic;           
                           SIGNAL       d1, d0 :  IN std_ulogic;
                           SIGNAL         dsel :  IN std_ulogic;
                           CONSTANT   tpd_d1_q :  IN DelayType01    := DefDelay01;
                           CONSTANT   tpd_d0_q :  IN DelayType01    := DefDelay01;
                           CONSTANT tpd_dsel_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalMUX4  ( SIGNAL            q : OUT std_ulogic;          
                           SIGNAL         data :  IN std_logic_vector4;
                           SIGNAL         dsel :  IN std_logic_vector2;
                           CONSTANT tpd_data_q :  IN DelayArrayType01;
                           CONSTANT tpd_dsel_q :  IN DelayArrayType01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalMUX8  ( SIGNAL            q : OUT std_ulogic;         
                           SIGNAL         data :  IN std_logic_vector8;
                           SIGNAL         dsel :  IN std_logic_vector3;
                           CONSTANT tpd_data_q :  IN DelayArrayType01;
                           CONSTANT tpd_dsel_q :  IN DelayArrayType01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap );

    -- ----------------------------------------------------------------------------
    -- Decoder
    --          General Algorithm : 
    --              (a) Result(...) := '0' when (enable = '0') 
    --              (b) Result(data) := '1'; all other subelements = '0'
    --              ... Result array is decending (n-1 downto 0)
    --
    --          DECODERn  .......... n:2**n decoder
    -- ----------------------------------------------------------------------------
    FUNCTION VitalDECODER   ( CONSTANT       data :  IN std_logic_vector;
                              CONSTANT     enable :  IN std_ulogic;
                              CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                            ) RETURN std_logic_vector;
    FUNCTION VitalDECODER2  ( CONSTANT       data :  IN std_ulogic;
                              CONSTANT     enable :  IN std_ulogic;
                              CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                            ) RETURN std_logic_vector2;
    FUNCTION VitalDECODER4  ( CONSTANT       data :  IN std_logic_vector2;
                              CONSTANT     enable :  IN std_ulogic;
                              CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                            ) RETURN std_logic_vector4;
    FUNCTION VitalDECODER8  ( CONSTANT       data :  IN std_logic_vector3;
                              CONSTANT     enable :  IN std_ulogic;
                              CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                            ) RETURN std_logic_vector8;
 
    PROCEDURE VitalDECODER   ( SIGNAL              q : OUT std_logic_vector;
                               SIGNAL           data :  IN std_logic_vector;
                               SIGNAL         enable :  IN std_ulogic;
                               CONSTANT   tpd_data_q :  IN DelayArrayType01;
                               CONSTANT tpd_enable_q :  IN DelayType01    := DefDelay01;
                               CONSTANT    ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalDECODER2  ( SIGNAL              q : OUT std_logic_vector2;
                               SIGNAL           data :  IN std_ulogic;
                               SIGNAL         enable :  IN std_ulogic;
                               CONSTANT   tpd_data_q :  IN DelayType01    := DefDelay01;
                               CONSTANT tpd_enable_q :  IN DelayType01    := DefDelay01;
                               CONSTANT    ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalDECODER4  ( SIGNAL              q : OUT std_logic_vector4;
                               SIGNAL           data :  IN std_logic_vector2;
                               SIGNAL         enable :  IN std_ulogic;
                               CONSTANT   tpd_data_q :  IN DelayArrayType01;
                               CONSTANT tpd_enable_q :  IN DelayType01    := DefDelay01;
                               CONSTANT    ResultMap :  IN ResultMapType  := DefaultResultMap );
    PROCEDURE VitalDECODER8  ( SIGNAL              q : OUT std_logic_vector8;
                               SIGNAL           data :  IN std_logic_vector3;
                               SIGNAL         enable :  IN std_ulogic;
                               CONSTANT   tpd_data_q :  IN DelayArrayType01;
                               CONSTANT tpd_enable_q :  IN DelayType01    := DefDelay01;
                               CONSTANT    ResultMap :  IN ResultMapType  := DefaultResultMap );


    FUNCTION VitalTruthTable  ( CONSTANT TruthTable   : IN VitalTruthTableType;
                                CONSTANT DataIn       : IN std_logic_vector
                              ) RETURN std_logic_vector;

    FUNCTION VitalTruthTable  ( CONSTANT TruthTable   : IN VitalTruthTableType;
                                CONSTANT DataIn       : IN std_logic_vector
                              ) RETURN std_logic;

    PROCEDURE VitalTruthTable ( CONSTANT TruthTable   : IN VitalTruthTableType;
                                CONSTANT DataIn       : IN std_logic_vector;
                                SIGNAL   Result       : OUT std_logic_vector
                              );
                              
    PROCEDURE VitalTruthTable ( CONSTANT TruthTable   : IN VitalTruthTableType;
                                CONSTANT DataIn       : IN std_logic_vector;
                                SIGNAL   Result       : OUT std_logic
                              );
 
   PROCEDURE VitalStateTable ( CONSTANT StateTable     : IN VitalStateTableType; -- User's StateTable data
                               CONSTANT DataIn         : IN  std_logic_vector;   -- Inputs
                               CONSTANT NumStates      : IN Natural;             -- number of states
                               VARIABLE Result         : INOUT std_logic_vector; -- Outputs
                               VARIABLE PreviousDataIn : INOUT std_logic_vector
                             );
                              
   PROCEDURE VitalStateTable ( CONSTANT StateTable     : IN VitalStateTableType; -- User's StateTable data
                               CONSTANT DataIn         : IN  std_logic_vector;   -- Inputs
                               VARIABLE Result         : INOUT std_logic;        -- Outputs
                               VARIABLE PreviousDataIn : INOUT std_logic_vector
                             );
                              
   PROCEDURE VitalStateTable ( CONSTANT StateTable : IN VitalStateTableType; -- User's StateTable data
                               SIGNAL   DataIn     : IN std_logic_vector;    -- Inputs
                               CONSTANT NumStates  : IN Natural;             -- number of states
                               SIGNAL   Result     : INOUT std_logic_vector  -- Outputs
                               );

   PROCEDURE VitalStateTable ( CONSTANT StateTable : IN VitalStateTableType; -- User's StateTable data
                               SIGNAL   DataIn     : IN std_logic_vector;    -- Inputs
                               SIGNAL   Result     : INOUT std_logic         -- Outputs
                             );
END VITAL_PRIMITIVES;
