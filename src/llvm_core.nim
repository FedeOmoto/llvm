## This module provides an interface to libLLVMCore, which implements
## the LLVM intermediate representation as well as other related types
## and utilities.
##
## LLVM uses a polymorphic type hierarchy which C cannot represent, therefore
## parameters must be passed as base types. Despite the declared types, most
## of the functions provided operate only on branches of the type hierarchy.
## The declared parameter names are descriptive and specify which type is
## required. Additionally, each type hierarchy is documented along with the
## functions that operate upon it. For more detail, refer to LLVM's C++ code.
## If in doubt, refer to Core.cpp, which performs parameter downcasts in the
## form unwrap<RequiredType>(Param).
##
## Many exotic languages can interoperate with C code but have a harder time
## with C++ due to name mangling. So in addition to C, this interface enables
## tools written in such languages.

import llvm_support
export Bool, MemoryBufferRef

include llvm_lib

# Opaque types.
type
  ContextRef* = ptr object
    ## The top-level container for all LLVM global data. See the LLVMContext
    ## class.
  ModuleRef* = ptr object
    ## The top-level container for all other LLVM Intermediate Representation
    ## (IR) objects.
  TypeRef* = ptr object
    ## Each value in the LLVM IR has a type, an LLVMTypeRef.
  ValueRef* = ptr object
    ## Represents an individual value in LLVM IR.
  BasicBlockRef* = ptr object
    ## Represents a basic block of instructions in LLVM IR.
  BuilderRef* = ptr object
    ## Represents an LLVM basic block builder
  ModuleProviderRef* = ptr object
    ## Interface used to provide a module to JIT or interpreter.
    ## This is now just a synonym for llvm::Module, but we have to keep using
    ## the different type to keep binary compatibility.
  PassManagerRef* = ptr object
  PassRegistryRef* = ptr object
  UseRef* = ptr object
    ## Used to get the users and usees of a Value.
  DiagnosticInfoRef* = ptr object

type
  Attribute* = enum
    ZExtAttribute            = 1 shl 0
    SExtAttribute            = 1 shl 1
    NoReturnAttribute        = 1 shl 2
    InRegAttribute           = 1 shl 3
    StructRetAttribute       = 1 shl 4
    NoUnwindAttribute        = 1 shl 5
    NoAliasAttribute         = 1 shl 6
    ByValAttribute           = 1 shl 7
    NestAttribute            = 1 shl 8
    ReadNoneAttribute        = 1 shl 9
    ReadOnlyAttribute        = 1 shl 10
    NoInlineAttribute        = 1 shl 11
    AlwaysInlineAttribute    = 1 shl 12
    OptimizeForSizeAttribute = 1 shl 13
    StackProtectAttribute    = 1 shl 14
    StackProtectReqAttribute = 1 shl 15
    Alignment                = 31 shl 16
    NoCaptureAttribute       = 1 shl 21
    NoRedZoneAttribute       = 1 shl 22
    NoImplicitFloatAttribute = 1 shl 23
    NakedAttribute           = 1 shl 24
    InlineHintAttribute      = 1 shl 25
    StackAlignment           = 7 shl 26
    ReturnsTwice             = 1 shl 29
    UWTable                  = 1 shl 30
    NonLazyBind              = 1 shl 31

  Opcode* = enum
    # Terminator Instructions
    Ret            = 1
    Br             = 2
    Switch         = 3
    IndirectBr     = 4
    Invoke         = 5
    # removed 6 due to API changes
    Unreachable    = 7

    # Standard Binary Operators
    Add            = 8
    FAdd           = 9
    Sub            = 10
    FSub           = 11
    Mul            = 12
    FMul           = 13
    UDiv           = 14
    SDiv           = 15
    FDiv           = 16
    URem           = 17
    SRem           = 18
    FRem           = 19

    # Logical Operators
    Shl            = 20
    LShr           = 21
    AShr           = 22
    And            = 23
    Or             = 24
    Xor            = 25

    # Memory Operators
    Alloca         = 26
    Load           = 27
    Store          = 28
    GetElementPtr  = 29

    # Cast Operators
    Trunc          = 30
    ZExt           = 31
    SExt           = 32
    FPToUI         = 33
    FPToSI         = 34
    UIToFP         = 35
    SIToFP         = 36
    FPTrunc        = 37
    FPExt          = 38
    PtrToInt       = 39
    IntToPtr       = 40
    BitCast        = 41

    # Other Operators
    ICmp           = 42
    FCmp           = 43
    PHI            = 44
    Call           = 45
    Select         = 46
    UserOp1        = 47
    UserOp2        = 48
    VAArg          = 49
    ExtractElement = 50
    InsertElement  = 51
    ShuffleVector  = 52
    ExtractValue   = 53
    InsertValue    = 54

    # Atomic operators
    Fence          = 55
    AtomicCmpXchg  = 56
    AtomicRMW      = 57

    # Exception Handling Operators
    Resume         = 58
    LandingPad     = 59

    # Cast Operators
    AddrSpaceCast  = 60

  TypeKind* = enum    ## Type kind.
    VoidTypeKind      ## type with no size
    HalfTypeKind      ## 16 bit floating point type
    FloatTypeKind     ## 32 bit floating point type
    DoubleTypeKind    ## 64 bit floating point type
    X86_FP80TypeKind  ## 80 bit floating point type (X87)
    FP128TypeKind     ## 128 bit floating point type (112-bit mantissa)*/
    PPC_FP128TypeKind ## 128 bit floating point type (two 64-bits)
    LabelTypeKind     ## Labels
    IntegerTypeKind   ## Arbitrary bit width integers
    FunctionTypeKind  ## Functions
    StructTypeKind    ## Structures
    ArrayTypeKind     ## Arrays
    PointerTypeKind   ## Pointers
    VectorTypeKind    ## SIMD 'packed' format or other vector type
    MetadataTypeKind  ## Metadata
    X86_MMXTypeKind   ## X86 MMX

  Linkage* = enum               ## Linkage.
    ExternalLinkage             ## Externally visible function
    AvailableExternallyLinkage  ##
    LinkOnceAnyLinkage          ## Keep one copy of function when linking (inline)
    LinkOnceODRLinkage          ## Same but only replaced by something equivalent.
    LinkOnceODRAutoHideLinkage  ## Obsolete
    WeakAnyLinkage              ## Keep one copy of function when linking (weak)
    WeakODRLinkage              ## Same but only replaced by something equivalent.
    AppendingLinkage            ## Special purpose only applies to global arrays
    InternalLinkage             ## Rename collisions when linking (static functions)
    PrivateLinkage              ## Like Internal but omit from symbol table
    DLLImportLinkage            ## Obsolete
    DLLExportLinkage            ## Obsolete
    ExternalWeakLinkage         ## ExternalWeak linkage description
    GhostLinkage                ## Obsolete
    CommonLinkage               ## Tentative definitions
    LinkerPrivateLinkage        ## Like Private but linker removes.
    LinkerPrivateWeakLinkage    ## Like LinkerPrivate but is weak.

  Visibility* = enum    ## Visibility.
    DefaultVisibility   ## The GV is visible
    HiddenVisibility    ## The GV is hidden
    ProtectedVisibility ## The GV is protected

  DLLStorageClass* = enum     ## DLL storage class.
    DefaultStorageClass   = 0 ##
    DLLImportStorageClass = 1 ## Function to be imported from DLL.
    DLLExportStorageClass = 2 ## Function to be accessible from DLL.

  CallConv* = enum
    CCallConv           = 0
    FastCallConv        = 8
    ColdCallConv        = 9
    WebKitJSCallConv    = 12
    AnyRegCallConv      = 13
    X86StdcallCallConv  = 64
    X86FastcallCallConv = 65

  IntPredicate* = enum  ## Integer predicate.
    IntEQ = 32          ## equal
    IntNE               ## not equal
    IntUGT              ## unsigned greater than
    IntUGE              ## unsigned greater or equal
    IntULT              ## unsigned less than
    IntULE              ## unsigned less or equal
    IntSGT              ## signed greater than
    IntSGE              ## signed greater or equal
    IntSLT              ## signed less than
    IntSLE              ## signed less or equal

  RealPredicate* = enum ## Real predicate.
    RealPredicateFalse  ## Always false (always folded)
    RealOEQ             ## True if ordered and equal
    RealOGT             ## True if ordered and greater than
    RealOGE             ## True if ordered and greater than or equal
    RealOLT             ## True if ordered and less than
    RealOLE             ## True if ordered and less than or equal
    RealONE             ## True if ordered and operands are unequal
    RealORD             ## True if ordered (no nans)
    RealUNO             ## True if unordered: isnan(X) | isnan(Y)
    RealUEQ             ## True if unordered or equal
    RealUGT             ## True if unordered or greater than
    RealUGE             ## True if unordered greater than or equal
    RealULT             ## True if unordered or less than
    RealULE             ## True if unordered less than or equal
    RealUNE             ## True if unordered or not equal
    RealPredicateTrue   ## Always true (always folded)

  LandingPadClauseTy* = enum  ## Landing pad clause type.
    LandingPadCatch           ## A catch clause
    LandingPadFilter          ## A filter clause

  ThreadLocalMode* = enum
    NotThreadLocal = 0
    GeneralDynamicTLSModel
    LocalDynamicTLSModel
    InitialExecTLSModel
    LocalExecTLSModel

  AtomicOrdering* = enum              ## Atomic ordering.
    AtomicOrderingNotAtomic = 0       ## A load or store which is not atomic
    AtomicOrderingUnordered = 1       ## Lowest level of atomicity guarantees
                                      ## somewhat sane results lock free.
    AtomicOrderingMonotonic = 2       ## Guarantees that if you take all the
                                      ## operations affecting a specific address
                                      ## a consistent ordering exists
    AtomicOrderingAcquire = 4         ## Acquire provides a barrier of the sort
                                      ## necessary to acquire a lock to access other
                                      ## memory with normal loads and stores.
    AtomicOrderingRelease = 5         ## Release is similar to Acquire but with
                                      ## a barrier of the sort necessary to
                                      ## release a lock.
    AtomicOrderingAcquireRelease = 6  ## Provides both an Acquire and a Release
                                      ## barrier (for fences and operations
                                      ## which both read and write memory).
    AtomicOrderingSequentiallyConsistent = 7  ## Provides Acquire semantics for
                                              ## loads and Release semantics for
                                              ## stores. Additionally it guarantees
                                              ## that a total ordering exists
                                              ## between all SequentiallyConsistent
                                              ## operations.

  AtomicRMWBinOp* = enum  ## Atomic R/W binary operation.
    AtomicRMWBinOpXchg    ## Set the new value and return the one old
    AtomicRMWBinOpAdd     ## Add a value and return the old one
    AtomicRMWBinOpSub     ## Subtract a value and return the old one
    AtomicRMWBinOpAnd     ## And a value and return the old one
    AtomicRMWBinOpNand    ## Not-And a value and return the old one
    AtomicRMWBinOpOr      ## OR a value and return the old one
    AtomicRMWBinOpXor     ## Xor a value and return the old one
    AtomicRMWBinOpMax     ## Sets the value if it's greater than the original
                          ## using a signed comparison and return the old one
    AtomicRMWBinOpMin     ## Sets the value if it's Smaller than the original
                          ## using a signed comparison and return the old one
    AtomicRMWBinOpUMax    ## Sets the value if it's greater than the original
                          ## using an unsigned comparison and return the old one
    AtomicRMWBinOpUMin    ## Sets the value if it's smaller than the original
                          ## using an unsigned comparison and return the old one

  DiagnosticSeverity* = enum
    DSError
    DSWarning
    DSRemark
    DSNote

proc initializeCore*(r: PassRegistryRef) {.importc: "LLVMInitializeCore",
                                          libllvm.}

proc shutdown* {.importc: "LLVMShutdown", libllvm.}
  ## Deallocate and destroy all ManagedStatic variables.

# Error handling
proc createMessage*(message: cstring): cstring {.importc: "LLVMCreateMessage",
                                                libllvm.}

proc disposeMessage*(message: cstring) {.importc: "LLVMDisposeMessage",
                                        libllvm.}

type FatalErrorHandler* = proc (reason: cstring) {.cdecl.}

proc installFatalErrorHandler*(handler: FatalErrorHandler) {.
  importc: "LLVMInstallFatalErrorHandler", libllvm.}
  ## Install a fatal error handler. By default, if LLVM detects a fatal error,
  ## it will call exit(1). This may not be appropriate in many contexts. For
  ## example, doing exit(1) will bypass many crash reporting/tracing system
  ## tools. This function allows you to install a callback that will be invoked
  ## prior to the call to exit(1).

proc resetFatalErrorHandler* {.importc: "LLVMResetFatalErrorHandler", libllvm.}
  ## Reset the fatal error handler. This resets LLVM's fatal error handling
  ## behavior to the default.

proc enablePrettyStackTrace* {.importc: "LLVMEnablePrettyStackTrace", libllvm.}
  ## Enable LLVM's built-in stack trace code. This intercepts the OS's crash
  ## signals and prints which component of LLVM you were in at the time if the
  ## crash.

# Contexts are execution states for the core LLVM IR system.
#
# Most types are tied to a context instance. Multiple contexts can exist
# simultaneously. A single context is not thread safe. However, different
# contexts can execute on different threads simultaneously.

type
  DiagnosticHandler* = proc (di: DiagnosticInfoRef, p: pointer) {.cdecl.}
  YieldCallback* = proc (c: ContextRef, p: pointer) {.cdecl.}

proc contextCreate*: ContextRef {.importc: "LLVMContextCreate", libllvm.}
  ## Create a new context.
  ##
  ## Every call to this function should be paired with a call to
  ## LLVMContextDispose() or the context will leak memory.

proc getGlobalContext*: ContextRef {.importc: "LLVMGetGlobalContext", libllvm.}
  ## Obtain the global context instance.

proc contextSetDiagnosticHandler*(c: ContextRef, handler: DiagnosticHandler,
                                  diagnosticContext: pointer) {.
                                  importc: "LLVMContextSetDiagnosticHandler",
                                  libllvm.}
  ## Set the diagnostic handler for this context.

proc contextSetYieldCallback*(c: ContextRef, callback: YieldCallback,
                              opaqueHandle: pointer) {.
                              importc: "LLVMContextSetYieldCallback", libllvm.}
  ## Set the yield callback function for this context.

proc contextDispose*(c: ContextRef) {.importc: "LLVMContextDispose", libllvm.}
  ## Destroy a context instance.
  ##
  ## This should be called for every call to LLVMContextCreate() or memory will
  ## be leaked.

proc getDiagInfoDescription*(di: DiagnosticInfoRef): cstring {.
  importc: "LLVMGetDiagInfoDescription", libllvm.}
  ## Return a string representation of the DiagnosticInfo. Use LLVMDisposeMessage
  ## to free the string.

proc getDiagInfoSeverity*(di: DiagnosticInfoRef): DiagnosticSeverity {.
  importc: "LLVMGetDiagInfoSeverity", libllvm.}
  ## Return an enum LLVMDiagnosticSeverity.

proc getMDKindIDInContex*(c: ContextRef, name: cstring, sLen: cuint): cuint {.
  importc: "LLVMGetMDKindIDInContext", libllvm.}

proc getMDKindID*(name: cstring, sLen: cuint): cuint {.
  importc: "LLVMGetMDKindID", libllvm.}

# Modules represent the top-level structure in an LLVM program. An LLVM module
# is effectively a translation unit or a collection of translation units merged
# together.

proc moduleCreateWithName*(moduleID: cstring): ModuleRef {.
  importc: "LLVMModuleCreateWithName", libllvm.}
  ## Create a new, empty module in the global context.
  ##
  ## This is equivalent to calling LLVMModuleCreateWithNameInContext with
  ## LLVMGetGlobalContext() as the context parameter.
  ##
  ## Every invocation should be paired with LLVMDisposeModule() or memory will
  ## be leaked.

proc moduleCreateWithNameInContext*(moduleID: cstring, c: ContextRef): ModuleRef
  {.importc: "LLVMModuleCreateWithNameInContext", libllvm.}
  ## Create a new, empty module in a specific context.
  ##
  ## Every invocation should be paired with LLVMDisposeModule() or memory will
  ## be leaked.

proc disposeModule*(m: ModuleRef) {.importc: "LLVMDisposeModule", libllvm.}
  ## Destroy a module instance.
  ##
  ## This must be called for every created module or memory will be
  ## leaked.

proc getDataLayout*(m: ModuleRef): cstring {.importc: "LLVMGetDataLayout",
                                            libllvm.}
  ## Obtain the data layout for a module.

proc setDataLayout*(m: ModuleRef, triple: cstring) {.
  importc: "LLVMSetDataLayout", libllvm.}
  ## Set the data layout for a module.

proc getTarget*(m: ModuleRef): cstring {.importc: "LLVMGetTarget", libllvm.}
  ## Obtain the target triple for a module.

proc setTarget*(m: ModuleRef, triple: cstring) {.importc: "LLVMSetTarget",
                                                libllvm.}
  ## Set the target triple for a module.

proc dumpModule*(m: ModuleRef) {.importc: "LLVMDumpModule", libllvm.}
  ## Dump a representation of a module to stderr.

proc printModuleToFile*(m: ModuleRef, filename: cstring,
  errorMessage: ptr cstring): Bool {.importc: "LLVMPrintModuleToFile", libllvm.}
  ## Print a representation of a module to a file. The ErrorMessage needs to be
  ## disposed with LLVMDisposeMessage. Returns 0 on success, 1 otherwise.

proc printModuleToString*(m: ModuleRef): cstring {.
  importc: "LLVMPrintModuleToString", libllvm.}
  ## Return a string representation of the module. Use LLVMDisposeMessage to
  ## free the string.

proc setModuleInlineAsm*(m: ModuleRef, asmStr: cstring) {.
  importc: "LLVMSetModuleInlineAsm", libllvm.}
  ## Set inline assembly for a module.

proc getModuleContext*(m: ModuleRef): ContextRef {.
  importc: "LLVMGetModuleContext", libllvm.}
  ## Obtain the context to which this module is associated.

proc getTypeByName*(m: ModuleRef, name: cstring): TypeRef {.
  importc: "LLVMGetTypeByName", libllvm.}
  ## Obtain a Type from a module by its registered name.

proc getNamedMetadataNumOperands*(m: ModuleRef, name: cstring): cuint {.
  importc: "LLVMGetNamedMetadataNumOperands", libllvm.}
  ## Obtain the number of operands for named metadata in a module.

proc getNamedMetadataOperands*(m: ModuleRef, name: cstring, dest: ValueRef) {.
  importc: "LLVMGetNamedMetadataOperands", libllvm.}
  ## Obtain the named metadata operands for a module.
  ##
  ## The passed LLVMValueRef pointer should refer to an array of LLVMValueRef at
  ## least LLVMGetNamedMetadataNumOperands long. This array will be populated
  ## with the LLVMValueRef instances. Each instance corresponds to a llvm::MDNode.

proc addNamedMetadataOperand*(m: ModuleRef, name: cstring, val: ValueRef) {.
  importc: "LLVMAddNamedMetadataOperand", libllvm.}
  ## Add an operand to named metadata.

proc addFunction*(m: ModuleRef, name: cstring, functionType: TypeRef):
                 ValueRef {.importc: "LLVMAddFunction", libllvm.}
  ## Add a function to a module under a specified name.

proc getNamedFunction*(m: ModuleRef, name: cstring): ValueRef {.
  importc: "LLVMGetNamedFunction", libllvm.}
  ## Obtain a Function value from a Module by its name.
  ##
  ## The returned value corresponds to a llvm::Function value.

proc getFirstFunction*(m: ModuleRef): ValueRef {.
  importc: "LLVMGetFirstFunction", libllvm.}
  ## Obtain an iterator to the first Function in a Module.

proc getLastFunction*(m: ModuleRef): ValueRef {.importc: "LLVMGetLastFunction",
                                               libllvm.}
  ## Obtain an iterator to the last Function in a Module.

proc getNextFunction*(fn: ValueRef): ValueRef {.importc: "LLVMGetNextFunction",
                                               libllvm.}
  ## Advance a Function iterator to the next Function.
  ##
  ## Returns NULL if the iterator was already at the end and there are no more
  ## functions.

proc getPreviousFunction*(fn: ValueRef): ValueRef {.
  importc: "LLVMGetPreviousFunction", libllvm.}
  ## Decrement a Function iterator to the previous Function.
  ##
  ## Returns NULL if the iterator was already at the beginning and there are no
  ## previous functions.

# Types represent the type of a value.
#
# Types are associated with a context instance. The context internally
# deduplicates types so there is only 1 instance of a specific type alive at a
# time. In other words, a unique type is shared among all consumers within a
# context.
#
# A Type in the C API corresponds to llvm::Type.
#
# Types have the following hierarchy:
#
#    types:
#      integer type
#      real type
#      function type
#      sequence types:
#        array type
#        pointer type
#        vector type
#      void type
#      label type
#      opaque type

proc getTypeKind*(ty: TypeRef): TypeKind {.importc: "LLVMGetTypeKind",
                                            libllvm.}
  ## Obtain the enumerated type of a Type instance.

proc typeIsSized*(ty: TypeRef): Bool {.importc: "LLVMTypeIsSized", libllvm.}
  ## Whether the type has a known size.
  ##
  ## Things that don't have a size are abstract types, labels, and void.a

proc getTypeContext*(ty: TypeRef): ContextRef {.
  importc: "LLVMGetTypeContext", libllvm.}
  ## Obtain the context to which this type instance is associated.

proc dumpType*(val: TypeRef) {.importc: "LLVMDumpType", libllvm.}
  ## Dump a representation of a type to stderr.

proc printTypeToString*(val: TypeRef): cstring {.
  importc: "LLVMPrintTypeToString", libllvm.}
  ## Return a string representation of the type. Use LLVMDisposeMessage to free
  ## the string.

# Functions in this section operate on integer types.

proc int1TypeInContext*(c: ContextRef): TypeRef {.
  importc: "LLVMInt1TypeInContext", libllvm.}
  ## Obtain a 1-bit integer type from a context.

proc int8TypeInContext*(c: ContextRef): TypeRef {.
  importc: "LLVMInt8TypeInContext", libllvm.}
  ## Obtain a 8-bit integer type from a context.

proc int16TypeInContext*(c: ContextRef): TypeRef {.
  importc: "LLVMInt16TypeInContext", libllvm.}
  ## Obtain a 16-bit integer type from a context.

proc int32TypeInContext*(c: ContextRef): TypeRef {.
  importc: "LLVMInt32TypeInContext", libllvm.}
  ## Obtain a 32-bit integer type from a context.

proc int64TypeInContext*(c: ContextRef): TypeRef {.
  importc: "LLVMInt64TypeInContext", libllvm.}
  ## Obtain a 64-bit integer type from a context.

proc intTypeInContext*(c: ContextRef, numBits: cuint): TypeRef {.
  importc: "LLVMIntTypeInContext", libllvm.}
  ## Obtain an integer type from a context with specified bit width.

proc int1Type*: TypeRef {.importc: "LLVMInt1Type", libllvm.}
  ## Obtain a 1-bit integer type from the global context.

proc int8Type*: TypeRef {.importc: "LLVMInt8Type", libllvm.}
  ## Obtain a 8-bit integer type from the global context.

proc int16Type*: TypeRef {.importc: "LLVMInt16Type", libllvm.}
  ## Obtain a 16-bit integer type from the global context.

proc int32Type*: TypeRef {.importc: "LLVMInt32Type", libllvm.}
  ## Obtain a 32-bit integer type from the global context.

proc int64Type*: TypeRef {.importc: "LLVMInt64Type", libllvm.}
  ## Obtain a 64-bit integer type from the global context.

proc intType*(numBits: cuint): TypeRef {.importc: "LLVMIntType", libllvm.}
  ## Obtain an integer type from the global context with a specified bit width.

proc getIntTypeWidth*(integerType: TypeRef): cuint {.
  importc: "LLVMGetIntTypeWidth", libllvm.}

# Functions in this section operate on Floating Point types.

proc halfTypeInContext*(c: ContextRef): TypeRef {.
  importc: "LLVMHalfTypeInContext", libllvm.}
  ## Obtain a 16-bit floating point type from a context.

proc floatTypeInContext*(c: ContextRef): TypeRef {.
  importc: "LLVMFloatTypeInContext", libllvm.}
  ## Obtain a 32-bit floating point type from a context.

proc doubleTypeInContext*(c: ContextRef): TypeRef {.
  importc: "LLVMDoubleTypeInContext", libllvm.}
  ## Obtain a 64-bit floating point type from a context.

proc x86FP80TypeInContext*(c: ContextRef): TypeRef {.
  importc: "LLVMX86FP80TypeInContext", libllvm.}
  ## Obtain a 80-bit floating point type (X87) from a context.

proc fp128TypeInContext*(c: ContextRef): TypeRef {.
  importc: "LLVMFP128TypeInContext", libllvm.}
  ## Obtain a 128-bit floating point type (112-bit mantissa) from a context.

proc ppcFP128TypeInContext*(c: ContextRef): TypeRef {.
  importc: "LLVMPPCFP128TypeInContext", libllvm.}
  ## Obtain a 128-bit floating point type (two 64-bits) from a context.

proc halfType*: TypeRef {.importc: "LLVMHalfType", libllvm.}
  ## Obtain a 16-bit floating point type from the global context.

proc floatType*: TypeRef {.importc: "LLVMFloatType", libllvm.}
  ## Obtain a 32-bit floating point type from the global context.

proc doubleType*: TypeRef {.importc: "LLVMDoubleType", libllvm.}
  ## Obtain a 64-bit floating point type from the global context.

proc x86FP80Type*: TypeRef {.importc: "LLVMX86FP80Type", libllvm.}
  ## Obtain a 80-bit floating point type from the global context.

proc fp128Type*: TypeRef {.importc: "LLVMFP128Type", libllvm.}
  ## Obtain a 128-bit floating point type from the global context.

proc ppcFP128Type*: TypeRef {.importc: "LLVMPPCFP128Type", libllvm.}
  ## Obtain a 128-bit floating point type from the global context.

# Function Types

proc functionType*(returnType: TypeRef, paramTypes: ptr TypeRef, paramCount: cuint,
                   isVarArg: Bool): TypeRef {.importc: "LLVMFunctionType",
                                             libllvm.}
  ## Obtain a function type consisting of a specified signature.
  ##
  ## The function is defined as a tuple of a return Type, a list of parameter
  ## types, and whether the function is variadic.

proc isFunctionVarArg*(functionType: TypeRef): Bool {.
  importc: "LLVMIsFunctionVarArg", libllvm.}
  ## Returns whether a function type is variadic.

proc getReturnType*(functionType: TypeRef): TypeRef {.
  importc: "LLVMGetReturnType", libllvm.}
  ## Obtain the Type this function Type returns.

proc countParamTypes*(functionType: TypeRef): cuint {.
  importc: "LLVMCountParamTypes", libllvm.}
  ## Obtain the number of parameters this function accepts.

proc getParamTypes*(functionType: TypeRef, dest: ptr TypeRef) {.
  importc: "LLVMGetParamTypes", libllvm.}
  ## Obtain the types of a function's parameters.
  ##
  ## The Dest parameter should point to a pre-allocated array of LLVMTypeRef at
  ## least LLVMCountParamTypes() large. On return, the first LLVMCountParamTypes()
  ## entries in the array will be populated with LLVMTypeRef instances.

# These functions relate to LLVMTypeRef instances.

proc structTypeInContext*(c: ContextRef, elementTypes: ptr TypeRef,
                          elementCount: cuint, packed: Bool): TypeRef {.
  importc: "LLVMStructTypeInContext", libllvm.}
  ## Create a new structure type in a context.
  ##
  ## A structure is specified by a list of inner elements/types and whether
  ## these can be packed together.

proc structType*(elementTypes: ptr TypeRef, elementCount: cuint,
                 packed: Bool): TypeRef {.importc: "LLVMStructType", libllvm.}
  ## Create a new structure type in the global context.

proc structCreateNamed*(c: ContextRef, name: cstring): TypeRef {.
  importc: "LLVMStructCreateNamed", libllvm.}
  ## Create an empty structure in a context having a specified name.

proc getStructName*(ty: TypeRef): cstring {.importc: "LLVMGetStructName",
                                           libllvm.}
  ## Obtain the name of a structure.

proc structSetBody*(structType: TypeRef, elementTypes: ptr TypeRef,
                    elementCount: cuint, packed: Bool) {.
  importc: "LLVMStructSetBody", libllvm.}
  ## Set the contents of a structure type.

proc countStructElementTypes*(structType: TypeRef): cuint {.
  importc: "LLVMCountStructElementTypes", libllvm.}
  ## Get the number of elements defined inside the structure.

proc getStructElementTypes*(structType: TypeRef, dest: ptr TypeRef) {.
  importc: "LLVMGetStructElementTypes", libllvm.}
  ## Get the elements within a structure.
  ##
  ## The function is passed the address of a pre-allocated array of LLVMTypeRef
  ## at least LLVMCountStructElementTypes() long. After invocation, this array
  ## will be populated with the structure's elements. The objects in the
  ## destination array will have a lifetime of the structure type itself, which
  ## is the lifetime of the context it is contained in.

proc isPackedStruct*(structType: TypeRef): Bool {.
  importc: "LLVMIsPackedStruct", libllvm.}
  ## Determine whether a structure is packed.

proc isOpaqueStruct*(structType: TypeRef): Bool {.
  importc: "LLVMIsOpaqueStruct", libllvm.}
  ## Determine whether a structure is opaque.

# Sequential types represents "arrays" of types. This is a super class for
# array, vector, and pointer types.

proc getElementType*(ty: TypeRef): TypeRef {.importc: "LLVMGetElementType",
                                            libllvm.}
  ## Obtain the type of elements within a sequential type.
  ##
  ## This works on array, vector, and pointer types.

proc arrayType*(elementType: TypeRef, elementCount: cuint): TypeRef {.
  importc: "LLVMArrayType", libllvm.}
  ## Create a fixed size array type that refers to a specific type.
  ##
  ## The created type will exist in the context that its element type exists in.

proc getArrayLength*(arrayType: TypeRef): cuint {.
  importc: "LLVMGetArrayLength", libllvm.}
  ## Obtain the length of an array type.
  ##
  ## This only works on types that represent arrays.

proc pointerType*(elementType: TypeRef, addressSpace: cuint): TypeRef {.
  importc: "LLVMPointerType", libllvm.}
  ## Create a pointer type that points to a defined type.
  ##
  ## The created type will exist in the context that its pointee type exists in.

proc getPointerAddressSpace*(pointerType: TypeRef): cuint {.
  importc: "LLVMGetPointerAddressSpace", libllvm.}
  ## Obtain the address space of a pointer type.
  ##
  ## This only works on types that represent pointers.

proc vectorType*(elementType: TypeRef, elementCount: cuint): TypeRef {.
  importc: "LLVMVectorType", libllvm.}
  ## Create a vector type that contains a defined type and has a specific number
  ## of elements.
  ##
  ## The created type will exist in the context that its element type exists in.

proc getVectorSize*(vectorType: TypeRef): cuint {.importc: "LLVMGetVectorSize",
                                                libllvm.}
  ## Obtain the number of elements in a vector type.
  ##
  ## This only works on types that represent vectors.

# Other Types

proc voidTypeInContext*(c: ContextRef): TypeRef {.
  importc: "LLVMVoidTypeInContext", libllvm.}
  ## Create a void type in a context.

proc labelTypeInContext*(c: ContextRef): TypeRef {.
  importc: "LLVMLabelTypeInContext", libllvm.}
  ## Create a label type in a context.

proc x86MMXTypeInContext*(c: ContextRef): TypeRef {.
  importc: "LLVMX86MMXTypeInContext", libllvm.}
  ## Create a X86 MMX type in a context.

proc voidType*(): TypeRef {.importc: "LLVMVoidType", libllvm.}
  ## Create a void type in the global context.

proc labelType*(): TypeRef {.importc: "LLVMLabelType", libllvm.}
  ## Create a label type in the global context.

proc x86MMXType*(): TypeRef {.importc: "LLVMX86MMXType", libllvm.}
  ## Create a X86 MMX type in the global context.

# The bulk of LLVM's object model consists of values, which comprise a very
# rich type hierarchy.
#
# LLVMValueRef essentially represents llvm::Value. There is a rich
# hierarchy of classes within this type. Depending on the instance
# obtained, not all APIs are available.
#
# Callers can determine the type of an LLVMValueRef by calling the
# LLVMIsA* family of functions (e.g. LLVMIsAArgument()). These
# functions are defined by a macro, so it isn't obvious which are
# available by looking at the Doxygen source code. Instead, look at the
# source definition of LLVM_FOR_EACH_VALUE_SUBCLASS and note the list
# of value names given. These value names also correspond to classes in
# the llvm::Value hierarchy.

proc isAArgument*(val: ValueRef): ValueRef {.importc: "LLVMIsAArgument",
                                            libllvm.}

proc isABasicBlock*(val: ValueRef): ValueRef {.importc: "LLVMIsABasicBlock",
                                              libllvm.}

proc isAInlineAsm*(val: ValueRef): ValueRef {.importc: "LLVMIsAInlineAsm",
                                             libllvm.}

proc isAMDNode*(val: ValueRef): ValueRef {.importc: "LLVMIsAMDNode",
                                          libllvm.}

proc isAMDString*(val: ValueRef): ValueRef {.importc: "LLVMIsAMDString",
                                            libllvm.}

proc isAUser*(val: ValueRef): ValueRef {.importc: "LLVMIsAUser", libllvm.}

proc isAConstant*(val: ValueRef): ValueRef {.importc: "LLVMIsAConstant",
                                            libllvm.}

proc isABlockAddress*(val: ValueRef): ValueRef {.importc: "LLVMIsABlockAddress",
                                                libllvm.}

proc isAConstantAggregateZero*(val: ValueRef): ValueRef {.
  importc: "LLVMIsAConstantAggregateZero", libllvm.}

proc isAConstantArray*(val: ValueRef): ValueRef {.
  importc: "LLVMIsAConstantArray", libllvm.}

proc isAConstantDataSequential*(val: ValueRef): ValueRef {.
  importc: "LLVMIsAConstantDataSequential", libllvm.}

proc isAConstantDataArray*(val: ValueRef): ValueRef {.
  importc: "LLVMIsAConstantDataArray", libllvm.}

proc isAConstantDataVector*(val: ValueRef): ValueRef {.
  importc: "LLVMIsAConstantDataVector", libllvm.}

proc isAConstantExpr*(val: ValueRef): ValueRef {.importc: "LLVMIsAConstantExpr",
                                                libllvm.}

proc isAConstantFP*(val: ValueRef): ValueRef {.importc: "LLVMIsAConstantFP",
                                              libllvm.}

proc isAConstantInt*(val: ValueRef): ValueRef {.importc: "LLVMIsAConstantInt",
                                               libllvm.}

proc isAConstantPointerNull*(val: ValueRef): ValueRef {.
  importc: "LLVMIsAConstantPointerNull", libllvm.}

proc isAConstantStruct*(val: ValueRef): ValueRef {.
  importc: "LLVMIsAConstantStruct", libllvm.}

proc isAConstantVector*(val: ValueRef): ValueRef {.
  importc: "LLVMIsAConstantVector", libllvm.}

proc isAGlobalValue*(val: ValueRef): ValueRef {.importc: "LLVMIsAGlobalValue",
                                               libllvm.}

proc isAGlobalAlias*(val: ValueRef): ValueRef {.importc: "LLVMIsAGlobalAlias",
                                               libllvm.}

proc isAGlobalObject*(val: ValueRef): ValueRef {.importc: "LLVMIsAGlobalObject",
                                                libllvm.}

proc isAFunction*(val: ValueRef): ValueRef {.importc: "LLVMIsAFunction",
                                            libllvm.}

proc isAGlobalVariable*(val: ValueRef): ValueRef {.
  importc: "LLVMIsAGlobalVariable", libllvm.}

proc isAUndefValue*(val: ValueRef): ValueRef {.importc: "LLVMIsAUndefValue",
                                              libllvm.}

proc isAInstruction*(val: ValueRef): ValueRef {.importc: "LLVMIsAInstruction",
                                               libllvm.}

proc isABinaryOperator*(val: ValueRef): ValueRef {.
  importc: "LLVMIsABinaryOperator", libllvm.}

proc isACallInst*(val: ValueRef): ValueRef {.importc: "LLVMIsACallInst",
                                            libllvm.}

proc isAAIntrinsicInst*(val: ValueRef): ValueRef {.
  importc: "LLVMIsAIntrinsicInst", libllvm.}

proc isADbgInfoIntrinsic*(val: ValueRef): ValueRef {.
  importc: "LLVMIsADbgInfoIntrinsic", libllvm.}

proc isADbgDeclareInst*(val: ValueRef): ValueRef {.
  importc: "LLVMIsADbgDeclareInst", libllvm.}

proc isAMemIntrinsic*(val: ValueRef): ValueRef {.importc: "LLVMIsAMemIntrinsic",
                                                libllvm.}

proc isAMemCpyInst*(val: ValueRef): ValueRef {.importc: "LLVMIsAMemCpyInst",
                                              libllvm.}

proc isAMemMoveInst*(val: ValueRef): ValueRef {.importc: "LLVMIsAMemMoveInst",
                                               libllvm.}

proc isAMemSetInst*(val: ValueRef): ValueRef {.importc: "LLVMIsAMemSetInst",
                                              libllvm.}

proc isACmpInst*(val: ValueRef): ValueRef {.importc: "LLVMIsACmpInst",
                                           libllvm.}

proc isAFCmpInst*(val: ValueRef): ValueRef {.importc: "LLVMIsAFCmpInst",
                                            libllvm.}

proc isAICmpInst*(val: ValueRef): ValueRef {.importc: "LLVMIsAICmpInst",
                                            libllvm.}

proc isAExtractElementInst*(val: ValueRef): ValueRef {.
  importc: "LLVMIsAExtractElementInst", libllvm.}

proc isAGetElementPtrInst*(val: ValueRef): ValueRef {.
  importc: "LLVMIsAGetElementPtrInst", libllvm.}

proc isAInsertElementInst*(val: ValueRef): ValueRef {.
  importc: "LLVMIsAInsertElementInst", libllvm.}

proc isAInsertValueInst*(val: ValueRef): ValueRef {.
  importc: "LLVMIsAInsertValueInst", libllvm.}

proc isALandingPadInst*(val: ValueRef): ValueRef {.
  importc: "LLVMIsALandingPadInst", libllvm.}

proc isAPHINode*(val: ValueRef): ValueRef {.importc: "LLVMIsAPHINode",
                                           libllvm.}

proc isASelectInst*(val: ValueRef): ValueRef {.importc: "LLVMIsASelectInst",
                                              libllvm.}

proc isAShuffleVectorInst*(val: ValueRef): ValueRef {.
  importc: "LLVMIsAShuffleVectorInst", libllvm.}

proc isAStoreInst*(val: ValueRef): ValueRef {.importc: "LLVMIsAStoreInst",
                                             libllvm.}

proc isATerminatorInst*(val: ValueRef): ValueRef {.
  importc: "LLVMIsATerminatorInst", libllvm.}

proc isABranchInst*(val: ValueRef): ValueRef {.importc: "LLVMIsABranchInst",
                                              libllvm.}

proc isAIndirectBrInst*(val: ValueRef): ValueRef {.
  importc: "LLVMIsAIndirectBrInst", libllvm.}

proc isAInvokeInst*(val: ValueRef): ValueRef {.importc: "LLVMIsAInvokeInst",
                                              libllvm.}

proc isAReturnInst*(val: ValueRef): ValueRef {.importc: "LLVMIsAReturnInst",
                                              libllvm.}

proc isASwitchInst*(val: ValueRef): ValueRef {.importc: "LLVMIsASwitchInst",
                                              libllvm.}

proc isAUnreachableInst*(val: ValueRef): ValueRef {.
  importc: "LLVMIsAUnreachableInst", libllvm.}

proc isAResumeInst*(val: ValueRef): ValueRef {.importc: "LLVMIsAResumeInst",
                                              libllvm.}

proc isAUnaryInstruction*(val: ValueRef): ValueRef {.
  importc: "LLVMIsAUnaryInstruction", libllvm.}

proc isAAllocaInst*(val: ValueRef): ValueRef {.importc: "LLVMIsAAllocaInst",
                                              libllvm.}

proc isACastInst*(val: ValueRef): ValueRef {.importc: "LLVMIsACastInst",
                                            libllvm.}

proc isAAddrSpaceCastInst*(val: ValueRef): ValueRef {.
  importc: "LLVMIsAAddrSpaceCastInst", libllvm.}

proc isABitCastInst*(val: ValueRef): ValueRef {.importc: "LLVMIsABitCastInst",
                                               libllvm.}

proc isAFPExtInst*(val: ValueRef): ValueRef {.importc: "LLVMIsAFPExtInst",
                                             libllvm.}

proc isAFPToSIInst*(val: ValueRef): ValueRef {.importc: "LLVMIsAFPToSIInst",
                                              libllvm.}

proc isAFPToUIInst*(val: ValueRef): ValueRef {.importc: "LLVMIsAFPToUIInst",
                                              libllvm.}

proc isAFPTruncInst*(val: ValueRef): ValueRef {.importc: "LLVMIsAFPTruncInst",
                                               libllvm.}

proc isAIntToPtrInst*(val: ValueRef): ValueRef {.importc: "LLVMIsAIntToPtrInst",
                                                libllvm.}

proc isAPtrToIntInst*(val: ValueRef): ValueRef {.importc: "LLVMIsAPtrToIntInst",
                                                libllvm.}

proc isASExtInst*(val: ValueRef): ValueRef {.importc: "LLVMIsASExtInst",
                                            libllvm.}

proc isASIToFPInst*(val: ValueRef): ValueRef {.importc: "LLVMIsASIToFPInst",
                                              libllvm.}

proc isATruncInst*(val: ValueRef): ValueRef {.importc: "LLVMIsATruncInst",
                                             libllvm.}

proc isAUIToFPInst*(val: ValueRef): ValueRef {.importc: "LLVMIsAUIToFPInst",
                                              libllvm.}

proc isAZExtInst*(val: ValueRef): ValueRef {.importc: "LLVMIsAZExtInst",
                                            libllvm.}

proc isAExtractValueInst*(val: ValueRef): ValueRef {.
  importc: "LLVMIsAExtractValueInst", libllvm.}

proc isALoadInst*(val: ValueRef): ValueRef {.importc: "LLVMIsALoadInst",
                                            libllvm.}

proc isAVAArgInst*(val: ValueRef): ValueRef {.importc: "LLVMIsAVAArgInst",
                                             libllvm.}

# Functions in this section work on all LLVMValueRef instances,
# regardless of their sub-type. They correspond to functions available
# on llvm::Value.

proc typeOf*(val: ValueRef): TypeRef {.importc: "LLVMTypeOf", libllvm.}
  ## Obtain the type of a value.

proc getValueName*(val: ValueRef): cstring {.importc: "LLVMGetValueName",
                                            libllvm.}
  ## Obtain the string name of a value.

proc setValueName*(val: ValueRef, name: cstring) {.importc: "LLVMSetValueName",
                                                  libllvm.}
  ## Set the string name of a value.

proc dumpValue*(val: ValueRef) {.importc: "LLVMDumpValue", libllvm.}
  ## Dump a representation of a value to stderr.

proc printValueToString*(val: ValueRef): cstring {.
  importc: "LLVMPrintValueToString", libllvm.}
  ## Return a string representation of the value. Use LLVMDisposeMessage to free
  ## the string.

proc replaceAllUsesWith*(oldVal: ValueRef, newVal: ValueRef) {.
  importc: "LLVMReplaceAllUsesWith", libllvm.}
  ## Replace all uses of a value with another one.

proc isConstant*(val: ValueRef): Bool {.importc: "LLVMIsConstant", libllvm.}
  ## Determine whether the specified constant instance is constant.

proc isUndef*(val: ValueRef): Bool {.importc: "LLVMIsUndef", libllvm.}
  ## Determine whether a value instance is undefined.

# This module defines functions that allow you to inspect the uses of a
# LLVMValueRef.
#
# It is possible to obtain an LLVMUseRef for any LLVMValueRef instance.
# Each LLVMUseRef (which corresponds to a llvm::Use instance) holds a
# llvm::User and llvm::Value.

proc getFirstUse*(val: ValueRef): UseRef {.importc: "LLVMGetFirstUse", libllvm.}
  ## Obtain the first use of a value.
  ##
  ## Uses are obtained in an iterator fashion. First, call this function
  ## to obtain a reference to the first use. Then, call LLVMGetNextUse()
  ## on that instance and all subsequently obtained instances until
  ## LLVMGetNextUse() returns NULL.

proc getNextUse*(u: UseRef): UseRef {.importc: "LLVMGetNextUse", libllvm.}
  ## Obtain the next use of a value.
  ##
  ## This effectively advances the iterator. It returns NULL if you are on
  ## the final use and no more are available.

proc getUser*(u: UseRef): ValueRef {.importc: "LLVMGetUser", libllvm.}
  ## Obtain the user value for a use.
  ##
  ## The returned value corresponds to a llvm::User type.

proc getUsedValue*(u: UseRef): ValueRef {.importc: "LLVMGetUsedValue", libllvm.}
  ## Obtain the value this use corresponds to.

# Function in this group pertain to LLVMValueRef instances that descent
# from llvm::User. This includes constants, instructions, and
# operators.

proc getOperand*(val: ValueRef, index: cuint): ValueRef {.
  importc: "LLVMGetOperand", libllvm.}
  ## Obtain an operand at a specific index in a llvm::User value.

proc setOperand*(user: ValueRef, index: cuint, val: ValueRef) {.
  importc: "LLVMSetOperand", libllvm.}
  ## Set an operand at a specific index in a llvm::User value.

proc getNumOperands*(val: ValueRef): cint {.importc: "LLVMGetNumOperands",
                                           libllvm.}
  ## Obtain the number of operands in a llvm::User value.

# This section contains APIs for interacting with LLVMValueRef that
# correspond to llvm::Constant instances.
#
# These functions will work for any LLVMValueRef in the llvm::Constant
# class hierarchy.

proc constNull*(ty: TypeRef): ValueRef {.importc: "LLVMConstNull", libllvm.}
  ## Obtain a constant value referring to the null instance of a type.

proc constAllOnes*(ty: TypeRef): ValueRef {.importc: "LLVMConstAllOnes",
                                          libllvm.}
  ## Obtain a constant value referring to the instance of a type
  ## consisting of all ones.
  ##
  ## This is only valid for integer types.

proc getUndef*(ty: TypeRef): ValueRef {.importc: "LLVMGetUndef", libllvm.}
  ## Obtain a constant value referring to an undefined value of a type.

proc isNull*(val: ValueRef): Bool {.importc: "LLVMIsNull", libllvm.}
  ## Determine whether a value instance is null.

proc constPointerNull*(ty: TypeRef): ValueRef {.
  importc: "LLVMConstPointerNull", libllvm.}
  ## Obtain a constant that is a constant pointer pointing to NULL for a
  ## specified type.

# Functions in this group model LLVMValueRef instances that correspond
# to constants referring to scalar types.
#
# For integer types, the LLVMTypeRef parameter should correspond to a
# llvm::IntegerType instance and the returned LLVMValueRef will
# correspond to a llvm::ConstantInt.
#
# For floating point types, the LLVMTypeRef returned corresponds to a
# llvm::ConstantFP.

proc constInt*(intType: TypeRef, n: culonglong, signExtend: Bool): ValueRef {.
  importc: "LLVMConstInt", libllvm.}
  ## Obtain a constant value for an integer type.
  ##
  ## The returned value corresponds to a llvm::ConstantInt.

proc constIntOfArbitraryPrecision*(intType: TypeRef, numWords: cuint,
                                   words: ptr culonglong): ValueRef {.
  importc: "LLVMConstIntOfArbitraryPrecision", libllvm.}
  ## Obtain a constant value for an integer of arbitrary precision.

proc constIntOfString*(intType: TypeRef, text: cstring, radix: cuchar): ValueRef
  {.importc: "LLVMConstIntOfString", libllvm.}
  ## Obtain a constant value for an integer parsed from a string.
  ##
  ## A similar API, LLVMConstIntOfStringAndSize is also available. If the
  ## string's length is available, it is preferred to call that function
  ## instead.

proc constIntOfStringAndSize*(intType: TypeRef, text: cstring, sLen: cuint,
                              radix: cuchar): ValueRef {.
  importc: "LLVMConstIntOfStringAndSize", libllvm.}
  ## Obtain a constant value for an integer parsed from a string with
  ## specified length.

proc constReal*(realType: TypeRef, n: cdouble): ValueRef {.
  importc: "LLVMConstReal", libllvm.}
  ## Obtain a constant value referring to a double floating point value.

proc constRealOfString*(realType: TypeRef, text: cstring): ValueRef {.
  importc: "LLVMConstRealOfString", libllvm.}
  ## Obtain a constant for a floating point value parsed from a string.
  ##
  ## A similar API, LLVMConstRealOfStringAndSize is also available. It
  ## should be used if the input string's length is known.

proc constRealOfStringAndSize*(realType: TypeRef, text: cstring, sLen: cuint):
                               ValueRef {.
  importc: "LLVMConstRealOfStringAndSize", libllvm.}
  ## Obtain a constant for a floating point value parsed from a string.

proc constIntGetZExtValue*(constantVal: ValueRef): culonglong {.
  importc: "LLVMConstIntGetZExtValue", libllvm.}
  ## Obtain the zero extended value for an integer constant value.

proc constIntGetSExtValue*(constantVal: ValueRef): clonglong {.
  importc: "LLVMConstIntGetSExtValue", libllvm.}
  ## Obtain the sign extended value for an integer constant value.

# Functions in this group operate on composite constants.

proc constStringInContext*(c: ContextRef, str: cstring, length: cuint,
                           dontNullTerminate: Bool): ValueRef {.
  importc: "LLVMConstStringInContext", libllvm.}
  ## Create a ConstantDataSequential and initialize it with a string.

proc constString*(str: cstring, length: cuint, dontNullTerminate: Bool):
                  ValueRef {.importc: "LLVMConstString", libllvm.}
  ## Create a ConstantDataSequential with string content in the global context.
  ##
  ## This is the same as LLVMConstStringInContext except it operates on the
  ## global context.

proc constStructInContext*(c: ContextRef, constantVals: ptr ValueRef,
                           count: cuint, packed: Bool): ValueRef {.
  importc: "LLVMConstStructInContext", libllvm.}
  ## Create an anonymous ConstantStruct with the specified values.

proc constStruct*(constantVals: ptr ValueRef, count: cuint, packed: Bool):
                  ValueRef {.importc: "LLVMConstStruct", libllvm.}
  ## Create a ConstantStruct in the global Context.
  ##
  ## This is the same as LLVMConstStructInContext except it operates on the
  ## global Context.

proc constArray*(elementType: TypeRef, constantVals: ptr ValueRef,
                 length: cuint): ValueRef {.importc: "LLVMConstArray", libllvm.}
  ## Create a ConstantArray from values.

proc constNamedStruct*(structType: TypeRef, constantVals: ptr ValueRef,
                       count: cuint): ValueRef {.
  importc: "LLVMConstNamedStruct", libllvm.}
  ## Create a non-anonymous ConstantStruct from values.

proc constVector*(scalarConstantVals: ptr ValueRef, size: cuint): ValueRef {.
  importc: "LLVMConstVector", libllvm.}
  ## Create a ConstantVector from values.

# Functions in this group correspond to APIs on llvm::ConstantExpr.

proc getConstOpcode*(constantVal: ValueRef): Opcode {.
  importc: "LLVMGetConstOpcode", libllvm.}

proc alignOf*(ty: TypeRef): ValueRef {.importc: "LLVMAlignOf", libllvm.}

proc sizeOf*(ty: TypeRef): ValueRef {.importc: "LLVMSizeOf", libllvm.}

proc constNeg*(constantVal: ValueRef): ValueRef {.importc: "LLVMConstNeg",
                                                 libllvm.}

proc constNSWNeg*(constantVal: ValueRef): ValueRef {.importc: "LLVMConstNSWNeg",
                                                    libllvm.}

proc constNUWNeg*(constantVal: ValueRef): ValueRef {.importc: "LLVMConstNUWNeg",
                                                    libllvm.}

proc constFNeg*(constantVal: ValueRef): ValueRef {.importc: "LLVMConstFNeg",
                                                  libllvm.}

proc constNot*(constantVal: ValueRef): ValueRef {.importc: "LLVMConstNot",
                                                 libllvm.}

proc constAdd*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstAdd", libllvm.}

proc ConstNSWAdd*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstNSWAdd", libllvm.}

proc constNUWAdd*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstNUWAdd", libllvm.}

proc constFAdd*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstFAdd", libllvm.}

proc constSub*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstSub", libllvm.}

proc constNSWSub*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstNSWSub", libllvm.}

proc constNUWSub*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstNUWSub", libllvm.}

proc constFSub*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstFSub", libllvm.}

proc constMul*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstMul", libllvm.}

proc constNSWMul*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstNSWMul", libllvm.}

proc constNUWMul*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstNUWMul", libllvm.}

proc constFMul*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstFMul", libllvm.}

proc constUDiv*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstUDiv", libllvm.}

proc constSDiv*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstSDiv", libllvm.}

proc constExactSDiv*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstExactSDiv", libllvm.}

proc constFDiv*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstFDiv", libllvm.}

proc constURem*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstURem", libllvm.}

proc constSRem*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstSRem", libllvm.}

proc constFRem*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstFRem", libllvm.}

proc constAnd*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstAnd", libllvm.}

proc constOr*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstOr", libllvm.}

proc constXor*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstXor", libllvm.}

proc constICmp*(predicate: IntPredicate, lhsConstant: ValueRef,
                rhsConstant: ValueRef): ValueRef {.importc: "LLVMConstICmp",
                                                  libllvm.}

proc constFCmp*(predicate: RealPredicate, lhsConstant: ValueRef,
                rhsConstant: ValueRef): ValueRef {.importc: "LLVMConstFCmp",
                                                  libllvm.}

proc constShl*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstShl", libllvm.}

proc constLShr*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstLShr", libllvm.}

proc constAShr*(lhsConstant: ValueRef, rhsConstant: ValueRef): ValueRef {.
  importc: "LLVMConstAShr", libllvm.}

proc constGEP*(constantVal: ValueRef, constantIndices: ptr ValueRef,
               numIndices: cuint): ValueRef {.importc: "LLVMConstGEP", libllvm.}

proc constInBoundsGEP*(constantVal: ValueRef, constantIndices: ptr ValueRef,
                       numIndices: cuint): ValueRef {.
  importc: "LLVMConstInBoundsGEP", libllvm.}

proc constTrunc*(constantVal: ValueRef, toType: TypeRef): ValueRef {.
  importc: "LLVMConstTrunc", libllvm.}

proc constSExt*(constantVal: ValueRef, toType: TypeRef): ValueRef {.
  importc: "LLVMConstSExt", libllvm.}

proc constZExt*(constantVal: ValueRef, toType: TypeRef): ValueRef {.
  importc: "LLVMConstZExt", libllvm.}

proc constFPTrunc*(constantVal: ValueRef, toType: TypeRef): ValueRef {.
  importc: "LLVMConstFPTrunc", libllvm.}

proc constFPExt*(constantVal: ValueRef, toType: TypeRef): ValueRef {.
  importc: "LLVMConstFPExt", libllvm.}

proc constUIToFP*(constantVal: ValueRef, toType: TypeRef): ValueRef {.
  importc: "LLVMConstUIToFP", libllvm.}

proc constSIToFP*(constantVal: ValueRef, toType: TypeRef): ValueRef {.
  importc: "LLVMConstSIToFP", libllvm.}

proc constFPToUI*(constantVal: ValueRef, toType: TypeRef): ValueRef {.
  importc: "LLVMConstFPToUI", libllvm.}

proc constFPToSI*(constantVal: ValueRef, toType: TypeRef): ValueRef {.
  importc: "LLVMConstFPToSI", libllvm.}

proc constPtrToInt*(constantVal: ValueRef, toType: TypeRef): ValueRef {.
  importc: "LLVMConstPtrToInt", libllvm.}

proc constIntToPtr*(constantVal: ValueRef, toType: TypeRef): ValueRef {.
  importc: "LLVMConstIntToPtr", libllvm.}

proc constBitCast*(constantVal: ValueRef, toType: TypeRef): ValueRef {.
  importc: "LLVMConstBitCast", libllvm.}

proc constAddrSpaceCast*(constantVal: ValueRef, toType: TypeRef): ValueRef {.
  importc: "LLVMConstAddrSpaceCast", libllvm.}

proc constZExtOrBitCast*(constantVal: ValueRef, toType: TypeRef): ValueRef {.
  importc: "LLVMConstZExtOrBitCast", libllvm.}

proc constSExtOrBitCast*(constantVal: ValueRef, toType: TypeRef): ValueRef {.
  importc: "LLVMConstSExtOrBitCast", libllvm.}

proc constTruncOrBitCast*(constantVal: ValueRef, toType: TypeRef): ValueRef {.
  importc: "LLVMConstTruncOrBitCast", libllvm.}

proc constPointerCast*(constantVal: ValueRef, toType: TypeRef): ValueRef {.
  importc: "LLVMConstPointerCast", libllvm.}

proc constIntCast*(constantVal: ValueRef, toType: TypeRef, isSigned: Bool):
                   ValueRef {.importc: "LLVMConstIntCast", libllvm.}

proc constFPCast*(constantVal: ValueRef, toType: TypeRef): ValueRef {.
  importc: "LLVMConstFPCast", libllvm.}

proc constSelect*(constantCondition: ValueRef, constantIfTrue: ValueRef,
                  constantIfFalse: ValueRef): ValueRef {.
  importc: "LLVMConstSelect", libllvm.}

proc constExtractElement*(vectorConstant: ValueRef, indexConstant: ValueRef):
                          ValueRef {.importc: "LLVMConstExtractElement",
                                    libllvm.}

proc constInsertElement*(vectorConstant: ValueRef,
                         elementValueConstant: ValueRef,
                         indexConstant: ValueRef): ValueRef {.
  importc: "LLVMConstInsertElement", libllvm.}

proc constShuffleVector*(vectorAConstant: ValueRef, vectorBConstant: ValueRef,
                         maskConstant: ValueRef): ValueRef {.
  importc: "LLVMConstShuffleVector", libllvm.}

proc constExtractValue*(aggConstant: ValueRef, idxList: ptr cuint,
                        numIdx: cuint): ValueRef {.
  importc: "LLVMConstExtractValue", libllvm.}

proc constInsertValue*(aggConstant: ValueRef, elementValueConstant: ValueRef,
                       idxList: ptr cuint, numIdx: cuint): ValueRef {.
  importc: "LLVMConstInsertValue", libllvm.}

proc constInlineAsm*(ty: TypeRef, asmString: cstring, constraints: cstring,
                     hasSideEffects: Bool, isAlignStack: Bool): ValueRef {.
  importc: "LLVMConstInlineAsm", libllvm.}

proc BlockAddress*(f: ValueRef, bb: BasicBlockRef): ValueRef {.
  importc: "LLVMBlockAddress", libllvm.}

# This group contains functions that operate on global values. Functions in
# this group relate to functions in the llvm::GlobalValue class tree.

proc getGlobalParent*(global: ValueRef): ModuleRef {.
  importc: "LLVMGetGlobalParent", libllvm.}

proc isDeclaration*(global: ValueRef): Bool {.importc: "LLVMIsDeclaration",
                                             libllvm.}

proc getLinkage*(global: ValueRef): Linkage {.importc: "LLVMGetLinkage",
                                             libllvm.}

proc setLinkage*(global: ValueRef, linkage: Linkage) {.
  importc: "LLVMSetLinkage", libllvm.}

proc getSection*(global: ValueRef): cstring {.importc: "LLVMGetSection",
                                             libllvm.}

proc setSection*(global: ValueRef, section: cstring) {.
  importc: "LLVMSetSection", libllvm.}

proc getVisibility*(global: ValueRef): Visibility {.
  importc: "LLVMGetVisibility", libllvm.}

proc setVisibility*(global: ValueRef, viz: Visibility) {.
  importc: "LLVMSetVisibility", libllvm.}

proc getDLLStorageClass*(global: ValueRef): DLLStorageClass {.
  importc: "LLVMGetDLLStorageClass", libllvm.}

proc setDLLStorageClass*(global: ValueRef, class: DLLStorageClass) {.
  importc: "LLVMSetDLLStorageClass", libllvm.}

proc hasUnnamedAddr*(global: ValueRef): Bool {.importc: "LLVMHasUnnamedAddr",
                                              libllvm.}

proc setUnnamedAddr*(global: ValueRef, hasUnnamedAddr: Bool) {.
  importc: "LLVMSetUnnamedAddr", libllvm.}

# Functions in this group only apply to values with alignment, i.e.
# global variables, load and store instructions.

proc getAlignment*(v: ValueRef): cuint {.importc: "LLVMGetAlignment", libllvm.}
  ## Obtain the preferred alignment of the value.

proc setAlignment*(v: ValueRef, bytes: cuint) {.importc: "LLVMSetAlignment",
                                               libllvm.}
  ## Set the preferred alignment of the value.

# This group contains functions that operate on global variable values.

proc addGlobal*(m: ModuleRef, ty: TypeRef, name: cstring): ValueRef {.
  importc: "LLVMAddGlobal", libllvm.}

proc addGlobalInAddressSpace*(m: ModuleRef, ty: TypeRef, name: cstring,
                              addressSpace: cuint): ValueRef {.
  importc: "LLVMAddGlobalInAddressSpace", libllvm.}

proc getNamedGlobal*(m: ModuleRef, name: cstring): ValueRef {.
  importc: "LLVMGetNamedGlobal", libllvm.}

proc getFirstGlobal*(m: ModuleRef): ValueRef {.importc: "LLVMGetFirstGlobal",
                                              libllvm.}

proc getLastGlobal*(m: ModuleRef): ValueRef {.importc: "LLVMGetLastGlobal",
                                              libllvm.}

proc getNextGlobal*(globalVar: ValueRef): ValueRef {.
  importc: "LLVMGetNextGlobal", libllvm.}

proc getPreviousGlobal*(globalVar: ValueRef): ValueRef {.
  importc: "LLVMGetPreviousGlobal", libllvm.}

proc deleteGlobal*(globalVar: ValueRef) {.importc: "LLVMDeleteGlobal", libllvm.}

proc getInitializer*(globalVar: ValueRef): ValueRef {.
  importc: "LLVMGetInitializer", libllvm.}

proc setInitializer*(globalVar: ValueRef, constantVal: ValueRef) {.
  importc: "LLVMSetInitializer", libllvm.}

proc isThreadLocal*(globalVar: ValueRef): Bool {.importc: "LLVMIsThreadLocal",
                                                libllvm.}

proc setThreadLocal*(globalVar: ValueRef, isThreadLocal: Bool) {.
  importc: "LLVMSetThreadLocal", libllvm.}

proc isGlobalConstant*(globalVar: ValueRef): Bool {.
  importc: "LLVMIsGlobalConstant", libllvm.}

proc setGlobalConstant*(globalVar: ValueRef, isConstant: Bool) {.
  importc: "LLVMSetGlobalConstant", libllvm.}

proc getThreadLocalMode*(globalVar: ValueRef): ThreadLocalMode {.
  importc: "LLVMGetThreadLocalMode", libllvm.}

proc setThreadLocalMode*(globalVar: ValueRef, mode: ThreadLocalMode) {.
  importc: "LLVMSetThreadLocalMode", libllvm.}

proc isExternallyInitialized*(globalVar: ValueRef): Bool {.
  importc: "LLVMIsExternallyInitialized", libllvm.}

proc setExternallyInitialized*(globalVar: ValueRef, isExtInit: Bool) {.
  importc: "LLVMSetExternallyInitialized", libllvm.}

# This group contains function that operate on global alias values.

proc addAlias*(m: ModuleRef, ty: TypeRef, aliasee: ValueRef, name: cstring):
               ValueRef {.importc: "LLVMAddAlias", libllvm.}

# Functions in this group operate on LLVMValueRef instances that
# correspond to llvm::Function instances.

proc deleteFunction*(fn: ValueRef) {.importc: "LLVMDeleteFunction", libllvm.}
  ## Remove a function from its containing module and deletes it.

proc getIntrinsicID*(fn: ValueRef): cuint {.importc: "LLVMGetIntrinsicID",
                                           libllvm.}
  ## Obtain the ID number from a function instance.

proc getFunctionCallConv*(fn: ValueRef): cuint {.
  importc: "LLVMGetFunctionCallConv", libllvm.}
  ## Obtain the calling function of a function.
  ##
  ## The returned value corresponds to the LLVMCallConv enumeration.

proc setFunctionCallConv*(fn: ValueRef, cc: CallConv) {.
  importc: "LLVMSetFunctionCallConv", libllvm.}
  ## Set the calling convention of a function.

proc getGC*(fn: ValueRef): cstring {.importc: "LLVMGetGC", libllvm.}
  ## Obtain the name of the garbage collector to use during code
  ## generation.

proc setGC*(fn: ValueRef, name: cstring) {.importc: "LLVMSetGC", libllvm.}
  ## Define the garbage collector to use during code generation.

proc addFunctionAttr*(fn: ValueRef, pa: Attribute) {.
  importc: "LLVMAddFunctionAttr", libllvm.}
  ## Add an attribute to a function.

proc addTargetDependentFunctionAttr*(fn: ValueRef, a: cstring, v: cstring) {.
  importc: "LLVMAddTargetDependentFunctionAttr", libllvm.}
  ## Add a target-dependent attribute to a fuction

proc getFunctionAttr*(fn: ValueRef): Attribute {.importc: "LLVMGetFunctionAttr",
                                                libllvm.}
  ## Obtain an attribute from a function.

proc removeFunctionAttr*(fn: ValueRef, pa: Attribute) {.
  importc: "LLVMRemoveFunctionAttr", libllvm.}
  ## Remove an attribute from a function.

# Functions in this group relate to arguments/parameters on functions.
#
# Functions in this group expect LLVMValueRef instances that correspond
# to llvm::Function instances.

proc countParams*(fn: ValueRef): cuint {.importc: "LLVMCountParams", libllvm.}
  ## Obtain the number of parameters in a function.

proc getParams*(fn: ValueRef, params: ptr ValueRef) {.importc: "LLVMGetParams",
                                                     libllvm.}
  ## Obtain the parameters in a function.
  ##
  ## The takes a pointer to a pre-allocated array of LLVMValueRef that is
  ## at least LLVMCountParams() long. This array will be filled with
  ## LLVMValueRef instances which correspond to the parameters the
  ## function receives. Each LLVMValueRef corresponds to a llvm::Argument
  ## instance.

proc getParam*(fn: ValueRef, index: cuint): ValueRef {.importc: "LLVMGetParam",
                                                      libllvm.}
  ## Obtain the parameter at the specified index.
  ##
  ## Parameters are indexed from 0.

proc getParamParent*(inst: ValueRef): ValueRef {.importc: "LLVMGetParamParent",
                                                libllvm.}
  ## Obtain the function to which this argument belongs.
  ##
  ## Unlike other functions in this group, this one takes an LLVMValueRef
  ## that corresponds to a llvm::Attribute.
  ##
  ## The returned LLVMValueRef is the llvm::Function to which this
  ## argument belongs.

proc getFirstParam*(fn: ValueRef): ValueRef {.importc: "LLVMGetFirstParam",
                                             libllvm.}
  ## Obtain the first parameter to a function.

proc getLastParam*(fn: ValueRef): ValueRef {.importc: "LLVMGetLastParam",
                                            libllvm.}
  ## Obtain the last parameter to a function.

proc getNextParam*(arg: ValueRef): ValueRef {.importc: "LLVMGetNextParam",
                                             libllvm.}
  ## Obtain the next parameter to a function.
  ##
  ## This takes an LLVMValueRef obtained from LLVMGetFirstParam() (which is
  ## actually a wrapped iterator) and obtains the next parameter from the
  ## underlying iterator.

proc getPreviousParam*(arg: ValueRef): ValueRef {.
  importc: "LLVMGetPreviousParam", libllvm.}
  ## Obtain the previous parameter to a function.
  ##
  ## This is the opposite of LLVMGetNextParam().

proc addAttribute*(arg: ValueRef, pa: Attribute) {.importc: "LLVMAddAttribute",
                                                  libllvm.}
  ## Add an attribute to a function argument.

proc removeAttribute*(arg: ValueRef, pa: Attribute) {.
  importc: "LLVMRemoveAttribute", libllvm.}
  ## Remove an attribute from a function argument.

proc getAttribute*(arg: ValueRef): Attribute {.importc: "LLVMGetAttribute",
                                              libllvm.}
  ## Get an attribute from a function argument.

proc setParamAlignment*(arg: ValueRef, align: cuint) {.
  importc: "LLVMSetParamAlignment", libllvm.}
  ## Set the alignment for a function parameter.

# Metadata

proc mdStringInContext*(c: ContextRef, str: cstring, sLen: cuint): ValueRef {.
  importc: "LLVMMDStringInContext", libllvm.}
  ## Obtain a MDString value from a context.
  ##
  ## The returned instance corresponds to the llvm::MDString class.
  ##
  ## The instance is specified by string data of a specified length. The
  ## string content is copied, so the backing memory can be freed after
  ## this function returns.

proc mdString*(str: cstring, sLen: cuint): ValueRef {.importc: "LLVMMDString",
                                                    libllvm.}
  ## Obtain a MDString value from the global context.

proc mdNodeInContext*(c: ContextRef, vals: ptr ValueRef, count: cuint): ValueRef
  {.importc: "LLVMMDNodeInContext", libllvm.}
  ## Obtain a MDNode value from a context.
  ##
  ## The returned value corresponds to the llvm::MDNode class.

proc mdNode*(vals: ptr ValueRef, count: cuint): ValueRef {.
  importc: "LLVMMDNode", libllvm.}
  ## Obtain a MDNode value from the global context.

proc getMDString*(v: ValueRef, len: ptr cuint): cstring {.
  importc: "LLVMGetMDString", libllvm.}
  ## Obtain the underlying string from a MDString value.

proc getMDNodeNumOperands*(v: ValueRef): cuint {.
  importc: "LLVMGetMDNodeNumOperands", libllvm.}
  ## Obtain the number of operands from an MDNode value.

proc getMDNodeOperands*(v: ValueRef, dest: ptr ValueRef) {.
  importc: "LLVMGetMDNodeOperands", libllvm.}
  ## Obtain the given MDNode's operands.
  ##
  ## The passed LLVMValueRef pointer should point to enough memory to hold all of
  ## the operands of the given MDNode (see LLVMGetMDNodeNumOperands) as
  ## LLVMValueRefs. This memory will be populated with the LLVMValueRefs of the
  ## MDNode's operands.

# A basic block represents a single entry single exit section of code.
# Basic blocks contain a list of instructions which form the body of
# the block.
#
# Basic blocks belong to functions. They have the type of label.
#
# Basic blocks are themselves values. However, the C API models them as
# LLVMBasicBlockRef.

proc basicBlockAsValue*(bb: BasicBlockRef): ValueRef {.
  importc: "LLVMBasicBlockAsValue", libllvm.}
  ## Convert a basic block instance to a value type.

proc valueIsBasicBlock*(val: ValueRef): Bool {.importc: "LLVMValueIsBasicBlock",
                                              libllvm.}
  ## Determine whether an LLVMValueRef is itself a basic block.

proc valueAsBasicBlock*(val: ValueRef): BasicBlockRef {.
  importc: "LLVMValueAsBasicBlock", libllvm.}
  ## Convert an LLVMValueRef to an LLVMBasicBlockRef instance.

proc getBasicBlockParent*(bb: BasicBlockRef): ValueRef {.
  importc: "LLVMGetBasicBlockParent", libllvm.}
  ## Obtain the function to which a basic block belongs.

proc getBasicBlockTerminator*(bb: BasicBlockRef): ValueRef {.
  importc: "LLVMGetBasicBlockTerminator", libllvm.}
  ## Obtain the terminator instruction for a basic block.
  ##
  ## If the basic block does not have a terminator (it is not well-formed
  ## if it doesn't), then NULL is returned.
  ##
  ## The returned LLVMValueRef corresponds to a llvm::TerminatorInst.

proc countBasicBlocks*(fn: ValueRef): cuint {.importc: "LLVMCountBasicBlocks",
                                             libllvm.}
  ## Obtain the number of basic blocks in a function.

proc getBasicBlocks*(fn: ValueRef, basicBlocks: ptr BasicBlockRef) {.
  importc: "LLVMGetBasicBlocks", libllvm.}
  ## Obtain all of the basic blocks in a function.
  ##
  ## This operates on a function value. The BasicBlocks parameter is a
  ## pointer to a pre-allocated array of LLVMBasicBlockRef of at least
  ## LLVMCountBasicBlocks() in length. This array is populated with
  ## LLVMBasicBlockRef instances.

proc getFirstBasicBlock*(fn: ValueRef): BasicBlockRef {.
  importc: "LLVMGetFirstBasicBlock", libllvm.}
  ## Obtain the first basic block in a function.
  ##
  ## The returned basic block can be used as an iterator. You will likely
  ## eventually call into LLVMGetNextBasicBlock() with it.

proc getLastBasicBlock*(fn: ValueRef): BasicBlockRef {.
  importc: "LLVMGetLastBasicBlock", libllvm.}
  ## Obtain the last basic block in a function.

proc getNextBasicBlock*(bb: BasicBlockRef): BasicBlockRef {.
  importc: "LLVMGetNextBasicBlock", libllvm.}
  ## Advance a basic block iterator.

proc getPreviousBasicBlock*(bb: BasicBlockRef): BasicBlockRef {.
  importc: "LLVMGetPreviousBasicBlock", libllvm.}
  ## Go backwards in a basic block iterator.

proc getEntryBasicBlock*(fn: ValueRef): BasicBlockRef {.
  importc: "LLVMGetEntryBasicBlock", libllvm.}
  ## Obtain the basic block that corresponds to the entry point of a
  ## function.

proc appendBasicBlockInContext*(c: ContextRef, fn: ValueRef, name: cstring):
                                BasicBlockRef {.
  importc: "LLVMAppendBasicBlockInContext", libllvm.}
  ## Append a basic block to the end of a function.

proc appendBasicBlock*(fn: ValueRef, name: cstring): BasicBlockRef {.
  importc: "LLVMAppendBasicBlock", libllvm.}
  ## Append a basic block to the end of a function using the global
  ## context.

proc insertBasicBlockInContext*(c: ContextRef, bb: BasicBlockRef, name: cstring):
                                BasicBlockRef {.
  importc: "LLVMInsertBasicBlockInContext", libllvm.}
  ## Insert a basic block in a function before another basic block.
  ##
  ## The function to add to is determined by the function of the
  ## passed basic block.

proc insertBasicBlock*(insertBeforeBB: BasicBlockRef, name: cstring):
                       BasicBlockRef {.importc: "LLVMInsertBasicBlock", libllvm.}
  ## Insert a basic block in a function using the global context.

proc deleteBasicBlock*(bb: BasicBlockRef) {.importc: "LLVMDeleteBasicBlock",
                                           libllvm.}
  ## Remove a basic block from a function and delete it.
  ##
  ## This deletes the basic block from its containing function and deletes
  ## the basic block itself.

proc removeBasicBlockFromParent*(bb: BasicBlockRef) {.
  importc: "LLVMRemoveBasicBlockFromParent", libllvm.}
  ## Remove a basic block from a function.
  ##
  ## This deletes the basic block from its containing function but keep
  ## the basic block alive.

proc moveBasicBlockBefore*(bb: BasicBlockRef, movePos: BasicBlockRef) {.
  importc: "LLVMMoveBasicBlockBefore", libllvm.}
  ## Move a basic block to before another one.

proc moveBasicBlockAfter*(bb: BasicBlockRef, movePos: BasicBlockRef) {.
  importc: "LLVMMoveBasicBlockAfter", libllvm.}
  ## Move a basic block to after another one.

proc getFirstInstruction*(bb: BasicBlockRef): ValueRef {.
  importc: "LLVMGetFirstInstruction", libllvm.}
  ## Obtain the first instruction in a basic block.
  ##
  ## The returned LLVMValueRef corresponds to a llvm::Instruction
  ## instance.

proc GetLastInstruction*(bb: BasicBlockRef): ValueRef {.
  importc: "LLVMGetLastInstruction", libllvm.}
  ## Obtain the last instruction in a basic block.
  ##
  ## The returned LLVMValueRef corresponds to an LLVM:Instruction.

# Functions in this group relate to the inspection and manipulation of
# individual instructions.
#
# In the C++ API, an instruction is modeled by llvm::Instruction. This
# class has a large number of descendents. llvm::Instruction is a
# llvm::Value and in the C API, instructions are modeled by
# LLVMValueRef.
#
# This group also contains sub-groups which operate on specific
# llvm::Instruction types, e.g. llvm::CallInst.

proc hasMetadata*(val: ValueRef): cint {.importc: "LLVMHasMetadata", libllvm.}
  ## Determine whether an instruction has any metadata attached.

proc getMetadata*(val: ValueRef, kindID: cuint): ValueRef {.
  importc: "LLVMGetMetadata", libllvm.}
  ## Return metadata associated with an instruction value.

proc setMetadata*(val: ValueRef, kindID: cuint, node: ValueRef) {.
  importc: "LLVMSetMetadata", libllvm.}
  ## Set metadata associated with an instruction value.

proc getInstructionParent*(inst: ValueRef): BasicBlockRef {.
  importc: "LLVMGetInstructionParent", libllvm.}
  ## Obtain the basic block to which an instruction belongs.

proc getNextInstruction*(inst: ValueRef): ValueRef {.
  importc: "LLVMGetNextInstruction", libllvm.}
  ## Obtain the instruction that occurs after the one specified.
  ##
  ## The next instruction will be from the same basic block.
  ##
  ## If this is the last instruction in a basic block, NULL will be
  ## returned.

proc getPreviousInstruction*(inst: ValueRef): ValueRef {.
  importc: "LLVMGetPreviousInstruction", libllvm.}
  ## Obtain the instruction that occurred before this one.
  ##
  ## If the instruction is the first instruction in a basic block, NULL
  ## will be returned.

proc instructionEraseFromParent*(inst: ValueRef) {.
  importc: "LLVMInstructionEraseFromParent", libllvm.}
  ## Remove and delete an instruction.
  ##
  ## The instruction specified is removed from its containing building
  ## block and then deleted.

proc getInstructionOpcode*(inst: ValueRef): Opcode {.
  importc: "LLVMGetInstructionOpcode", libllvm.}
  ## Obtain the code opcode for an individual instruction.

proc getICmpPredicate*(inst: ValueRef): IntPredicate {.
  importc: "LLVMGetICmpPredicate", libllvm.}
  ## Obtain the predicate of an instruction.
  ##
  ## This is only valid for instructions that correspond to llvm::ICmpInst
  ## or llvm::ConstantExpr whose opcode is llvm::Instruction::ICmp.

# Functions in this group apply to instructions that refer to call
# sites and invocations. These correspond to C++ types in the
# llvm::CallInst class tree.

proc setInstructionCallConv*(instr: ValueRef, cc: cuint) {.
  importc: "LLVMSetInstructionCallConv", libllvm.}
  ## Set the calling convention for a call instruction.
  ##
  ## This expects an LLVMValueRef that corresponds to a llvm::CallInst or
  ## llvm::InvokeInst.

proc getInstructionCallConv*(instr: ValueRef): cuint {.
  importc: "LLVMGetInstructionCallConv", libllvm.}
  ## Obtain the calling convention for a call instruction.
  ##
  ## This is the opposite of LLVMSetInstructionCallConv(). Reads its
  ## usage.

proc addInstrAttribute*(instr: ValueRef, index: cuint, attr: Attribute) {.
  importc: "LLVMAddInstrAttribute", libllvm.}

proc removeInstrAttribute*(instr: ValueRef, index: cuint, attr: Attribute) {.
  importc: "LLVMRemoveInstrAttribute", libllvm.}

proc setInstrParamAlignment*(instr: ValueRef, index: cuint, align: cuint) {.
  importc: "LLVMSetInstrParamAlignment", libllvm.}

proc isTailCall*(callInst: ValueRef): Bool {.importc: "LLVMIsTailCall", libllvm.}
  ## Obtain whether a call instruction is a tail call.
  ##
  ## This only works on llvm::CallInst instructions.

proc setTailCall*(callInst: ValueRef, isTailCall: Bool) {.
  importc: "LLVMSetTailCall", libllvm.}
  ## Set whether a call instruction is a tail call.
  ##
  ## This only works on llvm::CallInst instructions.

proc getSwitchDefaultDest*(SwitchInstr: ValueRef): BasicBlockRef {.
  importc: "LLVMGetSwitchDefaultDest", libllvm.}
  ## Obtain the default destination basic block of a switch instruction.
  ##
  ## This only works on llvm::SwitchInst instructions.

# Functions in this group only apply to instructions that map to
# llvm::PHINode instances.

proc addIncoming*(phiNode: ValueRef, incomingValues: ptr ValueRef,
                  incomingBlocks: ptr BasicBlockRef, count: cuint) {.
  importc: "LLVMAddIncoming", libllvm.}
  ## Add an incoming value to the end of a PHI list.

proc countIncoming*(phiNode: ValueRef): cuint {.importc: "LLVMCountIncoming",
                                               libllvm.}
  ## Obtain the number of incoming basic blocks to a PHI node.

proc getIncomingValue*(phiNode: ValueRef, index: cuint): ValueRef {.
  importc: "LLVMGetIncomingValue", libllvm.}
  ## Obtain an incoming value to a PHI node as an LLVMValueRef.

proc getIncomingBlock*(phiNode: ValueRef, index: cuint): BasicBlockRef {.
  importc: "LLVMGetIncomingBlock", libllvm.}
  ## Obtain an incoming value to a PHI node as an LLVMBasicBlockRef.

# An instruction builder represents a point within a basic block and is
# the exclusive means of building instructions using the C interface.

proc createBuilderInContext*(c: ContextRef): BuilderRef {.
  importc: "LLVMCreateBuilderInContext", libllvm.}

proc createBuilder*: BuilderRef {.importc: "LLVMCreateBuilder", libllvm.}

proc positionBuilder*(builder: BuilderRef, bb: BasicBlockRef, instr: ValueRef) {.
  importc: "LLVMPositionBuilder", libllvm.}

proc positionBuilderBefore*(builder: BuilderRef, instr: ValueRef) {.
  importc: "LLVMPositionBuilderBefore", libllvm.}

proc positionBuilderAtEnd*(builder: BuilderRef, bb: BasicBlockRef) {.
  importc: "LLVMPositionBuilderAtEnd", libllvm.}

proc getInsertBlock*(builder: BuilderRef): BasicBlockRef {.
  importc: "LLVMGetInsertBlock", libllvm.}

proc clearInsertionPosition*(builder: BuilderRef) {.
  importc: "LLVMClearInsertionPosition", libllvm.}

proc insertIntoBuilder*(builder: BuilderRef, instr: ValueRef) {.
  importc: "LLVMInsertIntoBuilder", libllvm.}

proc insertIntoBuilderWithName*(builder: BuilderRef, instr: ValueRef,
                                name: cstring) {.
  importc: "LLVMInsertIntoBuilderWithName", libllvm.}

proc disposeBuilder*(builder: BuilderRef) {.importc: "LLVMDisposeBuilder",
                                           libllvm.}

# Metadata

proc setCurrentDebugLocation*(builder: BuilderRef, location: ValueRef) {.
  importc: "LLVMSetCurrentDebugLocation", libllvm.}

proc getCurrentDebugLocation*(builder: BuilderRef): ValueRef {.
  importc: "LLVMGetCurrentDebugLocation", libllvm.}

proc setInstDebugLocation*(builder: BuilderRef, inst: ValueRef) {.
  importc: "LLVMSetInstDebugLocation", libllvm.}

# Terminators

proc buildRetVoid*(builder: BuilderRef): ValueRef {.importc: "LLVMBuildRetVoid",
                                                   libllvm.}

proc buildRet*(builder: BuilderRef, v: ValueRef): ValueRef {.
  importc: "LLVMBuildRet", libllvm.}

proc buildAggregateRet*(builder: BuilderRef, retVals: ptr ValueRef, n: cuint):
                        ValueRef {.importc: "LLVMBuildAggregateRet", libllvm.}

proc buildBr*(builder: BuilderRef, dest: BasicBlockRef): ValueRef {.
  importc: "LLVMBuildBr", libllvm.}

proc buildCondBr*(builder: BuilderRef, ifCond: ValueRef, then: BasicBlockRef,
                  elseBranch: BasicBlockRef): ValueRef {.
  importc: "LLVMBuildCondBr", libllvm.}

proc buildSwitch*(builder: BuilderRef, v: ValueRef, elseBranch: BasicBlockRef,
                  numCases: cuint): ValueRef {.importc: "LLVMBuildSwitch",
                                              libllvm.}

proc buildIndirectBr*(builder: BuilderRef, address: ValueRef, numDests: cuint):
                      ValueRef {.importc: "LLVMBuildIndirectBr", libllvm.}

proc buildInvoke*(builder: BuilderRef, fn: ValueRef, args: ptr ValueRef,
                  numArgs: cuint, then: BasicBlockRef, catch: BasicBlockRef,
                  name: cstring): ValueRef {.importc: "LLVMBuildInvoke", libllvm.}

proc buildLandingPad*(builder: BuilderRef, ty: TypeRef, persFn: ValueRef,
                      numClauses: cuint, name: cstring): ValueRef {.
  importc: "LLVMBuildLandingPad", libllvm.}

proc buildResume*(builder: BuilderRef, exn: ValueRef): ValueRef {.
  importc: "LLVMBuildResume", libllvm.}

proc buildUnreachable*(builder: BuilderRef): ValueRef {.
  importc: "LLVMBuildUnreachable", libllvm.}

proc addCase*(switch: ValueRef, onVal: ValueRef, dest: BasicBlockRef) {.
  importc: "LLVMAddCase", libllvm.}
  ## Add a case to the switch instruction

proc addDestination*(indirectBr: ValueRef, dest: BasicBlockRef) {.
  importc: "LLVMAddDestination", libllvm.}
  ## Add a destination to the indirectbr instruction

proc addClause*(landingPad: ValueRef, clauseVal: ValueRef) {.
  importc: "LLVMAddClause", libllvm.}
  ## Add a catch or filter clause to the landingpad instruction

proc setCleanup*(landingPad: ValueRef, val: Bool) {.importc: "LLVMAddClause",
                                                   libllvm.}
  ## Set the 'cleanup' flag in the landingpad instruction

# Arithmetic

proc buildAdd*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef, name: cstring):
               ValueRef {.importc: "LLVMBuildAdd", libllvm.}

proc buildNSWAdd*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef,
                  name: cstring): ValueRef {.importc: "LLVMBuildNSWAdd", libllvm.}

proc buildNUWAdd*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef,
                  name: cstring): ValueRef {.importc: "LLVMBuildNUWAdd", libllvm.}

proc buildFAdd*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef, name: cstring):
                ValueRef {.importc: "LLVMBuildFAdd", libllvm.}

proc buildSub*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef, name: cstring):
               ValueRef {.importc: "LLVMBuildSub", libllvm.}

proc buildNSWSub*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef,
                  name: cstring): ValueRef {.importc: "LLVMBuildNSWSub", libllvm.}

proc buildNUWSub*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef,
                  name: cstring): ValueRef {.importc: "LLVMBuildNUWSub", libllvm.}

proc buildFSub*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef, name: cstring):
                ValueRef {.importc: "LLVMBuildFSub", libllvm.}

proc buildMul*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef, name: cstring):
               ValueRef {.importc: "LLVMBuildMul", libllvm.}

proc buildNSWMul*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef,
                  name: cstring): ValueRef {.importc: "LLVMBuildNSWMul", libllvm.}

proc buildNUWMul*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef,
                  name: cstring): ValueRef {.importc: "LLVMBuildNUWMul", libllvm.}

proc buildFMul*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef, name: cstring):
                ValueRef {.importc: "LLVMBuildFMul", libllvm.}

proc buildUDiv*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef, name: cstring):
                ValueRef {.importc: "LLVMBuildUDiv", libllvm.}

proc buildSDiv*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef, name: cstring):
                ValueRef {.importc: "LLVMBuildSDiv", libllvm.}

proc buildExactSDiv*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef,
                     name: cstring): ValueRef {.importc: "LLVMBuildExactSDiv",
                                               libllvm.}

proc buildFDiv*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef, name: cstring):
                ValueRef {.importc: "LLVMBuildFDiv", libllvm.}

proc buildURem*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef, name: cstring):
                ValueRef {.importc: "LLVMBuildURem", libllvm.}

proc buildSRem*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef, name: cstring):
                ValueRef {.importc: "LLVMBuildSRem", libllvm.}

proc buildFRem*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef, name: cstring):
                ValueRef {.importc: "LLVMBuildFRem", libllvm.}

proc buildShl*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef, name: cstring):
               ValueRef {.importc: "LLVMBuildShl", libllvm.}

proc buildLShr*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef, name: cstring):
                ValueRef {.importc: "LLVMBuildLShr", libllvm.}

proc buildAShr*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef, name: cstring):
                ValueRef {.importc: "LLVMBuildAShr", libllvm.}

proc buildAnd*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef, name: cstring):
               ValueRef {.importc: "LLVMBuildAnd", libllvm.}

proc buildOr*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef, name: cstring):
              ValueRef {.importc: "LLVMBuildOr", libllvm.}

proc buildXor*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef, name: cstring):
               ValueRef {.importc: "LLVMBuildXor", libllvm.}

proc buildBinOp*(builder: BuilderRef, op: Opcode, lhs: ValueRef, rhs: ValueRef,
                 name: cstring): ValueRef {.importc: "LLVMBuildBinOp", libllvm.}

proc buildNeg*(builder: BuilderRef, v: ValueRef, name: cstring): ValueRef {.
  importc: "LLVMBuildNeg", libllvm.}

proc buildNSWNeg*(builder: BuilderRef, v: ValueRef, name: cstring): ValueRef {.
  importc: "LLVMBuildNSWNeg", libllvm.}

proc buildNUWNeg*(builder: BuilderRef, v: ValueRef, name: cstring): ValueRef {.
  importc: "LLVMBuildNUWNeg", libllvm.}

proc buildFNeg*(builder: BuilderRef, v: ValueRef, name: cstring): ValueRef {.
  importc: "LLVMBuildFNeg", libllvm.}

proc buildNot*(builder: BuilderRef, v: ValueRef, name: cstring): ValueRef {.
  importc: "LLVMBuildNot", libllvm.}

# Memory

proc buildMalloc*(builder: BuilderRef, ty: TypeRef, name: cstring): ValueRef {.
  importc: "LLVMBuildMalloc", libllvm.}

proc buildArrayMalloc*(builder: BuilderRef, ty: TypeRef, val: ValueRef,
                       name: cstring): ValueRef {.
  importc: "LLVMBuildArrayMalloc", libllvm.}

proc buildAlloca*(builder: BuilderRef, ty: TypeRef, name: cstring): ValueRef {.
  importc: "LLVMBuildAlloca", libllvm.}

proc buildArrayAlloca*(builder: BuilderRef, ty: TypeRef, val: ValueRef,
                       name: cstring): ValueRef {.
  importc: "LLVMBuildArrayAlloca", libllvm.}

proc buildFree*(builder: BuilderRef, pointerVal: ValueRef): ValueRef {.
  importc: "LLVMBuildFree", libllvm.}

proc buildLoad*(builder: BuilderRef, pointerVal: ValueRef, name: cstring):
                ValueRef {.importc: "LLVMBuildLoad", libllvm.}

proc buildStore*(builder: BuilderRef, val: ValueRef, address: ValueRef):
                 ValueRef {.importc: "LLVMBuildStore", libllvm.}

proc buildGEP*(builder: BuilderRef, pointer: ValueRef, indices: ptr ValueRef,
               numIndices: cuint, name: cstring): ValueRef {.
  importc: "LLVMBuildGEP", libllvm.}

proc buildInBoundsGEP*(builder: BuilderRef, pointer: ValueRef,
                       indices: ptr ValueRef, numIndices: cuint, name: cstring):
                       ValueRef {.importc: "LLVMBuildInBoundsGEP", libllvm.}

proc buildStructGEP*(builder: BuilderRef, pointer: ValueRef, idx: cuint,
                     name: cstring): ValueRef {.importc: "LLVMBuildStructGEP",
                                               libllvm.}

proc buildGlobalString*(builder: BuilderRef, str: cstring, name: cstring):
                        ValueRef {.importc: "LLVMBuildGlobalString", libllvm.}

proc buildGlobalStringPtr*(builder: BuilderRef, str: cstring, name: cstring):
                           ValueRef {.importc: "LLVMBuildGlobalStringPtr",
                                     libllvm.}

proc getVolatile*(memoryAccessInst: ValueRef): Bool {.importc: "LLVMGetVolatile",
                                                     libllvm.}

proc setVolatile*(memoryAccessInst: ValueRef, isVolatile: Bool) {.
  importc: "LLVMSetVolatile", libllvm.}

# Casts

proc buildTrunc*(builder: BuilderRef, val: ValueRef, destTy: TypeRef,
                 name: cstring): ValueRef {.importc: "LLVMBuildTrunc", libllvm.}

proc buildZExt*(builder: BuilderRef, val: ValueRef, destTy: TypeRef,
                name: cstring): ValueRef {.importc: "LLVMBuildZExt", libllvm.}

proc buildSExt*(builder: BuilderRef, val: ValueRef, destTy: TypeRef,
                name: cstring): ValueRef {.importc: "LLVMBuildSExt", libllvm.}

proc buildFPToUI*(builder: BuilderRef, val: ValueRef, destTy: TypeRef,
                  name: cstring): ValueRef {.importc: "LLVMBuildFPToUI", libllvm.}

proc buildFPToSI*(builder: BuilderRef, val: ValueRef, destTy: TypeRef,
                  name: cstring): ValueRef {.importc: "LLVMBuildFPToSI", libllvm.}

proc buildUIToFP*(builder: BuilderRef, val: ValueRef, destTy: TypeRef,
                  name: cstring): ValueRef {.importc: "LLVMBuildUIToFP", libllvm.}

proc buildSIToFP*(builder: BuilderRef, val: ValueRef, destTy: TypeRef,
                  name: cstring): ValueRef {.importc: "LLVMBuildSIToFP", libllvm.}

proc buildFPTrunc*(builder: BuilderRef, val: ValueRef, destTy: TypeRef,
                   name: cstring): ValueRef {.importc: "LLVMBuildFPTrunc",
                                             libllvm.}

proc buildFPExt*(builder: BuilderRef, val: ValueRef, destTy: TypeRef,
                 name: cstring): ValueRef {.importc: "LLVMBuildFPExt", libllvm.}

proc buildPtrToInt*(builder: BuilderRef, val: ValueRef, destTy: TypeRef,
                    name: cstring): ValueRef {.importc: "LLVMBuildPtrToInt",
                                              libllvm.}

proc buildIntToPtr*(builder: BuilderRef, val: ValueRef, destTy: TypeRef,
                    name: cstring): ValueRef {.importc: "LLVMBuildIntToPtr",
                                              libllvm.}

proc buildBitCast*(builder: BuilderRef, val: ValueRef, destTy: TypeRef,
                   name: cstring): ValueRef {.importc: "LLVMBuildBitCast",
                                             libllvm.}

proc buildAddrSpaceCast*(builder: BuilderRef, val: ValueRef, destTy: TypeRef,
                         name: cstring): ValueRef {.
  importc: "LLVMBuildAddrSpaceCast", libllvm.}

proc buildZExtOrBitCast*(builder: BuilderRef, val: ValueRef, destTy: TypeRef,
                         name: cstring): ValueRef {.
  importc: "LLVMBuildZExtOrBitCast", libllvm.}

proc buildSExtOrBitCast*(builder: BuilderRef, val: ValueRef, destTy: TypeRef,
                         name: cstring): ValueRef {.
  importc: "LLVMBuildSExtOrBitCast", libllvm.}

proc buildTruncOrBitCast*(builder: BuilderRef, val: ValueRef, destTy: TypeRef,
                          name: cstring): ValueRef {.
  importc: "LLVMBuildTruncOrBitCast", libllvm.}

proc buildCast*(builder: BuilderRef, op: Opcode, val: ValueRef, destTy: TypeRef,
                name: cstring): ValueRef {.importc: "LLVMBuildCast", libllvm.}

proc buildPointerCast*(builder: BuilderRef, val: ValueRef, destTy: TypeRef,
                       name: cstring): ValueRef {.
  importc: "LLVMBuildPointerCast", libllvm.}

proc buildIntCast*(builder: BuilderRef, val: ValueRef, destTy: TypeRef,
                   name: cstring): ValueRef {.importc: "LLVMBuildIntCast",
                                             libllvm.}

proc buildFPCast*(builder: BuilderRef, val: ValueRef, destTy: TypeRef,
                  name: cstring): ValueRef {.importc: "LLVMBuildFPCast", libllvm.}

# Comparisons

proc buildICmp*(builder: BuilderRef, op: IntPredicate, lhs: ValueRef,
                rhs: ValueRef, name: cstring): ValueRef {.
  importc: "LLVMBuildICmp", libllvm.}

proc buildFCmp*(builder: BuilderRef, op: IntPredicate, lhs: ValueRef,
                rhs: ValueRef, name: cstring): ValueRef {.
  importc: "LLVMBuildFCmp", libllvm.}

# Miscellaneous instructions

proc buildPhi*(builder: BuilderRef, ty: TypeRef, name: cstring): ValueRef {.
  importc: "LLVMBuildPhi", libllvm.}

proc buildCall*(builder: BuilderRef, fn: ValueRef, args: ptr ValueRef,
                numArgs: cuint, name: cstring): ValueRef {.
  importc: "LLVMBuildCall", libllvm.}

proc buildSelect*(builder: BuilderRef, ifCond: ValueRef, then: ValueRef,
                  elseBranch: ValueRef, name: cstring): ValueRef {.
  importc: "LLVMBuildSelect", libllvm.}

proc buildVAArg*(builder: BuilderRef, list: ValueRef, ty: TypeRef, name: cstring):
                 ValueRef {.importc: "LLVMBuildVAArg", libllvm.}

proc buildExtractElement*(builder: BuilderRef, vecVal: ValueRef, index: ValueRef,
                          name: cstring): ValueRef {.
  importc: "LLVMBuildExtractElement", libllvm.}

proc buildInsertElement*(builder: BuilderRef, vecVal: ValueRef, eltVal: ValueRef,
                         index: ValueRef, name: cstring): ValueRef {.
  importc: "LLVMBuildInsertElement", libllvm.}

proc buildShuffleVector*(builder: BuilderRef, v1: ValueRef, v2: ValueRef,
                         mask: ValueRef, name: cstring): ValueRef {.
  importc: "LLVMBuildShuffleVector", libllvm.}

proc buildExtractValue*(builder: BuilderRef, aggVal: ValueRef, index: cuint,
                        name: cstring): ValueRef {.
  importc: "LLVMBuildExtractValue", libllvm.}

proc BuildInsertValue*(builder: BuilderRef, aggVal: ValueRef, eltVal: ValueRef,
                       index: cuint, name: cstring): ValueRef {.
  importc: "LLVMBuildInsertValue", libllvm.}

proc buildIsNull*(builder: BuilderRef, val: ValueRef, name: cstring): ValueRef {.
  importc: "LLVMBuildIsNull", libllvm.}

proc buildIsNotNull*(builder: BuilderRef, val: ValueRef, name: cstring):
                     ValueRef {.importc: "LLVMBuildIsNotNull", libllvm.}

proc buildPtrDiff*(builder: BuilderRef, lhs: ValueRef, rhs: ValueRef,
                   name: cstring): ValueRef {.importc: "LLVMBuildPtrDiff",
                                             libllvm.}

proc buildFence*(builder: BuilderRef, ordering: AtomicOrdering,
                 singleThread: Bool, name: cstring): ValueRef {.
  importc: "LLVMBuildFence", libllvm.}

proc buildAtomicRMW*(builder: BuilderRef, op: AtomicRMWBinOp, address: ValueRef,
                     val: ValueRef, ordering: AtomicOrdering, singleThread: Bool):
                     ValueRef {.importc: "LLVMBuildAtomicRMW", libllvm.}

# Module Providers

proc createModuleProviderForExistingModule*(m: ModuleRef): ModuleProviderRef {.
  importc: "LLVMCreateModuleProviderForExistingModule", libllvm.}
  ## Changes the type of M so it can be passed to FunctionPassManagers and the
  ## JIT.  They take ModuleProviders for historical reasons.

proc disposeModuleProvider*(m: ModuleProviderRef) {.
  importc: "LLVMDisposeModuleProvider", libllvm.}
  ## Destroys the module M.

# Memory Buffers

proc createMemoryBufferWithContentsOfFile*(path: cstring,
                                           outMemBuf: ptr MemoryBufferRef,
                                           outMessage: cstringArray): Bool {.
  importc: "LLVMCreateMemoryBufferWithContentsOfFile", libllvm.}

proc createMemoryBufferWithSTDIN*(outMemBuf: ptr MemoryBufferRef,
                                  outMessage: cstringArray): Bool {.
  importc: "LLVMCreateMemoryBufferWithSTDIN", libllvm.}

proc createMemoryBufferWithMemoryRange*(inputData: cstring,
                                        inputDataLength: csize,
                                        bufferName: cstring,
                                        requiresNullTerminator: Bool):
                                        MemoryBufferRef {.
  importc: "LLVMCreateMemoryBufferWithMemoryRange", libllvm.}

proc createMemoryBufferWithMemoryRangeCopy*(InputData: cstring,
                                            InputDataLength: csize,
                                            BufferName: cstring):
                                            MemoryBufferRef {.
  importc: "LLVMCreateMemoryBufferWithMemoryRangeCopy", libllvm.}

proc getBufferStart*(memBuf: MemoryBufferRef): cstring {.
  importc: "LLVMGetBufferStart", libllvm.}

proc getBufferSize*(memBuf: MemoryBufferRef): csize {.
  importc: "LLVMGetBufferSize", libllvm.}

proc disposeMemoryBuffer*(memBuf: MemoryBufferRef) {.
  importc: "LLVMDisposeMemoryBuffer", libllvm.}

# Pass Registry

proc getGlobalPassRegistry*: PassRegistryRef {.
  importc: "LLVMGetGlobalPassRegistry", libllvm.}
  ## Return the global pass registry, for use with initialization functions.

# Pass Managers

proc createPassManager*: PassManagerRef {.importc: "LLVMCreatePassManager",
                                         libllvm.}
  ## Constructs a new whole-module pass pipeline. This type of pipeline is
  ## suitable for link-time optimization and whole-module transformations.

proc createFunctionPassManagerForModule*(m: ModuleRef): PassManagerRef {.
  importc: "LLVMCreateFunctionPassManagerForModule", libllvm.}
  ## Constructs a new function-by-function pass pipeline over the module
  ## provider. It does not take ownership of the module provider. This type of
  ## pipeline is suitable for code generation and JIT compilation tasks.

proc createFunctionPassManager*(mp: ModuleProviderRef): PassManagerRef {.
  deprecated, importc: "LLVMCreateFunctionPassManager", libllvm.}
  ## Deprecated: Use LLVMCreateFunctionPassManagerForModule instead.

proc runPassManager*(pm: PassManagerRef, m: ModuleRef): Bool {.
  importc: "LLVMRunPassManager", libllvm.}
  ## Initializes, executes on the provided module, and finalizes all of the
  ## passes scheduled in the pass manager. Returns 1 if any of the passes
  ## modified the module, 0 otherwise.

proc initializeFunctionPassManager*(fpm: PassManagerRef): Bool {.
  importc: "LLVMInitializeFunctionPassManager", libllvm.}
  ## Initializes all of the function passes scheduled in the function pass
  ## manager. Returns 1 if any of the passes modified the module, 0 otherwise.

proc runFunctionPassManager*(fpm: PassManagerRef, f: ValueRef): Bool {.
  importc: "LLVMRunFunctionPassManager", libllvm.}
  ## Executes all of the function passes scheduled in the function pass manager
  ## on the provided function. Returns 1 if any of the passes modified the
  ## function, false otherwise.

proc finalizeFunctionPassManager*(fpm: PassManagerRef): Bool {.
  importc: "LLVMFinalizeFunctionPassManager", libllvm.}
  ## Finalizes all of the function passes scheduled in in the function pass
  ## manager. Returns 1 if any of the passes modified the module, 0 otherwise.

proc disposePassManager*(pm: PassManagerRef) {.importc: "LLVMDisposePassManager",
                                              libllvm.}
  ## Frees the memory of a pass pipeline. For function pipelines, does not free
  ## the module provider.

# Handle the structures needed to make LLVM safe for multithreading.

proc startMultithreaded*: Bool {.deprecated, importc: "LLVMStartMultithreaded",
                                libllvm.}
  ## Deprecated: Multi-threading can only be enabled/disabled with the compile
  ## time define LLVM_ENABLE_THREADS.  This function always returns
  ## LLVMIsMultithreaded().

proc stopMultithreaded* {.deprecated, importc: "LLVMStopMultithreaded", libllvm.}
  ## Deprecated: Multi-threading can only be enabled/disabled with the compile
  ## time define LLVM_ENABLE_THREADS.

proc isMultithreaded*: Bool {.importc: "LLVMIsMultithreaded", libllvm.}
  ## Check whether LLVM is executing in thread-safe mode or not.
