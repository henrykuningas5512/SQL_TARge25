```sql
/* ============================================================
   ANDMEBAASIDE LÕPUTÖÖ KONSPEKT
   Teemad:
   - ERD tegemine
   - Andmebaasi loomine
   - Tabelite loomine
   - Primary Key ja Foreign Key
   - Migratsioon
   - SQL päringud
   - JOIN, GROUP BY, HAVING
   ============================================================ */


-- ============================================================
-- 1. ANDMEBAASI LOOMINE
-- ============================================================

-- Loob uue andmebaasi
CREATE DATABASE LoppTooDB;
GO

-- Valib kasutamiseks loodud andmebaasi
USE LoppTooDB;
GO


-- ============================================================
-- 2. ERD LOOGIKA
-- ============================================================

/*
ERD tähendab Entity Relationship Diagram ehk andmebaasi seoste diagramm.

ERD-s peavad olema:
- tabelid
- veerud
- Primary Key ehk primaarvõti
- Foreign Key ehk võõrvõti
- tabelite vahelised seosed

Näide:
Ühes osakonnas võib olla mitu töötajat.

Department 1 --- mitu Employee

See tähendab:
- Department tabelis on Id
- Employee tabelis on DepartmentId
- Employee.DepartmentId viitab Department.Id peale
*/


-- ============================================================
-- 3. PRIMARY KEY JA FOREIGN KEY
-- ============================================================

/*
PRIMARY KEY:
- unikaalne väärtus
- ei tohi olla NULL
- iga rea peamine identifikaator

FOREIGN KEY:
- ühendab kaks tabelit
- viitab teise tabeli Primary Key peale
*/


-- ============================================================
-- 4. TABELITE LOOMINE ÕIGES JÄRJEKORRAS
-- ============================================================

/*
Kui üks tabel viitab teisele, siis tuleb kõigepealt luua see tabel,
millele viidatakse.

Õige järjekord:
1. Department
2. Employee

Sest Employee.DepartmentId viitab Department.Id peale.
*/


-- Parent table ehk põhitabel
CREATE TABLE Department
(
    Id INT PRIMARY KEY,
    DepartmentName NVARCHAR(50) NOT NULL,
    Location NVARCHAR(50),
    DepartmentHead NVARCHAR(50)
);
GO


-- Child table ehk tabel, mis viitab teisele tabelile
CREATE TABLE Employee
(
    Id INT PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    Gender NVARCHAR(10),
    Salary INT,
    DepartmentId INT
);
GO


-- ============================================================
-- 5. FOREIGN KEY LISAMINE ALTER TABLE ABIL
-- ============================================================

ALTER TABLE Employee
ADD CONSTRAINT FK_Employee_Department
FOREIGN KEY (DepartmentId) REFERENCES Department(Id);
GO


-- ============================================================
-- 6. ANDMETE SISESTAMINE
-- ============================================================

INSERT INTO Department (Id, DepartmentName, Location, DepartmentHead)
VALUES
(1, 'IT', 'London', 'Rick'),
(2, 'Payroll', 'Delhi', 'Ron'),
(3, 'HR', 'New York', 'Christie'),
(4, 'Other Department', 'Sydney', 'Cindrella');
GO


INSERT INTO Employee (Id, Name, Gender, Salary, DepartmentId)
VALUES
(1, 'Tom', 'Male', 4000, 1),
(2, 'Pam', 'Female', 3000, 3),
(3, 'John', 'Male', 3500, 1),
(4, 'Sam', 'Male', 4500, 2),
(5, 'Todd', 'Male', 2800, 2),
(6, 'Ben', 'Male', 7000, 1),
(7, 'Sara', 'Female', 4800, 3),
(8, 'Valarie', 'Female', 5500, 1),
(9, 'James', 'Male', 6500, NULL),
(10, 'Russell', 'Male', 8800, NULL);
GO


-- ============================================================
-- 7. TABELI SISU VAATAMINE
-- ============================================================

SELECT *
FROM Department;

SELECT *
FROM Employee;


-- ============================================================
-- 8. WHERE TINGIMUSED
-- ============================================================

-- Töötajad, kelle palk on suurem kui 4000
SELECT *
FROM Employee
WHERE Salary > 4000;


-- Ainult mehed
SELECT *
FROM Employee
WHERE Gender = 'Male';


-- Palk vahemikus 3000 kuni 6000
SELECT *
FROM Employee
WHERE Salary BETWEEN 3000 AND 6000;


-- Töötajad, kelle nimi algab S-tähega
SELECT *
FROM Employee
WHERE Name LIKE 'S%';


-- Töötajad, kellel ei ole osakonda
SELECT *
FROM Employee
WHERE DepartmentId IS NULL;


-- ============================================================
-- 9. ORDER BY JA TOP
-- ============================================================

-- Töötajad palga järgi kasvavalt
SELECT *
FROM Employee
ORDER BY Salary ASC;


-- Töötajad palga järgi kahanevalt
SELECT *
FROM Employee
ORDER BY Salary DESC;


-- 3 kõige suurema palgaga töötajat
SELECT TOP 3 *
FROM Employee
ORDER BY Salary DESC;


/*
NB!
SQL Serveris kasutatakse TOP, mitte LIMIT.

Vale:
SELECT * FROM Employee LIMIT 3;

Õige:
SELECT TOP 3 * FROM Employee;
*/


-- ============================================================
-- 10. UPDATE EHK ANDMETE MUUTMINE
-- ============================================================

-- Muudab töötaja palka, kelle Id on 1
UPDATE Employee
SET Salary = 4500
WHERE Id = 1;


/*
NB!
UPDATE käsul peab tavaliselt olema WHERE.

Ilma WHERE-ita muudetakse kõik read.

Ohtlik näide:
UPDATE Employee
SET Salary = 4500;
*/


-- ============================================================
-- 11. DELETE EHK ANDMETE KUSTUTAMINE
-- ============================================================

-- Kustutab töötaja, kelle Id on 10
DELETE FROM Employee
WHERE Id = 10;


/*
NB!
DELETE käsul peab tavaliselt olema WHERE.

Ohtlik näide:
DELETE FROM Employee;

See kustutab kõik read tabelist.
*/


-- ============================================================
-- 12. ALTER TABLE EHK TABELI MUUTMINE
-- ============================================================

-- Lisab uue veeru
ALTER TABLE Employee
ADD Email NVARCHAR(100);


-- Muudab olemasoleva veeru andmetüüpi
ALTER TABLE Employee
ALTER COLUMN Email NVARCHAR(150);


-- Kustutab veeru
ALTER TABLE Employee
DROP COLUMN Email;


-- ============================================================
-- 13. DEFAULT CONSTRAINT
-- ============================================================

/*
DEFAULT annab automaatse väärtuse, kui väärtust ise ei sisestata.
Näiteks kui DepartmentId puudub, pannakse vaikimisi 4.
*/

ALTER TABLE Employee
ADD CONSTRAINT DF_Employee_DepartmentId
DEFAULT 4 FOR DepartmentId;


-- Default constrainti kustutamine
ALTER TABLE Employee
DROP CONSTRAINT DF_Employee_DepartmentId;


-- ============================================================
-- 14. CHECK CONSTRAINT
-- ============================================================

/*
CHECK kontrollib, et väärtus vastaks tingimusele.
Näiteks palk peab olema suurem kui 0.
*/

ALTER TABLE Employee
ADD CONSTRAINT CK_Employee_Salary
CHECK (Salary > 0);


-- Check constrainti kustutamine
ALTER TABLE Employee
DROP CONSTRAINT CK_Employee_Salary;


-- ============================================================
-- 15. INNER JOIN
-- ============================================================

/*
INNER JOIN näitab ainult need read, kus mõlemas tabelis on vaste olemas.
Kui töötajal DepartmentId puudub, siis teda ei näidata.
*/

SELECT 
    E.Name,
    E.Gender,
    E.Salary,
    D.DepartmentName
FROM Employee E
INNER JOIN Department D
    ON E.DepartmentId = D.Id;


-- ============================================================
-- 16. LEFT JOIN
-- ============================================================

/*
LEFT JOIN näitab kõik read vasakust tabelist.
Kui paremas tabelis vastet pole, siis näitab NULL.
*/

SELECT 
    E.Name,
    E.Gender,
    E.Salary,
    D.DepartmentName
FROM Employee E
LEFT JOIN Department D
    ON E.DepartmentId = D.Id;


-- ============================================================
-- 17. RIGHT JOIN
-- ============================================================

/*
RIGHT JOIN näitab kõik read paremast tabelist.
Näiteks saab näha ka osakondi, kus töötajaid pole.
*/

SELECT 
    E.Name,
    E.Gender,
    E.Salary,
    D.DepartmentName
FROM Employee E
RIGHT JOIN Department D
    ON E.DepartmentId = D.Id;


-- ============================================================
-- 18. FULL JOIN
-- ============================================================

/*
FULL JOIN näitab kõik read mõlemast tabelist.
Kui vastet pole, siis näitab NULL.
*/

SELECT 
    E.Name,
    E.Gender,
    E.Salary,
    D.DepartmentName
FROM Employee E
FULL JOIN Department D
    ON E.DepartmentId = D.Id;


-- ============================================================
-- 19. CROSS JOIN
-- ============================================================

/*
CROSS JOIN kombineerib kõik read omavahel.
Kui ühes tabelis on 10 rida ja teises 4 rida,
siis tulemuseks tuleb 40 rida.
*/

SELECT 
    E.Name,
    D.DepartmentName
FROM Employee E
CROSS JOIN Department D;


-- ============================================================
-- 20. NULL VÄÄRTUSTE OTSIMINE
-- ============================================================

-- Töötajad, kellel pole osakonda
SELECT 
    E.Name,
    E.Gender,
    E.Salary,
    D.DepartmentName
FROM Employee E
LEFT JOIN Department D
    ON E.DepartmentId = D.Id
WHERE E.DepartmentId IS NULL;


-- Osakonnad, kus pole töötajaid
SELECT 
    E.Name,
    D.DepartmentName
FROM Employee E
RIGHT JOIN Department D
    ON E.DepartmentId = D.Id
WHERE E.DepartmentId IS NULL;


-- Kõik read mõlemast tabelist, millel pole vastet
SELECT 
    E.Name,
    D.DepartmentName
FROM Employee E
FULL JOIN Department D
    ON E.DepartmentId = D.Id
WHERE E.DepartmentId IS NULL
   OR D.Id IS NULL;


-- ============================================================
-- 21. GROUP BY
-- ============================================================

/*
GROUP BY grupeerib andmed.
Kui SELECT-is on tavaline veerg ja agregaatfunktsioon,
siis tavaline veerg peab olema GROUP BY sees.
*/


-- Töötajate arv soo järgi
SELECT 
    Gender,
    COUNT(*) AS TotalEmployees
FROM Employee
GROUP BY Gender;


-- Palgasumma osakonna järgi
SELECT 
    D.DepartmentName,
    SUM(E.Salary) AS TotalSalary
FROM Employee E
LEFT JOIN Department D
    ON E.DepartmentId = D.Id
GROUP BY D.DepartmentName;


-- Keskmine palk soo järgi
SELECT 
    Gender,
    AVG(Salary) AS AverageSalary
FROM Employee
GROUP BY Gender;


-- ============================================================
-- 22. HAVING
-- ============================================================

/*
WHERE filtreerib ridu enne GROUP BY-d.
HAVING filtreerib gruppe pärast GROUP BY-d.
*/


-- Näitab ainult need sood, kelle keskmine palk on üle 4000
SELECT 
    Gender,
    AVG(Salary) AS AverageSalary
FROM Employee
GROUP BY Gender
HAVING AVG(Salary) > 4000;


-- Näitab osakonnad, mille palgasumma on üle 10000
SELECT 
    D.DepartmentName,
    SUM(E.Salary) AS TotalSalary
FROM Employee E
LEFT JOIN Department D
    ON E.DepartmentId = D.Id
GROUP BY D.DepartmentName
HAVING SUM(E.Salary) > 10000;


/*
NB!
SQL Serveris ei saa HAVING sees kasutada aliast.

Vale:
HAVING AverageSalary > 4000

Õige:
HAVING AVG(Salary) > 4000
*/


-- ============================================================
-- 23. AGREGAATFUNKTSIOONID
-- ============================================================

-- Ridade arv
SELECT COUNT(*) AS TotalRows
FROM Employee;


-- Kõikide palkade summa
SELECT SUM(Salary) AS TotalSalary
FROM Employee;


-- Väikseim palk
SELECT MIN(Salary) AS MinSalary
FROM Employee;


-- Suurim palk
SELECT MAX(Salary) AS MaxSalary
FROM Employee;


-- Keskmine palk
SELECT AVG(Salary) AS AverageSalary
FROM Employee;


-- ============================================================
-- 24. ISNULL, COALESCE JA CASE
-- ============================================================

-- ISNULL asendab NULL väärtuse teise väärtusega
SELECT 
    Name,
    ISNULL(CAST(DepartmentId AS NVARCHAR(10)), 'No Department') AS DepartmentInfo
FROM Employee;


-- COALESCE võtab esimese väärtuse, mis ei ole NULL
SELECT 
    Name,
    COALESCE(CAST(DepartmentId AS NVARCHAR(10)), 'No Department') AS DepartmentInfo
FROM Employee;


-- CASE teeb tingimusliku tulemuse
SELECT 
    Name,
    Salary,
    CASE
        WHEN Salary >= 6000 THEN 'High salary'
        WHEN Salary >= 4000 THEN 'Medium salary'
        ELSE 'Low salary'
    END AS SalaryLevel
FROM Employee;


-- ============================================================
-- 25. MIGRATSIOONI NÄIDE
-- ============================================================

/*
Migratsioon tähendab andmebaasi loomist või muutmist SQL koodiga.

Lõputöö mõttes võib migratsioon sisaldada:
- andmebaasi loomist
- tabelite loomist
- veergude lisamist
- võtmete lisamist
- constraintide lisamist
- andmete sisestamist
- andmete muutmist
*/


CREATE DATABASE SchoolDB;
GO

USE SchoolDB;
GO


CREATE TABLE Class
(
    Id INT PRIMARY KEY,
    ClassName NVARCHAR(50) NOT NULL
);
GO


CREATE TABLE Student
(
    Id INT PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    Email NVARCHAR(50),
    ClassId INT
);
GO


ALTER TABLE Student
ADD CONSTRAINT FK_Student_Class
FOREIGN KEY (ClassId) REFERENCES Class(Id);
GO


INSERT INTO Class (Id, ClassName)
VALUES
(1, 'TARge25'),
(2, 'TARge24');
GO


INSERT INTO Student (Id, Name, Email, ClassId)
VALUES
(1, 'Mari', 'mari@test.com', 1),
(2, 'Juhan', 'juhan@test.com', 1),
(3, 'Kati', 'kati@test.com', 2);
GO


SELECT 
    S.Name,
    S.Email,
    C.ClassName
FROM Student S
LEFT JOIN Class C
    ON S.ClassId = C.Id;


-- ============================================================
-- 26. KIIRE SPIKKER
-- ============================================================

/*
CREATE DATABASE DB;
GO

USE DB;
GO

CREATE TABLE ParentTable
(
    Id INT PRIMARY KEY,
    Name NVARCHAR(50)
);

CREATE TABLE ChildTable
(
    Id INT PRIMARY KEY,
    Name NVARCHAR(50),
    ParentId INT
);

ALTER TABLE ChildTable
ADD CONSTRAINT FK_Child_Parent
FOREIGN KEY (ParentId) REFERENCES ParentTable(Id);

INSERT INTO ParentTable (Id, Name)
VALUES (1, 'Example');

INSERT INTO ChildTable (Id, Name, ParentId)
VALUES (1, 'Child example', 1);

SELECT *
FROM ChildTable;

SELECT 
    C.Name,
    P.Name
FROM ChildTable C
LEFT JOIN ParentTable P
    ON C.ParentId = P.Id;

SELECT 
    ParentId,
    COUNT(*) AS Total
FROM ChildTable
GROUP BY ParentId;

SELECT 
    ParentId,
    COUNT(*) AS Total
FROM ChildTable
GROUP BY ParentId
HAVING COUNT(*) > 1;
*/


-- ============================================================
-- 27. KÕIGE TÄHTSAMAD MEELDETULETUSED
-- ============================================================

/*
1. Kõigepealt tee ERD.
2. Leia tabelid.
3. Pane igale tabelile Id.
4. Primary Key on tabeli peamine võti.
5. Foreign Key läheb tavaliselt "mitu" poole tabelisse.
6. Tabel, millele viidatakse, tuleb enne luua.
7. SQL Serveris kasuta TOP, mitte LIMIT.
8. UPDATE ja DELETE käsul kasuta WHERE tingimust.
9. NULL-i kontrollimiseks kasuta IS NULL.
10. GROUP BY puhul peavad tavalised veerud olema GROUP BY sees.
11. WHERE käib enne grupeerimist.
12. HAVING käib pärast grupeerimist.
13. JOIN ühendab tabelid.
14. LEFT JOIN näitab kõik read vasakust tabelist.
15. INNER JOIN näitab ainult sobivad read.
*/

