param(
    [string]$Tag = "latest",
    [string]$TargetDir = "$PSScriptRoot",
    [string]$Platform = "auto"
    ,[string]$DownloadUrl = ""
    ,[string]$AssetName = ""
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


# Choose asset heuristically: prefer platform-specific names and known archive extensions
function Select-Asset($assets, $plat) {
    if (-not $assets) { return $null }
    # prefer extension order
    $extOrder = @('\.tar\.xz$','\.tar\.gz$','\.7z$','\.zip$')
    # prefer keywords
    $platKeywords = if ($plat -eq 'windows') { @('win','windows','x86_64','win64') } else { @('linux','x86_64','linux64') }

    foreach ($kw in $platKeywords) {
        foreach ($ext in $extOrder) {
            $match = $assets | Where-Object { $_.name -match ("(?i)" + $kw) -and $_.name -match $ext } | Select-Object -First 1
            if ($match) { return $match }
        }
    }

    # if no keyword match, try any asset with preferred extensions
    foreach ($ext in $extOrder) {
        $match = $assets | Where-Object { $_.name -match $ext } | Select-Object -First 1
        if ($match) { return $match }
    }

    # fallback to first asset
    return $assets | Select-Object -First 1
}

$asset = Select-Asset $rel.assets $plat
if ($DownloadUrl -ne "") {
    $downloadUrl = $DownloadUrl
    if ($AssetName -ne "") { $assetName = $AssetName } else { $assetName = [System.IO.Path]::GetFileName($downloadUrl) }
    Write-Host "Using explicit DownloadUrl: $downloadUrl"
} else {
    if (-not $asset) {
        Write-Warning "No release asset found from GitHub for tag '$Tag'. Available assets:\n$($rel.assets | ForEach-Object { $_.name } | Out-String)"
        # try to find a local xPack toolchain as a fallback
        Write-Host "Searching for local xPack toolchain under script tree..."
        $searchRoot = $PSScriptRoot
        $candidates = Get-ChildItem -Path $searchRoot -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'xpack-riscv-none-elf-gcc*' }
        if ($candidates -and $candidates.Count -gt 0) {
            $candidate = $candidates[0].FullName
            Write-Host "Found local xPack toolchain: $candidate"
            Write-Host "Final toolchain root: $candidate"
            Write-Host "To use it in CI or locally, set RISCV_TOOLCHAIN_DIR to: $candidate"
            exit 0
        }

        Write-Error "No release asset found and no local xPack fallback discovered. You can pass -DownloadUrl '<url>' to use a direct URL or add a local xPack under the script tree."
        exit 3
    }

    $downloadUrl = $asset.browser_download_url
    $assetName = $asset.name
    Write-Host "Selected asset: $assetName"
    Write-Host "Downloading $downloadUrl"
}

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
