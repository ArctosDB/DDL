  1  select count(*) || chr(9) || ci.collection_id || chr(9) || sp.part_modifier
  2  from specimen_part sp, cataloged_item ci
  3  where sp.derived_from_cat_item = ci.collection_object_id
  4  group by sp.part_modifier, ci.collection_id
  5* order by part_modifier, ci.collection_id
uam@arctos> /

COUNT(*)||CHR(9)||CI.COLLECTION_ID||CHR(9)||SP.PART_MODIFIER
--------------------------------------------------------------------------------
1       1       10th thoracic
1       1       11th thoracic
3       1       3rd cervical
2       1       4th cervical
1       1       5th cervical
1       1       6th cervical
1       1       6th thoracic
1       1       7th cervical
1       1       7th thoracic
1       1       8th thoracic
1       1       9th thoracic
138     2       Power
33      1       atlas
1       14      atlas
6       21      atlas
18      1       axis
4       21      axis
1       28      body
703     29      body
90      28      broken
4       1       brown
3       1       caudal
34      21      caudal
2       1       cervical
72      28      clipped
204955  28      complete
14815   29      complete
3589    30      complete
78      1       complete post-cranial
5       20      complete post-cranial
2344    28      complete post-cranial
10      1       damaged
1       14      damaged
1       20      damaged
20      28      disarticulated
1       30      disarticulated
1473    1       dissected
1       10      dissected
2       28      dissected
9       21      dorsal
28      28      eviscerated
2       30      eviscerated
287     1       flat
799     20      flat
3       21      flat
5063    28      flat
659     29      flat
1468    30      flat
309     21      fragment
2       1       fragments of
114     20      fragments of
102     21      fragments of
66      28      fragments of
2       30      fragments of
4       1       half
673     28      headless
1       29      headless
8       30      headless
2       1       hind
21      1       incomplete
19      14      incomplete
8       20      incomplete
3       21      incomplete
203     28      incomplete
15      29      incomplete
82      30      incomplete
107     1       left
1       14      left
12      20      left
16      21      left
11      29      left
5       1       lumbar
998     21      molar
8       20      mounted
5       29      mounted
38      21      partial
12360   28      partial
3824    29      partial
1799    30      partial
6       1       partial post-cranial
3       14      partial post-cranial
76      20      partial post-cranial
843     28      partial post-cranial
12      30      partial post-cranial
2100    28      pelt
417     1       postcranial
1       14      postcranial
4       20      postcranial
132     1       right
1       14      right
8       20      right
24      21      right
2       28      right
5       29      right
339     1       sectioned
4       28      sectioned
5       30      sectioned
1       24      skin
2       1       skinned
3       14      skinned
3       28      skinned
1       29      skinned
2570    28      skull-less
1       29      skull-less
35      1       slide
67      14      slide
32      17      slide
4       29      spread
21      1       study
1       20      study
150111  28      study
160451  29      study
1       30      study
5       1       thoracic
1       29      upper
260     28      whole
294360  1
7542    2
387     3
10340   4
165499  6
649     7
524     8
375     9
3557    10
7163    11
13915   12
70      13
460531  14
35      15
3668    16
88818   17
1824    18
4152    19
36919   20
887     21
1347    22
324     23
13107   24
1914    26
30      27
63347   28
18408   29
281347  30
14858   31
91      37

146 rows selected.


--PRESERVE method

  1  select count(*) || chr(9) || ci.collection_id || chr(9) || c.collection_cde || chr(9) || sp.preserve_method
  2  from specimen_part sp, cataloged_item ci, collection c
  3  where sp.derived_from_cat_item = ci.collection_object_id
  4  and ci.collection_id = c.collection_id
  5  and sp.preserve_method in (
  6     '70% or 95% ETOH',
  7     'formalin-fixed, 70% etoh',
  8     'alcohol',
  9     'air-dried',
 10     'stored in 95% etoh',
 11     'slide)/ovaries (slide')
 12  group by ci.collection_id, sp.preserve_method, c.collection_cde
 13* order by sp.preserve_method, ci.collection_id
uam@arctos> /

COUNT(*)||CHR(9)||CI.COLLECTION_ID||CHR(9)||C.COLLECTION_CDE||CHR(9)||SP.PRESERV
--------------------------------------------------------------------------------
705     28      Mamm    70% or 95% ETOH
51      30      Herp    70% or 95% ETOH
4       10      Fish    alcohol
41866   14      Mamm    alcohol
60      17      Mamm    alcohol
324     23      Fish    alcohol
11      24      Mamm    alcohol
19490   28      Mamm    alcohol
3530    29      Bird    alcohol
234615  30      Herp    alcohol
336     28      Mamm    formalin-fixed, 70% etoh
2       30      Herp    slide)/ovaries (slide
6       28      Mamm    stored in 95% etoh


alter trigger SPECIMEN_PART_CT_CHECK disable;
ALTER TRIGGER UP_FLAT_PART DISABLE;

--Mamm	'ethanol'    'alcohol'
--Bird	'ethanol'    'alcohol'
--Herp	'ethanol'    'alcohol'
    
UPDATE specimen_part
SET preserve_method = 'ethanol'
WHERE preserve_method = 'alcohol'    
AND derived_from_cat_item IN (
    SELECT collection_object_id 
    FROM cataloged_item
    WHERE collection_id IN (28,29,30));
    
-- Bird|ethanol and Herp|ethanol exist in ctspecimen_preserve_method
DELETE FROM ctspecimen_preserv_method
SET preserve_method = 'ethanol'
WHERE preserve_method = 'alcohol'    
AND collection_cde IN ('Bird','Herp');

INSERT INTO ctspecimen_preserv_method (collection_cde, preserve_method)
VALUES ('Mamm', 'ethanol');

--Mamm	'ethanol'    '70% or 95% ETOH'    
--Herp	'ethanol'    '70% or 95% ETOH'

UPDATE specimen_part
SET preserve_method = 'ethanol'
WHERE preserve_method = '70% or 95% ETOH'    
AND derived_from_cat_item IN (
    SELECT collection_object_id 
    FROM cataloged_item
    WHERE collection_id IN (28,30));
    
DELETE FROM ctspecimen_preserv_method
WHERE preserve_method = '70% or 95% ETOH'    
AND collection_cde IN ('Mamm','Herp');
    
--Mamm    'formalin-fixed, 70% ETOH'   'formalin-fixed, 70% etoh'
    
UPDATE specimen_part
SET preserve_method = 'formalin-fixed, 70% ETOH'
WHERE preserve_method = 'formalin-fixed, 70% etoh'    
AND derived_from_cat_item IN (
    SELECT collection_object_id 
    FROM cataloged_item
    WHERE collection_id = 28);
    
UPDATE ctspecimen_preserv_method
SET preserve_method = 'formalin-fixed, 70% ETOH'
WHERE preserve_method = 'formalin-fixed, 70% etoh'    
AND collection_cde = 'Mamm';
    
--Mamm    'dried'    'air-dried'
--Herp	'dried'    'air-dried'
    
UPDATE specimen_part
SET PRESERVE_method = 'dried'
WHERE preserve_method = 'air-dried'    
AND derived_from_cat_item IN (
    SELECT collection_object_id 
    FROM cataloged_item
    WHERE collection_id IN (28,30));
    
-- Mamm|dried, Herp|dried already exists in ctspecimen_preserv_method.
DELETE FROM ctspecimen_preserv_method
WHERE preserve_method = 'air-dried'    
AND collection_cde IN ('Mamm','Herp');
    
--Mamm    '95% ETOH'    'stored in 95% etoh'

UPDATE specimen_part
SET PRESERVE_method = '95% ETOH'
WHERE preserve_method = 'stored in 95% etoh'    
AND derived_from_cat_item IN (
    SELECT collection_object_id 
    FROM cataloged_item
    WHERE collection_id = 28);
    
-- Mamm|95% ETOH already exist in ctspecimen_preserve_method    
DELETE FROM ctspecimen_preserv_method
WHERE preserve_method = 'stored in 95% etoh'    
AND collection_cde = 'Mamm';

--Herp	NULL    'slide)/ovaries (slide'

UPDATE specimen_part
SET PRESERVE_method = NULL
WHERE preserve_method = 'slide)/ovaries (slide'    
AND derived_from_cat_item IN (
    SELECT collection_object_id 
    FROM cataloged_item
    WHERE collection_id = 30);
    
DELETE FROM ctspecimen_preserv_method
WHERE preserve_method = 'slide)/ovaries (slide'    
AND collection_cde = 'Herp';

alter trigger SPECIMEN_PART_CT_CHECK ENABLE;
ALTER TRIGGER UP_FLAT_PART ENABLE;

select count(*) || chr(9) || sp.preserve_method
from mvz.specimen_part sp, cataloged_item ci, collection c
where sp.derived_from_cat_item = ci.collection_object_id
and ci.collection_id = c.collection_id
and ci.collection_id in (28, 29, 30)
and sp.preserve_method in (
   '70% or 95% ETOH',
   'formalin-fixed, 70% etoh',
   'alcohol',
   'air-dried',
   'stored in 95% etoh',
   'slide)/ovaries (slide')
group by sp.preserve_method

COUNT(*)||CHR(9)||SP.PRESERVE_METHOD
-----------------------------------------------------------------------
6       stored in 95% etoh
336     formalin-fixed, 70% etoh
257635  alcohol
756     70% or 95% ETOH
2       slide)/ovaries (slide


UPDATE flat SET stale_flag = 1
WHERE collection_object_id IN (
SELECT sp.derived_from_cat_item
FROM mvz.specimen_part sp, cataloged_item ci
where sp.derived_from_cat_item = ci.collection_object_id
AND ci.collection_id IN (28, 29, 30)
AND sp.preserve_method IN (
   '70% or 95% ETOH',
   'formalin-fixed, 70% etoh',
   'air-dried',
   'stored in 95% etoh',
   'slide)/ovaries (slide')
);

UPDATE flat SET stale_flag = 1
WHERE collection_object_id IN (
SELECT sp.derived_from_cat_item
FROM mvz.specimen_part sp, cataloged_item ci
where sp.derived_from_cat_item = ci.collection_object_id
AND ci.collection_id = 28
AND sp.preserve_method = 'alcohol'
);

UPDATE flat SET stale_flag = 1
WHERE collection_object_id IN (
SELECT sp.derived_from_cat_item
FROM mvz.specimen_part sp, cataloged_item ci
where sp.derived_from_cat_item = ci.collection_object_id
AND ci.collection_id = 29
AND sp.preserve_method = 'alcohol'
);

UPDATE flat SET stale_flag = 1
WHERE collection_object_id IN (
SELECT sp.derived_from_cat_item
FROM mvz.specimen_part sp, cataloged_item ci
where sp.derived_from_cat_item = ci.collection_object_id
AND ci.collection_id = 30
AND sp.preserve_method = 'alcohol'
);


per    PERMIT_TRANS                   FK_PERMITTRANS_TRANS
      21062495
      21062495
      21062711
      21062816
pro    PROJECT_TRANS                  FK_PROJECTTRANS_TRANS
      21062911
a    TRANS_AGENT                    FK_TRANSAGENT_TRANS
      10013418
      10013665
      10013667
      10013676
      10013677
      10013678
      10013679
      10013686
      10013688
      10013689
      10013690
      10013691
      10013693
      10013694
      10013700
      10013706
      10013754
      10013812
      10013818
      10014167
      21039185
      21062376
      21062495
      21062711
      21062816
      21062911



DECLARE
    trec VARCHAR2(4000);
    pmrec VARCHAR2(4000);
    pjrec VARCHAR2(4000);
    pjrec VARCHAR2(4000);
begin
    dbms_output.put_line(
    '|TRANSACTION_ID|INSTITUTION_ACRONYM|COLLECTION_CDE|TRANS_DATE|CORRESP_FG|TRANSACTION_TYPE|NATURE_OF_MATERIAL|TRANS_REMARKS|' 
for tid in (select
    t.transaction_id || '|' ||
    t.institution_acronym || '|' ||
    c.collection_cde || '|' ||
    t.trans_date || '|' ||
    t.corresp_fg || '|' ||
    t.transaction_type || '|' ||
    t.nature_of_material || '|' ||
    t.trans_remarks || '|' ||
    pm.PERMIT_ID || '|' ||
    pm.PERMIT_NUM || '|' ||
    pm.PERMIT_TYPE || '|' ||
    pm.ISSUED_DATE || '|' ||
    pm.ISSUED_BY_AGENT_ID || '|' ||
    pm_issueby.agent_name || '|' ||
    pm.ISSUED_TO_AGENT_ID || '|' ||
    pm_issueto.agent_name || '|' ||
    pm.CONTACT_AGENT_ID || '|' ||
    pm_contact.agent_name || '|' ||
    pm.RENEWED_DATE || '|' ||
    pm.EXP_DATE || '|' ||
    pm.PERMIT_REMARKS || '|' ||
    pj.PROJECT_ID || '|' ||
    pj.PROJECT_NAME || '|' ||
    pj.START_DATE || '|' ||
    pj.END_DATE || '|' ||
    pj.PROJECT_DESCRIPTION || '|' ||
    pj.PROJECT_REMARKS || '|' ||
    ta.TRANS_AGENT_ID || '|' ||
    ta.TRANSACTION_ID || '|' ||
    ta.AGENT_ID || '|' ||
    ta_agent.agent_name || '|' ||
    ta.TRANS_AGENT_ROLE || '|'
FROM 
    trans t, 
    collection c, 
    permit_trans pmt, 
    permit pm,
    project_trans pjt, 
    project pj, 
    trans_agent ta, 
    agent_name pm_issueby,
    agent_name pm_issueto,
    agent_name pm_contact,
    agent_name ta_agent
WHERE t.collection_id = c.collection_id
AND t.transaction_id = pmt.transaction_id
AND pmt.permit_id = pm.permit_id
AND t.transaction_id = pjt.transaction_id
AND pjt.project_id = pj.project_id
AND t.transaction_id = ta.transaction_id
AND pm.ISSUED_BY_AGENT_ID = pm_issueby.agent_id
AND pm_issueby.agent_name_type = 'preferred'
AND pm.ISSUED_TO_AGENT_ID = pm_issueto.agent_id
AND pm_issueto.agent_name_type = 'preferred'
AND pm.CONTACT_AGENT_ID = pm_contact.agent_id
AND pm_contact.agent_name_type = 'preferred'
AND ta.AGENT_ID = ta_agent.agent_id
AND ta_agent.agent_name_type = 'preferred'
and t.transaction_id in (
    10013418, 10013665, 10013667, 10013676, 10013677,
    10013678, 10013679, 10013693, 10013694, 10013754,
    10013812, 10013818, 10014167, 21039185, 21062376,
    21062495, 21062711, 21062816, 10013686, 10013688,
    10013689, 10013690, 10013691, 10013700, 10013706, 21062911)
    ORDER BY t.transaction_id
) loop
    trec := '|' || tn.transaction_id;
    trec := trec || '|' || tn.institution_acronym;
    trec := trec || '|' || tn.collection_cde;
    trec := trec || '|' || tn.trans_date;
    trec := trec || '|' || tn.corresp_fg;
    trec := trec || '|' || tn.transaction_type;
    trec := trec || '|' || tn.nature_of_material;
    trec := trec || '|' || tn.trans_remarks || '|';
    FOR pmid IN (SELECT p.permit_id,  
p.PERMIT_ID,
p.ISSUED_BY_AGENT_ID,
p.ISSUED_DATE,
p.ISSUED_TO_AGENT_ID,
p.RENEWED_DATE,
p.EXP_DATE,
p.PERMIT_NUM,
p.PERMIT_TYPE,
p.PERMIT_REMARKS,
p.CONTACT_AGENT_ID
FROM permit p, permit_trans pt, agent a
WHERE p.permit_id = pt.permit_id
)
                
end loop;
END;


--TRANS
select
    t.transaction_id || '|' ||
    t.institution_acronym || '|' ||
    c.collection_cde || '|' ||
    t.trans_date || '|' ||
    t.corresp_fg || '|' ||
    t.transaction_type || '|' ||
    t.nature_of_material || '|' ||
    t.trans_remarks || '|'
FROM 
    trans t, 
    collection c
WHERE t.collection_id = c.collection_id
and t.transaction_id in (
    10013418, 10013665, 10013667, 10013676, 10013677,
    10013678, 10013679, 10013693, 10013694, 10013754,
    10013812, 10013818, 10014167, 21039185, 21062376,
    21062495, 21062711, 21062816, 10013686, 10013688,
    10013689, 10013690, 10013691, 10013700, 10013706, 21062911)
ORDER BY t.transaction_id;

select
    pmt.transaction_id || '|' ||
    pm.PERMIT_ID || '|' ||
    pm.PERMIT_NUM || '|' ||
    pm.PERMIT_TYPE || '|' ||
    pm.ISSUED_DATE || '|' ||
    pm.ISSUED_BY_AGENT_ID || '|' ||
    pm.ISSUED_TO_AGENT_ID || '|' ||
    pm.CONTACT_AGENT_ID || '|' ||
    pm.RENEWED_DATE || '|' ||
    pm.EXP_DATE || '|' ||
    pm.PERMIT_REMARKS || '|'
FROM 
    permit_trans pmt, 
    permit pm,
WHERE pmt.permit_id = pm.permit_id (+)
AND pm.ISSUED_BY_AGENT_ID = pm_issueby.agent_id
AND pm_issueby.agent_name_type = 'preferred'
AND pm.ISSUED_TO_AGENT_ID = pm_issueto.agent_id
AND pm_issueto.agent_name_type = 'preferred'
AND pm.CONTACT_AGENT_ID = pm_contact.agent_id
AND pm_contact.agent_name_type = 'preferred'
and pmt.transaction_id in (
    10013418, 10013665, 10013667, 10013676, 10013677,
    10013678, 10013679, 10013693, 10013694, 10013754,
    10013812, 10013818, 10014167, 21039185, 21062376,
    21062495, 21062711, 21062816, 10013686, 10013688,
    10013689, 10013690, 10013691, 10013700, 10013706, 21062911)
ORDER BY pmt.transaction_id, pm.permit_id;

--PROJECT
select
    t.transaction_id || '|' ||
    pj.PROJECT_ID || '|' ||
    pj.PROJECT_NAME || '|' ||
    pj.START_DATE || '|' ||
    pj.END_DATE || '|' ||
    pj.PROJECT_DESCRIPTION || '|' ||
    pj.PROJECT_REMARKS || '|'
FROM 
    trans t, 
    project_trans pjt, 
    project pj
WHERE t.transaction_id = pjt.transaction_id
AND pjt.project_id = pj.project_id
and t.transaction_id in (
    10013418, 10013665, 10013667, 10013676, 10013677,
    10013678, 10013679, 10013693, 10013694, 10013754,
    10013812, 10013818, 10014167, 21039185, 21062376,
    21062495, 21062711, 21062816, 10013686, 10013688,
    10013689, 10013690, 10013691, 10013700, 10013706, 21062911)
ORDER BY t.transaction_id, pj.project_id;
    
--TRANS_AGENT
select
    t.transaction_id || '|' ||
    ta.TRANS_AGENT_ID || '|' ||
    ta.AGENT_ID || '|' ||
    ta_agent.agent_name || '|' ||
    ta.TRANS_AGENT_ROLE || '|'
FROM 
    trans t, 
    trans_agent ta, 
    agent_name ta_agent
WHERE t.transaction_id = ta.transaction_id
AND ta.AGENT_ID = ta_agent.agent_id
AND ta_agent.agent_name_type = 'preferred'
and t.transaction_id in (
    10013418, 10013665, 10013667, 10013676, 10013677,
    10013678, 10013679, 10013693, 10013694, 10013754,
    10013812, 10013818, 10014167, 21039185, 21062376,
    21062495, 21062711, 21062816, 10013686, 10013688,
    10013689, 10013690, 10013691, 10013700, 10013706, 21062911)
ORDER BY t.transaction_id, ta.trans_agent_role;



create table mvz_specimen_part as 
select * from specimen_part 
where derived_from_cat_item in (
    select collection_object_id 
    from cataloged_item 
    where collection_id > 27);

82189

@spec_part_fix_sponly_getid.sqlo

alter table mvz_specimen_part add stale number(1);

@spec_part_fix_sponly.sql

ALTER TRIGGER SPECIMEN_PART_CT_CHECK DISABLE;
ALTER TRIGGER UP_FLAT_PART DISABLE;

UPDATE specimen_part sp SET
    (sp.part_name, sp.part_modifier, sp.preserve_method) 
    = (
    SELECT msp.part_name, msp.part_modifier, msp.preserve_method
    FROM mvz_specimen_part msp
    WHERE msp.stale = 1
    AND sp.collection_object_id = msp.collection_object_id
    )
WHERE sp.collection_object_id IN (
    SELECT collection_object_id
    FROM mvz_specimen_part
    WHERE stale = 1);
    
ALTER TRIGGER SPECIMEN_PART_CT_CHECK ENABLE;
ALTER TRIGGER UP_FLAT_PART enable;

UPDATE flatSET stale_flag = 1
WHERE collection_object_id IN (
SELECT derived_from_cat_item 
FROM mvz_specimen_part
WHERE stale = 1);

SELECT COUNT(*) FROM flat WHERE stale = 1;

create index ix_mvz_specimen_part on mvz_specimen_part ( collection_object_id);
create index ix_mvz_specpart_partname on mvz_specimen_part (part_name);
create index ix_mvz_specpart_partmod on mvz_specimen_part (part_modifier);
create index ix_mvz_specpart_preserve on  mvz_specimen_part (preserve_method);
create index ix_mvz_specpart_stale on mvz_specimen_part (stale);
