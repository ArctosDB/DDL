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
 
 
 
 
 --- now data
 create table temp_msb_f_d as 
 select
 	higher_geog,
 	--locality_remarks,
 	--instr(locality_remarks,'Drainage'),
 	substr(locality_remarks,0,instr(locality_remarks,'Drainage')+7) drainage
 from
 	geog_auth_rec,
 	locality,
 	collecting_event,
 	specimen_event,
 	cataloged_item,
 	collection
 where
 	geog_auth_rec.geog_auth_rec_id=locality.geog_auth_rec_id and
 	locality.locality_id=collecting_event.locality_id and
 	collecting_event.collecting_event_id=specimen_event.collecting_event_id and
 	specimen_event.collection_object_id=cataloged_item.collection_object_id and
 	cataloged_item.collection_id=collection.collection_id and
 	collection.guid_prefix='MSB:Fish' and
 	locality_remarks like '%Drainage%'
 group by
 	higher_geog,
 	substr(locality_remarks,0,instr(locality_remarks,'Drainage')+7)
 ;
 
 select * from temp_msb_f_d order by drainage,higher_geog;
 
 
 create table temp_msb_f_do as select distinct drainage from temp_msb_f_d;
 
 spec_locality from flat where guid like 'MSB:Fish%' group by spec_locality order by spec_locality;
 
 
 delete from temp_msb_f_d where drainage='Fish Hatchery Drainage';
 
 
 select distinct drainage, replace(drainage,' Drainage') from temp_msb_f_d;
 
 update temp_msb_f_d set drainage=replace(drainage,' Drainage');
 
  select distinct drainage from temp_msb_f_d;
  
  alter table temp_msb_f_d add wiki varchar2(255) ;
  update temp_msb_f_d set wiki='https://en.wikipedia.org/wiki/Mississippi_River_System' where drainage='Mississippi River';
  update temp_msb_f_d set wiki='https://en.wikipedia.org/wiki/Arkansas_River' where drainage='Arkansas River';
  update temp_msb_f_d set wiki='Atlantic Ocean Slope' where drainage='https://en.wikipedia.org/wiki/Atlantic_Ocean';
  update temp_msb_f_d set wiki='https://en.wikipedia.org/wiki/Gila_River' where drainage='Gila River';
  update temp_msb_f_d set wiki='https://en.wikipedia.org/wiki/Missouri_River' where drainage='Missouri River';
  update temp_msb_f_d set wiki='https://en.wikipedia.org/wiki/Guzm%C3%A1n_Basin' where drainage='Guzman Basin';
  update temp_msb_f_d set wiki='https://en.wikipedia.org/wiki/Rio_Grande' where drainage='Rio Grande';
  update temp_msb_f_d set wiki='https://en.wikipedia.org/wiki/Canadian_River' where drainage='Canadian River';
  update temp_msb_f_d set wiki='https://en.wikipedia.org/wiki/Pacific_Slope' where drainage='Pacific Ocean Slope';
  update temp_msb_f_d set wiki='https://en.wikipedia.org/wiki/San_Juan_River_(Colorado_River_tributary)' where drainage='San Juan River';
  update temp_msb_f_d set wiki='https://en.wikipedia.org/wiki/Zuni_River' where drainage='Zuni River';
  update temp_msb_f_d set wiki='https://en.wikipedia.org/wiki/Great_Basin' where drainage='Great Basin';
  update temp_msb_f_d set wiki='https://en.wikipedia.org/wiki/Colorado_River' where drainage='Colorado River';
  update temp_msb_f_d set wiki='https://en.wikipedia.org/wiki/Arctic_Ocean' where drainage='Arctic Ocean';
  update temp_msb_f_d set wiki='https://en.wikipedia.org/wiki/Pecos_River' where drainage='Pecos River';
  update temp_msb_f_d set wiki='https://en.wikipedia.org/wiki/Gulf_of_Mexico' where drainage='Gulf of Mexico';
  update temp_msb_f_d set wiki='https://en.wikipedia.org/wiki/Great_Lakes' where drainage='Great Lakes';
  update temp_msb_f_d set wiki='https://en.wikipedia.org/wiki/Tularosa_Basin' where drainage='Tularosa Basin';
  update temp_msb_f_d set wiki='https://en.wikipedia.org/wiki/Atlantic_Ocean' where drainage='Atlantic Ocean Slope';
  update temp_msb_f_d set wiki='xxx' where drainage='xxxx';
  
  
  select * from temp_msb_f_d where wiki is null;
  
  declare
  	isl varchar2(255);
  begin
	  for r in (select distinct higher_geog,drainage, wiki from temp_msb_f_d) loop
	  	dbms_output.put_line(r.drainage);
	  	dbms_output.put_line(r.higher_geog);
	  	dbms_output.put_line(r.wiki);
		for s in (select * from geog_auth_rec where higher_geog=r.higher_geog ) loop
			if s.island is not null then
				isl:='*' || s.island;
			else
				isl:=null;
			end if;
	  		dbms_output.put_line(s.geog_auth_rec_id);
	  		insert into geog_auth_rec(
	  			GEOG_AUTH_REC_ID,
	  			CONTINENT_OCEAN,
	  			COUNTRY,
	  			STATE_PROV,
	  			COUNTY,
	  			QUAD,
	  			FEATURE,
	  			ISLAND,
	  			ISLAND_GROUP,
	  			SEA,
	  			VALID_CATALOG_TERM_FG,
	  			SOURCE_AUTHORITY,
	  			DRAINAGE				
	  		) values (
	  			sq_GEOG_AUTH_REC_ID.nextval,
	  			s.CONTINENT_OCEAN,
	  			s.COUNTRY,
	  			s.STATE_PROV,
	  			s.COUNTY,
	  			s.QUAD,
	  			s.FEATURE,
	  			isl,
	  			s.ISLAND_GROUP,
	  			s.SEA,
	  			1,
	  			r.wiki,
	  			r.DRAINAGE		
	  		);
	  		
	  	end loop;
	  end loop;
  end ;
  /
  
  
  

 