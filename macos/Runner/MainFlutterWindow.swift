import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  // see more: https://github.com/flutter/flutter/issues/59969
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
