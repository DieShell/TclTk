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

## Windows specific Tk source files and configuration checks

## Target ######################################################################
target_sources(tk PRIVATE
               src/stubs.c src/tkWin.h src/tkWin32Dll.c src/tkWin3d.c
               src/tkWinButton.c src/tkWinClipboard.c src/tkWinColor.c
               src/tkWinConfig.c src/tkWinCursor.c src/tkWinDefault.h
               src/tkWinDialog.c src/tkWinDraw.c src/tkWinEmbed.c src/tkWinFont.c
               src/tkWinImage.c src/tkWinInit.c src/tkWinInt.h src/tkWinKey.c
               src/tkWinMenu.c src/tkWinPixmap.c src/tkWinPointer.c src/tkWinPort.h
               src/tkWinRegion.c src/tkWinScrlbr.c src/tkWinSend.c src/tkWinSendCom.c
               src/tkWinSendCom.h src/tkWinWindow.c src/tkWinWm.c src/tkWinX.c
               src/ttkWinMonitor.c src/ttkWinTheme.c src/ttkWinXPTheme.c
               src/winMain.c
               rc/tk.rc
               )
target_sources(wish PRIVATE
               src/winMain.c
               rc/wish.rc
               )
if (TARGET tktest)
    target_sources(tktest PRIVATE
                   src/tkWinTest.c
                   src/winMain.c
                   )
endif ()

## System checks ###############################################################
cmake_push_check_state(RESET)

check_include_files("windows.h;uxtheme.h" HAVE_UXTHEME_H)
check_include_files("windows.h;vssym32.h" HAVE_VSSYM32_H)

check_symbol_exists("_strtoi64" "stdlib.h" HAVE_STRTOI64)

cmake_pop_check_state()

## Manifests ###################################################################
if (TK_PATCH_LEVEL MATCHES [[a]])
    set(TK_RELEASE_LEVEL 0 CACHE INTERNAL "." FORCE)
elseif (TK_PATCH_LEVEL MATCHES [[b]])
    set(TK_RELEASE_LEVEL 1 CACHE INTERNAL "." FORCE)
else ()
    set(TK_RELEASE_LEVEL 2 CACHE INTERNAL "." FORCE)
endif ()
string(REGEX REPLACE [[[\.ab]+]] "" TK_WIN_VERSION_PATCH "${TK_PATCH_LEVEL}")
set(TK_WIN_VERSION
    "${TK_VERSION}.${TK_RELEASE_LEVEL}.${TK_WIN_VERSION_PATCH}"
    CACHE INTERNAL
    "The version used by the wish.exe.manifest file"
    FORCE
    )
message(STATUS "Configuring wish.exe manifest to ${TCL_TARGET_ARCH}")
configure_file(manifest/wish.exe.manifest.in
               manifest/wish.exe.manifest
               @ONLY
               )

target_sources(wish PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/manifest/wish.exe.manifest")

## Configuration ###############################################################
target_compile_definitions(tk_config INTERFACE
                           $<$<NOT:$<BOOL:${HAVE_STRTOI64}>>:NO_STRTOI64=1>
                           $<$<BOOL:${HAVE_UXTHEME_H}>:HAVE_UXTHEME_H=1>
                           $<$<BOOL:${HAVE_VSSYM32_H}>:HAVE_VSSYM32_H=1>
                           )

target_include_directories(tk_config INTERFACE
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/rc>
                           )

target_link_options(tk_config INTERFACE
                    $<$<C_COMPILER_ID:GNU,Clang>:-municode>
                    )
target_link_options(tkstub PRIVATE
                    $<$<C_COMPILER_ID:MSVC>:-nodefaultlib>
                    )
target_link_options(wish PRIVATE
                    $<$<C_COMPILER_ID:GNU,Clang>:-mwindows>
                    )

target_link_libraries(tk_config INTERFACE
                      netapi32 kernel32 user32 advapi32 userenv ws2_32 gdi32
                      comdlg32 imm32 comctl32 shell32 uuid ole32 oleaut32
                      )
