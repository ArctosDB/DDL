update cf_collection set HEADER_IMAGE='/images/ArctosBlue-generic-logo.svg',
	INSTITUTION_LINK_TEXT='Collaborative Collection Management Solution',
	COLLECTION_LINK_TEXT='Arctos' where cf_collection_id=0;
update cf_collection set INSTITUTION_LINK_TEXT='This Is Test' where cf_collection_id=0;

update cf_collection set 
	HEADER_IMAGE='/images/ArctosBlue-generic-logo.svg',
	INSTITUTION_URL='http://arctosdb.org/',
	COLLECTION_URL='http://arctosdb.org/',
	INSTITUTION_LINK_TEXT='Collaborative Collection Management Solution',
	COLLECTION_LINK_TEXT='' where cf_collection_id=0;

	commit;	
	
	
	

update cf_collection set HEADER_IMAGE='/images/ArctosBlue-generic-logo.svg',
	INSTITUTION_LINK_TEXT='Collaborative Collection Management Solution',
	COLLECTION_LINK_TEXT='' where cf_collection_id=0;


	
	
update cf_collection set 
	HEADER_IMAGE='/images/ArctosBlue-generic-logo.svg',
	INSTITUTION_URL='http://arctosdb.org/',
	COLLECTION_URL='http://arctosdb.org/',
	INSTITUTION_LINK_TEXT='',
	COLLECTION_LINK_TEXT='Collaborative Collection Management Solution' where cf_collection_id=0;

	commit;	

		
update cf_collection set 
	HEADER_IMAGE='/images/ArctosBlue-generic-logo.svg',
	INSTITUTION_URL='http://arctosdb.org/',
	COLLECTION_URL='http://arctosdb.org/',
	INSTITUTION_LINK_TEXT='Collaborative Collection Management Solution',
	COLLECTION_LINK_TEXT='Arctos' where cf_collection_id=0;

	commit;	
		
update cf_collection set 
	HEADER_IMAGE='/images/ArctosBlue-generic-logo.svg',
	INSTITUTION_URL='http://arctosdb.org/',
	COLLECTION_URL='http://arctosdb.org/',
	INSTITUTION_LINK_TEXT='Arctos',
	COLLECTION_LINK_TEXT='Collaborative Collection Management Solution' where cf_collection_id=0;

	commit;	
	
--------------


Last login: Mon Sep  8 08:55:43 on ttys000
ArctosGrinder:~ dustymc$ test
dbp
Last login: Fri Sep  5 18:29:03 2014 from c-76-105-44-231.hsd1.ca.comcast.net
------------------------------------------------------------------------------
Welcome to the Texas Advanced Computing Center
   at The University of Texas at Austin

** Unauthorized use/access is prohibited. **

If you log on to this computer system, you acknowledge your awareness
of and concurrence with the UT Austin Acceptable Use Policy. The
University will prosecute violators to the full extent of the law.

TACC Usage Policies:
http://www.tacc.utexas.edu/user-services/usage-policies/

TACC Support: 
https://portal.tacc.utexas.edu/tacc-consulting

------------------------------------------------------------------------------
dbp
-bash-4.1$ dbp

SQL*Plus: Release 11.2.0.1.0 Production on Mon Sep 8 10:55:55 2014

Copyright (c) 1982, 2009, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.1.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options

UAM@ARCTOS> select * from cf_collection where collection_id=0;

no rows selected

Elapsed: 00:00:00.01
UAM@ARCTOS> select * from cf_collection where cf_collection_id=0;

CF_COLLECTION_ID COLLECTION_ID
---------------- -------------
DBUSERNAME
------------------------------------------------------------------------------------------------------
DBPWD
------------------------------------------------------------------------------------------------------------------------
HEADER_COLOR
------------------------------------------------------------
HEADER_IMAGE
------------------------------------------------------------------------------------------------------------------------
COLLECTION_URL
------------------------------------------------------------------------------------------------------------------------
COLLECTION_LINK_TEXT
------------------------------------------------------------------------------------------------------------------------
INSTITUTION_URL
------------------------------------------------------------------------------------------------------------------------
INSTITUTION_LINK_TEXT
------------------------------------------------------------------------------------------------------------------------
META_DESCRIPTION
------------------------------------------------------------------------------------------------------------------------
META_KEYWORDS
------------------------------------------------------------------------------------------------------------------------
STYLESHEET
------------------------------------------------------------------------------------------------------------------------
HEA PORTAL_NAME
--- ------------------------------------------------------------------------------------------
COLLECTION
------------------------------------------------------------------------------------------------------------------------
PUBLIC_PORTAL_FG
----------------
	       0
PUB_USR_ALL_ALL
Vapru286hu.0
#E7E7E7
/images/genericHeaderIcon.gif
/
Arctos
/
Multi-Institution, Multi-Collection Museum Database
Arctos is a biological specimen database.
museum, collection, management, system, database, specimen

	
	
    ALL_ALL
All Collections
	       1


1 row selected.

Elapsed: 00:00:00.01
UAM@ARCTOS> 




	update cf_collection set HEADER_IMAGE='/images/ArctosBlue-generic-logo.svg'  where cf_collection_id=0;
	
		update cf_collection set HEADER_IMAGE='/images/ArctosBlue-generic-logo.svg'  where cf_collection_id=0;

	

	
	update cf_collection set HEADER_IMAGE='/images/ArctosBlue-generic-logo.svg',
	INSTITUTION_LINK_TEXT='Collaborative Collection Management System',
	COLLECTION_LINK_TEXT='' where cf_collection_id=0;
	
	
	
update cf_collection set HEADER_IMAGE='/images/ArctosBlue-generic-header.png',INSTITUTION_LINK_TEXT='Collaborative Collection Management System' where cf_collection_id=0;

update cf_collection set INSTITUTION_LINK_TEXT='Collaborative Collection Management' where cf_collection_id=0;

-- no more making up "sources"


CREATE OR REPLACE TRIGGER TRG_HIGHER_GEOG_wikisrc
BEFORE INSERT OR UPDATE ON GEOG_AUTH_REC
FOR EACH ROW
BEGIN
	
	if :NEW.SOURCE_AUTHORITY not like 'http://e_.wikipedia.org/wiki/%' and :NEW.SOURCE_AUTHORITY not like 'https://e_.wikipedia.org/wiki/%' then
		 raise_application_error(
            -20371,
            'Source authority must be a page on English Wikipedia.');	
	end if;
end;
/



-- first try some cleanup

drop table temp_geog;

create table temp_geog as select higher_geog from geog_auth_rec;

alter table temp_geog add stripped_key varchar2(4000);

declare
	temp varchar2(4000);
begin
	for x in (select higher_geog from temp_geog) loop
		temp:=lower(x.higher_geog);
		
		temp:=replace(temp,'autonomous');
		
		
		temp:=replace(temp,'city');
		temp:=replace(temp,'community');
		temp:=replace(temp,'county');
		temp:=replace(temp,'co.');
		temp:=replace(temp,' co ');
		
		
		temp:=replace(temp,'depto.');
		temp:=replace(temp,'dept.');
		temp:=replace(temp,'departamento');
		temp:=replace(temp,' del ');
		temp:=replace(temp,' de ');
		temp:=replace(temp,'district');
		temp:=replace(temp,'dist.');
		
		
		temp:=replace(temp,'island');
		temp:=replace(temp,'is.');
		temp:=replace(temp,'isl.');
		temp:=replace(temp,'isla');
		temp:=replace(temp,' is ');
		temp:=replace(temp,' isl ');
		
		
		temp:=replace(temp,'kray');
		temp:=replace(temp,'kabupaten');
		
		temp:=replace(temp,' la ');
		
		temp:=replace(temp,'municipality');
		
		temp:=replace(temp,'oblast');
		temp:=replace(temp,' of ');
		
		
		temp:=replace(temp,'province');
		temp:=replace(temp,'provincia');
		temp:=replace(temp,'prov.');
		temp:=replace(temp,'parish');
		temp:=replace(temp,'pref.');
		
		
		temp:=replace(temp,'republic');
		
		temp:=replace(temp,'territory');
		
		temp:=replace(temp,'ward');
		
		temp:=replace(temp,'.');
		
		temp:=replace(temp,'  ',' ');
		temp:=trim(temp);
		update temp_geog set stripped_key=temp where higher_geog=x.higher_geog;
	end loop;
end ;
/

select stripped_key, higher_geog from temp_geog where stripped_key in (select  stripped_key from temp_geog having count(*) > 1 group by stripped_key) order by stripped_key;

-- painful arbitrary manual cleanup
-- grumble grumble grumble....

-- woohoo, clean!!
-- now keep it that way

alter table geog_auth_rec add stripped_key varchar2(4000);


lock table geog_auth_rec in exclusive mode nowait;
-- turn off all the triggers
alter trigger UAM.TRG_HIGHER_GEOG_WIKISRC disable;
alter trigger TR_GEOGAUTHREC_AU_FLAT disable;
alter trigger TR_LOG_GEOG_UPDATE disable;
alter trigger TR_LOG_GEOG_UPDATE disable;


declare
	temp varchar2(4000);
begin
	for x in (select higher_geog from geog_auth_rec) loop
		temp:=lower(x.higher_geog);
		
		temp:=replace(temp,'autonomous');
		
		
		temp:=replace(temp,'city');
		temp:=replace(temp,'community');
		temp:=replace(temp,'county');
		temp:=replace(temp,'co.');
		temp:=replace(temp,' co ');
		
		
		temp:=replace(temp,'depto.');
		temp:=replace(temp,'dept.');
		temp:=replace(temp,'departamento');
		temp:=replace(temp,' del ');
		temp:=replace(temp,' de ');
		temp:=replace(temp,'district');
		temp:=replace(temp,'dist.');
		
		
		temp:=replace(temp,'island');
		temp:=replace(temp,'is.');
		temp:=replace(temp,'isl.');
		temp:=replace(temp,'isla');
		temp:=replace(temp,' is ');
		temp:=replace(temp,' isl ');
		
		
		temp:=replace(temp,'kray');
		temp:=replace(temp,'kabupaten');
		
		temp:=replace(temp,' la ');
		
		temp:=replace(temp,'municipality');
		
		temp:=replace(temp,'oblast');
		temp:=replace(temp,' of ');
		
		
		temp:=replace(temp,'province');
		temp:=replace(temp,'provincia');
		temp:=replace(temp,'prov.');
		temp:=replace(temp,'parish');
		temp:=replace(temp,'pref.');
		
		
		temp:=replace(temp,'republic');
		
		temp:=replace(temp,'territory');
		
		temp:=replace(temp,'ward');
		
		temp:=replace(temp,'.');
		
		temp:=replace(temp,'  ',' ');
		temp:=trim(temp);
		update geog_auth_rec set stripped_key=temp where higher_geog=x.higher_geog;
	end loop;
end ;
/

alter table geog_auth_rec modify stripped_key not null;

create unique index ix_u_geog_skey on geog_auth_rec(stripped_key) tablespace uam_idx_1;



CREATE OR REPLACE TRIGGER TRG_HIGHER_GEOG_MagicDups
BEFORE INSERT OR UPDATE ON GEOG_AUTH_REC
FOR EACH ROW
DECLARE 
	PRAGMA AUTONOMOUS_TRANSACTION;
	n number;
	gid number;
BEGIN
	-- see if we can detect some common problems
	if updating then
		gid:=:OLD.geog_auth_rec_id;
	else
		gid:=-1;
	end if;
	if :NEW.island is not null then
		if substr(:NEW.island,1,1) = '*' then
			:NEW.island:=replace(:NEW.island,'*');
		else
			select count(*) into n from GEOG_AUTH_REC where geog_auth_rec_id!=gid and trim(replace(replace(island,' Island'),'Isla '))=trim(replace(replace(:NEW.island,' Island'),'Isla '));
			if n>0 then
				raise_application_error(
	            	-20368,
	            	'Potential duplicate detected in Island. Double-check existing data. Prefix Island with an asterisk to force-create.');	
	            rollback;
	     	end if;
	     end if;
	end if;
	commit;
END;
/
sho err;


	



CREATE OR REPLACE TRIGGER TRG_MK_HIGHER_GEOG
BEFORE INSERT OR UPDATE ON GEOG_AUTH_REC
FOR EACH ROW
DECLARE 
	hg varchar2(4000);
	temp varchar2(4000);
	TYPE STR_LIST_TYPE IS TABLE OF VARCHAR2(15);
	V_STR_VALUES STR_LIST_TYPE;
	thisval varchar2(15);
	n number;
BEGIN
	
	
     
     
	if :NEW.VALID_CATALOG_TERM_FG is null then
		:NEW.VALID_CATALOG_TERM_FG:=1;
	end if;	
	IF :NEW.continent_ocean IS NOT NULL THEN
		IF hg IS NULL THEN
			hg := :NEW.continent_ocean;
		ELSE
			hg := hg || ', ' || :NEW.continent_ocean;
		END IF;
	END IF;   
	IF :NEW.sea IS NOT NULL THEN
		IF hg IS NULL THEN
			hg := :NEW.sea;
		ELSE
			hg := hg || ', ' || :NEW.sea;
		END IF;
	END IF;
	IF :NEW.country IS NOT NULL THEN
		IF hg IS NULL THEN
			hg := :NEW.country;
		ELSE
			hg := hg || ', ' || :NEW.country;
		END IF;
	END IF;
	IF :NEW.state_prov IS NOT NULL THEN
		IF hg IS NULL THEN
			hg := :NEW.state_prov;
		ELSE
			hg := hg || ', ' || :NEW.state_prov;
		END IF;
	END IF;
	IF :NEW.county IS NOT NULL THEN
		IF hg IS NULL THEN
			hg := :NEW.county;
		ELSE
			hg := hg || ', ' || :NEW.county;
		END IF;
	END IF;
	IF :NEW.quad IS NOT NULL THEN
		IF hg IS NULL THEN
			hg := :NEW.quad || ' Quad';
		ELSE
			hg := hg || ', ' || :NEW.quad || ' Quad';
		END IF;
	END IF;
	IF :NEW.feature IS NOT NULL THEN
		IF hg IS NULL THEN
			hg := :NEW.feature;
		ELSE
			hg := hg || ', ' || :NEW.feature;
		END IF;
	END IF;
	IF :NEW.island_group IS NOT NULL THEN
		IF hg IS NULL THEN
			hg := :NEW.island_group;
		ELSE
			hg := hg || ', ' || :NEW.island_group;
		END IF;
	END IF;
	IF :NEW.island IS NOT NULL THEN
		IF hg IS NULL THEN
			hg := :NEW.island;
		ELSE
			hg := hg || ', ' || :NEW.island;
		END IF;
	END IF;
	 
	if hg like '%  %' then
		 raise_application_error(
            -20370,
            'Detected double spaces.');	
	end if;
	-- list of characters that probably indicate garbage data
	V_STR_VALUES := STR_LIST_TYPE('}','{','(',')','[',']');
	FOR INDX IN V_STR_VALUES.FIRST..V_STR_VALUES.LAST LOOP
		thisval :=  V_STR_VALUES(INDX);
		if instr(hg ,thisval)>0 then
			raise_application_error(
			-20369,
			'Detected disallowed character: ' || thisval);	
   		end if; 
	END LOOP; 
	-- list of common evil abbreviations etc. - ignore case
	V_STR_VALUES := STR_LIST_TYPE('CO.','dept.','Depto.','ISL.','is.','Prov.','Pref.','Dist.','TERR.',' USA');
	FOR INDX IN V_STR_VALUES.FIRST..V_STR_VALUES.LAST LOOP
		thisval :=  upper(V_STR_VALUES(INDX));
		if instr(upper(hg) ,thisval)>0 then
   			 raise_application_error(
            -20369,
            'Detected disallowed phrase: ' || thisval);	
   		end if; 
	END LOOP;
	:NEW.higher_geog := trim(hg);

	temp:=lower(hg);
	-- Strip out common qualifiers etc. that are OK to include but lead to duplicates 
	-- and throw the result at a unique index. 
	-- No need to check for things that are outright disallowed by the above.

	temp:=replace(temp,'autonomous');
	
	temp:=replace(temp,'city');
	temp:=replace(temp,'community');
	temp:=replace(temp,'county');
	temp:=replace(temp,' co ');
	
	temp:=replace(temp,'departamento');
	temp:=replace(temp,' del ');
	temp:=replace(temp,' de ');
	temp:=replace(temp,'district');
	
	temp:=replace(temp,'governorate.');
	
	temp:=replace(temp,'island');
	temp:=replace(temp,'isla');
	temp:=replace(temp,' is ');
	temp:=replace(temp,' isl ');
	
	temp:=replace(temp,'kray');
	temp:=replace(temp,'kabupaten');
	
	temp:=replace(temp,' la ');
	
	temp:=replace(temp,'municipality');
	
	temp:=replace(temp,'oblast');
	temp:=replace(temp,' of ');
	
	temp:=replace(temp,'province');
	temp:=replace(temp,'provincia');
	temp:=replace(temp,'parish');

	temp:=replace(temp,'republic');
	
	temp:=replace(temp,'territory');
	
	temp:=replace(temp,'ward');
	
	temp:=replace(temp,'.');
	
	temp:=replace(temp,'  ',' ');
	temp:=trim(temp);
	:NEW.stripped_key:=temp;

END;
/





alter trigger UAM.TRG_HIGHER_GEOG_WIKISRC enable;
alter trigger UAM.TR_GEOGAUTHREC_AU_FLAT enable;
alter trigger UAM.TR_LOG_GEOG_UPDATE enable;
alter trigger UAM.TR_LOG_GEOG_UPDATE enable;





drop table ctnagpra_category;

create table ctnagpra_category as select lower(NAGPRA_category) NAGPRA_category,'EH' collection_cde, documentation DESCRIPTION from dlm.my_temp_cf ;

alter table ctnagpra_category modify collection_cde varchar2(10) not null;
alter table ctnagpra_category modify DESCRIPTION varchar2(4000);
alter table ctnagpra_category modify NAGPRA_CATEGORY varchar2(60) not null;

insert into ctnagpra_category (NAGPRA_category,collection_cde,DESCRIPTION) (select lower(NAGPRA_category),'Arc',documentation from dlm.my_temp_cf);

select * from ctnagpra_category;

create public synonym ctnagpra_category for ctnagpra_category;

grant select on ctnagpra_category to public;

grant all on ctnagpra_category to manage_codetables;

create unique index ix_u_ctnagrpa_category on ctnagpra_category (NAGPRA_category,collection_cde) tablespace uam_idx_1;

create table log_ctnagpra_category ( 
	username varchar2(60),	
	when date default sysdate,
	n_NAGPRA_CATEGORY varchar2(60),
	n_collection_cde varchar2(10),
	n_DESCRIPTION varchar2(4000),
	o_NAGPRA_CATEGORY varchar2(60),
	o_collection_cde varchar2(10),
	o_DESCRIPTION varchar2(4000)
);


create or replace public synonym log_ctnagpra_category for log_ctnagpra_category;


grant select on log_ctnagpra_category to coldfusion_user;


CREATE OR REPLACE TRIGGER TR_log_nagpra_category 
	AFTER INSERT or update or delete ON ctnagpra_category
	FOR EACH ROW 
BEGIN 
	insert into log_ctnagpra_category ( 
		username, 
		when,
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
	

insert into CTATTRIBUTE_TYPE (ATTRIBUTE_TYPE,COLLECTION_CDE,DESCRIPTION) values ('NAGPRA category','EH','see http://www.nps.gov/nagpra/MANDATES/INDEX.HTM and http://www.nps.gov/nagpra/TRAINING/GLOSSARY.HTM');
insert into CTATTRIBUTE_TYPE (ATTRIBUTE_TYPE,COLLECTION_CDE,DESCRIPTION) values ('NAGPRA category','Arc','see http://www.nps.gov/nagpra/MANDATES/INDEX.HTM and http://www.nps.gov/nagpra/TRAINING/GLOSSARY.HTM');

insert into CTATTRIBUTE_CODE_TABLES (ATTRIBUTE_TYPE,VALUE_CODE_TABLE) values ('NAGPRA category',upper('ctnagpra_category'));

 
 



