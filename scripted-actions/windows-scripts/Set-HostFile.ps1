#description: Set Content of Hosts File
#execution mode: Combined
#tags: ITaaS
<#
Notes:
This script will set the contents of the hosts file on the VM.
#>

$HostEntries = @(
    @{
        IPAddress = "52.127.58.160"
        FQDN      = "power-apis-usdod-001.azure-apihub.us"
    }
)

$UTCDateTime = Get-Date (Get-Date).ToUniversalTime() -UFormat '+%Y%m%dT%H%MZ'
$HostsFilePath = "$env:windir\System32\drivers\etc\hosts"
$BackupHostsFilePath = "${HostsFilePath}.${UTCDateTime}.bak"
Move-Item -Path $HostsFilePath -Destination $BackupHostsFilePath -Force

foreach ($HostEntry in $HostEntries) {
    $HostEntry = "$($HostEntry.IPAddress.Trim()) $($HostEntry.FQDN.Trim())"
    Write-Output "Adding entry '$HostEntry' to host file"
    $HostEntry | Tee-Object -FilePath $HostsFilePath -Append
}
