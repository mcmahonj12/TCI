#Author: Jim McMahon II
#Date: 3/1/2022
#Pre-Requisites: 
#PowerCLI Version: 7+
#Modules: Install-Module -Name VMware.vSphere.SsoAdmin
#Usage: Add-VcIdSource -FilePath ".\config\global\vc\permissions\globalPermissions.json"
#Update idsources.json with the required data for the LDAP ID Source to be added to vCenter Server. Update the file location for the Identity Source configuration.
#Little to no error checking. Use at your own risk.

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, Position = 1, HelpMessage = 'Path to the JSON file describing the role')]
    [ValidateNotNullorEmpty()]
    [Alias("Permission")]
    [String]$FilePath
)

# Check for the Sso module as this is a pre-requisite. Exit the script if unavailable.
$ModuleExists = Get-Module -Name "VMware.vSphere.SsoAdmin"
if (!($ModuleExists)) {
    Write-Verbose -Message "The module VMware.vSphere.SsoAdmin was not found. Please install the module before continuing. Exiting."
    Exit
}

# Attempt to find the file path before continuing. It's required to set the ID Sources.
Try {
    if (-not(Test-Path $filePath -ErrorAction Stop)) {
        Throw
    }
}
Catch {
    Write-Warning "The id soure configuration file path ($filePath) is not valid. Please check the path and try again."
    Exit
}

# Configure the ID sources.
#$filePath = ".\config\global\vc\permissions\globalPermissions.json"
$ldap =Get-Content -Raw $filePath | ConvertFrom-Json

$ldap | Foreach-Object ($_) {
Add-LDAPIdentitySource -Name $_.Name -DomainName $_.DomainName -DomainAlias $_.DomainAlias -PrimaryUrl $_.PrimaryUrl -BaseDNUsers $_.BaseDNUsers -BaseDNGroups $_.BaseDNGroups -Username $_.BindUser -Password "VMware1!"}