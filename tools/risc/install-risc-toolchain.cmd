@echo off
setlocal
set SCRIPT_DIR=%~dp0
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install-risc-toolchain.ps1" %*
endlocal
exit /b %errorlevel%
