import 
  llvm_analysis, llvm_core, llvm_support,
  llvm_bitreader, llvm_disassembler, llvm_targetmachine,
  llvm_bitwriter, llvm_executionengine, llvm_target,
  strutils, os

const
  ReleaseMode = gorge("llvm-config --build-mode") == "Release"
  Targets = gorge("llvm-config --targets-built").split(' ')

proc main =

  for T in Targets:
    echo "Target available: ", T

  linkInJIT()
  discard initializeNativeTarget()
  
  let module = moduleCreateWithName("fac_module")

  var fac_args = [int32Type()]
  var fac = addFunction(module, "fac", functionType(
    int32Type(), fac_args[0].addr, 1, 0))
  setFunctionCallConv(fac, CCallConv.cuint)
  var n = getParam(fac,0)

  var
    entry = appendBasicBlock(fac,"entry")
    iftrue = appendBasicBlock(fac,"iftrue")
    iffalse = appendBasicBlock(fac,"iffalse")
    endx = appendBasicBlock(fac,"end")
    builder = createBuilder()

  positionBuilderAtEnd(builder,entry)
  var ifcmp = buildICmp(builder, IntEQ, n,
    constInt(int32Type(), 0,0), "n == 0")
  discard buildCondBr(builder,ifcmp,iftrue,iffalse)

  positionBuilderAtEnd(builder,iftrue)
  let res_iftrue = constInt(int32Type(),1,0)
  discard buildBr(builder,endx)

  positionBuilderAtEnd(builder,iffalse)
  var
    n_minus = buildSub(builder,n, constInt(int32Type(),1,0), "n - 1")
    call_fac_args = [n_minus]
    call_fac = buildCall(builder,fac,call_fac_args[0].addr,1,"fac(n - 1)")
    res_iffalse = buildMul(builder,n,call_fac, "n * fac(n - 1)")
  discard buildBR(builder,endx)

  positionBuilderAtEnd(builder,endx)
  var
    res = buildPhi(builder, int32Type(), "result")
    phi_vals = [res_iftrue, res_iffalse]
    phi_blocks = [iftrue, iffalse]
  addIncoming(res, phi_vals[0].addr, phi_blocks[0].addr, 2)
  discard buildRet(builder,res)

  var error: cstring
  let error_p = cast[cstringarray](addr error)

  echo verifyModule(module, AbortProcessAction, error_p)
  if not error.isNil:
    echo error
  disposeMessage(error)
  error = nil

  var engine: ExecutionEngineRef
  let
    provider = createModuleProviderForExistingModule(module)
  if createJITCompiler(engine.addr, provider, 2, error_p) != 0:
    echo error[0]
    disposeMessage(error)
    quit 1

  let
    pass = createPassManager()
  addTargetData(getExecutionEngineTargetData(engine), pass)
  # TODO
  # addConstantPropagationPass(pass)
  # addInstructionCombiningPass(pass)
  # addPromoteMemoryToRegisterPass(pass)
  # addGVNPass(pass)
  # addCFGSimplificationPass(pass)
  echo runPassManager(pass, module)
  dumpModule(module)

  var N = 5
  if paramCount() > 0:
    try:
      N = parseInt(paramStr(1))
    except:
      discard

  var
    exec_args = [createGenericValueOfInt(int32Type(), N.culonglong, 0)]
    exec_res = runFunction(engine,fac,1, exec_args[0].addr)
  echo "Result: factorial(",N,") = ", genericValueToInt(exec_res, 0)

  disposePassManager(pass)
  disposeBuilder(builder)
  disposeExecutionEngine(engine)

main()
