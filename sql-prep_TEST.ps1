Add-Type -Path 'C:\Program Files\Microsoft SQL Server\110\SDK\Assemblies\Microsoft.SqlServer.Smo.dll'

sqlps -Command {
$smo = 'Microsoft.SqlServer.Management.Smo.'
$wmi = New-Object ($smo + 'Wmi.ManagedComputer')

$Wmi

$uri = "ManagedComputer[@Name='" + (Get-Item Env:\COMPUTERNAME).Value + "']/ServerInstance[@Name='MSSQLSERVER']/ServerProtocol[@Name='TCP']"
$Tcp = $wmi.GetSmoObject($uri)
$Tcp.isEnabled = $true
$Tcp.Alter()
$Tcp

}

net stop mssqlserver
Start-Sleep -Seconds 5
net start mssqlserver