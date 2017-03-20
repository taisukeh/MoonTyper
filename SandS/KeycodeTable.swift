//
//  KeycodeTable.swift
//  SandS
//
//  Created by Taisuke Hori on 2017/03/20.
//  Copyright © 2017年 Takatoshi Matsumoto. All rights reserved.
//

import Foundation

let usKeycodeTable: [String: CGKeyCode] = [
  "a": 0,
  "b": 11,
  "c": 8,
  "d": 2,
  "e": 14,
  "f": 3,
  "g": 5,
  "h": 4,
  "i": 34,
  "j": 38,
  "k": 40,
  "l": 37,
  "m": 46,
  "n": 45,
  "o": 31,
  "p": 35,
  "q": 12,
  "r": 15,
  "s": 1,
  "t": 17,
  "u": 32,
  "v": 9,
  "w": 13,
  "x": 7,
  "y": 16,
  "z": 6,
  
  "0": 29,
  "1": 18,
  "2": 19,
  "3": 20,
  "4": 21,
  "5": 23,
  "6": 22,
  "7": 26,
  "8": 28,
  "9": 25,

  "-": 27,
  "+": 24,
  "[": 33,
  "]": 30,
  "\\": 42,
  ";": 41,
  "'": 39,
  ",": 43,
  ".": 47,
  "/": 44,
  "=": 81,
  "`": 50,

  "🔙": 51, // backspace
  
  "keypad-0": 82,
  "keypad-1": 83,
  "keypad-2": 84,
  "keypad-3": 85,
  "keypad-4": 86,
  "keypad-5": 87,
  "keypad-6": 88,
  "keypad-7": 89,
  "keypad-8": 91,
  "keypad-9": 92,
]

let jisDiff: [String: CGKeyCode] = [
  // JIS
  "@": 0x21,
  "[": 0x2a,
  ":": 0x27,
  "゛": 0x21,
  "゜": 0x1e,
  "^": 0x18,
  "か": 0x68, // かな
  "全": 0x32, // 全角
  "_": 0x5e,
  "￥": 0x5d,
]

func jisKeyTable() -> [String: CGKeyCode] {
  var dic = usKeycodeTable
  for (k, v) in jisDiff {
    dic[k] = v
  }
  return dic
}

let jisKeycodeTable = jisKeyTable()

func keycodeTableFor(keyboard: Keyboard) -> [String: CGKeyCode] {
  switch keyboard {
  case .US: return usKeycodeTable
  case .JIS: return jisKeycodeTable
  }
}
