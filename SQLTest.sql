create database TARge25_Join_paringud1

--db valimine
use TARge25_Join_paringud1


---12. Join

CREATE TABLE tblDepartment
(
	Id int primary key,
	DepartmentName nvarchar(50), Location nvarchar(50),
	DepartmentHead nvarchar(50)
)
Go
Insert into tblDepartment values (1, 'IT', 'London', 'Rick')

Insert into tblDepartment values (2, 'Payroll', 'Delhi', 'Ron')
Insert into tblDepartment values (3, 'HR', 'New York', 'Christie')
Insert into tblDepartment values (4, 'Other Department', 'Sydney', 'Cindrella') 
Go

CREATE TABLE tblEmployee
(
	ID int primary key,
	Name nvarchar(50),
	Gender nvarchar(50),
	Salary int,
	DepartmentId int foreign key references tblDepartment (Id)
)
Go

Insert into tblEmployee values (1, 'Tom', 'Male', 4000, 1)
Insert into tblEmployee values (2, 'Pam', 'Female', 3000, 3)
Insert into tblEmployee values (3, 'John', 'Male', 3500, 1)
Insert into tblEmployee values (4, 'Sam', 'Male', 4500, 2)
Insert into tblEmployee values (5, 'Todd', 'Male', 2800, 2)
Insert into tblEmployee values (6, 'Ben', 'Male', 7000, 1)
Insert into tblEmployee values (7, 'Sara', 'Female', 4800, 3)
Insert into tblEmployee values (8, 'Valarie', 'Female', 5500, 1)
Insert into tblEmployee values (9, 'James', 'Male', 6500, NULL)
Insert into tblEmployee values (10, 'Russell', 'Male', 8800, NULL)


---Üldine koodinäide JOIN-i jaoks:
---SELECT ColumnList
---FROM LeftTableName
---JOIN_TYPE RightTableName
---ON JoinCondition


SELECT Name, Gender, Salary, DepartmentName
FROM tblEmployee
INNER JOIN tblDepartment
ON tblEmployee.DepartmentId = tblDepartment.Id

SELECT Name, Gender, Salary, DepartmentName
FROM tblEmployee
JOIN tblDepartment
ON tblEmployee.DepartmentId = tblDepartment.Id

﻿
SELECT Name, Gender, Salary, DepartmentName
FROM tblEmployee
LEFT OUTER JOIN tblDepartment
ON tblEmployee. DepartmentId = tblDepartment.Id


SELECT Name, Gender, Salary, DepartmentName
FROM tblEmployee
RIGHT OUTER JOIN tblDepartment
ON tblEmployee.DepartmentId = tblDepartment.Id

SELECT Name, Gender, Salary, DepartmentName
FROM tblEmployee
FULL OUTER JOIN tblDepartment
ON tblEmployee.DepartmentId = tblDepartment.Id


---13. Keerulisemad JOIN-d

SELECT Name, Gender, Salary, DepartmentName

FROM tblEmployee E
LEFT JOIN tblDepartment D
ON E.DepartmentId = D.Id
WHERE D.Id IS NULL

--

SELECT Name, Gender, Salary, DepartmentName

FROM tblEmployee E
RIGHT JOIN tblDepartment D
ON E.DepartmentId = D.Id
WHERE E.DepartmentId IS NULL

--

SELECT Name, Gender, Salary, DepartmentName

FROM tblEmployee E
FULL JOIN tblDepartment D
ON E.DepartmentId = D.Id
WHERE E.DepartmentId IS NULL
OR D.Id IS NULL



---14. Self join

ALTER TABLE tblEmployee
ADD ManagerId int NULL;

UPDATE tblEmployee SET ManagerId = NULL WHERE ID = 1;
UPDATE tblEmployee SET ManagerId = 1 WHERE ID = 2;
UPDATE tblEmployee SET ManagerId = 1 WHERE ID = 3;
UPDATE tblEmployee SET ManagerId = 1 WHERE ID = 4;
UPDATE tblEmployee SET ManagerId = 4 WHERE ID = 5;
UPDATE tblEmployee SET ManagerId = 1 WHERE ID = 6;
UPDATE tblEmployee SET ManagerId = 2 WHERE ID = 7;
UPDATE tblEmployee SET ManagerId = 1 WHERE ID = 8;
UPDATE tblEmployee SET ManagerId = 6 WHERE ID = 9;
UPDATE tblEmployee SET ManagerId = 6 WHERE ID = 10;

SELECT * FROM tblEmployee;

SELECT 
    E.Name AS Employee,
    M.Name AS Manager
FROM tblEmployee E
LEFT JOIN tblEmployee M
ON E.ManagerId = M.ID;

SELECT 
    E.Name AS Employee,
    M.Name AS Manager
FROM tblEmployee E
INNER JOIN tblEmployee M
ON E.ManagerId = M.ID;

SELECT 
    E.Name AS Employee,
    M.Name AS Manager
FROM tblEmployee E
CROSS JOIN tblEmployee M;