echo "Loading system configuration"

##############################
#DO NOT EDIT: SYSTEM VARIABLES
##############################
Add-Type -AssemblyName System.IO.Compression.FileSystem
$OutputEncoding=[System.Text.UTF8Encoding]::UTF8
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

$__jbossInstallFolder = "c:\opt\jboss"
$__webclientInstallFolder = "c:\inetpub\wwwroot"

$__logFileName = "$(Get-Date -Format g)_i2b2_install.log"
$__currentDirectory = (Get-Item -Path ".\" -Verbose).FullName
$__skelDirectory = $__currentDirectory + "\skel"
$__tempFolder = $__currentDirectory + "\.temp"
$__sourceCodeRootFolder = $__tempFolder + "\i2b2"


$__sourceCodeZipFile = $__skelDirectory + "\i2b2\i2b2core-src-1704.zip"
$__dataInstallationZipFile = $__skelDirectory + "\i2b2\i2b2createdb-1704.zip"
$__webclientZipFile = $__skelDirectory + "\i2b2\i2b2webclient-1704.zip"

setEnvironmentVariable NOPAUSE 1

##############################
#END SYSTEM VARIABLES
##############################
