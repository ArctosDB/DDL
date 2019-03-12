CREATE OR REPLACE PROCEDURE temp_update_junk IS
begin
	for r in (select scientific_name from taxon_name where taxon_name_id not in (select taxon_name_id from cf_temp_potentialduptax_ck) and rownum < 10000) loop
		potential_dup_taxonomy(r.scientific_name);
	end loop;
end;
/

exec temp_update_junk;




BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_TEMP_UPDATE_JUNK',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'temp_update_junk',
    enabled     => TRUE,
    start_date => systimestamp,
    repeat_interval => 'FREQ=MINUTELY;INTERVAL=1'
  );
END;
/ 

exec DBMS_SCHEDULER.DROP_JOB('J_TEMP_UPDATE_JUNK');


select count(*) from cf_temp_potentialduptax;
select count(*) from cf_temp_potentialduptax_ck;

select a.scientific_name,b.scientific_name from taxon_name a,taxon_name b,cf_temp_potentialduptax where 
a.TAXON_NAME_ID=cf_temp_potentialduptax.TAXON_NAME_ID and b.TAXON_NAME_ID=cf_temp_potentialduptax.DUPLICATION_TAXON_NAME_ID;

SP2-0734: unknown command beginning "cf_temp_po..." - rest of line ignored.
UAM@ARCTOS> desc cf_temp_potentialduptax
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 TAXON_NAME_ID								    NUMBER
 DUPLICATION_TAXON_NAME_ID						    NUMBER
 LASTDATE								    DATE

desc 


CREATE OR REPLACE PROCEDURE potential_dup_taxonomy (v_name IN varchar2)
 -- just find name variants; pass the checking off to another proc
is
    r_name taxon_name.scientific_name%TYPE;
    name_var taxon_name.scientific_name%TYPE;
    c number;
    r_tid number;
    tid number;
    t_ptrn varchar2(255);
    ptn_one varchar2(255);
    ptn_two varchar2(255);
    
    type nt_type is table of VARCHAR2(30);
 	nt nt_type := nt_type(
 		'aensis/ensis','alis/ata','ata/ula','atifolia/ifolia',
 		'escens/a','eata/eola','enisis/ensis','ensis/insis','ensis/ionalis','escens/icincta',
 		'ii/i','is/eus','ia/ium','ia/ius','ica/ulata','ides/phora','ii/iana','ivora/taria','ioides/oides',
 		'sis/ensis',
 		'ta/iens',
 		'ula/a','um/a','us/a'
 	);
BEGIN
		-- ending replacements
		--dbms_output.put_line(v_name);
		FOR i IN 1..nt.count LOOP
   			t_ptrn:=nt(i);
   			--dbms_output.put_line('Checking ' || t_ptrn);
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
					select taxon_name_id into tid from taxon_name where scientific_name=v_name;
					-- need to do more here when we're ready to create relationships
					--dbms_output.put_line('inserting ' || v_name || ' ==> ' || name_var  || ' because ' || t_ptrn);
					insert into cf_temp_potentialduptax (taxon_name_id,duplication_taxon_name_id,lastdate) values (tid,r_tid,sysdate);
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
				select taxon_name_id into tid from taxon_name where scientific_name=v_name;
				-- need to do more here when we're ready to create relationships
				--dbms_output.put_line('inserting ' || v_name || ' ==> ' || name_var || 'because dash-match');
				insert into cf_temp_potentialduptax (taxon_name_id,duplication_taxon_name_id,lastdate) values (tid,r_tid,sysdate);
			end if;
		end if;
		
		
		
		-- log the check
		-- only fetch ID if we need to
		if tid is null then
			select taxon_name_id into tid from taxon_name where scientific_name=v_name;
		end if;
		BEGIN
			--dbms_output.put_line('insert log');
 			insert into cf_temp_potentialduptax_ck (taxon_name_id,lastdate) values (tid,sysdate);
		EXCEPTION  WHEN DUP_VAL_ON_INDEX THEN
			--dbms_output.put_line('update log');
    		UPDATE cf_temp_potentialduptax_ck set lastdate=sysdate where taxon_name_id=tid;
		END;	
END;
/
sho err;

exec potential_dup_taxonomy('Baccharis delicatula');
exec potential_dup_taxonomy('Baccharoides pedunculatum');
exec potential_dup_taxonomy('Baculogypsinoides spinosus');
exec potential_dup_taxonomy('Baccharis aracatubaensis');
exec potential_dup_taxonomy('Baccharis pyramidalis');
exec potential_dup_taxonomy('Bactrocera biguttata');
exec potential_dup_taxonomy('Baccharis melastomatifolia');
exec potential_dup_taxonomy('Bactrocera latilineata');
exec potential_dup_taxonomy('Baccharis ibitienisis');
exec potential_dup_taxonomy('Baccharis famatinensis');
exec potential_dup_taxonomy('Baccharis meridensis');
exec potential_dup_taxonomy('Bacchisa flavescens');
exec potential_dup_taxonomy('Baccharis cotinifolia');
exec potential_dup_taxonomy('Baccharis toxicaria');
exec potential_dup_taxonomy('Baculogypsina sphaerica');
exec potential_dup_taxonomy('Bactris balanoides');
exec potential_dup_taxonomy('Baccharis weddelliana');
exec potential_dup_taxonomy('Baccharis weddellii');
exec potential_dup_taxonomy('Bactericera salicivora');
exec potential_dup_taxonomy('Baccharis vaccinioides');
exec potential_dup_taxonomy('Baccharis chilensis');
exec potential_dup_taxonomy('Baccharis aracatubaensis');
exec potential_dup_taxonomy('Baccharis aracatubensis');
exec potential_dup_taxonomy('Bactrocera decepta');
exec potential_dup_taxonomy('Babiana rubro-cyanea');
exec potential_dup_taxonomy('Polygala pseudo-coriacea');
exec potential_dup_taxonomy('xxxxx');
exec potential_dup_taxonomy('xxxxx');
exec potential_dup_taxonomy('xxxxx');
exec potential_dup_taxonomy('xxxxx');
exec potential_dup_taxonomy('xxxxx');
exec potential_dup_taxonomy('xxxxx');
exec potential_dup_taxonomy('xxxxx');
exec potential_dup_taxonomy('xxxxx');
exec potential_dup_taxonomy('xxxxx');
exec potential_dup_taxonomy('xxxxx');
exec potential_dup_taxonomy('xxxxx');

exec potential_dup_taxonomy('Pompilus funebris');


/*
select SUBSTR('Acartophthalmus nigrinus',-2) from dual;
 find Acartophthalmus nigrina.

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
 
 
 select * from cf_temp_potentialduptax;
 select * from cf_temp_potentialduptax_ck;
 
 
 delete from cf_temp_potentialduptax_ck;
 
 create unique index ix_u_potentialduptax_ck on cf_temp_potentialduptax_ck(taxon_name_id) tablespace uam_idx_1;
 
 select scientific_name from taxon_name where scientific_name like 'B%' and rownum < 5000 order by scientific_name;
*/



DECLARE
    
    nt nt_type := nt_type ('Choice_1', 'Choice_2'
    , 'Choice_3', 'Choice_4'
    , 'Choice_5', 'Choice_6');
BEGIN
  FOR i IN 1..nt.count
  LOOP
    dbms_output.put_line(nt(i));
  END LOOP;
END;
/




exec potential_dup_taxonomy('Abbevillea schlechtendahliana');




Abbevillea schlechtendahliana
Abbevillea schlechtendaliana


CREATE OR REPLACE PROCEDURE chk_log_pdup (
    v_name IN varchar2
IS
	c NUMBER;
	tid number;
	rtid number;
BEGIN
	select taxon_name_id into tid from taxon_name where scientific_name
	select count(*) into c from taxon_name where scientific_name=v_name;
	if c>0 then
		insert into cf_temp_potentialduptax (
 			taxon_name_id number,
 			duplication_taxon_name_id,
 			lastdate
 		) values ()
	IF is_number(other_id_num) = 1 THEN -- just a number
		part_one := NULL;
		part_two := other_id_num;
		part_three := NULL;
	ELSIF is_number(substr(other_id_num,1,length(other_id_num) - 1)) = 1 THEN
		-- number plus single char
		part_two := substr(other_id_num,1,length(other_id_num) - 1);
		part_three := substr(other_id_num,length(other_id_num));
	ELSIF is_positive_number(substr(other_id_num,2)) = 1 THEN
	 -- single char + number
		part_one := substr(other_id_num,1,1);
		part_two := substr(other_id_num,2);
	ELSIF substr(other_id_num,1,1) ='{' AND  substr(other_id_num,length(other_id_num),1) ='}' THEN
		-- entire thing surrounded by curly brackets==force all to prefix (eg, preserve leading zero)
		--dbms_output.put_line('is curly');
		part_one := other_id_num;
		part_one:=replace(part_one,'}');
		part_one:=replace(part_one,'{');
	ELSIF other_id_num like '%[%' and other_id_num like '%]%' then
		-- number between square brackets
		--dbms_output.put_line('squarebracket');
		part_one:=trim(regexp_replace(other_id_num,'\[.*$',''));
		part_two:=trim(regexp_substr(other_id_num,'\[(.*?)\]',1,1,null,1));
		part_three:=trim(regexp_replace(other_id_num,'^.*\]',''));
		--dbms_output.put_line('part_one: ' || part_one);
		--dbms_output.put_line('part_two: ' || part_two);
		--dbms_output.put_line('part_three: ' || part_three);
	ELSE -- loop through list of delimiter defined above and see what falls out
		--dbms_output.put_line('hit else');
		FOR i IN 1..100 LOOP
			td := substr(dlms,i,1);
			EXIT WHEN td IS NULL;
			IF instr(other_id_num,td) > 0 THEN  -- see if our number contains the current delimiter
				part_one := get_str_el (other_id_num,td,1) || td;
				part_two := get_str_el (other_id_num,td,2);
				IF instr(other_id_num,td,1,2) > 0 THEN
					part_three := td || get_str_el (other_id_num,td,3);
				END IF;
				IF part_three IS NULL THEN -- got back two parts, see if we can make one of them numeric
					IF is_number(part_two) = 0 AND is_number(part_one) = 1 THEN
						part_three := part_two;
						part_two := part_one;
						part_one := NULL;
					END IF;
				END IF;
			end IF;
		END LOOP;
	END IF;
	IF is_number(part_two) !=1 THEN
		--dbms_output.put_line('part two is not a number');
		part_one := other_id_num;
		part_two := NULL;
		part_three := NULL;
	END IF;
	part_two_number:=part_two;
	pend_disp_val:=part_one || part_two_number || part_three;
	-- get rid of parens and square brackets
	temp:=replace(other_id_num,'[');
	temp:=replace(temp,']');
	temp:=replace(temp,'{');
	temp:=replace(temp,'}');
	--dbms_output.put_line('pend_disp_val: ' || pend_disp_val);
	IF pend_disp_val IS NULL OR temp != pend_disp_val THEN
		--dbms_output.put_line('pend_disp_val angry');
		part_one := other_id_num;
		part_two := NULL;
		part_three := NULL;
	END IF;
	--dbms_output.put_line('part_one: ' || part_one);
	--dbms_output.put_line('part_two: ' || part_two);
	--dbms_output.put_line('part_three: ' || part_three);
	INSERT INTO coll_obj_other_id_num (
	    COLLECTION_OBJECT_ID,
	    OTHER_ID_TYPE,
	    OTHER_ID_PREFIX,
	    OTHER_ID_NUMBER,
	    OTHER_ID_SUFFIX,
	    ID_REFERENCES
	) values (
	    collection_object_id,
	    other_id_type,
	    part_one,
	    part_two,
	    part_three,
	    ID_REFERENCES
	);
end;
/
sho err

create or replace public synonym PARSE_OTHER_ID for PARSE_OTHER_ID;
grant execute on PARSE_OTHER_ID to manage_specimens;



