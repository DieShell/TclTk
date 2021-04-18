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
#
# utils.cmake --
#  Contains utility functionality for CMake used by TclTk

## tcl_install()
#
# An install wrapper that differentiates the different install types handled
# by TclTk CMake.
#
## Synopsis
# tcl_install(
#     [DEFAULT
#        [CONDITION <cond>]
#        <INSTALL_ARGS>]
#     [DEVELOPMENT
#        [CONDITION <cond>]
#        <INSTALL_ARGS>]
#     [RUNTIME
#        [CONDITION <cond>]
#        <INSTALL_ARGS>]
# )
#
# Where <INSTALL_ARGS> defines the arguments to pass to the native install
# command. <INSTALL_ARGS> are splint into multiple install commands on
# any of TARGETS, FILES, PROGRAMS, DIRECTORY, SCRIPT, CODE, EXPORT.
#
# A condition may be provided to each type of installation which is evaluated
# and if it returns a falsy value the whole type is ignored.
function(tcl_install)
    ## Helper functions ########################################################
    function(tcl_install_many)
        set(SPLIT_REGEX
            [[(TARGETS|FILES|PROGRAMS|DIRECTORY|SCRIPT|CODE|EXPORT)]]
            )

        set(INSTALL_CALLS "${ARGV}")
        list(TRANSFORM INSTALL_CALLS REPLACE "${SPLIT_REGEX}"
                                             "<SPLIT>;\\1"
                                     OUTPUT_VARIABLE INSTALL_SPLIT)
        list(JOIN INSTALL_SPLIT " " INSTALL_LIST_CALLS)
        string(REPLACE "<SPLIT>" ";" INSTALLS "${INSTALL_LIST_CALLS}")
        foreach (call IN LISTS INSTALLS)
            if (call STREQUAL "")
                continue()
            endif ()
            string(REPLACE " " ";" CALL_ARGS "${call}")
            install(${CALL_ARGS})
        endforeach ()
    endfunction()

    function(tcl_install_default)
        if ((NOT TCL_ENABLE_INSTALL)
            OR TCL_ENABLE_INSTALL_RUNTIME_ONLY)
            return ()
        endif ()
        cmake_parse_arguments(TIDEF
                              ""
                              "CONDITION"
                              ""
                              ${ARGV}
                              )
        if (TIDEF_CONDITION)
            if (${TIDEF_CONDITION})
                tcl_install_many(${TIDEF_UNPARSED_ARGUMENTS})
            endif ()
        else ()
            tcl_install_many(${TIDEF_UNPARSED_ARGUMENTS})
        endif ()
    endfunction()

    function(tcl_install_runtime)
        if (NOT TCL_ENABLE_INSTALL)
            return ()
        endif ()
        cmake_parse_arguments(TIRT
                              ""
                              "CONDITION"
                              ""
                              ${ARGV}
                              )
        if (TIRT_CONDITION)
            if (${TIRT_CONDITION})
                tcl_install_many(${TIRT_UNPARSED_ARGUMENTS})
            endif ()
        else ()
            tcl_install_many(${TIRT_UNPARSED_ARGUMENTS})
        endif ()
    endfunction()

    function(tcl_install_development)
        if (NOT TCL_ENABLE_INSTALL
            OR NOT TCL_ENABLE_INSTALL_DEVELOPMENT)
            return ()
        endif ()
        cmake_parse_arguments(TIDEV
                              ""
                              "CONDITION"
                              ""
                              ${ARGV}
                              )
        if (TIDEV_CONDITION)
            if (${TIDEV_CONDITION})
                tcl_install_many(${TIDEV_UNPARSED_ARGUMENTS})
            endif ()
        else ()
            tcl_install_many(${TIDEV_UNPARSED_ARGUMENTS})
        endif ()
    endfunction()

    macro(EMIT_ERROR MSG)
        message(FATAL_ERROR "tcl_install has encountered an error:\
${MSG}")
    endmacro()

    ## Argument parsing ########################################################
    cmake_parse_arguments(PARSE_ARGV 0 TI
                          ""
                          ""
                          "DEFAULT;RUNTIME_ONLY;DEVELOPMENT"
                          )
    if (TI_KEYWORDS_MISSING_VALUES)
        EMIT_ERROR("Values for the option(s): '${TI_KEYWORDS_MISSING_VALUES}' were not defined.")
    endif ()
    if (TI_UNPARSED_ARGUMENTS)
        EMIT_ERROR("unexpected argument(s): ${TI_UNPARSED_ARGUMENTS}")
    endif ()

    ## Body ####################################################################
    if (TI_DEFAULT)
        tcl_install_default(${TI_DEFAULT})
    endif ()

    if (TI_RUNTIME_ONLY)
        tcl_install_runtime(${TI_RUNTIME_ONLY})
    endif ()

    if (TI_DEVELOPMENT)
        tcl_install_development(${TI_DEVELOPMENT})
    endif ()
endfunction()
