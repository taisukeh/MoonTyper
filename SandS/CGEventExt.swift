//
//  CGEventExt.swift
//  SandS
//
//  Created by Taisuke Hori on 2017/03/21.
//  Copyright © 2017年 Takatoshi Matsumoto. All rights reserved.
//

import Foundation
import Cocoa

extension CGEvent {
  var hasModifier: Bool {
    return !flags.intersection([.maskCommand, .maskControl, .maskShift, .maskAlternate]).isEmpty
  }
}
