-- accn
-- see sequence for trans.transaction_id
-- where transaction_type = 'accn'

-- addr
CREATE OR REPLACE TRIGGER tr_addr_sq
BEFORE INSERT ON addr
FOR EACH ROW
BEGIN
    IF :new.addr_id IS NULL THEN
        SELECT sq_addr_id.nextval
        INTO :new.addr_id
        FROM dual;
    END IF;
END;

-- agent
CREATE OR REPLACE TRIGGER tr_agent_sq
BEFORE INSERT ON agent
FOR EACH ROW
BEGIN
    IF :new.agent_id IS NULL THEN
        SELECT sq_agent_id.nextval
        INTO :new.agent_id
        FROM dual;
    END IF;
END;

-- agent_name
CREATE OR REPLACE TRIGGER tr_agent_name_sq
BEFORE INSERT ON agent_name
FOR EACH ROW
BEGIN
    IF :new.agent_name_id IS NULL THEN
        SELECT sq_agent_name_id.nextval
        INTO :new.agent_name_id
        FROM dual;
    END IF;
END;

-- agent_relations
-- add column agent_relations.agent_relations_id
CREATE OR REPLACE TRIGGER tr_agent_relations_sq
BEFORE INSERT ON agent_relations
FOR EACH ROW
BEGIN
    IF :new.agent_relations_id IS NULL THEN
        SELECT sq_agent_relations_id.nextval
        INTO :new.agent_relations_id
        FROM dual;
    END IF;
END;

-- attributes
CREATE OR REPLACE TRIGGER tr_attributes_sq
BEFORE INSERT ON attributes
FOR EACH ROW
BEGIN
    IF :new.attribute_id IS NULL THEN
        SELECT sq_attribute_id.nextval
        INTO :new.attribute_id
        FROM dual;
    END IF;
END;

-- biol_indiv_relations
-- add column biol_indiv_relations.biol_indiv_relations_id
CREATE OR REPLACE TRIGGER tr_agent_relations_sq
BEFORE INSERT ON agent_relations
FOR EACH ROW
BEGIN
    IF :new.biol_indiv_relations_id IS NULL THEN
        SELECT sq_biol_indiv_relations_id.nextval
        INTO :new.biol_indiv_relations_id
        FROM dual;
    END IF;
END;

-- book
-- see sequence for publication.publication_id
-- where publication_type = 'Book'

-- book_section
-- see sequence for publication.publication_id
-- where publication_type = 'Book Section'

-- borrow
-- see sequence for trans.transaction_id
-- where transaction_type = 'borrow'

-- cataloged_item
-- see sequence for coll_object.collection_object_id
-- where coll_object_type = 'CI'

-- citation
CREATE OR REPLACE TRIGGER tr_citation_sq
BEFORE INSERT ON citation
FOR EACH ROW
BEGIN
    IF :new.citation_id IS NULL THEN
        SELECT sq_citation_id.nextval
        INTO :new.citation_id
        FROM dual;
    END IF;
END;

-- collecting_event
CREATE OR REPLACE TRIGGER tr_collecting_event_sq
BEFORE INSERT ON collecting_event
FOR EACH ROW
BEGIN
    IF :new.collecting_event_id IS NULL THEN
        SELECT sq_collecting_event_id.nextval
        INTO :new.collecting_event_id
        FROM dual;
    END IF;
END;

-- collection
CREATE OR REPLACE TRIGGER tr_collection_sq
BEFORE INSERT ON collection
FOR EACH ROW
BEGIN
    IF :new.collection_id IS NULL THEN
        SELECT sq_collection_id.nextval
        INTO :new.collection_id
        FROM dual;
    END IF;
END;

-- collection_contacts
CREATE OR REPLACE TRIGGER tr_collection_contacts_sq
BEFORE INSERT ON collection_contacts
FOR EACH ROW
BEGIN
    IF :new.collection_contact_id IS NULL THEN
        SELECT sq_collection_contact_id.nextval
        INTO :new.collection_contact_id
        FROM dual;
    END IF;
END;

-- collector
-- add collector.collector_id
CREATE OR REPLACE TRIGGER tr_collector_sq
BEFORE INSERT ON collector
FOR EACH ROW
BEGIN
    IF :new.collector_id IS NULL THEN
        SELECT sq_collector_id.nextval
        INTO :new.collector_id
        FROM dual;
    END IF;
END;

-- coll_object
CREATE OR REPLACE TRIGGER tr_coll_object_sq
BEFORE INSERT ON coll_object
FOR EACH ROW
BEGIN
    IF :new.collection_object_id IS NULL THEN
        SELECT sq_collection_object_id.nextval
        INTO :new.collection_object_id
        FROM dual;
    END IF;
END;

-- coll_object_encumbrance
-- join table between coll_object and encumbrance

-- coll_object_remark
-- see sequence for coll_object.collection_object_id

-- coll_obj_cont_hist
CREATE OR REPLACE TRIGGER tr_coll_object_cont_hist_sq
BEFORE INSERT ON coll_object_cont_hist
FOR EACH ROW
BEGIN
    IF :new.coll_obj_cont_hist_id IS NULL THEN
        SELECT sq_coll_obj_cont_hist_id.nextval
        INTO :new.coll_obj_cont_hist_id
        FROM dual;
    END IF;
END;

-- coll_obj_other_id_num
CREATE OR REPLACE TRIGGER tr_coll_obj_other_id_num_sq
BEFORE INSERT ON coll_obj_other_id_num
FOR EACH ROW
BEGIN
    IF :new.coll_obj_other_id_num_id IS NULL THEN
        SELECT sq_coll_obj_other_id_num_id.nextval
        INTO :new.coll_obj_other_id_num_id
        FROM dual;
    END IF;
END;

-- common_name
-- add column common_name.common_name_id
CREATE OR REPLACE TRIGGER tr_common_name_sq
BEFORE INSERT ON common_name
FOR EACH ROW
BEGIN
    IF :new.taxon_name_id IS NULL THEN
        SELECT sq_common_name_id.nextval
        INTO :new.common_name_id
        FROM dual;
    END IF;
END;

-- container
CREATE OR REPLACE TRIGGER tr_container_sq
BEFORE INSERT ON container
FOR EACH ROW
BEGIN
    IF :new.container_id IS NULL THEN
        SELECT sq_container_id.nextval
        INTO :new.container_id
        FROM dual;
    END IF;
END;

-- container_check
CREATE OR REPLACE TRIGGER tr_container_check_sq
BEFORE INSERT ON container_check
FOR EACH ROW
BEGIN
    IF :new.container_check_id IS NULL THEN
        SELECT sq_container_check_id.nextval
        INTO :new.container_check_id
        FROM dual;
    END IF;
END;

-- container_history
-- add column container_history.container_history_id
CREATE OR REPLACE TRIGGER tr_container_history_sq
BEFORE INSERT ON container_history
FOR EACH ROW
BEGIN
    IF :new.container_history_id IS NULL THEN
        SELECT sq_container_history_id.nextval
        INTO :new.container_history_id
        FROM dual;
    END IF;
END;

-- electronic_address
-- add column electronic_address_id
CREATE OR REPLACE TRIGGER tr_electronic_address_sq
BEFORE INSERT ON electronic_address
FOR EACH ROW
BEGIN
    IF :new.electronic_address_id IS NULL THEN
        SELECT sq_electronic_address_id.nextval
        INTO :new.electronic_address_id
        FROM dual;
    END IF;
END;

-- encumbrance
CREATE OR REPLACE TRIGGER tr_encumbrance_sq
BEFORE INSERT ON encumbrance
FOR EACH ROW
BEGIN
    IF :new.encumbrance_id IS NULL THEN
        SELECT sq_encumbrance_id.nextval
        INTO :new.encumbrance_id
        FROM dual;
    END IF;
END;

-- field_notebook_section
-- see publication.publication_id
-- where publication_type = 'Book Section'
-- and book_section_type = 'field notebook section'

-- fluid_container_history
-- add column fluid_container_history.fluid_container_history_id
CREATE OR REPLACE TRIGGER tr_fluid_container_history_sq
BEFORE INSERT ON fluid_container_history
FOR EACH ROW
BEGIN
    IF :new.fluid_container_history_id IS NULL THEN
        SELECT sq_fluid_container_history_id.nextval
        INTO :new.fluid_container_history_id
        FROM dual;
    END IF;
END;

-- geog_auth_rec
CREATE OR REPLACE TRIGGER tr_geog_auth_rec_sq
BEFORE INSERT ON geog_auth_rec
FOR EACH ROW
BEGIN
    IF :new.geog_auth_rec_id IS NULL THEN
        SELECT sq_geog_auth_rec_id.nextval
        INTO :new.geog_auth_rec_id
        FROM dual;
    END IF;
END;

-- geology_attributes
CREATE OR REPLACE TRIGGER tr_geology_attributes_sq
BEFORE INSERT ON geology_attributes
FOR EACH ROW
BEGIN
    IF :new.geology_attribute_id IS NULL THEN
        SELECT sq_geology_attribute_id.nextval
        INTO :new.geology_attribute_id
        FROM dual;
    END IF;
END;

-- geology_attribute_hierarchy
CREATE OR REPLACE TRIGGER tr_geology_attribute_hierarchy_sq
BEFORE INSERT ON geology_attribute_hierarchy
FOR EACH ROW
BEGIN
    IF :new.geology_attribute_hierarchy_id IS NULL THEN
        SELECT sq_geology_attribute_hierarchy_id.nextval
        INTO :new.geology_attribute_hierarchy_id
        FROM dual;
    END IF;
END;

-- group_member
-- add column group_member.group_member_id
CREATE OR REPLACE TRIGGER tr_group_member_sq
BEFORE INSERT ON group_member
FOR EACH ROW
BEGIN
    IF :new.group_member_id IS NULL THEN
        SELECT sq_group_member_id.nextval
        INTO :new.group_member_id
        FROM dual;
    END IF;
END;

-- identification
CREATE OR REPLACE TRIGGER tr_identification_sq
BEFORE INSERT ON identification
FOR EACH ROW
BEGIN
    IF :new.identification_id IS NULL THEN
        SELECT sq_identification_id.nextval
        INTO :new.identification_id
        FROM dual;
    END IF;
END;

-- identification_agent
CREATE OR REPLACE TRIGGER tr_identification_agent_sq
BEFORE INSERT ON identification_agent
FOR EACH ROW
BEGIN
    IF :new.identification_agent_id IS NULL THEN
        SELECT sq_identification_agent_id.nextval
        INTO :new.identification_agent_id
        FROM dual;
    END IF;
END;

-- identification_taxonomy
-- add column identification_taxonomy.identification_taxonomy_id
CREATE OR REPLACE TRIGGER tr_identification_taxonomy_sq
BEFORE INSERT ON identification_taxonomy
FOR EACH ROW
BEGIN
    IF :new.identification_taxonomy_id IS NULL THEN
        SELECT sq_identification_taxonomy_id.nextval
        INTO :new.identification_taxonomy_id
        FROM dual;
    END IF;
END;

-- image_content
-- table will soon be deprecated

-- image_object
-- see sequence for coll_object.collection_object_id
-- where coll_object_type = 'IO'
-- table will soon be deprecated

-- image_subject
-- table will soon be deprecated

-- image_subject_remarks
-- table will soon be deprecated

-- journal
CREATE OR REPLACE TRIGGER tr_journal_sq
BEFORE INSERT ON journal
FOR EACH ROW
BEGIN
    IF :new.journal_id IS NULL THEN
        SELECT sq_journal_id.nextval
        INTO :new.journal_id
        FROM dual;
    END IF;
END;

-- journal_article
-- see sequence for publication.publication_id
-- where publication_type = 'Journal Article'

-- lat_long
CREATE OR REPLACE TRIGGER tr_lat_long_sq
BEFORE INSERT ON lat_long
FOR EACH ROW
BEGIN
    IF :new.lat_long_id IS NULL THEN
        SELECT sq_lat_long_id.nextval
        INTO :new.lat_long_id
        FROM dual;
    END IF;
END;

-- loan
-- see sequence for trans.transaction_id
-- where transaction_type = 'loan')

-- loan_item
-- add column loan_item.loan_item_id
CREATE OR REPLACE TRIGGER tr_loan_item_sq
BEFORE INSERT ON loan_item
FOR EACH ROW
BEGIN
    IF :new.loan_item_id IS NULL THEN
        SELECT sq_loan_item_id.nextval
        INTO :new.loan_item_id
        FROM dual;
    END IF;
END;

-- locality
CREATE OR REPLACE TRIGGER tr_locality_sq
BEFORE INSERT ON locality
FOR EACH ROW
BEGIN
    IF :new.locality_id IS NULL THEN
        SELECT sq_locality_id.nextval
        INTO :new.locality_id
        FROM dual;
    END IF;
END;

-- media
CREATE OR REPLACE TRIGGER tr_media_sq
BEFORE INSERT ON media
FOR EACH ROW
BEGIN
    IF :new.media_id IS NULL THEN
        SELECT sq_media_id.nextval
        INTO :new.media_id
        FROM dual;
    END IF;
END;

-- media_labels
CREATE OR REPLACE TRIGGER tr_media_labels_sq
BEFORE INSERT ON media_labels
FOR EACH ROW
BEGIN
    IF :new.media_label_id IS NULL THEN
        SELECT sq_media_label_id.nextval
        INTO :new.media_label_id
        FROM dual;
    END IF;
END;

-- media_relations
CREATE OR REPLACE TRIGGER tr_media_relations_sq
BEFORE INSERT ON media_relations
FOR EACH ROW
BEGIN
    IF :new.media_relations_id IS NULL THEN
        SELECT sq_media_relations_id.nextval
        INTO :new.media_relations_id
        FROM dual;
    END IF;
END;

-- object_condition
CREATE OR REPLACE TRIGGER tr_object_condition_sq
BEFORE INSERT ON object_condition
FOR EACH ROW
BEGIN
    IF :new.object_condition_id IS NULL THEN
        SELECT sq_object_condition_id.nextval
        INTO :new.object_condition_id
        FROM dual;
    END IF;
END;

-- page
CREATE OR REPLACE TRIGGER tr_page_sq
BEFORE INSERT ON page
FOR EACH ROW
BEGIN
    IF :new.page_id IS NULL THEN
        SELECT sq_page_id.nextval
        INTO :new.page_id
        FROM dual;
    END IF;
END;

-- permit
CREATE OR REPLACE TRIGGER tr_permit_sq
BEFORE INSERT ON permit
FOR EACH ROW
BEGIN
    IF :new.permit_id IS NULL THEN
        SELECT sq_permit_id.nextval
        INTO :new.permit_id
        FROM dual;
    END IF;
END;

-- permit_trans
-- joint table between permit and trans

-- person
-- see sequence form agent.agent_id
-- where agent_type = 'person'

-- project
CREATE OR REPLACE TRIGGER tr_project_sq
BEFORE INSERT ON project
FOR EACH ROW
BEGIN
    IF :new.project_id IS NULL THEN
        SELECT sq_project_id.nextval
        INTO :new.project_id
        FROM dual;
    END IF;
END;

-- project_sponsor
CREATE OR REPLACE TRIGGER tr_project_sponsor_sq
BEFORE INSERT ON project_sponsor
FOR EACH ROW
BEGIN
    IF :new.project_sponsor_id IS NULL THEN
        SELECT sq_project_sponsor_id.nextval
        INTO :new.project_sponsor_id
        FROM dual;
    END IF;
END;

-- project_trans
-- add column project_trans.project_trans_id
CREATE OR REPLACE TRIGGER tr_project_trans_sq
BEFORE INSERT ON project_trans
FOR EACH ROW
BEGIN
    IF :new.project_trans_id IS NULL THEN
        SELECT sq_project_trans_id.nextval
        INTO :new.project_trans_id
        FROM dual;
    END IF;
END;

-- publication
CREATE OR REPLACE TRIGGER tr_publication_sq
BEFORE INSERT ON publication
FOR EACH ROW
BEGIN
    IF :new.publication_id IS NULL THEN
        SELECT sq_publication_id.nextval
        INTO :new.publication_id
        FROM dual;
    END IF;
END;

-- publication_author_name
-- add column publication_author_name.publication_author_name_id
CREATE OR REPLACE TRIGGER tr_publication_author_name_sq
BEFORE INSERT ON publication_author_name
FOR EACH ROW
BEGIN
    IF :new.publication_author_name_id IS NULL THEN
        SELECT sq_publication_author_name_id.nextval
        INTO :new.publication_author_name_id
        FROM dual;
    END IF;
END;

-- publication_url
CREATE OR REPLACE TRIGGER tr_publication_url_sq
BEFORE INSERT ON publication_url
FOR EACH ROW
BEGIN
    IF :new.publication_url_id IS NULL THEN
        SELECT sq_publication_url_id.nextval
        INTO :new.publication_url_id
        FROM dual;
    END IF;
END;

-- shipment
-- add column shipment.shipment_id
CREATE OR REPLACE TRIGGER tr_shipment_sq
BEFORE INSERT ON shipment
FOR EACH ROW
BEGIN
    IF :new.shipment_id IS NULL THEN
        SELECT sq_shipment_id.nextval
        INTO :new.shipment_id
        FROM dual;
    END IF;
END;

-- specimen_annotations
CREATE OR REPLACE TRIGGER tr_specimen_annotations_sq
BEFORE INSERT ON specimen_annotations
FOR EACH ROW
BEGIN
    IF :new.annotation_id IS NULL THEN
        SELECT sq_annotation_id.nextval
        INTO :new.annotation_id
        FROM dual;
    END IF;
END;

-- specimen_part
-- see sequence for coll_object.collection_object_id
-- where coll_object_type = 'SP'

-- TAB_MEDIA_REL_FKEY???

-- taxonomy
CREATE OR REPLACE TRIGGER tr_taxonomy_sq
BEFORE INSERT ON taxonomy
FOR EACH ROW
BEGIN
    IF :new.taxon_name_id IS NULL THEN
        SELECT sq_taxon_name_id.nextval
        INTO :new.taxon_name_id
        FROM dual;
    END IF;
END;

-- taxon_relations
-- add column taxon_relations.taxon_relations_id
CREATE OR REPLACE TRIGGER tr_taxon_relations_sq
BEFORE INSERT ON taxon_relations
FOR EACH ROW
BEGIN
    IF :new.taxon_relations_id IS NULL THEN
        SELECT sq_taxon_relations_id.nextval
        INTO :new.taxon_relations_id
        FROM dual;
    END IF;
END;

-- trans
CREATE OR REPLACE TRIGGER tr_trans_sq
BEFORE INSERT ON trans
FOR EACH ROW
BEGIN
    IF :new.transaction_id IS NULL THEN
        SELECT sq_transaction_id.nextval
        INTO :new.transaction_id
        FROM dual;
    END IF;
END;

-- trans_agent
CREATE OR REPLACE TRIGGER tr_trans_agent_sq
BEFORE INSERT ON trans_agent
FOR EACH ROW
BEGIN
    IF :new.trans_agent_id IS NULL THEN
        SELECT sq_trans_agent_id.nextval
        INTO :new.trans_agent_id
        FROM dual;
    END IF;
END;

-- vessel
-- add column vessel.vessel_id
CREATE OR REPLACE TRIGGER tr_vessel_sq
BEFORE INSERT ON vessel
FOR EACH ROW
BEGIN
    IF :new.vessel_id IS NULL THEN
        SELECT sq_vessel_id.nextval
        INTO :new.vessel_id
        FROM dual;
    END IF;
END;

-- 62 rows selected.
