# Start transcript to log PowerShell commands
Start-Transcript -Path $PSScriptRoot"\powershell.log" -Append -IncludeInvocationHeader

#Macke sure ties settings are correct

$office = "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=O365ProPlusRetail&platform=x64&language=en-us&version=O16GA"
$python = "https://www.python.org/ftp/python/3.11.4/python-3.11.4-amd64.exe"
$nugetUrl = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
$uiXamlUrl = "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx" # winget complains if it’s not version 2.7.x
$vcLibsurl = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
$defaultVMfolder = "C:\VMs"
$powerPlanName = "Ultimate Performance"
$nugetPath = "$PSScriptRoot\NuGet.exe"
$wtSettings = "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$1Passowrdurl = "https://downloads.1password.com/win/1PasswordSetup-latest.exe"

Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\*" -Recurse
Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce\*" -Recurse
Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run\*" -Recurse
Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce\*" -Recurse

#set $defaultVMfolder as Environment Variable for AfterReboot.ps1 and AfterReboot.ps1 removes the Environment Variable
[Environment]::SetEnvironmentVariable("defaultVMfolder", $defaultVMfolder, "Machine")

# Set the region to English Denmark
Set-Culture -CultureInfo "en-DK"

# Check if NuGet is installed
if ($null -ne (Get-PackageProvider -ListAvailable | Where-Object { $_.Name -eq "NuGet" }))
{
    Write-Host "NuGet is already installed."
}
else
{
    # Install NuGet if it's not already installed
    try
    {
        Install-PackageProvider -Name NuGet -Force
        Import-PackageProvider NuGet -Force

        # Check if NuGet exists
        if (!(Test-Path $nugetPath)) {
            # NuGet doesn't exist, so download it
            $webClient = New-Object System.Net.WebClient
            try {
                $webClient.DownloadFile($nugetUrl, $nugetPath)
            }
            catch {
                Write-Host "Failed to download NuGet from $nugetUrl to $nugetPath."
                Write-Host $_.Exception.Message
            }
        }

        
        Write-Host "NuGet has been installed."
    }
    catch
    {
        Write-Host "Failed to install NuGet."
        Write-Host $_.Exception.Message
    }
}

# Check if the PowerShellGet module is installed
if (!(Get-Module -ListAvailable -Name PowerShellGet)) {
    # If not, install it
    Install-Module -Name PowerShellGet -Force -AllowClobber
}

# Set the installation policy for the PSGallery repository
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

$PromptBackup = "Do you want to activate backup?"
$TitleBackup = "Set up backup task schedule"

$choicesBackup = [System.Management.Automation.Host.ChoiceDescription[]]@(
    (New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'),
    (New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList '&No')
)

$defaultChoiceBackup = 0

$choiceResultBackup = $host.ui.PromptForChoice($TitleBackup, $PromptBackup, $choicesBackup, $defaultChoiceBackup)

$PromptPswu = "Do you want to install Windows Update"
$TitlePswu = "Windows Update"

$choicesPswu = [System.Management.Automation.Host.ChoiceDescription[]]@(
    (New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'),
    (New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList '&No')
)

$defaultChoicePswu = 0

$choiceResultPswu = $host.ui.PromptForChoice($TitlePswu, $PromptPswu, $choicesPswu, $defaultChoicePswu)
    # Install and Import the PSWindowsUpdate module
    Install-Module PSWindowsUpdate
    Import-Module PSWindowsUpdate

$PromptOffice = "Do you want to install and activate Office?"
$TitleOffice = "Office Installation"

$choicesOffice = [System.Management.Automation.Host.ChoiceDescription[]]@(
    (New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'),
    (New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList '&No')
)

$defaultChoiceOffice = 1

$choiceResultOffice = $host.ui.PromptForChoice($TitleOffice, $PromptOffice, $choicesOffice, $defaultChoiceOffice)

$Promptwinget = "Do you want to install Firefox & Brave using winget?"
$Titlewinget = "Firefox/Brave Installation"

$choiceswinget = [System.Management.Automation.Host.ChoiceDescription[]]@(
    (New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'),
    (New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList '&No')
)

$defaultChoicewinget = 0

$choiceResultwinget = $host.ui.PromptForChoice($Titlewinget, $Promptwinget, $choiceswinget, $defaultChoicewinget)

if ($choiceResultPswu -eq $defaultChoicePswu) {
    # Get the available updates.
    Write-Host "Get the available Windows Update"
    Get-WindowsUpdate | Out-File "$PSScriptRoot\$(get-date -f yyyy-MM-dd)_Get-WindowsUpdate.log" -force
    # Install all the updates.
    Write-Host "Install all the updates"
    Install-WindowsUpdate -AcceptAll -Install -IgnoreReboot | Out-File "$PSScriptRoot\$(get-date -f yyyy-MM-dd)_Install-WindowsUpdate.log" -force
}

#Uninstall Apps
Get-Process onedrive | Stop-Process -Force

Write-Output "Remove OneDrive"
if (Test-Path "$env:windir\System32\OneDriveSetup.exe") {
    start-process "$env:windir\System32\OneDriveSetup.exe" /uninstall -Wait
    Write-Host "OneDrive32 has been uninstalled."
}
if (Test-Path "$env:windir\SysWOW64\OneDriveSetup.exe") {
    start-process "$env:windir\SysWOW64\OneDriveSetup.exe" /uninstall -Wait
    Write-Host "OneDrive64 has been uninstalled."
}

# Define the list of apps to uninstall

$appList = @("Microsoft.BingNews",
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
 "Microsoft.windowscommunicationsapps")

foreach($app in $appList) {
    # Get the package
    $package = Get-AppxPackage -AllUsers | Where-Object { $_.Name -eq $app }

    # Check if the package exists
    if($package) {
        foreach($package in $package){
            try {
                # Attempt to remove the package for all users
                Remove-AppxPackage -package $package.PackageFullName -AllUsers -ErrorAction Stop
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


# Test if winget is installed
try {
    $winget = Get-Command winget -ErrorAction Stop
    Write-Host "winget is already installed at $($winget.Source)"
} 
catch {
    Write-Host "winget is not installed. Installing now..."

    Invoke-WebRequest  "$uiXamlUrl" -OutFile $PSScriptRoot\UIXaml.appx
    Add-AppxPackage $PSScriptRoot\UIXaml.appx
    
    Invoke-WebRequest "$vcLibsurl"  -OutFile $PSScriptRoot\VCLibs.appx
    Add-AppxPackage $PSScriptRoot\VCLibs.appx

    Invoke-WebRequest  "$wingetUrl" -OutFile $PSScriptRoot\winget.msixbundle
    Add-AppxPackage $PSScriptRoot\winget.msixbundle

    # Remove the installer file
    Remove-Item $PSScriptRoot\winget.msixbundle
    Remove-Item $PSScriptRoot\UIXaml.appx
    Remove-Item $PSScriptRoot\VCLibs.appx

    Write-Host "winget is now installed"
}

# 1Password app
Invoke-WebRequest "$1Passowrdurl" -OutFile $PSScriptRoot\1pass.exe
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
Write-Output "$arch"
Read-Host -Prompt "Press any key to continue. . ."

$installDir = Join-Path -Path $env:ProgramFiles -ChildPath '1Password CLI'
Invoke-WebRequest -Uri "https://cache.agilebits.com/dist/1P/op2/pkg/v2.19.0-beta.01/op_windows_$($opArch)_v2.19.0-beta.01.zip" -OutFile $PSScriptRoot\op.zip 
Expand-Archive -Path op.zip -DestinationPath $installDir -Force
$envMachinePath = [System.Environment]::GetEnvironmentVariable('PATH','machine')
if ($envMachinePath -split ';' -notcontains $installDir){
    [Environment]::SetEnvironmentVariable('PATH', "$envMachinePath;$installDir", 'Machine')
}
Remove-Item -Path $PSScriptRoot\op.zip

Write-Output 'Enable CLI integration under the developer settings and make sure the CLI integration has access to 1password vault use the command "op vault list".'
Read-Host -Prompt "Press any key to continue. . ."

$sshKey = op ssh generate --title "$env:computername" --fields "label=public key"
$modifiedsshKey = $sshKey.Replace("`r`n", "")
$modifiedsshKey = $modifiedsshKey.Replace("""", "")

# Install Git and set up Git in Windows using winget
winget install Git.Git -e --accept-package-agreements --accept-source-agreements
Start-Process powershell.exe -ArgumentList "-Command", "git config --global user.signingkey $modifiedsshKey" -Wait
Start-Process powershell.exe -ArgumentList "-Command", "git config --global user.name 'Anders-RM'" -Wait
Start-Process powershell.exe -ArgumentList "-Command", "git config --global user.email 'Anders_RMathiesen@pm.me'" -Wait
Start-Process powershell.exe -ArgumentList "-Command", "git config --global gpg.format 'ssh'" -Wait
Start-Process powershell.exe -ArgumentList "-Command", "git config --global gpg.ssh.program $env:LOCALAPPDATA\1Password\app\8\op-ssh-sign.exe" -Wait
Start-Process powershell.exe -ArgumentList "-Command", "git config --global commit.gpgsign 'true'" -Wait

# Install Programs using winget
winget install --id=Microsoft.VisualStudioCode -e --accept-package-agreements --accept-source-agreements
winget install --id=M2Team.NanaZip -e --accept-package-agreements --accept-source-agreements
winget install --id=Microsoft.WindowsTerminal -e --accept-package-agreements --accept-source-agreements

if ($choiceResultOffice -eq $defaultChoiceOffice) {
    # Download and install Office 365 from Microsoft
    Invoke-WebRequest "$office" -OutFile $PSScriptRoot\office.exe

    # Start the Office installer in a separate process
    Start-Process -FilePath $PSScriptRoot\office.exe -Wait

    # Remove installers
    Remove-Item $PSScriptRoot\office.exe

    # Run Microsoft Activation Scripts as admin 
    Start-Process powershell -Verb runAs -ArgumentList 'irm https://massgrave.dev/get | iex' -Wait
}

# Install Python version 3.11.4 by downloading from python.org
Invoke-WebRequest "$python" -OutFile $PSScriptRoot\python.exe

# Start the Python installer in a separate process
Start-Process -FilePath $PSScriptRoot\python.exe -Wait

# Check if Hyper-V is installed
$HyperVInstalled = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V -Online | Select-Object -ExpandProperty State

# If Hyper-V is not installed, install it
if ($HyperVInstalled -ne 'Enabled') {
    Write-Host "Hyper-V is not installed. Installing..."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
    Write-Host "Hyper-V installation complete."
}

if (-not (Test-Path $defaultVMfolder)) {
    New-Item $defaultVMfolder -ItemType Directory -Force
}

if ($choiceResultwinget -eq $defaultChoicewinget){
    winget install --id=Mozilla.Firefox.ESR  -e --accept-package-agreements --accept-source-agreements
    winget install --id=Brave.Brave  -e --accept-package-agreements --accept-source-agreements
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

        if ($name -eq $powerPlanName) {
            $powerPlanGUID = $guid
            break
        }
    }
}

# Check if the power plan was found
if ($powerPlanGUID) {
    # Set the power plan
    powercfg.exe -setactive $powerPlanGUID
    Write-Host "Power plan '$powerPlanName' ($powerPlanGUID) set successfully."
} else {
    Write-Host "Power plan '$powerPlanName' not found."
}


if (-not (Test-Path $wtSettings)) {
    New-Item $wtSettings -ItemType Directory -Force
}
#replays file 
Move-Item $PSScriptRoot\settings.json "$wtSettings\settings.json" -Force

Start-Process Firefox
Start-Sleep -Seconds 6
Get-Process Firefox | Stop-Process

# Remove installers
Remove-Item $PSScriptRoot\python.exe
Remove-Item $nugetPath

# Move AfterReboot.ps1 to downloads folder
Move-Item $PSScriptRoot\AfterReboot.ps1 $HOME\downloads\AfterReboot.ps1

# Schedule AfterReboot.ps1 to run at startup
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File $HOME\downloads\AfterReboot.ps1" 
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "AfterReboot" -Description "Runs a command after reboot" -RunLevel Highest

if ($choiceResultBackup -eq $defaultChoiceBackup) {

    Move-Item $PSScriptRoot\BackupScript.ps1 C:\BackupScript.ps1
    # Schedule BackupScript.ps1 to run ons a week
    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File C:\BackupScript.ps1"
    $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At "20:00" 
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Backup Proton - NAS" -Description "Backup proton drive to NAS"
}
# Set the installation policy for the PSGallery repository
Set-PSRepository -Name PSGallery -InstallationPolicy Untrusted
winget upgrade --all

# Install python module
py -m pip install --upgrade pip
py -m pip install -U requests
py -m pip install -U selenium
# Run python.py script
py $PSScriptRoot\github_ssh-Firefox_disable_quick_find.py

# Stop transcript and restart computer
Stop-Transcript
Restart-Computer -Force