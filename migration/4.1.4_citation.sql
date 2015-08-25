alter table citation add citation_id number;

create sequence sq_citation_id;

create or replace public synonym sq_citation_id for sq_citation_id;
    
grant select on sq_citation_id to public;

begin
	for r in (select rowid from citation) loop
		update citation set citation_id=sq_citation_id.nextval where rowid=r.rowid;
	end loop;
end;
/


ALTER TABLE citation add CONSTRAINT pk_citation PRIMARY KEY (citation_id);

CREATE OR REPLACE TRIGGER citation_trg before insert  ON citation  
    for each row 
    begin     
	    if :NEW.citation_id is null then                                                                                      
	    	select sq_citation_id.nextval into :new.citation_id from dual;
	    end if;                       
    end;                                                                                            
/
sho err
      
      
 ALTER TABLE citation ADD identification_id NUMBER;
 
 --crap....
      
 DELETE FROM identification_agent WHERE identification_id IN (SELECT identification_id FROM identification WHERE IDENTIFICATION_REMARKS LIKE 'ID from citation in %');

 DELETE FROM identification WHERE IDENTIFICATION_REMARKS LIKE 'ID from citation in %';
     
 ALTER TABLE citation DROP CONSTRAINT pk_citation_identification;
     
ALTER TABLE citation MODIFY IDENTIFICATION_ID NULL;
       
 UPDATE citation SET IDENTIFICATION_ID=NULL;
     
-------------

declare
	sname varchar2(4000);
	n number;
begin
	for r in (select * from citation where identification_id is null) loop
		select scientific_name into sname from taxonomy where taxon_name_id=r.CITED_TAXON_NAME_ID;
		insert into identification (
			 IDENTIFICATION_ID,
			 COLLECTION_OBJECT_ID,
			 NATURE_OF_ID,
			 ACCEPTED_ID_FG,
			 IDENTIFICATION_REMARKS,
			 TAXA_FORMULA,
			 SCIENTIFIC_NAME,
			 PUBLICATION_ID,
			 MADE_DATE
		) values (
			sq_IDENTIFICATION_ID.nextval,
			r.COLLECTION_OBJECT_ID,
			'type specimen',
			0,
			'ID from citation in ' || (SELECT short_citation FROM publication WHERE publication_id=r.publication_id) || '.',
			'A',
			sname,
			r.publication_id,
			r.REP_PUBLISHED_YEAR
		);
		INSERT INTO identification_taxonomy (
           IDENTIFICATION_ID,
           TAXON_NAME_ID,
              VARIABLE
       ) VALUES (
           sq_IDENTIFICATION_ID.currval,
           r.CITED_TAXON_NAME_ID,
           'A'
       );    
                                          
		n:=1;
		for a in (select * from publication_agent where PUBLICATION_ID=r.PUBLICATION_ID) loop
			insert into identification_agent (
				IDENTIFICATION_ID,
				AGENT_ID,
				IDENTIFIER_ORDER,
				IDENTIFICATION_AGENT_ID
			) values (
				sq_IDENTIFICATION_ID.currval,
				a.agent_id,
				n,
				sq_IDENTIFICATION_AGENT_ID.nextval
			);
			n:=n+1;
		end loop;
		update citation set identification_id=sq_IDENTIFICATION_ID.currval where citation_id=r.citation_id;
	end loop;
end;
/

ALTER TABLE citation MODIFY IDENTIFICATION_ID NOT NULL;
    
ALTER TABLE citation ADD CONSTRAINT pk_citation_identification FOREIGN KEY (IDENTIFICATION_ID) REFERENCES IDENTIFICATION(IDENTIFICATION_ID);

ALTER TABLE citation MODIFY CITED_TAXON_NAME_ID NULL;

CREATE OR REPLACE FUNCTION "UAM"."CONCATTYPESTATUS" (colobjod in NUMBER )
	return varchar2
	AS
		sname varchar2(4000);
		result varchar2(4000);
		tresult varchar2(4000);
		publink varchar2(4000);
		sep varchar2(2) := '';
	BEGIN
		FOR r IN (
			SELECT 
				identification.identification_id,
				type_status,
				identification.scientific_name,
				short_citation,
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
					scientific_name,
					display_name
				FROM 
					identification_taxonomy,
					taxonomy
				WHERE 
					identification_taxonomy.taxon_name_id=taxonomy.taxon_name_id AND
					identification_taxonomy.identification_id=r.identification_id
			) LOOP
				publink:=REPLACE(sname,t.scientific_name,'<a href="http://arctos.database.museum/name/' || t.scientific_name || '">' || t.display_name || '</a>');
			END LOOP;
			tresult:=r.TYPe_status || ' of ' || publink;
			IF r.OCCURS_PAGE_NUMBER IS NOT NULL THEN
				tresult:=tresult || ', page ' || r.OCCURS_PAGE_NUMBER;
			END IF;
			tresult:=tresult || ' in <a href="http://arctos.database.museum/publication/' || r.publication_id || '">';
			tresult:=tresult || r.short_citation || '</a>';
			result:=result || sep || tresult;
			sep:='; ';      
		END LOOP;
		RETURN result;
	END;
/

				    
								    