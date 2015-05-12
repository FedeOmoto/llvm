## This header declares the C interface to libLLVMIPO.a, which implements
## various interprocedural transformations of the LLVM IR.

import ../llvm_core

include ../llvm_lib

# Interprocedural transformations

proc addArgumentPromotionPass*(pm: PassManagerRef) {.
  importc: "LLVMAddArgumentPromotionPass", libllvm.}

proc addConstantMergePass*(pm: PassManagerRef) {.
  importc: "LLVMAddConstantMergePass", libllvm.}

proc addDeadArgEliminationPass*(pm: PassManagerRef) {.
  importc: "LLVMAddDeadArgEliminationPass", libllvm.}

proc addFunctionAttrsPass*(pm: PassManagerRef) {.
  importc: "LLVMAddFunctionAttrsPass", libllvm.}

proc addFunctionInliningPass*(pm: PassManagerRef) {.
  importc: "LLVMAddFunctionInliningPass", libllvm.}

proc addAlwaysInlinerPass*(pm: PassManagerRef) {.
  importc: "LLVMAddAlwaysInlinerPass", libllvm.}

proc addGlobalDCEPass*(pm: PassManagerRef) {.
  importc: "LLVMAddGlobalDCEPass", libllvm.}

proc addGlobalOptimizerPass*(pm: PassManagerRef) {.
  importc: "LLVMAddGlobalOptimizerPass", libllvm.}

proc addIPConstantPropagationPass*(pm: PassManagerRef) {.
  importc: "LLVMAddIPConstantPropagationPass", libllvm.}

proc addPruneEHPass*(pm: PassManagerRef) {.importc: "LLVMAddPruneEHPass", libllvm.}

proc addIPSCCPPass*(pm: PassManagerRef) {.importc: "LLVMAddIPSCCPPass", libllvm.}

proc addInternalizePass*(pm: PassManagerRef, allButMain: cuint) {.
  importc: "LLVMAddInternalizePass", libllvm.}

proc addStripDeadPrototypesPass*(pm: PassManagerRef) {.
  importc: "LLVMAddStripDeadPrototypesPass", libllvm.}

proc addStripSymbolsPass*(pm: PassManagerRef) {.
  importc: "LLVMAddStripSymbolsPass", libllvm.}
