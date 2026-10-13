import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSPanel {
  // Keep the nib's top-level window alive even when Launch Services starts
  // the application without activation.
  private static var retainedWindow: MainFlutterWindow?
  private var diagnosticObservers: [NSObjectProtocol] = []
  override func awakeFromNib() {
    Self.retainedWindow = self
    self.styleMask.insert(.nonactivatingPanel)
    self.hidesOnDeactivate = false
    self.becomesKeyOnlyIfNeeded = true
    self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    if #available(macOS 13.0, *) {
      self.collectionBehavior.insert(.canJoinAllApplications)
    }
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
    for event in [NSWindow.willCloseNotification, NSWindow.didMiniaturizeNotification,
                  NSWindow.didDeminiaturizeNotification, NSWindow.didChangeOcclusionStateNotification] {
      diagnosticObservers.append(NotificationCenter.default.addObserver(forName: event, object: self, queue: .main) { [weak self] event in
        guard let self else { return }
        NSLog("workbench_window event=\(event.name.rawValue) visible=\(self.isVisible) mini=\(self.isMiniaturized) space=\(self.isOnActiveSpace) collection=\(self.collectionBehavior.rawValue)")
      })
    }
    // A Launch Services background launch does not necessarily order the
    // nib window. Publish it behind the active app without becoming key.
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      NSLog("workbench_window before visible=\(self.isVisible) mini=\(self.isMiniaturized) activeSpace=\(self.isOnActiveSpace) occlusion=\(self.occlusionState.rawValue) frame=\(self.frame)")
      self.orderBack(nil)
      NSLog("workbench_window after visible=\(self.isVisible) mini=\(self.isMiniaturized) activeSpace=\(self.isOnActiveSpace) occlusion=\(self.occlusionState.rawValue)")
    }
  }
}
