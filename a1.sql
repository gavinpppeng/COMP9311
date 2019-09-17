-- COMP9311 18s2 Assignment 1
-- Schema for the myPhotos.net photo-sharing site
--
-- Written by:
--    Name:  Wenxun Peng
--    Student ID:  z5195349
--    Date:  01/09/2018
--
-- Conventions:
-- * all entity table names are plural
-- * most entities have an artifical primary key called "id"
-- * foreign keys are named after either:
--   * the relationship they represent
--   * the table being referenced

-- Domains (you may add more)

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

create domain NameValue as varchar(50);

create domain LongNameValue as varchar(100);

create domain ShareWith as 
	varchar(20) check (value in ('private','friends','family','friends+family','public'));
	
create domain Security as
	varchar(15) check (value in ('safe','moderate','restricted'));

create domain Rating as
	integer check (value in (1, 2, 3, 4, 5));

create domain FreqValue as
	integer check (value >= 0);

-- Tables (you must add more)

create table People (
	id          serial,
	family_name NameValue,
	given_names NameValue not null,
	displayed_name LongNameValue not null,
	email_address EmailValue not null,
	primary key (id)
);

create table Users (
	password text not null,
	birthday date,
	gender GenderValue,
	website URLValue,
	date_registered date not null,
	portrait integer,
	id integer references People(id),
	primary key (id)
);

create table Groups (
	id serial,
	title text not null,
	ownedBy integer not null references Users(id),
	"mode" GroupModeValue not null,
	primary key (id)
);

create table Users_member_Groups  (
	user_id integer references Users(id),
	group_id integer references Groups(id),
	
	primary key (user_id, group_id)
);

create table Contact_lists (
	id serial,
	ownedBy integer references Users(id) not null,
	title text not null,
	"type" ContactListTypeValue default null,
	primary key (id)
);

create table People_member_Contact_Lists (
	person_id integer references People(id),
	contact_list_id integer references Contact_lists(id),
	primary key (person_id, contact_list_id)
);

create table Discussions (
	id serial,
	title NameValue,
	primary key (id)
);

create table Photos (
	id serial,
	title NameValue not null,
	description text,
	date_taken date,
	date_uploaded date not null,
	file_size integer not null check (file_size >= 0),
	visibility ShareWith not null,
	safety_level Security not null,
	technical_details text,
	discussion_id integer references Discussions (id),
	ownedBy integer references Users(id) not null,
	primary key (id)
);

alter table Users add foreign key (portrait) references Photos(id) deferrable; 

create table Tags (
	id serial,
	name NameValue not null,
	freq FreqValue not null default 0,
	primary key (id)
);

create table Users_has_Photos_has_Tags (
	photo_id integer references Photos(id),
	tag_id integer references Tags(id),
	user_id integer references Users(id),
	when_tagged timestamp not null,
	primary key (photo_id, tag_id, user_id)
);

create table Users_rates_Photos (
	user_id integer references Users(id),
	photo_id integer references Photos(id),
	rating Rating,
	when_rated timestamp not null,
	primary key (user_id, photo_id)
);

create table Collections (
	id serial,
	title NameValue not null,
	description text,
	havekey integer not null references Photos (id),
	primary key (id)
);

create table Users_Collections (
	id integer references Collections(id),
	ownedBy integer not null references Users(id),
	primary key (id)
);

create table Groups_Collections (
	id integer references Collections(id),
	ownedBy integer not null references Groups(id),
	primary key (id)
);

create table Photos_in_Collections (
	photo_id integer references Photos(id),
	collection_id integer references Collections(id),
	"order" integer not null check ("order" > 0),
	primary key (photo_id, collection_id)
);

create table Comments (
	id serial,
	content text not null,
	containedBy integer not null references Discussions (id),
	authorOf integer not null references Users (id),
	when_posted timestamp not null,
	replyTo integer references Comments(id), 
	primary key (id)
);

create table Groups_has_Discussions (
	group_id integer references Groups(id),
	discussion_id integer references Discussions (id),
	title text,
	primary key (group_id, discussion_id)
);


