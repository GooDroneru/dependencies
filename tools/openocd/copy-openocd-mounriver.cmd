@echo off
powershell.exe -ExecutionPolicy Bypass -File "%~dp0copy-openocd-mounriver.ps1" %*
pause
