#description: Set Content of Hosts File
#tags: ITaaS
<#
Notes:
This script will set the contents of the hosts file on the VM.
#>

$HostEntries = @{
    "INT01A" = @{
        "VA" = @(
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
    "INT01B" = @{
        "VA" = @(
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
}

Write-Output "Finding ring slice and region for VM '$AzureVMName'"
[Regex] $AzureVMNameRegex = "AVD(AZ|TX|VA)([A-Z]{3})(0[1-9]|[1-9][0-9])([A-B]{1})IMG"
$AzureVMNameRegexMatchedValues = $AzureVMNameRegex.match($AzureVMName).Groups.Value
$AzureVMRingSlice = $AzureVMNameRegexMatchedValues[2..4] -join ""
$AzureVMLocation = $AzureVMNameRegexMatchedValues[1]

Write-Output "Found ring slice '$AzureVMRingSlice' and region '$AzureVMLocation' for VM '$AzureVMName'"
$AzureVMHostEntries = $HostEntries.$AzureVMRingSlice.$AzureVMLocation
Write-Output "Found $($AzureVMHostEntries.Count) host entries to add to VM '$AzureVMName'"

$UTCDateTime = Get-Date (Get-Date).ToUniversalTime() -UFormat '+%Y%m%dT%H%MZ'
$HostsFilePath = "$env:windir\System32\drivers\etc\hosts"
$BackupHostsFilePath = "${HostsFilePath}.${UTCDateTime}.bak"
Move-Item -Path $HostsFilePath -Destination $BackupHostsFilePath -Force

foreach ($AzureVMHostEntry in $AzureVMHostEntries) {
    $HostEntry = "$($AzureVMHostEntry.IPAddress.Trim()) $($AzureVMHostEntry.FQDN.Trim())"
    Write-Output "Adding entry '$HostEntry' to host file for VM '$AzureVMName'"
    $HostEntry | Tee-Object -FilePath $HostsFilePath -Append
}
