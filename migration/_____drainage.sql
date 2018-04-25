alter table geog_auth_rec add drainage varchar2(255);


CREATE OR REPLACE TRIGGER TRG_MK_HIGHER_GEOG....

alter table log_geog_auth_rec add n_drainage varchar2(255);
alter table log_geog_auth_rec add O_drainage varchar2(255);

CREATE OR REPLACE TRIGGER TR_LOG_GEOG_UPDATE....


-- not adding drainage to flat at this time
-- and the geography stuff that's in there is singular anyway
-- so new function to get geography term

CREATE OR REPLACE FUNCTION getGeographyTerm(cid IN number, trm in varchar)
RETURN varchar
AS
   TYPE RC IS REF CURSOR;
    l_str    VARCHAR2(4000);
    l_sep    VARCHAR2(30);
    l_val    VARCHAR2(4000);
    l_cur    RC;
BEGIN
    OPEN l_cur FOR '
		select ' || trm || ' 
		from geog_auth_rec,locality,collecting_event,specimen_event 
		where 
		geog_auth_rec.geog_auth_rec_id=locality.geog_auth_rec_id and
		locality.locality_id=collecting_event.locality_id and
		collecting_event.collecting_event_id=specimen_event.collecting_event_id and
		' || trm || ' is not null and 
		specimen_event.collection_object_id=:x'
        USING cid;
	 LOOP
        FETCH l_cur INTO l_val;
        EXIT WHEN l_cur%notfound;
        l_str := l_str || l_sep || l_val;
        l_sep := '; ';
    END LOOP;
    CLOSE l_cur;
    RETURN l_str;
end;
    /
    sho err;

    create public synonym getGeographyTerm for getGeographyTerm;
    
   grant execute on getGeographyTerm to public;
   
   
select getGeographyTerm(21104932,'drainage') from dual;
select getGeographyTerm(21104932,'state_prov') from dual;
select getGeographyTerm(12,'drainage') from dual;
select getGeographyTerm(12,'state_prov') from dual;





insert into ssrch_field_doc (
 	CATEGORY,
 	CF_VARIABLE,
 	CONTROLLED_VOCABULARY,
 	DATA_TYPE,
 	DEFINITION,
 	DISPLAY_TEXT,
 	DOCUMENTATION_LINK,
 	PLACEHOLDER_TEXT,
 	SEARCH_HINT,
 	SQL_ELEMENT,
 	SPECIMEN_RESULTS_COL,
 	DISP_ORDER,
 	SPECIMEN_QUERY_TERM
 ) values (
 	'locality',
 	'drainage',
 	null,
 	'Drainage Basin or Watershed.',
 	'drainage',
 	'drainage',
 	'http://handbook.arctosdb.org/documentation/higher-geography.html',
 	'drainage',
 	null,
 	'getGeographyTerm(flatTableName.collection_object_id,''drainage'')',
 	1,
 	(select disp_order + .00001 from ssrch_field_doc where CF_VARIABLE='feature'),
 	0
 );
 
 	delete from ssrch_field_doc where CF_VARIABLE='specimen_results';
 	
 -- this is already in prod
 insert into ssrch_field_doc (
 	CF_VARIABLE,
 	DEFINITION,
 	DISPLAY_TEXT,
 	DOCUMENTATION_LINK,
 	SPECIMEN_RESULTS_COL,
 	SPECIMEN_QUERY_TERM
 ) values (
 	'specimen_results',
 	'clickthrough',
 	'Specimen Results',
 	'http://handbook.arctosdb.org/documentation/specimen-results.html',
 	0,
 	0
 );
 
 
 select spec_locality from flat where guid like 'MSB:Fish%' group by spec_locality order by spec_locality;
 