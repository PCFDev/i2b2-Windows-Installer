<#
.AUTHOR
Josh Hahn
Pediatrics Development Team
Washington University in St. Louis

.DATE
April 14, 2015
#>
<#
.SYNOPSIS
Install tomcat 8 and shrine on Windows Server


.DESCRIPTION
This script will download the correct version of Apache Tomcat 8.0. It will then unzip to 
another directory and copy the contents into the shrine\tomcat directory beneath the 
default directory. It will also install Tomcat 8.0 as a service running automatically.
#>

. .\functions.ps1
. .\config-system.ps1
. .\config-i2b2.ps1
. .\config-shrine.ps1

function prepareInstall(){

    report "Preparing for installation..."     
    report "creating temporary Shrine setup locations..."    
    
    #Create temp setup folder
    if(!(Test-Path $__tempFolder\shrine\setup)){
        mkdir $__tempFolder\shrine\setup
    }
    
    #Create temp folder for completed files
    if(!(Test-Path $__tempFolder\shrine\ready)){
        mkdir $__tempFolder\shrine\ready
    }
    report "Shrine setup locations created."

    report "installing Subversion"
    #Download and install Subversion
    $SVNUrl = "http://downloads.sourceforge.net/project/win32svn/1.8.11/apache22/svn-win32-1.8.11.zip?"
    Invoke-WebRequest  $SVNUrl -OutFile $__tempFolder\shrine\setup\subversion.zip -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer
    unzip $__tempFolder\shrine\setup\subversion.zip $__tempFolder\shrine\setup\svn
    report "Subversion is installed. Moving on..."

    report "Finished preparing."
}

function installShrine{

    #Creating URLs for downloading source files

    $ShrineQuickInstallUrl = "$_SHRINE_SVN_URL_BASE/code/install/i2b2-1.7/"

    $ShrineWar = "shrine-war-$_SHRINE_VERSION.war"
    $ShrineWarURL = "$_NEXUS_URL_BASE/shrine-war/$_SHRINE_VERSION/$ShrineWar"

    $ShrineProxy = "shrine-proxy-$_SHRINE_VERSION.war"
    $ShrineProxyURL = "$_NEXUS_URL_BASE/shrine-proxy/$_SHRINE_VERSION/$ShrineProxy"

    $ShrineAdapterMappingsURL = "$_SHRINE_SVN_URL_BASE/ontology/SHRINE_Demo_Downloads/AdapterMappings_i2b2_DemoData.xml"
    
    report "getting source files..."
    report "downloading shrine and shrine-proxy war files..."
    
    #Download shrine.war and shrine-proxy.war to tomcat
    Invoke-WebRequest $ShrineWarURL  -OutFile $__tempFolder\shrine\setup\shrine.war
    Invoke-WebRequest $ShrineProxyURL  -OutFile $__tempFolder\shrine\setup\shrine-proxy.war
    
    report "shrine and shrine-proxy war files downloaded."
    report "downloading shrine-webclient to tomcat..."
    
    #run to copy shrine-webclient to webapps folder in tomcat
    & "$__tempFolder\shrine\setup\svn\svn-win32-1.8.11\bin\svn.exe" checkout $_SHRINE_SVN_URL_BASE/code/shrine-webclient/  $__tempFolder\shrine\setup\shrine-webclient > $null

    report "shrine-webclient downloaded."
    report "downloading AdapterMappings.xml file to tomcat..."
   
    Invoke-WebRequest $ShrineAdapterMappingsURL  -OutFile $__tempFolder\shrine\setup\AdapterMappings.xml

    report "AdapterMappings.xml downloaded."
    report "Configuring tomcat server settings..."

    #Interpolate tomcat_server_8.xml with common settings
    interpolate_file $__skelDirectory\shrine\tomcat\tomcat_server_8.xml SHRINE_PORT $_SHRINE_PORT |
        interpolate SHRINE_SSL_PORT $_SHRINE_SSL_PORT | 
        interpolate KEYSTORE_FILE "$_SHRINE_HOME\shrine.keystore" |
        interpolate KEYSTORE_PASSWORD "changeit" | Out-File -Encoding utf8 $__tempFolder\shrine\ready\server.xml

    report "complete."
    report "Configuring Shrine cell files..."

    #Interpolate cell_config_data.js with common settings
    interpolate_file $__skelDirectory\shrine\tomcat\cell_config_data.js SHRINE_IP $_SHRINE_IP |
        interpolate SHRINE_SSL_PORT $_SHRINE_SSL_PORT > $__tempFolder\shrine\ready\cell_config_data.js

    #Interpolate shrine.xml with common settings
    interpolate_file $__skelDirectory\shrine\tomcat\shrine.xml SHRINE_SQL_USER $SHRINE_DB_USER |
        interpolate SHRINE_SQL_PASSWORD $SHRINE_DB_PASS |
        interpolate SHRINE_SQL_SERVER $_SHRINE_MSSQL_SERVER |
        interpolate databaseName= "instanceName=sqlexpress;" |
		interpolate SHRINE_SQL_DB "databaseName=shrine_query_history" > $__tempFolder\shrine\ready\shrine.xml

    #Interpolate i2b2_config_data.js with common settings
    interpolate_file $__skelDirectory\shrine\tomcat\i2b2_config_data.js I2B2_PM_IP $_I2B2_PM_IP |
        interpolate SHRINE_NODE_NAME $_SHRINE_NODE_NAME |
        interpolate I2B2_DOMAIN_ID $I2B2_DOMAIN > $__tempFolder\shrine\ready\i2b2_config_data.js

    #Interpolate shrine.conf with common settings
    interpolate_file $__skelDirectory\shrine\tomcat\shrine.conf I2B2_PM_IP $_I2B2_PM_IP | 
		interpolate I2B2_ONT_IP $_I2B2_ONT_IP |
        interpolate SHRINE_ADAPTER_I2B2_DOMAIN $I2B2_DOMAIN |
        interpolate SHRINE_ADAPTER_I2B2_USER $_SHRINE_ADAPTER_I2B2_USER | 
        interpolate SHRINE_ADAPTER_I2B2_PASSWORD $_SHRINE_ADAPTER_I2B2_PASSWORD |
        interpolate SHRINE_ADAPTER_I2B2_PROJECT $_SHRINE_ADAPTER_I2B2_PROJECT |
        interpolate I2B2_CRC_IP $_I2B2_CRC_IP | 
		interpolate SHRINE_NODE_NAME $_SHRINE_NODE_NAME |
        interpolate KEYSTORE_FILE (escape $_KEYSTORE_FILE) | 
		interpolate KEYSTORE_PASSWORD $_KEYSTORE_PASSWORD |
        interpolate KEYSTORE_ALIAS $_KEYSTORE_ALIAS > $__tempFolder\shrine\ready\shrine.conf

    report "complete."
    report "moving configured files to tomcat installation..."

    #Copy relevant files to proper locations
    mkdir $_SHRINE_TOMCAT_HOME\webapps\shrine-webclient
    Copy-Item $__tempFolder\shrine\setup\shrine-webclient\* -Destination $_SHRINE_TOMCAT_HOME\webapps\shrine-webclient -Container -Recurse
    Copy-Item $__tempFolder\shrine\ready\server.xml $_SHRINE_TOMCAT_SERVER_CONF
    Copy-Item $__tempFolder\shrine\ready\shrine.xml $_SHRINE_TOMCAT_APP_CONF
    Copy-Item $__tempFolder\shrine\ready\shrine.conf $_SHRINE_CONF_FILE
    Copy-Item $__tempFolder\shrine\ready\cell_config_data.js $_SHRINE_TOMCAT_HOME\webapps\shrine-webclient\js-i2b2\cells\SHRINE\cell_config_data.js
    Copy-Item $__tempFolder\shrine\ready\i2b2_config_data.js $_SHRINE_TOMCAT_HOME\webapps\shrine-webclient\i2b2_config_data.js
    Copy-Item $__tempFolder\shrine\setup\shrine.war $_SHRINE_TOMCAT_HOME\webapps\shrine.war
    Copy-Item $__tempFolder\shrine\setup\shrine-proxy.war $_SHRINE_TOMCAT_HOME\webapps\shrine-proxy.war
    Copy-Item $__tempFolder\shrine\setup\AdapterMappings.xml $_SHRINE_TOMCAT_LIB
    Copy-Item $__skelDirectory\shrine\sqlserver\sqljdbc4.jar $_SHRINE_TOMCAT_LIB\sqljdbc4.jar

    report "move complete."
    report "restarting Tomcat Service (if installed)..."

    Restart-Service Tomcat8
    }


function createCert{

    #This function will generate a keypair and a keystore according to the settings in common.ps1
    #It will export the created certificate to the $_SHRINE_HOME location

    report "Generating Shrine keystore and SSL certificate..."

    & "$Env:JAVA_HOME\bin\keytool.exe" -genkeypair -keysize 2048 -alias $_KEYSTORE_ALIAS -dname "CN=$_KEYSTORE_ALIAS, OU=$_KEYSTORE_HUMAN, O=SHRINE Network, L=$_KEYSTORE_CITY, S=$_KEYSTORE_STATE, C=$_KEYSTORE_COUNTRY" -keyalg RSA -keypass $_KEYSTORE_PASSWORD -storepass $_KEYSTORE_PASSWORD -keystore $_KEYSTORE_FILE -validity 7300
    & "$Env:JAVA_HOME\bin\keytool.exe" -noprompt -export -alias $_KEYSTORE_ALIAS -keystore $_KEYSTORE_FILE -storepass $_KEYSTORE_PASSWORD -file "$_SHRINE_HOME\$_KEYSTORE_ALIAS.cer"

    report "complete."
}


function createShrineDB{

    report "Creating Shrine Database..."

    createDatabase $SHRINE_DB_NAME

    report "Shrine Database created."
    report "Creating Shrine DB user..."

    createUser $SHRINE_DB_NAME $SHRINE_DB_USER $SHRINE_DB_PASS $DEFAULT_DB_SCHEMA

    report "Shrine DB User created."
}


function updateDatasources{

    report "Updating Ontology datasources..."
    report "creating backup of datasource files..."

    #making backup of datasource file
    mkdir $_SHRINE_HOME\Datasource_Backup
    Copy-Item $env:JBOSS_HOME\standalone\deployments\ont-ds.xml $_SHRINE_HOME\Datasource_Backup\ont-ds.xml

    report "datasource files backed up to $SHRINE_HOME\Datasource_Backup folder."
    report "configuring new ontology datasource file..."

    #configuring template to replace current ont-ds.xml
    interpolate_file $__skelDirectory\shrine\sqlserver\ont-ds.xml I2B2_DB_HIVE_DATASOURCE_NAME "OntologyBootStrapDS" |
        interpolate I2B2_DB_HIVE_JDBC_URL $HIVE_DB_URL |
        interpolate I2B2_DB_HIVE_USER $HIVE_DB_USER |
        interpolate I2B2_DB_HIVE_PASSWORD $HIVE_DB_PASS |
        interpolate I2B2_DB_ONT_DATASOURCE_NAME $ONT_DB_DATASOURCE |
        interpolate I2B2_DB_ONT_JDBC_URL $ONT_DB_URL |
        interpolate I2B2_DB_ONT_USER $ONT_DB_USER |
        interpolate I2B2_DB_ONT_PASSWORD $ONT_DB_PASS |
        interpolate I2B2_DB_SHRINE_ONT_DATASOURCE_NAME $SHRINE_DB_DATASOURCE |
        interpolate I2B2_DB_SHRINE_ONT_JDBC_URL $SHRINE_DB_URL |
        interpolate I2B2_DB_SHRINE_ONT_USER $ONT_DB_USER |
        interpolate I2B2_DB_SHRINE_ONT_PASSWORD $SHRINE_DB_PASS | sc $env:JBOSS_HOME\standalone\deployments\ont-ds.xml -Force

        report "complete."
        report "Ontology datasource update complete."

}

function updateDB{
    
    report "Beginning Shrine updates to I2B2 DB..."
    report "updating hive database..."

    $sql = interpolate_file $__skelDirectory\shrine\$DEFAULT_DB_TYPE\configure_hive_db_lookups.sql DB_NAME $HIVE_DB_NAME |
        interpolate I2B2_DOMAIN_ID $I2B2_DOMAIN |
        interpolate SHRINE $SHRINE_DB_PROJECT |
        interpolate I2B2_DB_SHRINE_ONT_DATABASE.I2B2_DB_SCHEMA $SHRINE_DB_SCHEMA |
        interpolate I2B2_DB_SHRINE_ONT_DATASOURCE_NAME $SHRINE_DB_DATASOURCE |
        interpolate SQLSERVER $DEFAULT_DB_TYPE.ToUpper() |
        interpolate I2B2_DB_CRC_DATABASE.I2B2_DB_SCHEMA $CRC_DB_SCHEMA |
        interpolate I2B2_DB_CRC_DATASOURCE_NAME $CRC_DB_DATASOURCE

    execSqlCmd $DEFAULT_DB_SERVER $DEFAULT_DB_TYPE $HIVE_DB_NAME $HIVE_DB_USER $HIVE_DB_PASS $sql
    report "complete."
	
    report "updating pm cell database..."
    $sql = interpolate_file $__skelDirectory\shrine\sqlserver\configure_pm.sql DB_NAME $PM_DB_NAME |
        interpolate SHRINE_USER $SHRINE_DB_USER |
        interpolate SHRINE_PASSWORD_CRYPTED (hash $SHRINE_DB_PASS) |
        interpolate SHRINE $SHRINE_DB_PROJECT |
        interpolate SHRINE_IP $_SHRINE_IP |
        interpolate SHRINE_SSL_PORT $_SHRINE_SSL_PORT

    execSqlCmd $DEFAULT_DB_SERVER $DEFAULT_DB_TYPE $PM_DB_NAME $PM_DB_USER $PM_DB_PASS $sql
	report "complete."
    
  
    report "Executing Shrine adapter.sql"
    $sql = interpolate_file $__skelDirectory\shrine\sqlserver\adapter.sql DB_NAME $SHRINE_DB_NAME 
    execSqlCmd $DEFAULT_DB_SERVER $DEFAULT_DB_TYPE $SHRINE_DB_NAME $SHRINE_DB_USER $SHRINE_DB_PASS $sql
    report "complete"


    report "Executing Shrine hub.sql"    
    $sql = interpolate_file $__skelDirectory\shrine\sqlserver\hub.sql DB_NAME $SHRINE_DB_NAME 
    execSqlCmd $DEFAULT_DB_SERVER $DEFAULT_DB_TYPE $SHRINE_DB_NAME $SHRINE_DB_USER $SHRINE_DB_PASS $sql    
    report "complete."
	
	report "Executing Shrine create_broadcaster_audit_table.sql"   
    $sql = interpolate_file $__skelDirectory\shrine\sqlserver\create_broadcaster_audit_table.sql DB_NAME $SHRINE_DB_NAME    
    execSqlCmd $DEFAULT_DB_SERVER $DEFAULT_DB_TYPE $SHRINE_DB_NAME $SHRINE_DB_USER $SHRINE_DB_PASS $sql        
    report "complete"
	
    report "updating ontology records..." 

    #Now using ontConn for ontology edits

    #Create URL for sql downloads
    $SHRINE_SQL_FILE_URL_SUFFIX = "SHRINE_Demo_Downloads/ShrineDemo.sql"
    $SHRINE_SQL_FILE_URL = "$_SHRINE_SVN_URL_BASE/ontology/$SHRINE_SQL_FILE_URL_SUFFIX"
    $ADAPTER_SQL_FILE_URL = "$_SHRINE_SVN_URL_BASE/code/adapter/src/main/resources/adapter.sql"
    $HUB_SQL_FILE_URL = "$_SHRINE_SVN_URL_BASE/code/broadcaster-aggregator/src/main/resources/hub.sql"
    $AUDIT_TABLE_SQL_FILE_URL = "$_SHRINE_SVN_URL_BASE/code/service/src/main/resources/create_broadcaster_audit_table.sql"

    report "creating tables..."

    #Configure create_tables sql template, create sql command, execute
    $sql = interpolate_file $__skelDirectory\shrine\sqlserver\ontology_create_tables.sql DB_NAME $ONT_DB_NAME |
        interpolate I2B2_DB_SCHEMA $DEFAULT_DB_SCHEMA

    execSqlCmd $DEFAULT_DB_SERVER $DEFAULT_DB_TYPE $ONT_DB_NAME $ONT_DB_USER $ONT_DB_PASS $sql

    report "complete."
    report "updating table access..."

    #Configure table_access sql template, create sql command, execute
    $sql = interpolate_file $__skelDirectory\shrine\sqlserver\ontology_table_access.sql DB_NAME $ONT_DB_NAME |
        interpolate I2B2_DB_SCHEMA $DEFAULT_DB_SCHEMA

    execSqlCmd $DEFAULT_DB_SERVER $DEFAULT_DB_TYPE $ONT_DB_NAME $ONT_DB_USER $ONT_DB_PASS $sql

    report "complete."
    report "downloading and running Shrine Ontology..."

    #Download sql files
    Invoke-WebRequest $SHRINE_SQL_FILE_URL -OutFile $__skelDirectory\shrine\sqlserver\shrine.sql

    $sql = Get-Content "$__skelDirectory\shrine\sqlserver\shrine.sql"

    #Must set CommandTimeout due to size of shrine.sql
    execSqlCmd $DEFAULT_DB_SERVER $DEFAULT_DB_TYPE $ONT_DB_NAME $ONT_DB_USER $ONT_DB_PASS $sql


    report "Shrine Ontology added."
    report "ontology records updated."
    report "cleaning up ontology files..."

    Remove-Item $__skelDirectory\shrine\sqlserver\shrine.sql

    report "complete."

    report "i2b2 Database Tables updated."
}

prepareInstall

report "Beginning Shrine client install..."
createCert
installShrine
report "Shrine client installation complete!"

report "Starting Shrine Data Installation..."
createShrineDB
updateDB
updateDatasources
report "Shrine Data Installation complete!"
