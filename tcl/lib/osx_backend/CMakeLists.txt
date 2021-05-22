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

## System checks ###############################################################
cmake_push_check_state(RESET)

check_include_file("CoreFoundation/CoreFoundation.h" HAVE_COREFOUNDATION)
check_include_file("libkern/OSAtomic.h"              HAVE_LIBKERN_OSATOMIC_H)
check_include_file("sys/attr.h"                      HAVE_SYS_ATTR_H)
check_include_file("sys/paths.h"                     HAVE_SYS_PATHS_H)
check_include_file("libkern/OSByteOrder.h"           HAVE_LIBKERN_OSBYTEORDER_H)
check_include_file("copyfile.h"                      HAVE_COPYFILE_H)
check_include_file("AvailabilityMacros.h"            HAVE_AVAILABILITYMACROS_H)

check_symbol_exists("getattrlist"    "sys/attr.h;sys/paths.h;libkern/OSByteOrder.h" 
                                                          HAVE_GETATTRLIST)
check_symbol_exists("copyfile"       "copyfile.h"         HAVE_COPYFILE)
check_symbol_exists("OSSpinLockLock" "libkern/OSAtomic.h" HAVE_OSSPINLOCKLOCK)

list(APPEND CMAKE_REQUIRED_FLAGS "-Werror")
check_c_source_compiles([[
#ifdef __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__
#   if __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ < 1020
#       error __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ < 1020
#   endif
#elif MAC_OS_X_VERSION_MIN_REQUIRED < 1020
#   error MAC_OS_X_VERSION_MIN_REQUIRED < 1020
#endif
		
int rand(void) __attribute__((weak_import));

int
main() {
    return rand();
}
]] HAVE_WEAK_IMPORT)

check_c_source_compiles([[
#ifdef __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__
#   if __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ < 1050
#       error __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ < 1050
#   endif
#elif MAC_OS_X_VERSION_MIN_REQUIRED < 1050
#   error MAC_OS_X_VERSION_MIN_REQUIRED < 1050
#endif

#define _DARWIN_C_SOURCE 1
#include <sys/cdefs.h>

int main() {}
]] HAVE_DARWIN_SUS_V3)

cmake_pop_check_state()

## Target ######################################################################
target_sources(tcl PRIVATE
               src/tclMacOSXFCmd.c
               src/tclMacOSXBundle.c
               src/tclMacOSXNotify.c
               )

## Configuration ###############################################################
target_compile_definitions(tcl_config INTERFACE
                           NO_REALPATH=1
                           USE_VFORK=1
                           MAC_OSX_TCL=1
                           "TCL_DEFAULT_ENCODING=\"utf-8\""
                           TCL_LOAD_FROM_MEMORY=1
                           TCL_WIDE_CLICKS=1
                           $<$<BOOL:HAVE_COREFOUNDATION>:HAVE_COREFOUNDATION=1>
                           $<$<BOOL:HAVE_OSSPINLOCKLOCK>:HAVE_OSSPINLOCKLOCK=1>
                           $<$<BOOL:HAVE_SYS_ATTR_H>:HAVE_SYS_ATTR_H=1>
                           $<$<BOOL:HAVE_SYS_PATHS_H>:HAVE_SYS_PATHS_H=1>
                           $<$<BOOL:HAVE_COPYFILE_H>:HAVE_COPYFILE_H=1>
                           $<$<BOOL:HAVE_AVAILABILITYMACROS_H>:HAVE_AVAILABILITYMACROS_H=1>
                           $<$<BOOL:HAVE_DARWIN_SUS_V3>:_DARWIN_C_SOURCE=1>
                           $<$<BOOL:HAVE_OSSPINLOCKLOCK>:HAVE_OSSPINLOCKLOCK=1>
                           $<$<BOOL:HAVE_GETATTRLIST>:HAVE_GETATTRLIST=1>
                           $<$<BOOL:HAVE_WEAK_IMPORT>:HAVE_WEAK_IMPORT=1>
                           $<$<BOOL:HAVE_COPYFILE>:HAVE_COPYFILE=1>
                           )

