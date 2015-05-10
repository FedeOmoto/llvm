## This header declares the C interface to libLLVMExecutionEngine.o, which
## implements various analyses of the LLVM IR.
##
## Many exotic languages can interoperate with C code but have a harder time
## with C++ due to name mangling. So in addition to C, this interface enables
## tools written in such languages.

import llvm_core, llvm_target, llvm_targetmachine

include llvm_lib

# Execution Engine

proc linkInJIT* {.importc: "LLVMLinkInJIT", libllvm.}

proc linkInMCJIT* {.importc: "LLVMLinkInMCJIT", libllvm.}

proc linkInInterpreter* {.importc: "LLVMLinkInInterpreter", libllvm.}

type
  GenericValueRef* = ptr object
  ExecutionEngineRef* = ptr object
  MCJITMemoryManagerRef* = ptr object

type MCJITCompilerOptions* = object
  optLevel*: cuint
  codeModel*: CodeModel
  noFramePointerElim*: Bool
  enableFastISel*: Bool
  mcJMM*: MCJITMemoryManagerRef

# Operations on generic values

proc createGenericValueOfInt*(ty: TypeRef, n: culonglong, isSigned: Bool):
                              GenericValueRef {.
  importc: "LLVMCreateGenericValueOfInt", libllvm.}

proc createGenericValueOfPointer*(p: pointer): GenericValueRef {.
  importc: "LLVMCreateGenericValueOfPointer", libllvm.}

proc createGenericValueOfFloat*(ty: TypeRef, n: cdouble): GenericValueRef {.
  importc: "LLVMCreateGenericValueOfFloat", libllvm.}

proc genericValueIntWidth*(genValRef: GenericValueRef): cuint {.
  importc: "LLVMGenericValueIntWidth", libllvm.}

proc genericValueToInt*(genVal: GenericValueRef, isSigned: Bool): culonglong {.
  importc: "LLVMGenericValueToInt", libllvm.}

proc genericValueToPointer*(genVal: GenericValueRef): pointer {.
  importc: "LLVMGenericValueToPointer", libllvm.}

proc genericValueToFloat*(tyRef: TypeRef, genVal: GenericValueRef): cdouble {.
  importc: "LLVMGenericValueToFloat", libllvm.}

proc disposeGenericValue*(genVal: GenericValueRef) {.
  importc: "LLVMDisposeGenericValue", libllvm.}

# Operations on execution engines

proc createExecutionEngineForModule*(outEE: ptr ExecutionEngineRef,
                                     m: ModuleRef, outError: cstringArray):
                                     Bool {.
  importc: "LLVMCreateExecutionEngineForModule", libllvm.}

proc createInterpreterForModule*(outInterp: ptr ExecutionEngineRef,
                                 m: ModuleRef, outError: cstringArray): Bool {.
  importc: "LLVMCreateInterpreterForModule", libllvm.}

proc createJITCompilerForModule*(outJIT: ptr ExecutionEngineRef, m: ModuleRef,
                                 optLevel: cuint, outError: cstringArray): Bool {.
  importc: "LLVMCreateJITCompilerForModule", libllvm.}

proc initializeMCJITCompilerOptions*(options: ptr MCJITCompilerOptions,
                                     sizeOfOptions: csize) {.
  importc: "LLVMInitializeMCJITCompilerOptions", libllvm.}

proc createMCJITCompilerForModule*(outJIT: ptr ExecutionEngineRef, m: ModuleRef,
                                   options: ptr MCJITCompilerOptions,
                                   sizeOfOptions: csize,
                                   outError: cstringArray): Bool {.
  importc: "LLVMCreateMCJITCompilerForModule", libllvm.}
  ## Create an MCJIT execution engine for a module, with the given options. It is
  ## the responsibility of the caller to ensure that all fields in Options up to
  ## the given SizeOfOptions are initialized. It is correct to pass a smaller
  ## value of SizeOfOptions that omits some fields. The canonical way of using
  ## this is:
  ##
  ## LLVMMCJITCompilerOptions options;
  ## LLVMInitializeMCJITCompilerOptions(&options, sizeof(options));
  ## ... fill in those options you care about
  ## LLVMCreateMCJITCompilerForModule(&jit, mod, &options, sizeof(options),
  ##                                 &error);
  ##
  ## Note that this is also correct, though possibly suboptimal:
  ##
  ## LLVMCreateMCJITCompilerForModule(&jit, mod, 0, 0, &error);

proc createExecutionEngine*(outEE: ptr ExecutionEngineRef,
                            mp: ModuleProviderRef, outError: cstringArray): Bool {.
  deprecated, importc: "LLVMCreateExecutionEngine", libllvm.}
  ## Deprecated: Use LLVMCreateExecutionEngineForModule instead.

proc createInterpreter*(outInterp: ptr ExecutionEngineRef, mp: ModuleProviderRef,
                        outError: cstringArray): Bool {.
  deprecated, importc: "LLVMCreateInterpreter", libllvm.}
  ## Deprecated: Use LLVMCreateInterpreterForModule instead.

proc createJITCompiler*(outJIT: ptr ExecutionEngineRef, mp: ModuleProviderRef,
                        optLevel: cuint, outError: cstringArray): Bool {.
  deprecated, importc: "LLVMCreateJITCompiler", libllvm.}
  ## Deprecated: Use LLVMCreateJITCompilerForModule instead.

proc disposeExecutionEngine*(ee: ExecutionEngineRef) {.
  importc: "LLVMDisposeExecutionEngine", libllvm.}

proc runStaticConstructors*(ee: ExecutionEngineRef) {.
  importc: "LLVMRunStaticConstructors", libllvm.}

proc runStaticDestructors*(ee: ExecutionEngineRef) {.
  importc: "LLVMRunStaticDestructors", libllvm.}

proc runFunctionAsMain*(ee: ExecutionEngineRef, f: ValueRef, argC: cuint,
                        argV: cstringArray, envP: cstringArray): cint {.
  importc: "LLVMRunFunctionAsMain", libllvm.}

proc runFunction*(ee: ExecutionEngineRef, f: ValueRef, numArgs: cuint,
                  args: ptr GenericValueRef): GenericValueRef {.
  importc: "LLVMRunFunction", libllvm.}

proc freeMachineCodeForFunction*(ee: ExecutionEngineRef, f: ValueRef) {.
  importc: "LLVMFreeMachineCodeForFunction", libllvm.}

proc addModule*(ee: ExecutionEngineRef, m: ModuleRef) {.
  importc: "LLVMAddModule", libllvm.}

proc addModuleProvider*(ee: ExecutionEngineRef, mp: ModuleProviderRef) {.
  importc: "LLVMAddModuleProvider", libllvm.}
  ## Deprecated: Use LLVMAddModule instead.

proc removeModule*(ee: ExecutionEngineRef, m: ModuleRef, outMod: ptr ModuleRef,
                   outError: cstringArray): Bool {.importc: "LLVMRemoveModule",
                                                  libllvm.}

proc removeModuleProvider*(ee: ExecutionEngineRef, mp: ModuleProviderRef,
                           outMod: ptr ModuleRef, outError: cstringArray): Bool {.
  deprecated, importc: "LLVMRemoveModuleProvider", libllvm.}
  ## Deprecated: Use LLVMRemoveModule instead.

proc findFunction*(ee: ExecutionEngineRef, name: cstring, outFn: ptr ValueRef):
                   Bool {.importc: "LLVMFindFunction", libllvm.}

proc recompileAndRelinkFunction*(ee: ExecutionEngineRef, fn: ValueRef): pointer {.
  importc: "LLVMRecompileAndRelinkFunction", libllvm.}

proc getExecutionEngineTargetData*(ee: ExecutionEngineRef): TargetDataRef {.
  importc: "LLVMGetExecutionEngineTargetData", libllvm.}

proc getExecutionEngineTargetMachine*(ee: ExecutionEngineRef): TargetMachineRef {.
  importc: "LLVMGetExecutionEngineTargetMachine", libllvm.}

proc addGlobalMapping*(ee: ExecutionEngineRef, global: ValueRef, address: pointer) {.
  importc: "LLVMAddGlobalMapping", libllvm.}

proc getPointerToGlobal*(ee: ExecutionEngineRef, global: ValueRef): pointer {.
  importc: "LLVMGetPointerToGlobal", libllvm.}

# Operations on memory managers

type
  MemoryManagerAllocateCodeSectionCallback* = proc (opaque: pointer, size: uint,
                                                    alignment: cuint,
                                                    sectionID: cuint,
                                                    sectionName: cstring):
                                                    ptr cuchar {.cdecl.}

  MemoryManagerAllocateDataSectionCallback* = proc (opaque: pointer, size: uint,
                                                    alignment: cuint,
                                                    sectionID: cuint,
                                                    sectionName: cstring,
                                                    isReadOnly: Bool):
                                                    ptr cuchar {.cdecl.}

  MemoryManagerFinalizeMemoryCallback* = proc (opaque: pointer,
                                               errMsg: cstringArray): Bool {.cdecl.}

  MemoryManagerDestroyCallback* = proc (opaque: pointer) {.cdecl.}

proc createSimpleMCJITMemoryManager*(opaque: pointer,
                                     allocateCodeSection: MemoryManagerAllocateCodeSectionCallback,
                                     allocateDataSection: MemoryManagerAllocateDataSectionCallback,
                                     finalizeMemory: MemoryManagerFinalizeMemoryCallback,
                                     destroy: MemoryManagerDestroyCallback):
                                     MCJITMemoryManagerRef {.
  importc: "LLVMCreateSimpleMCJITMemoryManager", libllvm.}
  ## Create a simple custom MCJIT memory manager. This memory manager can
  ## intercept allocations in a module-oblivious way. This will return NULL
  ## if any of the passed functions are NULL.
  ##
  ## @param Opaque An opaque client object to pass back to the callbacks.
  ## @param AllocateCodeSection Allocate a block of memory for executable code.
  ## @param AllocateDataSection Allocate a block of memory for data.
  ## @param FinalizeMemory Set page permissions and flush cache. Return 0 on
  ##   success, 1 on error.

proc disposeMCJITMemoryManager*(mm: MCJITMemoryManagerRef) {.
  importc: "LLVMDisposeMCJITMemoryManager", libllvm.}
