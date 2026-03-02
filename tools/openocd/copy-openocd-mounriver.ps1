#Requires -Version 5.1
<#
.SYNOPSIS
    Downloads WCH OpenOCD from the repository and extracts it to tools/openocd/wch-openocd.

.DESCRIPTION
    Downloads the patched WCH build of OpenOCD that supports CH32V devices
    from the dependencies repository and extracts it locally.

.EXAMPLE
    .\copy-openocd-mounriver.ps1
    .\copy-openocd-mounriver.ps1 -Force
#>

param(
    [switch]$Force
)

try {
    $ZIP_URL = "https://raw.githubusercontent.com/GooDroneru/dependencies/main/tools/openocd/wch-openocd.zip"
    $ZIP_TMP = Join-Path $PSScriptRoot "wch-openocd.zip"
    $DEST    = Join-Path $PSScriptRoot "wch-openocd"

    Write-Host "WCH OpenOCD download tool" -ForegroundColor Cyan
    Write-Host "Source : $ZIP_URL"
    Write-Host "Target : $DEST"
    Write-Host ""

    if ((Test-Path $DEST) -and -not $Force) {
        Write-Host "Already exists at:" -ForegroundColor Green
        Write-Host "  $DEST"
        Write-Host "Use -Force to overwrite."
        return
    }

    Write-Host "Downloading wch-openocd.zip..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $ZIP_URL -OutFile $ZIP_TMP -UseBasicParsing
    Write-Host "Download complete." -ForegroundColor Green

    if (Test-Path $DEST) {
        Write-Host "Removing existing directory..."
        Remove-Item -Path $DEST -Recurse -Force
    }

    Write-Host "Extracting..."
    Expand-Archive -Path $ZIP_TMP -DestinationPath $PSScriptRoot -Force
    Write-Host "Extraction complete." -ForegroundColor Green

    Remove-Item -Path $ZIP_TMP -Force

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
        Write-Warning "openocd.exe not found at expected path - archive layout may differ."
    }

    if (-not (Test-Path $cfgFile)) {
        Write-Warning "wch-riscv.cfg not found in bin\ - check archive contents."
    }

} catch {
    Write-Host ""
    Write-Host "ERROR: $_" -ForegroundColor Red
} finally {
    Write-Host ""
    Read-Host "Press Enter to exit..."
}
