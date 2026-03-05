@echo off
rem Installer launcher for Windows — runs PowerShell script and keeps window open on errors
setlocal
set SCRIPT_DIR=%~dp0
echo Running PowerShell installer...
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install-risc-toolchain.ps1" %*
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
