
type DBKind is
  ( DBKindHash
  | DBKindTree
  | DBKindCacheHash
  | DBKindCacheTree
  | DBKindStash
  )

primitive DBKindHash      fun _proto(): String => "-" fun _suffix(): String => "kch"
primitive DBKindTree      fun _proto(): String => "+" fun _suffix(): String => "kct"
primitive DBKindCacheHash fun _proto(): String => "*" fun _suffix(): String => "kcd"
primitive DBKindCacheTree fun _proto(): String => "%" fun _suffix(): String => "kcf"
primitive DBKindStash     fun _proto(): String => ":" fun _suffix(): String => "kcx"
