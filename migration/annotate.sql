
CREATE TABLE annotations (
    ANNOTATION_ID NUMBER NOT NULL,
    ANNOTATE_DATE DATE DEFAULT SYSDATE NOT NULL,
    CF_USERNAME VARCHAR2(255),
    collection_object_id NUMBER,
    taxon_name_id NUMBER,
    project_id NUMBER,
    publication_id NUMBER,
    annotation VARCHAR2(255) NOT NULL,
    REVIEWER_AGENT_ID NUMBER,
    REVIEWED_FG NUMBER(1) DEFAULT 0 NOT NULL,
    REVIEWER_COMMENT VARCHAR2(255)
);


alter table annotations add constraint PK_annotations PRIMARY KEY (ANNOTATION_ID)
    using index TABLESPACE UAM_IDX_1;

alter table annotations add constraint FK_annotation_specimen FOREIGN KEY (collection_object_id)
REFERENCES cataloged_item (collection_object_id);

alter table annotations add constraint FK_annotation_taxa FOREIGN KEY (taxon_name_id)
REFERENCES taxonomy (taxon_name_id);

alter table annotations add constraint FK_annotation_project FOREIGN KEY (project_id)
REFERENCES project (project_id);

alter table annotations add constraint FK_annotation_publicn FOREIGN KEY (publication_id)
REFERENCES publication (publication_id);

alter table annotations add constraint FK_REVIEWER_AGENT_ID FOREIGN KEY (REVIEWER_AGENT_ID)
REFERENCES agent (AGENT_ID);

CREATE SEQUENCE sq_annotation_id;

CREATE OR REPLACE TRIGGER trg_key_annotations
    BEFORE INSERT OR UPDATE ON annotations
    FOR EACH ROW
    BEGIN
        if :new.ANNOTATION_ID is null then
        	select sq_annotation_id.nextval into :new.ANNOTATION_ID from dual;
        end if;
    end;
/

CREATE PUBLIC SYNONYM annotations FOR annotations;
GRANT SELECT ON annotations TO PUBLIC;
GRANT INSERT ON annotations TO cf_dbuser;
GRANT UPDATE ON annotations TO manage_collection;

INSERT INTO annotations (
    ANNOTATE_DATE,
    CF_USERNAME,
    collection_object_id,
    annotation,
    REVIEWER_AGENT_ID,
    REVIEWED_FG,
    REVIEWER_COMMENT ) 
    ( SELECT 
        nvl(ANNOTATE_DATE,SYSDATE),
        CF_USERNAME,
 		collection_object_id,
 		SCIENTIFIC_NAME,
 		REVIEWER_AGENT_ID,
 		REVIEWED_FG,
 		REVIEWER_COMMENT
 		FROM
 		specimen_annotations
 		WHERE
 		SCIENTIFIC_NAME IS NOT NULL
     );
 		    
INSERT INTO annotations (
    ANNOTATE_DATE,
    CF_USERNAME,
    collection_object_id,
    annotation,
    REVIEWER_AGENT_ID,
    REVIEWED_FG,
    REVIEWER_COMMENT ) 
    ( SELECT 
        nvl(ANNOTATE_DATE,SYSDATE),
        CF_USERNAME,
 		collection_object_id,
 		HIGHER_GEOGRAPHY,
 		REVIEWER_AGENT_ID,
 		REVIEWED_FG,
 		REVIEWER_COMMENT
 		FROM
 		specimen_annotations
 		WHERE
 		HIGHER_GEOGRAPHY IS NOT NULL
     );		    

INSERT INTO annotations (
    ANNOTATE_DATE,
    CF_USERNAME,
    collection_object_id,
    annotation,
    REVIEWER_AGENT_ID,
    REVIEWED_FG,
    REVIEWER_COMMENT ) 
    ( SELECT 
        nvl(ANNOTATE_DATE,SYSDATE),
        CF_USERNAME,
 		collection_object_id,
 		SPECIFIC_LOCALITY,
 		REVIEWER_AGENT_ID,
 		REVIEWED_FG,
 		REVIEWER_COMMENT
 		FROM
 		specimen_annotations
 		WHERE
 		SPECIFIC_LOCALITY IS NOT NULL
     );		

INSERT INTO annotations (
    ANNOTATE_DATE,
    CF_USERNAME,
    collection_object_id,
    annotation,
    REVIEWER_AGENT_ID,
    REVIEWED_FG,
    REVIEWER_COMMENT ) 
    ( SELECT 
        nvl(ANNOTATE_DATE,SYSDATE),
        CF_USERNAME,
 		collection_object_id,
 		ANNOTATION_REMARKS,
 		REVIEWER_AGENT_ID,
 		REVIEWED_FG,
 		REVIEWER_COMMENT
 		FROM
 		specimen_annotations
 		WHERE
 		ANNOTATION_REMARKS IS NOT NULL
     );		
     
    