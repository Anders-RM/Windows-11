# Ensure logging directory exists and start logging PowerShell commands
$LogPath = Join-Path $PSScriptRoot "powershell.log"
if (-not (Test-Path $LogPath)) { New-Item -Path $LogPath -ItemType File -Force }
Start-Transcript -Path $LogPath -Append -IncludeInvocationHeader

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
# Define the list of apps to uninstall
$appList = @(
    "Microsoft.BingNews",
    "Microsoft.WindowsAlarms",
    "Clipchamp.Clipchamp",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.WindowsMaps",
    "MicrosoftTeams",
    "Microsoft.PowerAutomateDesktop",
    "MicrosoftCorporationII.QuickAssist",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.BingWeather",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxGameOverlay",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.YourPhone",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "Microsoft.Todos",
    "Microsoft.GamingApp",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.windowscommunicationsapps"
)

#set $defaultVMfolder as Environment Variable for AfterReboot.ps1 and AfterReboot.ps1 removes the Environment Variable
[Environment]::SetEnvironmentVariable("defaultVMfolder", $defaultVMfolder, "Machine")

# Set the region to English Denmark
Set-Culture -CultureInfo "en-DK"

function PromptUser($title, $prompt, $defaultChoice = 0) {
    $choices = [System.Management.Automation.Host.ChoiceDescription[]]@(
        (New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'),
        (New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList '&No')
    )
    return $host.ui.PromptForChoice($title, $prompt, $choices, $defaultChoice)
}

function InstallModule($moduleName) {
    if (!(Get-Module -ListAvailable -Name $moduleName)) {
        Install-Module -Name $moduleName -Force -AllowClobber
    }
}

$Backup = PromptUser "Set up backup task schedule", "Do you want to activate backup?"
$Update = PromptUser "Windows Update", "Do you want to install Windows Update"
$Office = PromptUser "Office Installation", "Do you want to install and activate Office?", 1


Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\*" -Recurse
Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce\*" -Recurse
Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run\*" -Recurse
Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce\*" -Recurse

InstallModule "PowerShellGet"
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

if ($Update -eq 0) {
    # Get the available updates.
    Write-Host "Get the available Windows Update"
    Get-WindowsUpdate | Out-File "$PSScriptRoot\$(get-date -f yyyy-MM-dd)_Get-WindowsUpdate.log" -force

    # Install all the updates.
    Write-Host "Install all the updates"
    Install-WindowsUpdate -AcceptAll -Install -IgnoreReboot | Out-File "$PSScriptRoot\$(get-date -f yyyy-MM-dd)_Install-WindowsUpdate.log" -force
}

# Check if OneDrive is installed
$onedriveInstalled = $false

if (Test-Path "$env:windir\System32\OneDriveSetup.exe" -or Test-Path "$env:windir\SysWOW64\OneDriveSetup.exe") {
    $onedriveInstalled = $true
}

# Uninstall OneDrive if it is installed
if ($onedriveInstalled) {
    Get-Process onedrive | Stop-Process -Force

    Write-Output "Removing OneDrive"
    if (Test-Path "$env:windir\System32\OneDriveSetup.exe") {
        start-process "$env:windir\System32\OneDriveSetup.exe" /uninstall -Wait
        Write-Host "OneDrive32 has been uninstalled."
    }
    if (Test-Path "$env:windir\SysWOW64\OneDriveSetup.exe") {
        start-process "$env:windir\SysWOW64\OneDriveSetup.exe" /uninstall -Wait
        Write-Host "OneDrive64 has been uninstalled."
    }
} else {
    Write-Output "OneDrive is not installed."
}

# Import the required modules
Import-Module -Name Microsoft.PowerShell.Management

# Uninstall apps
foreach($app in $appList) {
    # Get the package
    $package = Get-AppxPackage -AllUsers | Where-Object { $_.Name -eq $app }

    # Check if the package exists
    if($package) {
        foreach($package in $package){
            try {
                # Attempt to remove the package for all users
                Remove-AppxPackage -Package $package.PackageFullName -AllUsers -ErrorAction Stop
                Write-Host "$app has been uninstalled for all users."
            }
            catch {
                Write-Host "Failed to uninstall $app."
            }
        }
    }
    else {
        Write-Host "$app is not installed."
    }
}

# Check if Windows Store is installed
$storeApp = Get-AppxPackage -Name Microsoft.WindowsStore -ErrorAction SilentlyContinue

if ($null -eq $storeApp) {
# Windows Store is not installed, so install it (this might require administrative privileges)
wsreset -i
Get-AppxPackage -allusers Microsoft.WindowsStore | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register “$($_.InstallLocation)\AppXManifest.xml”}
Write-Host "Windows Store has been installed."
} else {
Write-Host "Windows Store is already installed."
}