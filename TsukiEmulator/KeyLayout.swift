//
//  KeyLayout.swift
//  SandS
//
//  Created by Taisuke Hori on 2017/03/20.
//  Copyright © 2017年 Takatoshi Matsumoto. All rights reserved.
//

import Foundation
import Yaml

enum Keyboard: String {
  case US = "US"
  case JIS = "JIS"
}

struct KeyLayout {
  let file: URL
  let name: String
  let keyboard: Keyboard
  let keymap: Keymap
}

func initDefaultLayoutFile(dir: URL) {
  do {
    if !FileManager.default.fileExists(atPath: dir.path) {
      try FileManager.default.createDirectory(at: dir,
                                              withIntermediateDirectories: false,
                                              attributes: nil)
    }

    guard let defaultUSFile = Bundle.main.path(forResource: "layouts/tsuki-2-263_us", ofType: "yml") else {
      assert(false)
      return
    }

    guard let defaultJisFile = Bundle.main.path(forResource: "layouts/tsuki-2-263_jis", ofType: "yml") else {
      assert(false)
      return
    }

    let destUSPath = dir.appendingPathComponent("tsuki-2-263_us.yml")
    if !FileManager.default.fileExists(atPath: destUSPath.path) {
      try FileManager.default.copyItem(atPath: defaultUSFile, toPath: destUSPath.path)
    }

    let destJisPath = dir.appendingPathComponent("tsuki-2-263_jis.yml")
    if !FileManager.default.fileExists(atPath: destJisPath.path) {
      try FileManager.default.copyItem(atPath: defaultJisFile, toPath: destJisPath.path)
    }
  } catch let error {
    warn(error.localizedDescription)
  }
}
func loadLayoutFiles() -> [KeyLayout] {

  let dirURl = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("TsukiEmulator")
  initDefaultLayoutFile(dir: dirURl)
  
  do {
    // Get the directory contents urls (including subfolders urls)
    let directoryContents = try FileManager.default.contentsOfDirectory(at: dirURl,
                                                                        includingPropertiesForKeys: nil, options: [])

    // if you want to filter the directory contents you can do like this:
    let files = directoryContents.filter{ $0.pathExtension == "yml" || $0.pathExtension == "yaml" }
    
    var keyLayouts: [KeyLayout] = []
    for file in files {
      if let keyLayout = loadKeylayout(yamlPath: file) {
        keyLayouts.append(keyLayout)
      }
    }

    return keyLayouts

  } catch let error {
    warn(error.localizedDescription)
    return []
  }
}

func loadKeylayout(yamlPath location: URL) -> KeyLayout? {
  guard let fh = try? FileHandle(forReadingFrom: location) else {
    warn("\(location)を開けませんでした")
    return nil
  }
  
  defer {
    fh.closeFile()
  }
  
  let data = fh.readDataToEndOfFile()
  guard let str = String(data: data, encoding: .utf8) else {
    warn("\(location)の読み込みに失敗しました")
    return nil
  }
  guard let yaml = try? Yaml.load(str) else {
    warn("\(location), yamlの読み込みに失敗しました")
    return nil
  }

  guard let name = loadName(location: location, yaml: yaml) else { return nil }
  guard let keyboard = loadKeyboard(location: location, yaml: yaml) else { return nil }
  let keymap = loadKeymap(location: location, yaml: yaml, keyboard: keyboard)

  return KeyLayout(file: location, name: name, keyboard: keyboard, keymap: keymap)
}

func loadName(location: URL, yaml: Yaml) -> String? {
  guard let name = yaml["name"].string else {
    warn("\(location) 配列名の読み込み失敗")
    return nil
  }
  return name
}

func loadKeyboard(location: URL, yaml: Yaml) -> Keyboard? {
  guard let keyboard = yaml["keyboard"].string else {
    warn("\(location) keyboardの読み込み失敗")
    return nil
  }
  return Keyboard.init(rawValue: keyboard)
}

func loadKeymap(location: URL, yaml: Yaml, keyboard: Keyboard) -> Keymap {
  var table: [(String, String)] = []

  if let keymap = yaml["keymap"].dictionary {
    for (key, value) in keymap {
      if let seq = key.string, let res = value.string {
        table.append((seq, res))
      } else {
        warn("\(location)ファイル読み込み中にエラー \(key, value)")
      }
    }
  } else {
    warn("\(location), keymap要素がありません")
  }
  return Keymap(table: table, keyboard: keyboard)
}

