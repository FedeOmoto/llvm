import
  llvm_core, llvm_analysis, llvm_executionengine, llvm_targetmachine,
  llvm_target, transforms/llvm_scalar

# TODO: Delete this line and uncomment the addGlobalMapping call in future
# versions of LLVM.
# See: https://llvm.org/bugs/show_bug.cgi?id=20656
{.passL: "-rdynamic".}

proc greet {.exportc.} = echo "\nHello World!"

proc callNimProc =
  linkInMCJIT()
  discard initializeNativeTarget()
  discard initializeNativeAsmPrinter()

  let module = moduleCreateWithName("nimCallModule")

  let greetType = functionType(voidType(), nil, 0, 0)
  let greetProc = module.addFunction("greet", greetType)
  greetProc.setFunctionCallConv(FastCallConv)

  let nimCallType = functionType(voidType(), nil, 0, 0)
  let nimCall = module.addFunction("nimCall", nimCallType)
  nimCall.setFunctionCallConv(CCallConv)

  let
    entry = nimCall.appendBasicBlock("")
    builder = createBuilder()

  builder.positionBuilderAtEnd(entry)
  discard builder.buildCall(greetProc, nil, 0, "")
  discard builder.buildRetVoid

  var error: cstring
  let errorP = cast[cstringArray](error.addr)

  discard verifyModule(module, AbortProcessAction, errorP)
  disposeMessage(error)

  var opts: MCJITCompilerOptions
  initializeMCJITCompilerOptions(opts.addr, sizeOf(opts))
  opts.optLevel = 2
  opts.enableFastISel = 1
  opts.noFramePointerElim = 1
  opts.codeModel = CodeModelJITDefault

  var engine: ExecutionEngineRef
  error = nil
  if createMCJITCompilerForModule(engine.addr, module, opts.addr, sizeOf(opts),
                                  errorP) != 0:
    stderr.write($error & "\n")
    disposeMessage(error)
    quit 1

  #engine.addGlobalMapping(greetProc, greet)

  let pass = createPassManager()
  addTargetData(engine.getExecutionEngineTargetData(), pass)
  pass.addConstantPropagationPass()
  pass.addInstructionCombiningPass()
  pass.addPromoteMemoryToRegisterPass()
  pass.addGVNPass()
  pass.addCFGSimplificationPass()
  discard pass.runPassManager(module)

  module.dumpModule()

  # Slower
  #discard engine.runFunction(nimCall, 0, nil)

  # Faster
  let nimCallProc: proc () {.cdecl.} = cast[proc () {.cdecl.}](engine.getPointerToGlobal(nimCall))
  nimCallProc()

  pass.disposePassManager()
  engine.disposeExecutionEngine()
  builder.disposeBuilder()

callNimProc()
