#Requires -Version 5.1
<#
.SYNOPSIS
    Downloads and installs xPack GNU RISC-V Embedded GCC v15.2.0-1 for Windows x64.

.DESCRIPTION
    Downloads the toolchain from GitHub releases and extracts it to the
    same directory as this script (tools/risc/).

.EXAMPLE
    .\install-toolchain.ps1
    .\install-toolchain.ps1 -Force   # re-install even if already present
#>

param(
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    # --- Configuration -------------------------------------------------------
    $VERSION      = "15.2.0-1"
    $ASSET        = "xpack-riscv-none-elf-gcc-$VERSION-win32-x64.zip"
    $DOWNLOAD_URL = "https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v$VERSION/$ASSET"
    $SHA_URL      = "$DOWNLOAD_URL.sha"

    $INSTALL_DIR   = $PSScriptRoot
    $TOOLCHAIN_DIR = Join-Path $INSTALL_DIR "xpack-riscv-none-elf-gcc-$VERSION"
    # -------------------------------------------------------------------------

    Write-Host "xPack RISC-V GCC installer" -ForegroundColor Cyan
    Write-Host "Version  : $VERSION"
    Write-Host "Target   : $INSTALL_DIR"
    Write-Host ""

    if ((Test-Path $TOOLCHAIN_DIR) -and -not $Force) {
        Write-Host "Toolchain already installed at:" -ForegroundColor Green
        Write-Host "  $TOOLCHAIN_DIR"
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
    $gccExe = Join-Path $TOOLCHAIN_DIR "bin\riscv-none-elf-gcc.exe"
    if (Test-Path $gccExe) {
        $gccVersion = (& $gccExe --version 2>&1)[0]
        Write-Host ""
        Write-Host "Installed successfully!" -ForegroundColor Green
        Write-Host "  GCC : $gccVersion"
        Write-Host "  Bin : $(Join-Path $TOOLCHAIN_DIR 'bin')"
    } else {
        Write-Warning "Installation may be incomplete - gcc.exe not found at expected path."
    }

} catch {
    Write-Host ""
    Write-Host "ERROR: $_" -ForegroundColor Red
} finally {
    Write-Host ""
    Read-Host "Press Enter to exit..."
}
