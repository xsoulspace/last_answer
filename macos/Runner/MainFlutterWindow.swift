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

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
