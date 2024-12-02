--
-- Copyright 1991-2009 Mentor Graphics Corporation
--
-- All Rights Reserved.
--
-- THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
-- MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
--   

ENTITY pal16r8 IS
    GENERIC (fuse_map_filename : string := "counter.jed");
    PORT (clk : bit;                            -- pin 1
          data_in : bit_vector(2 TO 9);         -- pins 2 to 9
          oe  : bit;                            -- pin 11
          data_out : OUT bit_vector(12 TO 19)); -- pins 12 to 19
END pal16r8;

USE work.jedec.ALL;
ARCHITECTURE gen OF pal16r8 IS

    CONSTANT rows : positive := 64;
    CONSTANT cols : positive := 32;
    CONSTANT fuse : fuse_array := read_jedec(fuse_map_filename, rows, cols);
    CONSTANT connected : bit := '0';

    TYPE source_kinds IS (normal_input, inverted_input, normal_register, inverted_register);
    TYPE source_kinds_vec IS ARRAY(integer RANGE <>) OF source_kinds;
    TYPE lookup_table IS ARRAY(integer RANGE <>) OF integer;

    SIGNAL reg_out : bit_vector(12 TO 19);
    SIGNAL or_out : resolve_or_vector(0 TO 7);

    -- convert the fuse map row number to the index of the input
    -- or register that is connected to it
    CONSTANT column_to_index : lookup_table(0 TO 31) := (
        -- data inputs
         0 |  1 => 2,
         4 |  5 => 3,
         8 |  9 => 4,
        12 | 13 => 5,
        16 | 17 => 6,
        20 | 21 => 7,
        24 | 25 => 8,
        28 | 29 => 9,

        -- register feedback
         2 |  3 => 19,
         6 |  7 => 18,
        10 | 11 => 17,
        14 | 15 => 16,
        18 | 19 => 15,
        22 | 23 => 14,
        26 | 27 => 13,
        30 | 31 => 12);

    -- describe the type of input connected to each of the rows
    CONSTANT source_type : source_kinds_vec(0 TO 31) := (
        0 | 4 | 8  | 12 | 16 | 20 | 24 | 28 => normal_input,
        1 | 5 | 9  | 13 | 17 | 21 | 25 | 29 => inverted_input,
        2 | 6 | 10 | 14 | 18 | 22 | 26 | 30 => inverted_register,
        3 | 7 | 11 | 15 | 19 | 23 | 27 | 31 => normal_register);

    -- count the number of fuses connected to a row
    FUNCTION fuses_connected(row : natural) RETURN natural IS
        VARIABLE cnt : natural := 0;
    BEGIN
        FOR col IN 0 TO 31 LOOP
            IF (fuse(row, col) = connected) THEN
                cnt := cnt + 1;
            END IF;
        END LOOP;
        RETURN cnt;
    END;
        

    -- 
    --  Several functions to reduce the clutter in the generate statements
    --
    FUNCTION is_normal_input(row, col : natural) RETURN boolean IS
    BEGIN
        RETURN ((fuse(row, col) = connected) AND (source_type(col) = normal_input));
    END;

    FUNCTION is_inverted_input(row, col : natural) RETURN boolean IS
    BEGIN
        RETURN ((fuse(row, col) = connected) AND (source_type(col) = inverted_input));
    END;

    FUNCTION is_normal_register(row, col : natural) RETURN boolean IS
    BEGIN
        RETURN ((fuse(row, col) = connected) AND (source_type(col) = normal_register));
    END;

    FUNCTION is_inverted_register(row, col : natural) RETURN boolean IS
    BEGIN
        RETURN ((fuse(row, col) = connected) AND (source_type(col) = inverted_register));
    END;


BEGIN

    PROCESS(oe, reg_out)
    BEGIN
        CASE oe IS 
            WHEN '0' => data_out <= reg_out;
            WHEN '1' => data_out <= "11111111";
            WHEN OTHERS => NULL;
        END CASE;
    END PROCESS;

    PROCESS(clk)
    BEGIN
        IF clk'event AND clk = '1' THEN
            reg_out <= bit_vector(or_out);
        END IF;
    END PROCESS;

    -- generate the and/or plane
    gen_ors:
    FOR or_num IN or_out'RANGE GENERATE

        -- look at all the ANDs feeding into this OR
        gen_ands:
        FOR row IN or_num*8 TO or_num*8 + 7 GENERATE

            gen_and0:
            IF (fuses_connected(row) = 0) GENERATE
                or_out(or_num) <= '1';
            END GENERATE;

            gen_and1:
            IF (fuses_connected(row) = 1) GENERATE
                gen_fuse:
                FOR col IN 0 TO 31 GENERATE
                    g1:
                    IF (is_normal_input(row, col)) GENERATE
                        or_out(or_num) <= data_in(column_to_index(col));
                    END GENERATE;
                    g2:
                    IF (is_inverted_input(row, col)) GENERATE
                        or_out(or_num) <= NOT data_in(column_to_index(col));
                    END GENERATE;
                    g3:
                    IF (is_normal_register(row, col)) GENERATE
                        or_out(or_num) <= reg_out(column_to_index(col));
                    END GENERATE;
                    g4:
                    IF (is_inverted_register(row, col)) GENERATE
                        or_out(or_num) <= NOT reg_out(column_to_index(col));
                    END GENERATE;
                END GENERATE;
            END GENERATE;

            gen_and2:
            IF ((fuses_connected(row) > 1) AND (fuses_connected(row) < 16)) GENERATE
                b:BLOCK
                    PORT(anded_value : OUT resolve_and bit);
                    PORT MAP(anded_value => or_out(or_num));
                BEGIN
                    gen_fuse:
                    FOR col IN 0 TO 31 GENERATE
                        g1:
                        IF (is_normal_input(row, col)) GENERATE
                            anded_value <= data_in(column_to_index(col));
                        END GENERATE;
                        g2:
                        IF (is_inverted_input(row, col)) GENERATE
                            anded_value <= NOT data_in(column_to_index(col));
                        END GENERATE;
                        g3:
                        IF (is_normal_register(row, col)) GENERATE
                            anded_value <= reg_out(column_to_index(col));
                        END GENERATE;
                        g4:
                        IF (is_inverted_register(row, col)) GENERATE
                            anded_value <= NOT reg_out(column_to_index(col));
                        END GENERATE;
                    END GENERATE;
                END BLOCK;
            END GENERATE;

        END GENERATE;

    END GENERATE;

END;
