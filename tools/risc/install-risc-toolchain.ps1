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

Write-Host "Selecting SiFive freedom-tools v2019.05.0 prebuilt assets for platform: $plat"

# If user provided an explicit DownloadUrl, use it. Otherwise pick a SiFive prebuilt URL based on platform.
if ($DownloadUrl -ne "") {
    $downloadUrl = $DownloadUrl
    if ($AssetName -ne "") { $assetName = $AssetName } else { $assetName = [System.IO.Path]::GetFileName($downloadUrl) }
    Write-Host "Using explicit DownloadUrl: $downloadUrl"
} else {
    Write-Host "No DownloadUrl provided — selecting SiFive 8.2 prebuilt archive"
    switch ($plat) {
        'linux' {
            $candidates = @(
                'https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.2.0-2019.05.3-x86_64-linux-centos6.tar.gz',
                'https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.2.0-2019.05.3-x86_64-linux.tar.gz'
            )
        }
        'darwin' {
            $candidates = @('https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.2.0-2019.05.3-x86_64-apple-darwin.tar.gz')
        }
        'windows' {
            $candidates = @('https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.2.0-2019.05.3-x86_64-w64-mingw32.tar.gz')
        }
        default {
            $candidates = @('https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.2.0-2019.05.3-x86_64-linux-centos6.tar.gz')
        }
    }

    $downloadUrl = $null
    foreach ($u in $candidates) {
        try {
            $resp = Invoke-WebRequest -Uri $u -Method Head -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
            if ($resp.StatusCode -ge 200 -and $resp.StatusCode -lt 400) { $downloadUrl = $u; break }
        } catch {
            # try next
        }
    }

    if (-not $downloadUrl) {
        Write-Error "No reachable SiFive prebuilt archive found for platform '$plat'. Provide -DownloadUrl to use a specific archive."
        exit 3
    }

    $assetName = [System.IO.Path]::GetFileName($downloadUrl)
    Write-Host "Selected SiFive asset: $assetName"
    Write-Host "Downloading $downloadUrl"
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
$localFile = Join-Path $tmp $assetName

Invoke-WebRequest -Uri $downloadUrl -OutFile $localFile -UseBasicParsing

Write-Host "Downloaded to $localFile"

# Ensure target directory
$installRoot = Join-Path $TargetDir "riscv-toolchain"
if (-not (Test-Path $installRoot)) { New-Item -ItemType Directory -Force -Path $installRoot | Out-Null }

Write-Host "Extracting $localFile to $installRoot"

# Choose extractor by archive extension
if ($localFile -match '\.tar\.gz$' -or $localFile -match '\.tgz$') {
    if ($IsWindows) {
        # On Windows, try tar (available on modern runners) or 7z as fallback
        try {
            tar -xzf $localFile -C $installRoot
        } catch {
            $seven = "C:\Program Files\7-Zip\7z.exe"
            if (-not (Test-Path $seven)) { $seven = "7z" }
            & $seven x $localFile -o$installRoot -y
        }
    } else {
        tar -xzf $localFile -C $installRoot
    }
} elseif ($localFile -match '\.tar\.xz$') {
    if ($IsWindows) {
        try { tar -xJf $localFile -C $installRoot } catch { $seven = "C:\Program Files\7-Zip\7z.exe"; if (-not (Test-Path $seven)) { $seven = "7z" }; & $seven x $localFile -o$installRoot -y }
    } else {
        tar -xJf $localFile -C $installRoot
    }
} elseif ($localFile -match '\.zip$' -or $localFile -match '\.7z$') {
    $seven = "C:\Program Files\7-Zip\7z.exe"
    if (-not (Test-Path $seven)) { $seven = "7z" }
    & $seven x $localFile -o$installRoot -y
} else {
    # Unknown extension — attempt 7z
    $seven = "C:\Program Files\7-Zip\7z.exe"
    if (-not (Test-Path $seven)) { $seven = "7z" }
    & $seven x $localFile -o$installRoot -y
}

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
