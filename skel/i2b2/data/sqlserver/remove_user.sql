USE [DB_NAME];		
IF NOT EXISTS (SELECT name  FROM DB_NAME.sys.database_principals WHERE name = 'DB_USER')
	BEGIN		
		DROP USER [DB_USER];			
	END

USE [master];
IF EXISTS (SELECT name  FROM master.sys.syslogins WHERE name = 'DB_USER')
	BEGIN
		DROP LOGIN [DB_USER];	
	END

