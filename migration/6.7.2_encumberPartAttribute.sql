

insert into CTENCUMBRANCE_ACTION (ENCUMBRANCE_ACTION,DESCRIPTION) values ('mask part attribute location','Hide and prevent finding specimens by part attribute "location."');

-- create encumbrance for uam:eh

insert into coll_object_encumbrance (ENCUMBRANCE_ID,COLLECTION_OBJECT_ID) (select 10000153,collection_object_id from cataloged_item where collection_id=76);


-- CREATE OR REPLACE VIEW filtered_flat AS....



update ssrch_field_doc set SEARCH_HINT='Integer or string, comma-list (1,3,7), or integer range (1-5). "%" matches any string, "_" any character. Prefix with "=" for exact match.' where cf_variable='cat_num';



---- update collecting_source for EH
-- copy over /DataServices/agents.cfm


-- add rights for /tools/mergeDuplicateEvents.cfm
