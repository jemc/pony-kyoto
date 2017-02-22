
use "ponytest"
use ".."

class DBTest is UnitTest
  fun name(): String => "kyoto.DB"
  
  fun _fail(h: TestHelper, db: DB box, action: String)? =>
    h.fail("error " + action + " ("
      + "code " + db.last_error().string()
      + "): " + db.last_error_message())
    error
  
  fun assert_error(h: TestHelper, db: DB, e: Error, fn: {(DB)?},
    loc: SourceLoc = __loc)?
  =>
    try
      fn(db)
      h.assert_true(false, "expected lambda to raise an error", loc)
    else
      if not h.assert_is[Error](e, db.last_error(), "", loc) then
        _fail(h, db, "unexpected")
        error
      end
    end
  
  fun assert_no_error(h: TestHelper, db: DB, fn: {(DB)?},
    loc: SourceLoc = __loc)?
  =>
    try
      fn(db)
    else
      h.assert_true(false, "expected lambda not to raise an error", loc)
      _fail(h, db, "was")
      error
    end
  
  fun apply(h: TestHelper)? =>
    let db = DB
    // try db.open_proto(DBKindTree, OpenWriter + OpenCreate + OpenTruncate)
    try db.open("/tmp/foo.kch", OpenWriter + OpenCreate + OpenTruncate)
    else _fail(h, db, "opening db")
    end
    
    try h.env.out.print(db.status_info())
    else _fail(h, db, "printing status_info")
    end
    
    try test_basic(h, db, "test_basic") end
    try test_i64(h, db, "test_i64") end
    try test_f64(h, db, "test_f64") end
  
  fun test_basic(h: TestHelper, db: DB, key: String)? =>
    assert_no_error(h, db, {(db: DB)(key)? =>
      db.set(key, "FOO")
    })
    
    assert_no_error(h, db, {(db: DB)(h, key)? =>
      h.assert_false(db.insert_if_absent(key, "NOPE"))
    })
    
    assert_no_error(h, db, {(db: DB)(h, key)? =>
      h.assert_true(db.replace_if_present(key, "BAR"))
    })
    
    assert_no_error(h, db, {(db: DB)(key)? =>
      db.append_to(key, "FIGHT")
    })
    
    assert_no_error(h, db, {(db: DB)(h, key)? =>
      h.assert_eq[String](db.get(key), "BARFIGHT")
    })
    
    assert_no_error(h, db, {(db: DB)(key)? =>
      db.remove(key)
    })
    
    assert_error(h, db, ErrorNoRec, {(db: DB)(key)? =>
      db.get(key)
    })
    
    assert_error(h, db, ErrorNoRec, {(db: DB)(key)? =>
      db.remove(key)
    })
    
    assert_no_error(h, db, {(db: DB)(h, key)? =>
      h.assert_false(db.remove_if_present(key))
    })
    
    assert_no_error(h, db, {(db: DB)(h, key)? =>
      h.assert_true(db.insert_if_absent(key, "FOO"))
    })
    
    assert_no_error(h, db, {(db: DB)(h, key)? =>
      h.assert_true(db.remove_if_present(key))
    })
    
    assert_no_error(h, db, {(db: DB)(h, key)? =>
      h.assert_false(db.replace_if_present(key, "NOPE"))
    })
    
    assert_error(h, db, ErrorNoRec, {(db: DB)(key)? =>
      db.get(key)
    })
    
    assert_no_error(h, db, {(db: DB)(h, key)? =>
      h.assert_false(db.contains(key))
    })
    
    assert_error(h, db, ErrorNoRec, {(db: DB)(h, key)? =>
      db.size_at(key)
    })
    
    assert_no_error(h, db, {(db: DB)(key)? =>
      db.append_to(key, "FIGHT")
    })
    
    assert_no_error(h, db, {(db: DB)(h, key)? =>
      h.assert_eq[String](db.get(key), "FIGHT")
    })
    
    assert_no_error(h, db, {(db: DB)(h, key)? =>
      h.assert_true(db.contains(key))
    })
    
    assert_no_error(h, db, {(db: DB)(h, key)? =>
      h.assert_eq[USize](db.size_at(key), "FIGHT".size())
    })
    
    assert_no_error(h, db, {(db: DB)(h, key)? =>
      h.assert_eq[String](db.pop(key), "FIGHT")
    })
    
    assert_error(h, db, ErrorNoRec, {(db: DB)(key)? =>
      db.get(key)
    })
  
  fun test_i64(h: TestHelper, db: DB, key: String)? =>
    assert_error(h, db, ErrorLogic, {(db: DB)(key)? =>
      db.incr_i64(key, 5)
    })
    
    assert_no_error(h, db, {(db: DB)(key)? =>
      db.incr_i64(key, 5, 0)
    })
    
    assert_no_error(h, db, {(db: DB)(key)? =>
      db.set_i64(key, 12)
    })
  
  fun test_f64(h: TestHelper, db: DB, key: String)? =>
    assert_error(h, db, ErrorLogic, {(db: DB)(key)? =>
      db.incr_f64(key, 5)
    })
    
    assert_no_error(h, db, {(db: DB)(key)? =>
      db.incr_f64(key, 5, 0)
    })
    
    assert_no_error(h, db, {(db: DB)(key)? =>
      db.set_f64(key, 12)
    })
