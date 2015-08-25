CREATE TABLE project_taxonomy (
    project_taxon_id NUMBER NOT NULL,
    project_id NUMBER NOT NULL,
    taxon_name_id NUMBER NOT NULL
);

CREATE public SYNONYM project_taxonomy FOR project_taxonomy;

CREATE SEQUENCE sq_project_taxon_id;

CREATE OR REPLACE TRIGGER project_taxonomy_key                                         
 before insert  ON project_taxonomy
 for each row 
    begin     
    	if :NEW.project_taxon_id is null then                                                                                      
    		select sq_project_taxon_id.nextval into :new.project_taxon_id from dual;
    	end if;                                
    end;                                                                                            
/
    
ALTER TABLE project_taxonomy ADD constraint pk_project_taxon_id PRIMARY KEY (project_taxon_id);

ALTER TABLE project_taxonomy
add CONSTRAINT fk_projtax_proj
FOREIGN KEY (project_id)
REFERENCES project(project_id);
    
ALTER TABLE project_taxonomy
add CONSTRAINT fk_projtax_tax
FOREIGN KEY (taxon_name_id)
REFERENCES taxonomy(taxon_name_id);


GRANT SELECT ON project_taxonomy TO PUBLIC;
GRANT ALL ON project_taxonomy TO manage_publications;

CREATE UNIQUE INDEX idx_u_proj_tax ON project_taxonomy (project_id,taxon_name_id) TABLESPACE uam_idx_1;