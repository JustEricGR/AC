-- ----------------------------------------------------------------------------
--
--  Copyright (c) Mentor Graphics Corporation, 1982-1996, All Rights Reserved.
--                       UNPUBLISHED, LICENSED SOFTWARE.
--            CONFIDENTIAL AND PROPRIETARY INFORMATION WHICH IS THE
--          PROPERTY OF MENTOR GRAPHICS CORPORATION OR ITS LICENSORS.
--
--
-- PackageName : std_mempak (stand alone)
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
--     v1.110   | mkd        |  03/06/92  | production release
--     v1.200   | mkd        |  04/21/92  | stand alone version
--     v1.300   | mkd        |  08/03/92  | production release
--     v1.310   | wrm        |  10/05/92  | modification to work around synopsys problems
--              |            |            | fix bug in mem_load's parser's error-handler
--     v1.400   | mkd        |  11/06/92  | production release
--     v1.500   | mkd        |  11/17/92  | production release
--     v1.600   | mkd        |  02/11/93  | production release v1.6
--     v1.61    | wrm        |  04/14/93  | production release - no change from v1.60
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

PACKAGE std_mempak is

 -- ************************************************************************
 -- Display Banner
 -- ************************************************************************
    CONSTANT StdMempakBanner : BOOLEAN;

    -- 2d array to store data for each row
    type row_matrix  is array (NATURAL RANGE <>, NATURAL RANGE <>) of UX01;
    type rowptr_type is access row_matrix;
    -- record for for storing refresh and memory ptr for each row
    type row_data_type is
        record
            last_refresh : time;                -- last time row was refreshed
            rowptr       : rowptr_type;         -- ptr to 2d matrix with data
            all_xs       : BOOLEAN;             -- true if row is filled with Xs
        end record;
    -- array of refresh times and memory ptrs for the rows
    type row_data is array (NATURAL RANGE <>) of row_data_type;
    type row_data_ptr_type is access row_data;
    type strptr is access string;
    type default_ptr_type is access std_logic_vector;
    type mem_type is (VRAM, DRAM, SRAM, ROM);   -- memory types
    -- for use in partioning rows in VRAMs
    type segment_type is (QUARTER1, QUARTER2, QUARTER3, QUARTER4, LOWER_HALF, UPPER_HALF, FULL);
    -- for use in partioning SAM in VRAMs
    subtype sam_segment_type is segment_type RANGE LOWER_HALF to FULL;
    
    -- record defining memory and holding general information

    type mem_id_rtype is

        record
            memory_type    : mem_type;            -- memory type
            refresh_period : time;                -- refresh period
            last_init      : time;                -- last time a refresh was performed
            counter        : NATURAL;             -- refresh counter
            name           : strptr;              -- pointer to memory name
            rows           : POSITIVE;            -- # of rows
            columns        : POSITIVE;            -- # of columns
            width          : POSITIVE;            -- # word length
            length         : POSITIVE;            -- # of memory locations
            row_data_ptr   : row_data_ptr_type;   -- ptr to memory ptrs.
            default        : default_ptr_type;    -- ptr to default memory word value
            sam_columns    : POSITIVE;            -- # of columns (words) in the SAM (for VRAMs)
            sam_lower_tap  : NATURAL;             -- tap address of lower half of SAM
            sam_upper_tap  : NATURAL;             -- tap address of upper half of SAM
            serial_ptr     : NATURAL;             -- serial datapointer of SAM
            wpb_mask       : default_ptr_type;    -- pointer to write per bit mask (for VRAMs)
            block_size     : POSITIVE;            -- max. # of written during a block write
            sam_data       : rowptr_type;         -- point to 2D array holding SAM data
        end record;

    type mem_id_type is access mem_id_rtype;


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

    Procedure Mem_Row_Refresh (  Variable mem_id     :  INOUT mem_id_type;
                                 Constant row        :  NATURAL
                              );

    Procedure Mem_Row_Refresh (  Variable mem_id     :  INOUT mem_id_type;
                                 Constant row        :  bit_vector
                              );

    Procedure Mem_Row_Refresh (  Variable mem_id     :  INOUT mem_id_type;
                                 Constant row        :  std_logic_vector
                              );
    
    Procedure Mem_Row_Refresh (  Variable mem_id     :  INOUT mem_id_type;
                                 Constant row        :  std_ulogic_vector
                              );

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
                             ) return mem_id_type;

    Function DRAM_Initialize ( Constant name            : IN string;
                               Constant rows            : IN POSITIVE;
                               Constant columns         : IN POSITIVE;
                               Constant width           : IN POSITIVE;
                               Constant refresh_period  : IN TIME;
                               Constant default_word    : IN std_ulogic_vector
                             ) return mem_id_type;

    Function DRAM_Initialize ( Constant name            : IN string;
                               Constant rows            : IN POSITIVE;
                               Constant columns         : IN POSITIVE;
                               Constant width           : IN POSITIVE;
                               Constant refresh_period  : IN TIME;
                               Constant default_word    : IN bit_vector
                             ) return mem_id_type;

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
                             ) return mem_id_type;

    Function SRAM_Initialize (  Constant name            : IN string;
                                Constant length          : IN POSITIVE;
                                Constant width           : IN POSITIVE;
                                Constant default_word    : IN std_ulogic_vector
                              ) return mem_id_type;

    Function SRAM_Initialize (  Constant name            : IN string;
                                Constant length          : IN POSITIVE;
                                Constant width           : IN POSITIVE;
                                Constant default_word    : IN bit_vector
                              ) return mem_id_type;

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

    Procedure Mem_Wake_Up (Variable mem_id     : INOUT mem_id_type);

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
                       );
    
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
                             ) return mem_id_type;

    Function ROM_Initialize (  Constant name            : IN string;
                               Constant length          : IN POSITIVE;
                               Constant width           : IN POSITIVE;
                               Constant default_word    : IN std_ulogic_vector;
                               Constant file_name       : IN string := ""
                             ) return mem_id_type;

    Function ROM_Initialize (  Constant name            : IN string;
                               Constant length          : IN POSITIVE;
                               Constant width           : IN POSITIVE;
                               Constant default_word    : IN bit_vector;
                               Constant file_name       : IN string := ""
                             ) return mem_id_type;

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
                       );

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
                         );

    procedure  Mem_Reset ( Variable mem_id          : INOUT mem_id_type;
                           Constant reset_value     : IN std_ulogic_vector;
                           Constant start_addr      : IN NATURAL := 0;
                           Constant end_addr        : IN NATURAL := integer'high
                         );
                         
    procedure  Mem_Reset ( Variable mem_id          : INOUT mem_id_type;
                           Constant reset_value     : IN bit_vector;
                           Constant start_addr      : IN NATURAL := 0;
                           Constant end_addr        : IN NATURAL := integer'high
                         );

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
                       );

    Procedure Mem_Read (  Variable mem_id    : INOUT mem_id_type;
                          Constant address   : IN NATURAL;
                          Variable data      : OUT bit
                       );

    Procedure Mem_Read (  Variable mem_id    : INOUT mem_id_type;
                          Constant address   : IN bit_vector;
                          Variable data      : OUT bit
                       );

    Procedure Mem_Read (  Variable mem_id    : INOUT mem_id_type;
                          Constant address   : IN std_logic_vector;
                          Variable data      : OUT std_ulogic
                       );

    Procedure Mem_Read (  Variable mem_id    : INOUT mem_id_type;
                          Constant address   : IN std_ulogic_vector;
                          Variable data      : OUT std_ulogic
                       );

    Procedure Mem_Read (  Variable mem_id    : INOUT mem_id_type;
                          Constant address   : IN NATURAL;
                          Variable data      : OUT bit_vector
                       );

    Procedure Mem_Read (  Variable mem_id    : INOUT mem_id_type;
                          Constant address   : IN NATURAL;
                          Variable data      : OUT std_logic_vector
                       );

    Procedure Mem_Read (  Variable mem_id    : INOUT mem_id_type;
                          Constant address   : IN NATURAL;
                          Variable data      : OUT std_ulogic_vector
                       );

    Procedure Mem_Read (  Variable mem_id    : INOUT mem_id_type;
                          Constant address   : IN bit_vector;
                          Variable data      : OUT bit_vector
                       );
                       
    Procedure Mem_Read (  Variable mem_id    : INOUT mem_id_type;
                          Constant address   : IN std_logic_vector;
                          Variable data      : OUT std_logic_vector
                       );
    Procedure Mem_Read (  Variable mem_id    : INOUT mem_id_type;
                          Constant address   : IN std_ulogic_vector;
                          Variable data      : OUT std_ulogic_vector
                       );
                       
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
                        );

    Procedure Mem_Write (  Variable mem_id        : INOUT mem_id_type;
                           Constant address       : IN NATURAL;
                           Constant data          : IN bit;
                           Constant write_per_bit : IN BOOLEAN := FALSE
                        );
                      
    Procedure Mem_Write (  Variable mem_id        : INOUT mem_id_type;
                           Constant address       : IN bit_vector;
                           Constant data          : IN bit;
                           Constant write_per_bit : IN BOOLEAN := FALSE
                        );

    Procedure Mem_Write (  Variable mem_id        : INOUT mem_id_type;
                           Constant address       : IN std_logic_vector;
                           Constant data          : IN std_ulogic;
                           Constant write_per_bit : IN BOOLEAN := FALSE
                        );

    Procedure Mem_Write (  Variable mem_id        : INOUT mem_id_type;
                           Constant address       : IN std_ulogic_vector;
                           Constant data          : IN std_ulogic;
                           Constant write_per_bit : IN BOOLEAN := FALSE
                        );
                        
    Procedure Mem_Write (  Variable mem_id        : INOUT mem_id_type;
                           Constant address       : IN NATURAL;
                           Constant data          : IN bit_vector;
                           Constant write_per_bit : IN BOOLEAN := FALSE
                        );

    Procedure Mem_Write (  Variable mem_id        : INOUT mem_id_type;
                           Constant address       : IN NATURAL;
                           Constant data          : IN std_logic_vector;
                           Constant write_per_bit : IN BOOLEAN := FALSE
                        );
                        
    Procedure Mem_Write (  Variable mem_id        : INOUT mem_id_type;
                           Constant address       : IN NATURAL;
                           Constant data          : IN std_ulogic_vector;
                           Constant write_per_bit : IN BOOLEAN := FALSE
                        );
                        
    Procedure Mem_Write (  Variable mem_id        : INOUT mem_id_type;
                           Constant address       : IN std_logic_vector;
                           Constant data          : IN std_logic_vector;
                           Constant write_per_bit : IN BOOLEAN := FALSE
                        );

    Procedure Mem_Write (  Variable mem_id        : INOUT mem_id_type;
                           Constant address       : IN std_ulogic_vector;
                           Constant data          : IN std_ulogic_vector;
                           Constant write_per_bit : IN BOOLEAN := FALSE
                        );
                        
    Procedure Mem_Write (  Variable mem_id        : INOUT mem_id_type;
                           Constant address       : IN bit_vector;
                           Constant data          : IN bit_vector;
                           Constant write_per_bit : IN BOOLEAN := FALSE
                        );

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

    Procedure Mem_Refresh (  Variable mem_id : INOUT mem_id_type);

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
                        );
                        
    Procedure Mem_Valid ( Variable mem_id     :  INOUT mem_id_type;
                          Constant address    :  IN bit_vector;
                          Variable DataValid  :  OUT BOOLEAN
                        );
                        
    Procedure Mem_Valid ( Variable mem_id     :  INOUT mem_id_type;
                          Constant address    :  IN std_logic_vector;
                          Variable DataValid  :  OUT BOOLEAN
                        );
                        
    Procedure Mem_Valid ( Variable mem_id     :  INOUT  mem_id_type;
                          Constant address    :  IN std_ulogic_vector;
                          Variable DataValid  :  OUT BOOLEAN
                        );
                                                                         
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
                         );

    Procedure Mem_Access (  Variable mem_id    : INOUT mem_id_type;
                            Constant address   : IN NATURAL;
                            Variable data      : OUT bit
                         );

    Procedure Mem_Access (  Variable mem_id    : INOUT mem_id_type;
                            Constant address   : IN bit_vector;
                            Variable data      : OUT bit
                         );

    Procedure Mem_Access (  Variable mem_id    : INOUT mem_id_type;
                            Constant address   : IN std_logic_vector;
                            Variable data      : OUT std_ulogic
                         );

    Procedure Mem_Access (  Variable mem_id    : INOUT mem_id_type;
                            Constant address   : IN std_ulogic_vector;
                            Variable data      : OUT std_ulogic
                         );

    Procedure Mem_Access (  Variable mem_id    : INOUT mem_id_type;
                            Constant address   : IN NATURAL;
                            Variable data      : OUT bit_vector
                         );

    Procedure Mem_Access (  Variable mem_id    : INOUT mem_id_type;
                            Constant address   : IN NATURAL;
                            Variable data      : OUT std_logic_vector
                         );

    Procedure Mem_Access (  Variable mem_id    : INOUT mem_id_type;
                            Constant address   : IN NATURAL;
                            Variable data      : OUT std_ulogic_vector
                         );

    Procedure Mem_Access (  Variable mem_id    : INOUT mem_id_type;
                            Constant address   : IN bit_vector;
                            Variable data      : OUT bit_vector
                         );
                       
    Procedure Mem_Access (  Variable mem_id    : INOUT mem_id_type;
                            Constant address   : IN std_logic_vector;
                            Variable data      : OUT std_logic_vector
                         );
                       
    Procedure Mem_Access (  Variable mem_id    : INOUT mem_id_type;
                            Constant address   : IN std_ulogic_vector;
                            Variable data      : OUT std_ulogic_vector
                         );
                       
    --------------------------------------------------------------------------------
    -- ************************************************************************** --
    --------------------------------------------------------------------------------
    -- Video RAM Procedures
    --------------------------------------------------------------------------------
    -- ************************************************************************** --
    --------------------------------------------------------------------------------

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
                             ) return mem_id_type;

    Function VRAM_Initialize ( Constant name            : IN string;
                               Constant rows            : IN POSITIVE;
                               Constant columns         : IN POSITIVE;
                               Constant width           : IN POSITIVE;
                               Constant sam_columns     : IN POSITIVE;
                               Constant block_size      : IN POSITIVE := 1;
                               Constant refresh_period  : IN TIME;
                               Constant default_word    : IN std_ulogic_vector
                             ) return mem_id_type;

    Function VRAM_Initialize ( Constant name            : IN string;
                               Constant rows            : IN POSITIVE;
                               Constant columns         : IN POSITIVE;
                               Constant width           : IN POSITIVE;
                               Constant sam_columns     : IN POSITIVE;
                               Constant block_size      : IN POSITIVE := 1;
                               Constant refresh_period  : IN TIME;
                               Constant default_word    : IN bit_vector
                             ) return mem_id_type;

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
                               );

    Procedure Mem_Set_WPB_Mask ( Variable mem_id : INOUT mem_id_type;
                                 Constant mask   : IN std_ulogic_vector
                               );
    
    Procedure Mem_Set_WPB_Mask ( Variable mem_id : INOUT mem_id_type;
                                 Constant mask   : IN bit_vector
                               );

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
                              );

    Procedure Mem_Block_Write ( Variable mem_id        : INOUT mem_id_type;
                                Constant address       : IN NATURAL;
                                Constant data          : IN std_ulogic_vector;
                                Constant column_mask   : IN std_ulogic_vector := "";
                                Constant write_per_bit : IN BOOLEAN := FALSE
                              );
                                                    
    Procedure Mem_Block_Write ( Variable mem_id        : INOUT mem_id_type;
                                Constant address       : IN std_logic_vector;
                                Constant data          : IN std_logic_vector;
                                Constant column_mask   : IN std_logic_vector := "";
                                Constant write_per_bit : IN BOOLEAN := FALSE
                              );
                          
   Procedure Mem_Block_Write ( Variable mem_id        : INOUT mem_id_type;
                               Constant address       : IN std_ulogic_vector;
                               Constant data          : IN std_ulogic_vector;
                               Constant column_mask   : IN std_ulogic_vector := "";
                               Constant write_per_bit : IN BOOLEAN := FALSE
                             );

   Procedure Mem_Block_Write ( Variable mem_id        : INOUT mem_id_type;
                               Constant address       : IN NATURAL;
                               Constant data          : IN bit_vector;
                               Constant column_mask   : IN bit_vector := "";
                               Constant write_per_bit : IN BOOLEAN := FALSE
                             );

   Procedure Mem_Block_Write ( Variable mem_id        : INOUT mem_id_type;
                               Constant address       : IN bit_vector;
                               Constant data          : IN bit_vector;
                               Constant column_mask   : IN bit_vector := "";
                               Constant write_per_bit : IN BOOLEAN := FALSE
                             );


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
                           );

   Procedure Mem_Row_Write ( Variable mem_id        : INOUT mem_id_type;
                             Constant row           : IN Natural;
                             Constant data          : IN std_ulogic;
                             Constant write_per_bit : IN BOOLEAN := FALSE
                           );

   Procedure Mem_Row_Write ( Variable mem_id        : INOUT mem_id_type;
                             Constant row           : Natural;
                             Constant data          : std_ulogic_vector;
                             Constant write_per_bit : IN BOOLEAN := FALSE
                           );

   Procedure Mem_Row_Write ( Variable mem_id        : INOUT mem_id_type;
                             Constant row           : std_logic_vector;
                             Constant data          : std_logic_vector;
                             Constant write_per_bit : IN BOOLEAN := FALSE
                           );

   Procedure Mem_Row_Write ( Variable mem_id        : INOUT mem_id_type;
                              Constant row           : std_ulogic_vector;
                              Constant data          : std_ulogic_vector;
                              Constant write_per_bit : IN BOOLEAN := FALSE
                           );

   Procedure Mem_Row_Write ( Variable mem_id        : INOUT mem_id_type;
                             Constant row           : NATURAL;
                             Constant data          : bit_vector;
                             Constant write_per_bit : IN BOOLEAN := FALSE
                           );

   Procedure Mem_Row_Write ( Variable mem_id        : INOUT mem_id_type;
                             Constant row           : bit_vector;
                             Constant data          : bit_vector;
                             Constant write_per_bit : IN BOOLEAN := FALSE
                           );

   Procedure Mem_Row_Write ( Variable mem_id        : INOUT mem_id_type;
                             Constant row           : NATURAL;
                             Constant data          : bit;
                             Constant write_per_bit : IN BOOLEAN := FALSE
                           );

   Procedure Mem_Row_Write ( Variable mem_id        : INOUT mem_id_type;
                             Constant row           : bit_vector;
                             Constant data          : bit;
                             Constant write_per_bit : IN BOOLEAN := FALSE
                           );
                         
   Procedure Mem_Row_Write ( Variable mem_id        : INOUT mem_id_type;
                             Constant row           : std_logic_vector;
                             Constant data          : std_ulogic;
                             Constant write_per_bit : IN BOOLEAN := FALSE
                           );

   Procedure Mem_Row_Write ( Variable mem_id        : INOUT mem_id_type;
                             Constant row           : std_ulogic_vector;
                             Constant data          : std_ulogic;
                             Constant write_per_bit : IN BOOLEAN := FALSE
                          );

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
    --                       Seiral_Ptr set serial ptr and tap address of the
    --                       appropriate SAM segment.
    --
    ---------------------------------------------------------------------------
   

   Procedure Mem_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                           Constant row         : IN NATURAL;
                           Constant Serial_Ptr  : IN NATURAL;
                           Constant row_segment : IN segment_type := FULL
                         );
                               
   Procedure Mem_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                           Constant row         : NATURAL;
                           Constant Serial_Ptr  : IN std_logic_vector;
                           Constant row_segment : IN segment_type := FULL
                         );

   Procedure Mem_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                           Constant row         : IN std_logic_vector;
                           Constant Serial_Ptr  : IN NATURAL;
                           Constant row_segment : IN segment_type := FULL
                         );

   Procedure Mem_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                           Constant row         : IN std_logic_vector;
                           Constant Serial_Ptr  : IN std_logic_vector;
                           Constant row_segment : IN segment_type := FULL
                         );

   Procedure Mem_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                           Constant row         : IN NATURAL;
                           Constant Serial_Ptr  : IN std_ulogic_vector;
                           Constant row_segment : IN segment_type := FULL
                         );

   Procedure Mem_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                           Constant row         : IN std_ulogic_vector;
                           Constant Serial_Ptr  : IN NATURAL;
                           Constant row_segment : IN segment_type := FULL
                         );

   Procedure Mem_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                           Constant row         : IN std_ulogic_vector;
                           Constant Serial_Ptr  : IN std_ulogic_vector;
                           Constant row_segment : IN segment_type := FULL
                         );

   Procedure Mem_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                           Constant row         : IN NATURAL;
                           Constant Serial_Ptr  : IN bit_vector;
                           Constant row_segment : IN segment_type := FULL
                         );
                         
   Procedure Mem_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                           Constant row         : IN bit_vector;
                           Constant Serial_Ptr  : IN NATURAL;
                           Constant row_segment : IN segment_type := FULL
                         );

   Procedure Mem_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                           Constant row         : IN bit_vector;
                           Constant Serial_Ptr  : IN bit_vector;
                           Constant row_segment : IN segment_type := FULL
                         );

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
                               );

   Procedure Mem_Split_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                                 Constant row         : IN std_logic_vector;
                                 Constant tap         : IN NATURAL;
                                 Constant row_segment : IN segment_type := FULL;
                                 Constant sam_segment : IN sam_segment_type
                               );

   Procedure Mem_Split_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                                 Constant row         : IN NATURAL;
                                 Constant tap         : IN std_logic_vector;
                                 Constant row_segment : IN segment_type := FULL;
                                 Constant sam_segment : IN sam_segment_type
                               );

   Procedure Mem_Split_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                                 Constant row         : IN std_logic_vector;
                                 Constant tap         : IN std_logic_vector;
                                 Constant row_segment : IN segment_type := FULL;
                                 Constant sam_segment : IN sam_segment_type
                               );

   Procedure Mem_Split_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                                 Constant row         : IN std_ulogic_vector;
                                 Constant tap         : IN NATURAL;
                                 Constant row_segment : IN segment_type := FULL;
                                 Constant sam_segment : IN sam_segment_type
                               );

   Procedure Mem_Split_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                                 Constant row         : IN NATURAL;
                                 Constant tap         : IN std_ulogic_vector;
                                 Constant row_segment : IN segment_type := FULL;
                                 Constant sam_segment : IN sam_segment_type
                               );

   Procedure Mem_Split_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                                 Constant row         : IN std_ulogic_vector;
                                 Constant tap         : IN std_ulogic_vector;
                                 Constant row_segment : IN segment_type := FULL;
                                 Constant sam_segment : IN sam_segment_type
                               );

   Procedure Mem_Split_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                                 Constant row         : IN bit_vector;
                                 Constant tap         : IN NATURAL;
                                 Constant row_segment : IN segment_type := FULL;
                                 Constant sam_segment : IN sam_segment_type
                               );

   Procedure Mem_Split_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                                 Constant row         : IN NATURAL;
                                 Constant tap         : IN bit_vector;
                                 Constant row_segment : IN segment_type := FULL;
                                 Constant sam_segment : IN sam_segment_type
                               );

   Procedure Mem_Split_RdTrans ( Variable mem_id      : INOUT mem_id_type;
                                 Constant row         : IN bit_vector;
                                 Constant tap         : IN bit_vector;
                                 Constant row_segment : IN segment_type := FULL;
                                 Constant sam_segment : IN sam_segment_type
                               );

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
                       );

   Procedure Mem_RdSAM ( Variable mem_id : INOUT mem_id_type;
                         Variable data   : OUT   std_ulogic
                       );

   Procedure Mem_RdSAM ( Variable mem_id : INOUT mem_id_type;
                         Variable data   : OUT   std_ulogic_vector
                       );

   Procedure Mem_RdSAM ( Variable mem_id : INOUT mem_id_type;
                         Variable data   : OUT   bit_vector
                       );

   Procedure Mem_RdSAM ( Variable mem_id : INOUT mem_id_type;
                         Variable data   : OUT   bit
                       );

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
                             );

   Procedure Mem_Split_RdSAM ( Variable mem_id : INOUT mem_id_type;
                               Variable data   : OUT   std_ulogic
                             );

   Procedure Mem_Split_RdSAM ( Variable mem_id : INOUT mem_id_type;
                               Variable data   : OUT   std_ulogic_vector
                             );

   Procedure Mem_Split_RdSAM ( Variable mem_id : INOUT mem_id_type;
                               Variable data   : OUT   bit_vector
                             );

   Procedure Mem_Split_RdSAM ( Variable mem_id : INOUT mem_id_type;
                               Variable data   : OUT   bit
                             );

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
                                 );

   Procedure Mem_Active_SAM_Half ( Variable mem_id : INOUT mem_id_type;
                                   Variable half   : OUT bit
                                 );

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
                          );
                               
   Procedure Mem_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                            Constant row           : NATURAL;
                            Constant Serial_Ptr    : IN std_logic_vector;
                            Constant row_segment   : IN segment_type := FULL;
                            Constant write_per_bit : IN BOOLEAN := FALSE
                          );

   Procedure Mem_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                            Constant row           : IN std_logic_vector;
                            Constant Serial_Ptr    : IN NATURAL;
                            Constant row_segment   : IN segment_type := FULL;
                            Constant write_per_bit : IN BOOLEAN := FALSE
                          );

   Procedure Mem_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                            Constant row           : IN std_logic_vector;
                            Constant Serial_Ptr    : IN std_logic_vector;
                            Constant row_segment   : IN segment_type := FULL;
                            Constant write_per_bit : IN BOOLEAN := FALSE
                          );

   Procedure Mem_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                            Constant row           : IN NATURAL;
                            Constant Serial_Ptr    : IN std_ulogic_vector;
                            Constant row_segment   : IN segment_type := FULL;
                            Constant write_per_bit : IN BOOLEAN := FALSE
                          );

   Procedure Mem_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                            Constant row           : IN std_ulogic_vector;
                            Constant Serial_Ptr    : IN NATURAL;
                            Constant row_segment   : IN segment_type := FULL;
                            Constant write_per_bit : IN BOOLEAN := FALSE
                          );

   Procedure Mem_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                            Constant row           : IN std_ulogic_vector;
                            Constant Serial_Ptr    : IN std_ulogic_vector;
                            Constant row_segment   : IN segment_type := FULL;
                            Constant write_per_bit : IN BOOLEAN := FALSE
                          );

   Procedure Mem_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                            Constant row           : IN NATURAL;
                            Constant Serial_Ptr    : IN bit_vector;
                            Constant row_segment   : IN segment_type := FULL;
                            Constant write_per_bit : IN BOOLEAN := FALSE
                          );

   Procedure Mem_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                            Constant row           : IN bit_vector;
                            Constant Serial_Ptr    : IN NATURAL;
                            Constant row_segment   : IN segment_type := FULL;
                            Constant write_per_bit : IN BOOLEAN := FALSE
                          );

   Procedure Mem_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                            Constant row           : IN bit_vector;
                            Constant Serial_Ptr    : IN bit_vector;
                            Constant row_segment   : IN segment_type := FULL;
                            Constant write_per_bit : IN BOOLEAN := FALSE
                          );

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
                                );

   Procedure Mem_Split_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                                  Constant row           : IN std_logic_vector;
                                  Constant tap           : IN NATURAL;
                                  Constant row_segment   : IN segment_type;
                                  Constant sam_segment   : IN sam_segment_type;
                                  Constant write_per_bit : IN BOOLEAN := FALSE
                                );

   Procedure Mem_Split_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                                  Constant row           : IN NATURAL;
                                  Constant tap           : IN std_logic_vector;
                                  Constant row_segment   : IN segment_type;
                                  Constant sam_segment   : IN sam_segment_type;
                                  Constant write_per_bit : IN BOOLEAN := FALSE
                                );

   Procedure Mem_Split_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                                  Constant row           : IN std_logic_vector;
                                  Constant tap           : IN std_logic_vector;
                                  Constant row_segment   : IN segment_type;
                                  Constant sam_segment   : IN sam_segment_type;
                                  Constant write_per_bit : IN BOOLEAN := FALSE
                                );

   Procedure Mem_Split_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                                  Constant row           : IN std_ulogic_vector;
                                  Constant tap           : IN NATURAL;
                                  Constant row_segment   : IN segment_type;
                                  Constant sam_segment   : IN sam_segment_type;
                                  Constant write_per_bit : IN BOOLEAN := FALSE
                                );

   Procedure Mem_Split_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                                  Constant row           : IN NATURAL;
                                  Constant tap           : IN std_ulogic_vector;
                                  Constant row_segment   : IN segment_type;
                                  Constant sam_segment   : IN sam_segment_type;
                                  Constant write_per_bit : IN BOOLEAN := FALSE
                                );

   Procedure Mem_Split_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                                  Constant row           : IN std_ulogic_vector;
                                  Constant tap           : IN std_ulogic_vector;
                                  Constant row_segment   : IN segment_type;
                                  Constant sam_segment   : IN sam_segment_type;
                                  Constant write_per_bit : IN BOOLEAN := FALSE
                               );

   Procedure Mem_Split_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                                  Constant row           : IN bit_vector;
                                  Constant tap           : IN NATURAL;
                                  Constant row_segment   : IN segment_type;
                                  Constant sam_segment   : IN sam_segment_type;
                                  Constant write_per_bit : IN BOOLEAN := FALSE
                                );

   Procedure Mem_Split_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                                  Constant row           : IN NATURAL;
                                  Constant tap           : IN bit_vector;
                                  Constant row_segment   : IN segment_type;
                                  Constant sam_segment   : IN sam_segment_type;
                                  Constant write_per_bit : IN BOOLEAN := FALSE
                                );

   Procedure Mem_Split_WrtTrans ( Variable mem_id        : INOUT mem_id_type;
                                  Constant row           : IN bit_vector;
                                  Constant tap           : IN bit_vector;
                                  Constant row_segment   : IN segment_type;
                                  Constant sam_segment   : IN sam_segment_type;
                                  Constant write_per_bit : IN BOOLEAN := FALSE
                               );

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
                          Constant data          : IN    std_logic_vector;
                          Constant write_per_bit : IN BOOLEAN := FALSE
                        );

   Procedure Mem_WrtSAM ( Variable mem_id        : INOUT mem_id_type;
                          Constant data          : IN    std_ulogic;
                          Constant write_per_bit : IN BOOLEAN := FALSE
                        );

   Procedure Mem_WrtSAM ( Variable mem_id        : INOUT mem_id_type;
                          Constant data          : IN    std_ulogic_vector;
                          Constant write_per_bit : IN BOOLEAN := FALSE
                        );

   Procedure Mem_WrtSAM ( Variable mem_id        : INOUT mem_id_type;
                          Constant data          : IN   bit_vector;
                          Constant write_per_bit : IN BOOLEAN := FALSE
                        );

   Procedure Mem_WrtSAM ( Variable mem_id        : INOUT mem_id_type;
                          Constant data          : IN    bit;
                          Constant write_per_bit : IN BOOLEAN := FALSE
                        );

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
                              );

   Procedure Mem_Split_WrtSAM ( Variable mem_id        : INOUT mem_id_type;
                                Constant data          : IN    std_ulogic;
                                Constant write_per_bit : IN BOOLEAN := FALSE
                              );

   Procedure Mem_Split_WrtSAM ( Variable mem_id        : INOUT mem_id_type;
                                Constant data          : IN    std_ulogic_vector;
                                Constant write_per_bit : IN BOOLEAN := FALSE
                              );

   Procedure Mem_Split_WrtSAM ( Variable mem_id        : INOUT mem_id_type;
                                Constant data          : IN    bit_vector;
                                Constant write_per_bit : IN BOOLEAN := FALSE
                              );

   Procedure Mem_Split_WrtSAM ( Variable mem_id        : INOUT mem_id_type;
                                Constant data          : IN    bit;
                                Constant write_per_bit : IN BOOLEAN := FALSE
                              );

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
                          );
      
   Procedure Mem_Get_SPtr ( Variable mem_id     : IN mem_id_type;
                            Variable serial_ptr : OUT std_logic_vector
                          );
                            
   Procedure Mem_Get_SPtr ( Variable mem_id     : INOUT mem_id_type;
                            Variable serial_ptr : OUT std_ulogic_vector
                          );
      
   Procedure Mem_Get_SPtr ( Variable mem_id     : INOUT mem_id_type;
                            Variable serial_ptr : OUT bit_vector
                          );
      
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
                          );

   Procedure Mem_Set_SPtr ( Variable mem_id     : INOUT mem_id_type;
                            Constant serial_ptr : IN std_logic_vector
                          );

   Procedure Mem_Set_SPtr ( Variable mem_id     : INOUT mem_id_type;
                            Constant serial_ptr : IN std_ulogic_vector
                          );

   Procedure Mem_Set_SPtr ( Variable mem_id     : INOUT mem_id_type;
                            Constant serial_ptr : IN bit_vector
                          );


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

   Function To_Segment ( Constant address : IN bit_vector ) return segment_type;

   Function To_Segment ( Constant address : IN std_logic_vector ) return segment_type;
   
   Function To_Segment ( Constant address : IN std_ulogic_vector ) return segment_type;
        
   Function To_Segment ( Constant address : IN std_ulogic ) return segment_type;
    
   Function To_Segment ( Constant address : IN bit ) return segment_type;

END std_mempak;
