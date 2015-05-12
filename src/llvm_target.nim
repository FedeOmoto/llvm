## This header declares the C interface to libLLVMTarget.a, which
## implements target information.
##
## Many exotic languages can interoperate with C code but have a harder time
## with C++ due to name mangling. So in addition to C, this interface enables
## tools written in such languages.

import llvm_core, macros, strutils#, pegs

include llvm_lib, llvm_config

proc defPath(): string {.compileTime.} =
  result = ".."
  for i in 3..currentSourcePath.count("/"):
    result &= "/.."
  result &= gorge("llvm-config --includedir") & "/llvm/Config/"

const DefPath = defPath()

#macro targetsFor(suffix: string): stmt =
#  var targets = newSeq[string]()
#  let def = slurp(DefPath & suffix.strVal & "s.def")
#  for line in def.splitLines():
#    if line.len != 0 and line =~ peg"(LLVM_\ident\({\ident}\)\s*)*":
#      for match in matches:
#        if match != nil: targets.add(match)
#      break
#  result = parseStmt("const " & suffix.strVal & "s* = " & repr(targets))

macro targetsFor(suffix: string): stmt =
  var targets = newSeq[string]()
  let def = slurp(DefPath & suffix.strVal & "s.def")
  for line in def.splitLines():
    if line.startsWith("LLVM_"):
      for str in line.split(')'):
        var target = str.split('(')
        if target.len == 2: targets.add(target[1])
      break
  result = parseStmt("const " & suffix.strVal & "s* = " & repr(targets))

# Target information

const Targets* = gorge("llvm-config --targets-built").strip.split(' ')

targetsFor("AsmPrinter")
targetsFor("AsmParser")
targetsFor("Disassembler")

type
  ByteOrdering* = enum
    BigEndian
    LittleEndian

type
  TargetDataRef* = ptr object
  TargetLibraryInfoRef* = ptr object

macro declareTargetProcs(targets: static[openArray[string]], suffix: string): stmt =
  var src = ""
  for target in targets:
    when defined(dynamic_link) or defined(static_link):
      src &= ("proc LLVMInitialize$1$2 {.importc: \"LLVMInitialize$1$2\", " &
             "libllvm.}\n") % [target, suffix.strVal]
      src &= ("proc initialize$1$2* = LLVMInitialize$1$2()\n") % [target, suffix.strVal]
    else:
      src &= ("proc initialize$1$2* {.importc: \"LLVMInitialize$1$2\", " &
             "libllvm.}\n") % [target, suffix.strVal]
      src &= ("proc LLVMInitialize$1$2 {.exportc.} = initialize$1$2()\n") %
             [target, suffix.strVal]
  result = parseStmt(src)

# Declare all of the target-initialization functions that are available.
declareTargetProcs(Targets, "TargetInfo")
declareTargetProcs(Targets, "Target")
declareTargetProcs(Targets, "TargetMC")

# Declare all of the available assembly printer initialization functions.
declareTargetProcs(AsmPrinters, "AsmPrinter")

# Declare all of the available assembly parser initialization functions.
declareTargetProcs(AsmParsers, "AsmParser")

# Declare all of the available disassembler initialization functions.
declareTargetProcs(Disassemblers, "Disassembler")

macro defineTargetProcBody(targets: static[openArray[string]], suffix: string): stmt =
  var src = ""
  for target in targets:
    src &= "initialize" & target & suffix.strVal & "()\n"
  result = parseStmt(src)

proc initializeAllTargetInfos* {.inline.} =
  defineTargetProcBody(Targets, "TargetInfo")
  ## The main program should call this function if it wants access to all
  ## available targets that LLVM is configured to support.

proc initializeAllTargets* {.inline.} =
  defineTargetProcBody(Targets, "Target")
  ## The main program should call this function if it wants to link in all
  ## available targets that LLVM is configured to support.

proc initializeAllTargetMCs* {.inline.} =
  defineTargetProcBody(Targets, "TargetMC")
  ## The main program should call this function if it wants access to all
  ## available target MC that LLVM is configured to support.

proc initializeAllAsmPrinters* {.inline.} =
  defineTargetProcBody(AsmPrinters, "AsmPrinter")
  ## The main program should call this function if it wants all asm printers that
  ## LLVM is configured to support, to make them available via the TargetRegistry.

proc initializeAllAsmParsers* {.inline.} =
  defineTargetProcBody(AsmParsers, "AsmParser")
  ## The main program should call this function if it wants all asm parsers that
  ## LLVM is configured to support, to make them available via the TargetRegistry.

proc initializeAllDisassemblers* {.inline.} =
  defineTargetProcBody(Disassemblers, "Disassembler")
  ## The main program should call this function if it wants all disassemblers that
  ## LLVM is configured to support, to make them available via the TargetRegistry.

proc initializeNativeTarget*: Bool {.inline.} =
  # If we have a native target, initialize it to ensure it is linked in.
  when declared(LLVM_NATIVE_TARGET):
    LLVM_NATIVE_TARGETINFO()
    LLVM_NATIVE_TARGET()
    LLVM_NATIVE_TARGETMC()
    return 0
  else:
    return 1
  ## The main program should call this function to initialize the native target
  ## corresponding to the host. This is useful for JIT applications to ensure
  ## that the target gets linked in correctly.

proc initializeNativeAsmParser*: Bool {.inline.} =
  when declared(LLVM_NATIVE_ASMPARSER):
    LLVM_NATIVE_ASMPARSER()
    return 0
  else:
    return 1
  ## The main program should call this function to initialize the parser for the
  ## native target corresponding to the host.

proc initializeNativeAsmPrinter*: Bool {.inline.} =
  when declared(LLVM_NATIVE_ASMPRINTER):
    LLVM_NATIVE_ASMPRINTER()
    return 0
  else:
    retuen 1
  ## The main program should call this function to initialize the printer for the
  ## native target corresponding to the host.

proc initializeNativeDisassembler*: Bool {.inline.} =
  when declared(LLVM_NATIVE_DISASSEMBLER):
    LLVM_NATIVE_DISASSEMBLER()
    return 0
  else:
    return 1
  ## The main program should call this function to initialize the disassembler
  ## for the native target corresponding to the host.

# Target Data

proc createTargetData*(stringRep: cstring): TargetDataRef {.
  importc: "LLVMCreateTargetData", libllvm.}
  ## Creates target data from a target layout string.

proc addTargetData*(td: TargetDataRef, pm: PassManagerRef) {.
  importc: "LLVMAddTargetData", libllvm.}
  ## Adds target data information to a pass manager. This does not take ownership
  ## of the target data.

proc addTargetLibraryInfo*(tli: TargetLibraryInfoRef, pm: PassManagerRef) {.
  importc: "LLVMAddTargetLibraryInfo", libllvm.}
  ## Adds target library information to a pass manager. This does not take
  ## ownership of the target library info.

proc copyStringRepOfTargetData*(td: TargetDataRef): cstring {.
  importc: "LLVMCopyStringRepOfTargetData", libllvm.}
  ## Converts target data to a target layout string. The string must be disposed
  ## with LLVMDisposeMessage.

proc byteOrder*(td: TargetDataRef): ByteOrdering {.importc: "LLVMByteOrder",
                                                  libllvm.}
  ## Returns the byte order of a target, either LLVMBigEndian or LLVMLittleEndian.

proc pointerSize*(td: TargetDataRef): cuint {.importc: "LLVMPointerSize",
                                             libllvm.}
  ## Returns the pointer size in bytes for a target.

proc pointerSizeForAS*(td: TargetDataRef, addressSpace: cuint): cuint {.
  importc: "LLVMPointerSizeForAS", libllvm.}
  ## Returns the pointer size in bytes for a target for a specified
  ## address space.

proc intPtrType*(td: TargetDataRef): TypeRef {.importc: "LLVMIntPtrType",
                                              libllvm.}
  ## Returns the integer type that is the same size as a pointer on a target.

proc intPtrTypeForAS*(td: TargetDataRef, addressSpace: cuint): TypeRef {.
  importc: "LLVMIntPtrTypeForAS", libllvm.}
  ## Returns the integer type that is the same size as a pointer on a target.
  ## This version allows the address space to be specified.

proc intPtrTypeInContext*(c: ContextRef, td: TargetDataRef): TypeRef {.
  importc: "LLVMIntPtrTypeInContext", libllvm.}
  ## Returns the integer type that is the same size as a pointer on a target.

proc intPtrTypeForASInContext*(c: ContextRef, td: TargetDataRef,
                               addressSpace: cuint): TypeRef {.
  importc: "LLVMIntPtrTypeForASInContext", libllvm.}
  ## Returns the integer type that is the same size as a pointer on a target.
  ## This version allows the address space to be specified.

proc SizeOfTypeInBits*(td: TargetDataRef, ty: TypeRef): culonglong {.
  importc: "LLVMSizeOfTypeInBits", libllvm.}
  ## Computes the size of a type in bytes for a target.

proc storeSizeOfType*(td: TargetDataRef, ty: TypeRef): culonglong {.
  importc: "LLVMStoreSizeOfType", libllvm.}
  ## Computes the storage size of a type in bytes for a target.

proc abiSizeOfType*(td: TargetDataRef, ty: TypeRef): culonglong {.
  importc: "LLVMABISizeOfType", libllvm.}
  ## Computes the ABI size of a type in bytes for a target.

proc abiAlignmentOfType*(td: TargetDataRef, ty: TypeRef): cuint {.
  importc: "LLVMABIAlignmentOfType", libllvm.}
  ## Computes the ABI alignment of a type in bytes for a target.

proc callFrameAlignmentOfType*(td: TargetDataRef, ty: TypeRef): cuint {.
  importc: "LLVMCallFrameAlignmentOfType", libllvm.}
  ## Computes the call frame alignment of a type in bytes for a target.

proc preferredAlignmentOfType*(td: TargetDataRef, ty: TypeRef): cuint {.
  importc: "LLVMPreferredAlignmentOfType", libllvm.}
  ## Computes the preferred alignment of a type in bytes for a target.

proc preferredAlignmentOfGlobal*(td: TargetDataRef, globalVar: ValueRef): cuint {.
  importc: "LLVMPreferredAlignmentOfGlobal", libllvm.}
  ## Computes the preferred alignment of a global variable in bytes for a target.

proc elementAtOffset*(td: TargetDataRef, structTy: TypeRef, offset: culonglong):
                      cuint {.importc: "LLVMElementAtOffset", libllvm.}
  ## Computes the structure element that contains the byte offset for a target.

proc offsetOfElement*(td: TargetDataRef, structTy: TypeRef, element: cuint):
                      culonglong {.importc: "LLVMOffsetOfElement", libllvm.}
  ## Computes the byte offset of the indexed struct element for a target.

proc disposeTargetData*(td: TargetDataRef) {.importc: "LLVMDisposeTargetData",
                                            libllvm.}
  ## Deallocates a TargetData.
