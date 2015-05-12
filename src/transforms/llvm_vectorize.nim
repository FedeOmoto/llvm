## This header declares the C interface to libLLVMVectorize.a, which
## implements various vectorization transformations of the LLVM IR.
##
## Many exotic languages can interoperate with C code but have a harder time
## with C++ due to name mangling. So in addition to C, this interface enables
## tools written in such languages.

import ../llvm_core

include ../llvm_lib

# Vectorization transformations

proc addBBVectorizePass*(pm: PassManagerRef) {.
  importc: "LLVMAddBBVectorizePass", libllvm.}

proc addLoopVectorizePass*(pm: PassManagerRef) {.
  importc: "LLVMAddLoopVectorizePass", libllvm.}

proc addSLPVectorizePass*(pm: PassManagerRef) {.
  importc: "LLVMAddSLPVectorizePass", libllvm.}
