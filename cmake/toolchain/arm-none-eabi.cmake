set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(TOOLCHAIN_TRIPLET "arm-none-eabi")
set(CMAKE_LIBRARY_ARCHITECTURE arm-none-eabi)

# Devcontainer: xPack ARM GCC in /tools/
set(_XPACK_BIN_DIR "/tools/xpack-arm-none-eabi-gcc/bin")

# CI: xPack ARM GCC in GooDroneru/dependencies LFS
set(_CI_XPACK_BIN_DIR "${CMAKE_CURRENT_LIST_DIR}/../../tools/arm/xpack-arm-none-eabi-gcc-14.2.1-1.1/bin")

if(EXISTS "${_XPACK_BIN_DIR}/arm-none-eabi-gcc")
    set(_GCC_EXE "${_XPACK_BIN_DIR}/arm-none-eabi-gcc")
    get_filename_component(TOOLCHAIN_DIR "${_XPACK_BIN_DIR}/.." ABSOLUTE)
    message(STATUS "Found arm-none-eabi toolchain (devcontainer): ${TOOLCHAIN_DIR}")
elseif(EXISTS "${_CI_XPACK_BIN_DIR}/arm-none-eabi-gcc")
    set(_GCC_EXE "${_CI_XPACK_BIN_DIR}/arm-none-eabi-gcc")
    get_filename_component(TOOLCHAIN_DIR "${_CI_XPACK_BIN_DIR}/.." ABSOLUTE)
    message(STATUS "Found arm-none-eabi toolchain (xPack): ${TOOLCHAIN_DIR}")
else()
    find_program(_SYS_GCC NAMES arm-none-eabi-gcc)
    if(NOT _SYS_GCC)
        message(FATAL_ERROR
            "arm-none-eabi-gcc not found.\n"
            "Expected at:\n"
            "  ${_XPACK_BIN_DIR} (devcontainer)\n"
            "  ${_CI_XPACK_BIN_DIR} (CI)\n"
            "Or install arm-none-eabi-gcc system-wide.")
    endif()
    get_filename_component(_SYS_GCC_DIR "${_SYS_GCC}" DIRECTORY)
    get_filename_component(TOOLCHAIN_DIR "${_SYS_GCC_DIR}/.." ABSOLUTE)
    message(STATUS "Found arm-none-eabi toolchain (system): ${_SYS_GCC}")
endif()

include(${CMAKE_CURRENT_LIST_DIR}/gcc.cmake)
