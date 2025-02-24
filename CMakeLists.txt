cmake_minimum_required(VERSION 3.16.3)

#Note this line must be before project!
set(CMAKE_TOOLCHAIN_FILE ./cc65-toolchain.cmake)

project(os-816 ASM)
set(executable_name ${CMAKE_PROJECT_NAME})

add_executable(${executable_name})
target_compile_options(${executable_name} PUBLIC
    -C ${CMAKE_SOURCE_DIR}/memory.cfg
    -Wa --listing,${CMAKE_CURRENT_BINARY_DIR}/${executable_name}.lst,--cpu,65816
)
target_link_options(${executable_name} PUBLIC
    -C ${CMAKE_SOURCE_DIR}/memory.cfg
    -Ln ${CMAKE_CURRENT_BINARY_DIR}/${executable_name}.lab
    --mapfile ${CMAKE_CURRENT_BINARY_DIR}/${executable_name}.map
    -Wl --dbgfile,${CMAKE_CURRENT_BINARY_DIR}/${executable_name}.dbg
)
set_target_properties(${executable_name} PROPERTIES
    OUTPUT_NAME ${executable_name} SUFFIX ".xex"
)
target_sources(${executable_name} PRIVATE
    src/boot.asm
)

install(TARGETS ${executable_name})
