
use @kcdbnew[_DB ref]()
use @kcdbdel[None](db: _DB tag)
use @kcdbopen[I32](db: _DB ref, path: Pointer[U8] tag, mode: U32)
use @kcdbclose[I32](db: _DB ref)
use @kcdbecode[I32](db: _DB box)
use @kcdbemsg[Pointer[U8] val](db: _DB box)
// TODO: @kcdbaccept
// TODO: @kcdbacceptbulk
// TODO: @kcdbiterate
// TODO: @kcdbscanpara
use @kcdbset[I32](db: _DB ref, kbuf: Pointer[U8] tag, ksiz: USize,
  vbuf: Pointer[U8] tag, vsiz: USize)
use @kcdbadd[I32](db: _DB ref, kbuf: Pointer[U8] tag, ksiz: USize,
  vbuf: Pointer[U8] tag, vsiz: USize)
use @kcdbreplace[I32](db: _DB ref, kbuf: Pointer[U8] tag, ksiz: USize,
  vbuf: Pointer[U8] tag, vsiz: USize)
use @kcdbappend[I32](db: _DB ref, kbuf: Pointer[U8] tag, ksiz: USize,
  vbuf: Pointer[U8] tag, vsiz: USize)
use @kcdbget[Pointer[U8] val](db: _DB box, kbuf: Pointer[U8] tag, ksiz: USize,
  sp: Pointer[USize])

class _DB
  """
  Private class that acts as the underlying C pointer for a DB.
  """

class DB
  let _db: _DB
  
  new create() =>
    _db = @kcdbnew()
  
  fun _final() =>
    @kcdbdel(_db)
  
  // TODO: Make this method work.
  // fun ref open_proto(kind': DBKind, mode': (OpenReader | OpenWriter))? =>
  //   """
  //   Open a prototyping database in memory, not associated with a file on disk.
  //   Errors in case of failure - check last_error method for details.
  //   """
  //   let res = @kcdbopen(_db, kind'._proto().cstring(), 0)
  //   if res == 0 then error end
  
  // TODO: Take capability-safe FilePath instead (and check perms).
  // TODO: Take DBKind parameter and figure out how to check against suffix.
  fun ref open(path': String, mode': (OpenReader | OpenWriter))? =>
    """
    Open the database file at the given path, with the given mode.
    Errors in case of failure - check last_error method for details.
    """
    let mode_value =
      match mode'
      | let m: OpenReader => m.value() + _OpenReader.value()
      | let m: OpenWriter => m.value() + _OpenWriter.value()
      else _Unreachable; mode'.value()
      end
    
    let res = @kcdbopen(_db, path'.cstring(), mode_value)
    if res == 0 then error end
  
  fun ref close()? =>
    """
    Open the database file at the given path, with the given mode.
    Errors in case of failure - check last_error method for details.
    """
    let res = @kcdbclose(_db)
    if res == 0 then error end
  
  // TODO: combine these into error classes instead, under last_error name.
  fun last_error(): Error => _ErrorUtil.from_i32(@kcdbecode(_db))
  fun last_error_message(): String =>
    let ptr = @kcdbemsg(_db)
    recover String.copy_cstring(ptr) end
  
  fun apply(key': String): String?              => get(key')
  fun ref update(key': String, value': String)? => set(key', value')
  
  fun ref set(key': String, value': String)? =>
    """
    Create or overwrite the value in the record at the given key.
    Errors in case of failure - check last_error method for details.
    """
    let res = @kcdbset(_db, key'.cpointer(), key'.size(), value'.cpointer(),
      value'.size())
    if res == 0 then error end
  
  fun ref set(key': String, value': String)? =>
    """
    Create or overwrite the value in the record at the given key.
    Errors in case of failure - check last_error method for details.
    """
    let res = @kcdbset(_db, key'.cpointer(), key'.size(), value'.cpointer(),
      value'.size())
    if res == 0 then error end
  
  fun ref insert_if_absent(key': String, value': String): Bool? =>
    """
    Create a new record with the given value at the given key.
    Returns true if the record was created, or false if it already existed.
    Errors in case of failure - check last_error method for details.
    """
    let res = @kcdbadd(_db, key'.cpointer(), key'.size(), value'.cpointer(),
      value'.size())
    if res == 0 then
      if last_error() is ErrorDupRec then false else error end
    else true
    end
  
  fun ref replace_if_present(key': String, value': String): Bool? =>
    """
    Replace the value of record at the given key with the given value.
    Returns false if the record did not exist, or true if it was replaced.
    Errors in case of failure - check last_error method for details.
    """
    let res = @kcdbreplace(_db, key'.cpointer(), key'.size(), value'.cpointer(),
      value'.size())
    if res == 0 then
      if last_error() is ErrorNoRec then false else error end
    else true
    end
  
  fun ref replace_if_present(key': String, value': String): Bool? =>
    """
    Replace the value of record at the given key with the given value.
    Returns false if the record did not exist, or true if it was replaced.
    Errors in case of failure - check last_error method for details.
    """
    let res = @kcdbreplace(_db, key'.cpointer(), key'.size(), value'.cpointer(),
      value'.size())
    if res == 0 then
      if last_error() is ErrorNoRec then false else error end
    else true
    end
  
  fun ref append_to(key': String, value': String)? =>
    """
    Append the given value to the value of the record at the given key,
    or create a new record with the given value if none currently exists.
    Errors in case of failure - check last_error method for details.
    """
    let res = @kcdbappend(_db, key'.cpointer(), key'.size(), value'.cpointer(),
      value'.size())
    if res == 0 then error end
  
  fun get(key': String): String? =>
    """
    Return the value of the record at the given key.
    The value will be copied into a new String.
    Errors in case of failure - check last_error method for details.
    """
    var vsiz: USize = 0
    let vbuf = @kcdbget(_db, key'.cpointer(), key'.size(), addressof vsiz)
    if vbuf.is_null() then error end
    let value = recover String.copy_cstring(vbuf, vsiz) end
    _Lib.free[U8](vbuf)
    value
