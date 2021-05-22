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
project(tk-compat-layer C)

# This file does basically nothing, as we can just check the same values from
# the Tcl build, however, if X11 is not available on non Aqua build, we
# provide that. Applies to Windows too, but don't ask me why.

if (TK_ENABLE_AQUA)
    # Nothing to do with Aqua
    return ()
endif ()

find_package(X11)
if (X11_FOUND)
    # System has X11, nothing else to do, just use it
    target_link_libraries(tk_config INTERFACE X11::X11)
    set(TK_LIBS "${TK_LIBS};${X11_X11_LIB}" CACHE INTERNAL "")
    return ()
endif ()

## Patch in X11 for system #####################################################
target_include_directories(tk_config INTERFACE
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/X>
                           $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
                           )
target_sources(tk_config INTERFACE
               src/X/xbytes.h
               src/X/xcolors.c
               src/X/xdraw.c
               src/X/xgc.c
               src/X/ximage.c
               src/X/xutil.c
               src/X/X11/ap_keysym.h
               src/X/X11/cursorfont.h
               src/X/X11/DECkeysym.h
               src/X/X11/HPkeysym.h
               src/X/X11/keysym.h
               src/X/X11/keysymdef.h
               src/X/X11/Sunkeysym.h
               src/X/X11/X.h
               src/X/X11/Xatom.h
               src/X/X11/XF86keysym.h
               src/X/X11/Xfuncproto.h
               src/X/X11/Xlib.h
               src/X/X11/Xutil.h
               src/tkImgUtil.c
               )

## Install #####################################################################
#&!off
tcl_install(DEVELOPMENT
                DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/src/X/X11"
                    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
                    FILES_MATCHING PATTERN "*.h"
            )
#&!on
