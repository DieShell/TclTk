# TclTk CMake project
#
# Copyright (c) 2021, András Bodor <bodand@pm.me>
#
# This software is provided 'as-is', without any express or implied
# warranty.  In no event will the authors be held liable for any damages
# arising from the use of this software.
# 
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
# 
# 1. The origin of this software must not be misrepresented; you must not
#    claim that you wrote the original software. If you use this software
#    in a product, an acknowledgment in the product documentation would be
#    appreciated but is not required.
# 2. Altered source versions must be plainly marked as such, and must not be
#    misrepresented as being the original software.
# 3. This notice may not be removed or altered from any source distribution.

file(STRINGS "src/tdbc.h" TDBC_H_VERSION_LINE
     REGEX [[TDBC_VERSION]]
     )
string(REGEX REPLACE [[.*"([0-9]+\.[0-9]+\.[0-9]+)".*]] "\\1" TDBC_VERSION
       "${TDBC_H_VERSION_LINE}"
       )
set(TDBC_VERSION ${TDBC_VERSION} CACHE INTERNAL "" FORCE)
project(TEA-TDBC
        VERSION ${TDBC_VERSION}
        LANGUAGES C
        )

## Options #####################################################################
option(TEA_TDBC_ENABLE_THREADS 
       "Enable the use of threads in TEA TDBC [${TEA_USE_THREADS}]" "${TEA_USE_THREADS}"
       )
option(TEA_TDBC_BUILD_SHARED 
       "Build TEA TDBC as a shared library [On]" On
       )

# Option integrity checks
if (NOT TEA_TDBC_ENABLE_THREADS
    AND TCL_ENABLE_THREADS)
        message(SEND_ERROR 
"A non-threaded extension may only run in a non-threaded Tcl core.
Reconfigure with TCL_ENABLE_THREADS=0, or TEA_SQLITE_ENABLE_THREADS=1"
            )
endif ()

# Config based on options
if (NOT DEFINED TEA_TDBC_BUILD_TYPE)
    if (TEA_TDBC_BUILD_SHARED)
        set(TEA_TDBC_BUILD_TYPE "SHARED" CACHE INTERNAL "" FORCE)
    else ()
        set(TEA_TDBC_BUILD_TYPE "STATIC" CACHE INTERNAL "" FORCE)
    endif ()
endif ()

## Target ######################################################################
add_library(tea_tdbc "${TEA_TDBC_BUILD_TYPE}"
            src/tdbc.c
            src/tdbcStubInit.c
            src/tdbcTokenize.c
            src/tdbc.h
            src/tdbcInt.h
            src/tdbcDecls.h
            $<$<PLATFORM_ID:Windows>:${CMAKE_CURRENT_BINARY_DIR}/tdbc.rc>
            )
add_library(tea_tdbcstub STATIC 
            src/tdbcStubLib.c
            )
add_library(tea_tdbc_config INTERFACE)

target_link_libraries(tea_tdbc     PRIVATE tea_tdbc_config)
target_link_libraries(tea_tdbcstub PRIVATE tea_tdbc_config)

target_compile_definitions(tea_tdbc PRIVATE 
                           PACKAGE_NAME="tdbc"
                           PACKAGE_VERSION="${TDBC_VERSION}"
                           )
target_compile_definitions(tea_tdbcstub PRIVATE 
                           PACKAGE_NAME="tdbc"
                           PACKAGE_VERSION="${TDBC_VERSION}"
                           )
target_compile_definitions(tea_tdbc_config INTERFACE
                           BUILD_tdbc=1
                           USE_TCL_STUBS=1
                           USE_TCLOO_STUBS=1
                           MODULE_SCOPE=extern
                           )
target_link_libraries(tea_tdbc_config INTERFACE
                      tclstub
                      )

string(REPLACE "." "" TDBC_DOTLESS_VERSION "${TDBC_VERSION}")
string(REPLACE "." "," TDBC_COMMA_VERSION "${TDBC_VERSION}")
set_target_properties(tea_tdbc PROPERTIES
                      PREFIX ""
                      OUTPUT_NAME "tdbc${TDBC_DOTLESS_VERSION}"
                      )
set_target_properties(tea_tdbcstub PROPERTIES
                      OUTPUT_NAME "tdbcstub${TDBC_DOTLESS_VERSION}"
                      )
set_source_files_properties(${CMAKE_CURRENT_BINARY_DIR}/tdbc.rc 
                            TARGET_DIRECTORY tea_tdbc
                            PROPERTIES
                                COMPILE_DEFINITIONS "$<$<CONFIG:Debug>:DEBUG>"
                            )

## Configuration ###############################################################
set(TCL_VERSION_REQ     "8.5-")
set(TCL_VERSION_DESIRED "${TCL_VERSION}")
set(TCLOO_VERSION_REQ   "1.0")
set(PACKAGE_NAME        "tdbc")
set(PACKAGE_VERSION     "${TDBC_VERSION}")
set(PKG_LIB_FILE        "tdbc${TDBC_DOTLESS_VERSION}${CMAKE_SHARED_LIBRARY_SUFFIX}")
configure_file(pkgIndex.tcl.in
               pkgIndex.tcl
               @ONLY
               )
configure_file(src/tdbc.rc.in
               tdbc.rc
               @ONLY
               )

## Install #####################################################################
if (TCL_ENABLE_INSTALL)
    install(TARGETS tea_tdbc tea_tdbcstub
            DESTINATION "${CMAKE_INSTALL_LIBDIR}/tdbc${TDBC_VERSION}"
            )
    install(FILES 
            "${CMAKE_CURRENT_BINARY_DIR}/pkgIndex.tcl"
            "${CMAKE_CURRENT_SOURCE_DIR}/tcl/tdbc.tcl"
            DESTINATION
            "${CMAKE_INSTALL_LIBDIR}/tdbc${TDBC_VERSION}"
            )
endif ()
