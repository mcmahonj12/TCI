
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
        Write-Host "Could not resolve HOST A record for host $_"
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
    # Check NTP is configured with time servers.
    Write-Host "Checking if time servers are configured on the ESXi host. If not, set them." -ForegroundColor Green
    try {
        $currNtp = Get-VMHostNtpServer
        If (!($currNtp)) {
            Write-Host "Setting SSH policy to 'Start and stop with host'" -ForegroundColor Magenta
            $ntp | ForEach-Object {Add-VMHostNtpServer -NTPServer $_}
        }
        ElseIf ($currNtp -ne $ntp) {
            Get-VMHostNtpServer | ForEach-Object {Remove-VMHostNtpServer -NtpServer $_ -Confirm:$false}
            $ntp | Foreach-Object {Add-VMHostNtpServer -NtpServer $_ -Confirm:$false}
        }
    }
    catch {
        Write-Host "HOST_CHECK_NTP_CONFIG"
        Write-Host "Could not add NTP servers."
        $error[0]
    }

    # Check NTP is configured with time servers.
    Write-Host "Enable the NTP service." -ForegroundColor Green
    try {
        If ($ntpSvc = Get-VMHostService | Where-Object {($_.Key -eq "ntpd") -and ($_.Running -ne $True)}) {
            Write-Host "The SSH service is not running. Starting the SSH service." -ForegroundColor Magenta
            Start-VMHostService $ntpSvc -Confirm:$false
        }
    }
    catch {
        Write-Host "HOST_CHECK_NTP_CONFIG"
        Write-Host "Could not enable and start the NTP service."
        $error[0]
    }

# Check if the ESXi host is in Maintenance Mode. If so, try to exit Maintenance Mode.
    # Check the SSH service policy is set to start and stop with the host.
    Write-Host "Checking to see if the host is in Maintenance Mode." -ForegroundColor Green
    try {
        If ($mm = Get-VMHost -State Maintenance) {
            Write-Host "The host is in Maintenance Mode. Exiting Maintenance Mode." -ForegroundColor Magenta
            Set-VMHost $mm -State Connected
        }
    }
    catch {
        Write-Host "HOST_CHECK_IN_MAINTENANCE"
        Write-Host "The host could not be taken out of Maintenance Mode."
        Write-Host $error[0]
    }  

}