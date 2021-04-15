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

## Targets #####################################################################
# tclsh and tcl libs
add_executable(tclsh)
add_library(tcl ${TCL_BUILD_TYPE})
add_library(tclstub STATIC)

# pseudo-target to contain the configuration settings
add_library(tcl_config INTERFACE)

# link all the things together
target_link_libraries(tclsh PUBLIC tcl tclstub)

target_link_libraries(tclsh PUBLIC tcl_config)
target_link_libraries(tcl PUBLIC tcl_config)
target_link_libraries(tclstub PUBLIC tcl_config)

# proper output names
set_target_properties(tclsh PROPERTIES
                      OUTPUT_NAME "tclsh${TCL_DOUBLE_VERSION}"
                      POSITION_INDEPENDENT_CODE TRUE
                      INSTALL_RPATH "\$ORIGIN:\$ORIGIN/../lib"
                      )
set_target_properties(tcl PROPERTIES
                      PREFIX ""
                      OUTPUT_NAME "tcl${TCL_DOUBLE_VERSION}"
                      POSITION_INDEPENDENT_CODE TRUE
                      INSTALL_RPATH "\$ORIGIN:\$ORIGIN/../lib"
                      )
set_target_properties(tclstub PROPERTIES
                      OUTPUT_NAME "tclstub${TCL_DOUBLE_VERSION}"
                      POSITION_INDEPENDENT_CODE TRUE
                      )

# config based on the environment
target_compile_definitions(tcl_config INTERFACE
                           TCL_CFG_DO64BIT=$<BOOL:${TCL_BUILD_64BIT}>
                           TCL_CFG_OPTIMIZED=$<NOT:$<CONFIG:Debug>>
                           )

# Add tcltest if tests enabled
if (TCL_ENABLE_TESTS)
    add_executable(tcltest)

    target_link_libraries(tcltest PUBLIC tcl_config tclstub tcl)

    set_target_properties(tcltest PROPERTIES
                          OUTPUT_NAME "tcltest${TCL_DOUBLE_VERSION}"
                          POSITION_INDEPENDENT_CODE TRUE
                          COMPILE_DEFINITIONS "TCL_TEST=1"
                          )
endif ()

# tcldde and tclreg are separate on Windows for reasons?
if (WIN32)
    add_library(tcl_dde SHARED)
    add_library(tcl_reg SHARED)

    target_link_libraries(tcl_reg PUBLIC tcl_config)
    target_link_libraries(tcl_dde PUBLIC tcl_config)

    if (TCL_BUILD_SHARED)
        target_link_libraries(tcl_dde PRIVATE tclstub)
        target_link_libraries(tcl_reg PRIVATE tclstub)
    endif ()
    target_link_libraries(tcl PUBLIC tcl_dde tcl_reg)

    set_target_properties(tcl_dde PROPERTIES
                          OUTPUT_NAME "tcldde${TCL_DDE_DOTLESS}"
                          PREFIX ""
                          POSITION_INDEPENDENT_CODE TRUE
                          )
    set_target_properties(tcl_reg PROPERTIES
                          OUTPUT_NAME "tclreg${TCL_REG_DOTLESS}"
                          PREFIX ""
                          POSITION_INDEPENDENT_CODE TRUE
                          )
endif ()

## Compatibility sources #######################################################
add_subdirectory(lib/compat_layer)

## Platform independent sources ################################################
include(lib/zlib.cmake)
add_subdirectory(lib/common)
add_subdirectory(lib/tommath)

## Platform specific sources ###################################################
if (WIN32)
    add_subdirectory(lib/win32_backend)
else ()
    if (APPLE)
        add_subdirectory(lib/macos_backend)
    endif ()

    if (NOT UNIX)
        message(WARNING
                [[CMake doesn't think your system is Windows, MacOS, or UNIX-ish. This may very
well be incorrect. For this reason we are proceeding as if on UNIX. If this
works, great. If it does not, you found a platform which cannot build Tcl.
Congratulations!
Also try the official distributions, maybe those, blessed with AutoTools lunacy,
can help you.]])
    endif ()

    add_subdirectory(lib/unix_backend)
endif ()

add_subdirectory(pkgs)
add_subdirectory(library)

## Package Configs ##
# CMake is stupid, and so is passing every config flag
# on the command line but I don't care at this point
set_source_files_properties(lib/common/src/tclPkgConfig.c
                            PROPERTIES
                            COMPILE_DEFINITIONS "${PKG_CONFIG_LIST}"
                            )

set_source_files_properties(lib/unix_backend/src/tclUnixInit.c
                            PROPERTIES
                            COMPILE_DEFINITIONS
                            "TCL_LIBRARY=\"${CMAKE_INSTALL_LIBDIR}/tcl${TCL_VERSION}\";TCL_PACKAGE_PATH=\"{${CMAKE_INSTALL_LIBDIR}}\""
                            )

## Tests #######################################################################
add_subdirectory(tests)

## Install #####################################################################
set(IS_IMP_LIB  "$<NOT:$<STREQUAL:$<TARGET_LINKER_FILE_NAME:tcl>,${CMAKE_STATIC_LIBRARY_PREFIX}$<TARGET_FILE_NAME:tcl>${CMAKE_STATIC_LIBRARY_SUFFIX}>>")
set(IMPORT_LINK "${CMAKE_LINK_LIBRARY_FILE_FLAG}$<TARGET_LINKER_FILE_NAME:tcl>")
set(DIRECT_LINK "${CMAKE_LINK_LIBRARY_FLAG}$<TARGET_LINKER_FILE_BASE_NAME:tcl>")
set(TCL_LINK_FLAG "$<IF:${IS_IMP_LIB},${IMPORT_LINK},${DIRECT_LINK}>")

set(IS_IMP_LIB_S "$<NOT:$<BOOL:${CMAKE_LINK_LIBRARY_FLAG}>>")
set(IMPORT_LINK_S "${CMAKE_LINK_LIBRARY_FILE_FLAG}$<TARGET_LINKER_FILE_NAME:tclstub>")
set(DIRECT_LINK_S "${CMAKE_LINK_LIBRARY_FLAG}$<TARGET_LINKER_FILE_BASE_NAME:tclstub>")
set(TCLSTUB_LINK_FLAG "$<IF:${IS_IMP_LIB_S},${IMPORT_LINK_S},${DIRECT_LINK_S}>")

set(LIB_SFX $<${IS_IMP_LIB}:${CMAKE_IMPORT_LIBRARY_SUFFIX}>)
configure_file(tclConfig.sh.in
               tclConfig.sh.cmakein
               @ONLY
               )
file(GENERATE
     OUTPUT tclConfig.sh
     INPUT "${CMAKE_CURRENT_BINARY_DIR}/tclConfig.sh.cmakein"
     CONDITION "$<CONFIG:Release>"
     )

if (TCL_ENABLE_INSTALL)
    install(TARGETS tcl tclsh tclstub
            RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
            ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
            )
    if (CMAKE_BUILD_TYPE STREQUAL Release)
        install(FILES
                "${CMAKE_CURRENT_BINARY_DIR}/tclConfig.sh"
                "${CMAKE_CURRENT_SOURCE_DIR}/tclooConfig.sh"
                DESTINATION "${CMAKE_INSTALL_LIBDIR}"
                )
    endif ()
    if (TARGET tcl_reg)
        install(TARGETS tcl_reg
                DESTINATION "${CMAKE_INSTALL_LIBDIR}/reg${TCL_REG_VERSION}"
                )
    endif ()
    if (TARGET tcl_dde)
        install(TARGETS tcl_dde
                DESTINATION "${CMAKE_INSTALL_LIBDIR}/dde${TCL_DDE_VERSION}"
                )
    endif ()
endif ()
