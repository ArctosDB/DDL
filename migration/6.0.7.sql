drop index IU_CFCANNEDSEARCH_USERID_URL;
drop index IU_CFCANNEDSEARCH_USERID_SRCH;

drop index PK_CF_CANNED_SEARCH;



CREATE UNIQUE INDEX PK_CF_CANNED_SEARCH ON CF_CANNED_SEARCH (CANNED_ID) TABLESPACE UAM_IDX_1;

	
declare mid number;
begin
	for r in (select search_name from cf_canned_search having count(*) > 1 group by search_name) loop
		select min(CANNED_ID) into mid from cf_canned_search where search_name=r.search_name;
		delete from cf_canned_search where search_name=r.search_name and CANNED_ID>mid;
	end loop;
end;
/


CREATE UNIQUE INDEX ix_u_CANNED_SEARCH_schname ON CF_CANNED_SEARCH upper(search_name) TABLESPACE UAM_IDX_1;
