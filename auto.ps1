# Start transcript to log PowerShell commands
Start-Transcript -Path $PSScriptRoot"\powershell.log" -Append -IncludeInvocationHeader

# Set up ssh key for GitHub
#$SSHPassword = Read-Host -Prompt "Enter password for SSH key" #add hide input
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

# Install Python version 3.11.4 by downloading from python.org
Invoke-WebRequest https://www.python.org/ftp/python/3.11.4/python-3.11.4-amd64.exe -OutFile $PSScriptRoot\python.exe

# Start the Python installer in a separate process
Start-Process -FilePath $PSScriptRoot\python.exe -Wait

# Run a Chris Titus Tech's Windows Utility as admin
Start-Process powershell -Verb runAs -ArgumentList 'iwr -useb https://christitus.com/win | iex' -Wait

# Download and install Office 365 from Microsoft
Invoke-WebRequest "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=O365ProPlusRetail&platform=x86&language=en-us&version=O16GA" -OutFile $PSScriptRoot\office.exe

# Start the Office installer in a separate process
Start-Process -FilePath $PSScriptRoot\office.exe -Wait

# Run Microsoft Activation Scripts as admin 
Start-Process powershell -Verb runAs -ArgumentList 'irm https://massgrave.dev/get | iex' -Wait

# Install Hyper-V
Start-Process powershell.exe -ArgumentList "-Command", "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart" -Wait

# Customize Windows settings
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0
#(Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband").Favorites | ForEach-Object {Remove-Item $_.Path -Force}

# Enable clapboard history
Set-PSReadlineOption -HistorySaveStyle SaveIncrementally

# Install requests module
py -m pip install requests
#start-Process powershell.exe -ArgumentList "-Command", "py -m pip install requests" -Wait

# Run python.py script
py $PSScriptRoot\python.py
#start-Process powershell.exe -ArgumentList "-Command", "py $PSScriptRoo\python.py" -Wait

# Remove installers
Remove-Item $PSScriptRoot\office.exe
Remove-Item $PSScriptRoot\python.exe

# Move AfterReboot.ps1 to downloads folder
Move-Item $PSScriptRoot\AfterReboot.ps1 $HOME\downloads\AfterReboot.ps1

# Schedule AfterReboot.ps1 to run at startup
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File -noexit $HOME\downloads\AfterReboot.ps1"
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "AfterReboot" -Description "Runs a command after reboot"

# Stop transcript and restart computer
Stop-Transcript
#Restart-Computer -Force