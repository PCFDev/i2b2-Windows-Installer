IF NOT EXISTS (SELECT name  FROM master.sys.syslogins WHERE name = 'DB_USER')
	BEGIN
		CREATE LOGIN [DB_USER]
			WITH PASSWORD=N'DB_PASS',
			DEFAULT_DATABASE=[DB_NAME],
			CHECK_EXPIRATION=OFF,
			CHECK_POLICY=OFF;	
	END

USE [DB_NAME];
		
IF NOT EXISTS (SELECT name  FROM DB_NAME.sys.database_principals WHERE name = 'DB_USER')
	BEGIN
		
		CREATE USER [DB_USER]
		  FOR LOGIN [DB_USER]
		  WITH DEFAULT_SCHEMA=[DB_SCHEMA];
		
		
	END
	
if not  exists(select rp.name as database_role, mp.name as database_user
		from DB_NAME.sys.database_role_members drm
		join DB_NAME.sys.database_principals rp on (drm.role_principal_id = rp.principal_id)
		join DB_NAME.sys.database_principals mp on (drm.member_principal_id = mp.principal_id)
		where rp.name = 'db_owner' and mp.name = 'DB_USER')

	begin

			EXEC sp_addrolemember 'db_owner', 'DB_USER';

	end