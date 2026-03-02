# K1921VK035 — Cortex-M4F, hard FPU
# Analogous to CH32V2.cmake for RISC-V targets.
#
# Usage in project CMakeLists.txt (before project()):
#   set(CMAKE_DIR path/to/dependencies/cmake)
#   include(${CMAKE_DIR}/arm/K1921VK035.cmake)
#   include(${CMAKE_DIR}/common.cmake)
#   project(my_project C ASM)
#   ...
#   target_link_libraries(my_target PRIVATE niietsdk K1921VK035 NANO NOSYS)
#   gcc_add_linker_script(my_target PRIVATE ${K1921VK035_LD_SCRIPT})

include(${CMAKE_CURRENT_LIST_DIR}/../toolchain/arm-none-eabi.cmake)

set(MCU_ARCH   cortex-m4)
set(MCU_FPU    fpv4-sp-d16)
set(MCU_FLOAT_ABI hard)

# Default linker script shipped with niietsdk. Projects can override this variable.
set(K1921VK035_LD_SCRIPT
    "${CMAKE_CURRENT_LIST_DIR}/../../niietsdk/Device/NIIET/K1921VK035/Source/GCC/K1921VK035.ld"
    CACHE FILEPATH "Linker script for K1921VK035"
)
# ESC-specific linker script: adds .firmware_start / .eeprom sections and
# exports _flash_start_addr, _firmware_start_addr, _eeprom_start_addr symbols.
set(K1921VK035_ESC_LD_SCRIPT
    "${CMAKE_CURRENT_LIST_DIR}/../../niietsdk/Device/NIIET/K1921VK035/Source/GCC/esc_K1921VK035.ld"
    CACHE FILEPATH "ESC linker script for K1921VK035"
)
message(STATUS "K1921VK035 linker script    : ${K1921VK035_LD_SCRIPT}")
message(STATUS "K1921VK035 ESC linker script: ${K1921VK035_ESC_LD_SCRIPT}")

# --------------------------------------------------------------------------
# INTERFACE library — attach to any executable to get MCU-specific flags
# --------------------------------------------------------------------------
add_library(K1921VK035 INTERFACE IMPORTED)

set(_K1921VK035_ARCH_FLAGS
    -mcpu=${MCU_ARCH}
    -mthumb
    -mfpu=${MCU_FPU}
    -mfloat-abi=${MCU_FLOAT_ABI}
)

target_compile_options(K1921VK035 INTERFACE
    ${_K1921VK035_ARCH_FLAGS}
    -ffunction-sections
    -fdata-sections
    -fsigned-char
    -fmessage-length=0
    # C++ runtime overhead reduction
    $<$<COMPILE_LANGUAGE:CXX>:
        -fno-exceptions
        -fno-rtti
        -fno-use-cxa-atexit
        -fno-threadsafe-statics>
    # Enable C preprocessor for .S assembly files
    $<$<COMPILE_LANGUAGE:ASM>:-x assembler-with-cpp>
)

target_link_options(K1921VK035 INTERFACE
    ${_K1921VK035_ARCH_FLAGS}
    LINKER:--gc-sections
    LINKER:--print-memory-usage
    -nostartfiles
)

target_compile_definitions(K1921VK035 INTERFACE
    K1921VK035
    "__weak=__attribute__((weak))"
    "__packed=__attribute__((__packed__))"
    # startup_K1921VK035.S calls `bl __START` which defaults to `_start` (newlib
    # C-runtime entry). Without newlib's crt0, `_start` is missing. Override it
    # to jump straight to main() for bare-metal builds.
    __START=main
)
