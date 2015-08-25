begin
for tn in (select table_name from user_tables where table_name like 'CF_%'
) loop
        execute immediate 'grant all on ' || tn.table_name || ' to cf_dbuser';
        dbms_output.put_line('grant all on ' || tn.table_name || ' to cf_dbuser');
end loop;
end;
/