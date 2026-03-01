
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR rv32imac)

set(TOOLCHAIN_TRIPLET "riscv-none-elf")
set(CMAKE_LIBRARY_ARCHITECTURE riscv-none-elf)

set(_XPACK_VERSION "15.2.0-1")
set(_XPACK_BIN_DIR "${CMAKE_CURRENT_LIST_DIR}/../../tools/risc/xpack-riscv-none-elf-gcc-${_XPACK_VERSION}/bin")

if(WIN32)
    set(_GCC_EXE "${_XPACK_BIN_DIR}/riscv-none-elf-gcc.exe")
else()
    set(_GCC_EXE "${_XPACK_BIN_DIR}/riscv-none-elf-gcc")
endif()

if(NOT EXISTS "${_GCC_EXE}")
    message(FATAL_ERROR
        "xPack RISC-V GCC ${_XPACK_VERSION} not found.\n"
        "Expected: ${_GCC_EXE}\n"
        "Run the install script first:\n"
        "  Windows : dependencies/tools/risc/install-toolchain.ps1\n"
        "  Linux   : dependencies/tools/risc/install-toolchain.sh")
endif()

get_filename_component(TOOLCHAIN_DIR "${_XPACK_BIN_DIR}/.." ABSOLUTE)
message(STATUS "Found riscv-none-elf toolchain: ${TOOLCHAIN_DIR}")

include(${CMAKE_CURRENT_LIST_DIR}/gcc.cmake)
