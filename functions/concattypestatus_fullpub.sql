CREATE OR REPLACE FUNCTION CONCATTYPESTATUS_FULLPUB (colobjod in NUMBER )
	return varchar2
	AS
		sname varchar2(4000);
		result varchar2(4000);
		tresult varchar2(4000);
		publink varchar2(4000);
		sep varchar2(2) :='';
	BEGIN
		FOR r IN (
			SELECT 
				identification.identification_id,
				type_status,
				identification.scientific_name,
				full_citation,
				citation.publication_id,
				OCCURS_PAGE_NUMBER
			FROM
				citation,
				identification,
				publication
			WHERE
				citation.identification_id=identification.identification_id AND
				citation.publication_id=publication.publication_id AND
				citation.collection_object_id=colobjod
		) LOOP
			sname:=r.scientific_name;
			FOR t IN (
				SELECT 
					scientific_name
				FROM 
					identification_taxonomy,
					taxon_name
				WHERE 
					identification_taxonomy.taxon_name_id=taxon_name.taxon_name_id AND
					identification_taxonomy.identification_id=r.identification_id
			) LOOP
				publink:=REPLACE(sname,t.scientific_name,'<a href="http://arctos.database.museum/name/' || t.scientific_name || '">' || r.scientific_name || '</a>');
			END LOOP;
			tresult:=r.TYPe_status || ' of ' || publink;
			IF r.OCCURS_PAGE_NUMBER IS NOT NULL THEN
				tresult:=tresult || ', page ' || r.OCCURS_PAGE_NUMBER;
			END IF;
			tresult:=tresult || ' in <a href="http://arctos.database.museum/publication/' || r.publication_id || '">';
			tresult:=tresult || r.full_citation || '</a>';
			result:=result || sep || tresult;
			sep:='; ';      
		END LOOP;
		RETURN result;
	END;
/



CREATE OR REPLACE PUBLIC SYNONYM CONCATTYPESTATUS_FULLPUB FOR CONCATTYPESTATUS_FULLPUB;
GRANT EXECUTE ON CONCATTYPESTATUS_FULLPUB TO PUBLIC;

/