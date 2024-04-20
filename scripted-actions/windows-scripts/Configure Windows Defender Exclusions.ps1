#description: Configure Windows Defender Exclusions
#execution mode: Combined
#tags: ITaaS
<#
Configure Windows Defender exclusions for FSLogix and other processes.
#>

$FSLogixProfilePath = "C:\Program Files\FSLogix"

Write-Output "Configure Windows Defender exclusions"
Add-MpPreference -ExclusionPath "%ProgramFiles%\FSLogix\Apps\frxdrv.sys"
Add-MpPreference -ExclusionPath "%ProgramFiles%\FSLogix\Apps\frxdrvvt.sys"
Add-MpPreference -ExclusionPath "%ProgramFiles%\FSLogix\Apps\frxccd.sys"
Add-MpPreference -ExclusionPath "%TEMP%\*.VHD"
Add-MpPreference -ExclusionPath "%TEMP%\*.VHDX"
Add-MpPreference -ExclusionPath "%Windir%\TEMP\*.VHD"
Add-MpPreference -ExclusionPath "%Windir%\TEMP\*.VHDX"
Add-MpPreference -ExclusionPath "${FSLogixProfilePath}\**.VHD"
Add-MpPreference -ExclusionPath "${FSLogixProfilePath}\**.VHDX"
Add-MpPreference -ExclusionProcess "%ProgramFiles%\FSLogix\Apps\frxccd.exe"
Add-MpPreference -ExclusionProcess "%ProgramFiles%\FSLogix\Apps\frxccds.exe"
Add-MpPreference -ExclusionProcess "%ProgramFiles%\FSLogix\Apps\frxsvc.exe"
