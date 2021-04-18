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

get_filename_component(HTTP_DIR "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

## Tests #######################################################################
if (TCL_ENABLE_TESTS)
    configure_file(http.tcl
                   "${TCL_TEST_LIBRARY}/${HTTP_DIR}/http.tcl"
                   COPYONLY
                   )
    configure_file(pkgIndex.tcl
                   "${TCL_TEST_LIBRARY}/${HTTP_DIR}/pkgIndex.tcl"
                   COPYONLY
                   )
endif ()

## Install #####################################################################
#&!off
tcl_install(RUNTIME_ONLY
                FILES "${CMAKE_CURRENT_SOURCE_DIR}/http.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/pkgIndex.tcl"
                    DESTINATION "${CMAKE_INSTALL_LIBDIR}/tcl${TCL_VERSION}/${HTTP_DIR}"
            )
#&!on
