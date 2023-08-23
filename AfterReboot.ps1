$defaultVMfolder = [Environment]::GetEnvironmentVariable("defaultVMfolder", "Machine")

# Set the virtual hard disk and virtual machine paths for the VM host
Set-VMHost -VirtualHardDiskPath "$defaultVMfolder" -VirtualMachinePath "$defaultVMfolder"

# Unregister the scheduled task named "AfterReboot"
Unregister-ScheduledTask -TaskName "AfterReboot" -Confirm:$false

# Clear the environment variable
[Environment]::SetEnvironmentVariable("defaultVMfolder", $null, "Machine")

Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\*" -Recurse
Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce\*" -Recurse
Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run\*" -Recurse
Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce\*" -Recurse

# Remove AfterReboot.ps1 script
Remove-Item $HOME\downloads\AfterReboot.ps1 -Force