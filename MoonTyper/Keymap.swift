//
//  Keymap.swift
//  SandS
//
//  Created by Taisuke Hori on 2017/03/20.
//  Copyright © 2017年 Takatoshi Matsumoto. All rights reserved.
//

import Foundation
import Cocoa

class Keymap {
  let entries: [KeymapEntry]
  let level: Int

  convenience init(table: [(String, String)], keyboard: Keyboard) {
    var entries: [KeymapEntry] = []

    for (seq, key) in table {
      let seq = KeySequence(keys: seq, keyboard: keyboard)
      let res = KeyResult(key: key, keyboard: keyboard)
      entries.append(KeymapEntry(keySequence: seq, keyResult: res))
    }
    self.init(level: 0, entries: entries)
  }
  
  init(level: Int, entries: [KeymapEntry]) {
    self.entries = entries
    self.level = level
  }
  
  var isEmpty: Bool {
    return entries.isEmpty
  }

  func find(event: CGEvent) -> (match: Keymap, middle: Keymap) {
    var match: [KeymapEntry] = []
    var middle: [KeymapEntry] = []

    for entry in entries {
      switch entry.keySequence.match(level: level, event: event) {
      case .match: match.append(entry)
      case .matchMiddle: middle.append(entry)
      case .notMatch: break
      }
    }

    return (match: Keymap(level: level + 1, entries: match), middle: Keymap(level: level + 1, entries: middle))
  }
}

enum KeymapResult {
  case multi(keymap: Keymap)
  case one(result: KeyResult)
  case none
}

struct KeymapEntry {
  let keySequence: KeySequence
  let keyResult: KeyResult
}

struct KeySequence {
  let keys: [CGKeyCode]
  
  init(keys: String, keyboard: Keyboard) {
    let keycodeTable = keycodeTableFor(keyboard: keyboard)
    var keyCodes: [CGKeyCode] = []
    for (_, c) in keys.characters.enumerated() {
      if let keycode = keycodeTable[c.description] {
        keyCodes.append(keycode)
      } else {
        assert(false)
      }
    }
    self.keys = keyCodes
  }

  func match(level: Int, event: CGEvent) -> KeySequenceMatch {
    if keys.count  < level + 1 {
      return .notMatch
    }
    
    if event.hasModifier {
      return .notMatch
    }

    if keys[level] == CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode)) {
      if level == keys.count - 1 {
        return .match
      } else {
        return .matchMiddle
      }
    }

    return .notMatch
  }
}

enum KeySequenceMatch {
  case match
  case notMatch
  case matchMiddle
}


struct KeyResult {
  let keyCodes: [CGKeyCode]
  
  init() {
    keyCodes = []
  }
  
  init(KeyResult: KeyResult, event: CGEvent) {
    let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
    keyCodes = KeyResult.keyCodes + [keyCode]
  }

  init(key: String, keyboard: Keyboard) {
    let keycodeTable = keycodeTableFor(keyboard: keyboard)

    var keyCodes: [CGKeyCode] = []
    for (_, c) in key.characters.enumerated() {
      keyCodes.append(keycodeTable[c.description]!)
    }
    self.keyCodes = keyCodes
  }
  
  var isEmpty: Bool {
    return keyCodes.isEmpty
  }
  
  func postEvent(from event: CGEvent) {
    let origKeyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
    let origFlags = event.flags
    event.flags.subtract(CGEvent.modifiers)

    for keyCode in keyCodes {
      event.setIntegerValueField(.keyboardEventKeycode, value: Int64(keyCode))
      event.post(tap: .cghidEventTap)
    }
    event.setIntegerValueField(.keyboardEventKeycode, value: Int64(origKeyCode))
    event.flags = origFlags
  }
}

extension KeyResult {
  static func + (lhs: KeyResult, rhs: CGEvent) -> KeyResult {
    return KeyResult(KeyResult: lhs, event: rhs)
  }
}

let backspaceKeyResult = KeyResult(key: "🔙", keyboard: .US)
