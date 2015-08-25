CREATE OR REPLACE PROCEDURE MAKEDGRFREEZERPOSITIONS ( f in integer, r in integer, b in integer)
is
    i integer;
	slots integer;
	rack integer;
	box integer;
	sc integer;
begin
    i := 1;
	rack := 1;
	box := 1;
	sc := 1;
	slots := r * b * 100;
    for i in 1 .. slots loop
        --DBMS_OUTPUT.PUT_LINE ('rack: ' || rack || '; box: ' || box || '; slot: ' || sc);
        insert into dgr_locator (
            LOCATOR_ID,
            FREEZER,
			RACK,
			BOX,
			PLACE)
        values (
            dgr_locator_seq.nextval,
			f,
			rack,
			box,
			sc);
			
        sc := sc + 1;
        
        if sc = 101 then
            box := box + 1;
            --DBMS_OUTPUT.PUT_LINE ('new box');
            
            if box > b then
                box := 1;
                rack := rack + 1;
                --DBMS_OUTPUT.PUT_LINE ('new rack');
            end if;
                
            sc := 1;
        end if;
    end loop;
end;
/