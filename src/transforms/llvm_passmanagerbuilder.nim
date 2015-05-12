## This header declares the C interface to the PassManagerBuilder class.

import ../llvm_core

include ../llvm_lib

type PassManagerBuilderRef* = ptr object

# Pass manager builder

proc passManagerBuilderCreate*: PassManagerBuilderRef {.
  importc: "LLVMPassManagerBuilderCreate", libllvm.}

proc passManagerBuilderDispose*(pmb: PassManagerBuilderRef) {.
  importc: "LLVMPassManagerBuilderDispose", libllvm.}

proc passManagerBuilderSetOptLevel*(pmb: PassManagerBuilderRef, optLevel: cuint) {.
  importc: "LLVMPassManagerBuilderSetOptLevel", libllvm.}

proc passManagerBuilderSetSizeLevel*(pmb: PassManagerBuilderRef, SizeLevel: cuint) {.
  importc: "LLVMPassManagerBuilderSetSizeLevel", libllvm.}

proc passManagerBuilderSetDisableUnitAtATime*(pmb: PassManagerBuilderRef,
                                              value: Bool) {.
  importc: "LLVMPassManagerBuilderSetDisableUnitAtATime", libllvm.}

proc passManagerBuilderSetDisableUnrollLoops*(pmb: PassManagerBuilderRef,
                                              value: Bool) {.
  importc: "LLVMPassManagerBuilderSetDisableUnrollLoops", libllvm.}

proc passManagerBuilderSetDisableSimplifyLibCalls*(pmb: PassManagerBuilderRef, value: Bool) {.
  importc: "LLVMPassManagerBuilderSetDisableSimplifyLibCalls", libllvm.}

proc passManagerBuilderUseInlinerWithThreshold*(pmb: PassManagerBuilderRef,
                                                threshold: cuint) {.
  importc: "LLVMPassManagerBuilderUseInlinerWithThreshold", libllvm.}

proc passManagerBuilderPopulateFunctionPassManager*(pmb: PassManagerBuilderRef,
                                                    pm: PassManagerRef) {.
  importc: "LLVMPassManagerBuilderPopulateFunctionPassManager", libllvm.}

proc passManagerBuilderPopulateModulePassManager*(pmb: PassManagerBuilderRef,
                                                  pm: PassManagerRef) {.
  importc: "LLVMPassManagerBuilderPopulateModulePassManager", libllvm.}

proc passManagerBuilderPopulateLTOPassManager*(pmb: PassManagerBuilderRef,
                                               pm: PassManagerRef,
                                               internalize: Bool,
                                               runInliner: Bool) {.
  importc: "LLVMPassManagerBuilderPopulateLTOPassManager", libllvm.}
