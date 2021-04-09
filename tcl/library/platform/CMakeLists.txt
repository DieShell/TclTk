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

## platform.tcl ##
file(STRINGS platform.tcl PLATFORM_VERSION_LINE
     LIMIT_COUNT 1
     REGEX [[package provide platform [0-9]+\.[0-9]+\.[0-9]+]]
     )
string(REGEX REPLACE
       [[.*([0-9]+\.[0-9]+\.[0-9]+).*]] "\\1"
       PLATFORM_TCL_VERSION "${PLATFORM_VERSION_LINE}"
       )

## shell.tcl ##
file(STRINGS shell.tcl SHELL_VERSION_LINE
     LIMIT_COUNT 1
     REGEX [[package provide platform::shell [0-9]+\.[0-9]+\.[0-9]+]]
     )
string(REGEX REPLACE
       [[.*([0-9]+\.[0-9]+\.[0-9]+).*]] "\\1"
       SHELL_TCL_VERSION "${SHELL_VERSION_LINE}"
       )

## Tests #######################################################################
if (TCL_ENABLE_TESTS)
    configure_file(shell.tcl
                   "${TCL8_TEST_LIBRARY}/8.4/platform/shell-${SHELL_TCL_VERSION}.tm"
                   COPYONLY
                   )
    configure_file(platform.tcl
                   "${TCL8_TEST_LIBRARY}/8.4/platform-${PLATFORM_TCL_VERSION}.tm"
                   COPYONLY
                   )
endif ()

## Install #####################################################################
if (TCL_ENABLE_INSTALL)
    install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/shell.tcl"
            RENAME "shell-${SHELL_TCL_VERSION}.tm"
            DESTINATION "${CMAKE_INSTALL_LIBDIR}/tcl${TCL_MAJOR_VERSION}/8.4/platform"
            )
    install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/platform.tcl"
            RENAME "platform-${PLATFORM_TCL_VERSION}.tm"
            DESTINATION "${CMAKE_INSTALL_LIBDIR}/tcl${TCL_MAJOR_VERSION}/8.4/"
            )
endif ()
