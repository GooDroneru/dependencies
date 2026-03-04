#Requires -Version 5.1
<#
.SYNOPSIS
    Installs riscv-none-embed GCC v1.4 (8.2.0) from a local zip archive.

.DESCRIPTION
    Extracts riscv-none-embed-gcc-v1.4.zip (located in the same folder as
    this script) into tools/risc/riscv-none-embed-gcc-v1.4/.

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
    $ARCHIVE_NAME  = "riscv-none-embed-gcc-v1.4.zip"
    $TOOLCHAIN_NAME = "riscv-none-embed-gcc-v1.4"

    $INSTALL_DIR   = $PSScriptRoot
    $ARCHIVE       = Join-Path $INSTALL_DIR $ARCHIVE_NAME
    $TOOLCHAIN_DIR = Join-Path $INSTALL_DIR $TOOLCHAIN_NAME
    # -------------------------------------------------------------------------

    Write-Host "riscv-none-embed GCC installer" -ForegroundColor Cyan
    Write-Host "Archive  : $ARCHIVE"
    Write-Host "Target   : $TOOLCHAIN_DIR"
    Write-Host ""

    if ((Test-Path $TOOLCHAIN_DIR) -and -not $Force) {
        Write-Host "Toolchain already installed at:" -ForegroundColor Green
        Write-Host "  $TOOLCHAIN_DIR"
        Write-Host "Use -Force to reinstall."
        return
    }

    # --- Check archive exists ------------------------------------------------
    if (-not (Test-Path $ARCHIVE)) {
        throw "Archive not found: $ARCHIVE`nPlace $ARCHIVE_NAME next to this script."
    }

    # --- Extract -------------------------------------------------------------
    Write-Host "Extracting $ARCHIVE_NAME to $INSTALL_DIR ..."
    Expand-Archive -Path $ARCHIVE -DestinationPath $INSTALL_DIR -Force
    Write-Host "Extraction complete." -ForegroundColor Green

    # --- Summary -------------------------------------------------------------
    $gccExe = Join-Path $TOOLCHAIN_DIR "bin\riscv-none-embed-gcc.exe"
    if (Test-Path $gccExe) {
        $gccVersion = (& $gccExe --version 2>&1)[0]
        Write-Host ""
        Write-Host "Installed successfully!" -ForegroundColor Green
        Write-Host "  GCC : $gccVersion"
        Write-Host "  Bin : $(Join-Path $TOOLCHAIN_DIR 'bin')"
    } else {
        Write-Warning "Installation may be incomplete - riscv-none-embed-gcc.exe not found at expected path."
    }

} catch {
    Write-Host ""
    Write-Host "ERROR: $_" -ForegroundColor Red
} finally {
    Write-Host ""
    Read-Host "Press Enter to exit..."
}
