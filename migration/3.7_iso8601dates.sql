-- run /functions/is_is08601.sql

-- this UPDATE applies ONLY TO began AND ended dates
-- disable CHECK_FLAT_STALE




CREATE OR REPLACE TRIGGER "SYS".TR_ON_LOGON AFTER
LOGON ON DATABASE BEGIN
-- Set appropriate security based on username.
    UAM.APP_SECURITY_CONTEXT.SET_USER_INFO();
    --DBMS_SESSION.SET_NLS('NLS_DATE_FORMAT', 'yyyy-mm-dd');
     execute immediate 'alter session set nls_date_format = ''yyyy-mm-dd'' ';
END;


ALTER TABLE collecting_event ADD iso_began_date VARCHAR2(22);
ALTER TABLE collecting_event ADD iso_ended_date VARCHAR2(22);

UPDATE collecting_event SET iso_began_date=to_char(began_date,'YYYY-MM-DD');
UPDATE collecting_event SET iso_ended_date=to_char(ended_date,'YYYY-MM-DD');

ALTER TABLE collecting_event RENAME COLUMN began_date TO date_began_date;
ALTER TABLE collecting_event RENAME COLUMN ended_date TO date_ended_date;
ALTER TABLE collecting_event RENAME COLUMN iso_began_date TO began_date;
ALTER TABLE collecting_event RENAME COLUMN iso_ended_date TO ended_date;

alter table collecting_event modify DATE_BEGAN_DATE null;
alter table collecting_event modify DATE_ENDED_DATE null;

UPDATE bulkloader SET made_date=to_char(to_date(made_date,'dd-Mon-yyyy'),'yyyy-mm-dd') WHERE isdate(made_date)=1;
UPDATE bulkloader SET BEGAN_DATE=to_char(to_date(BEGAN_DATE,'dd-Mon-yyyy'),'yyyy-mm-dd') WHERE isdate(BEGAN_DATE)=1;
UPDATE bulkloader SET ENDED_DATE=to_char(to_date(ENDED_DATE,'dd-Mon-yyyy'),'yyyy-mm-dd') WHERE isdate(ENDED_DATE)=1;

UPDATE bulkloader SET DETERMINED_DATE=to_char(to_date(DETERMINED_DATE,'dd-Mon-yyyy'),'yyyy-mm-dd') WHERE isdate(DETERMINED_DATE)=1;

UPDATE bulkloader SET ATTRIBUTE_DATE_1=to_char(to_date(ATTRIBUTE_DATE_1,'dd-Mon-yyyy'),'yyyy-mm-dd') WHERE isdate(ATTRIBUTE_DATE_1)=1;
UPDATE bulkloader SET ATTRIBUTE_DATE_2=to_char(to_date(ATTRIBUTE_DATE_2,'dd-Mon-yyyy'),'yyyy-mm-dd') WHERE isdate(ATTRIBUTE_DATE_2)=1;
UPDATE bulkloader SET ATTRIBUTE_DATE_3=to_char(to_date(ATTRIBUTE_DATE_3,'dd-Mon-yyyy'),'yyyy-mm-dd') WHERE isdate(ATTRIBUTE_DATE_3)=1;
UPDATE bulkloader SET ATTRIBUTE_DATE_4=to_char(to_date(ATTRIBUTE_DATE_4,'dd-Mon-yyyy'),'yyyy-mm-dd') WHERE isdate(ATTRIBUTE_DATE_4)=1;
UPDATE bulkloader SET ATTRIBUTE_DATE_5=to_char(to_date(ATTRIBUTE_DATE_5,'dd-Mon-yyyy'),'yyyy-mm-dd') WHERE isdate(ATTRIBUTE_DATE_5)=1;
UPDATE bulkloader SET ATTRIBUTE_DATE_6=to_char(to_date(ATTRIBUTE_DATE_6,'dd-Mon-yyyy'),'yyyy-mm-dd') WHERE isdate(ATTRIBUTE_DATE_6)=1;
UPDATE bulkloader SET ATTRIBUTE_DATE_7=to_char(to_date(ATTRIBUTE_DATE_7,'dd-Mon-yyyy'),'yyyy-mm-dd') WHERE isdate(ATTRIBUTE_DATE_7)=1;
UPDATE bulkloader SET ATTRIBUTE_DATE_8=to_char(to_date(ATTRIBUTE_DATE_8,'dd-Mon-yyyy'),'yyyy-mm-dd') WHERE isdate(ATTRIBUTE_DATE_8)=1;
UPDATE bulkloader SET ATTRIBUTE_DATE_9=to_char(to_date(ATTRIBUTE_DATE_9,'dd-Mon-yyyy'),'yyyy-mm-dd') WHERE isdate(ATTRIBUTE_DATE_9)=1;
UPDATE bulkloader SET ATTRIBUTE_DATE_10=to_char(to_date(ATTRIBUTE_DATE_10,'dd-Mon-yyyy'),'yyyy-mm-dd') WHERE isdate(ATTRIBUTE_DATE_10)=1;



UPDATE bulkloader SET GEO_ATT_DETERMINED_DATE_1=to_char(to_date(GEO_ATT_DETERMINED_DATE_1,'dd-Mon-yyyy'),'yyyy-mm-dd') WHERE isdate(GEO_ATT_DETERMINED_DATE_1)=1;
UPDATE bulkloader SET GEO_ATT_DETERMINED_DATE_2=to_char(to_date(GEO_ATT_DETERMINED_DATE_2,'dd-Mon-yyyy'),'yyyy-mm-dd') WHERE isdate(GEO_ATT_DETERMINED_DATE_2)=1;
UPDATE bulkloader SET GEO_ATT_DETERMINED_DATE_3=to_char(to_date(GEO_ATT_DETERMINED_DATE_3,'dd-Mon-yyyy'),'yyyy-mm-dd') WHERE isdate(GEO_ATT_DETERMINED_DATE_3)=1;
UPDATE bulkloader SET GEO_ATT_DETERMINED_DATE_4=to_char(to_date(GEO_ATT_DETERMINED_DATE_4,'dd-Mon-yyyy'),'yyyy-mm-dd') WHERE isdate(GEO_ATT_DETERMINED_DATE_4)=1;
UPDATE bulkloader SET GEO_ATT_DETERMINED_DATE_5=to_char(to_date(GEO_ATT_DETERMINED_DATE_5,'dd-Mon-yyyy'),'yyyy-mm-dd') WHERE isdate(GEO_ATT_DETERMINED_DATE_5)=1;
UPDATE bulkloader SET GEO_ATT_DETERMINED_DATE_6=to_char(to_date(GEO_ATT_DETERMINED_DATE_6,'dd-Mon-yyyy'),'yyyy-mm-dd') WHERE isdate(GEO_ATT_DETERMINED_DATE_6)=1;


ALTER TABLE flat ADD iso_began_date VARCHAR2(22);
ALTER TABLE flat ADD iso_ended_date VARCHAR2(22);

UPDATE flat SET iso_began_date=to_char(began_date,'YYYY-MM-DD');
UPDATE flat SET iso_ended_date=to_char(ended_date,'YYYY-MM-DD');


ALTER TABLE flat RENAME COLUMN began_date TO date_began_date;
ALTER TABLE flat RENAME COLUMN ended_date TO date_ended_date;
ALTER TABLE flat RENAME COLUMN iso_began_date TO began_date;
ALTER TABLE flat RENAME COLUMN iso_ended_date TO ended_date;


CREATE OR REPLACE TRIGGER trg_collectingEventDate
BEFORE INSERT OR UPDATE ON collecting_event
FOR EACH ROW
	declare status varchar2(255);
BEGIN
    status:=is_iso8601(:NEW.began_date);
    IF status != 'valid' THEN
        raise_application_error(-20001,'Began Date: ' || status);
    END IF;
    status:=is_iso8601(:NEW.ended_date);
    IF status != 'valid' THEN
        raise_application_error(-20001,'Ended Date: ' || status);
    END IF;
    IF :NEW.began_date>:NEW.ended_date THEN
        raise_application_error(-20001,'Began Date can not occur after Ended Date.');
    END IF;
END;
/

-- rebuild filtered_flat


CREATE OR REPLACE VIEW filtered_flat AS
    SELECT
        collection_object_id,
        cat_num,
        accn_id,
        institution_acronym,
        collection_cde,
        collection_id,
        collection,
        minimum_elevation,
        maximum_elevation,
        orig_elev_units,
        identification_id,
        last_edit_date,
        individualcount,
        coll_obj_disposition,
        -- mask collector
        CASE
            WHEN encumbrances LIKE '%mask collector%'
            THEN 'Anonymous'
            ELSE collectors
        END collectors,
        -- mask original field number
        CASE
            WHEN encumbrances LIKE '%mask original field number%'
            THEN 'Anonymous'
            ELSE field_num
        END field_num,
        otherCatalogNumbers,
        genbankNum,
        relatedCatalogedItemS,
        typeStatus,
        sex,
        parts,
        partdetail,
        accession,
        -- mask original field number
        CASE
            WHEN encumbrances LIKE '%mask year collected%'
            THEN replace(began_date,substr(began_date,1,4),'8888')
            ELSE began_date
        END began_date,
        CASE
            WHEN encumbrances LIKE '%mask year collected%'
            THEN replace(ended_date,substr(ended_date,1,4),'8888')
            ELSE ended_date
        END ended_date,
        CASE
            WHEN encumbrances LIKE '%mask year collected%'
            THEN 'Masked'
            ELSE verbatim_date
        END verbatim_date,
        collecting_event_id,
        higher_geog,
        continent_ocean,
        country,
        state_prov,
        county,
        feature,
        island,
        island_group,
        quad,
        sea,
        geog_auth_rec_id,
        spec_locality,
        min_elev_in_m,
        max_elev_in_m ,
        locality_id,
        -- mask coordinates
        CASE
            WHEN encumbrances LIKE '%mask coordinates%'
            THEN NULL
            ELSE dec_lat
        END dec_lat,
        CASE
            WHEN encumbrances LIKE '%mask coordinates%'
            THEN NULL
            ELSE dec_long
        END dec_long,
        datum,
        orig_lat_long_units,
        CASE
            WHEN encumbrances LIKE '%mask coordinates%'
            THEN 'Masked'
            ELSE verbatimlatitude
        END verbatimlatitude,
        CASE
            WHEN encumbrances LIKE '%mask coordinates%'
            THEN 'Masked'
            ELSE verbatimlongitude
        END verbatimlongitude,
        lat_long_ref_source,
        coordinateuncertaintyinmeters,
        georefmethod,
        lat_long_remarks,
        lat_long_determiner,
        scientific_name,
        identifiedby,
        made_date,
        remarks,
        habitat,
        associated_species,
        encumbrances,
        taxa_formula,
        full_taxon_name,
        phylClass,
        kingdom,
        phylum,
        phylOrder,
        family,
        genus,
        species,
        subspecies,
        infraspecific_rank,
        author_text,
        identificationModifier,
        nomenclatural_code,
        guid,
        basisOfRecord,
        depth_units,
        min_depth,
        max_depth,
        min_depth_in_m,
        max_depth_in_m,
        collecting_method,
        collecting_source,
        dayOfYear,
        age_class,
        attributes,
        verificationStatus,
        specimenDetailUrl,
        imageUrl,
        fieldNotesUrl,
        catalogNumberText,
        '<a href="http://arctos.database.museum/guid/' || guid || '">' || guid || '</a>'  RelatedInformation,
        collectorNumber,
        verbatimelEvation,
        CASE
            WHEN encumbrances LIKE '%mask year collected%'
            THEN 8888
            ELSE year
        END year,
        month,
        day,
        '' emptystring
    FROM
        flat
    WHERE
    -- exclude masked records
        (encumbrances is null OR encumbrances NOT LIKE '%mask record%');



CREATE OR REPLACE PROCEDURE UPDATE_FLAT (collobjid IN NUMBER) IS
BEGIN
	UPDATE flat
	SET (
			cat_num,
			accn_id,
			collecting_event_id,
			collection_cde,
			collection_id,
			catalognumbertext,
			institution_acronym,
			collection,
			began_date,
			ended_date,
			verbatim_date,
			last_edit_date,
			individualCount,
			coll_obj_disposition,
			collectors,
			field_num,
			otherCatalogNumbers,
			genbankNum,
			relatedCatalogedItems,
			typeStatus,
			sex,
			parts,
			partdetail,
			encumbrances,
			accession,
			geog_auth_rec_id,
			higher_geog,
			continent_ocean,
			country,
			state_prov,
			county,
			feature,
			island,
			island_group,
			quad,
			sea,
			locality_id,
			spec_locality,
			minimum_elevation,
			maximum_elevation,
			orig_elev_units,
			min_elev_in_m,
			max_elev_in_m,
			dec_lat,
			dec_long,
			datum,
			orig_lat_long_units,
			verbatimLatitude,
			verbatimLongitude,
			lat_long_ref_source,
			coordinateUncertaintyInMeters,
			georefMethod,
			lat_long_remarks,
			lat_long_determiner,
			identification_id,
			scientific_name,
			identifiedby,
			made_date,
			remarks,
			habitat,
			associated_species,
			taxa_formula,
			full_taxon_name,
			phylclass,
			kingdom,
			phylum,
			phylOrder,
			family,
			genus,
			species,
			subspecies,
			author_text,
			nomenclatural_code,
			infraspecific_rank,
			identificationModifier,
			guid,
			basisOfRecord,
			depth_units,
			min_depth,
			max_depth,
			min_depth_in_m,
			max_depth_in_m,
			collecting_method,
			collecting_source,
			dayOfYear,
			age_class,
			attributes,
			verificationStatus,
			specimenDetailUrl,
			imageUrl,
			fieldNotesUrl,
			collectorNumber,
			verbatimElevation,
			year,
			month,
			day) = (
		SELECT
			cataloged_item.cat_num,
			cataloged_item.accn_id,
			cataloged_item.collecting_event_id,
			collection.collection_cde,
			cataloged_item.collection_id,
			to_char(cataloged_item.cat_num),
			collection.institution_acronym,
			collection.collection,
			collecting_event.began_date,
			collecting_event.ended_date,
			collecting_event.verbatim_date,
			DECODE(coll_object.last_edit_date,
				NULL, coll_object.coll_object_entered_date,
				coll_object.last_edit_date),
			coll_object.lot_count,
			coll_object.coll_obj_disposition,
			concatColl(cataloged_item.collection_object_id),
			concatSingleOtherId(cataloged_item.collection_object_id, 'Field Num'),
			concatOtherId(cataloged_item.collection_object_id),
			concatGenbank(cataloged_item.collection_object_id),
			concatRelations(cataloged_item.collection_object_id),
			concatTypeStatus(cataloged_item.collection_object_id),
			concatAttributeValue(cataloged_item.collection_object_id, 'sex'),
			concatParts(cataloged_item.collection_object_id),
			concatPartsDetail(cataloged_item.collection_object_id),
			concatEncumbrances(cataloged_item.collection_object_id),
			accn.accn_number,
			geog_auth_rec.geog_auth_rec_id,
			geog_auth_rec.higher_geog,
			geog_auth_rec.continent_ocean,
			geog_auth_rec.country,
			geog_auth_rec.state_prov,
			geog_auth_rec.county,
			geog_auth_rec.feature,
			geog_auth_rec.island,
			geog_auth_rec.island_group,
			geog_auth_rec.quad,
			geog_auth_rec.sea,
			locality.locality_id,
			locality.spec_locality,
			locality.minimum_elevation,
			locality.maximum_elevation,
			locality.orig_elev_units,
			to_meters(locality.minimum_elevation, locality.orig_elev_units),
			to_meters(locality.maximum_elevation, locality.orig_elev_units),
			accepted_lat_long.dec_lat,
			accepted_lat_long.dec_long,
			accepted_lat_long.datum,
			accepted_lat_long.orig_lat_long_units,
			decode(accepted_lat_long.orig_lat_long_units,
				'decimal degrees',
					to_char(accepted_lat_long.dec_lat) || 'd',
				'deg. min. sec.',
					to_char(accepted_lat_long.lat_deg) || 'd ' ||
					to_char(accepted_lat_long.lat_min) || 'm ' ||
					to_char(accepted_lat_long.lat_sec) || 's ' ||
					accepted_lat_long.lat_dir,
				'degrees dec. minutes',
					to_char(accepted_lat_long.lat_deg) || 'd ' ||
					to_char(accepted_lat_long.dec_lat_min) || 'm ' ||
					accepted_lat_long.lat_dir),
			decode(accepted_lat_long.orig_lat_long_units,
				'decimal degrees',
					to_char(accepted_lat_long.dec_long) || 'd',
				'deg. min. sec.',
					to_char(accepted_lat_long.long_deg) || 'd ' ||
					to_char(accepted_lat_long.long_min) || 'm ' ||
					to_char(accepted_lat_long.long_sec) || 's ' ||
					accepted_lat_long.long_dir,
				'degrees dec. minutes',
					to_char(accepted_lat_long.long_deg) || 'd ' ||
					to_char(accepted_lat_long.dec_long_min) || 'm ' ||
					accepted_lat_long.long_dir),
			accepted_lat_long.lat_long_ref_source,
			to_meters(accepted_lat_long.max_error_distance, accepted_lat_long.max_error_units),
			accepted_lat_long.georefmethod,
			accepted_lat_long.lat_long_remarks,
			lldetr.agent_name,
			identification.identification_id,
			identification.scientific_name,
			concatidentifiers(cataloged_item.collection_object_id),
			identification.made_date,
			coll_object_remark.coll_object_remarks,
			coll_object_remark.habitat,
			coll_object_remark.associated_species,
			taxa_formula,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'full_taxon_name')
				ELSE full_taxon_name
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'phylclass')
				ELSE phylclass
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'Kingdom')
				ELSE kingdom
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'Phylum')
				ELSE phylum
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'phylOrder')
				ELSE phylOrder
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'Family')
				ELSE family
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'Genus')
				ELSE genus
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'Species')
				ELSE species
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'Subspecies')
				ELSE subspecies
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'author_text')
				ELSE author_text
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'nomenclatural_code')
				ELSE nomenclatural_code
			END,
			CASE WHEN taxa_formula LIKE '%B'
				THEN get_taxonomy(cataloged_item.collection_object_id, 'infraspecific_rank')
				ELSE infraspecific_rank
			END,
			' ',
			collection.guid_prefix || ':' ||
			cataloged_item.cat_num,
			decode(coll_object.coll_object_type,
				'CI', 'PreservedSpecimen',
				'HO', 'HumanObservation',
				'OtherSpecimen'),
			locality.depth_units,
			locality.min_depth,
			locality.max_depth,
			to_meters(locality.min_depth,locality.depth_units),
			to_meters(locality.max_depth,locality.depth_units),
			collecting_event.collecting_method,
			collecting_event.collecting_source,
			decode(collecting_event.began_date,
				collecting_event.ended_date, to_number(substr(collecting_event.began_date,1,4)),
				NULL),
			concatAttributeValue(cataloged_item.collection_object_id, 'age_class'),
			concatattribute(cataloged_item.collection_object_id),
			accepted_lat_long.verificationstatus,
			'<a href="http://arctos.database.museum/guid/' ||
				collection.guid_prefix || ':' ||
				cataloged_item.cat_num || '">' ||
				collection.guid_prefix || ':' ||
				cataloged_item.cat_num || '</a>',
			'http://arctos.database.museum/guid/' ||
				collection.guid_prefix || ':' ||
				cataloged_item.cat_num,
			'http://arctos.database.museum/guid/' ||
				collection.guid_prefix || ':' ||
				cataloged_item.cat_num,
			concatSingleOtherId(cataloged_item.collection_object_id,'collector number'),
			decode(locality.orig_elev_units,
				NULL, NULL,
				locality.minimum_elevation || '-' || 
					locality.maximum_elevation || ' ' ||
					locality.orig_elev_units),
			decode(to_number(substr(collecting_event.began_date,1,4)),
			    to_number(substr(collecting_event.ended_date,1,4)),
			    to_number(substr(collecting_event.began_date,1,4)),
				NULL),
			decode(to_number(substr(collecting_event.began_date,6,2)),
				to_number(substr(collecting_event.ended_date,6,2)),
				to_number(substr(collecting_event.began_date,6,2)),
				NULL),
			decode(to_number(substr(collecting_event.began_date,9,2)),
				to_number(substr(collecting_event.ended_date,9,2)),
				to_number(substr(collecting_event.began_date,9,2)),
				NULL)
		FROM
			cataloged_item,
			coll_object,
			collection,
			accn,
			trans,
			collecting_event,
			locality,
			geog_auth_rec,
			accepted_lat_long,
			identification,
			coll_object_remark,
			preferred_agent_name lldetr,
			identification_taxonomy,
			taxonomy
		WHERE flat.collection_object_id = cataloged_item.collection_object_id
			AND cataloged_item.collection_object_id = coll_object.collection_object_id
			AND cataloged_item.collection_id = collection.collection_id
			AND cataloged_item.accn_id = accn.transaction_id
			AND accn.transaction_id = trans.transaction_id
			AND cataloged_item.collecting_event_id = collecting_event.collecting_event_id
			AND collecting_event.locality_id = locality.locality_id
			AND locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id
			AND locality.locality_id = accepted_lat_long.locality_id (+)
			AND accepted_lat_long.determined_by_agent_id = lldetr.agent_id (+)
			AND cataloged_item.collection_object_id = identification.collection_object_id
			AND identification.accepted_id_fg = 1
			AND identification.identification_id = identification_taxonomy.identification_id
			AND identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id
			AND identification_taxonomy.variable = 'A'
			AND coll_object.collection_object_id = coll_object_remark.collection_object_id (+))
	WHERE flat.collection_object_id = collobjid;
END;
/


/************************************************************************************************************/
/* few changes TO taxonomy WHILE we're here.... */

ALTER TABLE taxonomy ADD taxon_status VARCHAR2(60);

create table cttaxon_status (
    taxon_status VARCHAR2(60) not null,
    description VARCHAR2(4000)
);

CREATE OR REPLACE PUBLIC SYNONYM cttaxon_status FOR cttaxon_status;
GRANT SELECT ON cttaxon_status TO PUBLIC;
GRANT ALL ON cttaxon_status TO manage_codetables;

ALTER TABLE cttaxon_status add CONSTRAINT pk_cttaxon_status PRIMARY  KEY (taxon_status);
ALTER TABLE taxonomy add CONSTRAINT fk_taxon_status FOREIGN KEY (taxon_status) REFERENCES cttaxon_status(taxon_status);   
    
INSERT INTO cttaxon_status (taxon_status) VALUES ('nomen dubium');
INSERT INTO cttaxon_status (taxon_status) VALUES ('nomen oblitum');
INSERT INTO cttaxon_status (taxon_status) VALUES ('nomen nudum');


CREATE TABLE taxonomy_publication (
    taxonomy_publication_id NUMBER NOT NULL,
    taxon_name_id NUMBER NOT NULL,
    publication_id NUMBER NOT NULL
);
CREATE OR REPLACE PUBLIC SYNONYM taxonomy_publication FOR taxonomy_publication;
GRANT SELECT ON taxonomy_publication TO PUBLIC;
GRANT ALL ON taxonomy_publication TO manage_publications;
ALTER TABLE taxonomy_publication add CONSTRAINT pk_taxonomy_publication_id PRIMARY KEY (taxonomy_publication_id);
ALTER TABLE taxonomy_publication add CONSTRAINT fk_tax_pub_tax FOREIGN KEY (taxon_name_id) REFERENCES taxonomy(taxon_name_id);   
ALTER TABLE taxonomy_publication add CONSTRAINT fk_tax_pub_pub FOREIGN KEY (publication_id) REFERENCES publication(publication_id);   

CREATE UNIQUE INDEX ux_taxonomy_publication ON taxonomy_publication (taxon_name_id,publication_id) TABLESPACE uam_idx_1;
create sequence seq_taxonomy_publication;
CREATE OR REPLACE PUBLIC SYNONYM seq_taxonomy_publication FOR seq_taxonomy_publication;
GRANT SELECT ON seq_taxonomy_publication TO PUBLIC;

CREATE OR REPLACE TRIGGER tbi_taxonomy_publication before insert  ON taxonomy_publication for each row
    begin
        select seq_taxonomy_publication.nextval into :new.taxonomy_publication_id from dual;           
    end;                                                                                                                                                                                     
/
sho err


/************************************************************************************************************/


/************************************************************************************************************/
/* and BORROW.... */

ALTER TABLE borrow ADD borrow_number VARCHAR2(30);

UPDATE borrow SET borrow_number=to_char(borrow_num);

ALTER TABLE borrow MODIFY borrow_number NOT NULL;
ALTER TABLE borrow DROP COLUMN borrow_num;

CREATE UNIQUE INDEX ux_borrow_number ON borrow (borrow_number) TABLESPACE uam_idx_1;
DROP INDEX ux_borrow_number; -- this won't fly as UAM 123 and MVZ 123 borrows is valid - waiting on LKV to find a solution....

/************************************************************************************************************/
/* and identification.... */

ALTER TABLE identification ADD publication_id NUMBER;
ALTER TABLE identification add CONSTRAINT fk_ident_pub_id FOREIGN KEY (publication_id) REFERENCES publication(publication_id);
ALTER TABLE flat ADD id_sensu VARCHAR2(255);
 -- rebuild CREATE OR REPLACE PROCEDURE UPDATE_FLAT (collobjid IN NUMBER) IS
 -- rebuild CREATE OR REPLACE VIEW filtered_flat AS
 
UPDATE cf_spec_res_cols SET DISP_ORDER=DISP_ORDER+1 WHERE DISP_ORDER>6;

INSERT INTO cf_spec_res_cols (COLUMN_NAME,SQL_ELEMENT,CATEGORY,DISP_ORDER) VALUES (
'id_sensu',
'flatTableName.id_sensu',
'specimen',
7
);


--- enable CHECK_FLAT_STALE
--- 
