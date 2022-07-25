function Deploy-vRO {
    <#
    .SYNOPSIS
     Deploy vRO appliance from JSON.
    .DESCRIPTION
     This function will deploy a vRO appliance. 
     The parameters and the configuration scripts are passed via a JSON file.
    .NOTES
     Author:  Luc Dekens
     Version:
     1.0 11/08/18  Initial release
     1.1 16/08/18  Create function
                   Added support for Reboot action
                   Added support for environment variable
     1.2 17/08/18  Added Folder (in JSON file) support
                  
    .PARAMETER JSONPath
     The location of the JSON file with the configuration parameters
    .PARAMETER LogFile
     Optional file for capturing logging information.
     This includes the output of the customisation scripts
    .EXAMPLE
     Deploy-vRO -JSONPath .\vro.json
    #>
     
      [cmdletbinding()]
      param(
        [Parameter(Mandatory = $true)]
        [string]$JSONPath
      )
    
        function Set-OvfParameters {
        param (
                $params
            )
    process{
                $OvfConfiguration = Get-OvfConfiguration -Ovf $params.vSphere.ovapath
            
                if($params.Common.FIPSMode){
                $OvfConfiguration.Common.fips_mode.Value = $params.Common.FIPSMode
                }
                if($params.Common.k8s_cluster_cidr){
                $OvfConfiguration.Common.k8s_cluster_cidr.Value = $params.Common.k8s_cluster_cidr
                }
                if($params.Common.k8s_service_cidr){
                $OvfConfiguration.Common.k8s_service_cidr.Value = $params.Common.k8s_service_cidr
                }
                if($params.Network.NTPServers){
                $OvfConfiguration.Common.ntp_servers.Value = $params.Network.NTPServers
                }
                if($params.Common.Hostname){
                $OvfConfiguration.Common.vami.hostname.Value = $params.Common.Hostname
                }
                if($params.Common.Root_password){
                $OvfConfiguration.Common.varoot_password.Value = $params.Common.Root_password
                }
                if($params.Common.SSH_Enabled){
                $OvfConfiguration.Common.va_ssh_enabled.Value = $params.Common.SSH_Enabled
                }
                if($params.Network.IpProtocol){
                $OvfConfiguration.IpAssignment.IpProtocol.Value = $params.Network.IpProtocol
                }
                if($params.Network.Portgroup){
                $OvfConfiguration.NetworkMapping.Network_1.Value = $params.Network.Portgroup
                }
                if($params.Network.DNSServers){
                $OvfConfiguration.vami.VMware_vRealize_Orchestrator_Appliance.DNS.Value = $params.Network.DNSServers
                }
                if($params.Network.Domain){
                $OvfConfiguration.vami.VMware_vRealize_Orchestrator_Appliance.domain.Value = $params.Network.Domain
                }
                if($params.Network.Gateway){
                $OvfConfiguration.vami.VMware_vRealize_Orchestrator_Appliance.gateway.Value = $params.Network.Gateway
                }
                if($params.Network.IPAddress){
                $OvfConfiguration.vami.VMware_vRealize_Orchestrator_Appliance.ip0.Value = $params.Network.IPAddress
                }
                if($params.Network.Netmask){
                $OvfConfiguration.vami.VMware_vRealize_Orchestrator_Appliance.netmask0.Value = $params.Network.Netmask
                }
                if($params.Network.SearchPath){
                $OvfConfiguration.vami.VMware_vRealize_Orchestrator_Appliance.searchpath.Value = $params.Network.SearchPath
                }
            
                Return $OvfConfiguration
    }
    }
    
      # Get Parameters
     
      $paramDataJSON = Get-Content -Path $JSONPath | Out-String
      $paramData = ConvertFrom-Json -InputObject $paramDataJSON
    
      # Determine location for appliance
     
      $obj = Get-Inventory -Name $paramData.vSphere.VMHost
      if ($obj -is [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster]) {
        $obj = Get-VMHost -Location $obj | Get-Random
      }
      $esx = $obj
     
      $dsc = Get-DatastoreCluster -Name $paramData.vSphere.Datastore -ErrorAction SilentlyContinue
      if ($dsc) {
        $ds = Get-Datastore -RelatedObject $dsc | Get-Random
      }
      else {
        $ds = Get-Datastore -Name $paramData.vSphere.Datastore
      }
    
      # Set OVF parameters
    
      $ovfParam = Set-OvfParameters($paramData)
    
        # Import Appliance
     
      $sVApp = @{
        Name              = $paramData.VM.VMName
        Source            = $paramData.vSphere.OvaPath
        OvfConfiguration  = $ovfParam
        VMHost            = $esx
        Datastore         = $ds
        DiskStorageFormat = [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.VirtualDiskStorageFormat]::Thin
        Confirm           = $false
      }
      if($paramData.Template.Folder){
        $sVApp.Add('InventoryLocation',(Get-FolderByPath -Path $paramData.Template.Folder))
      }
      $vm = Import-VApp @sVApp
    
      $vm = Get-VM -Name $paramData.VM.VMName
    
      Start-VM $vm
    }
