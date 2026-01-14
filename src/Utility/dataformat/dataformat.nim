{.experimental: "strictNotNil".}

import tables
import ../math/bigint
import ../codeutils/bits
import ../codeutils/indexutils
import strutils
import algorithm
import ../codeutils/errorutils

type
  DataformatError* = enum
    WrongCharacters = 0

const Hex*: array[16, char] = [
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 
  'A', 'B', 'C', 'D', 'E', 'F'
]

const Oct*: array[8, char] = [
  '0', '1', '2', '3', '4', '5', '6', '7'
]

const Base32*: array[32, char] = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
  'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
  'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
  'Y', 'Z', '2', '3', '4', '5', '6', '7']

const Base36*: array[36, char] = [
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
  'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
  'U', 'V', 'W', 'X', 'Y', 'Z'
]

const Base45*: array[45, char] = [
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
  'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
  'U', 'V', 'W', 'X', 'Y', 'Z', ' ', '$', '%', '*',
  '+', '-', '.', '/', ':'
]

const Base56*: array[56, char] = [
  '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 
  'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 
  'N', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 
  'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 
  'i', 'j', 'k', 'm', 'n', 'p', 'q', 'r', 's', 't', 
  'u', 'v', 'w', 'x', 'y', 'z'
]

const Base58*: array[58, char] = [
  '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 
  'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 
  'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 
  'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 
  'h', 'i', 'j', 'k', 'm', 'n', 'o', 'p', 'q', 'r', 
  's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
]

const Base62*: array[62, char] = [
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
  'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
  'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd',
  'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
  'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
  'y', 'z'
]

const Base64*: array[64, char] = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 
  'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 
  'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 
  'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 
  'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 
  'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', 
  '8', '9', '+', '/'
]

const Base85*: array[85, char] = [
  '!', '"', '#', '$', '%', '&', '\'', '(', ')', '*', 
  '+', ',', '-', '.', '/', '0', '1', '2', '3', '4', 
  '5', '6', '7', '8', '9', ':', ';', '<', '=', '>', 
  '?', '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 
  'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 
  'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '[', '\\', 
  ']', '^', '_', '`', 'a', 'b', 'c', 'd', 'e', 'f', 
  'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 
  'q', 'r', 's', 't', 'u'
]

const Base91*: array[91, char] = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
  'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
  'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd',
  'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
  'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
  'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7',
  '8', '9', '!', '#', '$', '%', '&', '(', ')', '*',
  '+', ',', '.', '/', ':', ';', '<', '=', '>', '?',
  '@', '[', ']', '^', '_', '`', '{', '|', '}', '~',
  '"'
]

const Base92*: array[92, char] = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
  'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
  'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd',
  'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
  'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
  'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7',
  '8', '9', '!', '#', '$', '%', '&', '(', ')', '*',
  '+', ',', '-', '.', '/', ':', ';', '<', '=', '>',
  '?', '@', '[', ']', '^', '_', '`', '{', '|', '}',
  '~', '"'
]

let HexMap*: Table[char, uint8]= {
  '0': 0'u8, '1': 1'u8, '2': 2'u8, '3': 3'u8, '4': 4'u8, '5': 5'u8, '6': 6'u8, '7': 7'u8, '8': 8'u8, '9': 9'u8,
  'A': 10'u8, 'B': 11'u8, 'C': 12'u8, 'D': 13'u8, 'E': 14'u8, 'F': 15'u8
}.toTable

let OctMap*: Table[char, uint8] = {
  '0': 0'u8, '1': 1'u8, '2': 2'u8, '3': 3'u8, '4': 4'u8, '5': 5'u8, '6': 6'u8, '7': 7'u8
}.toTable

let Base32Map*: Table[char, uint8] = {
  'A': 0'u8, 'B': 1'u8, 'C': 2'u8, 'D': 3'u8, 'E': 4'u8, 'F': 5'u8, 'G': 6'u8, 'H': 7'u8, 'I': 8'u8, 'J': 9'u8, 
  'K': 10'u8, 'L': 11'u8, 'M': 12'u8, 'N': 13'u8, 'O': 14'u8, 'P': 15'u8, 'Q': 16'u8, 'R': 17'u8, 'S': 18'u8, 'T': 19'u8, 
  'U': 20'u8, 'V': 21'u8, 'W': 22'u8, 'X': 23'u8, 'Y': 24'u8, 'Z': 25'u8, '2': 26'u8, '3': 27'u8, '4': 28'u8, '5': 29'u8, 
  '6': 30'u8, '7': 31'u8
}.toTable

let Base36Map*: Table[char, uint8] = {
  '0': 0'u8,'1': 1'u8, '2': 2'u8, '3': 3'u8, '4': 4'u8, '5': 5'u8, '6': 6'u8, '7': 7'u8, '8': 8'u8, '9': 9'u8,
  'A': 10'u8, 'B': 11'u8, 'C': 12'u8, 'D': 13'u8, 'E': 14'u8, 'F': 15'u8, 'G': 16'u8, 'H': 17'u8, 'I': 18'u8, 'J': 19'u8,
  'K': 20'u8, 'L': 21'u8, 'M': 22'u8, 'N': 23'u8, 'O': 24'u8, 'P': 25'u8, 'Q': 26'u8, 'R': 27'u8, 'S': 28'u8, 'T': 29'u8,
  'U': 30'u8, 'V': 31'u8, 'W': 32'u8, 'X': 33'u8, 'Y': 34'u8, 'Z': 35'u8
}.toTable

let Base45Map*: Table[char, uint8] = {
  '0': 0'u8, '1': 1'u8, '2': 2'u8, '3': 3'u8, '4': 4'u8, '5': 5'u8, '6': 6'u8, '7': 7'u8, '8': 8'u8, '9': 9'u8,
  'A': 10'u8, 'B': 11'u8, 'C': 12'u8, 'D': 13'u8, 'E': 14'u8, 'F': 15'u8, 'G': 16'u8, 'H': 17'u8, 'I': 18'u8, 'J': 19'u8,
  'K': 20'u8, 'L': 21'u8, 'M': 22'u8, 'N': 23'u8, 'O': 24'u8, 'P': 25'u8, 'Q': 26'u8, 'R': 27'u8, 'S': 28'u8, 'T': 29'u8,
  'U': 30'u8, 'V': 31'u8, 'W': 32'u8, 'X': 33'u8, 'Y': 34'u8, 'Z': 35'u8, ' ': 36'u8, '$': 37'u8, '%': 38'u8, '*': 39'u8,
  '+': 40'u8, '-': 41'u8, '.': 42'u8, '/': 43'u8, ':': 44'u8
}.toTable

let Base56Map*: Table[char, uint8] = {
  '2': 0'u8, '3': 1'u8, '4': 2'u8, '5': 3'u8, '6': 4'u8, '7': 5'u8, '8': 6'u8, '9': 7'u8, 'A': 8'u8, 'B': 9'u8, 
  'C': 10'u8, 'D': 11'u8, 'E': 12'u8, 'F': 13'u8, 'G': 14'u8, 'H': 15'u8, 'J': 16'u8, 'K': 17'u8, 'L': 18'u8, 'M': 19'u8, 
  'N': 20'u8, 'P': 21'u8, 'Q': 22'u8, 'R': 23'u8, 'S': 24'u8, 'T': 25'u8, 'U': 26'u8, 'V': 27'u8, 'W': 28'u8, 'X': 29'u8, 
  'Y': 30'u8, 'Z': 31'u8, 'a': 32'u8, 'b': 33'u8, 'c': 34'u8, 'd': 35'u8, 'e': 36'u8, 'f': 37'u8, 'g': 38'u8, 'h': 39'u8, 
  'i': 40'u8, 'j': 41'u8, 'k': 42'u8, 'm': 43'u8, 'n': 44'u8, 'p': 45'u8, 'q': 46'u8, 'r': 47'u8, 's': 48'u8, 't': 49'u8, 
  'u': 50'u8, 'v': 51'u8, 'w': 52'u8, 'x': 53'u8, 'y': 54'u8, 'z': 55'u8
}.toTable

let Base58Map*: Table[char, uint8] = {
  '1': 0'u8, '2': 1'u8, '3': 2'u8, '4': 3'u8, '5': 4'u8, '6': 5'u8, '7': 6'u8, '8': 7'u8, '9': 8'u8, 'A': 9'u8, 
  'B': 10'u8, 'C': 11'u8, 'D': 12'u8, 'E': 13'u8, 'F': 14'u8, 'G': 15'u8, 'H': 16'u8, 'J': 17'u8, 'K': 18'u8, 'L': 19'u8, 
  'M': 20'u8, 'N': 21'u8, 'P': 22'u8, 'Q': 23'u8, 'R': 24'u8, 'S': 25'u8, 'T': 26'u8, 'U': 27'u8, 'V': 28'u8, 'W': 29'u8, 
  'X': 30'u8, 'Y': 31'u8, 'Z': 32'u8, 'a': 33'u8, 'b': 34'u8, 'c': 35'u8, 'd': 36'u8, 'e': 37'u8, 'f': 38'u8, 'g': 39'u8, 
  'h': 40'u8, 'i': 41'u8, 'j': 42'u8, 'k': 43'u8, 'm': 44'u8, 'n': 45'u8, 'o': 46'u8, 'p': 47'u8, 'q': 48'u8, 'r': 49'u8, 
  's': 50'u8, 't': 51'u8, 'u': 52'u8, 'v': 53'u8, 'w': 54'u8, 'x': 55'u8, 'y': 56'u8, 'z': 57'u8
}.toTable

let Base62Map*: Table[char, uint8] = {
  '0': 0'u8, '1': 1'u8, '2': 2'u8, '3': 3'u8, '4': 4'u8, '5': 5'u8, '6': 6'u8, '7': 7'u8, '8': 8'u8, '9': 9'u8,
  'A': 10'u8, 'B': 11'u8, 'C': 12'u8, 'D': 13'u8, 'E': 14'u8, 'F': 15'u8, 'G': 16'u8, 'H': 17'u8, 'I': 18'u8, 'J': 19'u8,
  'K': 20'u8, 'L': 21'u8, 'M': 22'u8, 'N': 23'u8, 'O': 24'u8, 'P': 25'u8, 'Q': 26'u8, 'R': 27'u8, 'S': 28'u8, 'T': 29'u8,
  'U': 30'u8, 'V': 31'u8, 'W': 32'u8, 'X': 33'u8, 'Y': 34'u8, 'Z': 35'u8, 'a': 36'u8, 'b': 37'u8, 'c': 38'u8, 'd': 39'u8,
  'e': 40'u8, 'f': 41'u8, 'g': 42'u8, 'h': 43'u8, 'i': 44'u8, 'j': 45'u8, 'k': 46'u8, 'l': 47'u8, 'm': 48'u8, 'n': 49'u8,
  'o': 50'u8, 'p': 51'u8, 'q': 52'u8, 'r': 53'u8, 's': 54'u8, 't': 55'u8, 'u': 56'u8, 'v': 57'u8, 'w': 58'u8, 'x': 59'u8,
  'y': 60'u8, 'z': 61'u8
}.toTable

let Base64Map*: Table[char, uint8] = {
  'A': 0'u8, 'B': 1'u8, 'C': 2'u8, 'D': 3'u8, 'E': 4'u8, 'F': 5'u8, 'G': 6'u8, 'H': 7'u8, 'I': 8'u8, 'J': 9'u8, 
  'K': 10'u8, 'L': 11'u8, 'M': 12'u8, 'N': 13'u8, 'O': 14'u8, 'P': 15'u8, 'Q': 16'u8, 'R': 17'u8, 'S': 18'u8, 'T': 19'u8, 
  'U': 20'u8, 'V': 21'u8, 'W': 22'u8, 'X': 23'u8, 'Y': 24'u8, 'Z': 25'u8, 'a': 26'u8, 'b': 27'u8, 'c': 28'u8, 'd': 29'u8, 
  'e': 30'u8, 'f': 31'u8, 'g': 32'u8, 'h': 33'u8, 'i': 34'u8, 'j': 35'u8, 'k': 36'u8, 'l': 37'u8, 'm': 38'u8, 'n': 39'u8, 
  'o': 40'u8, 'p': 41'u8, 'q': 42'u8, 'r': 43'u8, 's': 44'u8, 't': 45'u8, 'u': 46'u8, 'v': 47'u8, 'w': 48'u8, 'x': 49'u8, 
  'y': 50'u8, 'z': 51'u8, '0': 52'u8, '1': 53'u8, '2': 54'u8, '3': 55'u8, '4': 56'u8, '5': 57'u8, '6': 58'u8, '7': 59'u8, 
  '8': 60'u8, '9': 61'u8, '+': 62'u8, '/': 63'u8
}.toTable

let Base85Map*: Table[char, uint8] = {
  '!': 0'u8, '"': 1'u8, '#': 2'u8, '$': 3'u8, '%': 4'u8, '&': 5'u8, '\'': 6'u8, '(': 7'u8, ')': 8'u8, '*': 9'u8, 
  '+': 10'u8, ',': 11'u8, '-': 12'u8, '.': 13'u8, '/': 14'u8, '0': 15'u8, '1': 16'u8, '2': 17'u8, '3': 18'u8, '4': 19'u8, 
  '5': 20'u8, '6': 21'u8, '7': 22'u8, '8': 23'u8, '9': 24'u8, ':': 25'u8, ';': 26'u8, '<': 27'u8, '=': 28'u8, '>': 29'u8, 
  '?': 30'u8, '@': 31'u8, 'A': 32'u8, 'B': 33'u8, 'C': 34'u8, 'D': 35'u8, 'E': 36'u8, 'F': 37'u8, 'G': 38'u8, 'H': 39'u8, 
  'I': 40'u8, 'J': 41'u8, 'K': 42'u8, 'L': 43'u8, 'M': 44'u8, 'N': 45'u8, 'O': 46'u8, 'P': 47'u8, 'Q': 48'u8, 'R': 49'u8, 
  'S': 50'u8, 'T': 51'u8, 'U': 52'u8, 'V': 53'u8, 'W': 54'u8, 'X': 55'u8, 'Y': 56'u8, 'Z': 57'u8, '[': 58'u8, '\\': 59'u8, 
  ']': 60'u8, '^': 61'u8, '_': 62'u8, '`': 63'u8, 'a': 64'u8, 'b': 65'u8, 'c': 66'u8, 'd': 67'u8, 'e': 68'u8, 'f': 69'u8, 
  'g': 70'u8, 'h': 71'u8, 'i': 72'u8, 'j': 73'u8, 'k': 74'u8, 'l': 75'u8, 'm': 76'u8, 'n': 77'u8, 'o': 78'u8, 'p': 79'u8, 
  'q': 80'u8, 'r': 81'u8, 's': 82'u8, 't': 83'u8, 'u': 84'u8
}.toTable

let Base91Map*: Table[char, uint8] = {
  'A': 0'u8, 'B': 1'u8, 'C': 2'u8, 'D': 3'u8, 'E': 4'u8, 'F': 5'u8, 'G': 6'u8, 'H': 7'u8, 'I': 8'u8, 'J': 9'u8,
  'K': 10'u8, 'L': 11'u8, 'M': 12'u8, 'N': 13'u8, 'O': 14'u8, 'P': 15'u8, 'Q': 16'u8, 'R': 17'u8, 'S': 18'u8, 'T': 19'u8,
  'U': 20'u8, 'V': 21'u8, 'W': 22'u8, 'X': 23'u8, 'Y': 24'u8, 'Z': 25'u8, 'a': 26'u8, 'b': 27'u8, 'c': 28'u8, 'd': 29'u8,
  'e': 30'u8, 'f': 31'u8, 'g': 32'u8, 'h': 33'u8, 'i': 34'u8, 'j': 35'u8, 'k': 36'u8, 'l': 37'u8, 'm': 38'u8, 'n': 39'u8,
  'o': 40'u8, 'p': 41'u8, 'q': 42'u8, 'r': 43'u8, 's': 44'u8, 't': 45'u8, 'u': 46'u8, 'v': 47'u8, 'w': 48'u8, 'x': 49'u8,
  'y': 50'u8, 'z': 51'u8, '0': 52'u8, '1': 53'u8, '2': 54'u8, '3': 55'u8, '4': 56'u8, '5': 57'u8, '6': 58'u8, '7': 59'u8,
  '8': 60'u8, '9': 61'u8, '!': 62'u8, '#': 63'u8, '$': 64'u8, '%': 65'u8, '&': 66'u8, '(': 67'u8, ')': 68'u8, '*': 69'u8,
  '+': 70'u8, ',': 71'u8, '.': 72'u8, '/': 73'u8, ':': 74'u8, ';': 75'u8, '<': 76'u8, '=': 77'u8, '>': 78'u8, '?': 79'u8,
  '@': 80'u8, '[': 81'u8, ']': 82'u8, '^': 83'u8, '_': 84'u8, '`': 85'u8, '{': 86'u8, '|': 87'u8, '}': 88'u8, '~': 89'u8,
  '"': 90'u8
}.toTable

let Base92Map*: Table[char, uint8] = {
  'A': 0'u8, 'B': 1'u8, 'C': 2'u8, 'D': 3'u8, 'E': 4'u8, 'F': 5'u8, 'G': 6'u8, 'H': 7'u8, 'I': 8'u8, 'J': 9'u8,
  'K': 10'u8, 'L': 11'u8, 'M': 12'u8, 'N': 13'u8, 'O': 14'u8, 'P': 15'u8, 'Q': 16'u8, 'R': 17'u8, 'S': 18'u8, 'T': 19'u8,
  'U': 20'u8, 'V': 21'u8, 'W': 22'u8, 'X': 23'u8, 'Y': 24'u8, 'Z': 25'u8, 'a': 26'u8, 'b': 27'u8, 'c': 28'u8, 'd': 29'u8,
  'e': 30'u8, 'f': 31'u8, 'g': 32'u8, 'h': 33'u8, 'i': 34'u8, 'j': 35'u8, 'k': 36'u8, 'l': 37'u8, 'm': 38'u8, 'n': 39'u8,
  'o': 40'u8, 'p': 41'u8, 'q': 42'u8, 'r': 43'u8, 's': 44'u8, 't': 45'u8, 'u': 46'u8, 'v': 47'u8, 'w': 48'u8, 'x': 49'u8,
  'y': 50'u8, 'z': 51'u8, '0': 52'u8, '1': 53'u8, '2': 54'u8, '3': 55'u8, '4': 56'u8, '5': 57'u8, '6': 58'u8, '7': 59'u8,
  '8': 60'u8, '9': 61'u8, '!': 62'u8, '#': 63'u8, '$': 64'u8, '%': 65'u8, '&': 66'u8, '(': 67'u8, ')': 68'u8, '*': 69'u8,
  '+': 70'u8, ',': 71'u8, '-': 72'u8, '.': 73'u8, '/': 74'u8, ':': 75'u8, ';': 76'u8, '<': 77'u8, '=': 78'u8, '>': 79'u8,
  '?': 80'u8, '@': 81'u8, '[': 82'u8, ']': 83'u8, '^': 84'u8, '_': 85'u8, '`': 86'u8, '{': 87'u8, '|': 88'u8, '}': 89'u8,
  '~': 90'u8, '"': 91'u8
}.toTable

template charToBinC(input: lent openArray[char]): seq[uint8] =
  var output: seq[uint8]
  for c in input:
    output.add(c.uint8)

  output

template hexToBinC(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
  var result: Result[seq[uint8], DataformatError]

  var isValid: bool = true
  for c in input:
    if c notin Hex:
      result = Result[seq[uint8], DataformatError](kind: Failure, error: WrongCharacters)
      isValid = false
      break

  if isValid:
    let outLen: int = (input.len + 1) div 2
    result = Result[seq[uint8], DataformatError](kind: Success, value: newSeq[uint8](outLen))

    let fullPairs = input.len div 2
    for i in 0 ..< fullPairs:
      var hi: uint8 = HexMap[input[2 * i]]
      var lo: uint8 = HexMap[input[2 * i + 1]]
      result.value[i] = (hi shl 4) or lo

    if input.len mod 2 == 1:
      var hi: uint8 = HexMap[input[^1]]
      result.value[^1] = (hi shl 4)

  result

template binToHexC(input: lent openArray[uint8]): string =
  var output: string
  for bytes in input:
    let hi = (bytes shr 4) and 0xF
    let lo = bytes and 0xF
    output.add(char(hi + (if hi < 10: ord('0') else: ord('A') - 10)))
    output.add(char(lo + (if lo < 10: ord('0') else: ord('A') - 10)))

  output

template octToBinC(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
  var result: Result[seq[uint8], DataformatError]

  var isValid: bool = true
  for c in input:
    if c notin Oct:
      result = Result[seq[uint8], DataformatError](kind: Failure, error: WrongCharacters)
      isValid = false
      break

  if isValid:
    let totalBits: int = input.len * 3
    let outLen: int = (totalBits + 7) div 8

    result = Result[seq[uint8], DataformatError](kind: Success, value: newSeq[uint8](outLen))

    var buffer: uint32 = 0'u32
    var bits: int = 0
    var outIdx: int = 0

    for c in input:
      var val: uint8 = OctMap[c]
      buffer = (buffer shl 3) or val.uint32
      bits += 3

      if bits >= 8:
        let shift: int = bits - 8
        result.value[outIdx] = uint8((buffer shr shift) and 0xFF'u32)
        outIdx.inc
        bits = shift
        buffer = buffer and ((1'u32 shl bits) - 1)

    if bits > 0:
      result.value[outIdx] = uint8((buffer shl (8 - bits) and 0xFF'u32))

  result

template binToOctC(input: lent openArray[uint8]): string =
  var output: string
  var buffer = 0'u32
  var bits = 0

  for bytes in input:
    buffer = (buffer shl 8) or bytes.uint32
    bits += 8

    while bits >= 3:
      let index = (buffer shr (bits - 3)) and 0x07
      output.add(Oct[index])
      bits -= 3

    buffer = buffer and ((1'u32 shl bits) - 1)

  if bits > 0:
    let index = (buffer shl (3 - bits)) and 0x07
    output.add(Oct[index])
  output

template base32ToBinC(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
  var result: Result[seq[uint8], DataformatError]

  var isValid: bool = true
  for c in input:
    if c notin Base32:
      result = Result[seq[uint8], DataformatError](kind: Failure, error: WrongCharacters)
      isValid = false
      break

  if isValid:
    let totalBits: int = input.len * 5
    let outLen: int = (totalBits + 7) div 8

    result = Result[seq[uint8], DataformatError](kind: Success, value: newSeq[uint8](outLen))

    var buffer: uint32 = 0'u32
    var bits: int = 0
    var outIdx: int = 0

    for c in input:
      let val: uint8 = Base32Map[c]
      buffer = (buffer shl 5) or val.uint32
      bits += 5

      if bits >= 8:
        let shift: int = bits - 8

        result.value[outIdx] = uint8((buffer shr shift) and 0xFF'u32)
        outIdx.inc
        bits = shift

        buffer = buffer and ((1'u32 shl bits) - 1)

    if bits > 0:
      result.value[outIdx] = uint8((buffer shl (8 - bits) and 0xFF'u32))

  result

template binToBase32C(input: lent openArray[uint8]): string =
  var output: string
  var buffer = 0'u32
  var bits = 0

  for bytes in input:
    buffer = (buffer shl 8) or bytes.uint32
    bits += 8

    while bits >= 5:
      let index = (buffer shr (bits - 5)) and 0x1F
      output.add(Base32[index])
      bits -= 5

    buffer = buffer and ((1'u32 shl bits) - 1)

  if bits > 0:
    let index = (buffer shl (5 - bits)) and 0x1F
    output.add(Base32[index])

  output

template base64ToBinC(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
  var result: Result[seq[uint8], DataformatError]

  var isValid: bool = true
  for c in input:
    if c notin Base64:
      result = Result[seq[uint8], DataformatError](kind: Failure, error: WrongCharacters)
      isValid = false
      break

  if isValid:
    let totalBits: int = input.len * 6
    let outLen = (totalBits + 7) div 8

    result = Result[seq[uint8], DataformatError](kind: Success, value: newSeq[uint8](outLen))

    var buffer: uint32 = 0'u32
    var bits: int = 0
    var outIdx: int = 0

    for c in input:
      var val: uint8 = Base64Map[c]
      buffer = (buffer shl 6) or val.uint32
      bits += 6

      if bits >= 8:
        let shift: int = bits - 8
        result.value[outIdx] = uint8((buffer shr shift) and 0xFF'u32)
        outIdx.inc
        bits = shift
        buffer = buffer and ((1'u32 shl bits) - 1)

    if bits > 0:
      result.value[outIdx] = uint8((buffer shl (8 - bits) and 0xFF'u32))

  result

template binToBase64C(input: lent openArray[uint8]): string =
  var output: string
  var bitBuffer: uint32 = 0
  var bitCount = 0

  for bytes in input:
    bitBuffer = (bitBuffer shl 8) or uint32(bytes)
    bitCount += 8

    while bitCount >= 6:
      let index = (bitBuffer shr (bitCount - 6)) and 0x3F
      output.add(Base64[index])
      bitCount -= 6

  if bitCount > 0:
    let index = (bitBuffer shl (6 - bitCount)) and 0x3F
    output.add(Base64[index])

  output

template base36ToBinC(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
  var result: Result[seq[uint8], DataformatError]
  var temp: BigInt = initBigInt(0'u32)
  let constant: BigInt = initBigInt(36'u32)
  
  var isValid: bool = true
  for c in input:
    if c notin Base36:
      result = Result[seq[uint8], DataformatError](kind: Failure, error: WrongCharacters)
      isValid = false
      break
    var cBigInt: BigInt = initBigInt(uint32(Base36Map[c]))
    temp = temp * constant + cBigInt

  if isValid:
    let totalBytes: int = temp.limbs.len * 4
    result = Result[seq[uint8], DataformatError](kind: Success, value: newSeq[uint8](totalBytes))
    for i in 0 ..< temp.limbs.len:
      var limb: uint32 = temp.limbs[i]
      let baseIdx: int = (temp.limbs.len - 1 - i) * 4
      result.value[baseIdx + 0] = uint8((limb shr 24) and 0xFF'u32)
      result.value[baseIdx + 1] = uint8((limb shr 16) and 0xFF'u32)
      result.value[baseIdx + 2] = uint8((limb shr 8) and 0xFF'u32)
      result.value[baseIdx + 3] = uint8(limb and 0xFF'u32)

  result

template binToBase36C(input: lent openArray[uint8]): string =
  var output: string
  var zero: BigInt = initBigInt(0'u32)
  var temp: BigInt = zero
  let byteMax: BigInt = initBigInt(256'u32)
  let constant: BigInt = initBigInt(36'u32)
  let wordMax: BigInt = initBigInt(1'u64 shl 32)

  var i = 0
  while i <= input.len - 4:
    var chunk = (input[i].uint32 shl 24) or
    (input[i + 1].uint32 shl 16) or
    (input[i + 2].uint32 shl 8) or
    input[i + 3].uint32
    temp = temp * wordMax + initBigInt(chunk)
    i += 4

  while i < input.len:
    temp = temp * byteMax + initBigInt(input[i].uint32)
    i.inc

  if temp == zero:
    output = "0"
  else:
    while temp > zero:
      let (q, r) = divmod(temp, constant)
      output.add(Base36[toInt(r)])
      temp = q

    reverse(output)

  output

template base45ToBinC(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
  var result: Result[seq[uint8], DataformatError]
  var temp: BigInt = initBigInt(0'u32)
  let constant: BigInt = initBigInt(45'u32)

  var isValid: bool = true
  for c in input:
    if c notin Base45:
      result = Result[seq[uint8], DataformatError](kind: Failure, error: WrongCharacters)
      isValid = false
      break
    var cBigInt: BigInt = initBigInt(uint32(Base45Map[c]))
    temp = temp * constant + cBigInt

  if isValid:
    let totalBytes: int = temp.limbs.len * 4
    result = Result[seq[uint8], DataformatError](kind: Success, value: newSeq[uint8](totalBytes))
    for i in 0 ..< temp.limbs.len:
      var limb: uint32 = temp.limbs[i]
      let baseIdx: int = (temp.limbs.len - 1 - i) * 4
      result.value[baseIdx + 0] = uint8((limb shr 24) and 0xFF'u32)
      result.value[baseIdx + 1] = uint8((limb shr 16) and 0xFF'u32)
      result.value[baseIdx + 2] = uint8((limb shr 8) and 0xFF'u32)
      result.value[baseIdx + 3] = uint8(limb and 0xFF'u32)

  result

template binToBase45C(input: openArray[uint8]): string =
  var output: string
  var zero: BigInt = initBigInt(0'u32)
  var temp: BigInt = zero
  let wordMax: BigInt = initBigInt(1'u64 shl 32)
  let constant: BigInt = initBigInt(45'u32)
  let byteMax: BigInt = initBigInt(256'u32)

  var i = 0
  while i <= input.len - 4:
    var chunk = (input[i].uint32 shl 24) or
    (input[i + 1].uint32 shl 16) or
    (input[i + 2].uint32 shl 8) or
    input[i + 3].uint32
    temp = temp * wordMax + initBigInt(chunk)
    i += 4

  while i < input.len:
    temp = temp * byteMax + initBigInt(input[i].uint32)
    i.inc

  if temp == zero:
    output = "0"
  else:
    while temp > zero:
      let (q, r) = divmod(temp, constant)
      output.add(Base45[toInt(r)])
      temp = q

    reverse(output)

  output

template base56ToBinC(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
  var result: Result[seq[uint8], DataformatError]
  var temp: BigInt = initBigInt(0'u32)
  let constant: BigInt = initBigInt(56'u32)

  var isValid: bool = true
  for c in input:
    if c notin Base56:
      result = Result[seq[uint8], DataformatError](kind: Failure, error: WrongCharacters)
      isValid = false
      break
    var cBigInt: BigInt = initBigInt(uint32(Base56Map[c]))
    temp = temp * constant + cBigInt

  if isValid:
    let totalBytes: int = temp.limbs.len * 4
    result = Result[seq[uint8], DataformatError](kind: Success, value: newSeq[uint8](totalBytes))
    for i in 0 ..< temp.limbs.len:
      var limb: uint32 = temp.limbs[i]
      let baseIdx: int = (temp.limbs.len - 1 - i) * 4
      result.value[baseIdx + 0] = uint8((limb shr 24) and 0xFF'u32)
      result.value[baseIdx + 1] = uint8((limb shr 16) and 0xFF'u32)
      result.value[baseIdx + 2] = uint8((limb shr 8) and 0xFF'u32)
      result.value[baseIdx + 3] = uint8(limb and 0xFF'u32)

  result

template binToBase56C(input: lent openArray[uint8]): string =
  var output: string
  var zero: BigInt = initBigInt(0'u32)
  var temp: BigInt = zero
  let byteMax: BigInt = initBigInt(256'u32)
  let constant: BigInt = initBigInt(56'u32)
  let wordMax: BigInt = initBigInt(1'u64 shl 32)

  var i = 0
  while i <= input.len - 4:
    var chunk = (input[i].uint32 shl 24) or
    (input[i + 1].uint32 shl 16) or
    (input[i + 2].uint32 shl 8) or
    input[i + 3].uint32
    temp = temp * wordMax + initBigInt(chunk)
    i += 4

  while i < input.len:
    temp = temp * byteMax + initBigInt(input[i].uint32)
    i.inc

  if temp == zero:
    output = "0"
  else:
    while temp > zero:
      let (q, r) = divmod(temp, constant)
      output.add(Base56[toInt(r)])
      temp = q

    reverse(output)

  output

template base58ToBinC(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
  var result: Result[seq[uint8], DataformatError]
  var temp: BigInt = initBigInt(0'u32)
  let constant: BigInt = initBigInt(58'u32)

  var isValid: bool = true
  for c in input:
    if c notin Base58:
      result = Result[seq[uint8], DataformatError](kind: Failure, error: WrongCharacters)
      isValid = false
      break
    var cBigInt: BigInt = initBigInt(uint32(Base58Map[c]))
    temp = temp * constant + cBigInt

  if isValid:
    let totalBytes: int = temp.limbs.len * 4
    result = Result[seq[uint8], DataformatError](kind: Success, value: newSeq[uint8](totalBytes))
    for i in 0 ..< temp.limbs.len:
      var limb: uint32 = temp.limbs[i]
      let baseIdx: int = (temp.limbs.len - 1 - i) * 4
      result.value[baseIdx + 0] = uint8((limb shr 24) and 0xFF'u32)
      result.value[baseIdx + 1] = uint8((limb shr 16) and 0xFF'u32)
      result.value[baseIdx + 2] = uint8((limb shr 8) and 0xFF'u32)
      result.value[baseIdx + 3] = uint8(limb and 0xFF'u32)

  result

template binToBase58C(input: lent openArray[uint8]): string =
  var output: string
  var zero: BigInt = initBigInt(0'u32)
  var temp: BigInt = zero
  let byteMax: BigInt = initBigInt(256'u32)
  let constant: BigInt = initBigInt(58'u32)
  let wordMax: BigInt = initBigInt(1'u64 shl 32)

  var i = 0
  while i <= input.len - 4:
    var chunk = (input[i].uint32 shl 24) or
    (input[i + 1].uint32 shl 16) or
    (input[i + 2].uint32 shl 8) or
    input[i + 3].uint32
    temp = temp * wordMax + initBigInt(chunk)
    i += 4

  while i < input.len:
    temp = temp * byteMax + initBigInt(input[i].uint32)
    i.inc

  if temp == zero:
    output = "0"
  else:
    while temp > zero:
      let (q, r) = divmod(temp, constant)
      output.add(Base58[toInt(r)])
      temp = q

    reverse(output)

  output

template base62ToBinC(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
  var result: Result[seq[uint8], DataformatError]
  var temp: BigInt = initBigInt(0'u32)
  let constant: BigInt = initBigInt(62'u32)

  var isValid: bool = true
  for c in input:
    if c notin Base62:
      result = Result[seq[uint8], DataformatError](kind: Failure, error: WrongCharacters)
      isValid = false
      break
    var cBigInt: BigInt = initBigInt(uint32(Base62Map[c]))
    temp = temp * constant + cBigInt

  if isValid:
    let totalBytes: int = temp.limbs.len * 4
    result = Result[seq[uint8], DataformatError](kind: Success, value: newSeq[uint8](totalBytes))
    for i in 0 ..< temp.limbs.len:
      var limb: uint32 = temp.limbs[i]
      let baseIdx: int = (temp.limbs.len - 1 - i) * 4
      result.value[baseIdx + 0] = uint8((limb shr 24) and 0xFF'u32)
      result.value[baseIdx + 1] = uint8((limb shr 16) and 0xFF'u32)
      result.value[baseIdx + 2] = uint8((limb shr 8) and 0xFF'u32)
      result.value[baseIdx + 3] = uint8(limb and 0xFF'u32)

  result

template binToBase62C(input: lent openArray[uint8]): string =
  var output: string
  var zero: BigInt = initBigInt(0'u32)
  var temp: BigInt = zero
  let byteMax: BigInt = initBigInt(256'u32)
  let constant: BigInt = initBigInt(62'u32)
  let wordMax: BigInt = initBigInt(1'u64 shl 32)

  var i = 0
  while i <= input.len - 4:
    var chunk = (input[i].uint32 shl 24) or
    (input[i + 1].uint32 shl 16) or
    (input[i + 2].uint32 shl 8) or
    input[i + 3].uint32
    temp = temp * wordMax + initBigInt(chunk)
    i += 4

  while i < input.len:
    temp = temp * byteMax + initBigInt(input[i].uint32)
    i.inc

  if temp == zero:
    output = "0"
  else:
    while temp > zero:
      let (q, r) = divmod(temp, constant)
      output.add(Base62[toInt(r)])
      temp = q

    reverse(output)

  output

template base85ToBinC(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
  var result: Result[seq[uint8], DataformatError]
  var temp: BigInt = initBigInt(0'u32)
  let constant: BigInt = initBigInt(85'u32)

  var isValid: bool = true
  for c in input:
    if c notin Base85:
      result = Result[seq[uint8], DataformatError](kind: Failure, error: WrongCharacters)
      isValid = false
      break
    var cBigInt: BigInt = initBigInt(uint32(Base85Map[c]))
    temp = temp * constant + cBigInt

  if isValid:
    let totalBytes: int = temp.limbs.len * 4
    result = Result[seq[uint8], DataformatError](kind: Success, value: newSeq[uint8](totalBytes))
    for i in 0 ..< temp.limbs.len:
      var limb: uint32 = temp.limbs[i]
      let baseIdx: int = (temp.limbs.len - 1 - i) * 4
      result.value[baseIdx + 0] = uint8((limb shr 24) and 0xFF'u32)
      result.value[baseIdx + 1] = uint8((limb shr 16) and 0xFF'u32)
      result.value[baseIdx + 2] = uint8((limb shr 8) and 0xFF'u32)
      result.value[baseIdx + 3] = uint8(limb and 0xFF'u32)

  result

template binToBase85C(input: lent openArray[uint8]): string =
  var output: string
  var zero: BigInt = initBigInt(0'u32)
  var temp: BigInt = zero
  let byteMax: BigInt = initBigInt(256'u32)
  let constant: BigInt = initBigInt(85'u32)
  let wordMax: BigInt = initBigInt(1'u64 shl 32)

  var i = 0
  while i <= input.len - 4:
    var chunk = (input[i].uint32 shl 24) or
    (input[i + 1].uint32 shl 16) or
    (input[i + 2].uint32 shl 8) or
    input[i + 3].uint32
    temp = temp * wordMax + initBigInt(chunk)
    i += 4

  while i < input.len:
    temp = temp * byteMax + initBigInt(input[i].uint32)
    i.inc

  if temp == zero:
    output = "0"
  else:
    while temp > zero:
      let (q, r) = divmod(temp, constant)
      output.add(Base85[toInt(r)])
      temp = q

    reverse(output)

  output

template base91ToBinC(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
  var result: Result[seq[uint8], DataformatError]
  var temp: BigInt = initBigInt(0'u32)
  let constant: BigInt = initBigInt(91'u32)

  var isValid: bool = true
  for c in input:
    if c notin Base91:
      result = Result[seq[uint8], DataformatError](kind: Failure, error: WrongCharacters)
      isValid = false
      break
    var cBigInt: BigInt = initBigInt(uint32(Base91Map[c]))
    temp = temp * constant + cBigInt

  if isValid:
    let totalBytes: int = temp.limbs.len * 4
    result = Result[seq[uint8], DataformatError](kind: Success, value: newSeq[uint8](totalBytes))
    for i in 0 ..< temp.limbs.len:
      var limb: uint32 = temp.limbs[i]
      let baseIdx: int = (temp.limbs.len - 1 - i) * 4
      result.value[baseIdx + 0] = uint8((limb shr 24) and 0xFF'u32)
      result.value[baseIdx + 1] = uint8((limb shr 16) and 0xFF'u32)
      result.value[baseIdx + 2] = uint8((limb shr 8) and 0xFF'u32)
      result.value[baseIdx + 3] = uint8(limb and 0xFF'u32)

  result

template binToBase91C(input: lent openArray[uint8]): string =
  var output: string
  var zero: BigInt = initBigInt(0'u32)
  var temp: BigInt = zero
  let byteMax: BigInt = initBigInt(256'u32)
  let constant: BigInt = initBigInt(91'u32)
  let wordMax: BigInt = initBigInt(1'u64 shl 32)

  var i = 0
  while i <= input.len - 4:
    var chunk = (input[i].uint32 shl 24) or
    (input[i + 1].uint32 shl 16) or
    (input[i + 2].uint32 shl 8) or
    input[i + 3].uint32
    temp = temp * wordMax + initBigInt(chunk)
    i += 4

  while i < input.len:
    temp = temp * byteMax + initBigInt(input[i].uint32)
    i.inc

  if temp == zero:
    output = "0"
  else:
    while temp > zero:
      let (q, r) = divmod(temp, constant)
      output.add(Base91[toInt(r)])
      temp = q

    reverse(output)

  output

template base92ToBinC(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
  var result: Result[seq[uint8], DataformatError]
  var temp: BigInt = initBigInt(0'u32)
  let constant: BigInt = initBigInt(92'u32)

  var isValid: bool = true
  for c in input:
    if c notin Base92:
      result = Result[seq[uint8], DataformatError](kind: Failure, error: WrongCharacters)
      isValid = false
      break
    var cBigInt: BigInt = initBigInt(uint32(Base92Map[c]))
    temp = temp * constant + cBigInt

  if isValid:
    let totalBytes: int = temp.limbs.len * 4
    result = Result[seq[uint8], DataformatError](kind: Success, value: newSeq[uint8](totalBytes))
    for i in 0 ..< temp.limbs.len:
      var limb: uint32 = temp.limbs[i]
      let baseIdx: int = (temp.limbs.len - 1 - i) * 4
      result.value[baseIdx + 0] = uint8((limb shr 24) and 0xFF'u32)
      result.value[baseIdx + 1] = uint8((limb shr 16) and 0xFF'u32)
      result.value[baseIdx + 2] = uint8((limb shr 8) and 0xFF'u32)
      result.value[baseIdx + 3] = uint8(limb and 0xFF'u32)

  result

template binToBase92C(input: lent openArray[uint8]): string =
  var output: string
  var zero: BigInt = initBigInt(0'u32)
  var temp: BigInt = zero
  let byteMax: BigInt = initBigInt(256'u32)
  let constant: BigInt = initBigInt(92'u32)
  let wordMax: BigInt = initBigInt(1'u64 shl 32)

  var i = 0
  while i <= input.len - 4:
    var chunk = (input[i].uint32 shl 24) or
    (input[i + 1].uint32 shl 16) or
    (input[i + 2].uint32 shl 8) or
    input[i + 3].uint32
    temp = temp * wordMax + initBigInt(chunk)
    i += 4

  while i < input.len:
    temp = temp * byteMax + initBigInt(input[i].uint32)
    i.inc

  if temp == zero:
    output = "0"
  else:
    while temp > zero:
      let (q, r) = divmod(temp, constant)
      output.add(Base92[toInt(r)])
      temp = q

    reverse(output)

  output

when defined(templateOpt):
  when defined(varOpt):
    template charToBin*(input: lent openArray[char], output: var seq[uint8]): void =
      output = charToBinC(input)
    template hexToBin*(input: lent openArray[char], output: var seq[uint8]): void =
      var result: Result[void, DataformatError]
      var temp: Result[seq[uint8], DataformatError] = hexToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
      of Failure:
        result.kind = Failure
        result.error = temp.error
      result
    template binToHex*(input: lent openArray[uint8], output: var string): void =
      output = binToHexC(input)
    template octToBin*(input: lent openArray[char], output: var seq[uint8]): void =
      var result: Result[void, DataformatError]
      var temp: Result[seq[uint8], DataformatError] = octToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
      of Failure:
        result.kind = Failure
        result.error = temp.error
      result
    template binToOct*(input: lent openArray[uint8], output: var string): void =
      output = binToOctC(input)
    template base32ToBin*(input: lent openArray[char], output: var seq[uint8]): void =
      var result: Result[void, DataformatError]
      var temp: Result[seq[uint8], DataformatError] = base32ToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
      of Failure:
        result.kind = Failure
        result.error = temp.error
      result
    template binToBase32*(input: lent openArray[uint8], output: var string): void = 
      output = binToBase32C(input) 
    template base64ToBin*(input: lent openArray[char], output: var seq[uint8]): void =
      var result: Result[void, DataformatError]
      var temp: Result[seq[uint8], DataformatError] = base64ToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
      of Failure:
        result.kind = Failure
        result.error = temp.error
      result
    template binToBase64*(input: lent openArray[uint8], output: var string): void = 
      output = binToBase64C(input)
    template base36ToBin*(input: lent openArray[char], output: var seq[uint8]): Result[void, DataformatError] =
      var result: Result[void, DataformatError]
      var temp: Result[seq[uint8], DataformatError] = base36ToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
      of Failure:
        result.kind = Failure
        result.error = temp.error
      result
    template binToBase36*(input: lent openArray[uint8], output: var string): void =
      output = binToBase36C(input)
    template base45ToBin*(input: lent openArray[char], output: var seq[uint8]): Result[void, DataformatError] =
      var result: Result[void, DataformatError]
      var temp: Result[seq[uint8], DataformatError] = base45ToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
      of Failure:
        result.kind = Failure
        result.error = temp.error
      result
    template binToBase45*(input: lent openArray[uint8], output: var string): void =
      output = binToBase45C(input)
    template base56ToBin*(input: lent openArray[char], output: var seq[uint8]): Result[void, DataformatError] =
      var result: Result[void, DataformatError]
      var temp: Result[seq[uint8], DataformatError] = base56ToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
      of Failure:
        result.kind = Failure
        result.error = temp.error
      result
    template binToBase56*(input: lent openArray[uint8], output: var string): void =
      output = binToBase56C(input)
    template base58ToBin*(input: lent openArray[char], output: var seq[uint8]): Result[void, DataformatError] =
      var result: Result[void, DataformatError]
      var temp: Result[seq[uint8], DataformatError] = base58ToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
      of Failure:
        result.kind = Failure
        result.error = temp.error
      result
    template binToBase58*(input: lent openArray[uint8], output: var string): void =
      output = binToBase58C(input)
    template base62ToBin*(input: lent openArray[char], output: var seq[uint8]): Result[void, DataformatError] =
      var result: Result[void, DataformatError]
      var temp: Result[seq[uint8], DataformatError] = base62ToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
      of Failure:
        result.kind = Failure
        result.error = temp.error
      result
    template binToBase62*(input: lent openArray[uint8], output: var string): void =
      output = binToBase62C(input)
    template base85ToBin*(input: lent openArray[char], output: var seq[uint8]): Result[void, DataformatError] =
      var result: Result[void, DataformatError]
      var temp: Result[seq[uint8], DataformatError] = base85ToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
      of Failure:
        result.kind = Failure
        result.error = temp.error
      result
    template binToBase85*(input: lent openArray[uint8], output: var string): void =
      output = binToBase85C(input)
    template base91ToBin*(input: lent openArray[char], output: var seq[uint8]): Result[void, DataformatError] =
      var result: Result[void, DataformatError]
      var temp: Result[seq[uint8], DataformatError] = base91ToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
      of Failure:
        result.kind = Failure
        result.error = temp.error
      result
    template binToBase91*(input: lent openArray[uint8], output: var string): void =
      output = binToBase91C(input)
    template base92ToBin*(input: lent openArray[char], output: var seq[uint8]): Result[void, DataformatError] =
      var result: Result[void, DataformatError]
      var temp: Result[seq[uint8], DataformatError] = base92ToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
      of Failure:
        result.kind = Failure
        result.error = temp.error
      result
    template binToBase92*(input: lent openArray[uint8], output: var string): void =
      output = binToBase92C(input)
  else:
    template charToBin*(input: lent openArray[char]): seq[uint8] =
      charToBinC(input)
    template hexTobBin*(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
      var result: Result[seq[uint8], DataformatError] = hexToBinC(input)
      result
    template binToHex*(input: lent openArray[uint8]): string =
      var result: string = binToHexC(input)
      result
    template octToBin*(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
      var result: Result[seq[uint8], DataformatError] = octToBinC(input)
      result
    template binToOct*(input: lent openArray[uint8]): string =
      var result: string = binToOctC(input)
      result
    template base32ToBin*(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
      var result: Result[seq[uint8], DataformatError] = base32ToBinC(input)
      result 
    template binToBase32*(input: lent openArray[uint8]): string = 
      var result: string = binToBase32C(input) 
      result 
    template base64ToBin*(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
      var result: Result[seq[uint8], DataformatError] = base64ToBinC(input)
      result 
    template binToBase64*(input: lent openArray[uint8]): string = 
      var result: string = binToBase64C(input) 
      result
    template base36ToBin*(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
      var result: Result[seq[uint8], DataformatError] = base36ToBinC(input)
      result
    template binToBase36*(input: lent openArray[uint8]): string =
      var result: string = binToBase36C(input)
      result
    template base45ToBin*(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
      var result: Result[seq[uint8], DataformatError] = base45ToBinC(input)
      result
    template binToBase45*(input: lent openArray[uint8]): string =
      var result: string = binToBase45C(input)
      result
    template base56ToBin*(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
      var result: Result[seq[uint8], DataformatError] = base56ToBinC(input)
      result
    template binToBase56*(input: lent openArray[uint8]): string =
      var result: string = binToBase56C(input)
      result
    template base58ToBin*(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
      var result: Result[seq[uint8], DataformatError] = base58ToBinC(input)
      result
    template binToBase58*(input: lent openArray[uint8]): string =
      var result: string = binToBase58C(input)
      result
    template base62ToBin*(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
      var result: Result[seq[uint8], DataformatError] = base62ToBinC(input)
      result
    template binToBase62*(input: lent openArray[uint8]): string =
      var result: string = binToBase62C(input)
      result
    template base85ToBin*(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
      var result: Result[seq[uint8], DataformatError] = base85ToBinC(input)
      result
    template binToBase85*(input: lent openArray[uint8]): string =
      var result: string = binToBase85C(input)
      result
    template base91ToBin*(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
      var result: Result[seq[uint8], DataformatError] = base91ToBinC(input)
      result
    template binToBase91*(input: lent openArray[uint8]): string =
      var result: string = binToBase91C(input)
      result
    template base92ToBin*(input: lent openArray[char]): Result[seq[uint8], DataformatError] =
      var result: Result[seq[uint8], DataformatError] = base92ToBinC(input)
      result
    template binToBase92*(input: lent openArray[uint8]): string =
      var result: string = binToBase92C(input)
      result
else:
  when defined(varOpt):
    proc charToBin*(input: openArray[char], output: var seq[uint8]): void =
      output = charToBinC(input)
    proc hexToBin*(input: openArray[char], output: var seq[uint8]): Result[void, DataformatError] =
      var temp = hexToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
        return Result[void, DataformatError](kind: Success)
      of Failure:
        return Result[void, DataformatError](kind: Failure, error: temp.error)
    proc binToHex*(input: openArray[uint8], output: var string) =
      output = binToHexC(input)
    proc octToBin*(input: openArray[char], output: var seq[uint8]): Result[void, DataformatError] =
      var temp = octToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
        return Result[void, DataformatError](kind: Success)
      of Failure:
        return Result[void, DataformatError](kind: Failure, error: temp.error)
    proc binToOct*(input: openArray[uint8], output: var string) =
      output = binToOctC(input)
    proc base32ToBin*(input: openArray[char], output: var seq[uint8]): Result[void, DataformatError] =
      var temp = base32ToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
        return Result[void, DataformatError](kind: Success)
      of Failure:
        return Result[void, DataformatError](kind: Failure, error: temp.error)
    proc binToBase32*(input: openArray[uint8], output: var string) =
      output = binToBase32C(input)
    proc base64ToBin*(input: openArray[char], output: var seq[uint8]): Result[void, DataformatError] =
      var temp = base64ToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
        return Result[void, DataformatError](kind: Success)
      of Failure:
        return Result[void, DataformatError](kind: Failure, error: temp.error)
    proc binToBase64*(input: openArray[uint8], output: var string) =
      output = binToBase64C(input)
    proc base36ToBin*(input: openArray[char], output: var seq[uint8]): Result[void, DataformatError] =
      var temp = base36ToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
        return Result[void, DataformatError](kind: Success)
      of Failure:
        return Result[void, DataformatError](kind: Failure, error: temp.error)
    proc binToBase36*(input: openArray[uint8], output: var string) =
      output = binToBase36C(input)
    proc base45ToBin*(input: openArray[char], output: var seq[uint8]): Result[void, DataformatError] =
      var temp = base45ToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
        return Result[void, DataformatError](kind: Success)
      of Failure:
        return Result[void, DataformatError](kind: Failure, error: temp.error)
    proc binToBase45*(input: openArray[uint8], output: var string) =
      output = binToBase45C(input)
    proc base56ToBin*(input: openArray[char], output: var seq[uint8]): Result[void, DataformatError] =
      var temp = base56ToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
        return Result[void, DataformatError](kind: Success)
      of Failure:
        return Result[void, DataformatError](kind: Failure, error: temp.error)
    proc binToBase56*(input: openArray[uint8], output: var string) =
      output = binToBase56C(input)
    proc base58ToBin*(input: openArray[char], output: var seq[uint8]): Result[void, DataformatError] =
      var temp = base58ToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
        return Result[void, DataformatError](kind: Success)
      of Failure:
        return Result[void, DataformatError](kind: Failure, error: temp.error)
    proc binToBase58*(input: openArray[uint8], output: var string) =
      output = binToBase58C(input)
    proc base62ToBin*(input: openArray[char], output: var seq[uint8]): Result[void, DataformatError] =
      var temp = base62ToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
        return Result[void, DataformatError](kind: Success)
      of Failure:
        return Result[void, DataformatError](kind: Failure, error: temp.error)
    proc binToBase62*(input: openArray[uint8], output: var string) =
      output = binToBase62C(input)
    proc base85ToBin*(input: openArray[char], output: var seq[uint8]): Result[void, DataformatError] =
      var temp = base85ToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
        return Result[void, DataformatError](kind: Success)
      of Failure:
        return Result[void, DataformatError](kind: Failure, error: temp.error)
    proc binToBase85*(input: openArray[uint8], output: var string) =
      output = binToBase85C(input)
    proc base91ToBin*(input: openArray[char], output: var seq[uint8]): Result[void, DataformatError] =
      var temp = base91ToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
        return Result[void, DataformatError](kind: Success)
      of Failure:
        return Result[void, DataformatError](kind: Failure, error: temp.error)
    proc binToBase91*(input: openArray[uint8], output: var string) =
      output = binToBase91C(input)
    proc base92ToBin*(input: openArray[char], output: var seq[uint8]): Result[void, DataformatError] =
      var temp = base92ToBinC(input)
      case temp.kind
      of Success:
        output = temp.value
        return Result[void, DataformatError](kind: Success)
      of Failure:
        return Result[void, DataformatError](kind: Failure, error: temp.error)
    proc binToBase92*(input: openArray[uint8], output: var string) =
      output = binToBase92C(input)
  else:
    proc charToBin*(input: openArray[char]): seq[uint8] =
      return charToBinC(input)
    proc hexToBin*(input: openArray[char]): Result[seq[uint8], DataformatError] =
      return hexToBinC(input)
    proc binToHex*(input: openArray[uint8]): string =
      return binToHexC(input)
    proc octToBin*(input: openArray[char]): Result[seq[uint8], DataformatError] =
      return octToBinC(input)
    proc binToOct*(input: openArray[uint8]): string =
      return binToOctC(input)
    proc base32ToBin*(input: openArray[char]): Result[seq[uint8], DataformatError] =
      return base32ToBinC(input)
    proc binToBase32*(input: openArray[uint8]): string =
      return binToBase32C(input)
    proc base64ToBin*(input: openArray[char]): Result[seq[uint8], DataformatError] =
      return base64ToBinC(input)
    proc binToBase64*(input: openArray[uint8]): string =
      return binToBase64C(input)
    proc base36ToBin*(input: openArray[char]): Result[seq[uint8], DataformatError] =
      return base36ToBinC(input)
    proc binToBase36*(input: openArray[uint8]): string =
      return binToBase36C(input)
    proc base45ToBin*(input: openArray[char]): Result[seq[uint8], DataformatError] =
      return base45ToBinC(input)
    proc binToBase45*(input: openArray[uint8]): string =
      return binToBase45C(input)
    proc base56ToBin*(input: openArray[char]): Result[seq[uint8], DataformatError] =
      return base56ToBinC(input)
    proc binToBase56*(input: openArray[uint8]): string =
      return binToBase56C(input)
    proc base58ToBin*(input: openArray[char]): Result[seq[uint8], DataformatError] =
      return base58ToBinC(input)
    proc binToBase58*(input: openArray[uint8]): string =
      return binToBase58C(input)
    proc base62ToBin*(input: openArray[char]): Result[seq[uint8], DataformatError] =
      return base62ToBinC(input)
    proc binToBase62*(input: openArray[uint8]): string =
      return binToBase62C(input)
    proc base85ToBin*(input: openArray[char]): Result[seq[uint8], DataformatError] =
      return base85ToBinC(input)
    proc binToBase85*(input: openArray[uint8]): string =
      return binToBase85C(input)
    proc base91ToBin*(input: openArray[char]): Result[seq[uint8], DataformatError] =
      return base91ToBinC(input)
    proc binToBase91*(input: openArray[uint8]): string =
      return binToBase91C(input)
    proc base92ToBin*(input: openArray[char]): Result[seq[uint8], DataformatError] =
      return base92ToBinC(input)
    proc binToBase92*(input: openArray[uint8]): string =
      return binToBase92C(input)

#[
var a: string = "1398BDKEKDI398"
var b: Result[seq[uint8], DataformatError] = base36ToBin(a)
if b.kind == Success:
  echo binToBase36(b.value)
  echo binToHex(b.value)
else:
  case b.error
  of WrongCharacters:
    echo "Invalid Characters"

var c: string = "ADDE39C03"
var d: Result[seq[uint8], DataformatError] = hexToBin(c)
if d.kind == Success:
  echo binToHex(d.value)
else:
  case d.error
  of WrongCharacters:
    echo "Invalid Characters"

var e: string = "aEkbi32+/38A0"
var f: Result[seq[uint8], DataformatError] = base64ToBin(e)
if f.kind == Success:
  echo binToHex(f.value)
  echo binToBase64(f.value)
else:
  case f.error
  of WrongCharacters:
    echo "Invalid Characters"
]#
