-- deal with goofy catalog "numbers"
-- collection.ALLOW_PREFIX_SUFFIX has never been really used, so co-opt it for this
-- allow three types of catalog number "series"
---- integer
---- integer + prefix/suffix
---- string
-- the latter is necessary to deal with cultural collections catnums which have no predictable format whatsoever, and lots of leading zeroes on anything that 
--  might be considered "the integer"
---- 0013-0072
---- 0013-0072
---- UA2005-003-0006

alter table collection add catalog_number_format varchar2(20);
update collection set catalog_number_format='integer';
alter table collection modify catalog_number_format not null;
alter table collection modify catalog_number_format varchar2(21);

ALTER TABLE collection ADD CONSTRAINT ctcatalog_number_format CHECK (catalog_number_format in ('integer','prefix-integer-suffix','string'));


alter table collection drop column ALLOW_PREFIX_SUFFIX;

-- cat_num has a NOT NULL constraint, and is built from integer-n-friends when that's allowed, so....
alter table cataloged_item modify CAT_NUM_INTEGER null;

ALTER TABLE cataloged_item drop CONSTRAINT CK_CATITEM_CATNUM;


CREATE OR REPLACE TRIGGER parse_cat_num
    BEFORE INSERT OR UPDATE ON cataloged_item
    FOR EACH ROW
    DECLARE
		dlms VARCHAR2(255) := '|-.; '; -- delimiters that can be used to split the "number"
		td VARCHAR2(255);
		dc number := 0;
		catalog_number_format VARCHAR2(255);
    BEGIN
		SELECT /*+ result_cache */ catalog_number_format INTO catalog_number_format FROM collection WHERE collection_id=:NEW.collection_id;
		if catalog_number_format='integer' then
			IF is_number(:NEW.cat_num) = 0 or :NEW.cat_num<1 THEN -- just a number
				RAISE_APPLICATION_ERROR(-20001,'This collection requires numeric catalog numbers >0 ' || :NEW.cat_num || ' is invalid.');	
			else
				:NEW.cat_num_prefix := NULL;
        		:NEW.cat_num_integer := :NEW.cat_num;
        		:NEW.cat_num_suffix := NULL;
			end if;
	    		
		elsif catalog_number_format='prefix-integer-suffix' then
			FOR i IN 1..100 LOOP
				td := substr(dlms,i,1);
				EXIT WHEN td IS NULL;
				IF instr(:NEW.cat_num,td,1,2) > 0 AND instr(:NEW.cat_num,td,1,3)=0 THEN
					-- we have a 3-part string
					dc:=dc+1;
					:NEW.cat_num_prefix := get_str_el (:NEW.cat_num,td,1) || td;
					:NEW.cat_num_integer := get_str_el (:NEW.cat_num,td,2);
					:NEW.cat_num_suffix := td || get_str_el (:NEW.cat_num,td,3);
				ELSIF instr(:NEW.cat_num,td) > 0 AND instr(:NEW.cat_num,td,1,2)=0 THEN
					-- got a 2-part string
					dc:=dc+1;
					IF is_number(get_str_el (:NEW.cat_num,td,1)) = 1 THEN
					-- got suffix
					:NEW.cat_num_prefix := NULL;
					:NEW.cat_num_integer:=get_str_el (:NEW.cat_num,td,1);
					:NEW.cat_num_suffix:=td || get_str_el (:NEW.cat_num,td,2);
				ELSIF is_number(get_str_el(:NEW.cat_num,td,2)) = 1 THEN
					-- got prefix
					:NEW.cat_num_prefix:=get_str_el(:NEW.cat_num,td,1) || td;
					:NEW.cat_num_integer:=get_str_el(:NEW.cat_num,td,2);
					:NEW.cat_num_suffix := NULL;
					--ELSE something goofy happened, fail later
				END IF;
				END IF;
			END LOOP;
		elsif catalog_number_format='string' then
			:NEW.cat_num_prefix := NULL;
        	:NEW.cat_num_integer := NULL;
        	:NEW.cat_num_suffix := NULL;
		END IF;
		 if dc>1 then
	    	RAISE_APPLICATION_ERROR(-20001,'catnum parse failed: more than one potentially valid delimiter found');
	    end if;
	    IF :NEW.cat_num_integer IS NULL THEN
	        RAISE_APPLICATION_ERROR(-20001,'catnum parse failed: a numeric component could not be found in input (' || :NEW.cat_num || ')'); 
	    END IF;
	    IF (:NEW.cat_num_prefix || :NEW.cat_num_integer || :NEW.cat_num_suffix) != :NEW.cat_num THEN
	       RAISE_APPLICATION_ERROR(-20001,'catnum parse failed: result (' || :NEW.cat_num_prefix || :NEW.cat_num_integer || :NEW.cat_num_suffix || ') is not input (' || :NEW.cat_num || ')');
	    END IF;
	    IF is_number(:NEW.cat_num_integer) = 0 THEN
	      RAISE_APPLICATION_ERROR(-20001,'catnum parse failed: integer component (' || :NEW.cat_num_integer || ') is not numeric');
	    END IF;
		IF round(:NEW.cat_num_integer) != :NEW.cat_num_integer THEN
		  RAISE_APPLICATION_ERROR(-20001,'catnum parse failed: integer component (' || :NEW.cat_num_integer || ') is decimal');
		END IF;

end;
/
sho err



-------------- attributes --------


alter table cf_temp_attributes add username varchar2(255);


 CREATE OR REPLACE TRIGGER cf_temp_attributes_key
 before insert  ON cf_temp_attributes
 for each row
    begin
	    :new.username:=sys_context('USERENV', 'SESSION_USER');
	    
    	if :NEW.key is null then
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;
    end;
/
sho err
	   
alter table cf_temp_attributes add guid_prefix varchar2(255);

alter table cf_temp_attributes drop column COLLECTION_CDE;
alter table cf_temp_attributes drop column INSTITUTION_ACRONYM;


-- new otherID type for use in pre-specimen relationships

insert into CTCOLL_OTHER_ID_TYPE (OTHER_ID_TYPE,DESCRIPTION) values ('UUID','Temporary universal unique identifier for use only in linking records in the specimen bulkloader to records in other bulkloaders.');











alter table cf_temp_specevent add UUID varchar2(255);
alter table cf_temp_specevent modify guid null;

alter table cf_temp_specevent add username varchar2(255) not null;
alter table cf_temp_specevent add insert_date date  default sysdate not null;

CREATE OR REPLACE TRIGGER cf_temp_specevent_key before insert ON cf_temp_specevent for each row
    begin
    	:new.username:=sys_context('USERENV', 'SESSION_USER');
	    if :NEW.key is null then
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;
    	if :NEW.guid is null and :NEW.uuid is null then
    		 raise_application_error(
            -20372,
            'One of (GUID, UUID) is required.');
        end if;
    end;
/


alter table cf_temp_parts add PART_ATTRIBUTE_TYPE_1 VARCHAR2(60);
alter table cf_temp_parts add PART_ATTRIBUTE_VALUE_1 VARCHAR2(255);
alter table cf_temp_parts add PART_ATTRIBUTE_UNITS_1 VARCHAR2(255);
alter table cf_temp_parts add PART_ATTRIBUTE_DATE_1 date;
alter table cf_temp_parts add PART_ATTRIBUE_DETERMINER_1 VARCHAR2(255);
alter table cf_temp_parts add PART_ATTRIBUE_REMARK_1 VARCHAR2(255);


alter table cf_temp_parts add PART_ATTRIBUTE_TYPE_2 VARCHAR2(60);
alter table cf_temp_parts add PART_ATTRIBUTE_VALUE_2 VARCHAR2(255);
alter table cf_temp_parts add PART_ATTRIBUTE_UNITS_2 VARCHAR2(255);
alter table cf_temp_parts add PART_ATTRIBUTE_DATE_2 date;
alter table cf_temp_parts add PART_ATTRIBUE_DETERMINER_2 VARCHAR2(255);
alter table cf_temp_parts add PART_ATTRIBUE_REMARK_2 VARCHAR2(255);


alter table cf_temp_parts add PART_ATTRIBUTE_TYPE_3 VARCHAR2(60);
alter table cf_temp_parts add PART_ATTRIBUTE_VALUE_3 VARCHAR2(255);
alter table cf_temp_parts add PART_ATTRIBUTE_UNITS_3 VARCHAR2(255);
alter table cf_temp_parts add PART_ATTRIBUTE_DATE_3 date;
alter table cf_temp_parts add PART_ATTRIBUE_DETERMINER_3 VARCHAR2(255);
alter table cf_temp_parts add PART_ATTRIBUE_REMARK_3 VARCHAR2(255);


alter table cf_temp_parts add PART_ATTRIBUTE_TYPE_4 VARCHAR2(60);
alter table cf_temp_parts add PART_ATTRIBUTE_VALUE_4 VARCHAR2(255);
alter table cf_temp_parts add PART_ATTRIBUTE_UNITS_4 VARCHAR2(255);
alter table cf_temp_parts add PART_ATTRIBUTE_DATE_4 date;
alter table cf_temp_parts add PART_ATTRIBUE_DETERMINER_4 VARCHAR2(255);
alter table cf_temp_parts add PART_ATTRIBUE_REMARK_4 VARCHAR2(255);


alter table cf_temp_parts add PART_ATTRIBUTE_TYPE_5 VARCHAR2(60);
alter table cf_temp_parts add PART_ATTRIBUTE_VALUE_5 VARCHAR2(255);
alter table cf_temp_parts add PART_ATTRIBUTE_UNITS_5 VARCHAR2(255);
alter table cf_temp_parts add PART_ATTRIBUTE_DATE_5 date;
alter table cf_temp_parts add PART_ATTRIBUE_DETERMINER_5 VARCHAR2(255);
alter table cf_temp_parts add PART_ATTRIBUE_REMARK_5 VARCHAR2(255);


alter table cf_temp_parts add PART_ATTRIBUTE_TYPE_6 VARCHAR2(60);
alter table cf_temp_parts add PART_ATTRIBUTE_VALUE_6 VARCHAR2(255);
alter table cf_temp_parts add PART_ATTRIBUTE_UNITS_6 VARCHAR2(255);
alter table cf_temp_parts add PART_ATTRIBUTE_DATE_6 date;
alter table cf_temp_parts add PART_ATTRIBUE_DETERMINER_6 VARCHAR2(255);
alter table cf_temp_parts add PART_ATTRIBUE_REMARK_6 VARCHAR2(255);



-- ai-ya!!!

alter table cf_temp_parts rename column PART_ATTRIBUE_DETERMINER_1 to PART_ATTRIBUTE_DETERMINER_1;
alter table cf_temp_parts rename column PART_ATTRIBUE_DETERMINER_2 to PART_ATTRIBUTE_DETERMINER_2;
alter table cf_temp_parts rename column PART_ATTRIBUE_DETERMINER_3 to PART_ATTRIBUTE_DETERMINER_3;
alter table cf_temp_parts rename column PART_ATTRIBUE_DETERMINER_4 to PART_ATTRIBUTE_DETERMINER_4;
alter table cf_temp_parts rename column PART_ATTRIBUE_DETERMINER_5 to PART_ATTRIBUTE_DETERMINER_5;
alter table cf_temp_parts rename column PART_ATTRIBUE_DETERMINER_6 to PART_ATTRIBUTE_DETERMINER_6;


alter table cf_temp_parts rename column PART_ATTRIBUE_REMARK_1 to PART_ATTRIBUTE_REMARK_1;
alter table cf_temp_parts rename column PART_ATTRIBUE_REMARK_2 to PART_ATTRIBUTE_REMARK_2;
alter table cf_temp_parts rename column PART_ATTRIBUE_REMARK_3 to PART_ATTRIBUTE_REMARK_3;
alter table cf_temp_parts rename column PART_ATTRIBUE_REMARK_4 to PART_ATTRIBUTE_REMARK_4;
alter table cf_temp_parts rename column PART_ATTRIBUE_REMARK_5 to PART_ATTRIBUTE_REMARK_5;
alter table cf_temp_parts rename column PART_ATTRIBUE_REMARK_6 to PART_ATTRIBUTE_REMARK_6;



alter table cf_temp_parts rename column institution_acronym to guid_prefix;
alter table cf_temp_parts drop column COLLECTION_CDE;

alter table cf_temp_parts add status VARCHAR2(255);
alter table cf_temp_parts add username VARCHAR2(255) not null;

CREATE OR REPLACE TRIGGER trg_cf_temp_parts_key before insert ON cf_temp_parts for each row
    begin
    	:new.username:=sys_context('USERENV', 'SESSION_USER');
	    if :NEW.key is null then
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;
    end;
/

alter table cf_temp_parts modify part_name not null;
alter table cf_temp_parts modify DISPOSITION not null;
alter table cf_temp_parts modify CONDITION not null;
alter table cf_temp_parts modify LOT_COUNT not null;
alter table cf_temp_parts modify use_existing not null;
alter table cf_temp_parts modify STATUS VARCHAR2(4000);

ALTER TABLE cf_temp_parts ADD CONSTRAINT booluse_existing CHECK (use_existing in (0,1));



 