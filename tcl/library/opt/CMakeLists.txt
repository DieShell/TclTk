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

file(STRINGS optparse.tcl OPT_VERSION_LINE
     REGEX [[package provide opt [0-9]+\.[0-9]+\.[0-9]+]]
     )
string(REGEX REPLACE
       [[.*([0-9]+\.[0-9]+)\.[0-9]+.*]] "\\1"
       OPT_TCL_VERSION "${OPT_VERSION_LINE}"
       )

## Tests #######################################################################
if (TCL_ENABLE_TESTS)
    configure_file(optparse.tcl
                   "${TCL_TEST_LIBRARY}/opt${OPT_TCL_VERSION}/optparse.tcl"
                   COPYONLY
                   )
    configure_file(pkgIndex.tcl
                   "${TCL_TEST_LIBRARY}/opt${OPT_TCL_VERSION}/pkgIndex.tcl"
                   COPYONLY
                   )
endif ()

## Install #####################################################################
if (TCL_ENABLE_INSTALL)
    install(FILES
            "${CMAKE_CURRENT_SOURCE_DIR}/optparse.tcl"
            "${CMAKE_CURRENT_SOURCE_DIR}/pkgIndex.tcl"
            DESTINATION
            "${CMAKE_INSTALL_LIBDIR}/tcl${TCL_VERSION}/opt${OPT_TCL_VERSION}"
            )
endif ()
