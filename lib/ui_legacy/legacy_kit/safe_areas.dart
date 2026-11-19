/// Legacy-kit port of `_library/widgets/core/safe_areas.dart`.
/// Widgets-layer only; public API identical to the original.
library;

import 'package:flutter/widgets.dart';

class BottomSafeArea extends StatelessWidget {
  const BottomSafeArea({super.key});
  @override
  Widget build(final BuildContext context) =>
      const SafeArea(top: false, child: SizedBox(height: 1));
}

class TopSafeArea extends StatelessWidget {
  const TopSafeArea({super.key});

  @override
  Widget build(final BuildContext context) =>
      const SafeArea(bottom: false, child: SizedBox(height: 1));
}
