template zerofill*(address: pointer, u: int, size: int): void =
  if address != nil and size > 0:
    for i in 0 ..< u:
      {.emit: """memset(`address`, 0xFF, `size`);""".}

      when defined(gcc) or defined(clang):
        asm """
        "" : : "r"(`address`) : "memory"
        """
