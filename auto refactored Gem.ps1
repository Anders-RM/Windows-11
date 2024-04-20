# Start logging PowerShell commands
Start-Transcript -Path $PSScriptRoot"\powershell.log" -Append -IncludeInvocationHeader

# Define function to check if package is installed
function Check-PackageInstalled($packageName) {
  Get-PackageProvider -ListAvailable | Where-Object { $_.Name -eq $packageName }
}

# Define function to install NuGet package
function Install-NuGetPackage($packageName) {
  if (!(Check-PackageInstalled 'NuGet')) {
    Install-PackageProvider -Name NuGet -Force
    Import-PackageProvider NuGet -Force
  }

  $nugetPath = "$PSScriptRoot\NuGet.exe"
  if (!(Test-Path $nugetPath)) {
    $webClient = New-Object System.Net.WebClient
    try {
      $webClient.DownloadFile($nugetUrl, $nugetPath)
    } catch {
      Write-Host "Failed to download NuGet: $($_.Exception.Message)"
      return
    }
  }

  Install-Package $packageName -Force
  Write-Host "NuGet package '$packageName' installed."
}

# Define function to install PowerShell module
function Install-PowerShellModule($moduleName) {
  if (!(Get-Module -ListAvailable -Name $moduleName)) {
    Install-Module $moduleName -Force -AllowClobber
  }
  Import-Module $moduleName
}

# Configure environment variables and regional settings
Set-Culture -CultureInfo "en-DK"
[Environment]::SetEnvironmentVariable("defaultVMfolder", $defaultVMfolder, "Machine")

# Check and install NuGet
Install-NuGetPackage 'NuGet'

# Check and install PowerShellGet module
Install-PowerShellModule 'PowerShellGet'
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# User Prompt functions
function Prompt-UserChoice($message, $title, $choices) {
  $defaultChoice = 0
  $choiceResult = $host.ui.PromptForChoice($title, $message, $choices, $defaultChoice)
  return $choiceResult
}

$promptOffice = "Install and activate Office?"
$titleOffice = "Office Installation"
$choicesOffice = @(
  New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'
  New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList '&No'
)

$promptPswu = "Install Windows Update?"
$titlePswu = "Windows Update"
$choicesPswu = @(
  New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'
  New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList '&No'
)

$promptBackup = "Activate backup task schedule?"
$titleBackup = "Set up backup task schedule"
$choicesBackup = @(
  New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'
  New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList '&No'
)

# User prompts for Windows Update, Office Install, and Backup
$choiceResultPswu = Prompt-UserChoice $promptPswu $titlePswu $choicesPswu
$choiceResultOffice = Prompt-UserChoice $promptOffice $titleOffice $choicesOffice
$choiceResultBackup = Prompt-UserChoice $promptBackup $titleBackup $choicesBackup

# Windows Update
if ($choiceResultPswu -eq $defaultChoice) {
  # Get and install updates
  Get-WindowsUpdate | Out-File "<span class="math-inline">PSScriptRoot\\</span>(get-date -f yyyy-MM-dd)_Get-WindowsUpdate.log" -force
  Install-WindowsUpdate -AcceptAll -Install -IgnoreReboot | Out-File "<span class="math-inline">PSScriptRoot\\</span>(get-date -f yyyy-MM-dd)_Install-WindowsUpdate.log" -force
}

# Uninstall OneDrive
function Uninstall-OneDrive {
  $onedrivePath = If ((Test-Path "$env:windir\System32\OneDriveSetup.exe")) {
    "$env:windir\System32\OneDriveSetup.exe"
  } ElseIf ((Test-Path "$env:windir\SysWOW64\OneDriveSetup.exe")) {
    "$env:windir\SysWOW64\OneDriveSetup.exe"
  }

  if ($onedrivePath) {
    Start-Process $onedrivePath /uninstall -
