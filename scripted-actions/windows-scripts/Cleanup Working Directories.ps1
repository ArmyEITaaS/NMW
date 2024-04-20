#description: Cleanup working directories
#execution mode: Combined
#tags: ITaaS
<#
Cleanup working directories.
#>

Write-Output "Cleaning up working directories"
Remove-Item -Path "C:\AzureData\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\DSC\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\LGPO-STIGs" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\logs\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\virtual-desktop-optimization-tool\" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\WindowsDefenderATPOnboardingScript.cmd" -Force -ErrorAction SilentlyContinue
