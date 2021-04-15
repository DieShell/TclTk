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
# wish and tcl libs
add_executable(wish ${TCL_EXE})
add_library(tk ${TCL_BUILD_TYPE})
add_library(tkstub STATIC)

# pseudo-target to contain the configuration settings
add_library(tk_config INTERFACE)

# link all the things together
target_link_libraries(wish PRIVATE tk tkstub)
target_link_libraries(tk PRIVATE tkstub)

target_link_libraries(wish PUBLIC tk_config)
target_link_libraries(tk PUBLIC tk_config)
target_link_libraries(tkstub PUBLIC tk_config)

target_link_libraries(tk_config INTERFACE
                      tcl_config
                      tclstub
                      tcl
                      )

# proper output names
set_target_properties(wish PROPERTIES
                      OUTPUT_NAME "wish${TK_DOUBLE_VERSION}"
                      POSITION_INDEPENDENT_CODE TRUE
                      INSTALL_RPATH "\$ORIGIN:\$ORIGIN/../lib"
                      )
set_target_properties(tk PROPERTIES
                      PREFIX ""
                      OUTPUT_NAME "tk${TK_DOUBLE_VERSION}"
                      POSITION_INDEPENDENT_CODE TRUE
                      INSTALL_RPATH "\$ORIGIN:\$ORIGIN/../lib"
                      )
set_target_properties(tkstub PROPERTIES
                      OUTPUT_NAME "tkstub${TK_DOUBLE_VERSION}"
                      POSITION_INDEPENDENT_CODE TRUE
                      )

# Add tktest if tests enabled
if (TCL_ENABLE_TESTS)
    add_executable(tktest)# ${TCL_EXE})

    target_link_libraries(tktest PRIVATE tk_config tkstub tk)

    set_target_properties(tktest PROPERTIES
                          OUTPUT_NAME "tktest${TK_DOUBLE_VERSION}"
                          POSITION_INDEPENDENT_CODE TRUE
                          COMPILE_DEFINITIONS "TK_TEST=1"
                          )

    if (CMAKE_C_COMPILER_ID STREQUAL "MSVC")
        add_custom_command(TARGET tktest POST_BUILD
                           COMMAND "${CMAKE_COMMAND}" -E copy $<TARGET_FILE:tcl> $<TARGET_FILE_DIR:tktest>
                           )
    endif ()
endif ()

## Platform independent sources ################################################
add_subdirectory(lib/compat_layer)
add_subdirectory(bitmaps)
add_subdirectory(lib/common)

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
works, great. If it does not, you found a platform which cannot build Tk.
Congratulations!
Also try the official distributions, maybe those, blessed with AutoTools lunacy,
can help you.]])
    endif ()

    add_subdirectory(lib/unix_backend)
endif ()

## CMake has issues remembering ##
# "old" CMake (<3.18) support
set_source_files_properties("${CMAKE_CURRENT_BINARY_DIR}/lib/common/src/tkMain2.c"
                            PROPERTIES
                            COMPILE_DEFINITIONS "UNICODE=1;_UNICODE=1"
                            )
set_source_files_properties("lib/win32_backend/src/winMain.c"
                            PROPERTIES
                            COMPILE_DEFINITIONS "UNICODE=1;_UNICODE=1"
                            )

set(TK_LIB_NAME "tk${TK_DOUBLE_VERSION}${CMAKE_SHARED_LIBRARY_SUFFIX}"
    CACHE INTERNAL "" FORCE
    )
set(TK_ACCESS_PATH ".. .. ${CMAKE_INSTALL_LIBDIR}")
configure_file(pkgIndex.tcl.in
               pkgIndex.tcl
               @ONLY
               )

## Tcl sources #################################################################
add_subdirectory(library)

## Tests #######################################################################
add_subdirectory(tests)

## Install #####################################################################
set(IS_IMP_LIB "$<NOT:$<STREQUAL:$<TARGET_LINKER_FILE_NAME:tk>,${CMAKE_STATIC_LIBRARY_PREFIX}$<TARGET_FILE_NAME:tk>${CMAKE_STATIC_LIBRARY_SUFFIX}>>")
set(IMPORT_LINK "${CMAKE_LINK_LIBRARY_FILE_FLAG}$<TARGET_LINKER_FILE_NAME:tk>")
set(DIRECT_LINK "${CMAKE_LINK_LIBRARY_FLAG}$<TARGET_LINKER_FILE_BASE_NAME:tk>")
set(TCL_LINK_FLAG "$<IF:${IS_IMP_LIB},${IMPORT_LINK},${DIRECT_LINK}>")

set(IS_IMP_LIB_S "$<NOT:$<BOOL:${CMAKE_LINK_LIBRARY_FLAG}>>")
set(IMPORT_LINK_S "${CMAKE_LINK_LIBRARY_FILE_FLAG}$<TARGET_LINKER_FILE_NAME:tkstub>")
set(DIRECT_LINK_S "${CMAKE_LINK_LIBRARY_FLAG}$<TARGET_LINKER_FILE_BASE_NAME:tkstub>")
set(TCLSTUB_LINK_FLAG "$<IF:${IS_IMP_LIB_S},${IMPORT_LINK_S},${DIRECT_LINK_S}>")

configure_file(tkConfig.sh.in
               tkConfig.sh.cmakein
               @ONLY
               )
file(GENERATE
     OUTPUT tkConfig.sh
     INPUT "${CMAKE_CURRENT_BINARY_DIR}/tkConfig.sh.cmakein"
     CONDITION "$<CONFIG:Release>"
     )

if (TCL_ENABLE_INSTALL)
    install(FILES
            "${CMAKE_CURRENT_BINARY_DIR}/pkgIndex.tcl"
            "${CMAKE_CURRENT_SOURCE_DIR}/lib/unix_backend/src/tkAppInit.c"
            DESTINATION "${CMAKE_INSTALL_LIBDIR}/tk${TK_VERSION}"
            )
    if (CMAKE_BUILD_TYPE STREQUAL "Release")
        install(FILES "${CMAKE_CURRENT_BINARY_DIR}/tkConfig.sh"
                DESTINATION "${CMAKE_INSTALL_LIBDIR}"
                )
    endif ()
    install(TARGETS tk wish tkstub
            RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
            ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
            )
endif ()
