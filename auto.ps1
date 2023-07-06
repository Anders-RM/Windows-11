# Start transcript to log PowerShell commands
Start-Transcript -Path $PSScriptRoot"\powershell.log" -Append -IncludeInvocationHeader

Add-Type -AssemblyName System.Windows.Forms

# Define the prompt message
$title = "Office Installation"
$message = "Do you want to install and activate Office?"

# Display the MessageBox and get the user's choice
$result = [System.Windows.Forms.MessageBox]::Show($message, $title, [System.Windows.Forms.MessageBoxButtons]::YesNo)


# Set up ssh key for GitHub
$Password = Read-Host -Prompt "Enter password for SSH key" -AsSecureString
$SSHPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
ssh-keygen -t rsa -b 4096 -C "Main Key" -f $HOME/.ssh/id_rsa -N $SSHPassword -q   #create ssh key

# Download the installer
Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/download/v1.5.1572/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile $PSScriptRoot\winget.appxbundle

# Install Winget
Add-AppxPackage -Path $PSScriptRoot\winget.appxbundle

# Install Git and set up Git in Windows using winget
winget install Git.Git -e --accept-package-agreements --accept-source-agreements
Start-Process powershell.exe -ArgumentList "-Command", "git config --global user.name 'Anders-RM'" -Wait
Start-Process powershell.exe -ArgumentList "-Command", "git config --global user.email 'Anders_RMathiesen@pm.me'" -Wait

# Install Visual Studio Code and Visual Studio Code Insiders using winget
winget install Microsoft.VisualStudioCode -e --accept-package-agreements --accept-source-agreements
winget install Microsoft.VisualStudioCode.Insiders  -e --accept-package-agreements --accept-source-agreements


if ($result -eq "Yes") {
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

# Customize Windows settings search widget
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

# Add hibernate to power menu
powercfg /h on

# Restart explorer.exe
Stop-Process -Name explorer


Move-Item $PSScriptRoot\settings.json "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Run a Chris Titus Tech's Windows Utility as admin
Start-Process powershell -Verb runAs -ArgumentList 'iwr -useb https://christitus.com/win | iex' -Wait

# Install python module
py -m pip install -U requests
py -m pip install -U selenium
# Run python.py script
py $PSScriptRoot\python.py

Start-Process Firefox
Get-Process Firefox | Stop-Process

# Remove installers
Remove-Item $PSScriptRoot\python.exe

# Move AfterReboot.ps1 to downloads folder
Move-Item $PSScriptRoot\AfterReboot.ps1 $HOME\downloads\AfterReboot.ps1

# Schedule AfterReboot.ps1 to run at startup
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoExit -ExecutionPolicy Bypass -File $HOME\downloads\AfterReboot.ps1" 
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "AfterReboot" -Description "Runs a command after reboot" -RunLevel Highest

# Stop transcript and restart computer
Stop-Transcript
Restart-Computer -Force