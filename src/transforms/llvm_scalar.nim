## This header declares the C interface to libLLVMScalarOpts.a, which
## implements various scalar transformations of the LLVM IR.
##
## Many exotic languages can interoperate with C code but have a harder time
## with C++ due to name mangling. So in addition to C, this interface enables
## tools written in such languages.

import ../llvm_core

include ../llvm_lib

# Scalar transformations

proc addAggressiveDCEPass*(pm: PassManagerRef) {.
  importc: "LLVMAddAggressiveDCEPass", libllvm.}

proc addCFGSimplificationPass*(pm: PassManagerRef) {.
  importc: "LLVMAddCFGSimplificationPass", libllvm.}

proc addDeadStoreEliminationPass*(pm: PassManagerRef) {.
  importc: "LLVMAddDeadStoreEliminationPass", libllvm.}

proc addScalarizerPass*(pm: PassManagerRef) {.importc: "LLVMAddScalarizerPass",
                                             libllvm.}

proc addMergedLoadStoreMotionPass*(pm: PassManagerRef) {.
  importc: "LLVMAddMergedLoadStoreMotionPass", libllvm.}

proc addGVNPass*(pm: PassManagerRef) {.importc: "LLVMAddGVNPass", libllvm.}

proc addIndVarSimplifyPass*(pm: PassManagerRef) {.
  importc: "LLVMAddIndVarSimplifyPass", libllvm.}

proc addInstructionCombiningPass*(pm: PassManagerRef) {.
  importc: "LLVMAddInstructionCombiningPass", libllvm.}

proc addJumpThreadingPass*(pm: PassManagerRef) {.
  importc: "LLVMAddJumpThreadingPass", libllvm.}

proc addLICMPass*(pm: PassManagerRef) {.importc: "LLVMAddLICMPass", libllvm.}

proc addLoopDeletionPass*(pm: PassManagerRef) {.
  importc: "LLVMAddLoopDeletionPass", libllvm.}

proc addLoopIdiomPass*(pm: PassManagerRef) {.importc: "LLVMAddLoopIdiomPass",
                                            libllvm.}

proc addLoopRotatePass*(pm: PassManagerRef) {.importc: "LLVMAddLoopRotatePass",
                                             libllvm.}

proc addLoopRerollPass*(pm: PassManagerRef) {.importc: "LLVMAddLoopRerollPass",
                                             libllvm.}

proc addLoopUnrollPass*(pm: PassManagerRef) {.importc: "LLVMAddLoopUnrollPass",
                                             libllvm.}

proc addLoopUnswitchPass*(pm: PassManagerRef) {.
  importc: "LLVMAddLoopUnswitchPass", libllvm.}

proc addMemCpyOptPass*(pm: PassManagerRef) {.importc: "LLVMAddMemCpyOptPass",
                                            libllvm.}

proc addPartiallyInlineLibCallsPass*(pm: PassManagerRef) {.
  importc: "LLVMAddPartiallyInlineLibCallsPass", libllvm.}

proc addPromoteMemoryToRegisterPass*(pm: PassManagerRef) {.
  importc: "LLVMAddPromoteMemoryToRegisterPass", libllvm.}

proc addReassociatePass*(pm: PassManagerRef) {.
  importc: "LLVMAddReassociatePass", libllvm.}

proc addSCCPPass*(pm: PassManagerRef) {.importc: "LLVMAddSCCPPass", libllvm.}

proc addScalarReplAggregatesPass*(pm: PassManagerRef) {.
  importc: "LLVMAddScalarReplAggregatesPass", libllvm.}

proc addScalarReplAggregatesPassSSA*(pm: PassManagerRef) {.
  importc: "LLVMAddScalarReplAggregatesPassSSA", libllvm.}

proc addScalarReplAggregatesPassWithThreshold*(pm: PassManagerRef,
                                               threshold: cint) {.
  importc: "LLVMAddScalarReplAggregatesPassWithThreshold", libllvm.}

proc addSimplifyLibCallsPass*(pm: PassManagerRef) {.
  importc: "LLVMAddSimplifyLibCallsPass", libllvm.}

proc addTailCallEliminationPass*(pm: PassManagerRef) {.
  importc: "LLVMAddTailCallEliminationPass", libllvm.}

proc addConstantPropagationPass*(pm: PassManagerRef) {.
  importc: "LLVMAddConstantPropagationPass", libllvm.}

proc addDemoteMemoryToRegisterPass*(pm: PassManagerRef) {.
  importc: "LLVMAddDemoteMemoryToRegisterPass", libllvm.}

proc addVerifierPass*(pm: PassManagerRef) {.importc: "LLVMAddVerifierPass",
                                           libllvm.}

proc addCorrelatedValuePropagationPass*(pm: PassManagerRef) {.
  importc: "LLVMAddCorrelatedValuePropagationPass", libllvm.}

proc addEarlyCSEPass*(pm: PassManagerRef) {.importc: "LLVMAddEarlyCSEPass",
                                           libllvm.}

proc addLowerExpectIntrinsicPass*(pm: PassManagerRef) {.
  importc: "LLVMAddLowerExpectIntrinsicPass", libllvm.}

proc addTypeBasedAliasAnalysisPass*(pm: PassManagerRef) {.
  importc: "LLVMAddTypeBasedAliasAnalysisPass", libllvm.}

proc addBasicAliasAnalysisPass*(pm: PassManagerRef) {.
  importc: "LLVMAddBasicAliasAnalysisPass", libllvm.}
