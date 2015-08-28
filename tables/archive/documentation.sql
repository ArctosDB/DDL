
  CREATE TABLE DOCUMENTATION
   (    DOC_ID NUMBER NOT NULL,
        DEFINITION VARCHAR2(4000) NOT NULL,
        COLNAME VARCHAR2(255) NOT NULL,
        DISPLAY_NAME VARCHAR2(255) NOT NULL,
        MORE_INFO VARCHAR2(255),
        SEARCH_HINT VARCHAR2(255)
   );
   
   CREATE PUBLIC SYNONYM DOCUMENTATION FOR DOCUMENTATION;
   CREATE UNIQUE INDEX UDOCCOLNAME ON UAM.DOCUMENTATION (COLNAME);
   
   DROP INDEX UDOCDISPNAME;
   
   

GRANT ALTER ON DOCUMENTATION TO UAM_QUERY;
GRANT DELETE ON DOCUMENTATION TO UAM_QUERY;
GRANT INDEX ON DOCUMENTATION TO UAM_QUERY;
GRANT INSERT ON DOCUMENTATION TO UAM_QUERY;
GRANT SELECT ON DOCUMENTATION TO UAM_QUERY;
GRANT UPDATE ON DOCUMENTATION TO UAM_QUERY;
GRANT REFERENCES ON DOCUMENTATION TO UAM_QUERY;
GRANT ON COMMIT REFRESH ON DOCUMENTATION TO UAM_QUERY;
GRANT QUERY REWRITE ON DOCUMENTATION TO UAM_QUERY;
GRANT DEBUG ON DOCUMENTATION TO UAM_QUERY;
GRANT FLASHBACK ON DOCUMENTATION TO UAM_QUERY;
GRANT ALTER ON DOCUMENTATION TO UAM_UPDATE;
GRANT DELETE ON DOCUMENTATION TO UAM_UPDATE;
GRANT INDEX ON DOCUMENTATION TO UAM_UPDATE;
GRANT INSERT ON DOCUMENTATION TO UAM_UPDATE;
GRANT SELECT ON DOCUMENTATION TO UAM_UPDATE;
GRANT UPDATE ON DOCUMENTATION TO UAM_UPDATE;
GRANT REFERENCES ON DOCUMENTATION TO UAM_UPDATE;
GRANT ON COMMIT REFRESH ON DOCUMENTATION TO UAM_UPDATE;
GRANT QUERY REWRITE ON DOCUMENTATION TO UAM_UPDATE;
GRANT DEBUG ON DOCUMENTATION TO UAM_UPDATE;
GRANT FLASHBACK ON DOCUMENTATION TO UAM_UPDATE;
CREATE OR REPLACE TRIGGER DOCUMENTATION_PKEY
before insert ON documentation
for each row
begin
    if :NEW.DOC_ID is null then
        select documentation_seq.nextval into :new.DOC_ID from dual;
    end if;
end;
ALTER TRIGGER DOCUMENTATION_PKEY ENABLE;