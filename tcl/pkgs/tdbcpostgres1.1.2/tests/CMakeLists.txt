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

## Tests #######################################################################
# bail if we are not building tests
if (NOT (TCL_ENABLE_TESTS AND TEA_TDBC_POSTGRES_ENABLE_TESTS))
    return()
endif ()

add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/all.tcl"
                   MAIN_DEPENDENCY "${CMAKE_CURRENT_SOURCE_DIR}/all.tcl"
                   COMMENT "Copying tests for tcltest: tdbcpostgres"
                   COMMAND "${CMAKE_COMMAND}" -E copy_directory "${CMAKE_CURRENT_SOURCE_DIR}/"
                                                                "${CMAKE_CURRENT_BINARY_DIR}/"
                   )
add_custom_target(TclTest-TDBCPostgreSQLTests ALL
                  DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/all.tcl"
                  )

add_custom_command(OUTPUT "${TCL_TEST_LIBRARY}/../tdbcpostgres${TDBC_VERSION}/${PKG_LIB_FILE}"
                   DEPENDS tea_tdbc_pq
                   COMMENT "Copying tdbcpostgres for tcltest"
                   COMMAND "${CMAKE_COMMAND}" -E copy "$<TARGET_FILE:tea_tdbc_pq>"
                                                      "${TCL_TEST_LIBRARY}/../tdbcpostgres${TDBC_VERSION}/"
                   )
add_custom_target(TclTest-TDBCPostgreSQLRuntime ALL
                  DEPENDS "${TCL_TEST_LIBRARY}/../tdbcpostgres${TDBC_VERSION}/${PKG_LIB_FILE}"
                  )

configure_file("${CMAKE_CURRENT_BINARY_DIR}/../pkgIndex.tcl"
               "${TCL_TEST_LIBRARY}/../tdbcpostgres${TDBC_VERSION}/pkgIndex.tcl"
               COPYONLY
               )
configure_file(../tcl/tdbcpostgres.tcl
               "${TCL_TEST_LIBRARY}/../tdbcpostgres${TDBC_VERSION}/tdbcpostgres.tcl"
               COPYONLY
               )

file(GLOB TEA_TDBC_PQ_TESTS
     RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
     CONFIGURE_DEPENDS
     "*.test"
     )
foreach (test IN LISTS TEA_TDBC_PQ_TESTS)
    string(REGEX REPLACE [[\.test$]] "" test_NAME "${test}")
    add_test(NAME "tdbcpostgres_${test_NAME}"
             COMMAND tcltest "tests/all.tcl" -file "${test}"
             WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/.."
             )
endforeach ()
