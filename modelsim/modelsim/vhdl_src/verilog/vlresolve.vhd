--
-- Copyright 1991-2009 Mentor Graphics Corporation
--
-- All Rights Reserved.
--
-- THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
-- MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
--   
package vl_resolve is
	function modelsim_to_BitVectorFromCharEnum (s : character) return bit_vector;
	function modelsim_to_BitVectorFromIntegerEnum(s : integer) return bit_vector;
	function modelsim_to_CharEnumFromBitVector (s : bit_vector) return character;
	function modelsim_to_IntegerEnumFromBitVector (s : bit_vector) return integer;
end vl_resolve;

package body vl_resolve is
	function modelsim_to_BitVectorFromCharEnum(s : character) return bit_vector is
		variable v : integer := character'pos(s);
		variable return_vec : bit_vector(31 downto 0) := "00000000000000000000000000000000";
	begin
		for i in 0 to 7 loop
			if (v mod 2) /= 0 then 
				return_vec(i) := '1';
			end if;
			v := v/2;
		end loop;
		return return_vec;
	end modelsim_to_BitVectorFromCharEnum;

	function modelsim_to_BitVectorFromIntegerEnum(s : integer) return bit_vector is
		variable v : integer := s;
		variable return_vec : bit_vector(31 downto 0) := "00000000000000000000000000000000";
	begin
		for i in 0 to 31 loop
			if (v mod 2) /= 0 then 
				return_vec(i) := '1';
			end if;
			v := v/2;
		end loop;
		return return_vec;
	end modelsim_to_BitVectorFromIntegerEnum;

	function modelsim_to_CharEnumFromBitVector (s : bit_vector) return character is
		variable len : integer;
		variable result : integer := 0;
	begin
		if (s'length < 8) then
			len := s'length;
		else
			len := 8;
		end if;

		for i in 0 to len - 1 loop
			if s(i) = '1' then
				result := result + 2**i;
			end if;
		end loop;
		return character'val(result);
	end modelsim_to_CharEnumFromBitVector;

	function modelsim_to_IntegerEnumFromBitVector (s : bit_vector) return integer is
		variable len : integer;
		variable result : integer := 0;
	begin
		for i in 0 to s'length loop
			if s(i) = '1' then
				result := result + 2**i;
			end if;
		end loop;
		return result;
	end modelsim_to_IntegerEnumFromBitVector;

end vl_resolve;
