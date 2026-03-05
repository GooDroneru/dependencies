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
    try {
        if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)) { return "windows" }
        if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::OSX)) { return "darwin" }
        if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Linux)) { return "linux" }
    } catch {
        # Fallback to older uname heuristic
        $uname = (uname -s) 2>$null
        if ($uname -match "Linux") { return "linux" }
        if ($uname -match "Darwin") { return "darwin" }
    }
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

    # Try downloading each candidate in turn until one succeeds
    $downloadUrl = $null
    $localAttempt = $null
    # prepare temporary download directory before attempting candidates
    $tmp = Join-Path $env:TEMP ([System.IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory -Force -Path $tmp | Out-Null
    if (-not $candidates -or $candidates.Count -eq 0) {
        Write-Host "No candidate URLs available for platform '$plat'"
    }
    foreach ($u in $candidates) {
        if (-not $u) { continue }
        $tryName = [System.IO.Path]::GetFileName($u)
        $tryFile = Join-Path $tmp $tryName
        Write-Host "Attempting to download candidate: $u"
        try {
            Invoke-WebRequest -Uri $u -OutFile $tryFile -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
            # downloaded successfully
            Write-Host "Downloaded candidate to $tryFile"
            $downloadUrl = $u
            $assetName = $tryName
            $localAttempt = $tryFile
            break
        } catch {
            Write-Host "Candidate failed: $u ($($_.Exception.Message))"
            if (Test-Path $tryFile) { Remove-Item -Force $tryFile }
            continue
        }
    }

    if (-not $downloadUrl) {
        Write-Error "No reachable SiFive prebuilt archive found for platform '$plat'. Provide -DownloadUrl to use a specific archive."
        exit 3
    }

    Write-Host "Selected SiFive asset: $assetName ($downloadUrl)"
}


# (Old openwch-release handling removed.)
# At this point $downloadUrl and $assetName have been selected above (SiFive defaults or explicit DownloadUrl).

$tmp = Join-Path $env:TEMP ([System.IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
$localFile = $null
if ($localAttempt -ne $null -and (Test-Path $localAttempt)) {
    $localFile = $localAttempt
    Write-Host "Using previously downloaded file: $localFile"
} else {
    # No predownload; download now
    $localFile = Join-Path $tmp $assetName
    Write-Host "Downloading $downloadUrl to $localFile"
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $localFile -UseBasicParsing -TimeoutSec 60 -ErrorAction Stop
        Write-Host "Downloaded to $localFile"
    } catch {
        Write-Error "Failed to download $downloadUrl : $($_.Exception.Message)"
        exit 4
    }
}

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
