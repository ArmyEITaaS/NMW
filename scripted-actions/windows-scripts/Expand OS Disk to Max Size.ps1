#description: Expands OS disk to maximum allowed volume size, useful when creating an image or VM with an OS disk size beyond 128GB
#execution mode: Individual
#tags: ITaaS
<#
Expands OS disk to maximum allowed volume size, useful when increasing the size beyond 128GB
#>

$DiskCPartition = Get-Partition -DriveLetter "C"
$DiskCPartitionSupportedSize = Get-PartitionSupportedSize -DriveLetter "C"
if ($DiskCPartition.Size -lt $DiskCPartitionSupportedSize.SizeMax) {
    Write-Host "Partition for 'C' drive partition is not maximum size, resizing partition"
    Resize-Partition -DriveLetter "C" -Size $DiskCPartitionSupportedSize.SizeMax
} else {
    Write-Host "Partition for 'C' drive is already at maximum size"
}
