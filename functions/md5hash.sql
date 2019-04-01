CREATE OR REPLACE FUNCTION md5hash (str IN clob)
    RETURN VARCHAR2
    IS v_checksum VARCHAR2(32);
    BEGIN
      if str is null then
        return null;
      end if;
        v_checksum := LOWER( RAWTOHEX( UTL_RAW.CAST_TO_RAW( sys.dbms_obfuscation_toolkit.md5(input_string => str) ) ) );
        
        RETURN v_checksum;
        EXCEPTION
           WHEN OTHERS THEN
           -- this function is mostly used to determine if two things are the same
           -- the safe assumption is that they are not
           -- on fail, just return something that should never match anything
           v_checksum := LOWER( RAWTOHEX( UTL_RAW.CAST_TO_RAW( sys.dbms_obfuscation_toolkit.md5(input_string => SYS_GUID()) ) ) );
           RETURN v_checksum;
        
        --    RAISE;
      --  return 'not skippy';
    END md5hash;
/

create or replace public synonym md5hash for md5hash;
grant execute on md5hash to public;

select md5hash(WKT_POLYGON) from locality where LOCALITY_ID=10819659;


SELECT dbms_crypto.hash(to_clob(lpad(' ', 4000, ' ')) ||to_clob(' '), 1) my_ohc FROM dual;

select dbms_lob.getlength(WKT_POLYGON) from locality where LOCALITY_ID=10819659;