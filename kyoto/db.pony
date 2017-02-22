
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
use @kcdbincrint[I64](db: _DB ref, kbuf: Pointer[U8] tag, ksiz: USize,
  num: I64, orig: I64)
use @kcdbincrdouble[F64](db: _DB ref, kbuf: Pointer[U8] tag, ksiz: USize,
  num: F64, orig: F64)
// TODO: @kcdbcas
use @kcdbremove[I32](db: _DB ref, kbuf: Pointer[U8] tag, ksiz: USize)
use @kcdbget[Pointer[U8] val](db: _DB box, kbuf: Pointer[U8] tag, ksiz: USize,
  sp: Pointer[USize])
use @kcdbcheck[I32](db: _DB box, kbuf: Pointer[U8] tag, ksiz: USize)
// TODO: @kcdbgetbuf
use @kcdbseize[Pointer[U8] val](db: _DB ref, kbuf: Pointer[U8] tag, ksiz: USize,
  sp: Pointer[USize])
// TODO: @kcdbsetbulk
// TODO: @kcdbremovebulk
// TODO: @kcdbgetbulk
// TODO: @kcdbsync
// TODO: @kcdboccupy
// TODO: @kcdbcopy
// TODO: @kcdbbegintran
// TODO: @kcdbbegintrantry
// TODO: @kcdbendtran
use @kcdbclear[I32](db: _DB ref)
// TODO: @kcdbdumpsnap
// TODO: @kcdbloadsnap
use @kcdbcount[I64](db: _DB box)
use @kcdbsize[I64](db: _DB box)
use @kcdbpath[Pointer[U8] val](db: _DB box)
use @kcdbstatus[Pointer[U8] val](db: _DB box)
// TODO: @kcdbmatchprefix
// TODO: @kcdbmatchregex
// TODO: @kcdbmatchsimilar
// TODO: @kcdbmerge


class _DB
  """
  Private class that acts as the underlying C pointer for a DB.
  """

class DB
  """
  An object used for creating and operating on a KyotoCabinet database.
  
  All methods that raise errors will set internal state with details about
  the nature of the error, which can be retrieved using the last_error method.
  """
  let _database: _DB
  fun _db(): this->_DB => _database
  
  new create() =>
    _database = @kcdbnew()
  
  fun _final() =>
    @kcdbdel(_database)
  
  // TODO: Make this method work.
  // fun ref open_proto(kind': DBKind, mode: (OpenReader | OpenWriter))? =>
  //   """
  //   Open a prototyping database in memory, not associated with a file on disk.
  //   Errors in case of failure - check last_error method for details.
  //   """
  //   let res = @kcdbopen(_db(), kind'._proto().cstring(), 0)
  //   if res == 0 then error end
  
  // TODO: Take capability-safe FilePath instead (and check perms).
  // TODO: Take DBKind parameter and figure out how to check against suffix.
  fun ref open(path: String, mode: (OpenReader | OpenWriter))? =>
    """
    Open the database file at the given path, with the given mode.
    """
    let mode_value =
      match mode
      | let mode': OpenReader => mode'.value() + _OpenReader.value()
      | let mode': OpenWriter => mode'.value() + _OpenWriter.value()
      else _Unreachable; mode.value()
      end
    
    let res = @kcdbopen(_db(), path.cstring(), mode_value)
    if res == 0 then error end
  
  fun ref close()? =>
    """
    Open the database file at the given path, with the given mode.
    """
    let res = @kcdbclose(_db())
    if res == 0 then error end
  
  // TODO: combine these into error classes instead, under last_error name.
  fun last_error(): Error => _ErrorUtil.from_i32(@kcdbecode(_db()))
  fun last_error_message(): String =>
    let ptr = @kcdbemsg(_db())
    recover String.copy_cstring(ptr) end
  
  fun apply(key: String): String?              => get(key)
  fun ref update(key: String, value: String)? => set(key, value)
  
  fun ref set(key: String, value: String)? =>
    """
    Create or overwrite the value in the record at the given key.
    """
    let res = @kcdbset(_db(), key.cpointer(), key.size(), value.cpointer(),
      value.size())
    if res == 0 then error end
  
  fun ref set(key: String, value: String)? =>
    """
    Create or overwrite the value in the record at the given key.
    """
    let res = @kcdbset(_db(), key.cpointer(), key.size(), value.cpointer(),
      value.size())
    if res == 0 then error end
  
  fun ref insert_if_absent(key: String, value: String): Bool? =>
    """
    Create a new record with the given value at the given key.
    Returns true if the record was created, or false if it already existed.
    """
    let res = @kcdbadd(_db(), key.cpointer(), key.size(), value.cpointer(),
      value.size())
    if res == 0 then
      if last_error() is ErrorDupRec then false else error end
    else true
    end
  
  fun ref replace_if_present(key: String, value: String): Bool? =>
    """
    Replace the value of record at the given key with the given value.
    Returns false if the record did not exist, or true if it was replaced.
    """
    let res = @kcdbreplace(_db(), key.cpointer(), key.size(), value.cpointer(),
      value.size())
    if res == 0 then
      if last_error() is ErrorNoRec then false else error end
    else true
    end
  
  fun ref append_to(key: String, value: String)? =>
    """
    Append the given value to the value of the record at the given key,
    or create a new record with the given value if none currently exists.
    Errors in case of failure - check last_error method for details.
    """
    let res = @kcdbappend(_db(), key.cpointer(), key.size(), value.cpointer(),
      value.size())
    if res == 0 then error end
  
  fun ref set_i64(key: String, num: I64): I64? =>
    """
    Set the given number as the numeric value of the given record.
    
    The num argument specifies the number to set.
    
    The value is serialized as an 8-byte binary integer in big-endian order,
    and fails if an existing record at that key isn't serialized this way.
    """
    let orig = I64.max_value()
    let res = @kcdbincrint(_db(), key.cpointer(), key.size(), num, orig)
    if res == I64.min_value() then error end
    res
  
  fun ref incr_i64(key: String, num: I64 = 1, orig: I64 = I64.min_value()): I64?
  =>
    """
    Add the given number to the numeric value of the given record.
    
    The optional num argument specifies the number to add.
    The optional orig argument specifies the number to start from if no record
    is found for that key. If `I64.min_value()` is given, the fallback behaviour
    is failure. If `I64.max_value()` is given, the fallback behaviour is the
    same as calling the `set_i64` method.
    
    The value is serialized as an 8-byte binary integer in big-endian order,
    and fails if an existing record at that key isn't serialized this way.
    """
    let res = @kcdbincrint(_db(), key.cpointer(), key.size(), num, orig)
    if res == I64.min_value() then error end
    res
  
  fun ref set_f64(key: String, num: F64): F64? =>
    """
    Set the given number as the numeric value of the given record.
    
    The num argument specifies the number to set.
    
    The value is serialized as a 16-byte binary fixed-point number (big-endian),
    and fails if an existing record at that key isn't serialized this way.
    """
    let res = @kcdbincrdouble(_db(), key.cpointer(), key.size(), num, 1 / 0)
    if res.nan() then error end
    res
  
  fun ref incr_f64(key: String, num: F64 = 1, orig: F64 = -1 / 0): F64? =>
    """
    Add the given number to the numeric value of the given record.
    
    The optional num argument specifies the number to add.
    The optional orig argument specifies the number to start from if no record
    is found for that key. If negative infinity is given, the fallback behaviour
    is failure. If positive infinity is given, the fallback behaviour is the
    same as calling the `set_i64` method.
    
    The value is serialized as a 16-byte binary fixed-point number (big-endian),
    and fails if an existing record at that key isn't serialized this way.
    """
    let res = @kcdbincrdouble(_db(), key.cpointer(), key.size(), num, orig)
    if res.nan() then error end
    res
  
  fun ref remove(key: String)? =>
    """
    Remove the record at the given key.
    Errors if no record exists at that key.
    """
    let res = @kcdbremove(_db(), key.cpointer(), key.size())
    if res == 0 then error end
  
  fun ref remove_if_present(key: String): Bool? =>
    """
    Remove the record at the given key, if it exists.
    Returns true if a record was removed, or false if no such record existed.
    """
    let res = @kcdbremove(_db(), key.cpointer(), key.size())
    if res == 0 then
      if last_error() is ErrorNoRec then false else error end
    else true
    end
  
  fun get(key: String): String? =>
    """
    Return the value of the record at the given key.
    The value will be copied into a new String.
    """
    var vsiz: USize = 0
    let vbuf = @kcdbget(_db(), key.cpointer(), key.size(), addressof vsiz)
    if vbuf.is_null() then error end
    let value = recover String.copy_cstring(vbuf, vsiz) end
    _Lib.free[U8](vbuf)
    value
  
  fun contains(key: String): Bool? =>
    """
    Return true if a record exists at the given key, otherwise false.
    """
    let res = @kcdbcheck(_db(), key.cpointer(), key.size())
    if res < 0 then
      if last_error() is ErrorNoRec then false else error end
    else true
    end
  
  fun size_at(key: String): USize? =>
    """
    Return the byte size of the value at the given key.
    Errors if no record exists at the given key.
    """
    let res = @kcdbcheck(_db(), key.cpointer(), key.size())
    if res < 0 then error end
    res.usize()
  
  fun ref pop(key: String): String? =>
    """
    Return the value of the record at the given key, and atomically remove it.
    The value will be copied into a new String.
    """
    var vsiz: USize = 0
    let vbuf = @kcdbseize(_db(), key.cpointer(), key.size(), addressof vsiz)
    if vbuf.is_null() then error end
    let value = recover String.copy_cstring(vbuf, vsiz) end
    _Lib.free[U8](vbuf)
    value
  
  fun ref clear()? =>
    """
    Remove all records.
    """
    let res = @kcdbclear(_db())
    if res == 0 then error end
  
  fun count(): U64? =>
    """
    Return the number of records.
    """
    let res = @kcdbcount(_db())
    if res < 0 then error end
    res.u64()
  
  fun total_bytes(): U64? =>
    """
    Return the size of the database file, in bytes.
    """
    let res = @kcdbsize(_db())
    if res < 0 then error end
    res.u64()
  
  fun file_path(): String? =>
    """
    Return the path of the database file.
    """
    let res = @kcdbpath(_db())
    let res' = recover String.copy_cstring(res) end
    _Lib.free[U8](res)
    if res'.size() == 0 then error end
    res'
  
  fun status_info(): String? =>
    """
    Return the a set of key/value pairs, as a set of lines where each line
    contains an attribute name and its value separate by a tab character.
    """
    let res = @kcdbstatus(_db())
    let res' = recover String.copy_cstring(res) end
    _Lib.free[U8](res)
    if res'.size() == 0 then error end
    res'
