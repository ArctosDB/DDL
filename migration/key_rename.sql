select uc.table_name, uc.constraint_name from user_constraints uc, user_cons_col
umns ucc
where uc.constraint_name = ucc.constraint_name
and uc.constraint_type = 'P'
and uc.constraint_name not like 'PK_%'
order by uc.table_name, uc.constraint_name


select 'alter table ' || uc.table_name || ' add constraint ' || uc.constraint_name ||
' primary key (' || ucc.column_name || ')'
from user_constraints uc, user_cons_columns ucc
where uc.constraint_name = ucc.constraint_name
and uc.constraint_type = 'P'
and uc.table_name not like 'CT%'
order by ucc.table_name, ucc.column_name, ucc.position
alter table ACCN add constraint PK_ACCN primary key (TRANSACTION_ID)
alter table ADDR add constraint PK_ADDR primary key (ADDR_ID)
alter table AGENT add constraint PK_AGENT primary key (AGENT_ID)
alter table AGENT_NAME add constraint PK_AGENT_NAME primary key (AGENT_NAME_ID)
alter table AGENT_NAME_PENDING_DELETE add constraint PK_AGENT_NAME_PENDING_DELETE primary key (AGENT_ID)
alter table AGENT_NAME_PENDING_DELETE add constraint PK_AGENT_NAME_PENDING_DELETE primary key (AGENT_NAME_ID)
alter table ATTRIBUTES add constraint PK_ATTRIBUTES primary key (ATTRIBUTE_ID)
alter table BINARY_OBJECT add constraint PK_BINARY_OBJECT primary key (COLLECTION_OBJECT_ID)
alter table BOOK add constraint PK_BOOK primary key (PUBLICATION_ID)
alter table BOOK_SECTION add constraint PK_BOOK_SECTION primary key (PUBLICATION_ID)
alter table BORROW add constraint PK_BORROW primary key (TRANSACTION_ID)
alter table CATALOGED_ITEM add constraint PK_CATALOGED_ITEM primary key (COLLECTION_OBJECT_ID)
alter table CF_REPORT_SQL add constraint PK_CF_REPORT_SQL primary key (REPORT_ID)
alter table CF_SPEC_RES_COLS add constraint PK_CF_SPEC_RES_COLS primary key (CF_SPEC_RES_COLS_ID)
alter table CITATION add constraint PK_CITATION primary key (COLLECTION_OBJECT_ID)
alter table CITATION add constraint PK_CITATION primary key (PUBLICATION_ID)
alter table COLLECTING_EVENT add constraint PK_COLLECTING_EVENT primary key (COLLECTING_EVENT_ID)
alter table COLLECTION add constraint PK_COLLECTION primary key (COLLECTION_ID)
alter table COLLECTION_CONTACTS add constraint PK_COLLECTION_CONTACTS primary key (COLLECTION_CONTACT_ID)
alter table COLL_OBJECT add constraint PK_COLL_OBJECT primary key (COLLECTION_OBJECT_ID)
alter table COLL_OBJECT_ENCUMBRANCE add constraint PK_COLL_OBJECT_ENCUMBRANCE primary key (COLLECTION_OBJECT_ID)
alter table COLL_OBJECT_ENCUMBRANCE add constraint PK_COLL_OBJECT_ENCUMBRANCE primary key (ENCUMBRANCE_ID)
alter table COLL_OBJECT_REMARK add constraint PK_COLL_OBJECT_REMARK primary key (COLLECTION_OBJECT_ID)
alter table COLL_OBJ_OTHER_ID_NUM add constraint PK_COLL_OBJ_OTHER_ID_NUM_ID primary key (COLL_OBJ_OTHER_ID_NUM_ID)
alter table COMMON_NAME add constraint PK_COMMON_NAME primary key (COMMON_NAME)
alter table COMMON_NAME add constraint PK_COMMON_NAME primary key (TAXON_NAME_ID)
alter table CONTAINER add constraint PKEY_CONTAINER_ID primary key (CONTAINER_ID)
alter table CONTAINER_CHECK add constraint PKEY_CONTAINER_CHECK primary key (CONTAINER_CHECK_ID)
alter table DEV_TASK add constraint DEV_TASK_PKEY primary key (TASK_ID)
alter table ENCUMBRANCE add constraint PK_ENCUMBRANCE primary key (ENCUMBRANCE_ID)
alter table FIELD_NOTEBOOK_SECTION add constraint PK_FIELD_NOTEBOOK_SECTION primary key (PUBLICATION_ID)
alter table FLAT add constraint PK_FLAT primary key (COLLECTION_OBJECT_ID)
alter table GEOG_AUTH_REC add constraint PKEY_GEOG_AUTH_REC primary key (GEOG_AUTH_REC_ID)
alter table GEOLOGY_ATTRIBUTES add constraint PK_GEOLOGY_ATTRIBUTES primary key (GEOLOGY_ATTRIBUTE_ID)
alter table GEOLOGY_ATTRIBUTE_HIERARCHY add constraint PK_GEOLOGY_ATTRIBUTE_HIERARCHY primary key (GEOLOGY_ATTRIBUTE_HIERARCHY_ID)
alter table IDENTIFICATION add constraint PK_IDENTIFICATION primary key (IDENTIFICATION_ID)
alter table IDENTIFICATION_AGENT add constraint PK_IDENTIFICATION_AGENT primary key (IDENTIFICATION_AGENT_ID)
alter table LAT_LONG add constraint PK_LAT_LONG primary key (LAT_LONG_ID)
alter table LOCALITY add constraint PK_LOCALITY primary key (LOCALITY_ID)
alter table MEDIA add constraint PK_MEDIA primary key (MEDIA_ID)
alter table MEDIA_LABELS add constraint PK_MEDIA_LABEL_ID primary key (MEDIA_LABEL_ID)
alter table MEDIA_RELATIONS add constraint PK_MEDIA_RELATIONS primary key (MEDIA_RELATIONS_ID)
alter table OBJECT_CONDITION add constraint PK_OBJECT_CONDITION primary key (OBJECT_CONDITION_ID)
alter table PAGE add constraint PKEY_PAGE primary key (PAGE_ID)
alter table PERSON add constraint PKEY_PERSON primary key (PERSON_ID)
alter table PLSQL_PROFILER_DATA add constraint SYS_C0019533 primary key (LINE#)
alter table PLSQL_PROFILER_DATA add constraint SYS_C0019533 primary key (RUNID)
alter table PLSQL_PROFILER_DATA add constraint SYS_C0019533 primary key (UNIT_NUMBER)
alter table PLSQL_PROFILER_RUNS add constraint SYS_C0019534 primary key (RUNID)
alter table PLSQL_PROFILER_UNITS add constraint SYS_C0019536 primary key (RUNID)
alter table PLSQL_PROFILER_UNITS add constraint SYS_C0019536 primary key (UNIT_NUMBER)
alter table PROJECT add constraint PK_PROJECT primary key (PROJECT_ID)
alter table PROJECT_SPONSOR add constraint PK_PROJECT_SPONSOR primary key (PROJECT_SPONSOR_ID)
alter table PUBLICATION add constraint PKEY_PUBLICATION primary key (PUBLICATION_ID)
alter table PUBLICATION_YEAR add constraint PKEY_PUBLICATION_YEAR primary key (PUBLICATION_ID)
alter table PUBLICATION_YEAR add constraint PKEY_PUBLICATION_YEAR primary key (PUB_YEAR)
alter table TAXONOMY add constraint PK_TAXONOMY primary key (TAXON_NAME_ID)
alter table TAXON_RELATIONS add constraint PKEY_TAXON_RELATIONS primary key (RELATED_TAXON_NAME_ID)
alter table TAXON_RELATIONS add constraint PKEY_TAXON_RELATIONS primary key (TAXON_NAME_ID)
alter table TAXON_RELATIONS add constraint PKEY_TAXON_RELATIONS primary key (TAXON_RELATIONSHIP)
alter table TRANS add constraint PK_TRANS primary key (TRANSACTION_ID)
alter table TRANS_AGENT add constraint PK_TRANS_AGENT primary key (TRANS_AGENT_ID)
alter table URL add constraint PKEY_URL primary key (URL_ID)
alter table VIEWER add constraint PKEY_VIEWER primary key (VIEWER_ID)


select 'alter table ' || uc.table_name || ' rename constraint ' || uc.constraint_name ||
' to FK_' || uc.table_name || '_' || uc.r_constraint_name
from user_constraints uc, user_cons_columns ucc
where uc.constraint_name = ucc.constraint_name
and uc.constraint_type = 'R'
and uc.table_name not like 'CT%'
order by ucc.table_name, ucc.column_name, ucc.position
