## This file enumerates variables from the LLVM configuration so that they
## can be in exported headers and won't override package specific directives.

var
  LLVM_BINDIR* {.importc, header: "<llvm/Config/llvm-config.h>".}: cstring
    ## Installation directory for binary executables

  LLVM_CONFIGTIME* {.importc, header: "<llvm/Config/llvm-config.h>".}: cstring
    ## Time at which LLVM was configured

  LLVM_DATADIR* {.importc, header: "<llvm/Config/llvm-config.h>".}: cstring
    ## Installation directory for data files

  LLVM_DEFAULT_TARGET_TRIPLE* {.importc, header: "<llvm/Config/llvm-config.h>".}: cstring
    ## Target triple LLVM will generate code for by default

  LLVM_DOCSDIR* {.importc, header: "<llvm/Config/llvm-config.h>".}: cstring
    ## Installation directory for documentation

  LLVM_ENABLE_THREADS* {.importc, header: "<llvm/Config/llvm-config.h>".}: cint
    ## Define if threads enabled

  LLVM_ETCDIR* {.importc, header: "<llvm/Config/llvm-config.h>".}: cstring
    ## Installation directory for config files

  LLVM_HAS_ATOMICS* {.importc, header: "<llvm/Config/llvm-config.h>".}: cint
    ## Has gcc/MSVC atomic intrinsics

  LLVM_HOST_TRIPLE* {.importc, header: "<llvm/Config/llvm-config.h>".}: cstring
    ## Host triple LLVM will be executed on

  LLVM_INCLUDEDIR* {.importc, header: "<llvm/Config/llvm-config.h>".}: cstring
    ## Installation directory for include files

  LLVM_INFODIR* {.importc, header: "<llvm/Config/llvm-config.h>".}: cstring
    ## Installation directory for .info files

  LLVM_MANDIR* {.importc, header: "<llvm/Config/llvm-config.h>".}: cstring
    ## Installation directory for man pages

  LLVM_NATIVE_ARCH* {.importc, header: "<llvm/Config/llvm-config.h>".}: proc () {.cdecl.}
    ## LLVM architecture name for the native architecture, if available

when defined(dynamic_link) or defined(static_link):
  var
    LLVM_NATIVE_ASMPARSER* {.importc, header: "<llvm/Config/llvm-config.h>".}: proc () {.cdecl.}
      ## LLVM name for the native AsmParser init function, if available

    LLVM_NATIVE_ASMPRINTER* {.importc, header: "<llvm/Config/llvm-config.h>".}: proc () {.cdecl.}
      ## LLVM name for the native AsmPrinter init function, if available

    LLVM_NATIVE_DISASSEMBLER* {.importc, header: "<llvm/Config/llvm-config.h>".}: proc () {.cdecl.}
      ## LLVM name for the native Disassembler init function, if available

    LLVM_NATIVE_TARGET* {.importc, header: "<llvm/Config/llvm-config.h>".}: proc () {.cdecl.}
      ## LLVM name for the native Target init function, if available

    LLVM_NATIVE_TARGETINFO* {.importc, header: "<llvm/Config/llvm-config.h>".}: proc () {.cdecl.}
      ## LLVM name for the native TargetInfo init function, if available

    LLVM_NATIVE_TARGETMC* {.importc, header: "<llvm/Config/llvm-config.h>".}: proc () {.cdecl.}
      ## LLVM name for the native target MC init function, if available
else:
  var
    LLVM_NATIVE_ASMPARSER* {.importc, header: "<llvm/Config/llvm-config.h>".}: proc () {.nimcall.}
      ## LLVM name for the native AsmParser init function, if available

    LLVM_NATIVE_ASMPRINTER* {.importc, header: "<llvm/Config/llvm-config.h>".}: proc () {.nimcall.}
      ## LLVM name for the native AsmPrinter init function, if available

    LLVM_NATIVE_DISASSEMBLER* {.importc, header: "<llvm/Config/llvm-config.h>".}: proc () {.nimcall.}
      ## LLVM name for the native Disassembler init function, if available

    LLVM_NATIVE_TARGET* {.importc, header: "<llvm/Config/llvm-config.h>".}: proc () {.nimcall.}
      ## LLVM name for the native Target init function, if available

    LLVM_NATIVE_TARGETINFO* {.importc, header: "<llvm/Config/llvm-config.h>".}: proc () {.nimcall.}
      ## LLVM name for the native TargetInfo init function, if available

    LLVM_NATIVE_TARGETMC* {.importc, header: "<llvm/Config/llvm-config.h>".}: proc () {.nimcall.}
      ## LLVM name for the native target MC init function, if available

var
  LLVM_ON_UNIX* {.importc, header: "<llvm/Config/llvm-config.h>".}: cint
    ## Define if this is Unixish platform

  LLVM_ON_WIN32* {.importc, header: "<llvm/Config/llvm-config.h>".}: cint
    ## Define if this is Win32ish platform

  LLVM_PREFIX* {.importc, header: "<llvm/Config/llvm-config.h>".}: cstring
    ## Installation prefix directory

  LLVM_USE_INTEL_JITEVENTS* {.importc, header: "<llvm/Config/llvm-config.h>".}: cint
    ## Define if we have the Intel JIT API runtime support library

  LLVM_USE_OPROFILE* {.importc, header: "<llvm/Config/llvm-config.h>".}: cint
    ## Define if we have the oprofile JIT-support library

  LLVM_VERSION_MAJOR* {.importc, header: "<llvm/Config/llvm-config.h>".}: cint
    ## Major version of the LLVM API

  LLVM_VERSION_MINOR* {.importc, header: "<llvm/Config/llvm-config.h>".}: cint
    ## Minor version of the LLVM API
