create database TARge25

--db valimine
use master

--db kustutamine
drop database TARge25

--tabeli tegemine
create table Gender
(
Id int not null primary key,
Gender nvarchar (10) not null
)

--andmete sisestamine
insert into Gender (Id, Gender)
values (2, 'Male'),
(1, 'Female'),
(3, 'Unkown')

--taveli sisu vaatamine
select * from Gender

--tehke tabel nimega Person
--id int, not null, primary key
--Name nvarchar 30
--Email nvarchar 30
--GenderId int

create table Person
(
Id int not null primary key,
Name nvarchar (30),
Email nvarchar (30),
GenderId int
)

--andmete sisestamine
insert into Person (Id, Name, Email, GenderId)
values (1, 'Superman', 's@s.com', 2),
(2, 'Wonderwoman', 'w@w.com', 1),
(3, 'Batman', 'b@b.com', 2),
(4, 'Aquaman', 'a@a.com', 2),
(5, 'Catwoman', 'cat@cat.com', 1),
(6, 'Antman', 'ant"ant.com', 2),
(8, NULL, NULL, 2)

--soovime nähe Person tabeli sisu
select * from Person

--võõrvõtme ühenduse loomine kahe tabeli vahel
alter table Person add constraint tblPerson_GenderId_FK
foreign key (GenderId) references Gender(Id)

--kui sisestad uue rea andmeid ja ei ole sisestanud genderId alla väärtust, siis
--see automaatselt sisetab sellele reale väärtsed 3 e mis meil on unkown
alter table Person
add constraint DF_Persons_GenderId
default 3 for GenderId

insert into Person (Id, Name, Email, GenderId)
values (7, 'Flash', 'f@f.com', NULL)

insert into Person (Id, Name, Email, GenderId)
values (9, 'Black Panther', 'p@p.com', NULL)

select * from Person

--kustudada DF_Persons_GenderId piirang koodiga
alter table Person
drop constraint DF_Persons_GenderId

--lisame koodiga veeru
alter table Person
add Age nvarchar(10)

--lisame nr iirangu vanuse sisestamisel
alter table Person
add constraint CK_Person_Age check (Age > 0 and Age < 155)

--kui tead veergude järjekorda peast, siis ei pea neid sisestama
insert into Person
values (10, 'Green Arrow', 'g@g.com', 2, 154)

--constrainti kustutamine
alter table Person
drop constraint CK_Person_Age

alter table Person
add constraint CK_Person_Age check (Age > 0 and Age < 130)

--kuidas uuendada andmed koodiga
--Id 3 uus vanus on 50
update Person
set age = 50
where Id = 3

--lisame Person tabelisse veeru City ja nvarchar 50
alter table Person 
add City nvarchar(50)

--kõik, kes elavad  Gothami linnas
select * from Person where City = 'Gotham'
--kõik kes ei ela Gothamis
select * from Person where City != 'Gotham'
select * from Person where not City = 'Gotham'
select * from Person where City <> 'Gotham'

--näitab teatud vanusega inimesi
--35, 42, 23
select * from Person where Age = 35 or Age = 42 or Age = 23
select * from Person where Age in (35, 42, 23)

--näitab teatud vanusevahemikus olevaid isikuid 22 kuni 39
select * from Person where Age between 22 and 39

--wildcardi kasutamine
--näitab kõik g-tähega algavaid linnad
select * from Person where City like 'g%'

--email, kus on @ märk sees
select * from Person where Email like '%@%'

--näitab, kellel on emailis ees ja peale @-märki ainult üks täht ja omakorda .com lõppus
select * from Person where Email like '_@_.com'

--kõik, kelle on nimes esimene täht W, A, S
select * from Person where Name like 'w%' or Name like 'a%' or Name like 's%'
select * from Person where Name like '[was]%'
-- katusega välistab
select * from Person where Name like '[^was]%'
--kes elavad Gothamis või New Yorkis
select * from Person where City = 'Gotham' or City = 'New York'

--kes elavad Gothamis või New Yorkis ja on vanemad, kui 29
select * from Person where (City = 'Gotham' or City = 'New York') and Age > 29




-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------






create table Employees();
create table Departments();

alter table Departments add id int primary key;
alter table Departments add name nchar(50);
alter table Departments add location nchar(50);
alter table Departments add department_head nchar(50);

alter table Employees
    add id int,
    add name nchar(50),
    add gender nchar(30),
    add salary float,
    add department_id int;

select * from Employees;

insert into Departments
values (1, null, 'London', null),
       (2, null, 'New York', null),
       (3, null, 'Sydney', null);

insert into Departments
values (4, 'Payroll', 'Delhi', 'Christie');

update Departments set name = 'IT' where id = 1;
update Departments set name = 'HR' where id = 2;
update Departments set name = 'Other' where id = 3;

update Departments set department_head = 'Rick' where id = 1;
update Departments set department_head = 'Ron' where id = 2;
update Departments set department_head = 'Cinderella' where id = 3;

insert into Employees
values
        (1,'Tom', 'Male', 4000, 1), -- London
       (2, 'Pam', 'Female', 3000, 2), -- NY
       (3, 'John', 'Male', 3500, 1), -- London
       (4, 'Sam', 'Male', 4500, 1), -- London
       (5, 'Todd', 'Male', 2800, 3), -- Sydney
       (6, 'Ben', 'Male', 7000, 2), -- NY
       (7, 'Sara', 'Female', 4800, 3), -- Sydney
       (8, 'Valarie', 'Female', 5500, 2), -- NY
       (9, 'James', 'Male', 6500, 1),  -- London
       (10, 'Russell', 'Male', 8800, 1); -- London

select Employees.name, gender, salary, Departments.name
from Employees
    left join Departments
on Employees.department_id = Departments.id;

-- All salaries
select sum(employees.salary) as total_salaries from Employees;

-- Employee with min salary
select min(Employees.salary), Employees.name from Employees
group by Employees.name fetch first 1 row only;

-- 17.03.26

-- Left join
select Departments.location, sum(cast(Salary as int)) as TotalSalary
from Employees
left join Departments
on Employees.department_id = Departments.id
group by Departments.location;

-- Uus veerg City Employees tabelisse
alter table Employees add city nchar(30);

select * from Employees;

update Employees set city = 'New York' where id = 1;
update Employees set city = 'London' where id = 2;
update Employees set city = 'London' where id = 3;
update Employees set city = 'Boston' where id = 4;
update Employees set city = 'New York' where id = 5;
update Employees set city = 'Boston' where id = 6;
update Employees set city = 'New York' where id = 7;
update Employees set city = 'London' where id = 8;
update Employees set city = 'London' where id = 9;
update Employees set city = 'Boston' where id = 10;

select city, gender, sum(cast(employees.salary as int)) as TotalSalary
from Employees group by city, gender;

-- Sama command, aga linnad on tähestikulises järjekorras
select city, gender, sum(cast(employees.salary as int)) as TotalSalary
from Employees group by city, gender order by city;

select city,
       gender,
       sum(cast(employees.salary as int)) as TotalSalary,
       count(*) as totalEmployees
from Employees group by city, gender
order by city;

-- Ainult kõik mehed linnade kaupa
select city,
       count(*) as totalMaleEmployees,
       sum(cast(employees.salary as int)) as TotalMensSalary
from Employees where gender = 'Male'
group by city
order by city;

-- Sama asi "having" võtmesõnaga
select city,
       count(*) as totalMaleEmployees,
       sum(cast(employees.salary as int)) as TotalMensSalary
from Employees
group by city, gender
having Employees.gender = 'Male'
order by city;

--Filter by salary (>4000)
select name, salary as salaryAbove4000
from Employees where Employees.salary > 4000
group by name, Employees.salary
order by Employees.salary;

alter table Employees drop column city;

-- Inner join
-- Kuvab nimed, kellel on DepartmentId all väärtus
select e.name, gender, salary, d.name
from Employees as e
inner join Departments as d
on e.department_id = d.id;

-- Left join Employees tabel, DepartmentName kuvab ainult olemasolul
select e.name, salary, d.name from Employees as e
left join Departments as d
on e.department_id = d.id;

-- Sama, aga right join
select e.name, salary, d.name from Employees as e
right join Departments as d
on e.department_id = d.id; -- Delhi all pole töötajaid, tabelis seda kuvatakse "null" reana e tabelis

--cross join
select e.name, gender, salary, d.name
from Employees as e
cross join Departments as d;

-- inner join
select e.name, gender, salary, d.name
from Employees as e
inner join Departments as d
on d.id = e.department_id;

insert into Employees values (11, 'Ben', 'Ten', 3500, NULL);
insert into Employees values (NULL, NULL, NULL, NULL, NULL);
select * from Employees;

-- Ainult need isikud, kellel on departmentName Null
select e.name, gender, salary, d.name from Employees as e
         left join Departments as d
         on e.department_id = d.id
         where department_id IS NULL;

select e.name, salary, d.name from Employees as e
    right join Departments as d
    on e.department_id = d.id
    where e.department_id IS NULL;

-- Full join
-- Kui on vaja kuvada kõik read mõlemast tabelist, millel ei ole vastet
select e.name, salary, d.name from Employees as e
    full join Departments as d
    on e.department_id = d.id
    where e.department_id IS NULL;

-- Changing table name
-- execute sp_rename 'Employees1', 'Employees'; (MS SQL exclusive)

alter table Employees add manager_id int;

-- select e.name as Employee, m.name as Manager
--     from Employees as e
--     left join Departments d
--     on e.manager_id = ;
--
-- select e.name as Employee, m.name as Manager
--     from Employees as e
--     inner join Employees m
--     on e.manager_id = m.id;
























































































-----------------------------------------------------------------------
-----------------------------------------------------------------------


--rida 412
--asdfdafdsfdsaf
--fsdafsaddsafdaf
select isnull('Sinu Nimi', 'No Manager') as Manager

select COALESCE(null, 'No Manager') as Manager

--neil kellel ei ole ülemust, siis paneb neile No Manager teksti
select E.Name as Employee, isnull(M.Name, 'No Manager') as Manager
from Employees E
left join Employees M
on E.ManagerId = M.Id

--kui Expression on õige, siis paneb väärtuse, mida soovid või
--vastasel juhul paneb No Manager teksti
case when Expression Then '' else '' end

--teeme päringu, kus kasutame case-i
--tuleb kasutada ka left join
select E.Name as Employee, case when M.Name is null then 'No Manager'
else M.Name end as Manager
from Employees E
left join Employees M
on E.ManagerId = M.Id

--lisame tabelisse uued veerud
alter table Employees
add MiddleName nvarchar(30)
alter table Employees
add LastName nvarchar(30)

--muudame veeru nime koodiga
sp_rename 'Employees.Middlename', 'MiddleName'
Select* from Employees
