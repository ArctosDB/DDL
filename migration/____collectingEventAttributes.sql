-- https://github.com/ArctosDB/arctos/issues/1270

create table ctcoll_event_attr_type (
	event_attribute_type varchar2(255) not null,
	description varchar2(4000) not null
);

ALTER TABLE ctcoll_event_attr_type ADD CONSTRAINT pkctcoll_event_attr_type PRIMARY KEY (event_attribute_type);

create public synonym ctcoll_event_attr_type for ctcoll_event_attr_type;

grant select on ctcoll_event_attr_type to public;

grant insert,update,delete on ctcoll_event_attr_type to manage_codetables;


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


ALTER TABLE collecting_event_attributes ADD CONSTRAINT pkcollecting_event_attributes PRIMARY KEY (collecting_event_attribute_id);

ALTER TABLE collecting_event_attributes ADD CONSTRAINT fk_ceatr_collecting_event FOREIGN KEY (collecting_event_id) references collecting_event(collecting_event_id);

ALTER TABLE collecting_event_attributes ADD CONSTRAINT fk_ceatr_determin_agent FOREIGN KEY (determined_by_agent_id) references agent(agent_id);

ALTER TABLE collecting_event_attributes ADD CONSTRAINT fk_attribute_type FOREIGN KEY (event_attribute_type) references ctcoll_event_attr_type(event_attribute_type);

create public synonym collecting_event_attributes for collecting_event_attributes;


grant insert,update,delete,select on collecting_event_attributes to manage_locality;





create TABLE ctcoll_event_att_att (
    event_attribute_type varchar2(30) NOT NULL,
    VALUE_code_table VARCHAR2(38),
    unit_code_table varchar2(38)
);

create public synonym ctcoll_event_att_att for ctcoll_event_att_att;

grant select on ctcoll_event_att_att to public;

grant insert,update,delete on ctcoll_event_att_att to manage_codetables;



CREATE UNIQUE INDEX iu_ctcoll_event_att_att_all ON ctcoll_event_att_att (event_attribute_type,VALUE_code_table,unit_code_table);
CREATE UNIQUE INDEX iu_ctevent_att_att ON ctcoll_event_att_att (event_attribute_type);




CREATE SEQUENCE sq_coll_event_attribute_id;

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
        if :new.collecting_event_attribute_id is null then
        	select sq_coll_event_attribute_id.nextval into :new.collecting_event_attribute_id from dual;
        end if;        
        IF :NEW.event_determined_date IS NOT NULL THEN
	    	status:=is_iso8601(:NEW.event_determined_date);
	        IF status != 'valid' THEN
	   	       raise_application_error(-20001,'event_determined_date: ' || status);
	   		END IF;
	    END IF;
		SELECT COUNT(*) INTO numrows FROM ctcoll_event_att_att WHERE event_attribute_type = :NEW.event_attribute_type;
     	IF (numrows = 0) and :new.event_attribute_units IS NOT NULL THEN
            raise_application_error(
                -20001,
                'This attribute cannot have units');
        END IF;
        if numrows > 0 then
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
				SELECT IS_number(:new.event_attribute_value) INTO numrows FROM dual;
				IF numrows = 0 THEN
				    raise_application_error(
				        -20001,
				        'Attributes with units must be numeric.');
				END IF;
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
				sqlString := 'SELECT count(*) FROM ' || vct || 
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

