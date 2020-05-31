-- postgres
alter table collection add dwc_license_id bigint;

-- don't update everything, get that later

ALTER TABLE collection DISABLE TRIGGER tr_collection_au_flat;

-- temp table for later update
 

update collection set use_license_id=(select media_license_id from ctmedia_license where display = 'Arctos Data Ownership and Use') where use_license_id is null;
update collection set dwc_license_id=(select media_license_id from ctmedia_license where display = 'CC BY-NC');

ALTER TABLE collection enable TRIGGER tr_collection_au_flat;

ALTER TABLE collection ADD CONSTRAINT fk_collection_dwc_ctmedialic FOREIGN KEY (dwc_license_id) REFERENCES ctmedia_license(media_license_id);

ALTER TABLE collection ALTER COLUMN dwc_license_id SET NOT NULL;
ALTER TABLE collection ALTER COLUMN use_license_id SET NOT NULL;


-- oracle

alter table collection add use_license_id number;

alter trigger tr_collection_au_flat disable;



update collection set use_license_id=(select media_license_id from ctmedia_license where display = 'Arctos Data Ownership and Use') where use_license_id is null;
update collection set dwc_license_id=(select media_license_id from ctmedia_license where display = 'CC BY-NC');


alter trigger tr_collection_au_flat enable;

ALTER TABLE collection ADD CONSTRAINT fk_collection_dwc_ctmedialic FOREIGN KEY (dwc_license_id) REFERENCES ctmedia_license(media_license_id);


alter table collection modify use_license_id not null;
alter table collection modify dwc_license_id not null;



