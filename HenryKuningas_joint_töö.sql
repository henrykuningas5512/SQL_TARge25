USE AdventureWorksDW2019;
GO

--left Join näitab kõiki vasaku tabeli ridu, parema tabeli sobivaid andmeid, vaste puudumisel kuvatakse parema tabeli veergudes NULL.
--Siin tabelis tahame teada saada, kus kliendid elavad.
SELECT
    C.FirstName,
    C.MiddleName,
    C.LastName,
    G.City,
    G.EnglishCountryRegionName AS Country
FROM DimCustomer AS C
LEFT JOIN DimGeography AS G
    ON C.GeographyKey = G.GeographyKey;
GO

--right Join näitab kõiki parema tabeli ridu, vasaku tabeli sobivaid andmeid, vaste puudumisel kuvatakse vasaku tabeli veergudes NULL.
--Siin tabelist näeme kust kohast kõige rohkem ostetakse asju.
SELECT
    S.SalesTerritoryGroup,
    COUNT(G.City) AS CityCount
FROM DimGeography AS G
RIGHT JOIN DimSalesTerritory AS S
    ON G.SalesTerritoryKey = S.SalesTerritoryKey
GROUP BY S.SalesTerritoryGroup;
GO

--inner Joini omapära on see et see näitab ainult ridasid mis mõlemal tabelil on.
--Siin tabelist tahame teada saada töötajate andmed, et saaks lihtsasti kontakti nendega võtta.
SELECT
    E.FirstName,
    E.LastName,
    E.EmailAddress,
    E.Phone,
    G.PostalCode
FROM DimEmployee AS E
INNER JOIN DimGeography AS G
    ON E.SalesTerritoryKey = G.SalesTerritoryKey;
GO


SELECT *
FROM DimEmployee
SELECT *
FROM DimGeography
--full outer Join mõlema tabeli ridasid näidatakse ja kui vaste puudub siis teistes tabeli veergudes on NULL.
--Siin saab vaadata mis organisatsioon kasutab mis rahaühikut.
SELECT
    C.CurrencyName,
    O.OrganizationName,
    C.CurrencyAlternateKey
FROM DimOrganization AS O
FULL OUTER JOIN DimCurrency AS C
    ON O.CurrencyKey = C.CurrencyKey;
GO

--cross Join ühendab esimese tabeli iga rea teise tabeli iga reaga, mis teeb read pikkemaks ja cross join ei vaja ON tingimust.
--Siin näeb müügi asjade alamkatekooriaid.
SELECT
    S.EnglishProductSubcategoryName AS ProductSubcategoryName,
    P.EnglishProductCategoryName AS ProductCategoryName
FROM DimProductSubcategory AS S
CROSS JOIN DimProductCategory AS P;
GO

--lisa table 10rida ja 6muutujat
CREATE TABLE tblEmployee
(
	ID int primary key,
	FirstName nvarchar(50),
    LastName nvarchar(50),
	Gender nvarchar(50),
	Salary int,
    EmailAddress nvarchar(50)
	
)
Go

Insert into tblEmployee values (1, 'Aadu', 'Aavik', 'Mees', 1200, 'Aadu@aavik.com')
Insert into tblEmployee values (2, 'Kristjan', 'Saar', 'Mees', 2800, 'Kristjan@saar.com')
Insert into tblEmployee values (3, 'Tõnis', 'Tuut', 'Mees', 870, 'Tõnis@tuut.com')
Insert into tblEmployee values (4, 'Stiina', 'Saar', 'Naine', 2300, 'Stiina@saar.com')
Insert into tblEmployee values (5, 'Jaan', 'Jaaniuss', 'Mees', 1600, 'Jaan@jaaniuss.com')
Insert into tblEmployee values (6, 'Heidi', 'Kristi', 'Naine', 3000, 'Heidi@kristi.com')
Insert into tblEmployee values (7, 'Laura', 'Lagrits', 'Naine', 1300, 'Laura@lagrits.com')
Insert into tblEmployee values (8, 'Sigrid', 'Ottens', 'Mees', 6000, 'Sigrid@ottens.com')
Insert into tblEmployee values (9, 'Riho', 'Kalevipoeg', 'Mees', 1850, 'Riho@kalevipoeg.com')
Insert into tblEmployee values (10, 'Toomas', 'Toome', 'Mees', 3030, 'Toomas@toome.com')

SELECT *
FROM tblEmployee