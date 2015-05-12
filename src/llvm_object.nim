## This header declares the C interface to libLLVMObject.a, which
## implements object file reading and writing.
##
## Many exotic languages can interoperate with C code but have a harder time
## with C++ due to name mangling. So in addition to C, this interface enables
## tools written in such languages.

import llvm_core

include llvm_lib

# Object file reading and writing

# Opaque type wrappers
type
  ObjectFileRef = ptr object
  SectionIteratorRef = ptr object
  SymbolIteratorRef = ptr object
  RelocationIteratorRef = ptr object

# ObjectFile creation

proc createObjectFile*(memBuf: MemoryBufferRef): ObjectFileRef {.
  importc: "LLVMCreateObjectFile", libllvm.}

proc disposeObjectFile*(objectFile: ObjectFileRef) {.
  importc: "LLVMDisposeObjectFile", libllvm.}

# ObjectFile Section iterators

proc getSections*(objectFile: ObjectFileRef): SectionIteratorRef {.
  importc: "LLVMSectionIteratorRef", libllvm.}

proc disposeSectionIterator*(si: SectionIteratorRef) {.
  importc: "LLVMDisposeSectionIterator", libllvm.}

proc isSectionIteratorAtEnd*(objectFile: ObjectFileRef, si: SectionIteratorRef):
                             Bool {.importc: "LLVMIsSectionIteratorAtEnd",
                                   libllvm.}

proc moveToNextSection*(si: SectionIteratorRef) {.
  importc: "LLVMMoveToNextSection", libllvm.}

proc moveToContainingSection*(sect: SectionIteratorRef, sym: SymbolIteratorRef) {.
  importc: "LLVMMoveToContainingSection", libllvm.}

# ObjectFile Symbol iterators

proc getSymbols*(objectFile: ObjectFileRef): SymbolIteratorRef {.
  importc: "LLVMGetSymbols", libllvm.}

proc disposeSymbolIterator*(si: SymbolIteratorRef) {.
  importc: "LLVMDisposeSymbolIterator", libllvm.}

proc isSymbolIteratorAtEnd*(objectFile: ObjectFileRef, si: SectionIteratorRef):
                            Bool {.importc: "LLVMIsSymbolIteratorAtEnd", libllvm.}

proc moveToNextSymbol*(si: SectionIteratorRef) {.importc: "LLVMMoveToNextSymbol",
                                                libllvm.}

# SectionRef accessors

proc getSectionName*(si: SectionIteratorRef): cstring {.
  importc: "LLVMGetSectionName", libllvm.}

proc getSectionSize*(si: SectionIteratorRef): culonglong {.
  importc: "LLVMGetSectionSize", libllvm.}

proc getSectionContents*(si: SectionIteratorRef): cstring {.
  importc: "LLVMGetSectionContents", libllvm.}

proc getSectionAddress*(si: SectionIteratorRef): culonglong {.
  importc: "LLVMGetSectionAddress", libllvm.}

proc getSectionContainsSymbol*(si: SectionIteratorRef, sym: SymbolIteratorRef):
                               Bool {.importc: "LLVMGetSectionContainsSymbol",
                                     libllvm.}

# Section Relocation iterators

proc getRelocations*(section: SectionIteratorRef): RelocationIteratorRef {.
  importc: "LLVMGetRelocations", libllvm.}

proc disposeRelocationIterator*(ri: RelocationIteratorRef) {.
  importc: "LLVMDisposeRelocationIterator", libllvm.}

proc isRelocationIteratorAtEnd*(section: SectionIteratorRef,
                                ri: RelocationIteratorRef): Bool {.
  importc: "LLVMIsRelocationIteratorAtEnd", libllvm.}

proc moveToNextRelocation*(ri: RelocationIteratorRef) {.
  importc: "LLVMMoveToNextRelocation", libllvm.}

# SymbolRef accessors

proc getSymbolName*(si: SymbolIteratorRef): cstring {.
  importc: "LLVMGetSymbolName", libllvm.}

proc getSymbolAddress*(si: SymbolIteratorRef): culonglong {.
  importc: "LLVMGetSymbolAddress", libllvm.}

proc getSymbolSize*(si: SymbolIteratorRef): culonglong {.
  importc: "LLVMGetSymbolSize", libllvm.}

# RelocationRef accessors

proc getRelocationAddress*(ri: RelocationIteratorRef): culonglong {.
  importc: "LLVMGetRelocationAddress", libllvm.}

proc getRelocationOffset*(ri: RelocationIteratorRef): culonglong {.
  importc: "LLVMGetRelocationOffset", libllvm.}

proc getRelocationSymbol*(ri: RelocationIteratorRef): SymbolIteratorRef {.
  importc: "LLVMGetRelocationSymbol", libllvm.}

proc getRelocationType*(ri: RelocationIteratorRef): culonglong {.
  importc: "LLVMGetRelocationType", libllvm.}

# NOTE: Caller takes ownership of returned string of the two
# following functions.

proc getRelocationTypeName*(ri: RelocationIteratorRef): cstring {.
  importc: "LLVMGetRelocationTypeName", libllvm.}

proc getRelocationValueString*(ri: RelocationIteratorRef): cstring {.
  importc: "LLVMGetRelocationValueString", libllvm.}
