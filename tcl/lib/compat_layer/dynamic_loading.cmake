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

# Provides the source file for dynamic linking and loading. If this file cannot
# provide a sensible way to hande dynamic linking the system is believed to be
# unable to load libraries dynamically.

cmake_push_check_state(RESET)

## POSIX - dlfcn.h #############################################################
# If we have dlfcn.h, no need to do anything else

check_include_file("dlfcn.h" HAVE_DLFCN_H)
if (HAVE_DLFCN_H)
    target_link_libraries(tcl PRIVATE ${CMAKE_DL_LIBS})
    set(TCL_LIBS "${TCL_LIBS};${CMAKE_DL_LIBS}" CACHE INTERNAL "")
endif ()

if (HAVE_DLFCN_H AND NOT APPLE) # apple is special
    target_sources(tcl PRIVATE
                   src/dynamic/tclLoadDl.c
                   )
    return ()
endif ()

if (NOT HAVE_DLFCN_H)
    target_compile_definitions(tcl_config INTERFACE NO_DLFCN_H)
endif ()

## AIX - sys/ldr.h #############################################################
# AIX is a special beast, because instead of using platform API, we implement
# the dlopen, etc, functions, and then use those.

check_include_file("sys/ldr.h" HAVE_SYS_LDR_H)
check_include_file("ldfcn.h"   HAVE_LDFCN_H)
check_include_file("a.out.h"   HAVE_A_OUT_H)

if (HAVE_SYS_LDR_H AND HAVE_LDFCN_H AND HAVE_A_OUT_H)
    target_sources(tcl PRIVATE
                   src/dynamic/tclLoadAix.c
                   src/dynamic/tclLoadDl.c
                   )

    #&!off
    tcl_install(DEVELOPMENT
                    FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/dynamic/dlfcn.h"
                        DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/tcl${TCL_DOUBLE_VERSION}/generic/"
                )
    #&!on
    return ()
endif ()

## MacOS - mach-o/dyld.h #######################################################
# MacOS is funky: if we are below 10.4 we use the deprecated
# TCL_DYLD_USE_NSMODULE, otherwise we just use POSIX dlfcn.h's dlopen, et al.

if (APPLE)
    target_sources(tcl PRIVATE
                   src/dynamic/tclLoadDyld.c
                   )
    if (NOT HAVE_DLFCN_H) # old things
        target_compile_definitions(tcl PRIVATE
                                   TCL_DYLD_USE_NSMODULE=1
                                   )
    endif ()
    return ()
endif ()

## NeXT - mach-o/rld.h #########################################################
# NeXT provides rld_load, etc functions for dynamic libraries

check_include_file("mach-o/rld.h"      HAVE_MACH_O_RLD_H)
check_include_file("streams/streams.h" HAVE_STREAMS_STREAMS_H)

if (HAVE_MACH_O_RLD_H AND HAVE_STREAMS_STREAMS_H)
    target_sources(tcl PRIVATE
                   src/dynamic/tclLoadNext.c
                   )
    return ()
endif ()

## OSF/1 - loader.h ############################################################
# Old OSF/1 didn't use ELF and the dl* functions. Implementation uses
# loader.h and load().

check_include_file("loader.h" HAVE_LOADER_H)

if (HAVE_LOADER_H)
    target_sources(tcl PRIVATE
                   src/dynamic/tclLoadOSF.c
                   )
    return ()
endif ()

## HP-UX - dl.h ################################################################
# HP-UX provides shl_* functions in the dl.h header.

check_include_file("dl.h" HAVE_DL_H)

if (HAVE_DL_H)
    target_sources(tcl PRIVATE
                   src/dynamic/tclLoadShl.c
                   )
    return ()
endif ()

## Windows - windows.h #########################################################
# Windows provides LoadLibrary(Ex)(A|W) in windows.h (or some other header
# included in windows.h)

list(APPEND CMAKE_REQUIRED_DEFINITIONS "-DWIN32_LEAN_AND_MEAN=1")
check_include_file("windows.h" HAVE_WINDOWS_H)

if (HAVE_WINDOWS_H)
    target_sources(tcl PRIVATE
                   src/dynamic/tclWinLoad.c
                   )
    return()
endif ()

## We do not have dynamic linking ##############################################
# ¯\_(ツ)_/¯

message(STATUS "System seems unable to dynamically load libraries. Disabling \"load\" support.")
target_sources(tcl PRIVATE
               src/dynamic/tclLoadNone.c
               )

cmake_pop_check_state()
