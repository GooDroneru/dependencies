#Requires -Version 5.1
<#
.SYNOPSIS
    Downloads VK035 OpenOCD from the repository and extracts it to tools/openocd/vk035.

.DESCRIPTION
    Downloads the patched K1921VK035 build of OpenOCD from the dependencies
    repository and extracts it locally.

.EXAMPLE
    .\download-openocd-vk035.ps1
    .\download-openocd-vk035.ps1 -Force
#>

param(
    [switch]$Force
)

try {
    $ZIP_URL = "https://raw.githubusercontent.com/GooDroneru/dependencies/main/tools/openocd/vk035.zip"
    $ZIP_TMP = Join-Path $PSScriptRoot "vk035.zip"
    $DEST    = Join-Path $PSScriptRoot "vk035"

    Write-Host "VK035 OpenOCD download tool" -ForegroundColor Cyan
    Write-Host "Source : $ZIP_URL"
    Write-Host "Target : $DEST"
    Write-Host ""

    if ((Test-Path $DEST) -and -not $Force) {
        Write-Host "Already exists at:" -ForegroundColor Green
        Write-Host "  $DEST"
        Write-Host "Use -Force to overwrite."
        return
    }

    Write-Host "Downloading vk035.zip..."
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
    $openocdExe = Join-Path $DEST "xpack-openocd-k1921vk-0.12.0-k1921vk\bin\openocd.exe"

    if (Test-Path $openocdExe) {
        $version = (& $openocdExe --version 2>&1)[0]
        Write-Host ""
        Write-Host "Done!" -ForegroundColor Green
        Write-Host "  OpenOCD : $version"
        Write-Host "  Bin     : $(Join-Path $DEST 'xpack-openocd-k1921vk-0.12.0-k1921vk\bin')"
    } else {
        Write-Warning "openocd.exe not found at expected path - archive layout may differ."
    }

} catch {
    Write-Host ""
    Write-Host "ERROR: $_" -ForegroundColor Red
} finally {
    Write-Host ""
    Read-Host "Press Enter to exit..."
}
