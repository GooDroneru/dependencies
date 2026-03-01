#Requires -Version 5.1
<#
.SYNOPSIS
    Copies WCH OpenOCD from MounRiver Studio to tools/openocd/wch-openocd.

.DESCRIPTION
    MounRiver Studio ships a patched WCH build of OpenOCD that supports
    CH32V devices and includes wch-riscv.cfg. This script copies it to
    the repository so it can be used independently of MounRiver.

.EXAMPLE
    .\copy-openocd-mounriver.ps1
    .\copy-openocd-mounriver.ps1 -MounRiverPath "D:\MounRiver\MounRiver_Studio"
    .\copy-openocd-mounriver.ps1 -Force
#>

param(
    [string]$MounRiverPath = "C:\MounRiver\MounRiver_Studio",
    [switch]$Force
)

try {
    $OPENOCD_SRC = Join-Path $MounRiverPath "toolchain\OpenOCD"
    $DEST        = Join-Path $PSScriptRoot "wch-openocd"

    Write-Host "WCH OpenOCD copy tool" -ForegroundColor Cyan
    Write-Host "Source : $OPENOCD_SRC"
    Write-Host "Target : $DEST"
    Write-Host ""

    if (-not (Test-Path $OPENOCD_SRC)) {
        throw "MounRiver OpenOCD not found at: $OPENOCD_SRC`nUse -MounRiverPath to specify the MounRiver Studio installation directory."
    }

    if ((Test-Path $DEST) -and -not $Force) {
        Write-Host "Already exists at:" -ForegroundColor Green
        Write-Host "  $DEST"
        Write-Host "Use -Force to overwrite."
        return
    }

    Write-Host "Copying OpenOCD..."
    Copy-Item -Path $OPENOCD_SRC -Destination $DEST -Recurse -Force
    Write-Host "Copy complete." -ForegroundColor Green

    # --- Summary -------------------------------------------------------------
    $openocdExe = Join-Path $DEST "bin\openocd.exe"
    $cfgFile    = Join-Path $DEST "bin\wch-riscv.cfg"

    if (Test-Path $openocdExe) {
        $version = (& $openocdExe --version 2>&1)[0]
        Write-Host ""
        Write-Host "Done!" -ForegroundColor Green
        Write-Host "  OpenOCD : $version"
        Write-Host "  Bin     : $(Join-Path $DEST 'bin')"
    } else {
        Write-Warning "openocd.exe not found at expected path - copy may be incomplete."
    }

    if (-not (Test-Path $cfgFile)) {
        Write-Warning "wch-riscv.cfg not found in bin\ - check MounRiver installation."
    }

} catch {
    Write-Host ""
    Write-Host "ERROR: $_" -ForegroundColor Red
} finally {
    Write-Host ""
    Read-Host "Press Enter to exit..."
}
