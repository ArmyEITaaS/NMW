#description: Reinstalls the RDAgent on target VM
#tags: Nerdio, Preview

<#
Notes:

This scripted action is intended to be used with Nerdio's Auto-heal feature. It uninstalls
the RDAgent, removes the VM from the host pool, reinstalls the RDAgent, and adds the host
back to the host pool.

This script is compatible with the ARM version of AVD (Spring 2020), and is not compatible with
v1 (Fall 2019) Azure WVD.

#>

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

try {
    Write-Output "Getting Host Pool Information"
    $HostPool = Get-AzResource -ResourceId $HostpoolID
    $HostPoolResourceGroupName = $HostPool.ResourceGroupName
    $HostPoolName = $Hostpool.Name

    $Script = @"
`$tempFolder = [environment]::GetEnvironmentVariable('TEMP', 'Machine')
`$logsFolderName = "NMWLogs"
`$logsPath = "`$tempFolder\`$logsFolderName"
if (-not (Test-Path -Path `$logsPath)) {
    New-Item -Path `$tempFolder -Name `$logsFolderName -ItemType Directory -Force | Out-Null
}

`$wvdAppsLogsFolderName = "WVDApps"
`$wvdAppsLogsPath = "`$logsPath\`$wvdAppsLogsFolderName"
if (-not (Test-Path -Path `$wvdAppsLogsPath)) {
    New-Item -Path `$logsPath -Name `$wvdAppsLogsFolderName -ItemType Directory -Force | Out-Null
}

`$AgentGuids = get-wmiobject Win32_Product | where-Object Name -eq 'Remote Desktop Services Infrastructure Agent' | select identifyingnumber -ExpandProperty identifyingnumber
Write-Output "Uninstalling any previous versions of RD Agent on VM"
Foreach (`$guid in `$AgentGuids) {
    `$avd_uninstall_status = Start-Process -FilePath "msiexec.exe" -ArgumentList "/x `$guid", "/quiet", "/qn", "/norestart", "/passive", "/l* `$wvdAppsLogsPath\RDAgentUninstall.log" -Wait -Passthru
    `$sts = `$avd_uninstall_status.ExitCode
    Write-Output "Uninstalling AVD Agetnt on VM Complete. Exit code=`$sts"
}
"@

    $VM = Get-AzVM `
        -VMName $AzureVMName `
        -ErrorAction SilentlyContinue

    if ($null -eq $VM) {
        throw "Failed to find VM '$AzureVMName' in resource group '$AzureResourceGroupName'"
    }

    $Script | Out-File ".\Uninstall-AVDAgent-${AzureVMName}.ps1"

    Write-Output "Execute uninstall script on remote VM '$AzureVMName'"
    $RunCommand = Invoke-AzVMRunCommand `
        -ResourceGroupName $VM.ResourceGroupName `
        -VMName $AzureVMName `
        -CommandId 'RunPowerShellScript' `
        -ScriptPath ".\Uninstall-AVDAgent-${AzureVMName}.ps1" `
        -DefaultProfile (Set-AzContext -Subscription $VM.Id.Split('/')[2])

    $errors = $RunCommand.Value | Where-Object Code -EQ 'ComponentStatus/StdErr/succeeded'
    if ($errors.message) {
        Throw "Error when uninstalling RD components. $($errors.message)"
    }
    Write-Output "Output from RunCommand:"
    $RunCommand.Value | Where-Object Code -EQ 'ComponentStatus/StdOut/succeeded' | Select-Object message -ExpandProperty message

    Write-Output "Restarting VM '$AzureVMName' after uninstall"
    $VM | Restart-AzVM

    $SessionHost = Get-AzWvdSessionHost `
        -HostPoolName $hostpoolname `
        -ResourceGroupName $HostPoolResourceGroupName | Where-Object name -Match $azureVMName

    Remove-AzWvdSessionHost `
        -ResourceGroupName $HostPoolResourceGroupName `
        -HostPoolName $HostPoolName -Name ($SessionHost.name -split '/')[1]

    Write-Output "Removed session host from host pool"

    $RegistrationKey = Get-AzWvdRegistrationInfo -ResourceGroupName $HostPoolResourceGroupName -HostPoolName $HostPoolName
    if (-not $RegistrationKey.Token) {
        Write-Output "Generating new registration token for host pool '$HostPoolName'"
        $RegistrationKey = New-AzWvdRegistrationInfo `
            -ResourceGroupName $HostPoolResourceGroupName `
            -HostPoolName $HostPoolName `
            -ExpirationTime $((Get-Date).ToUniversalTime().AddDays(1).ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ')) `
            -DefaultProfile (Set-AzContext -Subscription $HostPool.SubscriptionId)
    }

    $RegistrationToken = $RegistrationKey.token


    $Script = @"
`$tempFolder = [environment]::GetEnvironmentVariable('TEMP', 'Machine')
`$logsFolderName = "NMWLogs"
`$logsPath = "`$tempFolder\`$logsFolderName"
if (-not (Test-Path -Path `$logsPath)) {
    New-Item -Path `$tempFolder -Name `$logsFolderName -ItemType Directory -Force | Out-Null
}

`$wvdAppsLogsFolderName = "WVDApps"
`$wvdAppsLogsPath = "`$logsPath\`$wvdAppsLogsFolderName"
if (-not (Test-Path -Path `$wvdAppsLogsPath)) {
    New-Item -Path `$logsPath -Name `$wvdAppsLogsFolderName -ItemType Directory -Force | Out-Null
}

`$AgentInstaller = (Get-ChildItem 'C:\Program Files\Microsoft RDInfra\' | ? name -Match Microsoft.RDInfra.RDAgent.Installer | sort lastwritetime -Descending | select -First 1).fullname
`$InstallerPath = '"' + `$AgentInstaller + '"'

Write-Output "Installing RD Infra Agent on VM `$InstallerPath"

`$agent_deploy_status = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `$installerPath", "/quiet", "/qn", "/norestart", "/passive", "REGISTRATIONTOKEN=$RegistrationToken", "/l* `$wvdAppsLogsPath\RDInfraAgentInstall.log" -Wait -Passthru
`$sts = `$agent_deploy_status.ExitCode
Write-Output "Installing RD Infra Agent on VM Complete. Exit code=`$sts"
`$Log = get-content `$wvdAppsLogsPath\RDInfraAgentInstall.log
Write-output `$log
"@

    $VM = Get-AzVM `
        -VMName $AzureVMName `
        -ErrorAction SilentlyContinue

    if ($null -eq $VM) {
        throw "Failed to find VM '$AzureVMName' in resource group '$AzureResourceGroupName'"
    }

    $Script | Out-File ".\Reinstall-AVDAgent-${AzureVMName}.ps1"

    Write-Output "Execute reinstall script on remote VM '$AzureVMName'"
    $RunCommand = Invoke-AzVMRunCommand `
        -ResourceGroupName $VM.ResourceGroupName `
        -VMName $AzureVMName `
        -CommandId 'RunPowerShellScript' `
        -ScriptPath ".\Reinstall-AVDAgent-${AzureVMName}.ps1" `
        -DefaultProfile (Set-AzContext -Subscription $VM.Id.Split('/')[2])

    $errors = $RunCommand.Value | Where-Object Code -EQ 'ComponentStatus/StdErr/succeeded'
    if ($errors.message) {
        Throw "Error when reinstalling RD agent. $($errors.message)"
    }
    Write-Output "Output from RunCommand:"
    $RunCommand.Value | Where-Object Code -EQ 'ComponentStatus/StdOut/succeeded' | Select-Object message -ExpandProperty message

    Write-Output "Restarting VM '$AzureVMName' after reinstall"
    $VM | Restart-AzVM

    if ($SessionHost.assigneduser) {
        Write-Output "Re-assigning previously assigned user on VM '$AzureVMName'"
        Update-AzWvdSessionHost `
            -HostPoolName $hostpoolname `
            -Name ($SessionHost.name -split '/')[1] `
            -AssignedUser $SessionHost.AssignedUser `
            -ResourceGroupName $HostPoolResourceGroupName
    }
} catch {
    $ErrorScript = $PSItem.InvocationInfo.ScriptName
    $ErrorScriptLine = "$($PSItem.InvocationInfo.ScriptLineNumber):$($PSItem.InvocationInfo.OffsetInLine)"
    $ErrorMessage = "$($PSItem.Exception.Message) Error Script: $ErrorScript, Error Line: $ErrorScriptLine"
    Write-Error -Message $ErrorMessage -Exception $PSItem.Exception
}
