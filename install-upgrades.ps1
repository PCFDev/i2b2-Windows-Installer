. .\functions.ps1
. .\config-system.ps1
. .\config-i2b2.ps1


$_i2b2Version = "1706"
$_release = "Release_1-7"
$_upgradeDirectory = ($_currentDirectory).Parent.FullName

$_sourceDirectory = $_upgradeDirectory + "\i2b2core-src-" + $_i2b2Version
$_dataDirectory = $_upgradeDirectory + "\i2b2createdb-" + $_i2b2Version + "\edu.harvard.i2b2.data\" + $_release + "\Upgrade"
$_webDirectory = $upgradeDirectory + "\i2b2webclient-" + $_i2b2Version

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

function upgradeCrcData{

    Copy-Item $_currentDirectory\skel\i2b2\db.properties -destination $_crcDataFolder -Force
    
    interpolate_file $_crcDataFolder\db.properties DB_TYPE $DEFAULT_DB_TYPE |
        interpolate DB_USER $CRC_DB_USER |
        interpolate DB_PASS $CRC_DB_PASS |
        interpolate DB_SERVER (escape $DEFAULT_DB_SERVER) |
        interpolate DB_DRIVER $CRC_DB_DRIVER |
        interpolate DB_URL (escape $CRC_DB_URL) |
        interpolate I2B2_PROJECT_NAME $I2B2_PROJECT_NAME |
        sc db.properties

    (Get-Content $_crcDataFolder + "\scripts\crc_create_query_sqlserver.sql") |
    Where-Object {$_ -notmatch 'Demo'} | Set-Content $_crcDataFolder + "\scripts\crc_create_query_sqlserver.sql"
    
    ant –f data_build.xml upgrade_table_release_1-7
    
    ant –f data_build.xml upgrade_procedures_release_1-7

}

function upgradeHiveData{

    Copy-Item $_currentDirectory\skel\i2b2\db.properties -destination $_hiveDataFolder -Force
    
    interpolate_file $_hiveDataFolder\db.properties DB_TYPE $DEFAULT_DB_TYPE |
        interpolate DB_USER $HIVE_DB_USER |
        interpolate DB_PASS $HIVE_DB_PASS |
        interpolate DB_SERVER (escape $DEFAULT_DB_SERVER) |
        interpolate DB_DRIVER $HIVE_DB_DRIVER |
        interpolate DB_URL (escape $HIVE_DB_URL) |
        interpolate I2B2_PROJECT_NAME $I2B2_PROJECT_NAME |
        sc db.properties
        
        (Get-Content $_hiveDataFolder + "\scripts\upgrade_sqlserver_i2b2hive_tables.sql") |
        Where-Object {$_ -notmatch 'INSERT'} | Set-Content $_hiveDataFolder + "\scripts\upgrade_sqlserver_i2b2hive_tables.sql"

        (Get-Content $_hiveDataFolder + "\scripts\upgrade_sqlserver_i2b2hive_tables.sql") |
        Where-Object {$_ -notmatch 'i2b2demo'} | Set-Content $_hiveDataFolder + "\scripts\upgrade_sqlserver_i2b2hive_tables.sql"
        
        ant –f data_build.xml upgrade_hivedata_tables_release_1-7

}


function upgradeMetaData{
    
    Copy-Item $_currentDirectory\skel\i2b2\db.properties -destination $_metaDataFolder -Force
    
    interpolate_file $_metaDataFolder\db.properties DB_TYPE $DEFAULT_DB_TYPE |
        interpolate DB_USER $ONT_DB_USER |
        interpolate DB_PASS $ONT_DB_PASS |
        interpolate DB_SERVER (escape $DEFAULT_DB_SERVER) |
        interpolate DB_DRIVER $ONT_DB_DRIVER |
        interpolate DB_URL (escape $ONT_DB_URL) |
        interpolate I2B2_PROJECT_NAME $I2B2_PROJECT_NAME |
        sc db.properties

        ant -f data_build.xml upgrade_metadata_tables_release_1-7

}

function upgradePMData{
    
    Copy-Item $_currentDirectory\skel\i2b2\db.properties -destination $_pmDataFolder -Force
    
    interpolate_file $_pmDataFolder\db.properties DB_TYPE $DEFAULT_DB_TYPE |
        interpolate DB_USER $PM_DB_USER |
        interpolate DB_PASS $PM_DB_PASS |
        interpolate DB_SERVER (escape $DEFAULT_DB_SERVER) |
        interpolate DB_DRIVER $PM_DB_DRIVER |
        interpolate DB_URL (escape $PM_DB_URL) |
        interpolate I2B2_PROJECT_NAME $I2B2_PROJECT_NAME |
        sc db.properties

    ant -f data_build.xml upgrade_pm_tables_release_1-7

}



function upgradeCells{

#Install PM Cell
    $file = $_pmSourceFolder + "\build.properties"
    
    (Get-Content $file) | ForEach-Object { $_ -replace "/opt/jboss-as-7.1.1.Final", (escape $env:JBOSS_HOME) } | Set-Content ($file) -Force

    Copy-Item $_jbossInstallFolder\standalone\deployments\pm-ds.xml -destination $_pmSourceFolder\etc\jboss -Force
        
    ant -f master_build.xml clean build-all deploy    
  
#Install ONT Cell
    $file = $_ontSourceFolder + "\build.properties"
    (Get-Content $file) | ForEach-Object { $_ -replace "/opt/jboss-as-7.1.1.Final", (escape $env:JBOSS_HOME) } | Set-Content ($file) -Force   
    
    $file = $_ontSourceFolder + "\etc\spring\ontology_application_directory.properties"
    (Get-Content $file) | ForEach-Object { $_ -replace "jboss-as-7.1.1.Final", "jboss" } | Set-Content ($file) -Force
    
    Copy-Item $_jbossInstallFolder\standalone\configuration\ontologyapp\ontology.properties -Destination $_ontSourceFolder\etc\spring -Force
    
    Copy-Item $_jbossInstallFolder\standalone\deployments\ont-ds.xml -destination $_ontSourceFolder\etc\jboss -Force
        
    ant -f master_build.xml clean build-all deploy    
    
#Install CRC Cell
    $file = $_crcSourceFolder + "\build.properties"
    (Get-Content $file) | ForEach-Object { $_ -replace "/opt/jboss-as-7.1.1.Final", (escape $env:JBOSS_HOME) } | Set-Content ($file) -Force    
    
    $file = $_crcSourceFolder + "\etc\spring\crc_application_directory.properties"
    (Get-Content $file) | ForEach-Object { $_ -replace "jboss-as-7.1.1.Final", "jboss" } | Set-Content ($file) -Force   
    
    Copy-Item $_jbossInstallFolder\standalone\configuration\crcapp\edu.harvard.i2b2.crc.loader.properties -Destination $_crcSourceFolder\etc\spring -Force
    Copy-Item $_jbossInstallFolder\standalone\configuration\crcapp\CRCLoaderApplicationContext.xmls -Destination $_crcSourceFolder\etc\spring -Force
    Copy-Item $_jbossInstallFolder\standalone\configuration\crcapp\crc.properties -Destination $_crcSourceFolder\etc\spring -Force
    
    Copy-Item $_jbossInstallFolder\standalone\deployments\crc-ds.xml -destination $_crcSourceFolder\etc\jboss -Force
        
    ant -f master_build.xml clean build-all deploy  
    
#Install Workplace Cell
    $file = $_workSourceFolder + "\build.properties"
    (Get-Content $file) | ForEach-Object { $_ -replace "/opt/jboss-as-7.1.1.Final", (escape $env:JBOSS_HOME) } | Set-Content ($file) -Force   
    
    $file = $_workSourceFolder + "\etc\spring\workplace_application_directory.properties"
    (Get-Content $file) | ForEach-Object { $_ -replace "jboss-as-7.1.1.Final", "jboss" } | Set-Content ($file) -Force   
    
    Copy-Item $_jbossInstallFolder\standalone\configuration\workplaceapp\workplace.properties -Destination $_workSourceFolder\etc\spring -Force 
    
    Copy-Item $_jbossInstallFolder\standalone\deployments\work-ds.xml -destination $_workSourceFolder\etc\jboss -Force
        
    ant -f master_build.xml clean build-all deploy   
    
    
#Install File Repository Cell
    $file = $_frSourceFolder + "\build.properties"
    (Get-Content $file) | ForEach-Object { $_ -replace "/opt/jboss-as-7.1.1.Final", (escape $env:JBOSS_HOME) } | Set-Content ($file) -Force   
    
    $file = $_frSourceFolder + "\etc\spring\fr_application_directory.properties"
    (Get-Content $file) | ForEach-Object { $_ -replace "jboss-as-7.1.1.Final", "jboss" } | Set-Content ($file) -Force   
    
    Copy-Item $_jbossInstallFolder\standalone\configuration\frapp\edu.harvard.i2b2.fr.properties -Destination $_frSourceFolder\etc\spring -Force 
        
    ant -f master_build.xml clean build-all deploy
    
#Install Identity Management Cell
    $file = $_imSourceFolder + "\build.properties"
    (Get-Content $file) | ForEach-Object { $_ -replace "/opt/jboss-as-7.1.1.Final", (escape $env:JBOSS_HOME) } | Set-Content ($file) -Force     
    
    $file = $_imSourceFolder + "\etc\spring\im_application_directory.properties"
    (Get-Content $file) | ForEach-Object { $_ -replace "jboss-as-7.1.1.Final", "jboss" } | Set-Content ($file) -Force  
    
    Copy-Item $_jbossInstallFolder\standalone\configuration\imapp\im.properties -Destination $_imSourceFolder\etc\spring -Force 
    
    Copy-Item $_jbossInstallFolder\standalone\deployments\im-ds.xml -destination $_imSourceFolder\etc\jboss -Force
        
    ant -f master_build.xml clean build-all deploy    
}

function UpgradeWeb{
    Copy-Item "C:\inetpub\wwwroot\webclient\i2b2_config_data.js" -Destination $_upgradeDirectory
    Copy-Item $_webDirectory\webclient -Destination "C:\inetpub\wwwroot" -Force
    Copy-Item $_upgradeDirectory\i2b2_config_data.js -Destination "C:\inetpub\wwwroot\webclient" -Force
    
    Copy-Item "C:\inetpub\wwwroot\admin\i2b2_config_data.js" -Destination $_upgradeDirectory  -Force
    Copy-Item $_sourceDirectory\admin -Destination "C:\inetpub\wwwroot" -Force
    Copy-Item $_upgradeDirectory\i2b2_config_data.js -Destination "C:\inetpub\wwwroot\admin" -Force
}


#Prerequisites
    Stop-Service JBOSS

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

upgradeCells
upgradeWeb

Start-Service JBOSS