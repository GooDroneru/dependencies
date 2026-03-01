add_library(CH32V INTERFACE IMPORTED)

# Always print memory usage after linking
target_link_libraries(CH32V INTERFACE GCC::PrintMemoryUsage)

# Architecture + ABI flags (also needed at link time)
set(COMMON_COMPILE_FLAGS
    -march=${MCU_ARCH}
    -mabi=${MCU_INTEGER_ABI}
    -msmall-data-limit=8
)

# C/C++ compile-only flags
set(C_CXX_COMPILE_FLAGS
    -ffunction-sections
    -fdata-sections
    -fsigned-char
    -fmessage-length=0
    -msave-restore
)

# Architecture flags for all languages
target_compile_options(CH32V INTERFACE
    --sysroot="${TOOLCHAIN_SYSROOT}"
    ${COMMON_COMPILE_FLAGS}
)

target_compile_options(CH32V INTERFACE
    $<$<COMPILE_LANGUAGE:C>:${C_CXX_COMPILE_FLAGS}>
    $<$<COMPILE_LANGUAGE:CXX>:${C_CXX_COMPILE_FLAGS}>
)

# C++ specific: disable heavy runtime features
target_compile_options(CH32V INTERFACE
    $<$<COMPILE_LANGUAGE:CXX>:-fno-exceptions -fno-rtti -fno-use-cxa-atexit -fno-threadsafe-statics>
)

# ASM: enable C preprocessor for .S files
target_compile_options(CH32V INTERFACE
    $<$<COMPILE_LANGUAGE:ASM>:-x assembler-with-cpp>
)

# Linker: only architecture flags + linker-specific options
target_link_options(CH32V INTERFACE
    --sysroot="${TOOLCHAIN_SYSROOT}"
    ${COMMON_COMPILE_FLAGS}
    LINKER:-gc-sections
    -nostartfiles
)

target_compile_definitions(CH32V INTERFACE
    "__weak=__attribute__((weak))"
    "__packed=__attribute__((__packed__))"
    CH32V
)