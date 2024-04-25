@echo off
setlocal enabledelayedexpansion

:: Define the PowerShell script path
set "powerShellScriptPath=%~dp0SshKeyForGit.ps1"

:: Run PowerShell script as administrator
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""!powerShellScriptPath!""' -Verb RunAs}"

endlocal