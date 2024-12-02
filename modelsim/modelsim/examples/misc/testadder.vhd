--
-- Copyright 1991-2009 Mentor Graphics Corporation
--
-- All Rights Reserved.
--
-- THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
-- MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
--   

entity testbench is
end;

------------------------------------------------------------------------
-- testbench for 8-bit adder
------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
architecture adder8 of testbench is 
    component adderN 
	generic(N : integer);
	port (a    : in std_logic_vector(N downto 1);
	      b    : in std_logic_vector(N downto 1);
	      cin  : in std_logic;
	      sum  : out std_logic_vector(N downto 1);
	      cout : out std_logic);
    end component;

    constant N : integer := 8;

    signal a    : std_logic_vector(N downto 1);
    signal b    : std_logic_vector(N downto 1);
    signal cin  : std_logic;
    signal sum  : std_logic_vector(N downto 1);
    signal cout : std_logic;

    type test_record_t is record
	a :  std_logic_vector(N downto 1);
	b :  std_logic_vector(N downto 1);
	cin :  std_logic;
	sum :  std_logic_vector(N downto 1);
	cout :  std_logic;
    end record;
    type test_array_t is array(positive range <>) of test_record_t;

    constant test_patterns : test_array_t := (
	(a => "00000000", b => "00000001", cin => '0', sum => "00000001", cout => '0'),
	(a => "00000001", b => "00000001", cin => '0', sum => "00000010", cout => '0'),
	(a => "00000001", b => "00000001", cin => '1', sum => "00000011", cout => '0'),
	(a => "00001010", b => "00000011", cin => '0', sum => "00001101", cout => '0'),
	(a => "00000011", b => "00001010", cin => '0', sum => "00001101", cout => '0'),
	(a => "00000101", b => "00000001", cin => '1', sum => "00001000", cout => '0'),
	(a => "00000011", b => "11111100", cin => '0', sum => "11111111", cout => '0'),
	(a => "00000011", b => "11111100", cin => '1', sum => "00000000", cout => '1'),
	(a => "01010101", b => "01010101", cin => '0', sum => "10101010", cout => '0'),
	(a => "00000000", b => "00000000", cin => '0', sum => "00000000", cout => '0')
    );

    --
    -- convert a std_logic value to a character
    --
    type stdlogic_to_char_t is array(std_logic) of character;
    constant to_char : stdlogic_to_char_t := (
	'U' => 'U',
	'X' => 'X',
	'0' => '0',
	'1' => '1',
	'Z' => 'Z',
	'W' => 'W',
	'L' => 'L',
	'H' => 'H',
	'-' => '-');

    --
    -- convert a std_logic_vector to a string
    --
    function to_string(inp : std_logic_vector)
    return string
    is
	alias vec : std_logic_vector(1 to inp'length) is inp;
	variable result : string(vec'range);
    begin
	for i in vec'range loop
	    result(i) := to_char(vec(i));
	end loop;
	return result;
    end;

begin
    -- instantiate the component
    uut: adderN generic map(N)
		port map(a => a,
			 b => b,
			 cin => cin,
			 sum => sum,
			 cout => cout);
 
    -- provide stimulus and check the result
    test: process
	variable vector : test_record_t;
	variable found_error : boolean := false;
    begin
	for i in test_patterns'range loop
	    vector := test_patterns(i);

	    -- apply the stimuls
	    a <= vector.a;
	    b <= vector.b;
	    cin <= vector.cin;

	    -- wait for the outputs to settle
	    wait for 100 ns;

	    -- check the results
	    if (sum  /= vector.sum) then
		assert false
		    report "Sum is " & to_string(sum)
		    & ". Expected " & to_string(vector.sum);
		found_error := true;
	    end if;
	    if (cout /= vector.cout) then
		assert false
		    report "Cout is " & to_char(cout) & ". "
		    & "Expected value is " & to_char(vector.cout);
		found_error := true;
	    end if;
	end loop;

	assert not found_error
	  report "There were ERRORS in the test."
	  severity note;
	assert found_error
	  report "Test completed with no errors."
	  severity note;
	wait;
    end process;
end;


configuration test_adder_behavioral of testbench is
    for adder8
	for all: adderN 
	    use entity work.adderN(behavioral);
	end for;
    end for;
end test_adder_behavioral;


configuration test_adder_structural of testbench is
    for adder8
	for all: adderN 
	    use entity work.adderN(structural);
	    for structural
		-- configure the components that are generated 
		for gen
		    for all : adder
			use entity work.adder(structural);
		    end for;
		end for;
	    end for;
	end for;
    end for;
end test_adder_structural;
