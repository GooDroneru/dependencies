#!/usr/bin/env bash
# Downloads and installs xPack GNU Arm Embedded GCC v14.2.1-1.1 for Linux x64.
#
# Usage:
#   ./install-toolchain.sh          # install
#   ./install-toolchain.sh --force  # re-install even if already present

set -euo pipefail

VERSION="14.2.1-1.1"
ASSET="xpack-arm-none-eabi-gcc-${VERSION}-linux-x64.tar.gz"
DOWNLOAD_URL="https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/download/v${VERSION}/${ASSET}"
SHA_URL="${DOWNLOAD_URL}.sha"

INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLCHAIN_DIR="${INSTALL_DIR}/xpack-arm-none-eabi-gcc-${VERSION}"

FORCE=0
for arg in "$@"; do
    [[ "$arg" == "--force" ]] && FORCE=1
done

echo "xPack ARM GCC installer"
echo "Version  : ${VERSION}"
echo "Target   : ${INSTALL_DIR}"
echo ""

if [[ -d "${TOOLCHAIN_DIR}" && "${FORCE}" -eq 0 ]]; then
    echo "Toolchain already installed at:"
    echo "  ${TOOLCHAIN_DIR}"
    echo "Use --force to reinstall."
    exit 0
fi

ARCHIVE="/tmp/${ASSET}"

# --- Download ----------------------------------------------------------------
echo "Downloading ${ASSET} ..."
curl -L --progress-bar -o "${ARCHIVE}" "${DOWNLOAD_URL}"
echo "Download complete."

# --- Verify SHA-256 ----------------------------------------------------------
echo "Verifying checksum ..."
SHA_LINE="$(curl -fsSL "${SHA_URL}")"
EXPECTED_HASH="$(echo "${SHA_LINE}" | awk '{print toupper($1)}')"
ACTUAL_HASH="$(sha256sum "${ARCHIVE}" | awk '{print toupper($1)}')"

if [[ "${ACTUAL_HASH}" != "${EXPECTED_HASH}" ]]; then
    echo "Checksum mismatch!" >&2
    echo "  Expected : ${EXPECTED_HASH}" >&2
    echo "  Actual   : ${ACTUAL_HASH}" >&2
    rm -f "${ARCHIVE}"
    exit 1
fi
echo "Checksum OK."

# --- Extract -----------------------------------------------------------------
echo "Extracting to ${INSTALL_DIR} ..."
tar -xf "${ARCHIVE}" -C "${INSTALL_DIR}"
echo "Extraction complete."

# --- Cleanup -----------------------------------------------------------------
rm -f "${ARCHIVE}"
echo "Temporary archive removed."

# --- Summary -----------------------------------------------------------------
GCC_BIN="${TOOLCHAIN_DIR}/bin/arm-none-eabi-gcc"
if [[ -x "${GCC_BIN}" ]]; then
    GCC_VERSION="$("${GCC_BIN}" --version 2>&1 | head -1)"
    echo ""
    echo "Installed successfully!"
    echo "  GCC : ${GCC_VERSION}"
    echo "  Bin : ${TOOLCHAIN_DIR}/bin"
else
    echo "Warning: installation may be incomplete — gcc not found at expected path." >&2
fi
