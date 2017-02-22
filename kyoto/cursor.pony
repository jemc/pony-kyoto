
// use @kcdbcursor[_Cur ref](db: _DB tag)
// use @kccurdel[None](cur: _Cur tag)
// // TODO: @kccuraccept
// use @kccursetvalue[I32](cur: _Cur ref, vbuf: Pointer[U8] tag, vsiz: USize,
//   step: I32)
// use @kccurremove[I32](cur: _Cur ref)
// use @kccurgetkey[Pointer[U8] val](cur: _Cur ref, sp: Pointer[USize], step: I32)
// use @kccurgetvalue[Pointer[U8] val](cur: _Cur ref, sp: Pointer[USize],
//   step: I32)


// class _Cur
//   """
//   Private class that acts as the underlying C pointer for Cursor and ReadCursor.
//   """

// class ReadCursor is _ReadCursorMethods
//   let _cursor: _Cur
//   fun ref _cur(): _Cur => _cursor
//   new create(db: DB box) => _cursor = @kcdbcursor(db._db())
//   fun _final() => @kccurdel(_cursor)

// class Cursor is (_ReadCursorMethods & _WriteCursorMethods)
//   let _cursor: _Cur
//   fun ref _cur(): _Cur => _cursor
//   new create(db: DB ref) => _cursor = @kcdbcursor(db._db())
//   fun _final() => @kccurdel(_cursor)


// trait _ReadCursorMethods
//   fun ref _cur(): _Cur
  
//   fun ref get_key(step: Bool = false): String? =>
//     """
//     Get the key of the current record under the cursor.
//     The value will be copied into a new String.
//     """
//     var ksiz: USize = 0
//     let kbuf = @kccurgetkey(_cur(), addressof ksiz, if step then 1 else 0 end)
//     if kbuf.is_null() then error end
//     let key = recover String.copy_cstring(kbuf, ksiz) end
//     _Lib.free[U8](kbuf)
//     key
  
//   fun ref get_value(step: Bool = false): String? =>
//     """
//     Get the key of the current record under the cursor.
//     The value will be copied into a new String.
//     """
//     var vsiz: USize = 0
//     let vbuf = @kccurgetvalue(_cur(), addressof vsiz, if step then 1 else 0 end)
//     if vbuf.is_null() then error end
//     let value = recover String.copy_cstring(vbuf, vsiz) end
//     _Lib.free[U8](vbuf)
//     value

// trait _WriteCursorMethods
//   fun ref _cur(): _Cur
  
//   fun ref set_value(value: String, step: Bool = false)? =>
//     """
//     Set the value of the current record under the cursor.
    
//     If the optional step argument is set to true, the cursor will be moved to
//     the next record after setting the value of the current record.
//     """
//     let res = @kccursetvalue[I32](_cur(), value.cpointer(), value.size(),
//       if step then 1 else 0 end)
//     if res == 0 then error end
  
//   fun ref remove()? =>
//     """
//     Remove the current record under the cursor.
//     The cursor is moved to the next record implicitly.
//     """
//     let res = @kccurremove[I32](_cur())
//     if res == 0 then error end
