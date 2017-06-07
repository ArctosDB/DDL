-- first AS SYS:
  -- SYS@ARCTOSTE> grant delete on sys.aud$ to uam;



CREATE OR REPLACE PROCEDURE PRUNE_AUDIT_LOGS IS
	begin
		delete from sys.aud$ where NTIMESTAMP# < sysdate-90;
		delete from arctos_audit where TIMESTAMP < sysdate-90;
	end;
/

sho err;

	

BEGIN
DBMS_SCHEDULER.DROP_JOB('J_PRUNE_AUDIT_LOGS');
END;
/



BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_PRUNE_AUDIT_LOGS',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'PRUNE_AUDIT_LOGS',
    enabled     => TRUE
  );
END;
/ 

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_PRUNE_AUDIT_LOGS',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'PRUNE_AUDIT_LOGS',
    enabled     => TRUE,
    end_date    => NULL,
    start_date  =>  SYSTIMESTAMP,
	repeat_interval	=> 'freq=daily;'
  );
END;
/ 

select STATE,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_PRUNE_AUDIT_LOGS';



select count(*) from arctos_audit;



UAM@ARCTOSTE> select * from dba_extents where SEGMENT_NAME='BULKLOADER';



desc all_tables;

select distinct owner from all_tables order by owner;

UAM@ARCTOSTE> select distinct owner from all_tables order by owner;



select 'drop table cumv.' || table_name || ';' from all_tables where OWNER='CUMV';

drop table cumv.CATALOGSERIES;
drop table cumv.CATALOGSERIESDEFINITION;
drop table cumv.COLLECTION;
drop table cumv.COLLECTIONOBJECT;
drop table cumv.COLLECTIONOBJECTCATALOG;
drop table cumv.COLLECTIONOBJECTTYPE;
drop table cumv.DEACCESSIONAGENTS;
drop table cumv.DEACCESSIONCOLLECTIONOBJECT;
drop table cumv.GEOGRAPHY;
drop table cumv.GEOLOGICTIMEBOUNDARY;
drop table cumv.GEOLOGICTIMEPERIOD;
drop table cumv.LOANPHYSICALOBJECT;
drop table cumv.LOCALITY;
drop table cumv.OBSERVATION;
drop table cumv.PERMIT;
drop table cumv.SHIPMENT;
drop table cumv.TAXONNAME;
drop table cumv.TAXONOMICUNITTYPE;
drop table cumv.TAXONOMYTYPE;
drop table cumv.ACCESSION;
drop table cumv.COLLECTINGEVENT;
drop table cumv.COLLECTIONTAXONOMYTYPES;
drop table cumv.COLLECTORS;
drop table cumv.DETERMINATION;
drop table cumv.GROUPPERSONS;
drop table cumv.HABITAT;
drop table cumv.LOANRETURNPHYSICALOBJECT;
drop table cumv.PREPARATION;
drop table cumv.AGENT;
drop table cumv.DISTINCTGEOG;
drop table cumv.U_FULLTAXONAME;
drop table cumv.LOAN;
drop table cumv.LOANAGENTS;
drop table cumv.FTD;
drop table cumv.INVDATE;
drop table cumv.TEMP;
drop table cumv.CDATE;
drop table cumv.NAMEDPLACEVLOCALITYNAME;
drop table cumv.U_AGENT;
drop table cumv.ACCESSIONAGENTS;
drop table cumv.ACCESSIONAUTHORIZATIONS;
drop table cumv.ADDRESS;
drop table cumv.AGENTADDRESS;
drop table cumv.BIOLOGICALOBJECTATTRIBUTES;
drop table cumv.BIOLOGICALOBJECTRELATIONTYPE;
drop table cumv.BORROW;
drop table cumv.BORROWAGENTS;
drop table cumv.BORROWMATERIAL;
drop table cumv.BORROWSHIPMENTS;
drop table cumv.NEWTAXONOMY;
drop table cumv.TAX;
drop table cumv.WORKINGGEOG;
drop table cumv.GEOGSPECONLY;
drop table cumv.PARTS;
drop table cumv.UPART;
drop table cumv.MAMMAGECLASS;
drop table cumv.HERPELEVATION;
drop table cumv.DEACCESSION;
drop table cumv.STRATIGRAPHY;
drop table cumv.REPORTS;
drop table cumv.REFERENCEWORK;
drop table cumv.BORROWRETURNMATERIAL;
drop table cumv.AUTHORS;
drop table cumv.WEBADMIN;
drop table cumv.TAXONCITATION;
drop table cumv.SOUNDEVENTSTORAGE;
drop table cumv.SOUND;
drop table cumv.RAVEPROJECT;
drop table cumv.PROJECTCOLLECTIONOBJECTS;
drop table cumv.PROJECT;
drop table cumv.OTHERIDENTIFIER;
drop table cumv.LOCALITYCITATION;
drop table cumv.JOURNAL;
drop table cumv.IMAGELOCALITIES;
drop table cumv.IMAGECOLLECTIONOBJECTS;
drop table cumv.IMAGEAGENTS;
drop table cumv.IMAGE;
drop table cumv.EXCHANGEOUT;
drop table cumv.EXCHANGEIN;
drop table cumv.DTPROPERTIES;
drop table cumv.DETERMINATIONCITATION;
drop table cumv.DATAVIEWS;
drop table cumv.COLLECTIONOBJECTCITATION;
drop table cumv.BIOLOGICALOBJECTRELATION;






select 'drop table CUMVBIRD.' || table_name || ';' from all_tables where OWNER='CUMVBIRD';
drop table CUMVBIRD.HABITAT;
drop table CUMVBIRD.DETERMINATION_NODUPS;
drop table CUMVBIRD.LOANRETURNPHYSICALOBJECT;
drop table CUMVBIRD.PREPARATION;
drop table CUMVBIRD.TAXONOMYTYPE;
drop table CUMVBIRD.ACCESSION;
drop table CUMVBIRD.ACCESSIONAGENTS;
drop table CUMVBIRD.ACCESSIONAUTHORIZATIONS;
drop table CUMVBIRD.ADDRESS;
drop table CUMVBIRD.AGENT;
drop table CUMVBIRD.AGENTADDRESS;
drop table CUMVBIRD.BIOLOGICALOBJECTATTRIBUTES;
drop table CUMVBIRD.BIOLOGICALOBJECTRELATIONTYPE;
drop table CUMVBIRD.BORROW;
drop table CUMVBIRD.BORROWAGENTS;
drop table CUMVBIRD.BORROWMATERIAL;
drop table CUMVBIRD.BORROWSHIPMENTS;
drop table CUMVBIRD.CATALOGSERIES;
drop table CUMVBIRD.COLLECTIONOBJECT;
drop table CUMVBIRD.COLLECTIONOBJECTCATALOG;
drop table CUMVBIRD.COLLECTIONOBJECTTYPE;
drop table CUMVBIRD.DEACCESSIONAGENTS;
drop table CUMVBIRD.DEACCESSIONCOLLECTIONOBJECT;
drop table CUMVBIRD.GEOGRAPHY;
drop table CUMVBIRD.GEOLOGICTIMEBOUNDARY;
drop table CUMVBIRD.GEOLOGICTIMEPERIOD;
drop table CUMVBIRD.LOAN;
drop table CUMVBIRD.LOANAGENTS;
drop table CUMVBIRD.LOANPHYSICALOBJECT;
drop table CUMVBIRD.LOCALITY;
drop table CUMVBIRD.OBSERVATION;
drop table CUMVBIRD.PERMIT;
drop table CUMVBIRD.SHIPMENT;
drop table CUMVBIRD.TAXONNAME;
drop table CUMVBIRD.TAXONOMICUNITTYPE;
drop table CUMVBIRD.COLLECTINGEVENT;
drop table CUMVBIRD.COLLECTIONTAXONOMYTYPES;
drop table CUMVBIRD.COLLECTORS;
drop table CUMVBIRD.DEACCESSION;
drop table CUMVBIRD.DETERMINATION;
drop table CUMVBIRD.GROUPPERSONS;
drop table CUMVBIRD.CATALOGSERIESDEFINITION;
drop table CUMVBIRD.COLLECTION;





select 'drop table CUMVFISH.' || table_name || ';' from all_tables where OWNER='CUMVFISH';

drop table CUMVFISH.GEOLOGICTIMEPERIOD;
drop table CUMVFISH.DETERMINATION_NODUPS;
drop table CUMVFISH.PREPNUMS;
drop table CUMVFISH.DETERMINATION_REMDUPS;
drop table CUMVFISH.ACCESSION;
drop table CUMVFISH.ACCESSIONAGENTS;
drop table CUMVFISH.ACCESSIONAUTHORIZATIONS;
drop table CUMVFISH.ADDRESS;
drop table CUMVFISH.AGENT;
drop table CUMVFISH.AGENTADDRESS;
drop table CUMVFISH.BIOLOGICALOBJECTATTRIBUTES;
drop table CUMVFISH.BIOLOGICALOBJECTRELATIONTYPE;
drop table CUMVFISH.BORROW;
drop table CUMVFISH.BORROWAGENTS;
drop table CUMVFISH.BORROWMATERIAL;
drop table CUMVFISH.BORROWSHIPMENTS;
drop table CUMVFISH.CATALOGSERIES;
drop table CUMVFISH.CATALOGSERIESDEFINITION;
drop table CUMVFISH.COLLECTINGEVENT;
drop table CUMVFISH.COLLECTION;
drop table CUMVFISH.COLLECTIONOBJECT;
drop table CUMVFISH.COLLECTIONOBJECTCATALOG;
drop table CUMVFISH.COLLECTIONOBJECTTYPE;
drop table CUMVFISH.COLLECTIONTAXONOMYTYPES;
drop table CUMVFISH.COLLECTORS;
drop table CUMVFISH.DEACCESSION;
drop table CUMVFISH.DEACCESSIONAGENTS;
drop table CUMVFISH.DEACCESSIONCOLLECTIONOBJECT;
drop table CUMVFISH.DETERMINATION;
drop table CUMVFISH.GEOGRAPHY;
drop table CUMVFISH.GEOLOGICTIMEBOUNDARY;
drop table CUMVFISH.LOANPHYSICALOBJECT;
drop table CUMVFISH.LOANRETURNPHYSICALOBJECT;
drop table CUMVFISH.LOCALITY;
drop table CUMVFISH.OBSERVATION;
drop table CUMVFISH.PERMIT;
drop table CUMVFISH.PREPARATION;
drop table CUMVFISH.SHIPMENT;
drop table CUMVFISH.TAXONNAME;
drop table CUMVFISH.TAXONOMICUNITTYPE;
drop table CUMVFISH.TAXONOMYTYPE;
drop table CUMVFISH.LOAN;
drop table CUMVFISH.LOANAGENTS;
drop table CUMVFISH.GROUPPERSONS;
drop table CUMVFISH.HABITAT;





select 'drop table CUMVHERP.' || table_name || ';' from all_tables where OWNER='CUMVHERP';

drop table CUMVHERP.DETERMINATION_NODUPS;
drop table CUMVHERP.COLLECTIONTAXONOMYTYPES;
drop table CUMVHERP.COLLECTORS;
drop table CUMVHERP.DEACCESSION;
drop table CUMVHERP.DEACCESSIONAGENTS;
drop table CUMVHERP.DEACCESSIONCOLLECTIONOBJECT;
drop table CUMVHERP.DETERMINATION;
drop table CUMVHERP.GEOGRAPHY;
drop table CUMVHERP.GEOLOGICTIMEBOUNDARY;
drop table CUMVHERP.GEOLOGICTIMEPERIOD;
drop table CUMVHERP.GROUPPERSONS;
drop table CUMVHERP.HABITAT;
drop table CUMVHERP.LOAN;
drop table CUMVHERP.LOANAGENTS;
drop table CUMVHERP.LOANPHYSICALOBJECT;
drop table CUMVHERP.LOANRETURNPHYSICALOBJECT;
drop table CUMVHERP.LOCALITY;
drop table CUMVHERP.OBSERVATION;
drop table CUMVHERP.PERMIT;
drop table CUMVHERP.PREPARATION;
drop table CUMVHERP.SHIPMENT;
drop table CUMVHERP.TAXONNAME;
drop table CUMVHERP.TAXONOMICUNITTYPE;
drop table CUMVHERP.TAXONOMYTYPE;
drop table CUMVHERP.COLLECTIONOBJECTCATALOG;
drop table CUMVHERP.COLLECTIONOBJECTTYPE;
drop table CUMVHERP.ACCESSION;
drop table CUMVHERP.ACCESSIONAGENTS;
drop table CUMVHERP.ACCESSIONAUTHORIZATIONS;
drop table CUMVHERP.ADDRESS;
drop table CUMVHERP.AGENT;
drop table CUMVHERP.AGENTADDRESS;
drop table CUMVHERP.BIOLOGICALOBJECTATTRIBUTES;
drop table CUMVHERP.BIOLOGICALOBJECTRELATIONTYPE;
drop table CUMVHERP.BORROW;
drop table CUMVHERP.BORROWAGENTS;
drop table CUMVHERP.BORROWMATERIAL;
drop table CUMVHERP.BORROWSHIPMENTS;
drop table CUMVHERP.CATALOGSERIES;
drop table CUMVHERP.CATALOGSERIESDEFINITION;
drop table CUMVHERP.COLLECTINGEVENT;
drop table CUMVHERP.COLLECTION;
drop table CUMVHERP.COLLECTIONOBJECT;





select 'drop table CUMVMAMM.' || table_name || ';' from all_tables where OWNER='CUMVMAMM';

drop table CUMVMAMM.TAXONOMYTYPE;
drop table CUMVMAMM.DETERMINATION_NODUPS;
drop table CUMVMAMM.NO_ERROR_UNITS;
drop table CUMVMAMM.DEACCESSIONCOLLECTIONOBJECT;
drop table CUMVMAMM.DETERMINATION;
drop table CUMVMAMM.GEOGRAPHY;
drop table CUMVMAMM.GEOLOGICTIMEBOUNDARY;
drop table CUMVMAMM.GEOLOGICTIMEPERIOD;
drop table CUMVMAMM.GROUPPERSONS;
drop table CUMVMAMM.HABITAT;
drop table CUMVMAMM.LOAN;
drop table CUMVMAMM.LOANAGENTS;
drop table CUMVMAMM.LOANPHYSICALOBJECT;
drop table CUMVMAMM.LOANRETURNPHYSICALOBJECT;
drop table CUMVMAMM.LOCALITY;
drop table CUMVMAMM.OBSERVATION;
drop table CUMVMAMM.PERMIT;
drop table CUMVMAMM.PREPARATION;
drop table CUMVMAMM.SHIPMENT;
drop table CUMVMAMM.TAXONNAME;
drop table CUMVMAMM.TAXONOMICUNITTYPE;
drop table CUMVMAMM.BORROW;
drop table CUMVMAMM.BORROWAGENTS;
drop table CUMVMAMM.BORROWMATERIAL;
drop table CUMVMAMM.BORROWSHIPMENTS;
drop table CUMVMAMM.CATALOGSERIES;
drop table CUMVMAMM.CATALOGSERIESDEFINITION;
drop table CUMVMAMM.COLLECTINGEVENT;
drop table CUMVMAMM.COLLECTION;
drop table CUMVMAMM.COLLECTIONOBJECT;
drop table CUMVMAMM.COLLECTIONOBJECTCATALOG;
drop table CUMVMAMM.COLLECTIONOBJECTTYPE;
drop table CUMVMAMM.COLLECTIONTAXONOMYTYPES;
drop table CUMVMAMM.COLLECTORS;
drop table CUMVMAMM.DEACCESSION;
drop table CUMVMAMM.DEACCESSIONAGENTS;
drop table CUMVMAMM.BIOLOGICALOBJECTATTRIBUTES;
drop table CUMVMAMM.BIOLOGICALOBJECTRELATIONTYPE;
drop table CUMVMAMM.ACCESSION;
drop table CUMVMAMM.ACCESSIONAGENTS;
drop table CUMVMAMM.ACCESSIONAUTHORIZATIONS;
drop table CUMVMAMM.ADDRESS;
drop table CUMVMAMM.AGENT;
drop table CUMVMAMM.AGENTADDRESS;



select 'drop table DLM.' || table_name || ';' from all_tables where OWNER='DLM';


'DROPTABLEDLM.'||TABLE_NAME||';'
------------------------------------------------------------------------------------------------------------------------
drop table DLM.TEMP_32212;
drop table DLM.TEMP_76264;
drop table DLM.TEMP_43184;
drop table DLM.TEMP_19847;
drop table DLM.TEMP_30245;
drop table DLM.TEMP_12307;
drop table DLM.CITATION_20090410;
drop table DLM.MEDIA_20090410;
drop table DLM.OBJECT_CONDITION20090424;
drop table DLM.CONTAINER20090512;
drop table DLM.CONTAINER20090611;
drop table DLM.MEDIA_20090615;
drop table DLM.COLLECTING_EVENT20090701;
drop table DLM.PUBLICATION20090803;
drop table DLM.PUBLICATIONAUTHORNAME20090803;
drop table DLM.CTPUBLICATION_TYPE20090803;
drop table DLM.ALA_PLANT_IMAGING20100129;
drop table DLM.PROJTABLE1254705885900204;
drop table DLM.CATALOGED_ITEM20100909;
drop table DLM.TEMP2;
drop table DLM.TEMP3;
drop table DLM.TEMP;
drop table DLM.WTF2;
drop table DLM.WTF;

drop table DLM.MY_TEMP_CF;



UAM@ARCTOSTE> desc all_tables;
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 OWNER								   NOT NULL VARCHAR2(30)
 TABLE_NAME							   NOT NULL VARCHAR2(30)
 TABLESPACE_NAME							    VARCHAR2(30)
 CLUSTER_NAME								    VARCHAR2(30)





drop table temp_is_eating_space;

create table temp_is_eating_space as select OWNER,SEGMENT_NAME,SEGMENT_TYPE,sum(bytes) bytes from dba_extents group by OWNER,SEGMENT_NAME,SEGMENT_TYPE;

select SEGMENT_NAME || ' @ ' || bytes from temp_is_eating_space where SEGMENT_TYPE='TABLE' order by bytes;



-- clean up temp tables which are old and no longer needed

select OWNER || '.' || SEGMENT_NAME || ' @ ' || bytes from temp_is_eating_space where SEGMENT_TYPE='TABLE' and owner='UAM' order by SEGMENT_NAME;


drop table TAXON_TERM20161107;
drop table ARCTOS_AUDIT_2010;
drop table TEMP_SPACENAME;
drop table TAXONOMY_OLDNFLAT  CASCADE CONSTRAINTS;
drop table CONTAINER20150512;
drop table TEMP_ALL_ALA;
drop table TEMP_COLL_OBJECT_20160616;
drop table BAK_SPEC_EVENT;
drop table ATTRIBUTES20141028;
drop table IDENTIFICATION20160127;
drop table IDENTIFICATION20170111;
drop table CONTAINER20090512;
drop table CONTAINER20090611;
drop table ATTRIBUTES20131112;
drop table ATTRIBUTES_20120808;
drop table IDENTIFICATION20150209;
drop table IDENTIFICATION_20150723;
drop table UAM_ARC_ORIG;
drop table COLLECTOR20160127;
drop table IDENTIFICATION_20130801;
drop table COLL_OBJ_OTHER_ID_NUM20141022;
drop table CATALOGED_ITEM20160128;
drop table TT_TEMP_FLAT;
drop table OBJECT_CONDITION20090424;
drop table MSBFISH2;
drop table KNWR;
drop table TEMP_MSB_FISHES;
drop table TEMP_MSB_FISH;
drop table COLL_OBJ_OTHER_ID_NUM20130218;
drop table MEDIA_20150826;
drop table TEMP_FUNKY_TAXONOMY;
drop table COLL_OBJECT_REMARK20160127;
drop table CF_TEMP_CLASSIFICATION20170501;
drop table TEMP_CF_TEMP_CLASS20161103;
drop table CF_TEMP_CLASSIFICATION_161108;
drop table ACCN201510088;
drop table AFISH;
drop table AGENT_NAME20140318;
drop table ALACRYPT;
drop table ALA_AGENT_MAKETHESE;
drop table ALADNG;
drop table ALADUPS;
drop table ALA_SPEC_EVENT;
drop table ALA_TEMP;
drop table ALA_TEMP_AGENT;
drop table ALA_TEMP_GEOG;
drop table ALA_TEMP_PNC;
drop table ALA_TEMP_ORIG;
drop table ALL_USED_TABLES;
drop table ARC_ACCNAGNT;
drop table ARC_AGENT_MERGE;
drop table ARC_AGENT_ORG;
drop table ARC_AGENT_PERSON;
drop table ARC_AGENT_P_DUPS;
drop table ARC_AGNT_PERSON_NPS;
drop table ARC_CATALOGER;
drop table ARC_EXC;
drop table ARC_INV;
drop table ARC_LOWNR;
drop table ARC_PMT;
drop table ARC_PRJ;
drop table ARC_RC;
drop table ARC_U_AGENTMERGE;
drop table ARC_VIL;
drop table AREN;
drop table BAD_TAXONOMY;
drop table BAH;
drop table BAH2;
drop table BIOL_INDIV_RELATIONS20130218;
drop table BIRDPREPCOLL;
drop table BL_BAK;
drop table BOOGITY;
drop table BUGSWITHPARTIALAGE;
drop table BUGSWITHPARTIALSEX;
drop table BULKLOADER20131113;
drop table BULKLOADER_BAK20150727;
drop table CARLASJUNK;
drop table CBPREP;
drop table CF_CANNED_SEARCH20150325;
drop table CITATION20160201;
drop table CMISS;
drop table CN50;
drop table COA;
drop table COA_AGNT;
drop table COA_CC_AGNT;
drop table COA_UA;
drop table COA_U_AGNT_CC;
drop table COE_DGR_MSB_LKV;
drop table COE_BAK_LKV;
drop table COLLECTING_EVENT_OLD;
drop table COLLECTION_CONTACTS20161011;
drop table COLL_OBJECT_REMARK20120511;
drop table CUMVFISH_ACCN_TEMP;
drop table CUMVF_LOAN;
drop table CUMVF_LOAN_ITEM_DISTINCT;
drop table CUMVF_LOAN_ITEM;
drop table CUMVF_LOAN_ITEM_FPARTS;
drop table CUMVF_LOAN_ITEM_OLD;
drop table CUMVF_SPECIMEN_PART;
drop table CUMVF_TRANS;
drop table CUMVF_TRANS_AGENT;
drop table CUMVF_TRANS_AGENT_A;
drop table CUMVF_TRANS_AGENT_COPY;
drop table CUMVHERP_ACCN_TEMP;
drop table CUMVHERP_ERROR_AND_METHOD;
drop table CUMVMAMMLOANS;
drop table CUMVMAMM_ACCN_TEMP;
drop table CUMVMAMM_LA;
drop table CUMVMAMM_LA_U;
drop table CUMVMAMM_LP;
drop table CUMVMAMM_LP_U;
drop table CUMVMAMM_LT;
drop table CUMVTABLES;
drop table CUMV_ACCNROLE;
drop table CUMV_ACCNTYPE;
drop table CUMV_AGENTS_MISSES;
drop table CUMV_AGENTS_MISSES_BAK;
drop table CUMV_AGENT_REPATRIATION;
drop table CUMV_AGENT_REPATRIATION_BAK;
drop table CUMV_BIRD_ADDL_IDENTIFIERS;
drop table CUMV_BIRD_BULK;
drop table CUMV_BIRD_CLUTCHSIZE;
drop table CUMV_BIRD_COLL_PREP_BULK;
drop table CUMV_BIRD_LEFTOVERATTR;
drop table CUMV_BIRD_PARTS;
drop table CUMV_BIRD_PART_BULK;
drop table CUMV_BIRD_PART_BULK_LOADED;
drop table CUMV_BIRD_PREP;
drop table CUMV_BIRD_TID;
drop table CUMV_BPB;
drop table CUMV_C_GEOG;
drop table CUMV_C__ORIG_GEOG;
drop table CUMV_FISH_ADDL_IDENTIFIERS;
drop table CUMV_FISH_BULK;
drop table CUMV_FISH_BULKT2;
drop table CUMV_FISH_NDCE;
drop table CUMV_FISH_PARTS;
drop table CUMV_FISH_PARTS2;
drop table CUMV_FISH_PART_BULK2;
drop table CUMV_FISH_R_CURR_TSTAT;
drop table CUMV_FISH_R_DETERMINATIONS;
drop table CUMV_FISH_R_PREV_D_REM;
drop table CUMV_FISH_SPECIMEN_EVENT;
drop table CUMV_FISH_TID;
drop table CUMV_FISH_TID_LE;
drop table CUMV_FWC_L;
drop table CUMV_GEOGRAPHY_REPATRIATION;
drop table CUMV_HERP_ADDL_IDENTIFIERS;
drop table CUMV_HERP_BULK;
drop table CUMV_HERP_PARTPREP;
drop table CUMV_HERP_PARTS;
drop table CUMV_HERP_PARTSTT;
drop table CUMV_HERP_PART_BULK;
drop table CUMV_HERP_TID;
drop table CUMV_HERP_TID_LE;
drop table CUMV_H_ATTR_MISS;
drop table CUMV_H_A_GOTEM;
drop table CUMV_MAMM_BULK;
drop table CUMV_MAMM_BULKT2;
drop table CUMV_MAMM_BULK_OOPS;
drop table CUMV_MAMM_GRERR;
drop table CUMV_MAMM_LEFTOVERATTR;
drop table CUMV_MAMM_PARTS;
drop table CUMV_MAMM_PARTST2;
drop table CUMV_MAMM_PARTS_T2;
drop table CUMV_MAMM_PART_BULK;
drop table CUMV_MAMM_PREPARATOR;
drop table CUMV_MAMM_PART_BULK_DONE;
drop table CUMV_MAMM_PREPARATORS;
drop table CUMV_MAMM_PREPARATORS_U;
drop table CUMV_MAMM_TID;
drop table CUMV_NEWFISHDETERMS;
drop table CUMV_R_ACCNROLE;
drop table CUMV_R_ACCNTYPE;
drop table CUMV_R_AGENT;
drop table CUMV_R_BIRD_PART;
drop table CUMV_R_C_AGENT;
drop table CUMV_R_C_AGENTBAK;
drop table CUMV_R_C_AGENTBAK2;
drop table CUMV_R_C_AGENTBAKBAKBAK;
drop table CUMV_R_DATE;
drop table CUMV_R_FISH_PART;
drop table CUMV_R_GEOG;
drop table CUMV_R_HERPAGECLASS;
drop table CUMV_R_HERPELEVATION;
drop table CUMV_R_HERP_PART;
drop table CUMV_R_MAMMAGECLASS;
drop table CUMV_R_MAMM_PART;
drop table CUMV_R_PARTS;
drop table CUMV_R_TAXA;
drop table CUMV_R_U_AGENT;
drop table CUMV_R_U_BIRD_PART;
drop table CUMV_R_U_FISH_PART;
drop table CUMV_R_U_HERP_PART;
drop table CUMV_R_U_MAMMAGECLASS;
drop table CUMV_R_U_MAMM_GEOG;
drop table CUMV_R_U_MAMM_GEOG2;
drop table CUMV_R_U_MAMM_PART;
drop table CUMV_R_U_PART;
drop table CUMV_WRONGCONTINENT;
drop table C_H_LREM_LID;
drop table DBMS_SP;
drop table DMNS;
drop table DMNSA;
drop table DMNSINVTAX;
drop table DMNS_ARCTOS_HIGHERGEOG;
drop table DMNS_GEOG_SPLIT;
drop table DMNS_OLD;
drop table DMNS_TAX;
drop table DMNS_T_A;
drop table DMNS_UNIQUE_AGENT;
drop table DMNS_U_AGENT;
drop table DMNS_U_DATE;
drop table DMNS_U_GEOG;
drop table DMNS_U_SPECIES;
drop table DSC;
drop table DSBARCODE;
drop table DUPDET;
drop table ELECTRONIC_ADDRESS;
drop table EMNN_U;
drop table ENTHAB;
drop table ESM;
drop table EVENMORENEWNAMES;
drop table EVENTSPERBUGSP;
drop table FLAT_IS_BROKEN;
drop table FLUID_CONT_HIST20170425;
drop table FT2;
drop table FT1;
drop table FTEST;
drop table GONNAUPDATE;
drop table GORDON_TAXONOMY;
drop table GORDON_TAX_RELATIONS;
drop table GOTIT;
drop table G_B_MEDIA;
drop table G_B_MEDIA_LABEL;
drop table G_B_MEDIA_RELATIONS;
drop table HERP_PARTIAL_GEOREF_REJECT;
drop table IDENTIFICATION_AGENT_20150723;
drop table ID_OR_PUB_DATE_NULL;
drop table INARCTOSNOTINNEWTHING;
drop table KH;
drop table KNRWREL;
drop table ISO3166;
drop table KNWR2;
drop table KNWR3;
drop table LAT_LONG_OLD;
drop table LKVTEMP;
drop table LLM;
drop table LOAN20160127;
drop table LOCALITY_OLD;
drop table MAMMALS_4_LINK;
drop table MARIEL_BULK;
drop table MCZBIRD;
drop table MCZBIRD_ORIG;
drop table MEDIA_FIX_BAK;
drop table MEDIA_LABELS_LKV;
drop table MEDIA_LABLES_LKV;
drop table MEDIA_LKV_141007;
drop table MLZA;
drop table MLZAGENTFAIL;
drop table MLZBACK;
drop table MORECOAAGNT;
drop table MSBCIT;
drop table MSBDGRLOAN;
drop table MSBLBL;
drop table MVZ18;
drop table NCBITYPES;
drop table NEWGEO;
drop table NEWSPSSP;
drop table NOPRINT_LINEFEED;
drop table NONPRINTING;
drop table NOPRINT_LINEFEED;
drop table NULLCATNUM;
drop table OLD_DMNS;
drop table PROJECT20160127;
drop table PROJECT20161010;
drop table PUBLICATION20160127;
drop table RRSLIDES;
drop table SBOX;
drop table SCIT;
drop table SIKEBARCODE;
drop table SIKESAGENT;
drop table SIKESLOAN;
drop table SIKESTAX;
drop table SIKES_METHOD;
drop table SP;
drop table SSP;
drop table SSRCH_FIELD_DOC20170223;
drop table STATECOUNTRYCOLNPOINTS;
drop table STATECOUNTRYPOINTS;
drop table STATEPOINTS;
drop table SUBGENUS_NUKE;
drop table T;
drop table T1;
drop table T2;
drop table TAXONOMY_OLDNFLAT;
drop table T3;
drop table TAXON_TERM_ENTO;
drop table TAXON_TERM_ENTO_ORIG;
drop table TAXON_TERM_NCBI;
drop table TAXUPFAIL;



drop table tco_COLLECTION;
drop table tco_CATALOGED_ITEM;
drop table tco_ATTRIBUTES;
drop table tco_COLL_OBJ_OTHER_ID_NUM;
drop table tco_SPECIMEN_EVENT;
drop table tco_COLLECTING_EVENT;
drop table tco_LOCALITY;
drop table tco_GEOG_AUTH_REC;
drop table tco_CITATION;
drop table tco_PUBLICATION;
drop table tco_PUBLICATION_AGENT;
drop table tco_MEDIA_RELATIONS;
drop table tco_MEDIA;
drop table tco_MEDIA_LABELS;
drop table tco_IDENTIFICATION;
drop table tco_IDENTIFICATION_AGENT;
drop table tco_IDENTIFICATION_TAXONOMY;
drop table tco_TAXON_NAME;
drop table tco_TAXON_TERM;
drop table tco_TRANS;
drop table tco_TRANS_AGENT;
drop table tco_ACCN;
drop table tco_LOAN;
drop table tco_LOAN_ITEM;
drop table tco_BORROW;
drop table tco_SHIPMENT;
drop table tco_PERMIT_TRANS;
drop table tco_PERMIT;
drop table tco_PROJECT_TRANS;
drop table tco_PROJECT;
drop table tco_PROJECT_AGENT;
drop table tco_PROJECT_PUBLICATION;
drop table tco_COLLECTOR;
drop table tco_SPECIMEN_PART;
drop table tco_SPECIMEN_PART_ATTRIBUTE;
drop table tco_COLL_OBJECT;
drop table tco_COLL_OBJECT_REMARK;
drop table tco_OBJECT_CONDITION;
drop table tco_AGENT;
drop table tco_ADDRESS;
drop table tco_AGENT_NAME;
drop table tco_AGENT_RELATIONS;


drop table TCT;
drop table TEMP;
drop table TEMP2;
drop table TEMP22;
drop table TEMP3;
drop table TEMP4;
drop table TEMP5;
drop table TEMP_AA_DS_2;
drop table TEMP_501;
drop table TEMP_ABANDONED_MEDIA;
drop table TEMP_AGENT_ACTIVITY_DS;
drop table TEMP_ALA_DIST_ID;
drop table TEMP_ALA_MAP;
drop table TEMP_ALA_OTHERCOLLS;
drop table TEMP_ALG_AGENT;
drop table TEMP_ALG_ANNO;
drop table TEMP_ALG_GEOG;
drop table TEMP_ALG_IMG;
drop table TEMP_ALG_SPEC;
drop table TEMP_ALG_SPEC_ORIG;
drop table TEMP_ALG_SPLIT_AGENTS;
drop table TEMP_ALG_TAX;
drop table TEMP_ALG_TYPE;
drop table TEMP_ALL_BARCODE;
drop table TEMP_ALL_KWP_NMOERR_LOC;
drop table TEMP_ARCTAXNAME;
drop table TEMP_AP;
drop table TEMP_ARCTOS_TBL_LIST;
drop table TEMP_ARC_AGENT_LOOKUP;
drop table TEMP_ARC_ATTR2;
drop table TEMP_ARC_BACN;
drop table TEMP_ARC_CLTR_R;
drop table TEMP_ARC_CULTURE;
drop table TEMP_ARC_DUPCN;
drop table TEMP_ARC_DUP_CATNUM;
drop table TEMP_ARC_GRP;
drop table TEMP_ARC_NODUP;
drop table TEMP_ARC_NOID;
drop table TEMP_ARC_OOPS;
drop table TEMP_ARC_PART2;
drop table TEMP_ARC_PART2_LOAD;
drop table TEMP_ARC_PART_LEFTOVER;
drop table TEMP_ARC_PL;
drop table TEMP_ARC_PLC1;
drop table TEMP_ARC_PNAR;
drop table TEMP_ARC_PLOADED;
drop table TEMP_ARC_PRSN;
drop table TEMP_ARC_TAXA;
drop table TEMP_AREN_BL;
drop table TEMP_BIRD_COMMON;
drop table TEMP_BIRD_SSP;
drop table TEMP_BL_ID;
drop table TEMP_BUG2;
drop table TEMP_BUGS;
drop table TEMP_BUG_NEWGUID;
drop table TEMP_CAL;
drop table TEMP_CHAG_GEO_1028;
drop table TEMP_CHAS_AA;
drop table TEMP_CHAS_ACCN;
drop table TEMP_CHAS_ACCNCORFINAL;
drop table TEMP_CHAS_ACCN_AGNT;
drop table TEMP_CHAS_ACNDATE;
drop table TEMP_CHAS_ACNDATE_OUT;
drop table TEMP_CHAS_AGENT_NOTONEMATCH;
drop table TEMP_CHAS_AGENT_NOTONEMATCH_EK;
drop table TEMP_CHAS_AGENT_NP_9SEP;
drop table TEMP_CHAS_AGENT_NP_PREF;
drop table TEMP_CHAS_AGENT_NP_PREF2;
drop table TEMP_CHAS_AGENT_TEST;
drop table TEMP_CHAS_AGNT_AUG28;
drop table TEMP_CHAS_AGNT_AUG28_M;
drop table TEMP_CHAS_AGNT_EXP;
drop table TEMP_CHAS_AGNT_EXP_EK;
drop table TEMP_CHAS_AGNT_OCT02;
drop table TEMP_CHAS_AGNT_OCT05;
drop table TEMP_CHAS_AGNT_REMERGE;
drop table TEMP_CHAS_AGNT_REMERGE_U;
drop table TEMP_CHAS_AGNT_SEP02;
drop table TEMP_CHAS_AGNT_SEP08;
drop table TEMP_CHAS_AGNT_SEP08_NP;
drop table TEMP_CHAS_AGNT_SEP09;
drop table TEMP_CHAS_AGNT_SEP10;
drop table TEMP_CHAS_AGNT_SEP30;
drop table TEMP_CHAS_BIRD_OID;
drop table TEMP_CHAS_BIRD_ORIG;
drop table TEMP_CHAS_BIRD_PART;
drop table TEMP_CHAS_BIRD_PB;
drop table TEMP_CHAS_BULK_BIRD_BAK;
drop table TEMP_CHAS_EGG_FORBL;
drop table TEMP_CHAS_FISH;
drop table TEMP_CHAS_EGG_ORIG;
drop table TEMP_CHAS_FISH_ORIG;
drop table TEMP_CHAS_FORBULK;
drop table TEMP_CHAS_GEO2;
drop table TEMP_CHAS_GEOG_ORIGINAL;
drop table TEMP_CHAS_GEOG_WRK;
drop table TEMP_CHAS_GEO_LOOKUP_FINAL;
drop table TEMP_CHAS_GEO_REPAT;
drop table TEMP_CHAS_MAMM;
drop table TEMP_CHAS_NP_BL;
drop table TEMP_CHAS_PARTS;
drop table TEMP_CHAS_PB;
drop table TEMP_CHAS_P_FORSPLIT;
drop table TEMP_CHAS_SE_UP_ORIG;
drop table TEMP_CHAS_SPLITAGENT;
drop table TEMP_CHAS_TAX;
drop table TEMP_CHAS_TAX_U;
drop table TEMP_CHAS_TEMP_WRK;
drop table TEMP_CHAS_U_AGENT;
drop table TEMP_CITCFY;
drop table TEMP_CLASS_AN;
drop table TEMP_CLASS_AN_LOOKUP;
drop table TEMP_CLASS_AN_LOOKUP2;
drop table TEMP_CLASS_RTG;
drop table TEMP_CL_AUTH_NOGO;
drop table TEMP_CL_AUTH_WILLGO;
drop table TEMP_COLL_TISS_PART_COUNT;
drop table TEMP_COLL_TISS_PART_COUNT2;
drop table TEMP_COLL_TISS_PART_COUNT3;
drop table TEMP_COLL_TISS_PART_COUNT4;
drop table TEMP_CONFUSING_TAXONOMY;
drop table TEMP_CRAPTAXONOMY;
drop table TEMP_CUMVFISH_GEOG;
drop table TEMP_CUMV_FISH_G;
drop table TEMP_CUMV_FISH_GEO2;
drop table TEMP_CUMV_GEO_LKUP;
drop table TEMP_C_O_E;
drop table TEMP_C_O_L;
drop table TEMP_DESTATS;
drop table TEMP_DGRCHILD;
drop table TEMP_DIST_PARTS;
drop table TEMP_DIST_US_CO_COORD;
drop table TEMP_DL_UP;
drop table TEMP_DMC_ID_NOEXP;
drop table TEMP_DNAMETEST;
drop table TEMP_DNAME_DIFF;
drop table TEMP_DSN;
drop table TEMP_DSS_GATES_NOOPS;
drop table TEMP_DS_TAX;
drop table TEMP_ES_FOLDER;
drop table TEMP_ES_TOOSMALL;
drop table TEMP_EXPYR_ENC;
drop table TEMP_FISH_ORIG;
drop table TEMP_FUTUREDATE;
drop table TEMP_F_NC;
drop table TEMP_GDNERR;
drop table TEMP_GEOCOUNTY;
drop table TEMP_GEOCOUNTY_BAK;
drop table TEMP_GEOG_NOMATCH;
drop table TEMP_GEOLOOKUP;
drop table TEMP_GEOSTATE;
drop table TEMP_GEOSTATE_BAK;
drop table TEMP_GEO_NP;
drop table TEMP_GEO_WKT;
drop table TEMP_GEO_WKT_BAK;
drop table TEMP_GEO_WKT_BAK2;
drop table TEMP_GETMAKECE_FLDS;
drop table TEMP_HASAUTH;
drop table TEMP_HASAUTH_U;
drop table TEMP_ISMM;
drop table TEMP_IMG_MIGR;
drop table TEMP_JUNK_BARCODE;
drop table TEMP_ISO_CC;
drop table TEMP_K_C;
drop table TEMP_LI;
drop table TEMP_LICFY;
drop table TEMP_LOG_WEBQUERY;
drop table TEMP_LSRCH;
drop table TEMP_LSRCHSS;
drop table TEMP_MAMM_PARTS;
drop table TEMP_MIABIRD;
drop table TEMP_MIABIRD2;
drop table TEMP_MIANAME;
drop table TEMP_MISSEDH;
drop table TEMP_MKGEO;
drop table TEMP_MKGEOALL;
drop table TEMP_MKGEOMVZ;
drop table TEMP_MSBBC;
drop table TEMP_MSBC;
drop table TEMP_MTA;
drop table TEMP_NEW_CLASS_TEMP;
drop table TEMP_NEW_NAMES;
drop table TEMP_NEW_NAMES_FD;
drop table TEMP_NEW_NAMES_NOS;
drop table TEMP_NMU_BC;
drop table TEMP_NOISMM;
drop table TEMP_NOPLANT;
drop table TEMP_NOSPACENAME;
drop table TEMP_NOTUSED_FLDNTBK;
drop table TEMP_NO_HOMO;
drop table TEMP_NPSCAT;
drop table TEMP_PB;
drop table TEMP_PLANTIMAL;
drop table TEMP_PR;
drop table TEMP_PREBL;
drop table TEMP_PRE_ACCN;
drop table TEMP_PRE_BULK_UMNH_1018;
drop table TEMP_PT;
drop table TEMP_PTU;
drop table TEMP_RAW;
drop table TEMP_RELATED_FUNKY_TAXONOMY;
drop table TEMP_REL_VERBLOC_NOJIVE;
drop table TEMP_RTS;
drop table TEMP_RTS2;
drop table TEMP_RTS3;
drop table TEMP_RTS4;
drop table TEMP_SG;
drop table TEMP_SHREW_OOPS;
drop table TEMP_SPACENAME_U;
drop table TEMP_SPBYCLASS;
drop table TEMP_SPBYORDER;
drop table TEMP_SPESIESIMG;
drop table TEMP_SPIMG;
drop table TEMP_SQL_PART;
drop table TEMP_TAXTERM_BADCHAR;
drop table TEMP_TAX_FUNK;
drop table TEMP_TAX_PLANT;
drop table TEMP_TAX_PLANT_U;
drop table TEMP_TC;
drop table TEMP_TCP2;
drop table TEMP_THESE_WERE_HOMO;
drop table TEMP_TT;
drop table TEMP_TT_U;
drop table TEMP_TT_U2;
drop table TEMP_UAMENTOCITPR;
drop table TEMP_UAMENTO_EVC_LC_NOMATCH;
drop table TEMP_UAMHERB_DL;
drop table TEMP_UAMHERB_DL_U;
drop table TEMP_UAM_AK_VOLE_HASBARCODE;
drop table TEMP_UAM_AK_VOLE_NOBARCODE;
drop table TEMP_UAM_BIRD_FIX;
drop table TEMP_UAM_BIRD_SEDATA;
drop table TEMP_UAM_LOANS;
drop table TEMP_UAM_MAMM_LOAN;
drop table TEMP_UAM_MAP;
drop table TEMP_UCM_FISH_GEOG;
drop table TEMP_UCM_FISH_GEOREF_REPAT;
drop table TEMP_UCM_FISH_G_R;
drop table TEMP_UCM_F_G_R_R;
drop table TEMP_UCM_P1;
drop table TEMP_UCM_PF;
drop table TEMP_UMNH_AGNT;
drop table TEMP_UMNH_BIRD;
drop table TEMP_UMNH_GEO_LKUP;
drop table TEMP_UMNH_GEO_REPAT;
drop table TEMP_UMNH_HERP;
drop table TEMP_UMNH_HERP_LOC;
drop table TEMP_UMNH_MAMM;
drop table TEMP_UMNH_PB_20161028;
drop table TEMP_UMNH_TAXONOMY;
drop table TEMP_UNNM_AGNT_SPLIT;
drop table TEMP_UTEP_ANT;
drop table TEMP_VERBATIMCOLLS;
drop table TENMP_NAME_USED_BY_NOTPLANT;
drop table TEST;
drop table TGR;
drop table THESENOTFOUND;
drop table TRANS201510088;
drop table TRANS20160127;
drop table TSA;
drop table TTAXONOMY;
drop table TTEMP;
drop table TTEMP2;
drop table TTTEST;
drop table TYPECITATIONS;
drop table T_BC;
drop table T_CUMV_CS;
drop table T_CUMV_CSIZE;
drop table T_CUMV_EGGNEST;
drop table T_CUMV_EN_IDENTITY;
drop table T_CUMV_EN_REM;
drop table T_CUMV_EN_SE_REM;
drop table T_CUMV_INCS;
drop table T_CUMV_ISPARA;
drop table T_CUMV_ND;
drop table T_CUMV_NEGG;
drop table T_CUMV_NESTCOLL;
drop table T_CUMV_SETMARK;
drop table T_CU_ANT;
drop table T_UC_AGNTLOOKUP;
drop table T_UC_ANGT;
drop table UAMEGAGENT_UN1;
drop table UAMDUPATTS;
drop table UAMEGAGENT_UN1R;
drop table UAMEGAGENT_UN2R;
drop table UAMEGAGENT_UN2;
drop table UAMEGAGENT_UNR;
drop table UAMEH1;
drop table UAMEHA;
drop table UAMEHAGENT;
drop table UAMEHAGENTRETURN;
drop table UAMINSFIX;
drop table UAM_ARC_PART;
drop table UAM_ENTO_20140430_TMP;
drop table UAM_INSECTS_COORDS;
drop table UCHERP2;
drop table UCM_BIRD_PART;
drop table UCM_FISH;
drop table UCM_FISH_ORIG;
drop table UCM_FISH_PARTS;
drop table UCM_HERP_PARTS;
drop table UCM_MAMM;
drop table UCM_MAMM_ORIG;
drop table UCM_MAMM_PARTS;
drop table UCM_TEMP_ATTR_NONUMCN;
drop table UCM_TEMP_ATTR_REJECT;
drop table UCM_TEMP_BIRD_PART_LEFTOVER;
drop table UCM_TEMP_BIRD_PART_NONUMCN;
drop table UCM_TEMP_PART_NONUMCN;
drop table UC_BIRD;
drop table UC_BIRD_ORIG;
drop table UC_HERP;
drop table UC_HERP_ORIG;
drop table UNMBOXNUMBERS;
drop table UNMSLIDENUMBERS;
drop table UNM_BARCODES_DLM;
drop table USCENSUSCOUNTY;
drop table UW;
drop table UWCS;
drop table UW_AC;
drop table UW_AF;
drop table UW_AFORIG;
drop table UW_AGE;
drop table UW_AGENT;
drop table UW_AGENTFIX;
drop table UW_AGENTLAST;
drop table UW_ATTR;
drop table UW_BEFOREBULK;
drop table UW_BEFOREBULK_FINAL;
drop table UW_BULK;
drop table UW_C1;
drop table UW_C2;
drop table UW_DATE;
drop table UW_DATE2;
drop table UW_DATER;
drop table UW_DATE_DLM;
drop table UW_DATE_OUT;
drop table UW_ELEV;
drop table UW_GEOG;
drop table UW_GEOGORIG;
drop table UW_OLD;
drop table UW_ORIG;
drop table UW_PARTS;
drop table UW_SENT_TO_BULK;
drop table UW_SPLIT;
drop table UW_TAXCORRECTED;
drop table UW_TAX;
drop table UW_TAXFIX;
drop table UW_TAXMISS;
drop table U_C_H_LREM_LID;
drop table U_L_TEST;
drop table VERBATIM_COLLECTOR_AGENT;
drop table VERBATIM_COLLECTOR_NAME;
drop table VNMAP;
drop table WTF;
drop table XXCUMV_HERP_BULK;


-- done at test; 



create table temp_is_eating_space (seg varchar2(4000),fbytes number);


declare
	b number;
begin
	for r in (select distinct SEGMENT_NAME from dba_extents order by SEGMENT_NAME) loop
		select sum(BYTES) into b from dba_extents where SEGMENT_NAME=r.SEGMENT_NAME;
		dbms_output.put_line(r.SEGMENT_NAME || ' @ ' || b);
		insert into temp_is_eating_space (seg,fbytes) values(r.segment_name,b);
	end loop;
end;
/



end 
	select count(*) from arctos_audit where TIMESTAMP < sysdate-90;
	
	
	
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 TIMESTAMP								    DATE
 DB_USER								    VARCHAR2(30)
 OBJECT_NAME								    VARCHAR2(128)
 SQL_TEXT								    NVARCHAR2(2000)
 SQL_BIND								    NVARCHAR2(2000)

