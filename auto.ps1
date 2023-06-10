Start-Transcript -Path $PSScriptRoot"\powershell.log" -Append -IncludeInvocationHeader
#set up ssh key for github
ssh-keygen -t rsa -b 4096 -C "Main Key" -f $HOME\.ssh\id_rsa -N '@Ndersraeder' -q   #create ssh key

#insatlling git and setting up git in windows using winget
winget install Git.Git -e

Start-Process powershell.exe -ArgumentList "-Command", "git config --global user.name 'Anders-RM'" -Wait
Start-Process powershell.exe -ArgumentList "-Command", "git config --global user.email 'Anders_RMathiesen@pm.me'" -Wait

#installing vscode using winget
winget install Microsoft.VisualStudioCode -e
winget install Microsoft.VisualStudioCode.Insiders  -e

#installing python version 3.11.3 downloading from python.org
Invoke-WebRequest https://www.python.org/ftp/python/3.11.3/python-3.11.3-amd64.exe -OutFile $PSScriptRoot\python.exe

#./python.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0

# Start the installer in a separate process
Start-Process -FilePath $PSScriptRoot\python.exe -Wait

#run a Chris Titus Tech's Windows Utility as admin
Start-Process powershell -Verb runAs -ArgumentList 'iwr -useb https://christitus.com/win | iex' -Wait

#downloading and installing office 365 from https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=O365ProPlusRetail&platform=x86&language=en-us&version=O16GA
Invoke-WebRequest "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=O365ProPlusRetail&platform=x86&language=en-us&version=O16GA" -OutFile $PSScriptRoot\office.exe

#./office.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0

# Start the installer in a separate process
Start-Process -FilePath $PSScriptRoot\office.exe -Wait

#run Microsoft Activation Scripts as admin 
Start-Process powershell -Verb runAs -ArgumentList 'irm https://massgrave.dev/get | iex' -Wait

#install hyper-v
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart

# Change the default virtual machine file location
#Set-VMHost -VirtualHardDiskPath "C:\VMs" -VirtualMachinePath "C:\VMs"

#customizing windows
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0
(Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband").Favorites | ForEach-Object {Remove-Item $_.Path -Force}
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1
# Enable clapboard history
Set-PSReadlineOption -HistorySaveStyle SaveIncrementally

#installing requests module
Start-Process powershell.exe -ArgumentList "-Command", "python -m pip install requests" -Wait

#running python.py script
Start-Process powershell.exe -ArgumentList "-Command", "python python.py" -Wait

#ristarting computer
#Restart-Computer -Force

Stop-Transcript

