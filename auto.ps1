# Start transcript to log PowerShell commands
Start-Transcript -Path $PSScriptRoot"\powershell.log" -Append -IncludeInvocationHeader

$Prompt = "Do you want to install and activate Office?"
$Title = "Office Installation"

$choices = [System.Management.Automation.Host.ChoiceDescription[]]@(
    (New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'),
    (New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList '&No')
)

$defaultChoice = 0

$choiceResult = $host.ui.PromptForChoice($Title, $Prompt, $choices, $defaultChoice)


# Set up ssh key for GitHub
$Password = Read-Host -Prompt "Enter password for SSH key" -AsSecureString
$SSHPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
ssh-keygen -t rsa -b 4096 -C "Main Key" -f $HOME/.ssh/id_rsa -N $SSHPassword -q   #create ssh key

#Uninstall Apps
#xbox live


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
 "Microsoft.XboxGameCallableUI",
 "Microsoft.Xbox.TCUI",
 "Microsoft.XboxSpeechToTextOverlay",
 "Microsoft.XboxIdentityProvider",
 "Microsoft.YourPhone",
 "Microsoft.ZuneMusic",
 "Microsoft.ZuneVideo",
 "Microsoft.Todos",
 "Microsoft.GamingApp",
 "Microsoft.GetHelp",
 "Microsoft.windowscommunicationsapps")

# Loop through the list
foreach($app in $appList) {
    # Get the package
    $package = Get-AppxPackage | Where-Object { $_.Name -eq $app }

    # Check if the package exists
    if($package) {
        try {
            # Attempt to remove the package
            $package | Remove-AppxPackage -ErrorAction Stop

            Write-Host "$app has been uninstalled."
        }
        catch {
            Write-Host "Failed to uninstall $app."
        }
    }
    else {
        Write-Host "$app is not installed."
    }
}

try {
    Get-Command winget -ErrorAction Stop
    Write-Output "Winget is installed."
}
catch {
    Write-Output "Winget is not installed."
    # Download the installer
    Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/download/v1.5.1572/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile $PSScriptRoot\winget.appxbundle

    # Install Winget
    Add-AppxPackage -Path $PSScriptRoot\winget.appxbundle
    
    Remove-Item $PSScriptRoot\winget.appxbundle
}

# Install Git and set up Git in Windows using winget
winget install Git.Git -e --accept-package-agreements --accept-source-agreements
Start-Process powershell.exe -ArgumentList "-Command", "git config --global user.name 'Anders-RM'" -Wait
Start-Process powershell.exe -ArgumentList "-Command", "git config --global user.email 'Anders_RMathiesen@pm.me'" -Wait

# Install Visual Studio Code and Visual Studio Code/Insiders using winget
winget install Microsoft.VisualStudioCode -e --accept-package-agreements --accept-source-agreements
#winget install Microsoft.VisualStudioCode.Insiders  -e --accept-package-agreements --accept-source-agreements


if ($choiceResult -eq $defaultChoice) {
    # Download and install Office 365 from Microsoft
    Invoke-WebRequest "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=O365ProPlusRetail&platform=x86&language=en-us&version=O16GA" -OutFile $PSScriptRoot\office.exe

    # Start the Office installer in a separate process
    Start-Process -FilePath $PSScriptRoot\office.exe -Wait

    # Remove installers
    Remove-Item $PSScriptRoot\office.exe

    # Run Microsoft Activation Scripts as admin 
    Start-Process powershell -Verb runAs -ArgumentList 'irm https://massgrave.dev/get | iex' -Wait
}

# Install Python version 3.11.4 by downloading from python.org
Invoke-WebRequest https://www.python.org/ftp/python/3.11.4/python-3.11.4-amd64.exe -OutFile $PSScriptRoot\python.exe

# Start the Python installer in a separate process
Start-Process -FilePath $PSScriptRoot\python.exe -Wait

# Check if Hyper-V is installed
$HyperVInstalled = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V -Online | Select-Object -ExpandProperty State

# If Hyper-V is not installed, install it
if ($HyperVInstalled -ne 'Enabled') {
    Write-Host "Hyper-V is not installed. Installing..."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
    Write-Host "Hyper-V installation complete."
} else {
    Write-Host "Hyper-V is already installed."
}

$defaultVMfolder = "C:\VMs"

if (-not (Test-Path $defaultVMfolder)) {
    New-Item $defaultVMfolder -ItemType Directory -Force
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

# Restart explorer.exe
Stop-Process -Name explorer
$wtSettings = "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"

if (-not (Test-Path $wtSettings)) {
    New-Item $wtSettings -ItemType Directory -Force
}
#replays file 
Move-Item $PSScriptRoot\settings.json "$wtSettings\settings.json" -Force

Start-Process Firefox
Start-Sleep -Seconds 5
Get-Process Firefox | Stop-Process

# Remove installers
Remove-Item $PSScriptRoot\python.exe


# Move AfterReboot.ps1 to downloads folder
Move-Item $PSScriptRoot\AfterReboot.ps1 $HOME\downloads\AfterReboot.ps1

# Schedule AfterReboot.ps1 to run at startup
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File $HOME\downloads\AfterReboot.ps1" 
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "AfterReboot" -Description "Runs a command after reboot" -RunLevel Highest

# Install python module
py -m pip install -U requests
py -m pip install -U selenium
# Run python.py script
py $PSScriptRoot\python.py

# Stop transcript and restart computer
Stop-Transcript
Restart-Computer -Force