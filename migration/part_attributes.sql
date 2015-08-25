CREATE TABLE specimen_part_attribute (
    part_attribute_id NUMBER NOT NULL,
    collection_object_id NUMBER NOT NULL,
    attribute_type VARCHAR2(30) NOT NULL,
    attribute_value VARCHAR2(255) NOT NULL,
    attribute_units varchar2(30),
    determined_date DATE,
    determined_by_agent_id NUMBER,
    attribute_remark varchar2(4000)
);


CREATE PUBLIC SYNONYM specimen_part_attribute FOR specimen_part_attribute;
GRANT SELECT ON specimen_part_attribute TO PUBLIC;
GRANT all ON specimen_part_attribute TO manage_specimens;

CREATE TABLE ctspecpart_attribute_type (
    attribute_type VARCHAR2(30) NOT NULL,
    description VARCHAR2(4000)
);

CREATE PUBLIC SYNONYM ctspecpart_attribute_type FOR ctspecpart_attribute_type;

GRANT ALL ON ctspecpart_attribute_type TO manage_codetables;
GRANT SELECT ON ctspecpart_attribute_type TO PUBLIC;


create TABLE ctspec_part_att_att (
    attribute_type varchar2(30) NOT NULL,
    VALUE_code_table VARCHAR2(38),
    unit_code_table varchar2(38)
);

CREATE PUBLIC SYNONYM ctspec_part_att_att FOR ctspec_part_att_att;

GRANT ALL ON ctspec_part_att_att TO manage_codetables;
GRANT SELECT ON ctspec_part_att_att TO PUBLIC;

CREATE UNIQUE INDEX iu_ctspec_part_att_att_all ON ctspec_part_att_att (attribute_type,VALUE_code_table,unit_code_table);
CREATE UNIQUE INDEX iu_ctspec_part_att_att ON ctspec_part_att_att (attribute_type);


             
alter table specimen_part_attribute add constraint PK_specimen_part_attribute PRIMARY KEY (part_attribute_id)
    using index TABLESPACE UAM_IDX_1;
    
alter table specimen_part_attribute add constraint FK_specpartattr_specpart FOREIGN KEY (collection_object_id)
REFERENCES specimen_part (collection_object_id);

alter table specimen_part_attribute add constraint FK_specpartattr_agent FOREIGN KEY (determined_by_agent_id)
REFERENCES agent (agent_id);

-- wtf??
alter table specimen_part_attribute add constraint FK_specpartattr_ctspattrtype FOREIGN KEY (attribute_type)
REFERENCES ctspecpart_attribute_type (attribute_type);

CREATE SEQUENCE sq_part_attribute_id;

CREATE OR REPLACE TRIGGER tr_specpartattribute_sq
    BEFORE INSERT ON specimen_part_attribute
    FOR EACH ROW
    BEGIN
        if :new.part_attribute_id is null then
        	select sq_part_attribute_id.nextval into :new.part_attribute_id from dual;
        end if;
    end;
/

-- ADD control FOR 
    /Admin/ctspec_part_att_att.cfm
    /form/partAtts.cfm
        
        
CREATE TABLE cttissue_volume_units (
    volume_units VARCHAR2(20) NOT NULL
);
CREATE PUBLIC SYNONYM cttissue_volume_units FOR cttissue_volume_units;
GRANT SELECT ON cttissue_volume_units TO PUBLIC;
GRANT ALL ON cttissue_volume_units TO manage_codetables;

CREATE TABLE ctpart_attribute_part (
    attribute_part VARCHAR2(20) NOT NULL
);
CREATE PUBLIC SYNONYM ctpart_attribute_part FOR ctpart_attribute_part;
GRANT SELECT ON ctpart_attribute_part TO PUBLIC;
GRANT ALL ON ctpart_attribute_part TO manage_codetables;
ALTER TABLE ctpart_attribute_part MODIFY attribute_part VARCHAR2(255);

    
    
-- AND CREATE a better display part
--- rebuild flat_procedures.sql
-- filtered_flat_view
update cf_spec_res_cols set DISP_ORDER=DISP_ORDER+1 where DISP_ORDER > 45;
insert into cf_spec_res_cols
(COLUMN_NAME,
SQL_ELEMENT,
CATEGORY,
CF_SPEC_RES_COLS_ID,
DISP_ORDER
) values (
'partdetail',
'flatTableName.partdetail',
'specimen',
somerandomsequence.nextval,
46);
UPDATE flat SET partdetail=concatPartsDetail(collection_object_id) WHERE partdetail IS NULL AND ROWNUM < 1000;

-- and trans_containers
CREATE TABLE trans_container (
    trans_container_id NUMBER NOT NULL,
    TRANSACTION_id NUMBER NOT NULL,
    container_id NUMBER NOT NULL
);
CREATE SEQUENCE sq_trans_container_id;

CREATE OR REPLACE TRIGGER tr_trans_container_sq
    BEFORE INSERT ON trans_container
    FOR EACH ROW
    BEGIN
        if :new.trans_container_id is null then
        	select sq_trans_container_id.nextval into :new.trans_container_id from dual;
        end if;
    end;
/


alter table trans_container add constraint PK_trans_container PRIMARY KEY (trans_container_id)
    using index TABLESPACE UAM_IDX_1;
    
alter table trans_container add constraint FK_trans_container_trans FOREIGN KEY (TRANSACTION_id)
REFERENCES trans (TRANSACTION_id);

alter table trans_container add constraint FK_trans_container_container FOREIGN KEY (container_id)
REFERENCES container (container_id);

CREATE PUBLIC SYNONYM trans_container FOR trans_container;
GRANT ALL ON trans_container TO manage_transactions;

CREATE UNIQUE INDEX iu_trans_container ON trans_container (transaction_id,container_id) TABLESPACE uam_idx_1;


-- called by tr_addr_bu (trigger on ADDR table)
-- inserts new record into ADDR table when there is a change in fields:
-- street_addr1, street_addr2, city, state, zip, country_cde, mail_stop,
-- agent_id, addr_type, job_title, institution, department

CREATE OR REPLACE PROCEDURE init_flatpartdetail 
AS
BEGIN
	UPDATE flat SET partdetail=concatPartsDetail(collection_object_id) WHERE partdetail IS NULL AND ROWNUM < 10000;
END;
/

exec DBMS_SCHEDULER.DROP_JOB('JOB_INIT_FLATPARTDETAIL');


BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'job_init_flatpartdetail',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'init_flatpartdetail',
		start_date		=> to_timestamp_tz('30-APR-2010 00:00:00', 'DD-MON-YYYY HH24:MI:SS'),
		repeat_interval	=> 'freq=minutely; bysecond=0,30',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'disable/drop when falt.partdetail is populated');
END;
/ 



select JOB_NAME, START_DATE, REPEAT_INTERVAL, LAST_START_DATE, LAST_RUN_DURATION, NEXT_RUN_DATE, RUN_COUNT 
from all_scheduler_jobs where lower(job_name) like '%job_init_flatpartdetail%';
