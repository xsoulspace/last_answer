import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  // see more: https://github.com/flutter/flutter/issues/59969
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // ADR 0024 — the shell (actor rail + pane tree) needs room; the
    // window never shrinks below the pane tree's usable minimum.
    self.minSize = NSSize(width: 980, height: 640)

    // DESIGN.md v2 — THE TITLE BAR IS GONE (the owner's split-redesign
    // law, Safari/VS Code anatomy): the tab strip is the window's only
    // top row and the traffic lights ride at its head. Flutter draws
    // the whole window under the lights; interactive Flutter content
    // there receives its own events (the fullSizeContentView law the
    // window_manager ecosystem ships on), and unhandled background
    // falls through to the native window drag. The shell's strips mark
    // their empty chrome as drag regions through the channel below —
    // `performDrag(with:)` is the AppKit-sanctioned replacement for the
    // retired native titlebar strip (the same call window_manager's
    // startDragging makes).
    self.styleMask.insert(.fullSizeContentView)
    self.titlebarAppearsTransparent = true
    self.titleVisibility = .hidden
    if #available(macOS 11.0, *) {
      self.titlebarSeparatorStyle = .none
    }
    self.backgroundColor = .black
    // macOS 26 Liquid Glass veils the whole window otherwise.
    self.isOpaque = true

    let windowChannel = FlutterMethodChannel(
      name: "dev.lastanswer/window",
      binaryMessenger: flutterViewController.engine.binaryMessenger)
    windowChannel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(FlutterError(code: "window_gone", message: nil, details: nil))
        return
      }
      switch call.method {
      case "startDrag":
        if let event = self.currentEvent {
          self.performDrag(with: event)
        }
        result(nil)
      case "zoom":
        self.zoom(nil)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
