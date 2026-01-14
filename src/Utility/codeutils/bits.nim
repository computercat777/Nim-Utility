{.experimental: "strictNotNil".}

type
  BitsUtilsError* = enum
    TooBigN = 0
    NotSameSize = 1

template leftRotateC[T: SomeInteger](value: lent T, shift: lent T): T =
  let bitCount: T = sizeof(T) * 8
  let realShift = shift mod bitCount
    
  ((value shl realShift) or (value shr (T(sizeof(T) * 8) - realShift)))

template rightRotateC[T: SomeInteger](value: lent T, shift: lent T): T =
  let bitCount: T = sizeof(T) * 8
  let realShift = shift mod bitCount
    
  ((value shr realShift) or (value shl (T(sizeof(T) * 8) - realShift)))

# Little Endian Encode
template toBytesLEC*[T: SomeInteger, N: static[int]](x: T, result: var array[N, uint8]) =
  static: doAssert N == sizeof(x)
  for i in static(0 ..< N):
    result[i] = uint8((x shr (i * 8)) and 0xFF)

# Big Endian Encode
template toBytesBEC*[T: SomeInteger, N: static[int]](x: T, result: var array[N, uint8]) =
  static: doAssert N == sizeof(x)
  for i in static(0 ..< N):
    result[i] = uint8((x shr ((N - 1 - i) * 8)) and 0xFF)

# Little Endian Decode
template fromBytesLEC*[T: SomeInteger, N: static[int]](src: array[N, uint8], ret: var T) =
  static: doAssert N == sizeof(ret)
  ret = 0
  for i in static(0 ..< N):
    ret = ret or (T(src[i]) shl (i * 8))

# Big Endian Decode
template fromBytesBEC*[T: SomeInteger, N: static[int]](src: array[N, uint8], ret: var T) =
  static: doAssert N == sizeof(ret)
  ret = 0
  for i in static(0 ..< N):
    ret = ret or (T(src[i]) shl ((N - 1 - i) * 8))

# export wrapper
when defined(templateOpt):
  template leftRotate*[T: SomeInteger](x: lent T, n: lent T): T =
    var result: T = leftRotateC(x, n)
    result

  template rightRotate*[T: SomeInteger](x: lent T, n: lent T): T =
    var result: T = rightRotateC(x, n)
    result

  template toBytesLE*[T: SomeInteger, N: static[int]](input: lent T, output: var array[N, uint8]): void =
    toBytesLEC(input, output)
    
  template toBytesBE*[T: SomeInteger, N: static[int]](input: lent T, output: var array[N, uint8]): void =
    toBytesBEC(input, output)

  template fromBytesLE*[T: SomeInteger, N: static[int]](input: lent array[N, uint8], output: var T): void =
    fromBytesLEC(input, output)

  template fromBytesBE*[T: SomeINteger, N: static[int]](input: lent array[N, uint8], output: var T): void =
    fromBytesBEC(input, output)

  template `^=`*[T: SomeInteger](x: var T, y: T): void =
    x = x xor y

  template `&=`*[T: SomeInteger](x: var T, y: T): void =
    x = x and y

  template `|=`*[T: SomeInteger](x: var T, y: T): void =
    x = x or y

  template `<<`*[T: SomeInteger](x: T, y: T): T =
    x shl y

  template `>>`*[T: SomeInteger](x: T, y: T): T =
    x shr y

  template `<<<`*[T: SomeInteger](x: T, y: T): T =
    leftRotateC(x, y)

  template `>>>`*[T: SomeInteger](x: T, y: T): T =
    rightRotateC(x, y)

  template `<<<=`*[T: SomeInteger](x: var T, y: T): void =
    x = leftRotateTemplate(x, y)

  template `>>>=`*[T: SomeInteger](x: var T, y: T): void =
    x = rightRotateTemplate(x, y)
else:
  func leftRotate*[T: SomeInteger](x: T, n: T): T =
    result = leftRotateC(x, n)
    return result

  func rightRotate*[T: SomeInteger](x: T, n: T): T =
    result = rightRotateC(x, n)
    return result

  func toBytesLE*[T: SomeInteger, N: static[int]](input: T, output: var array[N, uint8]): void =
    toBytesLEC(input, output)
    return
    
  func toBytesBE*[T: SomeInteger, N: static[int]](input: T, output: var array[N, uint8]): void =
    toBytesBEC(input, output)
    return

  func fromBytesLE*[T: SomeInteger, N: static[int]](input: array[N, uint8], output: var T): void =
    fromBytesLEC(input, output)
    return 

  func fromBytesBE*[T: SomeINteger, N: static[int]](input: array[N, uint8], output: var T): void =
    fromBytesBEC(input, output)
    return 

  func `^=`*[T: SomeInteger](x: var T, y: T): void =
    x = x xor y
    return 

  func `&=`*[T: SomeInteger](x: var T, y: T): void =
    x = x and y
    return 

  func `|=`*[T: SomeInteger](x: var T, y: T): void =
    x = x or y
    return 

  func `<<`*[T: SomeInteger](x: T, y: T): T =
    x shl y
    return 

  func `>>`*[T: SomeInteger](x: T, y: T): T =
    x shr y
    return 

  func `<<<`*[T: SomeInteger](x: T, y: T): T =
    leftRotateC(x, y)
    return 

  func `>>>`*[T: SomeInteger](x: T, y: T): T =
    rightRotateC(x, y)
    return 

  func `<<<=`*[T: SomeInteger](x: var T, y: T): void =
    x = leftRotateC(x, y)
    return 

  func `>>>=`*[T: SomeInteger](x: var T, y: T): void =
    x = rightRotateC(x, y)
    return 
