
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR rv32imac)

set(TOOLCHAIN_TRIPLET "riscv-none-embed")
set(CMAKE_LIBRARY_ARCHITECTURE riscv-none-embed)

set(_EMBED_VERSION "v1.4")


# Always use RISCV_TOOLCHAIN_DIR if set, no fallback!
if(DEFINED ENV{RISCV_TOOLCHAIN_DIR} AND NOT "$ENV{RISCV_TOOLCHAIN_DIR}" STREQUAL "")
    set(_EMBED_BIN_DIR "$ENV{RISCV_TOOLCHAIN_DIR}/bin")
    message(STATUS "Using RISCV_TOOLCHAIN_DIR from environment: $_EMBED_BIN_DIR")
    if(WIN32)
        set(_GCC_EXE "${_EMBED_BIN_DIR}/riscv-none-embed-gcc.exe")
    else()
        set(_GCC_EXE "${_EMBED_BIN_DIR}/riscv-none-embed-gcc")
    endif()
    if(NOT EXISTS "${_GCC_EXE}")
        file(GLOB _BIN_CONTENTS LIST_DIRECTORIES false "${_EMBED_BIN_DIR}/*")
        message(FATAL_ERROR "RISCV_TOOLCHAIN_DIR is set, but ${_GCC_EXE} not found!\nContents of bin dir:\n${_BIN_CONTENTS}")
    endif()
else()
    # Fallback: xPack or default
    file(GLOB _XP_PACKS RELATIVE "${CMAKE_CURRENT_LIST_DIR}/../../tools/risc" "${CMAKE_CURRENT_LIST_DIR}/../../tools/risc/xpack-riscv-none-elf-gcc-*")
    if(_XP_PACKS)
        list(SORT _XP_PACKS)
        list(GET _XP_PACKS 0 _CHOICE)
        set(_EMBED_BIN_DIR "${CMAKE_CURRENT_LIST_DIR}/../../tools/risc/${_CHOICE}/bin")
    else()
        set(_EMBED_BIN_DIR "${CMAKE_CURRENT_LIST_DIR}/../../tools/risc/riscv-none-embed-gcc-${_EMBED_VERSION}/bin")
    endif()
endif()

if(WIN32)
    set(_GCC_EXE "${_EMBED_BIN_DIR}/riscv-none-embed-gcc.exe")
else()
    set(_GCC_EXE "${_EMBED_BIN_DIR}/riscv-none-embed-gcc")
endif()

if(NOT EXISTS "${_GCC_EXE}")
    # Try to find riscv-none-embed-gcc on PATH as a fallback
    find_program(_FOUND_RISCV_GCC riscv-none-embed-gcc)
    if(_FOUND_RISCV_GCC)
        get_filename_component(_FOUND_BIN_DIR "${_FOUND_RISCV_GCC}" DIRECTORY)
        set(_EMBED_BIN_DIR "${_FOUND_BIN_DIR}")
        set(_GCC_EXE "${_EMBED_BIN_DIR}/riscv-none-embed-gcc")
        message(STATUS "Found riscv-none-embed-gcc on PATH: ${_GCC_EXE}")
    else()
        # Try xPack toolchain path if XPACK_RISCV_VERSION env var is set (CI cache)
        if(DEFINED ENV{XPACK_RISCV_VERSION} AND NOT "" STREQUAL "$ENV{XPACK_RISCV_VERSION}")
            set(_XPACK_DIR "${CMAKE_CURRENT_LIST_DIR}/../../tools/risc/xpack-riscv-none-elf-gcc-$ENV{XPACK_RISCV_VERSION}")
            # xPack uses riscv-none-elf-gcc names; check for both possibilities
            if(EXISTS "${_XPACK_DIR}/bin/riscv-none-embed-gcc" OR EXISTS "${_XPACK_DIR}/bin/riscv-none-embed-gcc.exe")
                set(_EMBED_BIN_DIR "${_XPACK_DIR}/bin")
                if(WIN32)
                    set(_GCC_EXE "${_EMBED_BIN_DIR}/riscv-none-embed-gcc.exe")
                else()
                    set(_GCC_EXE "${_EMBED_BIN_DIR}/riscv-none-embed-gcc")
                endif()
                message(STATUS "Found xpack riscv toolchain (embed name): ${_GCC_EXE}")
            elseif(EXISTS "${_XPACK_DIR}/bin/riscv-none-elf-gcc" OR EXISTS "${_XPACK_DIR}/bin/riscv-none-elf-gcc.exe")
                set(_EMBED_BIN_DIR "${_XPACK_DIR}/bin")
                if(WIN32)
                    set(_GCC_EXE "${_EMBED_BIN_DIR}/riscv-none-elf-gcc.exe")
                else()
                    set(_GCC_EXE "${_EMBED_BIN_DIR}/riscv-none-elf-gcc")
                endif()
                message(STATUS "Found xpack riscv toolchain (elf name): ${_GCC_EXE}")
            endif()
        endif()

        if(NOT EXISTS "${_GCC_EXE}")
        message(FATAL_ERROR
            "riscv-none-embed GCC ${_EMBED_VERSION} not found.\n"
            "Expected: ${_GCC_EXE}\n"
            "Or set environment variable RISCV_TOOLCHAIN_DIR to the toolchain root.\n"
            "Copy MounRiver toolchain to:\n"
            "  dependencies/tools/risc/riscv-none-embed-gcc-${_EMBED_VERSION}/")
        endif()
    endif()
endif()

get_filename_component(TOOLCHAIN_DIR "${_EMBED_BIN_DIR}/.." ABSOLUTE)
message(STATUS "Found riscv-none-embed toolchain: ${TOOLCHAIN_DIR}")

# Adjust library architecture prefix to match detected toolchain binaries
if(_GCC_EXE MATCHES "riscv-none-elf")
    set(CMAKE_LIBRARY_ARCHITECTURE "riscv-none-elf")
    message(STATUS "Using CMAKE_LIBRARY_ARCHITECTURE=${CMAKE_LIBRARY_ARCHITECTURE}")
else()
    set(CMAKE_LIBRARY_ARCHITECTURE "riscv-none-embed")
    message(STATUS "Using CMAKE_LIBRARY_ARCHITECTURE=${CMAKE_LIBRARY_ARCHITECTURE}")
endif()

include(${CMAKE_CURRENT_LIST_DIR}/gcc.cmake)
