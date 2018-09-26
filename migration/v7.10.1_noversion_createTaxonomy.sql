--no version for this, but the forms are in 7.10.1
alter table taxon_name add created_by_agent_id number;
alter table taxon_name add created_date date;

-- aiya...

select scientific_name from taxon_name where isValidTaxonName(scientific_name) != 'valid';
-- cleaned up in test and prod

update taxon_name set created_by_agent_id=0,created_date=sysdate;

CREATE OR REPLACE TRIGGER trg_taxon_name_biu....

ALTER TABLE taxon_name ADD CONSTRAINT fk_tax_create_agent FOREIGN KEY (created_by_agent_id) REFERENCES agent (agent_id);

alter table taxon_name modify created_by_agent_id not null;
alter table taxon_name modify created_date not null;


