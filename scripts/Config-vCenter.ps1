$vCenter = "vc-mkt-4.dishwasher.cloud"
$rolePath = ".\config\global\vc\roles\*.json"
$idPath = ".\config\global\vc\idsrc\idsources.json"
$permsPath = ".\config\local\vc\permissions\vc-mkt-4-perms.json"
$creds = Get-Credential

#Connect to the target vCenter Server
Connect-VIServer -server $vCenter -Credential $creds

# Import the VIRole sciprt as a module
Import-Module -Name ".\scripts\Import-VIRole.ps1"

Import-VIRole -RolePath $rolePath
Pause

.\scripts\Add-VcIdSource.ps1 -ViServer $vcenter -Credential $creds -FilePath $idPath
Pause

.\scripts\Add-VIPermissions.ps1 -FilePath $permsPath

Disconnect-VIServer -Confirm:$false