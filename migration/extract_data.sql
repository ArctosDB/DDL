declare c number;
begin
for tn in (select table_name from user_tables
    WHERE table_name NOT LIKE 'LKV%'
    AND table_name NOT LIKE 'LAM%'
    AND table_name NOT LIKE '%BAK'
    AND table_name NOT LIKE 'BULK%'
    AND table_name NOT LIKE 'CCT%'
    AND table_name NOT LIKE 'CT%'
    AND TABLE_name != 'PLAN_TABLE'
    AND TABLE_name != 'PROC_BL_STATUS'
    order by table_name) loop
    execute immediate 'select count(*) from ' || tn.table_name into c;
    if c > 0 then
        dbms_output.put_line(c || chr(9) || tn.table_name);
    end if;
end loop;
end;

-- need to run script to create collection code tables (CCT%)
-- need to run script to recreate flat
-- need to figure out what to do with
/*
DO NOT migrate:
1       AGENT_NAME_PENDING_DELETE
8654    BSCIT_IMAGE_SUBJECT
718187  FLAT
8334    FMP_IMAGE_DATA

what do we do with these tables????
23150   GREF_PAGE_REFSET_NG
9089    GREF_REFSET_NG
67473   GREF_REFSET_ROI_NG
103511  GREF_ROI_NG
104642  GREF_ROI_VALUE_NG
11      GREF_USER
8502    BINARY_OBJECT
68396   IMAGE_CONTENT
8351    IMAGE_SUBJECT_REMARKS
16179   STILL_IMAGE
800000  NUMS
8       TEMP_ALLOW_CF_USER
10      TAXONOMY_ARCHIVE
11      USER_ROLES
1       VIEWER
*/

14188   ACCN
390     ADDR
12983   AGENT
37465   AGENT_NAME
80      AGENT_RELATIONS
1425077 ATTRIBUTES
2900    BIOL_INDIV_RELATIONS
697     BOOK
2810    BOOK_SECTION
1       BORROW
718187  CATALOGED_ITEM
2679    CITATION
216362  COLLECTING_EVENT
10      COLLECTION
53      COLLECTION_CONTACTS
846264  COLLECTOR
1722609 COLL_OBJECT
2668    COLL_OBJECT_ENCUMBRANCE
166405  COLL_OBJECT_REMARK
945981  COLL_OBJ_CONT_HIST
611941  COLL_OBJ_OTHER_ID_NUM
9308    COMMON_NAME
945984  CONTAINER
431     ELECTRONIC_ADDRESS
5       ENCUMBRANCE
2766    FIELD_NOTEBOOK_SECTION
349     FLUID_CONTAINER_HISTORY
4298    GEOG_AUTH_REC
193     GROUP_MEMBER
760947  IDENTIFICATION
760969  IDENTIFICATION_AGENT
766210  IDENTIFICATION_TAXONOMY
45933   IMAGE_OBJECT
101     JOURNAL
605     JOURNAL_ARTICLE
109002  LAT_LONG
433     LOAN
9695    LOAN_ITEM
114599  LOCALITY
8504    MEDIA
25506   MEDIA_LABELS
17006   MEDIA_RELATIONS
1724144 OBJECT_CONDITION
31487   PAGE
662     PERMIT
576     PERMIT_TRANS
12170   PERSON
281     PROJECT
579     PROJECT_AGENT
59      PROJECT_PUBLICATION
338     PROJECT_TRANS
4137    PUBLICATION
4404    PUBLICATION_AUTHOR_NAME
4       PUBLICATION_URL
393     SHIPMENT
946210  SPECIMEN_PART
17006   TAB_MEDIA_REL_FKEY
19805   TAXONOMY
798     TAXON_RELATIONS
14647   TRANS
44389   TRANS_AGENT


63      CF_BUGS
199     CF_CANNED_SEARCH
16      CF_CTUSER_ROLES
19883   CF_DATABASE_ACTIVITY
2340    CF_DOWNLOAD
407     CF_FORM_PERMISSIONS
220974  CF_LOG
90      CF_SPEC_RES_COLS
96      CF_TEMP_CITATION
33      CF_TEMP_OIDS
22      CF_TEMP_RELATIONS
759     CF_USERS
614     CF_USER_DATA
105888  CF_USER_LOG
206     CF_USER_ROLES


create table lam_pk_tables as select
distinct ucc.constraint_name, ucc.table_name, ucc.column_name, utc.data_type
from  user_cons_columns ucc, user_constraints uc, user_tab_cols utc
where ucc.constraint_name = uc.constraint_name
and ucc.table_name = uc.table_name
and uc.constraint_type = 'P'
and ucc.table_name = utc.table_name
and ucc.column_name = ucc.column_name
and utc.data_type = 'NUMBER';

alter table lam_pk_tables add rcount number;
alter table lam_pk_tables add min number;
alter table lam_pk_tables add max number;

declare
    ct number;
    mn number;
    mx number;
begin
for tn in (
    select table_name, column_name from lam_pk_tables
    where table_name in (
        select table_name from lam_pk_tables
        group by table_name
        having count(*) = 1)
    and data_type = 'NUMBER'
    order by table_name
) loop
    execute immediate 'select count(*) from ' || tn.table_name into ct;
    if ct > 0 then
        execute immediate 'select min(' || tn.column_name || ') from ' || tn.tab
le_name into mn;
        execute immediate 'select max(' || tn.column_name || ') from ' || tn.tab
le_name into mx;
        update lam_pk_tables set c = ct, min = mn, max = mx
        where table_name = tn.table_name;
        dbms_output.put_line(ct || chr(9) || mn || chr(9) || mx || chr(9) || tn.
table_name || '.' || tn.column_name);
    end if;
end loop;
/
