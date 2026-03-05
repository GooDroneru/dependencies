set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR rv32imac)

set(TOOLCHAIN_TRIPLET "riscv-none-embed")
set(CMAKE_LIBRARY_ARCHITECTURE riscv-none-embed)

set(_PINNED_TOOLCHAIN_ROOT "D:/git/dependencies/tools/risc/riscv-toolchain/risc-none-embed-gcc-8.2.0")

# Prefer RISCV_TOOLCHAIN_DIR from environment (CI), fall back to pinned local path
if(DEFINED ENV{RISCV_TOOLCHAIN_DIR} AND NOT "$ENV{RISCV_TOOLCHAIN_DIR}" STREQUAL "")
    set(_TOOLCHAIN_ROOT "$ENV{RISCV_TOOLCHAIN_DIR}")
    message(STATUS "Using RISCV_TOOLCHAIN_DIR from environment: ${_TOOLCHAIN_ROOT}")
else()
    set(_TOOLCHAIN_ROOT "${_PINNED_TOOLCHAIN_ROOT}")
    message(STATUS "Using pinned toolchain root: ${_TOOLCHAIN_ROOT}")
endif()

if(WIN32)
    set(_GCC_EXE "${_TOOLCHAIN_ROOT}/bin/riscv-none-embed-gcc.exe")
else()
    set(_GCC_EXE "${_TOOLCHAIN_ROOT}/bin/riscv-none-embed-gcc")
endif()

if(EXISTS "${_GCC_EXE}")
    get_filename_component(TOOLCHAIN_DIR "${_TOOLCHAIN_ROOT}" ABSOLUTE)
    message(STATUS "Found riscv-none-embed toolchain: ${TOOLCHAIN_DIR}")
else()
    message(FATAL_ERROR
        "riscv-none-embed-gcc not found at: ${_GCC_EXE}\n"
        "Please install the toolchain or set RISCV_TOOLCHAIN_DIR environment variable.")
endif()

include(${CMAKE_CURRENT_LIST_DIR}/gcc.cmake)