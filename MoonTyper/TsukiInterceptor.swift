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
  private var keyState: (match: Keymap, middle: Keymap, queue: KeyResult)?
  var isOnlyJapaneseInput: Bool = false
  private var inputSourceRegexp = try! NSRegularExpression(pattern: "Japanese",
                                                           options: [NSRegularExpression.Options.caseInsensitive])
  private var latestTimestamp: CGEventTimestamp = 0
  var isStop: Bool = false {
    didSet {
      keyState = nil
    }
  }
  
  var keyLayout: KeyLayout? {
    didSet {
      keyState = nil
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
  
  func interceptKeyDownInner(_ event: CGEvent, keyMap initKeymap: Keymap) -> Unmanaged<CGEvent>? {

    let keyState = self.keyState ?? (match: Keymap(level: 0, entries: []),
                                     middle:initKeymap,
                                     queue: KeyResult())
    let nextKeymap = keyState.middle.find(event: event)
    
    if !nextKeymap.match.isEmpty && nextKeymap.middle.isEmpty {
      nextKeymap.match.entries[0].keyResult.postEvent(from: event)
      self.keyState = nil
      return nil
    }
    
    if !nextKeymap.middle.isEmpty {
      self.keyState = (match: nextKeymap.match,
                       middle: nextKeymap.middle,
                       queue: keyState.queue + event)
      return nil
    }
    
    if keyState.middle.level > 0 &&  CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode)) == 51 {
      // バックスペースで途中の状態をキャンセルする
      self.keyState = nil
      return nil
    }
    
    if !keyState.match.isEmpty && event.hasModifier {
      self.keyState = nil
      keyState.match.entries[0].keyResult.postEvent(from: event)
      event.post(tap: .cghidEventTap)
      return nil
    }
    
    if !keyState.match.isEmpty && !event.hasModifier {
      self.keyState = nil
      keyState.match.entries[0].keyResult.postEvent(from: event)
      if let newEvent = interceptKeyDownInner(event, keyMap: initKeymap) {
        newEvent.takeUnretainedValue().post(tap: .cghidEventTap)
      }
      return nil
    }
    
    if !keyState.queue.isEmpty {
      keyState.queue.postEvent(from: event)
      event.post(tap: .cghidEventTap)
      self.keyState = nil
      return nil
    }
    
    self.keyState = nil
    
    return Unmanaged.passUnretained(event)
  }

  func interceptKeyUp(_ event: CGEvent) -> Unmanaged<CGEvent>? {
    return Unmanaged.passUnretained(event)
  }
}
