#description: Remove Reader RBAC role from the VM system identity on the VM scope, disallow self-read
#tags: ITaaS
<# Notes:
    This script will remove the 'Reader' RBAC role from the VM system identity on the VM scope to disallow self-read.
#>

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

Write-Output "Checking for VM '$AzureVMName' in resource group '$AzureResourceGroupName'"
$VM = Get-AzVM `
    -ResourceGroupName $AzureResourceGroupName `
    -Name $AzureVMName `
    -Status `
    -ErrorAction SilentlyContinue

if ($null -eq $VM) {
    throw "Failed to find VM '$AzureVMName' in resource group '$AzureResourceGroupName'"
}

Write-Output "Found VM '$AzureVMName' in resource group '$AzureResourceGroupName'"
Write-Output "Checking if VM '$AzureVMName' has 'Reader' RBAC role on resource group '$AzureResourceGroupName'"
$ExistingVmResourceGroupReaderAssignment = Get-AzRoleAssignment `
    -ServicePrincipalName $VM.Identity.PrincipalId `
    -Scope $VM.Id `
    -RoleDefinitionName "Reader" `
    -ErrorAction SilentlyContinue

if ($ExistingVmResourceGroupReaderAssignment) {
    Write-Output "Removing 'Reader' RBAC role for VM '$AzureVMName' on resource group '$AzureResourceGroupName'"
    Remove-AzRoleAssignment `
        -ObjectId $ExistingVmResourceGroupReaderAssignment.ObjectId | Out-Null
}
