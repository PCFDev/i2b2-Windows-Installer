function installCrc{

    cd Crcdata

    createDatabase $CRC_DB_NAME
    createUser $CRC_DB_NAME $CRC_DB_USER $CRC_DB_PASS $DEFAULT_DB_SCHEMA

    $buildFile = (Get-Item -Path ".\" -Verbose).FullName + "\data_build.xml"

    interpolate_file $__skelDirectory\i2b2\data\db.properties DB_TYPE $DEFAULT_DB_TYPE |
        interpolate DB_USER $CRC_DB_USER |
        interpolate DB_PASS $CRC_DB_PASS |
        interpolate DB_SERVER (escape $DEFAULT_DB_SERVER) |
        interpolate DB_DRIVER $CRC_DB_DRIVER |
        interpolate DB_URL (escape $CRC_DB_URL) |
        interpolate I2B2_PROJECT_NAME $I2B2_PROJECT_NAME |
        sc db.properties
    
    report "Installing CRC Tables"    
    ant -f "$buildFile" create_crcdata_tables_release_1-7 > "$__rootFolder\$logFileName" 2>&1

    report "Installing CRC Stored Procedures"
    ant -f "$buildFile" create_procedures_release_1-7 > "$__rootFolder\$logFileName" 2>&1

    if($InstallDemoData -eq $true){
        report "Loading CRC demo data"
        ant -f "$buildFile" db_demodata_load_data   > "$__rootFolder\$logFileName" 2>&1      
    }
    
    cd ..
    report "CRC Data Installed"

}

function installHive{
    cd Hivedata
    $buildFile = (Get-Item -Path ".\" -Verbose).FullName + "\data_build.xml"

    createDatabase $HIVE_DB_NAME
    createUser $HIVE_DB_NAME $HIVE_DB_USER $HIVE_DB_PASS $DEFAULT_DB_SCHEMA

    interpolate_file $__skelDirectory\i2b2\data\db.properties DB_TYPE $DEFAULT_DB_TYPE |
        interpolate DB_USER $HIVE_DB_USER |
        interpolate DB_PASS $HIVE_DB_PASS |
        interpolate DB_SERVER (escape $DEFAULT_DB_SERVER) |
        interpolate DB_DRIVER $HIVE_DB_DRIVER |
        interpolate DB_URL (escape $HIVE_DB_URL) |
        interpolate I2B2_PROJECT_NAME $I2B2_PROJECT_NAME |
        sc db.properties

    report "Installing Hive Tables"

    ant -f "$buildFile" create_hivedata_tables_release_1-7 > "$__rootFolder\$logFileName" 2>&1


    if($InstallDemoData -eq $true){
       report "Loading Hive demo data"

       ant -f "$buildFile" db_hivedata_load_data > "$__rootFolder\$logFileName" 2>&1
    }

    cd ..
    report "Hive Data Installed"
}

function installIM{

    cd Imdata
    $buildFile = (Get-Item -Path ".\" -Verbose).FullName + "\data_build.xml"

    createDatabase $IM_DB_NAME
    createUser $IM_DB_NAME $IM_DB_USER $IM_DB_PASS $DEFAULT_DB_SCHEMA

    interpolate_file $__skelDirectory\i2b2\data\db.properties DB_TYPE $DEFAULT_DB_TYPE |
        interpolate DB_USER $IM_DB_USER |
        interpolate DB_PASS $IM_DB_PASS |
        interpolate DB_SERVER (escape $DEFAULT_DB_SERVER) |
        interpolate DB_DRIVER $IM_DB_DRIVER |
        interpolate DB_URL (escape $IM_DB_URL) |
        interpolate I2B2_PROJECT_NAME $I2B2_PROJECT_NAME |
        sc db.properties

    report "Installing IM Tables"
    ant -f "$buildFile" create_imdata_tables_release_1-7 > "$__rootFolder\$logFileName" 2>&1
    
    if($InstallDemoData -eq $true){
        report "Loading IM demo data"
        ant -f "$buildFile"  db_imdata_load_data > "$__rootFolder\$logFileName" 2>&1
    }

    cd ..
    report "IM Data Installed"
}

function installOnt{

    cd Metadata
    $buildFile = (Get-Item -Path ".\" -Verbose).FullName + "\data_build.xml"

    createDatabase $ONT_DB_NAME
    createUser $ONT_DB_NAME $ONT_DB_USER $ONT_DB_PASS $DEFAULT_DB_SCHEMA

    interpolate_file $__skelDirectory\i2b2\data\db.properties DB_TYPE $DEFAULT_DB_TYPE |
        interpolate DB_USER $ONT_DB_USER |
        interpolate DB_PASS $ONT_DB_PASS |
        interpolate DB_SERVER (escape $DEFAULT_DB_SERVER) |
        interpolate DB_DRIVER $ONT_DB_DRIVER |
        interpolate DB_URL (escape $ONT_DB_URL) |
        interpolate I2B2_PROJECT_NAME $I2B2_PROJECT_NAME |
        sc db.properties

    report "Installing ONT Tables"
    ant -f "$buildFile" create_metadata_tables_release_1-7 > "$__rootFolder\$logFileName" 2>&1
    
    if($InstallDemoData -eq $true){
        report "Loading ONT demo data"
        ant -f "$buildFile" db_metadata_load_data > "$__rootFolder\$logFileName" 2>&1
    }

    cd ..
    report "Metadata Data Installed"
}

function installPM{

    cd Pmdata        
    $buildFile = (Get-Item -Path ".\" -Verbose).FullName + "\data_build.xml"

    createDatabase $PM_DB_NAME
    createUser $PM_DB_NAME $PM_DB_USER $PM_DB_PASS $DEFAULT_DB_SCHEMA

    interpolate_file $__skelDirectory\i2b2\data\db.properties DB_TYPE $DEFAULT_DB_TYPE |
        interpolate DB_USER $PM_DB_USER |
        interpolate DB_PASS $PM_DB_PASS |
        interpolate DB_SERVER (escape $DEFAULT_DB_SERVER) |
        interpolate DB_DRIVER $PM_DB_DRIVER |
        interpolate DB_URL (escape $PM_DB_URL) |
        interpolate I2B2_PROJECT_NAME $I2B2_PROJECT_NAME |
        sc db.properties

    report "Installing PM Tables"

    ant -f "$buildFile" create_pmdata_tables_release_1-7 > "$__rootFolder\$logFileName" 2>&1

    report "Installing PM Triggers"
    

    ant -f "$buildFile" create_triggers_release_1-7 > "$__rootFolder\$logFileName" 2>&1
    
    if($InstallDemoData -eq $true){
        report "Loading PM demo data"
        ant -f "$buildFile" db_pmdata_load_data > "$__rootFolder\$logFileName" 2>&1
    }

    cd ..
    report "PM Data Installed"
}

function installWork{

    cd Workdata    
    $buildFile = (Get-Item -Path ".\" -Verbose).FullName + "\data_build.xml"

    createDatabase $WORK_DB_NAME
    createUser $WORK_DB_NAME $WORK_DB_USER $WORK_DB_PASS $DEFAULT_DB_SCHEMA

    interpolate_file $__skelDirectory\i2b2\data\db.properties DB_TYPE $DEFAULT_DB_TYPE |
        interpolate DB_USER $WORK_DB_USER |
        interpolate DB_PASS $WORK_DB_PASS |
        interpolate DB_SERVER (escape $DEFAULT_DB_SERVER) |
        interpolate DB_DRIVER $WORK_DB_DRIVER |
        interpolate DB_URL (escape $WORK_DB_URL) |
        interpolate I2B2_PROJECT_NAME $I2B2_PROJECT_NAME |
        sc db.properties

    report "Installing Work Tables"

    ant -f "$buildFile" create_workdata_tables_release_1-7 > "$__rootFolder\$logFileName" 2>&1
  
    if($InstallDemoData -eq $true){
        report "Loading Work demo data"
        ant -f "$buildFile" db_workdata_load_data > "$__rootFolder\$logFileName" 2>&1
    }

    cd ..
    report "Work Data Installed"
}





require $DEFAULT_DB_ADMIN_USER "Database admin username must be set in the configuration"
require $DEFAULT_DB_ADMIN_PASS "Database admin password must be set in the configuration"
require $DEFAULT_DB_TYPE "Database type must be set in the configuration"
require $DEFAULT_DB_SERVER "Database server must be set in the configuration"

report "Starting i2b2 Data Installation"


report "Extracting data creation scripts..."
unzip $__dataInstallationZipFile $__sourceCodeRootFolder $true
report "Source extracted to $__sourceCodeRootFolder"

if(!(Test-Path $__sourceCodeRootFolder))
{
    Throw "Data creation scripts not extracted"
}

cd $__sourceCodeRootFolder\edu.harvard.i2b2.data\Release_1-7\NewInstall

installCrc
installHive
installIM
installOnt
installPM
installWork


cd $__currentDirectory

report "i2b2 Data Installation Completed"