#Requires -Modules VMware.VimAutomation.Core
function Install-TCA {
    <#
    .SYNOPSIS
    This PowerCLI cmdlet create a PowerCli object OvfConfiguration specifically designed to be used when importing the VMware-Telco-Cloud-Automation-2.1.0-20142564 ovf/ova package with the Import-VApp cmdlet.
    It relies on the get-ovfconfiguration PowerCli cmdlet
    
    .DESCRIPTION
    This function is based on the original get-ovfconfiguration PowerCLI cmdlet...
    ...and convert it in a Powershell friendly function specifically for the package VMware-Telco-Cloud-Automation-2.1.0-20142564
    It is mandatory to be connected to one vCenter or Get-OvfConfiguration will throw an error
    
    .NOTES
    Author: Jim McMahon II
    Original: Christophe Calvet
    Blog: http://www.thecrazyconsultant.com/Get-OvfConfiguration_on_steroids
    
    .LINK
    This function has been generated by script for a VMware-Telco-Cloud-Automation-2.1.0-20142564 ovf/ova package then modified to use a JSON payload.
    The script used to create this function is available at the link below, and can be used for any ovf/ova packages.
    http://www.thecrazyconsultant.com/Get-OvfConfiguration_on_steroids
    Documentation for the original get-ovfconfiguration
    http://pubs.vmware.com/vsphere-55/index.jsp#com.vmware.powercli.cmdletref.doc/Get-OvfConfiguration.html
    Link for a good overview of get-ovfconfiguration
    http://blogs.vmware.com/PowerCLI/2014/09/powercli-5-8-new-feature-get-ovfconfiguration-part-1-2.html
    
    .PARAMETER jsonpath
    Specifies the file path to the json payload to be used to deploy a vCenter Server appliance. This payload is used to create the OVF properties object.
  
    .PARAMETER ovfpath
    Specifies the local path to the OVF or OVA package for which the user-configurable options are returned. URL paths are not supported.
    #>
    [cmdletbinding()]
    param(
        ## Specifies the json payload to be used to create an OVF properties object.
        [Parameter(Mandatory = $true)]
        [string]$JSONPath,
    
        ## Specifies the name of the OVA used to deploy the Telco Cloud Automation appliance.
        [Parameter(Mandatory = $true)]
        [string]$OVAName
    )
  
    # Function sets the ovf properties from the specified JSON configuration file. Will only set those which contain data in the JSON.
    function Set-OvfParameters($params, $OvfConfiguration) {  
    
        # Set the OVF properties from the accepted JSON payload.
        process {
  
            if ($params.common.applianceRole) {
                $OvfConfiguration.Common.applianceRole.Value = $params.common.applianceRole
            }
            if ($params.common.hostname) {
                $OvfConfiguration.Common.hostname.Value = $params.common.hostname
            }
            if ($params.common.mgr_cli_password) {
                $OvfConfiguration.Common.mgr_cli_passwd.Value = $params.common.mgr_cli_password
            }
            if ($params.network.dnsservers) {
                $OvfConfiguration.Common.mgr_dns_list.Value = $params.network.dnsservers
            }
            if ($params.network.searchpath) {
                $OvfConfiguration.Common.mgr_domain_search_list.Value = $params.network.searchpath
            }
            if ($params.network.gateway) {
                $OvfConfiguration.Common.mgr_gateway_0.Value = $params.network.gateway
            }
            if ($params.network.ipaddress) {
                $OvfConfiguration.Common.mgr_ip_0.Value = $params.network.ipaddress
            }
            if ($params.network.ipprotocol) {
                $OvfConfiguration.Common.mgr_ip_protocol.Value = $params.network.ipprotocol
            }
            if ($params.common.ssh_enabled) {
                $OvfConfiguration.Common.mgr_isSSHEnabled.Value = $params.common.ssh_enabled
            }
            if ($params.network.dhcp_enabled) {
                $OvfConfiguration.Common.mgr_is_dhcp_enabled.Value = $params.network.dhcp_enabled
            }
            if ($params.network.ntpservers) {
                $OvfConfiguration.Common.mgr_ntp_list.Value = $params.network.ntpservers
            }
            if ($params.network.prefix) {
                $OvfConfiguration.Common.mgr_prefix_ip_0.Value = $params.network.prefix
            }
            if ($params.common.root_password) {
                $OvfConfiguration.Common.mgr_root_passwd.Value = $params.common.root_password
            }
            if ($params.routes.staticNet1.gatewayIp) {
                $OvfConfiguration.Common.mgr_static_gateway_ip_1.Value = $params.routes.staticNet1.gatewayIp
            }
            if ($params.routes.staticNet2.gatewayIp) {
                $OvfConfiguration.Common.mgr_static_gateway_ip_2.Value = $params.routes.staticNet2.gatewayIp
            }
            if ($params.routes.staticNet1.network) {
                $OvfConfiguration.Common.mgr_static_network_1.Value = $params.routes.staticNet1.network
            }
            if ($params.routes.staticNet2.network) {
                $OvfConfiguration.Common.mgr_static_network_2.Value = $params.routes.staticNet2.network
            }
            if ($params.routes.staticNet1.networkPrefix) {
                $OvfConfiguration.Common.mgr_static_network_prefix_1.Value = $params.routes.staticNet1.networkPrefix
            }
            if ($params.routes.staticNet2.networkPrefix) {
                $OvfConfiguration.Common.mgr_static_network_prefix_2.Value = $params.routes.staticNet2.networkPrefix
            }
            if ($params.network.portgroup) {
                $OvfConfiguration.NetworkMapping.VSMgmt.Value = $params.network.portgroup
            }
            if ($OvfConfiguration.EULAs.Accept) {
                $OvfConfiguration.EULAs.Accept.Value = $true
            }
    
            Return $OvfConfiguration
        }
    }
  
    $ErrorActionPreference = 'Stop'
      
    Write-Host -ForegroundColor Gray "**********************************************************"
    Write-Host -ForegroundColor Gray "** Starting Telco Cloud Automation appliance deployment **"
    Write-Host -ForegroundColor Gray "**********************************************************"
    Write-Host ""
    
    # Get JSON parameters from the specified config file which should be set in the OVF parameters hashtable.
    # If the path does not exist or the path is not a JSON exit the script with an error.
    Write-Host -ForegroundColor Cyan "Validate the provided JSON..."
    Write-Host -ForegroundColor Cyan "*****************************"
    Try {
        Write-Host -ForegroundColor Magenta "Checking the provided JSON path..."
        if (Resolve-Path $JSONPath -ErrorAction Stop) {
            Write-Host -ForegroundColor Magenta "Successfully resolved the provided path. Checking the extension..."
            if (([IO.Path]::GetExtension($JSONPath)) -ne ".json") {
                Write-Warning "The file extension specified is not supported. Retry the deployment with a .json extension. Stopping the script."
            }
            Write-Host -ForegroundColor Green "Provided path is a valid JSON extension."
            Write-Host ""
        }
        $paramDataJSON = Get-Content -Path $JSONPath | Out-String
    }
    Catch {
        Write-Host ""
        Write-Warning "The file path $JSONPath does not exist. Please retry the deployment with another path to the Telco Cloud Automation configuration JSON."
        Return 1
    }
    #$paramDataJSON = Get-Content -Path $JSONPath | Out-String
    # Try to convert the json file to a PowerShell object. If the file is not a valid JSON, exit the script.
    Write-Host -ForegroundColor Cyan "Performing JSON conversion to PSObject"
    Write-Host -ForegroundColor Cyan "**************************************"
    Try {
        Write-Host ""
        Write-Host -ForegroundColor Magenta "Converting the JSON to a PowerShell object."
        $paramData = ConvertFrom-Json -InputObject $paramDataJSON -ErrorAction Stop
        #$paramData = ConvertFrom-Json -InputObject $JSON -ErrorAction Stop
    }
    Catch {
        Write-Host ""
        Write-Warning "Could not convert the JSON file specified. $_"
        Return 1
    }
      
    Write-Host -ForegroundColor Green "Successfully converted the specfied JSON."
    Write-Host ""
      
    Write-Host -ForegroundColor Cyan "Checking if VM exists on the destination"
    Write-Host -ForegroundColor Cyan "****************************************"
      
    If (Get-VM $paramData.VM.VMName -ErrorAction SilentlyContinue) {
        Write-Host -ForegroundColor Green "The VM $($paramData.VM.VMName) already exists on the target vCenter Server."
        Return 0
    }
      
    Write-Host -ForegroundColor Green "The VM $($paramData.VM.VMName) was not found on the target vCenter Server. Continuing..."
    Write-Host ""
      
    # Try to obtain the OVF configuration data from the specified OVA.
    # If the OVA cannot be located exit the script.
    Write-Host -ForegroundColor Cyan "Getting the OVF properties from the specified OVA"
    Write-Host -ForegroundColor Cyan "*************************************************"
    Try {
        Write-Host -ForegroundColor Magenta "Getting the OVF properties from OVA $($OVAName)."
        $ovf = Get-OvfConfiguration -ContentLibraryItem $OVAName -Target ($paramData.vsphere.vmhost) -ErrorAction Stop
    }
    Catch {
        Write-Warning "The specified ova $OVAName could not be located in the target vCenter Server's content libraries."
        Write-Warning "Please correct the name or upload the desired Telco Cloud Automation OVA and retry the deployment."
        Return 1
    }
    Write-Host -ForegroundColor Green "Successfully acquired the appliance OVF properties from the OVA."
    Write-Host ""
    
    # Determine destination ESXi host (required New-VM parameter). Will get a host from a cluster object.
    $obj = Get-Inventory -Name $paramData.vSphere.VMHost
    if ($obj -is [VMware.VimAutomation.ViCore.Impl.V1.Inventory.ComputeResourceImpl]) {
        $obj = Get-VMHost -Location $obj | Get-Random
    }
    $esx = $obj
     
    # Set the destination datastore for the VM.
    $ds = Get-Datastore -Name $paramData.vSphere.Datastore -ErrorAction SilentlyContinue
    
    # Set OVF parameters for the VM deployment
    Write-Host -ForegroundColor Cyan "Setting the OVF properties from the specified OVA"
    Write-Host -ForegroundColor Cyan "*************************************************"
    Write-Host -ForegroundColor Magenta "Setting the OVF properties to apply to the virtual appliance from the specified JSON."
    $ovfParam = Set-OvfParameters $paramData $ovf
     
    # VM configuration hashtable. Used to deploy a new VM.
    $sVApp = @{
        Name               = $paramData.VM.VMName
        VMHost             = $esx
        Datastore          = $ds
        DiskStorageFormat  = [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.VirtualDiskStorageFormat]::Thin
        #Source            = $paramData.vSphere.OvaPath
        ContentLibraryItem = $paramData.vSphere.OvaPath
        OvfConfiguration   = $ovfParam
        Confirm            = $false
    }
    Write-Host -ForegroundColor Green "Successfully set the new VM configuration properties."
    Write-Host ""
       
    # Add a folder location to the confguration hashtable if a folder location has been specified in the config file.
    Write-Host -ForegroundColor Cyan "Setting VM folder if specified in the JSON payload"
    Write-Host -ForegroundColor Cyan "**************************************************"
      
    if ($paramData.VM.Folder) {
        # If the configuration JSON contains a folder name check if the folder exists.
        Write-Host -ForegroundColor Magenta "Folder specified. Checking if folder exists..."
        $data = get-folder -Type VM | Where-Object { $_.name -eq $paramData.VM.Folder }
          
        # If the folder does not exist, create the folder in the VM root.
        if (!($data)) {
            Write-Host -ForegroundColor Red "Folder does not exist on destination."
            Write-Host -ForegroundColor Magenta "Creating folder $($paramData.VM.Folder)"
            Get-Folder vm | New-Folder $paramData.VM.Folder -ErrorAction SilentlyContinue
            Write-Host -ForegroundColor Green "Created VM folder $($paramData.VM.Folder)."
        }
        else {
            Write-Host -ForegroundColor Green "Specified folder already exists."
        }
          
        # Add the folder as a location parameter to the deployment options.
        #$sVApp.Add('InventoryLocation',(Get-Folder $paramData.VM.Folder))
        $sVApp.Add('Location', (Get-Folder $paramData.VM.Folder))
    }
    #$vm = Import-VApp @sVApp
    
    #Deploy a new VM using the configuration hashtable. If the VM fails to be created, stop the script.
    Write-Host ""
    Write-Host -ForegroundColor Cyan "Deploy vCenter Server appliance"
    Write-Host -ForegroundColor Cyan "*******************************"
    try {
        Write-Host -ForegroundColor Green "Deploying Telco Cloud Automation appliance..."
        New-VM @sVApp -ErrorAction Stop
    }
    catch {
        Write-Host ""
        Write-Warning "Could not create VM $($paramData.VM.VMName)"
        Write-Host -ForegroundColor Yellow -BackgroundColor Black "$_.Exception"
        Write-Host -ForegroundColor Yellow -BackgroundColor Black "Check destination host logs for more information."
        Return 1
    }
    Write-Host -ForegroundColor Green "Successfully deployed VM $($paramData.VM.VMName)"
    
    #Get the Telco Cloud Automation appliance VM object.
    $vm = Get-VM -Name $paramData.VM.VMName
    
    #Power on the new Virtual Machine.
    Write-Host ""
    Write-Host -ForegroundColor Cyan "Power on the VM"
    Write-Host -ForegroundColor Cyan "***************"
    try {
        Write-Host ""
        Write-Host -ForegroundColor Magenta "Starting VM $($paramData.VM.VMName)"
        Start-VM $vm
    }
    catch {
        Write-Host ""
        Write-Warning "Could not start VM $($paramData.VM.VMName)."
        Write-Host -ForegroundColor Yellow -BackgroundColor Black "$_.Exception"
        Write-Host -ForegroundColor Yellow -BackgroundColor Black "Check destination host logs for more information."
        Return 1
    }
  
    #Start checking if the appliance services are available.
    Write-Host ""
    Write-Host -ForegroundColor Cyan "Check appliance availability"
    Write-Host -ForegroundColor Cyan "****************************"
    Write-Host -ForegroundColor Magenta "Attempting to connect to $($paramData.common.hostname) to validate it has come online properly."
    
    <#$i = 0
      do {
          Write-Host "$($paramData.common.hostname) is not currently available. Retrying in 60 seconds."
          $i++
          Start-Sleep 60
      }
      until (($api = Invoke-RestMethod #connect-viserver -server $paramData.common.hostname -user "administrator@vsphere.local" -password $paramData.new_vcsa.sso.password -ErrorAction SilentlyContinue) -or ($i -eq 25))
  #>
    #If the connection was successful inform the operator so.
    if ($api) {
        Write-Host -ForegroundColor Green "Successfully connected to Telco Cloud Automation appliance."
    }
    #If the connection was unsuccessful inform the operator the vCenter Server may still be configuring but the timeout was met.
    else {
        Write-Warning "The Telco Cloud Automation VM $($paramData.VM.VMName) deployed successfully but could not be contacted."
        Write-Warning "Please check the appliance and ensure the services have come online."
        return 1
    }
      
    Write-Host -ForegroundColor Green "Telco Cloud Automation appliance $($paramData.VM.VMName) deployed successfully!"
  
    #Return the connection status so it may be used to perform other configurations.
    Return 0
}