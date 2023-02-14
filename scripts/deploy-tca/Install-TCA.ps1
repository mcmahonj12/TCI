function Install-TCA{
  <#
  .SYNOPSIS
  This PowerCLI cmdlet create a PowerCli object OvfConfiguration specifically designed to be used when importing the VMware-Telco-Cloud-Automation-2.1.0-20142564 ovf/ova package with the Import-VApp cmdlet.
  It relies on the get-ovfconfiguration PowerCli cmdlet
  
  .DESCRIPTION
  This function is based on the original get-ovfconfiguration PowerCLI cmdlet...
  ...and convert it in a Powershell friendly function specifically for the package VMware-Telco-Cloud-Automation-2.1.0-20142564
  It is mandatory to be connected to one vCenter or Get-OvfConfiguration will throw an error
  
  .NOTES
  Author: Christophe Calvet
  Blog: http://www.thecrazyconsultant.com/Get-OvfConfiguration_on_steroids
  
  .LINK
  This function has been generated by script for a VMware-Telco-Cloud-Automation-2.1.0-20142564 ovf/ova package.
  The script used to create this function is available at the link below, and can be used for any ovf/ova packages.
  http://www.thecrazyconsultant.com/Get-OvfConfiguration_on_steroids
  Documentation for the original get-ovfconfiguration
  http://pubs.vmware.com/vsphere-55/index.jsp#com.vmware.powercli.cmdletref.doc/Get-OvfConfiguration.html
  Link for a good overview of get-ovfconfiguration
  http://blogs.vmware.com/PowerCLI/2014/09/powercli-5-8-new-feature-get-ovfconfiguration-part-1-2.html
  
  .PARAMETER Common_applianceRole
  OvfTypeDescription: string["Manager", "ControlPlane","Bootstrapper"]
  Configure Appliance Role
  
  .PARAMETER Common_hostname
  OvfTypeDescription: string
  The hostname for this VM.
  
  .PARAMETER Common_mgr_cli_passwd
  OvfTypeDescription: password
  The password for default CLI user for this VM.
  
  .PARAMETER Common_mgr_dns_list
  OvfTypeDescription: string
  The DNS server list(space separated) for this VM.
  
  .PARAMETER Common_mgr_domain_search_list
  OvfTypeDescription: string
  The domain Search list(space separated) for this VM.
  
  .PARAMETER Common_mgr_gateway_0
  OvfTypeDescription: string
  The default gateway for this appliance.
  
  .PARAMETER Common_mgr_ip_0
  OvfTypeDescription: string
  The IP Address for this interface.
  
  .PARAMETER Common_mgr_ip_protocol
  OvfTypeDescription: string["IPv4", "IPv6"]
  Select IP protocol to be used for the appliance.
  
  .PARAMETER Common_mgr_isSSHEnabled
  OvfTypeDescription: boolean
  Enabling SSH service is not recommended for security reasons.
  
  .PARAMETER Common_mgr_is_dhcp_enabled
  OvfTypeDescription: boolean
  Configure DHCP for the appliance. If DHCP is enabled, IP Address, Prefix Length and Gateway will be ignored.
  
  .PARAMETER Common_mgr_ntp_list
  OvfTypeDescription: string
  The NTP server list(space separated) for this VM.
  
  .PARAMETER Common_mgr_prefix_ip_0
  OvfTypeDescription: string(..3)
  The IP Prefix Length for this interface.
  
  .PARAMETER Common_mgr_root_passwd
  OvfTypeDescription: password
  The password for root user.
  
  .PARAMETER Common_mgr_static_gateway_ip_1
  OvfTypeDescription: string
  The Default Gateway’s IP Address 1
  
  .PARAMETER Common_mgr_static_gateway_ip_2
  OvfTypeDescription: string
  The Default Gateway’s IP Address 2
  
  .PARAMETER Common_mgr_static_network_1
  OvfTypeDescription: string
  The Static Route 1 Network
  
  .PARAMETER Common_mgr_static_network_2
  OvfTypeDescription: string
  The Static Route 2 Network
  
  .PARAMETER Common_mgr_static_network_prefix_1
  OvfTypeDescription: string(..2)
  The Static Route 1 Prefix Length
  
  .PARAMETER Common_mgr_static_network_prefix_2
  OvfTypeDescription: string(..2)
  The Static Route 2 Prefix Length
  
  .PARAMETER NetworkMapping_VSMgmt
  OvfTypeDescription: string
  This network provides connectivity to this virtual machine.
  Option 1: Standard Port Group associated to one host - VirtualPortGroupImpl
  Option 2: Distributed Port Group associated to vCenter - VmwareVDPortgroupImpl
  
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
  
      process{
      #Get ovf configuration from a local file
      #$OvfConfiguration = Get-OvfConfiguration -Ovf $params.vSphere.ovapath
		  #$OvfConfiguration = Get-OvfConfiguration -ContentLibraryItem $ova -Target (Get-Inventory $params.new_vcsa.vc.vmhost)

      if($params.common.applianceRole){
      $OvfConfiguration.Common.applianceRole.Value = $params.common.applianceRole
      }
      if($params.common.hostname){
      $OvfConfiguration.Common.hostname.Value = $params.common.hostname
      }
      if($params.common.mgr_cli_password){
      $OvfConfiguration.Common.mgr_cli_passwd.Value = $params.common.mgr_cli_password
      }
      if($params.network.dnsservers){
      $OvfConfiguration.Common.mgr_dns_list.Value = $params.network.dnsservers
      }
      if($params.network.searchpath){
      $OvfConfiguration.Common.mgr_domain_search_list.Value = $params.network.searchpath
      }
      if($params.network.gateway){
      $OvfConfiguration.Common.mgr_gateway_0.Value = $params.network.gateway
      }
      if($params.network.ipaddress){
      $OvfConfiguration.Common.mgr_ip_0.Value = $params.network.ipaddress
      }
      if($params.network.ipprotocol){
      $OvfConfiguration.Common.mgr_ip_protocol.Value = $params.network.ipprotocol
      }
      if($params.common.ssh_enabled){
      $OvfConfiguration.Common.mgr_isSSHEnabled.Value = $params.common.ssh_enabled
      }
      if($params.network.dhcp_enabled){
      $OvfConfiguration.Common.mgr_is_dhcp_enabled.Value = $params.network.dhcp_enabled
      }
      if($params.network.ntpservers){
      $OvfConfiguration.Common.mgr_ntp_list.Value = $params.network.ntpservers
      }
      if($params.network.prefix){
      $OvfConfiguration.Common.mgr_prefix_ip_0.Value = $params.network.prefix
      }
      if($params.common.root_password){
      $OvfConfiguration.Common.mgr_root_passwd.Value = $params.common.root_password
      }
      if($params.routes.staticNet1.gatewayIp){
      $OvfConfiguration.Common.mgr_static_gateway_ip_1.Value = $params.routes.staticNet1.gatewayIp
      }
      if($params.routes.staticNet2.gatewayIp){
      $OvfConfiguration.Common.mgr_static_gateway_ip_2.Value = $params.routes.staticNet2.gatewayIp
      }
      if($params.routes.staticNet1.network){
      $OvfConfiguration.Common.mgr_static_network_1.Value = $params.routes.staticNet1.network
      }
      if($params.routes.staticNet2.network){
      $OvfConfiguration.Common.mgr_static_network_2.Value = $params.routes.staticNet2.network
      }
      if($params.routes.staticNet1.networkPrefix){
      $OvfConfiguration.Common.mgr_static_network_prefix_1.Value = $params.routes.staticNet1.networkPrefix
      }
      if($params.routes.staticNet2.networkPrefix){
      $OvfConfiguration.Common.mgr_static_network_prefix_2.Value = $params.routes.staticNet2.networkPrefix
      }
      if($params.network.portgroup){
      $OvfConfiguration.NetworkMapping.VSMgmt.Value = $params.network.portgroup
      }
      if($OvfConfiguration.EULAs.Accept){
      $OvfConfiguration.EULAs.Accept.Value = $true
      }
  
      Return $OvfConfiguration
      }
  }

    $Global:ErrorActionPreference = ”Stop”
  
    # Get JSON parameters from the specified config file which should be set in the OVF parameters hashtable.
    Try {
      #$paramData = ConvertFrom-Json -InputObject $paramDataJSON -ErrorAction Stop
      $paramData = ConvertFrom-Json -InputObject $JSONPath -ErrorAction Stop
    }
    Catch {
      Write-Warning "Could not convert the JSON file specified. $_"
    }
    
    # Try to obtain the OVF configuration data from the specified OVA.
    # If the OVA cannot be located exit the script.
    Try {
      $ovf = Get-OvfConfiguration -ContentLibraryItem $OVAName -Target ($paramData.new_vcsa.vc.vmhost) -ErrorAction Stop
    }
    Catch {
      Write-Warning "The specified ova $OVAName could not be located in the target vCenter Server's content libraries."
      Write-Warning "Please correct the name or upload the desired vCenter Server OVA and retry the deployment."
    }
    
    # Try to obtain the OVF configuration data from the specified OVA.
    # If the OVA cannot be located exit the script.
    Try {
      $ovf = Get-OvfConfiguration -ContentLibraryItem $OVAName -Target ($paramData.new_vcsa.vc.vmhost) -ErrorAction Stop
    }
    Catch {
      Write-Warning "The specified ova $OVAName could not be located in the target vCenter Server's content libraries."
      Write-Warning "Please correct the name or upload the desired vCenter Server OVA and retry the deployment."
    }
  
    # Determine destination ESXi host (required New-VM parameter). Will get a host from a cluster object.
    $obj = Get-Inventory -Name $paramData.vSphere.VMHost
    if ($obj -is [VMware.VimAutomation.ViCore.Impl.V1.Inventory.ComputeResourceImpl]) {
      $obj = Get-VMHost -Location $obj | Get-Random
    }
    $esx = $obj
   
    # Set the destination datastore for the VM.
    $ds = Get-Datastore -Name $paramData.vSphere.Datastore -ErrorAction SilentlyContinue
  
    # Set OVF parameters for the VM deployment
    $ovfParam = Set-OvfParameters $paramData $ovf
      
   
    # VM configuration hashtable. Used to deploy a new VM.
    $sVApp = @{
      Name              = $paramData.VM.VMName
      VMHost            = $esx
      Datastore         = $ds
      DiskStorageFormat = [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.VirtualDiskStorageFormat]::Thin
      #Source            = $paramData.vSphere.OvaPath
      ContentLibraryItem = $paramData.vSphere.OvaPath
      OvfConfiguration  = $ovfParam
      Confirm           = $false
    }
  # Add a folder location to the confguration hashtable if a folder location has been specified in the config file.
    if($paramData.VM.Folder){
    # If the configuration JSON contains a folder name check if the folder exists.
    $data = get-folder -Type VM | Where-Object {$_.name -eq $paramData.VM.Folder}
    
    # If the folder does not exist, create the folder in the VM root.
    if (!($data)) {Get-Folder vm | New-Folder $paramData.VM.Folder -ErrorAction SilentlyContinue}
    
    # Add the folder as a location parameter to the deployment options.
        #$sVApp.Add('InventoryLocation',(Get-Folder $paramData.VM.Folder))
    $sVApp.Add('Location',(Get-Folder $paramData.VM.Folder))
    }
    #$vm = Import-VApp @sVApp
  
  #Deploy a new VM using the configuration hashtable
  try {
		Write-Host "Deploying vCenter appliance..."
		New-VM @sVApp -ErrorAction Stop
	}
	catch {
		Write-Warning "Could not create VM vcsa."
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "$_.Exception"
		Write-Host -ForegroundColor Yellow -BackgroundColor Black "Check destination host logs for more information."
	}
  
  #Get the vCenter Server appliance VM object.
  $vm = Get-VM -Name $paramData.VM.VMName
  
  #Power on the new Virtual Machine.
  Start-VM $vm

  #Start checking if the appliance services are available.
  Write-Host "Will now attempt to connect to $($paramData.common.hostname) to validate it has come online properly."

  #Code here

  #If the connection is unsuccessful inform the operator the appliance may not yet be available. Check the appliance for more details.

  #Return the connection status so it may be used to perform other configurations.
  Return $tca
}