//
//  UserInfo.swift
//  SandS
//
//  Created by Taisuke Hori on 2017/03/20.
//  Copyright © 2017年 Takatoshi Matsumoto. All rights reserved.
//

import Foundation

class UserInfo {
  private let lastSelectedLayoutFileKey = "TsukiEmulator_lastSelectedLayoutFile"
  private let lastSelectedKeyboardLayoutKey = "TsukiEmulator_keybaordLayout"
  private let onlyJapaneseInputKey = "TsukiEmulator_isOnlyJapaneseInput"

  var lastSelectedLayoutFile: URL? {
    get {
      return UserDefaults.standard.url(forKey: lastSelectedLayoutFileKey)
    }
    set(url) {
      UserDefaults.standard.set(url, forKey: lastSelectedLayoutFileKey)
    }
  }
  
  var keyboardLayout: String {
    get {
      return UserDefaults.standard.string(forKey: lastSelectedKeyboardLayoutKey) ?? "US"
    }
    set(layout) {
      UserDefaults.standard.set(layout, forKey: lastSelectedKeyboardLayoutKey)
    }
  }
  
  var isOnlyJapaneseInput: Bool {
    get {
      return UserDefaults.standard.bool(forKey: onlyJapaneseInputKey)
    }
    set(b) {
      UserDefaults.standard.set(b, forKey: onlyJapaneseInputKey)
    }
  }
}

let userInfo = UserInfo()
