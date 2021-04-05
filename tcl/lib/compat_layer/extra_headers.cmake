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

# This file does extra checks about some headers which may or may not exist

## System checks ###############################################################
cmake_push_check_state(RESET)

check_include_file("stdint.h"    HAVE_STDINT_H)
check_include_file("stdbool.h"   HAVE_STDBOOL_H)
check_include_file("memory.h"    HAVE_MEMORY_H)
check_include_file("strings.h"   HAVE_STRINGS_H)
check_include_file("sys/stat.h"  HAVE_SYS_STAT_H)
check_include_file("sys/types.h" HAVE_SYS_TYPES_H)
check_include_file("sys/time.h"  HAVE_SYS_TIME_H)
check_include_file("sys/param.h" HAVE_SYS_PARAM_H)
check_include_file("inttypes.h"  HAVE_INTTYPES_H)

cmake_pop_check_state()

## Add to targets ##############################################################
target_compile_definitions(tcl_config INTERFACE
                           $<$<BOOL:${HAVE_STDINT_H}>:HAVE_STDINT_H=1>
                           $<$<BOOL:${HAVE_STDBOOL_H}>:HAVE_STDBOOL_H=1>
                           $<$<BOOL:${HAVE_MEMORY_H}>:HAVE_MEMORY_H=1>
                           $<$<BOOL:${HAVE_STRINGS_H}>:HAVE_STRINGS_H=1>
                           $<$<BOOL:${HAVE_SYS_TYPES_H}>:HAVE_SYS_TYPES_H=1>
                           $<$<BOOL:${HAVE_SYS_STAT_H}>:HAVE_SYS_STAT_H=1>
                           $<$<BOOL:${HAVE_SYS_TIME_H}>:HAVE_SYS_TIME_H=1>
                           $<$<BOOL:${HAVE_SYS_PARAM_H}>:HAVE_SYS_PARAM_H=1>
                           $<$<BOOL:${HAVE_INTTYPES_H}>:HAVE_INTTYPES_H=1>
                           )

