-- create a relationship of type 'rel' in both directions between 2 taxa IF they do not have any existing relationships
CREATE OR REPLACE PROCEDURE makeRecipTaxRel(id1 IN number, id2 in number, rel in varchar2)
is
	c number;
begin
	select sum(c) into c from (
		select count(*) c from taxon_relations where TAXON_NAME_ID=id1 and RELATED_TAXON_NAME_ID=id2
		union
		select count(*) c from taxon_relations where TAXON_NAME_ID=id2 and RELATED_TAXON_NAME_ID=id1
	);
	
	if c = 0 then
		--dbms_output.put_line('creating a relationships....');
		insert into taxon_relations (
			TAXON_RELATIONS_ID,
			TAXON_NAME_ID,
			RELATED_TAXON_NAME_ID,
			TAXON_RELATIONSHIP
		) values (
			sq_TAXON_RELATIONS_ID.nextval,
			id1,
			id2,
			rel
		);
		-- reciprocal
		insert into taxon_relations (
			TAXON_RELATIONS_ID,
			TAXON_NAME_ID,
			RELATED_TAXON_NAME_ID,
			TAXON_RELATIONSHIP
		) values (
			sq_TAXON_RELATIONS_ID.nextval,
			id2,
			id1,
			rel
		);
	end if;
end;
/

 -- log that a name has been checked
  create table cf_temp_potentialduptax_ck (
 	taxon_name_id number,
 	lastdate date
 );
 
   
 -- this can go away once we start making relationships
 create table cf_temp_potentialduptax (
 	taxon_name_id number,
 	duplication_taxon_name_id number,
 	lastdate date
 );
 
 -- function to find variants and return IDs
CREATE OR REPLACE function find_taxonomy_variations (v_name in varchar) return varchar2
 -- from a name, return ID(s) of potential alternate names
is
    name_var taxon_name.scientific_name%TYPE;
    tidlist varchar2(4000):='';
    sep varchar2(10);    
    arrow number := 0;
    TYPE t_tab IS TABLE OF number;
    t_val    t_tab := t_tab ();
    c number;
    r_tid number;
    t_ptrn varchar2(255);
    ptn_one varchar2(255);
    ptn_two varchar2(255);
    type nt_type is table of VARCHAR2(30);
 	nt nt_type := nt_type(
 		'aensis/ensis','alis/ata','ata/ula','atifolia/ifolia','a/s',
 		'escens/a','eata/eola','enisis/ensis','ensis/insis','ensis/ionalis','escens/icincta',
 		'ii/i','is/eus','ia/ium','ia/ius','ica/ulata','ides/phora','ii/iana','ivora/taria','ioides/oides',
 		'sis/ensis',
 		'ta/iens',
 		'ula/a','um/a','us/a'
 	);
 	--- complicated stuff first to reduce false errors
 	intp nt_type := nt_type(
 		'aea/ae','ae/i',
 		'ie/e','ii/i','ii/e','ii/','iae/ii',
 		'm/n',
 		'p/f',
 		'y/i'
 	);
BEGIN
	-- ending replacements
	--dbms_output.put_line(v_name);
	FOR i IN 1..nt.count LOOP
   		t_ptrn:=nt(i);
   		ptn_one:=SUBSTR(t_ptrn,1, INSTR(t_ptrn, '/',1) -1);
		ptn_two:=SUBSTR(t_ptrn,INSTR(t_ptrn, '/',1) +1);
		if SUBSTR(v_name,-length(ptn_one)) = ptn_one then
			--dbms_output.put_line('INSIDE::Checking ' || t_ptrn);
			name_var:=substr(v_name,0,length(v_name)-length(ptn_one)) || ptn_two;
			--dbms_output.put_line(name_var);
			select count(*) into c from taxon_name where scientific_name=name_var;
			--dbms_output.put_line(c);
			if c>0 then
				select taxon_name_id into r_tid from taxon_name where scientific_name=name_var;
				arrow:=arrow+1;
				t_val.extend;
    			t_val(arrow) := r_tid;
			end if;
		end if;
	END LOOP;
	-- END ending replacements
	-- dash
	if instr(v_name,'-') > 0 then
		name_var:=replace(v_name,'-');
		select count(*) into c from taxon_name where scientific_name=name_var;
		if c>0 then
			select taxon_name_id into r_tid from taxon_name where scientific_name=name_var;
			arrow:=arrow+1;
			t_val.extend;
      		t_val(arrow) := r_tid;
		end if;
	end if;
	-- embedded replacements
	FOR i IN 1..intp.count LOOP
		t_ptrn:=intp(i);
		--dbms_output.put_line('Checking ' || t_ptrn);
		ptn_one:=SUBSTR(t_ptrn,1, INSTR(t_ptrn, '/',1) -1);
		ptn_two:=SUBSTR(t_ptrn,INSTR(t_ptrn, '/',1) +1);
		if instr(v_name,ptn_one) > 0 then
			--dbms_output.put_line(v_name || ' contains ' || ptn_one);
			--dbms_output.put_line('REGEXP_COUNT(v_name,ptn_one): ' || REGEXP_COUNT(v_name,ptn_one));
			-- check each occurrence individually; this does not support combinations at this time
			for x in 1..REGEXP_COUNT(v_name,ptn_one) loop
				name_var:=regexp_replace(v_name,ptn_one,ptn_two,1,x);
				--dbms_output.put_line(' name_var: ' || name_var);
				select count(*) into c from taxon_name where scientific_name=name_var;
				--dbms_output.put_line(c);
			 	if c>0 then
					select taxon_name_id into r_tid from taxon_name where scientific_name=name_var;
					arrow:=arrow+1;
					t_val.extend; 
      				t_val(arrow) := r_tid;
				end if;
			 end loop;
		end if;
	end loop;
	--- infraspecific ranks
	if instr(v_name,'.') > 0 then
		--dbms_output.put_line('Checking infraspecific ranks');	
		for irt in (
			select 
       			scientific_name, 
       			taxon_name_id 
    		from 
       			taxon_name 
       		where 
       			scientific_name != v_name and
       			scientific_name like replace(regexp_replace(v_name, 'agamosp.|agamovar.|convar.|f.|lus.|modif.|monstr.|mut.|nm.|nothof.|nothosubsp.|nothovar.|prol.|subf.|subhybr.|subsp.|subsubvar.|subf.|subvar.|var.', '%'),' % ','%') and 
       			REGEXP_REPLACE(regexp_replace(scientific_name, ' ' || 'agamosp.|agamovar.|convar.|f.|lus.|modif.|monstr.|mut.|nm.|nothof.|nothosubsp.|nothovar.|prol.|subf.|subhybr.|subsp.|subsubvar.|subf.|subvar.|var.' || ' ', ' '),' {2,}', ' ')
       			=REGEXP_REPLACE(regexp_replace(v_name, ' ' || 'agamosp.|agamovar.|convar.|f.|lus.|modif.|monstr.|mut.|nm.|nothof.|nothosubsp.|nothovar.|prol.|subf.|subhybr.|subsp.|subsubvar.|subf.|subvar.|var.' || ' ', ' '),' {2,}', ' ')
       	) loop
			--dbms_output.put_line(irt.scientific_name);
			arrow:=arrow+1;
			t_val.extend; -- Extend it
    	  	t_val(arrow) := irt.taxon_name_id;
		end loop;
	end if;
	-- get distinct
	if t_val.count >0 then
	   t_val := t_val MULTISET UNION DISTINCT t_val;
		--DBMS_OUTPUT.put_line ('t_val.last NOT zero');t_val := t_val MULTISET UNION DISTINCT t_val;
    	FOR i IN t_val.first .. t_val.last LOOP
	    -- DBMS_OUTPUT.put_line ('uniq:'||t_val (i));
	    	tidlist:=tidlist||sep||to_char(t_val(i));
	        sep:=',';
	    END LOOP;
	end if;
	--DBMS_OUTPUT.put_line ('tidlist :'||tidlist );
	return tidlist;
END;
/
sho err;




-- procedure to check systematically
-- 5K names takes about 5-10 seconds; run with that, it should not be obtrusive
CREATE OR REPLACE PROCEDURE proc_find_tax_vars IS
	rslt varchar2(4000);
begin
	for r in (select scientific_name, taxon_name_id from taxon_name where 
		taxon_name_id not in (select taxon_name_id from cf_temp_potentialduptax_ck where sysdate-LASTDATE<7) and rownum < 5000
		--scientific_name='Leptonychotes weddellii'
	) loop
		select find_taxonomy_variations(r.scientific_name) into rslt from dual;
		--dbms_output.put_line('rslt: ' || rslt);	
		for x in (
			select taxon_name_id,scientific_name from taxon_name where taxon_name_id in (
				SELECT regexp_substr(rslt,'[^,]+', 1, level) AS list FROM dual CONNECT BY regexp_substr(rslt, '[^,]+', 1, level) IS NOT NULL
			)
		) loop
			--dbms_output.put_line(r.scientific_name || ' ----------------------> '||x.scientific_name);
			makeRecipTaxRel(r.taxon_name_id, x.taxon_name_id, 'potential alternate spelling');
		end loop;
		BEGIN
			--dbms_output.put_line('insert log');
 			insert into cf_temp_potentialduptax_ck (taxon_name_id,lastdate) values (r.taxon_name_id,sysdate);
		EXCEPTION  WHEN DUP_VAL_ON_INDEX THEN
			--dbms_output.put_line('update log');
    		UPDATE cf_temp_potentialduptax_ck set lastdate=sysdate where taxon_name_id=r.taxon_name_id;
		END;	
	end loop;
end;
/
sho err;
--exec proc_find_tax_vars;



-- run this every minute - FREQ=MINUTELY;INTERVAL=30 - for now
-- it can scale way back once things get caught up
-- it's caught up, got to every 4 hours - FREQ=HOURLY; INTERVAL=4
exec DBMS_SCHEDULER.DROP_JOB (JOB_NAME => 'j_find_tax_vars', FORCE => TRUE);

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'j_find_tax_vars',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'proc_find_tax_vars',
    enabled     => TRUE,
    start_date => systimestamp,
    repeat_interval => 'FREQ=HOURLY; INTERVAL=4'
  );
END;
/ 
 select START_DATE,REPEAT_INTERVAL,END_DATE,ENABLED,STATE,RUN_COUNT,FAILURE_COUNT,LAST_START_DATE,LAST_RUN_DURATION,NEXT_RUN_DATE from all_scheduler_jobs where lower(job_name)='j_find_tax_vars';


-- check in

select count(*) from taxon_relations where taxon_relationship='potential alternate spelling';

select
	a.scientific_name || ' ---> ' || b.scientific_name 
from
	taxon_name a,
	taxon_name b,
	taxon_relations
where
	a.taxon_name_id=taxon_relations.taxon_name_id and
	b.taxon_name_id=taxon_relations.related_taxon_name_id and
	taxon_relationship='potential alternate spelling'
order by
	a.scientific_name,
	b.scientific_name
;
	


