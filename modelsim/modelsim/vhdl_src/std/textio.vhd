---------------------------------------------------------------------------
-- Package TEXTIO as defined in Chapter 14 of the IEEE Standard VHDL
--   Language Reference Manual (IEEE Std. 1076-1987), as modified
--   by the Issues Screening and Analysis Committee (ISAC), a subcommittee
--   of the VHDL Analysis and Standardization Group (VASG) on 
--   10 November, 1988.  See "The Sense of the VASG", October, 1989.
--   VHDL2008 features added.
---------------------------------------------------------------------------
-- Version information: %W% %G%
---------------------------------------------------------------------------

package TEXTIO is
    type LINE is access string;
--  procedure DEALLOCATE (P : inout LINE);
    
    type TEXT is file of string;
--  procedure FLUSH (file F : TEXT);

    type SIDE is (right, left);
--  function MINIMUM (L, R : SIDE) return SIDE;
--  function MAXIMUM (L, R : SIDE) return SIDE;

--  function TO_STRING (VALUE : SIDE) return STRING;
    subtype WIDTH is natural;

    function JUSTIFY (VALUE : STRING; JUSTIFIED : SIDE := right; FIELD : WIDTH := 0) return STRING;

	-- changed for vhdl92 syntax:
    file input : TEXT open read_mode is "STD_INPUT";
    file output : TEXT open write_mode is "STD_OUTPUT";

	-- changed for vhdl92 syntax (and now a built-in):
    procedure READLINE(file f: TEXT; L: out LINE);

    procedure READ(L:inout LINE; VALUE: out bit; GOOD : out BOOLEAN);
    procedure READ(L:inout LINE; VALUE: out bit);

    procedure READ(L:inout LINE; VALUE: out bit_vector; GOOD : out BOOLEAN);
    procedure READ(L:inout LINE; VALUE: out bit_vector);

    procedure READ(L:inout LINE; VALUE: out BOOLEAN; GOOD : out BOOLEAN);
    procedure READ(L:inout LINE; VALUE: out BOOLEAN);

    procedure READ(L:inout LINE; VALUE: out character; GOOD : out BOOLEAN);
    procedure READ(L:inout LINE; VALUE: out character);

    procedure READ(L:inout LINE; VALUE: out integer; GOOD : out BOOLEAN);
    procedure READ(L:inout LINE; VALUE: out integer);

    procedure READ(L:inout LINE; VALUE: out real; GOOD : out BOOLEAN);
    procedure READ(L:inout LINE; VALUE: out real);

    procedure READ(L:inout LINE; VALUE: out string; GOOD : out BOOLEAN);
    procedure READ(L:inout LINE; VALUE: out string);

    procedure READ(L:inout LINE; VALUE: out time; GOOD : out BOOLEAN);
    procedure READ(L:inout LINE; VALUE: out time);

    procedure SREAD (L    : inout LINE; VALUE : out STRING; STRLEN : out NATURAL);
    alias STRING_READ is SREAD [LINE, STRING, NATURAL];
    alias BREAD is READ [LINE, BIT_VECTOR, BOOLEAN];
    alias BREAD is READ [LINE, BIT_VECTOR];
    alias BINARY_READ is READ [LINE, BIT_VECTOR, BOOLEAN];
    alias BINARY_READ is READ [LINE, BIT_VECTOR];

    procedure OREAD (L    : inout LINE; VALUE : out BIT_VECTOR; GOOD : out BOOLEAN);

    procedure OREAD (L    : inout LINE; VALUE : out BIT_VECTOR);
    alias OCTAL_READ is OREAD [LINE, BIT_VECTOR, BOOLEAN];
    alias OCTAL_READ is OREAD [LINE, BIT_VECTOR];

    procedure HREAD (L    : inout LINE; VALUE : out BIT_VECTOR; GOOD : out BOOLEAN);

    procedure HREAD (L    : inout LINE; VALUE : out BIT_VECTOR);
    alias HEX_READ is HREAD [LINE, BIT_VECTOR, BOOLEAN];
    alias HEX_READ is HREAD [LINE, BIT_VECTOR];

	-- changed for vhdl92 syntax (and now a built-in):
    procedure WRITELINE(file f : TEXT; L : inout LINE);

    procedure TEE (file F :       TEXT; L : inout LINE);

    procedure WRITE(L : inout LINE; VALUE : in bit;
	      JUSTIFIED: in SIDE := right;
	      FIELD: in WIDTH := 0);

    procedure WRITE(L : inout LINE; VALUE : in bit_vector;
	      JUSTIFIED: in SIDE := right;
	      FIELD: in WIDTH := 0);

    procedure WRITE(L : inout LINE; VALUE : in BOOLEAN;
	      JUSTIFIED: in SIDE := right;
	      FIELD: in WIDTH := 0);

    procedure WRITE(L : inout LINE; VALUE : in character;
	      JUSTIFIED: in SIDE := right;
	      FIELD: in WIDTH := 0);

    procedure WRITE(L : inout LINE; VALUE : in integer;
	      JUSTIFIED: in SIDE := right;
	      FIELD: in WIDTH := 0);

    procedure WRITE(L : inout LINE; VALUE : in real;
	      JUSTIFIED: in SIDE := right;
	      FIELD: in WIDTH := 0;
	      DIGITS: in NATURAL := 0);

    procedure WRITE (L      : inout LINE; VALUE : in REAL;
                   FORMAT : in    STRING);

    procedure WRITE(L : inout LINE; VALUE : in string;
	      JUSTIFIED: in SIDE := right;
	      FIELD: in WIDTH := 0);

    procedure WRITE(L : inout LINE; VALUE : in time;
	      JUSTIFIED: in SIDE := right;
	      FIELD: in WIDTH := 0;
	      UNIT: in TIME := ns);

    alias SWRITE is WRITE [LINE, STRING, SIDE, WIDTH];
    alias STRING_WRITE is WRITE [LINE, STRING, SIDE, WIDTH];
    alias BWRITE is WRITE [LINE, BIT_VECTOR, SIDE, WIDTH];
    alias BINARY_WRITE is WRITE [LINE, BIT_VECTOR, SIDE, WIDTH];
    
    procedure OWRITE (L         : inout LINE; VALUE : in BIT_VECTOR;
                    JUSTIFIED : in    SIDE := right; FIELD : in WIDTH := 0);
   alias OCTAL_WRITE is OWRITE [LINE, BIT_VECTOR, SIDE, WIDTH];
   procedure HWRITE (L         : inout LINE; VALUE : in BIT_VECTOR;
                    JUSTIFIED : in    SIDE := right; FIELD : in WIDTH := 0);
   alias HEX_WRITE is HWRITE [LINE, BIT_VECTOR, SIDE, WIDTH];

	-- is implicit built-in:
	-- function ENDFILE(file F : TEXT) return boolean;

    -- function ENDLINE(variable L : in LINE) return BOOLEAN;
    --
    -- Function ENDLINE as declared cannot be legal VHDL, and
    --   the entire function was deleted from the definition
    --   by the Issues Screening and Analysis Committee (ISAC),
    --   a subcommittee of the VHDL Analysis and Standardization
    --   Group (VASG) on 10 November, 1988.  See "The Sense of
    --   the VASG", October, 1989, VHDL Issue Number 0032.
end;

--*******************************************************
--**                                                   **
--** Copyright 1991-2009 Mentor Graphics Corporation      **
--**                                                   **
--** All Rights Reserved                               **
--**                                                   **
--** THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY   **
--** INFORMATION WHICH IS THE PROPERTY OF MENTOR       **
--** GRAPHICS CORPORATION OR ITS LICENSORS AND IS      **
--** SUBJECT TO LICENSE TERMS.                         **
--**                                                   **
--*******************************************************


--   There is no true source-code package body for textio
--   since the code is all accellerated

package body TEXTIO is

    function JUSTIFY (VALUE : STRING; JUSTIFIED : SIDE := right; FIELD : WIDTH := 0) return STRING is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
      return value;
    end;

    procedure READLINE(file f: TEXT; L: out LINE) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure READ(L:inout LINE; VALUE: out bit; GOOD : out BOOLEAN) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;
      
    procedure READ(L:inout LINE; VALUE: out bit) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure READ(L:inout LINE; VALUE: out bit_vector; GOOD : out BOOLEAN) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;
      
    procedure READ(L:inout LINE; VALUE: out bit_vector) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure READ(L:inout LINE; VALUE: out BOOLEAN; GOOD : out BOOLEAN) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;
      
    procedure READ(L:inout LINE; VALUE: out BOOLEAN) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure READ(L:inout LINE; VALUE: out character; GOOD : out BOOLEAN) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;
      
    procedure READ(L:inout LINE; VALUE: out character) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure READ(L:inout LINE; VALUE: out integer; GOOD : out BOOLEAN) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;
      
    procedure READ(L:inout LINE; VALUE: out integer) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure READ(L:inout LINE; VALUE: out real; GOOD : out BOOLEAN) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;
      
    procedure READ(L:inout LINE; VALUE: out real) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure READ(L:inout LINE; VALUE: out string; GOOD : out BOOLEAN) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;
      
    procedure READ(L:inout LINE; VALUE: out string) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure READ(L:inout LINE; VALUE: out time; GOOD : out BOOLEAN) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;
      
    procedure READ(L:inout LINE; VALUE: out time) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure SREAD (L    : inout LINE; VALUE : out STRING; STRLEN : out NATURAL) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure OREAD (L    : inout LINE; VALUE : out BIT_VECTOR; GOOD : out BOOLEAN) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;
      
    procedure OREAD (L    : inout LINE; VALUE : out BIT_VECTOR) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure HREAD (L    : inout LINE; VALUE : out BIT_VECTOR; GOOD : out BOOLEAN) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;
    
    procedure HREAD (L    : inout LINE; VALUE : out BIT_VECTOR) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;
    
    procedure WRITELINE(file f : TEXT; L : inout LINE) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure TEE (file F :       TEXT; L : inout LINE) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure WRITE(L : inout LINE; VALUE : in bit;
	      JUSTIFIED: in SIDE := right; FIELD: in WIDTH := 0) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure WRITE(L : inout LINE; VALUE : in bit_vector;
	      JUSTIFIED: in SIDE := right; FIELD: in WIDTH := 0) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure WRITE(L : inout LINE; VALUE : in BOOLEAN;
	      JUSTIFIED: in SIDE := right; FIELD: in WIDTH := 0) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure WRITE(L : inout LINE; VALUE : in character;
	      JUSTIFIED: in SIDE := right; FIELD: in WIDTH := 0) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure WRITE(L : inout LINE; VALUE : in integer;
	      JUSTIFIED: in SIDE := right; FIELD: in WIDTH := 0) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure WRITE(L : inout LINE; VALUE : in real;
	      JUSTIFIED: in SIDE := right; FIELD: in WIDTH := 0;
	      DIGITS: in NATURAL := 0) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure WRITE (L      : inout LINE; VALUE : in REAL;
          FORMAT : in    STRING) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure WRITE(L : inout LINE; VALUE : in STRING;
	      JUSTIFIED: in SIDE := right; FIELD: in WIDTH := 0) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure WRITE(L : inout LINE; VALUE : in TIME;
	      JUSTIFIED: in SIDE := right;
	      FIELD: in WIDTH := 0;
	      UNIT: in TIME := ns) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

    procedure OWRITE (L         : inout LINE; VALUE : in BIT_VECTOR;
                    JUSTIFIED : in    SIDE := right; FIELD : in WIDTH := 0) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;
     
    procedure HWRITE (L         : inout LINE; VALUE : in BIT_VECTOR;
                    JUSTIFIED : in    SIDE := right; FIELD : in WIDTH := 0) is
    begin
      assert false report "ERROR: builtin subprogram not called" severity note;
    end;

end textio;
