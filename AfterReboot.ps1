# Define the paths
$defaultVMfolder = [Environment]::GetEnvironmentVariable("defaultVMfolder", "Machine")
$paths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\*",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce\*",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run\*",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce\*"
)

# Set the virtual hard disk and virtual machine paths for the VM host
Set-VMHost -VirtualHardDiskPath $defaultVMfolder -VirtualMachinePath $defaultVMfolder

# Unregister the scheduled task named "AfterReboot"
Unregister-ScheduledTask -TaskName "AfterReboot" -Confirm:$false

# Clear the environment variable
[Environment]::SetEnvironmentVariable("defaultVMfolder", $null, "Machine")

# Remove items from the paths
$paths | ForEach-Object { Remove-Item -Path $_ -Recurse }

# Remove AfterReboot.ps1 script
Remove-Item "$HOME\downloads\AfterReboot.ps1" -Force