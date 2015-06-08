﻿#JBOSS Configuration
$JBOSS_ADDRESS = "0.0.0.0"
$JBOSS_PORT = "9090"
$JBOSS_ADMIN = "jbossAdmin"
$JBOSS_PASS = "jbossP@ss"

#i2b2 domain config
$I2B2_DOMAIN="i2b2demo"
$I2B2_HIVE_NAME="Local Demo"
$I2B2_PROJECT_NAME="demo"

#Location of the i2b2 web services
$DEFAULT_I2B2_SERVER = "localhost"
$DEFAULT_I2B2_SERVICE_URL="http://" + $DEFAULT_I2B2_SERVER + ":9090/i2b2/services"
$PM_SERVICE_URL="$DEFAULT_I2B2_SERVICE_URL/PMService"
$CRC_SERVICE_URL="$DEFAULT_I2B2_SERVICE_URL/QueryToolService"
$FR_SERVICE_URL="$DEFAULT_I2B2_SERVICE_URL/FRService"
$ONT_SERVICE_URL="$DEFAULT_I2B2_SERVICE_URL/OntologyService"

#Service account used by i2b2 software
$I2B2_SERVICEACCOUNT_USER="AGG_SERVICE_ACCOUNT"
$I2B2_SERVICEACCOUNT_PASS="demouser"

#Database configuration
$DEFAULT_DB_SERVER="localhost:1433;instanceName=sqlexpress"

#THESE ARE USED TO CREATE DATABASES, NEEDS TO HAVE ADMIN ACCESS TO DB SERVER
$DEFAULT_DB_ADMIN_USER="admin" #<== THIS IS NOT SET
$DEFAULT_DB_ADMIN_PASS="password" #<== THIS IS NOT SET

$DEFAULT_DB_URL="jdbc:sqlserver://" + $DEFAULT_DB_SERVER  #If NOT using SQLEXPRESS need to include the port number: + ":1433"
$DEFAULT_DB_DRIVER="com.microsoft.sqlserver.jdbc.SQLServerDriver"
$DEFAULT_DB_JAR_FILE="sqljdbc4.jar"
$DEFAULT_DB_TYPE="SQLServer"



$DEFAULT_DB_PASS="demouser"
$DEFAULT_DB_SCHEMA="dbo"

#Cell configuration
$HIVE_DB_NAME="i2b2hive"
$HIVE_DB_DRIVER=$DEFAULT_DB_DRIVER
$HIVE_DB_JAR_FILE=$DEFAULT_DB_JAR_FILE
$HIVE_DB_URL=$DEFAULT_DB_URL
$HIVE_DB_SCHEMA="$HIVE_DB_NAME.$DEFAULT_DB_SCHEMA"
$HIVE_DB_USER=$HIVE_DB_NAME
$HIVE_DB_PASS=$DEFAULT_DB_PASS

$PM_DB_NAME="i2b2pm"
$PM_DB_DRIVER=$DEFAULT_DB_DRIVER
$PM_DB_JAR_FILE=$DEFAULT_DB_JAR_FILE
$PM_DB_URL=$DEFAULT_DB_URL
$PM_DB_SCHEMA="$PM_DB_NAME.$DEFAULT_DB_SCHEMA"
$PM_DB_USER=$PM_DB_NAME
$PM_DB_PASS=$DEFAULT_DB_PASS

$ONT_DB_NAME="i2b2metadata"
$ONT_DB_DRIVER=$DEFAULT_DB_DRIVER
$ONT_DB_JAR_FILE=$DEFAULT_DB_JAR_FILE
$ONT_DB_URL=$DEFAULT_DB_URL
$ONT_DB_SCHEMA="$ONT_DB_NAME.$DEFAULT_DB_SCHEMA"
$ONT_DB_USER=$ONT_DB_NAME
$ONT_DB_PASS=$DEFAULT_DB_PASS
$ONT_DB_DATASOURCE="OntologyDemoDS"

$CRC_DB_NAME="i2b2demodata"
$CRC_DB_DRIVER=$DEFAULT_DB_DRIVER
$CRC_DB_JAR_FILE=$DEFAULT_DB_JAR_FILE
$CRC_DB_URL=$DEFAULT_DB_URL
$CRC_DB_SCHEMA="$CRC_DB_NAME.$DEFAULT_DB_SCHEMA"
$CRC_DB_USER=$CRC_DB_NAME
$CRC_DB_PASS=$DEFAULT_DB_PASS
$CRC_DB_DATASOURCE="QueryToolDS"

$WORK_DB_NAME="i2b2workdata"
$WORK_DB_DRIVER=$DEFAULT_DB_DRIVER
$WORK_DB_JAR_FILE=$DEFAULT_DB_JAR_FILE
$WORK_DB_URL=$DEFAULT_DB_URL
$WORK_DB_SCHEMA="$WORK_DB_NAME.$DEFAULT_DB_SCHEMA"
$WORK_DB_USER=$WORK_DB_NAME
$WORK_DB_PASS=$DEFAULT_DB_PASS

$IM_DB_NAME="i2b2imdata"
$IM_DB_DRIVER=$DEFAULT_DB_DRIVER
$IM_DB_JAR_FILE=$DEFAULT_DB_JAR_FILE
$IM_DB_URL=$DEFAULT_DB_URL
$IM_DB_SCHEMA="$IM_DB_NAME.$DEFAULT_DB_SCHEMA"
$IM_DB_USER=$IM_DB_NAME
$IM_DB_PASS=$DEFAULT_DB_PASS

#Shrine Cell Configuration
$SHRINE_DB_NAME="shrine_query_history"
$SHRINE_DB_DRIVER=$DEFAULT_DB_DRIVER
$SHRINE_DB_JAR_FILE=$DEFAULT_DB_JAR_FILE
$SHRINE_DB_URL=$DEFAULT_DB_URL
$SHRINE_DB_SCHEMA="$SHRINE_DB_NAME.$DEFAULT_DB_SCHEMA"
$SHRINE_DB_USER="shrine"
$SHRINE_DB_PASS=$DEFAULT_DB_PASS
$SHRINE_DB_PROJECT="SHRINE"
$SHRINE_DB_DATASOURCE="ShrineOntologyDS"
$SHRINE_DB_NICENAME="Shrine"
