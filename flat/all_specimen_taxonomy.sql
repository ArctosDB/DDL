SELECT cat_num FROM cataloged_item WHERE
cataloged_item.collection_object_id IN (
    select 
        collection_object_id 
    FROM 
        identification 
    where 
        UPPER(scientific_name) LIKE '%Myodes%'
) OR 
cataloged_item.collection_object_id IN (
    select collection_object_id FROM citation, taxonomy WHERE 
    citation.cited_taxon_name_id = taxonomy.taxon_name_id AND UPPER(scientific_name) LIKE '%Myodes%'
) OR 
cataloged_item.collection_object_id IN ( 
    select collection_object_id 
    FROM 
        identification, 
        identification_taxonomy, 
        taxonomy AccTax, 
        taxonomy RelTaxA,
        taxon_relations toA
    WHERE 
        identification.identification_id=identification_taxonomy.identification_id AND 
        identification_taxonomy.taxon_name_id=AccTax.taxon_name_id AND 
        AccTax.taxon_name_id=toA.taxon_name_id AND 
        toA.related_taxon_name_id = RelTaxA.taxon_name_id AND 
        (
            UPPER(AccTax.scientific_name) LIKE '%Myodes%' OR
            UPPER(RelTaxA.scientific_name) LIKE '%Myodes%' 
        ) 
) OR
cataloged_item.collection_object_id IN ( 
    select collection_object_id 
    FROM 
        identification, 
        identification_taxonomy, 
        taxonomy AccTax, 
        taxonomy RelTaxA,
        taxon_relations toA
    WHERE 
        identification.identification_id=identification_taxonomy.identification_id AND 
        identification_taxonomy.taxon_name_id=AccTax.taxon_name_id AND 
        AccTax.taxon_name_id=related_taxon_name_id  AND 
        toA.taxon_name_id = RelTaxA.taxon_name_id AND 
        UPPER(RelTaxA.scientific_name) LIKE '%Myodes%' ) 