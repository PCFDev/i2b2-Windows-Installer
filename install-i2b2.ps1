
function installServerCommon {
    echo "Installing server common"
    cd $__sourceCodeRootFolder\edu.harvard.i2b2.server-common

    interpolate_file $__skelDirectory\i2b2\server-common\build.properties JBOSS_HOME (escape $env:JBOSS_HOME) | sc build.properties

    ant clean dist deploy jboss_pre_deployment_setup

    cd ..
    echo "Server common installed"
}

function installPM{
    echo "Installing PM Cell"
    cd edu.harvard.i2b2.pm

    interpolate_file $__skelDirectory\i2b2\pm\build.properties JBOSS_HOME (escape $env:JBOSS_HOME) | sc build.properties

    interpolate_file $__skelDirectory\i2b2\pm\pm-ds.xml PM_DB_URL $PM_DB_URL | 
        interpolate PM_DB_USER $PM_DB_USER |
        interpolate PM_DB_PASS $PM_DB_PASS |        
        interpolate PM_DB_DRIVER $PM_DB_DRIVER |
        interpolate PM_DB_JAR_FILE $PM_DB_JAR_FILE |
        sc etc\jboss\pm-ds.xml


    ant -file master_build.xml clean build-all deploy

    cd ..
    echo "PM Cell Installed"
}

function installONT{
    echo "Installing ONT Cell"
    cd edu.harvard.i2b2.ontology

    interpolate_file $__skelDirectory\i2b2\ontology\build.properties JBOSS_HOME (escape $env:JBOSS_HOME) | sc build.properties

    interpolate_file $__skelDirectory\i2b2\ontology\ontology_application_directory.properties JBOSS_HOME (escape $env:JBOSS_HOME) | 
        sc etc/spring/ontology_application_directory.properties

    interpolate_file $__skelDirectory\i2b2\ontology\ontology.properties HIVE_DB_SCHEMA $HIVE_DB_SCHEMA | 
        interpolate PM_SERVICE_URL $PM_SERVICE_URL |
        interpolate CRC_SERVICE_URL $CRC_SERVICE_URL |
        interpolate FR_SERVICE_URL $FR_SERVICE_URL |
        interpolate I2B2_SERVICEACCOUNT_USER $I2B2_SERVICEACCOUNT_USER |
        interpolate I2B2_SERVICEACCOUNT_PASS $I2B2_SERVICEACCOUNT_PASS |
        sc etc/spring/ontology.properties

    interpolate_file $__skelDirectory\i2b2\ontology\ont-ds.xml HIVE_DB_URL $HIVE_DB_URL | 
        interpolate HIVE_DB_USER $HIVE_DB_USER |
        interpolate HIVE_DB_PASS $HIVE_DB_PASS |
        interpolate HIVE_DB_DRIVER $HIVE_DB_DRIVER |
        interpolate HIVE_DB_JAR_FILE $HIVE_DB_JAR_FILE |
        interpolate ONT_DB_DRIVER $ONT_DB_DRIVER |
        interpolate ONT_DB_JAR_FILE $ONT_DB_JAR_FILE |
        interpolate ONT_DB_URL $ONT_DB_URL |
        interpolate ONT_DB_USER $ONT_DB_USER |
        interpolate ONT_DB_PASS $ONT_DB_PASS |
        sc etc\jboss\ont-ds.xml


    ant -file master_build.xml clean build-all deploy

    cd ..
    echo "ONT Cell Installed"
}

function installCRC {

    echo "Installing CRC Cell"
    cd edu.harvard.i2b2.crc

    interpolate_file $__skelDirectory\i2b2\crc\build.properties JBOSS_HOME (escape $env:JBOSS_HOME) | sc build.properties

    interpolate_file $__skelDirectory\i2b2\crc\crc_application_directory.properties JBOSS_HOME (escape $env:JBOSS_HOME) | 
        sc etc/spring/crc_application_directory.properties

    interpolate_file $__skelDirectory\i2b2\crc\edu.harvard.i2b2.crc.loader.properties HIVE_DB_SCHEMA $HIVE_DB_SCHEMA | 
        interpolate PM_SERVICE_URL $PM_SERVICE_URL |
        interpolate FR_SERVICE_URL $FR_SERVICE_URL |
        interpolate DEFAULT_DB_TYPE $DEFAULT_DB_TYPE |
        sc etc/spring/edu.harvard.i2b2.crc.loader.properties

    interpolate_file $__skelDirectory\i2b2\crc\CRCLoaderApplicationContext.xml HIVE_DB_URL $HIVE_DB_URL | 
        interpolate HIVE_DB_USER $HIVE_DB_USER |
        interpolate HIVE_DB_PASS $HIVE_DB_PASS |
        interpolate HIVE_DB_DRIVER $HIVE_DB_DRIVER |
        sc etc/spring/CRCLoaderApplicationContext.xml

    
    interpolate_file $__skelDirectory\i2b2\crc\crc.properties HIVE_DB_SCHEMA $HIVE_DB_SCHEMA | 
        interpolate PM_SERVICE_URL $PM_SERVICE_URL |
        interpolate ONT_SERVICE_URL $ONT_SERVICE_URL |
        interpolate DEFAULT_DB_TYPE $DEFAULT_DB_TYPE |
        interpolate I2B2_SERVICEACCOUNT_USER $I2B2_SERVICEACCOUNT_USER |
        interpolate I2B2_SERVICEACCOUNT_PASS $I2B2_SERVICEACCOUNT_PASS |        
        sc etc/spring/crc.properties

    interpolate_file $__skelDirectory\i2b2\crc\crc-ds.xml HIVE_DB_URL $HIVE_DB_URL | 
        interpolate HIVE_DB_USER $HIVE_DB_USER |
        interpolate HIVE_DB_PASS $HIVE_DB_PASS |
        interpolate HIVE_DB_DRIVER $HIVE_DB_DRIVER |
        interpolate HIVE_DB_JAR_FILE $HIVE_DB_JAR_FILE |
        interpolate CRC_DB_DRIVER $CRC_DB_DRIVER |
        interpolate CRC_DB_JAR_FILE $CRC_DB_JAR_FILE |
        interpolate CRC_DB_URL $CRC_DB_URL |
        interpolate CRC_DB_USER $CRC_DB_USER |
        interpolate CRC_DB_PASS $CRC_DB_PASS |
        sc etc/jboss/crc-ds.xml


    ant -file master_build.xml clean build-all deploy

    cd ..
    echo "CRC Cell Installed"


}

function installWorkplace {

    echo "Installing Workplace Cell"
    cd edu.harvard.i2b2.workplace

    interpolate_file $__skelDirectory\i2b2\workplace\build.properties JBOSS_HOME (escape $env:JBOSS_HOME) | sc build.properties

    interpolate_file $__skelDirectory\i2b2\workplace\workplace_application_directory.properties JBOSS_HOME (escape $env:JBOSS_HOME) | 
        sc etc/spring/workplace_application_directory.properties

    interpolate_file $__skelDirectory\i2b2\workplace\workplace.properties HIVE_DB_SCHEMA $HIVE_DB_SCHEMA | 
        interpolate PM_SERVICE_URL $PM_SERVICE_URL |
        sc etc/spring/workplace.properties
    
    
    interpolate_file $__skelDirectory\i2b2\workplace\work-ds.xml HIVE_DB_URL $HIVE_DB_URL | 
        interpolate HIVE_DB_USER $HIVE_DB_USER |
        interpolate HIVE_DB_PASS $HIVE_DB_PASS |
        interpolate HIVE_DB_DRIVER $HIVE_DB_DRIVER |
        interpolate HIVE_DB_JAR_FILE $HIVE_DB_JAR_FILE |
        interpolate WORK_DB_DRIVER $WORK_DB_DRIVER |
        interpolate WORK_DB_JAR_FILE $WORK_DB_JAR_FILE |
        interpolate WORK_DB_URL $WORK_DB_URL |
        interpolate WORK_DB_USER $WORK_DB_USER |
        interpolate WORK_DB_PASS $WORK_DB_PASS |
        sc etc\jboss\work-ds.xml
  
    ant -file master_build.xml clean build-all deploy

    cd ..
    echo "Workplace Cell Installed"
}

function installFR {

    echo "Installing FR Cell"
    cd edu.harvard.i2b2.fr

    interpolate_file $__skelDirectory\i2b2\fr\build.properties JBOSS_HOME (escape $env:JBOSS_HOME) | sc build.properties

    interpolate_file $__skelDirectory\i2b2\fr\fr_application_directory.properties JBOSS_HOME (escape $env:JBOSS_HOME) | 
        sc etc/spring/fr_application_directory.properties

    interpolate_file $__skelDirectory\i2b2\fr\edu.harvard.i2b2.fr.properties PM_SERVICE_URL $PM_SERVICE_URL | 
        sc etc/spring/edu.harvard.i2b2.fr.properties
  
    ant -file master_build.xml clean build-all deploy

    cd ..
    echo "FR Cell Installed"
}

function installIM {

    echo "Installing IM Cell"
    cd edu.harvard.i2b2.im

    interpolate_file $__skelDirectory\i2b2\im\build.properties JBOSS_HOME (escape $env:JBOSS_HOME) | sc build.properties

    interpolate_file $__skelDirectory\i2b2\im\im_application_directory.properties JBOSS_HOME (escape $env:JBOSS_HOME) | 
        sc etc/spring/im_application_directory.properties

    interpolate_file $__skelDirectory\i2b2\im\im.properties PM_SERVICE_URL $PM_SERVICE_URL | 
        interpolate HIVE_DB_SCHEMA $HIVE_DB_SCHEMA |
        sc etc/spring/im.properties

    interpolate_file $__skelDirectory\i2b2\im\im-ds.xml HIVE_DB_URL $HIVE_DB_URL | 
        interpolate HIVE_DB_USER $HIVE_DB_USER |
        interpolate HIVE_DB_PASS $HIVE_DB_PASS |
        interpolate HIVE_DB_DRIVER $HIVE_DB_DRIVER |
        interpolate HIVE_DB_JAR_FILE $HIVE_DB_JAR_FILE |
        interpolate IM_DB_DRIVER $IM_DB_DRIVER |
        interpolate IM_DB_JAR_FILE $IM_DB_JAR_FILE |
        interpolate IM_DB_URL $IM_DB_URL |
        interpolate IM_DB_USER $IM_DB_USER |
        interpolate IM_DB_PASS $IM_DB_PASS |
        sc etc\jboss\im-ds.xml
  
    ant -file master_build.xml clean build-all deploy

    cd ..
    echo "IM Cell Installed"
}

function installWebClient{
    echo "Installing i2b2 webclient..."
    unzip $__webclientZipFile $__webclientInstallFolder $true

   
    if(!(Test-Path $__webclientInstallFolder))
    {
        Throw "Web client could not be installed"
    }

    interpolate_file $__skelDirectory\i2b2\webclient\i2b2_config_data.js I2B2_DOMAIN $I2B2_DOMAIN | 
        interpolate I2B2_HIVE_NAME $I2B2_HIVE_NAME |
        interpolate PM_SERVICE_URL $PM_SERVICE_URL |
        sc $__webclientInstallFolder\webclient\i2b2_config_data.js

    echo "Web Client installed to $__webclientInstallFolder"

}

function installAdminTool{
    echo "Installing i2b2 admin tool..."

    cp  $__sourceCodeRootFolder\admin $__webClientInstallFolder -Force -Recurse

    
    interpolate_file $__skelDirectory\i2b2\admin\i2b2_config_data.js I2B2_DOMAIN $I2B2_DOMAIN | 
        interpolate I2B2_HIVE_NAME $I2B2_HIVE_NAME |
        interpolate PM_SERVICE_URL $PM_SERVICE_URL |
        sc $__webclientInstallFolder\admin\i2b2_config_data.js


    echo "i2b2 admin tool installed"
}


echo "Extracting i2b2 source..."
unzip $__sourceCodeZipFile $__sourceCodeRootFolder $true
echo "Source extracted to $__sourceCodeRootFolder"

if(!(Test-Path $__sourceCodeRootFolder))
{
    Throw "Source not extracted"
}

installServerCommon
installPM
installONT
installCRC
installWorkplace
installFR
installIM

if($InstallWebClient -eq $true){
    installWebClient
}

if($InstallAdminTool -eq $true){
    installAdminTool
}

cd $__currentDirectory