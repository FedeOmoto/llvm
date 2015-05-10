## This header declares the C interface to libLLVMBitWriter.a, which
## implements output of the LLVM bitcode format.
##
## Many exotic languages can interoperate with C code but have a harder time
## with C++ due to name mangling. So in addition to C, this interface enables
## tools written in such languages.

import llvm_core

include llvm_lib

# Bit Writer

proc writeBitcodeToFile*(m: ModuleRef, path: cstring): cint {.
  importc: "LLVMWriteBitcodeToFile", libllvm.}
  ## Writes a module to the specified path. Returns 0 on success.

proc writeBitcodeToFD*(m: ModuleRef, fd: cint, shouldClose: cint,
                       unbuffered: cint): cint {.
  importc: "LLVMWriteBitcodeToFD", libllvm.}
  ## Writes a module to an open file descriptor. Returns 0 on success.

proc writeBitcodeToFileHandle*(m: ModuleRef, handle: cint): cint {.
  deprecated, importc: "LLVMWriteBitcodeToFD", libllvm.}
  ## Deprecated for LLVMWriteBitcodeToFD. Writes a module to an open file
  ## descriptor. Returns 0 on success. Closes the Handle.
