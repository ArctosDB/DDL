DROPed due TO auditing


/*
CREATE OR REPLACE TRIGGER TRG_UP_TAX AFTER
UPDATE ON TAXONOMY REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW BEGIN
    INSERT INTO taxonomy_archive (
        when,
        who,
        taxon_name_id,
        phylclass,
        phylorder,
        suborder,
        family,
        subfamily,
        genus,
        subgenus,
        species,
        subspecies,
        valid_catalog_term_fg,
        source_authority,
        full_taxon_name,
        scientific_name,
        author_text,
        tribe,
        infraspecific_rank,
        taxon_remarks,
        phylum,
        subclass,
        superfamily)
    VALUES (
        sysdate,
        user,
        :old.taxon_name_id,
        :old.phylclass,
        :old.phylorder,
        :old.suborder,
        :old.family,
        :old.subfamily,
        :old.genus,
        :old.subgenus,
        :old.species,
        :old.subspecies,
        :old.valid_catalog_term_fg,
        :old.source_authority,
        :old.full_taxon_name,
        :old.scientific_name,
        :old.author_text,
        :old.tribe,
        :old.infraspecific_rank,
        :old.taxon_remarks,
        :old.phylum,
        :old.subclass,
        :old.superfamily);
END;
*/