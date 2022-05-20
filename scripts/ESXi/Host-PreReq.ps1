
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

}