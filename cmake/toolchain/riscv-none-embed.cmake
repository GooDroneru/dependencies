set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR rv32imac)

set(_PINNED_TOOLCHAIN_ROOT "D:/git/dependencies/tools/risc/riscv-toolchain/risc-none-embed-gcc-8.2.0")

# Prefer RISCV_TOOLCHAIN_DIR from environment (CI), fall back to pinned local path
if(DEFINED ENV{RISCV_TOOLCHAIN_DIR} AND NOT "$ENV{RISCV_TOOLCHAIN_DIR}" STREQUAL "")
    set(_TOOLCHAIN_ROOT "$ENV{RISCV_TOOLCHAIN_DIR}")
    message(STATUS "Using RISCV_TOOLCHAIN_DIR from environment: ${_TOOLCHAIN_ROOT}")
else()
    set(_TOOLCHAIN_ROOT "${_PINNED_TOOLCHAIN_ROOT}")
    message(STATUS "Using pinned toolchain root: ${_TOOLCHAIN_ROOT}")
endif()

# Auto-detect toolchain triplet: prefer riscv-none-elf (hydrausb3/CI), fall back to riscv-none-embed (legacy/local)
if(WIN32)
    set(_ELF_GCC  "${_TOOLCHAIN_ROOT}/bin/riscv-none-elf-gcc.exe")
    set(_EMBED_GCC "${_TOOLCHAIN_ROOT}/bin/riscv-none-embed-gcc.exe")
else()
    set(_ELF_GCC  "${_TOOLCHAIN_ROOT}/bin/riscv-none-elf-gcc")
    set(_EMBED_GCC "${_TOOLCHAIN_ROOT}/bin/riscv-none-embed-gcc")
endif()

if(EXISTS "${_ELF_GCC}")
    set(TOOLCHAIN_TRIPLET "riscv-none-elf")
    set(_GCC_EXE "${_ELF_GCC}")
    message(STATUS "Detected riscv-none-elf toolchain (hydrausb3/CI)")
elseif(EXISTS "${_EMBED_GCC}")
    set(TOOLCHAIN_TRIPLET "riscv-none-embed")
    set(_GCC_EXE "${_EMBED_GCC}")
    message(STATUS "Detected riscv-none-embed toolchain (legacy/local)")
else()
    message(FATAL_ERROR
        "No RISC-V GCC toolchain found in: ${_TOOLCHAIN_ROOT}/bin\n"
        "Expected riscv-none-elf-gcc or riscv-none-embed-gcc.\n"
        "Please install the toolchain or set RISCV_TOOLCHAIN_DIR environment variable.")
endif()

set(CMAKE_LIBRARY_ARCHITECTURE ${TOOLCHAIN_TRIPLET})
get_filename_component(TOOLCHAIN_DIR "${_TOOLCHAIN_ROOT}" ABSOLUTE)
message(STATUS "Using toolchain: ${_GCC_EXE}")

include(${CMAKE_CURRENT_LIST_DIR}/gcc.cmake)