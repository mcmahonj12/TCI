
$vCenter = "vc-mkt-4.dishwasher.cloud"
$creds = Get-Credential

#Connect to the target vCenter Server
Connect-VIServer -server $vCenter -Credential $creds

# Import the VIRole sciprt as a module
Import-Module -Name ".\scripts\Import-VIRole.ps1"

Import-VIRole -RolePath ".\config\global\vc\roles\*.json"
Pause

.\scripts\Add-VcIdSource.ps1 -ViServer $vcenter -Credential $creds -FilePath ".\config\global\vc\idsrc\idsources.json"
Pause

.\scripts\Add-VIPermissions.ps1 -FilePath ".\config\global\vc\permissions\globalPermissions.json"

Disconnect-VIServer -Confirm:$false