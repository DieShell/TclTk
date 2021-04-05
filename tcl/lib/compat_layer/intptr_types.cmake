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

function (check_intptr_type tgt type)
    string(TOUPPER "${type}" type_var)
    check_type_size("${type}" "${type_var}")

    if ("${HAVE_${type_var}}")
        target_compile_definitions("${tgt}" INTERFACE
                                   "HAVE_${type_var}"
                                   )
        return ()
    endif ()

    foreach (fallback IN LISTS ARGN)
        if (fallback STREQUAL "FALLBACK")
            continue()
        endif ()
        string(MAKE_C_IDENTIFIER fb_id "${fallback}")
        if (NOT "$CACHE{CHECKED_${fb_id}_FOR_${type_var}}")
            file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/compile-${fallback}.c"
                 "int main() { return sizeof(void*) <= sizeof(${fallback}); }"
                 )

            try_run("${fb_id}_CAN_STORE_PTR"
                    "${fb_id}_BUILT"
                    "${CMAKE_CURRENT_BINARY_DIR}"
                    "${CMAKE_CURRENT_BINARY_DIR}/compile-${fallback}.c"
                    )
            set("CHECKED_${fb_id}_FOR_${type_var}" 1 CACHE INTERNAL "Checked type ${fallback} for filling in for non-existent ${type}")

            if ("${${fb_id}_BUILT}" AND ("${${fb_id}_CAN_STORE_PTR}" EQUAL 1))
                target_compile_definitions("${tgt}" INTERFACE )
                return ()
            endif ()
        endif ()
    endforeach ()
endfunction ()

check_intptr_type(tcl_config "intptr_t"
                  FALLBACK "int"
                  FALLBACK "long" 
                  FALLBACK "long long"
                  )
check_intptr_type(tcl_config "uintptr_t"
                  FALLBACK "unsigned"
                  FALLBACK "unsigned long" 
                  FALLBACK "unsigned long long"
                  )
