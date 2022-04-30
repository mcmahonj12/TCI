#Author: Jim McMahon II
#Date: 3/1/2022
#Pre-Requisites: 
#PowerCLI Version: 7+
#Modules: VMware.PowerCLI
#Usage: Add-VIPermission -FilePath ".\config\global\vc\permissions\globalPermissions.json"
#Adds desired VI permissions at folder levels from the idsources.json file. Please feel free to modify to add additional permissions at other object levels.
#Little to no error checking. Use at your own risk.

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, Position = 1, HelpMessage = 'Path to the JSON file describing the role')]
    [ValidateNotNullorEmpty()]
    [Alias("Permission")]
    [String]$FilePath
)

# Attempt to find the file path before continuing. It's required to set the ID Sources.
Try {
    if (-not(Test-Path $filePath -ErrorAction Stop)) {
        Throw
    }
}
Catch {
    Write-Warning "The VI permissions configuration file path ($filePath) is not valid. Please check the path and try again."
    Exit
}

# Configure the VI permissions.
#$filePath = ".\config\global\vc\permissions\globalPermissions.json" 
$perms = Get-Content -Raw $filePath | ConvertFrom-Json

$perms | Foreach-Object ($_) {
    New-VIPermission -Principal $_.principal -Role $_.Role -Entity (Get-Folder $_.Entity) -Propagate $_.propogate}