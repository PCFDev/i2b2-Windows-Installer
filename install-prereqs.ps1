require $JBOSS_ADDRESS "JBOSS_ADDRESS must be set"
require $JBOSS_PORT "JBOSS_PORT must be set"
require $JBOSS_ADMIN "JBOSS_ADMIN must be set"
require $JBOSS_PASS "JBOSS_PASS must be set"

#Install chocolatey https://chocolatey.org/
function installChocolatey{
	if ((Get-Command choco) -eq $null){
		echo "Installing Chocolatey"
		iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
	}
}
#region Choco Functions...
function Get-EnvironmentVariable([string] $Name, [System.EnvironmentVariableTarget] $Scope) {
    [Environment]::GetEnvironmentVariable($Name, $Scope)
}
function Get-EnvironmentVariableNames([System.EnvironmentVariableTarget] $Scope) {
    switch ($Scope) {
        'User' { Get-Item 'HKCU:\Environment' | Select-Object -ExpandProperty Property }
        'Machine' { Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' | Select-Object -ExpandProperty Property }
        'Process' { Get-ChildItem Env:\ | Select-Object -ExpandProperty Key }
        default { throw "Unsupported environment scope: $Scope" }
    }
}
function Update-SessionEnvironment{
	Write-Debug "Running 'Update-SessionEnvironment' - Updating the environment variables for the session."

	#ordering is important here, $user comes after so we can override $machine
	'Machine', 'User' |
		% {
		  $scope = $_
		  Get-EnvironmentVariableNames -Scope $scope |
			% {
			  Set-Item "Env:$($_)" -Value (Get-EnvironmentVariable -Scope $scope -Name $_)
			}
		}

	  #Path gets special treatment b/c it munges the two together
	  $paths = 'Machine', 'User' |
		% {
		  (Get-EnvironmentVariable -Name 'PATH' -Scope $_) -split ';'
		} |
		Select -Unique
	  $Env:PATH = $paths -join ';'
}
#endregion Choco Functions

function installJava{

	echo "Installing Java"
	
	choco install jdk7 -y -version 7.0.79
	
	Update-SessionEnvironment
	
	
	$java_home = Join-Path (Get-Item "Env:ProgramFiles").Value "Java\jdk1.7.0_79"
	
	setEnvironmentVariable "JAVA_HOME" $java_home
	
	echo "JAVA_HOME set to: $env:JAVA_HOME"


	#$env:JAVA_HOME = $java_home
	#echo "JAVA_HOME set (again) to: $env:JAVA_HOME"
	
	
	if($env:JAVA_HOME -eq $null){
		throw "JAVA_HOME not set"
	}
	echo "Java Installed"
}


function installAnt {
	echo "Installing Ant"	
	choco install ant -yi
	
	Update-SessionEnvironment
	echo "ANT_HOME set to: $env:ANT_HOME"
	
	addToPath $env:ANT_HOME\bin		
    echo "Ant Installed"
}


#Takes the boolean value $service for option to install tomcat service
#$service is true by default
function installTomcat($service=$true){

	echo "Installing Tomcat"

	choco install tomcat -y -i -version 7.0.59
	
	Update-SessionEnvironment
	
	echo "CATALINA_HOME set to: $env:CATALINA_HOME"
	echo "Tomcat is installed."
}


function installJBoss{
	echo "Installing JBoss"
	
	#note: remove the source once the package is approved
	choco install jboss-as -yi -params "/InstallationPath:$__jbossInstallFolder  /Username:$JBOSS_ADMIN /Password:$JBOSS_PASS /Start:false" -source $__skelDirectory
	
	Update-SessionEnvironment	
	echo "JBOSS_HOME set to: $env:JBOSS_HOME"
	
	if($env:JBOSS_HOME -ne $__jbossInstallFolder){
		throw "JBOSS_HOME not set"
	}
	
	mv -force $env:JBOSS_HOME\standalone\configuration\standalone.xml $env:JBOSS_HOME\standalone\configuration\standalone.xml.bak

	interpolate_file skel\jboss\standalone.xml JBOSS_ADDRESS $JBOSS_ADDRESS |
		interpolate JBOSS_PORT $JBOSS_PORT | 
		Out-File -Encoding utf8 $env:JBOSS_HOME\standalone\configuration\standalone.xml
		
	echo "JBoss Installed"
}

function installAxis{
	echo "Installing AXIS War"
	
	#note: remove the source once the package is approved
	choco install axis2-war -iy -version 1.6.1 -params "/InstallationPath: $env:JBOSS_HOME\standalone\deployments\i2b2.war" -source $__skelDirectory
	
	echo "" >  $env:JBOSS_HOME\standalone\deployments\i2b2.war.dodeploy

    echo "AXIS War Installed"
}

function installIIS {
	echo "Installing IIS"
	
    $iis =  Get-WindowsOptionalFeature -FeatureName IIS-WebServerRole -Online

    if($iis.State -ne "Enabled"){
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole -NoRestart
    }
    
	echo "IIS Installed"
}

function installPHP{
	echo "Installing PHP"

	choco install vcredist2012 -y #need vc++ redist package
	choco install php -y
  
	cp $__skelDirectory\php\php.ini "c:\tools\php\php.ini" -force #enable curl
	
	echo "Configuring IIS"
	    
	#enable required IIS freatures
	#$cgi =  Get-WindowsOptionalFeature -FeatureName IIS-CGI -Online
	Enable-WindowsOptionalFeature -Online -FeatureName IIS-CGI -NoRestart
	Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIExtensions -NoRestart
	Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIFilter -NoRestart
	
	#Reference: http://php.net/manual/en/install.windows.iis7.php	
    #Creating IIS FastCGI process pool
    & $env:WinDir\system32\inetsrv\appcmd.exe set config -section:system.webServer/fastCgi /+"[fullPath='c:\tools\php\php-cgi.exe']" /commit:apphost
    
    #Creating handler mapping for PHP requests      
    & $env:WinDir\system32\inetsrv\appcmd.exe set config  -section:system.webServer/handlers /+"[name='PHP-FastCGI',path='*.php',verb='GET,HEAD,POST',modules='FastCgiModule',scriptProcessor='c:\tools\php\php-cgi.exe',resourceType='Either']"	

	echo "IIS Configured"
	echo "PHP Installed"
}


installChocolatey
installJava
installAnt

if($InstallCells -eq $true){
    installJBoss
    installAxis
}

if(($InstallWebClient -eq $true) -or ($InstallAdminTool -eq $true)){
    installIIS
    installPHP
}

if($InstallShrine -eq $true){
    installTomcat
}
