#Requires -Version 5.1
<#
.SYNOPSIS
    Downloads and installs xPack OpenOCD v0.12.0-7 for Windows x64.

.DESCRIPTION
    Downloads OpenOCD from GitHub releases and extracts it to the
    same directory as this script (tools/openocd/).

.EXAMPLE
    .\install-openocd.ps1
    .\install-openocd.ps1 -Force   # re-install even if already present
#>

param(
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    # --- Configuration -------------------------------------------------------
    $VERSION      = "0.12.0-7"
    $ASSET        = "xpack-openocd-$VERSION-win32-x64.zip"
    $DOWNLOAD_URL = "https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v$VERSION/$ASSET"
    $SHA_URL      = "$DOWNLOAD_URL.sha"

    $INSTALL_DIR = $PSScriptRoot
    $OPENOCD_DIR = Join-Path $INSTALL_DIR "xpack-openocd-$VERSION"
    # -------------------------------------------------------------------------

    Write-Host "xPack OpenOCD installer" -ForegroundColor Cyan
    Write-Host "Version  : $VERSION"
    Write-Host "Target   : $INSTALL_DIR"
    Write-Host ""

    if ((Test-Path $OPENOCD_DIR) -and -not $Force) {
        Write-Host "OpenOCD already installed at:" -ForegroundColor Green
        Write-Host "  $OPENOCD_DIR"
        Write-Host "Use -Force to reinstall."
        return
    }

    $ARCHIVE = Join-Path $env:TEMP $ASSET

    # --- Download ------------------------------------------------------------
    Write-Host "Downloading $ASSET ..."
    $ProgressPreference = "SilentlyContinue"
    Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile $ARCHIVE -UseBasicParsing
    $ProgressPreference = "Continue"
    Write-Host "Download complete." -ForegroundColor Green

    # --- Verify SHA-256 ------------------------------------------------------
    Write-Host "Verifying checksum ..."
    try {
        $shaLine      = [System.Text.Encoding]::UTF8.GetString(
            (Invoke-WebRequest -Uri $SHA_URL -UseBasicParsing).Content
        ).Trim()
        $expectedHash = ($shaLine -split '\s+')[0].ToUpper()
        $actualHash   = (Get-FileHash -Path $ARCHIVE -Algorithm SHA256).Hash.ToUpper()

        if ($actualHash -ne $expectedHash) {
            Remove-Item $ARCHIVE -Force
            throw "Checksum mismatch!`n  Expected : $expectedHash`n  Actual   : $actualHash"
        }
        Write-Host "Checksum OK." -ForegroundColor Green
    } catch {
        Write-Warning "Could not verify checksum: $_"
    }

    # --- Extract -------------------------------------------------------------
    Write-Host "Extracting to $INSTALL_DIR ..."
    Expand-Archive -Path $ARCHIVE -DestinationPath $INSTALL_DIR -Force
    Write-Host "Extraction complete." -ForegroundColor Green

    # --- Cleanup -------------------------------------------------------------
    Remove-Item $ARCHIVE -Force
    Write-Host "Temporary archive removed."

    # --- Summary -------------------------------------------------------------
    $openocdExe = Join-Path $OPENOCD_DIR "bin\openocd.exe"
    if (Test-Path $openocdExe) {
        $openocdVersion = (& $openocdExe --version 2>&1)[0]
        Write-Host ""
        Write-Host "Installed successfully!" -ForegroundColor Green
        Write-Host "  OpenOCD : $openocdVersion"
        Write-Host "  Bin     : $(Join-Path $OPENOCD_DIR 'bin')"
        Write-Host "  Scripts : $(Join-Path $OPENOCD_DIR 'openocd\scripts')"
    } else {
        Write-Warning "Installation may be incomplete - openocd.exe not found at expected path."
    }

} catch {
    Write-Host ""
    Write-Host "ERROR: $_" -ForegroundColor Red
} finally {
    Write-Host ""
    Read-Host "Press Enter to exit..."
}
