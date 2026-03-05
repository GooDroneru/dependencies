#!/usr/bin/env bash
set -euo pipefail

echo "export-riscv-compilers.sh: locating RISC-V toolchain..."

emit_env() {
  local name="$1" value="$2"
  if [ -n "${GITHUB_ENV:-}" ] && [ -w "${GITHUB_ENV}" ]; then
    printf '%s=%s\n' "$name" "$value" >> "$GITHUB_ENV"
  else
    # Fallback for local runs
    export "$name"="$value"
  fi
}

normalize_root() {
  local p="$1"
  # If path contains ".content" (xPack layout), cut at that point and keep .content
  if [[ "$p" == *".content"* ]]; then
    p="${p%%.content*}.content"
  fi
  # Resolve to absolute if possible
  if [ -d "$p" ]; then
    (cd "$p" 2>/dev/null && pwd) || echo "$p"
  else
    echo ""
  fi
}

try_bins_in() {
  local root="$1"
  [ -z "$root" ] && return 1
  local bin="$root/bin"
  if [ ! -d "$bin" ]; then
    return 1
  fi
  # Prefer explicit names
  local prefer=(riscv64-unknown-elf-gcc riscv-none-embed-gcc riscv64-unknown-elf-gcc-*)
  for p in "${prefer[@]}"; do
    for f in "$bin"/$p; do
      if [ -x "$f" ]; then
        echo "$f"
        return 0
      fi
    done
  done
  # Last resort: any executable in bin with 'riscv' and 'gcc' in name
  for f in "$bin"/*gcc*; do
    if [ -x "$f" ] && [[ "$(basename "$f")" == *riscv* ]]; then
      echo "$f"
      return 0
    fi
  done
  return 1
}

candidates=()

# 1. Respect explicit env var
if [ -n "${RISCV_TOOLCHAIN_DIR:-}" ]; then
  candidates+=("$RISCV_TOOLCHAIN_DIR")
fi

# 2. Runner temp common location used by CI workflows
if [ -n "${RUNNER_TEMP:-}" ]; then
  candidates+=("$RUNNER_TEMP/riscv" "$RUNNER_TEMP/risc")
fi

# 3. Workspace relative locations
cwd="$(pwd)"
candidates+=("$cwd/_deps/tools/risc" "$cwd/../dependencies/tools/risc" "$cwd/dependencies/tools/risc")

# 4. User-local xPack installs (Linux runners)
if [ -n "${HOME:-}" ]; then
  for xp in "$HOME/.local/xPacks/"*/.content; do
    [ -e "$xp" ] || continue
    candidates+=("$xp")
  done
fi

# 5. Common absolute path (Windows dev machine pinned path)
candidates+=("D:/git/dependencies/tools/risc/riscv-toolchain/risc-none-embed-gcc-8.2.0")

found_cc=""
found_root=""
for c in "${candidates[@]}"; do
  root="$(normalize_root "$c")"
  [ -z "$root" ] && continue
  cc_path="$(try_bins_in "$root" || true)"
  if [ -n "$cc_path" ]; then
    found_cc="$cc_path"
    found_root="$root"
    break
  fi
done

if [ -z "${found_cc}" ]; then
  echo "ERROR: no riscv gcc found. Tried candidate roots:" >&2
  for c in "${candidates[@]}"; do echo " - $c" >&2; done
  exit 1
fi

cc_bin="$found_cc"
cc_base="$(basename "$cc_bin")"
tool_prefix="${cc_base%gcc}"

cxx_bin="$found_root/bin/${cc_base/gcc/g++}"
asm_bin="$found_root/bin/${cc_base}"

# If expected cxx doesn't exist, try g++ alternatives
if [ ! -x "$cxx_bin" ]; then
  for alt in "$found_root/bin/${tool_prefix}g++" "$found_root/bin/${tool_prefix}c++"; do
    if [ -x "$alt" ]; then cxx_bin="$alt"; break; fi
  done
fi

echo "Found RISC-V toolchain root: $found_root"
echo "  CC  = $cc_bin"
echo "  CXX = $cxx_bin"
echo "  ASM = $asm_bin"

emit_env CC "$cc_bin"
emit_env CXX "$cxx_bin"
emit_env ASM "$asm_bin"

echo "export-riscv-compilers.sh: exported CC/CXX/ASM"

exit 0
