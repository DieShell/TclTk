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

project(TEA-IncrTcl
        VERSION 4.2.1 # idk where to summon this from
        LANGUAGES C
        )
set(ITCL_VERSION "${PROJECT_VERSION}")
string(REPLACE "." "" ITCL_DOTLESS_VERSION "${ITCL_VERSION}")
set(ITCL_MAJOR_VERSION 4)
set(ITCL_MINOR_VERSION 2)
set(ITCL_RELEASE_LEVEL 2)
set(ITCL_RELEASE_SERIAL 0) # ??

## Target ######################################################################
add_library(tea_itcl SHARED
            src/itcl.h
            src/itcl2TclOO.h
            src/itclDecls.h
            src/itclInt.h
            src/itclIntDecls.h
            src/itclMigrate2TclCore.h
            src/itclTclIntStubsFcn.h

            src/itcl2TclOO.c
            src/itclBase.c
            src/itclBuiltin.c
            src/itclClass.c
            src/itclCmd.c
            src/itclEnsemble.c
            src/itclHelpers.c
            src/itclInfo.c
            src/itclLinkage.c
            src/itclMethod.c
            src/itclMigrate2TclCore.c
            src/itclObject.c
            src/itclParse.c
            src/itclResolve.c
            src/itclStubInit.c
            src/itclStubs.c
            src/itclTclIntStubsFcn.c
            #src/itclTestRegisterC.c
            src/itclUtil.c
            $<$<PLATFORM_ID:Windows>:${CMAKE_CURRENT_BINARY_DIR}/itcl.rc>
            $<$<PLATFORM_ID:Windows>:src/dllEntryPoint.c>
            )
add_library(tea_itclstub STATIC
            src/itclStubLib.c
            )
add_library(tea_itcl_config INTERFACE)

target_link_libraries(tea_itcl     PRIVATE tea_itcl_config)
target_link_libraries(tea_itclstub PRIVATE tea_itcl_config)

target_compile_definitions(tea_itcl_config INTERFACE
                           BUILD_itcl=1
                           USE_TCL_STUBS=1
                           USE_TCLOO_STUBS=1
                           MODULE_SCOPE=extern
                           "PACKAGE_NAME=\"itcl\""
                           "PACKAGE_VERSION=\"${ITCL_VERSION}\""
                           )
target_link_libraries(tea_itcl_config INTERFACE
                      tclstub
                      )

set_target_properties(tea_itcl PROPERTIES
                      PREFIX ""
                      OUTPUT_NAME "itcl${ITCL_DOTLESS_VERSION}"
                      POSITION_INDEPENDENT_CODE TRUE
                      )
set_target_properties(tea_itclstub PROPERTIES
                      OUTPUT_NAME "itclstub${ITCL_DOTLESS_VERSION}"
                      POSITION_INDEPENDENT_CODE TRUE
                      )
target_include_directories(tea_itcl_config INTERFACE
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
                           $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
                           )

## Configuration ###############################################################
set(PACKAGE_VERSION "${ITCL_VERSION}")
set(PKG_LIB_FILE "itcl${ITCL_DOTLESS_VERSION}${CMAKE_SHARED_LIBRARY_SUFFIX}")
configure_file(pkgIndex.tcl.in
               pkgIndex.tcl
               @ONLY
               )
configure_file(src/itcl.rc.in
               itcl.rc
               @ONLY
               )

## Tests #######################################################################
add_subdirectory(tests)

## Install #####################################################################
set(IS_IMP_LIB "$<NOT:$<STREQUAL:$<TARGET_LINKER_FILE_NAME:tea_itcl>,${CMAKE_STATIC_LIBRARY_PREFIX}$<TARGET_FILE_NAME:tea_itcl>${CMAKE_STATIC_LIBRARY_SUFFIX}>>")
set(IMPORT_LINK "${CMAKE_LINK_LIBRARY_FILE_FLAG}$<TARGET_LINKER_FILE_NAME:tea_itcl>")
set(DIRECT_LINK "${CMAKE_LINK_LIBRARY_FLAG}$<TARGET_LINKER_FILE_BASE_NAME:tea_itcl>")
set(ITCL_LINK_FLAG "$<IF:${IS_IMP_LIB},${IMPORT_LINK},${DIRECT_LINK}>")

set(IS_IMP_LIB_S "$<NOT:$<BOOL:${CMAKE_LINK_LIBRARY_FLAG}>>")
set(IMPORT_LINK_S "${CMAKE_LINK_LIBRARY_FILE_FLAG}$<TARGET_LINKER_FILE_NAME:tea_itclstub>")
set(DIRECT_LINK_S "${CMAKE_LINK_LIBRARY_FLAG}$<TARGET_LINKER_FILE_BASE_NAME:tea_itclstub>")
set(ITCLSTUB_LINK_FLAG "$<IF:${IS_IMP_LIB_S},${IMPORT_LINK_S},${DIRECT_LINK_S}>")

configure_file(itclConfig.sh.in
               itclConfig.sh.cmakein
               @ONLY
               )
file(GENERATE
     OUTPUT itclConfig.sh
     INPUT "${CMAKE_CURRENT_BINARY_DIR}/itclConfig.sh.cmakein"
     CONDITION "$<CONFIG:Release>"
     )

if (TCL_ENABLE_INSTALL)
    install(TARGETS tea_itcl tea_itclstub
            DESTINATION "${CMAKE_INSTALL_LIBDIR}/itcl${ITCL_VERSION}"
            )
    install(FILES
            "${CMAKE_CURRENT_BINARY_DIR}/pkgIndex.tcl"
            "${CMAKE_CURRENT_SOURCE_DIR}/tcl/itcl.tcl"
            "${CMAKE_CURRENT_SOURCE_DIR}/tcl/itclHullCmds.tcl"
            "${CMAKE_CURRENT_SOURCE_DIR}/tcl/itclWidget.tcl"
            DESTINATION
            "${CMAKE_INSTALL_LIBDIR}/itcl${ITCL_VERSION}"
            )
    if (CMAKE_BUILD_TYPE STREQUAL "Release")
        install(FILES "${CMAKE_CURRENT_BINARY_DIR}/itclConfig.sh"
                DESTINATION "${CMAKE_INSTALL_LIBDIR}/itcl${ITCL_VERSION}"
                )
    endif ()
endif ()
if (TCL_ENABLE_INSTALL_DEVELOPMENT)
    install(FILES
            "${CMAKE_CURRENT_SOURCE_DIR}/src/itcl.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/itcl2TclOO.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/itclDecls.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/itclInt.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/itclIntDecls.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/itclMigrate2TclCore.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/itclTclIntStubsFcn.h"
            DESTINATION
            "${CMAKE_INSTALL_INCLUDEDIR}"
            )
endif ()
