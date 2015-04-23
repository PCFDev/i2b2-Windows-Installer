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
This script will download the correctversion of Apache Tomcat 8.0. It will then unzip to 
another directory and copy the contents into the shrine\tomcat directory beneath the 
user-specified or default directory. It will also install Tomcat 8.0 as a service running 
automatically.

.PARAMETER $tomcat_path
Define a path for tomcat to be extracted to. Avoid directory locations that include spaces
within their paths.

.PARAMETER $InstallService
Tomcat is installed as a Windows service by default. Using the -s alias and $false will 
keep Tomcat from being installed as a service.

.EXAMPLE
.\tomcat_install -s $false
Skips the installation of Tomcat as a Windows service.

.EXAMPLE
.\tomcat_install C:\newDirectory
tomcat_install will extract Tomcat to the C:\newDirectory\shrine\tomcat directory and
install Tomcat as a service.

.EXAMPLE
.\tomcat_install C:\otherDirectory -s $false
tomcat_install will extract Tomcat to the C:\otherDirectory\shrine\tomcat directory and
does not install Tomcat as a service.

.EXAMPLE
PowerShell will number them for you when it displays your help text to a user.
#>


[CmdletBinding()]
Param(
    [parameter(Mandatory=$false)]
	[AllowEmptyString()]
	[string]$tomcat_path
)


#Include functions.ps1 for unzip functionality
#Include configurations.ps1 for file download url
. .\functions.ps1
. .\configuration.ps1
. .\common.ps1


function prepareInstall(){

    echo "Preparing for installation..."

    #______________________________________________________________________________

    #Create temp downloads folder
    echo "creating directories..."
    if(!(Test-Path $Env:TOMCAT\shrine\_downloads)){
        echo "creating temporary download location..."
        mkdir $Env:TOMCAT\shrine\_downloads
    }

    echo "creating tomcat directory..."
    if(Test-Path $Env:TOMCAT\shrine\tomcat){
        Remove-Item $Env:TOMCAT\shrine\tomcat -Recurse
    }
    mkdir $Env:TOMCAT\shrine\tomcat
    echo "tomcat directory created."

        
    echo "creating temporary Shrine setup locations..."    
    #Create temp setup folder
    if(!(Test-Path $_SHRINE_HOME\setup)){
        mkdir $_SHRINE_HOME\setup
    }
    
    #Create temp folder for completed files
    if(!(Test-Path $_SHRINE_HOME\setup\ready)){
        mkdir $_SHRINE_HOME\setup\ready
    }
    echo "Shrine setup locations created."

#_____________________________________________

    #Check for Java
    if((isJavaInstalled) -eq $false)
    {
        throw "Java not installed!"
        #InstallJava
    }
    echo "Java is installed. Moving on..."
    
    echo "installing Subversion"
    #Download and install Subversion
    $SVNUrl = "http://downloads.sourceforge.net/project/win32svn/1.8.11/apache22/svn-win32-1.8.11.zip?"
    Invoke-WebRequest  $SVNUrl -OutFile $_SHRINE_HOME\setup\subversion.zip -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer
    unzip $_SHRINE_HOME\setup\subversion.zip $_SHRINE_HOME\setup\svn
    echo "Subversion is installed. Moving on..."

#________________________________________________________________________________________


    echo "Setting variable paths..."
    #If given no argument for install directory, set default directory C:\opt
    if($tomcat_path -eq "")
    {
        $Env:TOMCAT ="C:\opt"
        echo "install path set to C:\opt"
    }
    else
    {
        $Env:TOMCAT = $tomcat_path
        echo "install path set to $Env:TOMCAT"
    }


    echo "Finished preparing."
}



function installTomcatService{

    #This will set the service to Automatic startup, rename it to Apache Tomcat 8.0 and start it.

    echo "installing Tomcat8 service..."
    & "$Env:CATALINA_HOME\bin\service.bat" install
    
    & $Env:CATALINA_HOME\bin\tomcat8 //US//Tomcat8 --DisplayName="Apache Tomcat 8.0"

    echo "setting Tomcat8 service to Automatic and starting..."
    Set-Service Tomcat8 -StartupType Automatic
    Start-Service Tomcat8   

    echo "Tomcat8 service set to Automatic and running!"
}

function uninstallTomcatService{

    #This will stop and uninstall the Apache Tomcat 8.0 service

    echo "uninstalling Tomcat8 service..."
    & "$Env:CATALINA_HOME\bin\service.bat" uninstall Tomcat8

}


function installTomcat{

    echo "downloading tomcat archive..."
    
    #Download tomcat archive, unzip to temp directory, copy contents to shrine\tomcat folder
    #and remove the downloads and temp folders
    if(Test-Path $Env:TOMCAT\shrine\_downloads\tomcat.zip){
        Remove-Item $Env:TOMCAT\shrine\_downloads\tomcat.zip
    }
    Invoke-WebRequest $__tomcatDownloadUrl -OutFile $Env:TOMCAT\shrine\_downloads\tomcat8.zip

    echo "download complete."
    echo "unzipping archive..."
    
    unzip $Env:TOMCAT\shrine\_downloads\tomcat8.zip $Env:TOMCAT\shrine

    echo "moving to tomcat directory"

    Copy-Item $Env:TOMCAT\shrine\apache-tomcat-8.0.21\* -Destination $Env:TOMCAT\shrine\tomcat -Container -Recurse
    
    echo "cleaning up..."
    
    Remove-Item $Env:TOMCAT\shrine\_downloads -Recurse
    Remove-Item $Env:TOMCAT\shrine\apache-tomcat-8.0.21 -Recurse

    #This environment variable is required for Tomcat to run and to install as a service
    setEnvironmentVariable "CATALINA_HOME" "$Env:TOMCAT\shrine\tomcat"

    echo "Tomcat is installed."
}

function installShrine{

    echo "Beginning Shrine install..."

    #Creating URLs for downloading source files

    $ShrineQuickInstallUrl = "$_SHRINE_SVN_URL_BASE/code/install/i2b2-1.7/"

    $ShrineWar = "shrine-war-$_SHRINE_VERSION.war"
    $ShrineWarURL = "$_NEXUS_URL_BASE/shrine-war/$_SHRINE_VERSION/$ShrineWar"

    $ShrineProxy = "shrine-proxy-$_SHRINE_VERSION.war"
    $ShrineProxyURL = "$_NEXUS_URL_BASE/shrine-proxy/$_SHRINE_VERSION/$ShrineProxy"

    $ShrineAdapterMappingsURL = "$_SHRINE_SVN_URL_BASE/ontology/SHRINE_Demo_Downloads/AdapterMappings_i2b2_DemoData.xml"
    
    echo "getting source files..."
    echo "downloading shrine and shrine-proxy war files..."
    
    #Download shrine.war and shrine-proxy.war to tomcat
    Invoke-WebRequest $ShrineWarURL  -OutFile $_SHRINE_HOME\setup\shrine.war
    Invoke-WebRequest $ShrineProxyURL  -OutFile $_SHRINE_HOME\setup\shrine-proxy.war
    
    echo "shrine and shrine-proxy war files downloaded."
    echo "downloading shrine-webclient to tomcat..."
    
    #run to copy shrine-webclient to webapps folder in tomcat
    & "$_SHRINE_HOME\setup\svn\svn-win32-1.8.11\bin\svn.exe" checkout $_SHRINE_SVN_URL_BASE/code/shrine-webclient/  $_SHRINE_HOME\setup\shrine-webclient > $null

    echo "shrine-webclient downloaded."
    echo "downloading AdapterMappings.xml file to tomcat..."
   
    Invoke-WebRequest $ShrineAdapterMappingsURL  -OutFile $_SHRINE_HOME\setup\AdapterMappings.xml

    echo "AdapterMappings.xml downloaded."
    echo "Configuring tomcat server settings..."

    #Interpolate tomcat_server_8.xml with common settings
    interpolate_file $__skelDirectory\shrine\tomcat\tomcat_server_8.xml "SHRINE_PORT" $_SHRINE_PORT |
        interpolate "SHRINE_SSL_PORT" $_SHRINE_SSL_PORT | 
        interpolate "KEYSTORE_FILE" "$_SHRINE_HOME\shrine.keystore" |
        interpolate "KEYSTORE_PASSWORD" "changeit" | Out-File -Encoding utf8 $_SHRINE_HOME\setup\ready\server.xml

    echo "complete."
    echo "Configuring Shrine cell files..."

    #Interpolate cell_config_data.js with common settings
    interpolate_file $__skelDirectory\shrine\tomcat\cell_config_data.js "SHRINE_IP" $_SHRINE_IP |
        interpolate "SHRINE_SSL_PORT" $_SHRINE_SSL_PORT > $_SHRINE_HOME\setup\ready\cell_config_data.js

    #Interpolate shrine.xml with common settings
    interpolate_file $__skelDirectory\shrine\tomcat\shrine.xml "SHRINE_SQL_USER" $_SHRINE_MSSQL_USER |
        interpolate "SHRINE_SQL_PASSWORD" $_SHRINE_MSSQL_PASSWORD |
        interpolate "SHRINE_SQL_SERVER" $_SHRINE_MSSQL_SERVER |
        interpolate "SHRINE_SQL_DB" $_SHRINE_MSSQL_DB > $_SHRINE_HOME\setup\ready\shrine.xml

    #Interpolate i2b2_config_data.js with common settings
    interpolate_file $__skelDirectory\shrine\tomcat\i2b2_config_data.js "I2B2_PM_IP" $_I2B2_PM_IP |
        interpolate "SHRINE_NODE_NAME" $_SHRINE_NODE_NAME > $_SHRINE_HOME\setup\ready\i2b2_config_data.js

    #Interpolate shrine.conf with common settings
    interpolate_file $__skelDirectory\shrine\tomcat\shrine.conf "I2B2_PM_IP" $_I2B2_PM_IP | interpolate "I2B2_ONT_IP" $_I2B2_ONT_IP |
        interpolate "SHRINE_ADAPTER_I2B2_DOMAIN" $_SHRINE_ADAPTER_I2B2_DOMAIN |
        interpolate "SHRINE_ADAPTER_I2B2_USER" $_SHRINE_ADAPTER_I2B2_USER | 
        interpolate "SHRINE_ADAPTER_I2B2_PASSWORD" $_SHRINE_ADAPTER_I2B2_PASSWORD |
        interpolate "SHRINE_ADAPTER_I2B2_PROJECT" $_SHRINE_ADAPTER_I2B2_PROJECT |
        interpolate "I2B2_CRC_IP" $_I2B2_CRC_IP | interpolate "SHRINE_NODE_NAME" $_SHRINE_NODE_NAME |
        interpolate "KEYSTORE_FILE" (escape $_KEYSTORE_FILE) | interpolate "KEYSTORE_PASSWORD" $_KEYSTORE_PASSWORD |
        interpolate "KEYSTORE_ALIAS" $_KEYSTORE_ALIAS > $_SHRINE_HOME\setup\ready\shrine.conf

    echo "complete."
    echo "moving configured files to tomcat installation..."

    #Copy relevant files to proper locations
    mkdir $_SHRINE_TOMCAT_HOME\webapps\shrine-webclient
    Copy-Item $_SHRINE_HOME\setup\shrine-webclient\* -Destination $_SHRINE_TOMCAT_HOME\webapps\shrine-webclient -Container -Recurse
    Copy-Item $_SHRINE_HOME\setup\ready\server.xml $_SHRINE_TOMCAT_SERVER_CONF
    Copy-Item $_SHRINE_HOME\setup\ready\shrine.xml $_SHRINE_TOMCAT_APP_CONF
    Copy-Item $_SHRINE_HOME\setup\ready\shrine.conf $_SHRINE_CONF_FILE
    Copy-Item $_SHRINE_HOME\setup\ready\cell_config_data.js $_SHRINE_TOMCAT_HOME\webapps\shrine-webclient\js-i2b2\cells\SHRINE\cell_config_data.js
    Copy-Item $_SHRINE_HOME\setup\ready\i2b2_config_data.js $_SHRINE_TOMCAT_HOME\webapps\shrine-webclient\i2b2_config_data.js
    Copy-Item $_SHRINE_HOME\setup\shrine.war $_SHRINE_TOMCAT_HOME\webapps\shrine.war
    Copy-Item $_SHRINE_HOME\setup\shrine-proxy.war $_SHRINE_TOMCAT_HOME\webapps\shrine-proxy.war
    Copy-Item $_SHRINE_HOME\setup\AdapterMappings.xml $_SHRINE_TOMCAT_LIB
    Copy-Item $__skelDirectory\shrine\sqlserver\sqljdbc4.jar $_SHRINE_TOMCAT_LIB\sqljdbc4.jar

    echo "move complete."
    echo "Cleaning Up..."


    #Remove Shrine Setup Directory
    Remove-Item $_SHRINE_HOME\setup -Recurse -Force

    echo "all clean!"
    echo "restarting Tomcat Service (if installed)..."

    Restart-Service Tomcat8

    echo "Shrine installation complete!"
    }

function createCert{

    #This function will generate a keypair and a keystore according to the settings in common.ps1
    #It will export the created certificate to the $_SHRINE_HOME location

    echo "Generating Shrine keystore and SSL certificate..."

    keytool -genkeypair -keysize 2048 -alias $_KEYSTORE_ALIAS -dname "CN=$_KEYSTORE_ALIAS, OU=$_KEYSTORE_HUMAN, O=SHRINE Network, L=$_KEYSTORE_CITY, S=$_KEYSTORE_STATE, C=$_KEYSTORE_COUNTRY" -keyalg RSA -keypass $_KEYSTORE_PASSWORD -storepass $_KEYSTORE_PASSWORD -keystore $_KEYSTORE_FILE -validity 7300
    keytool -export -alias $_KEYSTORE_ALIAS -keystore $_KEYSTORE_FILE -storepass $_KEYSTORE_PASSWORD -file "$_SHRINE_HOME\$_KEYSTORE_ALIAS.cer"

    echo "complete."
}

$__timer = [Diagnostics.Stopwatch]::StartNew()

prepareInstall
installTomcat
installTomcatService
createCert
installShrine

.\shrine-data.ps1
    
formatElapsedTime $__timer.Elapsed
