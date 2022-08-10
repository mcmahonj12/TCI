function Set-AdGroupMembership {
    <#
    .SYNOPSIS
    This PowerCLI cmdlet creates sets Active Directory group membership in bulk.
    
    .DESCRIPTION
    This function bulk sets Active Directory user group membership as specified in the groups.json file. 

    The Microsoft Active Directory PowerShell module is required to use this script. To install the Active Directory module open
    a PowerShell command window as Administrator and run "Add-WindowsCapability -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0."
    
    .NOTES
    Author: Jim McMahon II
    
    .LINK
    This function was created and tested using Microsoft Windows Server 2022 with a Domain Level of 2016.

    .EXAMPLE
    Set-AdGroupMembership -ADServer 172.16.0.10 -Credential (Get-Credential) -JSONPath C:\Configs\groups.json
    
    .PARAMETER JSONPath
    JSONPath: string
    Set the location of the JSON where AD group settings are defined.
    #>

    
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 1, HelpMessage = 'Active Directory Server to connect to.')]
        [ValidateNotNullorEmpty()]
        [Alias("Server")]
        [String]$ADServer,
        [Parameter(Mandatory = $true, Position = 1, HelpMessage = 'Secure credential to authenticate to AD as Domain Admin.')]
        [ValidateNotNullorEmpty()]
        [Alias("Creds")]
        [pscredential]$Credential,
        [Parameter(Mandatory = $true, Position = 1, HelpMessage = 'Path to the JSON file describing the group configurations')]
        [ValidateNotNullorEmpty()]
        [Alias("Path")]
        [String]$JSONPath
    )

    try {
        $groups = Get-Content $JSONPath | ConvertFrom-JSON
    }
    catch {
        throw $error[0].Exception.Message
    }

    $groups | ForEach-Object { if ($_.members){
            Add-ADGroupMember -Server $ADServer -Credential $creds -Identity $_.Name -Members $_.members
        }
    }
}