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
project(tcl-compat-layer C)

# Note: This header mimics the AutoTools checks done by Tcl and is no way a good
# way to handle configuration, because
# 1) even the official AutoTools docs say that most of these checks are 
# meaningless today, such as checking if string.h exists and contains memchr.
# This is even more utter nonsense, considering CMake itself probably wouldn't
# build on a system without a correct C89 string.h, even it CMake is C++;
# 2) because the Tcl build system doesn't correctly use a configured header file
# all flags are passed on the command line. This is not that big of a problem,
# considering modern systems are capable of handling long command line arguments,
# we still spam it with completely useless flags like HAVE_STRING_H which is 
# going to be true 99.9% of the cases.

include(ansic.cmake)
include(directory_io.cmake)
include(dynamic_loading.cmake)
include(endian.cmake)
include(extra_headers.cmake)
include(intptr_types.cmake)
include(rfc2553.cmake)
include(threading.cmake)
