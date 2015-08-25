

/*


-- populate this table via however
-- run procedure to do stuff
-- edit column, add stuff, edit procedure as necessary
-- current stuff:

select term from taxon_term where source='Arctos' group by term;


drop table cf_taxonomy_update;

create table cf_taxonomy_update (
	i$taxon_name_id number,
	i$status varchar2(4000),
	username varchar2(255) not null,
	scientific_name varchar2(255) not null,
	source varchar2(255) not null,
	author_text  varchar2(255),
	infraspecific_author varchar2(255),
	display_name  varchar2(255),
	nomenclatural_code  varchar2(255),
	source_authority  varchar2(255),
	valid_catalog_term_fg  varchar2(255),	
	kingdom  varchar2(255),
	phylum  varchar2(255),
	phylclass  varchar2(255),
	subclass  varchar2(255),
	infraclass varchar2(255),
	superorder  varchar2(255),
	phylorder  varchar2(255),
	suborder  varchar2(255),
	infraorder  varchar2(255),	
	family varchar2(255),
	subfamily varchar2(255),
	tribe varchar2(255),
	subtribe varchar2(255),
	genus varchar2(255),
	subgenus varchar2(255),
	species varchar2(255),
	subspecies  varchar2(255)
);
	
	
	
	insert into cf_taxonomy_update (
		username,
		scientific_name,
		source,
		author_text
	) values (
		'dlm',
		'Rattus rattus',
		'Arctos Plants',
		'DLM, Yo!'
	);
	
	
		insert into cf_taxonomy_update (
		username,
		scientific_name,
		source,
		author_text
	) values (
		'dlm',
		'Rattus norvegicus',
		'Arctos Plants',
		'DLM, Yo!'
	);
	-------------------------------------------------------------------------------------------------------------------







	 select term_type from taxon_term where source='Arctos' group by term_type order by term_type;



	

*/



CREATE OR REPLACE PROCEDURE update_tax_classification
IS
	noclassfld varchar2(4000);
	classfld varchar2(4000);
	v_taxon_name_id number;
	
  vStartIdx binary_integer;
  vEndIdx   binary_integer;
  vCurValue varchar2(1000);
  vCurTT varchar2(1000);
  
  
  
  ssql varchar2(4000);
  
 v_cls_id varchar2(4000);
 
  
BEGIN
	-- DELETE current classification
	-- CREATE new classification with data in this table
		
noclassfld:='author_text,infraspecific_author,display_name,nomenclatural_code,source_authority,valid_catalog_term_fg';
		
update cf_taxonomy_update set status='scientific_name not found' where scientific_name not in (select scientific_name from taxon_name);

update cf_taxonomy_update set status='username not found' where upper(username) not in (select upper(username) from cf_users);

update cf_taxonomy_update set status='source not found' where source not in (select source from CTTAXONOMY_SOURCE);


	
for r in (select * from cf_taxonomy_update where status is null) loop
	select taxon_name_id into v_taxon_name_id from taxon_name where scientific_name=r.scientific_name;
	delete from taxon_term where source=r.source and taxon_name_id=v_taxon_name_id;
	SELECT SYS_GUID() into v_cls_id FROM dual;
	
	
	ssql:='insert into taxon_term ( 
		TAXON_TERM_ID,
		TAXON_NAME_ID,
		CLASSIFICATION_ID,
		SOURCE,
		LASTDATE,
		POSITION_IN_CLASSIFICATION,
		TERM_TYPE,
		TERM
	) values (
		sq_taxon_term_id.nextval,
		v_taxon_name_id,
		v_cls_id,
		r.source,
		sysdate,
		NULL,
		vCurValue,
		vCurTT
	);
	
	CREATE PROCEDURE insert_into_table (
      table_name  VARCHAR2, 
      deptnumber  NUMBER, 
      deptname    VARCHAR2, 
      location    VARCHAR2) IS
   stmt_str    VARCHAR2(200);

BEGIN
   stmt_str := 'INSERT INTO ' || 
      table_name || ' values 
      (:deptno, :dname, :loc)';

   EXECUTE IMMEDIATE stmt_str 
      USING 
      deptnumber, deptname, location;

END;
/
SHOW ERRORS;




	-- ok, fine, Oracle dynamic SQL is a PITA - time for copypasta central....
	
	
	vCurTT:='boogity';
	vCurValue:='author_text';
	
	-- non-classification stuff first
	
	insert into taxon_term (
		TAXON_TERM_ID,
		TAXON_NAME_ID,
		CLASSIFICATION_ID,
		SOURCE,
		LASTDATE,
		POSITION_IN_CLASSIFICATION,
		TERM_TYPE,
		TERM
	) values (
		sq_taxon_term_id.nextval,
		v_taxon_name_id,
		v_cls_id,
		r.source,
		sysdate,
		NULL,
		vCurValue,
		vCurTT
	);
		
		
 
end loop;




  vStartIdx := 0;
  vEndIdx   := instr(noclassfld, ','); 

  while(vEndIdx > 0) loop
    vCurValue := substr(noclassfld, vStartIdx+1, vEndIdx - vStartIdx - 1);

    -- call proc here
    dbms_output.put_line('->'||vCurValue||'<-');

    vStartIdx := vEndIdx;
    vEndIdx := instr(noclassfld, ',', vStartIdx + 1);
    
    
  end loop;

  -- Call proc here for last part (or in case of single element)
  vCurValue := substr(noclassfld, vStartIdx+1);
  dbms_output.put_line('-------->'||vCurValue||'<-');





END;
/

sho err;


exec update_tax_classification;


select * from taxon_term where source='Arctos' and taxon_name_id=(select taxon_name_id from taxon_name where scientific_name='Sorex yukonicus');
