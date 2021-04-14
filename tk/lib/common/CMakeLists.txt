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

## This file handles the common Tk sources that are required on all platforms.

project(Tk-Common C)

## Target #####################################################################
target_sources(tk PRIVATE
               # tk
               src/default.h src/ks_names.h src/tk.h src/tk3d.c src/tk3d.h
               src/tkArgv.c src/tkArray.h src/tkAtom.c src/tkBind.c src/tkBitmap.c
               src/tkBusy.c src/tkBusy.h src/tkButton.c src/tkButton.h src/tkCanvArc.c
               src/tkCanvas.c src/tkCanvas.h src/tkCanvBmap.c src/tkCanvImg.c
               src/tkCanvLine.c src/tkCanvPoly.c src/tkCanvPs.c src/tkCanvText.c
               src/tkCanvUtil.c src/tkCanvWind.c src/tkClipboard.c src/tkCmds.c
               src/tkColor.c src/tkColor.h src/tkConfig.c src/tkConsole.c
               src/tkCursor.c src/tkDecls.h src/tkDList.h src/tkEntry.c src/tkEntry.h
               src/tkError.c src/tkEvent.c src/tkFileFilter.c src/tkFileFilter.h
               src/tkFocus.c src/tkFont.c src/tkFont.h src/tkFrame.c src/tkGC.c
               src/tkGeometry.c src/tkGet.c src/tkGrab.c src/tkGrid.c src/tkImage.c
               src/tkImgBmap.c src/tkImgGIF.c src/tkImgPhInstance.c src/tkImgPhoto.c
               src/tkImgPhoto.h src/tkImgPNG.c src/tkImgPPM.c
               src/tkInt.h src/tkIntDecls.h src/tkIntPlatDecls.h src/tkIntXlibDecls.h
               src/tkListbox.c src/tkMacWinMenu.c src/tkMain.c src/tkMenu.c
               src/tkMenu.h src/tkMenubutton.c src/tkMenubutton.h src/tkMenuDraw.c
               src/tkMessage.c src/tkObj.c src/tkOldConfig.c src/tkOption.c
               src/tkPack.c src/tkPanedWindow.c src/tkPlace.c src/tkPlatDecls.h
               src/tkPort.h src/tkRectOval.c src/tkScale.c
               src/tkScale.h src/tkScrollbar.c src/tkScrollbar.h src/tkSelect.c
               src/tkSelect.h src/tkSquare.c src/tkStubInit.c src/tkStyle.c
               src/tkText.c src/tkText.h src/tkTextBTree.c src/tkTextDisp.c
               src/tkTextImage.c src/tkTextIndex.c src/tkTextMark.c src/tkTextTag.c
               src/tkTextWind.c src/tkTrig.c src/tkUndo.c src/tkUndo.h src/tkUtil.c
               src/tkVisual.c src/tkWindow.c src/tkMenubu.c src/tkScale2.c
               # ttk
               src/ttk/ttkBlink.c src/ttk/ttkButton.c src/ttk/ttkCache.c
               src/ttk/ttkClamTheme.c src/ttk/ttkClassicTheme.c src/ttk/ttkDecls.h
               src/ttk/ttkDefaultTheme.c src/ttk/ttkElements.c src/ttk/ttkEntry.c
               src/ttk/ttkFrame.c src/ttk/ttkImage.c src/ttk/ttkInit.c src/ttk/ttkLabel.c
               src/ttk/ttkLayout.c src/ttk/ttkManager.c src/ttk/ttkManager.h
               src/ttk/ttkNotebook.c src/ttk/ttkPanedwindow.c src/ttk/ttkProgress.c
               src/ttk/ttkScale.c src/ttk/ttkScroll.c src/ttk/ttkScrollbar.c
               src/ttk/ttkSeparator.c src/ttk/ttkSquare.c src/ttk/ttkState.c
               src/ttk/ttkStubInit.c src/ttk/ttkTagSet.c src/ttk/ttkTheme.c
               src/ttk/ttkTheme.h src/ttk/ttkThemeInt.h src/ttk/ttkTrace.c
               src/ttk/ttkTrack.c src/ttk/ttkTreeview.c src/ttk/ttkWidget.c
               src/ttk/ttkWidget.h
               )
if (WIN32 OR APPLE)
    target_sources(tk PRIVATE src/tkPointer.c)
endif ()
target_sources(tkstub PRIVATE
               src/tkStubLib.c
               src/ttk/ttkStubLib.c
               )
if (TARGET tktest)
    target_sources(tktest PRIVATE
                   src/tkTest.c
                   src/tkOldTest.c
                   # do not question, just obey
                   src/tkSquare.c
                   )
endif ()

target_compile_definitions(tk_config INTERFACE
                           BUILD_tk=1
                           BUILD_ttk=1
                           USE_TCL_STUBS=1
                           MODULE_SCOPE=extern
                           )

# Windows _?UNICODE main
configure_file(src/tkMain.c src/tkMain2.c COPYONLY)
if (WIN32)
    target_sources(tk PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/src/tkMain2.c")
endif ()

## Setting configuration values
target_include_directories(tk_config INTERFACE
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/ttk>
                           $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
                           )

if (TCL_ENABLE_INSTALL_DEVELOPMENT)
    install(FILES
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tk.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tkDecls.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tkIntXlibDecls.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tkPlatDecls.h"
            DESTINATION
            "${CMAKE_INSTALL_INCLUDEDIR}"
            )
endif ()
