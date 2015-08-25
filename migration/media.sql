/*
   	Random note: we can now deal with correspondence by creating a media relation of
	"correspondence for {trans? maybe loan + accn??}"
	
*/    
create table media (
    media_id number not null,
    media_uri varchar2(255) not null,
    mime_type VARCHAR2(255) NOT NULL,
    media_type VARCHAR2(255) NOT NULL,
    preview_uri VARCHAR2(255)
);


ALTER TABLE media
    add CONSTRAINT pk_media
    PRIMARY KEY (media_id);
      
create sequence seq_media;

CREATE OR REPLACE PUBLIC SYNONYM seq_media FOR seq_media;

GRANT SELECT ON seq_media TO PUBLIC;

CREATE OR REPLACE TRIGGER media_seq before insert ON media for each row
   begin     
       IF :new.media_id IS NULL THEN
           select seq_media.nextval into :new.media_id from dual;
       END IF;
   end;                                                                                            
/
sho err

create OR REPLACE public synonym media for media;
    
grant select on media to public;
---------------------------------------------------------------------------------------------------------------------------------
CREATE ROLE manage_media;


grant insert,update,delete on media to manage_media;
INSERT INTO cf_ctuser_roles (role_name,description) VALUES ('manage_media','Access to Media applications');
grant manage_media to dlm;
---------------------------------------------------------------------------------------------------------------------------------
--Table to add any number of arbitrary attributes to a Document:
create sequence seq_media_labels;

CREATE OR REPLACE PUBLIC SYNONYM seq_media_labels FOR seq_media_labels;
    
GRANT SELECT ON seq_media_labels TO PUBLIC;

create table media_labels (
    media_label_id NUMBER NOT NULL,
    media_id number not null,
    media_label varchar2(255) not null,
    label_value  varchar2(255) not null,
    assigned_by_agent_id number not null
);

create public synonym media_labels for media_labels;

grant select on media_labels to public;

grant insert,update,delete on media_labels to manage_media;

create unique index u_media_labels on media_labels (media_id,media_label,label_value) TABLESPACE uam_idx_1;

ALTER TABLE media_labels
    add CONSTRAINT pk_media_labels
    PRIMARY  KEY (media_label_id);
    
ALTER TABLE media_labels
    add CONSTRAINT fk_medialabels_media
      FOREIGN KEY (media_id)
      REFERENCES media(media_id);
      
ALTER TABLE media_labels
    add CONSTRAINT fk_medialabels_agent
      FOREIGN KEY (assigned_by_agent_id)
      REFERENCES agent(agent_id);


CREATE OR REPLACE TRIGGER media_labels_seq before insert  ON media_labels for each row
    begin
        select seq_media_labels.nextval into :new.media_label_id from dual;
        if :NEW.assigned_by_agent_id is null then                                                                                      
            select
                agent_name.agent_id
            into
                :NEW.assigned_by_agent_id
            from
                agent_name
            where
                agent_name_type='login' and
                upper(agent_name.agent_name) = SYS_CONTEXT('USERENV','SESSION_USER');
        end if;                   
    end;                                                                                                                                                                                     
/
--------------------------------------------------------------------------------------------------------------
create table ctmedia_label (media_label varchar2(255) not null);

create unique index iu_ctmedialabel_media_label on ctmedia_label (media_label) TABLESPACE uam_idx_1;

create public synonym ctmedia_label for ctmedia_label;

grant select on ctmedia_label to public;

grant insert,update,delete on ctmedia_label to manage_codetables;
------------------------------------------------------------------------------------------------------
-- controls media types allowed in uploaded files
-- URIs can refer to any media type


create table ctmedia_type (
    media_type varchar2(40) not null,
    description VARCHAR2(4000)
);

create unique index iu_ctctmediatype_media_type on ctmedia_type(media_type) TABLESPACE uam_idx_1;


create public synonym ctmedia_type for ctmedia_type;
grant select on ctmedia_type to public;
grant insert,update,delete on ctmedia_type to manage_codetables;
---------------------------------------------------------------------------------------------------------------
-- controls media types allowed in uploaded files
-- URIs can refer to any media type
create table ctmime_type (
    mime_type varchar2(40) not null,
    description VARCHAR2(4000) NOT NULL
);

create unique index iu_ctmimetype_mime_type on ctmime_type(mime_type) TABLESPACE uam_idx_1;
-- DROP INDEX u_ctmime_type;
create OR REPLACE public synonym ctmime_type for ctmime_type;
grant select on ctmime_type to public;
grant insert,update,delete on ctmime_type to manage_codetables;
ALTER TABLE ctmime_type
    add CONSTRAINT pk_ctmime_type
    PRIMARY  KEY (mime_type);
ALTER TABLE media
    add CONSTRAINT fk_media_ctmimetype
      FOREIGN KEY (mime_type)
      REFERENCES ctmime_type(mime_type);   
---------------------------------------------------------------------------------------------------------------

create table ctmedia_relationship (
    media_relationship varchar2(40) not null
);


/* Usage Rule:
must contain at least one space
value to the right of the space must be a valid and handled table name
*/

create OR REPLACE public synonym ctmedia_relationship for ctmedia_relationship;
grant select on ctmedia_relationship to public;
grant insert,update,delete on ctmedia_relationship to manage_codetables;
ALTER TABLE ctmedia_relationship
    add CONSTRAINT pk_ctmedia_relationship
    PRIMARY  KEY (media_relationship);
-------------------------------------------------------------------------------------------------------------------------
create sequence seq_media_relations;
CREATE OR REPLACE PUBLIC SYNONYM seq_media_relations FOR seq_media_relations;
GRANT SELECT ON seq_media_relations TO PUBLIC;
-- Table to track relationships between media and arbitrary Arctos nodes
create table media_relations (
    media_relations_id number not null,
    media_id number not null,
    media_relationship varchar2(40) not null,
    created_by_agent_id NUMBER NOT NULL,
    related_primary_key NUMBER NOT NULL
    );
    
ALTER TABLE media_relations
    add CONSTRAINT pk_media_relations
      PRIMARY  KEY (media_relations_id);

ALTER TABLE media_relations
    add CONSTRAINT fk_mediarelations_media
      FOREIGN KEY (media_id)
      REFERENCES media(media_id);
      
ALTER TABLE media_relations
    add CONSTRAINT fk_mediarelns_ctmediarelns
      FOREIGN KEY (media_relationship)
      REFERENCES ctmedia_relationship(media_relationship); 
      
ALTER TABLE media_relations
    add CONSTRAINT fk_mediarelns_agent
      FOREIGN KEY (created_by_agent_id)
      REFERENCES agent(agent_id);
           
create OR REPLACE public synonym media_relations for media_relations;
    
grant select on media_relations to public;

grant insert,update,delete on media_relations to manage_specimens;



CREATE OR REPLACE TRIGGER media_relations_seq before insert  ON media_relations for each row
    begin
        select seq_media_relations.nextval into :new.media_relations_id from dual;
        if :NEW.created_by_agent_id is null then                                                                                      
            select
                agent_name.agent_id
            into
                :NEW.created_by_agent_id
            from
                agent_name
            where
                agent_name_type='login' and
                upper(agent_name.agent_name) = SYS_CONTEXT('USERENV','SESSION_USER');
        end if;                   
    end;                                                                                                                                                                                     
/
sho err

CREATE OR REPLACE TRIGGER media_relations_chk before insert OR UPDATE ON media_relations 
    for each row
    declare
    numrows number := 0;
    tabl VARCHAR2(38);
    colName VARCHAR2(38);
BEGIN
        -- makes sure that the string after the last space in media_relationship resolves to a valid table name
        tabl := upper(SUBSTR(:NEW.media_relationship,instr(:NEW.media_relationship,' ',-1)+1));
		SELECT COUNT(*) INTO numrows FROM USEr_tables WHERE upper(table_name)=upper(tabl);
		IF numrows=0 THEN
		     raise_application_error(
    	        -20001,
    	        'Invalid media_relationship'
    	      );
		END IF;
		select COUNT(column_name) INTO numrows from 
            user_constraints,
            user_cons_columns
        where 
            user_constraints.CONSTRAINT_NAME=user_cons_columns.CONSTRAINT_NAME and
            user_constraints.CONSTRAINT_TYPE='P' and
            user_constraints.TABLE_NAME=tabl;
        IF numrows=0 THEN
		     raise_application_error(
    	        -20001,
    	        'Primary key not found.'
    	      );
		END IF;
		select COLUMN_NAME INTO colName from 
        user_constraints,
        user_cons_columns
        where 
        user_constraints.CONSTRAINT_NAME=user_cons_columns.CONSTRAINT_NAME and
        user_constraints.CONSTRAINT_TYPE='P' and
        user_constraints.TABLE_NAME=tabl;
		execute immediate 'SELECT COUNT(*) FROM ' || tabl || ' WHERE ' || colName || '=' || :NEW.related_primary_key  INTO numrows;
		IF numrows=0 THEN
		     raise_application_error(
    	        -20001,
    	        'Related record not found.'
    	      );
		END IF;
END;
/
sho err;

-----------------------------------------------------------------------------------------------
/*
	Maintain a table to create key relationships between Media Relations and any other table (with a numeric pkey, anyway
	
*/
create table tab_media_rel_fkey (media_relations_id number not null);

CREATE OR REPLACE PROCEDURE init_media_fkeys (
	tabl IN varchar2,
	colName in varchar2) IS
	 PRAGMA AUTONOMOUS_TRANSACTION;
	fkname varchar2(38);
	cName varchar2(38);
    sqlstr VARCHAR2(4000);
    BEGIN
    fkname:='CFK_' || tabl; -- foreign key name in the form of FK_AGENT
    cName:='FK_MR_' || tabl; -- constraint name in the form of FK_MR_AGENT
    sqlstr:='ALTER TABLE TAB_MEDIA_REL_FKEY ADD ' || fkname || ' NUMBER ';
    sqlstr:=sqlstr || ' CONSTRAINT ' || cName;
    sqlstr:=sqlstr || ' REFERENCES ' || tabl;
    sqlstr:=sqlstr || '(' || colName || ')';
    EXECUTE IMMEDIATE sqlstr;
    commit;
END;
/
sho err

CREATE PUBLIC SYNONYM tab_media_rel_fkey FOR tab_media_rel_fkey;

CREATE OR REPLACE TRIGGER media_relations_ct before insert OR UPDATE ON ctmedia_relationship 
    for each row
    declare
    numrows number := 0;
    tabl VARCHAR2(38);
    colName VARCHAR2(38);
    fkname VARCHAR2(38);
    sqlstr VARCHAR2(4000);
BEGIN
 		tabl := upper(SUBSTR(:NEW.media_relationship,instr(:NEW.media_relationship,' ',-1)+1));
		SELECT COUNT(*) INTO numrows FROM user_tables WHERE upper(table_name)=upper(tabl);
		IF numrows=0 THEN
		     raise_application_error(
    	        -20001,
    	        'Invalid media_relationship'
    	      );
		END IF;
		select COUNT(column_name) INTO numrows from 
            user_constraints,
            user_cons_columns
        where 
            user_constraints.CONSTRAINT_NAME=user_cons_columns.CONSTRAINT_NAME and
            user_constraints.CONSTRAINT_TYPE='P' and
            user_constraints.TABLE_NAME=tabl;
        IF numrows=0 THEN
		     raise_application_error(
    	        -20001,
    	        'Primary key or related table not found.'
    	      );
		END IF;
		select COLUMN_NAME INTO colName from 
        user_constraints,
        user_cons_columns
        where 
        user_constraints.CONSTRAINT_NAME=user_cons_columns.CONSTRAINT_NAME and
        user_constraints.CONSTRAINT_TYPE='P' and
        user_constraints.TABLE_NAME=tabl;
		
		-- check if this relationship is handled
		fkname:='CFK_' || tabl;
		
		SELECT COUNT(*) INTO numrows FROM all_tab_cols WHERE table_name='TAB_MEDIA_REL_FKEY'  AND column_name=fkname;
		IF numrows=0 THEN
            -- add referencing column using a procedure to avoid the commit-in-trigger error
            init_media_fkeys(tabl,colName);
        END IF;
END;
/
sho err;
-- and AFTER triggers to maintain the key table

CREATE OR REPLACE TRIGGER media_relations_after AFTER insert OR UPDATE OR DELETE ON media_relations 
    for each row
    declare
    numrows number := 0;
    tabl VARCHAR2(38);
    colName VARCHAR2(38);
    fkname VARCHAR2(38);
    sqlstr VARCHAR2(4000);

BEGIN
 		IF inserting THEN
 		    tabl := upper(SUBSTR(:NEW.media_relationship,instr(:NEW.media_relationship,' ',-1)+1));
 		    fkname:='CFK_' || tabl;
 		    sqlstr:='INSERT INTO tab_media_rel_fkey (media_relations_id,' || fkname || ') VALUES (';
 		    sqlstr:=sqlstr || :NEW.media_relations_id || ',' || :NEW.related_primary_key || ')';
 		    EXECUTE IMMEDIATE sqlstr;
 		ELSIF updating THEN
 		    IF :NEW.related_primary_key != :OLD.related_primary_key THEN
     		    tabl := upper(SUBSTR(:NEW.media_relationship,instr(:NEW.media_relationship,' ',-1)+1));
     		    fkname:='CFK_' || tabl;
     		    DELETE FROM tab_media_rel_fkey WHERE media_relations_id=:NEW.media_relations_id;
     		    sqlstr:='INSERT INTO tab_media_rel_fkey (media_relations_id,' || fkname || ') VALUES (';
     		    sqlstr:=sqlstr || :NEW.media_relations_id || ',' || :NEW.related_primary_key || ')';
     		    EXECUTE IMMEDIATE sqlstr;
 		    END IF;
        ELSIF deleting THEN
 		    DELETE FROM tab_media_rel_fkey WHERE media_relations_id=:OLD.media_relations_id;
        END IF;		
END;
/
sho err;


-------------------------------------------------------------------------------------------------
/* random functions to simplify business */
create or replace function get_media_relations_string (mediaID IN number)
	return varchar2
	AS
	the_relation varchar2(4000);
	sep varchar(6);
	tabl varchar2(38);
	theValue varchar2(4000);
begin
	for r in (select * from media_relations,preferred_agent_name where
	media_relations.created_by_agent_id=preferred_agent_name.agent_id and
	media_id=mediaID) loop
		the_relation:=the_relation || sep || r.media_relationship || ': ';
		-- find table name
		tabl := SUBSTR(r.media_relationship,instr(r.media_relationship,' ',-1)+1);
		--the_relation:=the_relation || '; table: ' || tabl;
		case tabl 
			when 'locality' then
				select spec_locality into theValue from locality where locality_id=r.related_primary_key;
				the_relation:=the_relation || theValue;
			when 'collecting_event' then
				select verbatim_locality || ' (' || verbatim_date || ')' into theValue from collecting_event 
				where collecting_event_id=r.related_primary_key;
				the_relation:=the_relation || theValue;
			when 'agent' then
				select agent_name into theValue from preferred_agent_name where agent_id=r.related_primary_key;
				the_relation:=the_relation || theValue;
			when 'media' then
				select media_uri into theValue from media where media_id=r.related_primary_key;
				the_relation:=the_relation || theValue;
			when 'cataloged_item' then
				select collection || ' ' || cat_num into theValue from cataloged_item,
				collection where
				cataloged_item.collection_id=collection.collection_id and
				 collection_object_id=r.related_primary_key;
				the_relation:=the_relation || theValue;
			else
				the_relation:=the_relation || 'Unknown table: ' || tabl || ' (PKEY: ' || r.related_primary_key || ')';
		end case;
		
		     
     
				--dbms_output.put_line(r.media_relationship);
		sep := ';';
	end loop;
	return the_relation;
end;
/
sho err

-- select get_media_relations(24) from dual;


create or replace function q_media_relations (mediaID IN number)
	return varchar2 
	-- returns pipe-delimited list of media relations
	-- media_relations_id|media_relationship|related_primary_key|summary_value
	AS
	the_relation varchar2(4000);
	sep varchar(6);
	tabl varchar2(38);
	theValue varchar2(4000);
begin
	for r in (select * from media_relations,preferred_agent_name where
	media_relations.created_by_agent_id=preferred_agent_name.agent_id and
	media_id=mediaID) loop
		the_relation:=the_relation || sep || r.media_relations_id || '|' || r.media_relationship;
		-- find table name
		tabl := SUBSTR(r.media_relationship,instr(r.media_relationship,' ',-1)+1);
		the_relation:=the_relation || '|' || r.related_primary_key;
		case tabl 
			when 'locality' then
				select spec_locality into theValue from locality where locality_id=r.related_primary_key;
				the_relation:=the_relation || '|' ||  theValue;
			when 'collecting_event' then
				select verbatim_locality || ' (' || verbatim_date || ')' into theValue from collecting_event 
				where collecting_event_id=r.related_primary_key;
				the_relation:=the_relation ||  '|' || theValue;
			when 'agent' then
				select agent_name into theValue from preferred_agent_name where agent_id=r.related_primary_key;
				the_relation:=the_relation ||  '|' || theValue;
			when 'media' then
				select media_uri into theValue from media where media_id=r.related_primary_key;
				the_relation:=the_relation ||  '|' || theValue;
			when 'cataloged_item' then
				select collection || ' ' || cat_num into theValue from cataloged_item,
				collection where
				cataloged_item.collection_id=collection.collection_id and
				 collection_object_id=r.related_primary_key;
				the_relation:=the_relation ||  '|' || theValue;
			else
				the_relation:=the_relation ||  '|' || 'Unknown table';
		end case;
		
		     
     
				--dbms_output.put_line(r.media_relationship);
		sep := chr(10);
	end loop;
	return the_relation;
end;
/
sho err
CREATE OR REPLACE PUBLIC SYNONYM q_media_relations FOR q_media_relations;
GRANT EXECUTE ON q_media_relations TO PUBLIC;



create or replace function media_relation_summary (mediaRelationsId IN number)
	return varchar2 
	AS
	summary varchar2(4000);
	mr varchar2(4000);
	fkey NUMBER;
	tabl varchar2(4000);
begin
	select media_relationship,related_primary_key
	 INTO mr,fkey from media_relations where media_relations_id = mediaRelationsId;
	tabl := SUBSTR(mr,instr(mr,' ',-1)+1);
	    case tabl 
			when 'locality' then
				select spec_locality into summary from locality where locality_id=fkey;
			when 'collecting_event' then
				select verbatim_locality || ' (' || verbatim_date || ')' into summary from collecting_event 
				where collecting_event_id=fkey;
			when 'agent' then
				select agent_name into summary from preferred_agent_name where agent_id=fkey;
			when 'media' then
				select media_uri into summary from media where media_id=fkey;
			when 'cataloged_item' then
				select collection || ' ' || cat_num into summary from cataloged_item,
				collection where
				cataloged_item.collection_id=collection.collection_id and
				 collection_object_id=fkey;
			else
				summary:='Unknown table';
		end case;

	return summary;
end;
/
sho err
CREATE OR REPLACE PUBLIC SYNONYM media_relation_summary FOR media_relation_summary;
GRANT EXECUTE ON media_relation_summary TO PUBLIC;

-----------------------------------------------------------------------------------------------------------------
-- seed some values in

INSERT INTO ctmedia_label VALUES ('subject');
INSERT INTO ctmedia_label VALUES ('description');
INSERT INTO ctmedia_label VALUES ('made date');
INSERT INTO ctmedia_label VALUES ('aspect');

INSERT INTO ctmedia_type (media_type,description) VALUES ('image','An image of any MIME type, including one embedded in an external application');
INSERT INTO ctmedia_type (media_type,description) VALUES ('audio','An audio file of any MIME type, including one embedded in an external application');
INSERT INTO ctmedia_type (media_type,description) VALUES ('video','A video file of any MIME type, including one embedded in an external application');
INSERT INTO ctmedia_type (media_type,description) VALUES ('text','A text file of any MIME type, including one embedded in an external application');

INSERT INTO ctmime_type (mime_type,description) VALUES
    ('text/html','http://www.rfc-editor.org/rfc/rfc2854.txt');
INSERT INTO ctmime_type (mime_type,description) VALUES
    ('image/png','Portable Network Graphic');
INSERT INTO ctmime_type (mime_type,description) VALUES
    ('image/jpeg','Joint Photographic Experts Group');
INSERT INTO ctmime_type (mime_type,description) VALUES
    ('image/dng','Digital Negative image (Adobe)');
INSERT INTO ctmime_type (mime_type,description) VALUES
    ('image/tiff','Tagged Image File Format');   

INSERT INTO ctmedia_relationship VALUES ('shows cataloged_item');
INSERT INTO ctmedia_relationship VALUES ('created by agent');