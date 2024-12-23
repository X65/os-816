cmake_minimum_required(VERSION 3.16.3)

#Note this line must be before project!
set(CMAKE_TOOLCHAIN_FILE ./cc65-toolchain.cmake)

project(os-816 ASM)
set(executable_name ${CMAKE_PROJECT_NAME}.xex)

add_executable(${executable_name})
target_link_options(${executable_name} PUBLIC
   -C ${CMAKE_CURRENT_SOURCE_DIR}/memory.cfg
   -Ln ${CMAKE_CURRENT_BINARY_DIR}/${executable_name}.lab
   --mapfile ${CMAKE_CURRENT_BINARY_DIR}/${executable_name}.map
)
target_sources(${executable_name} PRIVATE
   src/boot.s
   src/hello.s
)

install(TARGETS ${executable_name})
