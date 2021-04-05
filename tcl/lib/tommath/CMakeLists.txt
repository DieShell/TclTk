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

## Create the static tommath library and make it available for consumption.

project(tcl_tommath C)

## System checks ##############################################################
cmake_push_check_state(RESET)

# Includes 
check_include_file("stdint.h" HAVE_STDINT_H)
check_include_file("stdio.h"  HAVE_STDIO_H)
list(APPEND CMAKE_EXTRA_INCLUDE_FILES "stdio.h")

# Types
check_type_size("FILE" STDIO_FILE)

cmake_pop_check_state()

## Options ####################################################################
set(TCL_MP_PRECISION 4 CACHE STRING 
    "The precision used in tommath [4]"
    )

## Target #####################################################################
target_sources(tcl PRIVATE
               src/bn_mp_add.c
               src/bn_mp_add_d.c
               src/bn_mp_and.c
               src/bn_mp_clamp.c
               src/bn_mp_clear.c
               src/bn_mp_clear_multi.c
               src/bn_mp_cmp.c
               src/bn_mp_cmp_d.c
               src/bn_mp_cmp_mag.c
               src/bn_mp_cnt_lsb.c
               src/bn_mp_copy.c
               src/bn_mp_count_bits.c
               src/bn_mp_div.c
               src/bn_mp_div_d.c
               src/bn_mp_div_2.c
               src/bn_mp_div_2d.c
               src/bn_mp_div_3.c
               src/bn_mp_exch.c
               src/bn_mp_expt_u32.c
               src/bn_mp_grow.c
               src/bn_mp_init.c
               src/bn_mp_init_copy.c
               src/bn_mp_init_multi.c
               src/bn_mp_init_set.c
               src/bn_mp_init_size.c
               src/bn_mp_lshd.c
               src/bn_mp_mod.c
               src/bn_mp_mod_2d.c
               src/bn_mp_mul.c
               src/bn_mp_mul_d.c
               src/bn_mp_mul_2.c
               src/bn_mp_mul_2d.c
               src/bn_mp_neg.c
               src/bn_mp_or.c
               src/bn_mp_radix_size.c
               src/bn_mp_radix_smap.c
               src/bn_mp_read_radix.c
               src/bn_mp_rshd.c
               src/bn_mp_set.c
               src/bn_mp_shrink.c
               src/bn_mp_sqr.c
               src/bn_mp_sqrt.c
               src/bn_mp_sub.c
               src/bn_mp_sub_d.c
               src/bn_mp_signed_rsh.c
               src/bn_mp_to_ubin.c
               #src/bn_mp_to_sbin.c
               src/bn_mp_to_radix.c
               src/bn_mp_ubin_size.c
               src/bn_mp_xor.c
               src/bn_mp_zero.c
               src/bn_s_mp_add.c
               src/bn_s_mp_balance_mul.c
               src/bn_s_mp_karatsuba_mul.c
               src/bn_s_mp_karatsuba_sqr.c
               src/bn_s_mp_mul_digs.c
               src/bn_s_mp_mul_digs_fast.c
               src/bn_s_mp_reverse.c
               src/bn_s_mp_sqr_fast.c
               src/bn_s_mp_sqr.c
               src/bn_s_mp_sub.c
               src/bn_s_mp_toom_mul.c
               src/bn_s_mp_toom_sqr.c
               
               src/tommath.h
               src/tommath_class.h
               src/tommath_cutoffs.h
               src/tommath_private.h
               src/tommath_superclass.h
               )

target_compile_definitions(tcl_config INTERFACE
                           $<$<NOT:$<BOOL:${HAVE_STDIO_FILE}>>:MP_NO_FILE>
                           MP_NO_STDINT=1
                           TCL_TOMMATH=1
                           MP_FIXED_CUTOFFS=1
                           "MP_PREC=${TCL_MP_PRECISION}"
                           )
target_include_directories(tcl_config INTERFACE 
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
                           $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/tcl${TCL_DOUBLE_VERSION}/generic>
                           )

if (TCL_ENABLE_INSTALL_DEVELOPMENT)
    install(FILES 
            "src/tommath.h"
            DESTINATION
            "${CMAKE_INSTALL_INCLUDEDIR}/tcl${TCL_DOUBLE_VERSION}/generic"
            )
endif ()
