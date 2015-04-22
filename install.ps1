
<#
.SYNOPSIS
Install i2b2 on a windows server

.DESCRIPTION
This scripts is used to install i2b2 or portions of an i2b2 system such as the web client, databases, demo data etc.

.PARAMETER InstallPrereqs
Install the required software Java, Ant and JBoss (including JBoss as a service) as discussed in the i2b2 Server Requirements section of the installation guide.

.PARAMETER InstallDatabases
Run the ant scripts from the Data Installation Section of the Installation Guide

.PARAMETER InstallDemoData
Loads the i2b2 demo data into after creating the i2b2 database(s)

.PARAMETER InstallCells
Compiles and deploys all of the i2b2 core cells

.PARAMETER InstallWebClient
Extracts the i2b2 web client to the IIS default web site

.PARAMETER InstallAdminTool
Extracts the i2b2 admin tool to the IIS default web site

.PARAMETER InstallShrine
Runs automated install for the SHRINE extension of i2b2

.EXAMPLE
.\install
Runs the installation of the i2b2 Server Requirements, i2b2 cells, the Data Installation process and loads the demo data

.EXAMPLE
.\install -d $false
Runs the installation of the i2b2 Server Requirements and skips the Data Installation process

.EXAMPLE
.\install -demo $false
Runs the installation of the i2b2 Server Requirements and the Data Installation process but does not load the demo data

.EXAMPLE
.\install -p $false
Skips the installation of the i2b2 Server Requirements and runs the rest of the installation process assuming the pre-reqs are already installed

.EXAMPLE
.\install -p $false -d $false
Skips the installation of the i2b2 Server Requirements and the Data Installation process and runs the rest of the installation process assuming the pre-reqs are already installed

.\install -s $true
Runs the installation of the i2b2 Server Requirements, i2b2 cells, the Data Installation process, loads the demo data and installs shrine

#>
[CmdletBinding()]
Param(
    [parameter(Mandatory=$false)]
	[alias("p")]
	[bool]$InstallPrereqs=$true,

    [parameter(Mandatory=$false)]
	[alias("d")]
	[bool]$InstallDatabases=$true,

    [parameter(Mandatory=$false)]
	[alias("demo")]
	[bool]$InstallDemoData=$true,

    [parameter(Mandatory=$false)]
	[alias("c")]
	[bool]$InstallCells=$true,

    [parameter(Mandatory=$false)]
	[alias("w")]
	[bool]$InstallWebClient=$true,

    [parameter(Mandatory=$false)]
	[alias("a")]
	[bool]$InstallAdminTool=$true,
    
    [parameter(Mandatory=$false)]
	[alias("s")]
	[bool]$InstallShrine=$false
)

$__timer = [Diagnostics.Stopwatch]::StartNew()

. .\functions.ps1
. .\configuration.ps1
. .\config-i2b2.ps1

 if((Test-Path $__rootFolder) -ne  $true){

    New-Item $__rootFolder -Type directory -Force > $null

    echo "Created " $__rootFolder
}
  

#Create a directory to work out of
createTempFolder

if($InstallPrereqs -eq $true){
    . .\install-prereqs.ps1
}

if($InstallDatabases -eq $true){    
    . .\install-data.ps1
}

if($InstallCells -eq $true){
    . .\install-i2b2.ps1 
}

if($InstallShrine -eq $true){
    . .\install_shrine.ps1
}

#clean up after ourself
removeTempFolder

if((Get-Service jboss).Status -eq "Stopped") {    
    Start-Service -Name JBOSS
}

formatElapsedTime $__timer.Elapsed