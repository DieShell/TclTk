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

project(TEA-TDBC-PostgreSQL
        VERSION ${TDBC_VERSION}
        LANGUAGES C
        )

## Options #####################################################################
option(TEA_TDBC_MYSQL_ENABLE_THREADS 
       "Enable the use of threads in TEA TDBC_MYSQL [${TEA_USE_THREADS}]" "${TEA_USE_THREADS}"
       )

# Option integrity checks
if (NOT TEA_TDBC_MYSQL_ENABLE_THREADS
    AND TCL_ENABLE_THREADS)
        message(SEND_ERROR 
"A non-threaded extension may only run in a non-threaded Tcl core.
Reconfigure with TCL_ENABLE_THREADS=0, or TEA_SQLITE_ENABLE_THREADS=1"
            )
endif ()

## System checks ###############################################################
cmake_push_check_state(RESET)
check_type_size("long long" LONG_LONG)
check_type_size("long"      LONG)

cmake_pop_check_state()

## Target ######################################################################
add_library(tea_tdbc_pq SHARED
            src/tdbcpostgres.c
            src/pqStubInit.c
            src/fakepq.h
            src/int2ptr_ptr2int.h
            src/pqStubs.h
            )

target_compile_definitions(tea_tdbc_pq PRIVATE                           
                           BUILD_tdbcpostgres=1
                           USE_TCL_STUBS=1
                           USE_TCLOO_STUBS=1
                           USE_TDBC_STUBS=1
                           MODULE_SCOPE=extern
                           $<$<BOOL:${HAVE_LONG_LONG}>:HAVE_LONG_LONG=1>
                           $<$<BOOL:${HAVE_LONG_LONG}>:SIZEOF_LONG_LONG=${LONG_LONG}>
                           SIZEOF_LONG=${LONG}
                           PACKAGE_NAME="tdbcpostgres"
                           PACKAGE_VERSION="${TDBC_VERSION}"
                           )
target_link_libraries(tea_tdbc_pq PRIVATE
                      tea_tdbc_config
                      tea_tdbcstub
                      )
# from compat_layer/intptr_types.cmake
check_intptr_type(tea_tdbc_pq "intptr_t"
                  FALLBACK "int" "long" "long long"
                  )
check_intptr_type(tea_tdbc_pq "uintptr_t"
                  FALLBACK "unsigned" "unsinged long" "unsigned long long"
                  )

string(REPLACE "." "" TDBC_MYSQL_DOTLESS_VERSION "${TDBC_VERSION}")
set_target_properties(tea_tdbc_pq PROPERTIES
                      PREFIX ""
                      OUTPUT_NAME "tdbcpostgres${TDBC_MYSQL_DOTLESS_VERSION}"
                      )

## Configuration ###############################################################
set(TCL_VERSION_REQ     "8.6")
set(TCLOO_VERSION_REQ   "1.0")
set(PACKAGE_NAME        "tdbcpostgres")
set(PACKAGE_VERSION     "${TDBC_VERSION}")
set(PKG_LIB_FILE        "tdbcpq${TDBC_MYSQL_DOTLESS_VERSION}${CMAKE_SHARED_LIBRARY_SUFFIX}")
configure_file(pkgIndex.tcl.in
               pkgIndex.tcl
               @ONLY
               )

## Install #####################################################################
if (TCL_ENABLE_INSTALL)
    install(TARGETS tea_tdbc_pq
            DESTINATION "${CMAKE_INSTALL_LIBDIR}/tdbcpostgres${TDBC_VERSION}"
            )
    install(FILES 
            "${CMAKE_CURRENT_BINARY_DIR}/pkgIndex.tcl"
            "${CMAKE_CURRENT_SOURCE_DIR}/tcl/tdbcpostgres.tcl" 
            DESTINATION
            "${CMAKE_INSTALL_LIBDIR}/tdbcpostgres${TDBC_VERSION}"
            )
endif ()
