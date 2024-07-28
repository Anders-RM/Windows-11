# Specify source and destination directories
$source = 'C:\Users\Andsers\filen\*'
$destinationBase = '\\192.168.3.2\Anders'

# Get the current date and time in the desired format, but replace forbidden characters
$date = Get-Date -Format 'dd_MM_yyyy - HH_mm'

# Combine the base destination path with the formatted date
$destination = Join-Path -Path $destinationBase -ChildPath $date

# Specify the log file path
$logFile = Join-Path -Path $destination -ChildPath 'Backup.log'

# Create the destination directory if it does not exist
if (!(Test-Path -Path $destination)) {
    New-Item -ItemType Directory -Path $destination
}

# If the log file exists, delete it
if (Test-Path -Path $logFile) {
    Remove-Item -Path $logFile
}

# Start the transcript
Start-Transcript -Path $logFile

# Define the credentials (replace with actual username and password)
$username = 'YourUsername'
$password = ConvertTo-SecureString 'YourPassword' -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

# Use the credential to access the destination path
New-PSDrive -Name "DestDrive" -PSProvider FileSystem -Root $destinationBase -Credential $credential -Persist

# Create the destination directory if it does not exist on the mapped drive
if (!(Test-Path -Path "DestDrive:\$date")) {
    New-Item -ItemType Directory -Path "DestDrive:\$date"
}

# Copy the files and directories
Copy-Item -Path $source -Destination "DestDrive:\$date" -Recurse -Verbose

# Remove the PSDrive after copying
Remove-PSDrive -Name "DestDrive"

# Stop the transcript
Stop-Transcript
