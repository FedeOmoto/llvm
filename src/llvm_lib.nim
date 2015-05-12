when not defined(static_link):
  const libname = "LLVM-3.5"

{.passC: gorge("llvm-config --cflags").}

when defined(dynamic_link) or defined(static_link):
  const ldflags = gorge("llvm-config --ldflags")
  {.pragma: libllvm, cdecl.}
  when defined(dynamic_link): # Dynamic linking
    {.passL: ldflags & "-l" & libname.}
  else: # Static linking
    {.passL: gorge("llvm-config --system-libs") & "-lstdc++ " & ldflags &
     gorge("llvm-config --libs").}
else: # Dynamic loading
  when defined(windows): 
    const dllname = libname & ".dll"
  elif defined(macosx):
    const dllname = "lib" & libname & "(|.0).dylib"
  else: 
    const dllname = "lib" & libname & "(|.0).so"
  {.pragma: libllvm, cdecl, dynlib: dllname.}
