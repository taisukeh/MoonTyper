//
//  InputSource.swift
//  SandS
//
//  Created by Taisuke Hori on 2017/03/21.
//  Copyright © 2017年 Takatoshi Matsumoto. All rights reserved.
//

import Foundation
import Carbon

func bridge<T: AnyObject>(_ obj: T) -> UnsafeMutableRawPointer {
  return Unmanaged.passRetained(obj).toOpaque()
}

func bridge<T: AnyObject>(_ ptr: UnsafeRawPointer) -> T {
  return Unmanaged<T>.fromOpaque(ptr).takeRetainedValue()
}

func getProperty<T>(_ source: TISInputSource, _ key: CFString) -> T? {
  let cfType = TISGetInputSourceProperty(source, key)
  if (cfType != nil) {
    return Unmanaged<AnyObject>.fromOpaque(cfType!).takeUnretainedValue() as? T
  } else {
    return nil
  }
}

func availInputSources() -> [(name: String, id: String)] {
  var res: [(name: String, id: String)] = []
  
  let sourceList = TISCreateInputSourceList(nil, false).takeUnretainedValue()
  for i in 0 ..< CFArrayGetCount(sourceList) {
    let source: TISInputSource = bridge(CFArrayGetValueAtIndex(sourceList, i))

    let availTypes = [kTISTypeKeyboardInputMode as String]
    if let sourceType = getProperty(source, kTISPropertyInputSourceType) as String?, !availTypes.contains(sourceType) {
      print(sourceType)
      continue
    }
    if let capable = getProperty(source, kTISPropertyInputSourceIsSelectCapable) as Int?, capable != 1 {
      continue
    }
    
    guard let name: String = getProperty(source, kTISPropertyLocalizedName) else { continue }
    guard let id: String = getProperty(source, kTISPropertyInputSourceID) else { continue }
    
    res.append((name: name, id: id))
  }
  return res
}

func currentInputSourceId() -> String {
  let inputSource = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
  
  if let id = getProperty(inputSource, kTISPropertyInputSourceID) as String? {
    return id
  } else {
    return ""
  }
}
