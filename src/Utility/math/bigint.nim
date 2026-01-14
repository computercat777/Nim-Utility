type
  BigInt* = object
    limbs*: seq[uint32]
    isNegative*: bool = false
  IntegerType* = concept x
    x is (int8 or int16 or int32 or int64 or uint8 or uint16 or uint32 or uint64)
  SmallInt* = int8 | int16 | int32
  SmallUInt* = uint8 | uint16 | uint32

template initBigInt*[T: IntegerType](input: lent T): BigInt =
  var output: BigInt
  when T is SmallInt:
    if input < 0:
      output.limbs.add(uint32(-input))
      output.isNegative = true
    else:
      output.limbs.add(uint32(input))
      output.isNegative = false
  elif T is SmallUInt:
    output.limbs.add(uint32(input))
    output.isNegative = false
  elif T is int64:
    if uint64(abs(input)) > uint32.high.uint64:
      let absInput = uint64(abs(input))
      output.limbs = @[(absInput and 0xFFFFFFFF'u64).uint32, (absInput shr 32).uint32]
    else:
      output.limbs = @[uint32(abs(input))]
    output.isNegative = (input < 0)
  elif T is uint64:
    if input > uint32.high.uint64:
      output.limbs = @[(input and 0xFFFFFFFF'u64).uint32, (input shr 32).uint32]
    else:
      output.limbs = @[input.uint32]
    output.isNegative = false
  output


template isZero(b: lent BigInt): bool =
  var output: bool = true

  for limb in b.limbs:
    if limb != 0'u32: 
      output = false
      break
  
  output

template divMod10(b: var BigInt): uint32 =
  var remainder: uint64 = 0
  for i in countdown(b.limbs.len-1, 0):
    let cur = (remainder shl 32) + uint64(b.limbs[i])
    let q = cur div 10
    let r = cur mod 10
    b.limbs[i] = q.uint32
    remainder = r
  remainder.uint32

template toString*(input: lent BigInt): string = 
  var output: string

  if input.isZero:
    output = "0"

  var tmp: BigInt = input
  var digits: seq[char] = @[]

  while not tmp.isZero:
    let r = divmod10(tmp)
    digits.add(char(r + ord('0')))

  if input.isNegative:
    output.add('-')

  for i in countdown(digits.len - 1, 0):
    output.add(digits[i])

  output

template toInt*(input: lent BigInt): int =
  var result: int
  const intBits = sizeof(int) * 8

  when intBits == 32:
    static:
      doAssert intBits == 32, "Expected 32-bit int"
    if input.limbs.len == 0:
      result = 0
    elif input.limbs.len == 1:
      result = int(input.limbs[0])
    else:
      raise newException(ValueError, "BigInt too large to fit in 32-bit int")

  elif intBits == 64:
    static:
      doAssert intBits == 64, "Expected 64-bit int"
    if input.limbs.len == 0:
      result = 0
    elif input.limbs.len == 1:
      result = int(input.limbs[0])
    elif input.limbs.len == 2:
      result = int((uint64(input.limbs[1]) shl 32) or uint64(input.limbs[0]))
    else:
      raise newException(ValueError, "BigInt too large to fit in 64-bit int")

  else:
    {.error: "Unsupported int size for toInt: only 32-bit or 64-bit supported".}

  result

template shiftLeft*(x: lent BigInt, shift: Natural): BigInt =
  var result: BigInt

  if x.limbs.len == 0 or shift == 0:
    result = x

  let limbBits = 32
  let limbShift = shift div limbBits
  let bitShift = shift mod limbBits

  var res = newSeq[uint32](x.limbs.len + limbShift + 1)
  var carry: uint32 = 0

  for i in 0..<x.limbs.len:
    let limb = x.limbs[i]
    res[i + limbShift] = (limb shl bitShift) or carry
    if bitShift != 0:
      carry = limb shr (limbBits - bitShift)
    else:
      carry = 0

  if carry != 0:
    res[x.limbs.len + limbShift] = carry

  result.limbs = res
  result.isNegative = x.isNegative
 
  result

template shiftRight*(x: lent BigInt, shift: Natural): BigInt =
  var result: BigInt

  if x.limbs.len == 0 or shift == 0:
    result = x

  let limbBits = 32
  let limbShift = shift div limbBits
  let bitShift = shift mod limbBits

  if limbShift >= x.limbs.len:
    result = initBigInt(0)

  let newLen = x.limbs.len - limbShift
  var res = newSeq[uint32](newLen)
  var carry: uint32 = 0

  for i in countdown(newLen - 1, 0):
    let limb = x.limbs[i + limbShift]
    res[i] = (limb shr bitShift) or carry
    if bitShift != 0:
      carry = (limb shl (limbBits - bitShift)) and 0xFFFFFFFF'u32
    else:
      carry = 0

  while res.len > 0 and res[^1] == 0:
    discard res.pop()

  result.limbs = res
  result.isNegative = x.isNegative

  result

template bitwiseAnd*(a, b: lent BigInt): BigInt =
  var result: BigInt
  var maxLen = if a.limbs.len > b.limbs.len: a.limbs.len else: b.limbs.len
  result.limbs = newSeq[uint32](maxLen)
  for i in 0..<maxLen:
    let ai = if i < a.limbs.len: a.limbs[i] else: 0'u32
    let bi = if i < b.limbs.len: b.limbs[i] else: 0'u32
    result.limbs[i] = ai and bi
  result

template bitwiseOr*(a, b: lent BigInt): BigInt =
  var result: BigInt
  var maxLen = if a.limbs.len > b.limbs.len: a.limbs.len else: b.limbs.len
  result.limbs = newSeq[uint32](maxLen)
  for i in 0..<maxLen:
    let ai = if i < a.limbs.len: a.limbs[i] else: 0'u32
    let bi = if i < b.limbs.len: b.limbs[i] else: 0'u32
    result.limbs[i] = ai or bi
  result

template bitwiseXor*(a, b: lent BigInt): BigInt =
  var result: BigInt
  var maxLen = if a.limbs.len > b.limbs.len: a.limbs.len else: b.limbs.len
  result.limbs = newSeq[uint32](maxLen)
  for i in 0..<maxLen:
    let ai = if i < a.limbs.len: a.limbs[i] else: 0'u32
    let bi = if i < b.limbs.len: b.limbs[i] else: 0'u32
    result.limbs[i] = ai xor bi
  result

template bitwiseNot*(a: lent BigInt): BigInt =
  var result: BigInt
  result.limbs = newSeq[uint32](a.limbs.len)
  for i in 0..<a.limbs.len:
    result.limbs[i] = not a.limbs[i]
  result

template cmpAbs*(a, b: lent BigInt): int =
  var result: int = 0
  if a.limbs.len > b.limbs.len: result = 1
  elif a.limbs.len < b.limbs.len: result = -1
  else:
    for i in countdown(a.limbs.len - 1, 0):
      if a.limbs[i] > b.limbs[i]: result = 1
      elif a.limbs[i] < b.limbs[i]: result = -1
  result

template equalTo*(a, b: lent BigInt): bool =
  var result: bool
  var x: int = cmpAbs(a, b)
  if x == 0:
    result = true
  else:
    result = false
  result

template notEqualTo*(a, b: lent BigInt): bool =
  var result: bool
  var x: int = cmpAbs(a, b)
  if x != 0:
    result = true
  else:
    result = false
  result

template lessThan*(a, b: lent BigInt): bool =
  var result: bool
  var x: int = cmpAbs(a, b)
  if (a.isNegative == true) and (b.isNegative == true):
    if x == 1:
      result = true
    else:
      result = false
  elif (a.isNegative == true) and (b.isNegative == false):
    result = true
  elif (a.isNegative == false) and (b.isNegative == true):
    result = false
  elif (a.isNegative == false) and (b.isNegative == false):
    if x == -1:
      result = true
    else:
      result = false
  result

template greaterThan*(a, b: lent BigInt): bool =
  var result: bool
  var x: int = cmpAbs(a, b)
  if (a.isNegative == true) and (b.isNegative == true):
    if x == -1:
      result = true
    else:
      result = false
  elif (a.isNegative == true) and (b.isNegative == false):
    result = false
  elif (a.isNegative == false) and (b.isNegative == true):
    result = true
  elif (a.isNegative == false) and (b.isNegative == false):
    if x == 1:
      result = true
    else:
      result = false
  result

template lessThanOrEqualTo*(a, b: lent BigInt): bool =
  var result: bool
  var x: int = cmpAbs(a, b)
  if (a.isNegative == true) and (b.isNegative == true):
    if x == 1 or x == 0:
      result = true
    else:
      result = false
  elif (a.isNegative == true) and (b.isNegative == false):
    result = true
  elif (a.isNegative == false) and (b.isNegative == true):
    result = false
  elif (a.isNegative == false) and (b.isNegative == false):
    if x == -1 or x == 0:
      result = true
    else:
      result = false
  result

template greaterThanOrEqualTo*(a, b: lent BigInt): bool =
  var result: bool
  var x: int = cmpAbs(a, b)
  if (a.isNegative == true) and (b.isNegative == true):
    if x == -1 or x == 0:
      result = true
    else:
      result = false
  elif (a.isNegative == true) and (b.isNegative == false):
    result = false
  elif (a.isNegative == false) and (b.isNegative == true):
    result = true
  elif (a.isNegative == false) and (b.isNegative == false):
    if x == 1 or x == 0:
      result = true
    else:
      result = false
  result

template addAbs*(a, b: lent BigInt): BigInt = 
  var result: BigInt
  result.isNegative = false
  
  if a.limbs.len == 0 or b.limbs.len == 0:
    result = initBigInt(0)

  let maxLen = max(a.limbs.len, b.limbs.len)
  var carry: uint64 = 0

  for i in 0 ..< maxLen:
    let ai = if i < a.limbs.len: a.limbs[i] else: 0'u32
    let bi = if i < b.limbs.len: b.limbs[i] else: 0'u32

    let sum = uint64(ai) + uint64(bi) + carry
    result.limbs.add(sum.uint32)

    carry = sum shr 32

  if carry > 0:
    result.limbs.add(carry.uint32)

  result

template subAbs*(a, b: lent BigInt): BigInt =
  var result: BigInt

  let cmp = cmpAbs(a, b)
  var A: BigInt
  var B: BigInt

  if cmp >= 0:
    A = a
    B = b
    result.isNegative = false
  else:
    A = b
    B = a
    result.isNegative = true

  var borrow: uint64 = 0
  
  for i in 0 ..< A.limbs.len:
    let ai: uint64 = uint64(A.limbs[i])
    let bi: uint64 = if i < B.limbs.len: uint64(B.limbs[i]) else: 0'u64
    var diff = ai - bi - borrow
    if ai < bi + borrow:
      diff += (1'u64 shl 32)
      borrow = 1
    else:
      borrow = 0

    result.limbs.add(diff.uint32)

  while result.limbs.len > 0 and result.limbs[^1] == 0'u32:
    result.limbs.setLen(result.limbs.len - 1)

  result

template mulAbs*(a, b: lent BigInt): BigInt = 
  var result: BigInt
  result.isNegative = false
  result.limbs = newSeq[uint32](a.limbs.len + b.limbs.len)

  for i in 0 ..< a.limbs.len:
    var carry: uint64 = 0
    for j in 0 ..< b.limbs.len:
      let idx = i + j
      let prod = uint64(a.limbs[i]) * uint64(b.limbs[j]) + uint64(result.limbs[idx]) + carry
      result.limbs[idx] = prod.uint32
      carry = prod shr 32
      
    result.limbs[i + b.limbs.len] = (uint64(result.limbs[i + b.limbs.len]) + carry).uint32

  while result.limbs.len > 0 and result.limbs[^1] == 0'u32:
    result.limbs.setLen(result.limbs.len - 1)

  if a.limbs.len == 0 or b.limbs.len == 0: 
    result.limbs = @[0'u32]

  result

template normalize(a: var BigInt) =
  for i in countdown(a.limbs.high, 0):
    if a.limbs[i] > 0'u32:
        a.limbs.setLen(i+1)
        a.limbs.setLen(1)

template add*(a, b: lent BigInt): BigInt = 
  var result: BigInt
  if (a.isNegative == true) and (b.isNegative == true):
    result = addAbs(a, b)
    result.isNegative = true
  elif (a.isNegative == true) and (b.isNegative == false):
    result = subAbs(b, a)
  elif (a.isNegative == false) and (b.isNegative == true):
    result = subAbs(a, b)
  elif (a.isNegative == false) and (b.isNegative == false):
    result = addAbs(a, b)
    result.isNegative = false
  result

template sub*(a, b: lent BigInt): BigInt =
  var result: BigInt
  if (a.isNegative == true) and (b.isNegative == true):
    result = subAbs(b, a)
  elif (a.isNegative == true) and (b.isNegative == false):
    result = addAbs(a, b)
    result.isNegative = true
  elif (a.isNegative == false) and (b.isNegative == true):
    result = addAbs(a, b)
    result.isNegative = false
  elif (a.isNegative == false) and (b.isNegative == false):
    result = subAbs(a, b)
  result

template mul*(a, b: lent BigInt): BigInt =
  var result: BigInt
  if (a.isNegative == true) and (b.isNegative == true):
    result = mulAbs(a, b)
    result.isNegative = false
  elif (a.isNegative == true) and (b.isNegative == false):
    result = mulAbs(a, b)
    result.isNegative = true
  elif (a.isNegative == false) and (b.isNegative == true):
    result = mulAbs(a, b)
    result.isNegative = true
  elif (a.isNegative == false) and (b.isNegative == false):
    result = mulAbs(a, b)
    result.isNegative = false
  result

when defined(templateOpt):
  template `+`*(a, b: lent BigInt): BigInt =
    var result: BigInt = add(a, b)
    result

  template `-`*(a, b: lent BigInt): BigInt =
    var result: BigInt = sub(a, b)
    result

  template `*`*(a, b: lent BigInt): BigInt =
    var result: BigInt = mul(a, b)
    result

  template `==`*(a, b: lent BigInt): bool =
    var result: bool = equalTo(a, b)
    result

  template `!=`*(a, b: lent BigInt): bool =
    var result: bool = notEqualTo(a, b)
    result

  template `<`*(a, b: lent BigInt): bool =
    var result: bool = lessThan(a, b)
    result

  template `>`*(a, b: lent BigInt): bool =
    var result: bool = greaterThan(a, b)
    result

  template `<=`*(a, b: lent BigInt): bool =
    var result: bool = lessThanOREqualTo(a, b)
    result

  template `>=`*(a, b: lent BigInt): bool =
    var result: bool = greaterThanOrEqualTo(a, b)
    result
  
  template `+=`*(a: var BigInt, b: lent BigInt): void =
    a = a + b
    a

  template `-=`*(a: var BigInt, b: lent BigInt): void =
    a = a - b
    a
  template `*=`*(a: var BigInt, b: lent BigInt): void =
    a = a * b
    b

  template `shl`*(a: lent BigInt, b: Natural): BigInt =
    var result: BigInt = shiftLeft(a, b)
    result

  template `shr`*(a: lent BigInt, b: Natural): BigInt =
    var result: BigInt = shiftRight(a, b)
    result

  template `abs`*(a: lent BigInt): BigInt =
    var result: BigInt = a
    if a.isNegative == true:
      result.isNegative = false
    result

  template `and`*(a, b: lent BigInt): BigInt =
    var result: BigInt = bitwiseAnd(a, b)
    result

  template `or`*(a, b: lent BigInt): BigInt =
    var result: BigInt = bitwiseOr(a, b)
    result

  template `xor`*(a, b: lent BigInt): BigInt =
    var result: BigInt = bitwiseXor(a, b)
    result

  template `not`*(a: lent BigInt): BigInt =
    var result: BigInt = bitwiseNot(a)
    result
else:
  func `+`*(a, b: BigInt): BigInt =
    result = add(a, b)
    return result

  func `-`*(a, b: BigInt): BigInt =
    result = sub(a, b)
    return result

  func `*`*(a, b: BigInt): BigInt =
    result = mul(a, b)
    return result

  func `==`*(a, b: BigInt): bool =
    result = equalTo(a, b)
    return result

  func `!=`*(a, b: BigInt): bool =
    result = notEqualTo(a, b)
    return result

  func `<`*(a, b: BigInt): bool =
    result = lessThan(a, b)
    return result

  func `>`*(a, b: BigInt): bool =
    result = greaterThan(a, b)
    return result

  func `<=`*(a, b: BigInt): bool =
    result = lessThanOREqualTo(a, b)
    return result

  func `>=`*(a, b: BigInt): bool =
    result = greaterThanOrEqualTo(a, b)
    return result

  func `+=`*(a: var BigInt, b: BigInt): void =
    a = a + b
    return

  func `-=`*(a: var BigInt, b: BigInt): void =
    a = a - b
    return 
  
  func `*=`*(a: var BigInt, b: BigInt): void =
    a = a * b
    return
 
  func `shl`*(a: BigInt, b: Natural): BigInt =
    result = shiftLeft(a, b)
    return result

  func `shr`*(a: BigInt, b: Natural): BigInt =
    result = shiftRight(a, b)
    return result 
  
  func `abs`*(a: BigInt): BigInt =
    result = a
    if a.isNegative == true:
      result.isNegative = false
    return result

  func `and`*(a, b: BigInt): BigInt =
    result = bitwiseAnd(a, b)
    return result

  func `or`*(a, b: BigInt): BigInt =
    result = bitwiseOr(a, b)
    return result

  func `xor`*(a, b: BigInt): BigInt =
    result = bitwiseXor(a, b)
    return result

  func `not`*(a: BigInt): BigInt =
    result = bitwiseNot(a)
    return result

const Base: uint64 = 1'u64 shl 32

template divAbs*(a, b: lent BigInt): tuple[q, r: BigInt] =
  var result: tuple[q, r: BigInt]
  if a < b:
    result.q = initBigInt(0)
    result.r = a
  elif a.limbs.len == 0 or a == initBigInt(0):
    result.q = initBigInt(0)
    result.r = initBigInt(0)
  elif b.limbs.len == 0 or b == initBigInt(0):
    raise newException(ValueError, "b can't be zero.")
  else:
    let n: int = a.limbs.len
    let m: int = b.limbs.len

    var rL: seq[uint32] = a.limbs & 0'u32
    var qL: seq[uint32] = newSeq[uint32](n - m + 1)
    
    let vTop: uint64 = b.limbs[m - 1].uint64
    
    for i in countdown(n - m, 0):
      var top2: uint64 = (rL[i + m]. uint64 shl 32) or rL[i + m - 1].uint64
      var qHat = top2 div vTop

      if qHat >= Base: qHat = Base - 1

      var borrow: int64 = 0
      for j in 0 ..< m:
        let prod: uint64 = qHat * b.limbs[j].uint64 + borrow.uint64
        let sub: uint64 = rL[i + j].uint64
        
        rL[i + j] = uint32(sub.int64 - (prod and 0xFFFFFFFF'u64).int64)
        borrow = (prod shr 32).int64 + (if sub < (prod and 0xFFFFFFFF'u64): 1 else: 0)

      let lastSub: int64 = rL[i + m].int64 - borrow
      rL[i + m] = uint32(lastSub.uint64 and 0xFFFFFFFF'u64)
      
      if lastSub < 0:
        qHat -= 1
        var carry: uint64 = 0
        for j in 0 ..< m:
          let sum = rL[i + j].uint64 + b.limbs[j].uint64 + carry
          rL[i + j] = uint32(sum and 0xFFFFFFFF'u64)
          carry = sum shr 32
        rL[i + m] = uint32((rL[i + m].uint64 + carry) and 0xFFFFFFFF'u64)

      qL[i] = uint32(qHat)

    result.q.limbs = qL
    while result.q.limbs.len > 1 and result.q.limbs[^1] == 0:
      result.q.limbs.setLen(result.q.limbs.len - 1)

    result.r.limbs = rL[0 ..< m]
    while result.r.limbs.len > 1 and result.r.limbs[^1] == 0:
      result.r.limbs.setLen(result.r.limbs.len - 1)
    
  result

template division*(a, b: lent BigInt): tuple[q, r: BigInt] =
  var result: tuple[q, r: BigInt]
  if (a.isNegative == true) and (b.isNegative == true):
    result = divAbs(a, b)
    result.q.isNegative = false
  elif (a.isNegative == true) and (b.isNegative == false):
    result = divAbs(a, b)
    result.q.isNegative = true
  elif (a.isNegative == false) and (b.isNegative == true):
    result = divAbs(a, b)
    result.q.isNegative = true
  elif (a.isNegative == false) and (b.isNegative == false):
    result = divAbs(a, b)
    result.q.isNegative = false
  result

when defined(templateOpt):
  template `div`*(a, b: lent BigInt): BigInt =
    var tmp: tuple[q, r: BigInt] = division(a, b)
    tmp.q

  template `mod`*(a, b: lent BigInt): BigInt = 
    var tmp: tuple[q, r: BigInt] = division(a, b)
    tmp.r

  template `divmod`*(a, b: lent BigInt): tuple[q, r: BigInt] =
    result = division(a, b)
    result
else:
  func `div`*(a, b: BigInt): BigInt =
    var tmp: tuple[q, r: BigInt] = division(a, b)
    return tmp.q

  func `mod`*(a, b: BigInt): BigInt = 
    var tmp: tuple[q, r: BigInt] = division(a, b)
    return tmp.r

  func `divmod`*(a, b: BigInt): tuple[q, r: BigInt] =
    result = division(a, b)
    return result

template initBigInt*(input: lent string): BigInt =
  if input.len == 0:
    raise newException(ValueError, "Empty input")

  let constant: BigInt = initBigInt(10'u32)
  var output: BigInt = initBigInt(0'u32)
  var start = 0
  if input[0] == '-':
    output.isNegative = true
    start = 1
  elif input[0] == '+':
    output.isNegative = false
    start = 1

  for i in countdown(input.len, start):
    var c: char = input[i]
    if c < '0' or c > '9':
      raise newException(ValueError, "input string is not digit.")

    var digit: uint32 = uint32(ord(c) - ord('0'))
    output = output * constant + initBigInt(digit)

  output
