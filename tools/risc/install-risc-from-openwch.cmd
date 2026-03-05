@echo off
rem Windows launcher: runs PowerShell installer and keeps window open on errors
setlocal
set SCRIPT_DIR=%~dp0
echo Running PowerShell installer...
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install-risc-from-openwch.ps1" %*
set RC=%ERRORLEVEL%
if %RC% NEQ 0 (
	echo.
	echo Installer failed with exit code %RC%.
	echo Check output above for details.
	pause
	endlocal
	exit /b %RC%
)
echo.
echo Installer finished successfully. Press any key to exit.
pause
endlocal
exit /b 0
