#!/usr/bin/env bash
set -euo pipefail

DOWNLOAD_URL=${1:-https://github.com/openwch/risc-none-embed-gcc/archive/refs/tags/8.2.0.tar.gz}
TARGET_DIR=${2:-"$(cd "$(dirname "$0")" && pwd)/riscv-toolchain"}

echo "install-risc-from-openwch.sh"
echo "DownloadUrl: $DOWNLOAD_URL"
echo "TargetDir: $TARGET_DIR"

ASSET=$(basename "$DOWNLOAD_URL")
TMPDIR=$(mktemp -d)
LOCAL="$TMPDIR/$ASSET"

echo "Downloading to $LOCAL ..."
if command -v curl >/dev/null 2>&1; then
    curl -L --fail -o "$LOCAL" "$DOWNLOAD_URL"
else
    wget -O "$LOCAL" "$DOWNLOAD_URL"
fi

echo "Download complete. Extracting..."
mkdir -p "$TARGET_DIR"
case "$LOCAL" in
    *.tar.gz|*.tgz)
        tar -xzf "$LOCAL" -C "$TARGET_DIR"
        ;;
    *.tar.xz)
        tar -xJf "$LOCAL" -C "$TARGET_DIR"
        ;;
    *.zip)
        unzip -o "$LOCAL" -d "$TARGET_DIR"
        ;;
    *)
        echo "Unknown archive type, trying 7z"
        if command -v 7z >/dev/null 2>&1; then
            7z x "$LOCAL" -o"$TARGET_DIR" -y
        else
            echo "7z not found, cannot extract."
            exit 2
        fi
        ;;
esac

# prefer single subdir with bin
shopt -s nullglob
subs=("$TARGET_DIR"/*/)
if [ ${#subs[@]} -eq 1 ]; then
    candidate="${subs[0]%/}"
    if [ -d "$candidate/bin" ]; then
        echo "Toolchain root appears to be: $candidate"
        echo "Add to PATH: $candidate/bin"
        exit 0
    fi
fi

echo "Final path: $TARGET_DIR"
exit 0
