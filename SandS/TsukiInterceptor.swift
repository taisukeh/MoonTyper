//
//  TsukiInterceptor.swift
//  SandS
//
//  Created by Taisuke Hori on 2017/03/20.
//  Copyright © 2017年 Takatoshi Matsumoto. All rights reserved.
//

import Foundation
import Cocoa
import Carbon

class TsukiInterceptor: NSObject {
  private var curKeymap: (match: Keymap, middle: Keymap)?
  var isOnlyJapaneseInput: Bool = false
  private var inputSourceRegexp = try! NSRegularExpression(pattern: "Japanese",
                                                           options: [NSRegularExpression.Options.caseInsensitive])
  private var latestTimestamp: CGEventTimestamp = 0
  var isStop: Bool = false {
    didSet {
      curKeymap = nil
    }
  }
  
  var keyLayout: KeyLayout? {
    didSet {
      curKeymap = nil
    }
  }
  
  override init() {
    super.init()
  }

  func intercept(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
    switch type {
    case CGEventType.keyDown:
      return interceptKeyDown(event)
    case CGEventType.keyUp:
      return interceptKeyUp(event)
    default:
      return Unmanaged.passUnretained(event)
    }
  }
  
  func interceptKeyDown(_ event: CGEvent) -> Unmanaged<CGEvent>? {
    guard let keyLayout = keyLayout else {
      return Unmanaged.passUnretained(event)
    }
    
    if isStop {
      return Unmanaged.passUnretained(event)
    }

    let inputSourceId = currentInputSourceId()

    if isOnlyJapaneseInput {
      let matches = inputSourceRegexp.matches(in: inputSourceId,
                                              options: [],
                                              range: NSMakeRange(0, inputSourceId.characters.count))

      if matches.count == 0 { // not match
        return Unmanaged.passUnretained(event)
      }
    }

    if event.timestamp <= latestTimestamp {
      return Unmanaged.passUnretained(event)
    }

    latestTimestamp = event.timestamp

    return interceptKeyDownInner(event, keyMap: keyLayout.keymap)
  }
  
  let isRetypeMode: Bool = false

  func interceptKeyDownInner(_ event: CGEvent, keyMap initKeymap: Keymap) -> Unmanaged<CGEvent>? {

    let curKeymap = self.curKeymap ?? (match: Keymap(level: 0, entries: []), middle:initKeymap)
    let nextKeymap = curKeymap.middle.find(event: event)
    
    if isRetypeMode {
      if !curKeymap.match.isEmpty && !nextKeymap.match.isEmpty {
        for _ in 0 ..< curKeymap.match.entries[0].keyResult.jaCharCount {
          backspaceKeyResult.postEvent(from: event)
        }
        nextKeymap.match.entries[0].keyResult.postEvent(from: event)
        self.curKeymap = nil
        return nil
      }

      if !nextKeymap.match.isEmpty && !nextKeymap.middle.isEmpty {
        nextKeymap.match.entries[0].keyResult.postEvent(from: event)
        self.curKeymap = nextKeymap
        return nil
      }

      if !nextKeymap.middle.isEmpty {
        self.curKeymap = nextKeymap
        return nil
      }

      if !nextKeymap.match.isEmpty {
        nextKeymap.match.entries[0].keyResult.postEvent(from: event)
        self.curKeymap = nil
        return nil
      }

      let initMatchedRes = initKeymap.find(event: event)
      if !initMatchedRes.match.isEmpty {
        initMatchedRes.match.entries[0].keyResult.postEvent(from: event)
        self.curKeymap = initMatchedRes
        return nil
      }
      
      if !initMatchedRes.middle.isEmpty {
        self.curKeymap = initMatchedRes
        return nil
      }

      self.curKeymap = nil
      return Unmanaged.passUnretained(event)
    } else {
    
      if !nextKeymap.match.isEmpty && nextKeymap.middle.isEmpty {
        nextKeymap.match.entries[0].keyResult.postEvent(from: event)
        self.curKeymap = nil
        return nil
      }
      
      if !nextKeymap.middle.isEmpty {
        self.curKeymap = nextKeymap
        return nil
      }
      
      if !curKeymap.match.isEmpty && !event.hasModifier {
        self.curKeymap = nil
        curKeymap.match.entries[0].keyResult.postEvent(from: event)
        if let newEvent = interceptKeyDownInner(event, keyMap: initKeymap) {
          newEvent.takeUnretainedValue().post(tap: .cghidEventTap)
        }
        return nil
      }
      
      self.curKeymap = nil
      
      return Unmanaged.passUnretained(event)
    }
  }
  
  func interceptKeyUp(_ event: CGEvent) -> Unmanaged<CGEvent>? {
    return Unmanaged.passUnretained(event)
  }
}
