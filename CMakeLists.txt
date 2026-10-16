cmake_minimum_required(VERSION 3.16.3)

#Note this line must be before project!
set(CMAKE_TOOLCHAIN_FILE ./cc65-toolchain.cmake)

project(os-816 ASM)
set(executable_name ${CMAKE_PROJECT_NAME})

add_executable(${executable_name})
target_compile_options(${executable_name} PUBLIC
    -C ${CMAKE_SOURCE_DIR}/memory.cfg
    --cpu 65816
    --asm-include-dir ${CMAKE_SOURCE_DIR}/src
)
target_include_directories(${executable_name} PUBLIC
    ${CMAKE_SOURCE_DIR}/src
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
    src/boot.kk
    src/macros.kk
    src/generic.kk
    src/errors.kk
    src/kernel/api.kk
    src/kernel/main.kk
    src/kernel/task.kk
    src/kernel/sched.kk
    src/kernel/sys.kk
    src/kernel/isr.kk
    src/kernel/cio.kk
    src/kernel/uart.kk
    src/kernel/util.kk
    src/kernel/dbg.kk
    src/dev/dev.kk
    src/dev/init.kk
    src/dev/S.kk
    src/dev/K.kk
    src/dev/E.kk
    src/hw/cgia.kk
    src/hw/ria.kk
    src/hw/dspl.kk
    src/shell/main.kk
    src/shell/errors.kk
    src/shell/cmds.kk
    src/shell/print.kk
)

install(TARGETS ${executable_name})
