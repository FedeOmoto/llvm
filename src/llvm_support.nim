## This file defines the C interface to the LLVM support library.

include llvm_lib

when defined(static_link):
  {.passL: gorge("llvm-config --libs support").}

type Bool* = cint

type MemoryBufferRef* = ptr object
  ## Used to pass regions of memory through LLVM interfaces.

proc loadLibraryPermanently*(filename: cstring): Bool {.
  importc: "LLVMLoadLibraryPermanently", libllvm.}
  ## This function permanently loads the dynamic library at the given path.
  ## It is safe to call this function multiple times for the same library.
