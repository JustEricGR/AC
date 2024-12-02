--
-- Copyright 1991-2009 Mentor Graphics Corporation
--
-- All Rights Reserved.
--
-- THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
-- MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
--   

PACKAGE jedec IS
    TYPE fuse_array IS ARRAY(integer RANGE <>, integer RANGE <>) OF bit;

    FUNCTION read_jedec(file_name : string;
                        row_cnt  : positive;
                        col_cnt  : positive) RETURN fuse_array;
    FUNCTION resolve_or(driver_vals : bit_vector) RETURN bit;
    FUNCTION resolve_and(driver_vals : bit_vector) RETURN bit;

    SUBTYPE resolve_or_bit IS resolve_or bit;
    TYPE resolve_or_vector IS ARRAY(integer RANGE <>) OF resolve_or_bit;

END jedec;

USE std.textio.ALL;
PACKAGE BODY jedec IS

    FUNCTION read_jedec(file_name : string;
                        row_cnt  : positive;
                        col_cnt  : positive) RETURN fuse_array
    IS
        FILE jedec_file : text IS IN file_name;
        CONSTANT fuse_cnt : integer := row_cnt * col_cnt;
        VARIABLE fuse_2d : fuse_array(0 TO row_cnt - 1, 0 TO col_cnt - 1);
        VARIABLE fuse_1d : bit_vector(0 TO fuse_cnt - 1);
        VARIABLE buf : line;
        VARIABLE fuse_number : natural;
        VARIABLE c : character;
        VARIABLE default_fuse_state : bit := '0';
        VARIABLE zero_count : integer := 0;
        VARIABLE l : line;

        PROCEDURE fill_buf IS
        BEGIN
            WHILE (buf = NULL) OR (buf'length = 0) LOOP
                EXIT WHEN endfile(jedec_file);
                readline(jedec_file, buf);
            END LOOP;
        END fill_buf;

        PROCEDURE getchar(VARIABLE char : OUT character) IS
        BEGIN
            fill_buf;
            IF (buf = NULL) OR (buf'length = 0) THEN
                char := '*';
            ELSE read(buf, char);
            END IF;
        END getchar;

        PROCEDURE getint(VARIABLE int : OUT integer) IS
        BEGIN
            fill_buf;
            read(buf, int);
        END getint;

        PROCEDURE getbit(VARIABLE b : OUT bit) IS
        BEGIN
            fill_buf;
            read(buf, b);
        END getbit;

        PROCEDURE skip_to_next_field IS
            VARIABLE c : character;
        BEGIN
            LOOP
                getchar(c);
                EXIT WHEN (c = '*');
            END LOOP;
        END skip_to_next_field;

    BEGIN
        ASSERT false
           REPORT "Loading JEDEC file " & file_name
           SEVERITY note;
        WHILE NOT endfile(jedec_file) LOOP
            IF (c /= '*') THEN
                skip_to_next_field;
            END IF;
            getchar(c);
            CASE c IS

                WHEN 'f' =>
                    getbit(default_fuse_state);
                    IF (default_fuse_state /= '0') THEN
                        fuse_1d := (OTHERS => default_fuse_state);
                    END IF;

                WHEN 'l' =>
                    getint(fuse_number);
                    fuse_loop: LOOP
                        getchar(c);
                        CASE c IS
                            WHEN '0' =>
                                fuse_1d(fuse_number) := '0';
                                fuse_number := fuse_number + 1;
                                zero_count := zero_count + 1;
                            WHEN '1' =>
                                fuse_1d(fuse_number) := '1';
                                fuse_number := fuse_number + 1;
                            WHEN '*' =>
                                EXIT fuse_loop;
                            WHEN OTHERS =>
                                NULL;
                        END CASE;
                    END LOOP fuse_loop;

                WHEN OTHERS =>
                    NULL;
            END CASE;
            
        END LOOP;

        -- copy the 1-d fuse map to the 2-d map 
        fuse_number := 0;
        FOR i IN 0 TO row_cnt - 1 LOOP
            FOR j IN 0 TO col_cnt - 1 LOOP
                fuse_2d(i, j) := fuse_1d(fuse_number);
                fuse_number := fuse_number + 1;
            END LOOP;
        END LOOP;

        write(l, zero_count);
        ASSERT false
           REPORT "Complete loading JEDEC file " & file_name 
                & ". There were " 
                & l.ALL
                & " explicit zeros."
           SEVERITY note;

        RETURN fuse_2d;
    END read_jedec;

    FUNCTION resolve_or(driver_vals : bit_vector) RETURN bit IS
        VARIABLE result : bit := '0';
    BEGIN
        FOR i IN driver_vals'RANGE LOOP
            result := result OR driver_vals(i);
        END LOOP;
        RETURN result;
    END;

    FUNCTION resolve_and(driver_vals : bit_vector) RETURN bit IS
        VARIABLE result : bit := '1';
    BEGIN
        FOR i IN driver_vals'RANGE LOOP
            result := result AND driver_vals(i);
        END LOOP;
        RETURN result;
    END;

END jedec;

