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

file(STRINGS "src/compat/sqlite3/sqlite3.h" SQLITE3_H_VERSION_LINE
     REGEX [[SQLITE_VERSION]]
     )
string(REGEX REPLACE [[.*"([0-9]+\.[0-9]+\.[0-9]+)".*]] "\\1" SQLITE_VERSION
       "${SQLITE3_H_VERSION_LINE}"
       )
project(TEA-SQLite
        VERSION ${SQLITE_VERSION}
        LANGUAGES C
        )

## Options #####################################################################
option(TEA_SQLITE_ENABLE_THREADS
       "Enable the use of threads in TEA SQLite [${TEA_USE_THREADS}]" "${TEA_USE_THREADS}"
       )
option(TEA_SQLITE_BUILD_SHARED
       "Build TEA SQLite as a shared library [On]" On
       )
option(TEA_ENABLE_SQLITE
       "Enable building SQLite [On]" On
       )

if (NOT TEA_ENABLE_SQLITE)
    return()
endif ()

# Option integrity checks
if (NOT TEA_SQLITE_ENABLE_THREADS
    AND TCL_ENABLE_THREADS)
    message(SEND_ERROR
            "A non-threaded extension may only run in a non-threaded Tcl core.
Reconfigure with TCL_ENABLE_THREADS=0, or TEA_SQLITE_ENABLE_THREADS=1"
            )
endif ()

# Config based on options
if (NOT DEFINED TEA_SQLITE_BUILD_TYPE)
    if (TEA_SQLITE_BUILD_SHARED)
        set(TEA_SQLITE_BUILD_TYPE "SHARED" CACHE INTERNAL "" FORCE)
    else ()
        set(TEA_SQLITE_BUILD_TYPE "STATIC" CACHE INTERNAL "" FORCE)
    endif ()
endif ()

## System checks ###############################################################
cmake_push_check_state(RESET)
check_include_file("malloc.h" HAVE_MALLOC_H)

check_symbol_exists(fdatasync "unistd.h" HAVE_FDATASYNC)
check_symbol_exists(usleep "unistd.h" HAVE_USLEEP)
check_symbol_exists(localtime_r "sys/types.h;time.h" HAVE_LOCALTIME_R)
check_symbol_exists(localtime_s "time.h" HAVE_LOCALTIME_S)
check_symbol_exists(gmtime_r "sys/types.h;time.h" HAVE_GMTIME_R)
check_symbol_exists(malloc_usable_size
                    "malloc.h" HAVE_MALLOC_USABLE_SIZE)
check_symbol_exists(utime "sys/types.h;utime.h" HAVE_UTIME)
check_symbol_exists(flock "fcntl.h" HAVE_FLOCK)
check_symbol_exists(readlink "unistd.h" HAVE_READLINK)
check_symbol_exists(lstat "sys/stat.h" HAVE_LSTAT)
check_symbol_exists(pread "unistd.h" HAVE_PREAD)
check_symbol_exists(pread64 "unistd.h" HAVE_PREAD64)
check_symbol_exists(pwrite "unistd.h" HAVE_PWRITE)
check_symbol_exists(pwrite64 "unistd.h" HAVE_PWRITE64)
list(APPEND CMAKE_REQUIRED_DEFINITIONS "-D_GNU_SOURCE=1")
check_symbol_exists(strchrnul "string.h" HAVE_STRCHRNUL)
list(APPEND CMAKE_REQUIRED_DEFINITIONS "-D_CRT_RAND_S=1")
check_symbol_exists(rand_s "stdlib.h" HAVE_RAND_S)

check_symbol_exists(strerror_r "string.h" HAVE_DECL_STRERROR_R)
if (HAVE_DECL_STRERROR_R)
    check_c_source_compiles([[
#include <string.h>
int
main() {
    *strerror_r(0, 0, 0);
}
]] STRERROR_R_CHAR_P)
endif ()

cmake_pop_check_state()

## Target ######################################################################
add_library(tea_sqlite "${TEA_SQLITE_BUILD_TYPE}"
            src/tclsqlite3.c
            )

target_compile_definitions(tea_sqlite PRIVATE
                           BUILD_sqlite=1
                           USE_TCL_STUBS=1
                           SQLITE_ENABLE_DBPAGE_VTAB=1
                           SQLITE_ENABLE_DBSTAT_VTAB=1
                           SQLITE_ENABLE_FTS3_PARENTHESIS=1
                           SQLITE_ENABLE_FTS4=1
                           SQLITE_ENABLE_FTS5=1
                           SQLITE_ENABLE_COLUMN_METADATA=1
                           SQLITE_ENABLE_JSON1=1
                           SQLITE_3_SUFFIX_ONLY=1
                           SQLITE_ENABLE_RTREE=1
                           SQLITE_ENABLE_GEOPOLY=1
                           SQLITE_ENABLE_STAT4=1
                           SQLITE_ENABLE_UPDATE_DELETE_LIMIT=1
                           SQLITE_LIKE_DOESNT_MATCH_BLOBLS=1
                           SQLITE_UNTESTABLE=1
                           SQLITE_OMIT_DEPRECATED=1
                           SQLITE_OMIT_LOOKASIDE=1
                           SQLITE_SECURE_DELETE=1
                           SQLITE_SOUNDEX=1
                           SQLITE_USE_ALLOCA=1
                           SQLITE_WIN32_NO_ANSI=1
                           SQLITE_WIN32_GETVERSIONEX=1
                           SQLITE_THREADSAFE=$<BOOL:${TEA_SQLITE_ENABLE_THREADS}>
                           $<$<BOOL:${HAVE_FDATASYNC}>:HAVE_FDATASYNC=1>
                           $<$<BOOL:${HAVE_USLEEP}>:HAVE_USLEEP=1>
                           $<$<BOOL:${HAVE_STRCHRNUL}>:HAVE_STRCHRNUL=1>
                           $<$<BOOL:${HAVE_LOCALTIME_R}>:HAVE_LOCALTIME_R=1>
                           $<$<BOOL:${HAVE_LOCALTIME_S}>:HAVE_LOCALTIME_S=1>
                           $<$<BOOL:${HAVE_GMTIME_R}>:HAVE_GMTIME_S=1>
                           $<$<BOOL:${HAVE_MALLOC_USABLE_SIZE}>:HAVE_MALLOC_USABLE_SIZE=1>
                           $<$<BOOL:${HAVE_UTIME}>:HAVE_UTIME=1>
                           $<$<BOOL:${HAVE_FLOCK}>:HAVE_FLOCK=1>
                           $<$<BOOL:${HAVE_READLINK}>:HAVE_READLINK=1>
                           $<$<BOOL:${HAVE_LSTAT}>:HAVE_LSTAT=1>
                           $<$<BOOL:${HAVE_PREAD}>:HAVE_PREAD=1>
                           $<$<BOOL:${HAVE_PWRITE}>:HAVE_PWRITE=1>
                           $<$<BOOL:${HAVE_PREAD64}>:HAVE_PREAD64=1>
                           $<$<BOOL:${HAVE_PWRITE64}>:HAVE_PWRITE64=1>
                           $<$<BOOL:${HAVE_RAND_S}>:HAVE_RAND_S=1>
                           $<$<BOOL:${HAVE_DECL_STRERROR_R}>:HAVE_DECL_STRERROR_R=1>
                           $<$<BOOL:${STRERROR_R_CHAR_P}>:STRERROR_R_CHAR_P=1>
                           )

target_link_libraries(tea_sqlite PRIVATE
                      tclstub
                      )

string(REPLACE "." "" SQLITE_DOTLESS_VERSION "${SQLITE_VERSION}")
set_target_properties(tea_sqlite PROPERTIES
                      PREFIX ""
                      OUTPUT_NAME "tclsqlite${SQLITE_DOTLESS_VERSION}"
                      )

## Configuration ###############################################################
set(PACKAGE_VERSION "${SQLITE_VERSION}")
set(PKG_LIB_FILE "tclsqlite${SQLITE_DOTLESS_VERSION}${CMAKE_SHARED_LIBRARY_SUFFIX}")
configure_file(pkgIndex.tcl.in
               pkgIndex.tcl
               @ONLY
               )

## Tests #######################################################################
add_subdirectory(tests)

## Install #####################################################################
#&!off
tcl_install(RUNTIME_ONLY
                TARGETS tea_sqlite
                    RUNTIME DESTINATION "${TCL_INSTALL_LIBDIR}/sqlite${SQLITE_VERSION}"
                FILES "${CMAKE_CURRENT_BINARY_DIR}/pkgIndex.tcl"
                    DESTINATION "${TCL_INSTALL_LIBDIR}/sqlite${SQLITE_VERSION}"
            DEFAULT
                TARGETS tea_sqlite
                    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}/sqlite${SQLITE_VERSION}"
                FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/spaceanal.tcl"
                    RENAME sqlite3_analyzer
                    DESTINATION "${CMAKE_INSTALL_BINDIR}"
            )
#&!on
