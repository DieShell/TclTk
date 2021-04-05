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

## unix-ish specific Tcl source files and configuration checks

## Target ######################################################################
target_sources(tcl PRIVATE
               src/tclUnixChan.c
               src/tclUnixCompat.c
               src/tclUnixEvent.c
               src/tclUnixFile.c
               src/tclUnixFCmd.c
               src/tclUnixInit.c
               src/tclUnixNotfy.c
               src/tclUnixPipe.c
               src/tclUnixPort.h
               src/tclUnixSock.c
               #src/tclUnixTest.c
               src/tclUnixThrd.c src/tclUnixThrd.h
               src/tclUnixTime.c
               src/tclXtNotify.c
               #src/tclXtTest.c
               )
target_sources(tclsh PRIVATE
               src/tclAppInit.c
               )

## Options #####################################################################
set(TCL_WITH_ENCODING "iso8895-1" CACHE STRING 
    "The encoding to use (--with-encoding=) [iso8895-1]"
    )

## System checks ###############################################################
cmake_push_check_state(RESET)

check_include_file("termios.h"    HAVE_TERMIOS_H)
check_include_file("sys/ioctl.h"  HAVE_SYS_IOCTL_H)
check_include_file("sys/modem.h"  HAVE_SYS_MODEM_H)
check_include_file("sys/filio.h"  HAVE_SYS_FILIO_H)
check_include_file("sys/select.h" HAVE_SYS_SELECT_H)
check_include_file("net/errno.h"  HAVE_NET_ERRNO_H)
check_include_file("fts.h"        HAVE_FTS_H)

check_symbol_exists("getcwd"       "unistd.h"                HAVE_GETCWD)
check_symbol_exists("getwd"        "unistd.h"                HAVE_GETWD)
check_symbol_exists("strerror"     "string.h"                HAVE_STRERROR)
check_symbol_exists("uname"        "sys/utsname.h"           HAVE_UNAME)
check_symbol_exists("wait3"        "sys/wait.h"              HAVE_WAIT3)
check_symbol_exists("realpath"     "stdlib.h"                HAVE_REALPATH)
check_symbol_exists("gmtime_r"     "sys/types.h;time.h"      HAVE_GMTIME_R)
check_symbol_exists("localtime_r"  "sys/types.h;time.h"      HAVE_LOCALTIME_R)
check_symbol_exists("mktime"       "sys/types.h;time.h"      HAVE_MKTIME)
check_symbol_exists("fstatfs"      "sys/types.h;sys/mount.h" HAVE_FSTATFS)
check_symbol_exists("mkstemps"     "stdlib.h"                HAVE_MKSTEMPS)
check_symbol_exists("chflags"      "sys/stat.h"              HAVE_CHFLAGS)
check_symbol_exists("isnan"        "math.h"                  HAVE_ISNAN)

check_type_size("((struct tm*)0)->tm_tzajd"  TM_TZADJ)
check_type_size("((struct tm*)0)->tm_gmtoff" TM_GMTOFF)
check_type_size("fd_set"                     FD_SET)
if (HAVE_SYS_SELECT_H)
    list(APPEND CMAKE_EXTRA_INCLUDE_FILES "sys/select.h")
    check_type_size("fd_mask"                    FD_MASK)
endif ()

check_c_source_compiles([[
extern long timezone;
int main() {}
]] HAVE_LONG_TIMEZONE)
check_c_source_compiles([[
#include <time.h>
extern time_t timezone;
int main() {}
]] HAVE_TIME_T_TIMEZONE)

if (HAVE_TIME_T_TIMEZONE OR HAVE_LONG_TIMEZONE)
    set(HAVE_TIMEZONE_VAR TRUE CACHE BOOL "have a timezone extern variable" FORCE)
else ()
    set(HAVE_TIMEZONE_VAR FALSE CACHE BOOL "have a timezone extern variable" FORCE)
endif ()

# check if char == unsigned char by default
if (NOT DEFINED TCL_UNSIGNED_CHAR_CHECKED)
    file(WRITE unsigned-char.c
         [[
         int main() { char c = -1; return c == (unsigned char)~0; }
         ]])
    try_run(DEFAULT_UNSIGNED_CHAR _ignore
            "${CMAKE_CURRENT_BINARY_DIR}"
            "${CMAKE_CURRENT_BINARY_DIR}/unsigned-char.c"
            )
    set(TCL_UNSIGNED_CHAR_DEFAULT ${DEFAULT_UNSIGNED_CHAR} CACHE BOOL 
        "char is unsigned by default" FORCE)
    set(TCL_UNSIGNED_CHAR_CHECKED 1 CACHE INTERNAL "" FORCE)
endif ()
check_c_source_compiles([[
int 
main() {
    signed char *p;
    p = 0;
}
]] HAVE_SIGNED_CHAR)

# union wait
check_c_source_compiles([[
#include <sys/types.h>
#include <sys/wait.h>
int
main() {
    union wait w;
    WIFEXITED(w);
}
]] HAVE_UNION_WAIT)

if (NOT DEFINED TCL_PUTENV_CHECKED)
    file(WRITE putenv-copies.c
        [[
        #include <stdlib.h>
        #include <string.h>
        int
        main() {
            char *give_env, *get_env;
            give_env = stddup("PUTENV_COPIED=1");
            putenv(give_env);
            strcpy(strchr(give_env, '=') + 1, "0");
            get_env = getenv("PUTENV_COPIED");
            if (strcmp(get_env, "0") == 0) return 0; /* didn't copy give_env */
            free(give_env);
            return 1; /* copied give_env */
        }
        ]]) # code is based on original configure.ac's code snippet for checking this
    try_run(PUTENV_COPIES _ignore
            "${CMAKE_CURRENT_BINARY_DIR}"
            "${CMAKE_CURRENT_BINARY_DIR}/putenv-copies.c"
            )
    set(HAVE_PUTENV_COPY "${PUTENV_COPIES}" CACHE BOOL "putenv copies the string" FORCE)
    set(TCL_PUTENV_CHECKED 1 CACHE INTERNAL "" FORCE)
endif ()

include(thread_safe.cmake)

## can we use fts instead of readdir
if (HAVE_FTS_H)
    check_symbol_exists("fts_open" "fts.h"                   HAVE_FTS_OPEN)
    check_symbol_exists("fts_read" "fts.h"                   HAVE_FTS_READ)
    check_symbol_exists("fts_close" "fts.h"                  HAVE_FTS_CLOSE)

    if (HAVE_FTS_OPEN AND HAVE_FTS_READ AND HAVE_FTS_CLOSE)
        set(HAVE_FTS TRUE CACHE BOOL "have the fts_* functions" FORCE)
    else ()
        set(HAVE_FTS FALSE CACHE BOOL "have the fts_* functions" FORCE)
    endif ()
else ()
    set(HAVE_FTS FALSE CACHE BOOL "have the fts_* functions" FORCE)
endif ()

## cpuid instruction works with inline asm
check_c_source_compiles([[
    int
    main() {
        int idx;
        int regs[4];
        __asm__ __volatile__("mov %%ebx, %%edi\n\t"
                             "cpuid\n\t"
                             "mov %%ebx, %%esi\n\t"
                             "mov %%edi, %%ebx\n\t"
                             : "=a"(regs[0]), 
                               "=S"(regs[1]),
                               "=c"(regs[2]),
                               "=d"(regs[3])
                             : "a"(idx)
                             : "edi");
    }
]] HAVE_CPUID)

cmake_pop_check_state()

## Configuration ###############################################################
target_compile_definitions(tcl_config INTERFACE 
                           HAVE_ZLIB=1
                           $<$<NOT:$<BOOL:${HAVE_GETCWD}>>:USEGETWD=1>
                           $<$<NOT:$<BOOL:${HAVE_GETWD}>>:NO_GETWD=1>
                           $<$<NOT:$<BOOL:${HAVE_WAIT3}>>:NO_WAIT3=1>
                           $<$<NOT:$<BOOL:${HAVE_STRERROR}>>:NO_STRERROR=1>
                           $<$<NOT:$<BOOL:${HAVE_UNAME}>>:NO_UNAME=1>
                           $<$<NOT:$<BOOL:${HAVE_REALPATH}>>:NO_REALPATH=1>
                           $<$<BOOL:${HAVE_GMTIME_R}>:HAVE_GMTIME_R=1>
                           $<$<BOOL:${HAVE_LOCALTIME_R}>:HAVE_LOCALTIME_R=1>
                           $<$<BOOL:${HAVE_MKTIME}>:HAVE_MKTIME=1>
                           $<$<BOOL:${HAVE_CHFLAGS}>:HAVE_CHFLAGS=1>
                           $<$<BOOL:${HAVE_MKSTEMPS}>:HAVE_MKSTEMPS=1>
                           $<$<BOOL:${HAVE_ISNAN}>:HAVE_ISNAN=1>
                           $<$<BOOL:${HAVE_TM_TZADJ}>:HAVE_TM_TZAJD=1>
                           $<$<BOOL:${HAVE_TM_GMTOFF}>:HAVE_TM_GMTOFF=1>
                           $<$<BOOL:${HAVE_TIMEZONE_VAR}>:HAVE_TIMEZONE_VAR=1>
                           $<$<BOOL:${TCL_UNSIGNED_CHAR_DEFAULT}>:__CHAR_UNSIGNED__=1>
                           $<$<BOOL:${HAVE_SIGNED_CHAR}>:HAVE_SIGNED_CHAR=1>
                           $<$<NOT:$<BOOL:${HAVE_FSTATFS}>>:NO_FSTATFS=1>
                           $<$<NOT:$<OR:$<BOOL:${HAVE_FD_MASK}>,$<BOOL:${HAVE_FD_SET}>>>:NO_FD_SET=1>
                           $<$<NOT:$<BOOL:${HAVE_UNION_WAIT}>>:NO_UNION_WAIT=1>
                           $<$<BOOL:${HAVE_PUTENV_COPY}>:HAVE_PUTENV_THAT_COPIES=1>
                           $<$<BOOL:${HAVE_FTS}>:HAVE_FTS=1>
                           $<$<BOOL:${HAVE_CPUID}>:HAVE_CPUID=1>
                           )

target_include_directories(tcl_config INTERFACE
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/manifest>
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
                           $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/tcl${TCL_DOUBLE_VERSION}/win>
                           )
target_include_directories(tcl_public INTERFACE
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
                           $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/tcl${TCL_DOUBLE_VERSION}/win>
                           )

target_link_options(tcl_config INTERFACE
                    $<$<C_COMPILER_ID:GNU,Clang>:-municode>
                    )
target_link_options(tclsh PRIVATE
                    $<$<C_COMPILER_ID:GNU,Clang>:-mconsole>
                    )

target_link_libraries(tcl_config INTERFACE kernel32 ws2_32 netapi32 userenv user32 advapi32)

if (TCL_ENABLE_INSTALL_DEVELOPMENT)
    install(FILES
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclWinInt.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclWinPort.h"
            DESTINATION
            "${CMAKE_INSTALL_INCLUDEDIR}/tcl${TCL_DOUBLE_VERSION}/win"
            )
endif ()
