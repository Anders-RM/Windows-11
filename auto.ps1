Start-Transcript -Path $PSScriptRoot"\powershell.log" -Append -IncludeInvocationHeader
# Set up ssh key for github
ssh-keygen -t rsa -b 4096 -C "Main Key" -f $HOME/.ssh/id_rsa -N '@Ndersraeder' -q   #create ssh key

# Insatlling git and setting up git in windows using winget
winget install Git.Git -e --accept-package-agreements --accept-source-agreements

Start-Process powershell.exe -ArgumentList "-Command", "git config --global user.name 'Anders-RM'" -Wait
Start-Process powershell.exe -ArgumentList "-Command", "git config --global user.email 'Anders_RMathiesen@pm.me'" -Wait

# Installing vscode using winget
winget install Microsoft.VisualStudioCode -e --accept-package-agreements --accept-source-agreements
winget install Microsoft.VisualStudioCode.Insiders  -e --accept-package-agreements --accept-source-agreements

# Installing python version 3.11.3 downloading from python.org
Invoke-WebRequest https://www.python.org/ftp/python/3.11.3/python-3.11.3-amd64.exe -OutFile $PSScriptRoot\python.exe

# Start the installer in a separate process
Start-Process -FilePath $PSScriptRoot\python.exe -Wait

# Run a Chris Titus Tech's Windows Utility as admin
Start-Process powershell -Verb runAs -ArgumentList 'iwr -useb https://christitus.com/win | iex' -Wait

# Downloading and installing office 365 from microsoft
Invoke-WebRequest "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=O365ProPlusRetail&platform=x86&language=en-us&version=O16GA" -OutFile $PSScriptRoot\office.exe

# Start the installer in a separate process
Start-Process -FilePath $PSScriptRoot\office.exe -Wait

# Run Microsoft Activation Scripts as admin 
Start-Process powershell -Verb runAs -ArgumentList 'irm https://massgrave.dev/get | iex' -Wait

# Install hyper-v
Start-Process powershell.exe -ArgumentList "-Command", "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart" -Wait


# Change the default virtual machine file location
#Set-VMHost -VirtualHardDiskPath "C:\VMs" -VirtualMachinePath "C:\VMs"

# Customizing windows
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0
#(Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband").Favorites | ForEach-Object {Remove-Item $_.Path -Force}
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1
# Enable clapboard history
Set-PSReadlineOption -HistorySaveStyle SaveIncrementally

# Installing requests module
Start-Process powershell.exe -ArgumentList "-Command", "python -m pip install requests" -Wait

# Running python.py script
Start-Process powershell.exe -ArgumentList "-Command", "python python.py" -Wait

Stop-Transcript
# Ristarting computer
#Restart-Computer -Force
