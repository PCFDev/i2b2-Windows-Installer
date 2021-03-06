﻿<#
.SYNOPSIS
Uninstall i2b2 from a windows server

.DESCRIPTION
This scripts is used to uninstall i2b2 or portions of an i2b2 system such as the web client, databases, demo data etc.

.PARAMETER RemovePrereqs
Remove the required software Java, Ant and JBoss (including JBoss as a service) as discussed in the i2b2 Server Requirements section of the installation guide.

.PARAMETER RemoveDatabases
Drops the i2b2 database(s) as described Data Installation Section of the Installation Guide. WARNING!!!! THIS CANNOT BE UNDONE. THE DATA IN THESE DATABASES WILL BE LOST

.PARAMETER RemoveCells
Removes the JBOSS deployments on the i2b2 core cells

.PARAMETER RemoveWebClient
Deletes the i2b2 web client from the IIS default web site

.PARAMETER RemoveWebClient
Deletes the i2b2 admin tool from the IIS default web site

.PARAMETER RemoveShrine
Removes the Tomcat installation along with the shrine installation. Will also remove shrine database entries if RemoveDatabases is also true


.EXAMPLE
.\uninstall
Removes the installation of the i2b2 Server Requirements, i2b2 cells, the web client and the admin tool. By default the script leaves the database(s) intact

.EXAMPLE
.\uninstall -d $true
Removes the installation of the i2b2 Server Requirements, i2b2 cells, the web client and the admin tool and drops all of the i2b2 databases

.EXAMPLE
.\uninstall -c $false
Removes the installation of the i2b2 Server Requirements, the web client and the admin tool. The i2b2 cell deployments are backed up and leaves the database(s) intact

#>
[CmdletBinding()]
Param(
    [parameter(Mandatory=$false)]
	[alias("p")]
	[bool]$RemovePrereqs=$true,

    [parameter(Mandatory=$false)]
	[alias("d")]
	[bool]$RemoveDatabases=$false,

    [parameter(Mandatory=$false)]
	[alias("c")]
	[bool]$RemoveCells=$true,
	
    [parameter(Mandatory=$false)]
	[alias("w")]
	[bool]$RemoveWebClient=$true,

    [parameter(Mandatory=$false)]
	[alias("a")]
	[bool]$RemoveAdminTool=$true,
	
	[parameter(Mandatory=$false)]
	[alias("s")]
	[bool]$RemoveShrine=$true
	
)

. .\functions.ps1
. .\config-system.ps1
. .\config-i2b2.ps1

function createBackupFolder{
    if((Test-Path $__rootFolder) -ne  $true){

        New-Item $__rootFolder -Type directory -Force > $null

        echo "Created " $__rootFolder
    }


    if((Test-Path $__rootFolder\backup) -ne  $true){

        New-Item $__rootFolder\backup -Type directory -Force > $null

        echo "Created $__rootFolder\backup"
    }
}

function removeJBOSS {

    if(Test-Path $env:JBOSS_HOME){

           
        Stop-Service jboss
        #&$env:JBOSS_HOME\bin\service.bat stop
        &$env:JBOSS_HOME\bin\service.bat uninstall

        Remove-Item $env:JBOSS_HOME\licenses -recurse -force
        Remove-Item $env:JBOSS_HOME\bin\native -recurse -force
        Remove-Item $env:JBOSS_HOME\bin\*.exe -force
        Remove-Item $env:JBOSS_HOME\bin\service.bat -force
        Remove-Item $env:JBOSS_HOME\bin\README-service.txt -force

        echo "Removing JBOSS..."

        if($RemoveCells -eq $false){

           createBackupFolder           

	       cp $env:JBOSS_HOME\standalone $__rootFolder\backup\

           echo "I2B2 Cells backuped up to $__rootFolder\backup\"
        }

        Remove-Item  $env:JBOSS_HOME -recurse -force

        removeFromPath "$env:JBOSS_HOME\bin"    
        [Environment]::SetEnvironmentVariable("JBOSS_HOME",$null,"Machine")
    } 

  
}

function removeJava {

    $java = Get-WmiObject -Class win32_product | where { $_.Name -like "*Java*"}

    if ($java -ne $null)
    {        
        foreach ($app in $java)
        {
    
            write-host "Removing " $app.Name "..."
            #write-host $app.LocalPackage
            #write-host $app.IdentifyingNumber
   
            &cmd /c "msiexec /uninstall $($app.IdentifyingNumber) /quiet /norestart"
        }

        removeFromPath "$env:JAVA_HOME\bin"
        [Environment]::SetEnvironmentVariable("JAVA_HOME",$null,"Machine")

    }
    else { Write-Host "java not installed..." }
}

function removeAnt {

    if(Test-Path "c:\opt\ant"){
        write-host "Removing Ant..."
	    Remove-Item  "c:\opt\ant" -recurse -force
        removeFromPath "$env:ANT_HOME\bin"
        [Environment]::SetEnvironmentVariable("ANT_HOME",$null,"Machine")
    }    
}
 
function removeIIS{
    $iis =  Get-WindowsOptionalFeature -FeatureName IIS-WebServerRole -Online

    if($iis.State -eq "Enabled"){
        echo "Removing IIS"
        Disable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole -NoRestart
    }

 }

function removePHP{
    if(Test-Path "c:\php"){
        echo "Removing PHP"
        exec iisreset '/stop'
        Remove-Item  "c:\php" -recurse -force
        removeFromPath "c:\php"
        exec iisreset '/start'

    }
 }

function removeDatabases{

    $conn = New-Object System.Data.SqlClient.SqlConnection
    $conn.ConnectionString = "Server=$DEFAULT_DB_SERVER;Database=master;Uid=$DEFAULT_DB_ADMIN_USER;Pwd=$DEFAULT_DB_ADMIN_PASS;"

     try{    

        $conn.Open() > $null    
        echo "Connected to $DEFAULT_DB_SERVER"

        removeUser $CRC_DB_NAME $CRC_DB_USER $CRC_DB_PASS $DEFAULT_DB_SCHEMA    
        removeDatabase $CRC_DB_NAME

        removeUser $HIVE_DB_NAME $HIVE_DB_USER $HIVE_DB_PASS $DEFAULT_DB_SCHEMA    
        removeDatabase $HIVE_DB_NAME

        removeUser $IM_DB_NAME $IM_DB_USER $IM_DB_PASS $DEFAULT_DB_SCHEMA    
        removeDatabase $IM_DB_NAME

        removeUser $ONT_DB_NAME $ONT_DB_USER $ONT_DB_PASS $DEFAULT_DB_SCHEMA    
        removeDatabase $ONT_DB_NAME

        removeUser $PM_DB_NAME $PM_DB_USER $PM_DB_PASS $DEFAULT_DB_SCHEMA    
        removeDatabase $PM_DB_NAME
    
        removeUser $WORK_DB_NAME $WORK_DB_USER $WORK_DB_PASS $DEFAULT_DB_SCHEMA    
        removeDatabase $WORK_DB_NAME

    
    }
    catch {
        echo "Could not conect to database server: $DEFAULT_DB_SERVER"
    
    }
}

if($RemoveShrine -eq $true){
	.\uninstall-shrine.ps1
}

if($RemoveDatabases -eq $true){

	#QUESTION? should we verify that cells are being removed? Doing so would allow shrine databases to be removed without removing i2b2 databases...
    removeDatabases
}

if($RemoveWebClient -eq $true -And (Test-Path $__webclientInstallFolder\webclient)){    
    rm -r $__webclientInstallFolder\webclient -Force
}

if($RemoveAdminTool -eq $true -And (Test-Path  $__webclientInstallFolder\admin)){
   rm -r $__webclientInstallFolder\admin -Force
}

if($RemovePrereqs -eq $true){  
    removeAnt
    removeJBOSS
	if($RemoveShrine -eq $true -or !(Test-Path $__rootFolder\shrine)){
		removeJava}
    removePHP
    removeIIS
}

echo "done."