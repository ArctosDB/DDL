-- ref https://github.com/ArctosDB/arctos/issues/593, https://github.com/ArctosDB/arctos/issues/830

-- code table editor is already doing weird things for other IDs, so changing it to do something
-- slightly weirder doesn't seem like a big thang
-- so just add an ordering column and sort by it in the various forms

alter table CTCOLL_OTHER_ID_TYPE add sort_order number;

-- get the most common things to the top; change or whatever from the interfaces as needed
-- try to maintain some semblance of alphabetical in the "chosen identifiers"
select 	other_id_type || ': ' || count(*) from coll_obj_other_id_num group by other_id_type order by count(*);

update ctcoll_other_id_type set sort_order=1 where OTHER_ID_TYPE='AF';
update ctcoll_other_id_type set sort_order=2 where OTHER_ID_TYPE='ALAAC';
update ctcoll_other_id_type set sort_order=3 where OTHER_ID_TYPE='collector number';
update ctcoll_other_id_type set sort_order=4 where OTHER_ID_TYPE='GenBank';
update ctcoll_other_id_type set sort_order=5 where OTHER_ID_TYPE='NK';
update ctcoll_other_id_type set sort_order=6 where OTHER_ID_TYPE='original identifier';
update ctcoll_other_id_type set sort_order=7 where OTHER_ID_TYPE='preparator number';
	

