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
# custom_target for encoding because file() cannot copy directories
if (TCL_ENABLE_TESTS)
    add_custom_command(OUTPUT "${TK_TEST_LIBRARY}/demos/anilabel.tcl"
                       MAIN_DEPENDENCY anilabel.tcl
                       COMMENT "Copying demos for tktest"
                       COMMAND
                       "${CMAKE_COMMAND}" -E copy_directory "${CMAKE_CURRENT_SOURCE_DIR}"
                       "${TK_TEST_LIBRARY}/demos"
                       )
    add_custom_target(TkTest-Demos ALL
                      DEPENDS "${TK_TEST_LIBRARY}/demos/anilabel.tcl"
                      )
endif ()

## Install #####################################################################
#&!off
tcl_install(DEFAULT
                DIRECTORY .
                    DESTINATION "${TCL_INSTALL_LIBDIR}/tk${TK_VERSION}/demos"
                    PATTERN "CMakeLists.txt" EXCLUDE
            )
#&!on
