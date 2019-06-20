-- https://github.com/ArctosDB/arctos/issues/1270

create table ctcoll_event_attr_type (
	event_attribute_type varchar2(255) not null,
	description varchar2(4000) not null
);

ALTER TABLE ctcoll_event_attr_type ADD CONSTRAINT pkctcoll_event_attr_type PRIMARY KEY (event_attribute_type);

create public synonym ctcoll_event_attr_type for ctcoll_event_attr_type;

grant select on ctcoll_event_attr_type to public;

grant insert,update,delete on ctcoll_event_attr_type to manage_codetables;


create table log_ctcoll_event_attr_type (
	username varchar2(60),
	when date default sysdate,
	n_event_attribute_type VARCHAR2(255),
	o_event_attribute_type VARCHAR2(255),
	n_description VARCHAR2(4000),
	o_description VARCHAR2(4000)
);


create or replace public synonym log_ctcoll_event_attr_type for log_ctcoll_event_attr_type;

grant select on log_ctcoll_event_attr_type to coldfusion_user;


CREATE OR REPLACE TRIGGER TR_log_ctcoll_event_attr_type AFTER INSERT or update or delete ON ctcoll_event_attr_type
FOR EACH ROW
BEGIN
	insert into log_ctcoll_event_attr_type (
		username,
		when,
		n_event_attribute_type,
		o_event_attribute_type,
		n_description,
		o_description
	) values (
		SYS_CONTEXT('USERENV','SESSION_USER'),
		sysdate,
		:NEW.event_attribute_type,
		:OLD.event_attribute_type,
		:NEW.description,
		:OLD.description
	);
END;
/ 
sho err;










create table collecting_event_attributes (
	collecting_event_attribute_id number not null,
	collecting_event_id number not null,
	determined_by_agent_id number not null,
	event_attribute_type varchar2(255) NOT NULL,
	event_attribute_value varchar2(4000) NOT NULL,
	event_attribute_units varchar2(30) ,
	event_attribute_remark varchar2(4000) ,
	event_determination_method varchar2(4000) ,
	event_determined_date varchar2(30)
);

alter table collecting_event_attributes modify determined_by_agent_id number null;


ALTER TABLE collecting_event_attributes ADD CONSTRAINT pkcollecting_event_attributes PRIMARY KEY (collecting_event_attribute_id);

ALTER TABLE collecting_event_attributes ADD CONSTRAINT fk_ceatr_collecting_event FOREIGN KEY (collecting_event_id) references collecting_event(collecting_event_id);

ALTER TABLE collecting_event_attributes ADD CONSTRAINT fk_ceatr_determin_agent FOREIGN KEY (determined_by_agent_id) references agent(agent_id);

ALTER TABLE collecting_event_attributes ADD CONSTRAINT fk_attribute_type FOREIGN KEY (event_attribute_type) references ctcoll_event_attr_type(event_attribute_type);

create public synonym collecting_event_attributes for collecting_event_attributes;


grant insert,update,delete,select on collecting_event_attributes to manage_locality;



CREATE OR REPLACE TRIGGER tr_ctcoll_event_att_att_biu
    BEFORE INSERT or update or delete ON ctcoll_event_att_att
    FOR EACH ROW
    DECLARE
		c NUMBER;
    BEGIN
	    -- disallow changing stuff that's already in the data
	    if inserting then
	    	select count(*) into c from collecting_event_attributes where event_attribute_type=:NEW.event_attribute_type;
	    	if c>0 then
	    		raise_application_error(-20001,'You may not add control for used attributes.');
	    	end if;
	    end if;
	    if deleting then
	    	select count(*) into c from collecting_event_attributes where event_attribute_type=:OLD.event_attribute_type;
	    	if c>0 then
	    		raise_application_error(-20001,'You may not delete for used attributes.');
	    	end if;
	    end if;
	    if updating then
	    	if :OLD.event_attribute_type != :NEW.event_attribute_type then
	    		raise_application_error(-20001,'Changing attribute type is not allowed; delete and insert.');
			end if;
			if :NEW.VALUE_CODE_TABLE is not null and :NEW.VALUE_CODE_TABLE!=:OLD.VALUE_CODE_TABLE then
	    		select count(*) into c from collecting_event_attributes where event_attribute_type=:OLD.event_attribute_type;
	    		if c>0 then
		    		raise_application_error(-20001,'You may not change value control for used attributes.');
		    	end if;
		    end if;
		    if :NEW.UNIT_CODE_TABLE is not null and :NEW.UNIT_CODE_TABLE!=:OLD.UNIT_CODE_TABLE then
	    		select count(*) into c from collecting_event_attributes where event_attribute_type=:OLD.event_attribute_type;
	    		if c>0 then
		    		raise_application_error(-20001,'You may not change unit control for used attributes.');
		    	end if;
		    end if;
		end if;
	    
	    if :NEW.VALUE_CODE_TABLE is null and :NEW.UNIT_CODE_TABLE is null then
	    	raise_application_error(-20001,'Either value or unit code table must be provided.');
	   	END IF;
	   	
	    if :NEW.VALUE_CODE_TABLE is not null and :NEW.UNIT_CODE_TABLE is not null then
	    	raise_application_error(-20001,'Either value or unit code table must be provided.');
	   	END IF;
	end;
/
sho err;


create TABLE ctcoll_event_att_att (
    event_attribute_type varchar2(30) NOT NULL,
    VALUE_code_table VARCHAR2(38),
    unit_code_table varchar2(38)
);

create public synonym ctcoll_event_att_att for ctcoll_event_att_att;

grant select on ctcoll_event_att_att to public;

grant insert,update,delete on ctcoll_event_att_att to manage_codetables;






create table log_ctcoll_event_att_att (
	username varchar2(60),
	when date default sysdate,
	n_event_attribute_type VARCHAR2(255),
	o_event_attribute_type VARCHAR2(255),
	n_VALUE_code_table VARCHAR2(255),
	o_VALUE_code_table VARCHAR2(255),
	n_unit_code_table VARCHAR2(255),
	o_unit_code_table VARCHAR2(255)
);


create or replace public synonym log_ctcoll_event_att_att for log_ctcoll_event_att_att;

grant select on log_ctcoll_event_att_att to coldfusion_user;


CREATE OR REPLACE TRIGGER TR_log_ctcoll_event_att_att AFTER INSERT or update or delete ON ctcoll_event_att_att
FOR EACH ROW
BEGIN
	insert into log_ctcoll_event_att_att (
		username,
		when,
		n_event_attribute_type,
		o_event_attribute_type,
		n_VALUE_code_table,
		o_VALUE_code_table,
		n_unit_code_table,
		o_unit_code_table
	) values (
		SYS_CONTEXT('USERENV','SESSION_USER'),
		sysdate,
		:NEW.event_attribute_type,
		:OLD.event_attribute_type,
		:NEW.VALUE_code_table,
		:OLD.VALUE_code_table,
		:NEW.unit_code_table,
		:OLD.unit_code_table
	);
END;
/ 
sho err;





CREATE UNIQUE INDEX iu_ctcoll_event_att_att_all ON ctcoll_event_att_att (event_attribute_type,VALUE_code_table,unit_code_table);
CREATE UNIQUE INDEX iu_ctevent_att_att ON ctcoll_event_att_att (event_attribute_type);




CREATE SEQUENCE sq_coll_event_attribute_id;
CREATE PUBLIC SYNONYM sq_coll_event_attribute_id for sq_coll_event_attribute_id;
GRANT SELECT ON sq_coll_event_attribute_id TO public;

CREATE OR REPLACE TRIGGER tr_coll_event_attr_biu
    BEFORE INSERT or update ON collecting_event_attributes
    FOR EACH ROW
	DECLARE
		numrows NUMBER := 0;
		vct VARCHAR2(255);
		uct VARCHAR2(255);
		ctctColname VARCHAR2(255);
		status varchar2(255);
		sqlString varchar2(4000);
    BEGIN
	    
	    dbms_output.put_line('hola yo soy tr_coll_event_attr_biu');
        if :new.collecting_event_attribute_id is null then
        	select sq_coll_event_attribute_id.nextval into :new.collecting_event_attribute_id from dual;
        end if;        
        IF :NEW.event_determined_date IS NOT NULL THEN
	    	status:=is_iso8601(:NEW.event_determined_date);
	        IF status != 'valid' THEN
	   	       raise_application_error(-20001,'event_determined_date: ' || status);
	   		END IF;
	    END IF;
	    dbms_output.put_line('event_attribute_type:' || :NEW.event_attribute_type);
		SELECT COUNT(*) INTO numrows FROM ctcoll_event_att_att WHERE event_attribute_type = :NEW.event_attribute_type;
		
	    dbms_output.put_line('numrows:' || numrows);
     	IF (numrows = 0) and :new.event_attribute_units IS NOT NULL THEN
            raise_application_error(
                -20001,
                'This attribute cannot have units');
        END IF;
        if numrows > 0 then
        
	    dbms_output.put_line('its controlled');
        	-- it's controlled   
        	SELECT 
        		upper(VALUE_CODE_TABLE), 
        		upper(UNIT_CODE_TABLE) 
        	INTO 
        		vct, 
        		uct 
        	FROM 
        		ctcoll_event_att_att 
        	WHERE 
        		event_attribute_type = :NEW.event_attribute_type;
        	IF vct IS NOT NULL THEN
        	
	    dbms_output.put_line('vct IS NOT NULL');
	    		SELECT 
	    			column_name 
	    		INTO 
	    			ctctColname 
	    		FROM 
	    			user_tab_columns 
	    		WHERE 
	    			upper(table_name) = vct AND 
	    			upper(column_name) <> 'COLLECTION_CDE' AND 
	    			upper(column_name) <> 'DESCRIPTION'
	    		;
				sqlString := 'SELECT count(*) FROM ' || vct || 
					' WHERE ' || ctctColname || ' = ''' || 
					:NEW.event_attribute_value || '''';
				EXECUTE IMMEDIATE sqlstring INTO numrows;
				IF (numrows = 0) THEN
				    raise_application_error(
				        -20001,
				        'Invalid event_attribute_value - ' || :NEW.event_attribute_value);
				END IF;
			end if;
			IF (uct IS NOT NULL) THEN
			
	    dbms_output.put_line('uct is not null');
				SELECT IS_number(:new.event_attribute_value) INTO numrows FROM dual;
				
	    dbms_output.put_line('numrows isnumber:' || numrows);
	    
				IF numrows = 0 THEN
				    raise_application_error(
				        -20001,
				        'Attributes with units must be numeric.');
				END IF;
	    dbms_output.put_line('uct:' || uct);
				
	    		SELECT 
	    			column_name
	    		INTO 
	    			ctctColname 
	    		FROM 
	    			user_tab_columns 
	    		WHERE 
	    			upper(table_name)=uct AND 
	    			upper(column_name) <> 'COLLECTION_CDE' AND 
	    			upper(column_name) <> 'DESCRIPTION'
	    		;
	    		
	    		
	    dbms_output.put_line('ctctColname' || ctctColname);
	    
	    
	    
				sqlString := 'SELECT count(*) FROM ' || uct || 
					' WHERE ' || ctctColname || ' = ''' || 
					:NEW.event_attribute_units || '''';
				EXECUTE IMMEDIATE sqlstring INTO numrows;
				IF (numrows = 0) THEN
				    raise_application_error(
				        -20001,
				        'Invalid event_attribute_units - ' || :NEW.event_attribute_units);
				END IF;
			end if;
        END IF;
	end;
/
sho err;





create or replace function getEventAttrSig(cid in number)
/* are sum of event attributes same - eg, can events be merged? */
return varchar2 as

	l_thisstr    varchar2(4000);
	l_str    varchar2(4000);
	l_sep    varchar2(30);
	l_val    varchar2(4000);
	l_checksum varchar2(4000);
	all_data clob;
	temp_data clob;
begin
	for r in (
		select
			determined_by_agent_id,
			event_attribute_type,
			event_attribute_value,
			event_attribute_units,
			event_attribute_remark,
			event_determination_method,
			event_determined_date
		from
			collecting_event_attributes
		where
			collecting_event_id=cid
		order by
			event_determined_date,
			determined_by_agent_id,
			event_attribute_type,
			event_attribute_value,
			event_attribute_units,
			event_attribute_remark,
			event_determination_method
	) loop
		-- will always fit
		l_thisstr:=r.determined_by_agent_id||r.event_determined_date||r.event_attribute_type||r.event_attribute_units;
		dbms_lob.append(temp_data,l_thisstr);
		-- append individually
		dbms_lob.append(temp_data,r.event_attribute_value);
		dbms_lob.append(temp_data,r.event_attribute_remark);
		dbms_lob.append(temp_data,r.event_determination_method);
	end loop;
	-- now grab the hash of ordered-everything
	select md5hash(temp_data) into l_checksum from dual;
	return l_checksum;
  end;
/

-- now we need to rebuild the merger scripts to consider event attributes


------- IMPORTANT!!


-- this is NOT in prod
-- it need to be before this gets used
CREATE OR REPLACE PROCEDURE auto_merge_collecting_event 
IS
	i number :=0;
	c number;
BEGIN
	-- run this on new stuff and recheck every month or so
	-- need to monitor and adjust the "every month or so" bits
	-- collecting_event_name is unique so those will never be duplicates
	-- but grab them anyway so we can flag them as being checked
	for r in (
		select * from collecting_event where rownum<150 and (last_dup_check_date is null or sysdate-last_dup_check_date > 30)
	) loop
			--dbms_output.put_line(r.collecting_event_id);
			--dbms_output.put_line(r.VERBATIM_LOCALITY);
			--dbms_output.put_line(r.last_dup_check_date);
		for dups in (
			select * from collecting_event where
				collecting_event_id != r.collecting_event_id and
				LOCALITY_ID=r.LOCALITY_ID and
				nvl(VERBATIM_DATE,'NULL')=nvl(r.VERBATIM_DATE,'NULL') and
				nvl(VERBATIM_LOCALITY,'NULL')=nvl(r.VERBATIM_LOCALITY,'NULL') and
				nvl(COLL_EVENT_REMARKS,'NULL')=nvl(r.COLL_EVENT_REMARKS,'NULL') and
				nvl(BEGAN_DATE,'NULL')=nvl(r.BEGAN_DATE,'NULL') and
				nvl(ENDED_DATE,'NULL')=nvl(r.ENDED_DATE,'NULL') and
				nvl(VERBATIM_COORDINATES,'NULL')=nvl(r.VERBATIM_COORDINATES,'NULL') and
				nvl(COLLECTING_EVENT_NAME,'NULL')=nvl(r.COLLECTING_EVENT_NAME,'NULL') and
				nvl(getEventAttrSig(collecting_event_id),'NULL')=nvl(getEventAttrSig(r.collecting_event_id),'NULL')
			) loop
			BEGIN
				i:=i+1;
				--dbms_output.put_line('!!!!!!!!!!!!!!!!!!!!!!!!! FOUND DUPLICATE GONNA MERGE!!!!!!!!!! dup evt ID: ' || dups.collecting_event_id);
				-- log; probably won't go to prod
				--update bak_collecting_event20180405 set merged_into_cid = r.collecting_event_id where collecting_event_id=dups.collecting_event_id;
				--dbms_output.put_line('gonna update specimen_event');
				
				--dbms_output.put_line('update specimen_event	set	collecting_event_id=' || r.collecting_event_id || '	where collecting_event_id=' || dups.collecting_event_id);
				
				--dbms_output.put_line('BEFORE UPDATE SPECIMEN EVENT: ' || SYSTIMESTAMP);
				update 
					specimen_event 
				set 
					collecting_event_id=r.collecting_event_id
				where 
					collecting_event_id=dups.collecting_event_id;
					
				
				--dbms_output.put_line('AFTER UPDATE SPECIMEN EVENT: ' || SYSTIMESTAMP);
				
				update 
					tag 
				set 
					collecting_event_id=r.collecting_event_id 
				where 
					collecting_event_id=dups.collecting_event_id;
					
					
				--dbms_output.put_line('AFTER UPDATE tag: ' || SYSTIMESTAMP);

				update 
					media_relations 
				set 
					related_primary_key=r.collecting_event_id 
				where
					media_relationship like '% collecting_event' and
					related_primary_key =dups.collecting_event_id;

					
				--dbms_output.put_line('AFTER UPDATE media_relations: ' || SYSTIMESTAMP);
				
				update 
					bulkloader 
				set 
					collecting_event_id=r.collecting_event_id 
				where 
					collecting_event_id=dups.collecting_event_id;

					
				--dbms_output.put_line('AFTER UPDATE bulkloader: ' || SYSTIMESTAMP);

				-- and delete the duplicate locality
				--dbms_output.put_line('gonna delete collecting_event');
				delete from collecting_event where collecting_event_id=dups.collecting_event_id;
				
				
				--dbms_output.put_line('AFTER DELETE collecting_event: ' || SYSTIMESTAMP);
				
				--dbms_output.put_line(' deleted collecting_event');
			exception when others then
			--	null;
				-- these happen (at least) when the initial query contains the duplicate
				-- ignore, they'll get caught next time around/eventually
				dbms_output.put_line('FAIL ID: ' || dups.collecting_event_id);
				dbms_output.put_line(sqlerrm);
			end;
		end loop;
		-- now that we're merged, DELETE if unused and unnamed
		-- DO NOT delete named localities
		if r.COLLECTING_EVENT_NAME is null then
			select sum(x) into c from (
				select count(*) x from specimen_event where collecting_event_id=r.collecting_event_id
				union
				select count(*) x from tag where collecting_event_id=r.collecting_event_id
				union
				select count(*) x from media_relations where media_relationship like '% collecting_event' and related_primary_key =r.collecting_event_id
				union
				select count(*) x from bulkloader where collecting_event_id=r.collecting_event_id
			);
			if c=0 then
				--dbms_output.put_line('not used deleting');
				delete from collecting_event where collecting_event_id=r.collecting_event_id;
			end if;
		end if;

		-- log the last check
		-- pass in the admin_flag = 'proc auto_merge_locality' - we're not changing anything here
		--dbms_output.put_line('gonna log....');
		update collecting_event set admin_flag = 'proc auto_merge_locality',last_dup_check_date=sysdate where collecting_event_id=r.collecting_event_id;

		-- if there are a lot of not-so-duplicates found, this can process many per run
		-- if there are a log of duplicates, it'll get all choked up on trying to update FLAT
		-- so throttle - if we haven't merged much then keep going, if we have exit and start over next run
		if i > 100 then
			--dbms_output.put_line('i maxout: ' || i);
			return;
		--else
			--dbms_output.put_line('i stillsmall: ' || i);
		end if;
	end loop;
end;
/
sho err;


-- need to archive environmental attrs
