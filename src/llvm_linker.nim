## This file defines the C interface to the module/file/archive linker.

import llvm_core

include llvm_lib

type LinkerMode* = enum
  LinkerDestroySource  = 0
  LinkerPreserveSource = 1

proc linkModules*(dest: ModuleRef, src: ModuleRef, mode: LinkerMode,
                  outMessage: cstringArray): Bool {.importc: "LLVMLinkModules",
                                                   libllvm.}
  ## Links the source module into the destination module, taking ownership
  ## of the source module away from the caller. Optionally returns a
  ## human-readable description of any errors that occurred in linking.
  ## OutMessage must be disposed with LLVMDisposeMessage. The return value
  ## is true if an error occurred, false otherwise.
