CREATE OR REPLACE FUNCTION getGuidFromID(collobjid IN number)
RETURN varchar2
AS
    retval VARCHAR2(100);
BEGIN
    SELECT guid_prefix || ':' || cat_num INTO retval
    FROM cataloged_item, collection
    WHERE 
    cataloged_item.collection_id=collection.collection_id and
    cataloged_item.collection_object_id=collobjid;
    
    RETURN retval;
END;
/

CREATE or replace PUBLIC SYNONYM getGuidFromID FOR getGuidFromID;
GRANT EXECUTE ON getGuidFromID TO PUBLIC;