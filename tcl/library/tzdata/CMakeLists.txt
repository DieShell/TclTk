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
if (TCL_ENABLE_TESTS)
    add_custom_command(OUTPUT "${TCL_TEST_LIBRARY}/tzdata/UTC"
                       MAIN_DEPENDENCY "UTC"
                       COMMENT "Copying timezone data for tcltest"
                       COMMAND "${CMAKE_COMMAND}" -E copy_directory "${CMAKE_CURRENT_SOURCE_DIR}"
                                                                    "${TCL_TEST_LIBRARY}/tzdata"
                       )
    add_custom_target(TclTest-TZData ALL
                      DEPENDS "${TCL_TEST_LIBRARY}/tzdata/UTC"
                      )
endif ()

## Install #####################################################################
#&!off
tcl_install(RUNTIME_ONLY
                DIRECTORY .
                    DESTINATION "${TCL_INSTALL_LIBDIR}/tcl${TCL_VERSION}/tzdata"
                    PATTERN "CMakeLists.txt" EXCLUDE
            )
#&!on
