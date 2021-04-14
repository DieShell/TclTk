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

## This file checks for the existence of the POSIX "{open,close,read}dir"
# functions in the dirent.h header.
# If this is not found we try the old BSD "sys/dir.h" with the same functions
# but a different struct name (struct direht -> struct direct)
# If all else fails we provide a backup, and hope it works

## Helper functions ############################################################
function(tcl_dirio_posix _have_posix)
    set(${_have_posix} 0 PARENT_SCOPE)

    cmake_push_check_state(RESET)
    check_include_file("dirent.h" HAVE_DIRENT_H)
    list(APPEND CMAKE_EXTRA_INCLUDE_FILES "dirent.h")

    if (HAVE_DIRENT_H)
        check_type_size("DIR*" POSIX_DIR)
        check_type_size("struct dirent" POSIX_DIRENT)

        if (HAVE_POSIX_DIR
            AND HAVE_POSIX_DIRENT)
            check_symbol_exists("opendir"  "dirent.h" HAVE_POSIX_OPENDIR)
            check_symbol_exists("closedir" "dirent.h" HAVE_POSIX_CLOSEDIR)
            check_symbol_exists("readdir"  "dirent.h" HAVE_POSIX_READDIR)

            if (HAVE_POSIX_OPENDIR
                AND HAVE_POSIX_CLOSEDIR
                AND HAVE_POSIX_READDIR)
                set(${_have_posix} 1 PARENT_SCOPE)
            endif ()
        endif ()
    endif ()

    cmake_pop_check_state()
endfunction ()

function(tcl_dirio_bsd _have_bsd)
    set(${_have_bsd} 0 PARENT_SCOPE)

    cmake_push_check_state(RESET)
    check_include_file("sys/dir.h" HAVE_SYS_DIR_H)
    list(APPEND CMAKE_EXTRA_INCLUDE_FILES "sys/dir.h")

    if (HAVE_SYS_DIR_H)
        check_type_size("DIR*" BSD_DIR)
        check_type_size("struct direct" BSD_DIRECT)

        if (HAVE_BSD_DIR
            AND HAVE_BSD_DIRECT)
            check_symbol_exists("opendir"  "sys/dir.h" HAVE_BSD_OPENDIR)
            check_symbol_exists("closedir" "sys/dir.h" HAVE_BSD_CLOSEDIR)
            check_symbol_exists("readdir"  "sys/dir.h" HAVE_BSD_READDIR)

            if (HAVE_BSD_OPENDIR
                AND HAVE_BSD_CLOSEDIR
                AND HAVE_BSD_READDIR)
                set(${_have_bsd} 1 PARENT_SCOPE)
            endif ()
        endif ()
    endif ()

    cmake_pop_check_state()
endfunction ()

## Actual code #################################################################
if (WIN32)
    # nothing to do on Windows
    return ()
endif ()

tcl_dirio_posix(HAVE_POSIX_DIR_IO)
if (NOT HAVE_POSIX_DIR_IO)

    tcl_dirio_bsd(HAVE_BSD_DIR_IO)
    if (HAVE_BSD_DIR_IO)
        # BSD style directory io
        target_include_directories(tcl_config INTERFACE
                                   $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/dirent_bsd>
                                   $<INSTALL_INTERFACE:include>
                                   )
        target_compile_definitions(tcl_config INTERFACE NO_DIRENT_H=1)

        # handle extra header install
        if (TCL_ENABLE_INSTALL_DEVELOPMENT)
            install(FILES
                    "${CMAKE_CURRENT_SOURCE_DIR}/src/dirent_bsd/compat/dirent.h"
                    DESTINATION
                    "${CMAKE_INSTALL_INCLUDEDIR}/tcl${TCL_DOUBLE_VERSION}/generic/compat"
                    )
        endif ()
    else ()
        # all hope is lost
        target_include_directories(tcl_config INTERFACE
                                   $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/dirent_severe>
                                   $<INSTALL_INTERFACE:include>
                                   )
        target_sources(tcl PRIVATE
                       src/dirent_severe/opendir.c
                       )

        set(TCL_COMPAT_FILES
            "${TCL_COMPAT_FILES};src/dirent_severe/opendir.c"
            CACHE INTERNAL "" FORCE)
        target_compile_definitions(tcl_config INTERFACE USE_DIRENT2_H=1)

        # handle extra header install
        if (TCL_ENABLE_INSTALL_DEVELOPMENT)
            install(FILES
                    "${CMAKE_CURRENT_SOURCE_DIR}/src/dirent_severe/compat/dirent2.h"
                    DESTINATION
                    "${CMAKE_INSTALL_INCLUDEDIR}/tcl${TCL_DOUBLE_VERSION}/generic/compat"
                    )
        endif ()
    endif ()
endif ()


