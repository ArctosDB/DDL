/*
select 'create public synonym ' || s.synonym_name || ' for ' || s.table_name || ';'
from all_synonyms s, dba_objects o
where s.table_owner = o.owner
and s.table_name = o.object_name
and s.table_owner = 'UAM'
and o.object_type = 'FUNCTION'
*/

create public synonym ALL_TAXON_NAMES for ALL_TAXON_NAMES;
create public synonym ATC for ATC;
create public synonym AUTHYEAR for AUTHYEAR;
create public synonym AY for AY;
create public synonym BUILDSCIENTIFICNAME for BUILDSCIENTIFICNAME;
create public synonym BULK_CHECK_ONE for BULK_CHECK_ONE;
create public synonym B_CONCATGEOLOGYATTRIBUTEDETAIL for B_CONCATGEOLOGYATTRIBUTEDETAIL;
create public synonym CHECKCONTAINERMOVEMENT for CHECKCONTAINERMOVEMENT;
create public synonym CONCATACCEPTEDIDENTIFYINGAGENT for CONCATACCEPTEDIDENTIFYINGAGENT;
create public synonym CONCATALLIDENTIFICATION for CONCATALLIDENTIFICATION;
create public synonym CONCATATTRIBUTE for CONCATATTRIBUTE;
create public synonym CONCATATTRIBUTEDETAIL for CONCATATTRIBUTEDETAIL;
create public synonym CONCATATTRIBUTEVALUE for CONCATATTRIBUTEVALUE;
create public synonym CONCATCOLL for CONCATCOLL;
create public synonym CONCATCOLLS for CONCATCOLLS;
create public synonym CONCATCOLLW_NUM for CONCATCOLLW_NUM;
create public synonym CONCATCOMMONNAME for CONCATCOMMONNAME;
create public synonym CONCATDARWINRELATIONS for CONCATDARWINRELATIONS;
create public synonym CONCATENCUMBRANCEDETAILS for CONCATENCUMBRANCEDETAILS;
create public synonym CONCATENCUMBRANCES for CONCATENCUMBRANCES;
create public synonym CONCATGENBANK for CONCATGENBANK;
create public synonym CONCATGEOLOGYATTRIBUTE for CONCATGEOLOGYATTRIBUTE;
create public synonym CONCATGEOLOGYATTRIBUTEDETAIL for CONCATGEOLOGYATTRIBUTEDETAIL;
create public synonym CONCATIDAGENT for CONCATIDAGENT;
create public synonym CONCATIDENTIFIERS for CONCATIDENTIFIERS;
create public synonym CONCATIDENTIFYINGAGENT for CONCATIDENTIFYINGAGENT;
create public synonym CONCATIDRBYIDID for CONCATIDRBYIDID;
create public synonym CONCATIMAGEURL for CONCATIMAGEURL;
create public synonym CONCATNAME for CONCATNAME;
create public synonym CONCATORIGLAT for CONCATORIGLAT;
create public synonym CONCATORIGLATLONG for CONCATORIGLATLONG;
create public synonym CONCATOTHERID for CONCATOTHERID;
create public synonym CONCATOTHERIDFILT for CONCATOTHERIDFILT;
create public synonym CONCATPARTNAME for CONCATPARTNAME;
create public synonym CONCATPARTS for CONCATPARTS;
create public synonym CONCATPARTSDETAIL for CONCATPARTSDETAIL;
create public synonym CONCATPARTSWITHLOC for CONCATPARTSWITHLOC;
create public synonym CONCATPREP for CONCATPREP;
create public synonym CONCATPROJAGENT for CONCATPROJAGENT;
create public synonym CONCATRELATIONS for CONCATRELATIONS;
create public synonym CONCATSEX for CONCATSEX;
create public synonym CONCATSINGLEOTHERID for CONCATSINGLEOTHERID;
create public synonym CONCATSINGLEOTHERIDINT for CONCATSINGLEOTHERIDINT;
create public synonym CONCATSTRING for CONCATSTRING;
create public synonym CONCATTHIS for CONCATTHIS;
create public synonym CONCATTRANSAGENT for CONCATTRANSAGENT;
create public synonym CONCATTYPESTATUS for CONCATTYPESTATUS;
create public synonym CONCAT_LIST for CONCAT_LIST;
create public synonym CP for CP;
create public synonym CVSDATA for CVSDATA;
create public synonym GETJSONMEDIAURIBYSPECIMEN for GETJSONMEDIAURIBYSPECIMEN;
create public synonym GETLABELNAME for GETLABELNAME;
create public synonym GETMEDIABYSPECIMEN for GETMEDIABYSPECIMEN;
create public synonym GETTAXA for GETTAXA;
create public synonym GET_ADDRESS for GET_ADDRESS;
create public synonym GET_CONTAINER_BARCODE for GET_CONTAINER_BARCODE;
create public synonym GET_MEDIA_RELATIONS_STRING for GET_MEDIA_RELATIONS_STRING;
create public synonym GET_SCIENTIFIC_NAME_AUTHS for GET_SCIENTIFIC_NAME_AUTHS;
create public synonym GET_STR_EL for GET_STR_EL;
create public synonym GET_TAXONOMY for GET_TAXONOMY;
create public synonym ISDATE for ISDATE;
create public synonym ISNUMERIC for ISNUMERIC;
create public synonym IS_NUMBER for IS_NUMBER;
create public synonym IS_POSITIVE_NUMBER for IS_POSITIVE_NUMBER;
create public synonym MEDIA_RELATION_SUMMARY for MEDIA_RELATION_SUMMARY;
create public synonym NICEURL for NICEURL;
create public synonym NICEURLNUMBERS for NICEURLNUMBERS;
create public synonym P for P;
create public synonym Q_MEDIA_RELATIONS for Q_MEDIA_RELATIONS;
create public synonym STDMAMMMEAS for STDMAMMMEAS;
create public synonym STRINGAGG for STRINGAGG;
create public synonym TO_DATE2 for TO_DATE2;
create public synonym TO_METERS for TO_METERS;
create public synonym TRANSPOSE for TRANSPOSE;
