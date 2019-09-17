--Q1 55
create or replace view Q1(Name) as
select Name from Person,Proceeding
where Proceeding.EditorId = Person.PersonId
group by Person.PersonId
;


--Q2 39
create or replace view Q2(Name) as
select Name from Person,Proceeding,RelationPersonInProceeding
where Proceeding.EditorId = Person.PersonId and RelationPersonInProceeding.PersonId = Proceeding.Editorid
group by Person.PersonId
;


--Q3 19
create or replace view Q3(Name) as
select Name from Person,Proceeding,InProceeding,RelationPersonInProceeding
where Proceeding.EditorId = Person.PersonId and Proceeding.Editorid = RelationPersonInProceeding.personid
and RelationPersonInProceeding.inproceedingid = inproceeding.inproceedingid and inproceeding.proceedingid = proceeding.proceedingid
group by Person.PersonId
;


--Q4 31
create or replace view Q4(Title) as
select inproceeding.title from Person,Proceeding,InProceeding,RelationPersonInProceeding
where Proceeding.EditorId = Person.PersonId and Proceeding.Editorid = RelationPersonInProceeding.personid
and RelationPersonInProceeding.inproceedingid = inproceeding.inproceedingid and inproceeding.proceedingid = proceeding.proceedingid
group by inproceeding.title
;


--Q5 2
create or replace view Q5(Title) as
select Inproceeding.title from Person,InProceeding,RelationPersonInProceeding
where RelationPersonInProceeding.PersonId = Person.PersonId and RelationPersonInProceeding.InProceedingId = InProceeding.InProceedingId
and Person.Name like '% Clark'
group by Inproceeding.title
;


--Q6 18
create or replace view Q6_initial(Year, Total) as
select Year,count(*) from Proceeding,InProceeding
where InProceeding.ProceedingId = Proceeding.ProceedingId and Proceeding.Year is not null
group by Year
;

create or replace view Q6(Year, Total) as
select Year,Total from Q6_initial
where Total != 0
order by Year asc
;


--Q7 1611 Springer
create or replace view Q7_initial(Name,Total) as
select Publisher.Name,count(*) from Publisher,Proceeding,InProceeding
where Publisher.Publisherid = Proceeding.publisherid and inproceeding.proceedingid = proceeding.proceedingid
group by Publisher.Publisherid
;

create or replace view Q7(Name) as
select Name from Q7_initial
where total = (select max(total) from Q7_initial)
;


--Q8   Eugene,Toby
create or replace view Q8_first(paper,author_num) as
select inproceeding.inproceedingid,count(*) from inproceeding,RelationPersonInProceeding
where inproceeding.inproceedingid = RelationPersonInProceeding.inproceedingid
group by inproceeding.inproceedingid
;

create or replace view Q8_sec(paper) as
select q8_first.paper from q8_first
where author_num > 1
;

create or replace view Q8_third(author) as
select person.personid from q8_sec,person,relationpersoninproceeding
where q8_sec.paper = relationpersoninproceeding.inproceedingid and relationpersoninproceeding.personid = person.personid
;

create or replace view Q8_for(author,paper_num) as
select q8_third.author,count(*) from q8_third,relationpersoninproceeding,q8_sec
where q8_third.author = relationpersoninproceeding.personid and q8_sec.paper = relationpersoninproceeding.inproceedingid 
group by q8_third.author
;

create or replace view Q8(Name) as
select person.name from person,q8_for
where q8_for.paper_num = (select max(q8_for.paper_num) from q8_for) and q8_for.author = person.personid
group by person.personid
;


--Q9 435
create or replace view Q9_first(paper,author_num) as
select inproceeding.inproceedingid,count(*) from inproceeding,RelationPersonInProceeding
where inproceeding.inproceedingid = RelationPersonInProceeding.inproceedingid
group by inproceeding.inproceedingid
;

create or replace view Q9_sec(paper) as
select q9_first.paper from q9_first
where author_num > 1
;

create or replace view Q9_third(author) as
select person.personid from q9_sec,person,relationpersoninproceeding
where q9_sec.paper = relationpersoninproceeding.inproceedingid and relationpersoninproceeding.personid = person.personid
;

create or replace view Q9(Name) as
select person.Name from person,q9_third,relationpersoninproceeding
where relationpersoninproceeding.personid = person.personid and person.personid not in (select author from q9_third)
group by person.personid
;


--Q10 3358
create or replace view Q10_first(inproceedingid,total) as
select RelationPersonInProceeding.inproceedingid,count(*)-1
from RelationPersonInProceeding
group by RelationPersonInProceeding.inproceedingid
;

create or replace view Q10_sec(personid,total) as
select RelationPersonInProceeding.personid,q10_first.total
from RelationPersonInProceeding,q10_first
where q10_first.inproceedingid = RelationPersonInProceeding.inproceedingid
group by RelationPersonInProceeding.personid,q10_first.total
order by RelationPersonInProceeding.personid
;

create or replace view Q10_third(personid,total) as
select  Q10_sec.personid,sum(Q10_sec.total)
from q10_sec
group by q10_sec.personid
;

create or replace view Q10(Name, Total) as
select name,q10_third.total
from q10_third,person
where q10_third.personid = person.personid
order by q10_third.total desc, name asc
;


--Q11 3289
create or replace view Q11_Richardid(personid,name) as
select Personid,name from Person
where person.name like 'Richard%'
;

--34
create or replace view Q11_paper(inproceedingid) as
select inproceedingid from q11_Richardid,RelationPersonInProceeding
where q11_Richardid.personid = RelationPersonInProceeding.personid
;

--54
create or replace view Q11_author(personid) as
select RelationPersonInProceeding.personid from RelationPersonInProceeding,q11_paper
where q11_paper.inproceedingid = RelationPersonInProceeding.inproceedingid
group by RelationPersonInProceeding.personid
;

--52
create or replace view Q11_allpaper(inproceedingid) as
select RelationPersonInProceeding.inproceedingid from RelationPersonInProceeding,q11_author
where q11_author.personid = RelationPersonInProceeding.personid
group by RelationPersonInProceeding.inproceedingid
;

--72
create or replace view Q11_allauthor(personid) as
select RelationPersonInProceeding.personid from RelationPersonInProceeding,q11_allpaper
where RelationPersonInProceeding.inproceedingid = q11_allpaper.inproceedingid
group by RelationPersonInProceeding.personid
;

create or replace view Q11_never(personid) as
select RelationPersonInProceeding.personid from RelationPersonInProceeding,q11_allauthor
where RelationPersonInProceeding.personid in
((select RelationPersonInProceeding.personid from RelationPersonInProceeding) EXCEPT (select q11_allauthor.personid from q11_allauthor)
)
group by RelationPersonInProceeding.personid
;

create or replace view Q11(Name) as
select name from person,q11_never
where person.personid = q11_never.personid
;


--Q12 170
create or replace view Q12_Richardid(personid,name) as
select Personid,name from Person
where person.name like 'Richard%'
;

--34
create or replace view Q12_paper(inproceedingid) as
select inproceedingid from q12_Richardid,RelationPersonInProceeding
where q12_Richardid.personid = RelationPersonInProceeding.personid
;

--54
create or replace view Q12_author(personid,inproceedingid) as
select RelationPersonInProceeding.personid,RelationPersonInProceeding.inproceedingid from RelationPersonInProceeding,q12_paper
where q12_paper.inproceedingid = RelationPersonInProceeding.inproceedingid
;

create or replace view Q12_recursive(personid,inproceedingid) as
with recursive allauthor(personid,inproceedingid) as
(
select q.personid,q.inproceedingid
from Q12_author q
union
select q2.personid,q2.inproceedingid
from RelationPersonInProceeding q2,allauthor q3
where q2.inproceedingid in (select q2.inproceedingid from RelationPersonInProceeding q2 where q3.personid = q2.personid)
)
select *
from allauthor
;

create or replace view Q12(Name) as
select name from Q12_recursive,person
where person.personid = Q12_recursive.personid
group by person.personid
;


--Q13 3358
create or replace view Q13_first(personid, Total) as   --this is all author's inproceeding num
select personid,count(*)
from RelationPersonInProceeding
group by personid
;

create or replace view Q13_sec(personid,firstyear,lastyear) as    -- this part of inproceeding is in proceeding
select RelationPersonInProceeding.personid,min(proceeding.year),max(proceeding.year)
from proceeding,RelationPersonInProceeding,inproceeding
where RelationPersonInProceeding.inproceedingid = inproceeding.inproceedingid
and inproceeding.proceedingid = proceeding.proceedingid and proceeding.year is not null
group by RelationPersonInProceeding.personid
union
select RelationPersonInProceeding.personid,text('unknow'),text('unknow')   --year is null
from proceeding,RelationPersonInProceeding,inproceeding
where RelationPersonInProceeding.inproceedingid = inproceeding.inproceedingid
and inproceeding.proceedingid = proceeding.proceedingid and proceeding.year is null
group by RelationPersonInProceeding.personid
;

create or replace view Q13_third(personid,firstyear,lastyear) as
select * from q13_sec
union
select RelationPersonInProceeding.personid,text('unknow'),text('unknow')   --this part of inproceeding is not in proceeding
from proceeding,RelationPersonInProceeding,inproceeding
where RelationPersonInProceeding.inproceedingid = inproceeding.inproceedingid
and inproceeding.proceedingid is null and RelationPersonInProceeding.personid not in (select personid from q13_sec)
group by RelationPersonInProceeding.personid
;

create or replace view Q13(Author, Total, FirstYear, LastYear) as
select person.name,total,firstyear,lastyear
from person,q13_first,q13_third
where person.personid = q13_third.personid and q13_first.personid = person.personid
order by total desc,person.name asc
;


--Q14 288
create or replace view Q14_first(inproceedingid) as
select inproceeding.inproceedingid
from inproceeding,person
where LOWER(inproceeding.title) like '%data%'
group by inproceeding.inproceedingid
;

create or replace view Q14_sec(inproceedingid) as
select inproceeding.inproceedingid
from proceeding,inproceeding
where LOWER(proceeding.title) like '%data%' and proceeding.proceedingid = inproceeding.proceedingid
group by inproceeding.inproceedingid
;

create or replace view Q14_third(personid) as
select RelationPersonInProceeding.personid
from Q14_first,Q14_sec,RelationPersonInProceeding
where RelationPersonInProceeding.inproceedingid = q14_first.inproceedingid or RelationPersonInProceeding.inproceedingid = q14_sec.inproceedingid
group by RelationPersonInProceeding.personid
;

create or replace view Q14(Total) as
select count(*)
from q14_third
;

--Q15 59
create or replace view Q15_first(proceedingid, editorid, publisherid, Title, Year, Total) as
select proceeding.proceedingid,proceeding.editorid, proceeding.publisherid,proceeding.title,year,count(*) 
from Proceeding,inproceeding
where inproceeding.proceedingid=proceeding.proceedingid
group by proceeding.proceedingid
;

create or replace view Q15(EditorName, Title, PublisherName, Year, Total) as
select Person.name, q15_first.title, publisher.name, q15_first.year, q15_first.total
from person,publisher,q15_first
where q15_first.editorid is not null and q15_first.publisherid is not null
and person.personid=q15_first.editorid and q15_first.publisherid=publisher.publisherid
order by q15_first.total desc,q15_first.year asc,q15_first.title asc
;


--Q16 427
create or replace view Q16_first(paper,author_num) as
select inproceeding.inproceedingid,count(*) from inproceeding,RelationPersonInProceeding
where inproceeding.inproceedingid = RelationPersonInProceeding.inproceedingid
group by inproceeding.inproceedingid
;

create or replace view Q16_sec(paper) as
select q16_first.paper from q16_first
where author_num > 1
;

create or replace view Q16_third(author) as
select person.personid from q16_sec,person,relationpersoninproceeding
where q16_sec.paper = relationpersoninproceeding.inproceedingid and relationpersoninproceeding.personid = person.personid
;

create or replace view Q16_for(personid) as
select person.personid from person,q16_third,relationpersoninproceeding
where relationpersoninproceeding.personid = person.personid and person.personid not in (select author from q16_third)
group by person.personid
;

create or replace view Q16(Name) as
select Person.name from Person,Q16_for,proceeding
where person.personid=q16_for.personid and person.personid not in (select editorid from proceeding,q16_for where personid = editorid)
group by person.personid
;


--Q17 2955
--select author and their paper
create or replace view Q17_first(personid, inproceedingid,proceedingid) as
select RelationPersonInProceeding.personid,RelationPersonInProceeding.inproceedingid,proceeding.proceedingid
from RelationPersonInProceeding,person,inproceeding,proceeding
where RelationPersonInProceeding.personid = person.personid and RelationPersonInProceeding.inproceedingid = inproceeding.inproceedingid
and inproceeding.proceedingid = proceeding.proceedingid
;

create or replace view Q17(Name, Total) as
select name,count(*)
from Q17_first,person
where person.personid = Q17_first.personid
group by person.personid
order by count(*) desc,name asc
;


--Q18 1 1 14
create or replace view Q18_first(inproceedingid) as
select inproceeding.inproceedingid
from inproceeding,proceeding
where inproceeding.proceedingid = proceeding.proceedingid
group by inproceeding.inproceedingid
;

create or replace view Q18_sec(personid,paper_num) as
select personid,count(*)
from q18_first,RelationPersonInProceeding
where RelationPersonInProceeding.inproceedingid = q18_first.inproceedingid
group by personid
;

create or replace view Q18(MinPub, AvgPub, MaxPub) as
select min(paper_num),round(avg(paper_num)),max(paper_num)
from q18_sec
;


--Q19 0 27 94
create or replace view Q19_first(proceedingid,publish_num) as
select proceeding.proceedingid,count(*)
from inproceeding,proceeding
where inproceeding.proceedingid = proceeding.proceedingid
group by proceeding.proceedingid
;

create or replace view Q19_sec(inproceedingid,publish_num) as
(select q19_first.proceedingid,q19_first.publish_num
from q19_first)
union
(select proceeding.proceedingid,0
from proceeding,q19_first
where proceeding.proceedingid not in (select proceedingid from q19_first)
)
;

create or replace view Q19(MinPub, AvgPub, MaxPub) as
select min(publish_num),round(avg(publish_num)),max(publish_num)
from q19_sec
;


--Q20
create or replace function q20_function() returns trigger as
$$
begin
if new.personid = 
(select proceeding.editorid from proceeding,inproceeding
where inproceeding.proceedingid = proceeding.proceedingid and new.inproceedingid = inproceeding.inproceedingid)
then return old;
end if;
return new;
end;
$$ language plpgsql;

create trigger q20_trigger
before insert or update on relationpersoninproceeding
for each row
execute procedure q20_function();


--Q21
create or replace function q21_function() returns trigger as
$$
begin
if new.editorid = (
select Relationpersoninproceeding.personid from Relationpersoninproceeding, Inproceeding
where inproceeding.inproceedingid = Relationpersoninproceeding.inproceedingid and new.proceedingid = inproceeding.proceedingid )
then return old;
end if;
return new;
end;
$$ language plpgsql;

create trigger q21_trigger
before insert or update on Proceeding
for each row
execute procedure q21_function();


--Q22
create or replace function q22_function() returns trigger as
$$
begin
if new.proceedingid = (
select proceeding.proceedingid from Proceeding, Relationpersoninproceeding
where Relationpersoninproceeding.personid = proceeding.editorid and new.inproceedingid = Relationpersoninproceeding.inproceedingid )
then return old;
end if;
return new;
end;
$$ language plpgsql;

create trigger q22_trigger
before insert or update on inproceeding
for each row
execute procedure q22_function();


