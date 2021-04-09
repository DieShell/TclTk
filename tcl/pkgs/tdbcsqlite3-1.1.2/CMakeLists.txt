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

project(TEA-TDBC-SQLite
        VERSION ${TDBC_VERSION}
        LANGUAGES NONE
        )

## Options #####################################################################
option(TEA_TDBC_SQLITE_ENABLE_TESTS
       "Enable running tests for the TDBC PostgreSQL connector [Off]" Off
       )

## Configuration ###############################################################
set(PACKAGE_VERSION "${TDBC_VERSION}")
configure_file(pkgIndex.tcl.in
               pkgIndex.tcl
               @ONLY
               )

## Tests #######################################################################
add_subdirectory(tests)

## Install #####################################################################
if (TCL_ENABLE_INSTALL)
    install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/tcl/tdbcsqlite3.tcl"
            RENAME "sqlite3-${TDBC_VERSION}.tm"
            DESTINATION "${CMAKE_INSTALL_LIBDIR}/tcl${TCL_MAJOR_VERSION}/${TCL_VERSION}/tdbc/"
            )
endif ()
