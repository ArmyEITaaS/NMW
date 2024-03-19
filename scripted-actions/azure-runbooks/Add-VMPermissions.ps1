#description: Assign Reader RBAC role to the VM system identity on the VM scope, allow self-read
#tags: ITaaS

<# Notes:
    This script will assign the 'Reader' RBAC role to the VM system identity on the VM scope to allow self-read.
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

Write-Output "Found VM '$AzureVMName' in resource group '$AzureResourceGroupName'"
Write-Output "Checking if VM '$AzureVMName' has 'Reader' RBAC role on resource group '$AzureResourceGroupName'"
$ExistingVmResourceGroupReaderAssignment = Get-AzRoleAssignment `
    -ServicePrincipalName $VM.Identity.PrincipalId `
    -Scope $VM.Id `
    -RoleDefinitionName "Reader" `
    -ErrorAction SilentlyContinue

if (-Not $ExistingVmResourceGroupReaderAssignment) {
    Write-Output "Creating 'Reader' RBAC role for VM '$AzureVMName' on resource group '$AzureResourceGroupName'"
    New-AzRoleAssignment `
        -ApplicationId $VM.Identity.PrincipalId `
        -Scope $VM.Id `
        -RoleDefinitionName "Reader" `
        -ErrorAction Stop | Out-Null
}
