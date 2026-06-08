CREATE DATABASE GamesDb;
GO

USE GamesDb;
GO

CREATE TABLE Games (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Genre NVARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Rating DECIMAL(3,1) NOT NULL
);
GO

INSERT INTO Games (Name, Genre, Price, Rating)
VALUES 
('Minecraft', 'Sandbox', 29.99, 9.5),
('GTA V', 'Action', 19.99, 9.0),
('FIFA 24', 'Sports', 59.99, 8.2);
GO

SELECT * FROM Games;

USE GamesDb;
GO

SELECT * FROM Games;