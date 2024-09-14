Start-Transcript -Path $PSScriptRoot"\SSH.log" -Append -IncludeInvocationHeader

$gitConfigSettings = @{
    'user.signingkey' = $modifiedsshKey
    'user.name' = 'Anders-RM'
    'user.email' = 'usual.dusk6145@fastmail.com'
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
