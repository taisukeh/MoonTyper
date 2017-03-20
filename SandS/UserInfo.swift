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
}

let userInfo = UserInfo()
