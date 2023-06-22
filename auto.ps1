# Start transcript to log PowerShell commands
Start-Transcript -Path $PSScriptRoot"\powershell.log" -Append -IncludeInvocationHeader

# Install the Windows Terminal module (if not already installed)
Install-Module -Name Microsoft.PowerShell.UnixCompleters -Scope CurrentUser

# Import the module
Import-Module -Name WindowsTerminal

#add qeustion for  office 
$run_script = Read-Host "Do you want to install and activate Office? (y/n)"

# Set up ssh key for GitHub
$Password = Read-Host -Prompt "Enter password for SSH key" -AsSecureString
$SSHPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
ssh-keygen -t rsa -b 4096 -C "Main Key" -f $HOME/.ssh/id_rsa -N $SSHPassword -q   #create ssh key

# Install Git and set up Git in Windows using winget
winget install Git.Git -e --accept-package-agreements --accept-source-agreements
Start-Process powershell.exe -ArgumentList "-Command", "git config --global user.name 'Anders-RM'" -Wait
Start-Process powershell.exe -ArgumentList "-Command", "git config --global user.email 'Anders_RMathiesen@pm.me'" -Wait

# Install Visual Studio Code and Visual Studio Code Insiders using winget
#winget install Microsoft.VisualStudioCode -e --accept-package-agreements --accept-source-agreements
winget install Microsoft.VisualStudioCode.Insiders  -e --accept-package-agreements --accept-source-agreements


if ($run_script -eq "y") {
    # Download and install Office 365 from Microsoft
    Invoke-WebRequest "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=O365ProPlusRetail&platform=x86&language=en-us&version=O16GA" -OutFile $PSScriptRoot\office.exe

    # Start the Office installer in a separate process
    Start-Process -FilePath $PSScriptRoot\office.exe -Wait

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
powercfg -SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS PBUTTONACTION 0

# Set the sleep button behavior to do nothing
powercfg -SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS PSLEEPBUTTONACTION 0
powercfg -SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS PSLEEPBUTTONACTION 0

# Add hibernate to power menu
powercfg /h on

# Restart explorer.exe
Stop-Process -Name explorer

# #fix this
# # Customize Windows Terminal settings
# $TerminalConfigPath = "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_*\LocalState\settings.json"
# $TerminalConfig = Get-Content -Path $TerminalConfigPath | ConvertFrom-Json

# # Set Windows Terminal shortcut for split pane down to Ctrl+Shift+Num Minus
# $TerminalConfig.keybindings += @{
#     "command": "splitPaneDown",
#     "keys": "ctrl+shift+numpadminus"
# }

# # Set Windows Terminal shortcut for split pane right to Ctrl+Shift+Num Plus
# $TerminalConfig.keybindings += @{
#     "command": "splitPaneRight",
#     "keys": "ctrl+shift+numpadadd"
# }

# # Set Windows Terminal shortcut for split pane auto to Ctrl+Shift+Num Multiply
# $TerminalConfig.keybindings += @{
#     "command": "splitPaneAuto",
#     "keys": "ctrl+shift+numpadmultiply"
# }

# # Set Windows Terminal default profile to PowerShell
# $TerminalConfig.defaultProfile = "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}"

# # Enable Windows Terminal automatic copy on select
# $TerminalConfig.profiles.defaults.copyOnSelect = $true

# # Enable Windows Terminal automatic focus on mouse hover
# $TerminalConfig.profiles.defaults.mouseMode = "automatic"

# # Enable Windows Terminal remove trailing whitespace
# $TerminalConfig.profiles.defaults.trimTrailingWhitespace = $true

# # Disable Windows Terminal confirm close all tabs
# $TerminalConfig.profiles.defaults.confirmCloseAllTabs = $false

# # Disable Windows Terminal confirm on big text paste
# $TerminalConfig.profiles.defaults.confirmOnPaste = "never"

# # Set default terminal to Windows Terminal
# $TerminalConfig.defaultTerminalApplicationPath = "wt.exe"

# # Save the updated configuration back to the file
# $TerminalConfig | ConvertTo-Json | Set-Content -Path $TerminalConfigPath

#test

# Get the current Windows Terminal settings
$settings = Get-WindowsTerminalSettings

# Set the desired keybindings
$settings.Keybindings += @{
    "command" = "splitPaneDown"
    "keys" = "ctrl+shift+numpadminus"
}
$settings.Keybindings += @{
    "command" = "splitPaneRight"
    "keys" = "ctrl+shift+numpadadd"
}
$settings.Keybindings += @{
    "command" = "splitPaneAuto"
    "keys" = "ctrl+shift+numpadmultiply"
}

# Set the default profile
$settings.DefaultProfile = "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}"

# Enable copy on select
$settings.Profiles.Defaults.CopyOnSelect = $true

# Enable automatic mouse mode
$settings.Profiles.Defaults.MouseMode = "automatic"

# Enable removing trailing whitespace
$settings.Profiles.Defaults.TrimTrailingWhitespace = $true

# Disable confirm close all tabs
$settings.Profiles.Defaults.ConfirmCloseAllTabs = $false

# Disable confirm on big text paste
$settings.Profiles.Defaults.ConfirmOnPaste = "never"

# Set the default terminal application path
$settings.DefaultTerminalApplicationPath = "wt.exe"

# Update the Windows Terminal settings
Set-WindowsTerminalSettings -Settings $settings

# Uninstall unnecessary apps test
$AppsToRemove = @(
    "Microsoft.Microsoft3DViewer",
    "Microsoft.BingWeather",
    "Microsoft.GetHelp",
    "Microsoft.HEIFImageExtension",
    "Microsoft.Messaging",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MSPaint",
    "Microsoft.OneConnect",
    "Microsoft.People",
    "Microsoft.Print3D",
    "Microsoft.ScreenSketch",
    "Microsoft.SkypeApp",
    "Microsoft.Wallet",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsCalculator",
    "Microsoft.WindowsCamera",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.WindowsPhone",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.WindowsStore",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay"
)

$AppsToRemove | ForEach-Object {
    Get-AppxPackage -Name $_ | Remove-AppxPackage -ErrorAction SilentlyContinue
}

# Run a Chris Titus Tech's Windows Utility as admin
Start-Process powershell -Verb runAs -ArgumentList 'iwr -useb https://christitus.com/win | iex' -Wait

# Install python module
py -m pip install -U requests
py -m pip install -U selenium
# Run python.py script
py $PSScriptRoot\python.py


if ($run_script -eq "y") {
    # Remove installers
    Remove-Item $PSScriptRoot\office.exe
}

# Remove installers
Remove-Item $PSScriptRoot\python.exe

# Move AfterReboot.ps1 to downloads folder
Move-Item $PSScriptRoot\AfterReboot.ps1 $HOME\downloads\AfterReboot.ps1

# Schedule AfterReboot.ps1 to run at startup
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoExit -ExecutionPolicy Bypass -File $HOME\downloads\AfterReboot.ps1" 
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "AfterReboot" -Description "Runs a command after reboot" -RunLevel HighestAvailable

# Stop transcript and restart computer
Stop-Transcript
Restart-Computer -Force