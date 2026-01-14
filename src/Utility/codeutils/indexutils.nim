{.experimental: "strictNotNil".}

import errorutils

type
  IndexUtilsError* = enum
    DifferentIndexLength = 0,
    TooBigStarts = 1,
    TooBigEnds = 2

template toArray*[N, T](s: lent seq[T], arr: var array[N, T]): void =
  for i in 0 ..< arr.len:
    arr[i] = s[i]

template convertArray*[N1, T1, N2, T2](input: lent array[N1, T1], output: var array[N2, T2]): Result[void, IndexUtilsError] =
  when (input.len * sizeof(T1)) != (output.len * sizeof(T2)):
    Result[array[N2, T2], IndexUtilsError](kind: Failure, error: DifferentIndexLength)
  else:  
    var pInput: ptr array[N2, T2] = cast[ptr array[N2, T2]](addr input)
    for i in 0 ..< output.len:
      output[i] = pInput[][i]
    Result[array[N2, T2], IndexUtilsError](kind: Success)

template lenConvertArray*[N1, T1, N2, T2](input: lent array[N1, T1], output: var array[N2, T2], starts: int, ends: int): Result[void, IndexUtilsError] =
  if output.len < ends:
    Result[void, IndexUtilsError](kind: Failure, error: TooBigEnds)

  if output.len < starts:
    Result[void, IndexUtilsError](kind: Failure, error: TooBigStarts)
  var pInput: ptr array[N2, T2] = cast[ptr array[N2, T2]](addr input)
  for i in 0 ..< ends - starts:
    output[i] = pInput[][starts + i]
  Result[void, IndexErrorUtils](kind: Success)

template toSeq*[T](input: lent openArray[T], output: var seq[T], starts: int, ends: int): Result[void, IndexUtilsError]  =
  var result: Result[void, IndexUtilsError]
  let length: int = input.len
  if length <= starts:
    result = Result[void, IndexUtilsError](kind: Failure, error: TooBigStarts)
  elif length < ends:
    result = Result[void, IndexUtilsError](kind: Failure, error: TooBigEnds)
  else:
    for i in starts ..< ends:
      output.add(input[i])
    result = Result[void, IndexUtilsError](kind: Success)
  result

template copyArray*[N: static[int], T](input: lent array[N, T], output: var array[N, T]): void =
  for i in static(0 ..< N):
    output[i] = input[i]

template lenCopyArray*[N1, N2, T](input: lent array[N1, T], output: var array[N2, T], starts: int, ends: int): Result[void, IndexUtilsError] =
  var result: Result[void, IndexUtilsError]
  if N1 < ends or N2 < ends:
    result = Result[void, IndexUtilsError](kind: Failure, error: TooBigEnds)
  elif N1 <= starts or N2 <= starts:
    result = Result[void, IndexUtilsError](kind: Failure, error: TooBigStarts)
  else:
    for i in 0 ..< ends - starts:
      output[i] = input[starts + i]
    result = Result[void, IndexUtilsError](kind: Success)
  result
