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

## This file manages the MacOS implementation

project(Tcl-MacOS C)

## Configuration ###############################################################
string(TIMESTAMP TCL_YEAR "%Y")
configure_file(src/Tcl-Info.plist.in
               Tcl-info.plist
               @ONLY
               )

configure_file(src/Tclsh-Info.plist.in
               Tclsh-info.plist
               @ONLY
               )
# Note: TclTk CMake currently does not support generating MacOS Frameworks, thus
# the plist files are redundant. I however, have no idea how MacOS Frameworks
# work (= the reason there is no support for them), and how big of a deal they
# are to have, therefore, the files are left intact, are even configured but
# are unused. Feel free to implement the Framework support with them.
# Note on the note: CMake has built-in support for Frameworks, I just don't know
# what to do with it.

## Target ######################################################################
target_sources(tcl PRIVATE
               src/tclMacOSXFCmd.c
               src/tclMacOSXBundle.c
               src/tclMacOSXNotify.c
               )

## Install #####################################################################
if (TCL_ENABLE_INSTALL)

endif ()
