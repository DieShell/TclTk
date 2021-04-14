# TclTk

### Disclaimer

This Tcl distribution, if you can call it that, does not provide all the build functionality that the original Tcl
source distributions do: I see no chance of building Tcl on Ultrix, IRIX, AIX, OSF/1, VMS*, and other archaic/exotic
systems by using this project. (Even if the required system checks would be done correctly, whether CMake itself builds
on said platforms is most probably the tightest bottleneck.)

*: I do not know if Tcl by default builds on VMS or not. I know Perl5 does, so I guess Tcl does too?

## TclTk

This repository provides a CMake project for building Tcl (including core packages) and Tk.

Tcl/Tk is used by the optional GUI [DieShell/dsh](https://github.com/DieShell/dsh) provides and this project was born to
ease creating the installer for DieShell, by providing a homogenous CMake build environment for all DieShell and Tcl.

C and corresponding header sources are only minimally modified where include paths do not work properly with the
original relative include paths.

All AutoTools related build files are removed, with a few literally useless files which contain nothing;
Tcl's `threadUnix.c` file for example. (If I learn how to, I will send a patch about this latter change back to the Tcl
people.)

## CMake Targets

For use in other CMake projects, the following targets are defined for `target_link_libraries`.

- `tcl` The Tcl shared library
- `tclstub` The Tcl stub library
- `tk` The Tk shared library
- `tkstub` The Tk stub library

The `tclsh`, and `wish` executable targets may be used for custom commands that wish to rely on a fresh-baked Tcl
interpreter.

## License and copyright

Copyright (c) 2021, András Bodor <bodand@pm.me>

CMake files and other related new sources are licensed under the zlib license. 

Copyright (c) Regents of the University of California, Sun Microsystems, Inc., Scriptics Corporation, ActiveState
Corporation and other parties

Tcl sources and binaries are licensed under the Tcl license available in whichever `license.terms` file in the
repository.  
