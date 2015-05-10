## This header declares the C interface to libLLVMAnalysis.a, which
## implements various analyses of the LLVM IR.
##
## Many exotic languages can interoperate with C code but have a harder time
## with C++ due to name mangling. So in addition to C, this interface enables
## tools written in such languages.

import llvm_core

include llvm_lib

# Analysis

type VerifierFailureAction* = enum  ## Verifier Failure Action.
  AbortProcessAction                ## Verifier will print to stderr and abort()
  PrintMessageAction                ## Verifier will print to stderr and return 1
  ReturnStatusAction                ## Verifier will just return 1

proc verifyModule*(m: ModuleRef, action: VerifierFailureAction,
                   outMessage: cstringArray): Bool {.importc: "LLVMVerifyModule",
                                                    libllvm.}
  ## Verifies that a module is valid, taking the specified action if not.
  ## Optionally returns a human-readable description of any invalid constructs.
  ## OutMessage must be disposed with LLVMDisposeMessage.

proc verifyFunction*(fn: ValueRef, action: VerifierFailureAction): Bool {.
  importc: "LLVMVerifyFunction", libllvm.}
  ## Verifies that a single function is valid, taking the specified action. Useful
  ## for debugging.

proc viewFunctionCFG*(fn: ValueRef) {.importc: "LLVMViewFunctionCFG", libllvm.}
  ## Open up a ghostview window that displays the CFG of the current function.
  ## Useful for debugging.

proc viewFunctionCFGOnly*(fn: ValueRef) {.importc: "LLVMViewFunctionCFGOnly",
                                         libllvm.}
  ## Open up a ghostview window that displays the CFG of the current function.
  ## Useful for debugging.
