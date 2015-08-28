CREATE OR REPLACE FUNCTION md5hash (str IN VARCHAR2)
    RETURN VARCHAR2
    IS v_checksum VARCHAR2(32);

    BEGIN
      if str is null then
        return null;
      end if;

        v_checksum := LOWER( RAWTOHEX( UTL_RAW.CAST_TO_RAW( sys.dbms_obfuscation_toolkit.md5(input_string => str) ) ) );
        RETURN v_checksum;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            NULL;
        WHEN OTHERS THEN
            -- Consider logging the error and then re-raise
            RAISE;
    END md5hash;
/

create or replace public synonym md5hash for md5hash;
grant execute on md5hash to public;