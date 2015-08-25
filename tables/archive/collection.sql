ALTER TABLE collection ADD institution varchar2(255);

-- UAM et al stuff
UPDATE collection SET institution='Western New Mexico University'
WHERE institution_acronym='WNMU';

UPDATE collection SET institution='University of Alaska Musem'
WHERE institution_acronym='UAM';

UPDATE collection SET institution='Connor Museum'
WHERE institution_acronym='CRCM';

UPDATE collection SET institution='National Biomonitoring Specimen Bank'
WHERE institution_acronym='NBSB';

UPDATE collection SET institution='Kenelm W. Philip'
WHERE institution_acronym='KWP';

UPDATE collection SET institution='Portland State University'
WHERE institution_acronym='PSU';

UPDATE collection SET institution='Museum of Southwestern Biology'
WHERE institution_acronym='MSB';

UPDATE collection SET institution='University of Alaska Musem'
WHERE institution_acronym='UAMObs';

UPDATE collection SET institution='Museum of Southwestern Biology Division of Genetic Resources'
WHERE institution_acronym='DGR';

UPDATE collection SET institution='Museum of Vertebrate Zoology'
WHERE institution_acronym LIKE 'MVZ%';
