ALTER TABLE shipment ADD shipment_type VARCHAR2(60);

update shipment SET shipment_type='loan';

ALTER TABLE shipment MODIFY shipment_type NOT NULL;
    
create TABLE ctshipment_type (
    shipment_type VARCHAR2(60) NOT NULL,
    description VARCHAR2(4000)
);

CREATE PUBLIC SYNONYM ctshipment_type FOR ctshipment_type;
    
GRANT ALL ON ctshipment_type TO manage_codetables;

GRANT SELECT ON ctshipment_type TO PUBLIC;

alter table ctshipment_type add constraint PK_ctship_type PRIMARY KEY (shipment_type) using index TABLESPACE UAM_IDX_1;
    
INSERT INTO ctshipment_type (shipment_type,description) VALUES ('loan','entire loan leaving the institution');
INSERT INTO ctshipment_type (shipment_type,description) VALUES ('loan: partial','loan installment leaving the institution');
INSERT INTO ctshipment_type (shipment_type,description) VALUES ('loan: return','entire loan returning to the institution');
INSERT INTO ctshipment_type (shipment_type,description) VALUES ('loan: partial return','loan installment returning to the institution');
INSERT INTO ctshipment_type (shipment_type,description) VALUES ('borrow: incoming','material coming to the institution; external loan');
INSERT INTO ctshipment_type (shipment_type,description) VALUES ('borrow: returning','borrowed material being returned to the originating institution');

ALTER TABLE shipment add CONSTRAINT fk_ctshipment_type FOREIGN KEY (shipment_type) REFERENCES ctshipment_type(shipment_type);