create database TARge25

--db valimine
use master

--db kustutamine
drop database TARge25

--tabeli tegemine
create table Gender
(
Id int not null primary key,
Gender nvarchar(10) not null
)

--andmete sisestamine
insert into Gender (Id, Gender)
values (2, 'Male'),
(1, 'Female'),
(3, 'Unknown')

--tabeli sisu vaatamine
select * from Gender

--tehke tabel nimega Person
--id int, not null, primary key
--Name nvarchar 30
--Email nvarchar 30
--GenderId int

create table Person
(
Id int not null primary key,
Name nvarchar(30),
Email nvarchar(30),
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

--soovime näha Person tabeli sisu
select * from Person

--võõrvõtme ühenduse loomine kahe tabeli vahel
alter table Person add constraint tblPerson_GenderId_FK
foreign key (GenderId) references Gender(Id)

--kui sisestad uue rea andmeid aj ei ole sisestanud genderId alla väärtust, siis
--see automaatselt sisestab sellele reale väärtuse 3 e mis meil on unknown
alter table Person
add constraint DF_Persons_GenderId
default 3 for GenderId

insert into Person (Id, Name, Email, GenderId)
values (7, 'Flash', 'f@f.com', NULL)

insert into Person (Id, Name, Email)
values (9, 'Plack Panther', 'p@p.com')

select * from Person

--kustutada DF_Persons_GenderId piirang koodiga
alter table Person
drop constraint DF_Persons_GenderId

--lisamine koodiga veeru
alter table Person
add Age nvarchar(10)

--lisamine nr piirangu vanuse sisestamisel
alter table Person 
add constraint CK_Person_Age check (Age > 0 and Age < 155)

--kui sa tead veergude järjekorda peast, siis ei pea neid sisestama
insert into Person 
values (10, 'Green Arrow', 'g@g.com', 2, 154)

--constrainti kustutamine
alter table Person
drop constraint CK_Person_Age

alter table Person 
add constraint CK_Person_Age check (Age > 0 and Age < 130)

--kustutame rea
delete from Person where Id = 10

--kuidas uuendada andmeid koodiga
--Id 3 uus vanus on 50
update Person
set Age = 50 
where Id = 3

select * from Person

--lisame Person tabelisse veeru City ja nvarchar 50
alter table Person
add City nvarchar(50)

--kõik, kes elavad Gothami linnas
select * from Person where City = 'Gotham'
--kõik, kes ei ela Gothamis
select * from Person where not City = 'Gotham'
select * from Person where not City <> 'Gotham' 
select * from Person where not City != 'Gotham'

--näitab teatud vanusega inimesi
--35,42,23
select * from Person where Age in (35, 42, 23)
select * from Person where Age = 35 or Age = 42 or Age = 23

--näitab teatud vanusevahemikus olevaid isikuid 22 kuni 39
select * from Person where Age between 22 and 39
select * from Person where Age >=22 and Age <=39

--wildcardi kasutamine
--näitab kõik g-tähega algavad linnad
select * from Person where City like 'g%'
--email, kus on @ märk sees
select * from Person where Email like '%@%'

--näitab kellel on emailis ees ja peale @-märki ainult üks täht
select * from Person where Email like '_@_.com'

--kõik, kellel on nimes esimene täht W, A, S
select * from Person where Name like 'w%' or Name like 'A%' or Name like 'S%'
select * from Person where Name like '[^WAS]%'
select * from Person where Name like '[WAS]%'

--kes elavad Gothamis ja New Yorkis
select * from Person where City like 'Gotham' or City like 'New York'
select * from Person where (City = 'Gotham' or City = 'New York')

--kes elavad Gothamis ja New Yorkis ja on vanemad, kui 29
select * from Person where (City = 'Gotham' or City = 'New York')
and Age >=30

--3 tund
--10.03.26

--kuvab tähestikulises järjekorras inimesi ja võtab aluseks nime
select * from Person order by Name ASC
--kuvab vastupidises järjestuses nimed
select * from Person order by Name DESC

--võtab kolm esimest rida person tabelist
select top 3 * from Person

--kolm esimest, aga tabeli järjestus on Age ja siis Name
select top 3 Age, Name from Person order by CAST(Age as int)

--näita esimesed 50% tabelist
select top 50 PERCENT * from Person

--kõikide isikute koondvanus
select SUM(cast(Age as int)) as Koondvanus from Person

--näitab kõige nooremat isikut
select MIN(cast(Age as int)) as NoorematIsikut from Person

--näitab kõige vanem isik
select MAX(cast(Age as int)) as VanemIsik from Person

--muudame Age veeru int andmetüübiks
alter table Person alter column Age INT

--näeme konkreetsetes linnades olevate isikute koondvanust
select City, SUM(Age) as TotalAge from Person group by City
--kuvab esimeses reas välja toodud järjestuses ja kuvab Age TotalAge-ks
--järjestab City-S olevate nimede järgi ja siis GenderId järgi
select City, GenderId, SUM(Age) as TotalAge from Person
group by City, GenderId order by City

--näitab, et mitu rida on selles tabelis
select * from Person
select COUNT(Id) as ColumnCount from Person

--näitab tulemust, et mitu inimest on GenderId väärtusega 2 konkreetses linnades
--arvutab vanuse kokku konkreetses linnas
select GenderID, City, SUM(age) as 'TotalAge', COUNT(Name) as 'TotalPersons' 
from Person 
where (GenderId = 2) group by city, GenderId

--näitab ära inimeste koondvanuse, mis on üle 41 a ja
--kui palju neid igas linnas elab
--eristab soo järgi
select GenderID, City, SUM(age) as 'TotalAge', COUNT(Name) as 'TotalPersons'
from Person 
group by GenderId, City having SUM(Age) > 41

--loome tabelid Employees ja Department
create table Employees
(
Id int not null primary key,
Name nvarchar(50),
Gender nvarchar(50),
Salary nvarchar(50),
DepartmentId int,
)

create table Department
(
Id int not null primary key,
DepartmentName nvarchar(50),
Location nvarchar(50),
DepartmentHead nvarchar(50),
)

alter table Employees
add City nvarchar(50)

insert into Employees (Id, Name, Gender, Salary, DepartmentId, City)
values(1, 'Tom', 'Male', '4000', 1,  'London'),
(2, 'Pam', 'Female', '3000', 3, 'New York'),
(3, 'John', 'Male', '3500', 1, 'London'),
(4, 'Sam', 'Male', '4500', 2, 'London'),
(5, 'Todd', 'Male', '2800', 2, 'Sydney'),
(6, 'Ben', 'Male', '7000', 1, 'New York'),
(7, 'Sara', 'Female', '4800', 3, 'Sydney'),
(8, 'Valarie', 'Female', '5500', 1, 'New York'),
(9, 'James', 'Male', '6500', NULL, 'London'),
(10, 'Russell', 'Male', '8800', NULL, 'London')


select * from Employees

insert into Department (Id, DepartmentName, Location, DepartmentHead )
values(1, 'It', 'London', 'Rick'),
(2, 'Payroll', 'Delhi', 'Ron'),
(3, 'HR', 'New York', 'Christie'),
(4, 'Other Department', 'Sydney', 'Cindrella')

select * from Department

--
select Name, Gender, Salary, DepartmentName
from Employees
left join Department
on Employees.DepartmentId = Department.Id

--arvutame kõikide palgad kokku
select sum(cast(Salary as int)) as SalaryTotal from Employees
--min palga saaja
select MIN(cast(Salary as int)) as MinimalSalary from Employees

--teeme left join päringu
select Location, SUM(cast(Salary as int)) as TotalSalary
from Employees
left join Department
on Employees.DepartmentId = Department.Id
group by Location

--teeme veeru nimega City Employees tabelisse
--nvarchar 30
alter table Employees
add City nvarchar(30)

select * from Employees
--peale selecti tuleb veergude nimed
select City, Gender, SUM(cast(Salary as int)) as TotalSalary
--tabelist nimega Employees ja mis on grupitatud City ja Gender järgi
from Employees group by City, Gender
--oleks vaja, et linnad oleksid tähestikulises järjekorras
select City, Gender, SUM(cast(Salary as int)) as TotalSalary
from Employees group by City, Gender
order by City
--order by järjestab linnad tähestikuliselt, 
--aga kui nullid, ss need tulevad kõige ette

--loeb ära, mitu rida on tabelis Employees
--* asemele võib panna ka veeru nime,
--aga siis loeb ainult selle veeru väärtused, mis ei ole nullid
select COUNT(*) from Employees

--mittu töötajat on soo ja linna kaupa
select Gender, City, SUM(cast(Salary as int)) as TotalSalary, COUNT(Name) as TotalEmployees
from Employees group by City, Gender
order by city

--kuvab ainult kõik mehed linnade kaupa
select Gender, City, SUM(cast(Salary as int)) as TotalSalary, COUNT(Id) as TotalEmployees
from Employees 
where Gender = 'Male'
group by City, Gender
order by city

--sama tulemuse, aga kasutage having klauslit

select * from Employees
select Gender, City, SUM(cast(Salary as int)) as TotalSalary, COUNT(Id) as TotalEmployees
from Employees 
group by City, Gender having Gender = 'Male'
order by city

--näitab meile ainult neid töötajad, kellel on palga summa üle 4000
select City, Name, SUM(cast(Salary as int)) as TotalSalary, 
COUNT(Id) as TotalEmployees
from Employees
group by Salary, City, Name
having SUM(cast(Salary as int)) > 4000

--loome tabeli, milles hakatakse automaatselt nummerdama Id-d
create table Test1
(
Id int identity(1,1) primary key,
Value nvarchar(30)
)

insert into Test1 values('X')
select * from Test1

--kustutame veeru nimega City Employees tabelist
alter table Employees
drop column City
select * from Employees

--inner join
--kuvab neid, kellel on DepartmentName all olemas väärtus
select Name, Gender, Salary, DepartmentName
from Employees
inner join Department
on Employees.DepartmentId = Department.Id

--left join
--kuvab kõik read Employees tabelist,
--aga DepartmentName näitab ainult siis, kui on olemas
--kui DepartmentId on null, siis DepartmentName näitab nulli
select Name, Gender, Salary, DepartmentName
from Employees
left join Department
on Employees.DepartmentId = Department.Id

-- right join
--kuvab kõik Department tabelist
--aga Name näitab ainult siis, kui on olemas väärtus DepartmentId-s, mis on sama
--Department tabeli Id-ga
select Name, Gender, Salary, DepartmentName
from Employees
right join Department
on Employees.DepartmentId = Department.Id

--full outer join ja full join on sama asi
-- kuvab kõik read mõlemast tabelist,
-- aga kui ei ole vastet, siis näitab nulli
select Name, Gender, Salary, DepartmentName
from Employees
full outer join Department
on Employees.DepartmentId = Department.Id

--cross join
--kuvab kõik read mõlemast tabelist, aga ei võta aluseks mingit veergu,
--vaid lihtsalt kombineerib kõik read omavahel
--kasutatakse harva, aga kui on vaja kombineerida kõiki
--võimalikke kombinatsioone kahe tabeli vahel, siis võib kausta 
select Name, Gender, Salary, DepartmentName
from Employees
cross join Department
where Employees.DepartmentId = Department.Id

--päringu sisu 
select ColumnList
from LeftTable
joinType RightTable
on JoinCondition

select Name, Gender, Salary, DepartmentName
from Employees
inner join Department
on Department.Id = Employees.DepartmentId

--kuidas kuvada ainult need isikud, kellel on DepartmentName NULL
select Name, Gender, Salary, DepartmentName
from Employees
left join Department
on Employees.DepartmentId = Department.Id
where Employees.DepartmentId is null

--kuidas saame department tabelis oleva rea, kus on NULL
select Name, Gender, Salary, DepartmentName
from Employees
right join Department
on Employees.DepartmentId = Department.Id
where Employees.DepartmentId is null

--full join
--kus on vaja kuvada kõik read mõlemast tabelist,
--millel ei ole vastet
select Name, Gender, Salary, DepartmentName
from Employees
full join Department
on Employees.DepartmentId = Department.Id
where Employees.DepartmentId is null
or Department.Id is null

--tabeli nimetuse muutmine koodiga
sp_rename 'Employees1', 'Employees'

--kasutame Employees tabeli asemel lühendit E ja M
-- aga enne seda lisame uue veeru nimega ManagerId ja see on int
alter table Employees
add ManagerId int

--antud juhul E on Employees tabeli lühend ja M
-- on samuti Employees tabeli lühend, aga me kasutame
--seda, et näidata, et see on manageri tabel
select E.Name as Employee, M.Name as Manager
from Employees E
left join Employees M
on E.ManagerId = M.Id

--inner join ja kasutame lühendeid
select E.Name as Employee, M.Name as Manager
from Employees E
inner join Employees M
on E.ManagerId = M.Id

--cross join ja kasutame lühendeid
select E.Name as Employee, M.Name as Manager
from Employees E
cross join Employees M


select FirstName, LastName, Phone, AddressId, AddressType
from SalesLT.CustomerAddress Ca
left join SalesLT.Customer C
on SalesLT.CustomerAddress.CustomerID = SalesLT.Customer.CustomerID


--teha päring, kus kasutate ProductModelit ja Product tabelit,
--et näha, millised tooted on millise mudeliga seotud
select PM.Name as ProductModel, P.Name as Product
from SalesLT.Product P
left join SalesLT.ProductModel PM
on PM.ProductModelId = P.ProductModelId













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

update Employees
set FirstName = 'James', MiddleName = '007', LastName = 'Bond'
Where ID = 9

update Employees
set FirstName = NULL, MiddleName = NULL, LastName = 'Crowe'
Where ID = 10

--igast reast võtab esimesena mitte nulli väärtuse ja paneb Name veergu
--kasutada coalece
select Id, coalesce(FirstName, MiddleName, LastName) as Name
from Employess

create table IndianCustomers
(
Id int identity(1,1),
Name nvchar(25),
Email nvarchar(25)
)

create table UKCustomers
(
Id int identity(1,1),
Name nvchar(25),
Email nvarchar(25)
)

insert into InianCustomers (Name, Email)
values ('Raj', 'R@R.com'),
('Sam', 'S@S.com')

insert into UKCustomers (Name, Email)
values ('Ben', 'B@B.com'),
('Sam', 'S@S.com')

select * from IndianCustomers
select * from UKCustomers

--kasutate union all
--kahe tabeli andmete vaatamiseks
--näitab kõik read mõlemast tabelist
select Id, Name, Email from IndianCustomers
union all
select Id, Name, Email from UKCustomers

--kordubate väärtuste eemaldamiseks kasutame unionit
select Id, Name, Email from IndianCustomers
union
select Id, Name, Email from UKCustomers

--kuidas tulemust sorteerida nime järgi
--kasutada union all-i
select Id, Name, Email from IndianCustomers
union all
select Id, Name, Email from UKCustomers
order by Name;

--stored procedure
--salvestatud protseduurid on SQL-i koodid, mis on salvestatud
--andmebaasis ja mida saab käivitada, et teha mingi kindel töö ära
create procedure spGetEmployees
as begin
select FirstName, Gender from Employees
end

--nüüd saame kasutada spGetEmployees-i
spGetEmployees
exec spGetEmployees
execute spGetEmployees

---
create proc spGetEmployeesByGenderAndDepartment
@Gender nvarchar(10),
@DepartmentId int
as begin
	select FirstName, Gender, DepartmentId from Employees
	where Gender = @Gender and DepartmentId = @DepartmentId
end

--miks saab veateate
spGetEmployeesByGenderAndDepartment
--õige variant
spGetEmployeesByGenderAndDepartment 'male', 1
--kuidas minna sp järjekorrast mööda parameetrite sisestamisel
spGetEmployeesByGenderAndDepartment @DepartmentId = 1, @Gender = 'Male'

sp_helptext spGetEmployeesByGenderAndDepartment

--muudame sp-d ja võti peale, et keegi teine ei saaks seda muuta
alter procedure spGetEmployeesByGenderAndDepartment
@Gender nvarchar(10),
@DepartmentId int
with encryption --paneb võtme peale
as begin
	select FirstName, Gender, DepartmentId from Employees
	where Gender = @Gender and DepartmentId = @DepartmentId
end

--
create proc spGetEmployeeCountByGender
@Gender nvarchar(10)
--output parameeter, mis võimaldab meil salvestada protseduuri
--sees tehtud arvutuse tulemuse ja kasutada seda väljaspool protseduuri
@EmployeeCount int output
as begin
	select @EmployeeCount = count(Id) from Employees
	where Gender = @Gender
end

--annab tulemöuse, kus loendab ära nõuetele vastavad read
--prindib tulemuse, mis on parameetris @Employee Count
declare @TotalCount int
exec spGetEmployeeCountByGender 'Female', @TotalCount out
if(@TotalCount = 0)
	print '@TotalCount is null'
else
	print '@TotalCount is not null'
print @TotalCount

--näitab ära, et mitu ida vastab nõuetele
declare @TotalCount int
execute spGetEmployeeCountByGender
--mis on out?
--out on parameeter, mis võimaldab meil salvestada protseduuri
@EmployeeCount = @TotalCount out, @Gender = 'Male'
print @TotalCount

--sp sisu vaatamine
sp_help spGetEmployeeCountByGender
--tabeli info
sp_help Employees
--kui soovid sp teksti näha
sp_helptext spGetEmployeeCountByGender

--vaatame, millest sõltub see sp
sp_depends spGetEmployeeCountByGender
--vaatame tabelit sp_depends-ga
sp_depends Employee

---
create proc spGetNameById
@Id int
@Name nvarchar(30) output
as begin
	select @Id = Id, @Name = FirstName from Employees
end

--tahame näha kogu tabelit ridade arvu
--count kasutada
create proc spTotalCount2
@TotalCount int output
as begin
	select @TotalCount = count(Id) from Employees
end

--saame teada, et mitu rida on tabelis
declare @TotalEmployees int
execute spTotalCount2 @TotalEmployees output
select @TotalEmployees

--mis id all on keegi nime järgi
create proc spGetIdByName1
@Id int
@FirstName nvarchar(30) output
as begin
	select @Name = FirstName from Employees where @Id = Id
end

--annab tulemuse, kus on id 1 real on keegi koos nimega
declare @FirstName nvarchar(30)
execute spGetIdByName1 1, @FirstName output
print 'Name of the employee = ' + @FirstName

---
declare @FirstName nvarchar(30)
execute spGetNameById 1, @FirstName output
print 'Name of the employee = ' + @FirstName
--ei anna tulemust, sest sp-s on viga
--sp-s on viga, sest @Id on parameeter,
--mis on mõeldud selleks, et me saaksime sisestada id-d
--ja saada nime, aga sp-s on loogika viga, sest see
--üritab määrata @Id väärtuseks Id veeru väärtust, mis on vale
