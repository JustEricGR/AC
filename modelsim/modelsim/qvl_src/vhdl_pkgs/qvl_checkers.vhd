--              Copyright 2006-2009 Mentor Graphics Corporation
--                           All Rights Reserved.
--
--              THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY
--            INFORMATION WHICH IS THE PROPERTY OF MENTOR GRAPHICS
--           CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE
--                                  TERMS.
--
--                   Questa Verification Library (QVL)
--

library ieee;
use ieee.std_logic_1164.all;

PACKAGE qvl_checkers IS

  constant QVL_STD_DEFINES_H : boolean := true;

  -- severity level
  constant QVL_FATAL   : integer := 0;
  constant QVL_ERROR   : integer := 1;
  constant QVL_WARNING : integer := 2;
  constant QVL_INFO    : integer := 3;

  -- coverage levels
  constant QVL_COVER_NONE      : integer := 0;
  constant QVL_COVER_SANITY    : integer := 1;
  constant QVL_COVER_BASIC     : integer := 2;
  constant QVL_COVER_CORNER    : integer := 4;
  constant QVL_COVER_STATISTIC : integer := 8;
  constant QVL_COVER_ALL       : integer := 15;

  -- property type
  constant QVL_ASSERT     : integer := 0;
  constant QVL_ASSUME     : integer := 1;
  constant QVL_IGNORE     : integer := 2;

  -- Biggest integer in VHDL for 32 bit representation
  constant BIGGEST_INTEGER_32_BIT : integer := -2147483648; 

 function log2 (N : positive) return natural;
 function ceil_log2 (N : positive) return natural;


--------------------------------------------------------------------------------

COMPONENT qvl_arbiter

  GENERIC (
    severity_level : integer := QVL_ERROR;
    property_type  : integer := QVL_ASSERT;
    msg            : string  := "QVL_VIOLATION : ";
    coverage_level : integer := QVL_COVER_NONE;
    width          : integer := 2;
    req_type       : integer := 0;
    gnt_type       : integer := 0;
    deassert_count : integer := 0;
    park           : integer := 0;
    min            : integer := 0;
    max            : integer := 0;
    max_gnt_cycles : integer := 0;
    no_simultaneous_req_gnt : integer := 0
  );

  PORT (
    clk       : in std_logic;
    reset_n   : in std_logic;
    active    : in std_logic;
    req       : in std_logic_vector(width-1 downto 0);
    gnt       : in std_logic_vector(width-1 downto 0)
  );

END COMPONENT; -- qvl_arbiter

--------------------------------------------------------------------------------

COMPONENT qvl_assert_follower

  GENERIC (
   severity_level          : integer :=  QVL_ERROR;
   property_type           : integer :=  QVL_ASSERT;
   msg                     : string  :=  "QVL_VIOLATION : ";
   coverage_level          : integer :=  QVL_COVER_NONE;
   min                     : integer :=  0;
   max                     : integer :=  0;
   max_leaders             : integer :=  0;
   known_follower_check    : integer :=  0
  );

  PORT (
   clk                : in std_logic;
   reset_n            : in std_logic;
   active             : in std_logic;
   leader             : in std_logic;
   follower           : in std_logic
  );

END COMPONENT; -- qvl_assert_follower

--------------------------------------------------------------------------------

COMPONENT qvl_assert_leader

  GENERIC (
    severity_level      : integer := QVL_ERROR;
    property_type       : integer := QVL_ASSERT;
    msg                 : string  := "QVL_VIOLATION : ";
    coverage_level      : integer := QVL_COVER_NONE;
    min                 : integer := 0;
    max                 : integer := 0;
    max_leaders         : integer := 0
  );

  PORT (
    clk       : in std_logic;
    reset_n   : in std_logic;
    active    : in std_logic;
    leader    : in std_logic;
    follower  : in std_logic
  );

END COMPONENT; -- qvl_assert_leader

--------------------------------------------------------------------------------

COMPONENT qvl_assert_timer

  GENERIC (
    severity_level    : integer := QVL_ERROR;
    property_type     : integer := QVL_ASSERT;
    msg               : string  := "QVL_VIOLATION : ";
    coverage_level    : integer := QVL_COVER_ALL;
    min_check         : integer := 0;
    max_check         : integer := 0
   );

  PORT (
        clk       : in std_logic;
        reset_n   : in std_logic;
        active    : in std_logic;
        test_expr : in std_logic;
        max       : in std_logic_vector (31 downto 0);
        min       : in std_logic_vector (31 downto 0)
      );

END COMPONENT; -- qvl_assert_timer

--------------------------------------------------------------------------------

COMPONENT qvl_assert_together

  GENERIC (
    severity_level : integer := QVL_ERROR;
    property_type  : integer := QVL_ASSERT;
    msg            : string  := "QVL_VIOLATION : ";
    coverage_level : integer := QVL_COVER_NONE
  );

  PORT (
    clk        : in std_logic;
    reset_n    : in std_logic;
    active     : in std_logic;
    test_expr1 : in std_logic;
    test_expr2 : in std_logic
  );

END COMPONENT; -- qvl_assert_together

--------------------------------------------------------------------------------

COMPONENT qvl_back_pressure

  GENERIC (
    severity_level : integer := QVL_ERROR;
    property_type  : integer := QVL_ASSERT;
    msg            : string  := "QVL_VIOLATION : ";
    coverage_level : integer := QVL_COVER_ALL;
    min            : integer := 1;
    max            : integer := 1
  );

  PORT (
    clk            : in std_logic;
    reset_n        : in std_logic;
    active         : in std_logic;
    back_pressure  : in std_logic;
    transmit_ready     : in std_logic
  );

END COMPONENT; -- qvl_back_pressure

--------------------------------------------------------------------------------

COMPONENT qvl_bits_off

  GENERIC (
    severity_level : integer := QVL_ERROR;
    property_type  : integer := QVL_ASSERT;
    msg            : string  := "QVL_VIOLATION : ";
    coverage_level : integer := QVL_COVER_NONE;
    width          : integer := 1;
    min            : integer := 0;
    max            : integer := 1
  );

  PORT (
    clk       : in std_logic;
    reset_n   : in std_logic;
    active    : in std_logic;
    test_expr : in std_logic_vector(width-1 downto 0)
  );

END COMPONENT; -- qvl_bits_off

--------------------------------------------------------------------------------

COMPONENT qvl_bits_on

  GENERIC (
    severity_level : integer := QVL_ERROR;
    property_type  : integer := QVL_ASSERT;
    msg            : string  := "QVL_VIOLATION : ";
    coverage_level : integer := QVL_COVER_NONE;
    width          : integer := 1;
    min            : integer := 0;
    max            : integer := 1
  );

  PORT (
    clk       : in std_logic;
    reset_n   : in std_logic;
    active    : in std_logic;
    test_expr : in std_logic_vector(width-1 downto 0)
  );

END COMPONENT; -- qvl_bits_on

--------------------------------------------------------------------------------

COMPONENT qvl_bus_driver

  GENERIC (
    severity_level       : integer := QVL_ERROR;
    property_type        : integer := QVL_ASSERT;
    msg                  : string  := "QVL_VIOLATION : ";
    coverage_level       : integer := QVL_COVER_NONE;
    width                : integer := 1;
    num_drivers          : integer := 1;
    max_undriven_cycles  : integer := 0;
    no_driver_check      : integer := 0
   );

  PORT (
    clk            : in std_logic;
    reset_n        : in std_logic;
    active         : in std_logic;
    test_expr      : in std_logic_vector((width-1) downto 0);
    driver_enables : in std_logic_vector((num_drivers-1) downto 0)
  );

END COMPONENT; -- qvl_bus_driver

--------------------------------------------------------------------------------

COMPONENT qvl_bus_id

  GENERIC (
    severity_level                    : integer := QVL_ERROR;
    property_type                     : integer := QVL_ASSERT;
    msg                               : string  := "QVL_VIOLATION : ";
    coverage_level                    : integer := QVL_COVER_ALL;
    width                             : integer := 4;
    max_ids                           : integer := 16;
    allow_simultaneous_req_ret        : integer := 0;
    disallow_req_when_full            : integer := 0;
    unique_ids_check                  : integer := 1;
    known_ids_check                   : integer := 1
  );

  PORT (
    clk            : in std_logic;
    reset_n        : in std_logic;
    active         : in std_logic;
    req            : in std_logic;
    req_id         : in std_logic_vector(width-1 downto 0);
    ret            : in std_logic;
    ret_id         : in std_logic_vector(width-1 downto 0)
  );

END COMPONENT; -- qvl_bus_id

--------------------------------------------------------------------------------

COMPONENT qvl_change_timer

  GENERIC (
    severity_level    : integer := QVL_ERROR;
    property_type     : integer := QVL_ASSERT;
    msg               : string  := "QVL_VIOLATION : ";
    coverage_level    : integer := QVL_COVER_ALL;
    width             : integer := 1;
    min_check         : integer := 0;
    max_check         : integer := 0
   );

  PORT (
        clk       : in std_logic;
        reset_n   : in std_logic;
        active    : in std_logic;
        test_expr : in std_logic_vector (width-1 downto 0);
        max       : in std_logic_vector (31 downto 0);
        min       : in std_logic_vector (31 downto 0)
      );

END COMPONENT; -- qvl_change_timer

--------------------------------------------------------------------------------

COMPONENT qvl_channel_data_integrity

  GENERIC (
    severity_level                         : integer := QVL_ERROR;
    property_type                          : integer := QVL_ASSERT;
    msg                                    : string  := "QVL_VIOLATION : ";
    coverage_level                         : integer := QVL_COVER_NONE;
    width                                  : integer := 1;
    depth                                  : integer := 1;
    insert_count                           : integer := 1;
    remove_count                           : integer := 1;
    cancel_count                           : integer := 1;
    pass                                   : integer := 0;
    registered                             : integer := 0;
    latency                                : integer := 0;
    high_water                             : integer := 0;
    insert_check                           : integer := 0;
    cancel_check                           : integer := 0;
    empty_check                            : integer := 0
  );

  PORT (
    clk          : in std_logic;
    reset_n      : in std_logic;
    active       : in std_logic;
    insert       : in std_logic_vector(insert_count-1 downto 0);
    remove       : in std_logic_vector(remove_count-1 downto 0);
    cancel       : in std_logic_vector(cancel_count-1 downto 0);
    empty        : in std_logic;
    insert_data  : in std_logic_vector((width * insert_count)-1 downto 0);
    remove_data  : in std_logic_vector((width * remove_count)-1 downto 0);
    cancel_data  : in std_logic_vector((width * cancel_count)-1 downto 0)
  );

END COMPONENT; -- qvl_channel_data_integrity

--------------------------------------------------------------------------------

COMPONENT qvl_constant

  GENERIC (
    severity_level   : integer := QVL_ERROR;
    property_type    : integer := QVL_ASSERT;
    msg              : string  := "QVL_VIOLATION : ";
    coverage_level   : integer := QVL_COVER_NONE;
    width            : integer := 4
  );

  PORT (
    clk       : in std_logic;
    reset_n   : in std_logic;
    active    : in std_logic;
    test_expr : in std_logic_vector(width-1 downto 0)
  );

END COMPONENT; -- qvl_constant

--------------------------------------------------------------------------------

COMPONENT qvl_content_addressable_memory

  GENERIC (
    severity_level                         : integer := QVL_ERROR;
    property_type                          : integer := QVL_ASSERT;
    msg                                    : string  := "QVL_VIOLATION : ";
    coverage_level                         : integer := QVL_COVER_NONE;
    depth                                  : integer := 1;
    width                                  : integer := 1;
    addr_enable                            : integer := 0;
    match_data_enable                      : integer := 0;
    latency                                : integer := 0;
    allow_x                                : integer := 0;
    addr_encoding                          : integer := 0;
    lowest_addr                            : integer := 0;
    single_match_check                     : integer := 0;
    address_check                          : integer := 0
  );

  PORT (
    clk             : in std_logic;
    reset_n         : in std_logic;
    active          : in std_logic;
    write           : in std_logic;
    addr            : in std_logic_vector((((log2(depth)) -1) * addr_enable) downto 0);
    data            : in std_logic_vector(width-1 downto 0);
    match           : in std_logic;
    match_found     : in std_logic;
    data_mask       : in std_logic_vector(width -1 downto 0);
    match_data      : in std_logic_vector(width -1 downto 0);
    match_addr      : in std_logic_vector( ((((((addr_encoding/2)+depth) -
                         (((addr_encoding/2)*depth)+(addr_encoding/2))) +
                         ( (addr_encoding/2)* (log2(depth)) ) )-1)*
                         address_check)  downto 0)
  );

END COMPONENT; -- qvl_content_addressable_memory

--------------------------------------------------------------------------------

COMPONENT qvl_coverage

  GENERIC (
    severity_level : integer := QVL_ERROR;
    property_type  : integer := QVL_ASSERT;
    msg            : string  := "QVL_VIOLATION : ";
    coverage_level : integer := QVL_COVER_NONE
  );

  PORT (
    clk       : in std_logic;
    reset_n   : in std_logic;
    active    : in std_logic;
    test_expr : in std_logic
  );

END COMPONENT; -- qvl_coverage

--------------------------------------------------------------------------------

COMPONENT qvl_crc

  GENERIC (
    severity_level          : integer := QVL_ERROR;
    property_type           : integer := QVL_ASSERT;
    msg                     : string  := "QVL_VIOLATION";
    coverage_level          : integer := QVL_COVER_NONE;
    width                   : integer := 1;
    data_width              : integer := 0;
    crc_width               : integer := 5;
    crc_enable              : integer := 0;
    crc_latch_enable        : integer := 0;
    polynomial              : integer := 5;
    initial_value           : integer := 0;
    lsb_first               : integer := 0;
    big_endian              : integer := 0;
    reverse_endian          : integer := 0;
    invert                  : integer := 0;
    combinational           : integer := 0
  );


  PORT (
    clk                     : in std_logic;
    reset_n                 : in std_logic;
    active                  : in std_logic;
    test_expr               : in std_logic_vector(width-1 downto 0);
    initialize              : in std_logic;
    valid                   : in std_logic; 
    compare                 : in std_logic;
    crc                     : in std_logic_vector(crc_width-1 downto 0);
    crc_latch               : in std_logic
    );

END COMPONENT; -- qvl_crc

--------------------------------------------------------------------------------

COMPONENT qvl_data_loaded

  GENERIC (
    severity_level       : integer := QVL_ERROR;
    property_type        : integer := QVL_ASSERT;
    msg                  : string  := "QVL_VIOLATION : ";
    coverage_level       : integer := QVL_COVER_NONE;
    start_count          : integer := 0;
    stop_count           : integer := 0;
    restart              : integer := 0;
    no_restart_check     : integer := 0
   );

  PORT (
    clk            : in std_logic;
    reset_n        : in std_logic;
    active         : in std_logic;
    start          : in std_logic;
    stop           : in std_logic;
    load_condition : in std_logic
  );

END COMPONENT; -- qvl_data_loaded

--------------------------------------------------------------------------------

COMPONENT qvl_data_used

  GENERIC (
    severity_level      : integer := QVL_ERROR;
    property_type       : integer := QVL_ASSERT;
    msg                 : string  := "QVL_VIOLATION : ";
    coverage_level      : integer := QVL_COVER_NONE;
    width               : integer := 2;
    any_load            : integer := 0;
    start_enable        : integer := 0;
    restart             : integer := 0;
    no_restart_check    : integer := 0;
    start_count         : integer := 0;
    stop_enable         : integer := 0;
    stop_count          : integer := 0
  );

  PORT (
    clk            : in std_logic;
    reset_n        : in std_logic;
    active         : in std_logic;
    test_expr      : in std_logic_vector(width-1 downto 0);
    valid          : in std_logic;
    load_condition : in std_logic;
    used_condition : in std_logic;
    flush          : in std_logic;
    start          : in std_logic;
    stop           : in std_logic
  );

END COMPONENT; -- qvl_data_used

--------------------------------------------------------------------------------

COMPONENT qvl_decoder

  GENERIC (
    severity_level   : integer := QVL_ERROR;
    property_type    : integer := QVL_ASSERT;
    msg              : string  := "QVL_VIOLATION : ";
    coverage_level   : integer := QVL_COVER_NONE;
    in_width         : integer := 1;
    out_width        : integer := 2;
    msb              : integer := 0
  );

  PORT (
    clk       : in std_logic;
    reset_n   : in std_logic;
    active    : in std_logic;
    in_data   : in std_logic_vector(in_width-1 downto 0);
    out_data  : in std_logic_vector(out_width-1 downto 0)
  );

END COMPONENT; -- qvl_decoder

--------------------------------------------------------------------------------

COMPONENT qvl_decoder_8b10b

  GENERIC (
    severity_level         : integer := QVL_ERROR;
    property_type          : integer := QVL_ASSERT;
    msg                    : string  := "QVL_VIOLATION : ";
    coverage_level         : integer := QVL_COVER_NONE;
    num_decoders           : integer := 1;
    cascade                : integer := 0;
    reserved_k_codes_count : integer := 0;
    disparity_check        : integer := 0
  );

  PORT (
    clk              : in std_logic;
    reset_n          : in std_logic;
    active           : in std_logic;
    in_10b           : in std_logic_vector ((10*num_decoders)-1 downto 0);
    out_k            : in std_logic_vector (num_decoders-1 downto 0);
    out_8b           : in std_logic_vector ((8*num_decoders)-1 downto 0);
    rd               : in std_logic_vector ((num_decoders-(cascade*(num_decoders-1)))-1 downto 0);
    force_rd_enable  : in std_logic_vector (num_decoders-1 downto 0);
    force_rd         : in std_logic_vector (num_decoders-1 downto 0);
    reserved_k_codes : in std_logic_vector (((reserved_k_codes_count * 8) + ((12-reserved_k_codes_count)/12))-1 downto 0)
  );

END COMPONENT; -- qvl_decoder_8b10b

--------------------------------------------------------------------------------

COMPONENT qvl_driven

  GENERIC (
    severity_level : integer := QVL_ERROR;
    property_type  : integer := QVL_ASSERT;
    msg            : string  := "QVL_VIOLATION : ";
    coverage_level : integer := QVL_COVER_NONE;
    width          : integer := 4
  );

  PORT (
    clk       : in std_logic;
    reset_n   : in std_logic;
    active    : in std_logic;
    test_expr : in std_logic_vector(width-1 downto 0)
  );

END COMPONENT; -- qvl_driven

--------------------------------------------------------------------------------

COMPONENT qvl_encoder

  GENERIC (
    severity_level   : integer := QVL_ERROR;
    property_type    : integer := QVL_ASSERT;
    msg              : string  := "QVL_VIOLATION : ";
    coverage_level   : integer := QVL_COVER_NONE;
    in_width         : integer := 2;
    out_width        : integer := 1;
    lsb              : integer := 0;
    multibit_check  : integer := 0
  );

  PORT (
    clk       : in std_logic;
    reset_n   : in std_logic;
    active    : in std_logic;
    in_data   : in std_logic_vector(in_width-1 downto 0);
    out_data  : in std_logic_vector(out_width-1 downto 0)
  );

END COMPONENT; -- qvl_encoder

--------------------------------------------------------------------------------

COMPONENT qvl_encoder_8b10b

  GENERIC (
    severity_level         : integer := QVL_ERROR;
    property_type          : integer := QVL_ASSERT;
    msg                    : string  := "QVL_VIOLATION : ";
    coverage_level         : integer := QVL_COVER_NONE;
    num_encoders           : integer := 1;
    initial_rd             : integer := 0;
    cascade                : integer := 0;
    reserved_k_codes_count : integer := 0;
    disparity_check        : integer := 0
  );

  PORT (
    clk              : in std_logic;
    reset_n          : in std_logic;
    active           : in std_logic;
    in_8b            : in std_logic_vector ((8*num_encoders)-1 downto 0);
    in_k             : in std_logic_vector (num_encoders-1 downto 0);
    out_10b          : in std_logic_vector ((10*num_encoders)-1 downto 0);
    rd               : in std_logic_vector ((num_encoders-(cascade*(num_encoders-1)))-1 downto 0);
    force_rd_enable  : in std_logic_vector (num_encoders-1 downto 0);
    force_rd         : in std_logic_vector (num_encoders-1 downto 0);
    reserved_k_codes : in std_logic_vector (((reserved_k_codes_count * 8) + ((12-reserved_k_codes_count)/12))-1 downto 0)
  );

END COMPONENT; -- qvl_encoder_8b10b

--------------------------------------------------------------------------------

COMPONENT qvl_fifo

  GENERIC (
    severity_level                         : integer := QVL_ERROR;
    property_type                          : integer := QVL_ASSERT;
    msg                                    : string  := "QVL_VIOLATION : ";
    coverage_level                         : integer := QVL_COVER_NONE;
    depth                                  : integer := 1;
    width                                  : integer := 1;
    pass                                   : integer := 0;
    registered                             : integer := 0;
    high_water                             : integer := 0;
    full_check                             : integer := 0;
    empty_check                            : integer := 0;
    value_check                            : integer := 0;
    latency                                : integer := 0;
    preload_count                          : integer := 0
  );

  PORT (
    clk                : in std_logic;
    reset_n            : in std_logic;
    active             : in std_logic;
    enq                : in std_logic;
    deq                : in std_logic;
    full               : in std_logic;
    empty              : in std_logic;
    enq_data           : in std_logic_vector(width-1 downto 0);
    deq_data           : in std_logic_vector(width-1 downto 0);
    preload            : in std_logic_vector((((depth -preload_count)/depth
                             + preload_count)*width)-1 downto 0)
  );

END COMPONENT; -- qvl_fifo

--------------------------------------------------------------------------------

COMPONENT qvl_gray_code

  GENERIC (
    severity_level   : integer := QVL_ERROR;
    property_type    : integer := QVL_ASSERT;
    msg              : string  := "QVL_VIOLATION : ";
    coverage_level   : integer := QVL_COVER_NONE;
    width            : integer := 1
  );

  PORT (
    clk       : in std_logic;
    reset_n   : in std_logic;
    active    : in std_logic;
    test_expr : in std_logic_vector(width-1 downto 0)
  );

END COMPONENT; -- qvl_gray_code

--------------------------------------------------------------------------------

COMPONENT qvl_hamming_distance

  GENERIC (
    severity_level : integer := QVL_ERROR;
    property_type  : integer := QVL_ASSERT;
    msg            : string  := "QVL_VIOLATION : ";
    coverage_level : integer := QVL_COVER_NONE;
    width          : integer := 1;
    distance       : integer := 0;
    min            : integer := 0;
    max            : integer := 0
  );

  PORT (
    clk       : in std_logic;
    reset_n   : in std_logic;
    active    : in std_logic;
    test_expr : in std_logic_vector(width-1 downto 0)
  );

END COMPONENT; -- qvl_hamming_distance

--------------------------------------------------------------------------------

COMPONENT qvl_known

  GENERIC (
    severity_level : integer := QVL_ERROR;
    property_type  : integer := QVL_ASSERT;
    msg            : string  := "QVL_VIOLATION : ";
    coverage_level : integer := QVL_COVER_ALL;
    width          : integer := 4
  );

  PORT (
    clk       : in std_logic;
    reset_n   : in std_logic;
    active    : in std_logic;
    test_expr : in std_logic_vector(width-1 downto 0)
  );

END COMPONENT; -- qvl_known

--------------------------------------------------------------------------------

COMPONENT qvl_maximum

  GENERIC (
    severity_level   : integer := QVL_ERROR;
    property_type    : integer := QVL_ASSERT;
    msg              : string  := "QVL_VIOLATION : ";
    coverage_level   : integer := QVL_COVER_NONE;
    width            : integer := 4;
    val_width        : integer := 4;
    twos_complement  : integer := 0
  );

  PORT (
    clk       : in std_logic;
    reset_n   : in std_logic;
    active    : in std_logic;
    test_expr : in std_logic_vector(width-1 downto 0);
    val       : in std_logic_vector(val_width-1 downto 0)
  );

END COMPONENT; -- qvl_maximum

--------------------------------------------------------------------------------

COMPONENT qvl_memory_access

  GENERIC (
    severity_level     : integer := QVL_ERROR;
    property_type      : integer := QVL_ASSERT;
    msg                : string  := "QVL_VIOLATION : ";
    coverage_level     : integer := QVL_COVER_ALL;
    addr_width         : integer := 2;
    read_old_data      : integer := 0;
    initialized_check  : integer := 0;
    single_access_check: integer := 1;
    single_write_check : integer := 0;
    single_read_check  : integer := 0;
    data_check         : integer := 0;
    data_width         : integer := 1;
    latency            : integer := 0
   );

  PORT (
    clk           : in std_logic;
    reset_n       : in std_logic;
    active        : in std_logic;
    read_addr     : in std_logic_vector((addr_width-1) downto 0);
    read_data     : in std_logic_vector((data_width-1) downto 0);
    read          : in std_logic;
    write_addr    : in std_logic_vector((addr_width-1) downto 0);
    write_data    : in std_logic_vector((data_width-1) downto 0);
    write         : in std_logic;
    start_addr    : in std_logic_vector((addr_width-1) downto 0);
    end_addr      : in std_logic_vector((addr_width-1) downto 0)
  );

END COMPONENT; -- qvl_memory_access

--------------------------------------------------------------------------------

COMPONENT qvl_minimum

  GENERIC (
    severity_level   : integer := QVL_ERROR;
    property_type    : integer := QVL_ASSERT;
    msg              : string  := "QVL_VIOLATION : ";
    coverage_level   : integer := QVL_COVER_NONE;
    width            : integer := 4;
    val_width        : integer := 4;
    twos_complement  : integer := 0
  );

  PORT (
    clk       : in std_logic;
    reset_n   : in std_logic;
    active    : in std_logic;
    test_expr : in std_logic_vector(width-1 downto 0);
    val       : in std_logic_vector(val_width-1 downto 0)
  );

END COMPONENT; -- qvl_minimum

--------------------------------------------------------------------------------

COMPONENT qvl_multiplexor

  GENERIC (
    severity_level : integer := QVL_ERROR;
    property_type  : integer := QVL_ASSERT;
    msg            : string  := "QVL_VIOLATION : ";
    coverage_level : integer := QVL_COVER_ALL;
    in_width       : integer := 1;
    out_width      : integer := 1;
    select_width   : integer := 1;
    item_count     : integer := 1;
    binary         : integer := 0
   );

  PORT (
    clk        : in std_logic;
    reset_n    : in std_logic;
    active     : in std_logic;
    in_data    : in std_logic_vector(in_width-1 downto 0);
    mux_select : in std_logic_vector(select_width-1 downto 0);
    out_data   : in std_logic_vector(out_width-1 downto 0)
  );

END COMPONENT; -- qvl_multiplexor

--------------------------------------------------------------------------------

COMPONENT qvl_multi_clock_fifo

  GENERIC (
    severity_level : integer := QVL_ERROR;
    property_type  : integer := QVL_ASSERT;
    msg            : string  := "QVL_VIOLATION : ";
    coverage_level : integer := QVL_COVER_NONE;
    width          : integer := 1;
    depth          : integer := 1;
    latency        : integer := 0;
    preload_count  : integer := 0;
    high_water     : integer := 0;
    full_check     : integer := 0;
    empty_check    : integer := 0;
    value_check    : integer := 0
  );

  PORT (
    enq_clk        : in std_logic;
    deq_clk        : in std_logic;
    enq_reset_n    : in std_logic;
    deq_reset_n    : in std_logic;
    active         : in std_logic;
    enq_active     : in std_logic;
    deq_active     : in std_logic;
    enq            : in std_logic;
    deq            : in std_logic;
    full           : in std_logic;
    empty          : in std_logic;
    enq_data       : in std_logic_vector(width-1 downto 0);
    deq_data       : in std_logic_vector(width-1 downto 0);
    preload        : in std_logic_vector(((((depth -preload_count)/depth)
                            + preload_count)*width)-1 downto 0)
  );

END COMPONENT; -- qvl_multi_clock_fifo

--------------------------------------------------------------------------------

COMPONENT qvl_multi_clock_multi_enq_deq_fifo

  GENERIC (
    severity_level : integer := QVL_ERROR;
    property_type  : integer := QVL_ASSERT;
    msg            : string  := "QVL_VIOLATION : ";
    coverage_level : integer := QVL_COVER_ALL;
    width          : integer := 1;
    depth          : integer := 2;
    enq_count      : integer := 1;
    deq_count      : integer := 1;
    latency        : integer := 0;
    preload_count  : integer := 0;
    high_water     : integer := 0;
    low_water      : integer := 1;
    full_check     : integer := 0;
    empty_check    : integer := 0;
    value_check    : integer := 0
  );

  PORT (
    enq_clk       : in std_logic;
    deq_clk       : in std_logic;
    enq_reset_n   : in std_logic;
    deq_reset_n   : in std_logic;
    active        : in std_logic;
    enq_active    : in std_logic;
    deq_active    : in std_logic;
    enq           : in std_logic_vector(enq_count-1 downto 0);
    deq           : in std_logic_vector(deq_count-1 downto 0);
    full          : in std_logic;
    empty         : in std_logic;
    enq_data      : in std_logic_vector((enq_count*width)-1 downto 0);
    deq_data      : in std_logic_vector((deq_count*width)-1 downto 0);
    preload       : in std_logic_vector(((((depth-preload_count)/depth) + preload_count)*width)-1 downto 0)
  );

END COMPONENT; -- qvl_multi_clock_multi_enq_deq_fifo

--------------------------------------------------------------------------------

COMPONENT qvl_multi_clock_multi_port_memory_access

  GENERIC (
    severity_level : integer := QVL_ERROR;
    property_type  : integer := QVL_ASSERT;
    msg            : string  := "QVL_VIOLATION : ";
    coverage_level : integer := QVL_COVER_NONE;
    read_count     : integer := 1;
    write_count    : integer := 1;
    addr_width     : integer := 4;
    data_width     : integer := 4;
    latency        : integer := 0;
    write_lock_period   : integer := 0;
    read_lock_period    : integer := 0;
    multiple_read_check : integer := 0;
    single_write_check  : integer := 0;
    single_read_check   : integer := 0;
    initialized_check   : integer := 0;
    data_check          : integer := 0
  );

  PORT (
    read_clk      : in std_logic;
    write_clk     : in std_logic;
    read_reset_n  : in std_logic;
    write_reset_n : in std_logic;
    active        : in std_logic;
    read_active   : in std_logic;
    write_active  : in std_logic;
    read          : in std_logic_vector(read_count-1 downto 0);
    write         : in std_logic_vector(write_count-1 downto 0);
    read_addr     : in std_logic_vector((read_count*addr_width)-1 downto 0);
    write_addr    : in std_logic_vector((write_count*addr_width)-1 downto 0);
    read_data     : in std_logic_vector((read_count*data_width)-1 downto 0);
    write_data    : in std_logic_vector((write_count*data_width)-1 downto 0);
    start_addr    : in std_logic_vector(addr_width-1 downto 0);
    end_addr      : in std_logic_vector(addr_width-1 downto 0)
  );

END COMPONENT; -- qvl_multi_clock_multi_port_memory_access

--------------------------------------------------------------------------------

COMPONENT qvl_multi_enq_deq_fifo

  GENERIC (
    severity_level : integer := QVL_ERROR;
    property_type  : integer := QVL_ASSERT;
    msg            : string  := "QVL_VIOLATION : ";
    coverage_level : integer := QVL_COVER_ALL;
    width          : integer := 1;
    depth          : integer := 1;
    enq_count      : integer := 1;
    deq_count      : integer := 1;
    pass           : integer := 0;
    registered     : integer := 0;
    latency        : integer := 0;
    preload_count  : integer := 0;
    high_water     : integer := 0;
    full_check     : integer := 0;
    empty_check    : integer := 0;
    value_check    : integer := 0

   );

  PORT (
   clk         : in std_logic;
   reset_n     : in std_logic;
   active      : in std_logic;
   enq         : in std_logic_vector ((enq_count-1) downto 0);
   deq         : in std_logic_vector ((deq_count-1) downto 0);
   full        : in std_logic;
   empty       : in std_logic;
   enq_data    : in std_logic_vector ((enq_count*width-1) downto 0);
   deq_data    : in std_logic_vector ((deq_count*width-1) downto 0);
   preload     : in std_logic_vector (((((depth-preload_count)/depth) + preload_count)*width)-1 downto 0)
       );

END COMPONENT; -- qvl_multi_enq_deq_fifo

--------------------------------------------------------------------------------

COMPONENT qvl_mutex

  GENERIC (
    severity_level : integer := QVL_ERROR;
    property_type  : integer := QVL_ASSERT;
    msg            : string  := "QVL_VIOLATION : ";
    coverage_level : integer := QVL_COVER_NONE;
    width          : integer := 4
  );

  PORT (
    clk       : in std_logic;
    reset_n   : in std_logic;
    active    : in std_logic;
    test_expr : in std_logic_vector(width-1 downto 0)
  );

END COMPONENT; -- qvl_mutex

--------------------------------------------------------------------------------

COMPONENT qvl_outstanding_id

  GENERIC (
    severity_level                    : integer := QVL_ERROR;
    property_type                     : integer := QVL_ASSERT;
    msg                               : string  := "QVL_VIOLATION : ";
    coverage_level                    : integer := QVL_COVER_NONE;
    width                             : integer := 6;
    count_width                       : integer := 2;
    min                               : integer := 0;
    max                               : integer := 0;
    max_ids                           : integer := 16;
    max_count_per_id                  : integer := 8;
    flush_enable                      : integer := 0;
    flush_count_enable                : integer := 0;
    pre_req_ids_count                 : integer := 0;
    pre_req_count_width               : integer := 1;
    allow_simultaneous_req_ret        : integer := 0;
    allow_simultaneous_flush_req      : integer := 0;
    allow_partial                     : integer := 0;
    disallow_req_when_full            : integer := 0;
    known_ids_check                   : integer := 1;
    known_flush_check                 : integer := 0
  );

  PORT (
    clk            : in std_logic;
    reset_n        : in std_logic;
    active         : in std_logic;
    req            : in std_logic;
    req_id         : in std_logic_vector(width-1 downto 0);
    req_count      : in std_logic_vector(count_width-1 downto 0);
    ret            : in std_logic;
    ret_id         : in std_logic_vector(width-1 downto 0);
    ret_count      : in std_logic_vector(count_width-1 downto 0);
    flush          : in std_logic;
    flush_id       : in std_logic_vector(width-1 downto 0);
    flush_count    : in std_logic_vector(count_width-1 downto 0);
    pre_req_ids    : in std_logic_vector(((((2**30 - pre_req_ids_count)/
                                         2**30) + pre_req_ids_count) *
                                         width)-1 downto 0);
    pre_req_counts : in std_logic_vector((((2**30 - pre_req_ids_count)/
                                         2**30) + (pre_req_ids_count*
                                         pre_req_count_width))-1 downto 0)
  );

END COMPONENT; -- qvl_outstanding_id

--------------------------------------------------------------------------------

COMPONENT qvl_parallel_to_serial

  GENERIC (
    severity_level                      : integer := QVL_ERROR;
    property_type                       : integer := QVL_ASSERT;
    msg                                 : string  := "QVL_VIOLATION : ";
    coverage_level                      : integer := QVL_COVER_NONE;
    width                               : integer := 4;
    latency                             : integer := 0;
    sync_delay                          : integer := 0;
    msb_convert_check                   : integer := 0;
    hold_check                          : integer := 0;
    reversal_check                      : integer := 0;
    consecutive_load_check              : integer := 0
   );

  PORT (
   in_clk          : in std_logic;
   out_clk         : in std_logic;
   in_reset_n      : in std_logic;
   out_reset_n     : in std_logic;
   active          : in std_logic;
   in_active       : in std_logic;
   out_active      : in std_logic;
   load            : in std_logic;
   hold            : in std_logic;
   msb             : in std_logic;
   in_data         : in std_logic_vector((width-1) downto 0);
   out_data        : in std_logic
  );

END COMPONENT; -- qvl_parallel_to_serial

--------------------------------------------------------------------------------
    
COMPONENT qvl_req_ack

  GENERIC (
    severity_level                         : integer := QVL_ERROR;
    property_type                          : integer := QVL_ASSERT;
    msg                                    : string  := "QVL_VIOLATION : ";
    coverage_level                         : integer := QVL_COVER_NONE;
    max                                    : integer := 0;
    max_check                              : integer := 0;
    min                                    : integer := 0;
    no_simultaneous_req_ack                : integer := 0;
    new_req_after_ack                      : integer := 0;
    req_until_ack                          : integer := 0;
    min_max_port_width                     : integer := 32;
    ack_assert_to_req_deassert_max_check   : integer := 0;
    req_deassert_to_ack_deassert_max_check : integer := 0;
    ack_until_req_deassert                 : integer := 0;
    ack_deassert_to_req_deassert_max_check : integer := 0;
    max_ack                                : integer := 0
  );

  PORT (
    clk                              : in std_logic;
    reset_n                          : in std_logic;
    active                           : in std_logic;
    req                              : in std_logic;
    ack                              : in std_logic;
    ack_assert_to_req_deassert_min   : in std_logic_vector(min_max_port_width-1 downto 0);
    ack_assert_to_req_deassert_max   : in std_logic_vector(min_max_port_width-1 downto 0);
    req_deassert_to_ack_deassert_min : in std_logic_vector(min_max_port_width-1 downto 0);
    req_deassert_to_ack_deassert_max : in std_logic_vector(min_max_port_width-1 downto 0);
    ack_deassert_to_req_deassert_min : in std_logic_vector(min_max_port_width-1 downto 0);
    ack_deassert_to_req_deassert_max : in std_logic_vector(min_max_port_width-1 downto 0)
  );

END COMPONENT; -- qvl_req_ack

--------------------------------------------------------------------------------
    
COMPONENT qvl_resource_share
    
  GENERIC (
    severity_level  : integer := QVL_ERROR;
    property_type   : integer := QVL_ASSERT; 
    msg             : string  := "QVL_VIOLATION : ";
    coverage_level  : integer := QVL_COVER_NONE; 
    resource_count  : integer := 1;
    min_idle_check  : integer := 0;
    max_idle_check  : integer := 0;
    min_hold_check  : integer := 0;
    max_hold_check  : integer := 0
   );
    
  PORT (
   clk              : in std_logic;
   reset_n          : in std_logic;
   active           : in std_logic;
   resource_enables : in std_logic_vector((resource_count-1) downto 0);
   min_idle         : in std_logic_vector(31 downto 0);
   max_idle         : in std_logic_vector(31 downto 0);
   min_hold         : in std_logic_vector(31 downto 0);
   max_hold         : in std_logic_vector(31 downto 0)
  );

END COMPONENT; -- qvl_resource_share

--------------------------------------------------------------------------------

COMPONENT qvl_same

  GENERIC (
    severity_level : integer := QVL_ERROR;
    property_type  : integer := QVL_ASSERT;
    msg            : string  := "QVL_VIOLATION : ";
    coverage_level : integer := QVL_COVER_NONE;
    width          : integer := 1;
    count          : integer := 2;
    match_xz       : integer := 0
  );

  PORT (
    clk            : in std_logic;
    reset_n        : in std_logic;
    active         : in std_logic;
    test_expr      : in std_logic_vector((count*width)-1 downto 0)
  );

END COMPONENT; -- qvl_same

--------------------------------------------------------------------------------

COMPONENT qvl_same_bit

  GENERIC (
    severity_level   : integer := QVL_ERROR;
    property_type    : integer := QVL_ASSERT;
    msg              : string  := "QVL_VIOLATION : ";
    coverage_level   : integer := QVL_COVER_NONE;
    width            : integer := 2;
    match_xz         : integer := 0
  );

  PORT (
    clk       : in std_logic;
    reset_n   : in std_logic;
    active    : in std_logic;
    test_expr : in std_logic_vector(width-1 downto 0)
  );

END COMPONENT; -- qvl_same_bit

--------------------------------------------------------------------------------

COMPONENT qvl_same_word

  GENERIC (
    severity_level : integer := QVL_ERROR;
    property_type  : integer := QVL_ASSERT;
    msg            : string  := "QVL_VIOLATION : ";
    coverage_level : integer := QVL_COVER_NONE;
    width          : integer := 1;
    count          : integer := 2;
    match_xz       : integer := 0
  );

  PORT (
    clk       : in std_logic;
    reset_n   : in std_logic;
    active    : in std_logic;
    test_expr : in std_logic_vector((width*count)-1 downto 0)
  );

END COMPONENT; -- qvl_same_word

--------------------------------------------------------------------------------

COMPONENT qvl_scoreboard

  GENERIC (
    severity_level               : integer := QVL_ERROR;
    property_type                : integer := QVL_ASSERT;
    msg                          : string  := "QVL_VIOLATION : ";
    coverage_level               : integer := QVL_COVER_NONE;
    width                        : integer := 6;
    count_width                  : integer := 2;
    min                          : integer := 0;
    max                          : integer := 0;
    max_ids                      : integer := 16;
    max_count_per_id             : integer := 8;
    flush_enable                 : integer := 0;
    flush_count_enable           : integer := 0;
    pre_rx_ids_count             : integer := 0;
    pre_rx_count_width           : integer := 1;
    allow_simultaneous_rx_tx     : integer := 0;
    allow_simultaneous_flush_rx  : integer := 0;
    allow_partial                : integer := 0;
    disallow_rx_when_full        : integer := 0;
    known_ids_check              : integer := 1;
    known_flush_check            : integer := 0
  );

  PORT (
    clk            : in std_logic;
    reset_n        : in std_logic;
    active         : in std_logic;
    rx             : in std_logic;
    rx_id          : in std_logic_vector(width-1 downto 0);
    rx_count       : in std_logic_vector(count_width-1 downto 0);
    tx             : in std_logic;
    tx_id          : in std_logic_vector(width-1 downto 0);
    tx_count       : in std_logic_vector(count_width-1 downto 0);
    flush          : in std_logic;
    flush_id       : in std_logic_vector(width-1 downto 0);
    flush_count    : in std_logic_vector(count_width-1 downto 0);
    pre_rx_ids     : in std_logic_vector(((((2**30 - pre_rx_ids_count)/
                                         2**30) + pre_rx_ids_count) *
                                         width)-1 downto 0);
    pre_rx_counts  : in std_logic_vector((((2**30 - pre_rx_ids_count)/
                                         2**30) + (pre_rx_ids_count*
                                         pre_rx_count_width))-1 downto 0)
  );

END COMPONENT; -- qvl_scoreboard

--------------------------------------------------------------------------------

COMPONENT qvl_serial_to_parallel

  GENERIC (
    severity_level                      : integer := QVL_ERROR;
    property_type                       : integer := QVL_ASSERT;
    msg                                 : string  := "QVL_VIOLATION : ";
    coverage_level                      : integer := QVL_COVER_NONE;
    width                               : integer := 2;
    latency                             : integer := 0;
    sync_delay                          : integer := 0;
    msb_convert_check                   : integer := 0;
    reversal_check                      : integer := 0;
    read_check                          : integer := 0
   );

  PORT (
   out_clk        : in std_logic;
   in_clk         : in std_logic;
   in_reset_n     : in std_logic;
   out_reset_n    : in std_logic;
   active         : in std_logic;
   in_active      : in std_logic;
   out_active     : in std_logic;
   load           : in std_logic;
   read           : in std_logic;
   msb            : in std_logic;
   in_data        : in std_logic;
   out_data       : in std_logic_vector((width-1) downto 0)
  );

END COMPONENT; -- qvl_serial_to_parallel

--------------------------------------------------------------------------------

COMPONENT qvl_stack

  GENERIC (
    severity_level     : integer := QVL_ERROR;
    property_type      : integer := QVL_ASSERT;
    msg                : string  := "QVL_VIOLATION : ";
    coverage_level     : integer := QVL_COVER_NONE;
    width              : integer := 32;
    depth              : integer := 1;
    high_water         : integer := 0;
    latency            : integer := 0;
    preload_count      : integer := 0;
    full_check         : integer := 0;
    empty_check        : integer := 0;
    value_check        : integer := 0
  );
    
  PORT (
    clk       : in std_logic;
    reset_n   : in std_logic;
    active    : in std_logic;
    push      : in std_logic;
    pop       : in std_logic;
    full      : in std_logic;
    empty     : in std_logic;
    push_data : in std_logic_vector(width-1 downto 0);
    pop_data  : in std_logic_vector(width-1 downto 0);
    preload   : in std_logic_vector((31*((1/(1+preload_count)))) +
                                    (preload_count*width) -
                                    ((1-(1/(1+preload_count)))) downto 0)
  );

END COMPONENT; -- qvl_stack

--------------------------------------------------------------------------------

COMPONENT qvl_state_transition

  GENERIC (
   severity_level          : integer :=  QVL_ERROR;
   property_type           : integer :=  QVL_ASSERT;
   msg                     : string  :=  "QVL_VIOLATION : ";
   coverage_level          : integer :=  QVL_COVER_NONE;
   width                   : integer :=  1;
   next_count              : integer :=  1;
   start_enable            : integer :=  0;
   condition_enable        : integer :=  0;
   match_by_cycle          : integer :=  0;
   is_not_check            : integer :=  0
  );

  PORT (
   clk                : in std_logic;
   reset_n            : in std_logic;
   active             : in std_logic;
   test_expr          : in std_logic_vector((width-1) downto 0);
   val                : in std_logic_vector((width-1) downto 0);
   next_val           : in std_logic_vector((next_count*width)-1 downto 0);
   start              : in std_logic;
   condition          : in std_logic_vector(next_count-1 downto 0)
  );

END COMPONENT; -- qvl_state_transition

--------------------------------------------------------------------------------

COMPONENT qvl_timeout

  GENERIC (
    severity_level   : integer := QVL_ERROR;
    property_type    : integer := QVL_ASSERT;
    msg              : string  := "QVL_VIOLATION : ";
    coverage_level   : integer := QVL_COVER_ALL;
    width            : integer := 2;
    val_width        : integer := 1;
    max_possible_val : integer := BIGGEST_INTEGER_32_BIT
  );

  PORT (
    clk       : in std_logic;
    reset_n   : in std_logic;
    active    : in std_logic;
    test_expr : in std_logic_vector(width-1 downto 0);
    val       : in std_logic_vector(val_width-1 downto 0)
  );

END COMPONENT; -- qvl_timeout

--------------------------------------------------------------------------------
    
COMPONENT qvl_three_state
    
  GENERIC (
    severity_level   : integer := QVL_ERROR;
    property_type    : integer := QVL_ASSERT;
    msg              : string  := "QVL_VIOLATION : ";
    coverage_level   : integer := QVL_COVER_NONE;
    width            : integer := 1
  );
    
  PORT (
    clk              : in std_logic;
    reset_n          : in std_logic;
    active           : in std_logic;
    enable           : in std_logic;
    in_data          : in std_logic_vector(width-1 downto 0);
    out_data         : in std_logic_vector(width-1 downto 0)
  );
    
END COMPONENT; -- qvl_three_state

--------------------------------------------------------------------------------

COMPONENT qvl_value

  GENERIC (
    severity_level : integer := QVL_ERROR;
    property_type  : integer := QVL_ASSERT;
    msg            : string  := "QVL_VIOLATION : ";
    coverage_level : integer := QVL_COVER_NONE;
    width          : integer := 4;
    val_width      : integer := 4;
    num_values     : integer := 4;
    value_xz       : integer := 0
   );

  PORT (
    clk       : in std_logic;
    reset_n   : in std_logic;
    active    : in std_logic;
    test_expr : in std_logic_vector(width-1 downto 0);
    is_not    : in std_logic;
    val       : in std_logic_vector(((val_width*num_values)-1) downto 0)
  );

END COMPONENT; -- qvl_value

--------------------------------------------------------------------------------

COMPONENT qvl_value_coverage

  GENERIC (
    severity_level : integer := QVL_ERROR;
    property_type  : integer := QVL_ASSERT;
    msg            : string  := "QVL_VIOLATION : ";
    coverage_level : integer := QVL_COVER_NONE;
    width          : integer := 1;
    is_not_width   : integer := 1;
    is_not_count   : integer := 0;
    value_coverage : integer := 0
  );

  PORT (
    clk       : in std_logic;
    reset_n   : in std_logic;
    active    : in std_logic;
    test_expr : in std_logic_vector(width-1 downto 0);
    is_not    : in std_logic_vector(is_not_width-1 downto 0)
  );

END COMPONENT; -- qvl_value_coverage

--------------------------------------------------------------------------------

COMPONENT qvl_xproduct_bit_coverage

  GENERIC (
    severity_level         : integer := QVL_ERROR;
    property_type          : integer := QVL_ASSERT;
    msg                    : string  := "QVL_VIOLATION : ";
    coverage_level         : integer := QVL_COVER_NONE;
    width1                 : integer := 1;
    width2                 : integer := 1;
    test_expr2_enable      : integer := 0;
    coverage_check         : integer := 0
  );

  PORT (
    clk            : in std_logic;
    reset_n        : in std_logic;
    active         : in std_logic;
    test_expr1     : in std_logic_vector(width1-1 downto 0);
    test_expr2     : in std_logic_vector(width2-1 downto 0)
  );

END COMPONENT; -- qvl_xproduct_bit_coverage

--------------------------------------------------------------------------------

COMPONENT qvl_xproduct_value_coverage

  GENERIC (
    severity_level           : integer := QVL_ERROR;
    property_type            : integer := QVL_ASSERT;
    msg                      : string  := "QVL_VIOLATION : ";
    coverage_level           : integer := QVL_COVER_NONE;
    width1                   : integer := 1;
    width2                   : integer := 1;
    val1_width               : integer := 1;
    val2_width               : integer := 1;
    val1_count               : integer := 0;
    val2_count               : integer := 0;
    min1                     : integer := 0;
    min2                     : integer := 0;
    max1                     : integer := 0;
    max2                     : integer := 0;
    coverage_check           : integer := 0
  );

  PORT (
    clk            : in std_logic;
    reset_n        : in std_logic;
    active         : in std_logic;
    test_expr1     : in std_logic_vector(width1-1 downto 0);
    test_expr2     : in std_logic_vector(width2-1 downto 0);
    val1           : in std_logic_vector((val1_width*val1_count+(0**val1_count)-1) downto 0);
    val2           : in std_logic_vector((val2_width*val2_count+(0**val2_count)-1) downto 0)
  );

END COMPONENT; -- qvl_xproduct_value_coverage

--------------------------------------------------------------------------------

END qvl_checkers;

package body qvl_checkers is

 function log2 (N : positive) return natural is -- N should be power of two.
   variable res : integer;
   variable temp_n : positive;
   begin
     if N/2 /=0 then
       temp_n := N+1;
       res := ceil_log2(temp_n);
     else
       res := ceil_log2(N);
     end if;
     return res;
 end log2;

 function ceil_log2 (N : positive) return natural is
 variable tmp, res : integer;
 variable out_of_range : boolean;
 begin
 tmp:=1 ; res:=0;
 out_of_range:=true;
 for i in 0 to 31 loop
 if tmp < N then
 tmp:=tmp*2;
 else
 res:=i;
 out_of_range:=false;
 exit;
 end if;
 end loop;
 assert not out_of_range report "increase upper bound of for loop in function ceil_log2 (package <the package name> )" severity error;
 return res;
 end ceil_log2;

end package body qvl_checkers;

------------------------------------------------------------------------------

