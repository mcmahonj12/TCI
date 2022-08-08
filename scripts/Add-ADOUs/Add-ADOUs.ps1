function Add-ADOUs {
    <#
    .SYNOPSIS
    This PowerCLI cmdlet creates an Active Directory structure to include OUs via Active Directory.
    
    .DESCRIPTION
    This function creates an Active Directory structure defined in a CSV to to prepare OUs
    for VMWare cloud architectures. The deployment structure can be modified by changing the data in the CSV file. Using a CSV file 
    for large deployments is the desireable method as multiple changes may be made using Excel rather than scrolling through YAML/JSON
    to make changes. This is especially helpful in the case of lab structures repeatedly recreated.

    The Microsoft Active Directory PowerShell module is required to use this script. To install the Active Directory module open
    a PowerShell command window as Administrator and run "Add-WindowsCapability -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0."
    
    .NOTES
    Author: Jim McMahon II
    
    .LINK
    This function was created and tested using Microsoft Windows Server 2022 with a Domain Level of 2016.
    
    .PARAMETER CSVPath
    CSVPath: string
    Set the location of the CSV where AD OU settings are defined.
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
        [Parameter(Mandatory = $true, Position = 1, HelpMessage = 'Path to the CSV file describing the OUs')]
        [ValidateNotNullorEmpty()]
        [Alias("Path")]
        [String]$CSVPath
    )

    try {
        $ous = Import-CSV -Path $CSVPath
    }
    catch {
        throw $error[0].Exception.Message
    }

    $ous | % {New-ADOrganizationalUnit -Server $server -Credential $creds -Name $_.name -Path $_.path}
}