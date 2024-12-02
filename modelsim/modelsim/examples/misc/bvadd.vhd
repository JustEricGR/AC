--
-- Copyright 1991-2009 Mentor Graphics Corporation
--
-- All Rights Reserved.
--
-- THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
-- MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
--   

-- Example of how to overload an operator 
--
PACKAGE bit_vector_ops IS
    -- overload + for bit vectors
	-- result will be the same size as the left operand
    FUNCTION "+"(left, right : bit_vector) RETURN bit_vector;
END;

PACKAGE BODY bit_vector_ops IS

    FUNCTION "+"(left, right : bit_vector) RETURN bit_vector
    IS
        -- normalize the indexing
        ALIAS left_val : bit_vector(left'length DOWNTO 1) IS left;
        ALIAS right_val : bit_vector(right'length DOWNTO 1) IS right;

        -- arbitrarily make the result the same size as the left input
        VARIABLE result : bit_vector(left_val'RANGE);

        -- temps
        VARIABLE carry : bit := '0';
        VARIABLE right_bit : bit;
        VARIABLE left_bit : bit;
    BEGIN
        FOR i IN result'reverse_range LOOP
            left_bit := left_val(i);

            IF (i <= right_val'high) THEN
                right_bit := right_val(i);
            ELSE
                -- zero extend the right input 
                right_bit := '0';
            END IF;

            result(i) := (left_bit XOR right_bit) XOR carry;
            carry := (left_bit  AND right_bit)
                  OR (left_bit  AND carry)
                  OR (right_bit AND carry);
        END LOOP;
        RETURN result;
    END "+";

END bit_vector_ops;


-- simple test architecture
ENTITY bvtest IS END;
USE work.bit_vector_ops.ALL;
ARCHITECTURE test_add OF bvtest IS
BEGIN
    PROCESS
    BEGIN
        ASSERT "000" + "000" = "000";
        ASSERT "000" + "001" = "001";
        ASSERT "001" + "001" = "010";
        ASSERT "110" + "111" = "101";
        ASSERT "011" +   "1" = "100";
        ASSERT "011" + "1000001" = "100";
        ASSERT false REPORT "Test complete" SEVERITY note;
        WAIT;
    END PROCESS;
END;

