--arctos
CREATE OR REPLACE FUNCTION concatRelations (p_key_val IN VARCHAR2)
RETURN VARCHAR2
AS
    TYPE RC IS REF CURSOR;
    l_str    VARCHAR2(4000);
    l_sep    VARCHAR2(30);
    l_val    VARCHAR2(4000);
    l_cur    RC;
BEGIN
    OPEN l_cur FOR '
        SELECT
            biol_indiv_relationship ||
            ''\&nbsp;<a href="http://arctos.database.museum/guid/'' ||
            collection.guid_prefix || '':'' || cataloged_item.cat_num || ''">'' ||
             collection.guid_prefix || '':'' ||
             cataloged_item.cat_num || ''</a>''
        FROM biol_indiv_relations, cataloged_item,collection
        WHERE biol_indiv_relations.related_coll_object_id = cataloged_item.collection_object_id and
        cataloged_item.collection_id=collection.collection_id and
        biol_indiv_relations.collection_object_id  = :x'
        USING p_key_val;
    LOOP
        FETCH l_cur INTO l_val;
        EXIT WHEN l_cur%notfound;
        l_str := l_str || l_sep || l_val;
        l_sep := '; ';
    END LOOP;
    CLOSE l_cur;
    RETURN l_str;
END;
/
