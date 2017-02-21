
use "lib:kyotocabinet"

primitive _Lib
  fun malloc[A](size: USize): Pointer[A] =>
    """
    Allocate memory of the given size. Release with corresponding free method.
    """
    @kcmalloc[Pointer[A]](size)
  
  fun free[A](ptr: Pointer[A] tag) =>
    """
    Release a pointer to a region of memory allocated by the library.
    """
    @kcfree[None](ptr)
