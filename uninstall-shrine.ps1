<#
.SYNOPSIS
Uninstall tomcat and shrine from a windows server and remove database entries

.DESCRIPTION
This script is used by the main uninstall script to remove Shrine, if the option is selected.
#>

. .\functions.ps1
. .\config-system.ps1
. .\config-i2b2.ps1
. .\config-shrine.ps1

function removeShrine {

    #This will stop and uninstall the Apache Tomcat 8.0 service

    echo "uninstalling Tomcat8 service..."
    
    & "$Env:CATALINA_HOME\bin\service.bat" uninstall Tomcat8

	echo "complete."
	echo "backing up datasource file to backup folder beneath JBOSS directory..."

	mkdir $Env:JBOSS_HOME\backup
	Move-Item $Env:JBOSS_HOME\standalone\deployments\ont-ds.xml $Env:JBOSS_HOME\backup\ont-ds.xml

	echo "backup finished. Moving pre-SHRINE datasource into i2b2 installation..."

	Move-Item $_SHRINE_HOME\Datasource_Backup\ont-ds.xml $Env:JBOSS_HOME\standalone\deployments\ont-ds.xml -Force

	echo "complete."
    echo "removing Shrine and Tomcat files and directories..."

    Remove-Item "c:\opt\shrine" -Force -Recurse

    echo "Shrine and Tomcat have been removed."

}

function removeShrineDatabases {
	
	echo "Beginning Shrine removal from I2B2 DB..."
    echo "updating hive database..."

    $sql = interpolate_file $__skelDirectory\shrine\$DEFAULT_DB_TYPE\uninstall_configure_hive_db_lookups.sql DB_NAME $HIVE_DB_NAME

    execSqlCmd $DEFAULT_DB_SERVER $DEFAULT_DB_TYPE $HIVE_DB_NAME $HIVE_DB_USER $HIVE_DB_PASS $sql
    
	echo "complete."
	echo "updating pm cell database..."

    $sql = interpolate_file $__skelDirectory\shrine\$DEFAULT_DB_TYPE\uninstall_configure_pm.sql DB_NAME $PM_DB_NAME

    execSqlCmd $DEFAULT_DB_SERVER $DEFAULT_DB_TYPE $PM_DB_NAME $PM_DB_USER $PM_DB_PASS $sql
	echo "complete."
	echo "removing tables..."

    $sql = interpolate_file $__skelDirectory\shrine\sqlserver\uninstall_ontology_create_tables.sql DB_NAME $ONT_DB_NAME |
        interpolate I2B2_DB_SCHEMA $DEFAULT_DB_SCHEMA

    execSqlCmd $DEFAULT_DB_SERVER $DEFAULT_DB_TYPE $ONT_DB_NAME $ONT_DB_USER $ONT_DB_PASS $sql

    echo "complete."
    echo "updating table access..."

    #Configure table_access sql template, create sql command, execute
    $sql = interpolate_file $__skelDirectory\shrine\sqlserver\ontology_table_access.sql DB_NAME $ONT_DB_NAME |
        interpolate I2B2_DB_SCHEMA $DEFAULT_DB_SCHEMA

    execSqlCmd $DEFAULT_DB_SERVER $DEFAULT_DB_TYPE $ONT_DB_NAME $ONT_DB_USER $ONT_DB_PASS $sql

    echo "complete."
	echo "removing Shrine DB Admin..."

	removeUser $SHRINE_DB_NAME $SHRINE_DB_USER $SHRINE_DB_PASS $DEFAULT_DB_SCHEMA

	echo "complete."
	echo "removing Shrine Query History database..."

	removeDatabase $SHRINE_DB_NAME

	echo "Finished removing Shrine data. Shrine uninstall complete."

	#TODO remove records from i2b2 tables...	
}

if($RemoveShrine -eq $true){
	removeShrine
	removeShrineDatabases
}
