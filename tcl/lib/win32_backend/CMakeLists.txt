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

## Windows specific Tcl source files and configuration checks

## Target ######################################################################
target_sources(tcl PRIVATE
               src/tcl.rc
               src/tclWin32Dll.c
               src/tclWinChan.c
               src/tclWinConsole.c
               src/tclWinSerial.c
               src/tclWinError.c
               src/tclWinFCmd.c
               src/tclWinFile.c
               src/tclWinInit.c
               src/tclWinNotify.c
               src/tclWinPipe.c
               src/tclWinSock.c
               #src/tclWinTest.c
               src/tclWinThrd.c
               src/tclWinTime.c
               
               src/tclWinInt.h
               src/tclWinPort.h
               )
target_sources(tclsh PRIVATE
               src/tclAppInit.c
               src/tclsh.rc
               )
target_sources(tcl_reg PRIVATE src/tclWinReg.c)
target_sources(tcl_dde PRIVATE src/tclWinDde.c)

#if (NOT TCL_BUILD_SHARED)
#    target_sources(tcl PUBLIC 
#                   src/tclWinReg.c
#                   src/tclWinDde.c
#                   )
#else ()
#    target_sources(tclsh PUBLIC 
#                   src/tclWinReg.c
#                   src/tclWinDde.c
#                   )
#endif ()

file (COPY 
      "${CMAKE_CURRENT_SOURCE_DIR}/../common/src/tclMain.c"
      DESTINATION
      "${CMAKE_CURRENT_BINARY_DIR}"
      )
target_sources(tcl PRIVATE 
               "${CMAKE_CURRENT_BINARY_DIR}/tclMain.c"
               )
set_source_files_properties("${CMAKE_CURRENT_BINARY_DIR}/tclMain.c" 
                            src/tclAppInit.c
                            TARGET_DIRECTORY tcl
                            PROPERTIES
                                COMPILE_DEFINITIONS "UNICODE=1;_UNICODE=1"
                            )

## Options #####################################################################
option(TCL_ENABLE_TIME64BIT 
       "Force 64-bit time in 32-bit applications [On]" On
       )
set(TCL_WITH_ENCODING "cp1252" CACHE STRING 
    "The encoding to use (--with-encoding=) [cp1252]"
    )

## System checks ###############################################################
cmake_push_check_state(RESET)

## headers ##
check_include_file("wspiapi.h"  HAVE_WSPIAPI_H)

## compiles ##
check_c_source_compiles([[
#define WIN32_LEAN_AND_MEAN
#include <windows.h>

int main() {
    FINDEX_INFO_LEVELS info;
    FINDEX_SEARCH_OPS ops;
}
]] HAVE_FINDEX_ENUMS)

check_c_source_compiles([[
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <intrin.h>

int main() { __cpuidex(0, 0, 0); }
]] HAVE_INTRIN_H)

check_c_source_compiles([[
#include <stdio.h>
extern int divsor;

int main() {
    __try {
        int x = 1 / divsor;
    } 
    __except(GetExceptionCode() == EXCEPTION_INT_DIVIDE_BY_ZERO ?
             EXCEPTION_EXECUTE_HANDLER :
             EXCEPTION_CONTINUE_SEARCH) {
        printf("you cannot divide by zero");
    }
}   
]] HAVE_STRUCTURED_EH)

# Note: This only checks the following four architectures: 
# x86, x86-64, ARM, and ARM64
# since Windows only runs on those arches. All other arches that may get Windows
# support in the future need to be checked here additionally.
if (NOT DEFINED TCL_TARGET_ARCH)
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/which-arch.c"
    [[#include <stdio.h>
    int
    main() {
    /* x86-64 */
    #if defined(__amd64__) || defined(__amd64) || defined(__x86_64__) \
        || defined(__x86_64) || defined(__x64__) || defined(__x64) \
        || defined(_M_AMD64) || defined(_M_X64)
        printf("amd64");
    /* x86 */
    #elif defined(__i386__) || defined(__i386) || defined(i386) \
          || defined(_M_IX86) || defined(__X86__) || defined(_X86_) \
          || defined(__THW_INTEL__) || defined(__I86__) || defined(__INTEL__) \
          || defined(__386) || defined(__IA32__)
        printf("x86");
    /* ARM64 */
    #elif defined(__aarch64__) || defined(_M_ARM64) || defined(__arm64__) \
          || defined(_ARM64)
        printf("arm64");
    /* ARM */
    #elif defined(__arm__) || defined(__TARGET_ARCH_ARM) || defined(_ARM) \
          || defined(_M_ARM) || defined(__arm)
        printf("arm");
    #endif
    }
    ]])
    try_run(_whatever _ignore
            "${CMAKE_CURRENT_BINARY_DIR}"
            "${CMAKE_CURRENT_BINARY_DIR}/which-arch.c"
            RUN_OUTPUT_VARIABLE TCL_TARGET_ARCH
            )
endif ()

cmake_pop_check_state()

## Manifests ###################################################################
if (TCL_PATCH_LEVEL MATCHES [[a]])
    set(TCL_RELEASE_LEVEL 0 CACHE INTERNAL "." FORCE)
elseif (TCL_PATCH_LEVEL MATCHES [[b]])
    set(TCL_RELEASE_LEVEL 1 CACHE INTERNAL "." FORCE)
else ()
    set(TCL_RELEASE_LEVEL 2 CACHE INTERNAL "." FORCE)
endif ()
string(REGEX REPLACE [[[\.ab]+]] "" TCL_WIN_VERSION_PATCH "${TCL_PATCH_LEVEL}")
set(TCL_WIN_VERSION 
    "${TCL_VERSION}.${TCL_RELEASE_LEVEL}.${TCL_WIN_VERSION_PATCH}"
    CACHE INTERNAL
    "The version used by the tclsh.exe.manifest file"
    FORCE
    )
message(STATUS "Configuring manifest to ${TCL_TARGET_ARCH}")
configure_file(manifest/tclsh.exe.manifest.in
               tclsh.exe.manifest
               @ONLY
               )

target_sources(tclsh PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/tclsh.exe.manifest")
if (TCL_BUILD_SHARED)
    target_sources(tcl     PRIVATE manifest/tcl86.dll.manifest)
    target_sources(tcl_dde PRIVATE manifest/tcldde14.dll.manifest)
    target_sources(tcl_reg PRIVATE manifest/tclreg13.dll.manifest)
endif ()

target_compile_definitions(tcl_config INTERFACE 
                           $<$<C_COMPILER_ID:MSVC>:inline=__inline>
                           HAVE_NO_SEH=$<NOT:$<BOOL:${HAVE_STRUCTURED_EH}>>
                           HAVE_ZLIB=1
                           $<$<BOOL:${TCL_ENABLE_TIME64BIT}>:_USE_64BIT_TIME_T>
                           $<$<NOT:$<BOOL:${HAVE_FINDEX_ENUMS}>>:HAVE_NO_FINDEX_ENUMS>
                           $<$<BOOL:${HAVE_INTRIN_H}>:HAVE_INTRIN_H>
                           $<$<BOOL:${HAVE_WSPIAPI_H}>:HAVE_WSPIAPI_H>
                           )

target_include_directories(tcl_config INTERFACE
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/manifest>
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
                           $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/tcl${TCL_DOUBLE_VERSION}/win>
                           )
target_include_directories(tcl_public INTERFACE
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
                           $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/tcl${TCL_DOUBLE_VERSION}/win>
                           )

target_link_options(tcl_config INTERFACE
                    $<$<C_COMPILER_ID:GNU,Clang>:-municode>
                    )
target_link_options(tclsh PRIVATE
                    $<$<C_COMPILER_ID:GNU,Clang>:-mconsole>
                    )

target_link_libraries(tcl_config INTERFACE kernel32 ws2_32 netapi32 userenv user32 advapi32)

if (TCL_ENABLE_INSTALL_DEVELOPMENT)
    install(FILES
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclWinInt.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclWinPort.h"
            DESTINATION
            "${CMAKE_INSTALL_INCLUDEDIR}/tcl${TCL_DOUBLE_VERSION}/win"
            )
endif ()
