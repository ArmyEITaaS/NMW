#description: Expands OS disk to maximum allowed volume size, useful when creating an image or VM with an OS disk size beyond 128GB
#execution mode: Individual
#tags: ITaaS
<#
Expands OS disk to maximum allowed volume size, useful when increasing the size beyond 128GB
#>

try {
    $PreviousVerbosePreference = $VerbosePreference
    $VerbosePreference = [System.Management.Automation.ActionPreference]::Continue
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    $StartDateTime = Get-Date
    $StartDateTimeUTC = $StartDateTime.ToUniversalTime()

    $LogDirectoryPath = "C:\Windows\temp\NerdioManagerLogs\ScriptedActions\expandosdisk"
    $LogFilePath = Join-Path -Path $LogDirectoryPath -ChildPath "ps_log.txt"
    New-Item -Path $LogDirectoryPath -ItemType Directory -Force | Out-Null
    Start-Transcript -Path $LogFilePath -Append
    Write-Output "Starting Script - Date/Time UTC $StartDateTimeUTC - Expand OS Disk to Max Size"

    $DiskCPartition = Get-Partition -DriveLetter "C"
    $DiskCPartitionSupportedSize = Get-PartitionSupportedSize -DriveLetter "C"
    if ($DiskCPartition.Size -lt $DiskCPartitionSupportedSize.SizeMax) {
        Write-Output "Partition for 'C' drive partition is not maximum size, resizing partition"
        Resize-Partition -DriveLetter "C" -Size $DiskCPartitionSupportedSize.SizeMax
    } else {
        Write-Output "Partition for 'C' drive is already at maximum size"
    }

    $EndDateTime = Get-Date
    $EndDateTimeUTC = $EndDateTime.ToUniversalTime()
    Write-Output "Completed Script - Date/Time UTC $EndDateTimeUTC - Expand OS Disk to Max Size"
} finally {
    Remove-Item -Path $BootstrapDirectoryPath -Recurse -Force -ErrorAction SilentlyContinue
    Stop-Transcript
    $VerbosePreference = $PreviousVerbosePreference
}
