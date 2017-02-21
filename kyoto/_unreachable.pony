
// use @pony_os_stderr[Pointer[None]]()
// use @fprintf[I32](Pointer[None], Pointer[U8], ...)
// use @exit[None](I32)

class _Unreachable
  // new create(value: (Stringable | None) = None, loc: SourceLoc = __loc) =>
  //   @fprintf(@pony_os_stderr(),
  //     "ABORT: Unreachable condition at %s:%zu (in %s method)\n".cstring(),
  //     loc.file().cstring(), loc.line(), loc.method().cstring())
    
  //   if value isnt None then
  //     @fprintf(@pony_os_stderr(), "%s\n".cstring(),
  //       value.string().cstring())
  //   end
    
  //   @exit(1)
