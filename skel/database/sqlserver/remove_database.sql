use master

IF EXISTS (SELECT name FROM master.sys.databases WHERE name = N'DB_NAME')
  BEGIN
	drop database [DB_NAME];
  END
