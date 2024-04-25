# Ensure logging directory exists and start logging PowerShell commands
$LogPath = Join-Path $PSScriptRoot "powershell.log"
if (-not (Test-Path $LogPath)) { New-Item -Path $LogPath -ItemType File -Force }
Start-Transcript -Path $LogPath -Append -IncludeInvocationHeader

$Config = @{
    OfficeUrl = "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=O365ProPlusRetail&platform=x64&language=en-us&version=O16GA"
    NugetUrl = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
    UiXamlUrl = "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx"
    VcLibsUrl = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
    PowerPlanName = "Ultimate Performance"
    NugetPath = Join-Path $PSScriptRoot "NuGet.exe"
    WtSettings = Join-Path $HOME "AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    OnePasswordUrl = "https://downloads.1password.com/win/1PasswordSetup-latest.exe"
    WingetApiUrl = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    VMwareUrl = "https://www.vmware.com/go/getplayer-win" 
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

# Install Programs using winget
$packageIds = @(
    "Microsoft.VisualStudioCode",
    "M2Team.NanaZip",
    "Microsoft.WindowsTerminal",
    "Brave.Brave"
)

# Set the region to English Denmark
Set-Culture -CultureInfo "en-DK"

function InstallModule($moduleName) {
    if (!(Get-Module -ListAvailable -Name $moduleName)) {
        Install-Module -Name $moduleName -Force -AllowClobber
    }
}
function PromptChoice {
    param (
        [string]$Title,
        [string]$Prompt,
        [string[]]$Choices,
        [int]$DefaultChoice = 0
    )

    $choiceDescriptions = $Choices | ForEach-Object {
        New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList "&$_"
    }

    $host.ui.PromptForChoice($Title, $Prompt, $choiceDescriptions, $DefaultChoice)
}

# 0 = Yes, 1 = No, Default = 0
$Backup = PromptChoice -Title "Set up backup task schedule" -Prompt "Do you want to activate backup?" -Choices @("Yes", "No") -DefaultChoice 1
$Update = PromptChoice -Title "Windows Update" -Prompt "Do you want to install Windows Update?" -Choices @("Yes", "No")
$Office = PromptChoice -Title "Office Installation" -Prompt "Do you want to install and activate Office?" -Choices @("Yes", "No")
$VM = PromptChoice -Title "VM Platform" -Prompt "Do you want want to install a VM platform?" -Choices @("Yes", "No")
if ($VM -eq 0) {
    $vmPlatform = PromptChoice -Title "VM Platform" -Prompt "Which VM platform do you want to install?" -Choices @("Hyper-V", "VMware") -DefaultChoice 1
}

# Check if NuGet is installed
if ($null -ne (Get-PackageProvider -ListAvailable | Where-Object { $_.Name -eq "NuGet" })) {
    Write-Host "NuGet is already installed."
} else {
    # Install NuGet if it's not already installed
    try {
        Install-PackageProvider -Name NuGet -Force
        Import-PackageProvider NuGet -Force

        # Check if NuGet exists
        if (!(Test-Path $Config.nugetPath)) {
            # NuGet doesn't exist, so download it
            $webClient = New-Object System.Net.WebClient
            try {
                $webClient.DownloadFile($Config.nugetUrl, $Config.nugetPath)
            } catch {
                Write-Host "Failed to download NuGet from "$Config.nugetUrl "to" $Config.nugetPath"."
                Write-Host $_.Exception.Message
            }
        }

        Write-Host "NuGet has been installed."
    } catch {
        Write-Host "Failed to install NuGet."
        Write-Host $_.Exception.Message
    }
}

InstallModule "PSWindowsUpdate"
InstallModule "PowerShellGet"
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\*" -Recurse
Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce\*" -Recurse
Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run\*" -Recurse
Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce\*" -Recurse

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

if ((Test-Path "$env:windir\System32\OneDriveSetup.exe") -or (Test-Path "$env:windir\SysWOW64\OneDriveSetup.exe")) {
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

# Invoke the GitHub API and retrieve the latest release information
$wingetreleaseInfo = Invoke-RestMethod -Uri $Config.wingetapiUrl -Method Get

# Extract the asset information (you might need to adjust this based on your asset's name or criteria)
$wingetasset = $wingetreleaseInfo.assets | Where-Object { $_.name -like "Microsoft.DesktopAppInstaller*.msixbundle" }

if ($wingetasset) {
    $wingetUrl = $wingetasset.browser_download_url
   
} else {
    Write-Host "Asset not found in the latest release."
}

# Test if winget is installed
try {
    $winget = Get-Command winget -ErrorAction Stop
    Write-Host "winget is already installed at $($winget.Source)"
} catch {
    Write-Host "winget is not installed. Installing now..."

    Start-BitsTransfer -Source  "$Config.uiXamlUrl" -Destination $PSScriptRoot\UIXaml.appx
    Add-AppxPackage $PSScriptRoot\UIXaml.appx

    Start-BitsTransfer -Source "$Config.vcLibsurl"  -Destination $PSScriptRoot\VCLibs.appx
    Add-AppxPackage $PSScriptRoot\VCLibs.appx

    Start-BitsTransfer -Source  "$wingetUrl" -Destination $PSScriptRoot\winget.msixbundle
    Add-AppxPackage $PSScriptRoot\winget.msixbundle

    # Remove the installer file
    Remove-Item $PSScriptRoot\winget.msixbundle
    Remove-Item $PSScriptRoot\UIXaml.appx
    Remove-Item $PSScriptRoot\VCLibs.appx

    Write-Host "winget is now installed"
}

# 1Password app
Start-BitsTransfer -Source $Config.OnePasswordUrl -Destination $PSScriptRoot\1pass.exe
Start-Process -FilePath $PSScriptRoot\1pass.exe --silent -Wait
Start-Sleep -Seconds 10
Remove-Item $PSScriptRoot\1pass.exe

Write-Output "Set a Pin (Windows Hello) and setup 1Password enable SSH agent under the developer settings. "
Start-Process "ms-settings:accounts"
Start-Process "ms-settings:accounts"
Read-Host -Prompt "Press any key to continue. . ."
Get-Process 1Password | Stop-Process

# 1Password CLI
$arch = (Get-CimInstance Win32_OperatingSystem).OSArchitecture
switch ($arch) {
    '64-bit' { $opArch = 'amd64'; break }
    '32-bit' { $opArch = '386'; break }
    Default { Write-Error "Sorry, your operating system architecture '$arch' is unsupported" -ErrorAction Stop }
}

$installDir = Join-Path -Path $env:ProgramFiles -ChildPath '1Password CLI'
Start-BitsTransfer -Source "https://cache.agilebits.com/dist/1P/op2/pkg/v2.19.0-beta.01/op_windows_$($opArch)_v2.19.0-beta.01.zip" -Destination $PSScriptRoot\op.zip 
Expand-Archive -Path $PSScriptRoot\op.zip -DestinationPath $installDir -Force
$envMachinePath = [System.Environment]::GetEnvironmentVariable('PATH','machine')
if ($envMachinePath -split ';' -notcontains $installDir){
    [Environment]::SetEnvironmentVariable('PATH', "$envMachinePath;$installDir", 'Machine')
}
Remove-Item -Path $PSScriptRoot\op.zip

winget install Git.Git -e --accept-package-agreements --accept-source-agreements
Write-Output 'Enable CLI integration under the developer settings and make sure the CLI integration has access to 1password vault make sure 1password is runig use the command "op vault list".'
Read-Host -Prompt "Press any key to continue. . ."

# Start SSH Key for Git
Start-Process -FilePath "StartSSHKeyForGit.bat" -Verb RunAs -Wait
Read-Host -Prompt "Press any key to continue. . ."


foreach ($packageId in $packageIds) {
    winget install --id=$packageId -e --accept-package-agreements --accept-source-agreements
}

if ($office -eq 0) {
# Download and install Office 365 from Microsoft
Start-BitsTransfer -Source $Config.OfficeUrl -Destination $PSScriptRoot\office.exe

# Start the Office installer in a separate process
Start-Process -FilePath $PSScriptRoot\office.exe -Wait

# Remove installers
Remove-Item $PSScriptRoot\office.exe

# Run Microsoft Activation Scripts as admin 
Start-Process powershell -Verb runAs -ArgumentList 'irm https://massgrave.dev/get | iex' -Wait
}
## net to add VMware or Hyper-V or non
if ($vmPlatform -eq 0) {
    # Check if Hyper-V is installed
$HyperVInstalled = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V -Online | Select-Object -ExpandProperty State

# If Hyper-V is not installed, install it
if ($HyperVInstalled -ne 'Enabled') {
Write-Host "Hyper-V is not installed. Installing..."
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
Write-Host "Hyper-V installation complete."
}
} else {
    Start-BitsTransfer -Source $Config.VMwareUrl -Destination $PSScriptRoot\VMware.exe
    Start-Process -FilePath $PSScriptRoot\VMware.exe /s /v/qn -Wait #mint not work
}

# Run a Chris Titus Tech's Windows Utility as admin
Start-Process powershell -Verb runAs -ArgumentList 'iwr -useb https://christitus.com/win | iex' -Wait

# Customize Windows settings
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0 -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Value 0 -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1 -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value 0 -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Value 1 -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Value 506 -Force
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -Value 1 -PropertyType DWORD -Force

# Set the power button behavior to do nothing
powercfg -SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS PBUTTONACTION 0

# Set the sleep button behavior to do nothing
powercfg -SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS PSLEEPBUTTONACTION 0

# Set power plan
# Get the list of power plans and their information
$powerPlans = powercfg.exe -list

# Iterate through the power plans and find the one with the specified name
foreach ($line in $powerPlans) {
    if ($line -match "GUID: ([0-9a-fA-F-]+)\s+\((.+)\)") {
        $guid = $matches[1]
        $name = $matches[2]

        if ($name -eq $Config.powerPlanName) {
            $powerPlanGUID = $guid
            break
        }
    }
}

# Check if the power plan was found
if ($powerPlanGUID) {
    # Set the power plan
    powercfg.exe -setactive $powerPlanGUID
    Write-Host "Power plan '$Config.powerPlanName' ($powerPlanGUID) set successfully."
} else {
    Write-Host "Power plan '$Config.powerPlanName' not found."
}


if (-not (Test-Path $Config.wtSettings)) {
    New-Item $Config.wtSettings -ItemType Directory -Force
}
#replays file 
Move-Item $PSScriptRoot\settings.json "$Config.wtSettings\settings.json" -Force

# Remove installers
Remove-Item $Config.nugetPath

if ($Backup -eq 0) {

    Move-Item $PSScriptRoot\BackupScript.ps1 C:\BackupScript.ps1
    # Schedule BackupScript.ps1 to run ons a week
    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File C:\BackupScript.ps1"
    $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At "20:00" 
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Backup Proton - NAS" -Description "Backup proton drive to NAS"
}
# Set the installation policy for the PSGallery repository
Set-PSRepository -Name PSGallery -InstallationPolicy Untrusted
winget upgrade --all

# Stop transcript and restart computer
Stop-Transcript
Restart-Computer -Force