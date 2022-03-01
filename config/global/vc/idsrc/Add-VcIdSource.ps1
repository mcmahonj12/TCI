#Author: Jim McMahon II
#Date: 3/1/2022
#Pre-Requisites: 
#PowerCLI Version: 7+
#Modules: Install-Module -Name VMware.vSphere.SsoAdmin
#Update idsources.json with the required data for the LDAP ID Source to be added to vCenter Server. Update the file location for the Identity Source configuration.

$filePath = "C:\myworkspace\config\idsources.json" 
$ldap =Get-Content -Raw $filePath | ConvertFrom-Json

$ldap.IdSources | Foreach ($_) {
Add-LDAPIdentitySource -Name $_.Name -DomainName $_.DomainName -DomainAlias $_.DomainAlias -PrimaryUrl $_.PrimaryUrl -BaseDNUsers $_.BaseDNUsers -BaseDNGroups $_.BaseDNGroups -Username $_.BindUser -Password "VMware1!"}
