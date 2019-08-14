select table_name,column_name from user_tab_cols where column_name='WHEN';

drop table TEMP_DISPNAMELOG;
drop table LOG_CTTAXONOMIC_AUTHORITY;
drop table LOG_CTPUBLICATION_ATTRIBUTE;
drop table LOG_CTSECTION_TYPE;
drop table LOG_CTBIOL_RELATIONS;
drop table LOG_CTELECTRONIC_ADDR_TYPE;
drop table LOG_CTFLUID_CONCENTRATION;
drop table LOG_CTFLUID_TYPE;
drop table LOG_CTGEOG_SOURCE_AUTHORITY;
drop table LOG_CTGEOREFMETHOD;


name from user_tab_cols where column_name='WHEN';

SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTTAXONOMIC_AUTHORITY';
SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name like '%TAXONOMIC_AUTHORITY';





-- LOG_CTGEOLOGY_ATTRIBUTE is a view, not logging needed

WHEN


WHEN


15 rows selected.






SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner)
FROM   all_triggers
WHERE table_name in (select table_name from user_tab_cols where column_name='WHEN');

-- table spec_scan is from the long done UAM:ES paleo imaging project
-- archive it for posterity: https://github.com/ArctosDB/arctos-archive/issues/1
drop trigger TG_SPEC_SCAN_KEY;
drop table spec_scan;

-- archive the jobs data
create table temp_es_tacc_jobs as select * from cf_crontab where PATH like '%es_tacc%';
-- in issue
delete from cf_crontab where  PATH like '%es_tacc%';

-- old trigger

alter table spec_scan
  CREATE OR REPLACE TRIGGER "UAM"."TG_SPEC_SCAN_KEY"
		before insert ON spec_scan
		 for each row
		    begin
			select
				sq_spec_scan_id.nextval,
				sys_context('USERENV', 'SESSION_USER'),
				sysdate
			into
				:new.id,
				:new.who,
				:new.when
			from dual;
		    end;



/
ALTER TRIGGER "UAM"."TG_SPEC_SCAN_KEY" ENABLE;
-- /old trigger

create table temp_es_spec_jobs as select * from cf_crontab where PATH like '%es_spec%';
-- to archive
delete from cf_crontab where PATH like '%es_spec%';
-- archive loc_card_scan
drop trigger TG_LOC_CARD_SCAN_KEY;
drop table loc_card_scan
-- old trigger
  CREATE OR REPLACE TRIGGER "UAM"."TG_LOC_CARD_SCAN_KEY"
		before insert ON loc_card_scan
		 for each row
		    begin
			select
				sq_loc_card_scan_id.nextval,
				sys_context('USERENV', 'SESSION_USER'),
				sysdate
			into
				:new.loc_id,
				:new.who,
				:new.when
			from dual;
		    end;



/
ALTER TRIGGER "UAM"."TG_LOC_CARD_SCAN_KEY" ENABLE;
-- /old trigger


-- archive accn_scan
drop trigger TG_ACCN_SCAN_KEY;
drop table accn_scan

  CREATE OR REPLACE TRIGGER "UAM"."TG_ACCN_SCAN_KEY"
		before insert ON accn_scan
		 for each row
		    begin
			select
				sq_accn_scan_id.nextval,
				sys_context('USERENV', 'SESSION_USER'),
				sysdate
			into
				:new.id,
				:new.who,
				:new.when
			from dual;
		    end;



/
ALTER TRIGGER "UAM"."TG_ACCN_SCAN_KEY" ENABLE;




-- now find things writing TO log... table


SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

declare
	mt varchar2(40);
	s varchar2(4000);
begin
	for r in (select distinct table_name from user_tab_cols where column_name='WHEN') loop
		mt:=replace(r.table_name,'LOG_');
		--dbms_output.put_line(r.table_name);
		--dbms_output.put_line(mt);
		s:='SELECT DBMS_METADATA.get_ddl (''TRIGGER'', trigger_name, owner) FROM  all_triggers WHERE table_name=''' || mt || ''';';
		dbms_output.put_line(s);
	end loop;
end ;
/

 
 
 

alter table LOG_GEOLOGY_ATTRIBUTE_HIY rename column when to change_date;
drop trigger UAM.TR_LOG_GEOLOGY_ATTRIBUTE_HIY;

update geology_attribute_hierarchy set DESCRIPTION='pending' where DESCRIPTION is null;
alter table geology_attribute_hierarchy modify description not null;


CREATE OR REPLACE TRIGGER TR_log_GEOLOGY_ATTRIBUTE_HIY 
	AFTER INSERT or update or delete ON GEOLOGY_ATTRIBUTE_HIERARCHY
	FOR EACH ROW 
BEGIN 
	insert into log_GEOLOGY_ATTRIBUTE_HIY ( 
		username, 
		change_date,
		n_parent_id,
		n_attribute,
		n_ATTRIBUTE_VALUE,
		n_USABLE_VALUE_FG,
		n_DESCRIPTION,	
		o_parent_id,
		o_attribute,
		o_ATTRIBUTE_VALUE,
		o_USABLE_VALUE_FG,
		o_DESCRIPTION
			) values (
		SYS_CONTEXT('USERENV','SESSION_USER'),
		sysdate,
		:NEW.parent_id,
		:NEW.attribute,
		:NEW.ATTRIBUTE_VALUE,
		:NEW.USABLE_VALUE_FG,
		:NEW.DESCRIPTION,	
		:OLD.parent_id,
		:OLD.attribute,
		:OLD.ATTRIBUTE_VALUE,
		:OLD.USABLE_VALUE_FG,
		:OLD.DESCRIPTION
	);
END;
/


desc LOG_GEOLOGY_ATTRIBUTE_HIY
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 USERNAME								    VARCHAR2(60)
 WHEN									    DATE
 N_PARENT_ID								    NUMBER
 N_ATTRIBUTE								    VARCHAR2(255)
 N_ATTRIBUTE_VALUE							    VARCHAR2(255)
 N_USABLE_VALUE_FG							    NUMBER
 N_DESCRIPTION								    VARCHAR2(4000)
 O_PARENT_ID								    NUMBER
 O_ATTRIBUTE								    VARCHAR2(255)
 O_ATTRIBUTE_VALUE							    VARCHAR2(255)
 O_USABLE_VALUE_FG							    NUMBER
 O_DESCRIPTION								    VARCHAR2(4000)

UAM@ARCTOS> desc geology_attribute_hierarchy_id
ERROR:
ORA-04043: object geology_attribute_hierarchy_id does not exist


UAM@ARCTOS> desc geology_attribute_hierarchy
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 GEOLOGY_ATTRIBUTE_HIERARCHY_ID 				   NOT NULL NUMBER
 PARENT_ID								    NUMBER
 ATTRIBUTE							   NOT NULL VARCHAR2(255)
 ATTRIBUTE_VALUE						   NOT NULL VARCHAR2(255)
 USABLE_VALUE_FG						   NOT NULL NUMBER
 DESCRIPTION								    VARCHAR2(4000)

 
 
 
alter table LOG_CTSPECPART_ATTRIBUTE_TYPE rename column when to change_date;
update CTSPECPART_ATTRIBUTE_TYPE set DESCRIPTION='pending' where DESCRIPTION is null;
alter table CTSPECPART_ATTRIBUTE_TYPE modify description not null;


CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTSPECPART_ATT_TYP" AFTER INSERT or update or delete ON CTSPECPART_ATTRIBUTE_TYPE
FOR EACH ROW
BEGIN
insert into LOG_CTSPECPART_ATTRIBUTE_TYPE (
username,
change_date,
N_DESCRIPTION,
N_ATTRIBUTE_TYPE,
O_DESCRIPTION,
O_ATTRIBUTE_TYPE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.ATTRIBUTE_TYPE,
:OLD.DESCRIPTION,
:OLD.ATTRIBUTE_TYPE
);
END;
/






alter table LOG_CTSPECIMEN_PART_LIST_ORDER rename column when to change_date;

CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTSPEC_PRT_LST_ORDR" AFTER INSERT or update or delete ON CTSPECIMEN_PART_LIST_ORDER
FOR EACH ROW
BEGIN
insert into LOG_CTSPECIMEN_PART_LIST_ORDER (
username,
change_date,
N_PARTNAME,
N_LIST_ORDER,
O_PARTNAME,
O_LIST_ORDER
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.PARTNAME,
:NEW.LIST_ORDER,
:OLD.PARTNAME,
:OLD.LIST_ORDER
);
END;
/





SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTMEDIA_TYPE';
alter table log_CTMEDIA_TYPE rename column when to change_date;

CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTMEDIA_TYPE" AFTER INSERT or update or delete ON CTMEDIA_TYPE
FOR EACH ROW
BEGIN
insert into log_CTMEDIA_TYPE (
username,
change_date,
n_MEDIA_TYPE,
n_DESCRIPTION,
o_MEDIA_TYPE,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.MEDIA_TYPE,
:NEW.DESCRIPTION,
:OLD.MEDIA_TYPE,
:OLD.DESCRIPTION
);
END;
/


SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTATTRIBUTE_TYPE';
alter table log_CTATTRIBUTE_TYPE rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTATTRIBUTE_TYPE" AFTER INSERT or update or delete ON CTATTRIBUTE_TYPE
FOR EACH ROW
BEGIN
insert into log_CTATTRIBUTE_TYPE (
username,
change_date,
n_DESCRIPTION,
n_COLLECTION_CDE,
n_ATTRIBUTE_TYPE,
o_DESCRIPTION,
o_COLLECTION_CDE,
o_ATTRIBUTE_TYPE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.COLLECTION_CDE,
:NEW.ATTRIBUTE_TYPE,
:OLD.DESCRIPTION,
:OLD.COLLECTION_CDE,
:OLD.ATTRIBUTE_TYPE
);
END;
/

SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTISLAND_GROUP';
alter table log_CTISLAND_GROUP rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTISLAND_GROUP" AFTER INSERT or update or delete ON CTISLAND_GROUP
FOR EACH ROW
BEGIN
insert into log_CTISLAND_GROUP (
username,
change_date,
n_ISLAND_GROUP,
n_DESCRIPTION,
o_ISLAND_GROUP,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.ISLAND_GROUP,
:NEW.DESCRIPTION,
:OLD.ISLAND_GROUP,
:OLD.DESCRIPTION
);
END;
/

SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTNATURE_OF_ID';
alter table log_CTNATURE_OF_ID rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTNATURE_OF_ID" AFTER INSERT or update or delete ON CTNATURE_OF_ID
FOR EACH ROW
BEGIN
insert into log_CTNATURE_OF_ID (
username,
change_date,
n_NATURE_OF_ID,
n_DESCRIPTION,
o_NATURE_OF_ID,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.NATURE_OF_ID,
:NEW.DESCRIPTION,
:OLD.NATURE_OF_ID,
:OLD.DESCRIPTION
);
END;
/


SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTLENGTH_UNITS';
alter table log_CTLENGTH_UNITS rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTLENGTH_UNITS" AFTER INSERT or update or delete ON CTLENGTH_UNITS
FOR EACH ROW
BEGIN
insert into log_CTLENGTH_UNITS (
username,
change_date,
n_DESCRIPTION,
n_LENGTH_UNITS,
o_DESCRIPTION,
o_LENGTH_UNITS
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.LENGTH_UNITS,
:OLD.DESCRIPTION,
:OLD.LENGTH_UNITS
);
END;
/

SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTTISSUE_VOLUME_UNITS';

alter table log_CTTISSUE_VOLUME_UNITS rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTTISSUE_VOLUME_UNITS" AFTER INSERT or update or delete ON CTTISSUE_VOLUME_UNITS
FOR EACH ROW
BEGIN
insert into log_CTTISSUE_VOLUME_UNITS (
username,
change_date,
n_VOLUME_UNITS,
o_VOLUME_UNITS
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.VOLUME_UNITS,
:OLD.VOLUME_UNITS
);
END;
/


SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTMEDIA_LICENSE';

alter table log_CTMEDIA_LICENSE rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTMEDIA_LICENSE" AFTER INSERT or update or delete ON CTMEDIA_LICENSE
FOR EACH ROW
BEGIN
insert into log_CTMEDIA_LICENSE (
username,
change_date,
n_URI,
n_MEDIA_LICENSE_ID,
n_DISPLAY,
n_DESCRIPTION,
o_URI,
o_MEDIA_LICENSE_ID,
o_DISPLAY,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.URI,
:NEW.MEDIA_LICENSE_ID,
:NEW.DISPLAY,
:NEW.DESCRIPTION,
:OLD.URI,
:OLD.MEDIA_LICENSE_ID,
:OLD.DISPLAY,
:OLD.DESCRIPTION
);
END;
/


SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTORIG_ELEV_UNITS';

alter table log_CTORIG_ELEV_UNITS rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTORIG_ELEV_UNITS" AFTER INSERT or update or delete ON CTORIG_ELEV_UNITS
FOR EACH ROW
BEGIN
insert into log_CTORIG_ELEV_UNITS (
username,
change_date,
n_ORIG_ELEV_UNITS,
n_DESCRIPTION,
o_ORIG_ELEV_UNITS,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.ORIG_ELEV_UNITS,
:NEW.DESCRIPTION,
:OLD.ORIG_ELEV_UNITS,
:OLD.DESCRIPTION
);
END;
/


SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTSHIPPED_CARRIER_METHOD';
--- no exist!!
alter table LOG_CTSHIPPED_CARRIER_METHOD rename column when to change_date;
alter table LOG_CTSHIPPED_CARRIER_METHOD add N_DESCRIPTION varchar2(4000);
alter table LOG_CTSHIPPED_CARRIER_METHOD add O_DESCRIPTION varchar2(4000);
update CTSHIPPED_CARRIER_METHOD set description='pending' where description is null;
alter table CTSHIPPED_CARRIER_METHOD modify DESCRIPTION not null;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTSHPD_CARER_METH"
AFTER INSERT or update or delete ON CTSHIPPED_CARRIER_METHOD
FOR EACH ROW
BEGIN
insert into LOG_CTSHIPPED_CARRIER_METHOD (
username,
change_date,
N_SHIPPED_CARRIER_METHOD,
N_DESCRIPTION,
O_SHIPPED_CARRIER_METHOD,
O_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.SHIPPED_CARRIER_METHOD,
:NEW.DESCRIPTION,
:OLD.SHIPPED_CARRIER_METHOD,
:OLD.DESCRIPTION
);
END;
/




SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTCONDUCTIVITY_UNITS';

alter table log_ctconductivity_units rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTCONDUCTIVITY_UNITS"
AFTER INSERT or update or delete ON ctconductivity_units
FOR EACH ROW
BEGIN
insert into log_ctconductivity_units (
username,
change_date,
n_conductivity_units,
n_DESCRIPTION,
o_conductivity_units,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.conductivity_units,
:NEW.DESCRIPTION,
:OLD.conductivity_units,
:OLD.DESCRIPTION
);
END;
/


SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTSPECIMEN_PART_NAME';

alter table log_CTSPECIMEN_PART_NAME rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTSPECIMEN_PART_NAME" AFTER INSERT or update or delete ON CTSPECIMEN_PART_NAME
FOR EACH ROW
BEGIN
insert into log_CTSPECIMEN_PART_NAME (
username,
change_date,
n_PART_NAME,
n_IS_TISSUE,
n_DESCRIPTION,
n_CTSPNID,
n_COLLECTION_CDE,
o_PART_NAME,
o_IS_TISSUE,
o_DESCRIPTION,
o_CTSPNID,
o_COLLECTION_CDE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.PART_NAME,
:NEW.IS_TISSUE,
:NEW.DESCRIPTION,
:NEW.CTSPNID,
:NEW.COLLECTION_CDE,
:OLD.PART_NAME,
:OLD.IS_TISSUE,
:OLD.DESCRIPTION,
:OLD.CTSPNID,
:OLD.COLLECTION_CDE
);
END;
/


SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTTRANSACTION_TYPE';

alter table log_CTTRANSACTION_TYPE rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTTRANSACTION_TYPE" AFTER INSERT or update or delete ON CTTRANSACTION_TYPE
FOR EACH ROW
BEGIN
insert into log_CTTRANSACTION_TYPE (
username,
change_date,
n_TRANSACTION_TYPE,
o_TRANSACTION_TYPE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.TRANSACTION_TYPE,
:OLD.TRANSACTION_TYPE
);
END;
/

SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTLAT_LONG_ERROR_UNITS';

alter table log_CTLAT_LONG_ERROR_UNITS rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTLAT_LONG_ERROR_UNITS" AFTER INSERT or update or delete ON CTLAT_LONG_ERROR_UNITS
FOR EACH ROW
BEGIN
insert into log_CTLAT_LONG_ERROR_UNITS (
username,
change_date,
n_LAT_LONG_ERROR_UNITS,
n_DESCRIPTION,
o_LAT_LONG_ERROR_UNITS,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.LAT_LONG_ERROR_UNITS,
:NEW.DESCRIPTION,
:OLD.LAT_LONG_ERROR_UNITS,
:OLD.DESCRIPTION
);
END;
/


SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTCOLLECTOR_ROLE';

alter table log_CTCOLLECTOR_ROLE rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTCOLLECTOR_ROLE" AFTER INSERT or update or delete ON CTCOLLECTOR_ROLE
FOR EACH ROW
BEGIN
insert into log_CTCOLLECTOR_ROLE (
username,
change_date,
n_DESCRIPTION,
n_COLLECTOR_ROLE,
o_DESCRIPTION,
o_COLLECTOR_ROLE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.COLLECTOR_ROLE,
:OLD.DESCRIPTION,
:OLD.COLLECTOR_ROLE
);
END;
/

SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTCOLL_EVENT_ATTR_TYPE';

alter table log_ctcoll_event_attr_type rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTCOLL_EVENT_ATTR_TYPE" AFTER INSERT or update or delete ON ctcoll_event_attr_type
FOR EACH ROW
BEGIN
insert into log_ctcoll_event_attr_type (
username,
change_date,
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


SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTCONTAINER_ENV_PARAMETER';

alter table log_ctcontainer_env_parameter rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTCONTR_ENV_PARAMETER"
AFTER INSERT or update or delete ON ctcontainer_env_parameter
FOR EACH ROW
BEGIN
insert into log_ctcontainer_env_parameter (
username,
change_date,
n_parameter_type,
n_DESCRIPTION,
o_parameter_type,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.parameter_type,
:NEW.DESCRIPTION,
:OLD.parameter_type,
:OLD.DESCRIPTION
);
END;
/



SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTPERMIT_REGULATION';

alter table log_CTPERMIT_REGULATION rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTPERMIT_REGULATION" AFTER INSERT or update or delete ON CTPERMIT_REGULATION
FOR EACH ROW
BEGIN
insert into log_CTPERMIT_REGULATION (
username,
change_date,
n_DESCRIPTION,
n_PERMIT_REGULATION,
o_DESCRIPTION,
o_PERMIT_REGULATION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.PERMIT_REGULATION,
:OLD.DESCRIPTION,
:OLD.PERMIT_REGULATION
);
END;
/


SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTTAXON_RELATION';

alter table log_CTTAXON_RELATION rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTTAXON_RELATION" AFTER INSERT or update or delete ON CTTAXON_RELATION
FOR EACH ROW
BEGIN
insert into log_CTTAXON_RELATION (
username,
change_date,
n_TAXON_RELATIONSHIP,
n_DESCRIPTION,
o_TAXON_RELATIONSHIP,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.TAXON_RELATIONSHIP,
:NEW.DESCRIPTION,
:OLD.TAXON_RELATIONSHIP,
:OLD.DESCRIPTION
);
END;
/


SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTMONETARY_UNITS';

alter table log_CTMONETARY_UNITS rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTMONETARY_UNITS" AFTER INSERT or update or delete ON CTMONETARY_UNITS
FOR EACH ROW
BEGIN
insert into log_CTMONETARY_UNITS (
username,
change_date,
n_MONETARY_UNITS,
o_MONETARY_UNITS
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.MONETARY_UNITS,
:OLD.MONETARY_UNITS
);
END;
/


SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTMIME_TYPE';

alter table log_CTMIME_TYPE rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTMIME_TYPE" AFTER INSERT or update or delete ON CTMIME_TYPE
FOR EACH ROW
BEGIN
insert into log_CTMIME_TYPE (
username,
change_date,
n_MIME_TYPE,
n_DESCRIPTION,
o_MIME_TYPE,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.MIME_TYPE,
:NEW.DESCRIPTION,
:OLD.MIME_TYPE,
:OLD.DESCRIPTION
);
END;
/


SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTCOLL_OBJ_DISP';

alter table log_CTCOLL_OBJ_DISP rename column when to change_date;



  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTCOLL_OBJ_DISP" AFTER INSERT or update or delete ON CTCOLL_OBJ_DISP
FOR EACH ROW
BEGIN
insert into log_CTCOLL_OBJ_DISP (
username,
change_date,
n_DESCRIPTION,
n_COLL_OBJ_DISPOSITION,
o_DESCRIPTION,
o_COLL_OBJ_DISPOSITION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.COLL_OBJ_DISPOSITION,
:OLD.DESCRIPTION,
:OLD.COLL_OBJ_DISPOSITION
);
END;
/

SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTSHIPMENT_TYPE';


alter table log_CTSHIPMENT_TYPE rename column when to change_date;



  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTSHIPMENT_TYPE" AFTER INSERT or update or delete ON CTSHIPMENT_TYPE
FOR EACH ROW
BEGIN
insert into log_CTSHIPMENT_TYPE (
username,
change_date,
n_SHIPMENT_TYPE,
n_DESCRIPTION,
o_SHIPMENT_TYPE,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.SHIPMENT_TYPE,
:NEW.DESCRIPTION,
:OLD.SHIPMENT_TYPE,
:OLD.DESCRIPTION
);
END;
/


SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTSUFFIX';

alter table log_CTSUFFIX rename column when to change_date;



  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTSUFFIX" AFTER INSERT or update or delete ON CTSUFFIX
FOR EACH ROW
BEGIN
insert into log_CTSUFFIX (
username,
change_date,
n_SUFFIX,
n_DESCRIPTION,
o_SUFFIX,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.SUFFIX,
:NEW.DESCRIPTION,
:OLD.SUFFIX,
:OLD.DESCRIPTION
);
END;
/


SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTTAXONOMY_SOURCE';

alter table log_CTTAXONOMY_SOURCE rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTTAXONOMY_SOURCE" AFTER INSERT or update or delete ON CTTAXONOMY_SOURCE
FOR EACH ROW
BEGIN
insert into log_CTTAXONOMY_SOURCE (
username,
change_date,
n_DESCRIPTION,
n_SOURCE,
o_DESCRIPTION,
o_SOURCE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.SOURCE,
:OLD.DESCRIPTION,
:OLD.SOURCE
);
END;
/



SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTABUNDANCE';

alter table log_CTABUNDANCE rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTABUNDANCE" AFTER INSERT or update
 or delete ON CTABUNDANCE
FOR EACH ROW
BEGIN
insert into log_CTABUNDANCE (
username,
change_date,
n_DESCRIPTION,
n_COLLECTION_CDE,
n_ABUNDANCE,
o_DESCRIPTION,
o_COLLECTION_CDE,
o_ABUNDANCE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.COLLECTION_CDE,
:NEW.ABUNDANCE,
:OLD.DESCRIPTION,
:OLD.COLLECTION_CDE,
:OLD.ABUNDANCE
);
END;
/



SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTAGENT_RELATIONSHIP';


alter table log_CTAGENT_RELATIONSHIP rename column when to change_date;



  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTAGENT_RELATIONSHIP" AFTER INSERT or update or delete ON CTAGENT_RELATIONSHIP
FOR EACH ROW
BEGIN
insert into log_CTAGENT_RELATIONSHIP (
username,
change_date,
n_DESCRIPTION,
n_AGENT_RELATIONSHIP,
o_DESCRIPTION,
o_AGENT_RELATIONSHIP
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.AGENT_RELATIONSHIP,
:OLD.DESCRIPTION,
:OLD.AGENT_RELATIONSHIP
);
END;
/


SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTTISSUE_QUALITY';


alter table log_cttissue_quality rename column when to change_date;



  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTTISSUE_QUALITY" AFTER INSERT or update or delete ON cttissue_quality
FOR EACH ROW
BEGIN
insert into log_cttissue_quality (
username,
change_date,
n_DESCRIPTION,
n_tissue_quality,
o_DESCRIPTION,
o_tissue_quality
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.tissue_quality,
:OLD.DESCRIPTION,
:OLD.tissue_quality
);
END;
/



SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTID_REFERENCES';


alter table log_CTID_REFERENCES rename column when to change_date;



  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTID_REFERENCES" AFTER INSERT or update or delete ON CTID_REFERENCES
FOR EACH ROW
BEGIN
insert into log_CTID_REFERENCES (
username,
change_date,
n_DESCRIPTION,
n_ID_REFERENCES,
o_DESCRIPTION,
o_ID_REFERENCES
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.ID_REFERENCES,
:OLD.DESCRIPTION,
:OLD.ID_REFERENCES
);
END;
/


SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTTAXA_FORMULA';


alter table log_CTTAXA_FORMULA rename column when to change_date;



  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTTAXA_FORMULA" AFTER INSERT or update or delete ON CTTAXA_FORMULA
FOR EACH ROW
BEGIN
insert into log_CTTAXA_FORMULA (
username,
change_date,
n_TAXA_FORMULA,
n_DESCRIPTION,
o_TAXA_FORMULA,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.TAXA_FORMULA,
:NEW.DESCRIPTION,
:OLD.TAXA_FORMULA,
:OLD.DESCRIPTION
);
END;
/



SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTAGENT_STATUS';

alter table log_ctagent_status rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTAGENT_STATUS" AFTER INSERT or update or delete ON ctagent_status
FOR EACH ROW
BEGIN
insert into log_ctagent_status (
username,
change_date,
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



SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTKILL_METHOD';

alter table log_CTKILL_METHOD rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTKILL_METHOD" AFTER INSERT or update or delete ON CTKILL_METHOD
FOR EACH ROW
BEGIN
insert into log_CTKILL_METHOD (
username,
change_date,
n_KILL_METHOD,
n_DESCRIPTION,
n_COLLECTION_CDE,
o_KILL_METHOD,
o_DESCRIPTION,
o_COLLECTION_CDE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.KILL_METHOD,
:NEW.DESCRIPTION,
:NEW.COLLECTION_CDE,
:OLD.KILL_METHOD,
:OLD.DESCRIPTION,
:OLD.COLLECTION_CDE
);
END;
/



SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTAGENT_NAME_TYPE';


alter table log_CTAGENT_NAME_TYPE rename column when to change_date;



  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTAGENT_NAME_TYPE" AFTER INSERT or update or delete ON CTAGENT_NAME_TYPE
FOR EACH ROW
BEGIN
insert into log_CTAGENT_NAME_TYPE (
username,
change_date,
n_DESCRIPTION,
n_AGENT_NAME_TYPE,
o_DESCRIPTION,
o_AGENT_NAME_TYPE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.AGENT_NAME_TYPE,
:OLD.DESCRIPTION,
:OLD.AGENT_NAME_TYPE
);
END;
/


alter table log_CTSEX_CDE rename column when to change_date;




  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTSEX_CDE" AFTER INSERT or update or delete ON CTSEX_CDE
FOR EACH ROW
BEGIN
insert into log_CTSEX_CDE (
username,
change_date,
n_SEX_CDE,
n_DESCRIPTION,
n_COLLECTION_CDE,
o_SEX_CDE,
o_DESCRIPTION,
o_COLLECTION_CDE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.SEX_CDE,
:NEW.DESCRIPTION,
:NEW.COLLECTION_CDE,
:OLD.SEX_CDE,
:OLD.DESCRIPTION,
:OLD.COLLECTION_CDE
);
END;
/


alter table log_CTDATUM rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTDATUM" AFTER INSERT or update or delete ON CTDATUM
FOR EACH ROW
BEGIN
insert into log_CTDATUM (
username,
change_date,
n_DATUM,
o_DATUM
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DATUM,
:OLD.DATUM
);
END;
/


alter table log_CTLOAN_STATUS rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTLOAN_STATUS" AFTER INSERT or update or delete ON CTLOAN_STATUS
FOR EACH ROW
BEGIN
insert into log_CTLOAN_STATUS (
username,
change_date,
n_LOAN_STATUS,
n_DESCRIPTION,
o_LOAN_STATUS,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.LOAN_STATUS,
:NEW.DESCRIPTION,
:OLD.LOAN_STATUS,
:OLD.DESCRIPTION
);
END;
/

alter table log_CTNUMERIC_AGE_UNITS rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTNUMERIC_AGE_UNITS" AFTER INSERT or update or delete ON CTNUMERIC_AGE_UNITS
FOR EACH ROW
BEGIN
insert into log_CTNUMERIC_AGE_UNITS (
username,
change_date,
n_NUMERIC_AGE_UNITS,
o_NUMERIC_AGE_UNITS
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.NUMERIC_AGE_UNITS,
:OLD.NUMERIC_AGE_UNITS
);
END;
/


alter table log_CTCOLL_OTHER_ID_TYPE rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTCOLL_OTHER_ID_TYPE" AFTER INSERT or update or delete ON CTCOLL_OTHER_ID_TYPE
FOR EACH ROW
BEGIN
insert into log_CTCOLL_OTHER_ID_TYPE (
username,
change_date,
n_OTHER_ID_TYPE,
n_DESCRIPTION,
n_BASE_URL,
o_OTHER_ID_TYPE,
o_DESCRIPTION,
o_BASE_URL
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.OTHER_ID_TYPE,
:NEW.DESCRIPTION,
:NEW.BASE_URL,
:OLD.OTHER_ID_TYPE,
:OLD.DESCRIPTION,
:OLD.BASE_URL
);
END;
/


alter table log_CTAGE_CLASS rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTAGE_CLASS" AFTER INSERT or update or delete ON CTAGE_CLASS
FOR EACH ROW
BEGIN
insert into log_CTAGE_CLASS (
username,
change_date,
n_DESCRIPTION,
n_COLLECTION_CDE,
n_AGE_CLASS,
o_DESCRIPTION,
o_COLLECTION_CDE,
o_AGE_CLASS
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.COLLECTION_CDE,
:NEW.AGE_CLASS,
:OLD.DESCRIPTION,
:OLD.COLLECTION_CDE,
:OLD.AGE_CLASS
);
END;
/


alter table log_CTLOAN_TYPE rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTLOAN_TYPE" AFTER INSERT or update or delete ON CTLOAN_TYPE
FOR EACH ROW
BEGIN
insert into log_CTLOAN_TYPE (
username,
change_date,
n_LOAN_TYPE,
n_DESCRIPTION,
o_LOAN_TYPE,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.LOAN_TYPE,
:NEW.DESCRIPTION,
:OLD.LOAN_TYPE,
:OLD.DESCRIPTION
);
END;
/


alter table log_CTVERIFICATIONSTATUS rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTVERIFICATIONSTATUS" AFTER INSERT or update or delete ON CTVERIFICATIONSTATUS
FOR EACH ROW
BEGIN
insert into log_CTVERIFICATIONSTATUS (
username,
change_date,
n_VERIFICATIONSTATUS,
n_DESCRIPTION,
o_VERIFICATIONSTATUS,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.VERIFICATIONSTATUS,
:NEW.DESCRIPTION,
:OLD.VERIFICATIONSTATUS,
:OLD.DESCRIPTION
);
END;
/

alter table log_CTDOWNLOAD_PURPOSE rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTDOWNLOAD_PURPOSE" AFTER INSERT or update or delete ON CTDOWNLOAD_PURPOSE
FOR EACH ROW
BEGIN
insert into log_CTDOWNLOAD_PURPOSE (
username,
change_date,
n_DOWNLOAD_PURPOSE,
o_DOWNLOAD_PURPOSE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DOWNLOAD_PURPOSE,
:OLD.DOWNLOAD_PURPOSE
);
END;
/


alter table log_CTPUBLICATION_TYPE rename column when to change_date;

CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTPUBLICATION_TYPE" AFTER INSERT or update or delete ON CTPUBLICATION_TYPE
FOR EACH ROW
BEGIN
insert into log_CTPUBLICATION_TYPE (
username,
change_date,
n_PUBLICATION_TYPE,
n_DESCRIPTION,
o_PUBLICATION_TYPE,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.PUBLICATION_TYPE,
:NEW.DESCRIPTION,
:OLD.PUBLICATION_TYPE,
:OLD.DESCRIPTION
);
END;
/


alter table log_ctpart_preservation rename column when to change_date;



  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_PART_PRESERVATION" AFTER INSERT or update or delete ON ctpart_preservation
FOR EACH ROW
BEGIN
insert into log_ctpart_preservation (
username,
change_date,
n_DESCRIPTION,
n_part_preservation,
o_DESCRIPTION,
o_part_preservation
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.part_preservation,
:OLD.DESCRIPTION,
:OLD.part_preservation
);
END;
/


alter table log_CTACCN_TYPE rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTACCN_TYPE" AFTER INSERT or update or delete ON CTACCN_TYPE
FOR EACH ROW
BEGIN
insert into log_CTACCN_TYPE (
username,
change_date,
n_DESCRIPTION,
n_ACCN_TYPE,
o_DESCRIPTION,
o_ACCN_TYPE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.ACCN_TYPE,
:OLD.DESCRIPTION,
:OLD.ACCN_TYPE
);
END;
/


alter table log_CTINFRASPECIFIC_RANK rename column when to change_date;



  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTINFRASPECIFIC_RANK" AFTER INSERT or update or delete ON CTINFRASPECIFIC_RANK
FOR EACH ROW
BEGIN
insert into log_CTINFRASPECIFIC_RANK (
username,
change_date,
n_INFRASPECIFIC_RANK,
n_DESCRIPTION,
o_INFRASPECIFIC_RANK,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.INFRASPECIFIC_RANK,
:NEW.DESCRIPTION,
:OLD.INFRASPECIFIC_RANK,
:OLD.DESCRIPTION
);
END;
/

alter table log_CTMEDIA_LABEL rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTMEDIA_LABEL" AFTER INSERT or update or delete ON CTMEDIA_LABEL
FOR EACH ROW
BEGIN
insert into log_CTMEDIA_LABEL (
username,
change_date,
n_MEDIA_LABEL,
n_DESCRIPTION,
o_MEDIA_LABEL,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.MEDIA_LABEL,
:NEW.DESCRIPTION,
:OLD.MEDIA_LABEL,
:OLD.DESCRIPTION
);
END;
/


alter table log_CTADDRESS_TYPE rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTADDRESS_TYPE" AFTER INSERT or update or delete ON CTADDRESS_TYPE
FOR EACH ROW
BEGIN
insert into log_CTADDRESS_TYPE (
username,
change_date,
n_ADDRESS_TYPE,
n_DESCRIPTION,
o_ADDRESS_TYPE,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.ADDRESS_TYPE,
:NEW.DESCRIPTION,
:OLD.ADDRESS_TYPE,
:OLD.DESCRIPTION
);
END;
/

alter table log_CTCATALOGED_ITEM_TYPE rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTCATALOGED_ITEM_TYPE" AFTER INSERT or update or delete ON CTCATALOGED_ITEM_TYPE
FOR EACH ROW
BEGIN
insert into log_CTCATALOGED_ITEM_TYPE (
username,
change_date,
n_DESCRIPTION,
n_CATALOGED_ITEM_TYPE,
o_DESCRIPTION,
o_CATALOGED_ITEM_TYPE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.CATALOGED_ITEM_TYPE,
:OLD.DESCRIPTION,
:OLD.CATALOGED_ITEM_TYPE
);
END;
/
ALTER TRIGGER "UAM"."TR_LOG_CTCATALOGED_ITEM_TYPE" ENABLE;

alter table log_CTCONTAINER_TYPE rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTCONTAINER_TYPE" AFTER INSERT or update or delete ON CTCONTAINER_TYPE
FOR EACH ROW
BEGIN
insert into log_CTCONTAINER_TYPE (
username,
change_date,
n_DESCRIPTION,
n_CONTAINER_TYPE,
o_DESCRIPTION,
o_CONTAINER_TYPE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.CONTAINER_TYPE,
:OLD.DESCRIPTION,
:OLD.CONTAINER_TYPE
);
END;
/

alter table log_ctculture rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTCULTURE"
AFTER INSERT or update or delete ON ctculture
FOR EACH ROW
BEGIN
insert into log_ctculture (
username,
change_date,
n_CULTURE,
n_collection_cde,
n_DESCRIPTION,
o_CULTURE,
o_collection_cde,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.CULTURE,
:NEW.collection_cde,
:NEW.DESCRIPTION,
:OLD.CULTURE,
:OLD.collection_cde,
:OLD.DESCRIPTION
);
END;
/

alter table log_CTADDR_TYPE rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTADDR_TYPE" AFTER INSERT or update or delete ON CTADDR_TYPE
FOR EACH ROW
BEGIN
insert into log_CTADDR_TYPE (
username,
change_date,
n_DESCRIPTION,
n_ADDR_TYPE,
o_DESCRIPTION,
o_ADDR_TYPE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.ADDR_TYPE,
:OLD.DESCRIPTION,
:OLD.ADDR_TYPE
);
END;
/





alter table log_geog_auth_rec rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_GEOG_UPDATE"
AFTER INSERT or update or delete ON geog_auth_rec
FOR EACH ROW
declare
action_type varchar2(255);
BEGIN
    if updating then
    if :OLD.higher_geog != :NEW.higher_geog then
    insert into log_geog_auth_rec (
GEOG_AUTH_REC_ID,
username,
action_type,
change_date,
n_CONTINENT_OCEAN,
n_COUNTRY,
n_STATE_PROV,
n_COUNTY,
n_QUAD,
n_FEATURE,
n_drainage,
n_ISLAND,
n_ISLAND_GROUP,
n_SEA,
n_SOURCE_AUTHORITY,
n_GEOG_REMARK,
o_CONTINENT_OCEAN,
o_COUNTRY,
o_STATE_PROV,
o_COUNTY,
o_QUAD,
o_FEATURE,
o_drainage,
o_ISLAND,
o_ISLAND_GROUP,
o_SEA,
o_SOURCE_AUTHORITY,
o_GEOG_REMARK
) values (
:OLD.GEOG_AUTH_REC_ID,
SYS_CONTEXT('USERENV','SESSION_USER'),
'updating',
sysdate,
:NEW.CONTINENT_OCEAN,
:NEW.COUNTRY,
:NEW.STATE_PROV,
:NEW.COUNTY,
:NEW.QUAD,
:NEW.FEATURE,
:NEW.drainage,
:NEW.ISLAND,
:NEW.ISLAND_GROUP,
:NEW.SEA,
:NEW.SOURCE_AUTHORITY,
:NEW.GEOG_REMARK,
:OLD.CONTINENT_OCEAN,
:OLD.COUNTRY,
:OLD.STATE_PROV,
:OLD.COUNTY,
:OLD.QUAD,
:OLD.FEATURE,
:OLD.drainage,
:OLD.ISLAND,
:OLD.ISLAND_GROUP,
:OLD.SEA,
:OLD.SOURCE_AUTHORITY,
:OLD.GEOG_REMARK
);
end if;

    elsif inserting then
    insert into log_geog_auth_rec (
GEOG_AUTH_REC_ID,
username,
action_type,
change_date,
n_CONTINENT_OCEAN,
n_COUNTRY,
n_STATE_PROV,
n_COUNTY,
n_QUAD,
n_FEATURE,
n_drainage,
n_ISLAND,
n_ISLAND_GROUP,
n_SEA,
n_SOURCE_AUTHORITY,
n_GEOG_REMARK
) values (
:NEW.GEOG_AUTH_REC_ID,
SYS_CONTEXT('USERENV','SESSION_USER'),
'inserting',
sysdate,
:NEW.CONTINENT_OCEAN,
:NEW.COUNTRY,
:NEW.STATE_PROV,
:NEW.COUNTY,
:NEW.QUAD,
:NEW.FEATURE,
:NEW.drainage,
:NEW.ISLAND,
:NEW.ISLAND_GROUP,
:NEW.SEA,
:NEW.SOURCE_AUTHORITY,
:NEW.GEOG_REMARK
);
    elsif deleting then
    insert into log_geog_auth_rec (
GEOG_AUTH_REC_ID,
username,
action_type,
change_date,
o_CONTINENT_OCEAN,
o_COUNTRY,
o_STATE_PROV,
o_COUNTY,
o_QUAD,
o_FEATURE,
o_drainage,
o_ISLAND,
o_ISLAND_GROUP,
o_SEA,
o_SOURCE_AUTHORITY,
o_GEOG_REMARK
) values (
:OLD.GEOG_AUTH_REC_ID,
SYS_CONTEXT('USERENV','SESSION_USER'),
'deleting',
sysdate,
:OLD.CONTINENT_OCEAN,
:OLD.COUNTRY,
:OLD.STATE_PROV,
:OLD.COUNTY,
:OLD.QUAD,
:OLD.FEATURE,
:OLD.drainage,
:OLD.ISLAND,
:OLD.ISLAND_GROUP,
:OLD.SEA,
:OLD.SOURCE_AUTHORITY,
:OLD.GEOG_REMARK
);

    end if;


END;
/


alter table log_ctnagpra_category rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_NAGPRA_CATEGORY"
AFTER INSERT or update or delete ON ctnagpra_category
FOR EACH ROW
BEGIN
insert into log_ctnagpra_category (
username,
change_date,
n_NAGPRA_CATEGORY,
n_collection_cde,
n_DESCRIPTION,
o_NAGPRA_CATEGORY,
o_collection_cde,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.NAGPRA_CATEGORY,
:NEW.collection_cde,
:NEW.DESCRIPTION,
:OLD.NAGPRA_CATEGORY,
:OLD.collection_cde,
:OLD.DESCRIPTION
);
END;
/

alter table log_CTFEATURE rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTFEATURE" AFTER INSERT or update or delete ON CTFEATURE
FOR EACH ROW
BEGIN
insert into log_CTFEATURE (
username,
change_date,
n_FEATURE,
n_DESCRIPTION,
o_FEATURE,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.FEATURE,
:NEW.DESCRIPTION,
:OLD.FEATURE,
:OLD.DESCRIPTION
);
END;
/
ALTER TRIGGER "UAM"."TR_LOG_CTFEATURE" ENABLE;

alter table log_CTMEDIA_RELATIONSHIP rename column when to change_date;



  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTMEDIA_RELATIONSHIP" AFTER INSERT or update or delete ON CTMEDIA_RELATIONSHIP
FOR EACH ROW
BEGIN
insert into log_CTMEDIA_RELATIONSHIP (
username,
change_date,
n_MEDIA_RELATIONSHIP,
n_DESCRIPTION,
o_MEDIA_RELATIONSHIP,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.MEDIA_RELATIONSHIP,
:NEW.DESCRIPTION,
:OLD.MEDIA_RELATIONSHIP,
:OLD.DESCRIPTION
);
END;
/


alter table log_CTLAT_LONG_UNITS rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTLAT_LONG_UNITS" AFTER INSERT or update or delete ON CTLAT_LONG_UNITS
FOR EACH ROW
BEGIN
insert into log_CTLAT_LONG_UNITS (
username,
change_date,
n_ORIG_LAT_LONG_UNITS,
n_DESCRIPTION,
o_ORIG_LAT_LONG_UNITS,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.ORIG_LAT_LONG_UNITS,
:NEW.DESCRIPTION,
:OLD.ORIG_LAT_LONG_UNITS,
:OLD.DESCRIPTION
);
END;
/


alter table log_CTPART_ATTRIBUTE_PART rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTPART_ATTRIBUTE_PART" AFTER INSERT or update or delete ON CTPART_ATTRIBUTE_PART
FOR EACH ROW
BEGIN
insert into log_CTPART_ATTRIBUTE_PART (
username,
change_date,
n_ATTRIBUTE_PART,
o_ATTRIBUTE_PART
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.ATTRIBUTE_PART,
:OLD.ATTRIBUTE_PART
);
END;
/


alter table log_CTNOMENCLATURAL_CODE rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTNOMENCLATURAL_CODE" AFTER INSERT or update or delete ON CTNOMENCLATURAL_CODE
FOR EACH ROW
BEGIN
insert into log_CTNOMENCLATURAL_CODE (
username,
change_date,
n_NOMENCLATURAL_CODE,
n_DESCRIPTION,
o_NOMENCLATURAL_CODE,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.NOMENCLATURAL_CODE,
:NEW.DESCRIPTION,
:OLD.NOMENCLATURAL_CODE,
:OLD.DESCRIPTION
);
END;
/

alter table log_CTPERMIT_TYPE rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTPERMIT_TYPE" AFTER INSERT or update or delete ON CTPERMIT_TYPE
FOR EACH ROW
BEGIN
insert into log_CTPERMIT_TYPE (
username,
change_date,
n_PERMIT_TYPE,
o_PERMIT_TYPE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.PERMIT_TYPE,
:OLD.PERMIT_TYPE
);
END;
/

alter table log_CTAUTHOR_ROLE rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTAUTHOR_ROLE" AFTER INSERT or update or delete ON CTAUTHOR_ROLE
FOR EACH ROW
BEGIN
insert into log_CTAUTHOR_ROLE (
username,
change_date,
n_AUTHOR_ROLE,
o_AUTHOR_ROLE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.AUTHOR_ROLE,
:OLD.AUTHOR_ROLE
);
END;
/

alter table log_cttemperature_units rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTTEMPERATURE_UNITS"
AFTER INSERT or update or delete ON cttemperature_units
FOR EACH ROW
BEGIN
insert into log_cttemperature_units (
username,
change_date,
n_temperature_units,
n_DESCRIPTION,
o_temperature_units,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.temperature_units,
:NEW.DESCRIPTION,
:OLD.temperature_units,
:OLD.DESCRIPTION
);
END;
/

alter table log_CTWEIGHT_UNITS rename column when to change_date;



  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTWEIGHT_UNITS" AFTER INSERT or update or delete ON CTWEIGHT_UNITS
FOR EACH ROW
BEGIN
insert into log_CTWEIGHT_UNITS (
username,
change_date,
n_WEIGHT_UNITS,
n_DESCRIPTION,
o_WEIGHT_UNITS,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.WEIGHT_UNITS,
:NEW.DESCRIPTION,
:OLD.WEIGHT_UNITS,
:OLD.DESCRIPTION
);
END;
/


alter table log_ctpart_preservation_need rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTPART_PRESN_NEED" AFTER INSERT or update or delete ON ctpart_preservation_need
FOR EACH ROW
BEGIN
insert into log_ctpart_preservation_need (
username,
change_date,
n_DESCRIPTION,
n_preservation_need,
o_DESCRIPTION,
o_preservation_need
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.preservation_need,
:OLD.DESCRIPTION,
:OLD.preservation_need
);
END;
/

alter table log_CTEW rename column when to change_date;
 
  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTEW" AFTER INSERT or update or delete ON CTEW
FOR EACH ROW
BEGIN
insert into log_CTEW (
username,
change_date,
n_E_OR_W,
o_E_OR_W
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.E_OR_W,
:OLD.E_OR_W
);
END;
/


alter table log_ctcoll_event_att_att rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTCOLL_EVENT_ATT_ATT" AFTER INSERT or update or delete ON ctcoll_event_att_att
FOR EACH ROW
BEGIN
insert into log_ctcoll_event_att_att (
username,
change_date,
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

alter table log_CTCOLL_OBJECT_TYPE rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTCOLL_OBJECT_TYPE" AFTER INSERT or update or delete ON CTCOLL_OBJECT_TYPE
FOR EACH ROW
BEGIN
insert into log_CTCOLL_OBJECT_TYPE (
username,
change_date,
n_COLL_OBJECT_TYPE,
o_COLL_OBJECT_TYPE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.COLL_OBJECT_TYPE,
:OLD.COLL_OBJECT_TYPE
);
END;
/

alter table log_CTYES_NO rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTYES_NO" AFTER INSERT or update or delete ON CTYES_NO
FOR EACH ROW
BEGIN
insert into log_CTYES_NO (
username,
change_date,
n_YES_OR_NO,
o_YES_OR_NO
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.YES_OR_NO,
:OLD.YES_OR_NO
);
END;
/

alter table log_CTAGENT_TYPE rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTAGENT_TYPE" AFTER INSERT or update or delete ON CTAGENT_TYPE
FOR EACH ROW
BEGIN
insert into log_CTAGENT_TYPE (
username,
change_date,
n_DESCRIPTION,
n_AGENT_TYPE,
o_DESCRIPTION,
o_AGENT_TYPE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.AGENT_TYPE,
:OLD.DESCRIPTION,
:OLD.AGENT_TYPE
);
END;
/


alter table log_CTAGENT_RANK rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTAGENT_RANK" AFTER INSERT or update or delete ON CTAGENT_RANK
FOR EACH ROW
BEGIN
insert into log_CTAGENT_RANK (
username,
change_date,
n_DESCRIPTION,
n_AGENT_RANK,
o_DESCRIPTION,
o_AGENT_RANK
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.AGENT_RANK,
:OLD.DESCRIPTION,
:OLD.AGENT_RANK
);
END;
/

alter table log_CTSPECIMEN_EVENT_TYPE rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTSPECIMEN_EVENT_TYPE" AFTER INSERT or update or delete ON CTSPECIMEN_EVENT_TYPE
FOR EACH ROW
BEGIN
insert into log_CTSPECIMEN_EVENT_TYPE (
username,
change_date,
n_DESCRIPTION,
n_SPECIMEN_EVENT_TYPE,
o_DESCRIPTION,
o_SPECIMEN_EVENT_TYPE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.SPECIMEN_EVENT_TYPE,
:OLD.DESCRIPTION,
:OLD.SPECIMEN_EVENT_TYPE
);
END;
/


alter table log_CTSPEC_PART_ATT_ATT rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTSPEC_PART_ATT_ATT" AFTER INSERT or update or delete ON CTSPEC_PART_ATT_ATT
FOR EACH ROW
BEGIN
insert into log_CTSPEC_PART_ATT_ATT (
username,
change_date,
n_VALUE_CODE_TABLE,
n_UNIT_CODE_TABLE,
n_ATTRIBUTE_TYPE,
o_VALUE_CODE_TABLE,
o_UNIT_CODE_TABLE,
o_ATTRIBUTE_TYPE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.VALUE_CODE_TABLE,
:NEW.UNIT_CODE_TABLE,
:NEW.ATTRIBUTE_TYPE,
:OLD.VALUE_CODE_TABLE,
:OLD.UNIT_CODE_TABLE,
:OLD.ATTRIBUTE_TYPE
);
END;
/

alter table log_CTCOLL_CONTACT_ROLE rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTCOLL_CONTACT_ROLE" AFTER INSERT or update or delete ON CTCOLL_CONTACT_ROLE
FOR EACH ROW
BEGIN
insert into log_CTCOLL_CONTACT_ROLE (
username,
change_date,
n_DESCRIPTION,
n_CONTACT_ROLE,
o_DESCRIPTION,
o_CONTACT_ROLE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.CONTACT_ROLE,
:OLD.DESCRIPTION,
:OLD.CONTACT_ROLE
);
END;
/

alter table log_CTPROJECT_AGENT_ROLE rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTPROJECT_AGENT_ROLE" AFTER INSERT or update or delete ON CTPROJECT_AGENT_ROLE
FOR EACH ROW
BEGIN
insert into log_CTPROJECT_AGENT_ROLE (
username,
change_date,
n_PROJECT_AGENT_ROLE,
o_PROJECT_AGENT_ROLE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.PROJECT_AGENT_ROLE,
:OLD.PROJECT_AGENT_ROLE
);
END;
/

alter table log_CTCF_LOAN_USE_TYPE rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTCF_LOAN_USE_TYPE" AFTER INSERT or update or delete ON CTCF_LOAN_USE_TYPE
FOR EACH ROW
BEGIN
insert into log_CTCF_LOAN_USE_TYPE (
username,
change_date,
n_USE_TYPE,
o_USE_TYPE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.USE_TYPE,
:OLD.USE_TYPE
);
END;
/


alter table log_CTTAXON_VARIABLE rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTTAXON_VARIABLE" AFTER INSERT or update or delete ON CTTAXON_VARIABLE
FOR EACH ROW
BEGIN
insert into log_CTTAXON_VARIABLE (
username,
change_date,
n_TAXON_VARIABLE,
o_TAXON_VARIABLE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.TAXON_VARIABLE,
:OLD.TAXON_VARIABLE
);
END;
/

alter table log_CTCITATION_TYPE_STATUS rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTCITATION_TYPE_STATUS" AFTER INSERT or update or delete ON CTCITATION_TYPE_STATUS
FOR EACH ROW
BEGIN
insert into log_CTCITATION_TYPE_STATUS (
username,
change_date,
n_TYPE_STATUS,
n_DESCRIPTION,
o_TYPE_STATUS,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.TYPE_STATUS,
:NEW.DESCRIPTION,
:OLD.TYPE_STATUS,
:OLD.DESCRIPTION
);
END;
/


alter table log_CTTRANS_AGENT_ROLE rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTTRANS_AGENT_ROLE" AFTER INSERT or update or delete ON CTTRANS_AGENT_ROLE
FOR EACH ROW
BEGIN
insert into log_CTTRANS_AGENT_ROLE (
username,
change_date,
n_TRANS_AGENT_ROLE,
n_DESCRIPTION,
o_TRANS_AGENT_ROLE,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.TRANS_AGENT_ROLE,
:NEW.DESCRIPTION,
:OLD.TRANS_AGENT_ROLE,
:OLD.DESCRIPTION
);
END;
/


alter table log_CTPERMIT_AGENT_ROLE rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTPERMIT_AGENT_ROLE" AFTER INSERT or update or delete ON CTPERMIT_AGENT_ROLE
FOR EACH ROW
BEGIN
insert into log_CTPERMIT_AGENT_ROLE (
username,
change_date,
n_DESCRIPTION,
n_PERMIT_AGENT_ROLE,
o_DESCRIPTION,
o_PERMIT_AGENT_ROLE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.PERMIT_AGENT_ROLE,
:OLD.DESCRIPTION,
:OLD.PERMIT_AGENT_ROLE
);
END;
/


alter table log_CTENCUMBRANCE_ACTION rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTENCUMBRANCE_ACTION" AFTER INSERT or update or delete ON CTENCUMBRANCE_ACTION
FOR EACH ROW
BEGIN
insert into log_CTENCUMBRANCE_ACTION (
username,
change_date,
n_ENCUMBRANCE_ACTION,
n_DESCRIPTION,
o_ENCUMBRANCE_ACTION,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.ENCUMBRANCE_ACTION,
:NEW.DESCRIPTION,
:OLD.ENCUMBRANCE_ACTION,
:OLD.DESCRIPTION
);
END;
/


alter table log_CTPREFIX rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTPREFIX" AFTER INSERT or update or delete ON CTPREFIX
FOR EACH ROW
BEGIN
insert into log_CTPREFIX (
username,
change_date,
n_PREFIX,
o_PREFIX
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.PREFIX,
:OLD.PREFIX
);
END;
/


alter table log_ctcopyright_status rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTCOPYRIGHT_STATUS"
AFTER INSERT or update or delete ON ctcopyright_status
FOR EACH ROW
BEGIN
insert into log_ctcopyright_status (
username,
change_date,
n_copyright_status,
n_DESCRIPTION,
o_copyright_status,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.copyright_status,
:NEW.DESCRIPTION,
:OLD.copyright_status,
:OLD.DESCRIPTION
);
END;
/

alter table log_CTTAXON_STATUS rename column when to change_date;


  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTTAXON_STATUS" AFTER INSERT or update or delete ON CTTAXON_STATUS
FOR EACH ROW
BEGIN
insert into log_CTTAXON_STATUS (
username,
change_date,
n_TAXON_STATUS,
n_DESCRIPTION,
o_TAXON_STATUS,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.TAXON_STATUS,
:NEW.DESCRIPTION,
:OLD.TAXON_STATUS,
:OLD.DESCRIPTION
);
END;
/

alter table log_CTATTRIBUTE_CODE_TABLES rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTATTRIBUTE_CODE_TABLES" AFTER INSERT or update or delete ON CTATTRIBUTE_CODE_TABLES
FOR EACH ROW
BEGIN
insert into log_CTATTRIBUTE_CODE_TABLES (
username,
change_date,
n_VALUE_CODE_TABLE,
n_UNITS_CODE_TABLE,
n_ATTRIBUTE_TYPE,
o_VALUE_CODE_TABLE,
o_UNITS_CODE_TABLE,
o_ATTRIBUTE_TYPE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.VALUE_CODE_TABLE,
:NEW.UNITS_CODE_TABLE,
:NEW.ATTRIBUTE_TYPE,
:OLD.VALUE_CODE_TABLE,
:OLD.UNITS_CODE_TABLE,
:OLD.ATTRIBUTE_TYPE
);
END;
/


alter table log_CTACCN_STATUS rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTACCN_STATUS" AFTER INSERT or update or delete ON CTACCN_STATUS
FOR EACH ROW
BEGIN
insert into log_CTACCN_STATUS (
username,
change_date,
n_ACCN_STATUS,
n_DESCRIPTION,
o_ACCN_STATUS,
o_DESCRIPTION
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.ACCN_STATUS,
:NEW.DESCRIPTION,
:OLD.ACCN_STATUS,
:OLD.DESCRIPTION
);
END;
/


alter table log_CTCOUNT_UNITS rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTCOUNT_UNITS" AFTER INSERT or update or delete ON CTCOUNT_UNITS
FOR EACH ROW
BEGIN
insert into log_CTCOUNT_UNITS (
username,
change_date,
n_DESCRIPTION,
n_COUNT_UNITS,
o_DESCRIPTION,
o_COUNT_UNITS
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.COUNT_UNITS,
:OLD.DESCRIPTION,
:OLD.COUNT_UNITS
);
END;
/


alter table log_CTDEPTH_UNITS rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTDEPTH_UNITS" AFTER INSERT or update or delete ON CTDEPTH_UNITS
FOR EACH ROW
BEGIN
insert into log_CTDEPTH_UNITS (
username,
change_date,
n_DESCRIPTION,
n_DEPTH_UNITS,
o_DESCRIPTION,
o_DEPTH_UNITS
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.DEPTH_UNITS,
:OLD.DESCRIPTION,
:OLD.DEPTH_UNITS
);
END;
/


alter table log_CTFLAGS rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTFLAGS" AFTER INSERT or update or delete ON CTFLAGS
FOR EACH ROW
BEGIN
insert into log_CTFLAGS (
username,
change_date,
n_FLAGS,
o_FLAGS
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.FLAGS,
:OLD.FLAGS
);
END;
/


alter table log_CTBORROW_STATUS rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTBORROW_STATUS" AFTER INSERT or update or delete ON CTBORROW_STATUS
FOR EACH ROW
BEGIN
insert into log_CTBORROW_STATUS (
username,
change_date,
n_BORROW_STATUS,
o_BORROW_STATUS
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.BORROW_STATUS,
:OLD.BORROW_STATUS
);
END;
/


alter table log_CTCOLLECTING_SOURCE rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTCOLLECTING_SOURCE" AFTER INSERT or update or delete ON CTCOLLECTING_SOURCE
FOR EACH ROW
BEGIN
insert into log_CTCOLLECTING_SOURCE (
username,
change_date,
n_DESCRIPTION,
n_COLLECTING_SOURCE,
o_DESCRIPTION,
o_COLLECTING_SOURCE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.COLLECTING_SOURCE,
:OLD.DESCRIPTION,
:OLD.COLLECTING_SOURCE
);
END;
/


alter table log_CTCOLLECTION_CDE rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTCOLLECTION_CDE" AFTER INSERT or update or delete ON CTCOLLECTION_CDE
FOR EACH ROW
BEGIN
insert into log_CTCOLLECTION_CDE (
username,
change_date,
n_COLLECTION_CDE,
o_COLLECTION_CDE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.COLLECTION_CDE,
:OLD.COLLECTION_CDE
);
END;
/


alter table log_CTCASTE rename column when to change_date;




  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTCASTE" AFTER INSERT or update or delete ON CTCASTE
FOR EACH ROW
BEGIN
insert into log_CTCASTE (
username,
change_date,
n_COLLECTION_CDE,
n_CASTE,
o_COLLECTION_CDE,
o_CASTE
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.COLLECTION_CDE,
:NEW.CASTE,
:OLD.COLLECTION_CDE,
:OLD.CASTE
);
END;
/

alter table log_CTGEOREFERENCE_PROTOCOL rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTGEOREFERENCE_PROTOCOL" AFTER INSERT or update or delete ON CTGEOREFERENCE_PROTOCOL
FOR EACH ROW
BEGIN
insert into log_CTGEOREFERENCE_PROTOCOL (
username,
change_date,
n_GEOREFERENCE_PROTOCOL,
o_GEOREFERENCE_PROTOCOL
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.GEOREFERENCE_PROTOCOL,
:OLD.GEOREFERENCE_PROTOCOL
);
END;
/


alter table log_CTNS rename column when to change_date;

  CREATE OR REPLACE TRIGGER "UAM"."TR_LOG_CTNS" AFTER INSERT or update or delete ON CTNS
FOR EACH ROW
BEGIN
insert into log_CTNS (
username,
change_date,
n_N_OR_S,
o_N_OR_S
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.N_OR_S,
:OLD.N_OR_S
);
END;
/


 
SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name='CTTAXONOMIC_AUTHORITY';
SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner) FROM  all_triggers WHERE table_name like '%TAXONOMIC_AUTHORITY';


LOG_CTTAXONOMIC_AUTHORITY
WHEN



-- not used
drop table taxonomy_archive;



SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner)
FROM   all_triggers
WHERE table_name in (select table_name from user_tab_cols where column_name='WHEN');






SET PAGESIZE 14 LINESIZE 100 FEEDBACK ON VERIFY ON


select trigger_name from all_triggers where table_name='CTADDRESS_TYPE';
WHEN
LOG_CTADDRESS_TYPE
TAXONOMY_ARCHIVE
WHEN

ACCN_SCAN
WHEN

LOC_CARD_SCAN
WHEN

SPEC_SCAN
WHEN

LOG_CTNAGPRA_CATEGORY
WHEN

LOG_CTCOPYRIGHT_STATUS
WHEN

LOG_CTCONDUCTIVITY_UNITS
WHEN

LOG_CTTEMPERATURE_UNITS
WHEN

LOG_GEOLOGY_ATTRIBUTE_HIY
WHEN

LOG_GEOG_AUTH_REC
WHEN

LOG_CTTISSUE_QUALITY
WHEN

LOG_CTTAXA_FORMULA
WHEN

LOG_CTTAXONOMIC_AUTHORITY
WHEN

LOG_CTTAXONOMY_SOURCE
WHEN

LOG_CTTAXON_RELATION
WHEN

LOG_CTTAXON_STATUS
WHEN

LOG_CTTAXON_VARIABLE
WHEN

LOG_CTTISSUE_VOLUME_UNITS
WHEN

LOG_CTTRANSACTION_TYPE
WHEN

LOG_CTTRANS_AGENT_ROLE
WHEN

LOG_CTVERIFICATIONSTATUS
WHEN

LOG_CTINFRASPECIFIC_RANK
WHEN

LOG_CTISLAND_GROUP
WHEN

LOG_CTKILL_METHOD
WHEN

LOG_CTLAT_LONG_ERROR_UNITS
WHEN

LOG_CTLAT_LONG_UNITS
WHEN

LOG_CTCOLL_EVENT_ATT_ATT
WHEN

LOG_CTNOMENCLATURAL_CODE
WHEN

LOG_CTNS
WHEN

LOG_CTNUMERIC_AGE_UNITS
WHEN

LOG_CTORIG_ELEV_UNITS
WHEN

LOG_CTPART_ATTRIBUTE_PART
WHEN

LOG_CTPERMIT_TYPE
WHEN

LOG_CTPREFIX
WHEN

LOG_CTPROJECT_AGENT_ROLE
WHEN

LOG_CTPUBLICATION_ATTRIBUTE
WHEN

LOG_CTPUBLICATION_TYPE
WHEN

LOG_CTSECTION_TYPE
WHEN

LOG_CTSEX_CDE
WHEN

LOG_CTSHIPMENT_TYPE
WHEN

LOG_CTSHIPPED_CARRIER_METHOD
WHEN

LOG_CTSPECIMEN_EVENT_TYPE
WHEN

LOG_CTSPECIMEN_PART_LIST_ORDER
WHEN

LOG_CTSPECIMEN_PART_NAME
WHEN

LOG_CTSPECPART_ATTRIBUTE_TYPE
WHEN

LOG_CTSPEC_PART_ATT_ATT
WHEN

LOG_CTSUFFIX
WHEN

LOG_CTACCN_TYPE
WHEN

LOG_CTADDR_TYPE
WHEN

LOG_CTAGENT_NAME_TYPE
WHEN

LOG_CTAGENT_RANK
WHEN

LOG_CTAGENT_RELATIONSHIP
WHEN

LOG_CTAGENT_TYPE
WHEN

LOG_CTAGE_CLASS
WHEN

LOG_CTATTRIBUTE_CODE_TABLES
WHEN

LOG_CTATTRIBUTE_TYPE
WHEN

LOG_CTAUTHOR_ROLE
WHEN

LOG_CTWEIGHT_UNITS
WHEN

LOG_CTYES_NO
WHEN

LOG_CTBIOL_RELATIONS
WHEN

LOG_CTBORROW_STATUS
WHEN

LOG_CTCATALOGED_ITEM_TYPE
WHEN

LOG_CTCF_LOAN_USE_TYPE
WHEN

LOG_CTABUNDANCE
WHEN

LOG_CTACCN_STATUS
WHEN

LOG_CTPART_PRESERVATION
WHEN

LOG_CTPERMIT_REGULATION
WHEN

LOG_CTPERMIT_AGENT_ROLE
WHEN

LOG_CTCASTE
WHEN

LOG_CTCITATION_TYPE_STATUS
WHEN

LOG_CTCOLLECTING_SOURCE
WHEN

LOG_CTCOLLECTION_CDE
WHEN

LOG_CTCOLLECTOR_ROLE
WHEN

LOG_CTCOLL_CONTACT_ROLE
WHEN

LOG_CTAGENT_STATUS
WHEN

LOG_CTCOLL_OBJECT_TYPE
WHEN

LOG_CTCOLL_OBJ_DISP
WHEN

LOG_CTCOLL_OTHER_ID_TYPE
WHEN

LOG_CTCONTAINER_TYPE
WHEN

LOG_CTCOUNT_UNITS
WHEN

LOG_CTDATUM
WHEN

LOG_CTDEPTH_UNITS
WHEN

LOG_CTDOWNLOAD_PURPOSE
WHEN

LOG_CTELECTRONIC_ADDR_TYPE
WHEN

LOG_CTENCUMBRANCE_ACTION
WHEN

LOG_CTLENGTH_UNITS
WHEN

LOG_CTLOAN_STATUS
WHEN

LOG_CTLOAN_TYPE
WHEN

LOG_CTMEDIA_LABEL
WHEN

LOG_CTMEDIA_LICENSE
WHEN

LOG_CTMEDIA_RELATIONSHIP
WHEN

LOG_CTMEDIA_TYPE
WHEN

LOG_CTMIME_TYPE
WHEN

LOG_CTMONETARY_UNITS
WHEN

LOG_CTNATURE_OF_ID
WHEN

LOG_CTEW
WHEN

LOG_CTFEATURE
WHEN

LOG_CTFLAGS
WHEN

LOG_CTFLUID_CONCENTRATION
WHEN

LOG_CTFLUID_TYPE
WHEN

LOG_CTGEOLOGY_ATTRIBUTE
WHEN

LOG_CTGEOREFERENCE_PROTOCOL
WHEN

LOG_CTGEOREFMETHOD
WHEN

LOG_CTID_REFERENCES
WHEN

LOG_CTCOLL_EVENT_ATTR_TYPE
WHEN

LOG_CTGEOG_SOURCE_AUTHORITY
WHEN

LOG_CTPART_PRESERVATION_NEED
WHEN

LOG_CTCONTAINER_ENV_PARAMETER
WHEN

LOG_CTCULTURE
WHEN


111 rows selected.

Elapsed: 00:00:00.73
UAM@ARCTOS> UAM@ARCTOS> 
