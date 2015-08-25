CREATE SEQUENCE sq_ala_image_id NOCACHE START WITH 140821;
DROP SEQUENCE ala_plant_imaging_seq;

DROP TRIGGER ALA_PLANT_IMAGING_KEY;

CREATE OR REPLACE TRIGGER tr_ala_plant_imaging_sq
before insert ON ala_plant_imaging
for each row
begin
    if :new.image_id is null then
        select sq_ala_image_id.nextval
        into :new.image_id from dual;
    end if;
end;
/

DROP SEQUENCE canned_id_seq;

CREATE SEQUENCE sq_canned_id NOCACHE START WITH 3127;

CREATE OR REPLACE TRIGGER CF_CANNED_SEARCH_TRG
BEFORE INSERT
ON cf_canned_search
REFERENCING NEW AS NEW
FOR EACH ROW
BEGIN
    IF :NEW.canned_id IS NULL THEN
        SELECT sq_canned_id.nextval
    	INTO :NEW.canned_id FROM dual;
    END IF;
END;
/

ALTER TRIGGER CF_CANNED_SEARCH_TRG RENAME TO TR_CF_CANNED_SEARCH_SQ;

CREATE OR REPLACE TRIGGER TR_CFCOLLECTION_SQ
BEFORE INSERT ON cf_collection
FOR EACH ROW
BEGIN
    IF :NEW.cf_collection_id IS NULL THEN
        SELECT SQ_CF_COLLECTION_ID.nextval
        into :NEW.cf_collection_id from dual;
    END IF;
END;
/
ALTER TRIGGER TR_CFCOLLECTION_SQ RENAME TO TR_CF_COLLECTION_SQ;

CREATE OR REPLACE TRIGGER CF_FORM_PERMISSIONS_KEY
BEFORE UPDATE OR INSERT ON cf_form_permissions
FOR EACH ROW
BEGIN
    IF :new.key IS NULL THEN
        SELECT somerandomsequence.NEXTVAL
        INTO :new.KEY FROM dual;
    END IF;
END;
/
CREATE SEQUENCE sq_log_id START WITH 10447470 NOCACHE;

CREATE OR REPLACE TRIGGER CF_LOG_ID
before insert ON cf_log
for each row
begin
    if :NEW.log_id is null then
        select sq_log_id.nextval into :new.log_id from dual;
    end if;
        
    if :NEW.access_date is null then
        :NEW.access_date:= sysdate;
    end if;
end;
ALTER TRIGGER CF_LOG_ID RENAME TO TR_CF_LOG_SQ;
/

create sequence sq_report_id nocache start with 5600869;

CREATE OR REPLACE TRIGGER CF_REPORT_SQL_KEY
before insert ON cf_report_sql
for each row
begin
    if :NEW.report_id is null then
        select SQ_REPORT_ID.nextval
        into :new.report_id from dual;
    end if;
end;
/
ALTER TRIGGER CF_REPORT_SQL_KEY RENAME TO tr_cf_report_sql_sq;

create sequence sq_CF_SPEC_RES_COLS_ID start with 5594223 nocache;

CREATE OR REPLACE TRIGGER TRG_CF_SPEC_RES_COLS_ID
BEFORE INSERT ON cf_spec_res_cols
FOR EACH ROW
BEGIN
    if :new.cf_spec_res_cols_id is null then
        SELECT sq_cf_spec_res_cols_id.nextval 
        INTO :new.cf_spec_res_cols_id FROM dual;
    end if;
END;
/

ALTER TRIGGER TRG_CF_SPEC_RES_COLS_ID RENAME TO tr_cf_spec_res_cols_sq;

CREATE OR REPLACE TRIGGER CF_TEMP_AGENTS_KEY
before insert  ON cf_temp_agents
for each row
begin
    if :NEW.key is null then
        select somerandomsequence.nextval
        into :new.key from dual;
    end if;
end;
/

CREATE OR REPLACE TRIGGER CF_TEMP_ATTRIBUTES_KEY
before insert  ON cf_temp_attributes
for each row
begin
    if :NEW.key is null then
        select somerandomsequence.nextval
        into :new.key from dual;
    end if;
end;
/

CREATE OR REPLACE TRIGGER CF_TEMP_CITATION_KEY
before insert ON cf_temp_citation
for each row
begin
    if :NEW.key is null then
        select somerandomsequence.nextval
        into :new.key from dual;
    end if;
end;
/

CREATE OR REPLACE TRIGGER CF_TEMP_LOAN_ITEM_KEY
before insert ON cf_temp_loan_item
for each row
begin
    if :NEW.key is null then
        select somerandomsequence.nextval
        into :new.key from dual;
    end if;
end;

CREATE OR REPLACE TRIGGER CF_TEMP_OIDS_KEY
before insert  ON cf_temp_oids
for each row
begin
    if :NEW.key is null then
        select somerandomsequence.nextval
        into :new.key from dual;
    end if;
end;
/

CREATE OR REPLACE TRIGGER CF_TEMP_PARTS_KEY
before insert  ON cf_temp_parts
for each row
begin
    if :NEW.key is null then
        select somerandomsequence.nextval
        into :new.key from dual;
    end if;
end;
/

CREATE OR REPLACE TRIGGER CF_TEMP_TAXONOMY_KEY
before insert  ON cf_temp_taxonomy
for each row
DECLARE
    nsn varchar2(4000);
begin
    if :NEW.key is null then
        select somerandomsequence.nextval
        into :new.key from dual;
    end if;

    IF :NEW.subspecies IS NOT null THEN
        nsn := :NEW.subspecies;
    END IF;
    IF :NEW.infraspecific_rank IS NOT null THEN
        nsn := :NEW.infraspecIFic_rank || ' ' || nsn;
    END IF;
    IF :NEW.species IS NOT null THEN
        nsn := :NEW.species || ' ' || nsn;
    END IF;
    IF :NEW.genus IS NOT null THEN
        nsn := :NEW.genus || ' ' || nsn;
    END IF;
    IF :NEW.tribe IS NOT null THEN
        IF nsn IS null THEN
            nsn := :NEW.tribe;
        END IF;
    END IF;
    IF :NEW.subfamily IS NOT null THEN
        IF nsn IS null THEN
            nsn := :NEW.subfamily;
        END IF;
    END IF;
    IF :NEW.family IS NOT null THEN
        IF nsn IS null THEN
            nsn := :NEW.family;
        END IF;
    END IF;
    IF :NEW.suborder IS NOT null THEN
        IF nsn IS null THEN
            nsn := :NEW.suborder;
        END IF;
    END IF;
    IF :NEW.phylorder IS NOT null THEN
        IF nsn IS null THEN
            nsn := :NEW.phylorder;
        END IF;
    END IF;
    IF :NEW.phylclass IS NOT null THEN
        IF nsn IS null THEN
            nsn := :NEW.phylclass;
        END IF;
    END IF;
    IF :NEW.phylum IS NOT null THEN
        IF nsn IS null THEN
            nsn := :NEW.phylum;
        END IF;
    END IF;
    :NEW.scientific_name := trim(nsn);
end;
/

CREATE OR REPLACE TRIGGER TRG_OBJECT_CONDITION
AFTER UPDATE OR INSERT ON coll_object
FOR EACH ROW
DECLARE
    usrid NUMBER;
    cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO cnt
    FROM agent_name
    WHERE agent_name_type = 'login'
    AND upper(agent_name.agent_name) = SYS_CONTEXT('USERENV','SESSION_USER');

    IF cnt=1 THEN
        SELECT agent_id INTO usrid
        FROM agent_name
        WHERE agent_name_type = 'login'
        AND upper(agent_name.agent_name) = SYS_CONTEXT('USERENV','SESSION_USER');
    ELSE
        usrid:=0;
    END IF;

    IF inserting THEN
        INSERT INTO object_condition (
            OBJECT_CONDITION_ID,
            COLLECTION_OBJECT_ID,
            CONDITION,
            DETERMINED_AGENT_ID,
            DETERMINED_DATE)
        VALUES(
            sq_object_condition_id.nextval,
            :NEW.COLLECTION_OBJECT_ID,
            :NEW.CONDITION,
            usrid,
            SYSDATE);
    ELSIF updating THEN
        IF :new.condition != :old.condition THEN
            INSERT INTO object_condition (
                OBJECT_CONDITION_ID,
                COLLECTION_OBJECT_ID,
                CONDITION,
                DETERMINED_AGENT_ID,
                DETERMINED_DATE)
            VALUES(
                sq_object_condition_id.nextval,
                :NEW.COLLECTION_OBJECT_ID,
                :NEW.CONDITION,
                usrid,
                SYSDATE);
        END IF;
    END IF;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        NULL; -- just ignore
END;
/

ALTER TRIGGER TRG_OBJECT_CONDITION RENAME TO tr_object_condition_aiu_sq;

CREATE OR REPLACE TRIGGER TR_COLL_OBJ_OTHER_ID_NUM_SQ
before insert on coll_obj_other_id_num
for each row
begin
    IF :new.coll_obj_other_id_num_id IS NULL THEN
        select sq_coll_obj_other_id_num_id.nextval
        into :new.coll_obj_other_id_num_id
        from dual;
    END IF;
end;
/

CREATE OR REPLACE TRIGGER CONTAINER_CHECK_ID
before insert ON container_check
for each row
begin
    if :NEW.container_check_id is null then
        select sq_container_check_id.nextval
        into :new.container_check_id from dual;
    end if;

    if :NEW.check_date is null then
        :NEW.check_date:= sysdate;
    end if;
end;
/
ALTER TRIGGER CONTAINER_CHECK_ID RENAME TO tr_container_check_bi_sq;

drop sequence seq_geology_attributes;
create sequence sq_geology_attribute_id nocache start with 148;

CREATE OR REPLACE TRIGGER GEOLOGY_ATTRIBUTES_SEQ
before insert ON geology_attributes
for each row
begin
    IF :new.geology_attribute_id IS NULL THEN
        select sq_geology_attribute_id.nextval
        into :new.geology_attribute_id
        from dual;
    END IF;
end;
/

ALTER TRIGGER GEOLOGY_ATTRIBUTES_SEQ RENAME TO sq_geology_attributes_sq;

CREATE OR REPLACE TRIGGER GEOL_ATT_HIERARCHY_SEQ
before insert ON geology_attribute_hierarchy
for each row
begin
    IF :new.geology_attribute_hierarchy_id IS NULL THEN
        select sq_geology_attribute_hier_id.nextval
        into :new.geology_attribute_hierarchy_id
        from dual;
    END IF;
end;
/

ALTER TRIGGER GEOL_ATT_HIERARCHY_SEQ RENAME TO TR_GEOL_ATTR_HIER_SQ;

drop sequence identification_agent_seq;
create sequence sq_identification_agent_id nocache start with 10767761;

CREATE OR REPLACE TRIGGER IDENTIFICATION_AGENT_TRG
BEFORE INSERT ON identification_agent
FOR EACH ROW
BEGIN
    IF :NEW.identification_agent_id IS NULL THEN
        SELECT sq_identification_agent_id.nextval
        INTO :new.identification_agent_id FROM dual;
    END IF;
END;
/
alter trigger IDENTIFICATION_AGENT_TRG rename to tr_IDENTIFICATION_AGENT_sq;

create sequence sq_media_id nocache start with 10008506;
drop sequence seq_media;

CREATE OR REPLACE TRIGGER MEDIA_SEQ
before insert ON media
for each row
begin
    IF :new.media_id IS NULL THEN
        select sq_media_id.nextval
        into :new.media_id from dual;
    END IF;
end;

alter trigger MEDIA_SEQ rename to tr_media_sq;


create sequence sq_media_label_id nocache start with 10025622;
drop sequence seq_media_labels;

CREATE OR REPLACE TRIGGER MEDIA_LABELS_SEQ
before insert ON media_labels for each row
begin
    IF :new.media_label_id IS NULL THEN
        select sq_media_label_id.nextval
    	into :new.media_label_id from dual;
    END IF;

    if :NEW.assigned_by_agent_id is null then
        select agent_name.agent_id
        into :NEW.assigned_by_agent_id
        from agent_name
        where agent_name_type='login'
        and upper(agent_name.agent_name) = SYS_CONTEXT('USERENV','SESSION_USER');
    end if;
end;
/
alter trigger MEDIA_LABELS_SEQ rename to tr_media_labels_sq;

drop sequence seq_media_labels;
create sequence sq_media_label_id nocache start with 10025622;

CREATE OR REPLACE TRIGGER MEDIA_RELATIONS_SEQ
before insert ON media_relations
for each row
begin
    IF :new.media_relations_id IS NULL THEN
        select sq_media_relations_id.nextval
    	into :new.media_relations_id from dual;
    END IF;

    if :NEW.created_by_agent_id is null then
        select agent_name.agent_id
        into :NEW.created_by_agent_id
        from agent_name
        where agent_name_type='login'
        and upper(agent_name.agent_name) = SYS_CONTEXT('USERENV','SESSION_USER');
    end if;
end;
/

alter trigger MEDIA_RELATIONS_SEQ rename to tr_media_relations_sq;

create sequence sq_project_sponsor_id nocache start with 23;
drop sequence project_sponsor_seq;

CREATE OR REPLACE TRIGGER TRIG_PROJECT_SPONSOR_ID
before INSERT on project_sponsor
for each row
BEGIN
    if :NEW.project_sponsor_id is null then
        select sq_project_sponsor_id.nextval
        into :new.project_sponsor_id from dual;
    end if;
END;
/

alter trigger TRIG_PROJECT_SPONSOR_ID rename to tr_project_sponsor_sq;

create sequence sq_annotation_id nocache start with 262;
drop sequence specimen_annotations_seq;

CREATE OR REPLACE TRIGGER SPECIMEN_ANNOTATIONS_KEY
before insert ON specimen_annotations
for each row
begin
    if :NEW.annotation_id is null then
        select sq_annotation_id.nextval
        into :new.annotation_id from dual;
    end if;

    if :NEW.annotate_date is null then
        :NEW.annotate_date := sysdate;
    end if;
end;
/
alter trigger SPECIMEN_ANNOTATIONS_KEY rename to tr_specimen_annotations_sq;

CREATE OR REPLACE TRIGGER MAKE_PART_COLL_OBJ_CONT
after insert ON specimen_part
FOR EACH ROW
declare
    label varchar2(255);
    institution_acronym varchar2(255);
BEGIN
    select
        collection.institution_acronym,
        collection.collection || ' ' || cataloged_item.cat_num || ' ' || :NEW.part_name
    INTO institution_acronym, label
    FROM collection, cataloged_item
    WHERE collection.collection_id = cataloged_item.collection_id
    AND cataloged_item.collection_object_id = :NEW.derived_from_cat_item;

    INSERT INTO container (
        CONTAINER_ID,
        PARENT_CONTAINER_ID,
        CONTAINER_TYPE,
        LABEL,
        locked_position,
        institution_acronym)
    VALUES (
        sq_container_id.nextval,
        0,
        'collection object',
        label,
        0,
        institution_acronym);

    INSERT INTO coll_obj_cont_hist (
        COLLECTION_OBJECT_ID,
        CONTAINER_ID,
        INSTALLED_DATE,
        CURRENT_CONTAINER_FG)
    VALUES (
        :NEW.collection_object_id,
        sq_container_id.currval,
        sysdate,
        1);
EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20000, 'trigger problems: ' || SQLERRM);
end;
/

drop sequence trans_agent_seq;
create sequence sq_trans_agent_id nocache start with 10047595;

CREATE OR REPLACE TRIGGER TRANS_AGENT_PRE
BEFORE UPDATE OR INSERT ON trans_agent
FOR EACH ROW
DECLARE
    numrows NUMBER;
BEGIN
    IF :new.trans_agent_id IS NULL THEN
        SELECT sq_trans_agent_id.NEXTVAL
        INTO :new.trans_agent_id FROM dual;
    END IF;

    SELECT COUNT(*) INTO numrows
    FROM cttrans_agent_role
    WHERE trans_agent_role = :new.trans_agent_role;

    IF (numrows = 0) THEN
        raise_application_error(
        -20001,
        'Invalid trans_agent_role');
    END IF;
END;
/
alter trigger TRANS_AGENT_PRE rename to tr_trans_agent_bui_sq;

/*
CREATE OR REPLACE TRIGGER ALA_PLANT_IMAGING_KEY
before insert ON ala_plant_imaging
for each row
begin
    if :new.image_id is null then
        select ala_plant_imaging_seq.nextval
        into :new.image_id from dual;
    end if;
end;
/

CREATE OR REPLACE TRIGGER CFRELEASE_NOTES_ID
before insert  ON cfRelease_notes
for each row
begin
    if :NEW.release_note_id is null then
        select somerandomsequence.nextval
        into :new.release_note_id from dual;
    end if;
end;
/

CREATE OR REPLACE TRIGGER CF_CANNED_SEARCH_TRG
BEFORE INSERT
ON cf_canned_search
REFERENCING NEW AS NEW
FOR EACH ROW
BEGIN
    SELECT canned_id_seq.nextval
    INTO :NEW.canned_id FROM dual;
END;
/

CREATE OR REPLACE TRIGGER TR_CFCOLLECTION_SQ
BEFORE INSERT ON cf_collection
FOR EACH ROW
BEGIN
    IF :NEW.cf_collection_id IS NULL THEN
        SELECT SQ_CF_COLLECTION_ID.nextval
        into :NEW.cf_collection_id from dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER CF_FORM_PERMISSIONS_KEY
BEFORE UPDATE OR INSERT ON cf_form_permissions
FOR EACH ROW
BEGIN
    IF :new.key IS NULL THEN
        SELECT somerandomsequence.NEXTVAL
        INTO :new.KEY FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER CF_LOG_ID
before insert  ON cf_log
for each row
begin
    if :NEW.log_id is null then
        select somerandomsequence.nextval
        into :new.log_id from dual;
    end if;
    if :NEW.access_date is null then
        :NEW.access_date:= sysdate;
    end if;
end;
/

CREATE OR REPLACE TRIGGER TR_CF_REPORT_SQL_BI
before insert ON cf_report_sql
for each row
begin
    if :NEW.report_id is null then
        select SQ_REPORT_ID.nextval
        into :new.report_id from dual;
    end if;
end;
/

CREATE OR REPLACE TRIGGER TRG_CF_SPEC_RES_COLS_ID
BEFORE INSERT ON cf_spec_res_cols
FOR EACH ROW
BEGIN
    SELECT somerandomsequence.nextval
    INTO :new.cf_spec_res_cols_id
    FROM dual;
END;
/

CREATE OR REPLACE TRIGGER CF_TEMP_AGENTS_KEY
before insert  ON cf_temp_agents
for each row
begin
    if :NEW.key is null then
        select somerandomsequence.nextval
        into :new.key from dual;
    end if;
end;
/

CREATE OR REPLACE TRIGGER CF_TEMP_ATTRIBUTES_KEY
before insert  ON cf_temp_attributes
for each row
begin
    if :NEW.key is null then
        select somerandomsequence.nextval
        into :new.key from dual;
    end if;
end;
/

CREATE OR REPLACE TRIGGER CF_TEMP_CITATION_KEY
before insert ON cf_temp_citation
for each row
begin
    if :NEW.key is null then
        select somerandomsequence.nextval
        into :new.key from dual;
    end if;
end;
/

CREATE OR REPLACE TRIGGER CF_TEMP_CONT_EDIT_KEY
before insert  ON cf_temp_cont_edit
for each row
begin
    if :NEW.key is null then
        select somerandomsequence.nextval
        into :new.key from dual;
    end if;
end;
/

CREATE OR REPLACE TRIGGER CF_TEMP_ID_KEY
before insert ON cf_temp_id
for each row
begin
    if :NEW.key is null then
        select somerandomsequence.nextval
        into :new.key from dual;
    end if;
end;
/

CREATE OR REPLACE TRIGGER CF_TEMP_LOAN_ITEM_KEY
before insert ON cf_temp_loan_item
for each row
begin
    if :NEW.key is null then
        select somerandomsequence.nextval
        into :new.key from dual;
    end if;
end;

CREATE OR REPLACE TRIGGER CF_TEMP_OIDS_KEY
before insert  ON cf_temp_oids
for each row
begin
    if :NEW.key is null then
        select somerandomsequence.nextval
        into :new.key from dual;
    end if;
end;
/

CREATE OR REPLACE TRIGGER CF_TEMP_PARTS_KEY
before insert  ON cf_temp_parts
for each row
begin
    if :NEW.key is null then
        select somerandomsequence.nextval
        into :new.key from dual;
    end if;
end;
/

CREATE OR REPLACE TRIGGER CF_TEMP_PART_SAMPLE_KEY
before insert  ON cf_temp_part_sample
for each row
begin
    if :NEW.i$key is null then
        select somerandomsequence.nextval
        into :new.i$key from dual;
    end if;
end;
/

CREATE OR REPLACE TRIGGER CF_TEMP_TAXONOMY_KEY
before insert  ON cf_temp_taxonomy
for each row
DECLARE
    nsn varchar2(4000);
begin
    if :NEW.key is null then
        select somerandomsequence.nextval
        into :new.key from dual;
    end if;

    IF :NEW.subspecies IS NOT null THEN
        nsn := :NEW.subspecies;
    END IF;
    IF :NEW.infraspecific_rank IS NOT null THEN
        nsn := :NEW.infraspecIFic_rank || ' ' || nsn;
    END IF;
    IF :NEW.species IS NOT null THEN
        nsn := :NEW.species || ' ' || nsn;
    END IF;
    IF :NEW.genus IS NOT null THEN
        nsn := :NEW.genus || ' ' || nsn;
    END IF;
    IF :NEW.tribe IS NOT null THEN
        IF nsn IS null THEN
            nsn := :NEW.tribe;
        END IF;
    END IF;
    IF :NEW.subfamily IS NOT null THEN
        IF nsn IS null THEN
            nsn := :NEW.subfamily;
        END IF;
    END IF;
    IF :NEW.family IS NOT null THEN
        IF nsn IS null THEN
            nsn := :NEW.family;
        END IF;
    END IF;
    IF :NEW.suborder IS NOT null THEN
        IF nsn IS null THEN
            nsn := :NEW.suborder;
        END IF;
    END IF;
    IF :NEW.phylorder IS NOT null THEN
        IF nsn IS null THEN
            nsn := :NEW.phylorder;
        END IF;
    END IF;
    IF :NEW.phylclass IS NOT null THEN
        IF nsn IS null THEN
            nsn := :NEW.phylclass;
        END IF;
    END IF;
    IF :NEW.phylum IS NOT null THEN
        IF nsn IS null THEN
            nsn := :NEW.phylum;
        END IF;
    END IF;
    :NEW.scientific_name := trim(nsn);
end;
/

CREATE OR REPLACE TRIGGER CF_VERSION_PKEY_TRG
before insert on cf_version for each row
WHEN (new.version_id is null)
begin
    select cf_version_seq.nextval
    into :new.version_id
    from dual;
end;
/

CREATE OR REPLACE TRIGGER CF_VERSION_LOG_PKEY_TRG
before insert on cf_
version_log for each row
WHEN (new.version_log_id is null)
begin
    select cf_version_log_seq.nextval
    into :new.version_log_id
    from dual;
end;
/
 
CREATE OR REPLACE TRIGGER TRG_OBJECT_CONDITION
AFTER UPDATE OR INSERT ON coll_object
FOR EACH ROW
DECLARE
    usrid NUMBER;
    cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO cnt
    FROM agent_name
    WHERE agent_name_type = 'login'
    AND upper(agent_name.agent_name) = SYS_CONTEXT('USERENV','SESSION_USER');

    IF cnt=1 THEN
        SELECT agent_id INTO usrid
        FROM agent_name
        WHERE agent_name_type = 'login'
        AND upper(agent_name.agent_name) = SYS_CONTEXT('USERENV','SESSION_USER');
    ELSE
        usrid:=0;
    END IF;

    IF inserting THEN
        INSERT INTO object_condition (
            OBJECT_CONDITION_ID,
            COLLECTION_OBJECT_ID,
            CONDITION,
            DETERMINED_AGENT_ID,
            DETERMINED_DATE)
        VALUES(
            objcondid.nextval,
            :NEW.COLLECTION_OBJECT_ID,
            :NEW.CONDITION,
            usrid,
            SYSDATE);
    ELSIF updating THEN
        IF :new.condition != :old.condition THEN
            INSERT INTO object_condition (
                OBJECT_CONDITION_ID,
                COLLECTION_OBJECT_ID,
                CONDITION,
                DETERMINED_AGENT_ID,
                DETERMINED_DATE)
            VALUES(
                objcondid.nextval,
                :NEW.COLLECTION_OBJECT_ID,
                :NEW.CONDITION,
                usrid,
                SYSDATE);
        END IF;
    END IF;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        NULL; -- just ignore
END;
/

CREATE OR REPLACE TRIGGER TR_COLL_OBJ_OTHER_ID_NUM_SQ
before insert on coll_obj_other_id_nuM
for each row
begin
    IF :new.coll_obj_other_id_num_id IS NULL THEN
        select sq_coll_obj_other_id_num_id.nextval
        into :new.coll_obj_other_id_num_id
        from dual;
    END IF;
end;
/

CREATE OR REPLACE TRIGGER CONTAINER_CHECK_ID
before insert ON container_check
for each row
begin
    if :NEW.container_check_id is null then
        select sq_container_check_id.nextval
        into :new.container_check_id from dual;
    end if;

    if :NEW.check_date is null then
        :NEW.check_date:= sysdate;
    end if;
end;
/

CREATE OR REPLACE TRIGGER DEV_TASK_DEF
before insert ON dev_task
for each row
BEGIN
    if :new.task_id is null then
        select dev_task_seq.nextval
        into :new.task_id from dual;
    end if;
end;
/

CREATE OR REPLACE TRIGGER DOCUMENTATION_PKEY
before insert  ON documentation
for each row
begin
    if :NEW.DOC_ID is null then
        select documentation_seq.nextval
        into :new.DOC_ID from dual;
    end if;
end;
/

CREATE OR REPLACE TRIGGER GEOLOGY_ATTRIBUTES_SEQ
before insert ON geology_attributes
for each row
begin
    IF :new.geology_attribute_id IS NULL THEN
        select seq_geology_attributes.nextval
        into :new.geology_attribute_id
        from dual;
    END IF;
end;
/

CREATE OR REPLACE TRIGGER GEOL_ATT_HIERARCHY_SEQ
before insert ON geology_attribute_hierarchy
for each row
begin
    IF :new.geology_attribute_hierarchy_id IS NULL THEN
        select sq_geology_attribute_hier_id.nextval
        into :new.geology_attribute_hierarchy_id
        from dual;
    END IF;
end;
/

CREATE OR REPLACE TRIGGER IDENTIFICATION_AGENT_TRG
BEFORE INSERT ON identification_agent
FOR EACH ROW
BEGIN
    IF :NEW.identification_agent_id IS NULL THEN
        SELECT identification_agent_seq.nextval
        INTO :new.identification_agent_id FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER MEDIA_SEQ
before insert ON media for each row
begin
    IF :new.media_id IS NULL THEN
        select seq_media.nextval
        into :new.media_id from dual;
    END IF;
end;

CREATE OR REPLACE TRIGGER MEDIA_LABELS_SEQ
before insert  ON media_labels for each row
begin
    select seq_media_labels.nextval
    into :new.media_label_id from dual;

    if :NEW.assigned_by_agent_id is null then
        select agent_name.agent_id
        into :NEW.assigned_by_agent_id
        from agent_name
        where agent_name_type='login'
        and upper(agent_name.agent_name) = SYS_CONTEXT('USERENV','SESSION_USER');
    end if;
end;
/

CREATE OR REPLACE TRIGGER MEDIA_RELATIONS_SEQ
before insert  ON media_
relations for each row
begin
    select seq_media_relations.nextval
    into :new.media_relations_id from dual;

    if :NEW.created_by_agent_id is null then
        select agent_name.agent_id
        into :NEW.created_by_agent_id
        from agent_name
        where agent_name_type='login'
        and upper(agent_name.agent_name) = SYS_CONTEXT('USERENV','SESSION_USER');
    end if;
end;
/

CREATE OR REPLACE TRIGGER TRIG_PROJECT_SPONSOR_ID
before INSERT on project_sponsor
for each row
BEGIN
    if :NEW.project_sponsor_id is null then
        select project_sponsor_seq.nextval
        into :new.project_sponsor_id from dual;
    end if;
END;
/

CREATE OR REPLACE TRIGGER SPECIMEN_ANNOTATIONS_KEY
before insert  ON specimen_annotations
for each row
begin
    if :NEW.annotation_id is null then
        select specimen_annotations_seq.nextval
        into :new.annotation_id from dual;
    end if;

    if :NEW.annotate_date is null then
        :NEW.annotate_date := sysdate;
    end if;
end;
/

CREATE OR REPLACE TRIGGER MAKE_PART_COLL_OBJ_CONT
after insert ON specimen_part
FOR EACH ROW
declare
    label varchar2(255);
    institution_acronym varchar2(255);
BEGIN
    select
        collection.institution_acronym,
        collection.collection || ' ' || cataloged_item.cat_num || ' ' || :NEW.part_name
    INTO institution_acronym, label
    FROM collection, cataloged_item
    WHERE collection.collection_id = cataloged_item.collection_id
    AND cataloged_item.collection_object_id = :NEW.derived_from_cat_item;

    INSERT INTO container (
        CONTAINER_ID,
        PARENT_CONTAINER_ID,
        CONTAINER_TYPE,
        LABEL,
        locked_position,
        institution_acronym)
    VALUES (
        sq_container_id.nextval,
        0,
        'collection object',
        label,
        0,
        institution_acronym);

    INSERT INTO coll_obj_cont_hist (
        COLLECTION_OBJECT_ID,
        CONTAINER_ID,
        INSTALLED_DATE,
        CURRENT_CONTAINER_FG)
    VALUES (
        :NEW.collection_object_id,
        sq_container_id.currval,
        sysdate,
        1);
EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20000, 'trigger problems: ' || SQLERRM);
end;
/

CREATE OR REPLACE TRIGGER TRANS_AGENT_PRE
BEFORE UPDATE OR INSERT ON trans_agent
FOR EACH ROW
DECLARE
    numrows NUMBER;
BEGIN
    IF :new.trans_agent_id IS NULL THEN
        SELECT trans_agent_seq.NEXTVAL
        INTO :new.trans_agent_id FROM dual;
    END IF;

    SELECT COUNT(*) INTO numrows
    FROM cttrans_agent_role
    WHERE trans_agent_role = :new.trans_agent_role;

    IF (numrows = 0) THEN
        raise_application_error(
        -20001,
        'Invalid trans_agent_role');
    END IF;
END;
/
*/