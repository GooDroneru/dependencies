#!/usr/bin/env bash
# Downloads and installs xPack OpenOCD v0.12.0-7 for Linux x64.
#
# Usage:
#   ./install-openocd.sh          # install
#   ./install-openocd.sh --force  # re-install even if already present

set -euo pipefail

VERSION="0.12.0-7"
ASSET="xpack-openocd-${VERSION}-linux-x64.tar.gz"
DOWNLOAD_URL="https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v${VERSION}/${ASSET}"
SHA_URL="${DOWNLOAD_URL}.sha"

INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENOCD_DIR="${INSTALL_DIR}/xpack-openocd-${VERSION}"

FORCE=0
for arg in "$@"; do
    [[ "$arg" == "--force" ]] && FORCE=1
done

echo "xPack OpenOCD installer"
echo "Version  : ${VERSION}"
echo "Target   : ${INSTALL_DIR}"
echo ""

if [[ -d "${OPENOCD_DIR}" && "${FORCE}" -eq 0 ]]; then
    echo "OpenOCD already installed at:"
    echo "  ${OPENOCD_DIR}"
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
OPENOCD_BIN="${OPENOCD_DIR}/bin/openocd"
if [[ -x "${OPENOCD_BIN}" ]]; then
    OPENOCD_VERSION="$("${OPENOCD_BIN}" --version 2>&1 | head -1)"
    echo ""
    echo "Installed successfully!"
    echo "  OpenOCD : ${OPENOCD_VERSION}"
    echo "  Bin     : ${OPENOCD_DIR}/bin"
    echo "  Scripts : ${OPENOCD_DIR}/openocd/scripts"
else
    echo "Warning: installation may be incomplete — openocd not found at expected path." >&2
fi
