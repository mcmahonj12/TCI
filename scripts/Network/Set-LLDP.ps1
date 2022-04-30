# Get the target vCenter to configure Distributed Switch Link Layer Discovery Protocol
$vcenter = Read-Host "Please specify the vCenter Server to connect to"

# Try connecting to the target vCenter Server
try {
    Write-Host "Connecting to vCenter, please wait.." -ForegroundColor Green
    #Connect to vCenter
    Connect-ViServer -server $vcenter -ErrorAction Stop | Out-Null
  }
  catch [Exception]{
    $exception = $_.Exception
    Write-Host $exception.Message

  }

# Enable LLDP on all Distributed Switches.
Write-Host "Enabling LLDP on Distributed Switches" -ForegroundColor Magenta
$tasks = Get-VDSwitch | Set-VDSwitch -LinkDiscoveryProtocol LLDP -LinkDiscoveryProtocolOperation Listen -RunAsync:$true
Write-Host "Completed configuring LLDP on DVS. Please check the console for errors." -ForegroundColor Green

Start-Sleep -Seconds 5

Write-Host "Displaying all DVS LLDP config task status." -ForegroundColor Magenta
$tasks

# Show DVS LLDP configuration
Write-Host "Displaying all DVS LLDP current configs." -ForegroundColor Magenta
Get-VDSwitch | Select-Object Name, LinkDiscoveryProtocol, LinkDiscoveryProtocolOperation | Format-Table -AutoSize

# Clean up the VI session.
Write-Host "Disconnecting from vCenter Server $vcenter" -ForegroundColor Green
Disconnect-VIServer -Confirm:$false