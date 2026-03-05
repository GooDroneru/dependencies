set(TOOLCHAIN_BIN_PATH "${TOOLCHAIN_DIR}/bin")
# Derive the toolchain binary prefix from the detected compiler if available
# e.g. if _GCC_EXE is /.../riscv64-unknown-elf-gcc then prefix -> "riscv64-unknown-elf-"
if(DEFINED _GCC_EXE)
    get_filename_component(_gcc_name "${_GCC_EXE}" NAME)
    string(REGEX REPLACE "gcc(\\.exe)?$" "" _prefix "${_gcc_name}")
    if(NOT _prefix MATCHES "-$")
        set(_prefix "${_prefix}-")
    endif()
    set(TOOLCHAIN_PREFIX "${_prefix}")
else()
    set(TOOLCHAIN_PREFIX "${CMAKE_LIBRARY_ARCHITECTURE}-")
endif()

set(TOOLCHAIN_INC_PATH "${TOOLCHAIN_DIR}/${CMAKE_LIBRARY_ARCHITECTURE}/include")
set(TOOLCHAIN_LIB_PATH "${TOOLCHAIN_DIR}/${CMAKE_LIBRARY_ARCHITECTURE}/lib")
set(TOOLCHAIN_SYSROOT  "${TOOLCHAIN_DIR}/${CMAKE_LIBRARY_ARCHITECTURE}")

if(WIN32)
    set(TOOLCHAIN_EXT ".exe")
else()
    set(TOOLCHAIN_EXT "")
endif()

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_C_COMPILER   ${TOOLCHAIN_BIN_PATH}/${TOOLCHAIN_PREFIX}gcc${TOOLCHAIN_EXT})
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_BIN_PATH}/${TOOLCHAIN_PREFIX}g++${TOOLCHAIN_EXT})
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_BIN_PATH}/${TOOLCHAIN_PREFIX}gcc${TOOLCHAIN_EXT})
set(CMAKE_CPPFILT      ${TOOLCHAIN_BIN_PATH}/${TOOLCHAIN_PREFIX}c++filt${TOOLCHAIN_EXT})
set(CMAKE_DEBUGGER     ${TOOLCHAIN_BIN_PATH}/${TOOLCHAIN_PREFIX}gdb${TOOLCHAIN_EXT})
set(CMAKE_OBJCOPY      ${TOOLCHAIN_BIN_PATH}/${TOOLCHAIN_PREFIX}objcopy${TOOLCHAIN_EXT})
set(CMAKE_OBJDUMP      ${TOOLCHAIN_BIN_PATH}/${TOOLCHAIN_PREFIX}objdump${TOOLCHAIN_EXT})
set(CMAKE_SIZE         ${TOOLCHAIN_BIN_PATH}/${TOOLCHAIN_PREFIX}size${TOOLCHAIN_EXT})
set(CMAKE_AS           ${TOOLCHAIN_BIN_PATH}/${TOOLCHAIN_PREFIX}as${TOOLCHAIN_EXT})
set(CMAKE_AR           ${TOOLCHAIN_BIN_PATH}/${TOOLCHAIN_PREFIX}ar${TOOLCHAIN_EXT})

set(CMAKE_EXECUTABLE_SUFFIX_C   .elf)
set(CMAKE_EXECUTABLE_SUFFIX_CXX .elf)
set(CMAKE_EXECUTABLE_SUFFIX_ASM .elf)

add_library(NOSYS INTERFACE IMPORTED)
target_link_options(NOSYS INTERFACE 
    -specs=nosys.specs
)

add_library(NANO INTERFACE IMPORTED)
target_link_options(NANO INTERFACE 
    -specs=nano.specs
)

add_library(GCC::PrintMemoryUsage INTERFACE IMPORTED)
target_link_options(GCC::PrintMemoryUsage INTERFACE
    -Xlinker --print-memory-usage
)

function(gcc_print_target_size TargetName)
    add_custom_command(
        TARGET ${TargetName}
        POST_BUILD
	    COMMAND ${CMAKE_COMMAND} -E echo "Invoking: GCC Print Size"
        COMMAND ${CMAKE_SIZE} ${TargetName}${CMAKE_EXECUTABLE_SUFFIX_C}
    )
endfunction()

function(gcc_generate_bin_file TargetName)
    add_custom_command(
        TARGET ${TargetName}
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo "Generating flash image ${TargetName}.bin"
        COMMAND ${CMAKE_OBJCOPY} -O binary ${TargetName}${CMAKE_EXECUTABLE_SUFFIX_C} ${TargetName}.bin
        BYPRODUCTS ${TargetName}.bin
    )
endfunction()


function(gcc_generate_hex_file TargetName)
    add_custom_command(
        TARGET ${TargetName}
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo "Generating flash image ${TargetName}.hex"
        COMMAND ${CMAKE_OBJCOPY} -O ihex ${TargetName}${CMAKE_EXECUTABLE_SUFFIX_C} ${TargetName}.hex
        BYPRODUCTS ${TargetName}.hex
    )
endfunction()


function(gcc_generate_srec_file TargetName)
    add_custom_command(
        TARGET ${TargetName}
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo "Generating flash image ${TargetName}.srec"
        COMMAND ${CMAKE_OBJCOPY} -O srec ${TargetName}${CMAKE_EXECUTABLE_SUFFIX_C} ${TargetName}.srec
        BYPRODUCTS ${TargetName}.srec
    )
endfunction()

function(gcc_add_linker_script TARGET VISIBILITY SCRIPT_PATH)
    get_filename_component(SCRIPT_PATH "${SCRIPT_PATH}" ABSOLUTE)
    target_link_options(${TARGET} ${VISIBILITY} -T "${SCRIPT_PATH}")
endfunction()

