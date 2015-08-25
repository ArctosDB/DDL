/* Will create a string of the form
http://bg.berkeley.edu/Client.html?pageid=5929&publicationid=1911&otherid=116677&otheridtype=collection_object
Using chr(38) instead of & since & is a reserved character which cannot
be escaped.
*/
CREATE OR REPLACE FUNCTION concatGrefLinks(baseurl in varchar2, oidtype IN number, oid in varchar2)
RETURN varchar2
        AS
        type rc is ref cursor;
        retval varchar2(4000);
	l_sep    varchar2(3);
	l_val    varchar2(4000);
	l_cur    rc;
	the_statement varchar2(400);
BEGIN
      -- Check to make sure that the input is valid
      IF does_not_end_statement(oid) = 0 THEN
        RETURN null;
      end if;
      IF does_not_end_statement(oidtype) = 0 THEN
        RETURN null;
      end if;
      IF does_not_end_statement(baseurl) = 0 THEN
        RETURN null;
      end if;
      the_statement := '
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
          and gref_roi_value_ng.:oidtype = :oid';
      open l_cur for the_statement
      	using baseurl, oidtype, oid;
      loop
      	fetch l_cur into l_val;
      	exit when l_cur%notfound;
      	retval := retval || l_sep || l_val;
      	l_sep := ',';
      end loop;
      close l_cur;
      RETURN retval;
END;

CREATE PUBLIC SYNONYM concatGrefLinks FOR concatGrefLinks;
GRANT EXECUTE ON concatGrefLinks TO PUBLIC;