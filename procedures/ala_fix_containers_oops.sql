CREATE OR REPLACE PROCEDURE ALA_FIX_CONTAINERS_OOPS IS
    cid NUMBER;
	pcid NUMBER;
	part_id NUMBER;
	part_container_id NUMBER;
begin
    -- first, update all the sheets
    FOR s IN (
        SELECT BARCODE 
        FROM ala_plant_imaging
        where status in (
            'pre_existing',
            'loaded',
            'loaded_containerized',
            'pre_existing_containerized')
        GROUP BY BARCODE
    ) LOOP
        UPDATE container
        SET container_type = 'herbarium sheet'
        WHERE barcode = s.barcode;
    END LOOP;
end;
/
