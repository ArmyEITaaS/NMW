#description: Test output and error
#execution mode: Individual
#tags: ITaaS
<#
Test output and error
#>

Write-Host "Writing to host"
Write-Output "Writing to output"
Write-Error "writing to error"
throw "throw error"

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

Write-Host "Writing to host 2"
Write-Output "Writing to output 2"
Write-Error "writing to error 2"
throw "throw error 2"
