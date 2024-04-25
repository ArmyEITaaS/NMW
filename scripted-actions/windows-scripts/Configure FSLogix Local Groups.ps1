#description: Configure FSLogix Local Groups
#execution mode: Combined
#tags: ITaaS
<#
Configure FSLogix local groups.
#>

$FSLogixLocalAdministratorsGroupName = "Administrators"
$FSLogixLocalAdministratorsUserName = "localadmin"
$FSLogixLocalAdministratorsUserFullName = "${env:COMPUTERNAME}\${FSLogixLocalAdministratorsUserName}"
$FSLogixLocalAdministratorsGroupFullName = "BUILTIN\${FSLogixLocalAdministratorsGroupName}"
$FSLogixODFCExcludeGroupName = "FSLogix ODFC Exclude List"
$FSLogixProfileExcludeGroupName = "FSLogix Profile Exclude List"

Write-Output "Configure FSLogix local group membership"

$FslogixProfileExcludeGroupMembers = Get-LocalGroupMember -Name $FSLogixProfileExcludeGroupName
if ($FslogixProfileExcludeGroupMembers.Name -inotcontains $FSLogixLocalAdministratorsGroupFullName) {
    Write-Output "Excluding local group '$FSLogixLocalAdministratorsGroupName' from local group '$FSLogixProfileExcludeGroupName'"
    Add-LocalGroupMember -Group $FSLogixProfileExcludeGroupName -Member $FSLogixLocalAdministratorsGroupFullName | Out-Null
}

$FslogixODFCExcludeGroupMembers = Get-LocalGroupMember -Name $FSLogixODFCExcludeGroupName
if ($FslogixODFCExcludeGroupMembers.Name -inotcontains $FSLogixLocalAdministratorsGroupFullName) {
    Write-Output "Excluding local group '$FSLogixLocalAdministratorsGroupName' from local group '$FSLogixODFCExcludeGroupName'"
    Add-LocalGroupMember -Group $FSLogixODFCExcludeGroupName -Member $FSLogixLocalAdministratorsGroupFullName | Out-Null
}

$FslogixProfileExcludeGroupMembers = Get-LocalGroupMember -Name $FSLogixProfileExcludeGroupName
if ($FslogixProfileExcludeGroupMembers.Name -inotcontains $FSLogixLocalAdministratorsUserFullName) {
    Write-Output "Excluding local user '$FSLogixLocalAdministratorsUserName' from local group '$FSLogixProfileExcludeGroupName'"
    Add-LocalGroupMember -Group $FSLogixProfileExcludeGroupName -Member $FSLogixLocalAdministratorsUserFullName | Out-Null
}

$FslogixODFCExcludeGroupMembers = Get-LocalGroupMember -Name $FSLogixODFCExcludeGroupName
if ($FslogixODFCExcludeGroupMembers.Name -inotcontains $FSLogixLocalAdministratorsUserFullName) {
    Write-Output "Excluding local user '$FSLogixLocalAdministratorsUserName' from local group '$FSLogixODFCExcludeGroupName'"
    Add-LocalGroupMember -Group $FSLogixODFCExcludeGroupName -Member $FSLogixLocalAdministratorsUserFullName | Out-Null
}
