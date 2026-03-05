#!/usr/bin/env bash
set -euo pipefail

# install-sifive-toolchain.sh
# Download and extract SiFive freedom-tools prebuilt GCC 8.2 archives
# Usage: install-sifive-toolchain.sh [target-dir] [platform]
# platform: auto|linux|windows|darwin

TARGET_DIR=${1:-$(pwd)}
PLATFORM=${2:-auto}

detect_platform() {
  if [ "$PLATFORM" != "auto" ]; then
    echo "$PLATFORM"
    return
  fi
  uname_s=$(uname -s)
  case "$uname_s" in
    Linux*) echo linux ;;
    Darwin*) echo darwin ;;
    MINGW*|MSYS*|CYGWIN*) echo windows ;;
    *) echo linux ;;
  esac
}

plat=$(detect_platform)
echo "Detected platform: $plat"

BASE=https://static.dev.sifive.com/dev-tools
VERSION_PART="riscv64-unknown-elf-gcc-8.2.0-2019.05.3"

declare -a candidates
if [ "$plat" = "linux" ]; then
  candidates=(
    "$BASE/${VERSION_PART}-x86_64-linux-centos6.tar.gz"
    "$BASE/${VERSION_PART}-x86_64-linux-ubuntu16.tar.gz"
    "$BASE/${VERSION_PART}-x86_64-linux.tar.gz"
  )
elif [ "$plat" = "darwin" ]; then
  candidates=("$BASE/${VERSION_PART}-x86_64-apple-darwin.tar.gz")
else
  # try mingw / windows archive
  candidates=(
    "$BASE/${VERSION_PART}-x86_64-w64-mingw32.tar.gz"
    "$BASE/${VERSION_PART}-x86_64-windows.tar.gz"
  )
fi

mkdir -p "$TARGET_DIR"
OUTDIR=$(mktemp -d)
trap 'rm -rf "$OUTDIR"' EXIT

download_url=""
for url in "${candidates[@]}"; do
  echo "Checking $url"
  if curl -sSfI "$url" >/dev/null 2>&1; then
    download_url=$url
    break
  fi
done

if [ -z "$download_url" ]; then
  echo "No suitable SiFive prebuilt archive found for platform $plat"
  exit 2
fi

echo "Downloading $download_url"
archive="$OUTDIR/$(basename "$download_url")"
curl -L --retry 3 -o "$archive" "$download_url"

echo "Extracting to $TARGET_DIR"
tar -xzf "$archive" -C "$TARGET_DIR"

# If extraction created a single subdir, print that as the toolchain root
firstsub=$(find "$TARGET_DIR" -maxdepth 1 -type d | sed -n '2p' || true)
if [ -n "$firstsub" ] && [ -d "$firstsub/bin" ]; then
  echo "Toolchain root: $firstsub"
  echo "$firstsub"
else
  echo "Toolchain root: $TARGET_DIR"
  echo "$TARGET_DIR"
fi

exit 0
