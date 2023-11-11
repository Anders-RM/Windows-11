@echo off
setlocal enabledelayedexpansion

:: Get the folder of the batch script
set "batchFolder=%~dp0"

:: Define the PowerShell script name
set "powerShellScript=auto.ps1"

:: Combine the batch script folder and PowerShell script name
set "powerShellScriptPath=!batchFolder!!powerShellScript!"

:: Run PowerShell script as administrator
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""!powerShellScriptPath!""' -Verb RunAs}"

endlocal
