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


## Target ######################################################################
add_library(tea_thread SHARED
            src/psGdbm.h             src/common/psGdbm.c
            src/psLmdb.h             src/common/psLmdb.c
            src/tclXkeylist.h        src/common/tclXkeylist.c
                                     src/threadCmd.c
                                     src/threadNs.c
                                     src/threadPoolCmd.c
            src/threadSpCmd.h        src/common/threadSpCmd.c
            src/threadSvCmd.h        src/common/threadSvCmd.c
            src/threadSvKeylistCmd.h src/common/threadSvKeylistCmd.c
            src/threadSvListCmd.h    src/common/threadSvListCmd.c

            src/tclThread.h
            src/tclThreadInt.h

            $<$<PLATFORM_ID:Windows>:src/thread.rc>
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

message("TEA: Thread ${PROJECT_VERSION}")
string(REPLACE "." "" TEA_THREAD_DOTLESS_VERSION "${PROJECT_VERSION}")
set_target_properties(tea_thread PROPERTIES
                      PREFIX ""
                      OUTPUT_NAME "thread${TEA_THREAD_DOTLESS_VERSION}"
                      )
#
string(REPLACE "." "," TEA_THREAD_COMMA_VERSION "${PROJECT_VERSION}")
set(PKG_LIB_FILE "thread${TEA_THREAD_DOTLESS_VERSION}${CMAKE_SHARED_LIBRARY_SUFFIX}")
set(THREAD_RC_DEFINES 
    "DOTVERSION=\"${PROJECT_VERSION}\"\\0"
    "COMMAVERSION=${TEA_THREAD_COMMA_VERSION},0"
    "PRJLIBNAME=\"${PKG_LIB_FILE}\\0\""
    "$<$<CONFIG:Debug>:DEBUG=1>"
    )
set_source_files_properties(src/win32/thread.rc 
                            TARGET_DIRECTORY tea_thread
                            PROPERTIES
                                COMPILE_DEFINITIONS "${THREAD_RC_DEFINES}"
                            )

## Configuration ###############################################################
set(PACKAGE_NAME    "thread")
set(PACKAGE_VERSION "${PROJECT_VERSION}")
configure_file(pkgIndex.tcl.in
               pkgIndex.tcl
               @ONLY
               )

## Install #####################################################################
if (TCL_ENABLE_INSTALL)
    install(TARGETS tea_thread
            DESTINATION "${CMAKE_INSTALL_LIBDIR}/thread${PROJECT_VERSION}"
            )
    install(FILES 
            "${CMAKE_CURRENT_BINARY_DIR}/pkgIndex.tcl"
            "${CMAKE_CURRENT_SOURCE_DIR}/tcl/ttrace.tcl"
            DESTINATION
            "${CMAKE_INSTALL_LIBDIR}/thread${PROJECT_VERSION}"
            )
endif ()
