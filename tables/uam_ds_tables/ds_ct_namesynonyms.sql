-- ds_ct_namesynonyms is a list of name synonyms

-- these should never be used for rules, only suggestions
-- The point of this is to detect and prevent duplicate agents,
-- which make all queries involving agents untrustworthy.
-- Therefore, this list should contain ANY and ALL name variations, no
-- matter how unlikely they might seem. Returning false positives is at worst
-- slightly annoying, while failing to detect duplicates results in data degredation.

-- there is no interface; add via SQL.

-- names should include all synonyms separated by commas
-- ex: Daniel,Dan,Danny

-- do NOT make duplicates. Check this via eg,

-- ex: select names from ds_ct_namesynonyms where lower(names) like lower('%one_name_from_list_im_thinking_about_adding%');




create table ds_ct_namesynonyms (
	names varchar2(4000)
);

create or replace public synonym ds_ct_namesynonyms for ds_ct_namesynonyms;
grant select on ds_ct_namesynonyms to public;
-- not much point in an index, since 
-- Daniel,Dan,Danny
-- Danny,Daniel,Dan
--- etc are possible - just be paranoid....

-- original data

insert into ds_ct_namesynonyms(names) values ('Abraham,Abe'); 
insert into ds_ct_namesynonyms(names) values ('Albert,Al,Bert,Alfred,Alonzo');
insert into ds_ct_namesynonyms(names) values ('Alexandria,Alexandra,Sandy,Sasha,Cassandra,Cassie,Cassy,Alexander,Alec,Alex,Sasha');
insert into ds_ct_namesynonyms(names) values ('Allen,Alan,Al');
insert into ds_ct_namesynonyms(names) values ('Amanda,Manda,Mandy');
insert into ds_ct_namesynonyms(names) values ('Amos,Moses');
insert into ds_ct_namesynonyms(names) values ('Andrew,Andy,Drew');
insert into ds_ct_namesynonyms(names) values ('Angela,Angie');
insert into ds_ct_namesynonyms(names) values ('Anna,Ann,Anna,Hannah,Anne,Annie');
insert into ds_ct_namesynonyms(names) values ('Anthony,Tony');
insert into ds_ct_namesynonyms(names) values ('Arthur,Art,Arturo,Artie');
insert into ds_ct_namesynonyms(names) values ('Barbara,Barb,Barby,Barbie,Babs');
insert into ds_ct_namesynonyms(names) values ('Barnabas,Barnard,Bernard,Bernie,Berny');
insert into ds_ct_namesynonyms(names) values ('Bartholomew,Bart');
insert into ds_ct_namesynonyms(names) values ('Benjamin,Ben,Benny');
insert into ds_ct_namesynonyms(names) values ('Beverly,Bev');
insert into ds_ct_namesynonyms(names) values ('Bradford,Brad,Bradly');
insert into ds_ct_namesynonyms(names) values ('Brian,Bryan,Bryant');
insert into ds_ct_namesynonyms(names) values ('Caleb,Cal');
insert into ds_ct_namesynonyms(names) values ('Charles,Charlie,Charley,Chuck,Chaz');
insert into ds_ct_namesynonyms(names) values ('Christopher,Chris');
insert into ds_ct_namesynonyms(names) values ('Curtis,Curt,Kurtis,Kurt');
insert into ds_ct_namesynonyms(names) values ('Cynthia,Cindi,Cindy');
insert into ds_ct_namesynonyms(names) values ('Carolyn,Carol,Carrie,Cary');
insert into ds_ct_namesynonyms(names) values ('Daniel,Dan,Danny');
insert into ds_ct_namesynonyms(names) values ('Danielle,Danelle');
insert into ds_ct_namesynonyms(names) values ('David,Dave,Davey');
insert into ds_ct_namesynonyms(names) values ('Deborah,Deb,Debbie,Debby,Debra');
insert into ds_ct_namesynonyms(names) values ('Dennis,Denny');
insert into ds_ct_namesynonyms(names) values ('Donald,Don,Donny');
insert into ds_ct_namesynonyms(names) values ('Douglas,Doug');
insert into ds_ct_namesynonyms(names) values ('Dorothy,Dot,Dottie');
insert into ds_ct_namesynonyms(names) values ('Duane,Dewayne,Dwayne,Dwane');
insert into ds_ct_namesynonyms(names) values ('Dusty,Dustin');
insert into ds_ct_namesynonyms(names) values ('Earnest,Ernest,Erny,Ernie');
insert into ds_ct_namesynonyms(names) values ('Edmund,Edward,Ed,Edgar,Eddy,Eddie,Edwin,Ted');
insert into ds_ct_namesynonyms(names) values ('Egbert,Bert,Burt');
insert into ds_ct_namesynonyms(names) values ('Elaine,Eleanor');
insert into ds_ct_namesynonyms(names) values ('Elizabeth,Liz,Beth,Betty');
insert into ds_ct_namesynonyms(names) values ('Eugene,Gene');
insert into ds_ct_namesynonyms(names) values ('Frank,Franklin,Frances');
insert into ds_ct_namesynonyms(names) values ('Gabriel,Gabe,Gabby,Gabbie');
insert into ds_ct_namesynonyms(names) values ('George,Jorge');
insert into ds_ct_namesynonyms(names) values ('Gerald,Jerry,Gerry');
insert into ds_ct_namesynonyms(names) values ('Gregory,Greg,Gregg');
insert into ds_ct_namesynonyms(names) values ('Howard,Hal,Howie');
insert into ds_ct_namesynonyms(names) values ('Irwin,Erwin');
insert into ds_ct_namesynonyms(names) values ('Jacob,Jake,Jakob');
insert into ds_ct_namesynonyms(names) values ('Jacqueline,Jacky,Jackie,Jaclyn,Jacklyn');
insert into ds_ct_namesynonyms(names) values ('James,Jamie,Jamey,Jim,Jimmy,Jimmie,Jay');
insert into ds_ct_namesynonyms(names) values ('Janet,Jan');
insert into ds_ct_namesynonyms(names) values ('Jeffrey,Joffrey,Jeff,Joff');
insert into ds_ct_namesynonyms(names) values ('Jennifer,Jenny,Jennie');
insert into ds_ct_namesynonyms(names) values ('Jessica,Jess,Jesse,Jessy,Jessie');
insert into ds_ct_namesynonyms(names) values ('John,Jon,Hans,Ian,Ivan,Jack,Jan,Jean,Jaques,Jock,Johnathan,Jonathan,Johnny,Jonny');
insert into ds_ct_namesynonyms(names) values ('Joseph,Joe,Jose,Joey');
insert into ds_ct_namesynonyms(names) values ('Joshua,Josh');
insert into ds_ct_namesynonyms(names) values ('Joyce,Joy');
insert into ds_ct_namesynonyms(names) values ('Judith,Judy');
insert into ds_ct_namesynonyms(names) values ('Katherine,Katarina,Kathleen,Cathy,Kat,Kitty,Kate,Katy,Katie,Kayey,Kathy,Kathey,Kit,Cathleen,Catherine,Kathryn,Katherina,Kathe,Katrina');
insert into ds_ct_namesynonyms(names) values ('Kenneth,Ken,Kenney,Kenny');
insert into ds_ct_namesynonyms(names) values ('Kimberly,Kimberly,Kimberlee,Kim,Kym,Kimmy,Kimmie');
insert into ds_ct_namesynonyms(names) values ('Lauryn,Laurie,Lorrie');
insert into ds_ct_namesynonyms(names) values ('Leonard,Leo,Leon,Len,Lenny,Lennie,Lineau,Lenhart');
insert into ds_ct_namesynonyms(names) values ('Leroy,Lee,Roy');
insert into ds_ct_namesynonyms(names) values ('Leslie,Les,Lester');
insert into ds_ct_namesynonyms(names) values ('Lillian,Lil,Lilly,Lillie');
insert into ds_ct_namesynonyms(names) values ('Lincoln,Link');
insert into ds_ct_namesynonyms(names) values ('Linda,Lynn,Lynette,Linette');
insert into ds_ct_namesynonyms(names) values ('Lois,Louise');
insert into ds_ct_namesynonyms(names) values ('Louis,Lewis,Lou,Louie');
insert into ds_ct_namesynonyms(names) values ('Margaret,Maggy,Maggie,Marge,Peg,Peggy,Peggie');
insert into ds_ct_namesynonyms(names) values ('Matthew,Matt,Matthias');
insert into ds_ct_namesynonyms(names) values ('Michael,Mickey,Micky,Mike,Mitchell,Micah,Mick');
insert into ds_ct_namesynonyms(names) values ('Michelle,Mickey,Micky,Shelley,Shelly');
insert into ds_ct_namesynonyms(names) values ('Megan,Meg');
insert into ds_ct_namesynonyms(names) values ('Nicholas,Nick,Nicky,Nico');
insert into ds_ct_namesynonyms(names) values ('Nathan,Nathaniel,Nat,Nate');
insert into ds_ct_namesynonyms(names) values ('Pamela,Pam');
insert into ds_ct_namesynonyms(names) values ('Patricia,Pat,Tricia,Patsy,Patsie,Pattie,Patty,Trixie,Trixi,Trixy,Trish,Tish');
insert into ds_ct_namesynonyms(names) values ('Patrick,Paddie,Paddy,Paddey,Pat,Patsie,Patsy,Peter,Patricia,Pate');
insert into ds_ct_namesynonyms(names) values ('Paulina,Paula,Pollie,Polly,Lina,Pauline');
insert into ds_ct_namesynonyms(names) values ('Peter,Pete,Petey,Pate');
insert into ds_ct_namesynonyms(names) values ('Rebecca,Becka,Becky');
insert into ds_ct_namesynonyms(names) values ('Ric,Richard,Dick,Rich,Rick,Richey,Dickon,Dickson,Ricky,Rickey');
insert into ds_ct_namesynonyms(names) values ('Robert,Dob,Dobbin,Bob,Bobby,Bobbie,Rob,Robin,Rupert,Hob,Hobkin,Robbie,Robby');
insert into ds_ct_namesynonyms(names) values ('Rodney,Rod,Ronald');
insert into ds_ct_namesynonyms(names) values ('Raymond,Ray');
insert into ds_ct_namesynonyms(names) values ('Samuel,Sam,Sammy,Sammey,Samantha,Samson');
insert into ds_ct_namesynonyms(names) values ('Sharon,Sharyn,Sharrey,Sharrie,Sharry,Shar,Sharey,Sharie,Sheron,Sheryn,Sheryl,Cheryl');
insert into ds_ct_namesynonyms(names) values ('Shaun,Sean,Shawn,Shane,Shayne');
insert into ds_ct_namesynonyms(names) values ('Stephen,Steve,Steven');
insert into ds_ct_namesynonyms(names) values ('Stephanie,Steph,Steffi,Stephy,Steffy,Stepfanie');
insert into ds_ct_namesynonyms(names) values ('Susan,Sue,Susie,Suzy');
insert into ds_ct_namesynonyms(names) values ('Theodore,Ted,Theodrick,Theodorick,Tad,Theo,Teddy,Teddie');
insert into ds_ct_namesynonyms(names) values ('Theresa,Therese,Terry,Terrie,Tess Tessy,Tessie,Thursa,Teresa,Thirsa,Tessa');
insert into ds_ct_namesynonyms(names) values ('Thomas,Thom,Tom,Tommy,Tommie');
insert into ds_ct_namesynonyms(names) values ('Timothy,Tim,Timmy,Timmey,Timmie');
insert into ds_ct_namesynonyms(names) values ('Vanessa,,Nessa,Vanna');
insert into ds_ct_namesynonyms(names) values ('Victor,Vic.Vick');
insert into ds_ct_namesynonyms(names) values ('Victoria,Vickie,Vickey,Vicky');
insert into ds_ct_namesynonyms(names) values ('Vincent,Vin,Vince,Vinnie,Vinny');
insert into ds_ct_namesynonyms(names) values ('Virgil,Virg');
insert into ds_ct_namesynonyms(names) values ('Walter,Walt');
insert into ds_ct_namesynonyms(names) values ('Wesley,Wes');
insert into ds_ct_namesynonyms(names) values ('Wilber,Will,Wilbert');
insert into ds_ct_namesynonyms(names) values ('William,Bill,Will,Willy,Willie,Billy,Billie,Bell,Bela,Willie,Wilhelm,Willis');
insert into ds_ct_namesynonyms(names) values ('Virginia,Ginger,Ginny,Jane,Jenni,Jenny,Gina');
insert into ds_ct_namesynonyms(names) values ('Yolanda,Yolonda');
insert into ds_ct_namesynonyms(names) values ('Zachariah,Zach,Zacharias,Zachary,Zeke');
insert into ds_ct_namesynonyms(names) values ('Zebedee,Zebulon,Zeb'); 