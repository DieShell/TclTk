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

## Checks some _r functions and generally thread safe alternatives to networking
# related functions

## Actual system checks ##
if (NOT DEFINED TCL_MTSAFE_GETHOSTBY_FUNCTIONS)
    set(TCL_MTSAFE_GETHOSTBY_FUNCTIONS 1 CACHE INTERNAL "" FORCE)
    execute_process(COMMAND uname -s
                    OUTPUT_VARIABLE TCL_SYS_NAME
                    )
    execute_process(COMMAND uname -r
                    OUTPUT_VARIABLE TCL_SYS_VERISON
                    )
    if (TCL_SYS_NAME STREQUAL "Darwin")
        string(REGEX REPLACE [[([0-9]+)\..*$]] "\\1" TCL_SYS_MAJOR "${TCL_SYS_VERISON}")
        if (TCL_SYS_MAJOR GREATER 5)
            set(HAVE_MTSAFE_GETHOSTBY_FUNCS 1 CACHE BOOL 
                "gethostby(name|addr) functions are MT-safe" FORCE)
        else ()
            set(HAVE_MTSAFE_GETHOSTBY_FUNCS 0 CACHE BOOL 
                "gethostby(name|addr) functions are MT-safe" FORCE)
        endif ()
    elseif (TCL_SYS_NAME STREQUAL "HP-UX")
        string(REGEX REPLACE [[B\.]]   "" TCL_SYS_MAJOR_0 "${TCL_SYS_VERISON}")
        string(REGEX REPLACE [[\..*$]] "" TCL_SYS_MAJOR   "${TCL_SYS_MAJOR_0}")
        if (TCL_SYS_MAJOR GREATER 10)
            set(HAVE_MTSAFE_GETHOSTBY_FUNCS 1 CACHE BOOL 
                "gethostby(name|addr) functions are MT-safe" FORCE)
        else ()
            set(HAVE_MTSAFE_GETHOSTBY_FUNCS 0 CACHE BOOL 
                "gethostby(name|addr) functions are MT-safe" FORCE)
        endif ()
    else ()
        set(HAVE_MTSAFE_GETHOSTBY_FUNCS 0 CACHE BOOL 
            "gethostby(name|addr) functions are MT-safe" FORCE)
    endif ()
endif ()
target_compile_definitions(tcl_config INTERFACE
                           $<$<BOOL:${HAVE_MTSAFE_GETHOSTBY_FUNCS}>:HAVE_MTSAFE_GETHOSTBYNAME=1>
                           $<$<BOOL:${HAVE_MTSAFE_GETHOSTBY_FUNCS}>:HAVE_MTSAFE_GETHOSTBYADDR=1>
                           )

## getpwuid_r 
check_symbol_exists("getpwuid_r" "pwd.h" HAVE_GETPWUID_R)
check_c_source_compiles([[
    #include <sys/types.h>
    #include <pwd.h>
    int 
    main() {
        uid_t u;
        struct passwd pw, *ppw;
        char buf[1024];
        (void) getpwuid_r(u, &pw, buf, sizeof(buf), &ppw);
    }
]] HAVE_GETPWUID_R_5)
check_c_source_compiles([[
    #include <sys/types.h>
    #include <pwd.h>
    int 
    main() {
        uid_t u;
        struct passwd pw;
        char buf[1024];
        (void) getpwuid_r(u, &pw, buf, sizeof(buf));
    }
]] HAVE_GETPWUID_R_4)
target_compile_definitions(tcl_config INTERFACE 
                           $<$<BOOL:${HAVE_GETPWUID_R}>:HAVE_GETPWUID_R=1>
                           $<$<BOOL:${HAVE_GETPWUID_R_4}>:HAVE_GETPWUID_R_4=1>
                           $<$<BOOL:${HAVE_GETPWUID_R_5}>:HAVE_GETPWUID_R_5=1>
                           )

## getpwnam_r 
check_symbol_exists("getpwnam_r" "pwd.h" HAVE_GETPWNAM_R)
check_c_source_compiles([[
    #include <sys/types.h>
    #include <pwd.h>
    int 
    main() {
        char *nam;
        struct passwd pw, *ppw;
        char buf[1];
        (void) getpwnam_r(nam, &pw, buf, sizeof(buf), &ppw);
    }
]] HAVE_GETPWNAM_R_5)
check_c_source_compiles([[
    #include <sys/types.h>
    #include <pwd.h>
    int 
    main() {
        char *nam;
        struct passwd pw;
        char buf[1];
        (void) getpwnam_r(nam, &pw, buf, sizeof(buf));
    }
]] HAVE_GETPWNAM_R_4)
target_compile_definitions(tcl_config INTERFACE 
                           $<$<BOOL:${HAVE_GETPWNAM_R}>:HAVE_GETPWNAM_R=1>
                           $<$<BOOL:${HAVE_GETPWNAM_R_4}>:HAVE_GETPWNAM_R_4=1>
                           $<$<BOOL:${HAVE_GETPWNAM_R_5}>:HAVE_GETPWNAM_R_5=1>
                           )
## getgrgid_r 
check_symbol_exists("getgrgid_r" "grp.h" HAVE_GETGRGID_R)
check_c_source_compiles([[
    #include <sys/types.h>
    #include <grp.h>
    int 
    main() {
        gid_t u;
        struct group gr, *pgr;
        char buf[1024];
        (void) getgrgid_r(u, &gr, buf, sizeof(buf), &pgr);
    }
]] HAVE_GETGRGID_R_5)
check_c_source_compiles([[
    #include <sys/types.h>
    #include <grp.h>
    int 
    main() {
        gid_t u;
        struct group gr;
        char buf[1024];
        (void) getgrgid_r(u, &gr, buf, sizeof(buf));
    }
]] HAVE_GETGRGID_R_4)
target_compile_definitions(tcl_config INTERFACE 
                           $<$<BOOL:${HAVE_GETGRGID_R}>:HAVE_GETGRGID_R=1>
                           $<$<BOOL:${HAVE_GETGRGID_R_4}>:HAVE_GETGRGID_R_4=1>
                           $<$<BOOL:${HAVE_GETGRGID_R_5}>:HAVE_GETGRGID_R_5=1>
                           )

## getgrnam_r 
check_symbol_exists("getgrnam_r" "grp.h" HAVE_GETGRNAM_R)
check_c_source_compiles([[
    #include <sys/types.h>
    #include <grp.h>
    int 
    main() {
        char *nam;
        struct group gr, *pgr;
        char buf[1];
        (void) getgrnam_r(nam, &gr, buf, sizeof(buf), &pgr);
    }
]] HAVE_GETGRNAM_R_5)
check_c_source_compiles([[
    #include <sys/types.h>
    #include <grp.h>
    int 
    main() {
        char *nam;
        struct group gr;
        char buf[1];
        (void) getgrnam_r(nam, &gr, buf, sizeof(buf));
    }
]] HAVE_GETGRNAM_R_4)
target_compile_definitions(tcl_config INTERFACE 
                           $<$<BOOL:${HAVE_GETGRNAM_R}>:HAVE_GETGRNAM_R=1>
                           $<$<BOOL:${HAVE_GETGRNAM_R_4}>:HAVE_GETGRNAM_R_4=1>
                           $<$<BOOL:${HAVE_GETGRNAM_R_5}>:HAVE_GETGRNAM_R_5=1>
                           )

## gethostbyaddr_r
check_symbol_exists("gethostbyaddr_r" "netdb.h" HAVE_GETHOSTBYADDR_R)
check_c_source_compiles([[
    #include <netdb.h>
    int
    main() {
        char addr[1];
        int type;
        struct hostent *host;
        char buf[1];
        int err;
        (void) gethostbyaddr_r(addr, sizeof(addr), type, host,
                               buf, sizeof(buf), &err);
    }
]] HAVE_GETHOSTBYADDR_R_7)
check_c_source_compiles([[
    #include <netdb.h>
    int
    main() {
        char addr[1];
        int type;
        struct hostent *host, *host_ptr;
        char buf[1];
        int err;
        (void) gethostbyaddr_r(addr, sizeof(addr), type, 
                               host, buf, sizeof(buf), 
                               &host_ptr, &err);
    }
]] HAVE_GETHOSTBYADDR_R_8)
target_compile_definitions(tcl_config INTERFACE 
                           $<$<BOOL:${HAVE_GETHOSTBYADDR_R}>:HAVE_GETHOSTBYADDR_R=1>
                           $<$<BOOL:${HAVE_GETHOSTBYADDR_R_7}>:HAVE_GETHOSTBYADDR_R_7=1>
                           $<$<BOOL:${HAVE_GETHOSTBYADDR_R_8}>:HAVE_GETHOSTBYADDR_R_8=1>
                           )

check_symbol_exists("gethostbyname_r" "netdb.h" HAVE_GETHOSTBYNAME_R)
check_c_source_compiles([[
    #include <netdb.h>
    int
    main() {
        char name[1];
        struct hostent *host;
        struct hostent_data data;
        (void) gethostbyname_r(name, host, &data);
    }
]] HAVE_GETHOSTBYNAME_R_3)
check_c_source_compiles([[
    #include <netdb.h>
    int
    main() {
        char name[1];
        struct hostent *host;
        char buf[1];
        int err;
        (void) gethostbyname_r(name, host, buf, sizeof(buf), &err);
    }
]] HAVE_GETHOSTBYNAME_R_5)
check_c_source_compiles([[
    #include <netdb.h>
    int
    main() {
        char name[1];
        struct hostent *host, *host_ptr;
        char buf[1];
        int err;
        (void) gethostbyname_r(name, host, buf, sizeof(buf), &host_ptr, &err);
    }
]] HAVE_GETHOSTBYNAME_R_6)

target_compile_definitions(tcl_config INTERFACE 
                           $<$<BOOL:${HAVE_GETHOSTBYNAME_R}>:HAVE_GETHOSTBYADDR_R=1>
                           $<$<BOOL:${HAVE_GETHOSTBYNAME_R_3}>:HAVE_GETHOSTBYADDR_R_3=1>
                           $<$<BOOL:${HAVE_GETHOSTBYNAME_R_5}>:HAVE_GETHOSTBYADDR_R_5=1>
                           $<$<BOOL:${HAVE_GETHOSTBYNAME_R_6}>:HAVE_GETHOSTBYADDR_R_6=1>
                           )
