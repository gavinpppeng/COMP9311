-- COMP9311 18s2 Assignment 1 Sample Solution
-- Schema for the myPhotos.net photo-sharing site
--
--
-- Conventions:
-- * all entity table names are plural
-- * most entities have an artifical primary key called "id"
-- * foreign keys are named after either:
--   * the relationship they represent
--   * the table being referenced

-- Domains

create domain URLValue as
	varchar(100) check (value like 'http://%');

create domain EmailValue as
	varchar(100) check (value like '%@%.%');

create domain GenderValue as
	varchar(6) check (value in ('male','female'));

create domain GroupModeValue as
	varchar(15) check (value in ('private','by-invitation','by-request'));

create domain ContactListTypeValue as
	varchar(10) check (value in ('friends','family'));

create domain VisibilityValue as
	varchar(20) check (value in ('private','friends','family',
	                             'friends+family', 'public'));

create domain SafetyValue as
	varchar(15) check (value in ('safe', 'moderate', 'restricted'));

create domain NameValue as varchar(50);

create domain LongNameValue as varchar(100);


-- Tables 

create table People (
	id          serial,
	family_name NameValue,
	given_name  NameValue not null,
	displayed_name LongNameValue not null unique, -- unique is optional 
	email_address  EmailValue not null,
	primary key (id)
);

create table Users (
	id          integer references People(id),
	password    text,
	website     URLvalue,
	gender      GenderValue,
	birthday    date,
	portrait    integer, -- references Photos(id) (add it later using "alter" after creating Photos table)
	date_registered date,
	primary key (id)
);

-- can't represent (Groups must have >= 1 member)
create table Groups (
	id          serial,
	title       NameValue not null,
	mode        GroupModeValue not null,
	owner       integer references Users(id),
	primary key (id)
);

create table Group_members (
	"user"      integer references Users(id),
	"group"     integer references Groups(id),
	primary key ("user","group")
);

create table Contact_lists (
	id          serial,
	title       NameValue not null,
	"type"      ContactListTypeValue,
	owner       integer references Users(id),
	primary key (id)
);

-- can't represent (Contact_list must have >= 1 member)
create table Contact_list_members (
	person      integer references People(id),
	contact_list integer references Contact_lists(id),
	primary key (person,contact_list)
);

create table Photos (
	id          serial,
	owner       integer references Users(id),
	title       NameValue not null,
	description text,
	date_taken  date,
	date_uploaded date not null,
	technical_details text,
	visibility  VisibilityValue, -- not null is optional
	safety_level SafetyValue, -- not null is optional
	file_size   integer check (file_size > 0),
	discussion  integer, -- references Discussions(id) (add it later using "alter" after creating Discussions table)
	primary key (id)
);

alter table Users add foreign key (portrait) references Photos(id);

create table Tags (
	id          serial,
	name        NameValue not null,
	freq        integer not null default 1 check (freq > 0),
	primary key (id)
);

create table Users_tag_photos (
	"user"      integer references Users(id),
	tag         integer references Tags(id),
	photo       integer references Photos(id),
	when_tagged date not null,
	primary key ("user",tag,photo)
);

create table Users_rate_photos (
	"user"      integer references Users(id),
	photo       integer references Photos(id),
	rating      integer not null
	                    check (rating between 1 and 5),
	when_rated  date not null,
	primary key ("user",photo)
);

create table Collections (
	id          serial,
	title       NameValue not null,
	description text,
	key_photo   integer not null references Photos(id),
	primary key (id)
);

create table Photos_in_collections (
	collection  integer references Collections(id),
	photo       integer references Photos(id),
	"order"     integer not null check ("order" >= 1),
	constraint UniqueOrder unique(collection,"order"),
	primary key (collection,photo)
);

create table User_collections (
	id          integer references Collections(id),
	owner       integer not null references Users(id),
	primary key (id)
);

create table Group_collections (
	id          integer references Collections(id),
	owner       integer not null references Groups(id),
	primary key (id)
);

create table Discussions (
	id          serial,
	title       NameValue, -- null is optional
	primary key (id)
);

alter table Photos add foreign key (discussion) references Discussions(id);

create table Discussions_in_groups (
	discussion  integer references Discussions(id),
	"group"     integer references Groups(id),
	primary key (discussion,"group")
);

create table Comments (
	id          serial,
	author      integer not null references Users(id),
	contained_in integer not null references Discussions(id),
	reply_to    integer references Comments(id),
	when_posted timestamp not null, -- default now() is optional
	content     text,
	primary key (id)
);

