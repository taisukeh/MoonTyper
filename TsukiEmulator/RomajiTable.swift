//
//  RomajiTable.swift
//  SandS
//
//  Created by Taisuke Hori on 2017/03/20.
//  Copyright © 2017年 Takatoshi Matsumoto. All rights reserved.
//

import Foundation

class RomajiTable {
  let twoLenList: [String] = [
    "kya", "kyu", "kyo",
    "sha", "shu", "sho", "sya", "syu", "syo",
    "tya", "tyu", "tyo", "cya", "cyu", "cyo", "cha", "chu", "cho",
    "nya", "nyu", "nyo",
    "hya", "hyu", "hyo",
    "mya", "myu", "myo",
    "rya", "ryu", "ryo",
    "gya", "gyu", "gyo",
    "ja", "ju", "jo", "zya", "zyu", "zyo", "jya", "jyu", "jyo",
    "dya", "dyu", "dyo",
    "bya", "byu", "byo",
    "pya", "pyu", "pyo",
    "fya", "fyu", "fyo",
    "tha", "thu", "tho",
    "wha", "wi", "whi", "whe", "who",
    "fa", "fi", "fe", "fo",
    "va", "vi", "ve", "vo",
    "dha", "dhi", "dhu", "dhe", "dho",
  ]
  
  func jaCharCount(s: String) -> Int {
    if twoLenList.contains(s) {
      return 2
    } else {
      return 1
    }
  }
}

let romajiTable = RomajiTable()
