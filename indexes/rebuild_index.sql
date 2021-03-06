-- 16 feb 09: more dlm additions
CREATE INDEX ix_media_rel_created_agnt ON media_relations(created_by_agent_id) TABLESPACE uam_idx_1;

CREATE INDEX ix_media_lbl_asgnd_agnt ON media_labels(ASSIGNED_BY_AGENT_ID) TABLESPACE uam_idx_1;


-- 2 Oct 2008: DLM additions to make SpecimenDetail_body.cfm faster (we hope)
    CREATE INDEX ix_accepted_id_fg ON identification(accepted_id_fg) TABLESPACE uam_idx_1;
    CREATE INDEX ix_biol_indiv_cat_itm ON biol_indiv_relations (collection_object_id) TABLESPACE uam_idx_1;
-- /DLM

-- DLM 30 Jan 2009: these seem to improve performance of taxonomy query view drastically
create index u_id_sci_name on identification (upper(scientific_name)) tablespace uam_idx_1;

create index u_tax_sci_name on taxonomy (upper(scientific_name)) tablespace uam_idx_1;
create index u_tax_full_name on taxonomy (upper(full_taxon_name)) tablespace uam_idx_1;

create index u_common_name on common_name (upper(common_name)) tablespace uam_idx_1;

create index u_verb_loc on collecting_event (upper(verbatim_locality)) tablespace uam_idx_1;
--NOT upper so die
DROP INDEX U_HIGHER_GEOG;
CREATE INDEX U_HIGHER_GEOG ON GEOG_AUTH_REC (upper(HIGHER_GEOG)) TABLESPACE UAM_IDX_1;

CREATE INDEX U_flat_part ON flat (upper(parts)) TABLESPACE UAM_IDX_1;
CREATE INDEX U_flat_typestatus ON flat (upper(typestatus)) TABLESPACE UAM_IDX_1;
CREATE INDEX flat_beg_year ON flat (TO_NUMBER(TO_CHAR(BEGAN_DATE,'yyyy'))) TABLESPACE UAM_IDX_1;
CREATE INDEX flat_end_year ON flat (TO_NUMBER(TO_CHAR(ENDED_DATE,'yyyy'))) TABLESPACE UAM_IDX_1;

ANALYZE TABLE common_name COMPUTE STATISTICS;
ANALYZE TABLE taxonomy COMPUTE STATISTICS;
ANALYZE TABLE identification COMPUTE STATISTICS;
---- thats all
SELECT index_name FROM user_indexes WHERE tablespace_name = 'UAM_DAT_1';

BEGIN
    FOR idxn IN (
        SELECT index_name 
        FROM user_indexes 
        WHERE tablespace_name = 'UAM_DAT_1'
        AND index_name NOT LIKE 'SYS%')
    LOOP
        EXECUTE IMMEDIATE 'alter index ' || idxn.index_name || ' rebuild tablespace "UAM_IDX_1"';                                                              
        dbms_output.put_line('alter index ' || idxn.index_name || ' rebuild tablespace "UAM_IDX_1"');
    END LOOP;
END;
 
/* alters in mvzlprod
ALTER INDEX PKEY_CONTAINER_CHECK REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX PK_COLL_OBJ_OTHER_ID_NUM REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX COLLOBJOTHERIDNUM_COLLOBJID REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX SYS_C0013687 REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX ACCN_COLLECTOR_PKEY REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX ACCN_COLLECTOR_AGENT_ID_IDX REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX ACCN_COLLECTOR_TRANS_ID_IDX REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX ATT_DETERMINER REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX XPKBINARY_OBJECT REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX XIF633BINARY_OBJECT REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_FULL_URL REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX BIOL_INDIV_PKEY REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX BIRD_PKEY REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX BIRD_ASSOC_EGG_NEST_ID_IDX REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX BL_PKEY REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX CATALOGED_ITEM_IDX2 REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX IDX$$_01250001 REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX PKEY_CDATA REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_CF_CANNED_SEARCH REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX PKEY_CF_CANNED_SEARCH REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX SAME_CF_CANNED_SEARCH REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX CF_TEMP_ATTRIBUTES_PKEY REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX UUSERNAME REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX CF_VERSION_PKEY REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX CF_VERSION_LOG_PKEY REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX PKEY_CGLOBAL REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX CGLOBAL_DATE REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX COLLECTING_EVENT_IDX3 REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX PKEYCOLLCONTACT REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX CONT_PRINT_FG REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_BARCODE REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX FLAT_COLLECTION_ID REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX DEV_TASK_PKEY REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX ENC_ACTION REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX PKEY_FLAT REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_HIGHER_GEOG REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX XPKIDENTIFICATION_TAXONOMY REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX XIF646IDENTIFICATION_TAXONOMY REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX XIF650IDENTIFICATION_TAXONOMY REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX LAT_LONG_DEC_LAT REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX LAT_LONG_DEC_LONG REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX LAT_LONG_DEC_ALL REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX SYS_IL0000053287C00036$$ REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX SYS_C006461 REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX SYS_C006462 REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX SYS_C006464 REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_FLAT_HIGHER_GEOG REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX REFSET_NG_PKEY REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX ROI_NG_PKEY REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX ROI_VALUE_NG_PKEY REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_STRING_SERIES_NAME REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX FULL_TAX_NAME REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX FLAT_CAT_NUM REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX FLAT_BEGAN_DATE REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX FLAT_COLLECTORS REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX PK_COMMON_NAME REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_CT_FEATURE REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_CT_WEIGHT_UNITS REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_FLAT_SCIENTIFIC_NAME REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX IDX$$_0DE40001 REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX SYS_C0014491 REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_TAX_SCI_NAME REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_FLAT_SPEC_LOCALITY REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX UPPERSCINAME REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX UIDX_ACCN_ACCN_NUMBER REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_FLAT_COUNTRY REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_FLAT_STATE_PROV REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_FLAT_COUNTY REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_FLAT_FEATURE REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_FLAT_ISLAND REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_FLAT_ISLAND_GROUP REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_FLAT_QUAD REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_FLAT_SEA REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_FLAT_CONTINENT_OCEAN REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX FLAT_ENDED_DATE REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX PK_CF_SPEC_RES_COLS REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX PK_COLL_OBJ_OTHER_ID_NUM_ID REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX TRANS_AGENT_PKEY REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_TRANS_AGENT REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX USER_ROLE_KEY REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX PK_GEOLOGY_ATTRIBUTES REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX PK_GEOLOGY_ATTRIBUTE_HIERARCHY REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX PK_OBJECT_CONDITION REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX U_OBJECT_CONDITION REBUILD TABLESPACE "UAM_IDX_1";
ALTER INDEX I_PART_NAME REBUILD TABLESPACE "UAM_IDX_1";
*/
