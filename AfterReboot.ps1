# Set the virtual hard disk and virtual machine paths for the VM host
Set-VMHost -VirtualHardDiskPath "C:\VMs" -VirtualMachinePath "C:\VMs"

# Install requests module
#python -m pip install requests

# Run python.py script
#python $HOME\downloads\python.py

# Unregister the scheduled task named "AfterReboot"
Unregister-ScheduledTask -TaskName "AfterReboot" -Confirm:$false

# Remove python.py script
#Remove-Item $HOME\downloads\python.py -Force

# Remove AfterReboot.ps1 script
Remove-Item $HOME\downloads\AfterReboot.ps1 -Force