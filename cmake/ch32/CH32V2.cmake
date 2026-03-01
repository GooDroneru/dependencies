include(${CMAKE_CURRENT_LIST_DIR}/../toolchain/riscv-none-embed.cmake)

set(MCU_ARCH rv32imac_zicsr)
set(MCU_INTEGER_ABI ilp32)

# Select linker script based on CH32_DEVICE (must be set before including this file)
if(NOT DEFINED CH32_DEVICE)
    message(FATAL_ERROR "CH32_DEVICE must be set before including CH32V2.cmake (D6, D8, or D8W)")
endif()

set(CH32_SDK_LD_DIR "${CMAKE_CURRENT_LIST_DIR}/../../ch32sdk/ld")
set(CH32_LINKER_SCRIPT "${CH32_SDK_LD_DIR}/ch32v20x_${CH32_DEVICE}.ld"
    CACHE FILEPATH "Linker script selected by CH32_DEVICE" FORCE)
message(STATUS "CH32 linker script: ${CH32_LINKER_SCRIPT}")

include(${CMAKE_CURRENT_LIST_DIR}/CH32Vcommon.cmake)

set_property(CACHE CH32_SYSCLK PROPERTY STRINGS
    SYSCLK_FREQ_HSI
    SYSCLK_FREQ_48MHz_HSI
    SYSCLK_FREQ_56MHz_HSI
    SYSCLK_FREQ_72MHz_HSI
    SYSCLK_FREQ_96MHz_HSI
    SYSCLK_FREQ_120MHz_HSI
    SYSCLK_FREQ_144MHz_HSI
    SYSCLK_FREQ_HSE
    SYSCLK_FREQ_48MHz_HSE
    SYSCLK_FREQ_56MHz_HSE
    SYSCLK_FREQ_72MHz_HSE
    SYSCLK_FREQ_96MHz_HSE
    SYSCLK_FREQ_120MHz_HSE
    SYSCLK_FREQ_144MHz_HSE
)
if(NOT CH32_SYSCLK)
    message(FATAL_ERROR "CH32_SYSCLK must be set to a valid SYSCLK_FREQ_* value")
endif()