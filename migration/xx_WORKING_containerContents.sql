Ref Issue/#565

select parent_container_id from container where parent_container_id in (
select
	parent_container_id
from
	container having count(*) > 10000 group by parent_container_id);
	
	
	
-- proposed allowable parent type
-- what are institutions in?

-- edit: what are EVERYTHING in?

	
drop table temp;
create table temp (container_type varchar2(255), contains_types varchar2(4000));

declare
	ctlist varchar2(4000);
	sep varchar2(4000);
begin
	for c in (select container_type from ctcontainer_type order by container_type) loop
		sep:='';
		ctlist:='';
		dbms_output.put_line('Container Type: ' || c.container_type);
		for p in (
			select container_type, count(*) cnt from container where parent_container_id in (
				select container_id from container where container_type=c.container_type
			) group by container_type order by container_type
		) loop
			
		ctlist:=ctlist || sep || p.container_type;
		sep:=', ';
			dbms_output.put_line('   Contained By: ' || p.container_type);
			--insert into temp (container_type,contained_by_type,numberchildren) values (c.container_type,p.container_type,p.cnt);
		end loop;
		dbms_output.put_line(c.container_type || ' contains  ' || ctlist);
		insert into temp (container_type,contains_types) values (c.container_type,ctlist);
	end loop;
end;
/

-- spot-check
select c.container_id,c.barcode,c.label from container c, container p where c.parent_container_id=p.container_id and 
c.container_type='box' and p.container_type='cryovial';


freezer contains  Nalgene, bag, box, collection object, cryovial, freezer box, freezer rack, jar, legacy container, posi
tion, tag, unit tray, unknown, vial


Container Type: Nalgene
   Contained By: box
   Contained By: freezer
   Contained By: institution
   Contained By: position
   Contained By: room
   Contained By: shelf
   Contained By: tray
Container Type: bag
   Contained By: bag
   Contained By: box
   Contained By: cabinet
   Contained By: case
   Contained By: cryovial
   Contained By: freezer
   Contained By: freezer box
   Contained By: jar
   Contained By: legacy container
   Contained By: position
   Contained By: range case
   Contained By: room
   Contained By: shelf
   Contained By: tray
Container Type: box
   Contained By: bag
   Contained By: box
   Contained By: cabinet
   Contained By: case
   Contained By: cryovial
   Contained By: drawer
   Contained By: freezer
   Contained By: institution
   Contained By: jar
   Contained By: legacy container
   Contained By: position
   Contained By: range
   Contained By: range case
   Contained By: room
   Contained By: shelf
   Contained By: tag
   Contained By: tray
   Contained By: unit tray
   Contained By: vial
Container Type: cabinet
   Contained By: range
   Contained By: room
   Contained By: tag
Container Type: case
   Contained By: range
   Contained By: range case
   Contained By: room
Container Type: collection object
   Contained By: Nalgene
   Contained By: bag
   Contained By: box
   Contained By: cryovial
   Contained By: cryovial label
   Contained By: envelope
   Contained By: folder
   Contained By: freezer
   Contained By: freezer box
   Contained By: herbarium folder
   Contained By: herbarium sheet
   Contained By: institution
   Contained By: jar
   Contained By: legacy container
   Contained By: not recorded
   Contained By: pin
   Contained By: position
   Contained By: range
   Contained By: range case
   Contained By: room
   Contained By: shelf
   Contained By: slide
   Contained By: specimen label
   Contained By: tag
   Contained By: tray
   Contained By: unit tray
   Contained By: unknown
   Contained By: vial
   Contained By: vial unit tray
Container Type: container label
Container Type: cryovial
   Contained By: box
   Contained By: cryovial
   Contained By: freezer
   Contained By: freezer box
   Contained By: institution
   Contained By: position
   Contained By: room
   Contained By: tray
Container Type: cryovial label
   Contained By: unit tray
Container Type: drawer
   Contained By: cabinet
   Contained By: case
   Contained By: range
   Contained By: room
Container Type: envelope
   Contained By: box
   Contained By: legacy container
   Contained By: room
   Contained By: unit tray
Container Type: folder
   Contained By: folder
   Contained By: herbarium folder
   Contained By: herbarium sheet
   Contained By: position
Container Type: freezer
   Contained By: room
Container Type: freezer box
   Contained By: box
   Contained By: freezer
   Contained By: freezer box
   Contained By: freezer rack
   Contained By: institution
   Contained By: position
   Contained By: range
   Contained By: room
   Contained By: shelf
Container Type: freezer rack
   Contained By: box
   Contained By: freezer
   Contained By: freezer rack
   Contained By: institution
   Contained By: position
   Contained By: room
   Contained By: tray
Container Type: herbarium folder
   Contained By: folder
   Contained By: herbarium folder
   Contained By: herbarium sheet
   Contained By: position
Container Type: herbarium sheet
   Contained By: folder
   Contained By: herbarium folder
   Contained By: herbarium sheet
   Contained By: specimen label
Container Type: institution
   Contained By: institution
Container Type: jar
   Contained By: box
   Contained By: cabinet
   Contained By: drawer
   Contained By: freezer
   Contained By: jar
   Contained By: position
   Contained By: range
   Contained By: range case
   Contained By: room
   Contained By: shelf
   Contained By: tag
   Contained By: tray
   Contained By: wood case
Container Type: legacy container
   Contained By: bag
   Contained By: box
   Contained By: cabinet
   Contained By: case
   Contained By: drawer
   Contained By: freezer
   Contained By: freezer box
   Contained By: herbarium sheet
   Contained By: jar
   Contained By: legacy container
   Contained By: range
   Contained By: range case
   Contained By: room
   Contained By: shelf
   Contained By: tag
   Contained By: tray
   Contained By: vial
Container Type: microplate
   Contained By: cabinet
   Contained By: institution
Container Type: not recorded
   Contained By: institution
Container Type: pin
   Contained By: box
   Contained By: drawer
   Contained By: institution
   Contained By: room
   Contained By: unit tray
   Contained By: vial
   Contained By: vial unit tray
Container Type: position
   Contained By: box
   Contained By: cabinet
   Contained By: freezer
   Contained By: freezer box
   Contained By: freezer rack
   Contained By: microplate
   Contained By: range case
   Contained By: shelf
   Contained By: slide box
Container Type: range
   Contained By: room
Container Type: range case
   Contained By: range
   Contained By: tray
Container Type: room
   Contained By: institution
   Contained By: room
Container Type: shelf
   Contained By: cabinet
   Contained By: case
   Contained By: jar
   Contained By: range
   Contained By: range case
   Contained By: room
   Contained By: shelf
Container Type: slide
   Contained By: position
   Contained By: room
   Contained By: slide box
Container Type: slide box
   Contained By: cabinet
   Contained By: drawer
   Contained By: room
   Contained By: shelf
Container Type: slide drawer
   Contained By: drawer
Container Type: specimen label
   Contained By: folder
   Contained By: herbarium folder
   Contained By: herbarium sheet
   Contained By: specimen label
   Contained By: tag
Container Type: tag
   Contained By: bag
   Contained By: box
   Contained By: cabinet
   Contained By: case
   Contained By: container label
   Contained By: drawer
   Contained By: envelope
   Contained By: freezer
   Contained By: institution
   Contained By: jar
   Contained By: legacy container
   Contained By: range
   Contained By: range case
   Contained By: room
   Contained By: shelf
   Contained By: slide box
   Contained By: slide drawer
   Contained By: tag
   Contained By: tray
   Contained By: unit tray
   Contained By: vial
   Contained By: vial unit tray
Container Type: tray
   Contained By: box
   Contained By: cabinet
   Contained By: case
   Contained By: range
   Contained By: range case
   Contained By: room
   Contained By: shelf
   Contained By: tray
   Contained By: wood case
Container Type: unit tray
   Contained By: box
   Contained By: cabinet
   Contained By: drawer
   Contained By: freezer
   Contained By: institution
   Contained By: pin
   Contained By: room
   Contained By: shelf
   Contained By: unit tray
   Contained By: unknown
Container Type: unknown
   Contained By: bag
   Contained By: freezer
   Contained By: range
   Contained By: room
   Contained By: tray
   Contained By: unknown
Container Type: vial
   Contained By: box
   Contained By: cabinet
   Contained By: drawer
   Contained By: freezer
   Contained By: freezer box
   Contained By: institution
   Contained By: jar
   Contained By: position
   Contained By: range case
   Contained By: room
   Contained By: shelf
   Contained By: tag
   Contained By: tray
   Contained By: unit tray
   Contained By: unknown
   Contained By: vial
   Contained By: vial unit tray
Container Type: vial unit tray
   Contained By: box
   Contained By: cabinet
   Contained By: drawer
   Contained By: freezer
   Contained By: room
   Contained By: shelf
Container Type: wood case
   Contained By: range
   Contained By: room
   Contained By: tray




select count(*) from container where container_type='institution';
select container_id from container where container_id in (
select parent_container_id from container where container_type='institution'
);

institution --> parent container ID can only be 0 (=parentless void)
room --> institution
freezer --> room
range --->room	
	
	CONTAINER_TYPE
------------------------------------------------------------
Nalgene
bag
box
cabinet
case
collection object
container label
cryovial
cryovial label
drawer
envelope
folder

freezer box
freezer rack
herbarium folder
herbarium sheet
institution
jar
legacy container
microplate
not recorded
pin
position

range case

shelf
slide
slide box
slide drawer
specimen label
tag
tray
unit tray
unknown
vial
vial unit tray
wood case



