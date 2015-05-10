## This header declares the C interface to libLLVMBitReader.a, which
## implements input of the LLVM bitcode format.
##
## Many exotic languages can interoperate with C code but have a harder time
## with C++ due to name mangling. So in addition to C, this interface enables
## tools written in such languages.

import llvm_core

include llvm_lib

# Bit Reader

proc parseBitcode*(memBuf: MemoryBufferRef, outModule: ptr ModuleRef,
                   outMessage: cstringArray): Bool {.
  importc: "LLVMParseBitcode", libllvm.}
  ## Builds a module from the bitcode in the specified memory buffer, returning a
  ## reference to the module via the OutModule parameter. Returns 0 on success.
  ## Optionally returns a human-readable error message via OutMessage.

proc parseBitcodeInContext*(contextRef: ContextRef, memBuf: MemoryBufferRef,
                            outModule: ptr ModuleRef, outMessage: cstringArray):
                            Bool {.importc: "LLVMParseBitcodeInContext", libllvm.}

proc getBitcodeModuleInContext*(contextRef: ContextRef, memBuf: MemoryBufferRef,
                                outModule: ptr ModuleRef,
                                outMessage: cstringArray): Bool {.
  importc: "LLVMGetBitcodeModuleInContext", libllvm.}
  ## Reads a module from the specified path, returning via the OutMP parameter
  ## a module provider which performs lazy deserialization. Returns 0 on success.
  ## Optionally returns a human-readable error message via OutMessage.

proc getBitcodeModule*(memBuf: MemoryBufferRef, outModule: ptr ModuleRef,
                       outMessage: cstringArray): Bool {.
  importc: "LLVMGetBitcodeModule", libllvm.}

proc getBitcodeModuleProviderInContext*(contextRef: ContextRef,
                                        memBuf: MemoryBufferRef,
                                        outMP: ptr ModuleProviderRef,
                                        outMessage: cstringArray): Bool {.
  deprecated, importc: "LLVMGetBitcodeModuleProviderInContext", libllvm.}
  ## Deprecated: Use LLVMGetBitcodeModuleInContext instead.

proc getBitcodeModuleProvider*(memBuf: MemoryBufferRef,
                               outMP: ptr ModuleProviderRef,
                               outMessage: cstringArray): Bool {.
  deprecated, importc: "LLVMGetBitcodeModuleProvider", libllvm.}
  ## Deprecated: Use LLVMGetBitcodeModule instead.
