set(CMAKE_CXX_STANDARD 17)
set(CMAKE_C_STANDARD 11)

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    add_link_options(-static-libgcc)
    add_link_options(-static-libstdc++)
endif()

include(${CMAKE_CURRENT_LIST_DIR}/optimization.cmake)