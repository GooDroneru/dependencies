set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR rv32imfd_zicsr_zifencei)

# Try PATH first (compiler in /usr/local/bin from devcontainer)
find_program(_PATH_GCC NAMES
    riscv64-unknown-elf-gcc
    riscv32-unknown-elf-gcc
    riscv-none-elf-gcc
    riscv-none-embed-gcc
)
if(_PATH_GCC)
    get_filename_component(_GCC_EXE "${_PATH_GCC}" ABSOLUTE)
    # Resolve symlinks to find real toolchain root
    execute_process(COMMAND realpath "${_GCC_EXE}"
        OUTPUT_VARIABLE _GCC_REAL
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(_GCC_REAL AND EXISTS "${_GCC_REAL}")
        set(_GCC_EXE "${_GCC_REAL}")
    endif()
    get_filename_component(_BIN_DIR "${_GCC_EXE}" DIRECTORY)
    # Detect layout: standard (bin/ subdir) vs non-standard (gcc at root)
    if(_BIN_DIR MATCHES "/bin$")
        get_filename_component(_TOOLCHAIN_ROOT "${_BIN_DIR}" DIRECTORY)
    else()
        set(_TOOLCHAIN_ROOT "${_BIN_DIR}")
    endif()
    get_filename_component(_GCC_NAME "${_GCC_EXE}" NAME)
    string(REGEX REPLACE "-gcc(\\.exe)?$" "" TOOLCHAIN_TRIPLET "${_GCC_NAME}")
    message(STATUS "Using RISC-V GCC from PATH: ${_GCC_EXE}")
endif()

if(NOT DEFINED _GCC_EXE)
    if(DEFINED ENV{RISCV_TOOLCHAIN_DIR} AND NOT "$ENV{RISCV_TOOLCHAIN_DIR}" STREQUAL "")
        set(_TOOLCHAIN_ROOT "$ENV{RISCV_TOOLCHAIN_DIR}")
        message(STATUS "Using RISCV_TOOLCHAIN_DIR from environment: ${_TOOLCHAIN_ROOT}")
    else()
        # Devcontainer paths
        foreach(_candidate
            "/opt/riscv-gnu-toolchain"
            "/tools/xpack-riscv-none-embed-gcc"
            "${CMAKE_CURRENT_LIST_DIR}/../../tools/risc/riscv-toolchain/risc-none-embed-gcc-8.2.0"
        )
            if(EXISTS "${_candidate}/bin/riscv64-unknown-elf-gcc" OR
               EXISTS "${_candidate}/bin/riscv32-unknown-elf-gcc" OR
               EXISTS "${_candidate}/bin/riscv-none-elf-gcc" OR
               EXISTS "${_candidate}/bin/riscv-none-embed-gcc")
                set(_TOOLCHAIN_ROOT "${_candidate}")
                break()
            endif()
        endforeach()
        if(NOT DEFINED _TOOLCHAIN_ROOT)
            set(_TOOLCHAIN_ROOT "${CMAKE_CURRENT_LIST_DIR}/../../tools/risc/riscv-toolchain/risc-none-embed-gcc-8.2.0")
            message(STATUS "Using pinned toolchain root: ${_TOOLCHAIN_ROOT}")
        endif()
    endif()

    foreach(_triplet "riscv64-unknown-elf" "riscv32-unknown-elf" "riscv-none-elf" "riscv-none-embed")
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
        "Expected riscv64-unknown-elf-gcc, riscv32-unknown-elf-gcc, riscv-none-elf-gcc or riscv-none-embed-gcc.\n"
        "Please install the toolchain or set RISCV_TOOLCHAIN_DIR environment variable.")
endif()

set(CMAKE_LIBRARY_ARCHITECTURE ${TOOLCHAIN_TRIPLET})
get_filename_component(TOOLCHAIN_DIR "${_TOOLCHAIN_ROOT}" ABSOLUTE)
message(STATUS "Using toolchain: ${_GCC_EXE}")

include(${CMAKE_CURRENT_LIST_DIR}/gcc.cmake)
