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

cmake_minimum_required(VERSION 3.16)

## CMake system setup ##########################################################
## Languages ##
enable_language(C)
set(CMAKE_C_STANDARD 89)

## Policies ##
cmake_policy(SET CMP0009 NEW) # Do not follow symlinks in GLOB_RECURSE
cmake_policy(SET CMP0048 NEW) # project sets VERSION vars
cmake_policy(SET CMP0070 NEW) # file(GENERATE) handles relative paths correctly
cmake_policy(SET CMP0083 NEW) # PIE
cmake_policy(SET CMP0091 NEW) # MSVC does not set the runtime library in CMAKE_<LANG>_FLAGS
cmake_policy(SET CMP0092 NEW) # MSVC does not set the default /W3 in CMAKE_<LANG>_FLAGS

## Modules #####################################################################
include(CMakePackageConfigHelpers)
include(CMakeDependentOption)
include(GNUInstallDirs)
include(CheckPIESupported)
include(CheckTypeSize)
include(CheckFunctionExists)
include(CheckSymbolExists)
include(CheckLibraryExists)
include(CheckStructHasMember)
include(CheckCSourceCompiles)
include(CMakePushCheckState)
include(CheckIncludeFile)
include(CheckIncludeFiles)
include(TestBigEndian)

## System cabaility checks #####################################################
# Position independent code #
check_pie_supported(LANGUAGES C)

# Whether we need to link to libm
cmake_push_check_state(RESET)
check_library_exists("m" "sin" "" HAVE_M)
cmake_pop_check_state()
if (HAVE_M)
    # if libm exist we want to link it to everything
    link_libraries(m)
    set(TCL_LIBS m CACHE INTERNAL "")
endif ()

# These are for the {tcl,tk,tdbc}Config.sh files
# AFAIK there is no way to make cmake give up this information, so we just assume
# and hope that it works out
if (MSVC)
    set(TCL_LD "link -dll -nologo $<$<CONFIG:Release>:-release> $<$<CONFIG:Release>:-ltcg>" CACHE INTERNAL "")
    set(TCL_AR "lib -nologo" CACHE INTERNAL "")
else ()
    # If not MSVC we assume UNIX compatible ar cr and cc -shared
    get_filename_component(CC_NAME "${CMAKE_C_COMPILER}" NAME CACHE)
    get_filename_component(AR_NAME "${CMAKE_AR}" NAME CACHE)
    set(TCL_LD "${CC_NAME} -shared" CACHE INTERNAL "")
    set(TCL_AR "${AR_NAME} cr" CACHE INTERNAL "")
endif ()

## Options #####################################################################
option(TCL_ENABLE_INSTALL
       "Enable the Tcl runtime install target [On]" On
       )
option(TCL_ENABLE_INSTALL_RUNTIME_ONLY
       "Do not install executables and static libraries [Off]" Off
       )
option(TCL_ENABLE_INSTALL_DEVELOPMENT
       "Enable install Tcl's development required files [Off]" Off
       )
option(TCL_BUILD_SHARED
       "Build Tcl's libtcl as a shared library [On]" On
       )
option(TCL_ENABLE_TK
       "Build Tcl's Tk package [On]" On
       )
option(TCL_ENABLE_STATIC_ZLIB
       "Build Tcl with a static zlib [On]" On
       )
# CMake is rather stupid with regards to target arch
# which makes this require manual intervention
option(TCL_BUILD_64BIT
       "Disable only if you are building for 32-bit [On]" On
       )
option(TCL_ENABLE_UNLOAD_DLLS
       "Enable Tcl's support for unloading DLL-s [On]" On
       )
option(TCL_ENABLE_THREADS
       "Enable Tcl's multi-threading support [On]" On
       )
option(TCL_ENABLE_TESTS
       "Enable tests using the tcltest driver [On]" On
       )
if (WIN32)
    set(TCL_WITH_ENCODING "cp1252" CACHE STRING
        "The encoding to use (--with-encoding=) [cp1252]"
        )
else ()
    set(TCL_WITH_ENCODING "iso8859-1" CACHE STRING
        "The encoding to use (--with-encoding=) [iso8859-1]"
        )
endif ()
if (TCL_ENABLE_INSTALL)
    set(TCL_INSTALL_TZDATA "auto" CACHE STRING
        "Enable installing tzdata if the system does not provide it (true/false/auto) [auto]"
        )
else ()
    set(TCL_INSTALL_TZDATA OFF CACHE INTERNAL "" FORCE)
endif ()

# Option based configurations
if (NOT DEFINED TCL_BUILD_TYPE)
    if (TCL_BUILD_SHARED)
        set(TCL_BUILD_TYPE "SHARED" CACHE INTERNAL "" FORCE)
    else ()
        set(TCL_BUILD_TYPE "STATIC" CACHE INTERNAL "" FORCE)
    endif ()
endif ()

if (NOT DEFINED TCL_INSTALL_TIMEZONE)
    if (TCL_INSTALL_TZDATA STREQUAL "auto")
        foreach (dir "/usr/share/zoneinfo"
                     "/usr/share/lib/zoneinfo"
                     "/usr/lib/zoneinfo")
            if ((EXISTS "${dir}/UTC")
                OR (EXISTS "${dir}/GMT"))
                set(TCL_INSTALL_TIMEZONE 1 CACHE INTERNAL "" FORCE)
                break ()
            endif ()
            set(TLC_INSTALL_TIMEZONE 0 CACHE INTERNAL "")
        endforeach ()
    elseif (TCL_INSTALL_TZDATA)
        set(TCL_INSTALL_TIMEZONE 1 CACHE INTERNAL "" FORCE)
    elseif (NOT TCL_INSTALL_TZDATA)
        set(TCL_INSTALL_TIMEZONE 0 CACHE INTERNAL "" FORCE)
    else ()
        message(FATAL_ERROR "Whether to install tzdata, \"${TCL_INSTALL_TZDATA}\" is not a valid value.")
    endif ()
endif ()

## Common project ##############################################################
project(TclTk
        VERSION 8.6.11
        LANGUAGES C
        )

set(TCL_VERSION       8.6)
string(REPLACE "." "" TCL_DOUBLE_VERSION "${TCL_VERSION}")
set(TCL_MAJOR_VERSION 8)
set(TCL_MINOR_VERSION 6)
set(TCL_PATCH_LEVEL   .11)
set(TCL_REG_VERSION   1.3)
string(REPLACE "." "" TCL_REG_DOTLESS "${TCL_REG_VERSION}")
set(TCL_DDE_VERSION   1.4)
string(REPLACE "." "" TCL_DDE_DOTLESS "${TCL_DDE_VERSION}")
set(TK_VERSION        ${TCL_VERSION})
string(REPLACE "." "" TK_DOUBLE_VERSION "${TK_VERSION}")
set(TK_MAJOR_VERSION  ${TCL_MAJOR_VERSION})
set(TK_MINOR_VERSION  ${TCL_MINOR_VERSION})
set(TK_PATCH_LEVEL    ${TCL_PATCH_LEVEL})

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT
   AND CMAKE_INSTALL_PREFIX MATCHES [[C:/Program Files( \(x86\))?]])
   set(CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}\\Tcl" CACHE PATH "..." FORCE)
endif()

## Tcl Install libdir ##########################################################
# Some platform install binaries into lib64, as they are, well, 64-bit binaries.
# Tcl, however, does not account for this and expects it's stuff to be installed
# in plain lib. To fix it, we install binaries into CMAKE_INSTALL_LIBDIR but for
# Tcl scripts and stdlib we use TCL_INSTALL_LIBDIR which is just lib.
set(TCL_INSTALL_LIBDIR lib)

## CTest support ###############################################################
# CTest needs to be included into the top-level CMakeLists.txt to be allowed
# to call ctest from the build directory
# Also this needs to happen before calling any add_test()
if (TCL_ENABLE_TESTS)
    message(STATUS "Enabling test support")
    set(TCL_TEST_LIBRARY "${CMAKE_BINARY_DIR}/lib/tcl${TCL_VERSION}" CACHE INTERNAL "")
    set(TCL8_TEST_LIBRARY "${CMAKE_BINARY_DIR}/lib/tcl${TCL_MAJOR_VERSION}" CACHE INTERNAL "")
    set(TK_TEST_LIBRARY "${CMAKE_BINARY_DIR}/lib/tk${TK_VERSION}" CACHE INTERNAL "")
    include(CTest)
endif ()

## Utilities ###################################################################
include(cmake/utils.cmake)

# Windows is funky with its subsystems
if (WIN32)
    set(TCL_EXE "WIN32")
endif ()

## Tcl #########################################################################
add_subdirectory(tcl)

## Tk ##########################################################################
if (TCL_ENABLE_TK)
    add_subdirectory(tk)
endif ()
