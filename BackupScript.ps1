# Specify source and destination directories
$source = 'C:\Users\Anders\Proton Drive\Anders_RMathiesen\My files\*'
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

# Copy the files and directories
Copy-Item -Path $source -Destination $destination -Recurse -Verbose

# Stop the transcript
Stop-Transcript

