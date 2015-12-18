
-- control file

load data
 infile 'uamarchdata.csv'
 badfile 'arcbad.bad'
 into table uam_arc_orig
fields terminated by ',' optionally enclosed by '"'
 trailing nullcols  
 (
 	GUID_PREFIX CHAR(4000),
	ACCN CHAR(4000),
	HIGHER_GEOG CHAR(4000),
	SPEC_LOCALITY CHAR(4000),
	VERBATIM_LOCALITY CHAR(4000),
	CAT_NUM CHAR(4000),
	OTHER_ID_NUM_1 CHAR(4000),
	OTHER_ID_NUM_TYPE_1 CHAR(4000),
	OTHER_ID_NUM_2 CHAR(4000),
	OTHER_ID_NUM_TYPE_2 CHAR(4000),
	OTHER_ID_NUM_3 CHAR(4000),
	OTHER_ID_NUM_TYPE_3 CHAR(4000),
	OTHER_ID_NUM_4 CHAR(4000),
	OTHER_ID_NUM_TYPE_4 CHAR(4000),
	TAXON_NAME CHAR(4000),
	NATURE_OF_ID CHAR(4000),
	ID_MADE_BY_AGENT CHAR(4000),
	MADE_DATE CHAR(4000),
	IDENTIFICATION_REMARKS CHAR(4000),
	COLLECTOR_AGENT_1 CHAR(4000),
	COLLECTOR_ROLE_1 CHAR(4000),
	COLLECTOR_AGENT_2 CHAR(4000),
	COLLECTOR_ROLE_2 CHAR(4000),
	COLLECTOR_AGENT_3 CHAR(4000),
	COLLECTOR_ROLE_3 CHAR(4000),
	COLLECTOR_AGENT_4 CHAR(4000),
	COLLECTOR_ROLE_4 CHAR(4000),
	COLLECTOR_AGENT_5 CHAR(4000),
	COLLECTOR_ROLE_5 CHAR(4000),
	COLLECTOR_AGENT_6 CHAR(4000),
	COLLECTOR_ROLE_6 CHAR(4000),
	COLLECTOR_AGENT_7 CHAR(4000),
	COLLECTOR_ROLE_7 CHAR(4000),
	VERBATIM_DATE CHAR(4000),
	MADE_DATE_1 CHAR(4000),
	COLL_OBJECT_REMARKS CHAR(4000),
	PART_NAME_1 CHAR(4000),
	PART_CONDITION_1 CHAR(4000),
	PART_BARCODE_1 CHAR(4000),
	PART_CONTAINER_LABEL_1 CHAR(4000),
	PART_ATTRIBUTE_LOCATION_1 CHAR(4000),
	PART_LOT_COUNT_1 CHAR(4000),
	PART_DISPOSITION_1 CHAR(4000),
	PART_REMARK_1 CHAR(4000),
	ATTRIBUTE_1 CHAR(4000),
	ATTRIBUTE_VALUE_1 CHAR(4000),
	ATTRIBUTE_UNITS_1 CHAR(4000),
	ATTRIBUTE_REMARKS_1 CHAR(4000),
	ATTRIBUTE_DATE_1 CHAR(4000),
	ATTRIBUTE_DET_METH_1 CHAR(4000),
	ATTRIBUTE_DETERMINER_1 CHAR(4000),
	ATTRIBUTE_2 CHAR(4000),
	ATTRIBUTE_VALUE_2 CHAR(4000),
	ATTRIBUTE_UNITS_2 CHAR(4000),
	ATTRIBUTE_REMARKS_2 CHAR(4000),
	ATTRIBUTE_DATE_2 CHAR(4000),
	ATTRIBUTE_DET_METH_2 CHAR(4000),
	ATTRIBUTE_DETERMINER_2 CHAR(4000),
	ATTRIBUTE_3 CHAR(4000),
	ATTRIBUTE_VALUE_3 CHAR(4000),
	ATTRIBUTE_UNITS_3 CHAR(4000),
	ATTRIBUTE_REMARKS_3 CHAR(4000),
	ATTRIBUTE_DATE_3 CHAR(4000),
	ATTRIBUTE_DET_METH_3 CHAR(4000),
	ATTRIBUTE_DETERMINER_3 CHAR(4000),
	ATTRIBUTE_4 CHAR(4000),
	ATTRIBUTE_VALUE_4 CHAR(4000),
	ATTRIBUTE_UNITS_4 CHAR(4000),
	ATTRIBUTE_REMARKS_4  CHAR(4000),
	ATTRIBUTE_DATE_4  CHAR(4000),
	ATTRIBUTE_DET_METH_4 CHAR(4000),
	ATTRIBUTE_DETERMINER_4 CHAR(4000),
	ATTRIBUTE_5 CHAR(4000),
	ATTRIBUTE_VALUE_5 CHAR(4000),
	ATTRIBUTE_UNITS_5 CHAR(4000),
	ATTRIBUTE_REMARKS_5 CHAR(4000),
	ATTRIBUTE_DATE_5 CHAR(4000),
	ATTRIBUTE_DET_METH_5 CHAR(4000),
	ATTRIBUTE_DETERMINER_5 CHAR(4000),
	ATTRIBUTE_6 CHAR(4000),
	ATTRIBUTE_VALUE_6 CHAR(4000),
	ATTRIBUTE_UNITS_6 CHAR(4000),
	ATTRIBUTE_REMARKS_6 CHAR(4000),
	ATTRIBUTE_DATE_6 CHAR(4000),
	ATTRIBUTE_DET_METH_6 CHAR(4000),
	ATTRIBUTE_DETERMINER_6 CHAR(4000),
	ATTRIBUTE_7 CHAR(4000),
	ATTRIBUTE_VALUE_7 CHAR(4000),
	ATTRIBUTE_UNITS_7 CHAR(4000),
	ATTRIBUTE_REMARKS_7 CHAR(4000),
	ATTRIBUTE_DATE_7 CHAR(4000),
	ATTRIBUTE_DET_METH_7 CHAR(4000),
	ATTRIBUTE_DETERMINER_7 CHAR(4000),
	ATTRIBUTE_8 CHAR(4000),
	ATTRIBUTE_VALUE_8 CHAR(4000),
	ATTRIBUTE_UNITS_8 CHAR(4000),
	ATTRIBUTE_REMARKS_8 CHAR(4000),
	ATTRIBUTE_DATE_8 CHAR(4000),
	ATTRIBUTE_DET_METH_8 CHAR(4000),
	ATTRIBUTE_DETERMINER_8 CHAR(4000),
	ATTRIBUTE_9 CHAR(4000),
	ATTRIBUTE_VALUE_9 CHAR(4000),
	ATTRIBUTE_UNITS_9 CHAR(4000),
	ATTRIBUTE_REMARKS_9 CHAR(4000),
	ATTRIBUTE_DATE_9 CHAR(4000),
	TTRIBUTE_DET_METH_9 CHAR(4000),
	ATTRIBUTE_DETERMINER_9 CHAR(4000),
	ATTRIBUTE_10 CHAR(4000),
	ATTRIBUTE_VALUE_10 CHAR(4000),
	ATTRIBUTE_UNITS_10 CHAR(4000),
	ATTRIBUTE_REMARKS_10 CHAR(4000),
	ATTRIBUTE_DATE_10 CHAR(4000),
	ATTRIBUTE_DET_METH_10 CHAR(4000),
	ATTRIBUTE_DETERMINER_10 CHAR(4000),
	ATTRIBUTE_11 CHAR(4000),
	ATTRIBUTE_VALUE_11 CHAR(4000),
	ATTRIBUTE_UNITS_11 CHAR(4000),
	ATTRIBUTE_REMARKS_11 CHAR(4000),
	ATTRIBUTE_DATE_11 CHAR(4000),
	ATTRIBUTE_DET_METH_11 CHAR(4000),
	ATTRIBUTE_DETERMINER_11 CHAR(4000),
	PUBLICATIONS_FULL_CITATION CHAR(4000),
	EVENT_ASSIGNED_DATE CHAR(4000)
 )
 
 load data as CSV
 
$ORACLE_HOME/bin/sqlldr U/P control=arcpart.ctl

-- then hop to prod and create the table there, then back to test and..

insert into uam_arc_part@DB_production (select * from uam_arc_part);





 create table uam_arc_part (
 GUID_PREFIX varCHAR2(4000),
	CAT_NUM varCHAR2(4000),
	other_id_type varCHAR2(4000),
	other_id_number varCHAR2(4000),
	part_name varCHAR2(4000),
	condition varCHAR2(4000),
	disposition varCHAR2(4000),
	lot_count varCHAR2(4000),
	remarks varCHAR2(4000),
	use_existing varCHAR2(4000),
	container_barcode varCHAR2(4000),
	PART_ATTRIBUTE_TYPE_1 varCHAR2(4000),
	PART_ATTRIBUTE_VALUE_1 varCHAR2(4000)
	);
