/* ============================================================
   ANDMEBAASIDE LÕPUTÖÖ NÄIDIS
   Teema: Raamatukogu andmebaas

   Ülesanne:
   Loo andmebaas, kus on autorid, raamatud ja laenutused.
   Tee ERD loogika, loo tabelid, lisa võtmed, sisesta andmed
   ja tee SQL päringud.
   ============================================================ */


/* ============================================================
   1. ERD LOOGIKA
   ============================================================ */

/*
Tabelid:

1. Author
   - Id              PRIMARY KEY
   - FirstName
   - LastName

2. Book
   - Id              PRIMARY KEY
   - Title
   - Genre
   - Price
   - AuthorId        FOREIGN KEY -> Author.Id

3. Customer
   - Id              PRIMARY KEY
   - Name
   - Email
   - City

4. Loan
   - Id              PRIMARY KEY
   - BookId          FOREIGN KEY -> Book.Id
   - CustomerId      FOREIGN KEY -> Customer.Id
   - LoanDate
   - ReturnDate

Seosed:

Author 1 --- mitu Book
Ühel autoril võib olla mitu raamatut.

Book 1 --- mitu Loan
Ühte raamatut võib olla mitu korda laenutatud.

Customer 1 --- mitu Loan
Üks klient võib teha mitu laenutust.

Foreign Key läheb tavaliselt sinna tabelisse,
mis on seoses "mitu" pool.
*/


/* ============================================================
   2. ANDMEBAASI LOOMINE
   ============================================================ */

CREATE DATABASE LibraryFinalDB;
GO

USE LibraryFinalDB;
GO


/* ============================================================
   3. TABELITE LOOMINE
   ============================================================ */

-- Kõigepealt loome tabelid, millele teised viitavad.
-- Author ja Customer ei sõltu teistest tabelitest.

CREATE TABLE Author
(
    Id INT PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL
);
GO


CREATE TABLE Customer
(
    Id INT PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100),
    City NVARCHAR(50)
);
GO


-- Book viitab Author tabelile.
-- Sellepärast peab Author enne olemas olema.

CREATE TABLE Book
(
    Id INT PRIMARY KEY,
    Title NVARCHAR(100) NOT NULL,
    Genre NVARCHAR(50),
    Price DECIMAL(10,2),
    AuthorId INT
);
GO


-- Loan viitab Book ja Customer tabelile.
-- Sellepärast peavad Book ja Customer enne olemas olema.

CREATE TABLE Loan
(
    Id INT PRIMARY KEY,
    BookId INT,
    CustomerId INT,
    LoanDate DATE,
    ReturnDate DATE
);
GO


/* ============================================================
   4. FOREIGN KEY LISAMINE
   ============================================================ */

ALTER TABLE Book
ADD CONSTRAINT FK_Book_Author
FOREIGN KEY (AuthorId) REFERENCES Author(Id);
GO


ALTER TABLE Loan
ADD CONSTRAINT FK_Loan_Book
FOREIGN KEY (BookId) REFERENCES Book(Id);
GO


ALTER TABLE Loan
ADD CONSTRAINT FK_Loan_Customer
FOREIGN KEY (CustomerId) REFERENCES Customer(Id);
GO


/* ============================================================
   5. CHECK JA DEFAULT CONSTRAINT
   ============================================================ */

-- Hind peab olema suurem kui 0.

ALTER TABLE Book
ADD CONSTRAINT CK_Book_Price
CHECK (Price > 0);
GO


-- Kui kliendile linna ei sisestata, siis pannakse vaikimisi 'Unknown'.

ALTER TABLE Customer
ADD CONSTRAINT DF_Customer_City
DEFAULT 'Unknown' FOR City;
GO


/* ============================================================
   6. ANDMETE SISESTAMINE
   ============================================================ */

INSERT INTO Author (Id, FirstName, LastName)
VALUES
(1, 'Jaan', 'Kross'),
(2, 'Andrus', 'Kivirahk'),
(3, 'Anton', 'Tammsaare'),
(4, 'Eduard', 'Vilde');
GO


INSERT INTO Customer (Id, Name, Email, City)
VALUES
(1, 'Mari Maasikas', 'mari@test.com', 'Tallinn'),
(2, 'Juhan Tamm', 'juhan@test.com', 'Tartu'),
(3, 'Kati Kask', 'kati@test.com', 'Pärnu'),
(4, 'Peeter Paju', 'peeter@test.com', 'Tallinn'),
(5, 'Laura Lepp', 'laura@test.com', NULL);
GO


INSERT INTO Book (Id, Title, Genre, Price, AuthorId)
VALUES
(1, 'Keisri hull', 'Romaan', 19.99, 1),
(2, 'Rehepapp', 'Romaan', 15.50, 2),
(3, 'Tõde ja õigus I', 'Klassika', 22.00, 3),
(4, 'Pisuhänd', 'Näidend', 12.99, 4),
(5, 'Mees, kes teadis ussisõnu', 'Fantaasia', 17.75, 2),
(6, 'Kolme katku vahel', 'Ajalooline romaan', 24.90, 1);
GO


INSERT INTO Loan (Id, BookId, CustomerId, LoanDate, ReturnDate)
VALUES
(1, 1, 1, '2026-05-01', '2026-05-15'),
(2, 2, 2, '2026-05-03', '2026-05-17'),
(3, 3, 1, '2026-05-05', NULL),
(4, 5, 3, '2026-05-10', NULL),
(5, 2, 4, '2026-05-12', '2026-05-20'),
(6, 6, 5, '2026-05-15', NULL);
GO


/* ============================================================
   7. TABELITE KONTROLLIMINE
   ============================================================ */

SELECT *
FROM Author;

SELECT *
FROM Customer;

SELECT *
FROM Book;

SELECT *
FROM Loan;


/* ============================================================
   8. LIHTSAD SELECT PÄRINGUD
   ============================================================ */

-- Näita kõiki raamatuid.

SELECT *
FROM Book;


-- Näita ainult raamatu pealkirja ja hinda.

SELECT Title, Price
FROM Book;


-- Näita raamatuid, mille hind on üle 18 euro.

SELECT *
FROM Book
WHERE Price > 18;


-- Näita raamatuid, mille žanr on Romaan.

SELECT *
FROM Book
WHERE Genre = 'Romaan';


-- Näita raamatuid, mille hind on 15 kuni 22 eurot.

SELECT *
FROM Book
WHERE Price BETWEEN 15 AND 22;


-- Näita raamatuid, mille pealkiri algab T-tähega.

SELECT *
FROM Book
WHERE Title LIKE 'T%';


/* ============================================================
   9. ORDER BY JA TOP
   ============================================================ */

-- Raamatud hinna järgi kasvavalt.

SELECT *
FROM Book
ORDER BY Price ASC;


-- Raamatud hinna järgi kahanevalt.

SELECT *
FROM Book
ORDER BY Price DESC;


-- Kolm kõige kallimat raamatut.

SELECT TOP 3 *
FROM Book
ORDER BY Price DESC;


/*
NB!
SQL Serveris kasutatakse TOP, mitte LIMIT.

Vale:
SELECT * FROM Book LIMIT 3;

Õige:
SELECT TOP 3 * FROM Book;
*/


/* ============================================================
   10. INNER JOIN
   ============================================================ */

-- Näita raamatu pealkirja ja autori nime.
-- INNER JOIN näitab ainult need read, kus mõlemas tabelis on vaste olemas.

SELECT 
    B.Title,
    B.Genre,
    B.Price,
    A.FirstName,
    A.LastName
FROM Book B
INNER JOIN Author A
    ON B.AuthorId = A.Id;


/* ============================================================
   11. LEFT JOIN
   ============================================================ */

-- Näita kõik autorid ja nende raamatud.
-- Kui autoril pole raamatuid, siis raamatu kohal oleks NULL.

SELECT 
    A.FirstName,
    A.LastName,
    B.Title
FROM Author A
LEFT JOIN Book B
    ON B.AuthorId = A.Id;


/* ============================================================
   12. MITME TABELI JOIN
   ============================================================ */

-- Näita laenutusi koos kliendi nime ja raamatu pealkirjaga.

SELECT 
    L.Id AS LoanId,
    C.Name AS CustomerName,
    B.Title AS BookTitle,
    L.LoanDate,
    L.ReturnDate
FROM Loan L
INNER JOIN Customer C
    ON L.CustomerId = C.Id
INNER JOIN Book B
    ON L.BookId = B.Id;


/* ============================================================
   13. NULL VÄÄRTUSTE OTSIMINE
   ============================================================ */

-- Näita laenutused, mida pole veel tagastatud.
-- ReturnDate on NULL.

SELECT 
    C.Name AS CustomerName,
    B.Title AS BookTitle,
    L.LoanDate,
    L.ReturnDate
FROM Loan L
INNER JOIN Customer C
    ON L.CustomerId = C.Id
INNER JOIN Book B
    ON L.BookId = B.Id
WHERE L.ReturnDate IS NULL;


/* ============================================================
   14. GROUP BY
   ============================================================ */

-- Mitu raamatut on igal autoril?

SELECT 
    A.FirstName,
    A.LastName,
    COUNT(B.Id) AS BookCount
FROM Author A
LEFT JOIN Book B
    ON B.AuthorId = A.Id
GROUP BY A.FirstName, A.LastName;


-- Mitu klienti on igas linnas?

SELECT 
    City,
    COUNT(*) AS CustomerCount
FROM Customer
GROUP BY City;


-- Raamatute keskmine hind žanri järgi.

SELECT 
    Genre,
    AVG(Price) AS AveragePrice
FROM Book
GROUP BY Genre;


/* ============================================================
   15. HAVING
   ============================================================ */

-- Näita ainult need autorid, kellel on rohkem kui 1 raamat.

SELECT 
    A.FirstName,
    A.LastName,
    COUNT(B.Id) AS BookCount
FROM Author A
LEFT JOIN Book B
    ON B.AuthorId = A.Id
GROUP BY A.FirstName, A.LastName
HAVING COUNT(B.Id) > 1;


-- Näita žanrid, mille keskmine hind on üle 16 euro.

SELECT 
    Genre,
    AVG(Price) AS AveragePrice
FROM Book
GROUP BY Genre
HAVING AVG(Price) > 16;


/*
NB!
WHERE filtreerib ridu enne grupeerimist.
HAVING filtreerib gruppe pärast grupeerimist.

SQL Serveris ära kasuta HAVING sees aliast.

Vale:
HAVING AveragePrice > 16

Õige:
HAVING AVG(Price) > 16
*/


/* ============================================================
   16. AGREGAATFUNKTSIOONID
   ============================================================ */

-- Kõikide raamatute arv.

SELECT COUNT(*) AS TotalBooks
FROM Book;


-- Kõikide raamatute hind kokku.

SELECT SUM(Price) AS TotalPrice
FROM Book;


-- Kõige odavam raamat.

SELECT MIN(Price) AS CheapestBook
FROM Book;


-- Kõige kallim raamat.

SELECT MAX(Price) AS MostExpensiveBook
FROM Book;


-- Keskmine raamatu hind.

SELECT AVG(Price) AS AverageBookPrice
FROM Book;


/* ============================================================
   17. UPDATE
   ============================================================ */

-- Muuda raamatu hinda, mille Id on 2.

UPDATE Book
SET Price = 16.99
WHERE Id = 2;


-- Kontroll.

SELECT *
FROM Book
WHERE Id = 2;


/*
NB!
UPDATE käsul kasuta WHERE tingimust.

Ohtlik:
UPDATE Book
SET Price = 16.99;

See muudaks kõikide raamatute hinna.
*/


/* ============================================================
   18. DELETE
   ============================================================ */

-- Näide kustutamiseks.
-- Kui raamat on Loan tabelis kasutusel, siis ei saa seda kustutada,
-- sest FOREIGN KEY kaitseb andmeid.

-- DELETE FROM Book
-- WHERE Id = 4;


/*
Kui rida on seotud teise tabeliga, siis SQL Server ei luba kustutada,
kui enne seotud ridu ei kustutata.
*/


/* ============================================================
   19. ALTER TABLE MIGRATSIOONI NÄIDE
   ============================================================ */

-- Lisa Book tabelisse uus veerg.

ALTER TABLE Book
ADD PublishedYear INT;
GO


-- Lisa kontroll, et aasta oleks loogiline.

ALTER TABLE Book
ADD CONSTRAINT CK_Book_PublishedYear
CHECK (PublishedYear > 1500 AND PublishedYear <= 2026);
GO


-- Uuenda andmeid.

UPDATE Book
SET PublishedYear = 1978
WHERE Id = 1;

UPDATE Book
SET PublishedYear = 2000
WHERE Id = 2;

UPDATE Book
SET PublishedYear = 1926
WHERE Id = 3;

UPDATE Book
SET PublishedYear = 1913
WHERE Id = 4;

UPDATE Book
SET PublishedYear = 2007
WHERE Id = 5;

UPDATE Book
SET PublishedYear = 1970
WHERE Id = 6;


-- Kontroll.

SELECT *
FROM Book;


/* ============================================================
   20. LÕPU PÄRINGUD, MIS VÕIKSID KT-S OLLA
   ============================================================ */

-- 1. Näita kõik raamatud koos autoriga.

SELECT 
    B.Title,
    A.FirstName + ' ' + A.LastName AS AuthorName,
    B.Genre,
    B.Price
FROM Book B
JOIN Author A
    ON B.AuthorId = A.Id;


-- 2. Näita kõik laenutused koos kliendi ja raamatu nimega.

SELECT 
    C.Name AS CustomerName,
    B.Title AS BookTitle,
    L.LoanDate,
    L.ReturnDate
FROM Loan L
JOIN Customer C
    ON L.CustomerId = C.Id
JOIN Book B
    ON L.BookId = B.Id;


-- 3. Näita ainult tagastamata raamatud.

SELECT 
    C.Name AS CustomerName,
    B.Title AS BookTitle,
    L.LoanDate
FROM Loan L
JOIN Customer C
    ON L.CustomerId = C.Id
JOIN Book B
    ON L.BookId = B.Id
WHERE L.ReturnDate IS NULL;


-- 4. Näita mitu raamatut on igal autoril.

SELECT 
    A.FirstName + ' ' + A.LastName AS AuthorName,
    COUNT(B.Id) AS BookCount
FROM Author A
LEFT JOIN Book B
    ON B.AuthorId = A.Id
GROUP BY A.FirstName, A.LastName;


-- 5. Näita ainult autorid, kellel on rohkem kui 1 raamat.

SELECT 
    A.FirstName + ' ' + A.LastName AS AuthorName,
    COUNT(B.Id) AS BookCount
FROM Author A
LEFT JOIN Book B
    ON B.AuthorId = A.Id
GROUP BY A.FirstName, A.LastName
HAVING COUNT(B.Id) > 1;


-- 6. Näita 3 kõige kallimat raamatut.

SELECT TOP 3
    Title,
    Price
FROM Book
ORDER BY Price DESC;


-- 7. Näita raamatute keskmine hind žanri järgi.

SELECT 
    Genre,
    AVG(Price) AS AveragePrice
FROM Book
GROUP BY Genre;


-- 8. Näita ainult need žanrid, mille keskmine hind on üle 16 euro.

SELECT 
    Genre,
    AVG(Price) AS AveragePrice
FROM Book
GROUP BY Genre
HAVING AVG(Price) > 16;


-- 9. Näita klientide arv linna järgi.

SELECT 
    City,
    COUNT(*) AS CustomerCount
FROM Customer
GROUP BY City;


-- 10. Näita laenutuste arv iga kliendi kohta.

SELECT 
    C.Name,
    COUNT(L.Id) AS LoanCount
FROM Customer C
LEFT JOIN Loan L
    ON L.CustomerId = C.Id
GROUP BY C.Name;


/* ============================================================
   21. KOKKUVÕTE
   ============================================================ */

/*
Sellises KT/lõputöö näites tegid ära:

1. ERD loogika
2. Andmebaasi loomise
3. Tabelite loomise
4. Primary Key kasutamise
5. Foreign Key kasutamise
6. Constraintide lisamise
7. Andmete sisestamise
8. Migratsiooni ALTER TABLE abil
9. SELECT päringud
10. WHERE tingimused
11. JOIN päringud
12. GROUP BY päringud
13. HAVING päringud
14. TOP ja ORDER BY
15. UPDATE näite
16. DELETE loogika

Kõige tähtsam:
- Parent tabel tuleb enne child tabelit.
- Foreign key läheb tavaliselt "mitu" poole tabelisse.
- UPDATE ja DELETE juures kasuta WHERE.
- SQL Serveris kasuta TOP, mitte LIMIT.
- NULL-i kontrolli IS NULL abil.
*/