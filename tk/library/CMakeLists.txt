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
# For the tests to run we need a "working" installation of Tk.
# For this we install already known files, and add add_custom_command-s for
# freshly baked ones
if (TCL_ENABLE_TESTS)
    foreach (lib
             bgerror.tcl button.tcl choosedir.tcl clrpick.tcl comdlg.tcl console.tcl
             dialog.tcl entry.tcl focus.tcl fontchooser.tcl iconlist.tcl icons.tcl
             listbox.tcl megawidget.tcl menu.tcl mkpsenc.tcl msgbox.tcl obsolete.tcl
             optMenu.tcl palette.tcl panedwindow.tcl safetk.tcl scale.tcl scrlbar.tcl
             spinbox.tcl tearoff.tcl text.tcl tk.tcl tkfbox.tcl unsupported.tcl
             xmfbox.tcl tclIndex
             )
        configure_file("${lib}" "${TK_TEST_LIBRARY}/${lib}" COPYONLY)
    endforeach ()
endif ()

## Install #####################################################################
#&!off
tcl_install(RUNTIME_ONLY
                FILES "${CMAKE_CURRENT_SOURCE_DIR}/bgerror.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/button.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/choosedir.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/clrpick.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/comdlg.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/console.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/dialog.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/entry.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/focus.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/fontchooser.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/iconlist.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/icons.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/listbox.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/megawidget.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/menu.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/mkpsenc.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/msgbox.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/obsolete.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/optMenu.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/palette.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/panedwindow.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/safetk.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/scale.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/scrlbar.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/spinbox.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/tearoff.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/text.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/tk.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/tkfbox.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/unsupported.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/xmfbox.tcl"
                      "${CMAKE_CURRENT_SOURCE_DIR}/tclIndex"
                    DESTINATION "${CMAKE_INSTALL_LIBDIR}/tk${TK_VERSION}"
            )
#&!on

add_subdirectory(demos)
add_subdirectory(images)
add_subdirectory(msgs)
add_subdirectory(ttk)

