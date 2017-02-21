
use collections = "collections"

type OpenReader is collections.Flags[
  ( OpenNoLock
  | OpenTryLock
  | OpenNoRepair
  ), U32]

type OpenWriter is collections.Flags[
  ( OpenCreate
  | OpenTruncate
  | OpenAutoTran
  | OpenAutoSync
  | OpenNoLock
  | OpenTryLock
  | OpenNoRepair
  ), U32]

primitive _OpenReader fun value(): U32 => 1 << 0
primitive _OpenWriter fun value(): U32 => 1 << 1

primitive OpenCreate
  """
  Create a new database if the file does not already exist.
  """
  fun value(): U32 => 1 << 2

primitive OpenTruncate
  """
  Truncate the database if the file already exists.
  """
  fun value(): U32 => 1 << 3

primitive OpenAutoTran
  """
  Each updating operation is performed in an implicit transaction.
  """
  fun value(): U32 => 1 << 4

primitive OpenAutoSync
  """
  Each updating operation is followed by implicit file system synchronization.
  """
  fun value(): U32 => 1 << 5

primitive OpenNoLock
  """
  Open the database file without locking.
  """
  fun value(): U32 => 1 << 6

primitive OpenTryLock
  """
  Open the database file with locking, but without blocking.
  """
  fun value(): U32 => 1 << 7

primitive OpenNoRepair
  """
  Open the database without repairing, even if file destruction is detected.
  """
  fun value(): U32 => 1 << 8
