import
  llvm_core, llvm_analysis, llvm_executionengine, llvm_target, os, strutils

proc factorial =
  linkInMCJIT()
  discard initializeNativeTarget()
  discard initializeNativeAsmPrinter()
  
  let module = moduleCreateWithName("fac_module")

  var facArgs = [int32Type()]
  var facType = functionType(int32Type(), facArgs[0].addr, 1, 0)
  var fac = module.addFunction("fac", facType)
  fac.setFunctionCallConv(CCallConv)
  var n = fac.getParam(0)

  var
    entry = fac.appendBasicBlock("entry")
    ifTrue = fac.appendBasicBlock("iftrue")
    ifFalse = fac.appendBasicBlock("iffalse")
    endBB = fac.appendBasicBlock("end")
    builder = createBuilder()

  builder.positionBuilderAtEnd(entry)
  var ifCmp = builder.buildICmp(IntEQ, n, constInt(int32Type(), 0, 0), "n == 0")
  discard builder.buildCondBr(ifCmp, ifTrue, ifFalse)

  builder.positionBuilderAtEnd(ifTrue)
  let resIfTrue = constInt(int32Type(), 1, 0)
  discard builder.buildBr(endBB)

  builder.positionBuilderAtEnd(ifFalse)
  var
    nMinus = builder.buildSub(n, constInt(int32Type(), 1, 0), "n - 1")
    callFacArgs = [nMinus]
    callFac = builder.buildCall(fac, callFacArgs[0].addr, 1, "fac(n - 1)")
    resIfFalse = builder.buildMul(n, callFac, "n * fac(n - 1)")
  discard builder.buildBr(endBB)

  builder.positionBuilderAtEnd(endBB)
  var
    res = builder.buildPhi(int32Type(), "result")
    phiVals = [resIfTrue, resIfFalse]
    phiBlocks = [ifTrue, ifFalse]
  res.addIncoming(phiVals[0].addr, phiBlocks[0].addr, 2)
  discard builder.buildRet(res)

  var error: cstring
  let errorP = cast[cstringArray](error.addr)

  discard verifyModule(module, AbortProcessAction, errorP)
  disposeMessage(error)

  var opts: MCJITCompilerOptions
  initializeMCJITCompilerOptions(opts.addr, sizeOf(opts))
  opts.optLevel = 2

  var engine: ExecutionEngineRef
  error = nil
  if createMCJITCompilerForModule(engine.addr, module, opts.addr, sizeOf(opts),
                                  errorP) != 0:
    stderr.write($error & "\n")
    disposeMessage(error)
    quit 1

  let pass = createPassManager()
  addTargetData(engine.getExecutionEngineTargetData(), pass)
  # TODO
  # pass.addConstantPropagationPass()
  # pass.addInstructionCombiningPass()
  # pass.addPromoteMemoryToRegisterPass()
  # pass.addGVNPass()
  # pass.addCFGSimplificationPass()
  discard pass.runPassManager(module)

  dumpModule(module)

  var num = 10
  if paramCount() > 0:
    try:
      num = parseInt(paramStr(1))
    except:
      discard

  var
    execArgs = [createGenericValueOfInt(int32Type(), num.culonglong, 0)]
    execRes = engine.runFunction(fac, 1, execArgs[0].addr)

  echo "\nRunning factorial(" & $num & ") with JIT..."
  echo "Result: " & $execRes.genericValueToInt(0)

  pass.disposePassManager()
  engine.disposeExecutionEngine()
  builder.disposeBuilder()

factorial()
