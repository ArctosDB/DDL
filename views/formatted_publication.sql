CREATE OR REPLACE VIEW "UAM"."FORMATTED_PUBLICATION" ("PUBLICATION_ID","FORMAT_STYLE","FORMATTED_PUBLICATION") AS select
        publication_id,
        'author-year' format_style,
        getAuthorYear(publication_id) formatted_publication
    from
        publication
    UNION
        select
        publication_id,
        'full citation' format_style,
        getFullCitation(publication_id) formatted_publication
    from
        publication
