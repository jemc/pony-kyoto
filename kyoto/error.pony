
type Error is
  ( ErrorNone
  | ErrorNoImpl
  | ErrorInvalid
  | ErrorNoRepos
  | ErrorNoPerm
  | ErrorBroken
  | ErrorDupRec
  | ErrorNoRec
  | ErrorLogic
  | ErrorSystem
  | ErrorMisc
  )

primitive ErrorNone    fun string(): String => "ErrorNone"    fun _i32(): I32 => 0
primitive ErrorNoImpl  fun string(): String => "ErrorNoImpl"  fun _i32(): I32 => 1
primitive ErrorInvalid fun string(): String => "ErrorInvalid" fun _i32(): I32 => 2
primitive ErrorNoRepos fun string(): String => "ErrorNoRepos" fun _i32(): I32 => 3
primitive ErrorNoPerm  fun string(): String => "ErrorNoPerm"  fun _i32(): I32 => 4
primitive ErrorBroken  fun string(): String => "ErrorBroken"  fun _i32(): I32 => 5
primitive ErrorDupRec  fun string(): String => "ErrorDupRec"  fun _i32(): I32 => 6
primitive ErrorNoRec   fun string(): String => "ErrorNoRec"   fun _i32(): I32 => 7
primitive ErrorLogic   fun string(): String => "ErrorLogic"   fun _i32(): I32 => 8
primitive ErrorSystem  fun string(): String => "ErrorSystem"  fun _i32(): I32 => 9
primitive ErrorMisc    fun string(): String => "ErrorMisc"    fun _i32(): I32 => 15

primitive _ErrorUtil
  fun from_i32(value: I32): Error =>
    match value
    | 0 => ErrorNone
    | 1 => ErrorNoImpl
    | 2 => ErrorInvalid
    | 3 => ErrorNoRepos
    | 4 => ErrorNoPerm
    | 5 => ErrorBroken
    | 6 => ErrorDupRec
    | 7 => ErrorNoRec
    | 8 => ErrorLogic
    | 9 => ErrorSystem
    else   ErrorMisc
    end
