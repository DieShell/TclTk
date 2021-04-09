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

# This file checks some POSIX functions for existence, and may provide
# a backup implementation

if (WIN32)
    # Windows builds do not POSIX checks and backup functions
    # as Windows sources do not expect POSIX to be available
    return ()
endif ()

## System checks ###############################################################
cmake_push_check_state(RESET)

check_include_file("unistd.h"   HAVE_UNISTD_H)
check_include_file("sys/wait.h" HAVE_SYS_WAIT_H)
check_include_file("strings.h"  HAVE_STRINGS_H)
check_include_file("sys/time.h" HAVE_SYS_TIME_H)
check_include_file("values.h"   HAVE_VALUES_H)
check_include_file("dlfcn.h"    HAVE_DLFCN_H)

check_symbol_exists("lseek"        "unistd.h"   HAVE_LSEEK)
check_symbol_exists("waitpid"      "sys/wait.h" HAVE_WAITPID)
check_symbol_exists("strncasecmp"  "strings.h"  HAVE_STRNCASECMP)
check_symbol_exists("mkstemp"      "stdlib.h"   HAVE_MKSTEMP)
check_symbol_exists("gettimeofday" "sys/time.h" HAVE_GETTOD)

if (NOT HAVE_STRNCASECMP)
    check_library_exists("socket" "strncasecmp" "" HAVE_STRNCASECMP_IN_SOCKET)
    check_library_exists("inet"   "strncasecmp" "" HAVE_STRNCASECMP_IN_INET)

    if (HAVE_STRNCASECMP_IN_SOCKET OR HAVE_STRNCASECMP_IN_INET)
        set(HAVE_STRNCASECMP TRUE CACHE BOOL "" FORCE)
    endif ()
endif ()

check_type_size("((struct stat*)0)->st_blocks"  STRUCT_STAT_ST_BLOCKS)
check_type_size("((struct stat*)0)->st_blksize" STRUCT_STAT_ST_BLKSIZE)
check_type_size("blkcnt_t"                      BLKCNT_T)
check_type_size("mode_t"                        MODE_T)
check_type_size("pid_t"                         PID_T)
check_type_size("size_t"                        SIZE_T)
check_type_size("uid_t"                         UID_T)
check_type_size("gid_t"                         GID_T)
if (HAVE_SYS_SOCKET_H)
    list(APPEND CMAKE_EXTRA_INCLUDE_FILES "sys/socket.h")
endif ()
check_type_size("socklen_t"                     SOCKLEN_T)
# idk if this is POSIX
list(APPEND CMAKE_EXTRA_INCLUDE_FILES "sys/stat.h")
check_type_size("struct stat64"                 STRUCT_STAT64)

cmake_pop_check_state()

target_compile_definitions(tcl_config INTERFACE
                           HAVE_WAITPID=1 # if it does not exists, we provide it
                           HAVE_MKSTEMP=1 # same
                           HAVE_OPENDIR=1 # ditto
                           HAVE_STRTOL=1  # equally
                           $<$<BOOL:${HAVE_LSEEK}>:HAVE_LSEEK=1>
                           $<$<BOOL:${HAVE_UNISTD_H}>:HAVE_UNISTD_H=1>
                           $<$<BOOL:${HAVE_STRUCT_STAT64}>:HAVE_STRUCT_STAT64=1>
                           $<$<NOT:$<BOOL:${HAVE_SYS_WAIT_H}>>:NO_SYS_WAIT_H=1>
                           $<$<NOT:$<BOOL:${HAVE_VALUES_H}>>:NO_VALUES_H=1>
                           $<$<NOT:$<BOOL:${HAVE_DLFCN_H}>>:NO_DLFCN_H=1>
                           $<$<NOT:$<BOOL:${HAVE_GETTOD}>>:GETTOD_NOT_DECLARED=1>
                           $<$<BOOL:${HAVE_STRUCT_STAT_ST_BLOCKS}>:HAVE_STRUCT_STAT_ST_BLOCKS=1>
                           $<$<BOOL:${HAVE_STRUCT_STAT_ST_BLKSIZE}>:HAVE_STRUCT_STAT_ST_BLKSIZE=1>
                           $<$<BOOL:${HAVE_BLKCNT_T}>:HAVE_BLKCNT_T=1>
                           $<$<NOT:$<BOOL:${HAVE_MODE_T}>>:mode_t=int>
                           $<$<NOT:$<BOOL:${HAVE_PID_T}>>:pid_t=int>
                           $<$<NOT:$<BOOL:${HAVE_UID_T}>>:uid_t=int>
                           $<$<NOT:$<BOOL:${HAVE_GID_T}>>:gid_t=int>
                           $<$<NOT:$<BOOL:${HAVE_SIZE_T}>>:size_t=unsigned long>
                           $<$<NOT:$<BOOL:${HAVE_SOCKLEN_T}>>:socklen_t=int>
                           )

target_include_directories(tcl_config INTERFACE
                           $<$<NOT:$<BOOL:${HAVE_UNISTD_H}>>:$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/unistd>>
                           $<$<NOT:$<BOOL:${HAVE_UNISTD_H}>>:$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/tcl${TCL_DOUBLE_VERSION}/generic>>
                           )
target_link_libraries(tcl_config INTERFACE
                      $<$<BOOL:${HAVE_STRNCASECMP_IN_SOCKET}>:socket>
                      $<$<BOOL:${HAVE_STRNCASECMP_IN_INET}>:inet>
                      )

target_sources(tcl_config INTERFACE
               $<$<NOT:$<BOOL:${HAVE_WAITPID}>>:${CMAKE_CURRENT_SOURCE_DIR}/src/waitpid.c>
               $<$<NOT:$<BOOL:${HAVE_STRNCASECMP}>>:${CMAKE_CURRENT_SOURCE_DIR}/src/strncasecmp.c>
               $<$<NOT:$<BOOL:${HAVE_MKSTEMP}>>:${CMAKE_CURRENT_SOURCE_DIR}/src/mkstemp.c>
               $<$<NOT:$<BOOL:${HAVE_GETTOD}>>:${CMAKE_CURRENT_SOURCE_DIR}/src/gettod.c>
               )

if (TCL_ENABLE_INSTALL_DEVELOPMENT)
    install(FILES
            "${CMAKE_CURRENT_SOURCE_DIR}/src/unistd/compat/unistd.h"
            DESTINATION
            "${CMAKE_INSTALL_INCLUDEDIR}/tcl${TCL_DOUBLE_VERSION}/generic/compat"
            )
endif ()
