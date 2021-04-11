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

## This file handles the common Tcl sources that are required on all platforms.

project(Tcl-Common C)

## Target #####################################################################
target_sources(tcl PRIVATE
               src/tcl.h src/tclAlloc.c src/tclAssembly.c src/tclAsync.c src/tclBasic.c
               src/tclBinary.c src/tclCkalloc.c src/tclClock.c src/tclCmdAH.c
               src/tclCmdIL.c src/tclCmdMZ.c src/tclCompCmds.c src/tclCompCmdsGR.c
               src/tclCompCmdsSZ.c src/tclCompExpr.c src/tclCompile.h src/tclCompile.c
               src/tclConfig.c src/tclDate.c src/tclDecls.h src/tclDictObj.c
               src/tclDisassemble.c src/tclEncoding.c src/tclEnsemble.c src/tclEnv.c
               src/tclEvent.c src/tclExecute.c src/tclFCmd.c src/tclFileName.c
               src/tclFileSystem.h src/tclGet.c src/tclHash.c src/tclHistory.c
               src/tclIndexObj.c src/tclInt.h src/tclIntDecls.h src/tclInterp.c
               src/tclIntPlatDecls.h src/tclIO.h src/tclIO.c src/tclIOCmd.c
               src/tclIOGT.c src/tclIORChan.c src/tclIORTrans.c src/tclIOSock.c
               src/tclIOUtil.c src/tclLink.c src/tclListObj.c src/tclLiteral.c
               src/tclLoad.c src/tclMain.c src/tclNamesp.c src/tclNotify.c
               src/tclObj.c src/tclOO.h src/tclOO.c src/tclOOBasic.c src/tclOOCall.c
               src/tclOODecls.h src/tclOODefineCmds.c src/tclOOInfo.c src/tclOOInt.h
               src/tclOOIntDecls.h src/tclOOMethod.c src/tclOOStubInit.c src/tclOptimize.c
               src/tclPanic.c src/tclParse.h src/tclParse.c src/tclPathObj.c
               src/tclPipe.c src/tclPkg.c src/tclPkgConfig.c src/tclPlatDecls.h
               src/tclPort.h src/tclPosixStr.c src/tclPreserve.c src/tclProc.c
               src/tclRegexp.h src/tclRegexp.c src/tclResolve.c src/tclResult.c
               src/tclScan.c src/tclStringObj.c src/tclStringRep.h src/tclStringTrim.h
               src/tclStrToD.c src/tclStubInit.c src/tclThread.c src/tclThreadAlloc.c
               src/tclThreadJoin.c src/tclThreadStorage.c src/tclTimer.c src/tclTomMath.h
               src/tclTomMathDecls.h src/tclTomMathInt.h src/tclTomMathInterface.c
               src/tclTrace.c src/tclUniData.c src/tclUtf.c src/tclUtil.c src/tclVar.c
               src/tclZlib.c src/regcomp.c src/regcustom.h src/regerror.c src/regerrs.h
               src/regex.h src/regexec.c src/regfree.c src/regguts.h
               )
target_sources(tclstub PRIVATE
               src/tclStubLib.c
               src/tclOOStubLib.c
               src/tclTomMathStubLib.c
               )
if (TARGET tcltest)
    target_sources(tcltest PRIVATE
                   src/tclTest.c
                   src/tclTestObj.c
                   src/tclTestProcBodyObj.c
                   src/tclThreadTest.c
                   )
endif ()

target_compile_definitions(tcl_config INTERFACE
                           MODULE_SCOPE=extern
                           "TCL_CFGVAL_ENCODING=\"${TCL_WITH_ENCODING}\""
                           $<$<BOOL:${TCL_ENABLE_UNLOAD_DLLS}>:TCL_UNLOAD_DLLS=1>
                           )
target_compile_definitions(tcl PRIVATE BUILD_tcl=1)
target_compile_definitions(tclstub PRIVATE BUILD_tcl=1)
target_compile_definitions(tcl_reg PRIVATE BUILD_tcl=1)
target_compile_definitions(tcl_dde PRIVATE BUILD_tcl=1)
if (TARGET tcltest)
    target_compile_definitions(tcltest PRIVATE BUILD_tcl=1)
endif ()
## Setting configuration values
target_include_directories(tcl_config INTERFACE
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
                           $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/tcl${TCL_DOUBLE_VERSION}/generic>
                           )

set(PKG_CONFIG_LIST
    "CFG_INSTALL_LIBDIR=\"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}\""
    "CFG_INSTALL_BINDIR=\"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}\""
    "CFG_INSTALL_SCRDIR=\"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/tcl${TCL_VERSION}\""
    "CFG_INSTALL_INCDIR=\"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}\""
    "CFG_INSTALL_DOCDIR=\"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_MANDIR}\""
    "CFG_RUNTIME_LIBDIR=\"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}\""
    "CFG_RUNTIME_BINDIR=\"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}\""
    "CFG_RUNTIME_SCRDIR=\"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/tcl${TCL_VERSION}\""
    "CFG_RUNTIME_INCDIR=\"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}\""
    "CFG_RUNTIME_DOCDIR=\"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_MANDIR}\""
    CACHE INTERNAL "")

if (TCL_ENABLE_INSTALL_DEVELOPMENT)
    install(FILES
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tcl.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclDecls.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclOO.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclOODecls.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclPlatDecls.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclTomMath.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclTomMathDecls.h"
            DESTINATION
            "${CMAKE_INSTALL_INCLUDEDIR}"
            )
    install(FILES
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tcl.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclDecls.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclFileSystem.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclInt.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclIntDecls.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclIntPlatDecls.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclIO.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclOO.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclOODecls.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclOOInt.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclOOIntDecls.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclParse.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclPlatDecls.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclPort.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclRegexp.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclStringRep.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclStringTrim.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclTomMath.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclTomMathDecls.h"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tclTomMathInt.h"
            DESTINATION
            "${CMAKE_INSTALL_INCLUDEDIR}/tcl${TCL_DOUBLE_VERSION}/generic"
            )
endif ()
