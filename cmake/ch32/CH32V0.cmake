include(${CMAKE_CURRENT_LIST_DIR}/../toolchain/riscv-none-embed.cmake)

set(MCU_ARCH rv32ecxw)
set(MCU_INTEGER_ABI ilp32e)

include(${CMAKE_CURRENT_LIST_DIR}/CH32Vcommon.cmake)