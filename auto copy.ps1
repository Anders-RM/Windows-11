
# Invoke the GitHub API and retrieve the latest release information
$wingetreleaseInfo = Invoke-RestMethod -Uri $wingetapiUrl -Method Get

# Extract the asset information (you might need to adjust this based on your asset's name or criteria)
$wingetasset = $wingetreleaseInfo.assets | Where-Object { $_.name -like "Microsoft.DesktopAppInstaller*.msixbundle" }

if ($wingetasset) {
    $wingetUrl = $wingetasset.browser_download_url
   
} else {
    Write-Host "Asset not found in the latest release."
}

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

# Test if winget is installed
try {
$winget = Get-Command winget -ErrorAction Stop
Write-Host "winget is already installed at $($winget.Source)"
} 
catch {
Write-Host "winget is not installed. Installing now..."

Start-BitsTransfer -Source  "$uiXamlUrl" -Destination $PSScriptRoot\UIXaml.appx
Add-AppxPackage $PSScriptRoot\UIXaml.appx

Start-BitsTransfer -Source "$vcLibsurl"  -Destination $PSScriptRoot\VCLibs.appx
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
Start-BitsTransfer -Source "$1Passowrdurl" -Destination $PSScriptRoot\1pass.exe
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
Start-Process 1Password # dos not work
Write-Output 'Enable CLI integration under the developer settings and make sure the CLI integration has access to 1password vault make sure 1password is runig use the command "op vault list".'
Read-Host -Prompt "Press any key to continue. . ."

winget install Git.Git -e --accept-package-agreements --accept-source-agreements

Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File $PSScriptRoot\SshKeyForGit.ps1" #did not find the op/git comnat


# Start a new PowerShell process with the commands no idre way theis comdnb exitst
Start-Process powershell.exe -ArgumentList "-NoExit", "-Command $commandString" -Wait


# Install Programs using winget
winget install --id=Microsoft.VisualStudioCode -e --accept-package-agreements --accept-source-agreements
winget install --id=M2Team.NanaZip -e --accept-package-agreements --accept-source-agreements
winget install --id=Microsoft.WindowsTerminal -e --accept-package-agreements --accept-source-agreements
winget install --id=Brave.Brave -e --accept-package-agreements --accept-source-agreements

if ($choiceResultOffice -eq $defaultChoiceOffice) {
# Download and install Office 365 from Microsoft
Start-BitsTransfer -Source "$office" -Destination $PSScriptRoot\office.exe

# Start the Office installer in a separate process
Start-Process -FilePath $PSScriptRoot\office.exe -Wait

# Remove installers
Remove-Item $PSScriptRoot\office.exe

# Run Microsoft Activation Scripts as admin 
Start-Process powershell -Verb runAs -ArgumentList 'irm https://massgrave.dev/get | iex' -Wait
}
## net to add VMware or Hyper-V or non
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

# Remove installers
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

# Stop transcript and restart computer
Stop-Transcript
Restart-Computer -Force