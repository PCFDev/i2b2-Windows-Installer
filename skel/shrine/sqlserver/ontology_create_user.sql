
--ITL modified for MSSQL 2015-04-03

--drop existing login if it exists
IF NOT EXISTS (SELECT name  FROM master.sys.server_principals WHERE name = 'I2B2_DB_SHRINE_ONT_USER')
	BEGIN
	
		--create sql account
		CREATE LOGIN [I2B2_DB_SHRINE_ONT_USER]
		  WITH PASSWORD=N'I2B2_DB_SHRINE_ONT_PASSWORD',
		  DEFAULT_DATABASE=[I2B2_DB_SHRINE_ONT_DATABASE],
		  CHECK_EXPIRATION=OFF,
		  CHECK_POLICY=OFF


		--create user for the database
		CREATE USER [I2B2_DB_SHRINE_ONT_USER]
		  FOR LOGIN [I2B2_DB_SHRINE_ONT_USER]
		  WITH DEFAULT_SCHEMA=[I2B2_DB_SCHEMA]

		--add user to the db_owner role for the database
		EXEC sp_addrolemember 'db_owner', 'I2B2_DB_SHRINE_ONT_USER'

	END
