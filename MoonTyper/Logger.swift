//
//  Logger.swift
//  SandS
//
//  Created by Taisuke Hori on 2017/03/20.
//  Copyright © 2017年 Takatoshi Matsumoto. All rights reserved.
//

import Foundation
import Cocoa

func warn(_ message: String) {
  let notification = NSUserNotification()
  notification.title = "MoonTyper"
  notification.informativeText = message
  NSUserNotificationCenter.default.deliver(notification)
}
