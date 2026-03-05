param(
    [string]$Tag = "latest",
    [string]$TargetDir = "$PSScriptRoot",
    [string]$Platform = "auto"
)

Write-Host "Install RISC-V toolchain script"

function Get-Platform() {
    if ($Platform -ne "auto") { return $Platform }
    if ($IsWindows) { return "windows" }
    $uname = (uname -s) 2>$null
    if ($uname -match "Linux") { return "linux" }
    return "linux"
}

$plat = Get-Platform
Write-Host "Detected platform: $plat"

$api = "https://api.github.com/repos/openwch/risc-none-embed-gcc/releases"
if ($Tag -eq "latest") { $url = "$api/latest" } else { $url = "$api/tags/$Tag" }

Write-Host "Querying $url"
try {
    $rel = Invoke-RestMethod -Uri $url -UseBasicParsing
} catch {
    Write-Error "Failed to query GitHub API: $_"; exit 2
}

$asset = $null
foreach ($a in $rel.assets) {
    if ($plat -eq "windows" -and $a.name -match "(?i)win|windows|x86_64|windows.*7z") { $asset = $a; break }
    if ($plat -eq "linux" -and $a.name -match "(?i)linux|x86_64") { $asset = $a; break }
}
if (-not $asset) { $asset = $rel.assets | Select-Object -First 1 }
if (-not $asset) { Write-Error "No release asset found"; exit 3 }

$downloadUrl = $asset.browser_download_url
Write-Host "Selected asset: $($asset.name)"
Write-Host "Downloading $downloadUrl"

$tmp = Join-Path $env:TEMP ([System.IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
$localFile = Join-Path $tmp $asset.name

Invoke-WebRequest -Uri $downloadUrl -OutFile $localFile -UseBasicParsing

Write-Host "Downloaded to $localFile"

# Ensure target directory
$installRoot = Join-Path $TargetDir "riscv-toolchain"
if (-not (Test-Path $installRoot)) { New-Item -ItemType Directory -Force -Path $installRoot | Out-Null }

# Extract using 7z
$seven = "C:\Program Files\7-Zip\7z.exe"
if (-not (Test-Path $seven)) { $seven = "7z" }

& $seven x $localFile -o$installRoot -y

Write-Host "Extracted to $installRoot"

# If extraction created a single subdir with bin, prefer that
$subs = Get-ChildItem -LiteralPath $installRoot -Directory -Force
if ($subs.Count -eq 1) {
    $candidate = $subs[0].FullName
    if (Test-Path (Join-Path $candidate 'bin')) {
        Write-Host "Toolchain root appears to be: $candidate"
        $installRoot = $candidate
    }
}

Write-Host "Final toolchain root: $installRoot"
Write-Host "To use it in CI or locally, set RISCV_TOOLCHAIN_DIR to: $installRoot"

exit 0
