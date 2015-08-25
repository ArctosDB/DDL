alter table cf_users add srmapclass varchar2(30);

create or replace view ctcountry as select distinct country from geog_auth_rec;
create or replace public synonym ctcountry for ctcountry;
grant select on ctcountry to public;
update ssrch_field_doc set CONTROLLED_VOCABULARY='ctcountry' where cf_variable='country';

create or replace view ctstate_prov as select distinct state_prov from geog_auth_rec;
create or replace public synonym ctstate_prov for ctstate_prov;
grant select on ctstate_prov to public;
update ssrch_field_doc set CONTROLLED_VOCABULARY='ctstate_prov' where cf_variable='state_prov';

create or replace view ctcounty as select distinct county from geog_auth_rec;
create or replace public synonym ctcounty for ctcounty;
grant select on ctcounty to public;
update ssrch_field_doc set CONTROLLED_VOCABULARY='ctcounty' where cf_variable='county';

create or replace view ctcontinent_ocean as select distinct continent_ocean from geog_auth_rec;
create or replace public synonym ctcontinent_ocean for ctcontinent_ocean;
grant select on ctcontinent_ocean to public;
update ssrch_field_doc set CONTROLLED_VOCABULARY='ctcontinent_ocean' where cf_variable='continent_ocean';

create or replace view ctsea as select distinct sea from geog_auth_rec;
create or replace public synonym ctsea for ctsea;
grant select on ctsea to public;
update ssrch_field_doc set CONTROLLED_VOCABULARY='ctsea' where cf_variable='sea';

create or replace view ctquad as select distinct quad from geog_auth_rec;
create or replace public synonym ctquad for ctquad;
grant select on ctquad to public;
update ssrch_field_doc set CONTROLLED_VOCABULARY='ctquad' where cf_variable='quad';


create or replace view ctisland as select distinct island from geog_auth_rec;
create or replace public synonym ctisland for ctisland;
grant select on ctisland to public;
update ssrch_field_doc set CONTROLLED_VOCABULARY='ctisland' where cf_variable='island';


create or replace view ctisland_group as select distinct island_group from geog_auth_rec;
create or replace public synonym ctisland_group for ctisland_group;
grant select on ctisland_group to public;
update ssrch_field_doc set CONTROLLED_VOCABULARY='ctisland_group' where cf_variable='island_group';

insert into ssrch_field_doc (
	SSRCH_FIELD_DOC_ID,
	CF_VARIABLE,
	DISPLAY_TEXT,
	SPECIMEN_QUERY_TERM,
	SEARCH_HINT,
	PLACEHOLDER_TEXT,
	SPECIMEN_RESULTS_COL
) values (
	sq_SSRCH_FIELD_DOC_ID.nextval,
	'coordinates',
	'coordinates',
	1,
	'exact match of {dec_lat,dec_long}',
	'dec_lat,dec_long',
	0
);

	CREATE OR REPLACE function to_grams.....

  
	CREATE OR REPLACE function to_days.....
	CREATE OR REPLACE function to_meters.....


  
  
 