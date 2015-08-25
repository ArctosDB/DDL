CREATE TABLE geology_attributes (
    geology_attribute_id NUMBER NOT NULL,
    locality_id NUMBER NOT NULL,
    geology_attribute varchar2(255) NOT NULL,
    geo_att_value VARCHAR2(255) NOT NULL,
    geo_att_determiner_id NUMBER,
    geo_att_determined_date DATE,
    geo_att_determined_method VARCHAR2(255),
    geo_att_remark VARCHAR2(4000)
   );
   
ALTER TABLE geology_attributes
    add CONSTRAINT pk_geology_attributes
    PRIMARY  KEY (geology_attribute_id);

ALTER TABLE geology_attributes
    add CONSTRAINT fk_geology_locality
    FOREIGN KEY (locality_id)
    REFERENCES locality(locality_id);
           
create sequence seq_geology_attributes;
CREATE PUBLIC SYNONYM seq_geology_attributes FOR seq_geology_attributes;
GRANT SELECT ON seq_geology_attributes TO PUBLIC;

CREATE OR REPLACE TRIGGER geology_attributes_seq before insert ON geology_attributes for each row
   begin     
       IF :new.geology_attribute_id IS NULL THEN
           select seq_geology_attributes.nextval into :new.geology_attribute_id from dual;
       END IF;
   end;                                                                                            
/
sho err

create public synonym geology_attributes for geology_attributes;
    
grant select on geology_attributes to public;

grant insert,update,delete on geology_attributes to manage_locality;


------------------------------- bulkloader ---------------------------------------------------
DECLARE s VARCHAR2(4000);
BEGIN
    FOR i IN 1..6 LOOP
        s:='ALTER TABLE bulkloader add  geology_attribute_' || i || ' varchar2(255)';
        EXECUTE IMMEDIATE(s);
        s:='ALTER TABLE bulkloader add  geo_att_value_' || i || ' varchar2(255)';
        EXECUTE IMMEDIATE(s);
        s:='ALTER TABLE bulkloader add  geo_att_determiner_' || i || ' varchar2(255)';
        EXECUTE IMMEDIATE(s);
        s:='ALTER TABLE bulkloader add  geo_att_determined_date_' || i || ' varchar2(255)';
        EXECUTE IMMEDIATE(s);
        s:='ALTER TABLE bulkloader add  geo_att_determined_method_' || i || ' varchar2(255)';
        EXECUTE IMMEDIATE(s);
        s:='ALTER TABLE bulkloader add  geo_att_remark_' || i || ' varchar2(4000)';
        EXECUTE IMMEDIATE(s);    
    END LOOP;
END;
/
sho err;

DECLARE s VARCHAR2(4000);
BEGIN
    FOR i IN 1..6 LOOP
        s:='ALTER TABLE bulkloader_deletes add  geology_attribute_' || i || ' varchar2(255)';
        EXECUTE IMMEDIATE(s);
        s:='ALTER TABLE bulkloader_deletes add  geo_att_value_' || i || ' varchar2(255)';
        EXECUTE IMMEDIATE(s);
        s:='ALTER TABLE bulkloader_deletes add  geo_att_determiner_' || i || ' varchar2(255)';
        EXECUTE IMMEDIATE(s);
        s:='ALTER TABLE bulkloader_deletes add  geo_att_determined_date_' || i || ' varchar2(255)';
        EXECUTE IMMEDIATE(s);
        s:='ALTER TABLE bulkloader_deletes add  geo_att_determined_method_' || i || ' varchar2(255)';
        EXECUTE IMMEDIATE(s);
        s:='ALTER TABLE bulkloader_deletes add  geo_att_remark_' || i || ' varchar2(4000)';
        EXECUTE IMMEDIATE(s);    
    END LOOP;
END;
/
sho err;

DECLARE s VARCHAR2(4000);
BEGIN
    FOR i IN 1..6 LOOP
        s:='ALTER TABLE bulkloader_stage add  geology_attribute_' || i || ' varchar2(255)';
        EXECUTE IMMEDIATE(s);
        s:='ALTER TABLE bulkloader_stage add  geo_att_value_' || i || ' varchar2(255)';
        EXECUTE IMMEDIATE(s);
        s:='ALTER TABLE bulkloader_stage add  geo_att_determiner_' || i || ' varchar2(255)';
        EXECUTE IMMEDIATE(s);
        s:='ALTER TABLE bulkloader_stage add  geo_att_determined_date_' || i || ' varchar2(255)';
        EXECUTE IMMEDIATE(s);
        s:='ALTER TABLE bulkloader_stage add  geo_att_determined_method_' || i || ' varchar2(255)';
        EXECUTE IMMEDIATE(s);
        s:='ALTER TABLE bulkloader_stage add  geo_att_remark_' || i || ' varchar2(4000)';
        EXECUTE IMMEDIATE(s);    
    END LOOP;
END;
/
sho err;

CREATE TABLE geology_attribute_hierarchy (
    geology_attribute_hierarchy_id NUMBER NOT NULL,
    parent_id NUMBER,                                
    attribute VARCHAR2(255) NOT NULL,
    attribute_value VARCHAR2(255) NOT NULL,
    usable_value_fg NUMBER NOT NULL,
    description VARCHAR2(4000)    
    );
ALTER TABLE geology_attribute_hierarchy
    add CONSTRAINT pk_geology_attribute_hierarchy
    PRIMARY  KEY (geology_attribute_hierarchy_id);
ALTER TABLE geology_attribute_hierarchy
    add CONSTRAINT fk_geology_attribute_hierarchy
    FOREIGN KEY (parent_id)
    REFERENCES geology_attribute_hierarchy(geology_attribute_hierarchy_id);

ALTER TABLE geology_attribute_hierarchy 
    add CONSTRAINT geo_att_h_usable_ck 
    CHECK (usable_value_fg IN (0,1));

CREATE UNIQUE INDEX u_geo_att_hierarchy_att_val ON geology_attribute_hierarchy(attribute_value);
CREATE OR REPLACE TRIGGER geol_att_hierarchy_seq before insert ON geology_attribute_hierarchy for each row
   begin     
       IF :new.geology_attribute_hierarchy_id IS NULL THEN
           select somerandomsequence.nextval into :new.geology_attribute_hierarchy_id from dual;
       END IF;
   end;                                                                                            
/
sho err
create public synonym geology_attribute_hierarchy for geology_attribute_hierarchy;
grant select on geology_attribute_hierarchy to public;
grant insert,update,delete on geology_attribute_hierarchy to manage_codetables; 
    
                      
/* view doesn't work well 
CREATE OR REPLACE VIEW ctgeology_attribute 
     AS SELECT attribute geology_attribute
     FROM geology_attribute_hierarchy 
     WHERE usable_value_fg=1
     GROUP BY attribute;
*/
CREATE OR REPLACE TABLE ctgeology_attribute 
     AS SELECT attribute geology_attribute
     FROM geology_attribute_hierarchy 
     WHERE usable_value_fg=1
     GROUP BY attribute;

create OR REPLACE public synonym ctgeology_attribute for ctgeology_attribute;
grant select on ctgeology_attribute to public;
ALTER TABLE ctgeology_attribute
    add CONSTRAINT pk_ctgeology_attribute
    PRIMARY  KEY (attribute);
    
CREATE OR REPLACE TRIGGER CTGEOLOGY_ATTRIBUTES_CHECK
BEFORE UPDATE or DELETE ON geology_attribute_hierarchy
    FOR EACH ROW
    declare
    pragma autonomous_transaction;
    numrows number:=0;
    BEGIN
        SELECT COUNT(*) INTO numrows FROM geology_attribute_hierarchy WHERE attribute=:OLD.attribute
        AND GEOLOGY_ATTRIBUTE_HIERARCHY_ID != :OLD.GEOLOGY_ATTRIBUTE_HIERARCHY_ID;
        dbms_output.put_line(numrows);
        -- we only care about deleting the LAST value from the code table
        IF numrows=0 THEN
            IF updating THEN
                IF :OLD.attribute != :NEW.attribute OR (:OLD.usable_value_fg=1 AND :NEW.usable_value_fg=0) THEN
                    SELECT COUNT(*) INTO numrows FROM geology_attributes WHERE geology_attribute = :OLD.attribute;               
                END IF;
            ELSE
                SELECT COUNT(*) INTO numrows FROM geology_attributes WHERE geology_attribute = :OLD.attribute;
            END IF;
            IF numrows > 0 THEN
            	 raise_application_error(
                    -20001,
                    'Cannot update or delete used geology_attribute.'
                  );
            END IF;
        END IF;
        COMMIT;
        
END;
/
sho err


CREATE OR REPLACE TRIGGER geology_attributes_check
    before UPDATE or INSERT ON geology_attributes
    for each row
    declare
    numrows number;
    BEGIN
    SELECT COUNT(*) INTO numrows FROM geology_attribute_hierarchy WHERE attribute = :NEW.geology_attribute;
    	IF (numrows = 0) THEN
    		 raise_application_error(
    	        -20001,
    	        'Invalid geology_attribute'
    	      );
    	END IF;
END;
/


CREATE OR REPLACE TRIGGER ctgeology_attributes_check
AFTER UPDATE or DELETE ON geology_attribute_hierarchy
    for each row
    declare
    numrows number:=0;
    BEGIN
        IF updating THEN
            IF :OLD.attribute != :NEW.attribute OR (:OLD.usable_value_fg=1 AND :NEW.usable_value_fg=0) THEN
                SELECT COUNT(*) INTO numrows FROM geology_attributes WHERE geology_attribute = :OLD.attribute;
            END IF;
        ELSE
            SELECT COUNT(*) INTO numrows FROM geology_attributes WHERE geology_attribute = :OLD.attribute;
        END IF;
        IF numrows > 0 THEN
        	 raise_application_error(
                -20001,
                'Cannot update or delete used geology_attribute.'
              );
        END IF;
END;
/

/* stuff this uses:

editLocality.cfm has changed and needs to be brought into any version supporting Geology
function b_concatGeologyAttributeDetail IS NEW
function concatGeologyAttributeDetail is new
view loc_acc_lat_long
package bulkload needs replaced with bulkload_withGeol.sql
*/

