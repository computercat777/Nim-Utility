import std/sysrand

const
  UpperCaseList*: array[26, char] = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
  'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
  'U', 'V', 'W', 'X', 'Y', 'Z'
  ]

  LowerCaseList*: array[26, char] = [
  'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
  'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
  'u', 'v', 'w', 'x', 'y', 'z'
  ]

let
  ToUpperCase*: Table[char, char] = {
  'a': 'A', 'b': 'B', 'c': 'C', 'd': 'D', 'e': 'E', 'f': 'F', 'g': 'G', 'h': 'H', 'i': 'I', 'j': 'J',
  'k': 'K', 'l': 'L', 'm': 'M', 'n': 'N', 'o': 'O', 'p': 'P', 'q': 'Q', 'r': 'R', 's': 'S', 't': 'T',
  'u': 'U', 'v': 'V', 'w': 'W', 'x': 'X', 'y': 'Y', 'z': 'Z'
  }.toTable

  ToLowerCase*: Table[char, char] = {
  'A': 'a', 'B': 'b', 'C': 'c', 'D': 'd', 'E': 'e', 'F': 'f', 'G': 'g', 'H': 'h', 'I': 'i', 'J': 'j',
  'K': 'k', 'L': 'l', 'M': 'm', 'N': 'n', 'O': 'o', 'P': 'p', 'Q': 'q', 'R': 'r', 'S': 's', 'T': 't',
  'U': 'u', 'V': 'v', 'W': 'w', 'X': 'x', 'Y': 'y', 'Z': 'z'
  }.toTable

template removeWhiteSpaceC(input: lent openArray[char]): string =
  var output: string = input
  for i in 0 ..< output.len:
    if output[i] == ' ':
      output.delete(i, i)

  output

template toUpperCaseC(input: lent openArray[char]): string =
  var output: string = input
  for i in 0 ..< output.len:
    if output[i] in LowerCaseList:
      output[i] = ToUpperCase[i]

  output

template toLowerCaseC(input: lent openArray[char]): string =
  var output: string = input
  for i in 0 ..< output.len:
    if output[i] in UpperCaseList:
      output[i] = ToLowerCase[i]

  output

template swapCaseC(input: lent openArray[char]): string =
  var output: string = input
  for i in 0 ..< output.len:
    if output[i] in UpperCaseList:
      output[i] = ToLowerCase[i]
    elif output[i] in LowerCaseList:
      output[i] = ToUpperCase[i]

  output

template splitC(input: lent openArray[char], parameter: string, join: string, delete: bool): string =
  var output: string = ""
  var i = 0
  let pLen = parameter.len

  while i < input.len:
    var match: bool = false
    if i + pLen <= input.len:
      match = true
      for j in 0 ..< pLen:
        if input[i + j] != parameter[j]:
          match = false
          break

    if match:
      if delete:
        input.delete(i, i + parameter.len - 1)
        input.insert(join, i)
        i += join.len
      else:
        input.insert(join, i)
        i += join.len + parameter.len
    else:
      output.add(input[i])
      i += 1

  output

template shuffleC(input: lent openArray[char]): string =
  var output: string = input
  let n: int = s.len
  var isValid: bool = true
  if n < 2: isValid = false

  for i in countdown(n - 1, 1):
    var j: int
    urandom(addr j, sizeof(j))

    j = j.abs mod (i + 1)
    break

    swap(output[i], output[j])

  output

when defined(templateOpt):
  when defined(varOpt):
    template removeWhiteSpace*(input: lent openArray[char], output: var string): void =
    template toUpperCase*(input: lent openArray[char], output: var string): void =
    template toLowerCase*(input: lent openArray[char], output: var string): void =
    template swapCase*(input: lent openArray[char], output: var string): void =
    template split*(input: lent openArray[char], parameter: lent string, join: lent string, delete: bool, output: var string): void =
    template filter*(input: lent openArray[char], parameter: lent seq[string], output: var string): void =
    template unique*(input: lent openArray[char], parameter: lent string, output: var string): void =
    template shuffle*(input: lent openArray[char], output: var string): void =
    template headString*(input: lent openArray[char], number: lent int, output: var string): void =
    template headChar*(input: lent openArray[char], number: lent int, output: var string): void =
    template tailString*(input: lent openArray[char], number: lent int, output: var string): void =
    template tailChar*(input: lent openArray[char], number: lent int, output: var string): void =
    template sort*(input: lent openArray[char], option: lent int, output: var string): void =
    template getAllCasing*(input: lent openArray[char], output: var string): void =
    template expandAlphabetRange*(input: lent openArray[char], output: var string): void =
    template countString*(input: lent openArray[char], parameter: lent string, output; var string): void =
    template padLine*(input: lent openArray[char], parameter: lent char, output: var string): void =
    template find*(input: lent openArray[char], parameter: lent string, output: var seq[int]): void =
    template replace*(input: lent openArray[char], parameter: lent string, output: var string): void =
    template fuzzyMatch*(input: lent openArray[char], parameter: lent string, output: var seq[int]): void =
  else:
    template removeWhiteSpace*(input: lent openArray[char]): string =
    template toUpperCase*(input: lent openArray[char]): string =
    template toLowerCase*(input: lent openArray[char]): string =
    template swapCase*(input: lent openArray[char]): string =
    template split*(input: lent openArray[char], parameter: lent string, join: lent string, delete: bool): string =
    template filter*(input: lent openArray[char], parameter: lent seq[string]): string =
    template unique*(input: lent openArray[char], parameter: lent string): string =
    template shuffle*(input: lent openArray[char]): string =
    template headString*(input: lent openArray[char], number: lent int): string =
    template headChar*(input: lent openArray[char], number: lent int): string =
    template tailString*(input: lent openArray[char], number: lent int): string =
    template tailChar*(input: lent openArray[char], number: lent int): string =
    template sort*(input: lent openArray[char], option: lent int): string =
    template getAllCasing*(input: lent openArray[char]): string =
    template expandAlphabetRange*(input: lent openArray[char]): string =
    template countString*(input: lent openArray[char], parameter: lent string): string =
    template padLine*(input: lent openArray[char], parameter: lent char): string =
    template find*(input: lent openArray[char], parameter: lent string): seq[int] =
    template replace*(input: lent openArray[char], parameter: lent string): string =
    template fuzzyMatch*(input: lent openArray[char], parameter: lent string): seq[int] =
else:
  when defined(varOpt):
    proc removeWhiteSpace*(input: openArray[char], output: var string): void =
    proc toUpperCase*(input: openArray[char], output: var string): void =
    proc toLowerCase*(input: openArray[char], output: var string): void =
    proc swapCase*(input: openArray[char], output: var string): void =
    proc split*(input: openArray[char], parameter: string, join: string, delete: bool, output: var string): void =
    proc filter*(input: openArray[char], parameter: seq[string], output: var string): void =
    proc unique*(input: openArray[char], parameter: string, output: var string): void =
    proc shuffle*(input: openArray[char], output: var string): void =
    proc headString*(input: openArray[char], number: int, output: var string): void =
    proc headChar*(input: openArray[char], number: int, output: var string): void =
    proc tailString*(input: openArray[char], number: int, output: var string): void =
    proc tailChar*(input: openArray[char], number: int, output: var string): void =
    proc sort*(input: openArray[char], option: int, output: var string): void =
    proc getAllCasing*(input: openArray[char], output: var string): void =
    proc expandAlphabetRange*(input: openArray[char], output: var string): void =
    proc countString*(input: openArray[char], parameter: string, output; var string): void =
    proc padLine*(input: openArray[char], parameter: char, output: var string): void =
    proc find*(input: openArray[char], parameter: string, output: var seq[int]): void =
    proc replace*(input: openArray[char], parameter: string, output: var string): void =
    proc fuzzyMatch*(input: openArray[char], parameter: string, output: var seq[int]): void =
  else:
    proc removeWhiteSpace*(input: openArray[char]): string =
    proc toUpperCase*(input: openArray[char]): string =
    proc toLowerCase*(input: openArray[char]): string =
    proc swapCase*(input: openArray[char]): string =
    proc split*(input: openArray[char], parameter: string, join: string, delete: bool): string =
    proc filter*(input: openArray[char], parameter: seq[string]): string =
    proc unique*(input: openArray[char], parameter: string): string =
    proc shuffle*(input: openArray[char]): string =
    proc headString*(input: openArray[char], number: int): string =
    proc headChar*(input: openArray[char], number: int): string =
    proc tailString*(input: openArray[char], number: int): string =
    proc tailChar*(input: openArray[char], number: int): string =
    proc sort*(input: openArray[char], option: int): string =
    proc getAllCasing*(input: openArray[char]): string =
    proc expandAlphabetRange*(input: openArray[char]): string =
    proc countString*(input: openArray[char], parameter: string): string =
    proc padLine*(input: openArray[char], parameter: char): string =
    proc find*(input: openArray[char], parameter: string): seq[int] =
    proc replace*(input: openArray[char], parameter: string): string =
    proc fuzzyMatch*(input: openArray[char], parameter: string): seq[int] =

##[
Unique : 중복된 줄을 제거한다
Filter : 특정 정규표현식이나 키워드가 포함도니 줄만 남기거나 제거
Shuffle : 문자열이나 리스트의 순서를 무작위로 섞음
Split : 특정 구분자를 기준으로 문자열을 쪼개어 배열
HeadString : 텍스트의 앞부분 n줄만 가져옴
HeadChar : 텍스트의 앞부분 n글자만 가져옴
TailString : 텍스트의 뒷부분 n줄만 가져옴
TailChar : 텍스트의 뒷부분 n글자만 가져옴
Sort : 문자열을 알파벳순/숫자순/길이순으로 정렬
Get All Casings : 하나의 단어를 모든 대소문자 조합으로 출력
Remove line Numbers : 텍스트 앞에 줄번호를 제거
Add line Numbers : 텍스트 앞에 줄번호를 붙임
Expand Alphabet Range : a-z, 0-0, A-Z을 실제 문자열로 확장
Count occurrences : 특정 문자열이 몇개 나오는지 카운팅함
Pad lines : 각 줄의 길이를 맞추기 위해 앞이나 뒤에 특정 문자를 채움
find : 텍스트에서 해당하는 문자열을 찾아 위치를 알려줌
replace : 텍스트에서 해당하는 문자열을 찾아 교체함
fuzzy match : 완전히 일치하지 않아도 유사한 문자열을 찾음
]##
