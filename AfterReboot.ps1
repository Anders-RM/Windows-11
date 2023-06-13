Start-Transcript -Path "$HOME\downloads\powershell.log" -Append -IncludeInvocationHeader
# Set the virtual hard disk and virtual machine paths for the VM host
Set-VMHost -VirtualHardDiskPath "C:\VMs" -VirtualMachinePath "C:\VMs"

# Unregister the scheduled task named "AfterReboot"
Unregister-ScheduledTask -TaskName "AfterReboot" -Confirm:$false

# Remove AfterReboot.ps1 script
Remove-Item $HOME\downloads\AfterReboot.ps1 -Force

Stop-Transcript