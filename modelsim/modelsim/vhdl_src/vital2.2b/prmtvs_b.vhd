--------------------------------------------------------------------------
--                                         Copyright 1993, 1994
--                                         VHDL Initiative Toward ASIC Libraries (VITAL)
--                                         All rights reserved.
--
-- File name   :  prmtvs_b.vhd
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
-- Limitations : none
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
--                                      initialize delay schedules
--     v0.302   |   rjr  |  10/30/93  | See package header
--     v0.400   |   rjr  |  01/21/94  | Updates for 2.1e specification
--                                      move Delay selection utils to Body
--                                      merge State and Table primitives
--     v0.401   |   rjr  |  01/26/94  | Add "Vital" to front of some names
--     v0.402   |   wrm  |  02/18/94  | Remove level sensitive dominance from
--                                      VitalStateTable.
--     v0.403   |   wdb  |  03/13/94  | GlitchMode changed to GlitchDetect
--              |        |            | to avoid confusion with the timing pkg.
--     v0.404   |    sn  |  05/23/94  | Bug fixes for
--                                      - N-bit primitives
--                                      - Wrong range used for subtype decl
--                                        in VitalIdent and GetSchedDelay
--                                      - Constraint error in VinterMux
--                                      - VitalNAND4, VitalNOR4: 
--                                        changing BufPath to InvPath
-- ----------------------------------------------------------------------------

PACKAGE BODY VITAL_PRIMITIVES is
    -- ------------------------------------------------------------------------
    --  Default values for Primitives
    -- ------------------------------------------------------------------------
    --  default values for delay parameters
    CONSTANT DefDelay01  : DelayType01  := ZeroDelay01; -- Propagation delays
    CONSTANT DefDelay01Z : DelayType01Z := ZeroDelay01Z;
    CONSTANT DefDelayIO  : DelayTypeIO  := ZeroDelayIO;

    --  default primitive model operation parameters
    CONSTANT GlitchDetect   : GlitchDetectType := OnEvent; -- select glitch detection
    CONSTANT PrimGlitchMode : GlitchModeType   := XOnly;   -- Glitch detection/reporting

    -- ------------------------------------------------------------------------
    -- Local Type and Subtype Declarations
    -- ------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    -- enumeration value representing the transition or level of the signal.
    --  See function 'GetEdge'
    ---------------------------------------------------------------------------
    TYPE EdgeType IS ( 'U',   -- Uninitialized level
                       'X',   -- Unknown level
                       '0',   -- low level
                       '1',   -- high level
                       '\',   -- 1 to 0 falling edge
                       '/',   -- 0 to 1 rising  edge
                       'F',   -- * to 0 falling edge
                       'R',   -- * to 1 rising  edge
                       'f',   -- rising  to X edge
                       'r',   -- falling to X edge
                       'x',   -- Unknown edge (ie U->X)
                       'V'    -- Timing violation edge
                     );
    TYPE EdgeArray  IS ARRAY ( NATURAL RANGE <> ) OF EdgeType;
 
    TYPE EdgeX1Table  IS ARRAY ( EdgeType                                ) OF EdgeType;
    TYPE EdgeX2Table  IS ARRAY ( EdgeType, EdgeType                      ) OF EdgeType;
    TYPE EdgeX3Table  IS ARRAY ( EdgeType, EdgeType, EdgeType            ) OF EdgeType;
    TYPE EdgeX4Table  IS ARRAY ( EdgeType, EdgeType, EdgeType, EdgeType  ) OF EdgeType;
 
    TYPE LogicToEdgeT  IS ARRAY(std_ulogic, std_ulogic) OF EdgeType;
    TYPE LogicToLevelT IS ARRAY(std_ulogic ) OF EdgeType;
    TYPE EdgeToLogicT  IS ARRAY(EdgeType   ) OF UX01;

    -- Enumerated type used in selection of output path delays
    TYPE SchedType  IS
      RECORD
        inp0  : TIME;       -- time (abs) of output change due to input change to 0
        inp1  : TIME;       -- time (abs) of output change due to input change to 1
        inpX  : TIME;       -- time (abs) of output change due to input change to X
        glch0 : TIME;       -- time (abs) of output glitch due to input change to 0
        glch1 : TIME;       -- time (abs) of output glitch due to input change to 0
      END RECORD;

    TYPE SchedArray  IS ARRAY ( NATURAL RANGE <> ) OF SchedType;
    CONSTANT DefSchedType : SchedType := (TIME'HIGH, TIME'HIGH, 0 ns, 0 ns, 0 ns);

    -- Constrained array declarations (common sizes used by primitives)
    SUBTYPE SchedArray2 IS SchedArray(1 DOWNTO 0);
    SUBTYPE SchedArray3 IS SchedArray(2 DOWNTO 0);
    SUBTYPE SchedArray4 IS SchedArray(3 DOWNTO 0);
    SUBTYPE SchedArray8 IS SchedArray(7 DOWNTO 0);

    SUBTYPE TimeArray2 IS TimeArray(1 DOWNTO 0);
    SUBTYPE TimeArray3 IS TimeArray(2 DOWNTO 0);
    SUBTYPE TimeArray4 IS TimeArray(3 DOWNTO 0);
    SUBTYPE TimeArray8 IS TimeArray(7 DOWNTO 0);

    SUBTYPE GlitchArray2 IS GlitchDataArrayType(1 DOWNTO 0);
    SUBTYPE GlitchArray3 IS GlitchDataArrayType(2 DOWNTO 0);
    SUBTYPE GlitchArray4 IS GlitchDataArrayType(3 DOWNTO 0);
    SUBTYPE GlitchArray8 IS GlitchDataArrayType(7 DOWNTO 0);

    SUBTYPE EdgeArray2 IS EdgeArray(1 DOWNTO 0);
    SUBTYPE EdgeArray3 IS EdgeArray(2 DOWNTO 0);
    SUBTYPE EdgeArray4 IS EdgeArray(3 DOWNTO 0);
    SUBTYPE EdgeArray8 IS EdgeArray(7 DOWNTO 0);

    TYPE stdlogic_table IS ARRAY(std_ulogic, std_ulogic) OF std_ulogic;

    CONSTANT InitialEdge : LogicToLevelT := (
            '1'|'H' => 'R',
            '0'|'L' => 'F',
            OTHERS  => 'x'
     );

    CONSTANT LogicToEdge  : LogicToEdgeT  := (  -- previous, current
    --  old \ new: U    X    0    1    Z    W    L    H    -
        'U' =>  ( 'U', 'x', 'F', 'R', 'x', 'x', 'F', 'R', 'x' ),
        'X' =>  ( 'x', 'X', 'F', 'R', 'x', 'X', 'F', 'R', 'X' ),
        '0' =>  ( 'r', 'r', '0', '/', 'r', 'r', '0', '/', 'r' ),
        '1' =>  ( 'f', 'f', '\', '1', 'f', 'f', '\', '1', 'f' ),
        'Z' =>  ( 'x', 'X', 'F', 'R', 'X', 'x', 'F', 'R', 'x' ),
        'W' =>  ( 'x', 'X', 'F', 'R', 'x', 'X', 'F', 'R', 'X' ),
        'L' =>  ( 'r', 'r', '0', '/', 'r', 'r', '0', '/', 'r' ),
        'H' =>  ( 'f', 'f', '\', '1', 'f', 'f', '\', '1', 'f' ),
        '-' =>  ( 'x', 'X', 'F', 'R', 'x', 'X', 'F', 'R', 'X' )
    );
    CONSTANT LogicToLevel : LogicToLevelT := (
            '1'|'H' => '1',
            '0'|'L' => '0',
            'U'     => 'U',
            OTHERS  => 'X'
     );
    CONSTANT EdgeToLogic : EdgeToLogicT := ( 
            '1'|'R'|'/' => '1',
            '0'|'F'|'\' => '0',
            'U'         => 'U',
            OTHERS      => 'X'
     );

    -- -----------------------------------
    -- 3-state logic tables
    -- -----------------------------------
    CONSTANT bufif0_table : stdlogic_table :=
        -- enable        data       value
        ( '1'|'H'   => ( OTHERS  => 'Z' ),
          '0'|'L'   => ( '1'|'H' => '1',
                         '0'|'L' => '0',
                         'U'     => 'U',
                         OTHERS  => 'X' ),
          'U'       => ( OTHERS  => 'U' ),
          OTHERS    => ( OTHERS  => 'X' ) );    -- {R&R}
    CONSTANT bufif1_table : stdlogic_table :=
        -- enable        data       value
        ( '0'|'L'   => ( OTHERS  => 'Z' ),
          '1'|'H'   => ( '1'|'H' => '1',
                         '0'|'L' => '0',
                         'U'     => 'U',
                         OTHERS  => 'X' ),
          'U'       => ( OTHERS  => 'U' ),
          OTHERS    => ( OTHERS  => 'X' ) );    -- {R&R}
    CONSTANT invif0_table : stdlogic_table :=
        -- enable        data       value
        ( '1'|'H'   => ( OTHERS  => 'Z' ),
          '0'|'L'   => ( '1'|'H' => '0',
                         '0'|'L' => '1',
                         'U'     => 'U',
                         OTHERS  => 'X' ),
          'U'       => ( OTHERS  => 'U' ),
          OTHERS    => ( OTHERS  => 'X' ) );    -- {R&R}
    CONSTANT invif1_table : stdlogic_table :=
        -- enable        data       value
        ( '0'|'L'   => ( OTHERS  => 'Z' ),
          '1'|'H'   => ( '1'|'H' => '0',
                         '0'|'L' => '1',
                         'U'     => 'U',
                         OTHERS  => 'X' ),
          'U'       => ( OTHERS  => 'U' ),
          OTHERS    => ( OTHERS  => 'X' ) );    -- {R&R}

    
    TYPE To_CharacterType IS ARRAY (VitalTableSymbolType) OF Character;
    CONSTANT To_Character : To_CharacterType :=
     ( '/', '\', 'P', 'N', 'r', 'f', 'x', 'U', 'X', '0', '1', '-', 'B',
       'Z', 'p', 'n', 'R', 'F', '^', 'v', 'E', 'A', 'D', '*', 'S' );
    
    TYPE TruthTableOutMapType IS ARRAY (VitalTruthTableSymbol) OF std_ulogic;
    CONSTANT TruthTableOutMap : TruthTableOutMapType :=
       --  'X', '0', '1', '-', 'B', 'Z'
         ( 'X', '0', '1', 'X', '-', 'Z' );
    
    TYPE TableOutMapType IS ARRAY (VitalTableSymbolType) OF std_ulogic;
    -- does conversion to X01Z or '-' if invalid
    CONSTANT StateTableOutMap : TableOutMapType :=
     -- '/' '\' 'P' 'N' 'r' 'f' 'x' 'U' 'X' '0' '1' '-' 'B' 'Z' 'p' 'n' 'R' 'F' '^' 'v' 'E' 'A' 'D' '*' 'S'
      ( '-','-','-','-','-','-','-','-','X','0','1','X','-','Z','-','-','-','-','-','-','-','-','-','-','W');

    -- -------------------------------------------------------------------------------------
    TYPE ValidTruthTableInputType IS ARRAY (VitalTruthTableSymbol) OF BOOLEAN;
    -- checks if a symbol IS valid for the stimulus portion of a truth table
    CONSTANT ValidTruthTableInput : ValidTruthTableInputType :=
       -- 'X'    '0'    '1'    '-'    'B'    'Z'
       (  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE );

    TYPE TruthTableMatchType IS ARRAY (X01, VitalTruthTableSymbol) OF BOOLEAN;
    -- checks if an input matches th corresponding truth table symbol
    -- use:  TruthTableMatch(input_converted_to_X01, truth_table_stimulus_symbol)
    CONSTANT TruthTableMatch : TruthTableMatchType  :=  (
       -- X,     0,     1,     -      B      Z
       (  TRUE,  FALSE, FALSE, TRUE,  FALSE, FALSE  ),  -- X
       (  FALSE, TRUE,  FALSE, TRUE,  TRUE,  FALSE  ),  -- 0
       (  FALSE, FALSE, TRUE,  TRUE,  TRUE,  FALSE  )   -- 1
    );

    -- -------------------------------------------------------------------------------------
    TYPE ValidStateTableInputType IS ARRAY (VitalTableSymbolType) OF BOOLEAN;
    CONSTANT ValidStateTableInput : ValidStateTableInputType :=
       -- '/',   '\',   'P',   'N',   'r',   'f',   'x',   'U',   'X',   '0',   '1',   '-',   'B',
      (   TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, TRUE,  TRUE,  TRUE,  TRUE,  TRUE,
       -- 'Z',   'p',   'n',   'R',   'F',   '^',   'v',   'E',   'A',    'D',  '*',  'S' 
          FALSE, TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE, TRUE );

    CONSTANT ValidStateTableState : ValidStateTableInputType :=
       -- '/',   '\',   'P',   'N',   'r',   'f',   'x',   'U',   'X',   '0',   '1',   '-',   'B',
      (   FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE,  TRUE,  TRUE,  TRUE,  TRUE, 
       -- 'Z',   'p',   'n',   'R',   'F',   '^',   'v',   'E',   'A',    'D',  '*',   'S' 
          FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE );

--    CONSTANT IsEdge : ValidStateTableInputType :=
--       -- '/',   '\',   'P',   'N',   'r',   'f',   'x',   'U',   'X',   '0',   '1',   '-',   'B',
--      (   TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
--       -- 'Z',   'p',   'n',   'R',   'F',   '^',   'v',   'E',   'A',    'D',  '*',   'S' 
--          FALSE, TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE );

          
    TYPE StateTableMatchType IS ARRAY (X01, X01, VitalTableSymbolType) OF BOOLEAN;
    -- last value, present value, table symbol
    CONSTANT StateTableMatch : StateTableMatchType :=  (
      ( -- X (lastvalue)
     --/     \     P     N     r     f     x     U     X     0     1     -     B     Z     p     n     R     F     ^     v     E     A     D     *     S
      (FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE, FALSE,FALSE,TRUE, FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE),
      (FALSE,FALSE,FALSE,TRUE, FALSE,FALSE,FALSE,FALSE,FALSE,TRUE, FALSE,TRUE, TRUE, FALSE,FALSE,FALSE,FALSE,TRUE, FALSE,TRUE, TRUE, FALSE,TRUE, TRUE, FALSE),
      (FALSE,FALSE,TRUE, FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE, TRUE, TRUE, FALSE,FALSE,FALSE,TRUE, FALSE,TRUE, FALSE,TRUE, TRUE, FALSE,TRUE, FALSE)
      ),

      (-- 0 (lastvalue)
     --/     \     P     N     r     f     x     U     X     0     1     -     B     Z     p     n     R     F     ^     v     E     A     D     *     S      
      (FALSE,FALSE,FALSE,FALSE,TRUE, FALSE,FALSE,FALSE,TRUE, FALSE,FALSE,TRUE, FALSE,FALSE,TRUE, FALSE,TRUE, FALSE,FALSE,FALSE,FALSE,TRUE, FALSE,TRUE, FALSE),
      (FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE, FALSE,TRUE, TRUE, FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE ),
      (TRUE, FALSE,TRUE, FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE, TRUE, TRUE, FALSE,TRUE, FALSE,TRUE, FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE, FALSE)
      ),

      (-- 1 (lastvalue)
     --/     \     P     N     r     f     x     U     X     0     1     -     B     Z     p     n     R     F     ^     v     E     A     D     *     S
      (FALSE,FALSE,FALSE,FALSE,FALSE,TRUE, FALSE,FALSE,TRUE, FALSE,FALSE,TRUE, FALSE,FALSE,FALSE,TRUE, FALSE,TRUE, FALSE,FALSE,FALSE,FALSE,TRUE, TRUE, FALSE),
      (FALSE,TRUE, FALSE,TRUE, FALSE,FALSE,FALSE,FALSE,FALSE,TRUE, FALSE,TRUE, TRUE, FALSE,FALSE,TRUE, FALSE,TRUE, FALSE,FALSE,FALSE,FALSE,FALSE,TRUE, FALSE),
      (FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE, TRUE, TRUE, FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE )
      )
      );

    --------------------------------------------------------------------
    -- LOCAL Utilities
    --------------------------------------------------------------------
    -- -------------------------------------------------------------------------------------
    --  FUNCTION  NAME  :  MINIMUM
    --
    --  PARAMETERS      :  in1, in2  - integer, time
    --
    --  DESCRIPTION     :  return smaller of in1 and in2
    -- -------------------------------------------------------------------------------------
    FUNCTION MINIMUM ( CONSTANT in1, in2 : INTEGER ) RETURN INTEGER is
    BEGIN
       IF (in1 < in2) THEN
          RETURN in1;
       END IF;
       RETURN in2;
    END;
    -----------------------------------------------------------------------
        FUNCTION MINIMUM ( CONSTANT t1,t2 : IN TIME ) RETURN TIME IS
        BEGIN
            IF ( t1 < t2 ) THEN RETURN (t1); ELSE RETURN (t2); END IF;
        END MINIMUM;
    
    -- -------------------------------------------------------------------------------------
    --  FUNCTION  NAME  :  MAXIMUM
    --
    --  PARAMETERS      :  in1, in2  - integer, time
    --
    --  DESCRIPTION     :  return larger of in1 and in2
    -- -------------------------------------------------------------------------------------
    FUNCTION MAXIMUM ( CONSTANT in1, in2 : INTEGER ) RETURN INTEGER is
    BEGIN
       IF (in1 > in2) THEN
          RETURN in1;
       END IF;
       RETURN in2;
    END;
    -----------------------------------------------------------------------
        FUNCTION MAXIMUM ( CONSTANT t1,t2 : IN TIME ) RETURN TIME IS
        BEGIN
            IF ( t1 > t2 ) THEN RETURN (t1); ELSE RETURN (t2); END IF;
        END MAXIMUM;
        
    -----------------------------------------------------------------------
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
    -- -------------------------------------------------------------------------------------
    --  PROCEDURE NAME  :  TruthOutputX01Z
    --
    --  PARAMETERS      :  table_out - output of table
    --                     X01Zout   - output converted to X01Z
    --                     err       - true if illegal character is encountered
    --
    --
    --  DESCRIPTION     :  converts the output of a truth table to a valid std_ulogic
    -- -------------------------------------------------------------------------------------
    PROCEDURE TruthOutputX01Z ( CONSTANT table_out : IN VitalTruthTableSymbol;
                                VARIABLE X01Zout   : OUT std_ulogic;
                                VARIABLE err       : OUT BOOLEAN
                              ) is
       VARIABLE temp_out : std_ulogic;
    BEGIN
        err := FALSE;
        temp_out := TruthTableOutMap(table_out);
        IF (temp_out = '-') THEN
           err := TRUE;
           temp_out := 'X';
           ASSERT FALSE
              REPORT "VitalTruthTable:  " & To_Character(table_out) & " is an illegal symbol for the output portion of a Truth Table."
              SEVERITY FAILURE;
        END IF;
        X01Zout := temp_out;
    END;

    -- -------------------------------------------------------------------------------------
    --  PROCEDURE NAME  :  StateOutputX01Z
    --
    --  PARAMETERS      :  table_out - output of table
    --                     prev_out  - previous output value
    --                     X01Zout   - output cojnverted to X01Z
    --                     err       - true if illegal character is encountered
    --
    --  DESCRIPTION     :  converts the output of a state table to a valid std_ulogic
    -- -------------------------------------------------------------------------------------
    PROCEDURE StateOutputX01Z ( CONSTANT table_out : IN VitalTableSymbolType;
                                CONSTANT prev_out  : IN std_ulogic;
                                VARIABLE X01Zout   : OUT std_ulogic;
                                VARIABLE err       : OUT BOOLEAN
                              ) IS
       VARIABLE temp_out : std_ulogic;
    BEGIN
       err := FALSE;
       temp_out := StateTableOutMap(table_out);
       IF (temp_out = '-') THEN
          err := TRUE;
          temp_out := 'X';
          ASSERT FALSE
             REPORT "VitalStateTable:  " & To_Character(table_out) & " is an illegal symbol for the output portion of a State Table."
             SEVERITY FAILURE;
       ELSIF (temp_out = 'W') THEN
          temp_out := To_X01Z(prev_out);
       END IF;
       X01Zout := temp_out;
    END;

    -- -------------------------------------------------------------------------------------
    -- PROCEDURE NAME:  StateMatch
    --
    -- PARAMETERS    :  symbol       - symbol from state table
    --                  in2          - input from VitalStateTble procedure to state table
    --                  in2LastValue - previous value of input
    --                  state        - false if the symbol is from the input portion of the table,
    --                                 true if the symbol is form the state portion of the table
    --                  Err          - true if symbol is not a valid input symbol
    --                  ReturnValue  - true if match occurred
    --
    -- DESCRIPTION   :  This procedure sets ReturnValue to true if in2 matches symbol (from
    --                  the state table).  If symbol is an edge value edge is set to true
    --                  and in2 and in2LastValue are checked against symbol.  Err is set to
    --                  true if symbol is an invalid value for the input portion of the state
    --                  table.
    --
    -- -------------------------------------------------------------------------------------
    PROCEDURE StateMatch (symbol       : IN VitalTableSymbolType;
                          in2          : IN std_ulogic;
                          in2LastValue : IN std_ulogic;
                          state        : IN BOOLEAN;
                          Err          : OUT BOOLEAN;
                          ReturnValue  : OUT BOOLEAN
                         ) is
    BEGIN
       IF (state) THEN
          IF (not ValidStateTableState(symbol)) THEN
             ASSERT FALSE
                REPORT "VitalStateTable:  " & To_Character(symbol) & " is an illegal symbol for the state portion of a state table."
                SEVERITY FAILURE;
             Err := TRUE;
             ReturnValue := FALSE;
          ELSE
             Err := FALSE;
             ReturnValue := StateTableMatch(in2LastValue, in2, symbol);
          END IF;
       ELSE
          IF (not ValidStateTableInput(symbol) ) THEN
             ASSERT FALSE
                REPORT "VitalStateTable:  " & To_Character(symbol) & " is an illegal symbol for the input portion of a state table."
                SEVERITY FAILURE;
             Err := TRUE;
             ReturnValue := FALSE;
          ELSE
             ReturnValue := StateTableMatch(in2LastValue, in2, symbol);
             Err := FALSE;
          END IF;
       END IF;
    END;
    
    -- -------------------------------------------------------------------------------------
    -- FUNCTION NAME:  StateTableLookUp
    --
    -- PARAMETERS   :  StateTable     - state table
    --                 PresentDataIn  - current inputs
    --                 PreviousDataIn - previous inputs and states
    --                 NumStates      - number of state variables
    --                 PresentOutputs - current state and current outputs
    --
    -- DESCRIPTION  :  This function is used to find the output of the StateTable
    --                 corresponding to a given set of inputs.
    --
    -- -------------------------------------------------------------------------------------
    FUNCTION StateTableLookUp ( StateTable     : VitalStateTableType;
                                PresentDataIn  : std_logic_vector;
                                PreviousDataIn : std_logic_vector;
                                NumStates      : Natural;
                                PresentOutputs : std_logic_vector
                              ) RETURN std_logic_vector is

        CONSTANT InputSize                   : INTEGER := PresentDataIn'LENGTH;
        CONSTANT StateTableEntries           : INTEGER := StateTable'LENGTH(1);
        CONSTANT StateTableWidth             : INTEGER := StateTable'LENGTH(2);
        CONSTANT OutputSize                  : INTEGER := StateTableWidth - InputSize - NumStates;
        VARIABLE Inputs                      : std_logic_vector(0 TO InputSize + NumStates - 1);
        VARIABLE PrevInputs                  : std_logic_vector(0 TO InputSize + NumStates - 1) := (OTHERS => 'X');
        VARIABLE returnValue                 : std_logic_vector(0 TO (OutputSize-1)) := (OTHERS => 'X');
        VARIABLE match_ind                   : INTEGER := StateTableEntries;
        -- This needs to be done since the TableLookup arrays must be ascending starting with 0
        VARIABLE StateTableAlias             : VitalStateTableType(0 TO StateTableEntries - 1, 0 TO StateTableWidth - 1) := StateTable;
        VARIABLE temp                        : std_ulogic;
        VARIABLE match                       : BOOLEAN;
        VARIABLE err                         : BOOLEAN := FALSE;

    BEGIN
       Inputs(0 TO InputSize-1) := PresentDataIn;
       Inputs(InputSize TO InputSize + NumStates - 1) := PresentOutputs(0 TO NumStates - 1);
       PrevInputs(0 TO InputSize - 1) := PreviousDataIn(0 TO Inputsize - 1);
       -- Compare each entry in the table
       col_loop: FOR i IN StateTableAlias'RANGE(1) LOOP
           -- Check each element of the entry
           row_loop: FOR j IN 0 TO InputSize + NumStates  LOOP
              IF (j = InputSize + NumStates) THEN        -- a match occurred
                 FOR k IN 0 TO Minimum(OutputSize, PresentOutputs'LENGTH) - 1 LOOP
                    StateOutputX01Z(StateTableAlias(i, StateTableWidth - k - 1), PresentOutputs(PresentOutputs'LENGTH - k - 1), temp, err);
                    returnValue(OutputSize - k - 1) := temp;
                    IF (err) THEN
                       returnValue := (OTHERS => 'X');
                       RETURN returnValue;
                    END IF;
                 END LOOP;
                 RETURN returnValue;
              END IF;
              StateMatch(StateTableAlias(i,j), Inputs(j), PrevInputs(j), j >= InputSize, err, match);
              EXIT row_loop WHEN not(match);
              EXIT col_loop WHEN err;
           END LOOP row_loop;
       END LOOP col_loop;
       returnValue := (OTHERS => 'X');
       RETURN returnValue;
    END;

    ----------------------------------------------------------
    -- table name : cvt_to_x01z
    --
    -- parameters :
    --        in  :  std_ulogic  -- some logic value
    -- returns    :  UX01Z       -- state value of logic value
    -- purpose    :  to convert state-strength to state only
    --                  
    ----------------------------------------------------------
    TYPE logic_ux01z_table IS ARRAY (std_ulogic'LOW TO std_ulogic'HIGH) OF UX01Z;
    CONSTANT cvt_to_ux01z : logic_ux01z_table := ('U','X','0','1','Z','X','0','1','X' );
    --------------------------------------------------------------------
    -- to_ux01z
    -------------------------------------------------------------------    
    FUNCTION To_UX01Z  ( s : std_ulogic ) RETURN  UX01Z IS
    BEGIN
        RETURN cvt_to_ux01z (s);
    END;

    ---------------------------------------------------------------------------
    -- Function  : GetEdge
    -- Purpose    : Converts transitions on a given input signal into a
    --              enumeration value representing the transition or level
    --              of the signal.
    -- 
    --             previous "value"     current "value"   :=   "edge"
    --             ---------------------------------------------------------
    --               '1' | 'H'          '1' | 'H'                 '1'    level, no edge
    --               '0' | 'L'          '1' | 'H'                 '/'    rising edge
    --                others            '1' | 'H'                 'R'    rising from X
    --
    --               '1' | 'H'          '0' | 'L'                 '\'    falling egde
    --               '0' | 'L'          '0' | 'L'                 '0'    level, no edge
    --                others            '0' | 'L'                 'F'    falling from X
    --
    --               'X' | 'W' | '-'    'X' | 'W' | '-'           'X'    unknown (X) level
    --               'Z'                'Z'                       'X'    unknown (X) level
    --               'U'                'U'                       'U'    'U' level
    --
    --               '1' | 'H'           others                   'f'    falling to X
    --               '0' | 'L'           others                   'r'    rising to X
    --               'X' | 'W' | '-'    'U' | 'Z'                 'x'    unknown (X) edge
    --               'Z'                'X' | 'W' | '-' | 'U'     'x'    unknown (X) edge
    --               'U'                'X' | 'W' | '-' | 'Z'     'x'    unknown (X) edge
    --
    ---------------------------------------------------------------------------
    FUNCTION GetEdge ( SIGNAL      s : IN    std_logic
                      ) RETURN EdgeType IS
    BEGIN
        IF (S'EVENT) 
            THEN RETURN LogicToEdge  ( s'LAST_VALUE, s );
            ELSE RETURN LogicToLevel ( s );
        END IF;
    END;    -- {R&R}
 
    ---------------------------------------------------------------------------
    FUNCTION GetEdge ( SIGNAL      s : IN  std_logic_vector;
                       CONSTANT edge : IN  EdgeArray
                      ) RETURN EdgeArray IS
        ALIAS    s_alias : std_logic_vector ( 1 TO    s'LENGTH ) IS s;
        ALIAS edge_alias : EdgeArray        ( 1 TO edge'LENGTH ) IS edge;
        VARIABLE result : EdgeArray ( 1 TO s'LENGTH );
    BEGIN
        IF s'LENGTH /= edge'LENGTH THEN
            ASSERT FALSE
             REPORT "ERROR from GetEdge: s, edge lengths not equal"
             SEVERITY ERROR;
            RETURN result;
        END IF;
 
        FOR n IN 1 TO s'LENGTH LOOP
            result(n) :=  LogicToEdge( EdgeToLogic(edge_alias(n)), s_alias(n) );
        END LOOP;
        RETURN result;
    END;    -- {R&R}

    ---------------------------------------------------------------------------
    FUNCTION  ToEdge     ( value         : IN std_logic    ) RETURN EdgeType IS
    BEGIN
        RETURN LogicToLevel( value );
    END;   -- {R&R}
 
    ---------------------------------------------------------------------------
    FUNCTION  To_UX01    ( value         : IN EdgeType     ) RETURN UX01 IS
    BEGIN
        RETURN EdgeToLogic( value );
    END;   -- {R&R}

    -- Note: This function will likely be replaced by S'DRIVING_VALUE in VHDL'92
    ---------------------------------------------------------------------------------------
    FUNCTION CurrentValue ( CONSTANT GlitchData : IN  GlitchDataType ) RETURN std_logic IS
    BEGIN
        IF NOW >= GlitchData.LastSchedTransaction THEN
          RETURN GlitchData.LastSchedValue;
        ELSIF NOW >= GlitchData.LastGlitchSchedTime THEN
          RETURN 'X';
        ELSE
          RETURN GlitchData.CurrentValue;
        END IF;
    END;
    ---------------------------------------------------------------------------------------
    FUNCTION CurrentValue ( CONSTANT GlitchData : IN  GlitchDataArrayType )
                             RETURN std_logic_vector IS
        VARIABLE result : std_logic_vector(GlitchData'RANGE);
    BEGIN
      FOR n IN GlitchData'RANGE LOOP
        IF NOW >= GlitchData(n).LastSchedTransaction THEN
          result(n) := GlitchData(n).LastSchedValue;
        ELSIF NOW >= GlitchData(n).LastGlitchSchedTime THEN
          result(n) := 'X';
        ELSE
          result(n) := GlitchData(n).CurrentValue;
        END IF;
      END LOOP;
      RETURN result;
    END;

    ---------------------------------------------------------------------------
    -- function calculation utilities
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Function   : VitalSame
    -- Returns    : VitalSame compares the state (UX01) of two logic value. A
    --              value of 'X' is returned if the values are different.  The
    --              common value is returned if the values are equal.
    -- Purpose    : When the result of a logic model may be either of two
    --              separate input values (eg. when the select on a MUX is 'X'),
    --              VitalSame may be used to determine if the result needs to
    --              be 'X'.
    -- Arguments  : See the declarations below...
    ---------------------------------------------------------------------------
    FUNCTION VitalSame ( CONSTANT a, b : IN std_ulogic ) RETURN std_ulogic IS
    BEGIN
        IF To_UX01(a) = To_UX01(b)
            THEN RETURN To_UX01(a);
            ELSE RETURN 'X';
        END IF;
    END;    -- {R&R}

    ---------------------------------------------------------------------------
    -- delay selection utilities
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Procedure  : BufPath, InvPath
    --
    -- Purpose    : BufPath and InvPath compute output change times, based on
    --              a change on an input port. The computed output change times
    --              returned in the composite parameter 'schd'.
    --
    --              BufPath and InpPath are used together with the delay path
    --              selection functions (GetSchedDelay, VitalAND, VitalOR... )
    --              The 'schd' value from each of the input ports of a model are
    --              combined by the delay selection functions (VitalAND, 
    --              VitalOR, ...). The GetSchedDelay procedure converts the
    --              combined output changes times to the single delay (delta
    --              time) value for scheduling the output change (passed to
    --              VitalGlitchOnEvent).
    --
    --              The values in 'schd' are: (absolute times)
    --                inp0  :  time of output change due to input change to 0
    --                inp1  :  time of output change due to input change to 1
    --                inpX  :  time of output change due to input change to X
    --                glch0 :  time of output glitch due to input change to 0
    --                glch1 :  time of output glitch due to input change to 1
    --
    --              The output times are computed from the model INPUT value
    --              and not the final value.  For this reason, 'BufPath' should
    --              be used to compute the output times for a non-inverting
    --              delay paths and 'InvPath' should be used to compute the
    --              ouput times for inverting delay paths. Delay paths which
    --              include both non-inverting and paths require usage of both
    --              'BufPath' and 'InvPath'. (IE this is needed for the
    --              select->output path of a MUX -- See the VitalMUX model).
    --
    --
    -- Parameters : schd....... Computed output result times. (INOUT parameter
    --                          modified only on input edges)
    --              Iedg....... Input port edge/level value.
    --               tpd....... Propagation delays from this input
    --
    -- Example : sample model with Function - "A AND (NOT B)"
    --
    --      ENTITY sample IS
    --          GENERIC ( tpd_A_Q, tpd_B_Q : DelayType01);
    --          PORT    ( A, B : IN  std_ulogic;
    --                    Q    : OUT std_ulogic );
    --      END;
    --      ARCHITECTURE behav OF sample IS
    --      : declarations
    --      BEGIN
    --      PROCESS (A,B)
    --        BEGIN
    --            -- A to Q is a non-inverting path
    --            -- B to Q is an inverting path
    --          BufPath ( schd_A_Q, GetEdge(A), tpd_A_Q );
    --          InvPath ( schd_B_Q, GetEdge(B), tpd_B_Q );
    --            -- compute logic function
    --          val_Q := A AND (NOT B);
    --            -- combine output times from A->Q, B->Q delay paths
    --          schd_Q := schd_A_Q AND (NOT schd_B_Q);
    --
    --            -- convert combined times to delay value
    --          GetSchedDelay ( dly, glch, val_Q, CurrentValue(gl_data_Q), schd_Q );
    --            -- assign to output signal
    --          VitalGlitchOnEvent ( Q, "Q", gl_data_Q, val_Q, dly, XOnly,
    --                               glch );
    --        END PROCESS;
    --      END;
    --
    --      Example Notes:
    --       >  The delay path selection functions used to combine the separate
    --          times from A and B are overloaded on the logic operators
    --          (AND, NOT ...).
    --       >  "GetEdge(s)" converts input signal values (std_ulogic) to
    --          edge/level values (type EdgeTYpe). See VITAL_Timing package.
    --       >  "CurrentValue(..)" returns the current value of Q, based on the
    --          scheduled transaction info in 'gl_data_Q'. The 'gl_data_Q'
    --          data is maintained by 'VitalGlitchOnEvent'. See VITAL_Timing package.
    --
    ---------------------------------------------------------------------------

    PROCEDURE BufPath ( VARIABLE schd : INOUT SchedType;
                        CONSTANT Iedg : IN    EdgeType;
                        CONSTANT  tpd : IN    DelayType01       ) IS
    BEGIN
      CASE Iedg IS
        WHEN '0'|'1' => NULL;                   -- no edge: no timing update
        WHEN '/'|'R' => schd.inp0 := TIME'HIGH;
                        schd.inp1 := NOW + tpd(tr01);  schd.glch1 := schd.inp1;  
                        schd.inpX := schd.inp1;
        WHEN '\'|'F' => schd.inp1 := TIME'HIGH;
                        schd.inp0 := NOW + tpd(tr10);  schd.glch0 := schd.inp0;  
                        schd.inpX := schd.inp0;
        WHEN 'r'     => schd.inp1 := TIME'HIGH;
                        schd.inp0 := TIME'HIGH;
                        schd.inpX := NOW + tpd(tr01);
        WHEN 'f'     => schd.inp0 := TIME'HIGH;
                        schd.inp1 := TIME'HIGH;
                        schd.inpX := NOW + tpd(tr10);
        WHEN 'x'     => schd.inp1 := TIME'HIGH;
                        schd.inp0 := TIME'HIGH;
                        schd.inpX := NOW + MINIMUM(tpd(tr10),tpd(tr01));  -- update for X->X change
        WHEN OTHERS  => NULL;                   -- no timing change
      END CASE;
    END;    -- {R&R}

    PROCEDURE BufPath ( VARIABLE schd : INOUT SchedArray;
                        CONSTANT Iedg : IN    EdgeArray;
                        CONSTANT  tpd : IN    DelayArrayType01       ) IS
    BEGIN
      FOR n IN schd'RANGE LOOP
        CASE Iedg(n) IS
          WHEN '0'|'1' => NULL;                   -- no edge: no timing update
          WHEN '/'|'R' => schd(n).inp0 := TIME'HIGH;
                          schd(n).inp1 := NOW + tpd(n)(tr01);
                          schd(n).glch1 := schd(n).inp1;  
                          schd(n).inpX := schd(n).inp1;
          WHEN '\'|'F' => schd(n).inp1 := TIME'HIGH;
                          schd(n).inp0 := NOW + tpd(n)(tr10);
                          schd(n).glch0 := schd(n).inp0;  
                          schd(n).inpX := schd(n).inp0;
          WHEN 'r'     => schd(n).inp1 := TIME'HIGH;
                          schd(n).inp0 := TIME'HIGH;
                          schd(n).inpX := NOW + tpd(n)(tr01);
          WHEN 'f'     => schd(n).inp0 := TIME'HIGH;
                          schd(n).inp1 := TIME'HIGH;
                          schd(n).inpX := NOW + tpd(n)(tr10);
          WHEN 'x'     => schd(n).inp1 := TIME'HIGH;
                          schd(n).inp0 := TIME'HIGH;
                          schd(n).inpX := NOW + MINIMUM(tpd(n)(tr10),tpd(n)(tr01));  -- update for X->X change
          WHEN OTHERS  => NULL;                   -- no timing change
        END CASE;
      END LOOP;
    END;    -- {R&R}

    PROCEDURE InvPath ( VARIABLE schd : INOUT SchedType;
                        CONSTANT Iedg : IN    EdgeType;
                        CONSTANT  tpd : IN    DelayType01       ) IS
    BEGIN
      CASE Iedg IS
        WHEN '0'|'1' => NULL;                   -- no edge: no timing update
        WHEN '/'|'R' => schd.inp0 := TIME'HIGH;
                        schd.inp1 := NOW + tpd(tr10);  schd.glch1 := schd.inp1;  
                        schd.inpX := schd.inp1;
        WHEN '\'|'F' => schd.inp1 := TIME'HIGH;
                        schd.inp0 := NOW + tpd(tr01);  schd.glch0 := schd.inp0;  
                        schd.inpX := schd.inp0;
        WHEN 'r'     => schd.inp1 := TIME'HIGH;
                        schd.inp0 := TIME'HIGH;
                        schd.inpX := NOW + tpd(tr10);
        WHEN 'f'     => schd.inp0 := TIME'HIGH;
                        schd.inp1 := TIME'HIGH;
                        schd.inpX := NOW + tpd(tr01);
        WHEN 'x'     => schd.inp1 := TIME'HIGH;
                        schd.inp0 := TIME'HIGH;
                        schd.inpX := NOW + MINIMUM(tpd(tr10),tpd(tr01));  -- update for X->X change
        WHEN OTHERS  => NULL;                   -- no timing change
      END CASE;
    END;    -- {R&R}

    PROCEDURE InvPath ( VARIABLE schd : INOUT SchedArray;
                        CONSTANT Iedg : IN    EdgeArray;
                        CONSTANT  tpd : IN    DelayArrayType01       ) IS
    BEGIN
      FOR n IN schd'RANGE LOOP
        CASE Iedg(n) IS
          WHEN '0'|'1' => NULL;                   -- no edge: no timing update
          WHEN '/'|'R' => schd(n).inp0 := TIME'HIGH;
                          schd(n).inp1 := NOW + tpd(n)(tr10);
                          schd(n).glch1 := schd(n).inp1;  
                          schd(n).inpX := schd(n).inp1;
          WHEN '\'|'F' => schd(n).inp1 := TIME'HIGH;
                          schd(n).inp0 := NOW + tpd(n)(tr01);
                          schd(n).glch0 := schd(n).inp0;  
                          schd(n).inpX := schd(n).inp0;
          WHEN 'r'     => schd(n).inp1 := TIME'HIGH;
                          schd(n).inp0 := TIME'HIGH;
                          schd(n).inpX := NOW + tpd(n)(tr10);
          WHEN 'f'     => schd(n).inp0 := TIME'HIGH;
                          schd(n).inp1 := TIME'HIGH;
                          schd(n).inpX := NOW + tpd(n)(tr01);
          WHEN 'x'     => schd(n).inp1 := TIME'HIGH;
                          schd(n).inp0 := TIME'HIGH;
                          schd(n).inpX := NOW + MINIMUM(tpd(n)(tr10),tpd(n)(tr01));  -- update for X->X change
          WHEN OTHERS  => NULL;                   -- no timing change
        END CASE;
      END LOOP;
    END;    -- {R&R}

    ---------------------------------------------------------------------------
    -- Procedure  : BufEnab, InvEnab
    --
    -- Purpose    : BufEnab and InvEnab compute output change times, from a
    --              change on an input enable port for a 3-state driver. The
    --              computed output change times are returned in the composite
    --              parameters 'schd1', 'schd0'.
    --
    --              BufEnab and InpEnab are used together with the delay path
    --              selection functions (GetSchedDelay, VitalAND, VitalOR... )
    --              The 'schd' value from each of the non-enable input ports of
    --              a model (See BufPath, InvPath) are combined using the delay
    --              selection functions (VitalAND,  VitalOR, ...). The
    --              GetSchedDelay procedure combines the output times on the
    --              enable path with the output times from the data path(s) and
    --              computes the single delay (delta time) value for scheduling
    --              the output change (passed to VitalGlitchOnEvent)
    --
    --              The values in 'schd*' are: (absolute times)
    --                inp0  :  time of output change due to input change to 0
    --                inp1  :  time of output change due to input change to 1
    --                inpX  :  time of output change due to input change to X
    --                glch0 :  time of output glitch due to input change to 0
    --                glch1 :  time of output glitch due to input change to 1
    --
    --              'schd1' contains output times for 1->Z, Z->1 transitions.
    --              'schd0' contains output times for 0->Z, Z->0 transitions.
    --
    --              'BufEnab' is used for computing the output times for an
    --              high asserted enable (output 'Z' for enable='0').
    --              'InvEnab' is used for computing the output times for an
    --              low asserted enable (output 'Z' for enable='1').
    --
    --              Note: separate 'schd1', 'schd0' parameters are generated
    --                    so that the combination of the delay paths from
    --                    multiple enable signals may be combined using the
    --                    same functions/operators used in combining separate
    --                    data paths. (See exampe 2 below)
    --
    --
    -- Parameters : schd1...... Computed output result times for 1->Z, Z->1
    --                          transitions. This parameter is modified only on
    --                          input edge values (events).
    --              schd0...... Computed output result times for 0->Z, 0->1
    --                          transitions. This parameter is modified only on
    --                          input edge values (events).
    --              Iedg....... Input port edge/level value.
    --               tpd....... Propagation delays for the enable -> output path.
    --
    -- Example1 : See the VitalBUFIF0, VitalBUFIF1, VitalINVIF0, VitalINVIF1
    --            models.
    --
    -- Example2 : sample 3-state buffer with two enables. Enable condition
    --            is "en1 OR (NOT en2)";
    --
    --      ENTITY buf99 IS
    --          GENERIC ( tpd_D_Q              : DelayType01;
    --                    tpd_EN1_Q, tpd_EN2_Q : DelayType01Z);
    --          PORT    ( D, EN1, EN2 : IN  std_ulogic;
    --                    Q           : OUT std_ulogic );
    --      END;
    --      ARCHITECTURE behav OF buf99 IS
    --      : declarations
    --      BEGIN
    --      PROCESS ( D, EN1, EN2 )
    --        BEGIN
    --            -- D to Q is a non-inverting path
    --            -- EN1 enables when high
    --            -- EN2 enables when low
    --          BufPath ( schd_D_Q,             GetEdge(D),      tpd_D_Q   );
    --          BufEnab ( schd1_EN1, schd0_EN1, GetEdge(enable), tpd_EN1_Q );
    --          InvEnab ( schd1_EN2, schd0_EN2, GetEdge(enable), tpd_EN2_Q );
    --
    --            -- compute logic function
    --          val_Q := VITALBufif1( D, (EN1 AND (NOT EN2)) );
    --
    --            -- combine times from EN1, EN2 delay paths
    --          schd1_en := schd1_EN1 AND (NOT schd1_EN2);
    --          schd0_en := schd0_EN1 AND (NOT schd0_EN2);
    --
    --            -- convert combined times to delay value
    --          GetSchedDelay ( dly, glch, val_Q, CurrentValue(gl_data),
    --                          schd_D_Q, schd1_en, schd0_en );
    --
    --            -- assign to output signal
    --          VitalGlitchOnEvent ( Q, "Q", gl_data_Q, val_Q, dly, XOnly,
    --                               glch );
    --        END PROCESS;
    --      END;
    --
    --      Example Notes:
    --       >  The delay path selection functions used to combine the separate
    --          times from A and B are overloaded on the logic operators
    --          (AND, NOT ...).
    --       >  "GetEdge(s)" converts input signal values (std_ulogic) to
    --          edge/level values (type EdgeTYpe). See VITAL_Timing package.
    --       >  "CurrentValue(..)" returns the current value of Q, based on the
    --          scheduled transaction info in 'gl_data_Q'. The 'gl_data_Q'
    --          data is maintained by 'VitalGlitchOnEvent'. See VITAL_Timing package.
    --
    ---------------------------------------------------------------------------
    PROCEDURE BufEnab ( VARIABLE schd1 : INOUT SchedType;
                        VARIABLE schd0 : INOUT SchedType;
                        CONSTANT  Iedg : IN    EdgeType;
                        CONSTANT   tpd : IN    DelayType01Z      ) IS
    BEGIN
      CASE Iedg IS
        WHEN '0'|'1' => NULL;                   -- no edge: no timing update
        WHEN '/'|'R' => schd1.inp0 := TIME'HIGH;
                        schd1.inp1 := NOW + tpd(trz1);
                        schd1.glch1 := schd1.inp1;  
                        schd1.inpX := schd1.inp1;
                        schd0.inp0 := TIME'HIGH;
                        schd0.inp1 := NOW + tpd(trz0);
                        schd0.glch1 := schd0.inp1;  
                        schd0.inpX := schd0.inp1;
        WHEN '\'|'F' => schd1.inp1 := TIME'HIGH;
                        schd1.inp0 := NOW + tpd(tr1z);
                        schd1.glch0 := schd1.inp0;  
                        schd1.inpX := schd1.inp0;
                        schd0.inp1 := TIME'HIGH;
                        schd0.inp0 := NOW + tpd(tr0z);
                        schd0.glch0 := schd0.inp0;  
                        schd0.inpX := schd0.inp0;
        WHEN 'r'     => schd1.inp1 := TIME'HIGH;
                        schd1.inp0 := TIME'HIGH;
                        schd1.inpX := NOW + tpd(trz1);
                        schd0.inp1 := TIME'HIGH;
                        schd0.inp0 := TIME'HIGH;
                        schd0.inpX := NOW + tpd(trz0);
        WHEN 'f'     => schd1.inp0 := TIME'HIGH;
                        schd1.inp1 := TIME'HIGH;
                        schd1.inpX := NOW + tpd(tr1z);
                        schd0.inp0 := TIME'HIGH;
                        schd0.inp1 := TIME'HIGH;
                        schd0.inpX := NOW + tpd(tr0z);
        WHEN 'x'     => schd1.inp0 := TIME'HIGH;
                        schd1.inp1 := TIME'HIGH;
                        schd1.inpX := NOW + MINIMUM(tpd(tr10),tpd(tr01));  -- update for X->X change
                        schd0.inp0 := TIME'HIGH;
                        schd0.inp1 := TIME'HIGH;
                        schd0.inpX := NOW + MINIMUM(tpd(tr10),tpd(tr01));  -- update for X->X change
        WHEN OTHERS  => NULL;                   -- no timing change
      END CASE;
    END;    -- {R&R}

    PROCEDURE InvEnab ( VARIABLE schd1 : INOUT SchedType;
                        VARIABLE schd0 : INOUT SchedType;
                        CONSTANT  Iedg : IN    EdgeType;
                        CONSTANT   tpd : IN    DelayType01Z      ) IS
    BEGIN
      CASE Iedg IS
        WHEN '0'|'1' => NULL;                   -- no edge: no timing update
        WHEN '/'|'R' => schd1.inp0 := TIME'HIGH;
                        schd1.inp1 := NOW + tpd(tr1z);
                        schd1.glch1 := schd1.inp1;  
                        schd1.inpX := schd1.inp1;
                        schd0.inp0 := TIME'HIGH;
                        schd0.inp1 := NOW + tpd(tr0z);
                        schd0.glch1 := schd0.inp1;  
                        schd0.inpX := schd0.inp1;
        WHEN '\'|'F' => schd1.inp1 := TIME'HIGH;
                        schd1.inp0 := NOW + tpd(trz1);  schd1.glch0 := schd1.inp0;  
                        schd1.inpX := schd1.inp0;
                        schd0.inp1 := TIME'HIGH;
                        schd0.inp0 := NOW + tpd(trz0);  schd0.glch0 := schd0.inp0;  
                        schd0.inpX := schd0.inp0;
        WHEN 'r'     => schd1.inp1 := TIME'HIGH;
                        schd1.inp0 := TIME'HIGH;
                        schd1.inpX := NOW + tpd(tr1z);
                        schd0.inp1 := TIME'HIGH;
                        schd0.inp0 := TIME'HIGH;
                        schd0.inpX := NOW + tpd(tr0z);
        WHEN 'f'     => schd1.inp0 := TIME'HIGH;
                        schd1.inp1 := TIME'HIGH;
                        schd1.inpX := NOW + tpd(trz1);
                        schd0.inp0 := TIME'HIGH;
                        schd0.inp1 := TIME'HIGH;
                        schd0.inpX := NOW + tpd(trz0);
        WHEN 'x'     => schd1.inp0 := TIME'HIGH;
                        schd1.inp1 := TIME'HIGH;
                        schd1.inpX := NOW + MINIMUM(tpd(tr10),tpd(tr01));  -- update for X->X change
                        schd0.inp0 := TIME'HIGH;
                        schd0.inp1 := TIME'HIGH;
                        schd0.inpX := NOW + MINIMUM(tpd(tr10),tpd(tr01));  -- update for X->X change
        WHEN OTHERS  => NULL;                   -- no timing change
      END CASE;
    END;    -- {R&R}

    ---------------------------------------------------------------------------
    -- Procedure  : GetSchedDelay
    --
    -- Purpose    : GetSchedDelay computes the final delay (incremental) for
    --              for scheduling an output signal.  The delay is computed
    --              from the absolute output times in the 'NewSched' parameter.
    --              (See BufPath, InvPath). 
    --
    --              Computation of the output delay for non-3_state outputs
    --              consists of selection the appropriate output time based
    --              on the new output value 'NewValue' and subtracting 'NOW'
    --              to convert to an incremental delay value.
    --
    --              The Computation of the output delay for 3_state output
    --              also includes combination of the enable path delay with
    --              the date path delay.
    --
    -- Parameters : NewDelay... Returned output delay value.
    --              GlchDelay.. Returned output delay for the start of a glitch.
    --              NewValue... New output value.
    --              CurValue... Current value of the output.
    --              NewSched... Composite containing the combined absolute
    --                          output times from the data inputs.
    --              EnSched1... Composite containing the combined absolute
    --                          output times from the enable input(s).
    --                          (for a 3_state output transitions 1->Z, Z->1)
    --              EnSched0... Composite containing the combined absolute
    --                          output times from the enable input(s).
    --                          (for a 3_state output transitions 0->Z, Z->0)
    --
    ---------------------------------------------------------------------------
    PROCEDURE GetSchedDelay ( VARIABLE   NewDelay : OUT TIME;
                              VARIABLE  GlchDelay : OUT TIME;
                              CONSTANT   NewValue : IN  std_ulogic;
                              CONSTANT   CurValue : IN  std_ulogic;
                              CONSTANT   NewSched : IN  SchedType
                            ) IS
        VARIABLE tim, glch : TIME;
    BEGIN

        CASE To_UX01(NewValue) IS
          WHEN '0'    => tim  := NewSched.inp0;
                         glch := NewSched.glch1;
          WHEN '1'    => tim  := NewSched.inp1;
                         glch := NewSched.glch0;
          WHEN OTHERS => tim  := NewSched.inpX;
                         glch := -1 ns;
        END CASE;
        IF (CurValue /= NewValue)
          THEN glch := -1 ns;
        END IF;

        NewDelay  := tim  - NOW;
        IF glch < 0 ns
            THEN GlchDelay := glch;
            ELSE GlchDelay := glch - NOW;
        END IF; -- glch < 0 ns
    END;    -- {R&R}

    PROCEDURE GetSchedDelay ( VARIABLE   NewDelay : OUT TimeArray;
                              VARIABLE  GlchDelay : OUT TimeArray;
                              CONSTANT   NewValue : IN  std_logic_vector;
                              CONSTANT   CurValue : IN  std_logic_vector;
                              CONSTANT   NewSched : IN  SchedArray
                            ) IS
        VARIABLE tim, glch : TIME;
        ALIAS  NewDelay_alias : TimeArray  (  NewDelay'LENGTH DOWNTO 1 ) IS NewDelay;
        ALIAS GlchDelay_alias : TimeArray  ( GlchDelay'LENGTH DOWNTO 1 ) IS GlchDelay;
        ALIAS  NewSched_alias : SchedArray (  NewSched'LENGTH DOWNTO 1 ) IS NewSched;
        ALIAS  NewValue_alias : std_logic_vector (  NewValue'LENGTH DOWNTO 1 )
                                IS  NewValue;
        ALIAS  CurValue_alias : std_logic_vector (  CurValue'LENGTH DOWNTO 1 )
                                IS  CurValue;
    BEGIN
      FOR n IN NewDelay'LENGTH DOWNTO 1 LOOP
        CASE To_UX01(NewValue_alias(n)) IS
          WHEN '0'    => tim  := NewSched_alias(n).inp0;
                         glch := NewSched_alias(n).glch1;
          WHEN '1'    => tim  := NewSched_alias(n).inp1;
                         glch := NewSched_alias(n).glch0;
          WHEN OTHERS => tim  := NewSched_alias(n).inpX;
                         glch := -1 ns;
        END CASE;
        IF (CurValue_alias(n) /= NewValue_alias(n))
          THEN glch := -1 ns;
        END IF;

        NewDelay_alias(n) := tim  - NOW;
        IF glch < 0 ns
            THEN GlchDelay_alias(n) := glch;
            ELSE GlchDelay_alias(n) := glch - NOW;
        END IF; -- glch < 0 ns
      END LOOP;
      RETURN;
    END;    -- {R&R}

    PROCEDURE GetSchedDelay ( VARIABLE   NewDelay : OUT TIME;
                              VARIABLE  GlchDelay : OUT TIME;
                              CONSTANT   NewValue : IN  std_ulogic;
                              CONSTANT   CurValue : IN  std_ulogic;
                              CONSTANT   NewSched : IN  SchedType;
                              CONSTANT   EnSched1 : IN  SchedType;
                              CONSTANT   EnSched0 : IN  SchedType
                            ) IS
        SUBTYPE v2 IS std_logic_vector(0 TO 1); 
        VARIABLE tim, glch : TIME;
    BEGIN

        CASE v2'(To_X01Z(CurValue) & To_X01Z(NewValue)) IS
          WHEN "00"    => tim  := MAXIMUM (NewSched.inp0, EnSched0.inp1);
                          glch := GlitchMinTime(NewSched.glch1,EnSched0.glch0);
          WHEN "01"    => tim  := MAXIMUM (NewSched.inp1, EnSched1.inp1);
                          glch := EnSched1.glch0;
          WHEN "0Z"    => tim  := EnSched0.inp0;
                          glch := NewSched.glch1;
          WHEN "0X"    => tim  := MAXIMUM (NewSched.inpX, EnSched1.inpX);
                          glch := 0 ns;
          WHEN "10"    => tim  := MAXIMUM (NewSched.inp0, EnSched0.inp1);
                          glch := EnSched0.glch0;
          WHEN "11"    => tim  := MAXIMUM (NewSched.inp1, EnSched1.inp1);
                          glch := GlitchMinTime(NewSched.glch0,EnSched1.glch0);
          WHEN "1Z"    => tim  := EnSched1.inp0;
                          glch := NewSched.glch0;
          WHEN "1X"    => tim  := MAXIMUM (NewSched.inpX, EnSched0.inpX);
                          glch := 0 ns;
          WHEN "Z0"    => tim  := MAXIMUM (NewSched.inp0, EnSched0.inp1);
                          IF NewSched.glch0 > NOW
                            THEN glch := MAXIMUM(NewSched.glch1,EnSched1.inp1);
                            ELSE glch := 0 ns;
                          END IF;
          WHEN "Z1"    => tim  := MAXIMUM (NewSched.inp1, EnSched1.inp1);
                          IF NewSched.glch1 > NOW
                            THEN glch := MAXIMUM(NewSched.glch0,EnSched0.inp1);
                            ELSE glch := 0 ns;
                          END IF;
          WHEN "ZX"    => tim  := MAXIMUM (NewSched.inpX, EnSched1.inpX);
                          glch := 0 ns;
          WHEN "ZZ"    => tim  := MAXIMUM (EnSched1.inpX, EnSched0.inpX);
                          glch := 0 ns;
          WHEN "X0"    => tim  := MAXIMUM (NewSched.inp0, EnSched0.inp1);
                          glch := 0 ns;
          WHEN "X1"    => tim  := MAXIMUM (NewSched.inp1, EnSched1.inp1);
                          glch := 0 ns;
          WHEN "XZ"    => tim  := MAXIMUM (EnSched1.inpX, EnSched0.inpX);
                          glch := 0 ns;
          WHEN OTHERS  => tim  := MAXIMUM (NewSched.inpX, EnSched1.inpX);
                          glch := 0 ns;

        END CASE;
        NewDelay  := tim  - NOW;
        IF glch < 0 ns
            THEN GlchDelay := glch;
            ELSE GlchDelay := glch - NOW;
        END IF; -- glch < 0 ns
    END;    -- {R&R}

    ---------------------------------------------------------------------------
    -- Operators and Functions for combination (selection) of path delays
    -- > These functions support selection of the "appripriate" path delay
    --   dependent on the logic function.
    -- > These functions only "select" from the possable output times. No
    --   calculation (addition) of delays is performed.
    -- > See description of 'BufPath', 'InvPath' and 'GetSchedDelay'
    -- > See primitive PROCEDURE models for examples.
    ---------------------------------------------------------------------------

    FUNCTION "not"  ( CONSTANT a : IN SchedType ) RETURN SchedType IS
        VARIABLE z : SchedType;
    BEGIN
        z.inp1  := a.inp0 ;
        z.inp0  := a.inp1 ;
        z.inpX  := a.inpX ;
        z.glch1 := a.glch0;
        z.glch0 := a.glch1;
        RETURN (z);
    END;    -- {R&R}

    FUNCTION "and"  ( CONSTANT a, b : IN SchedType ) RETURN SchedType IS
        VARIABLE z : SchedType;
    BEGIN
        z.inp1  := MAXIMUM   ( a.inp1 , b.inp1  );
        z.inp0  := MINIMUM   ( a.inp0 , b.inp0  );
        z.inpX  := GlitchMinTime ( a.inpX , b.inpX  );
        z.glch1 := MAXIMUM   ( a.glch1, b.glch1 );
        z.glch0 := GlitchMinTime ( a.glch0, b.glch0 );
        RETURN (z);
    END;    -- {R&R}

    FUNCTION "or"   ( CONSTANT a, b : IN SchedType ) RETURN SchedType IS
        VARIABLE z : SchedType;
    BEGIN
        z.inp0  := MAXIMUM   ( a.inp0 , b.inp0  );
        z.inp1  := MINIMUM   ( a.inp1 , b.inp1  );
        z.inpX  := GlitchMinTime ( a.inpX , b.inpX  );
        z.glch0 := MAXIMUM   ( a.glch0, b.glch0 );
        z.glch1 := GlitchMinTime ( a.glch1, b.glch1 );
        RETURN (z);
    END;    -- {R&R}

    FUNCTION "nand" ( CONSTANT a, b : IN SchedType ) RETURN SchedType IS
        VARIABLE z : SchedType;
    BEGIN
        z.inp0  := MAXIMUM   ( a.inp1 , b.inp1  );
        z.inp1  := MINIMUM   ( a.inp0 , b.inp0  );
        z.inpX  := GlitchMinTime ( a.inpX , b.inpX  );
        z.glch0 := MAXIMUM   ( a.glch1, b.glch1 );
        z.glch1 := GlitchMinTime ( a.glch0, b.glch0 );
        RETURN (z);
    END;    -- {R&R}

    FUNCTION "nor"  ( CONSTANT a, b : IN SchedType ) RETURN SchedType IS
        VARIABLE z : SchedType;
    BEGIN
        z.inp1  := MAXIMUM   ( a.inp0 , b.inp0  );
        z.inp0  := MINIMUM   ( a.inp1 , b.inp1  );
        z.inpX  := GlitchMinTime ( a.inpX , b.inpX  );
        z.glch1 := MAXIMUM   ( a.glch0, b.glch0 );
        z.glch0 := GlitchMinTime ( a.glch1, b.glch1 );
        RETURN (z);
    END;    -- {R&R}

    -- ------------------------------------------------------------------------
    -- Commonly used 2-bit Logical gates.
    -- ------------------------------------------------------------------------
    FUNCTION VitalAND2  ( CONSTANT a, b : IN SchedType ) RETURN SchedType IS
    BEGIN
        RETURN a AND b;
    END;    -- {R&R}

    FUNCTION VitalOR2   ( CONSTANT a, b : IN SchedType ) RETURN SchedType IS
    BEGIN
        RETURN a OR b;
    END;    -- {R&R}

    FUNCTION VitalNAND2 ( CONSTANT a, b : IN SchedType ) RETURN SchedType IS
    BEGIN
        RETURN a NAND b;
    END;    -- {R&R}

    FUNCTION VitalNOR2  ( CONSTANT a, b : IN SchedType ) RETURN SchedType IS
    BEGIN
        RETURN a NOR b;
    END;    -- {R&R}
 
    FUNCTION VitalXOR2   ( CONSTANT ab,ai, bb,bi : IN SchedType ) RETURN SchedType IS
        VARIABLE z : SchedType;
    BEGIN
        -- z = (a AND b) NOR (a NOR b)
        z.inp1  :=   MAXIMUM (  MINIMUM (ai.inp0 , bi.inp0 ),
                                MINIMUM (ab.inp1 , bb.inp1 ) );
        z.inp0  :=   MINIMUM (  MAXIMUM (ai.inp1 , bi.inp1 ),
                                MAXIMUM (ab.inp0 , bb.inp0 ) );
        z.inpX  :=   MAXIMUM (  MAXIMUM (ai.inpX , bi.inpX ),
                                MAXIMUM (ab.inpX , bb.inpX ) );
        z.glch1 :=   MAXIMUM (GlitchMinTime (ai.glch0, bi.glch0),
                              GlitchMinTime (ab.glch1, bb.glch1) );
        z.glch0 := GlitchMinTime (  MAXIMUM (ai.glch1, bi.glch1),
                                MAXIMUM (ab.glch0, bb.glch0) );
        RETURN (z);
    END;    -- {R&R}

    FUNCTION VitalXNOR2  ( CONSTANT ab,ai, bb,bi : IN SchedType ) RETURN SchedType IS
        VARIABLE z : SchedType;
    BEGIN
        -- z = (a AND b) OR (a NOR b)
        z.inp0  :=   MAXIMUM (  MINIMUM (ab.inp0 , bb.inp0 ),
                                MINIMUM (ai.inp1 , bi.inp1 ) );
        z.inp1  :=   MINIMUM (  MAXIMUM (ab.inp1 , bb.inp1 ),
                                MAXIMUM (ai.inp0 , bi.inp0 ) );
        z.inpX  :=   MAXIMUM (  MAXIMUM (ab.inpX , bb.inpX ),
                                MAXIMUM (ai.inpX , bi.inpX ) );
        z.glch0 :=   MAXIMUM (GlitchMinTime (ab.glch0, bb.glch0),
                              GlitchMinTime (ai.glch1, bi.glch1) );
        z.glch1 := GlitchMinTime (  MAXIMUM (ab.glch1, bb.glch1),
                                MAXIMUM (ai.glch0, bi.glch0) );
        RETURN (z);
    END;    -- {R&R}

    -- ------------------------------------------------------------------------
    -- Commonly used 3-bit Logical gates.
    -- ------------------------------------------------------------------------
    FUNCTION VitalAND3  ( CONSTANT a, b, c : IN SchedType ) RETURN SchedType IS
    BEGIN
        RETURN a AND b AND c;
    END;    -- {R&R}

    FUNCTION VitalOR3   ( CONSTANT a, b, c : IN SchedType ) RETURN SchedType IS
    BEGIN
        RETURN a OR b OR c;
    END;    -- {R&R}

    FUNCTION VitalNAND3 ( CONSTANT a, b, c : IN SchedType ) RETURN SchedType IS
    BEGIN
        RETURN NOT (a AND b AND c);
    END;    -- {R&R}

    FUNCTION VitalNOR3  ( CONSTANT a, b, c : IN SchedType ) RETURN SchedType IS
    BEGIN
        RETURN NOT (a OR b OR c);
    END;    -- {R&R}

    FUNCTION VitalXOR3   ( CONSTANT ab,ai, bb,bi, cb,ci : IN SchedType )
      RETURN SchedType IS
    BEGIN
        RETURN VitalXOR2 ( VitalXOR2 (ab,ai, bb,bi), VitalXOR2 (ai,ab, bi,bb),
                           cb, ci );
    END;    -- {R&R}

    FUNCTION VitalXNOR3  ( CONSTANT ab,ai, bb,bi, cb,ci : IN SchedType )
      RETURN SchedType IS
    BEGIN
        RETURN VitalXNOR2 ( VitalXOR2 ( ab,ai, bb,bi ), VitalXOR2 ( ai,ab, bi,bb ),
                            cb, ci );
    END;    -- {R&R}

    -- ------------------------------------------------------------------------
    -- Commonly used 4-bit Logical gates.
    -- ------------------------------------------------------------------------

    FUNCTION VitalAND4  ( CONSTANT a, b, c, d : IN SchedType ) RETURN SchedType IS
    BEGIN
        RETURN a AND b AND c AND d;
    END;    -- {R&R}

    FUNCTION VitalOR4   ( CONSTANT a, b, c, d : IN SchedType ) RETURN SchedType IS
    BEGIN
        RETURN a OR b OR c OR d;
    END;    -- {R&R}

    FUNCTION VitalNAND4 ( CONSTANT a, b, c, d : IN SchedType ) RETURN SchedType IS
    BEGIN
        RETURN NOT (a AND b AND c AND d);
    END;    -- {R&R}

    FUNCTION VitalNOR4  ( CONSTANT a, b, c, d : IN SchedType ) RETURN SchedType IS
    BEGIN
        RETURN NOT (a OR b OR c OR d);
    END;    -- {R&R}

    FUNCTION VitalXOR4   ( CONSTANT ab,ai, bb,bi, cb,ci, db,di : IN SchedType )
      RETURN SchedType IS
    BEGIN
        RETURN VitalXOR2 ( VitalXOR2 ( ab,ai, bb,bi ), VitalXOR2 ( ai,ab, bi,bb ), 
                           VitalXOR2 ( cb,ci, db,di ), VitalXOR2 ( ci,cb, di,db ) );
    END;    -- {R&R}

    FUNCTION VitalXNOR4  ( CONSTANT ab,ai, bb,bi, cb,ci, db,di : IN SchedType )
      RETURN SchedType IS
    BEGIN
        RETURN VitalXNOR2 ( VitalXOR2 ( ab,ai, bb,bi ), VitalXOR2 ( ai,ab, bi,bb ), 
                            VitalXOR2 ( cb,ci, db,di ), VitalXOR2 ( ci,cb, di,db ) );
    END;    -- {R&R}

    -- ------------------------------------------------------------------------
    -- N-bit wide Logical gates.
    -- ------------------------------------------------------------------------
    FUNCTION VitalAND  ( CONSTANT data : IN SchedArray ) RETURN SchedType IS
        VARIABLE result : SchedType;
    BEGIN
        FOR i IN data'RANGE LOOP
            result := result AND data(i);
        END LOOP;
        RETURN result;
    END;    -- {R&R}

    FUNCTION VitalOR   ( CONSTANT data : IN SchedArray ) RETURN SchedType IS
        VARIABLE result : SchedType;
    BEGIN
        FOR i IN data'RANGE LOOP
            result := result OR data(i);
        END LOOP;
        RETURN result;
    END;    -- {R&R}

    FUNCTION VitalNAND ( CONSTANT data : IN SchedArray ) RETURN SchedType IS
        VARIABLE result : SchedType;
    BEGIN
        FOR i IN data'RANGE LOOP
            result := result AND data(i);
        END LOOP;
        RETURN NOT result;
    END;    -- {R&R}

    FUNCTION VitalNOR  ( CONSTANT data : IN SchedArray ) RETURN SchedType IS
        VARIABLE result : SchedType;
    BEGIN
        FOR i IN data'RANGE LOOP
            result := result OR data(i);
        END LOOP;
        RETURN NOT result;
    END;    -- {R&R}
 
    -- Note: index range on datab,datai assumed to be 1 TO length.
    --       This is enforced by internal only usage of this Function
    FUNCTION VitalXOR   ( CONSTANT datab, datai : IN SchedArray ) RETURN SchedType IS
        CONSTANT leng : INTEGER := datab'LENGTH;
    BEGIN
        IF leng = 2 THEN
            RETURN VitalXOR2 ( datab(1),datai(1), datab(2),datai(2) );
        ELSE
            RETURN VitalXOR2 ( VitalXOR ( datab(1 TO leng-1), datai(1 TO leng-1) ),
                               VitalXOR ( datai(1 TO leng-1), datab(1 TO leng-1) ),
                               datab(leng),datai(leng) );
        END IF;
    END;    -- {R&R}

    -- Note: index range on datab,datai assumed to be 1 TO length.
    --       This is enforced by internal only usage of this Function
    FUNCTION VitalXNOR  ( CONSTANT datab, datai : IN SchedArray ) RETURN SchedType IS
        CONSTANT leng : INTEGER := datab'LENGTH;
    BEGIN
        IF leng = 2 THEN
            RETURN VitalXNOR2 ( datab(1),datai(1), datab(2),datai(2) );
        ELSE
            RETURN VitalXNOR2 ( VitalXOR ( datab(1 TO leng-1), datai(1 TO leng-1) ),
                                VitalXOR ( datai(1 TO leng-1), datab(1 TO leng-1) ),
                                datab(leng),datai(leng) );
        END IF;
    END;    -- {R&R}

    -- ------------------------------------------------------------------------
    -- Buffers
    --   BUF    ....... standard non-inverting buffer
    --   BUFIF0 ....... non-inverting buffer Data passes thru if (Enable = '0')
    --   BUFIF1 ....... non-inverting buffer Data passes thru if (Enable = '1')
    -- ------------------------------------------------------------------------
    FUNCTION VitalBUF  ( CONSTANT data : IN SchedType ) RETURN SchedType IS
    BEGIN
        RETURN data;
    END;    -- {R&R}

    -- ------------------------------------------------------------------------
    -- Invertors
    --   INV    ....... standard inverting buffer
    --   INVIF0 ....... inverting buffer Data passes thru if (Enable = '0')
    --   INVIF1 ....... inverting buffer Data passes thru if (Enable = '1')
    -- ------------------------------------------------------------------------
    FUNCTION VitalINV  ( CONSTANT data : IN SchedType ) RETURN SchedType IS
    BEGIN
        RETURN NOT data;
    END;    -- {R&R}

    -- ------------------------------------------------------------------------
    -- Multiplexor
    --   MUX   .......... result := data(dselect) 
    --   MUX2  .......... 2-input mux; result := data0 when (dselect = '0'), 
    --                                           data1 when (dselect = '1'),
    --                        'X' when (dselect = 'X') and (data0 /= data1)
    --   MUX4  .......... 4-input mux; result := data(dselect)
    --   MUX8  .......... 8-input mux; result := data(dselect)
    -- ------------------------------------------------------------------------
    FUNCTION VitalMUX2  ( CONSTANT d1, d0 : IN SchedType;
                          CONSTANT sb, si : IN SchedType
                        ) RETURN SchedType IS
    BEGIN
        RETURN (d1 AND sb) OR (d0 AND (NOT si) );
    END;    -- {R&R}
--
    FUNCTION VitalMUX4  ( CONSTANT data : IN SchedArray4;
                          CONSTANT sb   : IN SchedArray2;
                          CONSTANT si   : IN SchedArray2
                        ) RETURN SchedType IS
    BEGIN
        RETURN    (      sb(1)  AND VitalMux2(data(3),data(2), sb(0), si(0)) )
               OR ( (NOT si(1)) AND VitalMux2(data(1),data(0), sb(0), si(0)) );
    END;    -- {R&R}

    FUNCTION VitalMUX8  ( CONSTANT data : IN SchedArray8;
                          CONSTANT sb   : IN SchedArray3;
                          CONSTANT si   : IN SchedArray3
                        ) RETURN SchedType IS
    BEGIN
        RETURN    ( (    sb(2)) AND VitalMux4 (data(7 DOWNTO 4),
                                           sb(1 DOWNTO 0), si(1 DOWNTO 0) ) )
               OR ( (NOT si(2)) AND VitalMux4 (data(3 DOWNTO 0),
                                           sb(1 DOWNTO 0), si(1 DOWNTO 0) ) );
    END;    -- {R&R}
--
    FUNCTION VinterMUX   ( CONSTANT data : IN SchedArray;
                           CONSTANT sb   : IN SchedArray;
                           CONSTANT si   : IN SchedArray
                         ) RETURN SchedType IS
        CONSTANT smsb : INTEGER := sb'LENGTH;
        CONSTANT dmsb_high : INTEGER := data'LENGTH;
        CONSTANT dmsb_low  : INTEGER := data'LENGTH/2;
    BEGIN
        IF sb'LENGTH = 1 THEN
          RETURN VitalMux2( data(2), data(1), sb(1), si(1) );
        ELSIF sb'LENGTH = 2 THEN
          RETURN VitalMux4( data, sb, si );
        ELSIF sb'LENGTH = 3 THEN
          RETURN VitalMux8( data, sb, si );
        ELSIF sb'LENGTH > 3 THEN 
          RETURN    ((    sb(smsb)) AND VinterMux( data(dmsb_low  DOWNTO  1),
                                                     sb(smsb-1 DOWNTO 1),
                                                     si(smsb-1 DOWNTO 1) ))
                 OR ((NOT si(smsb)) AND VinterMux( data(dmsb_high DOWNTO dmsb_low+1),
                                                     sb(smsb-1 DOWNTO 1),
                                                     si(smsb-1 DOWNTO 1) ));
        ELSE
          RETURN (0 ns, 0 ns, 0 ns, 0 ns, 0 ns); -- dselect'LENGTH < 1
        END IF;
    END;    -- {R&R}
--
    CONSTANT DefSchedAnd  : SchedType  := (TIME'HIGH, 0 ns, 0 ns, TIME'HIGH, 0 ns);
    FUNCTION VitalMUX   ( CONSTANT data : IN SchedArray;
                          CONSTANT sb   : IN SchedArray;
                          CONSTANT si   : IN SchedArray
                        ) RETURN SchedType IS
        CONSTANT msb : INTEGER := 2**sb'LENGTH;
        VARIABLE    ldat : SchedArray(msb DOWNTO 1);
        ALIAS data_alias : SchedArray ( data'LENGTH DOWNTO 1 ) IS data;
        ALIAS   sb_alias : SchedArray (   sb'LENGTH DOWNTO 1 ) IS sb;
        ALIAS   si_alias : SchedArray (   si'LENGTH DOWNTO 1 ) IS si;
    BEGIN
        IF data'LENGTH <= msb THEN
            FOR i IN data'LENGTH DOWNTO 1 LOOP
                ldat(i) := data_alias(i);
            END LOOP;
            FOR i in msb DOWNTO data'LENGTH+1 LOOP
                ldat(i) := DefSchedAnd;
            END LOOP;
        ELSE
            FOR i IN msb DOWNTO 1 LOOP
                ldat(i) := data_alias(i);
            END LOOP;
        END IF;
        RETURN VinterMUX( ldat, sb_alias, si_alias );
    END;    -- {R&R}

    -- ------------------------------------------------------------------------
    -- Decoder
    --          General Algorithm : 
    --              (a) Result(...) := '0' when (enable = '0') 
    --              (b) Result(data) := '1'; all other subelements = '0'
    --              ... Result array is decending (n-1 downto 0)
    --
    --          DECODERn  .......... n:2**n decoder
    -- ------------------------------------------------------------------------
    FUNCTION VitalDECODER2  ( CONSTANT datab  : IN SchedType;
                              CONSTANT datai  : IN SchedType;
                              CONSTANT enable : IN SchedType
                            ) RETURN SchedArray IS
        VARIABLE result : SchedArray2;
    BEGIN
        result(1) := enable AND (    datab);
        result(0) := enable AND (NOT datai);
        RETURN result;
    END;    -- {R&R}

    FUNCTION VitalDECODER4  ( CONSTANT datab  : IN SchedArray2;
                              CONSTANT datai  : IN SchedArray2;
                              CONSTANT enable : IN SchedType
                            ) RETURN SchedArray IS
        VARIABLE result : SchedArray4;
    BEGIN
        result(3) := enable AND (    datab(1)) AND (    datab(0));
        result(2) := enable AND (    datab(1)) AND (NOT datai(0));
        result(1) := enable AND (NOT datai(1)) AND (    datab(0));
        result(0) := enable AND (NOT datai(1)) AND (NOT datai(0));
        RETURN result;
    END;    -- {R&R}

    FUNCTION VitalDECODER8  ( CONSTANT datab  : IN SchedArray3;
                              CONSTANT datai  : IN SchedArray3;
                              CONSTANT enable : IN SchedType
                            ) RETURN SchedArray IS
        VARIABLE result : SchedArray8;
    BEGIN
        result(7) := enable AND (    datab(2)) AND (    datab(1)) AND (    datab(0));
        result(6) := enable AND (    datab(2)) AND (    datab(1)) AND (NOT datai(0));
        result(5) := enable AND (    datab(2)) AND (NOT datai(1)) AND (    datab(0));
        result(4) := enable AND (    datab(2)) AND (NOT datai(1)) AND (NOT datai(0));
        result(3) := enable AND (NOT datai(2)) AND (    datab(1)) AND (    datab(0));
        result(2) := enable AND (NOT datai(2)) AND (    datab(1)) AND (NOT datai(0));
        result(1) := enable AND (NOT datai(2)) AND (NOT datai(1)) AND (    datab(0));
        result(0) := enable AND (NOT datai(2)) AND (NOT datai(1)) AND (NOT datai(0));
        RETURN result;
    END;    -- {R&R}

    CONSTANT DefSchedArray2 : SchedArray2 := (OTHERS=> (0 ns, 0 ns, 0 ns, 0 ns, 0 ns));

    FUNCTION VitalDECODER   ( CONSTANT datab  : IN SchedArray;
                              CONSTANT datai  : IN SchedArray;
                              CONSTANT enable : IN SchedType
                            ) RETURN SchedArray IS
        CONSTANT dmsb : INTEGER := datab'LENGTH - 1;
        ALIAS datab_a : SchedArray ( dmsb DOWNTO 0 ) IS datab;
        ALIAS datai_a : SchedArray ( dmsb DOWNTO 0 ) IS datai;
    BEGIN
        IF datab'LENGTH = 1 THEN
            RETURN VitalDECODER2 ( datab_a(    0     ), datai_a(    0     ), enable );
        ELSIF datab'LENGTH = 2 THEN
            RETURN VitalDECODER4 ( datab_a(1 DOWNTO 0), datai_a(1 DOWNTO 0), enable );
        ELSIF datab'LENGTH = 3 THEN
            RETURN VitalDECODER8 ( datab_a(2 DOWNTO 0), datai_a(2 DOWNTO 0), enable );
        ELSIF datab'LENGTH > 3 THEN
            RETURN   VitalDECODER ( datab_a(dmsb-1 DOWNTO 0),
                                    datai_a(dmsb-1 DOWNTO 0),
                                    enable AND (    datab_a(dmsb)) )
                   & VitalDECODER ( datab_a(dmsb-1 DOWNTO 0),
                                    datai_a(dmsb-1 DOWNTO 0),
                                    enable AND (NOT datai_a(dmsb)) );
        ELSE
            RETURN DefSchedArray2;
        END IF;
    END;    -- {R&R}


-----------------------------------------------------------------------------------
-- PRIMITIVES
-----------------------------------------------------------------------------------
    -- ----------------------------------------------------------------------------
    -- N-bit wide Logical gates.
    -- ----------------------------------------------------------------------------
    FUNCTION VitalAND    ( CONSTANT       data :  IN std_logic_vector;
                           CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                         ) RETURN std_ulogic IS
        VARIABLE result : UX01;
    BEGIN
        result := '1';
        FOR i IN data'RANGE LOOP
            result := result AND data(i);
        END LOOP;
        RETURN ResultMap(result);
    END;    -- {R&R}
--
    FUNCTION VitalOR     ( CONSTANT       data :  IN std_logic_vector;
                           CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                         ) RETURN std_ulogic IS
        VARIABLE result : UX01;
    BEGIN
        result := '0';
        FOR i IN data'RANGE LOOP
            result := result OR data(i);
        END LOOP;
        RETURN ResultMap(result);
    END;    -- {R&R}
--
    FUNCTION VitalXOR    ( CONSTANT       data :  IN std_logic_vector;
                           CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                         ) RETURN std_ulogic IS
        VARIABLE result : UX01;
    BEGIN
        result := '0';
        FOR i IN data'RANGE LOOP
            result := result XOR data(i);
        END LOOP;
        RETURN ResultMap(result);
    END;    -- {R&R}
--
    FUNCTION VitalNAND   ( CONSTANT       data :  IN std_logic_vector;
                           CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                         ) RETURN std_ulogic IS
        VARIABLE result : UX01;
    BEGIN
        result := '1';
        FOR i IN data'RANGE LOOP
            result := result AND data(i);
        END LOOP;
        RETURN ResultMap(NOT result);
    END;    -- {R&R}
--
    FUNCTION VitalNOR    ( CONSTANT       data :  IN std_logic_vector;
                           CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                         ) RETURN std_ulogic IS
        VARIABLE result : UX01;
    BEGIN
        result := '0';
        FOR i IN data'RANGE LOOP
            result := result OR data(i);
        END LOOP;
        RETURN ResultMap(NOT result);
    END;    -- {R&R}
--
    FUNCTION VitalXNOR   ( CONSTANT       data :  IN std_logic_vector;
                           CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                         ) RETURN std_ulogic IS
        VARIABLE result : UX01;
    BEGIN
        result := '0';
        FOR i IN data'RANGE LOOP
            result := result XOR data(i);
        END LOOP;
        RETURN ResultMap(NOT result);
    END;    -- {R&R}
 
    -- ------------------------------------------------------------------------
    -- Commonly used 2-bit Logical gates.
    -- ------------------------------------------------------------------------
    FUNCTION VitalAND2   ( CONSTANT       a, b :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(a AND b);
    END;    -- {R&R}
--
    FUNCTION VitalOR2    ( CONSTANT       a, b :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(a OR b);
    END;    -- {R&R}
--
    FUNCTION VitalXOR2   ( CONSTANT       a, b :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(a XOR b);
    END;    -- {R&R}
--
    FUNCTION VitalNAND2  ( CONSTANT       a, b :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(a NAND b);
    END;    -- {R&R}
--
    FUNCTION VitalNOR2   ( CONSTANT       a, b :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(a NOR b);
    END;    -- {R&R}
--
    FUNCTION VitalXNOR2  ( CONSTANT       a, b :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(NOT (a XOR b));
    END;    -- {R&R}
--
    -- ------------------------------------------------------------------------
    -- Commonly used 3-bit Logical gates.
    -- ------------------------------------------------------------------------
    FUNCTION VitalAND3   ( CONSTANT    a, b, c :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(a AND b AND c);
    END;    -- {R&R}
--
    FUNCTION VitalOR3    ( CONSTANT    a, b, c :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(a OR b OR c);
    END;    -- {R&R}
--
    FUNCTION VitalXOR3   ( CONSTANT    a, b, c :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(a XOR b XOR c);
    END;    -- {R&R}
--
    FUNCTION VitalNAND3  ( CONSTANT    a, b, c :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(NOT (a AND b AND c));
    END;    -- {R&R}
--
    FUNCTION VitalNOR3   ( CONSTANT    a, b, c :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(NOT (a OR b OR c));
    END;    -- {R&R}
--
    FUNCTION VitalXNOR3  ( CONSTANT    a, b, c :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(NOT (a XOR b XOR c));
    END;    -- {R&R}

    -- ---------------------------------------------------------------------------
    -- Commonly used 4-bit Logical gates.
    -- ---------------------------------------------------------------------------
    FUNCTION VitalAND4   ( CONSTANT a, b, c, d :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(a AND b AND c AND d);
    END;    -- {R&R}
--
    FUNCTION VitalOR4    ( CONSTANT a, b, c, d :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(a OR b OR c OR d);
    END;    -- {R&R}
--
    FUNCTION VitalXOR4   ( CONSTANT a, b, c, d :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(a XOR b XOR c XOR d);
    END;    -- {R&R}
--
    FUNCTION VitalNAND4  ( CONSTANT a, b, c, d :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(NOT (a AND b AND c AND d));
    END;    -- {R&R}
--
    FUNCTION VitalNOR4   ( CONSTANT a, b, c, d :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(NOT (a OR b OR c OR d));
    END;    -- {R&R}
--
    FUNCTION VitalXNOR4  ( CONSTANT a, b, c, d :  IN std_ulogic;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(NOT (a XOR b XOR c XOR d));
    END;    -- {R&R}

    -- ------------------------------------------------------------------------
    -- Buffers
    --   BUF    ....... standard non-inverting buffer
    --   BUFIF0 ....... non-inverting buffer Data passes thru if (Enable = '0')
    --   BUFIF1 ....... non-inverting buffer Data passes thru if (Enable = '1')
    -- ------------------------------------------------------------------------
    FUNCTION VitalBUF    ( CONSTANT         data :  IN std_ulogic;
                           CONSTANT    ResultMap :  IN ResultMapType := DefaultResultMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(To_UX01(data));
    END;    -- {R&R}
--
    FUNCTION VitalBUFIF0 ( CONSTANT data, enable :  IN std_ulogic;
                           CONSTANT    ResultMap :  IN ResultZMapType := DefaultResultZMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(bufif0_table(enable,data));
    END;    -- {R&R}
--
    FUNCTION VitalBUFIF1 ( CONSTANT data, enable :  IN std_ulogic;
                           CONSTANT    ResultMap :  IN ResultZMapType := DefaultResultZMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(bufif1_table(enable,data));
    END;    -- {R&R}
    FUNCTION VitalIDENT  ( CONSTANT         data :  IN std_ulogic;
                           CONSTANT    ResultMap :  IN ResultZMapType := DefaultResultZMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(To_UX01Z(data));
    END;    -- {R&R}

    -- ------------------------------------------------------------------------
    -- Invertors
    --   INV    ......... standard inverting buffer
    --   INVIF0 ......... inverting buffer Data passes thru if (Enable = '0')
    --   INVIF1 ......... inverting buffer Data passes thru if (Enable = '1')
    -- ------------------------------------------------------------------------
    FUNCTION VitalINV    ( CONSTANT         data :  IN std_ulogic;
                           CONSTANT    ResultMap :  IN ResultMapType := DefaultResultMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(NOT data);
    END;    -- {R&R}
--
    FUNCTION VitalINVIF0 ( CONSTANT data, enable :  IN std_ulogic;
                           CONSTANT    ResultMap :  IN ResultZMapType := DefaultResultZMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(invif0_table(enable,data));
    END;    -- {R&R}
--
    FUNCTION VitalINVIF1 ( CONSTANT data, enable :  IN std_ulogic;
                           CONSTANT    ResultMap :  IN ResultZMapType := DefaultResultZMap
                         ) RETURN std_ulogic IS
    BEGIN
        RETURN ResultMap(invif1_table(enable,data));
    END;    -- {R&R}

    -- ------------------------------------------------------------------------
    -- Multiplexor
    --   MUX   .......... result := data(dselect) 
    --   MUX2  .......... 2-input mux; result := data0 when (dselect = '0'), 
    --                                           data1 when (dselect = '1'),
    --                        'X' when (dselect = 'X') and (data0 /= data1)
    --   MUX4  .......... 4-input mux; result := data(dselect)
    --   MUX8  .......... 8-input mux; result := data(dselect)
    -- ------------------------------------------------------------------------
    FUNCTION VitalMUX2  ( CONSTANT data1, data0 :  IN std_ulogic;
                          CONSTANT      dselect :  IN std_ulogic;
                          CONSTANT    ResultMap :  IN ResultMapType := DefaultResultMap
                        ) RETURN std_ulogic IS
        VARIABLE result : UX01;
    BEGIN
        CASE To_X01(dselect) IS
          WHEN '0'    => result := To_UX01(data0);
          WHEN '1'    => result := To_UX01(data1);
          WHEN OTHERS => result := VitalSame( data1, data0 );
        END CASE;
        RETURN ResultMap(result);
    END;    -- {R&R}
--
    FUNCTION VitalMUX4  ( CONSTANT       data :  IN std_logic_vector4;
                          CONSTANT    dselect :  IN std_logic_vector2;
                          CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                        ) RETURN std_ulogic IS
        VARIABLE slct : std_logic_vector2;
        VARIABLE result : UX01;
    BEGIN
        slct := To_X01(dselect);
        CASE slct IS
          WHEN "00"   => result := To_UX01(data(0));
          WHEN "01"   => result := To_UX01(data(1));
          WHEN "10"   => result := To_UX01(data(2));
          WHEN "11"   => result := To_UX01(data(3));
          WHEN "0X"   => result := VitalSame( data(1), data(0) );
          WHEN "1X"   => result := VitalSame( data(2), data(3) );
          WHEN "X0"   => result := VitalSame( data(2), data(0) );
          WHEN "X1"   => result := VitalSame( data(3), data(1) );
          WHEN OTHERS => result := VitalSame( VitalSame(data(3),data(2)),
                                              VitalSame(data(1),data(0)));
        END CASE;
        RETURN ResultMap(result);
    END;    -- {R&R}
--
    FUNCTION VitalMUX8  ( CONSTANT       data :  IN std_logic_vector8;
                          CONSTANT    dselect :  IN std_logic_vector3;
                          CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                        ) RETURN std_ulogic IS
        VARIABLE result : UX01;
    BEGIN
        CASE To_X01(dselect(2)) IS
          WHEN '0'    => result := VitalMux4( data(3 DOWNTO 0), dselect(1 DOWNTO 0));
          WHEN '1'    => result := VitalMux4( data(7 DOWNTO 4), dselect(1 DOWNTO 0));
          WHEN OTHERS => result := VitalSame( VitalMux4( data(3 DOWNTO 0),
                                                         dselect(1 DOWNTO 0) ),
                                              VitalMux4( data(7 DOWNTO 4),
                                                         dselect(1 DOWNTO 0) ) );
        END CASE;
        RETURN ResultMap(result);
    END;    -- {R&R}
--
    FUNCTION VinterMUX    ( CONSTANT data    : IN std_logic_vector;
                            CONSTANT dselect : IN std_logic_vector
                          ) RETURN std_ulogic IS
        CONSTANT smsb      : INTEGER := dselect'LENGTH;
        CONSTANT dmsb_high : INTEGER := data'LENGTH;
        CONSTANT dmsb_low  : INTEGER := data'LENGTH/2;
        ALIAS data_alias    : std_logic_vector (   data'LENGTH DOWNTO 1) IS data;
        ALIAS dselect_alias : std_logic_vector (dselect'LENGTH DOWNTO 1) IS dselect;

        VARIABLE result : UX01;
    BEGIN
        IF dselect'LENGTH = 1 THEN
          result := VitalMux2( data_alias(2), data_alias(1), dselect_alias(1) );
        ELSIF dselect'LENGTH = 2 THEN
          result := VitalMux4( data_alias, dselect_alias );
        ELSIF dselect'LENGTH > 2 THEN
          CASE To_X01(dselect(smsb)) IS
            WHEN '0'    => 
              result := VinterMux( data_alias(dmsb_low  DOWNTO          1),
                                dselect_alias(smsb-1 DOWNTO 1) );
            WHEN '1'    => 
              result := VinterMux( data_alias(dmsb_high DOWNTO dmsb_low+1),
                                dselect_alias(smsb-1 DOWNTO 1) );
            WHEN OTHERS => 
              result := VitalSame( 
                       VinterMux( data_alias(dmsb_low  DOWNTO          1),
                                  dselect_alias(smsb-1 DOWNTO 1) ),
                       VinterMux( data_alias(dmsb_high DOWNTO dmsb_low+1),
                                  dselect_alias(smsb-1 DOWNTO 1) )
                              );
          END CASE;
        ELSE
          result := 'X'; -- dselect'LENGTH < 1
        END IF;
        RETURN result;
    END;    -- {R&R}
--
    FUNCTION VitalMUX   ( CONSTANT       data :  IN std_logic_vector;
                          CONSTANT    dselect :  IN std_logic_vector;
                          CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                        ) RETURN std_ulogic IS
        CONSTANT msb  : INTEGER := 2**dselect'LENGTH;
        VARIABLE ldat : std_logic_vector(msb DOWNTO 1) := (OTHERS=>'X');
        ALIAS data_alias    : std_logic_vector (   data'LENGTH DOWNTO 1) IS data;
        ALIAS dselect_alias : std_logic_vector (dselect'LENGTH DOWNTO 1) IS dselect;
        VARIABLE result : UX01;
    BEGIN
        IF data'LENGTH <= msb THEN
            FOR i IN data'LENGTH DOWNTO 1 LOOP
                ldat(i) := data_alias(i);
            END LOOP;
        ELSE
            FOR i IN msb DOWNTO 1 LOOP
                ldat(i) := data_alias(i);
            END LOOP;
        END IF;
        result := VinterMUX( ldat, dselect_alias );
        RETURN ResultMap(result);
    END;    -- {R&R}

    -- ------------------------------------------------------------------------
    -- Decoder
    --          General Algorithm : 
    --              (a) Result(...) := '0' when (enable = '0') 
    --              (b) Result(data) := '1'; all other subelements = '0'
    --              ... Result array is decending (n-1 downto 0)
    --
    --          DECODERn  .......... n:2**n decoder
    -- ------------------------------------------------------------------------
    FUNCTION VitalDECODER2  ( CONSTANT       data :  IN std_ulogic;
                              CONSTANT     enable :  IN std_ulogic;
                              CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                            ) RETURN std_logic_vector2 IS
        VARIABLE result : std_logic_vector2;
    BEGIN
        result(1) := ResultMap(enable AND (    data));
        result(0) := ResultMap(enable AND (NOT data));
        RETURN result;
    END;
--
    FUNCTION VitalDECODER4  ( CONSTANT       data :  IN std_logic_vector2;
                              CONSTANT     enable :  IN std_ulogic;
                              CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                            ) RETURN std_logic_vector4 IS
        VARIABLE result : std_logic_vector4;
    BEGIN
        result(3) := ResultMap(enable AND (    data(1)) AND (    data(0)));
        result(2) := ResultMap(enable AND (    data(1)) AND (NOT data(0)));
        result(1) := ResultMap(enable AND (NOT data(1)) AND (    data(0)));
        result(0) := ResultMap(enable AND (NOT data(1)) AND (NOT data(0)));
        RETURN result;
    END;    -- {R&R}
--
    FUNCTION VitalDECODER8  ( CONSTANT       data :  IN std_logic_vector3;
                              CONSTANT     enable :  IN std_ulogic;
                              CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                            ) RETURN std_logic_vector8 IS
        VARIABLE result : std_logic_vector8;
    BEGIN
        result(7) := ResultMap(enable AND (    data(2)) AND (    data(1)) AND (    data(0)));
        result(6) := ResultMap(enable AND (    data(2)) AND (    data(1)) AND (NOT data(0)));
        result(5) := ResultMap(enable AND (    data(2)) AND (NOT data(1)) AND (    data(0)));
        result(4) := ResultMap(enable AND (    data(2)) AND (NOT data(1)) AND (NOT data(0)));
        result(3) := ResultMap(enable AND (NOT data(2)) AND (    data(1)) AND (    data(0)));
        result(2) := ResultMap(enable AND (NOT data(2)) AND (    data(1)) AND (NOT data(0)));
        result(1) := ResultMap(enable AND (NOT data(2)) AND (NOT data(1)) AND (    data(0)));
        result(0) := ResultMap(enable AND (NOT data(2)) AND (NOT data(1)) AND (NOT data(0)));
        RETURN result;
    END;    -- {R&R}
--
    FUNCTION VitalDECODER   ( CONSTANT       data :  IN std_logic_vector;
                              CONSTANT     enable :  IN std_ulogic;
                              CONSTANT  ResultMap :  IN ResultMapType := DefaultResultMap
                            ) RETURN std_logic_vector IS
        CONSTANT dmsb : INTEGER := data'LENGTH - 1;
        ALIAS data_a : std_logic_vector ( dmsb DOWNTO 0 ) IS data;
    BEGIN
        IF    data'LENGTH = 1 
          THEN RETURN VitalDECODER2 ( data_a(    0     ), enable, ResultMap );
        ELSIF data'LENGTH = 2
          THEN RETURN VitalDECODER4 ( data_a(1 DOWNTO 0), enable, ResultMap );
        ELSIF data'LENGTH = 3
          THEN RETURN VitalDECODER8 ( data_a(2 DOWNTO 0), enable, ResultMap );
        ELSIF data'LENGTH > 3
          THEN RETURN VitalDECODER  ( data_a(dmsb-1 DOWNTO 0), 
                                      enable AND (    data_a(dmsb)), ResultMap )
                    & VitalDECODER  ( data_a(dmsb-1 DOWNTO 0),
                                      enable AND (NOT data_a(dmsb)), ResultMap );
        ELSE RETURN "X";
        END IF;
    END;    -- {R&R}

    -- ------------------------------------------------------------------------
    -- N-bit wide Logical gates.
    -- ------------------------------------------------------------------------
    PROCEDURE VitalAND   ( SIGNAL            q : OUT std_ulogic;                     
                           SIGNAL         data :  IN std_logic_vector;
                           CONSTANT tpd_data_q :  IN DelayArrayType01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE data_edge :  EdgeArray(data'RANGE);
        VARIABLE data_schd : SchedArray(data'RANGE);
        VARIABLE new_val     : UX01;
        VARIABLE glitch_data : GlitchDataType;
        VARIABLE new_schd    : SchedType;
        VARIABLE dly, glch   : TIME;
        ALIAS atpd_data_q : DelayArrayType01(data'RANGE) IS tpd_data_q;
        VARIABLE all_zero_delay  : BOOLEAN := TRUE; --SN
    BEGIN
      -- ------------------------------------------------------------------------
      --  Check if ALL zero delay paths, use simple model
      --   ( No delay selection, glitch detection required )
      -- ------------------------------------------------------------------------
      FOR i IN data'RANGE LOOP
          IF (atpd_data_q(i) /= ZeroDelay01) THEN
              all_zero_delay := FALSE;
              EXIT;
          END IF;
      END LOOP;
      IF (all_zero_delay) THEN LOOP
          q <= VitalAND(data, ResultMap);
          WAIT ON data;
      END LOOP;
      ELSE
 

        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        FOR n IN data'RANGE LOOP
            BufPath ( data_schd(n), InitialEdge(data(n)), atpd_data_q(n) );
        END LOOP;

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        data_edge := GetEdge ( data, data_edge );
        BufPath ( data_schd, data_edge, atpd_data_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val := '1';
        new_schd := data_schd(data_schd'LEFT);
        FOR i IN data'RANGE LOOP
            new_val  := new_val  AND data(i);
            new_schd := new_schd AND data_schd(i);
        END LOOP;
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;

        WAIT ON data;
      END LOOP;
      END IF; --SN
    END;    -- {R&R}
--
    PROCEDURE VitalOR    ( SIGNAL            q : OUT std_ulogic;                    
                           SIGNAL         data :  IN std_logic_vector;
                           CONSTANT tpd_data_q :  IN DelayArrayType01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE data_edge :  EdgeArray(data'RANGE);
        VARIABLE data_schd : SchedArray(data'RANGE);
        VARIABLE new_val     : UX01;
        VARIABLE glitch_data : GlitchDataType;
        VARIABLE new_schd    : SchedType;
        VARIABLE dly, glch   : TIME;
        ALIAS atpd_data_q : DelayArrayType01(data'RANGE) IS tpd_data_q;
        VARIABLE all_zero_delay  : BOOLEAN := TRUE; --SN
    BEGIN
      -- ------------------------------------------------------------------------       
      --  Check if ALL zero delay paths, use simple model
      --   ( No delay selection, glitch detection required )
      -- ------------------------------------------------------------------------       
      FOR i IN data'RANGE LOOP
          IF (atpd_data_q(i) /= ZeroDelay01) THEN
              all_zero_delay := FALSE;
              EXIT;
          END IF;
      END LOOP;
      IF (all_zero_delay) THEN LOOP
          q <= VitalOR(data, ResultMap);
          WAIT ON data;
      END LOOP;
      ELSE
        

        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        FOR n IN data'RANGE LOOP
            BufPath ( data_schd(n), InitialEdge(data(n)), atpd_data_q(n) );
        END LOOP;

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        data_edge := GetEdge ( data, data_edge );
        BufPath ( data_schd, data_edge, atpd_data_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val := '0';
        new_schd := data_schd(data_schd'LEFT);
        FOR i IN data'RANGE LOOP
            new_val  := new_val  OR data(i);
            new_schd := new_schd OR data_schd(i);
        END LOOP;
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON data;
      END LOOP;
      END IF; --SN
    END;    -- {R&R}
--
    PROCEDURE VitalXOR   ( SIGNAL            q : OUT std_ulogic;           
                           SIGNAL         data :  IN std_logic_vector;
                           CONSTANT tpd_data_q :  IN DelayArrayType01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE data_edge   :  EdgeArray(data'RANGE);
        VARIABLE datab_schd  : SchedArray(1 TO data'LENGTH);
        VARIABLE datai_schd  : SchedArray(1 TO data'LENGTH);
        VARIABLE new_val     : UX01;
        VARIABLE glitch_data : GlitchDataType;
        VARIABLE new_schd    : SchedType;
        VARIABLE dly, glch   : TIME;
        ALIAS atpd_data_q : DelayArrayType01(data'RANGE) IS tpd_data_q;
        ALIAS adatab_schd : SchedArray(data'RANGE) IS datab_schd;
        ALIAS adatai_schd : SchedArray(data'RANGE) IS datai_schd;
        VARIABLE all_zero_delay  : BOOLEAN := TRUE; --SN
    BEGIN
      -- ------------------------------------------------------------------------        
      --  Check if ALL zero delay paths, use simple model
      --   ( No delay selection, glitch detection required )
      -- ------------------------------------------------------------------------
      FOR i IN data'RANGE LOOP
          IF (atpd_data_q(i) /= ZeroDelay01) THEN
              all_zero_delay := FALSE;
              EXIT;
          END IF;
      END LOOP;
      IF (all_zero_delay) THEN LOOP
          q <= VitalXOR(data, ResultMap);
          WAIT ON data;
      END LOOP;
      ELSE

        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        FOR n IN data'RANGE LOOP
            BufPath ( adatab_schd(n), InitialEdge(data(n)), atpd_data_q(n) );
            InvPath ( adatai_schd(n), InitialEdge(data(n)), atpd_data_q(n) );
        END LOOP;

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        data_edge := GetEdge ( data, data_edge );
        BufPath ( datab_schd, data_edge, atpd_data_q );
        InvPath ( datai_schd, data_edge, atpd_data_q );

        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val  := VitalXOR ( data );
        new_schd := VitalXOR ( datab_schd, datai_schd );
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON data;
      END LOOP;
      END IF; --SN
    END;    -- {R&R}
--
    PROCEDURE VitalNAND  ( SIGNAL            q : OUT std_ulogic;                   
                           SIGNAL         data :  IN std_logic_vector;
                           CONSTANT tpd_data_q :  IN DelayArrayType01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE data_edge :  EdgeArray(data'RANGE);
        VARIABLE data_schd : SchedArray(data'RANGE);
        VARIABLE new_val     : UX01;
        VARIABLE glitch_data : GlitchDataType;
        VARIABLE new_schd    : SchedType;
        VARIABLE dly, glch   : TIME;
        ALIAS atpd_data_q : DelayArrayType01(data'RANGE) IS tpd_data_q;
        VARIABLE all_zero_delay  : BOOLEAN := TRUE; --SN
    BEGIN
      -- ------------------------------------------------------------------------
      --  Check if ALL zero delay paths, use simple model
      --   ( No delay selection, glitch detection required )
      -- ------------------------------------------------------------------------
      FOR i IN data'RANGE LOOP
          IF (atpd_data_q(i) /= ZeroDelay01) THEN
              all_zero_delay := FALSE;
              EXIT;
          END IF;
      END LOOP;
      IF (all_zero_delay) THEN LOOP
          q <= VitalNAND(data, ResultMap);
          WAIT ON data;
      END LOOP;
      ELSE

        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        FOR n IN data'RANGE LOOP
            InvPath ( data_schd(n), InitialEdge(data(n)), atpd_data_q(n) );
        END LOOP;

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        data_edge := GetEdge ( data, data_edge );
        InvPath ( data_schd, data_edge, atpd_data_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val := '1';
        new_schd := data_schd(data_schd'LEFT);
        FOR i IN data'RANGE LOOP
            new_val  := new_val  AND data(i);
            new_schd := new_schd AND data_schd(i);
        END LOOP;
        new_val  := NOT new_val;
        new_schd := NOT new_schd;
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON data;
      END LOOP;
      END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalNOR   ( SIGNAL            q : OUT std_ulogic;                  
                           SIGNAL         data :  IN std_logic_vector;
                           CONSTANT tpd_data_q :  IN DelayArrayType01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE data_edge :  EdgeArray(data'RANGE);
        VARIABLE data_schd : SchedArray(data'RANGE);
        VARIABLE new_val     : UX01;
        VARIABLE glitch_data : GlitchDataType;
        VARIABLE new_schd    : SchedType;
        VARIABLE dly, glch   : TIME;
        ALIAS atpd_data_q : DelayArrayType01(data'RANGE) IS tpd_data_q;
        VARIABLE all_zero_delay  : BOOLEAN := TRUE; --SN
    BEGIN
      -- ------------------------------------------------------------------------
      --  Check if ALL zero delay paths, use simple model
      --   ( No delay selection, glitch detection required )
      -- ------------------------------------------------------------------------
      FOR i IN data'RANGE LOOP
          IF (atpd_data_q(i) /= ZeroDelay01) THEN
              all_zero_delay := FALSE;
              EXIT;
          END IF;
      END LOOP;
      IF (all_zero_delay) THEN LOOP
          q <= VitalNOR(data, ResultMap);
          WAIT ON data;
      END LOOP;
      ELSE

        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        FOR n IN data'RANGE LOOP
            InvPath ( data_schd(n), InitialEdge(data(n)), atpd_data_q(n) );
        END LOOP;

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        data_edge := GetEdge ( data, data_edge );
        InvPath ( data_schd, data_edge, atpd_data_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val := '0';
        new_schd := data_schd(data_schd'LEFT);
        FOR i IN data'RANGE LOOP
            new_val  := new_val  OR data(i);
            new_schd := new_schd OR data_schd(i);
        END LOOP;
        new_val  := NOT new_val;
        new_schd := NOT new_schd;
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON data;
      END LOOP;
      END IF; --SN
    END;    -- {R&R}
--
    PROCEDURE VitalXNOR  ( SIGNAL            q : OUT std_ulogic;           
                           SIGNAL         data :  IN std_logic_vector;
                           CONSTANT tpd_data_q :  IN DelayArrayType01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE data_edge   :  EdgeArray(data'RANGE);
        VARIABLE datab_schd  : SchedArray(1 TO data'LENGTH);
        VARIABLE datai_schd  : SchedArray(1 TO data'LENGTH);
        VARIABLE new_val     : UX01;
        VARIABLE glitch_data : GlitchDataType;
        VARIABLE new_schd    : SchedType;
        VARIABLE dly, glch   : TIME;
        ALIAS atpd_data_q : DelayArrayType01(data'RANGE) IS tpd_data_q;
        ALIAS adatab_schd : SchedArray(data'RANGE) IS datab_schd;
        ALIAS adatai_schd : SchedArray(data'RANGE) IS datai_schd;
        VARIABLE all_zero_delay  : BOOLEAN := TRUE; --SN
    BEGIN
      -- ------------------------------------------------------------------------        
      --  Check if ALL zero delay paths, use simple model
      --   ( No delay selection, glitch detection required )
      -- ------------------------------------------------------------------------
      FOR i IN data'RANGE LOOP
          IF (atpd_data_q(i) /= ZeroDelay01) THEN
              all_zero_delay := FALSE;
              EXIT;
          END IF;
      END LOOP;
      IF (all_zero_delay) THEN LOOP
          q <= VitalXNOR(data, ResultMap);
          WAIT ON data;
      END LOOP;
      ELSE

        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        FOR n IN data'RANGE LOOP
            BufPath ( adatab_schd(n), InitialEdge(data(n)), atpd_data_q(n) );
            InvPath ( adatai_schd(n), InitialEdge(data(n)), atpd_data_q(n) );
        END LOOP;

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        data_edge := GetEdge ( data, data_edge );
        BufPath ( datab_schd, data_edge, atpd_data_q );
        InvPath ( datai_schd, data_edge, atpd_data_q );

        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val  := VitalXNOR ( data );
        new_schd := VitalXNOR ( datab_schd, datai_schd );
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON data;
      END LOOP;
      END IF; --SN
    END;    -- {R&R}
--
 
    -- ------------------------------------------------------------------------
    -- Commonly used 2-bit Logical gates.
    -- ------------------------------------------------------------------------
    PROCEDURE VitalAND2  ( SIGNAL            q : OUT std_ulogic;                       
                           SIGNAL         a, b :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE a_schd, b_schd : SchedType;
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
    BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF ((tpd_a_q = ZeroDelay01) AND (tpd_b_q = ZeroDelay01)) THEN
      LOOP
        q <= VitalAND2 ( a, b, ResultMap );
        WAIT ON a, b;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        BufPath ( a_schd, InitialEdge(a), tpd_a_q );
        BufPath ( b_schd, InitialEdge(b), tpd_b_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        BufPath ( a_schd, GetEdge(a), tpd_a_q );
        BufPath ( b_schd, GetEdge(b), tpd_b_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val := a AND b;
        new_schd := a_schd AND b_schd;
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON a, b;
      END LOOP;
    END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalOR2   ( SIGNAL            q : OUT std_ulogic;                      
                           SIGNAL         a, b :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE a_schd, b_schd : SchedType;
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
    BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF ((tpd_a_q = ZeroDelay01) AND (tpd_b_q = ZeroDelay01)) THEN
      LOOP
        q <= VitalOR2 ( a, b, ResultMap );
        WAIT ON a, b;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        BufPath ( a_schd, InitialEdge(a), tpd_a_q );
        BufPath ( b_schd, InitialEdge(b), tpd_b_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        BufPath ( a_schd, GetEdge(a), tpd_a_q );
        BufPath ( b_schd, GetEdge(b), tpd_b_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val := a OR b;
        new_schd := a_schd OR b_schd;
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON a, b;
      END LOOP;
    END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalNAND2 ( SIGNAL            q : OUT std_ulogic;                     
                           SIGNAL         a, b :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE a_schd, b_schd : SchedType;
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
    BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF ((tpd_a_q = ZeroDelay01) AND (tpd_b_q = ZeroDelay01)) THEN
      LOOP
        q <= VitalNAND2 ( a, b, ResultMap );
        WAIT ON a, b;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        InvPath ( a_schd, InitialEdge(a), tpd_a_q );
        InvPath ( b_schd, InitialEdge(b), tpd_b_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        InvPath ( a_schd, GetEdge(a), tpd_a_q );
        InvPath ( b_schd, GetEdge(b), tpd_b_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val := a NAND b;
        new_schd := a_schd NAND b_schd;
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON a, b;
      END LOOP;
    END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalNOR2  ( SIGNAL            q : OUT std_ulogic;                    
                           SIGNAL         a, b :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE a_schd, b_schd : SchedType;
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
    BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF ((tpd_a_q = ZeroDelay01) AND (tpd_b_q = ZeroDelay01)) THEN
      LOOP
        q <= VitalNOR2 ( a, b, ResultMap );
        WAIT ON a, b;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        InvPath ( a_schd, InitialEdge(a), tpd_a_q );
        InvPath ( b_schd, InitialEdge(b), tpd_b_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        InvPath ( a_schd, GetEdge(a), tpd_a_q );
        InvPath ( b_schd, GetEdge(b), tpd_b_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val := a NOR b;
        new_schd := a_schd NOR b_schd;
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON a, b;
      END LOOP;
    END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalXOR2  ( SIGNAL            q : OUT std_ulogic;                       
                           SIGNAL         a, b :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE ab_schd, bb_schd : SchedType;
        VARIABLE ai_schd, bi_schd : SchedType;
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
    BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF ((tpd_a_q = ZeroDelay01) AND (tpd_b_q = ZeroDelay01)) THEN
      LOOP
        q <= VitalXOR2 ( a, b, ResultMap );
        WAIT ON a, b;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        BufPath ( ab_schd, InitialEdge(a), tpd_a_q );
        InvPath ( ai_schd, InitialEdge(a), tpd_a_q );
        BufPath ( bb_schd, InitialEdge(b), tpd_b_q );
        InvPath ( bi_schd, InitialEdge(b), tpd_b_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        BufPath ( ab_schd, GetEdge(a), tpd_a_q );
        InvPath ( ai_schd, GetEdge(a), tpd_a_q );
    
        BufPath ( bb_schd, GetEdge(b), tpd_b_q );
        InvPath ( bi_schd, GetEdge(b), tpd_b_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val  := a XOR b;
        new_schd := VitalXOR2 ( ab_schd,ai_schd, bb_schd,bi_schd );
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;

        WAIT ON a, b;
      END LOOP;
    END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalXNOR2 ( SIGNAL            q : OUT std_ulogic;                      
                           SIGNAL         a, b :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE ab_schd, bb_schd : SchedType;
        VARIABLE ai_schd, bi_schd : SchedType;
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
    BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF ((tpd_a_q = ZeroDelay01) AND (tpd_b_q = ZeroDelay01)) THEN
      LOOP
        q <= VitalXNOR2 ( a, b, ResultMap );
        WAIT ON a, b;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        BufPath ( ab_schd, InitialEdge(a), tpd_a_q );
        InvPath ( ai_schd, InitialEdge(a), tpd_a_q );
        BufPath ( bb_schd, InitialEdge(b), tpd_b_q );
        InvPath ( bi_schd, InitialEdge(b), tpd_b_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        BufPath ( ab_schd, GetEdge(a), tpd_a_q );
        InvPath ( ai_schd, GetEdge(a), tpd_a_q );
    
        BufPath ( bb_schd, GetEdge(b), tpd_b_q );
        InvPath ( bi_schd, GetEdge(b), tpd_b_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val  := NOT (a XOR b);
        new_schd := VitalXNOR2 ( ab_schd,ai_schd, bb_schd,bi_schd );
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON a, b;
      END LOOP;
    END IF;
    END;    -- {R&R}
 
    -- ------------------------------------------------------------------------
    -- Commonly used 3-bit Logical gates.
    -- ------------------------------------------------------------------------
    PROCEDURE VitalAND3  ( SIGNAL            q : OUT std_ulogic;                     
                           SIGNAL      a, b, c :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE a_schd, b_schd, c_schd : SchedType;
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
    BEGIN
--
    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF (     (tpd_a_q = ZeroDelay01) 
         AND (tpd_b_q = ZeroDelay01)
         AND (tpd_c_q = ZeroDelay01)) THEN
      LOOP
        q <= VitalAND3 ( a, b, c, ResultMap );
        WAIT ON a, b, c;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        BufPath ( a_schd, InitialEdge(a), tpd_a_q );
        BufPath ( b_schd, InitialEdge(b), tpd_b_q );
        BufPath ( c_schd, InitialEdge(c), tpd_c_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        BufPath ( a_schd, GetEdge(a), tpd_a_q );
        BufPath ( b_schd, GetEdge(b), tpd_b_q );
        BufPath ( c_schd, GetEdge(c), tpd_c_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val  := a AND b AND c;
        new_schd := a_schd AND b_schd AND c_schd;
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON a, b, c;
      END LOOP;
    END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalOR3   ( SIGNAL            q : OUT std_ulogic;                    
                           SIGNAL      a, b, c :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE a_schd, b_schd, c_schd : SchedType;
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
    BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF (     (tpd_a_q = ZeroDelay01) 
         AND (tpd_b_q = ZeroDelay01)
         AND (tpd_c_q = ZeroDelay01)) THEN
      LOOP
        q <= VitalOR3 ( a, b, c, ResultMap );
        WAIT ON a, b, c;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        BufPath ( a_schd, InitialEdge(a), tpd_a_q );
        BufPath ( b_schd, InitialEdge(b), tpd_b_q );
        BufPath ( c_schd, InitialEdge(c), tpd_c_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        BufPath ( a_schd, GetEdge(a), tpd_a_q );
        BufPath ( b_schd, GetEdge(b), tpd_b_q );
        BufPath ( c_schd, GetEdge(c), tpd_c_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val  := a OR b OR c;
        new_schd := a_schd OR b_schd OR c_schd;
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON a, b, c;
      END LOOP;
    END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalNAND3 ( SIGNAL            q : OUT std_ulogic;                   
                           SIGNAL      a, b, c :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE a_schd, b_schd, c_schd : SchedType;
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
    BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF (     (tpd_a_q = ZeroDelay01) 
         AND (tpd_b_q = ZeroDelay01)
         AND (tpd_c_q = ZeroDelay01)) THEN
      LOOP
        q <= VitalNAND3 ( a, b, c, ResultMap );
        WAIT ON a, b, c;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        InvPath ( a_schd, InitialEdge(a), tpd_a_q );
        InvPath ( b_schd, InitialEdge(b), tpd_b_q );
        InvPath ( c_schd, InitialEdge(c), tpd_c_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        InvPath ( a_schd, GetEdge(a), tpd_a_q );
        InvPath ( b_schd, GetEdge(b), tpd_b_q );
        InvPath ( c_schd, GetEdge(c), tpd_c_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val  := (a AND b) NAND c;
        new_schd := (a_schd AND b_schd) NAND c_schd;
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON a, b, c;
      END LOOP;
    END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalNOR3  ( SIGNAL            q : OUT std_ulogic;                  
                           SIGNAL      a, b, c :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE a_schd, b_schd, c_schd : SchedType;
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
    BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF (     (tpd_a_q = ZeroDelay01) 
         AND (tpd_b_q = ZeroDelay01)
         AND (tpd_c_q = ZeroDelay01)) THEN
      LOOP
        q <= VitalNOR3 ( a, b, c, ResultMap );
        WAIT ON a, b, c;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        InvPath ( a_schd, InitialEdge(a), tpd_a_q );
        InvPath ( b_schd, InitialEdge(b), tpd_b_q );
        InvPath ( c_schd, InitialEdge(c), tpd_c_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        InvPath ( a_schd, GetEdge(a), tpd_a_q );
        InvPath ( b_schd, GetEdge(b), tpd_b_q );
        InvPath ( c_schd, GetEdge(c), tpd_c_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val  := (a OR b) NOR c;
        new_schd := (a_schd OR b_schd) NOR c_schd;
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON a, b, c;
      END LOOP;
    END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalXOR3  ( SIGNAL            q : OUT std_ulogic;                 
                           SIGNAL      a, b, c :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE ab_schd, bb_schd, cb_schd : SchedType;
        VARIABLE ai_schd, bi_schd, ci_schd : SchedType;
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
    BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF (     (tpd_a_q = ZeroDelay01) 
         AND (tpd_b_q = ZeroDelay01)
         AND (tpd_c_q = ZeroDelay01)) THEN
      LOOP
        q <= VitalXOR3 ( a, b, c, ResultMap );
        WAIT ON a, b, c;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        BufPath ( ab_schd, InitialEdge(a), tpd_a_q );
        InvPath ( ai_schd, InitialEdge(a), tpd_a_q );
        BufPath ( bb_schd, InitialEdge(b), tpd_b_q );
        InvPath ( bi_schd, InitialEdge(b), tpd_b_q );
        BufPath ( cb_schd, InitialEdge(c), tpd_c_q );
        InvPath ( ci_schd, InitialEdge(c), tpd_c_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        BufPath ( ab_schd, GetEdge(a), tpd_a_q );
        InvPath ( ai_schd, GetEdge(a), tpd_a_q );
    
        BufPath ( bb_schd, GetEdge(b), tpd_b_q );
        InvPath ( bi_schd, GetEdge(b), tpd_b_q );
    
        BufPath ( cb_schd, GetEdge(c), tpd_c_q );
        InvPath ( ci_schd, GetEdge(c), tpd_c_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val  := a XOR b XOR c;
        new_schd := VitalXOR3 ( ab_schd,ai_schd, bb_schd,bi_schd, cb_schd,ci_schd );
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON a, b, c;
      END LOOP;
    END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalXNOR3 ( SIGNAL            q : OUT std_ulogic;                
                           SIGNAL      a, b, c :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE ab_schd, bb_schd, cb_schd : SchedType;
        VARIABLE ai_schd, bi_schd, ci_schd : SchedType;
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
    BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF (     (tpd_a_q = ZeroDelay01) 
         AND (tpd_b_q = ZeroDelay01)
         AND (tpd_c_q = ZeroDelay01)) THEN
      LOOP
        q <= VitalXNOR3 ( a, b, c, ResultMap );
        WAIT ON a, b, c;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        BufPath ( ab_schd, InitialEdge(a), tpd_a_q );
        InvPath ( ai_schd, InitialEdge(a), tpd_a_q );
        BufPath ( bb_schd, InitialEdge(b), tpd_b_q );
        InvPath ( bi_schd, InitialEdge(b), tpd_b_q );
        BufPath ( cb_schd, InitialEdge(c), tpd_c_q );
        InvPath ( ci_schd, InitialEdge(c), tpd_c_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        BufPath ( ab_schd, GetEdge(a), tpd_a_q );
        InvPath ( ai_schd, GetEdge(a), tpd_a_q );
    
        BufPath ( bb_schd, GetEdge(b), tpd_b_q );
        InvPath ( bi_schd, GetEdge(b), tpd_b_q );
    
        BufPath ( cb_schd, GetEdge(c), tpd_c_q );
        InvPath ( ci_schd, GetEdge(c), tpd_c_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val  := NOT (a XOR b XOR c);
        new_schd := VitalXNOR3 ( ab_schd, ai_schd,
                                 bb_schd, bi_schd,
                                 cb_schd, ci_schd );
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON a, b, c;
      END LOOP;
    END IF;
    END;    -- {R&R}

    -- ------------------------------------------------------------------------
    -- Commonly used 4-bit Logical gates.
    -- ------------------------------------------------------------------------
    PROCEDURE VitalAND4  ( SIGNAL            q : OUT std_ulogic;               
                           SIGNAL   a, b, c, d :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_d_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE a_schd, b_schd, c_schd, d_schd : SchedType;
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
    BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF (     (tpd_a_q = ZeroDelay01) 
         AND (tpd_b_q = ZeroDelay01)
         AND (tpd_c_q = ZeroDelay01)
         AND (tpd_d_q = ZeroDelay01)) THEN
      LOOP
        q <= VitalAND4 ( a, b, c, d, ResultMap );
        WAIT ON a, b, c, d;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        BufPath ( a_schd, InitialEdge(a), tpd_a_q );
        BufPath ( b_schd, InitialEdge(b), tpd_b_q );
        BufPath ( c_schd, InitialEdge(c), tpd_c_q );
        BufPath ( d_schd, InitialEdge(d), tpd_d_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        BufPath ( a_schd, GetEdge(a), tpd_a_q );
        BufPath ( b_schd, GetEdge(b), tpd_b_q );
        BufPath ( c_schd, GetEdge(c), tpd_c_q );
        BufPath ( d_schd, GetEdge(d), tpd_d_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val  := a AND b AND c AND d;
        new_schd := a_schd AND b_schd AND c_schd AND d_schd;
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON a, b, c, d;
      END LOOP;
    END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalOR4   ( SIGNAL            q : OUT std_ulogic;              
                           SIGNAL   a, b, c, d :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_d_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE a_schd, b_schd, c_schd, d_schd : SchedType;
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
    BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF (     (tpd_a_q = ZeroDelay01) 
         AND (tpd_b_q = ZeroDelay01)
         AND (tpd_c_q = ZeroDelay01)
         AND (tpd_d_q = ZeroDelay01)) THEN
      LOOP
        q <= VitalOR4 ( a, b, c, d, ResultMap );
        WAIT ON a, b, c, d;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        BufPath ( a_schd, InitialEdge(a), tpd_a_q );
        BufPath ( b_schd, InitialEdge(b), tpd_b_q );
        BufPath ( c_schd, InitialEdge(c), tpd_c_q );
        BufPath ( d_schd, InitialEdge(d), tpd_d_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        BufPath ( a_schd, GetEdge(a), tpd_a_q );
        BufPath ( b_schd, GetEdge(b), tpd_b_q );
        BufPath ( c_schd, GetEdge(c), tpd_c_q );
        BufPath ( d_schd, GetEdge(d), tpd_d_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val  := a OR b OR c OR d;
        new_schd := a_schd OR b_schd OR c_schd OR d_schd;
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON a, b, c, d;
      END LOOP;
    END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalNAND4 ( SIGNAL            q : OUT std_ulogic;             
                           SIGNAL   a, b, c, d :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_d_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE a_schd, b_schd, c_schd, d_schd : SchedType;
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
    BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF (     (tpd_a_q = ZeroDelay01) 
         AND (tpd_b_q = ZeroDelay01)
         AND (tpd_c_q = ZeroDelay01)
         AND (tpd_d_q = ZeroDelay01)) THEN
      LOOP
        q <= VitalNAND4 ( a, b, c, d, ResultMap );
        WAIT ON a, b, c, d;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        InvPath ( a_schd, InitialEdge(a), tpd_a_q );
        InvPath ( b_schd, InitialEdge(b), tpd_b_q );
        InvPath ( c_schd, InitialEdge(c), tpd_c_q );
        InvPath ( d_schd, InitialEdge(d), tpd_d_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        InvPath ( a_schd, GetEdge(a), tpd_a_q );
        InvPath ( b_schd, GetEdge(b), tpd_b_q );
        InvPath ( c_schd, GetEdge(c), tpd_c_q );
        InvPath ( d_schd, GetEdge(d), tpd_d_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val  := (a AND b) NAND (c AND d);
        new_schd := (a_schd AND b_schd) NAND (c_schd AND d_schd);
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON a, b, c, d;
      END LOOP;
    END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalNOR4  ( SIGNAL            q : OUT std_ulogic;          
                           SIGNAL   a, b, c, d :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_d_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE a_schd, b_schd, c_schd, d_schd : SchedType;
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
    BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF (     (tpd_a_q = ZeroDelay01) 
         AND (tpd_b_q = ZeroDelay01)
         AND (tpd_c_q = ZeroDelay01)
         AND (tpd_d_q = ZeroDelay01)) THEN
      LOOP
        q <= VitalNOR4 ( a, b, c, d, ResultMap );
        WAIT ON a, b, c, d;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        InvPath ( a_schd, InitialEdge(a), tpd_a_q );
        InvPath ( b_schd, InitialEdge(b), tpd_b_q );
        InvPath ( c_schd, InitialEdge(c), tpd_c_q );
        InvPath ( d_schd, InitialEdge(d), tpd_d_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        InvPath ( a_schd, GetEdge(a), tpd_a_q );
        InvPath ( b_schd, GetEdge(b), tpd_b_q );
        InvPath ( c_schd, GetEdge(c), tpd_c_q );
        InvPath ( d_schd, GetEdge(d), tpd_d_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val  := (a OR b) NOR (c OR d);
        new_schd := (a_schd OR b_schd) NOR (c_schd OR d_schd);
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON a, b, c, d;
      END LOOP;
    END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalXOR4  ( SIGNAL            q : OUT std_ulogic;           
                           SIGNAL   a, b, c, d :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_d_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE ab_schd, bb_schd, cb_schd, db_schd : SchedType;
        VARIABLE ai_schd, bi_schd, ci_schd, di_schd : SchedType;
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
    BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF (     (tpd_a_q = ZeroDelay01) 
         AND (tpd_b_q = ZeroDelay01)
         AND (tpd_c_q = ZeroDelay01)
         AND (tpd_d_q = ZeroDelay01)) THEN
      LOOP
        q <= VitalXOR4 ( a, b, c, d, ResultMap );
        WAIT ON a, b, c, d;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        BufPath ( ab_schd, InitialEdge(a), tpd_a_q );
        InvPath ( ai_schd, InitialEdge(a), tpd_a_q );
    
        BufPath ( bb_schd, InitialEdge(b), tpd_b_q );
        InvPath ( bi_schd, InitialEdge(b), tpd_b_q );

        BufPath ( cb_schd, InitialEdge(c), tpd_c_q );
        InvPath ( ci_schd, InitialEdge(c), tpd_c_q );
    
        BufPath ( db_schd, InitialEdge(d), tpd_d_q );
        InvPath ( di_schd, InitialEdge(d), tpd_d_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        BufPath ( ab_schd, GetEdge(a), tpd_a_q );
        InvPath ( ai_schd, GetEdge(a), tpd_a_q );
    
        BufPath ( bb_schd, GetEdge(b), tpd_b_q );
        InvPath ( bi_schd, GetEdge(b), tpd_b_q );

        BufPath ( cb_schd, GetEdge(c), tpd_c_q );
        InvPath ( ci_schd, GetEdge(c), tpd_c_q );
    
        BufPath ( db_schd, GetEdge(d), tpd_d_q );
        InvPath ( di_schd, GetEdge(d), tpd_d_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val  := a XOR b XOR c XOR d;
        new_schd := VitalXOR4 ( ab_schd,ai_schd, bb_schd,bi_schd,
                                cb_schd,ci_schd, db_schd,di_schd );
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON a, b, c, d;
      END LOOP;
    END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalXNOR4 ( SIGNAL            q : OUT std_ulogic;            
                           SIGNAL   a, b, c, d :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_b_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_c_q :  IN DelayType01    := DefDelay01;
                           CONSTANT    tpd_d_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE ab_schd, bb_schd, cb_schd, db_schd : SchedType;
        VARIABLE ai_schd, bi_schd, ci_schd, di_schd : SchedType;
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
    BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF (     (tpd_a_q = ZeroDelay01) 
         AND (tpd_b_q = ZeroDelay01)
         AND (tpd_c_q = ZeroDelay01)
         AND (tpd_d_q = ZeroDelay01)) THEN
      LOOP
        q <= VitalXNOR4 ( a, b, c, d, ResultMap );
        WAIT ON a, b, c, d;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        BufPath ( ab_schd, InitialEdge(a), tpd_a_q );
        InvPath ( ai_schd, InitialEdge(a), tpd_a_q );
    
        BufPath ( bb_schd, InitialEdge(b), tpd_b_q );
        InvPath ( bi_schd, InitialEdge(b), tpd_b_q );
    
        BufPath ( cb_schd, InitialEdge(c), tpd_c_q );
        InvPath ( ci_schd, InitialEdge(c), tpd_c_q );
    
        BufPath ( db_schd, InitialEdge(d), tpd_d_q );
        InvPath ( di_schd, InitialEdge(d), tpd_d_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        BufPath ( ab_schd, GetEdge(a), tpd_a_q );
        InvPath ( ai_schd, GetEdge(a), tpd_a_q );
    
        BufPath ( bb_schd, GetEdge(b), tpd_b_q );
        InvPath ( bi_schd, GetEdge(b), tpd_b_q );
    
        BufPath ( cb_schd, GetEdge(c), tpd_c_q );
        InvPath ( ci_schd, GetEdge(c), tpd_c_q );
    
        BufPath ( db_schd, GetEdge(d), tpd_d_q );
        InvPath ( di_schd, GetEdge(d), tpd_d_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val  := NOT (a XOR b XOR c XOR d);
        new_schd := VitalXNOR4 ( ab_schd,ai_schd, bb_schd,bi_schd,
                                 cb_schd,ci_schd, db_schd,di_schd );
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;
  
        WAIT ON a, b, c, d;
      END LOOP;
    END IF;
    END;    -- {R&R}

    -- ------------------------------------------------------------------------
    -- Buffers
    --   BUF    ....... standard non-inverting buffer
    --   BUFIF0 ....... non-inverting buffer Data passes thru if (Enable = '0')
    --   BUFIF1 ....... non-inverting buffer Data passes thru if (Enable = '1')
    -- ------------------------------------------------------------------------
    PROCEDURE VitalBUF   ( SIGNAL            q : OUT std_ulogic;       
                           SIGNAL            a :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE new_val      : UX01;
        VARIABLE glitch_data  : GlitchDataType;
        VARIABLE dly, glch    : TIME;
    BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF (tpd_a_q = ZeroDelay01) THEN
      LOOP
        q <= ResultMap(To_UX01(a));
        WAIT ON a;
      END LOOP;

    ELSE
      LOOP
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val  := To_UX01(a);     -- convert to forcing strengths
        CASE EdgeType'(GetEdge(a)) IS
          WHEN '1'|'/'|'R'|'r' => dly := tpd_a_q(tr01);
          WHEN '0'|'\'|'F'|'f' => dly := tpd_a_q(tr10);
          WHEN OTHERS          => dly := MINIMUM (tpd_a_q(tr01), tpd_a_q(tr10));
        END CASE;
    
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode );
        END IF;
  
        WAIT ON a;
      END LOOP;
    END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalBUFIF1 ( SIGNAL              q : OUT std_ulogic; 
                            SIGNAL           data :  IN std_ulogic;
                            SIGNAL         enable :  IN std_ulogic;
                            CONSTANT   tpd_data_q :  IN DelayType01    := DefDelay01;
                            CONSTANT tpd_enable_q :  IN DelayType01Z   := DefDelay01Z;
                            CONSTANT    ResultMap :  IN ResultZMapType := DefaultResultZMap
                         ) IS
    VARIABLE new_val        : UX01Z;
    VARIABLE glitch_data    : GlitchDataType;
    VARIABLE d_schd, e1_schd, e0_schd : SchedType;
    VARIABLE dly, glch      : TIME;
  BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF (     (tpd_data_q   = ZeroDelay01 ) 
         AND (tpd_enable_q = ZeroDelay01Z)) THEN
      LOOP
        q <= VITALBufif1( data, enable, ResultMap );
        WAIT ON data, enable;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        BufPath ( d_schd, InitialEdge(data), tpd_data_q );
        BufEnab ( e1_schd, e0_schd, InitialEdge(enable), tpd_enable_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        BufPath ( d_schd, GetEdge(data), tpd_data_q );
        BufEnab ( e1_schd, e0_schd, GetEdge(enable), tpd_enable_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val := VITALBufif1( data, enable );
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), d_schd, e1_schd, e0_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;

        WAIT ON data, enable;
      END LOOP;
    END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalBUFIF0 ( SIGNAL              q : OUT std_ulogic; 
                            SIGNAL           data :  IN std_ulogic;
                            SIGNAL         enable :  IN std_ulogic;
                            CONSTANT   tpd_data_q :  IN DelayType01    := DefDelay01;
                            CONSTANT tpd_enable_q :  IN DelayType01Z   := DefDelay01Z;
                            CONSTANT    ResultMap :  IN ResultZMapType := DefaultResultZMap
                         ) IS
    VARIABLE new_val        : UX01Z;
    VARIABLE glitch_data    : GlitchDataType;
    VARIABLE d_schd, e1_schd, e0_schd : SchedType;
    VARIABLE ne1_schd, ne0_schd : SchedType;
    VARIABLE dly, glch      : TIME;
  BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF (     (tpd_data_q   = ZeroDelay01 ) 
         AND (tpd_enable_q = ZeroDelay01Z)) THEN
      LOOP
        q <= VITALBufif0( data, enable, ResultMap );
        WAIT ON data, enable;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        BufPath ( d_schd, InitialEdge(data), tpd_data_q );
        InvEnab ( e1_schd, e0_schd, InitialEdge(enable), tpd_enable_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        BufPath ( d_schd, GetEdge(data), tpd_data_q );
        InvEnab ( e1_schd, e0_schd, GetEdge(enable), tpd_enable_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val := VITALBufif0( data, enable );
        ne1_schd := NOT e1_schd;
        ne0_schd := NOT e0_schd;
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data),
                        d_schd, ne1_schd, ne0_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;

        WAIT ON data, enable;
      END LOOP;
    END IF;
    END;    -- {R&R}

    PROCEDURE VitalIDENT ( SIGNAL            q : OUT std_ulogic;       
                           SIGNAL            a :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01Z   := DefDelay01Z;
                           CONSTANT  ResultMap :  IN ResultZMapType := DefaultResultZMap
                         ) IS
        SUBTYPE v2 IS std_logic_vector(0 TO 1);
        VARIABLE new_val      : UX01Z;
        VARIABLE glitch_data  : GlitchDataType;
        VARIABLE dly, glch    : TIME;
    BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF (tpd_a_q = ZeroDelay01) THEN
      LOOP
        q <= ResultMap(To_UX01Z(a));
        WAIT ON a;
      END LOOP;

    ELSE
      LOOP
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        CASE v2'(To_X01Z(new_val) & To_X01Z(a)) IS
          WHEN "00"   => dly := tpd_a_q(tr10);
          WHEN "01"   => dly := tpd_a_q(tr01);
          WHEN "0Z"   => dly := tpd_a_q(tr0z);
          WHEN "0X"   => dly := tpd_a_q(tr01);
          WHEN "10"   => dly := tpd_a_q(tr10);
          WHEN "11"   => dly := tpd_a_q(tr01);
          WHEN "1Z"   => dly := tpd_a_q(tr1z);
          WHEN "1X"   => dly := tpd_a_q(tr10);
          WHEN "Z0"   => dly := tpd_a_q(trz0);
          WHEN "Z1"   => dly := tpd_a_q(trz1);
          WHEN "ZZ"   => dly := 0 ns;
          WHEN "ZX"   => dly := MINIMUM (tpd_a_q(trz1), tpd_a_q(trz0));
          WHEN "X0"   => dly := tpd_a_q(tr10);
          WHEN "X1"   => dly := tpd_a_q(tr01);
          WHEN "XZ"   => dly := MINIMUM (tpd_a_q(tr0z), tpd_a_q(tr1z));
          WHEN OTHERS => dly := MINIMUM (tpd_a_q(tr01), tpd_a_q(tr10));
        END CASE;
        new_val  := To_UX01Z(a);
    
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode );
        END IF;
  
        WAIT ON a;
      END LOOP;
    END IF;
    END;    -- {R&R}

    -- ------------------------------------------------------------------------
    -- Invertors
    --   INV    ......... standard inverting buffer
    --   INVIF0 ......... inverting buffer Data passes thru if (Enable = '0')
    --   INVIF1 ......... inverting buffer Data passes thru if (Enable = '1')
    -- ------------------------------------------------------------------------
    PROCEDURE VitalINV   ( SIGNAL            q : OUT std_ulogic;     
                           SIGNAL            a :  IN std_ulogic   ;
                           CONSTANT    tpd_a_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE new_val      : UX01;
        VARIABLE glitch_data  : GlitchDataType;
        VARIABLE new_schd     : SchedType;
        VARIABLE dly, glch    : TIME;
    BEGIN
    IF (tpd_a_q = ZeroDelay01) THEN
      LOOP
        q <= ResultMap(NOT a);
        WAIT ON a;
      END LOOP;

    ELSE
      LOOP
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val  := NOT a;
        CASE EdgeType'(GetEdge(a)) IS
          WHEN '1'|'/'|'R'|'r' => dly := tpd_a_q(tr10);
          WHEN '0'|'\'|'F'|'f' => dly := tpd_a_q(tr01);
          WHEN OTHERS          => dly := MINIMUM (tpd_a_q(tr01), tpd_a_q(tr10));
        END CASE;
    
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode );
        END IF;
  
        WAIT ON a;
      END LOOP;
    END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalINVIF1 ( SIGNAL              q : OUT std_ulogic;
                            SIGNAL           data :  IN std_ulogic;
                            SIGNAL         enable :  IN std_ulogic;
                            CONSTANT   tpd_data_q :  IN DelayType01    := DefDelay01;
                            CONSTANT tpd_enable_q :  IN DelayType01Z   := DefDelay01Z;
                            CONSTANT    ResultMap :  IN ResultZMapType := DefaultResultZMap
                         ) IS
    VARIABLE new_val        : UX01Z;
    VARIABLE new_schd       : SchedType;
    VARIABLE glitch_data    : GlitchDataType;
    VARIABLE d_schd, e1_schd, e0_schd : SchedType;
    VARIABLE dly, glch      : TIME;
  BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF (     (tpd_data_q   = ZeroDelay01 ) 
         AND (tpd_enable_q = ZeroDelay01Z)) THEN
      LOOP
        q <= VitalINVIF1( data, enable, ResultMap );
        WAIT ON data, enable;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        InvPath ( d_schd, InitialEdge(data), tpd_data_q );
        BufEnab ( e1_schd, e0_schd, InitialEdge(enable), tpd_enable_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        InvPath ( d_schd, GetEdge(data), tpd_data_q );
        BufEnab ( e1_schd, e0_schd, GetEdge(enable), tpd_enable_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val := VitalINVIF1( data, enable );
        new_schd := NOT d_schd;
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd, e1_schd, e0_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;

        WAIT ON data, enable;
      END LOOP;
    END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalINVIF0 ( SIGNAL              q : OUT std_ulogic;
                            SIGNAL           data :  IN std_ulogic;
                            SIGNAL         enable :  IN std_ulogic;
                            CONSTANT   tpd_data_q :  IN DelayType01    := DefDelay01;
                            CONSTANT tpd_enable_q :  IN DelayType01Z   := DefDelay01Z;
                            CONSTANT    ResultMap :  IN ResultZMapType := DefaultResultZMap
                         ) IS
    VARIABLE new_val        : UX01Z;
    VARIABLE new_schd       : SchedType;
    VARIABLE glitch_data    : GlitchDataType;
    VARIABLE d_schd, e1_schd, e0_schd : SchedType;
    VARIABLE ne1_schd, ne0_schd : SchedType := DefSchedType;
    VARIABLE dly, glch      : TIME;
  BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF (     (tpd_data_q   = ZeroDelay01 ) 
         AND (tpd_enable_q = ZeroDelay01Z)) THEN
      LOOP
        q <= VitalINVIF0( data, enable, ResultMap );
        WAIT ON data, enable;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        InvPath ( d_schd, InitialEdge(data), tpd_data_q );
        InvEnab ( e1_schd, e0_schd, InitialEdge(enable), tpd_enable_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        InvPath ( d_schd, GetEdge(data), tpd_data_q );
        InvEnab ( e1_schd, e0_schd, GetEdge(enable), tpd_enable_q );
    
        -- ------------------------------------
        -- Compute function and propation delay
        -- ------------------------------------
        new_val := VitalINVIF0( data, enable );
        ne1_schd := NOT e1_schd;
        ne0_schd := NOT e0_schd;
        new_schd := NOT d_schd;
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data),
                        new_schd, ne1_schd, ne0_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;

        WAIT ON data, enable;
      END LOOP;
    END IF;
    END;    -- {R&R}

    -- ------------------------------------------------------------------------
    -- Multiplexor
    --   MUX   .......... result := data(dselect) 
    --   MUX2  .......... 2-input mux; result := data0 when (dselect = '0'), 
    --                                           data1 when (dselect = '1'),
    --                        'X' when (dselect = 'X') and (data0 /= data1)
    --   MUX4  .......... 4-input mux; result := data(dselect)
    --   MUX8  .......... 8-input mux; result := data(dselect)
    -- ------------------------------------------------------------------------
    PROCEDURE VitalMUX2  ( SIGNAL            q : OUT std_ulogic;           
                           SIGNAL       d1, d0 :  IN std_ulogic;
                           SIGNAL         dsel :  IN std_ulogic;
                           CONSTANT   tpd_d1_q :  IN DelayType01    := DefDelay01;
                           CONSTANT   tpd_d0_q :  IN DelayType01    := DefDelay01;
                           CONSTANT tpd_dsel_q :  IN DelayType01    := DefDelay01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
        VARIABLE d1_schd,  d0_schd  : SchedType;
        VARIABLE dsel_bschd, dsel_ischd : SchedType;
        VARIABLE d1_edge, d0_edge, dsel_edge : EdgeType;
    BEGIN

    -- ------------------------------------------------------------------------
    --  For ALL zero delay paths, use simple model 
    --   ( No delay selection, glitch detection required )
    -- ------------------------------------------------------------------------
    IF (     (tpd_d1_q   = ZeroDelay01) 
         AND (tpd_d0_q   = ZeroDelay01) 
         AND (tpd_dsel_q = ZeroDelay01) ) THEN
      LOOP
        q <= VitalMux2 ( d1, d0, dsel, ResultMap );
        WAIT ON d1, d0, dsel;
      END LOOP;

    ELSE
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        BufPath ( d1_schd, InitialEdge(d1), tpd_d1_q );
        BufPath ( d0_schd, InitialEdge(d0), tpd_d0_q );
        BufPath ( dsel_bschd, InitialEdge(dsel), tpd_dsel_q );
        InvPath ( dsel_ischd, InitialEdge(dsel), tpd_dsel_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        BufPath ( d1_schd, GetEdge(d1), tpd_d1_q );
        BufPath ( d0_schd, GetEdge(d0), tpd_d0_q );
        BufPath ( dsel_bschd, GetEdge(dsel), tpd_dsel_q );
        InvPath ( dsel_ischd, GetEdge(dsel), tpd_dsel_q );
    
        -- ------------------------------------
        -- Compute function and propation delaq
        -- ------------------------------------
        new_val  := VitalMux2 ( d1, d0, dsel );
        new_schd := VitalMux2 ( d1_schd, d0_schd, dsel_bschd, dsel_ischd );
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;

        WAIT ON d1, d0, dsel;
      END LOOP;
    END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalMUX4  ( SIGNAL            q : OUT std_ulogic;          
                           SIGNAL         data :  IN std_logic_vector4;
                           SIGNAL         dsel :  IN std_logic_vector2;
                           CONSTANT tpd_data_q :  IN DelayArrayType01;
                           CONSTANT tpd_dsel_q :  IN DelayArrayType01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
        VARIABLE data_schd      : SchedArray4;
        VARIABLE data_edge      : EdgeArray4;
        VARIABLE dsel_edge      : EdgeArray2;
        VARIABLE dsel_bschd     : SchedArray2;
        VARIABLE dsel_ischd     : SchedArray2;
        ALIAS atpd_data_q : DelayArrayType01(data'RANGE) IS tpd_data_q;
        ALIAS atpd_dsel_q : DelayArrayType01(dsel'RANGE) IS tpd_dsel_q;
        VARIABLE all_zero_delay  : BOOLEAN := TRUE; --SN
    BEGIN
      -- ------------------------------------------------------------------------        
      --  Check if ALL zero delay paths, use simple model
      --   ( No delay selection, glitch detection required )
      -- ------------------------------------------------------------------------
      FOR i IN dsel'RANGE LOOP
          IF (atpd_dsel_q(i) /= ZeroDelay01) THEN
              all_zero_delay := FALSE;
              EXIT;
          END IF;
      END LOOP;
      IF (all_zero_delay) then
          FOR i IN data'RANGE LOOP
              IF (atpd_data_q(i) /= ZeroDelay01) THEN
                  all_zero_delay := FALSE;
                  EXIT;
              END IF;
          END LOOP;
 
          IF (all_zero_delay) THEN LOOP
              q <= VitalMUX(data, dsel, ResultMap);
              WAIT ON data, dsel;
          END LOOP;
          END IF;
      ELSE

        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        FOR n IN data'RANGE LOOP
            BufPath ( data_schd(n), InitialEdge(data(n)), atpd_data_q(n) );
        END LOOP;
        FOR n IN dsel'RANGE LOOP
            BufPath ( dsel_bschd(n), InitialEdge(dsel(n)), atpd_dsel_q(n) );
            InvPath ( dsel_ischd(n), InitialEdge(dsel(n)), atpd_dsel_q(n) );
        END LOOP;

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        data_edge := GetEdge ( data, data_edge );
        BufPath ( data_schd, data_edge, atpd_data_q );
    
        dsel_edge := GetEdge ( dsel, dsel_edge );
        BufPath ( dsel_bschd, dsel_edge, atpd_dsel_q );
        InvPath ( dsel_ischd, dsel_edge, atpd_dsel_q );
    
        -- ------------------------------------
        -- Compute function and propation delaq
        -- ------------------------------------
        new_val  := VitalMux4 ( data, dsel );
        new_schd := VitalMux4 ( data_schd, dsel_bschd, dsel_ischd );
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;

        WAIT ON data, dsel;
      END LOOP;
      END IF; --SN
    END;    -- {R&R}

    PROCEDURE VitalMUX8  ( SIGNAL            q : OUT std_ulogic;         
                           SIGNAL         data :  IN std_logic_vector8;
                           SIGNAL         dsel :  IN std_logic_vector3;
                           CONSTANT tpd_data_q :  IN DelayArrayType01;
                           CONSTANT tpd_dsel_q :  IN DelayArrayType01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
        VARIABLE data_schd      : SchedArray8;
        VARIABLE data_edge      : EdgeArray8;
        VARIABLE dsel_edge      : EdgeArray3;
        VARIABLE dsel_bschd     : SchedArray3;
        VARIABLE dsel_ischd     : SchedArray3;
        ALIAS atpd_data_q : DelayArrayType01(data'RANGE) IS tpd_data_q;
        ALIAS atpd_dsel_q : DelayArrayType01(dsel'RANGE) IS tpd_dsel_q;
        VARIABLE all_zero_delay  : BOOLEAN := TRUE; --SN
    BEGIN
      -- ------------------------------------------------------------------------        
      --  Check if ALL zero delay paths, use simple model
      --   ( No delay selection, glitch detection required )
      -- ------------------------------------------------------------------------
      FOR i IN dsel'RANGE LOOP
          IF (atpd_dsel_q(i) /= ZeroDelay01) THEN
              all_zero_delay := FALSE;
              EXIT;
          END IF;
      END LOOP;
      IF (all_zero_delay) then
          FOR i IN data'RANGE LOOP
              IF (atpd_data_q(i) /= ZeroDelay01) THEN
                  all_zero_delay := FALSE;
                  EXIT;
              END IF;
          END LOOP;
 
          IF (all_zero_delay) THEN LOOP
              q <= VitalMUX(data, dsel, ResultMap);
              WAIT ON data, dsel;
          END LOOP;
          END IF;
       ELSE

        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        FOR n IN data'RANGE LOOP
            BufPath ( data_schd(n), InitialEdge(data(n)), atpd_data_q(n) );
        END LOOP;
        FOR n IN dsel'RANGE LOOP
            BufPath ( dsel_bschd(n), InitialEdge(dsel(n)), atpd_dsel_q(n) );
            InvPath ( dsel_ischd(n), InitialEdge(dsel(n)), atpd_dsel_q(n) );
        END LOOP;

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        data_edge := GetEdge ( data, data_edge );
        BufPath ( data_schd, data_edge, atpd_data_q );
    
        dsel_edge := GetEdge ( dsel, dsel_edge );
        BufPath ( dsel_bschd, dsel_edge, atpd_dsel_q );
        InvPath ( dsel_ischd, dsel_edge, atpd_dsel_q );
    
        -- ------------------------------------
        -- Compute function and propation delaq
        -- ------------------------------------
        new_val  := VitalMux8 ( data, dsel );
        new_schd := VitalMux8 ( data_schd, dsel_bschd, dsel_ischd );
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;

        WAIT ON data, dsel;
      END LOOP;
      END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalMUX   ( SIGNAL            q : OUT std_ulogic;            
                           SIGNAL         data :  IN std_logic_vector;
                           SIGNAL         dsel :  IN std_logic_vector;
                           CONSTANT tpd_data_q :  IN DelayArrayType01;
                           CONSTANT tpd_dsel_q :  IN DelayArrayType01;
                           CONSTANT  ResultMap :  IN ResultMapType  := DefaultResultMap
                         ) IS
        VARIABLE new_val        : UX01;
        VARIABLE glitch_data    : GlitchDataType;
        VARIABLE new_schd       : SchedType;
        VARIABLE dly, glch      : TIME;
        VARIABLE data_schd      : SchedArray(data'RANGE);
        VARIABLE data_edge      : EdgeArray(data'RANGE);
        VARIABLE dsel_edge      : EdgeArray(dsel'RANGE);
        VARIABLE dsel_bschd     : SchedArray(dsel'RANGE);
        VARIABLE dsel_ischd     : SchedArray(dsel'RANGE);
        ALIAS atpd_data_q : DelayArrayType01(data'RANGE) IS tpd_data_q;
        ALIAS atpd_dsel_q : DelayArrayType01(dsel'RANGE) IS tpd_dsel_q;
        VARIABLE all_zero_delay  : BOOLEAN := TRUE; --SN
    BEGIN
      -- ------------------------------------------------------------------------        
      --  Check if ALL zero delay paths, use simple model
      --   ( No delay selection, glitch detection required )
      -- ------------------------------------------------------------------------
      FOR i IN dsel'RANGE LOOP
          IF (atpd_dsel_q(i) /= ZeroDelay01) THEN
              all_zero_delay := FALSE;
              EXIT;
          END IF;
      END LOOP;
      IF (all_zero_delay) then
          FOR i IN data'RANGE LOOP
              IF (atpd_data_q(i) /= ZeroDelay01) THEN
                  all_zero_delay := FALSE;
                  EXIT;
              END IF;
          END LOOP;
 
          IF (all_zero_delay) THEN LOOP
              q <= VitalMUX(data, dsel, ResultMap);
              WAIT ON data, dsel;
          END LOOP;
          END IF;
      ELSE

        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        FOR n IN data'RANGE LOOP
            BufPath ( data_schd(n), InitialEdge(data(n)), atpd_data_q(n) );
        END LOOP;
        FOR n IN dsel'RANGE LOOP
            BufPath ( dsel_bschd(n), InitialEdge(dsel(n)), atpd_dsel_q(n) );
            InvPath ( dsel_ischd(n), InitialEdge(dsel(n)), atpd_dsel_q(n) );
        END LOOP;

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        data_edge := GetEdge ( data, data_edge );
        BufPath ( data_schd, data_edge, atpd_data_q );
    
        dsel_edge := GetEdge ( dsel, dsel_edge );
        BufPath ( dsel_bschd, dsel_edge, atpd_dsel_q );
        InvPath ( dsel_ischd, dsel_edge, atpd_dsel_q );
    
        -- ------------------------------------
        -- Compute function and propation delaq
        -- ------------------------------------
        new_val  := VitalMux ( data, dsel );
        new_schd := VitalMux ( data_schd, dsel_bschd, dsel_ischd );
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, ResultMap(new_val), dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, ResultMap(new_val), dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;

        WAIT ON data, dsel;
      END LOOP;
     END IF; --SN
    END;    -- {R&R}

    -- ------------------------------------------------------------------------
    -- Decoder
    --          General Algorithm : 
    --              (a) Result(...) := '0' when (enable = '0') 
    --              (b) Result(data) := '1'; all other subelements = '0'
    --              ... Result array is decending (n-1 downto 0)
    --
    --          DECODERn  .......... n:2**n decoder
    -- Caution: If 'ResultMap' defines other than strength mapping, the
    --          delay selection is not defined.
    -- ------------------------------------------------------------------------
    PROCEDURE VitalDECODER2  ( SIGNAL              q : OUT std_logic_vector2;
                               SIGNAL           data :  IN std_ulogic;
                               SIGNAL         enable :  IN std_ulogic;
                               CONSTANT   tpd_data_q :  IN DelayType01    := DefDelay01;
                               CONSTANT tpd_enable_q :  IN DelayType01    := DefDelay01;
                               CONSTANT    ResultMap :  IN ResultMapType  := DefaultResultMap
                             ) IS
        VARIABLE new_val        : std_logic_vector2;
        VARIABLE glitch_data    : GlitchArray2;
        VARIABLE new_schd       : SchedArray2;
        VARIABLE dly, glch      : TimeArray2;
        VARIABLE enable_schd  : SchedType := DefSchedType;
        VARIABLE data_bschd, data_ischd : SchedType;
    BEGIN
      -- ------------------------------------------------------------------------        
      --  Check if ALL zero delay paths, use simple model
      --   ( No delay selection, glitch detection required )
      -- ------------------------------------------------------------------------       
      IF (tpd_enable_q = ZeroDelay01) and (tpd_data_q = ZeroDelay01) THEN
      LOOP
          q <= VitalDECODER2(data, enable, ResultMap);
          WAIT ON data, enable;
      END LOOP;
      ELSE

        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        BufPath ( data_bschd, InitialEdge(data), tpd_data_q );
        InvPath ( data_ischd, InitialEdge(data), tpd_data_q );
        BufPath ( enable_schd, InitialEdge(enable), tpd_enable_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        BufPath ( data_bschd, GetEdge(data), tpd_data_q );
        InvPath ( data_ischd, GetEdge(data), tpd_data_q );
    
        BufPath ( enable_schd, GetEdge(enable), tpd_enable_q );
    
        -- ------------------------------------
        -- Compute function and propation delaq
        -- ------------------------------------
        new_val  := VitalDECODER2 ( data, enable, ResultMap );
        new_schd := VitalDECODER2 ( data_bschd, data_ischd, enable_schd );
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, new_val, dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, new_val, dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;

        WAIT ON data, enable;
      END LOOP;
      END IF; -- SN
    END;    -- {R&R}
--
    PROCEDURE VitalDECODER4  ( SIGNAL              q : OUT std_logic_vector4;
                               SIGNAL           data :  IN std_logic_vector2;
                               SIGNAL         enable :  IN std_ulogic;
                               CONSTANT   tpd_data_q :  IN DelayArrayType01;
                               CONSTANT tpd_enable_q :  IN DelayType01    := DefDelay01;
                               CONSTANT    ResultMap :  IN ResultMapType  := DefaultResultMap
                             ) IS
        VARIABLE new_val        : std_logic_vector4;
        VARIABLE glitch_data    : GlitchArray4;
        VARIABLE new_schd       : SchedArray4;
        VARIABLE dly, glch      : TimeArray4;
        VARIABLE enable_schd    : SchedType;
        VARIABLE enable_edge    : EdgeType;
        VARIABLE data_edge      : EdgeArray2;
        VARIABLE data_bschd, data_ischd : SchedArray2;
        ALIAS atpd_data_q : DelayArrayType01(data'RANGE) IS tpd_data_q;
        VARIABLE all_zero_delay  : BOOLEAN := TRUE; --SN
    BEGIN
      -- ------------------------------------------------------------------------        
      --  Check if ALL zero delay paths, use simple model
      --   ( No delay selection, glitch detection required )
      -- ------------------------------------------------------------------------
      IF (tpd_enable_q /= ZeroDelay01) THEN
          all_zero_delay := FALSE;
      ELSE
          FOR i IN data'RANGE LOOP
          IF (atpd_data_q(i) /= ZeroDelay01) THEN
              all_zero_delay := FALSE;
              EXIT;
          END IF;
          END LOOP;
      END IF;
      IF (all_zero_delay) THEN LOOP
          q <= VitalDECODER4(data, enable, ResultMap);
          WAIT ON data, enable;
      END LOOP;
      ELSE

        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        FOR n IN data'RANGE LOOP
            BufPath ( data_bschd(n), InitialEdge(data(n)), atpd_data_q(n) );
            InvPath ( data_ischd(n), InitialEdge(data(n)), atpd_data_q(n) );
        END LOOP;
        BufPath ( enable_schd, InitialEdge(enable), tpd_enable_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        data_edge := GetEdge ( data, data_edge );
        BufPath ( data_bschd, data_edge, atpd_data_q );
        InvPath ( data_ischd, data_edge, atpd_data_q );
    
        BufPath ( enable_schd, GetEdge(enable), tpd_enable_q );
    
        -- ------------------------------------
        -- Compute function and propation delaq
        -- ------------------------------------
        new_val  := VitalDECODER4 ( data, enable, ResultMap );
        new_schd := VitalDECODER4 ( data_bschd, data_ischd, enable_schd );
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, new_val, dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, new_val, dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;

        WAIT ON data, enable;
      END LOOP;
      END IF;
    END;    -- {R&R}
--
    PROCEDURE VitalDECODER8  ( SIGNAL              q : OUT std_logic_vector8;
                               SIGNAL           data :  IN std_logic_vector3;
                               SIGNAL         enable :  IN std_ulogic;
                               CONSTANT   tpd_data_q :  IN DelayArrayType01;
                               CONSTANT tpd_enable_q :  IN DelayType01    := DefDelay01;
                               CONSTANT    ResultMap :  IN ResultMapType  := DefaultResultMap
                             ) IS
        VARIABLE new_val        : std_logic_vector8;
        VARIABLE glitch_data    : GlitchArray8;
        VARIABLE new_schd       : SchedArray8;
        VARIABLE dly, glch      : TimeArray8;
        VARIABLE enable_schd    : SchedType;
        VARIABLE enable_edge    : EdgeType;
        VARIABLE data_edge      : EdgeArray3;
        VARIABLE data_bschd, data_ischd : SchedArray3;
        ALIAS atpd_data_q : DelayArrayType01(data'RANGE) IS tpd_data_q;
        VARIABLE all_zero_delay  : BOOLEAN := TRUE; --SN
    BEGIN
      -- ------------------------------------------------------------------------        
      --  Check if ALL zero delay paths, use simple model
      --   ( No delay selection, glitch detection required )
      -- ------------------------------------------------------------------------
      IF (tpd_enable_q /= ZeroDelay01) THEN
          all_zero_delay := FALSE;
      ELSE
          FOR i IN data'RANGE LOOP
          IF (atpd_data_q(i) /= ZeroDelay01) THEN
              all_zero_delay := FALSE;
              EXIT;
          END IF;
          END LOOP;
      END IF;
      IF (all_zero_delay) THEN LOOP
          q <= VitalDECODER(data, enable, ResultMap);
          WAIT ON data, enable;
      END LOOP;
      ELSE

        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        FOR n IN data'RANGE LOOP
            BufPath ( data_bschd(n), InitialEdge(data(n)), atpd_data_q(n) );
            InvPath ( data_ischd(n), InitialEdge(data(n)), atpd_data_q(n) );
        END LOOP;
        BufPath ( enable_schd, InitialEdge(enable), tpd_enable_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        data_edge := GetEdge ( data, data_edge );
        BufPath ( data_bschd, data_edge, atpd_data_q );
        InvPath ( data_ischd, data_edge, atpd_data_q );
    
        BufPath ( enable_schd, GetEdge(enable), tpd_enable_q );
    
        -- ------------------------------------
        -- Compute function and propation delaq
        -- ------------------------------------
        new_val  := VitalDECODER8 ( data, enable, ResultMap );
        new_schd := VitalDECODER8 ( data_bschd, data_ischd, enable_schd );
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, new_val, dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, new_val, dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;

        WAIT ON data, enable;
      END LOOP;
      END IF; --SN
    END;    -- {R&R}
--
    PROCEDURE VitalDECODER   ( SIGNAL              q : OUT std_logic_vector;
                               SIGNAL           data :  IN std_logic_vector;
                               SIGNAL         enable :  IN std_ulogic;
                               CONSTANT   tpd_data_q :  IN DelayArrayType01;
                               CONSTANT tpd_enable_q :  IN DelayType01    := DefDelay01;
                               CONSTANT    ResultMap :  IN ResultMapType  := DefaultResultMap
                             ) IS
        VARIABLE new_val        : std_logic_vector(q'RANGE);
        VARIABLE glitch_data    : GlitchDataArrayType(q'RANGE);
        VARIABLE new_schd       : SchedArray(q'RANGE);
        VARIABLE dly, glch      : TimeArray(q'RANGE);
        VARIABLE enable_schd    : SchedType;
        VARIABLE enable_edge    : EdgeType;
        VARIABLE data_edge      : EdgeArray(data'RANGE);
        VARIABLE data_bschd, data_ischd : SchedArray(data'RANGE);
        ALIAS atpd_data_q : DelayArrayType01(data'RANGE) IS tpd_data_q;
    BEGIN
        -- --------------------------------------
        -- Initialize delay schedules
        -- --------------------------------------
        FOR n IN data'RANGE LOOP
            BufPath ( data_bschd(n), InitialEdge(data(n)), atpd_data_q(n) );
            InvPath ( data_ischd(n), InitialEdge(data(n)), atpd_data_q(n) );
        END LOOP;
        BufPath ( enable_schd, InitialEdge(enable), tpd_enable_q );

      LOOP
        -- --------------------------------------
        -- Process input signals
        --   get edge values
        --   re-evaluate output schedules
        -- --------------------------------------
        data_edge := GetEdge ( data, data_edge );
        BufPath ( data_bschd, data_edge, atpd_data_q );
        InvPath ( data_ischd, data_edge, atpd_data_q );
    
        BufPath ( enable_schd, GetEdge(enable), tpd_enable_q );
    
        -- ------------------------------------
        -- Compute function and propation delaq
        -- ------------------------------------
        new_val  := VitalDECODER ( data, enable, ResultMap );
        new_schd := VitalDECODER ( data_bschd, data_ischd, enable_schd );
    
        -- ------------------------------------------------------
        -- Assign Outputs
        --  get delays to new value and possable glitch
        --  schedule output change with On Event glitch detection
        -- ------------------------------------------------------
        GetSchedDelay ( dly, glch, new_val, CurrentValue(glitch_data), new_schd );
        IF (GlitchDetect = OnEvent) THEN
            VitalGlitchOnEvent ( q, "q", glitch_data, new_val, dly,
                                 PrimGlitchMode, GlitchDelay=>glch );
        ELSE
            VitalGlitchOnDetect ( q, "q", glitch_data, new_val, dly,
                                  PrimGlitchMode, GlitchDelay=>glch );
        END IF;

        WAIT ON data, enable;
      END LOOP;
    END;    -- {R&R}

    -- -------------------------------------------------------------------------------------
    -- PROCEDURE NAME:  VitalTruthTable
    -- FUNCTION  NAME:  VitalTruthTable
    --
    -- PARAMETERS    :  TruthTable - the truth table
    --                  DataIn     - the inputs to the truth table
    -- (procedure only) Result     - the outputs of the truth table
    --
    -- DESCRIPTION   :  This function implements a truth table.
    --                  It is used to find the output of the TruthTable
    --                  corresponding to a given set of inputs.
    --   
    --                  The first dimension of the table is for number of entries in the truth
    --                  table and second dimension is for the number of elements in a row.
    --                  The number of inputs in the row should be Data'LENGTH.
    --
    --                  Elements is a row will be interpreted as
    --                  Input(NumInputs - 1),.., Input(0), Result(NumOutputs - 1),.., Result(0)
    -- 
    --                  This function will return the first matching entry for the given input.
    --                  If for a certain combination of input values, the truth table does not
    --                  specify the result, then the result will be assigned 'X'. 
    -- 
    --                  All inputs will be mapped to the X01 subtype
    -- 
    --                  If the value of Result is not in the range 'X' to 'Z' then an
    --                  error will be reported. Also, the Result is always given either
    --                  as a 0, 1, X or Z value.
    -- 
    --                  The following mapping is used for driving Outputs of Truth/State tables
    --                      X    maps to X
    --                      0    maps to 0
    --                      1    maps to 1
    --                      Z    maps to Z
    --                      -    maps to X
    --
    -- -------------------------------------------------------------------------------------
    FUNCTION VitalTruthTable  ( CONSTANT TruthTable   : IN VitalTruthTableType;
                                CONSTANT DataIn       : IN std_logic_vector
                              ) RETURN std_logic_vector IS

        CONSTANT InputSize        : INTEGER := DataIn'LENGTH;
        CONSTANT OutputSize       : INTEGER := TruthTable'LENGTH(2) - InputSize;
        VARIABLE returnValue      : std_logic_vector(OutputSize - 1 DOWNTO 0) := (OTHERS => 'X');
        -- This needs to be done since the TableLookup arrays must be ascending starting with 0
        VARIABLE TruthTableAlias  : VitalTruthTableType(0 TO (TruthTable'LENGTH(1)-1),
                                                        0 TO (TruthTable'LENGTH(2)-1)) := TruthTable;
        VARIABLE DataInAlias      : std_logic_vector(0 TO InputSize - 1) :=  To_X01(DataIn);
        VARIABLE indx             : INTEGER;
        VARIABLE err              : BOOLEAN := FALSE;
    BEGIN
       -- search through each row of the truth table
       IF OutputSize > 0 THEN
          col_loop: FOR i IN TruthTableAlias'RANGE(1) LOOP  
              -- Check each input element of the entry
              row_loop: FOR j IN 0 TO InputSize LOOP
                  IF (j = inputSize) THEN -- This entry matches
                      -- Return the Result
                        indx := 0;
                        FOR k IN TruthTable'LENGTH(2) - 1 DOWNTO InputSize LOOP
                           TruthOutputX01Z(TruthTableAlias(i,k), returnValue(indx), err);
                           EXIT WHEN err;
                           indx := indx + 1;
                        END LOOP;
                      IF err THEN
                         returnValue := (OTHERS => 'X');
                      END IF;
                      RETURN returnValue;
                  END IF;
                  IF not ValidTruthTableInput(TruthTableAlias(i,j)) THEN
                     ASSERT FALSE
                        REPORT "VitalTruthTable:  " & To_Character(TruthTableAlias(i,j)) & " is an illegal symbol for the input portion of a Truth Table"
                        SEVERITY FAILURE;
                        EXIT col_loop;
                  END IF;
                  EXIT row_loop WHEN not(TruthTableMatch(DataInAlias(j), TruthTableAlias(i, j)));
              END LOOP row_loop;
          END LOOP col_loop;
       ELSE
          ASSERT FALSE
             REPORT "VitalTruthTable:  Input size equal to or larger than width of TruthTable."
             SEVERITY ERROR;
       END IF;
       RETURN returnValue;
    END;

    FUNCTION VitalTruthTable  ( CONSTANT TruthTable   : IN VitalTruthTableType;
                                CONSTANT DataIn       : IN std_logic_vector
                              ) RETURN std_logic IS

       CONSTANT InputSize        : INTEGER := DataIn'LENGTH;
       CONSTANT OutputSize       : INTEGER := TruthTable'LENGTH(2) - InputSize;
       VARIABLE temp_result      : std_logic_vector(OutputSize - 1 DOWNTO 0) := (OTHERS => 'X');
    BEGIN
       IF (OutputSize > 0) THEN
          temp_result := VitalTruthTable(TruthTable, DataIn);
          ASSERT OutputSize = 1
             REPORT "VitalTruthTable:  Truth table output is a vector not a scalar.  Returning LSB (right most bit)"
             SEVERITY ERROR;
          return (temp_result(0));
       ELSE
          ASSERT FALSE
             REPORT "VitalTruthTable:  Input size equal to or larger than width of TruthTable."
             SEVERITY ERROR;
          return 'X';
       END IF;
    END;

    PROCEDURE VitalTruthTable ( CONSTANT TruthTable : IN  VitalTruthTableType;
                                CONSTANT DataIn     : IN  std_logic_vector;
                                SIGNAL   Result     : OUT std_logic_vector
                              ) is
       CONSTANT actreslen    : INTEGER := TruthTable'LENGTH(2) - DataIn'LENGTH;
       CONSTANT finalreslen  : INTEGER := Minimum(actreslen, Result'Length);
       VARIABLE temp_result  : std_logic_vector(actreslen - 1 DOWNTO 0) := (OTHERS => 'X');
       
    BEGIN
       temp_result := VitalTruthTable(TruthTable, DataIn);
       ASSERT (Result'Length <= actreslen)
          REPORT "VitalTruthTable:  Length of parameter Result is larger than the size of the truth table's output."
          SEVERITY ERROR;
       ASSERT (Result'Length >= actreslen)
          REPORT "VitalTruthTable:  Length of parameter Result is smaller than the size of the truth table's output."
          SEVERITY ERROR;
       temp_result(finalreslen - 1 DOWNTO 0) := temp_result(finalreslen - 1 DOWNTO 0);
       Result <= temp_result;
    END;   

    PROCEDURE VitalTruthTable ( CONSTANT TruthTable : IN VitalTruthTableType;
                                CONSTANT DataIn     : IN std_logic_vector;
                                SIGNAL   Result     : OUT std_logic
                              ) is
                              
       CONSTANT actreslen    : INTEGER := TruthTable'LENGTH(2) - DataIn'LENGTH;
       VARIABLE temp_result  : std_logic_vector(actreslen - 1 DOWNTO 0) := (OTHERS => 'X');
       
    BEGIN
       temp_result := VitalTruthTable(TruthTable, DataIn);
       ASSERT (actreslen <= 1)
          REPORT "VitalTruthTable:  Length of parameter Result is smaller than the size of the truth table's output."
          SEVERITY ERROR;
       IF (actreslen >  0) THEN
          Result <= temp_result(0);
       END IF;
    END;   
    
    -- -------------------------------------------------------------------------------------
    -- PROCEDURE NAME:  VitalStateTable
    --
    -- PARAMETERS   :  StateTable         - the state table
    --                 DataIn             - current inputs to the state table
    --                 NumStates          - the number of state variables
    --                 Result             - the current state (which will become the next state)
    --                                    - and the outputs
    --                 PreviousDataIn     - the previous inputs and states 
    --
    -- NOTE          :  PreviousDataIn is a variable that should be declared within a process
    --                  and initialized to Xs.  After that, the user should never assign a value to it.
    --                  It should have a length equal to the NumStates + DataIn'Length
    --
    -- DESCRIPTION   :  non-concurrent implementation of a state machine.    
    --
    --                  The first dimension of the table is the number of entries in the state
    --                  table and second dimension is the number of elements in a row of the table.
    --                  The number of inputs in the row should be DataIn'LENGTH.
    --                  Result should contain the current state (which will become the next state)
    --                  as well as the outputs
    --
    --                  Elements is a row of the table will be interpreted as
    --                  Input(NumInputs-1),.., Input(0), State(NumStates-1), ..., State(0),Output(NumOutputs-1),.., Output(0)
    --
    --                  where State(numStates-1) DOWNTO State(0) represent the present state and
    --                  Output(NumOutputs - 1) DOWNTO Outputs(NumOutputs - NumStates) represent
    --                  the new values of the state variables (i.e. the next state).  Also,
    --                  Output(NumOutputs - NumStates - 1)
    -- 
    --                  This procedure returns the next state and the new outputs when 
    --                  a match is made between the present state and present inputs and the
    --                  state table.  A search is made starting at the top of the state table
    --                  and terminates with the first match.  If no match is found then the
    --                  next state and new outputs are set to all 'X's
    --
    --                  (Asynchronous inputs (i.e. resets and clears) must be handled by placing the 
    --                  corresponding entries at the top of the table. )
    --                  
    --                  All inputs will be mapped to the X01 subtype.
    --
    --                  NOTE:  Edge transitions should not be used as values for the state variables
    --                         in the present state portion of the state table.  The only valid values
    --                         that can be used for the present state portion of the state table are
    --                         'X', '0', '1', 'B', '-'
    -- 
    --                  The following mapping is used for driving Outputs of Truth/State tables
    --                      X    maps to X
    --                      0    maps to 0
    --                      1    maps to 1
    --                      Z    maps to Z
    --                      -    maps to X
    --
    -- -------------------------------------------------------------------------------------
    PROCEDURE VitalStateTable ( CONSTANT StateTable     : IN VitalStateTableType; -- User's StateTable data
                                CONSTANT DataIn         : IN std_logic_vector;    -- Inputs
                                CONSTANT NumStates      : IN Natural;             -- number of states
                                VARIABLE Result         : INOUT std_logic_vector; -- states and outputs
                                VARIABLE PreviousDataIn : INOUT std_logic_vector  -- previous inputs and states
                              ) is

        CONSTANT InputSize                   : INTEGER := DataIn'LENGTH;
        CONSTANT OutputSize                  : INTEGER := StateTable'LENGTH(2) - InputSize - NumStates;
        VARIABLE DataInAlias                 : std_logic_vector(0 TO DataIn'LENGTH - 1) := To_X01(DataIn);
        VARIABLE PrevDataInAlias             : std_logic_vector(0 TO PreviousDataIn'LENGTH - 1) := To_X01(PreviousDataIn);
        VARIABLE ResultAlias                 : std_logic_vector(0 TO Result'LENGTH - 1) := To_X01(Result);
        VARIABLE ExpectedResult              : std_logic_vector(0 TO OutputSize - 1);
        
    BEGIN
       IF (PreviousDataIn'LENGTH < DataIn'LENGTH) THEN
          ASSERT FALSE
             REPORT "VitalStateTable:  PreviousDataIn vector is too short"
             SEVERITY FAILURE;
          ResultAlias := (OTHERS => 'X');
          Result := ResultAlias;
       ELSIF (OutputSize <= 0) THEN
          ASSERT FALSE
             REPORT "VitalStateTable:  Inputs and States combined are larger than state table."
             SEVERITY FAILURE;
          ResultAlias := (OTHERS => 'X');
          Result := ResultAlias;
       ELSE
          ASSERT (Result'Length >= OutputSize)
             REPORT "VitalStateTable:  Length of formal parameter Result less than expected result length."
             SEVERITY ERROR;
          ASSERT (Result'Length <= OutputSize)
             REPORT "VitalStateTable:  Length of formal parameter Result greater than expected result length."
             SEVERITY ERROR;
          ExpectedResult := StateTableLookUp(StateTable, DataInAlias, PrevDataInAlias, NumStates, ResultAlias);
          ResultAlias := (OTHERS => 'X');
          ResultAlias(maximum(0, Result'Length - OutputSize) TO Result'LENGTH - 1) :=
                                    ExpectedResult(maximum(0, OutputSize - Result'LENGTH) TO Outputsize - 1);
          Result := ResultAlias;
          PrevDataInAlias(0 TO InputSize - 1) := DataInAlias;
          PreviousDataIn := PrevDataInAlias;
       END IF;
    END;

    PROCEDURE VitalStateTable ( CONSTANT StateTable     : IN VitalStateTableType; -- User's StateTable data
                                CONSTANT DataIn         : IN std_logic_vector;    -- Inputs
                                VARIABLE Result         : INOUT std_logic;        -- states
                                VARIABLE PreviousDataIn : INOUT std_logic_vector  -- previous inputs and states
                              ) is

       VARIABLE result_alias : std_logic_vector(0 TO 0);

    BEGIN
       result_alias(0) := Result;
       VitalStateTable ( StateTable     => StateTable,
                         DataIn         => DataIn,
                         NumStates      => 1,
                         Result         => result_alias,
                         PreviousDataIn => PreviousDataIn
                       );
       Result := result_alias(0);
    END;
    
    PROCEDURE VitalStateTable ( CONSTANT StateTable : IN VitalStateTableType; -- User's StateTable data
                                SIGNAL   DataIn     : IN std_logic_vector;    -- Inputs
                                CONSTANT NumStates  : IN Natural;             -- number of states
                                SIGNAL   Result     : INOUT std_logic_vector  -- states and outputs
                              ) is
                              
        CONSTANT InputSize      : INTEGER := DataIn'LENGTH;
        CONSTANT OutputSize     : INTEGER := StateTable'LENGTH(2) - InputSize - NumStates;
        VARIABLE PreviousDataIn : std_logic_vector(0 TO DataIn'LENGTH - 1) := (OTHERS => 'X');
        VARIABLE DataInAlias    : std_logic_vector(0 TO DataIn'LENGTH - 1);
        VARIABLE ResultAlias    : std_logic_vector(0 TO Result'LENGTH - 1);
        VARIABLE ExpectedResult : std_logic_vector(0 TO OutputSize - 1);
        
    BEGIN
       IF (OutputSize <= 0) THEN
          ASSERT FALSE
             REPORT "VitalStateTable:  Inputs and States combined are larger than state table."
             SEVERITY FAILURE;
          ResultAlias  := (OTHERS => 'X');
          Result <= ResultAlias;
       ELSE
          ASSERT (Result'Length >= OutputSize)
             REPORT "VitalStateTable:  Length of formal parameter Result less than expected result length."
             SEVERITY ERROR;
          ASSERT (Result'Length <= OutputSize)
             REPORT "VitalStateTable:  Length of formal parameter Result greater than expected result length."
             SEVERITY ERROR;
          LOOP
             DataInAlias := To_X01(DataIn);
             ResultAlias := To_X01(Result);
             ExpectedResult := StateTableLookUp(StateTable, DataInAlias, PreviousDataIn, NumStates, ResultAlias);
             ResultAlias := (OTHERS => 'X');
             ResultAlias(maximum(0, Result'Length - OutputSize) TO Result'LENGTH - 1) :=
                                       ExpectedResult(maximum(0, OutputSize - Result'LENGTH) TO Outputsize - 1);
             Result <= ResultAlias;
             PreviousDataIn := DataInAlias;
             WAIT ON DataIn;
          END LOOP;
       END IF;
    END;

    PROCEDURE VitalStateTable ( CONSTANT StateTable : IN VitalStateTableType; -- User's StateTable data
                                SIGNAL   DataIn     : IN std_logic_vector;    -- Inputs
                                SIGNAL   Result     : INOUT std_logic         -- states and outputs
                              ) is
        CONSTANT InputSize      : INTEGER := DataIn'LENGTH;
        CONSTANT OutputSize     : INTEGER := StateTable'LENGTH(2) - InputSize - 1;
        VARIABLE PreviousDataIn : std_logic_vector(0 TO DataIn'LENGTH - 1) := (OTHERS => 'X');
        VARIABLE DataInAlias    : std_logic_vector(0 TO DataIn'LENGTH - 1);
        VARIABLE ResultAlias    : std_logic_vector(0 TO 0);
        VARIABLE ExpectedResult : std_logic_vector(0 TO OutputSize - 1);
        
    BEGIN
       IF (OutputSize <= 0) THEN
          ASSERT FALSE
             REPORT "VitalStateTable:  Inputs and States combined are larger than state table."
             SEVERITY FAILURE;
          Result <= 'X';
       ELSE
          ASSERT (1 = OutputSize)
             REPORT "VitalStateTable:  expected result is a vector but this procedure only has a scalar result."
             SEVERITY ERROR;
          LOOP
             DataInAlias := To_X01(DataIn);
             ResultAlias(0) := To_X01(Result);
             ExpectedResult := StateTableLookUp(StateTable, DataInAlias, PreviousDataIn, 1, ResultAlias);
             Result <= ExpectedResult(OutputSize - 1);
             PreviousDataIn := DataInAlias;
             WAIT ON DataIn;
          END LOOP;
       END IF;
    END;

END VITAL_PRIMITIVES;
