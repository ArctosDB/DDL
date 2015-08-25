/*	 job to execute update to fire triggers
*/
exec DBMS_SCHEDULER.DROP_JOB('UPD_TAXONOMY');
exec DBMS_SCHEDULER.RUN_JOB('UPD_TAXONOMY');
exec DBMS_SCHEDULER.RUN_JOB('UPD_TAXONOMY', USE_CURRENT_SESSION=>TRUE);

ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY';

BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'UPD_TAXONOMY',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'SP_UPD_TAXONOMY',
		start_date		=> to_timestamp_tz(sysdate || ' 01:00:00', 'DD-MON-YYYY HH24:MI:SS'),
		repeat_interval	=> 'freq=daily;',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'updates taxonomy to fire triggers for building full taxon and scientific names');
END;
/ 

create index ix_taxon_arch_tnid on taxonomy_archive (taxon_name_id);
alter index ix_taxon_arch_tnid rebuild tablespace uam_idx_1;

DECLARE
    sd TIMESTAMP;
BEGIN
    FOR tnid IN (
        SELECT taxon_name_id FROM taxonomy WHERE taxon_name_id <= 10
    ) LOOP
        SELECT systimestamp INTO sd FROM dual;
        dbms_output.put_line(tnid.taxon_name_id || chr(9) || sd);
        UPDATE taxonomy SET source_authority = source_authority
        WHERE taxon_name_id = tnid.taxon_name_id;
    END LOOP;
END;
/


DECLARE
    sd TIMESTAMP;
    c number;
BEGIN
    c := 0;
    SELECT systimestamp INTO sd FROM dual;
    dbms_output.put_line(c || chr(9) || sd);
    FOR tnid IN (
        SELECT taxon_name_id FROM taxonomy
        WHERE taxon_name_id > 10
        and taxon_name_id <= 1000
        order by taxon_name_id
    ) LOOP
        c := c + 1;
        if mod(c, 100) = 0 then
            SELECT systimestamp INTO sd FROM dual;
            dbms_output.put_line(c || chr(9) || sd || chr(9) || tnid.taxon_name_id);
        end if;
        UPDATE taxonomy SET source_authority = source_authority
        WHERE taxon_name_id = tnid.taxon_name_id;
    END LOOP;
    SELECT systimestamp INTO sd FROM dual;
    dbms_output.put_line(c || chr(9) || sd);
END;
/

DECLARE
    sd TIMESTAMP;
    c number;
BEGIN
    c := 0;
    SELECT systimestamp INTO sd FROM dual;
    dbms_output.put_line(c || chr(9) || sd);
    FOR tnid IN (
        SELECT taxon_name_id
        FROM taxonomy
        WHERE taxon_name_id > 1000 
        AND taxon_name_id < 2000000
        order by taxon_name_id
    ) LOOP
        c := c + 1;
        if mod(c, 1000) = 0 then
            SELECT systimestamp INTO sd FROM dual;
            dbms_output.put_line(c || chr(9) || sd || chr(9) || tnid.taxon_name_id);
        end if;
        UPDATE taxonomy SET source_authority = source_authority
        WHERE taxon_name_id = tnid.taxon_name_id;
    END LOOP;
    SELECT systimestamp INTO sd FROM dual;
    dbms_output.put_line(c || chr(9) || sd);
END;
/

DECLARE
    sd TIMESTAMP;
    c number;
BEGIN
    c := 0;
    SELECT systimestamp INTO sd FROM dual;
    dbms_output.put_line(c || chr(9) || sd);
    FOR tnid IN (
        SELECT taxon_name_id
        FROM taxonomy
        WHERE taxon_name_id >= 2000000 AND taxon_name_id < 2300000;
        order by taxon_name_id
    ) LOOP
        c := c + 1;
        if mod(c, 1000) = 0 then
            SELECT systimestamp INTO sd FROM dual;
            dbms_output.put_line(c || chr(9) || sd || chr(9) || tnid.taxon_name_id);
        end if;
        UPDATE taxonomy SET source_authority = source_authority
        WHERE taxon_name_id = tnid.taxon_name_id;
    END LOOP;
    SELECT systimestamp INTO sd FROM dual;
    dbms_output.put_line(c || chr(9) || sd);
END;
/

DECLARE
    sd TIMESTAMP;
    c number;
BEGIN
    c := 0;
    SELECT systimestamp INTO sd FROM dual;
    dbms_output.put_line(c || chr(9) || sd);
    FOR tnid IN (
        SELECT taxon_name_id
        FROM taxonomy
        WHERE taxon_name_id >= 2300000 AND taxon_name_id < 2600000;
        order by taxon_name_id
    ) LOOP
        c := c + 1;
        if mod(c, 1000) = 0 then
            SELECT systimestamp INTO sd FROM dual;
            dbms_output.put_line(c || chr(9) || sd || chr(9) || tnid.taxon_name_id);
        end if;
        UPDATE taxonomy SET source_authority = source_authority
        WHERE taxon_name_id = tnid.taxon_name_id;
    END LOOP;
    SELECT systimestamp INTO sd FROM dual;
    dbms_output.put_line(c || chr(9) || sd);
END;
/

DECLARE
    sd TIMESTAMP;
    c number;
BEGIN
    c := 0;
    SELECT systimestamp INTO sd FROM dual;
    dbms_output.put_line(c || chr(9) || sd);
    FOR tnid IN (
        SELECT taxon_name_id
        FROM taxonomy
        WHERE taxon_name_id >= 2600000 AND taxon_name_id < 2900000;
        order by taxon_name_id
    ) LOOP
        c := c + 1;
        if mod(c, 1000) = 0 then
            SELECT systimestamp INTO sd FROM dual;
            dbms_output.put_line(c || chr(9) || sd || chr(9) || tnid.taxon_name_id);
        end if;
        UPDATE taxonomy SET source_authority = source_authority
        WHERE taxon_name_id = tnid.taxon_name_id;
    END LOOP;
    SELECT systimestamp INTO sd FROM dual;
    dbms_output.put_line(c || chr(9) || sd);
END;
/

DECLARE
    sd TIMESTAMP;
    c number;
BEGIN
    c := 0;
    SELECT systimestamp INTO sd FROM dual;
    dbms_output.put_line(c || chr(9) || sd);
    FOR tnid IN (
        SELECT taxon_name_id
        FROM taxonomy
        WHERE taxon_name_id >= 2900000;
        order by taxon_name_id
    ) LOOP
        c := c + 1;
        if mod(c, 1000) = 0 then
            SELECT systimestamp INTO sd FROM dual;
            dbms_output.put_line(c || chr(9) || sd || chr(9) || tnid.taxon_name_id);
        end if;
        UPDATE taxonomy SET source_authority = source_authority
        WHERE taxon_name_id = tnid.taxon_name_id;
    END LOOP;
    SELECT systimestamp INTO sd FROM dual;
    dbms_output.put_line(c || chr(9) || sd);
END;
/



CREATE OR REPLACE TRIGGER TRG_UP_TAX
AFTER UPDATE ON TAXONOMY
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
BEGIN
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
        kingdom,
        nomenclatural_code,
        infraspecific_author,
        sci_name_with_auths,
        sci_name_no_irank,
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
        :old.kingdom,
        :old.nomenclatural_code,
        :old.infraspecific_author,
        :old.sci_name_with_auths,
        :old.sci_name_no_irank,
        :old.subclass,
        :old.superfamily);
END;
/


uam@arctos> select count(*) from taxonomy_archive;

  COUNT(*)
----------
    125623

    
select taxon_name_id || '|' || family || '|' || full_taxon_name
from taxonomy
where family is not null
and instr(full_taxon_name, family) < 1;

1940157| Cuculidae|Cuculidae Cuculinae Chrysococcyx rufomerus
1940156| Cuculidae|Cuculidae Cuculinae Chrysococcyx russatus
1895365|Alcidae|Cyclorrhynchus psittacula
1893223|Anatidae|Oxyura dominica
1915004|Anguidae|Anniella nigra
1894822|Anguidae|Gerrhonotus multicarinatus
1910084|Aplodontidae|Aplodontia chryseola
1910086|Aplodontidae|Aplodontia humboldtiana
1910085|Aplodontidae|Aplodontia nigra
2009579|Arthroleptidae|Amphibia Anura Cardioglossa aureoli
1991992|Boidae|Calabaria reinhardtii
1897657|Canidae|Canis dingo
3182661|Cricetidae|Mammalia Rodentia Muridae Peromyscus floridanus
1895633|Cricetidae|Mammalia Rodentia Myomorpha Muridae Arvicolinae Microtus breweri
1994067|Cricetidae|Mammalia Rodentia Myomorpha Muridae Arvicolinae Volemys kikuchii
1991074|Cricetidae|Mammalia Rodentia Myomorpha Muridae Sigmodontinae Auliscomys micropus
1992188|Cricetidae|Mammalia Rodentia Myomorpha Muridae Sigmodontinae Wilfredomys pictipes
1984976|Dasypodidae|Priodontes giganteus
1895153|Diomedeidae|Aves Ciconiiformes Diomedea chlororhynchos
1895155|Diomedeidae|Aves Ciconiiformes Diomedea chrysostoma
1895154|Diomedeidae|Diomedea bulleri
1895157|Diomedeidae|Diomedea irrorata
1108005|Emberizidae|Aves Passeriformes Thraupidae Diglossa brunneiventris
1108007|Emberizidae|Aves Passeriformes Thraupidae Diglossa brunneiventris brunneiventris
1107997|Emberizidae|Aves Passeriformes Thraupidae Diglossa mystacalis pectoralis
1894605|Emydidae|Chrysemys scripta
1893830|Falconidae|Daptrius americanus
1893954|Hylidae|Hyla crucifer
2016972|Ichthyophiidae|Amphibia Gymnophiona Ichthyophis kohtaoensis
1958389|Iguanidae|Reptilia Iguania Sceloporus rufidorsum
1939394|Laridae|Catharacta chilensis
2015361|Megophryidae|Amphibia Anura Xenophrys omeimontis
1959190|Plethodontidae|Nototriton adelos
1959191|Plethodontidae|Nototriton alvarezdeltoroi
1938199|Plethodontidae|Nototriton nasalis
1894552|Plethodontidae|Typhlomolge rathbuni
1992000|Pythonidae|Liasis childreni
2013080|Ranidae|Amphibia Anura Petropedetes natator
1894613|Trionychidae|Trionyx ferox
1894614|Trionychidae|Trionyx muticus
1894615|Trionychidae|Trionyx sinensis
1894616|Trionychidae|Trionyx spiniferus
1992007|Viperidae|Bothrops nasutus
1992009|Viperidae|Bothrops nummifer
1992010|Viperidae|Bothrops schlegelii
1940867|Viperidae|Crotalus exsul

  1  select taxon_name_id || '|' || family || '|' || full_taxon_name
  2  from taxonomy
  3  where taxon_name_id in (
  4  1940157, 1940156, 1895365, 1893223, 1915004, 1894822, 1910084, 1910086,
  5  1910085, 2009579, 1991992, 1897657, 3182661, 1895633, 1994067, 1991074,
  6  1992188, 1984976, 1895153, 1895155, 1895154, 1895157, 1108005, 1108007,
  7  1107997, 1894605, 1893830, 1893954, 2016972, 1958389, 1939394, 2015361,
  8  1959190, 1959191, 1938199, 1894552, 1992000, 2013080, 1894613, 1894614,
  9  1894615, 1894616, 1992007, 1992009, 1992010, 1940867)
 10* order by family, full_taxon_name
uam@arctos> set linesize 300
uam@arctos> /

TAXON_NAME_ID||'|'||FAMILY||'|'||FULL_TAXON_NAME
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
1940157| Cuculidae|Cuculidae Cuculinae Chrysococcyx rufomerus
1940156| Cuculidae|Cuculidae Cuculinae Chrysococcyx russatus
1895365|Alcidae|Aves Charadriiformes Alcidae Cyclorrhynchus psittacula
1893223|Anatidae|Aves Anseriformes Anatidae Anatinae Oxyura dominica
1915004|Anguidae|Reptilia Squamata Scleroglossa Anguidae Anniella nigra
1894822|Anguidae|Reptilia Squamata Scleroglossa Anguidae Gerrhonotus multicarinatus
1910084|Aplodontidae|Mammalia Rodentia Sciurognathi Aplodontidae Aplodontia chryseola
1910086|Aplodontidae|Mammalia Rodentia Sciurognathi Aplodontidae Aplodontia humboldtiana
1910085|Aplodontidae|Mammalia Rodentia Sciurognathi Aplodontidae Aplodontia nigra
2009579|Arthroleptidae|Amphibia Anura Arthroleptidae Cardioglossa aureoli
1991992|Boidae|Reptilia Squamata Serpentes Boidae Calabaria reinhardtii
1897657|Canidae|Mammalia Carnivora Canidae Canis dingo
1895633|Cricetidae|Mammalia Rodentia Sciurognathi Cricetidae Arvicolinae Microtus breweri
1994067|Cricetidae|Mammalia Rodentia Sciurognathi Cricetidae Arvicolinae Volemys kikuchii
3182661|Cricetidae|Mammalia Rodentia Sciurognathi Cricetidae Neotominae Peromyscus floridanus
1991074|Cricetidae|Mammalia Rodentia Sciurognathi Cricetidae Sigmodontinae Auliscomys micropus
1992188|Cricetidae|Mammalia Rodentia Sciurognathi Cricetidae Sigmodontinae Wilfredomys pictipes
1984976|Dasypodidae|Mammalia Cingulata Dasypodidae Priodontes giganteus
1895154|Diomedeidae|Aves Procellariiformes Diomedeidae Diomedea bulleri
1895153|Diomedeidae|Aves Procellariiformes Diomedeidae Diomedea chlororhynchos
1895155|Diomedeidae|Aves Procellariiformes Diomedeidae Diomedea chrysostoma
1895157|Diomedeidae|Aves Procellariiformes Diomedeidae Diomedea irrorata
1108005|Emberizidae|Aves Passeriformes Emberizidae Diglossa brunneiventris
1108007|Emberizidae|Aves Passeriformes Emberizidae Diglossa brunneiventris brunneiventris
1107997|Emberizidae|Aves Passeriformes Emberizidae Diglossa mystacalis pectoralis
1894605|Emydidae|Reptilia Testudines Cryptodira Emydidae Chrysemys scripta
1893830|Falconidae|Aves Falconiformes Falconidae Caracarinae Daptrius americanus
1893954|Hylidae|Amphibia Anura Hylidae Hyla crucifer
2016972|Ichthyophiidae|Amphibia Gymnophiona Ichthyophiidae Ichthyophis kohtaoensis
1958389|Iguanidae|Reptilia Squamata Iguania Iguanidae Sceloporus rufidorsum
1939394|Laridae|Aves Charadriiformes Laridae Stercorariinae Catharacta chilensis
2015361|Megophryidae|Amphibia Anura Megophryidae Xenophrys omeimontis
1959190|Plethodontidae|Amphibia Caudata Plethodontidae Nototriton adelos
1959191|Plethodontidae|Amphibia Caudata Plethodontidae Nototriton alvarezdeltoroi
1938199|Plethodontidae|Amphibia Caudata Plethodontidae Nototriton nasalis
1894552|Plethodontidae|Amphibia Caudata Plethodontidae Typhlomolge rathbuni
1992000|Pythonidae|Reptilia Squamata Serpentes Pythonidae Liasis childreni
2013080|Ranidae|Amphibia Anura Ranidae Petropedetes natator
1894613|Trionychidae|Reptilia Testudines Cryptodira Trionychidae Trionyx ferox
1894614|Trionychidae|Reptilia Testudines Cryptodira Trionychidae Trionyx muticus
1894615|Trionychidae|Reptilia Testudines Cryptodira Trionychidae Trionyx sinensis
1894616|Trionychidae|Reptilia Testudines Cryptodira Trionychidae Trionyx spiniferus
1992007|Viperidae|Reptilia Squamata Serpentes Viperidae Bothrops nasutus
1992009|Viperidae|Reptilia Squamata Serpentes Viperidae Bothrops nummifer
1992010|Viperidae|Reptilia Squamata Serpentes Viperidae Bothrops schlegelii
1940867|Viperidae|Reptilia Squamata Serpentes Viperidae Crotalus exsul

uam@arctos> SELECT COUNT(*) FROM taxonomy WHERE taxon_name_id > 1000 AND taxon_name_id < 2000000;
SELECT COUNT(*) FROM taxonomy WHERE taxon_name_id >= 2000000 AND taxon_name_id < 2300000;
SELECT COUNT(*) FROM taxonomy WHERE taxon_name_id >= 2300000 AND taxon_name_id < 2600000;
SELECT COUNT(*) FROM taxonomy WHERE taxon_name_id >= 2600000 AND taxon_name_id < 2900000;
SELECT COUNT(*) FROM taxonomy WHERE taxon_name_id >= 2900000;

  COUNT(*)
----------
    341452

1 row selected.

Elapsed: 00:00:00.05
uam@arctos> 
  COUNT(*)
----------
    297742

1 row selected.

Elapsed: 00:00:00.05
uam@arctos> 
  COUNT(*)
----------
    300000

1 row selected.

Elapsed: 00:00:00.04
uam@arctos> 
  COUNT(*)
----------
    300000

1 row selected.

Elapsed: 00:00:00.03
uam@arctos> 
  COUNT(*)
----------
    294608

1 row selected.

Elapsed: 00:00:00.03
uam@arctos> select 341452 + 297742 + 300000 + 300000 + 294608 from dual;

341452+297742+300000+300000+294608
----------------------------------
                           1533802

1 row selected.

Elapsed: 00:00:00.01
uam@arctos> select count(*) from taxonomy where taxon_name_id > 1000;

  COUNT(*)
----------
   1533802

1 row selected.
