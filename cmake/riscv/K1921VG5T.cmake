# K1921VG5T — RISC-V 32IMFC_Zicsr_Zifencei (Syntacore SCR1-based)
# Usage in project CMakeLists.txt (before project()):
#   set(CMAKE_DIR path/to/dependencies/cmake)
#   include(${CMAKE_DIR}/riscv/K1921VG5T.cmake)
#   include(${CMAKE_DIR}/common.cmake)
#   project(my_project C ASM)
#   ...
#   target_link_libraries(my_target PRIVATE niietsdk K1921VG5T NANO NOSYS)
#   gcc_add_linker_script(my_target PRIVATE ${K1921VG5T_LD_SCRIPT})

include(${CMAKE_CURRENT_LIST_DIR}/../toolchain/riscv32-unknown-elf.cmake)

# ISA: rv32imafdc (toolchain default: --with-arch=rv32gc, 20191213 spec includes zicsr+zifencei)
set(MCU_ARCH   rv32imafdc)
# ABI: ilp32d (toolchain default: --with-abi=ilp32d; multilib disabled, must match libraries)
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
    -Wno-aggressive-loop-optimizations
    -Os
    -flto
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
    -flto
    -Wl,--gc-sections
    -Wl,--print-memory-usage
    -nostartfiles
)

target_compile_definitions(K1921VG5T INTERFACE
    K1921VG5T
    "__weak=__attribute__((weak))"
    "__packed=__attribute__((__packed__))"
)
