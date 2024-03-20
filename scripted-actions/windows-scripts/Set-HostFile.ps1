#description: Set Content of Hosts File
#tags: ITaaS
<#
Notes:
This script will set the contents of the hosts file on the VM.
#>

$HostEntries = @(
    @{
        ResourceGroupName = "P-ARMY-AVD-VA-01-INT01A-1"
        Entries           = @(
            @{
                IPAddress = "172.23.255.228"
                FQDN      = "parmyavdvaint01fx1.blob.core.usgovcloudapi.net"
            }
            @{
                IPAddress = "172.23.255.229"
                FQDN      = "parmyavdvaint01fx1.file.core.usgovcloudapi.net"
            }
            @{
                IPAddress = "52.127.58.160"
                FQDN      = "power-apis-usdod-001.azure-apihub.us"
            }
        )
    }
    @{
        ResourceGroupName = "P-ARMY-AVD-VA-01-INT01B-1"
        Entries           = @(
            @{
                IPAddress = "172.23.255.244"
                FQDN      = "parmyavdvaint01fx1.blob.core.usgovcloudapi.net"
            }
            @{
                IPAddress = "172.23.255.245"
                FQDN      = "parmyavdvaint01fx1.file.core.usgovcloudapi.net"
            }
            @{
                IPAddress = "52.127.58.160"
                FQDN      = "power-apis-usdod-001.azure-apihub.us"
            }
        )
    }
)

$ResourceGroupHostEntries = $HostEntries.Where({ $PSItem.ResourceGroupName -eq "P-ARMY-AVD-VA-01-INT01B-1" }).Entries

$UTCDateTime = Get-Date (Get-Date).ToUniversalTime() -UFormat '+%Y%m%dT%H%MZ'
$HostsFilePath = "$env:windir\System32\drivers\etc\hosts"
$BackupHostsFilePath = "${HostsFilePath}.${UTCDateTime}.bak"
Move-Item -Path $HostsFilePath -Destination $BackupHostsFilePath -Force

foreach ($HostEntry in $ResourceGroupHostEntries) {
    "$($HostEntry.IPAddress.Trim()) $($HostEntry.FQDN.Trim())" | Tee-Object -FilePath $HostsFilePath -Append
}
