create table publication20111122 as select * from publication;


ALTER TABLE publication ADD full_citation VARCHAR2(4000);
ALTER TABLE publication ADD short_citation VARCHAR2(4000);
ALTER TABLE publication ADD doi VARCHAR2(4000);

ALTER TABLE publication MODIFY publication_title NULL;
    
CREATE UNIQUE INDEX iu_publication_doi ON publication(doi) TABLESPACE uam_idx_1;

ALTER TABLE publication ADD pmid VARCHAR2(4000);
CREATE UNIQUE INDEX iu_publication_pmid ON publication(pmid) TABLESPACE uam_idx_1;


BEGIN
    FOR r IN (SELECT * FROM FORmatted_publication  WHERE FORmat_style='short') LOOP
        UPDATE publication SET short_citation=r.FORmatted_publication WHERE publication_id=r.publication_id;
    END LOOP;
    FOR r IN (SELECT * FROM FORmatted_publication  WHERE FORmat_style='long') LOOP
        UPDATE publication SET full_citation=r.FORmatted_publication WHERE publication_id=r.publication_id;
    END LOOP;  
    FOR r IN (SELECT * FROM publication_attributes  WHERE PUBLICATION_ATTRIBUTE='storage location') LOOP
        UPDATE publication SET publication_loc=r.PUB_ATT_VALUE WHERE publication_id=r.publication_id;
    END LOOP;
END;
/

SELECT
    full_citation,
    short_citation,
    FORmatted_publication
       FROM
       publication,FORmatted_publication
           WHERE FORmatted_publication.publication_id=publication.publication_id;
               
        
ALTER TABLE  publication MODIFY full_citation NOT NULL;
ALTER TABLE  publication MODIFY short_citation NOT NULL;
             
CREATE TABLE publication_agent (
    publication_agent_id NUMBER NOT NULL,
    publication_id NUMBER NOT NULL,
    agent_id NUMBER NOT NULL,
    author_role VARCHAR2(255) NOT NULL
);

CREATE PUBLIC SYNONYM publication_agent FOR publication_agent;
    GRANT ALL ON publication_agent TO manage_publications;
    GRANT SELECT ON publication_agent TO PUBLIC;
    
CREATE SEQUENCE sq_publication_agent_id;
CREATE PUBLIC SYNONYM sq_publication_agent_id FOR sq_publication_agent_id;

GRANT SELECT ON sq_publication_agent_id TO public;


CREATE OR REPLACE TRIGGER publication_agent_key                                         
 before insert  ON publication_agent
 for each row 
    begin     
    	if :NEW.publication_agent_id is null then                                                                                      
    		select sq_publication_agent_id.nextval into :new.publication_agent_id from dual;
    	end if;                                
    end;                                                                                            
/
sho err

ALTER TABLE publication_agent ADD constraint pk_publication_agent_id PRIMARY KEY (publication_agent_id);
ALTER TABLE publication_agent add CONSTRAINT fk_pub_agent_pub FOREIGN KEY (publication_id) REFERENCES publication(publication_id);
ALTER TABLE publication_agent add CONSTRAINT fk_pub_agent_agent FOREIGN KEY (agent_id) REFERENCES agent(agent_id);
ALTER TABLE publication_agent add CONSTRAINT fk_pub_agent_authrole FOREIGN KEY (author_role) REFERENCES ctauthor_role(author_role);

CREATE UNIQUE INDEX iu_publication_agent_oneper ON publication_agent (publication_id,agent_id) TABLESPACE uam_idx_1;
  	
INSERT INTO publication_agent (
      publication_id,
      agent_id,
      author_role
) (SELECT
    publication_author_name.PUBLICATION_ID,
    agent_name.agent_id,
    publication_author_name.AUTHOR_ROLE
    FROM
    publication_author_name,agent_name
    WHERE
    publication_author_name.AGENT_NAME_ID=agent_name.agent_name_id
    GROUP BY
     publication_author_name.PUBLICATION_ID,
    agent_name.agent_id,
    publication_author_name.AUTHOR_ROLE
)
;

CREATE TABLE project_agent20111122 AS SELECT * FROM project_agent;

ALTER TABLE project_agent DROP CONSTRAINT FK_PROJECTAGENT_AGENTNAME;
ALTER TABLE project_agent DROP CONSTRAINT PK_PROJECT_AGENT;

DROP INDEX 	IX_PROJECTAGENT_ANID;
DROP INDEX 	IX_PROJECTAGENT_PROJID;
DROP INDEX PK_PROJECT_AGENT;
    
ALTER TABLE project_agent ADD project_agent_id NUMBER;

CREATE SEQUENCE sq_project_agent_id;
CREATE PUBLIC SYNONYM sq_project_agent_id FOR sq_project_agent_id;
GRANT SELECT ON sq_project_agent_id TO public;

CREATE OR REPLACE TRIGGER project_agent_key                                         
 before insert  ON project_agent
 for each row 
    begin     
    	if :NEW.project_agent_id is null then                                                                                      
    		select sq_project_agent_id.nextval into :new.project_agent_id from dual;
    	end if;                                
    end;                                                                                            
/
sho err

BEGIN
    FOR r IN (SELECT ROWID FROM project_agent) LOOP
        UPDATE project_agent SET project_agent_id=sq_project_agent_id.nextval WHERE ROWID=r.rowid;
    END LOOP;
END;
/

ALTER TABLE project_agent MODIFY project_agent_id NOT NULL;
    
    
ALTER TABLE project_agent ADD agent_id NUMBER;
UPDATE project_agent SET agent_id= (SELECT agent_id FROM agent_name WHERE agent_name_id=project_agent.agent_name_id);
ALTER TABLE project_agent DROP COLUMN agent_name_id;

ALTER TABLE project_agent ADD constraint pk_project_agent_id PRIMARY KEY (project_agent_id);
ALTER TABLE project_agent add CONSTRAINT fk_proj_agent_proj FOREIGN KEY (project_id) REFERENCES project(project_id);
ALTER TABLE project_agent add CONSTRAINT fk_proj_agent_agent FOREIGN KEY (agent_id) REFERENCES agent(agent_id);
 
 alter table PROJECT_AGENT modify AGENT_NAME_ID null;
 
 
    
INSERT INTO project_agent (
    AGENT_ID,
    AGENT_POSITION,
    PROJECT_AGENT_REMARKS,
    PROJECT_AGENT_ROLE,
    PROJECT_ID
   ) (
   SELECT 
       agent_name.agent_id,
       99,
       ACKNOWLEDGEMENT,
       'Sponsor',
       project_sponsor.PROJECT_ID
      FROM
      project_sponsor,
      agent_name
      WHERE
      project_sponsor.agent_name_id=agent_name.agent_name_id
      GROUP BY
      agent_name.agent_id,
       ACKNOWLEDGEMENT,
       project_sponsor.PROJECT_ID
      );
      

alter table publication_author_name drop constraint fk_pubauthname_agentname;

drop trigger tr_agent_name_bu;

ALTER TABLE cf_temp_citation RENAME COLUMN publication_title TO full_citation;
 
      