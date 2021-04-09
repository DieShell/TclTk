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
# For the tests to run we need a "working" installation of Tcl Core library.
# For this we install already known files, and add add_custom_command-s for
# freshly baked ones
if (TCL_ENABLE_TESTS)
    foreach (lib
             auto.tcl
             clock.tcl
             history.tcl
             init.tcl
             package.tcl
             parray.tcl
             safe.tcl
             tm.tcl
             word.tcl
             tclIndex)
        configure_file("${lib}" "${TCL_TEST_LIBRARY}/${lib}" COPYONLY)
    endforeach ()
endif ()

## Install #####################################################################
if (TCL_ENABLE_INSTALL)
    install(FILES
            "${CMAKE_CURRENT_SOURCE_DIR}/auto.tcl"
            "${CMAKE_CURRENT_SOURCE_DIR}/clock.tcl"
            "${CMAKE_CURRENT_SOURCE_DIR}/history.tcl"
            "${CMAKE_CURRENT_SOURCE_DIR}/init.tcl"
            "${CMAKE_CURRENT_SOURCE_DIR}/package.tcl"
            "${CMAKE_CURRENT_SOURCE_DIR}/parray.tcl"
            "${CMAKE_CURRENT_SOURCE_DIR}/safe.tcl"
            "${CMAKE_CURRENT_SOURCE_DIR}/tclIndex"
            "${CMAKE_CURRENT_SOURCE_DIR}/tm.tcl"
            "${CMAKE_CURRENT_SOURCE_DIR}/word.tcl"
            DESTINATION
            "${CMAKE_INSTALL_LIBDIR}/tcl${TCL_VERSION}"
            )
endif ()

add_subdirectory(dde)
add_subdirectory(encoding)
add_subdirectory(http)
add_subdirectory(http1.0)
add_subdirectory(msgcat)
add_subdirectory(msgs)
add_subdirectory(opt)
add_subdirectory(platform)
add_subdirectory(reg)
add_subdirectory(tcltest)
add_subdirectory(tcltests)
add_subdirectory(tzdata)
