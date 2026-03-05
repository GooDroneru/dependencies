<#
.SYNOPSIS
    Download and extract openwch/risc-none-embed-gcc release (tag 8.2.0) into tools/risc.

.DESCRIPTION
    Downloads the specified archive (by default the 8.2.0 release source tar.gz) and
    extracts it into the target directory. On Windows the script will try `tar` then `7z`.

.PARAMETER DownloadUrl
    Optional explicit URL to download. Defaults to the openwch release tar.gz for 8.2.0.

.PARAMETER TargetDir
    Directory where the toolchain will be extracted. Defaults to a subfolder `riscv-toolchain` inside the script folder.

.PARAMETER Force
    If set, removes existing target dir before installing.
#>

param(
    [string]$DownloadUrl = "https://github.com/openwch/risc-none-embed-gcc/archive/refs/tags/8.2.0.tar.gz",
    [string]$TargetDir = (Join-Path $PSScriptRoot "riscv-toolchain"),
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "install-risc-from-openwch.ps1 - DownloadUrl=$DownloadUrl" -ForegroundColor Cyan
Write-Host "TargetDir=$TargetDir"

$assetName = [System.IO.Path]::GetFileName($DownloadUrl)
$tmp = Join-Path $env:TEMP ([System.IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
$localFile = Join-Path $tmp $assetName

try {
    Write-Host "Downloading $DownloadUrl to $localFile ..."
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $localFile -UseBasicParsing -TimeoutSec 0
    Write-Host "Download complete." -ForegroundColor Green
} catch {
    Write-Error "Failed to download $DownloadUrl : $($_.Exception.Message)"
    exit 2
}

if ($Force -and (Test-Path $TargetDir)) {
    Write-Host "Removing existing target dir $TargetDir (force)" -ForegroundColor Yellow
    Remove-Item -Recurse -Force -LiteralPath $TargetDir
}

if (-not (Test-Path $TargetDir)) { New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null }

Write-Host "Extracting $localFile to $TargetDir ..."
try {
    if ($localFile -match '\.tar\.gz$' -or $localFile -match '\.tgz$') {
        try {
            tar -xzf $localFile -C $TargetDir
            Write-Host "Extracted with tar." -ForegroundColor Green
        } catch {
            $seven = 'C:\Program Files\7-Zip\7z.exe'
            if (-not (Test-Path $seven)) { $seven = '7z' }
            & $seven x $localFile -o$TargetDir -y
            Write-Host "Extracted with 7z." -ForegroundColor Green
        }
    } elseif ($localFile -match '\.zip$') {
        Expand-Archive -Path $localFile -DestinationPath $TargetDir -Force
        Write-Host "Extracted zip with Expand-Archive." -ForegroundColor Green
    } else {
        $seven = 'C:\Program Files\7-Zip\7z.exe'
        if (-not (Test-Path $seven)) { $seven = '7z' }
        & $seven x $localFile -o$TargetDir -y
        Write-Host "Extracted with 7z (unknown extension)." -ForegroundColor Green
    }
} catch {
    Write-Error "Extraction failed: $($_.Exception.Message)"
    exit 3
}

# Normalize subdirs list to array
$subs = @(Get-ChildItem -LiteralPath $TargetDir -Directory -Force -ErrorAction SilentlyContinue)
if ($subs -and $subs.Count -eq 1) {
    $candidate = $subs[0].FullName
    if (Test-Path (Join-Path $candidate 'bin')) {
        Write-Host "Toolchain root appears to be: $candidate" -ForegroundColor Green
        Write-Host "Add to PATH: $candidate\bin"
        Write-Host "Installation complete." -ForegroundColor Green
        exit 0
    }
}

Write-Host "Final path: $TargetDir" -ForegroundColor Green
Write-Host "Installation complete." -ForegroundColor Green
exit 0
