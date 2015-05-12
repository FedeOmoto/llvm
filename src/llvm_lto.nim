## This header provides public interface to an abstract link time optimization
## library. LLVM provides an implementation of this interface for use with
## llvm bitcode files.

const libname = "LTO"

{.passC: gorge("llvm-config --cflags").}

when defined(dynamic_link) or defined(static_link):
  const ldflags = gorge("llvm-config --ldflags")
  {.pragma: liblto, cdecl.}
  when defined(dynamic_link): # Dynamic linking
    {.passL: ldflags & "-l" & libname.}
  else: # Static linking
    const libdir = gorge("llvm-config --libdir")
    {.passL: gorge("llvm-config --system-libs") & "-lstdc++ " & ldflags &
     libdir & "/lib" & libname & ".a " & gorge("llvm-config --libs").}
else: # Dynamic loading
  when defined(windows):
    const dllname =  libname & ".dll"
  elif defined(macosx):
    const dllname = "lib" & libname & ".dylib"
  else:
    const dllname = "lib" & libname & ".so"
  {.pragma: liblto, cdecl, dynlib: dllname.}

type Bool* = cuchar

# LTO

var LTO_API_VERSION* {.importc, header: "<llvm-c/lto.h>".}: cint

type
  SymbolAttributes* = enum                      ## Symbol attributes
    SymbolAlignmentMask           = 0x0000001F  ## log2 of alignment
    SymbolPermissionsROData       = 0x00000080
    SymbolPermissionsCode         = 0x000000A0
    SymbolPermissionsData         = 0x000000C0
    SymbolPermissionsMask         = 0x000000E0
    SymbolDefinitionRegular       = 0x00000100
    SymbolDefinitionTentative     = 0x00000200
    SymbolDefinitionWeak          = 0x00000300
    SymbolDefinitionUndefined     = 0x00000400
    SymbolDefinitionWeakUndef     = 0x00000500
    SymbolDefinitionMask          = 0x00000700
    SymbolScopeInternal           = 0x00000800
    SymbolScopeHidden             = 0x00001000
    SymbolScopeDefault            = 0x00001800
    SymbolScopeProtected          = 0x00002000
    SymbolScopeDefaultCanBeHidden = 0x00002800
    SymbolScopeMask               = 0x00003800

  DebugModel* = enum
    DebugModelNone  = 0
    DebugModelDwarf = 1

  CodegenModel* = enum
    CodegenPICModelStatic       = 0
    CodegenPICModelDynamic      = 1
    CodegenPICModelDynamicNoPIC = 2
    CodegenPICModelDefault      = 3

type
  Module* = ptr object
    ## opaque reference to a loaded object module
  CodeGen* = ptr object
    ## opaque reference to a code generator

proc getVersion*: cstring {.importc: "lto_get_version", liblto.}
  ## Returns a printable string.

proc getError*: cstring {.importc: "lto_get_error_message", liblto.}
  ## Returns the last error string or NULL if last operation was successful.

proc moduleIsObjectFile*(path: cstring): Bool {.
  importc: "lto_module_is_object_file", liblto.}
  ## Checks if a file is a loadable object file.

proc moduleIsObjectFileForTarget*(path: cstring, targetTriplePrefix: cstring): Bool {.
  importc: "lto_module_is_object_file_for_target", liblto.}
  ## Checks if a file is a loadable object compiled for requested target.

proc moduleIsObjectFileInMemory*(mem: pointer, length: csize): Bool {.
  importc: "lto_module_is_object_file_in_memory", liblto.}
  ## Checks if a buffer is a loadable object file.

proc moduleIsObjectFileInMemoryForTarget*(mem: pointer, length: csize,
                                          targetTriplePrefix: cstring): Bool {.
  importc: "lto_module_is_object_file_in_memory_for_target", liblto.}
  ## Checks if a buffer is a loadable object compiled for requested target.

proc moduleCreate*(path: cstring): Module {.importc: "lto_module_create", liblto.}
  ## Loads an object file from disk.
  ## Returns NULL on error (check lto_get_error_message() for details).

proc moduleCreateFromMemory*(mem: pointer, length: csize): Module {.
  importc: "lto_module_create_from_memory", liblto.}
  ## Loads an object file from memory.
  ## Returns NULL on error (check lto_get_error_message() for details).

proc moduleCreateFromMemoryWithPath*(mem: pointer, length: csize, path: cstring):
                                     Module {.
  importc: "lto_module_create_from_memory_with_path", liblto.}
  ## Loads an object file from memory with an extra path argument.
  ## Returns NULL on error (check lto_get_error_message() for details).

proc moduleCreateFromFD*(fd: cint, path: cstring, fileSize: csize): Module {.
  importc: "lto_module_create_from_fd", liblto.}
  ## Loads an object file from disk. The seek point of fd is not preserved.
  ## Returns NULL on error (check lto_get_error_message() for details).

proc module_create_from_fd_at_offset*(fd: cint, path: cstring, fileSize: csize,
                                      mapSize: csize, offset: csize): Module {.
  importc: "lto_module_create_from_fd_at_offset", liblto.}
  ## Loads an object file from disk. The seek point of fd is not preserved.
  ## Returns NULL on error (check lto_get_error_message() for details).

proc moduleDispose*(module: Module) {.importc: "lto_module_dispose", liblto.}
  ## Frees all memory internally allocated by the module.
  ## Upon return the lto_module_t is no longer valid.

proc moduleGetTargetTriple*(module: Module): cstring {.
  importc: "lto_module_get_target_triple", liblto.}
  ## Returns triple string which the object module was compiled under.

proc moduleSetTargetTriple*(module: Module, triple: cstring) {.
  importc: "lto_module_set_target_triple", liblto.}
  ## Sets triple string with which the object will be codegened.

proc moduleGetNumSymbols*(module: Module): cuint {.
  importc: "lto_module_get_num_symbols", liblto.}
  ## Returns the number of symbols in the object module.

proc moduleGetSymbolName*(module: Module, index: cuint): cstring {.
  importc: "lto_module_get_symbol_name", liblto.}
  ## Returns the name of the ith symbol in the object module.

proc moduleGetSymbolAttribute*(module: Module, index: cuint): SymbolAttributes {.
  importc: "lto_module_get_symbol_attribute", liblto.}
  ## Returns the attributes of the ith symbol in the object module.

proc moduleGetNumDeplibs*(module: Module): cuint {.
  importc: "lto_module_get_num_deplibs", liblto.}
  ## Returns the number of dependent libraries in the object module.

proc moduleGetDeplib*(module: Module, index: cuint): cstring {.
  importc: "lto_module_get_deplib", liblto.}
  ## Returns the ith dependent library in the module.

proc moduleGetNumLinkeropts*(module: Module): cuint {.
  importc: "lto_module_get_num_linkeropts", liblto.}
  ## Returns the number of linker options in the object module.

proc moduleGetLinkeropt*(module: Module, index: cuint): cstring {.
  importc: "lto_module_get_linkeropt", liblto.}
  ## Returns the ith linker option in the module.

type codegenDiagnosticSeverity* = enum ## Diagnostic severity.
  DSError   = 0
  DSWarning = 1
  DSNote    = 2
  DSRemark  = 3

type
  DiagnosticHandler* = proc (severity: codegenDiagnosticSeverity, diag: cstring,
                             ctxt: pointer) {.cdecl.}
  ## Diagnostic handler type.
  ## severity defines the severity.
  ## diag is the actual diagnostic.
  ## The diagnostic is not prefixed by any of severity keyword, e.g., 'error: '.
  ## ctxt is used to pass the context set with the diagnostic handler.

proc codegenSetDiagnosticHandler*(cg: CodeGen, dh: DiagnosticHandler,
                                  ctxt: pointer) {.
  importc: "lto_codegen_set_diagnostic_handler", liblto.}
  ## Set a diagnostic handler and the related context (void *).
  ## This is more general than lto_get_error_message, as the diagnostic handler
  ## can be called at anytime within lto.

proc codegenCreate*: CodeGen {.importc: "lto_codegen_create", liblto.}
  ## Instantiates a code generator.
  ## Returns NULL on error (check lto_get_error_message() for details).

proc codegenDispose*(cg: CodeGen) {.importc: "lto_codegen_dispose", liblto.}
  ## Frees all code generator and all memory it internally allocated.
  ## Upon return the lto_code_gen_t is no longer valid.

proc codegenAddModule*(cg: CodeGen, module: Module): Bool {.
  importc: "lto_codegen_add_module", liblto.}
  ## Add an object module to the set of modules for which code will be generated.
  ## Returns true on error (check lto_get_error_message() for details).

proc codegenSetDebugModel*(cg: CodeGen, dm: DebugModel): Bool {.
  importc: "lto_codegen_set_debug_model", liblto.}
  ## Sets if debug info should be generated.
  ## Returns true on error (check lto_get_error_message() for details).

proc codegenSetPICModel*(cg: CodeGen, cgm: CodegenModel): Bool {.
  importc: "lto_codegen_set_pic_model", liblto.}
  ## Sets which PIC code model to generated.
  ## Returns true on error (check lto_get_error_message() for details).

proc codegenSetCPU*(cg: CodeGen, cpu: cstring) {.importc: "lto_codegen_set_cpu",
                                                liblto.}
  ## Sets the cpu to generate code for.

proc codegenSetAssemblerPath*(cg: CodeGen, path: cstring) {.
  importc: "lto_codegen_set_assembler_path", liblto.}
  ## Sets the location of the assembler tool to run. If not set, libLTO
  ## will use gcc to invoke the assembler.

proc codegenSetAssemblerArgs*(cg: CodeGen, args: cstringArray, nArgs: cint) {.
  importc: "lto_codegen_set_assembler_args", liblto.}
  ## Sets extra arguments that libLTO should pass to the assembler.

proc codegenAddMustPreserveSymbol*(cg: CodeGen, symbol: cstring) {.
  importc: "lto_codegen_add_must_preserve_symbol", liblto.}
  ## Adds to a list of all global symbols that must exist in the final generated
  ## code. If a function is not listed there, it might be inlined into every usage
  ## and optimized away.

proc codegenWriteMergedModules*(cg: CodeGen, path: cstring): Bool {.
  importc: "lto_codegen_write_merged_modules", liblto.}
  ## Writes a new object file at the specified path that contains the
  ## merged contents of all modules added so far.
  ## Returns true on error (check lto_get_error_message() for details).

proc codegenCompile*(cg: CodeGen, length: ptr csize): pointer {.
  importc: "lto_codegen_compile", liblto.}
  ## Generates code for all added modules into one native object file.
  ## On success returns a pointer to a generated mach-o/ELF buffer and
  ## length set to the buffer size.  The buffer is owned by the
  ## lto_code_gen_t and will be freed when lto_codegen_dispose()
  ## is called, or lto_codegen_compile() is called again.
  ## On failure, returns NULL (check lto_get_error_message() for details).

proc codegenCompileToFile*(cg: CodeGen, name: cstring): Bool {.
  importc: "lto_codegen_compile_to_file", liblto.}
  ## Generates code for all added modules into one native object file.
  ## The name of the file is written to name. Returns true on error.

proc codegenDebugOptions*(cg: CodeGen, opts: cstring) {.
  importc: "lto_codegen_debug_options", liblto.}
  ## Sets options to help debug codegen bugs.

proc initializeDisassembler* {.importc: "lto_initialize_disassembler", liblto.}
  ## Initializes LLVM disassemblers.
