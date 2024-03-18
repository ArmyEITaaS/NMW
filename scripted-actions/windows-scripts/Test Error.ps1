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