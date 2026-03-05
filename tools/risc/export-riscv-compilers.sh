#!/usr/bin/env bash
set -euo pipefail

# Usage: export-riscv-compilers.sh <toolchain-root-or-bin>
# If run under GitHub Actions this will append CC/CXX/ASM to $GITHUB_ENV

TOOLCHAIN_PATH="${1:-${RISCV_TOOLCHAIN_DIR:-}}"
if [ -z "${TOOLCHAIN_PATH}" ]; then
  echo "Usage: $0 <toolchain-root-or-bin>" >&2
  exit 2
fi

# If a root is passed, prefer the bin directory
if [ -d "$TOOLCHAIN_PATH/bin" ]; then
  BIN_DIR="$TOOLCHAIN_PATH/bin"
else
  BIN_DIR="$TOOLCHAIN_PATH"
fi

echo "Detecting RISC‑V compilers in: $BIN_DIR"

# Find candidates
shopt -s nullglob
cands=("$BIN_DIR"/*-gcc*)
shopt -u nullglob

if [ ${#cands[@]} -eq 0 ]; then
  echo "No riscv gcc binary found in $BIN_DIR" >&2
  exit 3
fi

# Prefer common SiFive/xpack names, otherwise pick first
preferred=("riscv64-unknown-elf-gcc" "riscv-none-elf-gcc" "riscv-none-embed-gcc")
selected=""
for pref in "${preferred[@]}"; do
  for f in "$BIN_DIR"/${pref}*; do
    if [ -e "$f" ]; then
      selected="$f"
      break 2
    fi
  done
done

if [ -z "$selected" ]; then
  # fallback to lexicographically first candidate
  IFS=$'\n' sorted=($(printf "%s\n" "${cands[@]}" | sort))
  selected="${sorted[0]}"
fi

# Build companion tool names
gxx="${selected%gcc}g++"
asm_compiler="$selected"

echo "Detected compiler: $selected"
echo "Detected g++: $gxx"

# Export to current shell for immediate use
export CC="$selected"
export CXX="$gxx"
export ASM="$asm_compiler"

# Persist into GitHub Actions environment if available
if [ -n "${GITHUB_ENV:-}" ]; then
  printf "CC=%s\nCXX=%s\nASM=%s\n" "$selected" "$gxx" "$asm_compiler" >> "$GITHUB_ENV"
  echo "Wrote CC/CXX/ASM to GITHUB_ENV"
fi

echo "Exported CC=$CC CXX=$CXX ASM=$ASM"

exit 0
