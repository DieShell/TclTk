
The followings describe which subdirectory contains which source files
from the Tcl sources:

- compat_layer (CMake target: tcl_compat_layer)
  Contains compatibility cruft that needs to be figured out 
  for each system. For example dynamic loading is different for
  each system, even among the unices. This is first "configured"
  and other backends depend on macros and files this provides.
- osx_backend (CMake target: tcl_macos)
  Sources that are part of the MacOS implementation.
- win_backend (CMake target: tcl_win32)
  Sources that are part of the Windows implementation.
- unix_backend (CMake target: tcl_unix)
  Sources that are part the unices' implementation.
- common (CMake target: tcl_common_impl)
  Files common to all
- tommath (CMake target: tcl_tommath)
  Tcl's tommath library
