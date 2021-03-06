when notJSnotNims:
  proc zeroMem*(p: pointer, size: Natural) {.inline, noSideEffect,
    tags: [], locks: 0, raises: [].}
    ## Overwrites the contents of the memory at ``p`` with the value 0.
    ##
    ## Exactly ``size`` bytes will be overwritten. Like any procedure
    ## dealing with raw memory this is **unsafe**.

  proc copyMem*(dest, source: pointer, size: Natural) {.inline, benign,
    tags: [], locks: 0, raises: [].}
    ## Copies the contents from the memory at ``source`` to the memory
    ## at ``dest``.
    ## Exactly ``size`` bytes will be copied. The memory
    ## regions may not overlap. Like any procedure dealing with raw
    ## memory this is **unsafe**.

  proc moveMem*(dest, source: pointer, size: Natural) {.inline, benign,
    tags: [], locks: 0, raises: [].}
    ## Copies the contents from the memory at ``source`` to the memory
    ## at ``dest``.
    ##
    ## Exactly ``size`` bytes will be copied. The memory
    ## regions may overlap, ``moveMem`` handles this case appropriately
    ## and is thus somewhat more safe than ``copyMem``. Like any procedure
    ## dealing with raw memory this is still **unsafe**, though.

  proc equalMem*(a, b: pointer, size: Natural): bool {.inline, noSideEffect,
    tags: [], locks: 0, raises: [].}
    ## Compares the memory blocks ``a`` and ``b``. ``size`` bytes will
    ## be compared.
    ##
    ## If the blocks are equal, `true` is returned, `false`
    ## otherwise. Like any procedure dealing with raw memory this is
    ## **unsafe**.

when hasAlloc:
  proc alloc*(size: Natural): pointer {.noconv, rtl, tags: [], benign, raises: [].}
    ## Allocates a new memory block with at least ``size`` bytes.
    ##
    ## The block has to be freed with `realloc(block, 0) <#realloc,pointer,Natural>`_
    ## or `dealloc(block) <#dealloc,pointer>`_.
    ## The block is not initialized, so reading
    ## from it before writing to it is undefined behaviour!
    ##
    ## The allocated memory belongs to its allocating thread!
    ## Use `allocShared <#allocShared,Natural>`_ to allocate from a shared heap.
    ##
    ## See also:
    ## * `alloc0 <#alloc0,Natural>`_
  proc createU*(T: typedesc, size = 1.Positive): ptr T {.inline, benign, raises: [].} =
    ## Allocates a new memory block with at least ``T.sizeof * size`` bytes.
    ##
    ## The block has to be freed with `resize(block, 0) <#resize,ptr.T,Natural>`_
    ## or `dealloc(block) <#dealloc,pointer>`_.
    ## The block is not initialized, so reading
    ## from it before writing to it is undefined behaviour!
    ##
    ## The allocated memory belongs to its allocating thread!
    ## Use `createSharedU <#createSharedU,typedesc>`_ to allocate from a shared heap.
    ##
    ## See also:
    ## * `create <#create,typedesc>`_
    cast[ptr T](alloc(T.sizeof * size))

  proc alloc0*(size: Natural): pointer {.noconv, rtl, tags: [], benign, raises: [].}
    ## Allocates a new memory block with at least ``size`` bytes.
    ##
    ## The block has to be freed with `realloc(block, 0) <#realloc,pointer,Natural>`_
    ## or `dealloc(block) <#dealloc,pointer>`_.
    ## The block is initialized with all bytes containing zero, so it is
    ## somewhat safer than  `alloc <#alloc,Natural>`_.
    ##
    ## The allocated memory belongs to its allocating thread!
    ## Use `allocShared0 <#allocShared0,Natural>`_ to allocate from a shared heap.
  proc create*(T: typedesc, size = 1.Positive): ptr T {.inline, benign, raises: [].} =
    ## Allocates a new memory block with at least ``T.sizeof * size`` bytes.
    ##
    ## The block has to be freed with `resize(block, 0) <#resize,ptr.T,Natural>`_
    ## or `dealloc(block) <#dealloc,pointer>`_.
    ## The block is initialized with all bytes containing zero, so it is
    ## somewhat safer than `createU <#createU,typedesc>`_.
    ##
    ## The allocated memory belongs to its allocating thread!
    ## Use `createShared <#createShared,typedesc>`_ to allocate from a shared heap.
    cast[ptr T](alloc0(sizeof(T) * size))

  proc realloc*(p: pointer, newSize: Natural): pointer {.noconv, rtl, tags: [],
                                                         benign, raises: [].}
    ## Grows or shrinks a given memory block.
    ##
    ## If `p` is **nil** then a new memory block is returned.
    ## In either way the block has at least ``newSize`` bytes.
    ## If ``newSize == 0`` and `p` is not **nil** ``realloc`` calls ``dealloc(p)``.
    ## In other cases the block has to be freed with
    ## `dealloc(block) <#dealloc,pointer>`_.
    ##
    ## The allocated memory belongs to its allocating thread!
    ## Use `reallocShared <#reallocShared,pointer,Natural>`_ to reallocate
    ## from a shared heap.
  proc resize*[T](p: ptr T, newSize: Natural): ptr T {.inline, benign, raises: [].} =
    ## Grows or shrinks a given memory block.
    ##
    ## If `p` is **nil** then a new memory block is returned.
    ## In either way the block has at least ``T.sizeof * newSize`` bytes.
    ## If ``newSize == 0`` and `p` is not **nil** ``resize`` calls ``dealloc(p)``.
    ## In other cases the block has to be freed with ``free``.
    ##
    ## The allocated memory belongs to its allocating thread!
    ## Use `resizeShared <#resizeShared,ptr.T,Natural>`_ to reallocate
    ## from a shared heap.
    cast[ptr T](realloc(p, T.sizeof * newSize))

  proc dealloc*(p: pointer) {.noconv, rtl, tags: [], benign, raises: [].}
    ## Frees the memory allocated with ``alloc``, ``alloc0`` or
    ## ``realloc``.
    ##
    ## **This procedure is dangerous!**
    ## If one forgets to free the memory a leak occurs; if one tries to
    ## access freed memory (or just freeing it twice!) a core dump may happen
    ## or other memory may be corrupted.
    ##
    ## The freed memory must belong to its allocating thread!
    ## Use `deallocShared <#deallocShared,pointer>`_ to deallocate from a shared heap.

  proc allocShared*(size: Natural): pointer {.noconv, rtl, benign, raises: [], tags: [].}
    ## Allocates a new memory block on the shared heap with at
    ## least ``size`` bytes.
    ##
    ## The block has to be freed with
    ## `reallocShared(block, 0) <#reallocShared,pointer,Natural>`_
    ## or `deallocShared(block) <#deallocShared,pointer>`_.
    ##
    ## The block is not initialized, so reading from it before writing
    ## to it is undefined behaviour!
    ##
    ## See also:
    ## `allocShared0 <#allocShared0,Natural>`_.
  proc createSharedU*(T: typedesc, size = 1.Positive): ptr T {.inline, tags: [],
                                                               benign, raises: [].} =
    ## Allocates a new memory block on the shared heap with at
    ## least ``T.sizeof * size`` bytes.
    ##
    ## The block has to be freed with
    ## `resizeShared(block, 0) <#resizeShared,ptr.T,Natural>`_ or
    ## `freeShared(block) <#freeShared,ptr.T>`_.
    ##
    ## The block is not initialized, so reading from it before writing
    ## to it is undefined behaviour!
    ##
    ## See also:
    ## * `createShared <#createShared,typedesc>`_
    cast[ptr T](allocShared(T.sizeof * size))

  proc allocShared0*(size: Natural): pointer {.noconv, rtl, benign, raises: [], tags: [].}
    ## Allocates a new memory block on the shared heap with at
    ## least ``size`` bytes.
    ##
    ## The block has to be freed with
    ## `reallocShared(block, 0) <#reallocShared,pointer,Natural>`_
    ## or `deallocShared(block) <#deallocShared,pointer>`_.
    ##
    ## The block is initialized with all bytes
    ## containing zero, so it is somewhat safer than
    ## `allocShared <#allocShared,Natural>`_.
  proc createShared*(T: typedesc, size = 1.Positive): ptr T {.inline.} =
    ## Allocates a new memory block on the shared heap with at
    ## least ``T.sizeof * size`` bytes.
    ##
    ## The block has to be freed with
    ## `resizeShared(block, 0) <#resizeShared,ptr.T,Natural>`_ or
    ## `freeShared(block) <#freeShared,ptr.T>`_.
    ##
    ## The block is initialized with all bytes
    ## containing zero, so it is somewhat safer than
    ## `createSharedU <#createSharedU,typedesc>`_.
    cast[ptr T](allocShared0(T.sizeof * size))

  proc reallocShared*(p: pointer, newSize: Natural): pointer {.noconv, rtl, tags: [],
                                                               benign, raises: [].}
    ## Grows or shrinks a given memory block on the heap.
    ##
    ## If `p` is **nil** then a new memory block is returned.
    ## In either way the block has at least ``newSize`` bytes.
    ## If ``newSize == 0`` and `p` is not **nil** ``reallocShared`` calls
    ## ``deallocShared(p)``.
    ## In other cases the block has to be freed with
    ## `deallocShared <#deallocShared,pointer>`_.
  proc resizeShared*[T](p: ptr T, newSize: Natural): ptr T {.inline, raises: [].} =
    ## Grows or shrinks a given memory block on the heap.
    ##
    ## If `p` is **nil** then a new memory block is returned.
    ## In either way the block has at least ``T.sizeof * newSize`` bytes.
    ## If ``newSize == 0`` and `p` is not **nil** ``resizeShared`` calls
    ## ``freeShared(p)``.
    ## In other cases the block has to be freed with
    ## `freeShared <#freeShared,ptr.T>`_.
    cast[ptr T](reallocShared(p, T.sizeof * newSize))

  proc deallocShared*(p: pointer) {.noconv, rtl, benign, raises: [], tags: [].}
    ## Frees the memory allocated with ``allocShared``, ``allocShared0`` or
    ## ``reallocShared``.
    ##
    ## **This procedure is dangerous!**
    ## If one forgets to free the memory a leak occurs; if one tries to
    ## access freed memory (or just freeing it twice!) a core dump may happen
    ## or other memory may be corrupted.
  proc freeShared*[T](p: ptr T) {.inline, benign, raises: [].} =
    ## Frees the memory allocated with ``createShared``, ``createSharedU`` or
    ## ``resizeShared``.
    ##
    ## **This procedure is dangerous!**
    ## If one forgets to free the memory a leak occurs; if one tries to
    ## access freed memory (or just freeing it twice!) a core dump may happen
    ## or other memory may be corrupted.
    deallocShared(p)


# GC interface:

when hasAlloc:
  proc getOccupiedMem*(): int {.rtl.}
    ## Returns the number of bytes that are owned by the process and hold data.

  proc getFreeMem*(): int {.rtl.}
    ## Returns the number of bytes that are owned by the process, but do not
    ## hold any meaningful data.

  proc getTotalMem*(): int {.rtl.}
    ## Returns the number of bytes that are owned by the process.


when defined(js):
  # Stubs:
  proc getOccupiedMem(): int = return -1
  proc getFreeMem(): int = return -1
  proc getTotalMem(): int = return -1

  proc dealloc(p: pointer) = discard
  proc alloc(size: Natural): pointer = discard
  proc alloc0(size: Natural): pointer = discard
  proc realloc(p: pointer, newsize: Natural): pointer = discard

  proc allocShared(size: Natural): pointer = discard
  proc allocShared0(size: Natural): pointer = discard
  proc deallocShared(p: pointer) = discard
  proc reallocShared(p: pointer, newsize: Natural): pointer = discard


when hasAlloc and hasThreadSupport:
  proc getOccupiedSharedMem*(): int {.rtl.}
    ## Returns the number of bytes that are owned by the process
    ## on the shared heap and hold data. This is only available when
    ## threads are enabled.

  proc getFreeSharedMem*(): int {.rtl.}
    ## Returns the number of bytes that are owned by the
    ## process on the shared heap, but do not hold any meaningful data.
    ## This is only available when threads are enabled.

  proc getTotalSharedMem*(): int {.rtl.}
    ## Returns the number of bytes on the shared heap that are owned by the
    ## process. This is only available when threads are enabled.
