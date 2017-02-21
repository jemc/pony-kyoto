
use "ponytest"
use ".."

class DBTest is UnitTest
  new iso create() => None
  fun name(): String => "kyoto.DB"
  
  fun _fail(h: TestHelper, db: DB box, action: String = "")? =>
    h.fail("error " + action + " ("
      + "code " + db.last_error().string()
      + "): " + db.last_error_message())
    error
  
  fun apply(h: TestHelper)? =>
    let db = DB
    
    // try db.open_proto(DBKindTree, OpenWriter + OpenCreate + OpenTruncate)
    try db.open("/tmp/foo.kct", OpenWriter + OpenCreate + OpenTruncate)
    else _fail(h, db, "opening db")
    end
    
    try db.set("foo", "FOO")
    else _fail(h, db, "setting key 'foo'")
    end
    
    try db.insert_if_absent("foo", "FOO2")
    else _fail(h, db, "setting key 'foo'")
    end
    
    try db.replace_if_present("foo", "FOO3")
    else _fail(h, db, "setting key 'foo'")
    end
    
    try h.env.out.print(db.get("foo"))
    else _fail(h, db, "getting key 'foo'")
    end
