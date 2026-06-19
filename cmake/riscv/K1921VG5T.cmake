# K1921VG5T — RISC-V 32IMAC
# Usage in project CMakeLists.txt (before project()):
#   set(CMAKE_DIR path/to/dependencies/cmake)
#   include(${CMAKE_DIR}/riscv/K1921VG5T.cmake)
#   include(${CMAKE_DIR}/common.cmake)
#   project(my_project C ASM)
#   ...
#   target_link_libraries(my_target PRIVATE niietsdk K1921VG5T NANO NOSYS)
#   gcc_add_linker_script(my_target PRIVATE ${K1921VG5T_LD_SCRIPT})

include(${CMAKE_CURRENT_LIST_DIR}/../toolchain/riscv-none-embed.cmake)

set(MCU_ARCH   rv32imac)
set(MCU_ABI    ilp32)

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

target_compile_options(K1921VG5T INTERFACE
    ${_K1921VG5T_ARCH_FLAGS}
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

target_link_options(K1921VG5T INTERFACE
    ${_K1921VG5T_ARCH_FLAGS}
    LINKER:--gc-sections
    LINKER:--print-memory-usage
    -nostartfiles
)

target_compile_definitions(K1921VG5T INTERFACE
    K1921VG5T
    "__weak=__attribute__((weak))"
    "__packed=__attribute__((__packed__))"
    # startup_k1921vg5t.S calls `bl __START` which defaults to `_start` (newlib
    # C-runtime entry). Without newlib's crt0, `_start` is missing. Override it
    # to jump straight to main() for bare-metal builds.
    __START=main
)