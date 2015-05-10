## This header provides a public interface to a disassembler library.
## LLVM provides an implementation of this interface.

include llvm_lib

# Disassembler

type DisasmContextRef* = pointer
  ## An opaque reference to a disassembler context.

type OpInfoCallback* = proc (disInfo: pointer, pc: culonglong,
                             offset: culonglong, size: culonglong,
                             tagType: cint, tagBuf: pointer): cint {.cdecl.}
  ## The type for the operand information call back function.  This is called to
  ## get the symbolic information for an operand of an instruction.  Typically
  ## this is from the relocation information, symbol table, etc.  That block of
  ## information is saved when the disassembler context is created and passed to
  ## the call back in the DisInfo parameter.  The instruction containing operand
  ## is at the PC parameter.  For some instruction sets, there can be more than
  ## one operand with symbolic information.  To determine the symbolic operand
  ## information for each operand, the bytes for the specific operand in the
  ## instruction are specified by the Offset parameter and its byte widith is the
  ## size parameter.  For instructions sets with fixed widths and one symbolic
  ## operand per instruction, the Offset parameter will be zero and Size parameter
  ## will be the instruction width.  The information is returned in TagBuf and is
  ## Triple specific with its specific information defined by the value of
  ## TagType for that Triple.  If symbolic information is returned the function
  ## returns 1, otherwise it returns 0.

type OpInfoSymbol1* = object
  ## The initial support in LLVM MC for the most general form of a relocatable
  ## expression is "AddSymbol - SubtractSymbol + Offset".  For some Darwin targets
  ## this full form is encoded in the relocation information so that AddSymbol and
  ## SubtractSymbol can be link edited independent of each other.  Many other
  ## platforms only allow a relocatable expression of the form AddSymbol + Offset
  ## to be encoded.
  ##
  ## The LLVMOpInfoCallback() for the TagType value of 1 uses the struct
  ## LLVMOpInfo1.  The value of the relocatable expression for the operand,
  ## including any PC adjustment, is passed in to the call back in the Value
  ## field.  The symbolic information about the operand is returned using all
  ## the fields of the structure with the Offset of the relocatable expression
  ## returned in the Value field.  It is possible that some symbols in the
  ## relocatable expression were assembly temporary symbols, for example
  ## "Ldata - LpicBase + constant", and only the Values of the symbols without
  ## symbol names are present in the relocation information.  The VariantKind
  ## type is one of the Target specific #defines below and is used to print
  ## operands like "_foo@GOT", ":lower16:_foo", etc.
  present*: culonglong  ## 1 if this symbol is present
  name*: cstring        ## symbol name if not NULL
  value*: culonglong    ## symbol value if name is NULL

type OpInfo1* = object
  addSymbol*: OpInfoSymbol1
  subtractSymbol*: OpInfoSymbol1
  value*: culonglong
  variantKind*: culonglong

var
  LLVMDisassembler_VariantKind_None* {.importc, header: "<llvm-c/Disassembler.h>".}: cint # all targets
    ## The operand VariantKinds for symbolic disassembly.

  LLVMDisassembler_VariantKind_ARM_HI16* {.importc, header: "<llvm-c/Disassembler.h>".}: cint # :upper16:
    ## The ARM target VariantKinds.

  LLVMDisassembler_VariantKind_ARM_LO16* {.importc, header: "<llvm-c/Disassembler.h>".}: cint # :lower16:
    ## The ARM target VariantKinds.

  LLVMDisassembler_VariantKind_ARM64_PAGE* {.importc, header: "<llvm-c/Disassembler.h>".}: cint # @page
    ## The ARM64 target VariantKinds.

  LLVMDisassembler_VariantKind_ARM64_PAGEOFF* {.importc, header: "<llvm-c/Disassembler.h>".}: cint # @pageoff
    ## The ARM64 target VariantKinds.

  LLVMDisassembler_VariantKind_ARM64_GOTPAGE* {.importc, header: "<llvm-c/Disassembler.h>".}: cint # @gotpage
    ## The ARM64 target VariantKinds.

  LLVMDisassembler_VariantKind_ARM64_GOTPAGEOFF* {.importc, header: "<llvm-c/Disassembler.h>".}: cint # @gotpageoff
    ## The ARM64 target VariantKinds.

  LLVMDisassembler_VariantKind_ARM64_TLVP* {.importc, header: "<llvm-c/Disassembler.h>".}: cint # @tvlppage
    ## The ARM64 target VariantKinds.

  LLVMDisassembler_VariantKind_ARM64_TLVOFF* {.importc, header: "<llvm-c/Disassembler.h>".}: cint # @tvlppageoff
    ## The ARM64 target VariantKinds.

type SymbolLookupCallback* = proc (disInfo: pointer, referenceValue: culonglong,
                             referenceType: ptr culonglong,
                             referencePC: culonglong,
                             referenceName: cstringArray): cstring {.cdecl.}
  ## The type for the symbol lookup function.  This may be called by the
  ## disassembler for things like adding a comment for a PC plus a constant
  ## offset load instruction to use a symbol name instead of a load address value.
  ## It is passed the block information is saved when the disassembler context is
  ## created and the ReferenceValue to look up as a symbol.  If no symbol is found
  ## for the ReferenceValue NULL is returned.  The ReferenceType of the
  ## instruction is passed indirectly as is the PC of the instruction in
  ## ReferencePC.  If the output reference can be determined its type is returned
  ## indirectly in ReferenceType along with ReferenceName if any, or that is set
  ## to NULL.

# The reference types on input and output.

var
  LLVMDisassembler_ReferenceType_InOut_None* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## No input reference type or no output reference type.

  LLVMDisassembler_ReferenceType_In_Branch* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## The input reference is from a branch instruction.

  LLVMDisassembler_ReferenceType_In_PCrel_Load* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## The input reference is from a PC relative load instruction.

  LLVMDisassembler_ReferenceType_In_ARM64_ADRP* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## The input reference is from an ARM64::ADRP instruction.

  LLVMDisassembler_ReferenceType_In_ARM64_ADDXri* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## The input reference is from an ARM64::ADDXri instruction.

  LLVMDisassembler_ReferenceType_In_ARM64_LDRXui* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## The input reference is from an ARM64::LDRXui instruction.

  LLVMDisassembler_ReferenceType_In_ARM64_LDRXl* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## The input reference is from an ARM64::LDRXl instruction.

  LLVMDisassembler_ReferenceType_In_ARM64_ADR* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## The input reference is from an ARM64::ADR instruction.

  LLVMDisassembler_ReferenceType_Out_SymbolStub* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## The output reference is to as symbol stub.

  LLVMDisassembler_ReferenceType_Out_LitPool_SymAddr* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## The output reference is to a symbol address in a literal pool.

  LLVMDisassembler_ReferenceType_Out_LitPool_CstrAddr* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## The output reference is to a cstring address in a literal pool.

  LLVMDisassembler_ReferenceType_Out_Objc_CFString_Ref* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## The output reference is to a Objective-C CoreFoundation string.

  LLVMDisassembler_ReferenceType_Out_Objc_Message* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## The output reference is to a Objective-C message.

  LLVMDisassembler_ReferenceType_Out_Objc_Message_Ref* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## The output reference is to a Objective-C message ref.

  LLVMDisassembler_ReferenceType_Out_Objc_Selector_Ref* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## The output reference is to a Objective-C selector ref.

  LLVMDisassembler_ReferenceType_Out_Objc_Class_Ref* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## The output reference is to a Objective-C class ref.

  LLVMDisassembler_ReferenceType_DeMangled_Name* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## The output reference is to a C++ symbol name.

proc createDisasm*(tripleName: cstring, disInfo: pointer, tagType: cint,
                   getOpInfo: OpInfoCallback, symbolLookUp: SymbolLookupCallback):
                   DisasmContextRef {.importc: "LLVMCreateDisasm", libllvm.}
  ## Create a disassembler for the TripleName.  Symbolic disassembly is supported
  ## by passing a block of information in the DisInfo parameter and specifying the
  ## TagType and callback functions as described above.  These can all be passed
  ## as NULL.  If successful, this returns a disassembler context.  If not, it
  ## returns NULL. This function is equivalent to calling LLVMCreateDisasmCPU()
  ## with an empty CPU name.

proc createDisasmCPU*(triple: cstring, cpu: cstring, disInfo: pointer,
                      tagType: cint, getOpInfo: OpInfoCallback,
                      symbolLookUp: SymbolLookupCallback): DisasmContextRef {.
  importc: "LLVMCreateDisasmCPU", libllvm.}
  ## Create a disassembler for the TripleName and a specific CPU.  Symbolic
  ## disassembly is supported by passing a block of information in the DisInfo
  ## parameter and specifying the TagType and callback functions as described
  ## above.  These can all be passed * as NULL.  If successful, this returns a
  ## disassembler context.  If not, it returns NULL.

proc setDisasmOptions*(dc: DisasmContextRef, options: culonglong): cint {.
  importc: "LLVMSetDisasmOptions", libllvm.}
  ## Set the disassembler's options.  Returns 1 if it can set the Options and 0
  ## otherwise.

var
  LLVMDisassembler_Option_UseMarkup* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## The option to produce marked up assembly.

  LLVMDisassembler_Option_PrintImmHex* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## The option to print immediates as hex.

  LLVMDisassembler_Option_AsmPrinterVariant* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## The option use the other assembler printer variant

  LLVMDisassembler_Option_SetInstrComments* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## The option to set comment on instructions

  LLVMDisassembler_Option_PrintLatency* {.importc, header: "<llvm-c/Disassembler.h>".}: cint
    ## The option to print latency information alongside instructions

proc disasmDispose*(dc: DisasmContextRef) {.importc: "LLVMDisasmDispose", libllvm.}
  ## Dispose of a disassembler context.

proc disasmInstruction*(dc: DisasmContextRef, bytes: ptr cuchar,
                        bytesSize: culonglong, pc: culonglong,
                        outString: cstring, outStringSize: csize): csize {.
  importc: "LLVMDisasmInstruction", libllvm.}
  ## Disassemble a single instruction using the disassembler context specified in
  ## the parameter DC.  The bytes of the instruction are specified in the
  ## parameter Bytes, and contains at least BytesSize number of bytes.  The
  ## instruction is at the address specified by the PC parameter.  If a valid
  ## instruction can be disassembled, its string is returned indirectly in
  ## OutString whose size is specified in the parameter OutStringSize.  This
  ## function returns the number of bytes in the instruction or zero if there was
  ## no valid instruction.
