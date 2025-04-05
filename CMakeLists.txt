cmake_minimum_required(VERSION 3.16.3)

#Note this line must be before project!
set(CMAKE_TOOLCHAIN_FILE ./cc65-toolchain.cmake)

project(os-816 ASM)
set(executable_name ${CMAKE_PROJECT_NAME})

add_executable(${executable_name})
target_compile_options(${executable_name} PUBLIC
    -C ${CMAKE_SOURCE_DIR}/memory.cfg
    -Wa --cpu,65816,-I,${CMAKE_SOURCE_DIR}/src
)
target_link_options(${executable_name} PUBLIC
    -C ${CMAKE_SOURCE_DIR}/memory.cfg
    -Ln ${CMAKE_CURRENT_BINARY_DIR}/${executable_name}.lbl
    --mapfile ${CMAKE_CURRENT_BINARY_DIR}/${executable_name}.map
    -Wl --dbgfile,${CMAKE_CURRENT_BINARY_DIR}/${executable_name}.dbg
)
set_target_properties(${executable_name} PROPERTIES
    OUTPUT_NAME ${executable_name} SUFFIX ".xex"
)
target_sources(${executable_name} PRIVATE
    src/boot.asm
    src/kernel/main.asm
    src/kernel/task.asm
    src/kernel/sched.asm
    src/kernel/sys.asm
    src/kernel/isr.asm
    src/kernel/cio.asm
    src/kernel/uart.asm
    src/dev/init.asm
    src/dev/S.asm
    src/dev/K.asm
    src/dev/E.asm
    src/hw/dspl.asm
    src/shell/main.asm
    src/shell/errors.asm
    src/shell/cmds.asm
)

install(TARGETS ${executable_name})
