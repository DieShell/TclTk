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

# This file does mostly the equivalent of the AC_HEADER_STDC macro

## System checks ###############################################################
cmake_push_check_state(RESET)

check_include_file("stdlib.h" HAVE_STDLIB_H)
check_include_file("stdarg.h" HAVE_STDARG_H)
check_include_file("string.h" HAVE_STRING_H)
check_include_file("float.h"  HAVE_FLOAT_H)
check_include_file("ctype.h"  HAVE_CTYPE_H)

if (HAVE_STDLIB_H AND HAVE_STDARG_H
        AND HAVE_STRING_H AND HAVE_FLOAT_H
        AND HAVE_CTYPE_H)
    check_symbol_exists("memchr" "string.h" HAVE_MEMCHR)
    check_symbol_exists("free"   "stdlib.h" HAVE_FREE)

    if (NOT "$CACHE{CHECKED_CTYPE_HIGH_BIT}")
        file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/ctype_high_check.c"
            "#include <ctype.h>
             #include <stdio.h>
             int
             main() {
                char c = 'c';
                printf(\"%c\", toupper(c));
                c |= 1 << 8;
                printf(\"%c\", toupper(c));
             }")
        try_run(whatever HIGH_CHECK_BUILT
                "${CMAKE_CURRENT_BINARY_DIR}"
                "${CMAKE_CURRENT_BINARY_DIR}/ctype_high_check.c"
                RUN_OUTPUT_VARIABLE HIGH_RAN
                )
        set(CHECKED_CTYPE_HIGH_BIT 1 CACHE INTERNAL
            "Whether we already checked if ctype works with high bit set" FORCE)

        if (HIGH_CHECK_BUILT AND HIGH_RAN STREQUAL "AA")
            set(HAVE_ANSIC_CTYPE 1 CACHE INTERNAL
                "Do we have an ANSI C compatible ctype.h" FORCE)
        else ()
            set(HAVE_ANSIC_CTYPE 0 CACHE INTERNAL
                "Do we have an ANSI C compatible ctype.h" FORCE)
        endif ()
    endif ()

    if (HAVE_MEMCHR AND HAVE_FREE AND HAVE_ANSIC_CTYPE)
        set(STDC_HEADERS 1 CACHE INTERNAL "" FORCE)
    else ()
        set(STDC_HEADERS 0 CACHE INTERNAL "" FORCE)
    endif ()
else ()
    set(STDC_HEADERS 0 CACHE INTERNAL "" FORCE)
endif ()

# functions for which we have replacements
check_symbol_exists("memcmp"  "string.h" HAVE_MEMCMP)
check_symbol_exists("memmove" "string.h" HAVE_MEMMOVE)
check_symbol_exists("strstr"  "string.h" HAVE_STRSTR)
check_symbol_exists("strtol"  "stdlib.h" HAVE_STRTOL)
check_symbol_exists("strtoul" "stdlib.h" HAVE_STRTOUL)

# cast to union
check_c_source_compiles([[
union foo { int i; double d; };
int
main() {
    union foo u;
    int i;

    i = 42;
    u = (union foo) i;
}
]] HAVE_CAST_TO_UNION)

# check if strstr is broken
if (HAVE_STRSTR AND NOT DEFINED TCL_STRSTR_TESTED)
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/strstr-test.c"
         [[#include <string.h>
           int
           main() {
               /* we expect NULL to be returned */
               return (strstr("\0test", "test") ? 0 : 1);
           }
         ]])
    try_run(TCL_STRSTR_WORKS _ignore
            "${CMAKE_CURRENT_BINARY_DIR}"
            "${CMAKE_CURRENT_BINARY_DIR}/strstr-test.c"
            )
    set(HAVE_STRSTR "${TCL_STRSTR_WORKS}" CACHE INTERNAL "" FORCE)
    set(TCL_STRSTR_TESTED 1 CACHE INTERNAL "" FORCE)
endif ()

# check if strtoul is broken
if (HAVE_STRTOUL AND NOT DEFINED TCL_STRTOUL_TESTED)
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/strtoul-test.c"
         [[#include <stdlib.h>
           int
           main() {
               char *term, *str = "0";
               return (strtoul(str, &term, 0) == 0 && term == str + 1);
           }
         ]])
    try_run(TCL_STRTOUL_WORKS _still_ignore
            "${CMAKE_CURRENT_BINARY_DIR}"
            "${CMAKE_CURRENT_BINARY_DIR}/strtoul-test.c"
            )
    set(HAVE_STRTOUL "${TCL_STRTOUL_WORKS}" CACHE INTERNAL "" FORCE)
    set(TCL_STRTOUL_TESTED 1 CACHE INTERNAL "" FORCE)
endif ()

cmake_pop_check_state()

## Add to config ###############################################################
target_compile_definitions(tcl_config INTERFACE
                           $<${STDC_HEADERS}:STDC_HEADERS=1>
                           $<$<BOOL:${HAVE_CAST_TO_UNION}>:HAVE_CAST_TO_UNION=1>
                           $<$<BOOL:${HAVE_MEMCMP}>:HAVE_MEMCMP=1>
                           $<$<NOT:$<BOOL:${HAVE_MEMMOVE}>>:NO_MEMMOVE=1>
                           $<$<NOT:$<AND:$<BOOL:${HAVE_STDLIB_H}>,$<BOOL:${HAVE_FREE}>>>:NO_STDLIB_H=1>
                           $<$<NOT:$<AND:$<BOOL:${HAVE_STRING_H}>,$<BOOL:${HAVE_MEMCHR}>>>:NO_STRING_H=1>
                           )

if (NOT STDC_HEADERS)
    target_include_directories(tcl_config INTERFACE
                               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/ansic>
                               $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/tcl${TCL_DOUBLE_VERSION}/generic>
                               )
endif ()

target_sources(tcl_config INTERFACE
               $<$<NOT:$<BOOL:${HAVE_MEMCMP}>>:${CMAKE_CURRENT_SOURCE_DIR}/src/ansic/memcmp.c>
               $<$<NOT:$<BOOL:${HAVE_STRSTR}>>:${CMAKE_CURRENT_SOURCE_DIR}/src/ansic/strstr.c>
               $<$<NOT:$<BOOL:${HAVE_STRTOL}>>:${CMAKE_CURRENT_SOURCE_DIR}/src/strtol.c>
               $<$<NOT:$<BOOL:${HAVE_STRTOUL}>>:${CMAKE_CURRENT_SOURCE_DIR}/src/strtoul.c>
               )

if (TCL_ENABLE_INSTALL_DEVELOPMENT)
    install(FILES
            $<$<NOT:$<BOOL:${HAVE_FLOAT_H}>>:src/ansic/compat/float.h>
            $<$<NOT:$<BOOL:${HAVE_STDLIB_H}>>:src/ansic/compat/stdlib.h>
            $<$<NOT:$<BOOL:${HAVE_STRING_H}>>:src/ansic/compat/string.h>
            DESTINATION
            "${CMAKE_INSTALL_INCLUDEDIR}/tcl${TCL_DOUBLE_VERSION}/generic/compat"
            )
endif ()
