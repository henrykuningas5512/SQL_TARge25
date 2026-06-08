-- SELECT
SELECT *
FROM TARge25_Join_paringud.dbo.tblDepartment;

SELECT
Id, 
DepartmentName,
(Id + 10) * 10
FROM TARge25_Join_paringud.dbo.tblDepartment;

SELECT DISTINCT Id
FROM TARge25_Join_paringud.dbo.tblDepartment;

-- WHERE Clause

SELECT *
FROM dbo.tblEmployee
WHERE Salary >= 5000;

SELECT *
FROM dbo.tblEmployee
WHERE Gender != 'Female';

-- AND OR NOT
SELECT *
FROM dbo.tblEmployee
WHERE Salary >= 5000
OR Gender = 'Male';

-- LIKE
SELECT *
FROM dbo.tblEmployee
WHERE Name LIKE 'T%';

SELECT *
FROM dbo.tblEmployee
WHERE Name LIKE '%am%';

SELECT *
FROM dbo.tblEmployee
WHERE Name LIKE 'T__%';

-- Group By
SELECT Gender
FROM dbo.tblEmployee
GROUP BY Gender;

SELECT Gender, AVG(Salary), MAX(Salary), COUNT(Salary)
FROM dbo.tblEmployee
GROUP BY Gender;

-- ORDER BY
SELECT *
FROM dbo.tblEmployee
ORDER BY Name DESC
;

SELECT TOP 3 *
FROM dbo.tblEmployee
ORDER BY ID DESC;

-- Aliasing

SELECT Gender, AVG(Salary) AS avg_sal
FROM dbo.tblEmployee
GROUP BY Gender
;
