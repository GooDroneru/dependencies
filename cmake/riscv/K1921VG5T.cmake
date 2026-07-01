# K1921VG5T — RISC-V 32IMFD_Zicsr_Zifencei (Syntacore SCR4)
# Usage in project CMakeLists.txt (before project()):
#   set(CMAKE_DIR path/to/dependencies/cmake)
#   include(${CMAKE_DIR}/riscv/K1921VG5T.cmake)
#   include(${CMAKE_DIR}/common.cmake)
#   project(my_project C ASM)
#   ...
#   target_link_libraries(my_target PRIVATE niietsdk K1921VG5T NANO NOSYS)
#   gcc_add_linker_script(my_target PRIVATE ${K1921VG5T_LD_SCRIPT})

include(${CMAKE_CURRENT_LIST_DIR}/../toolchain/riscv-none-embed.cmake)

# ISA: rv32i base + m f d _zicsr _zifencei + c (compressed)
set(MCU_ARCH   rv32imfd_zicsr_zifencei)
# ABI: ilp32 + d (double floating point)
set(MCU_ABI    ilp32d)

# Default linker script shipped with niietsdk. Projects can override this variable.
set(K1921VG5T_LD_SCRIPT
    "${CMAKE_CURRENT_LIST_DIR}/../../niietsdk/vg5t/Device/K1921VG5T/ldscripts/k1921vg5t_flash.ld"
    CACHE FILEPATH "Linker script for K1921VG5T"
)

message(STATUS "K1921VG5T linker script: ${K1921VG5T_LD_SCRIPT}")

# --------------------------------------------------------------------------
# INTERFACE library — attach to any executable to get MCU-specific flags
# --------------------------------------------------------------------------
add_library(K1921VG5T INTERFACE IMPORTED)

set(_K1921VG5T_ARCH_FLAGS
    -march=${MCU_ARCH}
    -mabi=${MCU_ABI}
)

# Platform include directories (relative to project root where this is included)
# These paths assume the project is structured like the k1921vg5t_sdk reference
target_include_directories(K1921VG5T INTERFACE
    "${CMAKE_CURRENT_LIST_DIR}/../../niietsdk/vg5t/Device/K1921VG5T/include"
)

target_compile_options(K1921VG5T INTERFACE
    ${_K1921VG5T_ARCH_FLAGS}
    -ffunction-sections
    -fdata-sections
    -fsigned-char
    -fmessage-length=0
    -fno-builtin
    -fno-common
    # C++ runtime overhead reduction
    $<$<COMPILE_LANGUAGE:CXX>:
        -fno-exceptions
        -fno-rtti
        -fno-use-cxa-atexit
        -fno-threadsafe-statics>
    # Enable C preprocessor for .S assembly files
    $<$<COMPILE_LANGUAGE:ASM>:-x assembler-with-cpp>
)

target_link_options(K1921VG5T INTERFACE
    ${_K1921VG5T_ARCH_FLAGS}
    -Wl,--gc-sections
    -Wl,--print-memory-usage
    -nostartfiles
    -nostdlib
    -lgcc
    -lc
)

target_compile_definitions(K1921VG5T INTERFACE
    K1921VG5T
    "__weak=__attribute__((weak))"
    "__packed=__attribute__((__packed__))"
    # Required by system_k1921vg5t.c for clock initialization
    HSECLK_VAL=16000000
    SYSCLK_PLL
    CKO_HSE
)
