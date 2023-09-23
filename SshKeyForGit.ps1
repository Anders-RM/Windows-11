$sshKey = op ssh generate --title "$env:computername" --fields "label=public key"
$modifiedsshKey = $sshKey.Replace("`r`n", "")
$modifiedsshKey = $modifiedsshKey.Replace("""", "")
git config --global user.signingkey $modifiedsshKey
git config --global user.name 'Anders-RM'
git config --global user.email 'Anders_RMathiesen@pm.me'
git config --global gpg.format 'ssh'
git config --global gpg.ssh.program $env:LOCALAPPDATA\1Password\app\8\op-ssh-sign.exe
git config --global commit.gpgsign 'true'