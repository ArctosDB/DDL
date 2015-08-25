/* Will create a string of the form
Client.html?pageid=5929&publicationid=1911&otherid=116677&otheridtype=collection_object
which is to be added to the server location.
Using chr(38) instead of & since & is a reserved character which cannot
be escaped.
*/
CREATE OR REPLACE FUNCTION concatGrefLinksCollObj(baseurl in varchar2, collection_object_id IN number)
RETURN varchar2
        AS
        type rc is ref cursor;
        retval varchar2(4000);
	l_sep    varchar2(3);
	l_val    varchar2(4000);
	l_cur    rc;
BEGIN
      -- Check to make sure that the input is valid
      IF NOT (does_not_end_statement(collection_object_id)) THEN
        RETURN null
      end if;
      open l_cur for '
      select
          '':baseurl'' || ''Client.html?pageid='' || gref_roi_ng.page_id 
          || chr(38) || ''publicationid='' || book_section.publication_id 
          || chr(38) || ''otherid='' || oid
          || chr(38) || ''otheridtype=collection_object'' as the_link
        from
          gref_roi_ng, gref_roi_value_ng, book_section
        where
          book_section.book_id = gref_roi_ng.publication_id
          and gref_roi_value_ng.id = gref_roi_ng.roi_value_ng_id
          and gref_roi_ng.section_number = book_section.book_section_order
          and gref_roi_value_ng.collection_object_id = :1'
      using collection_object_id;
      loop
      	fetch l_cur into l_val;
      	exit when l_cur%notfound;
      	retval := retval || l_sep || l_val;
      	l_sep := ",";
      end loop;
      close l_cur;
      RETURN retval;
END;

CREATE PUBLIC SYNONYM concatGrefLinksCollObj FOR concatGrefLinksCollObj;
GRANT EXECUTE ON concatGrefLinksCollObj TO PUBLIC;