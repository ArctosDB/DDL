CREATE OR REPLACE PROCEDURE bulk_stage_junkstripper
AS
	s varchar2(4000);
	clist varchar2(4000);
	sep varchar2(20);
BEGIN
	
	for r in (select column_name from user_tab_cols where table_name=upper('bulkloader_stage')) loop
		--s:='update pre_bulkloader set ' || r.column_name || '=trim(' || r.column_name || ') where ' ||  r.column_name || ' != trim(' || r.column_name || ')';
		s:='update bulkloader_stage set ' || r.column_name || '=trim(' || r.column_name || ')';
		--dbms_output.put_line(s);
		execute immediate s;
		s:='update bulkloader_stage set ' || r.column_name || '=regexp_replace(' || r.column_name || ',''[^[:print:]]'','''') where regexp_like(' || r.column_name || ',''[^[:print:]]'')';
		--dbms_output.put_line(s);
		execute immediate s;
	end loop;
end;
/

create or replace public synonym bulk_stage_junkstripper for bulk_stage_junkstripper;

grant execute on bulk_stage_junkstripper to data_entry;

