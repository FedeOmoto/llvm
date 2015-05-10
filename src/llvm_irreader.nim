## This file defines the C interface to the IR Reader.

import llvm_core

include llvm_lib

proc parseIRInContext*(contextRef: ContextRef, memBuf: MemoryBufferRef,
                       outM: ptr ModuleRef, outMessage: cstringArray): Bool {.
  importc: "LLVMParseIRInContext", libllvm.}
  ## Read LLVM IR from a memory buffer and convert it into an in-memory Module
  ## object. Returns 0 on success.
  ## Optionally returns a human-readable description of any errors that
  ## occurred during parsing IR. OutMessage must be disposed with
  ## LLVMDisposeMessage.
