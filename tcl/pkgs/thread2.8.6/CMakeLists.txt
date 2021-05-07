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

project(TEA-Thread
        VERSION 2.8.6
        LANGUAGES C
        )

## Options #####################################################################
option(TEA_THREADS_ENABLE_TESTS
       "Enable running tests for the thread library [On]" On
       )
option(TEA_ENABLE_THREAD
       "Enable building the thread extension library [On]" On
       )

if (NOT TEA_ENABLE_THREAD)
    return()
endif ()

## Target ######################################################################
add_library(tea_thread SHARED
            src/psGdbm.h src/psGdbm.c
            src/psLmdb.h src/psLmdb.c
            src/tclXkeylist.h src/tclXkeylist.c
            src/threadCmd.c
            src/threadNs.c
            src/threadPoolCmd.c
            src/threadSpCmd.h src/threadSpCmd.c
            src/threadSvCmd.h src/threadSvCmd.c
            src/threadSvKeylistCmd.h src/threadSvKeylistCmd.c
            src/threadSvListCmd.h src/threadSvListCmd.c

            src/tclThread.h
            src/tclThreadInt.h

            $<$<PLATFORM_ID:Windows>:${CMAKE_CURRENT_BINARY_DIR}/thread.rc>
            )

target_compile_definitions(tea_thread PRIVATE
                           BUILD_thread=1
                           USE_TCL_STUBS=1
                           USE_TCLOO_STUBS=1
                           TCL_TIP143=1
                           TCL_TIP285=1
                           TCL_NO_DEPRECATED=1
                           )

target_link_libraries(tea_thread PRIVATE
                      tclstub
                      )

target_include_directories(tea_thread PUBLIC
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
                           $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/tcl${TCL_DOUBLE_VERSION}/thread>
                           )

string(REPLACE "." "" TEA_THREAD_DOTLESS_VERSION "${PROJECT_VERSION}")
set_target_properties(tea_thread PROPERTIES
                      PREFIX ""
                      OUTPUT_NAME "thread${TEA_THREAD_DOTLESS_VERSION}"
                      )

## Configuration ###############################################################
set(PACKAGE_NAME "thread")
set(PACKAGE_VERSION "${PROJECT_VERSION}")
set(PKG_LIB_FILE "thread${TEA_THREAD_DOTLESS_VERSION}${CMAKE_SHARED_LIBRARY_SUFFIX}")
string(REPLACE "." "," TEA_THREAD_COMMA_VERSION "${PROJECT_VERSION}")
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(DEBUG 1)
endif ()
configure_file(pkgIndex.tcl.in
               pkgIndex.tcl
               @ONLY
               )
configure_file(src/thread.rc.in
               thread.rc
               @ONLY
               )

## Tests #######################################################################
add_subdirectory(tests)

## Install #####################################################################
#&!off
tcl_install(RUNTIME_ONLY
                TARGETS tea_thread
                    RUNTIME DESTINATION "${CMAKE_INSTALL_LIBDIR}/thread${PROJECT_VERSION}"
                FILES "${CMAKE_CURRENT_BINARY_DIR}/pkgIndex.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/tcl/ttrace.tcl"
                    DESTINATION "${TCL_INSTALL_LIBDIR}/thread${PROJECT_VERSION}"
            DEFAULT
                TARGETS tea_thread
                    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}/thread${PROJECT_VERSION}"
            DEVELOPMENT
                FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/tclThread.h"
                    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
            )
#&!on
