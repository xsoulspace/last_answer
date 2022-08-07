enum WidthFormFactor {
  mobile(
    isLeftPanelAllowed: true,
    isCenterPanelAllowed: false,
    isRightPanelAllowed: false,
    max: 700,
  ),
  tablet(
    isLeftPanelAllowed: true,
    isCenterPanelAllowed: true,
    isRightPanelAllowed: false,
    max: 1000,
  ),
  desktop(
    isLeftPanelAllowed: true,
    isCenterPanelAllowed: true,
    isRightPanelAllowed: true,
    max: double.infinity,
  );

  const WidthFormFactor({
    required this.isLeftPanelAllowed,
    required this.isCenterPanelAllowed,
    required this.isRightPanelAllowed,
    required this.max,
  });
  final bool isLeftPanelAllowed;
  final bool isCenterPanelAllowed;
  final bool isRightPanelAllowed;
  final double max;
}

@Deprecated('should be dynamic and saved in user preferences')
const maxFullscreenPageWidth = 500.0;
@Deprecated('should be dynamic and saved in user preferences')
const minFullscreenPageWidth = 450.0;
@Deprecated('use WidthFormFactor')
const maxSmallWidth = 700.0;
@Deprecated('use WidthFormFactor')
const maxMediumWidth = 1000.0;

enum DeviceFormFactor {
  android(
    hasTransparencySupport: false,
    hasWindowClose: false,
    hasWindowExpand: false,
    hasWindowHide: false,
  ),
  iOS(
    hasTransparencySupport: false,
    hasWindowClose: false,
    hasWindowExpand: false,
    hasWindowHide: false,
  ),
  macOS(),
  windows(),
  linux(),
  web(
    hasTransparencySupport: false,
    hasWindowClose: false,
    hasWindowExpand: false,
    hasWindowHide: false,
  );

  const DeviceFormFactor({
    this.hasWindowClose = true,
    this.hasWindowExpand = true,
    this.hasWindowHide = true,
    this.hasTransparencySupport = false,
  });
  final bool hasWindowClose;
  final bool hasWindowHide;
  final bool hasWindowExpand;
  final bool hasTransparencySupport;
}

enum ControlsFormFactor {
  touch,
  mouse;
}

enum PerformanceFormFactor {
  batterySaver(
    hasAnimations: false,
  ),
  regular();

  const PerformanceFormFactor({
    this.hasAnimations = true,
  });
  final bool hasAnimations;
}
