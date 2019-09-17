-- COMP9311 Database Systems 18s2
-- Assignment 2 - Sample Solution

-- Q1
create or replace view  Q1(Name)as
select Name from Person, Proceeding 
where Person.PersonID = Proceeding.EditorID;

-- Q2
create or replace view Q2(Name) as 
select Name from Person, Proceeding, RelationPersonInProceeding 
where Person.PersonID = Proceeding.EditorID 
and Person.PersonID = RelationPersonInProceeding.PersonID;

-- Q3
create or replace view Q3(Name) as
select Name from Person, Proceeding, InProceeding, RelationPersonInProceeding
where Person.PersonID = Proceeding.EditorID 
and Person.PersonID = RelationPersonInProceeding.PersonID 
and InProceeding.ProceedingID = Proceeding.ProceedingID 
and RelationPersonInProceeding.InProceedingID = InProceeding.InProceedingID;

-- Q4
create or replace view Q4(Title) as
select  InPd.Title from Person Pn, Proceeding Pd, InProceeding InPd, RelationPersonInProceeding PnPd
where Pn.PersonID = Pd.EditorID 
and Pn.PersonID = PnPd.PersonID and Pd.ProceedingID = InPd.ProceedingID 
and InPd.InProceedingID = PnPd.InProceedingID;

-- Q5
-- Here I use regular expression operator ~*, many students use LIKE operator 
-- which is wrong for people name (usually we compare in case insensitive manner).
-- However, you may use ILIKE in PostgreSQL instead (though not SQL standard).
--
create or replace view Q5(Title) as
select InPd.Title from Person Pn, InProceeding InPd, RelationPersonInProceeding PnPd 
where Pn.PersonID = PnPd.PersonID and InPd.InProceedingID = PnPd.InProceedingID and Pn.Name ~* ' Clark$';

-- Q6
create or replace view Q6(Year, Total) as
select Year, count(*) from Proceeding, InProceeding 
where Proceeding.ProceedingID = InProceeding.ProceedingID 
and PublisherID is not null -- do not include unknown year
group by Year 
order by Year;

-- Q7
create or replace view Q7(Name) as
with tmp as (
  select PublisherId, count(InProceedingId) as Total from Proceeding, InProceeding 
  where Proceeding.ProceedingId = InProceeding.ProceedingId group by PublisherId)
select Publisher.Name from Publisher, tmp 
where Publisher.PublisherId = tmp.PublisherId
and Total = (select max(Total) from tmp);  

-- Q8 
create or replace view Q8(Name) as
with tmpCount as (
  with tmp as (  -- all co-authored papers
    select distinct PIP1.PersonId, PIP1.InProceedingId from RelationPersonInProceeding PIP1, RelationPersonInProceeding PIP2 
    where PIP1.InProceedingId = PIP2.InProceedingId and PIP1.PersonId <> PIP2.PersonId)
  select PersonId, count(distinct InProceedingId) as Total from tmp group by PersonId)
select Name from Person, tmpCount
where Person.personId = tmpCount.PersonId
and tmpCount.Total = (select max(Total) from tmpCount);

-- Q9
create or replace view author as 
select distinct p.Name as name, p.PersonId as id 
from Person p join RelationPersonInProceeding ppr on (p.PersonId = ppr.PersonId);

create or replace view co_author as 
select distinct p.Name as co_author, p.PersonId as id 
from Person p join RelationPersonInProceeding ppr on (p.PersonId = ppr.PersonId)
              join InProceeding inpr on (ppr.InProceedingId = inpr.InProceedingId)
              join co_authored_paper cap on (cap.paper = inpr.InProceedingId)
where cap.nauthored > 1;

create or replace view Q9 as 
select a.name as name
from author a left outer join co_author on (a.id = co_author.id)
where co_author.id is null;

-- Q10
create or replace view Q10(Name, Total) as
with tmp as (  -- all co-authors
    select PIP1.PersonId, count(distinct PIP2.PersonId) as Total from RelationPersonInProceeding PIP1 left join RelationPersonInProceeding PIP2 
    on PIP1.InProceedingId = PIP2.InProceedingId and PIP1.PersonId <> PIP2.PersonId group by PIP1.PersonId)
select Name, Total from Person, tmp
where Person.PersonId = tmp.PersonId
order by Total desc, Name;

-- Q11	 
-- all Richard's coauthors
create or replace view Q11tmp(PersonId) as
select distinct PIP1.PersonId from Person P, RelationPersonInProceeding PIP1, RelationPersonInProceeding PIP2 
where PIP1.InProceedingId = PIP2.InProceedingId and PIP1.PersonId <> PIP2.PersonId and P.PersonId = PIP2.PersonId and P.Name ~* '^Richard ';

-- all Richard's coauthors' coauthors (could include Richard himself, but can be fixed easily)
create or replace view Q11tmp2(PersonId) as
select distinct PIP1.PersonId from RelationPersonInProceeding PIP1, RelationPersonInProceeding PIP2, Q11tmp
where PIP1.InProceedingId = PIP2.InProceedingId and PIP1.PersonId <> PIP2.PersonId and Q11tmp.PersonId = PIP2.PersonId;

create or replace view Q11(Name) as
with tmpPersonId as (
  (select distinct PersonId from RelationPersonInProceeding EXCEPT select * from Q11tmp) EXCEPT select * from Q11tmp2)
select Name from Person, tmpPersonId where Person.PersonId = tmpPersonId.PersonId;

-- Q12
create or replace view Q12(Name) as
-- 1. start from Richard and recursively find his indirect co-authors
-- 2. at the end, get rid of all indirect co-authors called Richard
with recursive Indirect(PersonId) as (
  select distinct PIP.PersonId from RelationPersonInProceeding PIP, Person P
  where P.PersonId = PIP.PersonId and P.Name ~* '^Richard '
  union
  select PIP1.PersonId from RelationPersonInProceeding PIP1, RelationPersonInProceeding PIP2, Indirect Co
  where Co.PersonId = PIP2.PersonId and PIP1.InProceedingId = PIP2.InProceedingId)
select distinct Name from Person
where PersonId in (
  select PersonId from Indirect
  EXCEPT
  select distinct P.PersonId from RelationPersonInProceeding PIP, Person P
  where P.PersonId = PIP.PersonId and P.Name ~* '^Richard ');

-- Q13
create or replace view Q13tmp as
with tmp as (
  select PIP.PersonId, PIP.InProceedingId, IP.ProceedingId from InProceeding IP, RelationPersonInProceeding PIP
  where IP.InProceedingId = PIP.InProceedingId)
select tmp.PersonId, tmp.InProceedingId, tmp.ProceedingId, Year from tmp left join Proceeding on tmp.ProceedingId = Proceeding.ProceedingId;

create or replace view Q13(Author, Total, FirstYear, LastYear) as
with tmp as (
  select PersonId, count(InProceedingId) as Total, coalesce(min(Year), 'unknown') as FirstYear, (coalesce(max(Year), 'unknown')) as LastYear from Q13tmp 
  group by PersonId)
select Name, Total, FirstYear, LastYear from Person, tmp where Person.PersonId = tmp.PersonId order by Total desc; 


-- Q14
create or replace view Q14(Total) as
-- So a paper either has "data" in its title or in its proceeding's title
with tmp as (
  select distinct InProceedingId, IP.Title from Proceeding Pd, InProceeding IP 
  where Pd.ProceedingId = IP.ProceedingId 
  and (IP.Title ~* 'data' or Pd.Title ~* 'data'))
select count(distinct PIP.PersonId) from RelationPersonInProceeding PIP, tmp
where PIP.InProceedingId = tmp.InProceedingId;

-- Q15
create or replace view Q15(EditorName, Title, PublisherName, Year, Total) as
with tmp as (
  select ProceedingId, count(InProceedingId) as Total from InProceeding group by ProceedingId)
select P.Name, Pd.Title, Pb.Name, Pd.Year, Total from Person P, Publisher Pb, Proceeding Pd, tmp
where P.PersonId = Pd.EditorId and Pb.PublisherId= Pd.PublisherId and Pd.ProceedingId = tmp.ProceedingId
order by Total desc, year, title; 

-- Q16
create or replace view Q16(Name) as
-- tmp are those co-authors and editors
with tmp as (
  select distinct PIP1.PersonId from RelationPersonInProceeding PIP1, RelationPersonInProceeding PIP2 
  where PIP1.InProceedingId = PIP2.InProceedingId and PIP1.PersonId <> PIP2.PersonId
  union  
  select EditorId from Proceeding where EditorId is not null)
-- find those not in tmp
select distinct P.Name from person P, RelationPersonInProceeding PIP 
where P.PersonId = PIP.PersonId 
and PIP.PersonId not in (select PersonId from tmp);

-- Q17
create or replace view Q17 (Name, Total) as
with tmp as (
  select PIP.PersonId, count(distinct IP.ProceedingId) as Total from RelationPersonInProceeding PIP left join InProceeding IP
  on PIP.InProceedingId=IP.InProceedingId
  group by PIP.PersonId)
select Name, Total from Person, tmp
where Person.PersonId=tmp.PersonId and Total > 0
order by Total desc, Name;

-- Q18
create or replace view Q18(MinPub, AvgPub, MaxPub) as
with tmpCount as (
  select PersonId, count(InProceedingId) as Total from RelationPersonInProceeding 
  group by PersonId)
select min(Total), avg(Total), max(Total) from tmpCount;

create or replace view Q18_2(MinPub, AvgPub, MaxPub) as
with tmpCount as (
  select PersonId, count(PIP.InProceedingId) as Total from RelationPersonInProceeding PIP join InProceeding IP on PIP.InProceedingId = IP.InProceedingId
  join Proceeding P on P.ProceedingId = IP.ProceedingId
  group by PersonId)
select min(Total), avg(Total), max(Total) from tmpCount;

-- Q19
create or replace view Q19(MinPub, AvgPub, MaxPub) as
with tmpCount as (
  select Proceeding.ProceedingId, count(InProceedingId) as Total from Proceeding left join InProceeding
  on Proceeding.ProceedingId=InProceeding.ProceedingId
  group by Proceeding.ProceedingId)
select min(Total), avg(Total), max(Total) from tmpCount;

-- Q20
-- I use PERFORM here but you can use SELECT INTO to hold the results.
--
create or replace function CheckRelationPersonInProceeding() returns trigger as $$
begin
  perform * from Proceeding, InProceeding
  where new.PersonId = EditorId and new.InProceedingId = InProceeding.InProceedingId
  and Proceeding.ProceedingId = InProceeding.ProceedingId;
  -- below it's the standard checking
  if (found) then
    raise exception 'Q20: insert or update failed';
  end if;
  return new;
end;	 
$$ language plpgsql;
create trigger CheckRelationPersonInProceeding before insert or update
on RelationPersonInProceeding for each row execute procedure CheckRelationPersonInProceeding();

-- Q21
create or replace function CheckProceeding() returns trigger as $$
begin
  perform * from InProceeding, RelationPersonInProceeding 
  where new.EditorId = RelationPersonInProceeding.PersonId and 
  InProceeding.InProceedingId = RelationPersonInProceeding.InProceedingId 
  and new.ProceedingId = InProceeding.ProceedingId;
  -- below it's the standard checking
  if (found) then
    raise exception 'Q21: insert or update failed';
  end if;
  return new;
end;
$$ language plpgsql;
create trigger CheckProceeding before insert or update 
on Proceeding for each row execute procedure CheckProceeding();

-- Q22
create or replace function CheckInProceeding() returns trigger as $$
begin
  perform * from Proceeding
  where exists (
    select * from RelationPersonInProceeding 
    where Proceeding.EditorId = RelationPersonInProceeding.PersonId 
    and new.ProceedingId = Proceeding.ProceedingId
    and new.InProceedingId = RelationPersonInProceeding.InProceedingId
    );
  if (found) then
    raise exception 'Q22: insert or update failed';
  end if;
  return new;
end;
$$ language plpgsql;
create trigger CheckInProceeding before insert or update 
on InProceeding for each row execute procedure CheckInProceeding();
