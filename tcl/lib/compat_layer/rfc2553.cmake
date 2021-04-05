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

## This file handles if sys/types.h, sys/socket.h, and/or netdb.h define 
# the following
# types: sockaddr_storage, in6_addr, sockaddr_in6, addrinfo; and
# functions: getaddrinfo, gai_strerror, freeaddrinfo, getnameinfo
# If any is missing, we provide a makeshift solution that allows ssh.

# On Windows this file is ignored
if (WIN32)
    return()
endif ()

cmake_check_state_push(RESET)
## Headers #####################################################################
check_include_file("sys/types.h"  HAVE_SYS_TYPES_H)
check_include_file("sys/socket.h" HAVE_SYS_SOCKET_H)
check_include_file("netdb.h"      HAVE_NETDB_H)

if (HAVE_SYS_TYPES_H)
    list(APPEND CMAKE_EXTRA_INCLUDE_FILES "sys/types.h")
endif ()
if (HAVE_SYS_SOCKET_H)
    list(APPEND CMAKE_EXTRA_INCLUDE_FILES "sys/socket.h")
endif ()
if (HAVE_NETDB_H)
    list(APPEND CMAKE_EXTRA_INCLUDE_FILES "netdb.h")
endif ()

## Types #######################################################################
check_type_size("struct sockaddr_storage" STRUCT_SOCKADDR_STORAGE)
check_type_size("struct in6_addr"         STRUCT_IN6_ADDR)
check_type_size("struct sockaddr_in6"     STRUCT_SOCKADDR_IN6)
check_type_size("struct addrinfo"         STRUCT_ADDRINFO)
if (HAVE_STRUCT_ADDRINFO 
    AND HAVE_STRUCT_IN6_ADDR
    AND HAVE_STRUCT_SOCKADDR_IN6
    AND HAVE_STRUCT_SOCKADDR_STORAGE)
    set(_TCL_HAVE_RFC_TYPES 1)
else ()
    set(_TCL_HAVE_RFC_TYPES 0)
endif ()

## Functions ###################################################################
check_symbol_exists("getaddrinfo"  "${CMAKE_EXTRA_INCLUDE_FILES}" HAVE_GETADDRINFO)
check_symbol_exists("gai_strerror" "${CMAKE_EXTRA_INCLUDE_FILES}" HAVE_GAI_STRERROR)
check_symbol_exists("freeaddrinfo" "${CMAKE_EXTRA_INCLUDE_FILES}" HAVE_FREEADDRINFO)
check_symbol_exists("getnameinfo"  "${CMAKE_EXTRA_INCLUDE_FILES}" HAVE_GETNAMEINFO)

if (HAVE_GETADDRINFO
    AND HAVE_GAI_STRERROR
    AND HAVE_FREEADDRINFO
    AND HAVE_GETNAMEINFO)
    set (_TCL_HAVE_RFC_FUNCS 1)
else ()
    set (_TCL_HAVE_RFC_FUNCS 0)
endif ()

cmake_check_state_pop()

# if we have everything we need, do not do anything
if (_TCL_HAVE_RFC_FUNCS AND _TCL_HAVE_RFC_TYPES)
    return ()
endif ()

## Target ######################################################################
target_include_directories(tcl_config PUBLIC
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/rfc2553>
                           $<INSTALL_INTERFACE:include>
                           )
target_compile_definitions(tcl_config PUBLIC 
                           NEED_FAKE_RFC2553
                           )

target_sources(tcl_config PRIVATE src/rfc2553/fake-rfc2553.c)

if (TCL_ENABLE_INSTALL_DEVELOPMENT)
    install(FILES 
            "${CMAKE_CURRENT_SOURCE_DIR}/src/rfc2553/compat/fake-rfc2553.h"
            DESTINATION
            "${CMAKE_INSTALL_INCLUDEDIR}/compat"
            )
endif ()
