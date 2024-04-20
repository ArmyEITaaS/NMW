#description: Configure Public Folder NTFS Permissions
#execution mode: Combined
#tags: ITaaS
<#
Configure public folder NTFS permissions.
#>

$AdministratorsGroupName = 'administrators'

Write-Output "Configuring NTFS permissions on 'C:\users\Public'"
icacls ("C:\users\Public") /reset
icacls ("C:\users\Public") /deny /t /c ("Everyone" + ":(OI)(CI)F")
icacls ("C:\users\Public") /grant ("SYSTEM" + ":(OI)(CI)F")
icacls ("C:\users\Public") /grant ("$AdministratorsGroupName" + ":(OI)(CI)F")
