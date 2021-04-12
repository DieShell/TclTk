# testwrap.tcl --
#
# This file provides a wrapper around tktest to be run by CTest which (on Windows
# at least) cannot
#  - capture the output of tktest; OR
#  - apply a regular expression properly; OR
# tktest doesn't return the exit code with env(ERROR_ON_FAILURES).
# So this script is used to run the actual tktest executable, using the
# built tclsh executable.
#
# STDOUT
#   Prints the STDOUT from the invoked tktest as-is, without modifications.
#
# EXIT
#   Returns 0 for success and 1 for failures
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

if {[expr {$argc == 2}]} {
    if {[expr {[lindex $argv 0] eq {-ttk}}]} {
        set file [lindex $argv 1]
        set path {tests/ttk/all.tcl}
    } else {
        puts "warning: unrecognized option [lindex $argv 0] ignored"
        set file [lindex $argv 1]
        set path {tests/all.tcl}
    }
} elseif {[expr {$argc == 1}]} {
    set file [lindex $argv 0]
    set path {tests/all.tcl}
} else {
    puts "error: invalid command line arguments"
    puts "usage: $argv0 ?-ttk? test-file"
    exit -1
}

set result [exec ./tktest86 $path -file $file]

puts $result
if {[regexp {Failed\s*[1-9]} $result]} {
    exit 1
}
exit 0
