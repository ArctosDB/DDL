insert into CTENCUMBRANCE_ACTION (ENCUMBRANCE_ACTION) values ('mask specimen remarks');
insert into CTENCUMBRANCE_ACTION (ENCUMBRANCE_ACTION) values ('mask unformatted measurements');


  
create or replace view v_attributes as select distinct
	attributes.ATTRIBUTE_ID,
	attributes.collection_object_id,
	attributes.DETERMINED_BY_AGENT_ID,
	preferred_agent_name.agent_name determiner,
	attributes.ATTRIBUTE_TYPE,
	attributes.ATTRIBUTE_VALUE,
	attributes.ATTRIBUTE_UNITS,
	attributes.ATTRIBUTE_REMARK,
	attributes.DETERMINATION_METHOD,
	attributes.DETERMINED_DATE,
	attributes.attribute_type || '=' || 
		attributes.attribute_value || 
		decode(attribute_units,
        	null,null,
            ' ' || attribute_units
        ) ||
		' (Determiner: ' || preferred_agent_name.agent_name || ' on ' || 
		determined_date|| 
		decode(determination_method,
        	null,null,
            '; Method: ' || determination_method
        ) || 
        decode(attribute_remark,
        	null,null,
            ' Remark: ' || attribute_remark
        ) 
        || ')' attribute_detail,
	attributes.attribute_type || '=' || 
		attributes.attribute_value || ' ' || 
		attribute_units attribute_summary,
	CASE
		WHEN concatEncumbrances(attributes.collection_object_id) LIKE '%mask ' || attributes.ATTRIBUTE_TYPE || '%'
        	THEN 1
            ELSE 0
	END is_encumbered
from
	attributes,
	preferred_agent_name
where
	attributes.DETERMINED_BY_AGENT_ID=preferred_agent_name.agent_id
;

create or replace public synonym v_attributes for v_attributes;
grant select on v_attributes to public;


CREATE OR REPLACE FUNCTION CONCATATTRIBUTEDETAIL (cid in varchar2,attribute in varchar2,forceEncumbrance in number default null)
return varchar2 as
	l_str    varchar2(4000);
	l_sep    varchar2(30);
	l_val    varchar2(4000);
	is_encumbered number := 0;
	is_operator number;
begin
	for r in (select attribute_detail,is_encumbered from v_attributes where collection_object_id=cid and ATTRIBUTE_TYPE=attribute) loop
		is_encumbered := is_encumbered + r.is_encumbered;
		l_str := l_str || l_sep || r.attribute_detail;
		l_sep := '; ';
	end loop;
	if is_encumbered > 0 then
		if forceEncumbrance is null then
			select count(*) into is_operator from dba_role_privs where GRANTED_ROLE='COLDFUSION_USER' AND GRANTEE=sys_context('USERENV', 'SESSION_USER');
		else
			is_operator:=0;
		end if;		
		IF is_operator=0 THEN
			l_str := attribute || '=MASKED';
		end if;
	end if;
	return l_str;
  end;
/

CREATE OR REPLACE FUNCTION CONCATATTRIBUTE (cid in varchar2,forceEncumbrance in number default null)
return varchar2 as
	l_str    varchar2(4000);
	l_sep    varchar2(30);
	l_val    varchar2(4000);
	is_encumbered number := 0;
	is_operator number;
begin
	for r in (select attribute_summary,is_encumbered from v_attributes where collection_object_id=cid) loop
		is_encumbered := is_encumbered + r.is_encumbered;
		l_str := l_str || l_sep || r.attribute_summary;
		l_sep := '; ';
	end loop;
	if is_encumbered > 0 then
		if forceEncumbrance is null then
			select count(*) into is_operator from dba_role_privs where GRANTED_ROLE='COLDFUSION_USER' AND GRANTEE=sys_context('USERENV', 'SESSION_USER');
		else
			is_operator:=0;
		end if;		
		IF is_operator=0 THEN
			-- re-run the loop
			-- this is sorta clunky, but only a tiny percentage of attributes are masked
			-- and this approach is the best-performing for those
			l_str := NULL;
			l_sep := NULL;
			for r in (select attribute_type, attribute_summary,is_encumbered from v_attributes where collection_object_id=cid) loop
				if r.is_encumbered = 0 then
					l_str := l_str || l_sep || r.attribute_summary;
					l_sep := '; ';
				else
					l_str := l_str || l_sep || r.attribute_type || '=MASKED';
					l_sep := '; ';
				end if;
			end loop;
		end if;
	end if;
	return l_str;
  end;
/


CREATE OR REPLACE FUNCTION CONCATATTRIBUTEVALUE (cid in varchar2,attribute in varchar2,forceEncumbrance in number default null)
return varchar2 as
	l_str    varchar2(4000);
	l_sep    varchar2(30);
	l_val    varchar2(4000);
	is_encumbered number := 0;
	is_operator number;
begin
	for r in (select trim(attribute_value || ' ' || attribute_units) attr,is_encumbered from v_attributes where collection_object_id=cid and ATTRIBUTE_TYPE=attribute) loop
		is_encumbered := is_encumbered + r.is_encumbered;
		l_str := l_str || l_sep || r.attr;
		l_sep := '; ';
	end loop;
	if is_encumbered > 0 then
		if forceEncumbrance is null then
			select count(*) into is_operator from dba_role_privs where GRANTED_ROLE='COLDFUSION_USER' AND GRANTEE=sys_context('USERENV', 'SESSION_USER');
		else
			is_operator:=0;
		end if;
		IF is_operator=0 THEN
			l_str := 'MASKED';
		end if;
	end if;
	return l_str;
  end;
/



CREATE OR REPLACE VIEW filtered_flat AS
    SELECT
        flags,
        cataloged_item_type,
        LASTDATE,
        LASTUSER,
        nature_of_id,
        collection_object_id,
        enteredby,
        entereddate,
        cat_num,
        accn_id,
        institution_acronym,
        collection_cde,
        collection_id,
        collection,
        minimum_elevation,
        maximum_elevation,
        orig_elev_units,
        identification_id,
        individualcount,
        coll_obj_disposition,
        -- mask collector
        CASE
            WHEN encumbrances LIKE '%mask collector%'
            THEN 'Anonymous'
            ELSE collectors
        END collectors,
        CASE
            WHEN encumbrances LIKE '%mask preparator%'
            THEN 'Anonymous'
            ELSE preparators
        END preparators,
        -- mask original field number
        CASE
            WHEN encumbrances LIKE '%mask original field number%'
            THEN 'Anonymous'
            ELSE field_num
        END field_num,
        otherCatalogNumbers,
        genbankNum,
        relatedCatalogedItemS,
        typeStatus,
        sex,
        parts,
        partdetail,
        accession,
        -- mask original field number
        CASE
            WHEN encumbrances LIKE '%mask year collected%'
            THEN replace(began_date,substr(began_date,1,4),'8888')
            ELSE began_date
        END began_date,
        CASE
            WHEN encumbrances LIKE '%mask year collected%'
            THEN replace(ended_date,substr(ended_date,1,4),'8888')
            ELSE ended_date
        END ended_date,
        CASE
            WHEN encumbrances LIKE '%mask year collected%'
            THEN 'Masked'
            ELSE verbatim_date
        END verbatim_date,
        collecting_event_id,
        higher_geog,
        continent_ocean,
        country,
        state_prov,
        county,
        feature,
        island,
        island_group,
        quad,
        sea,
        geog_auth_rec_id,
        spec_locality,
        min_elev_in_m,
        max_elev_in_m ,
        locality_id,
        -- mask coordinates
        CASE
            WHEN encumbrances LIKE '%mask coordinates%'
            THEN NULL
            ELSE dec_lat
        END dec_lat,
        CASE
            WHEN encumbrances LIKE '%mask coordinates%'
            THEN NULL
            ELSE dec_long
        END dec_long,
        datum,
        orig_lat_long_units,
        CASE
            WHEN encumbrances LIKE '%mask coordinates%'
            THEN 'Masked'
            ELSE verbatim_coordinates
        END verbatim_coordinates,
        coordinateuncertaintyinmeters,
        scientific_name,
        identifiedby,
        made_date,
        CASE
            WHEN encumbrances LIKE '%mask specimen remarks%'
            THEN 'Masked'
            ELSE remarks
        END remarks,
        habitat,
        associated_species,
        encumbrances,
        taxa_formula,
        full_taxon_name,
        phylClass,
        kingdom,
        phylum,
        phylOrder,
        family,
        SUBFAMILY,
        TRIBE,
        SUBTRIBE,
        genus,
        species,
        subspecies,
        infraspecific_rank,
        author_text,
        identificationModifier,
        nomenclatural_code,
        guid,
        basisOfRecord,
        depth_units,
        min_depth,
        max_depth,
        min_depth_in_m,
        max_depth_in_m,
        collecting_method,
        collecting_source,
        dayOfYear,
        age_class,
         CASE
            WHEN encumbrances is not null
            THEN 
            	--call the caoncatenation function with the flag to force-mask attributes 
            	CONCATATTRIBUTE(collection_object_id,1)
            ELSE 
            	-- just use the data from flat
            	attributes
        END attributes,
		verificationStatus,
        specimenDetailUrl,
        imageUrl,
        fieldNotesUrl,
        catalogNumberText,
        '<a href="http://arctos.database.museum/guid/' || guid || '">' || guid || '</a>'  RelatedInformation,
        collectorNumber,
        verbatimelEvation,
        CASE
            WHEN encumbrances LIKE '%mask year collected%'
            THEN 8888
            ELSE year
        END year,
        month,
        day,
        id_sensu,
        '' emptystring,
        verbatim_locality,
		event_assigned_by_agent,
		event_assigned_date,
		specimen_event_remark,
		specimen_event_type,
		COLL_EVENT_REMARKS,
		collecting_event_name,
		georeference_source,
		georeference_protocol,
		locality_name,
		previousidentifications,
		use_license_url,
		IDENTIFICATION_REMARKS,
		LOCALITY_REMARKS,
		formatted_scientific_name
    FROM
        flat
    WHERE
    -- exclude masked records
        (encumbrances is null OR encumbrances NOT LIKE '%mask record%');

    
        
        
        
        
        
        
        
        
        -----------------------------------------------------------------------------------------------------------------------------------------
      
 
 begin
	 for r in (select b.agent_name_id from
	 agent_name a,
	agent_name b
where
	a.agent_id != b.agent_id and
	a.agent_id < b.agent_id and
	a.agent_name=b.agent_name and
	a.agent_name_type='preferred' and
	b.agent_name_type='preferred'
	 ) loop
	dbms_output.put_line(r.agent_name_id);
	end loop;
end;
/


 begin
	 for r in (select b.agent_name_id from
	 agent_name a,
	agent_name b
where
	a.agent_id != b.agent_id and
	a.agent_id < b.agent_id and
	a.agent_name=b.agent_name and
	a.agent_name_type='preferred' and
	b.agent_name_type='preferred'
	 ) loop
	 update agent_name set agent_name=agent_name || ' [dup]' where agent_name_id=r.agent_name_id;
	end loop;
end;
/

 alter table agent add PREFERRED_AGENT_NAME varchar2(255);
 update agent set PREFERRED_AGENT_NAME=(select agent_name from preferred_agent_name where preferred_agent_name.agent_id=agent.agent_id);




 alter table agent modify preferred_agent_name not null;
 create unique index iu_agnt_preferred_name on agent (preferred_agent_name) tablespace uam_idx_1;
 
 
  alter table agent add created_by_agent_id number;
  update agent set created_by_agent_id=0;
  
  alter table agent add created_date date;
  update agent set created_date=sysdate;
  
   alter table agent modify created_date not null;
 alter table agent modify created_by_agent_id not null;

  ALTER TABLE agent add CONSTRAINT fk_creator FOREIGN KEY (created_by_agent_id) REFERENCES agent (agent_id);		    

  

CREATE OR REPLACE TRIGGER trg_agent_bi
    BEFORE INSERT ON agent
    FOR EACH ROW  
    BEGIN
	    :new.created_date := sysdate;
        select agent_id into :new.created_by_agent_id from agent_name where agent_name_type='login' and upper(agent_name)=sys_context('USERENV', 'SESSION_USER');
    end;
/

CREATE OR REPLACE TRIGGER trg_agent_bu
    BEFORE update ON agent
    FOR EACH ROW 
    declare
    	c number;
    BEGIN
	    if :new.agent_type != :old.agent_type then
		    --- disallow orphaning group members
			if :new.agent_type != 'group' and :old.agent_type='group' then
				select count(*) into c from group_member where GROUP_AGENT_ID=:new.agent_id;
				if c > 0 then
					raise_application_error(-20001,'You cannot change this agent to a non-group while there are group members.');
				end if;
			end if;
			if :new.agent_type != 'person' then
				select count(*) into c from agent_name where agent_id=:new.agent_id and agent_name_type in ('first name','middle name','last name');
				if c > 0 then
					raise_application_error(-20001,'Non-person agents cannot have first name, middle name, or last name');
				end if;
			end if;
		end if;
    end;
/


alter table Agent_Name drop column DONOR_CARD_PRESENT_FG;

create table ctagent_status (
	agent_status varchar2(30) not null,
	description varchar2(4000) not null
);

create public synonym ctagent_status for ctagent_status;
grant select on ctagent_status to public;
grant all on ctagent_status to manage_codetables;


drop table log_ctagent_status;

create table log_ctagent_status ( 
		username varchar2(60),	
		when date default sysdate,
		n_agent_status varchar2(30)  null,
		n_description varchar2(4000) null,
		o_agent_status varchar2(30) null,
		o_description varchar2(4000) null
);

create or replace public synonym log_ctagent_status for log_ctagent_status;

grant select on log_ctagent_status to coldfusion_user;

CREATE OR REPLACE TRIGGER TR_log_ctagent_status AFTER INSERT or update or delete ON ctagent_status 
FOR EACH ROW 
BEGIN 
	insert into log_ctagent_status ( 
		username,
		when,
		n_agent_status,
		n_description,
		o_agent_status,
		o_description
	) values ( 
		SYS_CONTEXT('USERENV','SESSION_USER'),
		sysdate,
		:NEW.agent_status,
		:NEW.description,
		:OLD.agent_status,
		:OLD.description
	);
END;
/

sho err;


		
		

ALTER TABLE ctagent_status ADD CONSTRAINT pk_agent_status PRIMARY KEY (agent_status) USING INDEX TABLESPACE UAM_IDX_1;

insert into ctagent_status (agent_status,description) values ('born','Date on which a person is born; old person.birth_date.');
insert into ctagent_status (agent_status,description) values ('died','Date on which a person died; old person.death_date.');
insert into ctagent_status (agent_status,description) values ('alive','Date on which a person was known to be living.');
insert into ctagent_status (agent_status,description) values ('dead','Date on which a person was known to have been dead; not necessarily the date on which they died.)');

drop table Agent_Status;

create table Agent_Status (
	agent_status_id number not null,
	agent_id number not null,
	agent_status varchar2(30) not null,
	status_date varchar2(30) not null,
	status_reported_by number not null,
	status_reported_date date not null,
	status_remark varchar2(255)
);

         


create or replace public synonym Agent_Status for Agent_Status;
grant all on Agent_Status to manage_agents;

create sequence sq_agent_status_id;

CREATE OR REPLACE PUBLIC SYNONYM sq_agent_status_id FOR sq_agent_status_id;
GRANT SELECT ON sq_agent_status_id TO PUBLIC;


CREATE OR REPLACE TRIGGER trg_agent_status_biu
  BEFORE INSERT or update ON agent_status
    FOR EACH ROW
    declare 
        status varchar2(255);
    BEGIN
	   status:=is_iso8601(:NEW.status_date);
        IF status != 'valid' THEN
            raise_application_error(-20001,'Status Date: ' || status);
        END IF;
    end;
/

 
        

 ALTER TABLE Agent_Status add CONSTRAINT fk_status_reported_by FOREIGN KEY (status_reported_by) REFERENCES agent (agent_id);		    
 ALTER TABLE Agent_Status add CONSTRAINT fk_status_agent_id FOREIGN KEY (agent_id) REFERENCES agent (agent_id);		    

 
 drop trigger trg_agent_status_bi;
 
         
 insert into agent_status (
 	agent_status_id,
 	agent_id,
 	agent_status,
 	status_date,
 	status_reported_by,
 	status_reported_date
) ( select 
	sq_agent_status_id.nextval,
	person_id,
	'born',
	birth_date,
	0,
	sysdate
	from person where birth_date is not null);

insert into agent_status (
 	agent_status_id,
 	agent_id,
 	agent_status,
 	status_date,
 	status_reported_by,
 	status_reported_date
) ( select 
	sq_agent_status_id.nextval,
	person_id,
	'died',
	death_date,
	0,
	sysdate
	from person where death_date is not null);
	
	
 CREATE OR REPLACE TRIGGER trg_agent_status_bi
    BEFORE INSERT ON agent_status
    FOR EACH ROW  
    BEGIN
		select 
			agent_id, 
			sq_agent_status_id.nextval,
			sysdate
		into 
			:new.status_reported_by,
			:new.agent_status_id,
			:new.status_reported_date
		from 
			agent_name 
		where 
			agent_name_type='login' and 
			upper(agent_name)=sys_context('USERENV', 'SESSION_USER');
    end;
/

insert into ctagent_name_type (AGENT_NAME_TYPE,DESCRIPTION) values ('first name','given name; old person.first_name');
insert into ctagent_name_type (AGENT_NAME_TYPE,DESCRIPTION) values ('middle name','middle name; old person.middle_name');
insert into ctagent_name_type (AGENT_NAME_TYPE,DESCRIPTION) values ('last name','family name; old person.last_name');


drop trigger PRE_UP_INS_AGENT_NAME;

-- this index no longer works since we can have things like first_name="A." middle_name="A." ....
drop index IU_AGENTNAME_AGENTNAME_AID;


insert into agent_name (
	AGENT_NAME_ID,
	AGENT_ID,
	AGENT_NAME_TYPE,
	AGENT_NAME
) (
select 
	sq_AGENT_NAME_ID.nextval,
	person_id,
	'first name',
	first_name
from 
	person 
where 
	first_name is not null
);


insert into agent_name (
	AGENT_NAME_ID,
	AGENT_ID,
	AGENT_NAME_TYPE,
	AGENT_NAME
) (
select 
	sq_AGENT_NAME_ID.nextval,
	person_id,
	'middle name',
	middle_name
from 
	person 
where 
	middle_name is not null
);




insert into agent_name (
	AGENT_NAME_ID,
	AGENT_ID,
	AGENT_NAME_TYPE,
	AGENT_NAME
) (
select 
	sq_AGENT_NAME_ID.nextval,
	person_id,
	'last name',
	last_name
from 
	person 
where 
	last_name is not null
);


select trim(replace(PREFIX || ' ' || FIRST_NAME || ' ' || MIDDLE_NAME  || ' ' || LAST_NAME  || ' ' || SUFFIX,'  ',' ')) from person;


insert into agent_name (
	AGENT_NAME_ID,
	AGENT_ID,
	AGENT_NAME_TYPE,
	AGENT_NAME
) (
select 
	sq_AGENT_NAME_ID.nextval,
	person_id,
	'aka',
	 trim(replace(PREFIX || ' ' || FIRST_NAME || ' ' || MIDDLE_NAME  || ' ' || LAST_NAME  || ' ' || SUFFIX,'  ',' '))
from 
	person
);



alter table agent modify PREFERRED_AGENT_NAME_ID null;


drop trigger TR_AGENT_NAME_BIUD;



CREATE OR REPLACE FUNCTION getPreferredAgentName(aid IN varchar)
RETURN varchar
AS
   n varchar(255);
BEGIN
    SELECT  /*+ RESULT_CACHE */ preferred_agent_name INTO n FROM agent WHERE agent_id=aid;
    RETURN n;
end;
    /
    sho err;


CREATE or replace PUBLIC SYNONYM getPreferredAgentName FOR getPreferredAgentName;
GRANT EXECUTE ON getPreferredAgentName TO PUBLIC;


create or replace view preferred_agent_name as select
preferred_agent_name AGENT_NAME,
AGENT_ID
from agent;









drop table ds_temp_agent;

create table ds_temp_agent (
	key number not null,
	agent_type varchar2(255),
	preferred_name varchar2(255),
	first_name varchar2(255),
	middle_name varchar2(255),
	last_name varchar2(255),
	birth_date date,
	death_date date,
	prefix varchar2(255),
	suffix varchar2(255),
	other_name_1  varchar2(255),
	other_name_type_1   varchar2(255),
	other_name_2  varchar2(255),
	other_name_type_2   varchar2(255),
	other_name_3  varchar2(255),
	other_name_type_3   varchar2(255),
	other_name_4  varchar2(255),
	other_name_type_4   varchar2(255),
	other_name_5  varchar2(255),
	other_name_type_5   varchar2(255),
	other_name_6  varchar2(255),
	other_name_type_6   varchar2(255),
	agent_remark varchar2(4000),
	agent_status_1 varchar2(255),
	agent_status_date_1 varchar2(255),
	agent_status_2 varchar2(255),
	agent_status_date_2 varchar2(255),
	requires_admin_override number
	);
	
	
	
create public synonym ds_temp_agent for ds_temp_agent;
grant all on ds_temp_agent to coldfusion_user;
grant select on ds_temp_agent to public;

 CREATE OR REPLACE TRIGGER ds_temp_agent_key                                         
 before insert  ON ds_temp_agent
 for each row 
    begin     
    	if :NEW.key is null then                                                                                      
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;                                
    end;                                                                                            
/
sho err


create unique index iu_dsagnt_prefname on ds_temp_agent (preferred_name) tablespace uam_idx_1;



CREATE OR REPLACE TRIGGER trg_agent_aiu
    after update or insert ON agent
    FOR EACH ROW 
    declare
    	c number;
    BEGIN
	    -- maintain preferred name in agent names to simplify searching
	    if inserting then
	   		insert into agent_name (AGENT_NAME_ID,AGENT_ID,AGENT_NAME_TYPE,AGENT_NAME) values (sq_agent_name_id.nextval,:NEW.agent_id,'preferred',:NEW.preferred_agent_name);
	   	elsif updating then
	   		if :NEW.preferred_agent_name != :OLD.preferred_agent_name then
				delete from agent_name where agent_name_type='preferred' and agent_id=:NEW.agent_id;
	   			insert into agent_name (AGENT_NAME_ID,AGENT_ID,AGENT_NAME_TYPE,AGENT_NAME) values (sq_agent_name_id.nextval,:NEW.agent_id,'preferred',:NEW.preferred_agent_name);
	    	end if;
	   end if;
	end;
/




alter table agent drop constraint FK_AGENT_AGENTNAME;
		        
drop trigger TR_AGENTNAME_AIU_FLAT;

CREATE OR REPLACE TRIGGER TR_AGENT_AIU_FLAT
AFTER UPDATE ON agent
FOR EACH ROW
BEGIN
	IF :NEW.preferred_agent_name  != :OLD.preferred_agent_name THEN
    	 UPDATE flat
    	    SET stale_flag = 1,
        	lastuser=sys_context('USERENV', 'SESSION_USER'),
        	lastdate=SYSDATE
    	    WHERE collection_object_id in (
    	    	SELECT collection_object_id 
            	FROM collector 
            	WHERE agent_id = :NEW.agent_id
        	)
        ;
	END IF;
END;
/






-- clean up duplicates of preferred

begin
  for r in (select agent_id from agent_name where agent_name in (select agent_name from agent_name having count(*) > 1 group by agent_name)) loop
    --dbms_output.put_line(r.agent_id);

    delete from agent_name where agent_id=r.agent_id and agent_name_type != 'preferred' and agent_name in (
    select agent_name from agent_name where agent_id=r.agent_id and agent_name_type = 'preferred' 
    );

  end loop;
end;
/






select agent_name,agent_id from agent_name,person where agent_name.agent_id=person.person_id and agent_name=middle_name and middle_name is not null;


AGENT_NAME_TYPE						   NOT NULL VARCHAR2(40)
 DESCRIPTION								    VARCHAR2(4000)

 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 AGENT_NAME_ID							   NOT NULL NUMBER
 AGENT_ID							   NOT NULL NUMBER
 AGENT_NAME_TYPE						   NOT NULL VARCHAR2(18)
 DONOR_CARD_PRESENT_FG
         Table Agent:
        AGENT_ID (primary key)
        AGENT_TYPE (NOT NULL code table, see below)
        PREFERRED_AGENT_NAME (NOT NULL text)
        created_by_agent (NOT NULL, foreign key-->agent, default CURRENTUSER)
        created_on_date (NOT NULL date, default SYSDATE)
        AGENT_REMARKS (NULL text)