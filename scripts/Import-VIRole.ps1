function Import-VIRole {
    <#  
        .SYNOPSIS
        Imports a vSphere role based on pre-defined configuration values
        .DESCRIPTION
        The Import-VIRole cmdlet is used to parse through a list of pre-defined privileges to create a new role. Often, this is to support a particular vendor's set of requirements for access into vSphere.
        .PARAMETER RolePath
        Path to the JSON file describing the role, including the privileges
        .EXAMPLE
        Import-VIRole -RoleFile "C:\Banana.json" -Overwrite:$false
        Creates a new role named Banana, using the privileges list stored in Banana.json, and applies it to the VC1.FQDN vCenter Server
        .NOTES
        This script assumes a vCenter Server connection has already been established. To add roles to additional vCenter Servers, consider using this script as part of a larger script rolling through vCenter connections.
        Written by Chris Wahl for community usage
        Modified by Jim McMahon II
        
        Maintained by Rob Nelson and contributors.
        .LINK
        https://github.com/rnelson0/vCenter-roles/
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 1, HelpMessage = 'Path to the JSON file describing the role')]
        [ValidateNotNullorEmpty()]
        [Alias("Permission")]
        [String]$RolePath,
        [Parameter(Position = 3, HelpMessage = 'Overwrites existing Role by same name')]
        [Switch]$Overwrite = $false
    )

    Process {
        $files = Get-ChildItem $RolePath
        $files | ForEach-Object {
            $content = Get-Content $_ -raw | ConvertFrom-Json
            $content.roles | Foreach-Object {
                $Name = $_.Name
                Write-Host $name
                $RoleExists = Get-VIRole -Name $Name #-Server $vCenter -ErrorAction SilentlyContinue
                <#if ($RoleExists -And (! $Overwrite)) {
                Throw 'Role already exists.'
            }#>

                $PrivilegesArray = $_.privileges
                Write-Verbose -Message 'Parse the privileges array for IDs'
                $PrivilegesList = Get-VIPrivilege -Id $PrivilegesArray -ErrorVariable MissingPerm -ErrorAction SilentlyContinue

                Write-Verbose -Message "Identify any privileges in the list that are not present on vCenter server '$vCenter'"
                if ($MissingPrivileges) {
                    foreach ($MissingPrivilege in $MissingPrivileges) {
                        $PrivilegesID = ($MissingPrivilege.Exception.Message.Split("'"))[1]
                        Write-Warning -Message "Privilege ID '$PrivilegesID' not found"
                    }
                }

                if (!($RoleExists)) {
                    Write-Verbose -Message "Creating the role '$Name'"
                    New-VIRole -Name $Name | Set-VIRole -AddPrivilege $PrivilegesList
                }
            
                elseif ($RoleExists -And ($OverWrite)) {
                    Write-Verbose -Message "Overwriting the role '$Name'"
                    Get-VIRole -Name $Name | Set-VIRole -RemovePrivilege *
                    Get-VIRole -Name $Name | Set-VIRole -AddPrivilege $PrivilegesList
                }
                elseif ($RoleExists -And (!$OverWrite)) {
                    Write-Verbose -Message "Adding prvilieges to the role '$Name'"
                    Get-VIRole -Name $Name | Set-VIRole -AddPrivilege $PrivilegesList
                }
            }
        }
    }
}