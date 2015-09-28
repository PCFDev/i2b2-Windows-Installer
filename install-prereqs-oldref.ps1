
#require $env:JAVA_HOME "JAVA_HOME must be set"
#require $env:ANT_HOME "ANT_HOME must be set"
#require $env:JBOSS_HOME "JBOSS_HOME must be set"
#require $JBOSS_ADDRESS "JBOSS_ADDRESS must be set"
#require $JBOSS_PORT "JBOSS_PORT must be set"
#require $JBOSS_ADMIN "JBOSS_ADMIN must be set"
#require $JBOSS_PASS "JBOSS_PASS must be set"

#Install chocolatey https://chocolatey.org/
function installChocolatey{
	if ((Get-Command choco) -eq $null){
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

function installJava-sloppy{

	#SLOPPY STUFF HERE... Why will $env:JAVA_HOME not update!!!
	
	echo "Java Installing"
	echo "0) JAVA_HOME set to: $env:JAVA_HOME"
	$jp = [Environment]::GetEnvironmentVariable("JAVA_HOME", "Machine")
	echo "0) JAVA_HOME set to: $jp" 
	
	choco install jdk7 -y

	echo "1) JAVA_HOME set to: $env:JAVA_HOME"
	$jp = [Environment]::GetEnvironmentVariable("JAVA_HOME", "Machine")
	echo "1) JAVA_HOME set to: $jp" 
	
	#this choco package does not update the session so we do it here to ensure java_home is set...	
	Update-SessionEnvironment
  
	
	if($env:JAVA_HOME -eq ''){
		[Environment]::SetEnvironmentVariable("JAVA_HOME", ((Get-ItemProperty -path "HKLM:\SOFTWARE\JavaSoft\Java Development Kit\1.7.0_79" -name "JavaHome") | select -expandproperty JavaHome), "Machine")
		#$javaDir = (Get-ItemProperty -path "HKLM:\SOFTWARE\JavaSoft\Java Development Kit\1.7.0_79" -name "JavaHome") | select -expandproperty JavaHome
		#Set-EnvironmentVariable -Name "JAVA_HOME" -Value $javaDir -Scope 'Machine'
	
		Update-SessionEnvironment
  	
		echo "2) JAVA_HOME set to: $env:JAVA_HOME"
		$jp = [Environment]::GetEnvironmentVariable("JAVA_HOME", "Machine")
		echo "2) JAVA_HOME set to: $jp"
	}
	
	echo "Java Installed"
}


function installJava{

	echo "Installing Java"
	
	choco install jdk7 -y
		
	$__java_home = ((Get-ItemProperty -path "HKLM:\SOFTWARE\JavaSoft\Java Development Kit\1.7.0_79" -name "JavaHome") | select -expandproperty JavaHome)
	
	[Environment]::SetEnvironmentVariable("JAVA_HOME", $__java_home, "Machine")
	
	$env:JAVA_HOME = $__java_home

	echo "2) JAVA_HOME set to: $env:JAVA_HOME"
	$jp = [Environment]::GetEnvironmentVariable("JAVA_HOME", "Machine")
	echo "2) JAVA_HOME set to: $jp"

	echo "Java Installed"
}


function installAnt {
	echo "Installing Ant"
	
    if((isAntInstalled) -eq $false){

		choco install ant -y -i

        #addToPath "$env:ANT_HOME\bin;"
    }
	echo "ANT_HOME set to: $env:ANT_HOME"
    echo "Ant Installed"
}

function installJBoss{
    if((test-path $env:JBOSS_HOME) -eq $false){
      
        echo "Downloading $__jbossDownloadUrl"

        wget $__jbossDownloadUrl -OutFile $__tempFolder\jboss.zip
     
        echo "JBOSS downloaded"

        echo "Installing JBOSS"

        unzip $__tempFolder\jboss.zip $env:JBOSS_HOME\..\

        mv $env:JBOSS_HOME\..\$__jbossFolderName $env:JBOSS_HOME

        mv $env:JBOSS_HOME\standalone\configuration\standalone.xml $env:JBOSS_HOME\standalone\configuration\standalone.xml.bak

        interpolate_file skel\jboss\standalone.xml JBOSS_ADDRESS $JBOSS_ADDRESS |
            interpolate JBOSS_PORT $JBOSS_PORT | 
            Out-File -Encoding utf8 $env:JBOSS_HOME\standalone\configuration\standalone.xml
    
        addToPath "$env:JBOSS_HOME\bin;"

    }
    echo "JBOSS Installed"
}

function installJBossService{
    $jbossSvc = Get-Service jboss*
    if($jbossSvc -eq $null){
        echo "Downloading $__jbossServiceDownloadUrl"
    
        wget $__jbossServiceDownloadUrl -OutFile $__tempFolder\jboss-svc.zip
            
        echo "JBOSS Service downloaded"

        echo "Installing JBOSS Service"
        
        unzip $__tempFolder\jboss-svc.zip $env:JBOSS_HOME
        
        cp skel\jboss\service.bat $env:JBOSS_HOME\bin\service.bat -force
    
        &$env:JBOSS_HOME\bin\service.bat install

        Set-Service jboss -StartupType Automatic
       
        echo "Adding management user to JBOSS"

        $hashPass = hash ($JBOSS_ADMIN + ":ManagementRealm:" + $JBOSS_PASS)

        $jbossUser = "$JBOSS_ADMIN=$hashPass" 

        echo $jbossUser

        echo ([Environment]::NewLine)$jbossUser |
            Out-File  $env:JBOSS_HOME\standalone\configuration\mgmt-users.properties -Append -Encoding utf8
    }
    echo "JBOSS service installed"
}

function installAxis{
	$__axisVersion = "1.6.1"
	$__axisDownloadUrl = "http://archive.apache.org/dist/axis/axis2/java/core/$__axisVersion/axis2-$__axisVersion-war.zip"

    if(!(Test-Path "$env:JBOSS_HOME\webapps\i2b2"))
    {
        
        echo "Downloading AXIS"
       
        wget $__axisDownloadUrl -OutFile $__tempFolder\axis2-$__axisVersion-war.zip
      
        echo "AXIS downloaded"

        echo "Installing AXIS War"

        unzip $__tempFolder\axis2-$__axisVersion-war.zip $__tempFolder\axis2-$__axisVersion-war $true
  
        unzip $__tempFolder\axis2-$__axisVersion-war\axis2.war $__tempFolder\i2b2 $true

        mv -Force $__tempFolder\i2b2\ $env:CATALINA_HOME\webapps\

        #echo "" > $env:JBOSS_HOME\webapps\i2b2.war.dodeploy
   

    }

    echo "AXIS War Installed"
}

function installIIS {
    $iis =  Get-WindowsOptionalFeature -FeatureName IIS-WebServerRole -Online

    if($iis.State -ne "Enabled"){
        echo "Installing IIS"
    
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole -NoRestart
    }
    echo "IIS Installed"
}

function installPHP{

    if((Test-Path $__phpInstallFolder) -eq $false){


        echo "Installing PHP"

		choco install php -y
		
        #unzip $__tempFolder/php.zip $__phpInstallFolder
        #cp $__skelDirectory\php\php.ini $__phpInstallFolder\php.ini
     
   
    }
    echo "PHP Installed"
}

#Takes the boolean value $service for option to install tomcat service
#$service is true by default
function installTomcat($service=$true){

	echo "Installing Tomcat"
 
    #This environment variable is required for Tomcat to run and to install as a service
    #setEnvironmentVariable "CATALINA_HOME" $_SHRINE_HOME\tomcat

	#$params = "/InstallLocation="" + $env:JBOSS_HOME +"""
	#echo params: $params
	#choco install tomcat -packageparameters '$params' -y -i -version 8.0.26

	choco install tomcat -y -i -version 8.0.26
	
	#this choco package does not update session so we do here
	Update-SessionEnvironment
	$env:JBOSS_HOME = $env:CATALINA_HOME\webapps
	Update-SessionEnvironment
	
	echo "CATALINA_HOME set to: $env:CATALINA_HOME"
	echo "JBOSS_HOME set to: $env:JBOSS_HOME"
    echo "Tomcat is installed."
}

installChocolatey
installJava
installAnt

#if($InstallCells -eq $true){
#    #installJBoss
#    #installJBossService
#	installTomcat
#    installAxis
#}
installTomcat
installAxis

if(($InstallWebClient -eq $true) -or ($InstallAdminTool -eq $true)){
    installIIS
    installPHP
}

#if($InstallShrine -eq $true){
#    installTomcat
#}