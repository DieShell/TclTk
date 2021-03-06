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
if (NOT TCL_ENABLE_TESTS)
    return()
endif ()

set(TK_ACCESS_PATH ".. .. tk")
configure_file(../pkgIndex.tcl.in
               "${TK_TEST_LIBRARY}/pkgIndex.tcl"
               )

add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/../testwrap.tcl"
                   MAIN_DEPENDENCY "${CMAKE_CURRENT_SOURCE_DIR}/testwrap.tcl"
                   COMMENT "Copying testwrap for use in tktest tests"
                   COMMAND "${CMAKE_COMMAND}" -E copy "${CMAKE_CURRENT_SOURCE_DIR}/testwrap.tcl"
                                                      "${CMAKE_CURRENT_BINARY_DIR}/../"
                   )
add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/all.tcl"
                   MAIN_DEPENDENCY "${CMAKE_CURRENT_SOURCE_DIR}/all.tcl"
                   COMMENT "Copying tests for tktest: Tk"
                   COMMAND "${CMAKE_COMMAND}" -E copy_directory "${CMAKE_CURRENT_SOURCE_DIR}/"
                                                                "${CMAKE_CURRENT_BINARY_DIR}/"
                   )
add_custom_target(TkTest-Tests ALL
                  DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/all.tcl"
                          "${CMAKE_CURRENT_BINARY_DIR}/../testwrap.tcl"
                  )

file(GLOB TK_TESTS
     RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
     CONFIGURE_DEPENDS
     "*.test"
     )
foreach (test IN LISTS TK_TESTS)
    string(REGEX REPLACE [[\.test$]] "" test_NAME "${test}")
    add_test(NAME "Tk_${test_NAME}"
             COMMAND tclsh testwrap.tcl "${test}"
             WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/.."
             )
endforeach ()

file(GLOB TTK_TESTS
     RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}/ttk"
     CONFIGURE_DEPENDS
     "ttk/*.test"
     )
foreach (test IN LISTS TTK_TESTS)
    string(REGEX REPLACE [[\.test$]] "" test_NAME "${test}")
    add_test(NAME "Ttk_${test_NAME}"
             COMMAND tclsh testwrap.tcl -ttk "${test}"
             WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/.."
             )
endforeach ()
