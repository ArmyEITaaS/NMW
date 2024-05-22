#description: Renew IP Configuration
#execution mode: Combined
#tags: ITaaS
<#
Notes:
This script will renew the IP configuration of the computer and check for expected DNS addresses.
#>

Write-Output "$VmName - Starting ipconfig renew script - $(Get-Date -Format "yyyyMMdd-HH:mm")"

$DesiredDnsIpAddresses = @(
    "140.20.254.11"
    "140.20.254.12"
    "140.20.254.13"
)

ipconfig /renew
ipconfig /all

$AddressCount = 0
$DnsIpAddresses = (Get-DnsClientServerAddress).ServerAddresses
foreach ($IpAddress in $DesiredDnsIpAddresses) {
    if ($DnsIpAddresses.Contains($IpAddress)) {
        $AddressCount++
        Write-Output "Found DNS IP address '$IpAddress' after ipconfig /renew"
    } else {
        Write-Output "Failed to find DNS IP address '$IpAddress' after ipconfig /renew"
    }
}

if ($AddressCount -eq $DesiredDnsIpAddresses.Count) {
    Write-Output "Found $($DesiredDnsIpAddresses.Count) cArmy IP addresses being used for DNS"
} else {
    Write-Output "Failed to find desired number of DNS IP addresses, found only $($AddressCount.Count) IP addresses"
}

Write-Output "$VmName - Completed ipconfig renew script - $(Get-Date -Format "yyyyMMdd-HH:mm")"
