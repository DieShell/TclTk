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

## MacOS specific Tk source files and configuration checks

## Target ######################################################################
set (TK_MACOS_OBJC_SOURCES 
     src/tkMacOSXBitmap.c src/tkMacOSXButton.c src/tkMacOSXClipboard.c 
     src/tkMacOSXColor.c src/tkMacOSXConfig.c src/tkMacOSXCursor.c 
     src/tkMacOSXDebug.c src/tkMacOSXDebug.h src/tkMacOSXDialog.c 
     src/tkMacOSXDraw.c src/tkMacOSXEmbed.c src/tkMacOSXEntry.c 
     src/tkMacOSXEvent.c src/tkMacOSXFont.c src/tkMacOSXHLEvents.c 
     src/tkMacOSXImage.c src/tkMacOSXInit.c src/tkMacOSXKeyboard.c 
     src/tkMacOSXKeyEvent.c src/tkMacOSXMenu.c src/tkMacOSXMenubutton.c 
     src/tkMacOSXMenus.c src/tkMacOSXMouseEvent.c src/tkMacOSXNotify.c 
     src/tkMacOSXRegion.c src/tkMacOSXScale.c src/tkMacOSXScrlbr.c 
     src/tkMacOSXSend.c src/tkMacOSXServices.c src/tkMacOSXSubwindows.c 
     src/tkMacOSXTest.c src/tkMacOSXWindowEvent.c src/tkMacOSXWm.c 
     src/tkMacOSXXStubs.c src/ttkMacOSXTheme.c
     CACHE INTERNAL "sources which need be ObjC" FORCE
     )
target_sources(tk PRIVATE 
               ${TK_MACOS_OBJC_SOURCES}
               )

## Options #####################################################################
option(TK_ENABLE_XFT
       "Enable Xft support in Tk [On]" On
       )
set(TK_USE_AQUA ${TK_ENABLE_AQUA})

## System checks ###############################################################
cmake_push_check_state(RESET)

check_include_file("AvailabilityMacros.h" HAVE_AVAILABILITY_MACROS_H)

check_struct_has_member("struct passwd" "pw_gecos" "pwd.h" HAVE_PW_GECOS)

if (CMAKE_C_COMPILER_ID STREQUAL "GNU"
    OR CMAKE_C_COMPILER_ID MATCHES "Clang")
    list(APPEND CMAKE_REQUIRED_FLAGS "-Werror")
endif ()

## Testing if Aqua can be built ##
if (TK_USE_AQUA)
    check_include_file("CoreFoundation/CoreFoundation.h" HAVE_COREFOUNDATION_H)
    if (NOT HAVE_COREFOUNDATION_H)
        message(WARNING "Aqua can only be used when CoreFoundation is available")
        set (TK_USE_AQUA OFF)
    endif ()
endif ()

if (TK_USE_AQUA)
    if (NOT IS_DIRECTORY "/System/Library/Frameworks/Cocoa.framework")
        message(WARNING "Aqua can only be used when Cocoa is available")
        set (TK_USE_AQUA OFF)
    endif ()
endif ()

if (TK_USE_AQUA)
    execute_process(COMMAND uname -r
                    COMMAND awk -F. "{print $1}"
                    OUTPUT_VARIABLE DARWIN_VERSION
                    )
    if (DARWIN_VERSION LESS 9)
        message(WARNING "Aqua can only be used on MacOS X 10.5+")
        set (TK_USE_AQUA OFF)
    endif ()
endif ()

## Other checks ##
check_c_source_compiles([[
    #ifdef __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__
    #    if __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ < 1050
    #        error __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ < 1050
    #    endif
    #elif MAC_OS_X_VERSION_MIN_REQUIRED < 1050
    #    error MAC_OS_X_VERSION_MIN_REQUIRED < 1050
    #endif
    #define _DARWIN_C_SOURCE 1
    #include <sys/cdefs.h>
    int main() {}
]] HAVE_DARWIN_SUSV3)

cmake_push_check_state(RESET) # do not -Werror

list (APPEND CMAKE_REQUIRED_LINK_OPTIONS "-weak-lm")
check_c_source_compiles([[
    #include <math.h>
    int main() {
        float f = sinf(1.0f);
    }
]] HAVE_WEAK_LINK)

cmake_pop_check_state()

check_c_source_compiles([[
    #ifdef __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__
    #   if __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ < 1020
    #       error __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ < 1020
    #   endif
    #elif MAC_OS_X_VERSION_MIN_REQUIRED < 1020
    #   error MAC_OS_X_VERSION_MIN_REQUIRED < 1020
    #endif
    int rand(void) __attribute__((weak_import)); 

    int main() {
        (void)rand();
    }
]] HAVE_WEAK_IMPORT)

## Windowing system specific libraries ##
if (TK_USE_AQUA)
    set (_CMAKE_FIND_FRAMEWORK "${CMAKE_FIND_FRAMEWORK}")
    set (CMAKE_FIND_FRAMEWORK ONLY)

    find_library(COCOA_FMW  Cocoa)
    find_library(CARBON_FMW Carbon)
    find_library(IOKIT_FMW  IOKit)
    target_link_libraries(tk PRIVATE
                          "${COCOA_FMW}" 
                          "${CARBON_FMW}" 
                          "${IOKIT_FMW}" 
                          )

    set (CMAKE_FIND_FRAMEWORK ${_CMAKE_FIND_FRAMEWORK})

    set (TK_WINDOWINGSYSTEM "AQUA")
else () # X11
    find_package(X11 COMPONENTS Xft Xkb Xext)
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

    set (TK_WINDOWINGSYSTEM "X11")
endif ()

cmake_pop_check_state()

## Configuration ###############################################################
foreach (loc 
         cs da de el en en_gb eo es fr hu it nl pl pt ru sv)
     set (CFBUNDLELOCALIZATIONS "${CFBUNDLELOCALIZATIONS}<string>${loc}</string>")
endforeach ()

string(TIMESTAMP TK_YEAR "%Y")
configure_file(Credits.html.in
               Credits.html
               @ONLY
               )
configure_file(src/Wish-Info.plist.in
               Wish-Info.plist
               @ONLY
               )
configure_file(src/Tk-Info.plist.in
               Tk-Info.plist.cmakein
               @ONLY
               )
file(GENERATE OUTPUT "$<CONFIG>/Tk-Info.plist"
     INPUT "${CMAKE_CURRENT_BINARY_DIR}/Tk-Info.plist.cmakein"
     )

target_compile_definitions(tk_config INTERFACE
                           $<$<BOOL:${HAVE_PW_GECOS}>:HAVE_PW_GECOS=1>
                           $<$<BOOL:${X11_Xkb_FOUND}>:HAVE_XKBKEYCODETOKEYSYM=1>
                           $<$<BOOL:${IS_XKEYCODETOKEYSYM_DEPRECATED}>:XKBKEYCODETOKEYSYM_IS_DEPRECATED=1>
                           $<$<BOOL:${HAVE_DARWIN_SUSV3}>:_DARWIN_C_SOURCE=1>
                           $<$<BOOL:${HAVE_COREFOUNDATION_H}>:HAVE_COREFOUNDATION=1>
                           )
target_include_directories(tk_config INTERFACE
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
                           $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
                           )

if (TARGET tk)
    target_link_options(tk PRIVATE 
                        -sectcreate __TEXT __info_plist "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/Tk-Info.plist"
                        )
endif ()
if (TARGET wish)
    target_link_options(wish PRIVATE 
                        -sectcreate __TEXT __credits_html "${CMAKE_CURRENT_BINARY_DIR}/Credits.html"
                        $<$<NOT:$<BOOL:${TK_BUILD_SHARED}>>:-ObjC>
                        )
endif ()

if (NOT TK_USE_AQUA)
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
endif ()
