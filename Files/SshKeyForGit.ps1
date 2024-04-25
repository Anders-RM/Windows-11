Start-Transcript -Path $PSScriptRoot"\SSH.log" -Append -IncludeInvocationHeader
# Get current date and format it as a string
$date = Get-Date -Format "yyyyMMdd"

# add date to key --title
op ssh generate --title "$env:computername-$date"
$sshKey = op item get "$env:computername-$date" --fields "label=public key"
$modifiedsshKey = $sshKey.Replace("`r`n", "").Replace("""", "")

$gitConfigSettings = @{
    'user.signingkey' = $modifiedsshKey
    'user.name' = 'Anders-RM'
    'user.email' = 'Anders_RMathiesen@pm.me'
    'gpg.format' = 'ssh'
    'gpg.ssh.program' = "$env:LOCALAPPDATA\1Password\app\8\op-ssh-sign.exe"
    'commit.gpgsign' = 'true'
    'url."git@github.com:".insteadOf' = 'https://github.com/'
    'core.sshCommand' = "C:/Windows/System32/OpenSSH/ssh.exe"
}

$gitConfigSettings.Keys | ForEach-Object {
    git config --global $_ $gitConfigSettings[$_]
}

Stop-Transcript
Read-Host -Prompt "Press any key to continue. . ."