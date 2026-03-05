
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR rv32imac)

set(TOOLCHAIN_TRIPLET "riscv-none-embed")
set(CMAKE_LIBRARY_ARCHITECTURE riscv-none-embed)

# Minimal pinned toolchain (based on arm-none-eabi.cmake style)
# Hardcoded compiler path for CH32 builds
set(_PINNED_TOOLCHAIN_ROOT "D:/git/dependencies/tools/risc/riscv-toolchain/risc-none-embed-gcc-8.2.0")

if(WIN32)
    set(_GCC_EXE "${_PINNED_TOOLCHAIN_ROOT}/bin/riscv-none-embed-gcc.exe")
else()
    set(_GCC_EXE "${_PINNED_TOOLCHAIN_ROOT}/bin/riscv-none-embed-gcc")
endif()

if(EXISTS "${_GCC_EXE}")
    get_filename_component(TOOLCHAIN_DIR "${_PINNED_TOOLCHAIN_ROOT}" ABSOLUTE)
    message(STATUS "Found riscv-none-embed toolchain (pinned): ${TOOLCHAIN_DIR}")
else()
    message(FATAL_ERROR
        "riscv-none-embed-gcc not found at: ${_PINNED_TOOLCHAIN_ROOT}\n"
        "Please install the toolchain at that path or update this file.")
endif()

include(${CMAKE_CURRENT_LIST_DIR}/gcc.cmake)
