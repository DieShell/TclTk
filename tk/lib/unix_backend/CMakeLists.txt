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

## UNIX-ish OS specific Tk source files and configuration checks

## Target ######################################################################
target_sources(tk PRIVATE
               src/tkUnix.c src/tkUnix3d.c src/tkUnixButton.c
               src/tkUnixColor.c src/tkUnixConfig.c src/tkUnixCursor.c src/tkUnixDefault.h
               src/tkUnixDialog.c src/tkUnixDraw.c src/tkUnixEmbed.c src/tkUnixEvent.c
               src/tkUnixFocus.c src/tkUnixInit.c src/tkUnixInt.h src/tkUnixKey.c
               src/tkUnixMenu.c src/tkUnixPort.h src/tkUnixScrlbr.c src/tkUnixSelect.c
               src/tkUnixSend.c src/tkUnixWm.c src/tkUnixXId.c
               )
target_sources(wish PRIVATE
               src/tkAppInit.c
               )
if (TARGET tktest)
    target_sources(tktest PRIVATE
                   src/tkAppInit.c
                   )
endif ()

## Options #####################################################################
option(TK_ENABLE_XFT
       "Enable Xft support in Tk [On]" On
       )
option(TK_ENABLE_XSS
       "Enable Xss support in Tk [On]" On
       )

## System checks ###############################################################
cmake_push_check_state(RESET)

check_library_exists("Xbsd" "main" "" HAVE_XBSD)

check_struct_has_member("struct passwd" "pw_gecos" "pwd.h" HAVE_PW_GECOS)

find_package(X11 COMPONENTS Xft Xkb Xext Xss)
if (CMAKE_C_COMPILER_ID STREQUAL "GNU"
    OR CMAKE_C_COMPILER_ID MATCHES "Clang")
    list(APPEND CMAKE_REQUIRED_FLAGS "-Werror")
    list(APPEND CMAKE_REQUIRED_INCLUDES "${X11_INCLUDE_DIR}")
    list(APPEND CMAKE_REQUIRED_INCLUDES "${X11_Xkb_INCLUDE_PATH}")
    list(APPEND CMAKE_REQUIRED_LIBRARIES "${X11_LIBRARIES}")
    list(APPEND CMAKE_REQUIRED_LIBRARIES "${X11_Xkb_LIB}")
    check_c_source_compiles([[
        #include <X11/Xlib.h>
        int main() {
            (void)XKeycodeToKeysym(0,0,0);
        }
    ]] IS_XKEYCODETOKEYSYM_DEPRECATED)
endif ()

cmake_pop_check_state()

## Configuration ###############################################################
target_compile_definitions(tk_config INTERFACE
                           $<$<BOOL:${HAVE_PW_GECOS}>:HAVE_PW_GECOS=1>
                           $<$<BOOL:${X11_Xkb_FOUND}>:HAVE_XKBKEYCODETOKEYSYM=1>
                           $<$<BOOL:${IS_XKEYCODETOKEYSYM_DEPRECATED}>:XKBKEYCODETOKEYSYM_IS_DEPRECATED=1>
                           )
target_include_directories(tk_config INTERFACE
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
                           $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
                           )
if (TK_ENABLE_XFT)
    if (X11_Xft_FOUND)
        target_link_libraries(tk_config INTERFACE
                              X11::Xft
                              )
        set(TK_LIBS "${TK_LIBS};${X11_Xft_LIB}" CACHE INTERNAL "")
        target_compile_definitions(tk_config INTERFACE
                                   HAVE_XFT=1
                                   )
        target_sources(tk PRIVATE src/tkUnixRFont.c)
    else ()
        message(WARNING [[Xft was requested but CMake couldn't find it for us. Not using it.]])
        target_sources(tk PRIVATE src/tkUnixFont.c)
    endif ()
else ()
    target_sources(tk PRIVATE src/tkUnixFont.c)
endif ()

if (TK_ENABLE_XSS)
    if (X11_Xext_FOUND AND X11_Xss_FOUND)
        target_link_libraries(tk_config INTERFACE X11::Xext)
#        if (HAVE_WEAK_LINK) TODO
#        else ()
            target_link_libraries(tk_config INTERFACE X11::Xss)
#        endif ()
        set(TK_LIBS "${TK_LIBS};${X11_Xss_LIB};${X11_Xext_LIB}" CACHE INTERNAL "")
        target_compile_definitions(tk_config INTERFACE HAVE_XSS=1)
    else ()
        message(WARNING [[Xss was requested but CMake couldn't find it for us. Not using it.]])
    endif ()
endif ()

target_link_libraries(tk_config INTERFACE
                      $<$<BOOL:${HAVE_XBSD}>:Xbsd>
                      )
set(TK_LIBS "${TK_LIBS};$<$<BOOL:${HAVE_XBSD}>:Xbsd>" CACHE INTERNAL "")
