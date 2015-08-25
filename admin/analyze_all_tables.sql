DECLARE s varchar2(4000);
BEGIN
    FOR t IN (SELECT table_name FROM USEr_tables) LOOP
        s:='analyze table ' || t.table_name || ' compute statistics';
        dbms_output.put_line(s);
        execute immediate(s);
    END LOOP;
END;
/