set(CMAKE_CXX_STANDARD 17)
set(CMAKE_C_STANDARD 11)

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    add_link_options(-static-libgcc)
    add_link_options(-static-libstdc++)
endif()

# Debug builds: use -Og (optimize for debugging) instead of CMake default -O0.
# -O0 bloats the size-constrained ESC bootloader far beyond its 4KB slot.
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_compile_options(-Og)
endif()

# Shared ESC linker fragments (esc_sectors.ld) are included by name (INCLUDE esc_sectors.ld),
# so expose their directory via the linker search path. Keeps build dir depth-independent.
link_directories(${CMAKE_CURRENT_LIST_DIR}/../common/esc)

include(${CMAKE_CURRENT_LIST_DIR}/optimization.cmake)