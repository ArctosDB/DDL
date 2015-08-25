/*
	merge the UAM Molluscs,UAM Bryozoans , and UAM Marine Arthropod collections
*/

insert into ctcollection_cde values ('Inv');

declare
	sq varchar2(4000);
begin
	for r in (select table_name from user_tab_cols where table_name like 'CT%' and column_name='COLLECTION_CDE' group by table_name order by table_name) loop
			for c in (select table_name,column_name from user_tab_cols where table_name = r.table_name and column_name!='COLLECTION_CDE' and column_name != 'DESCRIPTION') loop
				sq:=' insert into ' || c.table_name || ' (collection_cde,' || c.column_name || ') ( select ''Inv'', ' || c.column_name || ' from ' || c.table_name || ' where collection_cde in (''Bryo'',''Moll'',''Crus'') group by ' || c.column_name || ') ';
				execute immediate(sq);
			end loop;
		end loop;
end;
/
insert into CTCOLL_OTHER_ID_TYPE (OTHER_ID_TYPE) values ('UAM:Moll: University of Alaska Museum Mollusc');
insert into CTCOLL_OTHER_ID_TYPE (OTHER_ID_TYPE) values ('UAM:Bryo: University of Alaska Museum Bryozoan');
insert into CTCOLL_OTHER_ID_TYPE (OTHER_ID_TYPE) values ('UAM:Crus: University of Alaska Museum Marine Arthropod');

begin
	for r in (select cat_num,collection_object_id from cataloged_item where collection_id=8) loop
		insert into coll_obj_other_id_num (
			COLLECTION_OBJECT_ID,
			OTHER_ID_TYPE,
			OTHER_ID_NUMBER
		) values (
			r.collection_object_id,
			'UAM:Bryo: University of Alaska Museum Bryozoan',
			r.cat_num
		);
	end loop;
end;
/

begin
	for r in (select cat_num,collection_object_id from cataloged_item where collection_id=11) loop
		insert into coll_obj_other_id_num (
			COLLECTION_OBJECT_ID,
			OTHER_ID_TYPE,
			OTHER_ID_NUMBER
		) values (
			r.collection_object_id,
			'UAM:Moll: University of Alaska Museum Mollusc',
			r.cat_num
		);
	end loop;
end;
/


begin
	for r in (select cat_num,collection_object_id from cataloged_item where collection_id=9) loop
		insert into coll_obj_other_id_num (
			COLLECTION_OBJECT_ID,
			OTHER_ID_TYPE,
			OTHER_ID_NUMBER
		) values (
			r.collection_object_id,
			'UAM:Crus: University of Alaska Museum Marine Arthropod',
			r.cat_num
		);
	end loop;
end;
/

-- rename one collection; uam:moll; collection_id=11

update collection set
	COLLECTION_CDE='Inv',
	DESCR='UAM Invertebrate (except Insects) collection',
	COLLECTION='UAM Invertebrates',
	WEB_LINK=null,
	WEB_LINK_TEXT=null,
	LOAN_POLICY_URL=null
where
	collection_id=11;
	
update cf_collection set
	DBUSERNAME='PUB_USR_UAM_INV',
	DBPWD='topsecret',
	PORTAL_NAME='UAM_INV',
	collection='UAM Invertebrates',
	PUBLIC_PORTAL_FG=1
where
	collection_id=11;

create role UAM_INV;
create user PUB_USR_UAM_INV identified by "topsecret" profile arctos_user default tablespace users quota 1g on users;
grant UAM_INV to PUB_USR_UAM_INV;
grant UAM_INV to UAM;
grant UAM_INV to PUB_USR_ALL_ALL;
grant UAM_INV to DLM;

-- enable stuff to move across partitions
alter table trans enable row movement;

-- update collection ID in trans, vpd_collection_locality
update trans set collection_id=11 where collection_id=8;
update trans set collection_id=11 where collection_id=9;
alter table trans disable row movement;

alter table vpd_collection_locality enable row movement;

update vpd_collection_locality set collection_id=11 where collection_id=8 and locality_id not in (select locality_id from vpd_collection_locality where collection_id=11);

update vpd_collection_locality set collection_id=11 where collection_id=9  and locality_id not in (select locality_id from vpd_collection_locality where collection_id=11);

delete from vpd_collection_locality where collection_id in (8,9);
alter table vpd_collection_locality disable row movement;

-- increment catnums
alter table cataloged_item enable row movement;

update cataloged_item set 
collection_id=11,
cat_num=cat_num + (select max(cat_num) from cataloged_item where collection_id=11) 
where collection_id=8;


update cataloged_item set 
collection_id=11,
cat_num=cat_num + (select max(cat_num) from cataloged_item where collection_id=11) 
where collection_id=9;

alter table cataloged_item disable row movement;

update collection set guid_prefix='UAM:Inv' where collection_id=11;

alter table flat enable row movement;

update flat set stale_flag=1,LASTUSER='DLM',LASTDATE=sysdate where collection_id in (8,9,11);
 exec is_flat_stale;
 
 alter table flat disable row movement;


-- delete uam_bryo,uam_moll,uam_crus directories
/*
[fndlm@arctos-test web]$ rm -rf uam_crus
[fndlm@arctos-test web]$ rm -rf uam_bryo
[fndlm@arctos-test web]$ rm -rf uam_moll

*/
delete from cf_collection where collection_id in (8,9);
delete from collection_contacts where collection_id in (8,9);
delete from collection where collection_id in (8,9);

-- run buildHome

-- if DAMMIT then...
update cf_collection set PORTAL_NAME='UAM_INV' where collection_id=11;
select distinct(collection_id) from flat;


drop role uam_bryo;
drop role uam_crus;
drop role uam_moll;
drop user pub_usr_uam_bryo;
drop user  pub_usr_uam_crus;
drop user pub_usr_uam_moll;

declare
	sq varchar2(4000);
begin
	for r in (select table_name from user_tab_cols where table_name like 'CT%' and column_name='COLLECTION_CDE' group by table_name order by table_name) loop
			for c in (select table_name,column_name from user_tab_cols where table_name = r.table_name and column_name!='COLLECTION_CDE' and column_name != 'DESCRIPTION') loop
				sq:=' delete from ' || c.table_name || ' where collection_cde in (''Bryo'',''Moll'',''Crus'',''ECDM'')';
				execute immediate(sq);
			end loop;
		end loop;
end;
/