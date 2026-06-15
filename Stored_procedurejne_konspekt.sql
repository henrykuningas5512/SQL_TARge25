/*==============================================================
  KONTROLLTÖÖ KONSPEKT

  TEEMAD:
  1. STORED PROCEDURE
  2. FUNKTSIOONID
  3. TEMP-TABELID
  4. INDEKSID
  5. VIEW'D

  ANDMEBAAS:
  AdventureWorksDW2019

  NB!
  CREATE PROCEDURE, CREATE FUNCTION ja CREATE VIEW peavad üldjuhul
  olema batch'i esimesed käsud. Sellepärast kasutatakse GO käsku.
==============================================================*/

USE AdventureWorksDW2019;
GO


/*==============================================================
  1. STORED PROCEDURE EHK SALVESTATUD PROTSEDUUR
==============================================================*/

/*
Stored procedure on andmebaasi salvestatud SQL-kood.

Stored procedure võib:
- otsida andmeid;
- lisada andmeid;
- muuta andmeid;
- kustutada andmeid;
- võtta vastu parameetreid;
- tagastada OUTPUT-parameetri;
- tagastada RETURN-koodina täisarvu.

Käivitamine:
EXEC protseduuri_nimi

CREATE OR ALTER tähendab, et:
- kui procedure puudub, siis see luuakse;
- kui procedure on olemas, siis seda muudetakse.
*/


/*--------------------------------------------------------------
  1.1. Lihtne stored procedure ilma parameetrita
--------------------------------------------------------------*/

CREATE OR ALTER PROCEDURE dbo.spGetEmployees
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        FirstName,
        LastName,
        Gender,
        Title,
        DepartmentName
    FROM dbo.DimEmployee;
END;
GO

-- Käivitamise variandid
EXEC dbo.spGetEmployees;
EXECUTE dbo.spGetEmployees;
GO


/*--------------------------------------------------------------
  1.2. Stored procedure ühe sisendparameetriga
--------------------------------------------------------------*/

CREATE OR ALTER PROCEDURE dbo.spGetEmployeesByGender
    @Gender nvarchar(10)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        FirstName,
        LastName,
        MiddleName,
        Gender,
        Title,
        DepartmentName
    FROM dbo.DimEmployee
    WHERE Gender = @Gender;
END;
GO

-- M tähendab Male
EXEC dbo.spGetEmployeesByGender 'M';

-- F tähendab Female
EXEC dbo.spGetEmployeesByGender 'F';

-- Parameetri nimega käivitamine
EXEC dbo.spGetEmployeesByGender
    @Gender = 'F';
GO


/*--------------------------------------------------------------
  1.3. Stored procedure mitme parameetriga
--------------------------------------------------------------*/

CREATE OR ALTER PROCEDURE dbo.spGetEmployeesByGenderAndDepartment
    @Gender nvarchar(10),
    @Department nvarchar(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        FirstName,
        LastName,
        Gender,
        Title,
        DepartmentName
    FROM dbo.DimEmployee
    WHERE Gender = @Gender
      AND DepartmentName = @Department;
END;
GO

-- Parameetrid antakse õiges järjekorras
EXEC dbo.spGetEmployeesByGenderAndDepartment
    'F',
    'Marketing';

-- Parameetrid antakse nime järgi.
-- Nime järgi kasutades ei ole järjekord oluline.
EXEC dbo.spGetEmployeesByGenderAndDepartment
    @Department = 'Marketing',
    @Gender = 'F';
GO


/*--------------------------------------------------------------
  1.4. OUTPUT-parameeter
--------------------------------------------------------------*/

/*
OUTPUT-parameeter võimaldab procedure'i sees arvutatud väärtuse
salvestada muutujasse ja kasutada seda väljaspool procedure'i.
*/

CREATE OR ALTER PROCEDURE dbo.spGetEmployeeCountByGender
    @Gender nvarchar(10),
    @EmployeeCount int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @EmployeeCount = COUNT(*)
    FROM dbo.DimEmployee
    WHERE Gender = @Gender;
END;
GO

DECLARE @TotalCount int;

EXEC dbo.spGetEmployeeCountByGender
    @Gender = 'F',
    @EmployeeCount = @TotalCount OUTPUT;

PRINT 'Töötajate arv: ' + CAST(@TotalCount AS nvarchar(20));

SELECT @TotalCount AS EmployeeCount;
GO


/*--------------------------------------------------------------
  1.5. OUTPUT-parameetri ja IF-i kasutamine
--------------------------------------------------------------*/

DECLARE @Count int;

EXEC dbo.spGetEmployeeCountByGender
    @Gender = 'M',
    @EmployeeCount = @Count OUTPUT;

IF @Count = 0
BEGIN
    PRINT 'Ühtegi töötajat ei leitud';
END
ELSE
BEGIN
    PRINT 'Leiti vähemalt üks töötaja';
    PRINT @Count;
END;
GO


/*--------------------------------------------------------------
  1.6. RETURN-väärtus
--------------------------------------------------------------*/

/*
Stored procedure'i RETURN tagastab ainult int-tüüpi väärtuse.

RETURN sobib tavaliselt staatuse tagastamiseks:
0 = korras
1 = viga või mingi tingimus täitus

RETURN ei sobi töötaja nime tagastamiseks.
Nime või muu väärtuse tagastamiseks kasutatakse:
- SELECT-i;
- OUTPUT-parameetrit.
*/

CREATE OR ALTER PROCEDURE dbo.spEmployeeExists
    @EmployeeKey int
AS
BEGIN
    IF EXISTS
    (
        SELECT 1
        FROM dbo.DimEmployee
        WHERE EmployeeKey = @EmployeeKey
    )
    BEGIN
        RETURN 1;
    END;

    RETURN 0;
END;
GO

DECLARE @ReturnValue int;

EXEC @ReturnValue = dbo.spEmployeeExists
    @EmployeeKey = 1;

SELECT @ReturnValue AS EmployeeExists;
GO


/*--------------------------------------------------------------
  1.7. Procedure'i info vaatamine
--------------------------------------------------------------*/

-- Näitab procedure'i infot
EXEC sp_help 'dbo.spGetEmployeesByGender';

-- Näitab procedure'i SQL-koodi
EXEC sp_helptext 'dbo.spGetEmployeesByGender';

-- Näitab, millistest objektidest procedure sõltub
-- Tegemist on vana käsuga, aga seda kasutati tunnis.
EXEC sp_depends 'dbo.spGetEmployeesByGender';
GO


/*--------------------------------------------------------------
  1.8. WITH ENCRYPTION
--------------------------------------------------------------*/

/*
WITH ENCRYPTION peidab procedure'i definitsiooni tavapäraste
SQL Serveri tööriistade eest.

See ei ole täielik turvameede.
Pärast seda ei saa sp_helptext abil procedure'i koodi vaadata.

Näide:

CREATE OR ALTER PROCEDURE dbo.spSecretProcedure
    @Gender nvarchar(10)
WITH ENCRYPTION
AS
BEGIN
    SELECT FirstName, LastName
    FROM dbo.DimEmployee
    WHERE Gender = @Gender;
END;
GO
*/


/*--------------------------------------------------------------
  1.9. Procedure'i kustutamine
--------------------------------------------------------------*/

-- DROP PROCEDURE IF EXISTS dbo.spGetEmployees;
-- GO



/*==============================================================
  2. FUNKTSIOONID
==============================================================*/

/*
Funktsioon võtab vastu sisendi ja peab tagastama tulemuse.

Peamised enda loodavad funktsioonid:

1. Scalar function
   Tagastab ühe väärtuse.

2. Inline table-valued function
   Tagastab SELECT-päringu tulemuse tabelina.

3. Multi-statement table-valued function
   Loob tabelimuutuja, täidab selle ja tagastab tabeli.

Funktsiooni kasutatakse tavaliselt SELECT-päringu sees.
*/


/*--------------------------------------------------------------
  2.1. Scalar function ehk ühte väärtust tagastav funktsioon
--------------------------------------------------------------*/

/*
Järgmine funktsioon arvutab inimese vanuse.

DATEDIFF(YEAR...) üksi ei ole täiesti täpne, sest see ei kontrolli,
kas inimese sünnipäev on sellel aastal juba olnud.
*/

CREATE OR ALTER FUNCTION dbo.fn_GetAge
(
    @BirthDate date
)
RETURNS int
AS
BEGIN
    IF @BirthDate IS NULL
        RETURN NULL;

    DECLARE @Age int;

    SET @Age = DATEDIFF(YEAR, @BirthDate, GETDATE());

    IF DATEADD(YEAR, @Age, @BirthDate) > CAST(GETDATE() AS date)
    BEGIN
        SET @Age = @Age - 1;
    END;

    RETURN @Age;
END;
GO

-- Funktsiooni kasutamine ühe kuupäevaga
SELECT dbo.fn_GetAge('2000-02-20') AS Age;

-- Funktsiooni kasutamine tabeli veeruga
SELECT
    FirstName,
    LastName,
    BirthDate,
    dbo.fn_GetAge(BirthDate) AS Age
FROM dbo.DimEmployee;

-- Ainult töötajad, kes on vähemalt 50-aastased
SELECT
    FirstName,
    LastName,
    BirthDate,
    dbo.fn_GetAge(BirthDate) AS Age
FROM dbo.DimEmployee
WHERE dbo.fn_GetAge(BirthDate) >= 50;
GO


/*--------------------------------------------------------------
  2.2. Vanus aastates, kuudes ja päevades
--------------------------------------------------------------*/

CREATE OR ALTER FUNCTION dbo.fn_ComputeDetailedAge
(
    @DOB date
)
RETURNS nvarchar(100)
AS
BEGIN
    IF @DOB IS NULL
        RETURN NULL;

    DECLARE @TempDate date;
    DECLARE @Years int;
    DECLARE @Months int;
    DECLARE @Days int;
    DECLARE @Age nvarchar(100);

    SET @TempDate = @DOB;

    SET @Years =
        DATEDIFF(YEAR, @TempDate, GETDATE())
        -
        CASE
            WHEN MONTH(@DOB) > MONTH(GETDATE())
                 OR
                 (
                     MONTH(@DOB) = MONTH(GETDATE())
                     AND DAY(@DOB) > DAY(GETDATE())
                 )
            THEN 1
            ELSE 0
        END;

    SET @TempDate = DATEADD(YEAR, @Years, @TempDate);

    SET @Months =
        DATEDIFF(MONTH, @TempDate, GETDATE())
        -
        CASE
            WHEN DAY(@TempDate) > DAY(GETDATE())
            THEN 1
            ELSE 0
        END;

    SET @TempDate = DATEADD(MONTH, @Months, @TempDate);

    SET @Days = DATEDIFF(DAY, @TempDate, GETDATE());

    SET @Age =
        CAST(@Years AS nvarchar(10)) + ' years, ' +
        CAST(@Months AS nvarchar(10)) + ' months, ' +
        CAST(@Days AS nvarchar(10)) + ' days old';

    RETURN @Age;
END;
GO

SELECT dbo.fn_ComputeDetailedAge('2000-02-20') AS DetailedAge;
GO


/*--------------------------------------------------------------
  2.3. Scalar function töötaja nime tagastamiseks
--------------------------------------------------------------*/

CREATE OR ALTER FUNCTION dbo.fn_GetEmployeeNameById
(
    @EmployeeKey int
)
RETURNS nvarchar(50)
AS
BEGIN
    DECLARE @Name nvarchar(50);

    SELECT @Name = FirstName
    FROM dbo.DimEmployee
    WHERE EmployeeKey = @EmployeeKey;

    RETURN @Name;
END;
GO

SELECT dbo.fn_GetEmployeeNameById(1) AS EmployeeName;
GO


/*--------------------------------------------------------------
  2.4. Inline table-valued function
--------------------------------------------------------------*/

/*
Inline table-valued function:
- tagastab tabeli;
- sisaldab ühte SELECT-päringut;
- BEGIN ja END ei ole vaja;
- sarnaneb parameetriga view'ga;
- on tavaliselt kiirem kui multi-statement funktsioon.
*/

CREATE OR ALTER FUNCTION dbo.fn_EmployeesByDepartment
(
    @Department nvarchar(50)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        EmployeeKey,
        FirstName,
        LastName,
        MiddleName,
        BirthDate,
        Gender,
        Title,
        DepartmentName
    FROM dbo.DimEmployee
    WHERE DepartmentName = @Department
);
GO

SELECT *
FROM dbo.fn_EmployeesByDepartment('Marketing');

-- Funktsiooni tulemust saab veel omakorda filtreerida
SELECT *
FROM dbo.fn_EmployeesByDepartment('Marketing')
WHERE Gender = 'F';

-- Funktsiooni tulemust saab sorteerida
SELECT *
FROM dbo.fn_EmployeesByDepartment('Marketing')
ORDER BY LastName;
GO


/*--------------------------------------------------------------
  2.5. Inline table-valued function soo järgi
--------------------------------------------------------------*/

CREATE OR ALTER FUNCTION dbo.fn_EmployeesByGender
(
    @Gender nvarchar(10)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        EmployeeKey,
        FirstName,
        LastName,
        BirthDate,
        Gender,
        DepartmentName
    FROM dbo.DimEmployee
    WHERE Gender = @Gender
);
GO

SELECT *
FROM dbo.fn_EmployeesByGender('F');
GO


/*--------------------------------------------------------------
  2.6. Multi-statement table-valued function
--------------------------------------------------------------*/

/*
Multi-statement table-valued function:

- tagastab tabeli;
- kasutab BEGIN ja END;
- loob tagastatava tabelimuutuja;
- võib sisaldada mitut SQL-lauset;
- võib olla inline-funktsioonist aeglasem.
*/

CREATE OR ALTER FUNCTION dbo.fn_MS_EmployeesByDepartment
(
    @Department nvarchar(50)
)
RETURNS @Employees TABLE
(
    EmployeeKey int,
    FirstName nvarchar(50),
    LastName nvarchar(50),
    BirthDate date,
    Gender nvarchar(10),
    DepartmentName nvarchar(50)
)
AS
BEGIN
    INSERT INTO @Employees
    (
        EmployeeKey,
        FirstName,
        LastName,
        BirthDate,
        Gender,
        DepartmentName
    )
    SELECT
        EmployeeKey,
        FirstName,
        LastName,
        BirthDate,
        Gender,
        DepartmentName
    FROM dbo.DimEmployee
    WHERE DepartmentName = @Department;

    RETURN;
END;
GO

SELECT *
FROM dbo.fn_MS_EmployeesByDepartment('Marketing');
GO


/*--------------------------------------------------------------
  2.7. Inline ja multi-statement funktsiooni erinevus
--------------------------------------------------------------*/

/*
INLINE TABLE-VALUED FUNCTION:

RETURNS TABLE
AS
RETURN
(
    SELECT ...
)

- sisaldab tavaliselt ainult ühte SELECT-i;
- SQL Server saab seda paremini optimeerida;
- tavaliselt kiirem;
- sarnaneb parameetriga view'ga.


MULTI-STATEMENT TABLE-VALUED FUNCTION:

RETURNS @Table TABLE (...)
AS
BEGIN
    INSERT INTO @Table ...
    RETURN;
END

- võib sisaldada mitut käsku;
- loob eraldi tabelimuutuja;
- võib olla aeglasem;
- tulemust ei saa tavaliselt otse uuendada.
*/


/*--------------------------------------------------------------
  2.8. Deterministic ja nondeterministic funktsioonid
--------------------------------------------------------------*/

/*
DETERMINISTIC FUNKTSIOON:

Annab sama sisendi korral alati sama tulemuse.

Näited:
SQUARE(3)
ABS(-10)
UPPER('tere')

Paljud SUM, AVG, MIN, MAX ja COUNT kasutused on samuti
deterministlikud.


NONDETERMINISTIC FUNKTSIOON:

Tulemus võib igal käivitamisel muutuda.

Näited:
GETDATE()
CURRENT_TIMESTAMP
SYSDATETIME()
RAND()
*/

SELECT SQUARE(3) AS DeterministicResult;

SELECT GETDATE() AS NonDeterministicResult;

SELECT RAND() AS RandomResult;
GO


/*--------------------------------------------------------------
  2.9. WITH SCHEMABINDING
--------------------------------------------------------------*/

/*
SCHEMABINDING seob funktsiooni kasutatavate tabelitega.

Kui funktsioon sõltub tabelist, siis ei saa selle tabeli kasutatud
veerge lihtsalt kustutada või muuta.

SCHEMABINDING nõuab tabeli kahesosalist nime:
dbo.DimEmployee

Mitte ainult:
DimEmployee
*/

CREATE OR ALTER FUNCTION dbo.fn_GetEmployeeNameSchemaBound
(
    @EmployeeKey int
)
RETURNS nvarchar(50)
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @Name nvarchar(50);

    SELECT @Name = FirstName
    FROM dbo.DimEmployee
    WHERE EmployeeKey = @EmployeeKey;

    RETURN @Name;
END;
GO

SELECT dbo.fn_GetEmployeeNameSchemaBound(1) AS EmployeeName;
GO


/*--------------------------------------------------------------
  2.10. Funktsiooni info vaatamine
--------------------------------------------------------------*/

EXEC sp_help 'dbo.fn_GetAge';

EXEC sp_helptext 'dbo.fn_GetAge';
GO


/*--------------------------------------------------------------
  2.11. Funktsiooni kustutamine
--------------------------------------------------------------*/

-- DROP FUNCTION IF EXISTS dbo.fn_GetAge;
-- GO



/*==============================================================
  2A. SISEEHITATUD FUNKTSIOONIDE KIIRMELESPEA
==============================================================*/


/*--------------------------------------------------------------
  Stringifunktsioonid
--------------------------------------------------------------*/

SELECT ASCII('A') AS AsciiCode;

SELECT CHAR(65) AS Character;

SELECT UPPER('Hello') AS UpperText;

SELECT LOWER('HELLO') AS LowerText;

SELECT LTRIM('     Hello') AS LeftTrimmed;

SELECT RTRIM('Hello     ') AS RightTrimmed;

SELECT TRIM('     Hello     ') AS Trimmed;

SELECT REVERSE('ABCDEF') AS ReversedText;

SELECT LEFT('ABCDEF', 3) AS LeftPart;

SELECT RIGHT('ABCDEF', 3) AS RightPart;

SELECT LEN('ABCDEF') AS TextLength;

SELECT CHARINDEX('@', 'test@example.com') AS AtPosition;

SELECT SUBSTRING('test@example.com', 6, 7) AS DomainPart;

SELECT REPLACE('test.com', '.com', '.net') AS ReplacedText;

SELECT REPLICATE('*', 5) AS RepeatedText;

SELECT SPACE(5) AS FiveSpaces;

SELECT CONCAT('Henry', ' ', 'Kuningas') AS FullName;

SELECT COALESCE(NULL, NULL, 'First non-null value') AS Result;

SELECT ISNULL(NULL, 'Replacement value') AS Result;
GO


/*--------------------------------------------------------------
  Kuupäevafunktsioonid
--------------------------------------------------------------*/

SELECT GETDATE() AS CurrentDateTime;

SELECT CURRENT_TIMESTAMP AS CurrentTimestamp;

SELECT SYSDATETIME() AS AccurateDateTime;

SELECT SYSDATETIMEOFFSET() AS DateTimeWithOffset;

SELECT GETUTCDATE() AS UTCDateTime;

SELECT DAY(GETDATE()) AS CurrentDay;

SELECT MONTH(GETDATE()) AS CurrentMonth;

SELECT YEAR(GETDATE()) AS CurrentYear;

SELECT DATENAME(WEEKDAY, GETDATE()) AS WeekdayName;

SELECT DATENAME(MONTH, GETDATE()) AS MonthName;

SELECT DATEPART(WEEK, GETDATE()) AS WeekNumber;

SELECT DATEADD(DAY, 20, GETDATE()) AS TwentyDaysLater;

SELECT DATEADD(DAY, -20, GETDATE()) AS TwentyDaysEarlier;

SELECT DATEDIFF(YEAR, '2000-01-01', GETDATE()) AS YearDifference;

SELECT CAST(GETDATE() AS date) AS DateOnly;

SELECT CONVERT(date, GETDATE()) AS ConvertedDate;

SELECT ISDATE('2026-04-07') AS IsValidDate;
GO


/*--------------------------------------------------------------
  Matemaatilised funktsioonid
--------------------------------------------------------------*/

SELECT ABS(-101.5) AS AbsoluteValue;

SELECT CEILING(101.5) AS RoundedUp;

SELECT FLOOR(101.5) AS RoundedDown;

SELECT POWER(2, 4) AS PowerResult;

SELECT SQUARE(5) AS SquareResult;

SELECT SQRT(25) AS SquareRoot;

SELECT ROUND(850.556, 2) AS RoundedValue;

SELECT RAND() AS RandomValue;

SELECT CEILING(RAND() * 100) AS RandomNumber1To100;
GO



/*==============================================================
  3. TEMP-TABELID
==============================================================*/

/*
Temp-tabel on ajutine tabel.

Temp-tabelid luuakse tempdb andmebaasi.

Kaks peamist liiki:

#LocalTempTable
- üks # märk;
- nähtav ainult praeguses sessioonis ehk ühenduses;
- kaob ühenduse sulgemisel;
- procedure'i sees loodud lokaalne temp-tabel kaob
  procedure'i töö lõppedes.

##GlobalTempTable
- kaks ## märki;
- nähtav ka teistele sessioonidele;
- kaob siis, kui seda loonud sessioon on suletud ja
  ükski teine sessioon seda enam ei kasuta.

GO ei kustuta temp-tabelit, kui kasutad sama ühendust.
*/


/*--------------------------------------------------------------
  3.1. Lokaalne temp-tabel
--------------------------------------------------------------*/

DROP TABLE IF EXISTS #PersonCarColor;

CREATE TABLE #PersonCarColor
(
    Id int,
    Name nvarchar(20),
    CarColor nvarchar(20)
);

INSERT INTO #PersonCarColor
(
    Id,
    Name,
    CarColor
)
VALUES
    (1, 'Mart', 'Red'),
    (2, 'Tiit', 'Green'),
    (3, 'Peep', 'Blue'),
    (4, 'Teele', 'Pink');

SELECT *
FROM #PersonCarColor;

-- Temp-tabelit saab filtreerida
SELECT *
FROM #PersonCarColor
WHERE CarColor = 'Red';

-- Käsitsi kustutamine
DROP TABLE IF EXISTS #PersonCarColor;
GO


/*--------------------------------------------------------------
  3.2. Globaalne temp-tabel
--------------------------------------------------------------*/

DROP TABLE IF EXISTS ##GlobalPersonDetails;

CREATE TABLE ##GlobalPersonDetails
(
    Id int,
    Name nvarchar(20),
    DateOfBirth date
);

INSERT INTO ##GlobalPersonDetails
(
    Id,
    Name,
    DateOfBirth
)
VALUES
    (1, 'Mart', '2006-05-12'),
    (2, 'Tiit', '2000-02-20'),
    (3, 'Peep', '1999-03-07'),
    (4, 'Teele', '2007-12-30');

SELECT *
FROM ##GlobalPersonDetails;

-- Kustutamine
DROP TABLE IF EXISTS ##GlobalPersonDetails;
GO


/*--------------------------------------------------------------
  3.3. SELECT INTO abil temp-tabeli loomine
--------------------------------------------------------------*/

/*
SELECT INTO:
- loob tabeli automaatselt;
- võtab veerud SELECT-päringust;
- eraldi CREATE TABLE käsku ei ole vaja.
*/

DROP TABLE IF EXISTS #MarketingEmployees;

SELECT
    EmployeeKey,
    FirstName,
    LastName,
    Gender,
    DepartmentName
INTO #MarketingEmployees
FROM dbo.DimEmployee
WHERE DepartmentName = 'Marketing';

SELECT *
FROM #MarketingEmployees;

DROP TABLE IF EXISTS #MarketingEmployees;
GO


/*--------------------------------------------------------------
  3.4. Temp-tabel stored procedure'i sees
--------------------------------------------------------------*/

CREATE OR ALTER PROCEDURE dbo.spCreateLocalEmployeeTempTable
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #EmployeeDetails
    (
        EmployeeKey int,
        FullName nvarchar(110),
        DepartmentName nvarchar(50)
    );

    INSERT INTO #EmployeeDetails
    (
        EmployeeKey,
        FullName,
        DepartmentName
    )
    SELECT
        EmployeeKey,
        CONCAT(FirstName, ' ', LastName),
        DepartmentName
    FROM dbo.DimEmployee;

    SELECT *
    FROM #EmployeeDetails;
END;
GO

EXEC dbo.spCreateLocalEmployeeTempTable;
GO

/*
Pärast procedure'i lõppu ei saa seda tabelit enam kasutada:

SELECT *
FROM #EmployeeDetails;

See annaks vea, sest temp-tabel loodi procedure'i sees.
*/



/*==============================================================
  4. INDEKSID
==============================================================*/

/*
Indeks aitab SQL Serveril andmeid kiiremini leida.

Indeksit võib võrrelda raamatu sisukorra või registriga.

Indeks aitab eriti päringuid, kus kasutatakse:

WHERE
JOIN
ORDER BY
GROUP BY

INDEKSI PLUSSID:
- SELECT võib olla kiirem;
- otsimine võib olla kiirem;
- JOIN võib olla kiirem;
- sorteerimine võib olla kiirem.

INDEKSI MIINUSED:
- võtab kettaruumi;
- INSERT võib muutuda aeglasemaks;
- UPDATE võib muutuda aeglasemaks;
- DELETE võib muutuda aeglasemaks;
- liiga palju indekseid ei ole hea.
*/


/*--------------------------------------------------------------
  4.1. Peamised indeksitüübid
--------------------------------------------------------------*/

/*
1. CLUSTERED INDEX
   - määrab tabeliridade põhilise salvestusjärjestuse;
   - tabelis saab olla ainult üks;
   - primary key loob selle sageli automaatselt.

2. NONCLUSTERED INDEX
   - eraldi indeksistruktuur, mis viitab tabeliridadele;
   - tabelis saab olla mitu.

3. UNIQUE INDEX
   - ei luba indekseeritud väärtustel korduda.

4. FILTERED INDEX
   - sisaldab ainult WHERE-tingimusele vastavaid ridu.

5. COMPOSITE INDEX
   - indeks koosneb mitmest veerust.

6. INCLUDED COLUMNS
   - lisaveerud hoitakse indeksis päringu katmiseks.

Muud SQL Serveri indeksid:
- XML index;
- full-text index;
- spatial index;
- columnstore index.
*/


/*--------------------------------------------------------------
  4.2. Tavaline nonclustered index
--------------------------------------------------------------*/

DROP INDEX IF EXISTS IX_DimEmployee_BirthDate
ON dbo.DimEmployee;
GO

CREATE NONCLUSTERED INDEX IX_DimEmployee_BirthDate
ON dbo.DimEmployee(BirthDate DESC);
GO

SELECT
    FirstName,
    LastName,
    BirthDate,
    Title,
    DepartmentName
FROM dbo.DimEmployee
WHERE BirthDate >= '1970-01-01'
ORDER BY BirthDate DESC;
GO


/*--------------------------------------------------------------
  4.3. Indeksi sundimine INDEX vihjega
--------------------------------------------------------------*/

/*
Tavaliselt valib SQL Server ise sobiva indeksi.

WITH (INDEX(...)) sunnib SQL Serverit kasutama kindlat indeksit.

Seda ei ole tavaliselt vaja kasutada, sest Query Optimizer
võib ise parema valiku teha.
*/

SELECT
    FirstName,
    LastName,
    BirthDate,
    Title,
    DepartmentName
FROM dbo.DimEmployee
WITH (INDEX(IX_DimEmployee_BirthDate))
WHERE BirthDate >= '1970-01-01';
GO


/*--------------------------------------------------------------
  4.4. Filtreeritud indeks
--------------------------------------------------------------*/

DROP INDEX IF EXISTS IX_DimEmployee_MarketingDepartment
ON dbo.DimEmployee;
GO

CREATE NONCLUSTERED INDEX IX_DimEmployee_MarketingDepartment
ON dbo.DimEmployee(DepartmentName)
WHERE DepartmentName = 'Marketing';
GO

SELECT
    FirstName,
    LastName,
    DepartmentName
FROM dbo.DimEmployee
WHERE DepartmentName = 'Marketing';
GO


/*--------------------------------------------------------------
  4.5. Mitme veeruga indeks ja INCLUDE
--------------------------------------------------------------*/

/*
Indeksi veergude järjekord on oluline.

Allolev indeks sobib hästi päringule, kus otsitakse:
1. DepartmentName järgi;
2. Gender järgi.

INCLUDE veerud ei kuulu otsinguvõtmesse, kuid neid saab
päringu tulemuse tagastamiseks indeksist lugeda.
*/

DROP INDEX IF EXISTS IX_DimEmployee_Department_Gender
ON dbo.DimEmployee;
GO

CREATE NONCLUSTERED INDEX IX_DimEmployee_Department_Gender
ON dbo.DimEmployee
(
    DepartmentName,
    Gender
)
INCLUDE
(
    FirstName,
    LastName,
    BirthDate,
    Title
);
GO

SELECT
    FirstName,
    LastName,
    BirthDate,
    Title
FROM dbo.DimEmployee
WHERE DepartmentName = 'Marketing'
  AND Gender = 'F';
GO


/*--------------------------------------------------------------
  4.6. Clustered ja nonclustered indeksi näide
--------------------------------------------------------------*/

DROP TABLE IF EXISTS dbo.IndexEmployeeDemo;
GO

CREATE TABLE dbo.IndexEmployeeDemo
(
    Id int NOT NULL,
    Name nvarchar(50),
    Salary int,
    Gender nvarchar(10)
);
GO

-- Clustered index määrab põhilise järjestuse.
-- Seda saab tabelis olla ainult üks.

CREATE UNIQUE CLUSTERED INDEX IX_IndexEmployeeDemo_Id
ON dbo.IndexEmployeeDemo(Id);
GO

-- Nonclustered indekseid võib olla mitu.

CREATE NONCLUSTERED INDEX IX_IndexEmployeeDemo_Salary
ON dbo.IndexEmployeeDemo(Salary);
GO

INSERT INTO dbo.IndexEmployeeDemo
(
    Id,
    Name,
    Salary,
    Gender
)
VALUES
    (3, 'John', 4500, 'Male'),
    (1, 'Sam', 2500, 'Male'),
    (4, 'Sara', 5500, 'Female'),
    (5, 'Todd', 3100, 'Male'),
    (2, 'Pam', 6500, 'Female');

SELECT *
FROM dbo.IndexEmployeeDemo;
GO


/*--------------------------------------------------------------
  4.7. Unique index
--------------------------------------------------------------*/

/*
Unique index ei luba samal väärtusel korduda.
*/

DROP INDEX IF EXISTS IX_IndexEmployeeDemo_Name
ON dbo.IndexEmployeeDemo;
GO

CREATE UNIQUE NONCLUSTERED INDEX IX_IndexEmployeeDemo_Name
ON dbo.IndexEmployeeDemo(Name);
GO

/*
See annaks vea, sest nimi Sam on juba olemas:

INSERT INTO dbo.IndexEmployeeDemo
VALUES (6, 'Sam', 4000, 'Male');
*/


/*--------------------------------------------------------------
  4.8. IGNORE_DUP_KEY
--------------------------------------------------------------*/

/*
IGNORE_DUP_KEY = ON tähendab, et mitme rea sisestamisel jäetakse
unikaalsusreeglit rikkuv rida vahele, kuid teised read võivad
siiski andmebaasi minna.
*/

DROP TABLE IF EXISTS dbo.UniqueEmailDemo;
GO

CREATE TABLE dbo.UniqueEmailDemo
(
    Id int PRIMARY KEY,
    Email nvarchar(100)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX IX_UniqueEmailDemo_Email
ON dbo.UniqueEmailDemo(Email)
WITH (IGNORE_DUP_KEY = ON);
GO

INSERT INTO dbo.UniqueEmailDemo
(
    Id,
    Email
)
VALUES
    (1, 'one@example.com'),
    (2, 'two@example.com');

-- Kolmas rida sisaldab korduvat e-posti.
-- Neljas rida on unikaalne ja lisatakse.
INSERT INTO dbo.UniqueEmailDemo
(
    Id,
    Email
)
VALUES
    (3, 'one@example.com'),
    (4, 'four@example.com');

SELECT *
FROM dbo.UniqueEmailDemo;
GO


/*--------------------------------------------------------------
  4.9. Indeksite info vaatamine
--------------------------------------------------------------*/

EXEC sp_helpindex 'dbo.DimEmployee';

EXEC sp_helpindex 'dbo.IndexEmployeeDemo';
GO


/*--------------------------------------------------------------
  4.10. Päringuplaani vaatamine
--------------------------------------------------------------*/

/*
STATISTICS PROFILE näitab päringu käivitamise infot.

SET STATISTICS PROFILE ON;

SELECT
    FirstName,
    LastName,
    BirthDate
FROM dbo.DimEmployee
WHERE BirthDate >= '1970-01-01';

SET STATISTICS PROFILE OFF;
*/


/*
SHOWPLAN_ALL näitab plaani, kuid ei käivita päringut.

SET SHOWPLAN_ALL ON;
GO

SELECT
    FirstName,
    LastName,
    BirthDate
FROM dbo.DimEmployee
WHERE BirthDate >= '1970-01-01';
GO

SET SHOWPLAN_ALL OFF;
GO
*/


/*--------------------------------------------------------------
  4.11. Indeksi kustutamine
--------------------------------------------------------------*/

-- DROP INDEX IF EXISTS IX_DimEmployee_BirthDate
-- ON dbo.DimEmployee;
-- GO



/*==============================================================
  5. VIEW EHK VAADE
==============================================================*/

/*
View on salvestatud SELECT-päring.

View'd võib käsitleda virtuaalse tabelina.

Tavaline view ei salvesta enamasti ise andmeid.
Kui view'd kasutatakse, loetakse andmed aluseks olevatest tabelitest.

VIEW EELISED:
- lihtsustab keerulisi päringuid;
- peidab ebavajalikud veerud;
- piirab kasutajale nähtavaid andmeid;
- saab ühendada mitu tabelit;
- saab näidata koondandmeid;
- sama SELECT-päringut ei pea kogu aeg uuesti kirjutama.
*/


/*--------------------------------------------------------------
  5.1. Lihtne view
--------------------------------------------------------------*/

CREATE OR ALTER VIEW dbo.vEmployeeDOB
AS
SELECT
    EmployeeKey,
    FirstName,
    LastName,
    MiddleName,
    BirthDate
FROM dbo.DimEmployee;
GO

SELECT *
FROM dbo.vEmployeeDOB;

-- View'd saab filtreerida nagu tabelit
SELECT *
FROM dbo.vEmployeeDOB
WHERE BirthDate >= '1970-01-01';

-- Sorteerimine tehakse view kasutamisel
SELECT *
FROM dbo.vEmployeeDOB
ORDER BY BirthDate;
GO


/*--------------------------------------------------------------
  5.2. Filtreeritud view
--------------------------------------------------------------*/

CREATE OR ALTER VIEW dbo.vMarketingEmployees
AS
SELECT
    EmployeeKey,
    FirstName,
    LastName,
    Gender,
    Title,
    DepartmentName
FROM dbo.DimEmployee
WHERE DepartmentName = 'Marketing';
GO

SELECT *
FROM dbo.vMarketingEmployees;
GO


/*--------------------------------------------------------------
  5.3. Veergude peitmine view abil
--------------------------------------------------------------*/

/*
Selles view's ei näidata näiteks sünnikuupäeva ega teisi
tundlikumaid või ebavajalikke veerge.
*/

CREATE OR ALTER VIEW dbo.vEmployeePublicInformation
AS
SELECT
    EmployeeKey,
    FirstName,
    LastName,
    Title,
    DepartmentName
FROM dbo.DimEmployee;
GO

SELECT *
FROM dbo.vEmployeePublicInformation;
GO


/*--------------------------------------------------------------
  5.4. JOIN-iga view
--------------------------------------------------------------*/

CREATE OR ALTER VIEW dbo.vEmployeeSalesTerritory
AS
SELECT
    E.EmployeeKey,
    E.FirstName,
    E.LastName,
    E.MiddleName,
    S.SalesTerritoryCountry,
    S.SalesTerritoryGroup
FROM dbo.DimEmployee AS E
LEFT JOIN dbo.DimSalesTerritory AS S
    ON E.SalesTerritoryKey = S.SalesTerritoryKey;
GO

SELECT *
FROM dbo.vEmployeeSalesTerritory;
GO


/*--------------------------------------------------------------
  5.5. Self join view
--------------------------------------------------------------*/

/*
Self join tähendab, et tabel ühendatakse iseendaga.

E = Employee ehk töötaja
P = Parent Employee ehk ülemus

LEFT JOIN näitab ka töötajaid, kellel ülemus puudub.
*/

CREATE OR ALTER VIEW dbo.vEmployeeParentEmployee
AS
SELECT
    E.EmployeeKey,
    E.FirstName,
    E.LastName,
    CONCAT(P.FirstName, ' ', P.LastName) AS ParentEmployee
FROM dbo.DimEmployee AS E
LEFT JOIN dbo.DimEmployee AS P
    ON E.ParentEmployeeKey = P.EmployeeKey;
GO

SELECT *
FROM dbo.vEmployeeParentEmployee;
GO


/*--------------------------------------------------------------
  5.6. Koondandmetega view
--------------------------------------------------------------*/

CREATE OR ALTER VIEW dbo.vEmployeeCountByDepartment
AS
SELECT
    DepartmentName,
    COUNT_BIG(*) AS TotalEmployees
FROM dbo.DimEmployee
GROUP BY DepartmentName;
GO

SELECT *
FROM dbo.vEmployeeCountByDepartment
ORDER BY TotalEmployees DESC;
GO


/*--------------------------------------------------------------
  5.7. View kaudu andmete muutmine
--------------------------------------------------------------*/

/*
Lihtsa view kaudu võib olla võimalik kasutada:
- UPDATE;
- INSERT;
- DELETE.

See töötab tavaliselt siis, kui view põhineb ühel tabelil
ja selles ei ole keerulist JOIN-i ega GROUP BY-d.
*/

CREATE OR ALTER VIEW dbo.vEmployeeBasicData
AS
SELECT
    EmployeeKey,
    FirstName,
    LastName,
    Gender
FROM dbo.DimEmployee;
GO

SELECT *
FROM dbo.vEmployeeBasicData;

/*
NB! Järgnev käsk muudaks päriselt AdventureWorksDW2019 andmeid.
Sellepärast on see kommentaarina.

UPDATE dbo.vEmployeeBasicData
SET FirstName = 'New name'
WHERE EmployeeKey = 1;
*/


/*--------------------------------------------------------------
  5.8. View piirangud
--------------------------------------------------------------*/

/*
1. VIEW EI SAA VÕTTA VASTU PARAMEETREID.

Vale:

CREATE VIEW vEmployeeDetails
    @Gender nvarchar(10)
AS
SELECT ...
WHERE Gender = @Gender;

Kui on vaja parameetrit, kasuta inline table-valued function'it:

SELECT *
FROM dbo.fn_EmployeesByGender('F');


2. VIEW SEES EI SAA TAVALISELT ORDER BY-D KASUTADA.

Vale:

CREATE VIEW vSortedEmployees
AS
SELECT *
FROM dbo.DimEmployee
ORDER BY LastName;

Õige:

CREATE VIEW vEmployees
AS
SELECT *
FROM dbo.DimEmployee;

SELECT *
FROM vEmployees
ORDER BY LastName;


3. VIEW EI SAA PÕHINEDA TEMP-TABELIL.

Vale:

CREATE VIEW vTempData
AS
SELECT *
FROM #TempTable;


4. KEERULIST VIEW'D EI SAA ALATI UUENDADA.

Probleeme võivad tekitada:
- JOIN;
- GROUP BY;
- DISTINCT;
- UNION;
- arvutatud koondväärtused;
- mitme tabeli korraga muutmine.


5. TAVALINE VIEW EI SALVESTA ANDMEID ISE.

Erand on indekseeritud view, mille tulemus füüsiliselt
indeksisse salvestatakse.
*/


/*--------------------------------------------------------------
  5.9. View info vaatamine
--------------------------------------------------------------*/

EXEC sp_help 'dbo.vEmployeeDOB';

EXEC sp_helptext 'dbo.vEmployeeDOB';

EXEC sp_depends 'dbo.vEmployeeDOB';
GO


/*--------------------------------------------------------------
  5.10. View muutmine
--------------------------------------------------------------*/

/*
View muutmiseks kasutatakse ALTER VIEW või CREATE OR ALTER VIEW.

Näide:

CREATE OR ALTER VIEW dbo.vEmployeeDOB
AS
SELECT
    EmployeeKey,
    FirstName,
    LastName,
    BirthDate,
    Gender
FROM dbo.DimEmployee;
GO
*/


/*--------------------------------------------------------------
  5.11. View kustutamine
--------------------------------------------------------------*/

-- DROP VIEW IF EXISTS dbo.vEmployeeDOB;
-- GO



/*==============================================================
  6. INDEKSEERITUD VIEW
==============================================================*/

/*
Indekseeritud view:

- tavaline view ei salvesta ise andmeid;
- indekseeritud view tulemus salvestatakse indeksisse;
- SQL Serveris nimetatakse seda indexed view'ks;
- Oracle'is kasutatakse nimetust materialized view.

Indekseeritud view põhinõuded:

1. View peab kasutama WITH SCHEMABINDING.
2. Tabelid peavad olema kahesosalise nimega:
   dbo.TableName
3. Esimene indeks peab olema UNIQUE CLUSTERED INDEX.
4. GROUP BY korral peab SELECT sisaldama COUNT_BIG(*).
5. NULL-võimalusega arvutustes kasutatakse tihti ISNULL-i.
6. Vajalikud SET valikud peavad olema õigesti seadistatud.
*/


/*--------------------------------------------------------------
  6.1. Indekseeritud view töötav demo
--------------------------------------------------------------*/

DROP VIEW IF EXISTS dbo.vStudyTotalSalesByProduct;
GO

DROP TABLE IF EXISTS dbo.StudyProductSales;
DROP TABLE IF EXISTS dbo.StudyProduct;
GO

CREATE TABLE dbo.StudyProduct
(
    ProductId int NOT NULL PRIMARY KEY,
    ProductName nvarchar(50) NOT NULL,
    UnitPrice int NOT NULL
);
GO

CREATE TABLE dbo.StudyProductSales
(
    SaleId int NOT NULL PRIMARY KEY,
    ProductId int NOT NULL,
    QuantitySold int NOT NULL,

    CONSTRAINT FK_StudyProductSales_Product
        FOREIGN KEY (ProductId)
        REFERENCES dbo.StudyProduct(ProductId)
);
GO

INSERT INTO dbo.StudyProduct
(
    ProductId,
    ProductName,
    UnitPrice
)
VALUES
    (1, 'Books', 20),
    (2, 'Pens', 14),
    (3, 'Pencils', 11),
    (4, 'Clips', 10);

INSERT INTO dbo.StudyProductSales
(
    SaleId,
    ProductId,
    QuantitySold
)
VALUES
    (1, 1, 10),
    (2, 3, 23),
    (3, 4, 21),
    (4, 2, 12),
    (5, 1, 13),
    (6, 3, 12),
    (7, 4, 13),
    (8, 1, 11),
    (9, 2, 12),
    (10, 1, 14);
GO


/* Vajalikud SET valikud */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
GO


CREATE VIEW dbo.vStudyTotalSalesByProduct
WITH SCHEMABINDING
AS
SELECT
    P.ProductId,
    P.ProductName,
    SUM
    (
        ISNULL
        (
            CONVERT(bigint, S.QuantitySold) *
            CONVERT(bigint, P.UnitPrice),
            0
        )
    ) AS TotalSales,
    COUNT_BIG(*) AS TotalTransactions
FROM dbo.StudyProduct AS P
INNER JOIN dbo.StudyProductSales AS S
    ON P.ProductId = S.ProductId
GROUP BY
    P.ProductId,
    P.ProductName;
GO

-- Indekseeritud view esimene indeks peab olema
-- UNIQUE CLUSTERED INDEX.

CREATE UNIQUE CLUSTERED INDEX
    UIX_vStudyTotalSalesByProduct_ProductId
ON dbo.vStudyTotalSalesByProduct(ProductId);
GO

SELECT *
FROM dbo.vStudyTotalSalesByProduct;

-- NOEXPAND sunnib päringut kasutama indekseeritud view'd.
SELECT *
FROM dbo.vStudyTotalSalesByProduct WITH (NOEXPAND);
GO



/*==============================================================
  7. STORED PROCEDURE, FUNCTION JA VIEW ERINEVUSED
==============================================================*/

/*
STORED PROCEDURE
----------------
Käivitamine:
EXEC dbo.ProcedureName

Võib:
- kasutada sisendparameetreid;
- kasutada OUTPUT-parameetreid;
- kasutada RETURN-koodi;
- lisada, muuta ja kustutada andmeid;
- tagastada mitu tulemustabelit.


SCALAR FUNCTION
---------------
Kasutamine:
SELECT dbo.FunctionName(...)

Tagastab:
- ühe väärtuse.

Näiteks:
- vanus;
- nimi;
- arvutatud hind.


TABLE-VALUED FUNCTION
---------------------
Kasutamine:
SELECT *
FROM dbo.FunctionName(...)

Tagastab:
- tabeli.

Võib võtta vastu parameetreid.


VIEW
----
Kasutamine:
SELECT *
FROM dbo.ViewName

Tagastab:
- salvestatud SELECT-päringu tulemuse.

View:
- ei võta vastu parameetreid;
- lihtsustab päringuid;
- võib peita veerge;
- võib ühendada mitu tabelit.
*/



/*==============================================================
  8. KÕIGE TÄHTSAMAD SÜNTAKSID
==============================================================*/

/*
STORED PROCEDURE:

CREATE OR ALTER PROCEDURE dbo.ProcedureName
    @Parameter andmetüüp
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ...
    FROM ...
    WHERE ColumnName = @Parameter;
END;
GO

EXEC dbo.ProcedureName
    @Parameter = väärtus;


OUTPUT-PARAMEETER:

CREATE OR ALTER PROCEDURE dbo.ProcedureName
    @InputParameter andmetüüp,
    @OutputParameter int OUTPUT
AS
BEGIN
    SELECT @OutputParameter = COUNT(*)
    FROM TableName
    WHERE ColumnName = @InputParameter;
END;
GO


SCALAR FUNCTION:

CREATE OR ALTER FUNCTION dbo.FunctionName
(
    @Parameter andmetüüp
)
RETURNS andmetüüp
AS
BEGIN
    DECLARE @Result andmetüüp;

    SET @Result = ...;

    RETURN @Result;
END;
GO


INLINE TABLE-VALUED FUNCTION:

CREATE OR ALTER FUNCTION dbo.FunctionName
(
    @Parameter andmetüüp
)
RETURNS TABLE
AS
RETURN
(
    SELECT ...
    FROM ...
    WHERE ColumnName = @Parameter
);
GO


MULTI-STATEMENT TABLE-VALUED FUNCTION:

CREATE OR ALTER FUNCTION dbo.FunctionName
(
    @Parameter andmetüüp
)
RETURNS @Result TABLE
(
    Id int,
    Name nvarchar(50)
)
AS
BEGIN
    INSERT INTO @Result
    SELECT Id, Name
    FROM TableName
    WHERE ColumnName = @Parameter;

    RETURN;
END;
GO


LOCAL TEMP TABLE:

CREATE TABLE #TempTable
(
    Id int,
    Name nvarchar(50)
);


GLOBAL TEMP TABLE:

CREATE TABLE ##GlobalTempTable
(
    Id int,
    Name nvarchar(50)
);


INDEX:

CREATE NONCLUSTERED INDEX IX_Table_Column
ON dbo.TableName(ColumnName);


FILTERED INDEX:

CREATE NONCLUSTERED INDEX IX_Table_Filtered
ON dbo.TableName(ColumnName)
WHERE ColumnName = väärtus;


VIEW:

CREATE OR ALTER VIEW dbo.ViewName
AS
SELECT ...
FROM ...;
GO


JOIN VIEW:

CREATE OR ALTER VIEW dbo.ViewName
AS
SELECT
    A.Column1,
    B.Column2
FROM dbo.TableA AS A
JOIN dbo.TableB AS B
    ON A.Id = B.TableAId;
GO
*/



/*==============================================================
  9. LEVINUD VEAD
==============================================================*/

/*
VIGA 1:
CREATE VIEW is not the first statement in a query batch.

LAHENDUS:
Pane enne CREATE VIEW käsku GO.

USE AdventureWorksDW2019;
GO

CREATE VIEW ...


VIGA 2:
There is already an object named ...

LAHENDUS:
Kasuta CREATE OR ALTER või DROP IF EXISTS.


VIGA 3:
Funktsiooni kutsutakse EXEC abil.

VALE:
EXEC dbo.fn_GetAge '2000-01-01';

ÕIGE:
SELECT dbo.fn_GetAge('2000-01-01');


VIGA 4:
Tabelifunktsioonil puudub dbo.

SOOVITATAV:
SELECT *
FROM dbo.fn_EmployeesByGender('F');


VIGA 5:
View's kasutatakse parameetrit.

View ei saa võtta parameetrit.
Kasuta inline table-valued function'it.


VIGA 6:
View sees kasutatakse ORDER BY-d.

Sorteeri view kasutamise ajal:

SELECT *
FROM dbo.vEmployeeDOB
ORDER BY BirthDate;


VIGA 7:
SCHEMABINDING kasutab ainult tabeli nime.

VALE:
FROM DimEmployee

ÕIGE:
FROM dbo.DimEmployee


VIGA 8:
RETURN abil proovitakse tagastada nime.

Stored procedure'i RETURN tagastab int-väärtuse.
Nime jaoks kasuta SELECT-i või OUTPUT-parameetrit.


VIGA 9:
Temp-tabelit ei leita.

Põhjused:
- ühendus suleti;
- temp-tabel loodi teises sessioonis;
- temp-tabel loodi procedure'i sees ja procedure lõpetas töö.


VIGA 10:
Tabelisse proovitakse luua teine clustered index.

Ühes tabelis saab olla ainult üks clustered index.
*/



/*==============================================================
  10. KONTROLLTÖÖ KIIRMELESPEA
==============================================================*/

/*
1. Stored procedure käivitatakse EXEC käsuga.

2. Procedure võib võtta vastu ühe või mitu parameetrit.

3. Parameetreid saab anda:
   - järjekorras;
   - nime järgi.

4. OUTPUT võimaldab procedure'i tulemust väljaspool kasutada.

5. Procedure'i RETURN tagastab ainult int-väärtuse.

6. Scalar function tagastab ühe väärtuse.

7. Inline table-valued function tagastab SELECT-i tabelina.

8. Multi-statement table-valued function loob @Table muutuja.

9. Funktsiooni kasutatakse tavaliselt SELECT-päringus.

10. #TempTable on lokaalne.

11. ##TempTable on globaalne.

12. Temp-tabelid asuvad tempdb andmebaasis.

13. Indeks kiirendab lugemist, kuid võib aeglustada andmete muutmist.

14. Clustered index'eid saab tabelis olla ainult üks.

15. Nonclustered index'eid saab olla mitu.

16. Primary key loob tavaliselt unikaalse clustered index'i.

17. Unique index ei luba väärtustel korduda.

18. Filtered index sisaldab ainult tingimusele vastavaid ridu.

19. View on salvestatud SELECT-päring.

20. View ei saa võtta parameetreid.

21. Parameetriga view asemel kasutatakse tabelifunktsiooni.

22. View sees ei kasutata tavaliselt ORDER BY-d.

23. View ei saa põhineda temp-tabelil.

24. Lihtsa view kaudu võib andmeid muuta.

25. Indekseeritud view vajab:
    - SCHEMABINDING;
    - kahesosalisi tabelinimesid;
    - UNIQUE CLUSTERED INDEX'it;
    - GROUP BY korral COUNT_BIG(*).

26. WITH ENCRYPTION peidab objekti SQL-definitsiooni.

27. WITH SCHEMABINDING seob objekti kasutatavate tabelitega.

28. sp_help näitab objekti infot.

29. sp_helptext näitab objekti SQL-koodi.

30. sp_helpindex näitab tabeli indekseid.