set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR rv32imac)

set(_PINNED_TOOLCHAIN_ROOT "D:/git/dependencies/tools/risc/riscv-toolchain/risc-none-embed-gcc-8.2.0")

# Prefer compiler from PATH (user-installed toolchain accessible from console)
find_program(_PATH_GCC NAMES
    riscv64-unknown-elf-gcc
    riscv-none-elf-gcc
    riscv-none-embed-gcc
)
if(_PATH_GCC)
    get_filename_component(_GCC_EXE "${_PATH_GCC}" ABSOLUTE)
    get_filename_component(_BIN_DIR "${_PATH_GCC}" DIRECTORY)
    get_filename_component(_TOOLCHAIN_ROOT "${_BIN_DIR}" DIRECTORY)
    get_filename_component(_GCC_NAME "${_PATH_GCC}" NAME)
    string(REGEX REPLACE "-gcc(\\.exe)?$" "" TOOLCHAIN_TRIPLET "${_GCC_NAME}")
    message(STATUS "Using RISC-V GCC from PATH: ${_GCC_EXE}")
endif()

if(NOT DEFINED _GCC_EXE)
    # Prefer RISCV_TOOLCHAIN_DIR from environment (CI), fall back to pinned local path
    if(DEFINED ENV{RISCV_TOOLCHAIN_DIR} AND NOT "$ENV{RISCV_TOOLCHAIN_DIR}" STREQUAL "")
        set(_TOOLCHAIN_ROOT "$ENV{RISCV_TOOLCHAIN_DIR}")
        message(STATUS "Using RISCV_TOOLCHAIN_DIR from environment: ${_TOOLCHAIN_ROOT}")
    else()
        set(_TOOLCHAIN_ROOT "${_PINNED_TOOLCHAIN_ROOT}")
        message(STATUS "Using pinned toolchain root: ${_TOOLCHAIN_ROOT}")
    endif()

    # Probe all possible binary names in priority order:
    # 1. riscv64-unknown-elf-gcc  (modern GCC 16+)
    # 2. riscv-none-elf-gcc       (native Linux, hydrausb3)
    # 3. riscv-none-embed-gcc     (native Linux/Windows)
    # 4. riscv-none-embed-gcc.exe (Windows .exe via Wine on Linux)
    foreach(_triplet "riscv64-unknown-elf" "riscv-none-elf" "riscv-none-embed")
        foreach(_suffix "" ".exe")
            set(_candidate "${_TOOLCHAIN_ROOT}/bin/${_triplet}-gcc${_suffix}")
            if(EXISTS "${_candidate}")
                set(TOOLCHAIN_TRIPLET "${_triplet}")
                set(_GCC_EXE "${_candidate}")
                break()
            endif()
        endforeach()
        if(DEFINED _GCC_EXE)
            break()
        endif()
    endforeach()
endif()

if(NOT DEFINED _GCC_EXE)
    message(FATAL_ERROR
        "No RISC-V GCC toolchain found.\n"
        "Searched PATH and: ${_TOOLCHAIN_ROOT}/bin\n"
        "Expected riscv64-unknown-elf-gcc, riscv-none-elf-gcc or riscv-none-embed-gcc.\n"
        "Please install the toolchain or set RISCV_TOOLCHAIN_DIR environment variable.")
endif()

set(CMAKE_LIBRARY_ARCHITECTURE ${TOOLCHAIN_TRIPLET})
get_filename_component(TOOLCHAIN_DIR "${_TOOLCHAIN_ROOT}" ABSOLUTE)
message(STATUS "Using toolchain: ${_GCC_EXE}")

include(${CMAKE_CURRENT_LIST_DIR}/gcc.cmake)