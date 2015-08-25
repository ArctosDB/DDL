CREATE TABLE lkv_county AS
SELECT
 u.GEOG_AUTH_REC_ID AS uGEOG_AUTH_REC_ID,
 u.CONTINENT_OCEAN AS uCONTINENT_OCEAN,
 u.COUNTRY AS uCOUNTRY,
 u.STATE_PROV AS uSTATE_PROV,
 u.COUNTY AS uCOUNTY,
 u.QUAD AS uQUAD,
 u.FEATURE AS uFEATURE,
 u.ISLAND AS uISLAND,
 u.ISLAND_GROUP AS uISLAND_GROUP,
 u.SEA AS uSEA,
 u.VALID_CATALOG_TERM_FG AS uVALID_CATALOG_TERM_FG,
 u.SOURCE_AUTHORITY AS uSOURCE_AUTHORITY,
 u.HIGHER_GEOG AS uHIGHER_GEOG,
 u.GEOG_AUTH_REC_ID|| '|' ||
 u.CONTINENT_OCEAN || '|' ||
 u.COUNTRY || '|' ||
 u.STATE_PROV || '|' ||
 u.COUNTY || '|' ||
 u.QUAD || '|' ||
 u.FEATURE || '|' ||
 u.ISLAND || '|' ||
 u.ISLAND_GROUP || '|' ||
 u.SEA || '|' ||
 u.VALID_CATALOG_TERM_FG || '|' ||
 u.SOURCE_AUTHORITY || '|' ||
 u.HIGHER_GEOG AS uam_geog,
 u.CONTINENT_OCEAN || '|' ||
 u.COUNTRY || '|' ||
 u.STATE_PROV || '|' ||
 regexp_replace(u.COUNTY,' County','') || '|' ||
 u.QUAD || '|' ||
 u.FEATURE || '|' ||
 u.ISLAND || '|' ||
 u.ISLAND_GROUP || '|' ||
 u.SEA || '|' ||
 u.VALID_CATALOG_TERM_FG || '|' ||
 regexp_replace(u.HIGHER_GEOG,' County','') AS uam_geog_noco,
 u.CONTINENT_OCEAN || '|' ||
 u.COUNTRY || '|' ||
 u.STATE_PROV || '|' ||
 regexp_replace(u.COUNTY,' County','') || '|' ||
 u.QUAD || '|' ||
 u.FEATURE || '|' ||
 u.ISLAND || '|' ||
 u.ISLAND_GROUP || '|' ||
 u.SEA || '|' ||
 regexp_replace(u.HIGHER_GEOG,' County','') AS uam_geog_nofg,
 m.GEOG_AUTH_REC_ID AS mGEOG_AUTH_REC_ID,
 m.CONTINENT_OCEAN AS mCONTINENT_OCEAN,
 m.COUNTRY AS mCOUNTRY,
 m.STATE_PROV AS mSTATE_PROV,
 m.COUNTY AS mCOUNTY,
 m.QUAD AS mQUAD,
 m.FEATURE AS mFEATURE,
 m.ISLAND AS mISLAND,
 m.ISLAND_GROUP AS mISLAND_GROUP,
 m.SEA AS mSEA,
 m.VALID_CATALOG_TERM_FG AS mVALID_CATALOG_TERM_FG,
 m.SOURCE_AUTHORITY AS mSOURCE_AUTHORITY,
 m.HIGHER_GEOG AS mHIGHER_GEOG,
 m.GEOG_AUTH_REC_ID|| '|' ||
 m.CONTINENT_OCEAN || '|' ||
 m.COUNTRY || '|' ||
 m.STATE_PROV || '|' ||
 m.COUNTY || '|' ||
 m.QUAD || '|' ||
 m.FEATURE || '|' ||
 m.ISLAND || '|' ||
 m.ISLAND_GROUP || '|' ||
 m.SEA || '|' ||
 m.VALID_CATALOG_TERM_FG || '|' ||
 m.SOURCE_AUTHORITY || '|' ||
 m.HIGHER_GEOG AS mvz_geog,
 m.CONTINENT_OCEAN || '|' ||
 m.COUNTRY || '|' ||
 m.STATE_PROV || '|' ||
 regexp_replace(m.COUNTY,' Co\.','') || '|' ||
 m.QUAD || '|' ||
 m.FEATURE || '|' ||
 m.ISLAND || '|' ||
 m.ISLAND_GROUP || '|' ||
 m.SEA || '|' ||
 m.VALID_CATALOG_TERM_FG || '|' ||
 regexp_replace(m.HIGHER_GEOG,' Co\.','') AS mvz_geog_noco,
 m.CONTINENT_OCEAN || '|' ||
 m.COUNTRY || '|' ||
 m.STATE_PROV || '|' ||
 regexp_replace(m.COUNTY,' Co\.','') || '|' ||
 m.QUAD || '|' ||
 m.FEATURE || '|' ||
 m.ISLAND || '|' ||
 m.ISLAND_GROUP || '|' ||
 m.SEA || '|' ||
 regexp_replace(m.HIGHER_GEOG,' Co\.','') AS mvz_geog_nofg
FROM geog_auth_rec u, geog_auth_rec m
WHERE u.GEOG_AUTH_REC_ID != m.GEOG_AUTH_REC_ID
AND regexp_replace(u.HIGHER_GEOG, ' County$', '') = regexp_replace(m.HIGHER_GEOG, ' Co\.$', '')
AND u.COUNTY LIKE '% County'
AND m.COUNTY LIKE '% Co.'


UPDATE locality l SET l.geog_auth_rec_id = (
    SELECT x.ugeog_auth_rec_id
    FROM lkv_county x
    WHERE x.mgeog_auth_rec_id = l.geog_auth_rec_id
    AND x.uam_geog_noco = x.mvz_geog_noco)
WHERE l.geog_auth_rec_id IN (
    SELECT mgeog_auth_rec_id 
    FROM lkv_county 
    WHERE uam_geog_noco = mvz_geog_noco);

  1  select count(*) from locality l, lkv_county lkv
  2  where l.geog_auth_rec_id = lkv.mgeog_auth_rec_id
  3  and lkv.uam_geog_noco != lkv.mvz_geog_noco
  4* and lkv.uam_geog_nofg = lkv.mvz_geog_nofg
uam@arctos> /

  COUNT(*)
----------
     67975

  1  select count(*) from flat where locality_id in (
  2  select locality_id from locality l, lkv_county lkv
  3  where l.geog_auth_rec_id = lkv.mgeog_auth_rec_id
  4  and lkv.uam_geog_noco != lkv.mvz_geog_noco
  5  and lkv.uam_geog_nofg = lkv.mvz_geog_nofg
  6* )
uam@arctos> /

  COUNT(*)
----------
    370590

BEGIN
FOR gar IN (
    SELECT mgeog_auth_rec_id, ugeog_auth_rec_id, mhigher_geog
    FROM lkv_county
    WHERE uam_geog_noco != mvz_geog_noco
    AND uam_geog_nofg = mvz_geog_nofg
    ORDER BY mhigher_geog
) LOOP
    BEGIN
    dbms_output.put_line(gar.mhigher_geog || chr(10) || chr(9) ||
        'MVZ: ' || gar.mgeog_auth_rec_id || chr(9) || 'UAM: ' || gar.ugeog_auth_rec_id);
    UPDATE locality SET geog_auth_rec_id = gar.ugeog_auth_rec_id
        WHERE geog_auth_rec_id = gar.mgeog_auth_rec_id;
    COMMIT;
    EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('ERROR: ' ||SQLERRM);
    END;
END LOOP;
END;
/    

DELETE FROM geog_auth_rec WHERE geog_auth_rec_id IN (
    SELECT mgeog_auth_rec_id 
	FROM lkv_county
	WHERE uam_geog_nofg = mvz_geog_nofg);

  1  UPDATE geog_auth_rec SET county = regexp_replace(county,' Co\.$',' County')
  2  WHERE county LIKE '% Co.'
  3  AND geog_auth_rec_id != 10002531
  4  and geog_auth_rec_id not in (
  5  select geog_auth_rec_id from lkv_geog_auth_rec
  6  where higher_geog in (
  7  select higher_geog from lkv_geog_auth_rec group by higher_geog having count(*) > 1
  8  )
  9* )


  1  select
  2   u.GEOG_AUTH_REC_ID|| '|' ||
  3   u.CONTINENT_OCEAN || '|' ||
  4   u.COUNTRY || '|' ||
  5   u.STATE_PROV || '|' ||
  6   u.COUNTY || '|' ||
  7   u.QUAD || '|' ||
  8   u.FEATURE || '|' ||
  9   u.ISLAND || '|' ||
 10   u.ISLAND_GROUP || '|' ||
 11   u.SEA || '|' ||
 12   u.VALID_CATALOG_TERM_FG || '|' ||
 13   u.SOURCE_AUTHORITY || '|' ||
 14   u.HIGHER_GEOG AS uam_geog
 15  from geog_auth_rec u
 16  where u.geog_auth_rec_id in (
 17  select geog_auth_rec_id from lkv_geog_auth_rec
 18  where higher_geog in (
 19  select higher_geog from lkv_geog_auth_rec group by higher_geog having count(*) > 1
 20  )
 21  )
 22* order by u.county
uam@arctos> /

UAM_GEOG
--------------------------------------------------------------------------------
10003009|North America|United States|Texas|Cameron Co.|||Padre Island|||1|Museum
 of Vertebrate Zoology|North America, United States, Texas, Cameron Co., Padre I
sland

4967|North America|United States|Texas|Cameron County|||Padre Island|||1|Univers
ity of Alaska Museum|North America, United States, Texas, Cameron County, Padre
Island

1005061|North America|United States|New Mexico|De Baca||||||1|Museum of Southwes
tern Biology|North America, United States, New Mexico, De Baca County

10002526|North America|United States|New Mexico|De Baca Co.||||||1|Museum of Ver
tebrate Zoology|North America, United States, New Mexico, De Baca Co.

10003277|North America|United States|Washington|Kitsap Co.|||Bainbridge Island||
|1|Museum of Vertebrate Zoology|North America, United States, Washington, Kitsap
 Co., Bainbridge Island

1001207|North America|United States|Washington|Kitsap County|||Bainbridge Island
|||1|Museum of Southwestern Biology|North America, United States, Washington, Ki
tsap County, Bainbridge Island

10001582|North America|United States|California|Santa Barbara Co.|||San Miguel I
sland|Channel Islands||1|Museum of Vertebrate Zoology|North America, United Stat
es, California, Santa Barbara Co., Channel Islands, San Miguel Island

980|North America|United States|California|Santa Barbara County|||San Miguel Isl
and|Channel Islands||0|University of Alaska Museum|North America, United States,
 California, Santa Barbara County, Channel Islands, San Miguel Island


8 rows selected.

INSERT INTO lkv_county
SELECT
 u.GEOG_AUTH_REC_ID AS uGEOG_AUTH_REC_ID,
 u.CONTINENT_OCEAN AS uCONTINENT_OCEAN,
 u.COUNTRY AS uCOUNTRY,
 u.STATE_PROV AS uSTATE_PROV,
 u.COUNTY AS uCOUNTY,
 u.QUAD AS uQUAD,
 u.FEATURE AS uFEATURE,
 u.ISLAND AS uISLAND,
 u.ISLAND_GROUP AS uISLAND_GROUP,
 u.SEA AS uSEA,
 u.VALID_CATALOG_TERM_FG AS uVALID_CATALOG_TERM_FG,
 u.SOURCE_AUTHORITY AS uSOURCE_AUTHORITY,
 u.HIGHER_GEOG AS uHIGHER_GEOG,
 u.GEOG_AUTH_REC_ID|| '|' ||
 u.CONTINENT_OCEAN || '|' ||
 u.COUNTRY || '|' ||
 u.STATE_PROV || '|' ||
 u.COUNTY || '|' ||
 u.QUAD || '|' ||
 u.FEATURE || '|' ||
 u.ISLAND || '|' ||
 u.ISLAND_GROUP || '|' ||
 u.SEA || '|' ||
 u.VALID_CATALOG_TERM_FG || '|' ||
 u.SOURCE_AUTHORITY || '|' ||
 u.HIGHER_GEOG AS uam_geog,
 u.CONTINENT_OCEAN || '|' ||
 u.COUNTRY || '|' ||
 u.STATE_PROV || '|' ||
 regexp_replace(u.COUNTY,' County','') || '|' ||
 u.QUAD || '|' ||
 u.FEATURE || '|' ||
 u.ISLAND || '|' ||
 u.ISLAND_GROUP || '|' ||
 u.SEA || '|' ||
 u.VALID_CATALOG_TERM_FG || '|' ||
 regexp_replace(u.HIGHER_GEOG,' County','') AS uam_geog_noco,
 u.CONTINENT_OCEAN || '|' ||
 u.COUNTRY || '|' ||
 u.STATE_PROV || '|' ||
 regexp_replace(u.COUNTY,' County','') || '|' ||
 u.QUAD || '|' ||
 u.FEATURE || '|' ||
 u.ISLAND || '|' ||
 u.ISLAND_GROUP || '|' ||
 u.SEA || '|' ||
 regexp_replace(u.HIGHER_GEOG,' County','') AS uam_geog_nofg,
 m.GEOG_AUTH_REC_ID AS mGEOG_AUTH_REC_ID,
 m.CONTINENT_OCEAN AS mCONTINENT_OCEAN,
 m.COUNTRY AS mCOUNTRY,
 m.STATE_PROV AS mSTATE_PROV,
 m.COUNTY AS mCOUNTY,
 m.QUAD AS mQUAD,
 m.FEATURE AS mFEATURE,
 m.ISLAND AS mISLAND,
 m.ISLAND_GROUP AS mISLAND_GROUP,
 m.SEA AS mSEA,
 m.VALID_CATALOG_TERM_FG AS mVALID_CATALOG_TERM_FG,
 m.SOURCE_AUTHORITY AS mSOURCE_AUTHORITY,
 m.HIGHER_GEOG AS mHIGHER_GEOG,
 m.GEOG_AUTH_REC_ID|| '|' ||
 m.CONTINENT_OCEAN || '|' ||
 m.COUNTRY || '|' ||
 m.STATE_PROV || '|' ||
 m.COUNTY || '|' ||
 m.QUAD || '|' ||
 m.FEATURE || '|' ||
 m.ISLAND || '|' ||
 m.ISLAND_GROUP || '|' ||
 m.SEA || '|' ||
 m.VALID_CATALOG_TERM_FG || '|' ||
 m.SOURCE_AUTHORITY || '|' ||
 m.HIGHER_GEOG AS mvz_geog,
 m.CONTINENT_OCEAN || '|' ||
 m.COUNTRY || '|' ||
 m.STATE_PROV || '|' ||
 regexp_replace(m.COUNTY,' Co\.','') || '|' ||
 m.QUAD || '|' ||
 m.FEATURE || '|' ||
 m.ISLAND || '|' ||
 m.ISLAND_GROUP || '|' ||
 m.SEA || '|' ||
 m.VALID_CATALOG_TERM_FG || '|' ||
 regexp_replace(m.HIGHER_GEOG,' Co\.','') AS mvz_geog_noco,
 m.CONTINENT_OCEAN || '|' ||
 m.COUNTRY || '|' ||
 m.STATE_PROV || '|' ||
 regexp_replace(m.COUNTY,' Co\.','') || '|' ||
 m.QUAD || '|' ||
 m.FEATURE || '|' ||
 m.ISLAND || '|' ||
 m.ISLAND_GROUP || '|' ||
 m.SEA || '|' ||
 regexp_replace(m.HIGHER_GEOG,' Co\.','') AS mvz_geog_nofg
FROM geog_auth_rec u, geog_auth_rec m
WHERE u.GEOG_AUTH_REC_ID != m.GEOG_AUTH_REC_ID
AND regexp_replace(u.HIGHER_GEOG, ' County,', '') = regexp_replace(m.HIGHER_GEOG, ' Co\.,', '')
AND u.COUNTY LIKE '% County'
AND m.COUNTY LIKE '% Co.'

UPDATE locality l SET l.geog_auth_rec_id = (
    SELECT x.ugeog_auth_rec_id
    FROM lkv_county x
    WHERE x.mgeog_auth_rec_id = l.geog_auth_rec_id
    AND x.mhigher_geog like '% Co.,%')
WHERE l.geog_auth_rec_id IN (
    SELECT mgeog_auth_rec_id 
    FROM lkv_county 
    WHERE mhigher_geog like '% Co.,%')

delete from geog_auth_rec 
where geog_auth_rec_id in (
    select mgeog_auth_rec_id 
    from lkv_county 
    where  mhigher_geog like '% Co.,%');