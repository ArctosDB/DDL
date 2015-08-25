-- ACCN --> trans --> collection
--
-- where a.transaction_id = t.transaction_id
-- and t.collection_id in SYSCONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'ACCN'
        ,policy_name => 'ACCN_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_TID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- ADDR --> none

-- AGENT --> none

-- AGENT_NAME --> none

-- AGENT_RELATIONS --> none

-- ELECTRONIC_ADDRESS --> none

-- GROUP_MEMBER --> none

-- PERSON --> none

-- ALA_PLANT_IMAGING --> none

-- ATTRIBUTES --> cataloged_item --> collection
--
-- where a.collection_object_id = ci.collection_object_id
-- and ci.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'ATTRIBUTES'
        ,policy_name => 'ATTRIBUTES_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_COID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- BINARY_OBJECT --> going away - no need to develop formal policies

-- BIOL_INDIV_RELATIONS --> cataloged_item --> collection
--
-- SPECIAL NOTE: related individuals may be in different collections, and
-- we may therefore need very open INSERT roles, or ?????
-- This can be explored later if need be - initial policy will be collection-specific control.
--
-- where bir.collection_object_id = ci.collection_object_id
-- and ci.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'BIOL_INDIV_RELATIONS'
        ,policy_name => 'BIOLINDIVRELN_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_COID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- BOOK --> none

-- BOOK_SECTION --> none

-- BORROW --> trans --> collection
--
-- where b.transaction_id = t.transaction_id
-- and t.collection_id in SYSCONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'BORROW'
        ,policy_name => 'BORROW_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_TID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- BULKLOADER --> already controlled by data entry groups. That needs revised to use DB roles, but not immediately

-- CATALOGED_ITEM --> collection
--
-- where ci.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'CATALOGED_ITEM'
        ,policy_name => 'CATITEM_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_CID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- CCT_* tables --> none

-- CF_* tables --> none

-- CITATION --> cataloged_item --> collection
--
-- where c.collection_object_id = ci.collection_object_id
-- and ci.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'CITATION'
        ,policy_name => 'CITATION_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_COID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- COLLECTING_EVENT --> cataloged_item --> collection
--
-- where ce.collecting_event_id = ci.collecting_event_id 
-- and ci.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'COLLECTING_EVENT'
        ,policy_name => 'COLLEVENT_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_CEID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- COLLECTION -- durrrr.....
--
-- where c.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'COLLECTION'
        ,policy_name => 'COLLECTION_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_CID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- COLLECTION_CONTACTS --> collection
--
-- where cc.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'COLLECTION_CONTACTS'
        ,policy_name => 'COLLCONTACTS_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_CID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- COLLECTOR --> cataloged_item --> collection
--
-- where c.collection_object_id = ci.collection_object_id
-- and ci.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'COLLECTOR'
        ,policy_name => 'COLLECTOR_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_COID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- COLL_OBJECT
--
-->cataloged_item-->collection
-- union
-->specimen_part-->cataloged_item-->collection
--
-- where (
--    co.collection_object_id = ci.collection_object_id
--    and ci.collection_id in VPD_CONTEXT)
-- or (
--    co.collection_object_id = sp.collection_object_id
--    and sp.derived_from_cat_item = ci.collection_object_id
--    and ci.collection_id in VPD_CONTEXT)
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'COLL_OBJECT'
        ,policy_name => 'COLLOBJ_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_CICOID_SPCOID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- COLL_OBJECT_ENCUMBRANCE --> cataloged_item --> collection
--
-- where coe.collection_object_id = ci.collection_object_id
-- and ci.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'COLL_OBJECT_ENCUMBRANCE'
        ,policy_name => 'COLLOBJENC_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_COID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- COLL_OBJECT_REMARK --> cataloged_item --> collection
--
-- where cor.collection_object_id = ci.collection_object_id
-- and ci.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'COLL_OBJECT_REMARK'
        ,policy_name => 'COLLOBJREM_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_COID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- COLL_OBJ_CONT_HIST --> cataloged_item --> collection
--
-- where coch.collection_object_id = ci.collection_object_id
-- and ci.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'COLL_OBJ_CONT_HIST'
        ,policy_name => 'COLLOBJCONTHIST_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_COID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- COLL_OBJ_OTHER_ID_NUM --> cataloged_item--> collection
--
-- where cooidn.collection_object_id = ci.collection_object_id
-- and ci.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'COLL_OBJ_OTHER_ID_NUM'
        ,policy_name => 'COLLOBJCOTHIDNUM_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_COID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- COMMON_NAME --> none

-- CONTAINER --> none - will need policies later

-- CT* tables --> none

-- CT_ATTRIBUTE_CODE_TABLES --> none

-- DGR_LOCATOR --> none; already cntrolled by restrictive role

-- OR
-- MSB_*

ENCUMBRANCE --> coll_object_encumbrance --> cataloged_item --> collection
--
-- where e.encumbrance_id = coe.encumbrance_id
-- and coe.collection_object_id = ci.collection_object_id
-- and ci.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'ENCUMBRANCE'
        ,policy_name => 'ENCUMBRANCE_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_EID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- FIELD_NOTEBOOK_SECTION --> none? 

-- FLAT --> none

-- FLUID_CONTAINER_HISTORY --> none

-- GEOG_AUTH_REC --> none

-- GEOLOGY_ATTRIBUTES --> collecting_event ---> cataloged_item --> collection
--
-- where ga.locality_id = ce.locality_id
-- and ce.collecting_event_id = ci.collecting_event_id
-- and ci.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'GEOLOGY_ATTRIBUTES '
        ,policy_name => 'GEOLATTR_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_LID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

GEOLOGY_ATTRIBUTE_HIERARCHY --> geology_attributes --> collecting_event --> cataloged_item --> collection
--
-- where gah.attribute = ga.geology_attribute
-- and ga.locality_id = ce.locality_id
-- and ce.collecting_event_id = ci.collecting_event_id
-- and ci.collection_id in VPD_CONTEXT

-- IDENTIFICATION
-->cataloged_item-->collection
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'IDENTIFICATION'
        ,policy_name => 'IDENTIFICATION_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_COID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- IDENTIFICATION_AGENT --> identification --> cataloged_item --> collection
--
-- where ia.identification_id = i.identification_id
-- and i.collection_object_id = ci.collection_object_id
-- and ci.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'IDENTIFICATION_AGENT'
        ,policy_name => 'IDAGENT_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_IID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

--IDENTIFICATION_TAXONOMY --> identification --> cataloged_item --> collection
--
-- where it.identification_id = i.identification_id
-- and i.collection_object_id = ci.collection_object_id
-- and ci.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'IDENTIFICATION_TAXONOMY'
        ,policy_name => 'IDTAXON_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_IID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- JOURNAL --> none

-- JOURNAL_ARTICLE --> none

-- LAT_LONG --> collecting_event --> cataloged_item --> collection
--
-- where ll.locality_id = ce.locality_id
-- and ce.collecting_event_id = ci.collecting_event_id
-- and ci.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'LAT_LONG'
        ,policy_name => 'LATLONG_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_LID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- LOAN --> trans --> collection
--
-- where l.transaction_id = t.transaction_id
-- and t.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'LOAN'
        ,policy_name => 'LOAN_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_TID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- LOAN_INSTALLMENT --> trans --> collection
--
-- where li.transaction_id = t.transaction_id
-- and t.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'LOAN_INSTALLMENT'
        ,policy_name => 'LOANINSTALL_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_TID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- LOAN_ITEM --> trans --> collection
--
-- where li.transaction_id = t.transaction_id
-- and t.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'LOAN_ITEM'
        ,policy_name => 'LOANITEM_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_TID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- LOAN_REQUEST --> none

-- LOCALITY --> collecting_event --> cataloged_item --> collection
--
-- where l.locality_id = ce.locality_id
-- and ce.collecting_event_id = ci.collecting_event_id
-- and ci.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'LOCALITY'
        ,policy_name => 'LOCALITY_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_LID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- OBJECT_CONDITION --> coll_object --> specimen_part --> cataloged_item --> collection
--
-- where (
--    oc.collection_object_id = ci.collection_object_id
--    and ci.collection_id in VPD_CONTEXT)
-- or (
--    oc.collection_object_id = sp.collection_object_id
--    and sp.derived_from_cat_item = ci.collection_object_id
--    and ci.collection_id in VPD_CONTEXT)
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'OBJECT_CONDITION'
        ,policy_name => 'OBJCOND_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_CICOID_SPCOID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- PERMIT --> permit_trans --> trans --> collection
-- where p.permit_id = pt.permit_id
-- and pt.transaction_id = t.transaction_id
-- and t.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'PERMIT'
        ,policy_name => 'PERMIT_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_PERMID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- PERMIT_TRANS --> trans--> collection
--
-- where pt.transaction_id = t.transaction_id
-- and t.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'PERMIT_TRANS'
        ,policy_name => 'PERMITTRANS_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_TID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- PROJECT --> project_trans --> trans --> collection
--
-- where p.project_id = pt.project_id
-- and pt.transaction_id = t.transaction_id
-- and t.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'PROJECT'
        ,policy_name => 'PROJECT_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_PROJID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- PROJECT_AGENT --> project_trans --> trans --> collection
-- 
-- where pa.project_id = pt.project_id
-- and pt.transaction_id = t.transaction_id
-- and t.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'PROJECT_AGENT'
        ,policy_name => 'PROJAGENT_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_PROJID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- PROJECT_PUBLICATION --> project_trans --> trans --> collection
--
-- where pp.project_id = pt.project_id
-- and pt.transaction_id = t.transaction_id
-- and t.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'PROJECT_TRANS'
        ,policy_name => 'PROJTRANS_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_PROJID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- PROJECT_SPONSOR --> project_trans --> trans --> collection
--
-- where ps.project_id = pt.project_id
-- and pt.transaction_id = t.transaction_id
-- and t.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'PROJECT_SPONSOR'
        ,policy_name => 'PROJSPONSOR_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_PROJID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- PROJECT_TRANS --> trans --> collection
--
-- where pt.transaction_id = t.transaction_id
-- and t.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'PROJECT_TRANS'
        ,policy_name => 'PROJTRANS_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_TID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- PUBLICATION --> citation --> cataloged_item --> collection
--
-- where p.publication_id = c.publication_id
-- and c.collection_object_id = ci.collection_object_id
-- and ci.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'PUBLICATION'
        ,policy_name => 'PUBLICATION_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_PUBLID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- PUBLICATION_AUTHOR_NAME --> citation --> cataloged_item --> collection
--
-- where pan.publication_id = c.publication_id
-- and c.collection_object_id = ci.collection_object_id
-- and ci.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'PUBLICATION_AUTHOR_NAME'
        ,policy_name => 'PUBAUTHNAME_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_PUBLID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- PUBLICATION_URL --> citation --> cataloged_item --> collection
--
-- where pu.publication_id = c.publication_id
-- and c.collection_object_id = ci.collection_object_id
-- and ci.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'PUBLICATION_URL'
        ,policy_name => 'PUBURL_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_PUBLID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- SHIPMENT --> trans --> collection
--
-- where s.transaction_id = t.transaction_id
-- and t.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'SHIPMENT'
        ,policy_name => 'SHIPMENT_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_TID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- SPECIMEN_ANNOTATIONS --> cataloged_item --> collection
--
-- where sa.collection_object_id = ci.collection_object_id
-- and ci.collection_id = VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'SPECIMEN_ANNOTATIONS'
        ,policy_name => 'SPECANNO_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_COID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- SPECIMEN_PART --> cataloged_item --> collection
--
-- where sp.derived_from_cat_item = ci.collection_object_id
-- and ci.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'SPECIMEN_PART'
        ,policy_name => 'SPECPART_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_DFCI_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- TAXONOMY --> none

-- TAXON_RELATIONS --> none

-- TRANS --> collection
--
-- where t.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'TRANS'
        ,policy_name => 'TRANS_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_CID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- TRANS_AGENT --> trans --> collection
--
-- where ta.transaction_id = t.transaction_id
-- and t.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'TRANS_AGENT'
        ,policy_name => 'TRANSAGENT_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_TID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

-- VESSEL --> collecting_event --> cataloged_item --> collection
--
-- where v.collecting_event_id = ci.collecting_event_id
-- and ci.collection_id in VPD_CONTEXT
--
BEGIN
    DBMS_RLS.ADD_POLICY(
         object_schema => 'UAM'
        ,object_name => 'VESSEL'
        ,policy_name => 'VESSEL_SIUD_POL'
        ,function_schema => 'SYS'
        ,policy_function=> 'APP_SECURITY_CONTEXT.SET_CEID_PRED'
        ,statement_types => 'SELECT,INSERT,UPDATE,DELETE'
        ,policy_type => DBMS_RLS.CONTEXT_SENSITIVE
    );
END;
/

1,2,3,4,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27

biol_indiv_relations: how to handle related specimens that are in different collections?

-- where a.transaction_id = t.transaction_id
-- and t.collection_id in SYSCONTEXT

-- where bir.collection_object_id = ci.collection_object_id
-- and ci.collection_id in VPD_CONTEXT

-- where ci.collection_id in VPD_CONTEXT

-- where ce.collecting_event_id = ci.collecting_event_id 
-- and ci.collection_id in VPD_CONTEXT

-- where e.encumbrance_id = coe.encumbrance_id
-- and coe.collection_object_id = ci.collection_object_id
-- and ci.collection_id in VPD_CONTEXT

-- where ga.locality_id = ce.locality_id
-- and ce.collecting_event_id = ci.collecting_event_id
-- and ci.collection_id in VPD_CONTEXT

-- where ia.identification_id = i.identification_id
-- and i.collection_object_id = ci.collection_object_id
-- and ci.collection_id in VPD_CONTEXT



-- NOTES:
-- BULKLOADER --> already controlled by data entry groups.
-- That needs revised to use DB roles, but not immediately
/* Data Entry Stuff

Role data_entry:
INSERT into Bulkoader
DELETE own records
UPDATE own records
SELECT own records

manage_collection:
UPDATE, DELETE, SELECT all records entered by members of own collection role

Example:
user A: uam_mamm, data_entry roles
-- create UAM MAMM records
-- update,delete,select anything with entered_by=A
-- cannot change LOADED to NULL (trigger)
user B: uam_mamm, mange_collection
-- do anything to user A's records

for select, update, delete
if role = 'DATA_ENTRY' then
	predicate := 'entered_by = username';
else
	predicate := '1 = 2';
end if;

for insert
if role = 'DATA_ENTRY' then
	predicate := 'institution_acronym || '_' || collection_cde in (SYS_CONTEXT('VPD_CONTEXT','ROLE_LIST'));
else
	predicate := '1 = 2';
end if;
*/
--biol_indiv_relations: how to handle related specimens that are in different collections?
