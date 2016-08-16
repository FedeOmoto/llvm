when not defined(static_link):
  const libname = "LLVM-3.5"

{.passC: gorge("llvm-config-3.5 --cflags").}

when defined(dynamic_link) or defined(static_link):
  const ldflags = gorge("llvm-config-3.5 --ldflags")
  {.pragma: libllvm, cdecl.}
  when defined(dynamic_link): # Dynamic linking
    {.passL: ldflags & "-l" & libname.}
  else: # Static linking
    {.passL: gorge("llvm-config-3.5 --system-libs") & "-lstdc++ " & ldflags &
     gorge("llvm-config-3.5 --libs").}
else: # Dynamic loading
  when defined(windows): 
    const dllname = libname & ".dll"
  elif defined(macosx):
    const dllname = "lib" & libname & "(|.2).(0|1).dylib"
  else: 
    const dllname = "lib" & libname & "(|.2).so.(0|1)"
  {.pragma: libllvm, cdecl, dynlib: dllname.}
