import Cocoa
import Carbon

var statusItem = NSStatusBar.system().statusItem(withLength: CGFloat(NSVariableStatusItemLength))

func interceptCGEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
  if let r = refcon {
    let hook = Unmanaged<TsukiInterceptor>.fromOpaque(r).takeUnretainedValue()
    return hook.intercept(type: type, event: event)
  }
  return Unmanaged.passUnretained(event)
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  var windowController : NSWindowController?
  
  private let interceptor: TsukiInterceptor = TsukiInterceptor()
  private var menu: NSMenu!
  private var layoutMenuItems: [NSMenuItem] = []
  private var keyLayouts: [KeyLayout] = []
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // MENU
    menu = NSMenu()
    statusItem.title = "🌒"
    statusItem.highlightMode = true
    statusItem.menu = menu
    
    reloadMenu()
    
    let axTrustedCheckOptionPrompt = kAXTrustedCheckOptionPrompt.takeRetainedValue() as String
    if AXIsProcessTrustedWithOptions([axTrustedCheckOptionPrompt: true] as CFDictionary) {
      activate()
      return
    }
    Timer.scheduledTimer(
      timeInterval: 1.0,
      target: self,
      selector: #selector(AppDelegate.checkAXIsProcessTrusted(_:)),
      userInfo: nil,
      repeats: true
    )
  }
  
  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool { return false }
  
  func checkAXIsProcessTrusted(_ timer: Timer) {
    if AXIsProcessTrusted() {
      timer.invalidate()
      activate()
    }
  }
  
  func activate() {
    guard let eventTap = CGEvent.tapCreate(
      tap: .cgSessionEventTap,
      place: .headInsertEventTap,
      options: .defaultTap,
      eventsOfInterest: CGEventMask(
        (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
      ),
      callback: interceptCGEvent,
      userInfo: UnsafeMutableRawPointer(Unmanaged.passRetained(interceptor).toOpaque())
      ) else {
        print("failed to create event tap")
        exit(1)
    }
    
    let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
    
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
    CGEvent.tapEnable(tap: eventTap, enable: true)
    CFRunLoopRun()
  }
  
  // MARK: - Menu

  func reloadMenu() {
    menu.removeAllItems()

    self.keyLayouts = loadLayoutFiles()
    layoutMenuItems = []
    interceptor.keyLayout = nil

    for keyLayout in keyLayouts {
      let item = NSMenuItem(title: keyLayout.name,
                            action: #selector(AppDelegate.layoutSelected(_:)),
                            keyEquivalent: "")
      item.representedObject = keyLayout
      menu.addItem(item)
      layoutMenuItems.append(item)
    }
    
    menu.addItem(NSMenuItem.separator())

    let isOnlyJpnMenuItem = NSMenuItem(title: "日本語入力時のみ有効", action: #selector(AppDelegate.onlyJapaneseInput(_:)), keyEquivalent: "")
    isOnlyJpnMenuItem.state = userInfo.isOnlyJapaneseInput ? NSOnState : NSOffState
    menu.addItem(isOnlyJpnMenuItem)
    interceptor.isOnlyJapaneseInput = userInfo.isOnlyJapaneseInput

    menu.addItem(NSMenuItem.separator())
    
    menu.addItem(withTitle: "一時停止", action: #selector(AppDelegate.tempStop(_:)), keyEquivalent: "")
    menu.addItem(withTitle: "再読み込み", action: #selector(AppDelegate.reload(_:)), keyEquivalent: "")
    menu.addItem(withTitle: "終了", action: #selector(AppDelegate.quit(_:)), keyEquivalent: "")

    if let lastSelectedFile = userInfo.lastSelectedLayoutFile {
      for (i, layout) in self.keyLayouts.enumerated() {
        if layout.file == lastSelectedFile {
          layoutSelected(layoutMenuItems[i])
          break
        }
      }
    }
  }
  
  func layoutSelected(_ menuItem: NSMenuItem) {
    let layout = menuItem.representedObject as! KeyLayout
    interceptor.keyLayout = layout

    for item in layoutMenuItems {
      item.state = NSOffState
    }
    menuItem.state = NSOnState
    
    userInfo.lastSelectedLayoutFile = layout.file
  }
  
  func onlyJapaneseInput(_ menuItem: NSMenuItem) {
    menuItem.state = menuItem.state == NSOffState ? NSOnState : NSOffState

    userInfo.isOnlyJapaneseInput = menuItem.state == NSOnState
    interceptor.isOnlyJapaneseInput = menuItem.state == NSOnState
  }

  func reload(_ sender: Any) {
    reloadMenu()
  }

  func tempStop(_ menuItem: NSMenuItem) {
    menuItem.state = menuItem.state == NSOffState ? NSOnState : NSOffState
    interceptor.isStop = menuItem.state == NSOnState
  }
  
  func quit(_ sender: Any) {
    NSApplication.shared().terminate(self)
  }
}
