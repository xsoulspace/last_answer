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

    // Phase 0 (docs/design/shell-redesign-rail-views-tabs-2026-11-05.md):
    // unified titlebar — Flutter draws the whole window under the traffic
    // lights, so the shell's own band (not macOS wallpaper-tinted glass) is
    // the chrome. The shell reserves MediaQuery.viewPadding.top for them.
    self.styleMask.insert(.fullSizeContentView)
    self.titlebarAppearsTransparent = true
    self.titleVisibility = .hidden
    self.backgroundColor = .black
    // macOS 26 Liquid Glass veils the whole window otherwise.
    self.isOpaque = true

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
