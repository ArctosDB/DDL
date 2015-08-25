CREATE OR REPLACE PROCEDURE LOAD_MB_DATA (uam in number, mb in number) 
is
    catcolid number;
    colobjid number;
begin
    --set define off;
    --set escape "\";
    select collection_object_id  into catcolid 
    from cataloged_item 
    where collection_id=6
    and cat_num= uam;
    
    select max(collection_object_id) + 1 into colobjid 
    from coll_object;

    insert into coll_object (
        COLLECTION_OBJECT_ID,
		COLL_OBJECT_TYPE,
		ENTERED_PERSON_ID,
		COLL_OBJECT_ENTERED_DATE,
		COLL_OBJ_DISPOSITION,
		LOT_COUNT,
		CONDITION) 
    values (
        colobjid,
		'IO',
		2072,
		sysdate,
		'not applicable',
		1,
		'not applicable');
		
    insert into binary_object (
        COLLECTION_OBJECT_ID,
		VIEWER_ID,
		DERIVED_FROM_CAT_ITEM,
		MADE_DATE,
		SUBJECT,
		description,
		FULL_URL,
		MADE_AGENT_ID)
    values (
		colobjid,
		1,
		catcolid,
		sysdate,
		'UAM Herb ' || uam,
		'Small JPG',
		'http://www.morphbank.net/Show/?imgType=jpg&id=' || mb,
		1016249);

    select max(collection_object_id) + 1 into colobjid 
    from coll_object;
    
    insert into coll_object (
		COLLECTION_OBJECT_ID,
		COLL_OBJECT_TYPE,
		ENTERED_PERSON_ID,
		COLL_OBJECT_ENTERED_DATE,
		COLL_OBJ_DISPOSITION,
		LOT_COUNT,
		CONDITION) 
    values (
		colobjid,
		'IO',
		2072,
		sysdate,
		'not applicable',
		1,
		'not applicable');

    insert into binary_object (
		COLLECTION_OBJECT_ID,
		VIEWER_ID,
		DERIVED_FROM_CAT_ITEM,
		MADE_DATE,
		SUBJECT,
		description,
		FULL_URL,
		MADE_AGENT_ID)
    values (
		colobjid,
		1,
		catcolid,
		sysdate,
		'UAM Herb ' || uam,
		'Large JPG',
		'http://www.morphbank.net/Show/?imgType=jpeg&id=' || mb,
		1016249);

    select max(collection_object_id) + 1 into colobjid 
    from coll_object;
    
    insert into coll_object (
		COLLECTION_OBJECT_ID,
		COLL_OBJECT_TYPE,
		ENTERED_PERSON_ID,
		COLL_OBJECT_ENTERED_DATE,
		COLL_OBJ_DISPOSITION,
		LOT_COUNT,
		CONDITION) 
    values (
		colobjid,
		'IO',
		2072,
		sysdate,
		'not applicable',
		1,
		'not applicable');

    insert into binary_object (
		COLLECTION_OBJECT_ID,
		VIEWER_ID,
		DERIVED_FROM_CAT_ITEM,
		MADE_DATE,
		SUBJECT,
		description,
		FULL_URL,
		MADE_AGENT_ID) 
    values (
		colobjid,
		1,
		catcolid,
		sysdate,
		'UAM Herb ' || uam,
		'TIFF',
		'http://www.morphbank.net/Show/?imgType=tiff&id=' || mb,
		1016249);
end;
/