
# Check DNS host A/PTR records exist
$result = Resolve-DnsName $hosts
Resolve-DnsName $result.IPAddress

$creds = (Get-Credential -Message "Please enter the root user and password to connect to ESXi hosts:")

$hosts | % {

# DNS Host Lookup Validation
Write-Host "Testing host DNS resolution" -ForegroundColor Green
    $dns = @{
        ip = ""
        address = ""
    }
    # Check for Host A resolution
    try {
        $dns.ip = (nslookup $_ | Select-String Address | Where-Object LineNumber -eq 5).ToString().Split(' ')[-1]
    }
    catch {
        Write-Host "HOST_CHECK_DNS_HOST_A"
        Write-Host "Could not resolve HOST A record for host $hosts"
    }
    Write-Host "HOST A record check succeeded"

    # Check for PTR resolution
    try {
        $dns.addr = (nslookup $dns.ip | Select-String Name | Where-Object LineNumber -eq 4).ToString().Split(' ')[-1]
    }
    catch {
        Write-Host "HOST_CHECK_DNS_PTR"
        Write-Host "Could not resolve PTR record for host $hosts"
    }
    Write-Host "Host PTR record check succeeded"

# Test host availability
Write-Host "Attempting to connect to host" -ForegroundColor Green
    try {
        Connect-VIServer $_ -Credential $creds
    }
    catch {
        Write-Host "HOST_CHECK_SVC_AVAILABLE"
        Write-Host "Unable to connect to host $_ via API."       
    }

# Check SSH is enabled
    # Check the SSH service policy is set to start and stop with the host.
    Write-Host "Checking the SSH service is enabled. If not, enabling." -ForegroundColor Green
    try {
        If ($ssh = Get-VMHostService | Where-Object {($_.Key -eq "TSM-ssh") -and ($_.Policy -ne "on")}) {
            Write-Host "Setting SSH policy to 'Start and stop with host'" -ForegroundColor Magenta
            Set-VMHostService $ssh -policy "on" -Confirm:$false | Restart-VMHostService -Confirm:$false
        }
    }
    catch {
        Write-Host "HOST_CHECK_HOST_SSH"
        Write-Host "Could not change the SSH host policy to 'Start and stop with host'"
    }

    # Check the SSH service is running and start it if not. 
    Write-Host "Checking the SSH service is running. If not, starting." -ForegroundColor Green   
    try {
        If ($ssh = Get-VMHostService | Where-Object {($_.Key -eq "TSM-ssh") -and ($_.Running -ne $True)}) {
            Write-Host "The SSH service is not running. Starting the SSH service." -ForegroundColor Magenta
            Start-VMHostService $ssh -Confirm:$false
        }
    }
    catch {
        Write-Host "HOST_CHECK_HOST_SSH"
        Write-Host "Could not start the SSH service."
        $error[0]
    }

# Check NTP is configured, the service is running, and the NTP servers are reachable.
    # Check the SSH service policy is set to start and stop with the host.
    Write-Host "Checking the SSH service is enabled. If not, enabling." -ForegroundColor Green
    try {
        If ($ssh = Get-VMHostService | Where-Object {($_.Key -eq "TSM-ssh") -and ($_.Policy -ne "on")}) {
            Write-Host "Setting SSH policy to 'Start and stop with host'" -ForegroundColor Magenta
            Set-VMHostService $ssh -policy "on" -Confirm:$false | Restart-VMHostService -Confirm:$false
        }
    }
    catch {
        Write-Host "HOST_CHECK_HOST_SSH"
        Write-Host "Could not change the SSH host policy to 'Start and stop with host'"
    }

}

HOST_CHECK_SERVER_VENDOR
