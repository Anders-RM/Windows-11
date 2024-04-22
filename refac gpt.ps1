# Ensure logging directory exists and start logging PowerShell commands
$LogPath = Join-Path $PSScriptRoot "powershell.log"
if (-not (Test-Path $LogPath)) { New-Item -Path $LogPath -ItemType File -Force }
Start-Transcript -Path $LogPath -Append -IncludeInvocationHeader

# Configuration settings
$Config = @{
    OfficeUrl = "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=O365ProPlusRetail&platform=x64&language=en-us&version=O16GA"
    NugetUrl = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
    UiXamlUrl = "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx"
    VcLibsUrl = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
    DefaultVMfolder = "C:\VMs"
    PowerPlanName = "Ultimate Performance"
    NugetPath = Join-Path $PSScriptRoot "NuGet.exe"
    WtSettings = Join-Path $HOME "AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    OnePasswordUrl = "https://downloads.1password.com/win/1PasswordSetup-latest.exe"
    WingetApiUrl = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
}

# Download and install utilities function
function Download-And-Install($url, $localPath) {
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($url, $localPath)
        Write-Host "Downloaded and installed from $url"
    } catch {
        Write-Host "Failed to download from $url. Error: $($_.Exception.Message)"
    }
}

# Remove startup items
"HKCU:\Software\Microsoft\Windows\CurrentVersion\Run", 
"HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce", 
"HKLM:\Software\Microsoft\Windows\CurrentVersion\Run", 
"HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" | ForEach-Object {
    Remove-Item -Path $_ -Recurse -ErrorAction SilentlyContinue
}

# Set environment variables
[Environment]::SetEnvironmentVariable("defaultVMfolder", $Config.DefaultVMfolder, "Machine")

# Localization settings
Set-Culture -CultureInfo "en-DK"

# Package installations
function Ensure-PackageInstalled($name, $installerUrl) {
    if (-not (Get-PackageProvider -Name $name -ListAvailable)) {
        Install-PackageProvider -Name $name -Force
        Import-PackageProvider -Name $name -Force
    }
    if (-not (Test-Path $Config.NugetPath)) {
        Download-And-Install $installerUrl $Config.NugetPath
    }
}

Ensure-PackageInstalled "NuGet" $Config.NugetUrl

# Ensure winget and other apps are installed
$wingetReleaseInfo = Invoke-RestMethod -Uri $Config.WingetApiUrl -Method Get
$wingetAsset = $wingetReleaseInfo.assets | Where-Object { $_.name -like "Microsoft.DesktopAppInstaller*.msixbundle" }
if ($wingetAsset) {
    Download-And-Install $wingetAsset.browser_download_url $PSScriptRoot
    Add-AppxPackage "$PSScriptRoot\winget.msixbundle"
    Remove-Item "$PSScriptRoot\winget.msixbundle"
} else {
    Write-Host "winget asset not found."
}

# 1Password installation
Download-And-Install $Config.OnePasswordUrl "$PSScriptRoot\1pass.exe"
Start-Process -FilePath "$PSScriptRoot\1pass.exe" --silent -Wait
Remove-Item "$PSScriptRoot\1pass.exe"

# Handling user choices for installations and updates
$choiceResultPswu = $host.ui.PromptForChoice("Windows Update", "Do you want to install Windows Update?", @('&Yes', '&No'), 0)
if ($choiceResultPswu -eq 0) {
    Install-WindowsUpdate -AcceptAll -AutoReboot | Out-File "$PSScriptRoot\$(get-date -f yyyy-MM-dd)_WindowsUpdate.log" -force
}

# Uninstall preinstalled apps
$appList = @(
    "Microsoft.BingNews", "Microsoft.WindowsAlarms", "Clipchamp.Clipchamp", "Microsoft.WindowsFeedbackHub",
    "Microsoft.MicrosoftOfficeHub", "Microsoft.WindowsMaps", "MicrosoftTeams"
)
$appList | ForEach-Object {
    $package = Get-AppxPackage -AllUsers | Where-Object { $_.Name -eq $_ }
    if ($package) {
        Remove-AppxPackage -package $package.PackageFullName -AllUsers -ErrorAction Stop
        Write-Host "$_ has been uninstalled for all users."
    } else {
        Write-Host "$_ is not installed."
    }
}

# Final steps: Restart and logging
Stop-Transcript
Restart-Computer -Force
