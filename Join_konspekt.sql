/* ============================================================
   SQL JOIN PÄRINGUTE KONSPEKT
   Andmebaas: AdventureWorksDW2019

   Päringu käivitamine SSMS-is:
   1. Märgi soovitud päring hiirega.
   2. Vajuta Execute või klaviatuuril F5.

   Kommentaarid:
   -- Üherealine kommentaar

   Mitmerealine kommentaar:
   /* kommentaar */
   ============================================================ */

USE AdventureWorksDW2019;
GO


/* ============================================================
   1. JOIN PÕHIMÕTE

   JOIN ühendab kahe või enama tabeli andmed.

   Tavaliselt ühendatakse:
   - ühe tabeli Primary Key ehk primaarvõti;
   - teise tabeli Foreign Key ehk võõrvõti.

   Näide:
   DimCustomer.GeographyKey on võõrvõti.
   DimGeography.GeographyKey on primaarvõti.

   ON määrab, milliste veergude järgi tabelid ühendatakse.
   ============================================================ */


/* ============================================================
   2. INNER JOIN

   INNER JOIN näitab ainult neid ridu, millel leidub
   mõlemas tabelis sobiv vaste.

   Meelespea:
   INNER JOIN = ainult sobivad read mõlemast tabelist.
   ============================================================ */

SELECT
    C.FirstName,
    C.MiddleName,
    C.LastName,
    G.City,
    G.EnglishCountryRegionName AS Country
FROM DimCustomer AS C
INNER JOIN DimGeography AS G
    ON C.GeographyKey = G.GeographyKey;
GO


/* ============================================================
   3. LEFT JOIN

   LEFT JOIN näitab:
   - kõiki vasaku tabeli ridu;
   - parema tabeli sobivaid andmeid;
   - vaste puudumisel kuvatakse parema tabeli veergudes NULL.

   Vasak tabel on FROM järel olev tabel.

   Meelespea:
   LEFT JOIN = kõik vasakult.
   ============================================================ */

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


/* ============================================================
   LEFT JOIN: vasteta ridade leidmine

   IS NULL abil leiame vasaku tabeli read,
   millele paremas tabelis vastet ei leitud.
   ============================================================ */

SELECT
    C.FirstName,
    C.LastName,
    C.GeographyKey
FROM DimCustomer AS C
LEFT JOIN DimGeography AS G
    ON C.GeographyKey = G.GeographyKey
WHERE G.GeographyKey IS NULL;
GO


/* ============================================================
   4. RIGHT JOIN

   RIGHT JOIN näitab:
   - kõiki parema tabeli ridu;
   - vasaku tabeli sobivaid andmeid;
   - vaste puudumisel kuvatakse vasaku tabeli veergudes NULL.

   Meelespea:
   RIGHT JOIN = kõik paremalt.
   ============================================================ */

SELECT
    S.SalesTerritoryGroup,
    COUNT(G.City) AS CityCount
FROM DimGeography AS G
RIGHT JOIN DimSalesTerritory AS S
    ON G.SalesTerritoryKey = S.SalesTerritoryKey
GROUP BY S.SalesTerritoryGroup;
GO


/* ============================================================
   RIGHT JOIN-i saab tavaliselt kirjutada LEFT JOIN-ina,
   kui tabelite järjekord ära vahetada.

   See päring annab eelmise päringuga sarnase tulemuse.
   ============================================================ */

SELECT
    S.SalesTerritoryGroup,
    COUNT(G.City) AS CityCount
FROM DimSalesTerritory AS S
LEFT JOIN DimGeography AS G
    ON S.SalesTerritoryKey = G.SalesTerritoryKey
GROUP BY S.SalesTerritoryGroup;
GO


/* ============================================================
   5. FULL OUTER JOIN

   FULL OUTER JOIN näitab:
   - kõiki vasaku tabeli ridu;
   - kõiki parema tabeli ridu;
   - sobivad read ühendatakse;
   - vaste puudumisel kuvatakse teise tabeli veergudes NULL.

   Meelespea:
   FULL OUTER JOIN = kõik mõlemalt poolt.
   ============================================================ */

SELECT
    C.CurrencyName,
    O.OrganizationName,
    C.CurrencyAlternateKey
FROM DimOrganization AS O
FULL OUTER JOIN DimCurrency AS C
    ON O.CurrencyKey = C.CurrencyKey;
GO


/* ============================================================
   FULL OUTER JOIN: vasteta ridade leidmine

   Näitab ridu, millel puudub vaste ühes tabelitest.
   ============================================================ */

SELECT
    C.CurrencyName,
    O.OrganizationName
FROM DimOrganization AS O
FULL OUTER JOIN DimCurrency AS C
    ON O.CurrencyKey = C.CurrencyKey
WHERE O.OrganizationKey IS NULL
   OR C.CurrencyKey IS NULL;
GO


/* ============================================================
   6. CROSS JOIN

   CROSS JOIN ühendab esimese tabeli iga rea
   teise tabeli iga reaga.

   CROSS JOIN ei vaja ON tingimust.

   Näide:
   Kui esimeses tabelis on 10 rida ja teises 4 rida,
   siis tulemuses on 10 * 4 = 40 rida.

   Meelespea:
   CROSS JOIN = kõik võimalikud kombinatsioonid.
   ============================================================ */

SELECT
    O.OrganizationName,
    P.EnglishProductCategoryName AS ProductCategoryName
FROM DimOrganization AS O
CROSS JOIN DimProductCategory AS P;
GO


/* ============================================================
   7. SELF JOIN

   SELF JOIN tähendab, et tabel ühendatakse iseendaga.

   Samale tabelile tuleb anda kaks erinevat aliast.

   Child = alamorganisatsioon.
   Parent = emaorganisatsioon.
   ============================================================ */

SELECT
    Parent.OrganizationName AS ParentOrganization,
    Child.OrganizationName AS ChildOrganization
FROM DimOrganization AS Child
INNER JOIN DimOrganization AS Parent
    ON Child.ParentOrganizationKey = Parent.OrganizationKey;
GO


/* ============================================================
   8. MITME TABELI ÜHENDAMINE

   Ühes päringus võib kasutada mitut JOIN-i.

   Seosed:
   DimCustomer.GeographyKey
   ühendatakse DimGeography.GeographyKey-ga.

   DimGeography.SalesTerritoryKey
   ühendatakse DimSalesTerritory.SalesTerritoryKey-ga.
   ============================================================ */

SELECT
    C.FirstName,
    C.LastName,
    G.City,
    G.EnglishCountryRegionName AS Country,
    S.SalesTerritoryRegion,
    S.SalesTerritoryGroup
FROM DimCustomer AS C
INNER JOIN DimGeography AS G
    ON C.GeographyKey = G.GeographyKey
INNER JOIN DimSalesTerritory AS S
    ON G.SalesTerritoryKey = S.SalesTerritoryKey;
GO


/* ============================================================
   9. TABELITE ALIASED

   Alias on tabeli lühendatud nimi.

   Näide:
   DimCustomer AS C
   DimGeography AS G

   Seejärel saab kasutada:
   C.FirstName
   G.City

   AS sõna võib tabeli aliase juures ära jätta:

   FROM DimCustomer C
   ============================================================ */


/* ============================================================
   10. WHERE

   WHERE filtreerib üksikuid ridu.

   WHERE kasutatakse enne GROUP BY-d.
   ============================================================ */

SELECT
    C.FirstName,
    C.LastName,
    G.City
FROM DimCustomer AS C
INNER JOIN DimGeography AS G
    ON C.GeographyKey = G.GeographyKey
WHERE G.City = 'London';
GO


/* ============================================================
   11. GROUP BY

   GROUP BY jagab sama väärtusega read gruppidesse.

   Kui SELECT-is olev veerg ei ole agregaadifunktsiooni sees,
   peab see üldjuhul olema GROUP BY osas.
   ============================================================ */

SELECT
    G.EnglishCountryRegionName AS Country,
    COUNT(*) AS CustomerCount
FROM DimCustomer AS C
INNER JOIN DimGeography AS G
    ON C.GeographyKey = G.GeographyKey
GROUP BY G.EnglishCountryRegionName;
GO


/* ============================================================
   12. HAVING

   HAVING filtreerib GROUP BY abil loodud gruppe.

   WHERE filtreerib üksikuid ridu.
   HAVING filtreerib gruppe.

   Näide:
   Näita ainult riike, kus on rohkem kui 100 klienti.
   ============================================================ */

SELECT
    G.EnglishCountryRegionName AS Country,
    COUNT(*) AS CustomerCount
FROM DimCustomer AS C
INNER JOIN DimGeography AS G
    ON C.GeographyKey = G.GeographyKey
GROUP BY G.EnglishCountryRegionName
HAVING COUNT(*) > 100;
GO


/* ============================================================
   13. WHERE JA HAVING KOOS

   Töötamise järjekord:
   1. WHERE filtreerib read.
   2. GROUP BY moodustab grupid.
   3. HAVING filtreerib grupid.
   4. ORDER BY sorteerib tulemuse.
   ============================================================ */

SELECT
    G.EnglishCountryRegionName AS Country,
    COUNT(*) AS CustomerCount
FROM DimCustomer AS C
INNER JOIN DimGeography AS G
    ON C.GeographyKey = G.GeographyKey
WHERE G.City IS NOT NULL
GROUP BY G.EnglishCountryRegionName
HAVING COUNT(*) > 100
ORDER BY CustomerCount DESC;
GO


/* ============================================================
   14. AGREGAADIFUNKTSIOONID

   COUNT(*)      = loendab kõik read.
   COUNT(veerg)  = loendab ainult mitte-NULL väärtused.
   SUM(veerg)    = liidab väärtused kokku.
   AVG(veerg)    = arvutab keskmise.
   MIN(veerg)    = leiab väikseima väärtuse.
   MAX(veerg)    = leiab suurima väärtuse.
   ============================================================ */

SELECT
    Gender,
    COUNT(*) AS EmployeeCount,
    AVG(BaseRate) AS AverageBaseRate,
    MIN(BaseRate) AS MinimumBaseRate,
    MAX(BaseRate) AS MaximumBaseRate
FROM DimEmployee
GROUP BY Gender;
GO


/* ============================================================
   15. COUNT(*) JA COUNT(VEERG) ERINEVUS

   COUNT(*) loendab kõik tulemuse read.

   COUNT(G.City) loendab ainult read,
   kus G.City ei ole NULL.

   LEFT JOIN-i korral on sageli kasulikum COUNT(parema_tabeli.Id).
   ============================================================ */

SELECT
    S.SalesTerritoryGroup,
    COUNT(*) AS ResultRowCount,
    COUNT(G.City) AS CityCount
FROM DimSalesTerritory AS S
LEFT JOIN DimGeography AS G
    ON S.SalesTerritoryKey = G.SalesTerritoryKey
GROUP BY S.SalesTerritoryGroup;
GO


/* ============================================================
   16. NULL VÄÄRTUSED

   NULL tähendab puuduvat või teadmata väärtust.

   Vale:
   WHERE MiddleName = NULL

   Õige:
   WHERE MiddleName IS NULL

   Väärtuse olemasolu kontroll:
   WHERE MiddleName IS NOT NULL
   ============================================================ */

SELECT
    FirstName,
    MiddleName,
    LastName
FROM DimCustomer
WHERE MiddleName IS NULL;
GO


/* ============================================================
   17. ORDER BY

   ORDER BY sorteerib tulemuse.

   ASC  = kasvav järjekord.
   DESC = kahanev järjekord.
   ============================================================ */

SELECT
    FirstName,
    LastName,
    BirthDate
FROM DimCustomer
ORDER BY BirthDate ASC;
GO


/* ============================================================
   18. TOP

   SQL Serveris kasutatakse LIMIT asemel TOP-i.

   Vale SQL Serveris:
   SELECT * FROM DimCustomer LIMIT 3;

   Õige:
   SELECT TOP 3 ...
   ============================================================ */

SELECT TOP 3
    FirstName,
    LastName,
    BirthDate
FROM DimCustomer
ORDER BY BirthDate ASC;
GO


/* ============================================================
   19. LIKE

   LIKE abil saab otsida teksti osa.

   'A%'  = algab A-tähega.
   '%a'  = lõpeb a-tähega.
   '%an%' = sisaldab teksti an.
   ============================================================ */

SELECT
    FirstName,
    LastName
FROM DimCustomer
WHERE FirstName LIKE 'A%';
GO


/* ============================================================
   20. BETWEEN

   BETWEEN kontrollib, kas väärtus jääb kahe väärtuse vahele.

   Mõlemad piirid kuuluvad tulemusse.
   ============================================================ */

SELECT
    FirstName,
    LastName,
    YearlyIncome
FROM DimCustomer
WHERE YearlyIncome BETWEEN 30000 AND 50000;
GO


/* ============================================================
   21. IN

   IN kontrollib, kas väärtus kuulub etteantud nimekirja.
   ============================================================ */

SELECT
    FirstName,
    LastName,
    EnglishEducation
FROM DimCustomer
WHERE EnglishEducation IN
(
    'Bachelors',
    'Graduate Degree'
);
GO


/* ============================================================
   22. PRIMARY KEY JA FOREIGN KEY

   PRIMARY KEY:
   - identifitseerib iga rea unikaalselt;
   - ei tohi sisaldada NULL väärtust;
   - väärtus peab olema unikaalne.

   FOREIGN KEY:
   - viitab teise tabeli primaarvõtmele;
   - aitab luua tabelite vahel seose.

   Näide:
   DimCustomer.GeographyKey
   viitab DimGeography.GeographyKey-le.
   ============================================================ */


/* ============================================================
   23. UUE TABELI LOOMINE

   Kontrollime enne, kas tabel on juba olemas.
   Kui tabelit ei ole, luuakse see.
   ============================================================ */

IF OBJECT_ID('dbo.NewRecruits', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.NewRecruits
    (
        Id int NOT NULL PRIMARY KEY,
        Firstname nvarchar(50),
        Lastname nvarchar(50),
        Gender nvarchar(10),
        Age int NOT NULL,
        City nvarchar(50),
        Email nvarchar(50)
    );
END;
GO


/* ============================================================
   24. ANDMETE LISAMINE

   Andmed lisatakse ainult siis,
   kui NewRecruits tabel on tühi.
   ============================================================ */

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.NewRecruits
)
BEGIN
    INSERT INTO dbo.NewRecruits
    (
        Id,
        Firstname,
        Lastname,
        Gender,
        Age,
        City,
        Email
    )
    VALUES
        (1, 'Aadu', 'Aavik', 'Mees', 28, 'Pärnu', 'Aadu@aavik.com'),
        (2, 'Peedu', 'Peet', 'Mees', 35, 'Tartu', 'Peedu@peet.com'),
        (3, 'Tiit', 'Tuut', 'Mees', 46, 'Tallinn', 'Tiit@tuut.com'),
        (4, 'Stiina', 'Saar', 'Naine', 23, 'Tallinn', 'Stiina@saar.com'),
        (5, 'Jaan', 'Jaaniuss', 'Mees', 27, 'Paide', 'Jaan@jaaniuss.com'),
        (6, 'Heidi', 'Häving', 'Naine', 30, 'Viljandi', 'Heidi@h2ving.com'),
        (7, 'Laura', 'Lagrits', 'Naine', 39, 'Pärnu', 'Laura@lagrits.com'),
        (8, 'Olev', 'Olevipoeg', 'Mees', 60, 'Haapsalu', 'Olev@olevipoeg.com'),
        (9, 'Kalev', 'Kalevipoeg', 'Mees', 57, 'Paide', 'Kalev@kalevipoeg.com'),
        (10, 'Toomas', 'Toome', 'Mees', 33, 'Haapsalu', 'Toomas@toome.com');
END;
GO


/* ============================================================
   25. KÕIK NEWRECRUITS TABELI ANDMED
   ============================================================ */

SELECT *
FROM dbo.NewRecruits;
GO


/* ============================================================
   26. TALLINNAS ELAVAD INIMESED
   ============================================================ */

SELECT *
FROM dbo.NewRecruits
WHERE City = 'Tallinn';
GO


/* ============================================================
   27. VÄHEMALT 30-AASTASED

   DESC sorteerib vanemast nooremani.
   ============================================================ */

SELECT
    Firstname,
    Lastname,
    Age
FROM dbo.NewRecruits
WHERE Age >= 30
ORDER BY Age DESC;
GO


/* ============================================================
   28. KOLM VANIMAT INIMEST
   ============================================================ */

SELECT TOP 3
    Firstname,
    Lastname,
    Age
FROM dbo.NewRecruits
ORDER BY Age DESC;
GO


/* ============================================================
   29. INIMESTE ARV LINNADE JÄRGI
   ============================================================ */

SELECT
    City,
    COUNT(*) AS PersonCount
FROM dbo.NewRecruits
GROUP BY City
ORDER BY PersonCount DESC;
GO


/* ============================================================
   30. LINNAD, KUS ELAB ROHKEM KUI ÜKS INIMENE
   ============================================================ */

SELECT
    City,
    COUNT(*) AS PersonCount
FROM dbo.NewRecruits
GROUP BY City
HAVING COUNT(*) > 1
ORDER BY PersonCount DESC;
GO


/* ============================================================
   31. KESKMINE VANUS SOO JÄRGI

   CAST muudab Age väärtuse kümnendarvuks,
   et keskmine saaks sisaldada komakohti.
   ============================================================ */

SELECT
    Gender,
    AVG(CAST(Age AS decimal(10, 2))) AS AverageAge
FROM dbo.NewRecruits
GROUP BY Gender;
GO


/* ============================================================
   32. INIMESED, KELLE NIMI ALGAB A-TÄHEGA
   ============================================================ */

SELECT *
FROM dbo.NewRecruits
WHERE Firstname LIKE 'A%';
GO


/* ============================================================
   33. INIMESED VANUSES 30 KUNI 50
   ============================================================ */

SELECT *
FROM dbo.NewRecruits
WHERE Age BETWEEN 30 AND 50
ORDER BY Age;
GO


/* ============================================================
   34. TALLINNAS VÕI PÄRNUS ELAVAD INIMESED
   ============================================================ */

SELECT *
FROM dbo.NewRecruits
WHERE City IN ('Tallinn', 'Pärnu');
GO


/* ============================================================
   35. SELF JOIN NEWRECRUITS TABELIGA

   Leiame inimesed, kes elavad samas linnas.

   N1.Id < N2.Id takistab:
   - inimese ühendamist iseendaga;
   - sama paari näitamist kaks korda.
   ============================================================ */

SELECT
    N1.Firstname AS FirstPerson,
    N2.Firstname AS SecondPerson,
    N1.City
FROM dbo.NewRecruits AS N1
INNER JOIN dbo.NewRecruits AS N2
    ON N1.City = N2.City
   AND N1.Id < N2.Id;
GO


/* ============================================================
   36. LEVINUD VIGA: GROUP BY

   Vale päring:

   SELECT City, Gender, COUNT(*)
   FROM dbo.NewRecruits
   GROUP BY City;

   Gender on SELECT-is, kuid ei ole GROUP BY osas.

   Õige päring:
   ============================================================ */

SELECT
    City,
    Gender,
    COUNT(*) AS PersonCount
FROM dbo.NewRecruits
GROUP BY City, Gender;
GO


/* ============================================================
   37. LEVINUD VIGA: WHERE JA HAVING

   Vale:
   WHERE COUNT(*) > 1

   Agregaadifunktsiooni tingimus tuleb panna HAVING ossa.

   Õige:
   ============================================================ */

SELECT
    City,
    COUNT(*) AS PersonCount
FROM dbo.NewRecruits
GROUP BY City
HAVING COUNT(*) > 1;
GO


/* ============================================================
   38. LEVINUD VIGA: LEFT JOIN MUUTUB INNER JOIN-IKS

   Allolev WHERE tingimus eemaldab NULL väärtusega read.
   Selle tõttu käitub LEFT JOIN sisuliselt INNER JOIN-ina.

   SELECT C.FirstName, G.City
   FROM DimCustomer C
   LEFT JOIN DimGeography G
       ON C.GeographyKey = G.GeographyKey
   WHERE G.City = 'London';

   Kui soovime säilitada kõik kliendid,
   tuleb parema tabeli tingimus panna ON ossa.
   ============================================================ */

SELECT
    C.FirstName,
    C.LastName,
    G.City
FROM DimCustomer AS C
LEFT JOIN DimGeography AS G
    ON C.GeographyKey = G.GeographyKey
   AND G.City = 'London';
GO


/* ============================================================
   39. KUIDAS VÕÕRAS ANDMEBAASIS SEOSEID LEIDA?

   1. Vaata tabelite esimesi ridu.
   2. Otsi sama nimega võtmeveerge.
   3. Kontrolli, milline veerg on Primary Key.
   4. Kontrolli, milline veerg on Foreign Key.
   5. Ühenda alguses ainult kaks tabelit.
   6. Lisa hiljem WHERE, GROUP BY, HAVING ja ORDER BY.
   ============================================================ */

SELECT TOP 10 *
FROM DimCustomer;
GO

SELECT TOP 10 *
FROM DimGeography;
GO


/* ============================================================
   40. LIHTNE JOIN-I TEST

   Alusta ainult võtmete kontrollimisest.
   Kui tulemused sobivad, lisa nimed ja muud veerud.
   ============================================================ */

SELECT TOP 20
    C.GeographyKey AS CustomerGeographyKey,
    G.GeographyKey AS GeographyGeographyKey,
    C.FirstName,
    C.LastName,
    G.City
FROM DimCustomer AS C
INNER JOIN DimGeography AS G
    ON C.GeographyKey = G.GeographyKey;
GO


/* ============================================================
   41. JOIN-IDE KIIRE MEELESPEA

   INNER JOIN
   = ainult mõlemas tabelis sobivad read.

   LEFT JOIN
   = kõik vasaku tabeli read.

   RIGHT JOIN
   = kõik parema tabeli read.

   FULL OUTER JOIN
   = kõik mõlema tabeli read.

   CROSS JOIN
   = kõik võimalikud kombinatsioonid.

   SELF JOIN
   = tabel ühendatakse iseendaga.

   ON
   = kuidas tabelid omavahel ühendatakse.

   WHERE
   = filtreerib üksikuid ridu.

   GROUP BY
   = moodustab grupid.

   HAVING
   = filtreerib gruppe.

   ORDER BY
   = sorteerib tulemuse.

   COUNT(*)
   = loendab kõik read.

   COUNT(veerg)
   = ei loenda NULL väärtusi.

   IS NULL
   = kontrollib puuduvat väärtust.

   TOP
   = piirab tulemuste arvu SQL Serveris.
   ============================================================ */


/* ============================================================
   42. JOIN-I ÜLDISED PÕHJAD

   Need on näidispõhjad.
   Ära käivita neid enne tabeli- ja veerunimede muutmist.

   INNER JOIN:

   SELECT
       A.Veerg,
       B.Veerg
   FROM TabelA AS A
   INNER JOIN TabelB AS B
       ON A.Voti = B.Voti;


   LEFT JOIN:

   SELECT
       A.Veerg,
       B.Veerg
   FROM TabelA AS A
   LEFT JOIN TabelB AS B
       ON A.Voti = B.Voti;


   RIGHT JOIN:

   SELECT
       A.Veerg,
       B.Veerg
   FROM TabelA AS A
   RIGHT JOIN TabelB AS B
       ON A.Voti = B.Voti;


   FULL OUTER JOIN:

   SELECT
       A.Veerg,
       B.Veerg
   FROM TabelA AS A
   FULL OUTER JOIN TabelB AS B
       ON A.Voti = B.Voti;


   CROSS JOIN:

   SELECT
       A.Veerg,
       B.Veerg
   FROM TabelA AS A
   CROSS JOIN TabelB AS B;


   SELF JOIN:

   SELECT
       A.Veerg,
       B.Veerg
   FROM SamaTabel AS A
   INNER JOIN SamaTabel AS B
       ON A.SeoseVeerg = B.Voti;


   JOIN KOOS GRUPEERIMISEGA:

   SELECT
       A.Nimetus,
       COUNT(B.Id) AS Total
   FROM TabelA AS A
   LEFT JOIN TabelB AS B
       ON A.Id = B.TabelAId
   GROUP BY A.Nimetus
   HAVING COUNT(B.Id) > 0
   ORDER BY Total DESC;
   ============================================================ */