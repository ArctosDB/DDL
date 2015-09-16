CREATE OR REPLACE PACKAGE parse_list AS
  /*
  || Package of utility procedures for parsing delimited or fixed position strings into tables
  || of individual values, and vice versa.
  */
  TYPE varchar2_table IS TABLE OF VARCHAR2(32767) INDEX BY BINARY_INTEGER;
  PROCEDURE delimstring_to_table
    ( p_delimstring IN VARCHAR2
    , p_table OUT varchar2_table
    , p_nfields OUT INTEGER
    , p_delim IN VARCHAR2 DEFAULT ','
    );
  PROCEDURE table_to_delimstring
    ( p_table IN varchar2_table
    , p_delimstring OUT VARCHAR2
    , p_delim IN VARCHAR2 DEFAULT ','
    );
END parse_list;
/
CREATE OR REPLACE PACKAGE BODY parse_list AS
  PROCEDURE delimstring_to_table
    ( p_delimstring IN VARCHAR2
    , p_table OUT varchar2_table
    , p_nfields OUT INTEGER
    , p_delim IN VARCHAR2 DEFAULT ','
    )
  IS
    v_string VARCHAR2(32767) := p_delimstring;
    v_nfields PLS_INTEGER := 1;
    v_table varchar2_table;
    v_delimpos PLS_INTEGER := INSTR(p_delimstring, p_delim);
    v_delimlen PLS_INTEGER := LENGTH(p_delim);
  BEGIN
    WHILE v_delimpos > 0
    LOOP
      v_table(v_nfields) := SUBSTR(v_string,1,v_delimpos-1);
      v_string := SUBSTR(v_string,v_delimpos+v_delimlen);
      v_nfields := v_nfields+1;
      v_delimpos := INSTR(v_string, p_delim);
    END LOOP;
    v_table(v_nfields) := v_string;
    p_table := v_table;
    p_nfields := v_nfields;
  END delimstring_to_table;
  PROCEDURE table_to_delimstring
    ( p_table IN varchar2_table
    , p_delimstring OUT VARCHAR2
    , p_delim IN VARCHAR2 DEFAULT ','
    )
  IS
    v_nfields PLS_INTEGER := p_table.COUNT;
    v_string VARCHAR2(32767);
  BEGIN
    FOR i IN 1..v_nfields
    LOOP
      v_string := v_string || p_table(i);
      IF i != v_nfields THEN
        v_string := v_string || p_delim;
      END IF;
    END LOOP;
    p_delimstring := v_string;
  END table_to_delimstring;
END parse_list;
/