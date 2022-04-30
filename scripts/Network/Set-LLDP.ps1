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
Get-VDSwitch | Set-VDSwitch -LinkDiscoveryProtocol LLDP -LinkDiscoveryProtocolOperation Listen
Write-Host "Completed configuring LLDP on DVS. Please check the console for errors." -ForegroundColor -Green

# Clean up the VI session.
Write-Host "Disconnecting from vCenter Server $vcenter" -ForegroundColor Green
Disconnect-VIServer -Confirm:$false