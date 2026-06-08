CREATE DATABASE ExampleDB;
GO

ALTER DATABASE ExampleDB
SET RECOVERY FULL;
GO

BACKUP DATABASE ExampleDB
TO DISK = 'C:\Backup\ExampleDB.bak'
WITH FORMAT;
GO

BACKUP DATABASE ExampleDB
TO DISK = 'C:\Backup\ExampleDB_Backup.bak'
WITH FORMAT,
NAME = 'ExampleDB backup';
GO

BACKUP DATABASE ExampleDB
TO DISK = 'C:\Backup\ExampleDB_Format.bak'
WITH FORMAT,
MEDIANAME = 'ExampleDBBackup',
NAME = 'FORMAT backup',
DESCRIPTION = 'Full backup of ExampleDB';
GO

CREATE DATABASE TestDB;
GO

ALTER DATABASE TestDB
SET RECOVERY FULL;
GO

SELECT name, recovery_model_desc
FROM sys.databases
WHERE name = 'TestDB';
GO