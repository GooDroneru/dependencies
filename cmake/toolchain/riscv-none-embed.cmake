
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR rv32imac)

set(TOOLCHAIN_TRIPLET "riscv-none-embed")
set(CMAKE_LIBRARY_ARCHITECTURE riscv-none-embed)

set(_EMBED_VERSION "v1.4")
set(_EMBED_BIN_DIR "${CMAKE_CURRENT_LIST_DIR}/../../tools/risc/riscv-none-embed-gcc-${_EMBED_VERSION}/bin")

if(WIN32)
    set(_GCC_EXE "${_EMBED_BIN_DIR}/riscv-none-embed-gcc.exe")
else()
    set(_GCC_EXE "${_EMBED_BIN_DIR}/riscv-none-embed-gcc")
endif()

if(NOT EXISTS "${_GCC_EXE}")
    message(FATAL_ERROR
        "riscv-none-embed GCC ${_EMBED_VERSION} not found.\n"
        "Expected: ${_GCC_EXE}\n"
        "Copy MounRiver toolchain to:\n"
        "  dependencies/tools/risc/riscv-none-embed-gcc-${_EMBED_VERSION}/")
endif()

get_filename_component(TOOLCHAIN_DIR "${_EMBED_BIN_DIR}/.." ABSOLUTE)
message(STATUS "Found riscv-none-embed toolchain: ${TOOLCHAIN_DIR}")

include(${CMAKE_CURRENT_LIST_DIR}/gcc.cmake)
