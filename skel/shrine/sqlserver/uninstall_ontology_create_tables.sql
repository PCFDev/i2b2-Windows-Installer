IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'I2B2_DB_SCHEMA' AND  TABLE_NAME = 'SHRINE')
BEGIN
   DROP TABLE [I2B2_DB_SCHEMA].[SHRINE]
END
