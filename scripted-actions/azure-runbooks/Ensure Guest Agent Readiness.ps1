#description: Checks for VM guest agent readiness, restarts the VM if the guest agent is not ready
#tags: ITaaS

<# Notes:
    This script check if the VM guest agent is ready, restart the VM if the guest agent is not ready, and then wait up to 15 minutes for it to be ready.
#>

Disable-AzContextAutosave -Scope Process | Out-Null
Set-AzContext -SubscriptionId $AzureSubscriptionId | Out-Null

$VM = Get-AzVM `
    -ResourceGroupName $AzureResourceGroupName `
    -Name $AzureVMName `
    -Status `
    -ErrorAction SilentlyContinue

if ($null -eq $VM) {
    throw "Failed to find VM '$AzureVMName' in resource group '$AzureResourceGroupName'"
}

$VmAgentStatus = $VM.VMAgent.Statuses.DisplayStatus
if ($VmAgentStatus -ilike "Not ready") {
    Write-Output "Restarting VM because guest agent is not ready"
    $RestartedVM = $PSItem | Restart-AzVM
    if ($RestartedVM.Status -ne "Succeeded") {
        Write-Warning "Failed to restart VM due to $($RestartedVM.Error)"
        continue
    }

    $Timeout = New-TimeSpan -Minutes 15
    $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    while (($VmAgentStatus -ne "Ready") -and ($StopWatch.Elapsed -lt $Timeout)) {
        Start-Sleep -Seconds 30
        $VmAgentStatus = ($PSItem | Get-AzVM -Status).VMAgent.Statuses.DisplayStatus
        if ($VmAgentStatus -ne "Ready") {
            Write-Output "Waiting for VM guest agent to be ready with current status '$($VmAgentStatus)'"
        }
    }
    $StopWatch.Stop()

    if ($VmAgentStatus -eq "Ready") {
        Write-Output "VM guest agent is ready"
    } else {
        throw "VM guest agent did not become ready before timeout period with current status '$($VM.VMAgent.Statuses.DisplayStatus)'"
    }
}
