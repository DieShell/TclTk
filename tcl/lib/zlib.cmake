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

if (NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/GetDependency.cmake")
    file(DOWNLOAD
         "https://raw.githubusercontent.com/bodand/GetDependency/master/cmake/GetDependency.cmake"
         "${CMAKE_CURRENT_BINARY_DIR}/GetDependency.cmake"
         )
endif ()
include("${CMAKE_CURRENT_BINARY_DIR}/GetDependency.cmake")

if (TCL_ENABLE_STATIC_ZLIB)
    set(Z_ENABLE_SHARED OFF CACHE BOOL "" FORCE)
    set(TCL_LINK_Z "z::zlibstatic" CACHE INTERNAL "")
else ()
    set(Z_ENABLE_STATIC OFF CACHE BOOL "" FORCE)
    set(TCL_LINK_Z "z::zlib" CACHE INTERNAL "")
endif ()
GetDependency(z
              REPOSITORY_URL "https://github.com/DieShell/zlib.git"
              VERSION "v1.2.11"
              )

target_link_libraries(tcl_config INTERFACE 
                      "${TCL_LINK_Z}"
                      $<$<BOOL:${TCL_BUILD_64BIT}>:z::z64>
                      )
