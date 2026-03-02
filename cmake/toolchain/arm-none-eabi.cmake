set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(TOOLCHAIN_TRIPLET "arm-none-eabi")
set(CMAKE_LIBRARY_ARCHITECTURE arm-none-eabi)

# Try local xPack ARM GCC first (installed via tools/arm/install-toolchain)
set(_XPACK_ARM_VERSION "14.2.1-1.1")
set(_XPACK_BIN_DIR "${CMAKE_CURRENT_LIST_DIR}/../../tools/arm/xpack-arm-none-eabi-gcc-${_XPACK_ARM_VERSION}/bin")

if(WIN32)
    set(_GCC_EXE "${_XPACK_BIN_DIR}/arm-none-eabi-gcc.exe")
else()
    set(_GCC_EXE "${_XPACK_BIN_DIR}/arm-none-eabi-gcc")
endif()

if(EXISTS "${_GCC_EXE}")
    get_filename_component(TOOLCHAIN_DIR "${_XPACK_BIN_DIR}/.." ABSOLUTE)
    message(STATUS "Found arm-none-eabi toolchain (xPack): ${TOOLCHAIN_DIR}")
else()
    # Fall back to arm-none-eabi-gcc on system PATH
    find_program(_SYS_GCC NAMES arm-none-eabi-gcc)
    if(NOT _SYS_GCC)
        message(FATAL_ERROR
            "arm-none-eabi-gcc not found.\n"
            "Expected xPack ${_XPACK_ARM_VERSION} at: ${_XPACK_BIN_DIR}\n"
            "Run the install script:\n"
            "  Windows : dependencies/tools/arm/install-toolchain.cmd\n"
            "  Linux   : dependencies/tools/arm/install-toolchain.sh\n"
            "Or install arm-none-eabi-gcc system-wide.")
    endif()
    get_filename_component(TOOLCHAIN_DIR "${_SYS_GCC}/../.." ABSOLUTE)
    message(STATUS "Found arm-none-eabi toolchain (system): ${_SYS_GCC}")
endif()

include(${CMAKE_CURRENT_LIST_DIR}/gcc.cmake)
