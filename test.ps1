$vmh =  Get-Cluster $Cluster | Get-VMHost | Sort-Object name
$LLDPResultArray = @()

Get-View $vmh.ID | `
   % { $esxname = $_.Name; Get-View $_.ConfigManager.NetworkSystem} | `
   % { foreach ($physnic in $_.NetworkInfo.Pnic) {
     $pnicInfo = $_.QueryNetworkHint($physnic.Device)

    foreach( $hint in $pnicInfo )
	{
	  ## If the switch support LLDP, and you're using Distributed Virtual Swicth with LLDP
	  if ($hint.LLDPInfo)
	  {
		#$hint.LLDPInfo.Parameter
		$LLDPResult = "" | select-object VMHost, PhysicalNic, PhysSW_Port, PhysSW_Name, PhysSW_Description, PhysSW_MGMTIP, PhysSW_MTU

		$LLDPResult.VMHost = $esxname
		$LLDPResult.PhysicalNic = $physnic.Device
		$LLDPResult.PhysSW_Port = ($hint.LLDPInfo.Parameter | ? { $_.Key -eq "Port Description" }).Value
		$LLDPResult.PhysSW_Name = ($hint.LLDPInfo.Parameter | ? { $_.Key -eq "System Name" }).Value
		$LLDPResult.PhysSW_Description = ($hint.LLDPInfo.Parameter | ? { $_.Key -eq "System Description" }).Value
		$LLDPResult.PhysSW_MGMTIP = ($hint.LLDPInfo.Parameter | ? { $_.Key -eq "Management Address" }).Value
		$LLDPResult.PhysSW_MTU = ($hint.LLDPInfo.Parameter | ? { $_.Key -eq "MTU" }).Value

		$LLDPResultArray += $LLDPResult
       }
	 }
   }
}


$sites = @()

$site = [PSCustomObject]@{
 SiteID= $data.Site.siteID
 AvailabilityZone = $data.CloudZones.availability_zone
 TCA = $data.CloudZones.tca
 vCenter = $data.CloudZones.vcenter_name
 ComputeNodes = @{
    Name = $data.ComputeNodes.name
    Vendor = $data.ComputeNodes.server_vendor
    Hostname = $data.ComputeNodes.compute_resources
    DvSwitch = $data.ComputeNodes.site_vswitch
 }
}

$sites += $site