ALTER TABLE shipment ADD shipment_id NUMBER;
CREATE SEQUENCE sq_shipment_id;
CREATE public SYNONYM sq_shipment_id FOR sq_shipment_id;
GRANT SELECT ON sq_shipment_id TO PUBLIC;

BEGIN
    FOR r IN (SELECT ROWID FROM shipment) LOOP
        UPDATE shipment SET shipment_id=sq_shipment_id.nextval WHERE ROWID=r.rowid;
    END LOOP;
END;
/


CREATE OR REPLACE TRIGGER trg_key_shipment
    BEFORE INSERT OR UPDATE ON shipment
    FOR EACH ROW
    BEGIN
        if :new.shipment_id is null then
        	select sq_shipment_id.nextval into :new.shipment_id from dual;
        end if;
    end;
/

ALTER TABLE shipment MODIFY shipment_id NOT NULL;

alter table shipment add constraint PK_shipment PRIMARY KEY (shipment_id) using index TABLESPACE UAM_IDX_1;