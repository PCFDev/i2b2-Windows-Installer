<#
.SYNOPSIS
Upgrade existing instance of i2b2 on a windows server

.DESCRIPTION
This script will backup the current deployments and websites, then upgrade the database, cells and websites to version 1.7.06.

#>

. .\functions.ps1
. .\config-system.ps1
. .\config-i2b2.ps1


$_i2b2Version = "1706"
$_release = "Release_1-7"
$_upgradeDirectory = (Get-Item -Path ".\" -Verbose).Parent.FullName

$_sourceDirectory = $_upgradeDirectory + "\i2b2core-src-" + $_i2b2Version
$_dataDirectory = $_upgradeDirectory + "\i2b2createdb-" + $_i2b2Version + "\edu.harvard.i2b2.data\" + $_release + "\Upgrade"
$_webDirectory = $_upgradeDirectory + "\i2b2webclient-" + $_i2b2Version

$_crcDataFolder = $_dataDirectory + "\Crcdata"
$_hiveDataFolder = $_dataDirectory + "\Hivedata"
$_metaDataFolder = $_dataDirectory + "\Metadata"
$_pmDataFolder = $_dataDirectory + "\Pmdata"

$_pmSourceFolder = $_sourceDirectory + "\edu.harvard.i2b2.pm"
$_ontSourceFolder = $_sourceDirectory + "\edu.harvard.i2b2.ontology"
$_crcSourceFolder = $_sourceDirectory + "\edu.harvard.i2b2.crc"
$_workSourceFolder = $_sourceDirectory + "\edu.harvard.i2b2.workplace"
$_frSourceFolder = $_sourceDirectory + "\edu.harvard.i2b2.fr"
$_imSourceFolder = $_sourceDirectory + "\edu.harvard.i2b2.im"

#Create backup directory and back up deployments and websites to it
function backupDeployment{

    New-Item $_upgradeDirectory\backup -ItemType directory
    Copy-Item $__jbossInstallFolder\standalone\deployments -destination $_upgradeDirectory\backup -Recurse
    Copy-Item C:\inetpub\wwwroot\webclient -Destination $_upgradeDirectory\backup -Recurse
    Copy-Item C:\inetpub\wwwroot\admin -Destination $_upgradeDirectory\backup -Recurse

}

#upgade CRC database fields to 1.7.06
function upgradeCrcData{

    Copy-Item $__currentDirectory\skel\i2b2\upgrade\db.properties -destination $_crcDataFolder -Force
    Copy-Item $__currentDirectory\skel\i2b2\upgrade\crc_create_query_sqlserver.sql -Destination $_crcDataFolder\scripts -Force
    
    interpolate_file $_crcDataFolder\db.properties DB_TYPE $DEFAULT_DB_TYPE |
        interpolate DB_USER $CRC_DB_USER |
        interpolate DB_PASS $CRC_DB_PASS |
        interpolate DB_SERVER ($DEFAULT_DB_SERVER) |
        interpolate DB_DRIVER $CRC_DB_DRIVER |
        interpolate DB_URL (escape $CRC_DB_URL) |
        interpolate DB_PROJECT $I2B2_PROJECT_NAME |
        sc $_crcDataFolder\db.properties

    
    cd $_crcDataFolder
    
    Rename-Item .\data_build.xml build.xml

    ant upgrade_table_release_1-7
    
    ant upgrade_procedures_release_1-7

    cd $_upgradeDirectory
#    echo (Get-Item -Path ".\" -Verbose).FullName

}


#upgade Hive database fields to 1.7.06
function upgradeHiveData{

    Copy-Item $__currentDirectory\skel\i2b2\upgrade\db.properties -destination $_hiveDataFolder -Force
    
    interpolate_file $_hiveDataFolder\db.properties DB_TYPE $DEFAULT_DB_TYPE |
        interpolate DB_USER $HIVE_DB_USER |
        interpolate DB_PASS $HIVE_DB_PASS |
        interpolate DB_SERVER ($DEFAULT_DB_SERVER) |
        interpolate DB_DRIVER $HIVE_DB_DRIVER |
        interpolate DB_URL (escape $HIVE_DB_URL) |
        interpolate DB_PROJECT $I2B2_PROJECT_NAME |
        sc $_hiveDataFolder\db.properties
        
    (Get-Content "$_hiveDataFolder\scripts\upgrade_sqlserver_i2b2hive_tables.sql") |
    Where-Object {$_ -notmatch 'INSERT'} | Set-Content "$_hiveDataFolder\scripts\upgrade_sqlserver_i2b2hive_tables.sql"

    (Get-Content "$_hiveDataFolder\scripts\upgrade_sqlserver_i2b2hive_tables.sql") |
    Where-Object {$_ -notmatch 'i2b2demo'} | Set-Content "$_hiveDataFolder\scripts\upgrade_sqlserver_i2b2hive_tables.sql"
        
    cd $_hiveDataFolder
    
    Rename-Item .\data_build.xml build.xml

    ant upgrade_hive_tables_release_1-7

    cd $_upgradeDirectory

}


#upgade Metadata database fields to 1.7.06
function upgradeMetaData{
    
    Copy-Item $__currentDirectory\skel\i2b2\upgrade\db.properties -destination $_metaDataFolder -Force
    Copy-Item $__currentDirectory\skel\i2b2\upgrade\create_icd10_icd9_table.sql $_metaDataFolder\scripts\sqlserver -Force
    Copy-Item $__currentDirectory\skel\i2b2\upgrade\table_access_insert_data.sql $_metaDataFolder\scripts -Force
    
    interpolate_file $_metaDataFolder\db.properties DB_TYPE $DEFAULT_DB_TYPE |
        interpolate DB_USER $ONT_DB_USER |
        interpolate DB_PASS $ONT_DB_PASS |
        interpolate DB_SERVER ($DEFAULT_DB_SERVER) |
        interpolate DB_DRIVER $ONT_DB_DRIVER |
        interpolate DB_URL (escape $ONT_DB_URL) |
        interpolate DB_PROJECT $I2B2_PROJECT_NAME |
        sc $_metaDataFolder\db.properties

    cd $_metaDataFolder
    
    Rename-Item .\data_build.xml build.xml

    ant upgrade_metadata_tables_release_1-7

    cd $_upgradeDirectory
}


#upgade PM database fields to 1.7.06
function upgradePMData{
    
    Copy-Item $__currentDirectory\skel\i2b2\upgrade\db.properties -destination $_pmDataFolder -Force
    
    interpolate_file $_pmDataFolder\db.properties DB_TYPE $DEFAULT_DB_TYPE |
        interpolate DB_USER $PM_DB_USER |
        interpolate DB_PASS $PM_DB_PASS |
        interpolate DB_SERVER ($DEFAULT_DB_SERVER) |
        interpolate DB_DRIVER $PM_DB_DRIVER |
        interpolate DB_URL (escape $PM_DB_URL) |
        interpolate DB_PROJECT $I2B2_PROJECT_NAME |
        sc $_pmDataFolder\db.properties

    cd $_pmDataFolder
    
    Rename-Item .\data_build.xml build.xml

    ant upgrade_pm_tables_release_1-7

    cd $_upgradeDirectory

}


#upgade PM i2b2 cell to 1.7.06
function upgradePMCell{

    $file = $_pmSourceFolder + "\build.properties"
    
    (Get-Content $file) | ForEach-Object { $_ -replace "/opt/jboss-as-7.1.1.Final", ($env:JBOSS_HOME) } | Set-Content ($file) -Force

    Copy-Item $__jbossInstallFolder\standalone\deployments\pm-ds.xml -destination $_pmSourceFolder\etc\jboss -Force
            
    cd $_pmSourceFolder

    ant -f master_build.xml clean build-all deploy    
  
    cd $_upgradeDirectory

}


#upgade Ontology i2b2 cell to 1.7.06
function upgradeONTCell{

    $file = $_ontSourceFolder + "\build.properties"
    (Get-Content $file) | ForEach-Object { $_ -replace "/opt/jboss-as-7.1.1.Final", ($env:JBOSS_HOME) } | Set-Content ($file) -Force   
    
    $file = $_ontSourceFolder + "\etc\spring\ontology_application_directory.properties"
    (Get-Content $file) | ForEach-Object { $_ -replace "jboss-as-7.1.1.Final", "jboss" } | Set-Content ($file) -Force
    
    Copy-Item $__jbossInstallFolder\standalone\configuration\ontologyapp\ontology.properties -Destination $_ontSourceFolder\etc\spring -Force
    
    Copy-Item $__jbossInstallFolder\standalone\deployments\ont-ds.xml -destination $_ontSourceFolder\etc\jboss -Force
            
    cd $_ontSourceFolder

    ant -f master_build.xml clean build-all deploy    
  
    cd $_upgradeDirectory
}


#upgade CRC i2b2 cell to 1.7.06
function upgradeCRCCell{

    $file = $_crcSourceFolder + "\build.properties"
    (Get-Content $file) | ForEach-Object { $_ -replace "/opt/jboss-as-7.1.1.Final", ($env:JBOSS_HOME) } | Set-Content ($file) -Force    
    
    $file = $_crcSourceFolder + "\etc\spring\crc_application_directory.properties"
    (Get-Content $file) | ForEach-Object { $_ -replace "jboss-as-7.1.1.Final", "jboss" } | Set-Content ($file) -Force   
    
    Copy-Item $__jbossInstallFolder\standalone\configuration\crcapp\edu.harvard.i2b2.crc.loader.properties -Destination $_crcSourceFolder\etc\spring -Force
    Copy-Item $__jbossInstallFolder\standalone\configuration\crcapp\CRCLoaderApplicationContext.xml -Destination $_crcSourceFolder\etc\spring -Force
    Copy-Item $__jbossInstallFolder\standalone\configuration\crcapp\crc.properties -Destination $_crcSourceFolder\etc\spring -Force
    
    Copy-Item $__jbossInstallFolder\standalone\deployments\crc-ds.xml -destination $_crcSourceFolder\etc\jboss -Force
                  
    cd $_crcSourceFolder

    ant -f master_build.xml clean build-all deploy    
  
    cd $_upgradeDirectory
}


#upgade Workplace i2b2 cell to 1.7.06
function upgradeWorkCell{

    $file = $_workSourceFolder + "\build.properties"
    (Get-Content $file) | ForEach-Object { $_ -replace "/opt/jboss-as-7.1.1.Final", ($env:JBOSS_HOME) } | Set-Content ($file) -Force   
    
    $file = $_workSourceFolder + "\etc\spring\workplace_application_directory.properties"
    (Get-Content $file) | ForEach-Object { $_ -replace "jboss-as-7.1.1.Final", "jboss" } | Set-Content ($file) -Force   
    
    Copy-Item $__jbossInstallFolder\standalone\configuration\workplaceapp\workplace.properties -Destination $_workSourceFolder\etc\spring -Force 
    
    Copy-Item $__jbossInstallFolder\standalone\deployments\work-ds.xml -destination $_workSourceFolder\etc\jboss -Force
            
    cd $_workSourceFolder

    ant -f master_build.xml clean build-all deploy    
  
    cd $_upgradeDirectory
}


#upgade FR i2b2 cell to 1.7.06
function upgradeFRCell{    

    $file = $_frSourceFolder + "\build.properties"
    (Get-Content $file) | ForEach-Object { $_ -replace "/opt/jboss-as-7.1.1.Final", ($env:JBOSS_HOME) } | Set-Content ($file) -Force   
    
    $file = $_frSourceFolder + "\etc\spring\fr_application_directory.properties"
    (Get-Content $file) | ForEach-Object { $_ -replace "jboss-as-7.1.1.Final", "jboss" } | Set-Content ($file) -Force   
    
    Copy-Item $__jbossInstallFolder\standalone\configuration\frapp\edu.harvard.i2b2.fr.properties -Destination $_frSourceFolder\etc\spring -Force 
        
    cd $_frSourceFolder

    ant -f master_build.xml clean build-all deploy    
  
    cd $_upgradeDirectory

}


#upgade IM i2b2 cell to 1.7.06
function upgradeIMCell{    

    $file = $_imSourceFolder + "\build.properties"
    (Get-Content $file) | ForEach-Object { $_ -replace "/opt/jboss-as-7.1.1.Final", ($env:JBOSS_HOME) } | Set-Content ($file) -Force     
    
    $file = $_imSourceFolder + "\etc\spring\im_application_directory.properties"
    (Get-Content $file) | ForEach-Object { $_ -replace "jboss-as-7.1.1.Final", "jboss" } | Set-Content ($file) -Force  
    
    Copy-Item $__jbossInstallFolder\standalone\configuration\imapp\im.properties -Destination $_imSourceFolder\etc\spring -Force 
    
    Copy-Item $__jbossInstallFolder\standalone\deployments\im-ds.xml -destination $_imSourceFolder\etc\jboss -Force
               
    cd $_imSourceFolder

    ant -f master_build.xml clean build-all deploy    
  
    cd $_upgradeDirectory  
     
}

#upgrade webclient and admin websites to 1.7.06
function upgradeWeb{

    Copy-Item "C:\inetpub\wwwroot\webclient\i2b2_config_data.js" -Destination $_upgradeDirectory
    Remove-Item "C:\inetpub\wwwroot\webclient" -Force -Recurse
    Copy-Item $_webDirectory\webclient -Destination "C:\inetpub\wwwroot" -Force -Recurse -Confirm:$false
    Copy-Item $_upgradeDirectory\i2b2_config_data.js -Destination "C:\inetpub\wwwroot\webclient" -Force -Confirm:$false
    
    Copy-Item "C:\inetpub\wwwroot\admin\i2b2_config_data.js" -Destination $_upgradeDirectory  -Force
    Remove-Item "C:\inetpub\wwwroot\admin" -Force -Recurse 
    Copy-Item $_sourceDirectory\admin -Destination "C:\inetpub\wwwroot" -Force -Recurse -Confirm:$false
    Copy-Item $_upgradeDirectory\i2b2_config_data.js -Destination "C:\inetpub\wwwroot\admin" -Force -Confirm:$false
}



#Backup Warning
echo "WARNING: This upgrade will make changes to the database, application and website of you i2b2 installation. A backup of your JBOSS deployment and website directories will be created, but it is recommended to backup your database."
$Proceed = Read-Host -Prompt 'Proceed? (Y or N)'

if($Proceed){

    backupDeployment
    
    #Prerequisites
        Stop-Service JBOSS
    
    #Upgrading Data
    if(Test-Path $_crcDataFolder){
        upgradeCrcData
    }
        
    if(Test-Path $_hiveDataFolder){
        upgradeHiveData
    }
    
    if(Test-Path $_metaDataFolder){
        upgradeMetaData
    }
    
    if(Test-Path $_pmDataFolder){
        upgradePMData
    }
    
    #Upgrading Cells
    upgradePMCell
    upgradeONTCell
    upgradeCRCCell
    upgradeWorkCell
    upgradeFRCell
    upgradeIMCell
    
    #Upgrading Webclient and Admin
    upgradeWeb
    
    #Finishing up
    Start-Service JBOSS
    
}
