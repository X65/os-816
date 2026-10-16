# CMake toolchain file for cc65
# https://github.com/jviskari/cc65_cmake by Joonas Viskari
# This is largely a result of experimentation, so some things may be done
# suboptimally/wrong. Some compilation options/CMake features may not work.
# Some generators will also not work (like MSVS). Ninja has been tested to work.
# What is supported: C, assembly, static libraries

set( CMAKE_SYSTEM_NAME Generic )

macro( __compilerCc65 lang )
    set( CMAKE_${lang}_COMPILER cl65 CACHE PATH "${lang} compiler" )
    set( CMAKE_${lang}_COMPILER_ID cc65 )

    # We cannot run tests for the cc65 compiler, because of cross-compilation,
    # so force the compiler tests to passed.
    set( CMAKE_${lang}_COMPILER_ID_RUN TRUE )
    # Don't know if these are necessary.
    set( CMAKE_${lang}_COMPILER_ID_WORKS TRUE )
    set( CMAKE_${lang}_COMPILER_ID_FORCED TRUE )

    # ca65/cc65 write a make-style depfile listing every import, but the
    # generators only reach for it once the format is declared as well - without
    # that CMake falls back to its own scanner, which looks for #include and so
    # sees none of the .kk imports: editing a shared import (ria.kk, cgia.kk...)
    # would rebuild nothing that imports it.
    set( CMAKE_DEPFILE_FLAGS_${lang} "--create-dep <DEP_FILE>")
    if( (NOT DEFINED CMAKE_DEPENDS_USE_COMPILER OR CMAKE_DEPENDS_USE_COMPILER)
        AND CMAKE_GENERATOR MATCHES "Makefiles|WMake" )
        set( CMAKE_${lang}_DEPENDS_USE_COMPILER TRUE )
    endif()
    set( CMAKE_${lang}_DEPFILE_FORMAT gcc )
    set( CMAKE_${lang}_VERBOSE_FLAG "-v" )
    set( CMAKE_${lang}_FLAGS_DEBUG_INIT "-g -D DEBUG --asm-define DEBUG"  )
endmacro()

__compilerCc65( C )
__compilerCc65( ASM )

set( CMAKE_ASM_SOURCE_FILE_EXTENSIONS s;asm;k65;k816;kk )

# Write a listing next to every object (<OBJECT>.lst) - a per-target listing
# would be overwritten by each source file in turn.
set( CMAKE_ASM_COMPILE_OBJECT
    "<CMAKE_ASM_COMPILER> <DEFINES> <INCLUDES> <FLAGS> --listing <OBJECT>.lst -o <OBJECT> -c <SOURCE>"
)

# Not sure why CMake by default looks for the compilers, but not the archiver.
# Force it to try to find the archiver.
find_program( CMAKE_AR ar65 )

# \note Need to delete the old file first because ar65 can only add files
#       into an archive (or remove named files, but we don't know the names).
set( CMAKE_C_CREATE_STATIC_LIBRARY
    "<CMAKE_COMMAND> -E remove <TARGET> "
    "<CMAKE_AR> a <TARGET> <LINK_FLAGS> <OBJECTS>"
)
set( CMAKE_ASM_CREATE_STATIC_LIBRARY ${CMAKE_C_CREATE_STATIC_LIBRARY} )
