CREATE TABLE Person (
  PersonId integer primary key,
  Name text not null,
  Email text default null,
  Url text default null
);

CREATE TABLE Publisher (
  PublisherId integer primary key,
  Name text not null,
  Address text default null
);

CREATE TABLE Series (
  SeriesId integer primary key,
  Title text not null, 
  Url text default null
);

CREATE TABLE Proceeding (
  ProceedingId integer primary key,
  Title text not null,
  EditorId integer references Person(PersonId),
  PublisherId integer references Publisher(PublisherId),
  SeriesId integer references Series(SeriesId),
  Year char(4) default null check (Year ~ '[1-2][0-9]{3}'),
  ISBN text default null,
  Url text default null
);

-- InProceeding contains the research paper title, and the proceeding (if known) 
-- in which the paper appears.
--
CREATE TABLE InProceeding (
  InProceedingId integer primary key,
  Title text default null,
  Pages text default null,
  Url text default null,
  ProceedingId integer references Proceeding(ProceedingId)
);

CREATE TABLE RelationPersonInProceeding (
  PersonId integer references Person(PersonId),
  InProceedingId integer references InProceeding(InProceedingId),
  primary key (PersonId,InProceedingId)
);
