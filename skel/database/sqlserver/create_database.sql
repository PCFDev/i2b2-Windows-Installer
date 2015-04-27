use [master]

IF NOT EXISTS (SELECT name FROM master.sys.databases WHERE name = N'DB_NAME')
  BEGIN
	create database [DB_NAME];
  END