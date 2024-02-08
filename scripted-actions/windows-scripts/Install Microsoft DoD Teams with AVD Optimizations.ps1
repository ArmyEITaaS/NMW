#description: Installs the latest version of Microsoft DoD Teams, WebRTC, and VisualC for AVD Media Optimizations
#execution mode: Individual
#tags: ITaaS
<#
Expands OS disk to maximum allowed volume size, useful when increasing the size beyond 128GB.
#>

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

try {
    Write-Output "Starting Script - Install Microsoft Teams"

    $TmpDirectoryPath = "C:\Temp"
    $BootstrapDirectoryPath = Join-Path -Path $TmpDirectoryPath -ChildPath "bootstrap-microsoft-teams-dod"
    New-Item -Path $BootstrapDirectoryPath -ItemType Directory -Force | Out-Null
    if (-not (Test-Path $BootstrapDirectoryPath)) {
        throw "Failed to find bootstrap directory '$BootstrapDirectoryPath'"
    }

    $MicrosoftTeamsRegistryItemPath = "HKLM:\SOFTWARE\Microsoft"
    $MicrosoftTeamsDirectoryPath = Join-Path -Path $BootstrapDirectoryPath -ChildPath "teams"
    $VisualCPlusPlusDownloadUrl = "https://aka.ms/vs/16/release/vc_redist.x64.exe"
    $VisualCPlusPlusExeFileName = "vc_redist.x64.exe"
    $VisualCPlusPlusExeFilePath = Join-Path -Path $MicrosoftTeamsDirectoryPath -ChildPath $VisualCPlusPlusExeFileName
    $WebSocketServiceDownloadUrl = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4AQBt"
    $WebSocketServiceMsiFileName = "webSocketSvc.msi"
    $WebSocketServiceMsiFilePath = Join-Path -Path $MicrosoftTeamsDirectoryPath -ChildPath $WebSocketServiceMsiFileName
    $MicrosoftTeamsDownloadUrl = "https://dod.teams.microsoft.us/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true"
    $MicrosoftTeamsMsiFileName = "teams.msi"
    $MicrosoftTeamsMsiFilePath = Join-Path -Path $MicrosoftTeamsDirectoryPath -ChildPath $MicrosoftTeamsMsiFileName

    Write-Output "Configuring registry for Microsoft Teams AVD Media Optimization"
    New-Item -Path $MicrosoftTeamsRegistryItemPath -Name "Teams" -Force
    New-ItemProperty `
        -Path "${MicrosoftTeamsRegistryItemPath}\Teams" `
        -Name "IsWVDEnvironment" `
        -PropertyType "Dword" `
        -Value 1 `
        -Force

    Write-Output "Creating working directory for Microsoft Teams '$MicrosoftTeamsDirectoryPath'"
    New-Item -Path $MicrosoftTeamsDirectoryPath -ItemType Directory -Force

    Write-Output "Downloading Visual C++ for Microsoft Teams"
    Invoke-WebRequest -Uri $VisualCPlusPlusDownloadUrl -OutFile $VisualCPlusPlusExeFilePath
    if (-not (Test-Path $VisualCPlusPlusExeFilePath)) {
        throw "Failed to find downloaded Visual C++ file for Microsoft Teams '$VisualCPlusPlusExeFilePath'"
    }

    Write-Output "Installing Visual C++ for Microsoft Teams"
    Start-Process -Wait `
        -FilePath $VisualCPlusPlusExeFilePath `
        -Args "/install /quiet /norestart /log vcdist.log"

    Write-Output "Downloading WebSocket Service for Microsoft Teams"
    Invoke-WebRequest -Uri $WebSocketServiceDownloadUrl -OutFile $WebSocketServiceMsiFilePath
    if (-not (Test-Path $WebSocketServiceMsiFilePath)) {
        throw "Failed to find downloaded WebSocket Service file for Microsoft Teams '$WebSocketServiceMsiFilePath'"
    }

    Write-Output "Installing WebSocket Service for Microsoft Teams"
    Start-Process  -Wait `
        -FilePath msiexec.exe `
        -Args "/I $WebSocketServiceMsiFilePath /quiet /norestart /log webSocket.log"

    Write-Output "Downloading Microsoft Teams"
    Invoke-WebRequest -Uri $MicrosoftTeamsDownloadUrl -OutFile $MicrosoftTeamsMsiFilePath
    if (-not (Test-Path $MicrosoftTeamsMsiFilePath)) {
        throw "Failed to find downloaded Microsoft Teams file '$MicrosoftTeamsMsiFilePath'"
    }

    Write-Output "Installing Microsoft Teams"
    Start-Process  -Wait `
        -FilePath msiexec.exe `
        -Args "/I $MicrosoftTeamsMsiFilePath /quiet /norestart /log teams.log ALLUSER=1 ALLUSERS=1"

    Write-Output "Completed Script - Install Microsoft Teams"
} finally {
    Remove-Item -Path $BootstrapDirectoryPath -Recurse -Force -ErrorAction SilentlyContinue
}
