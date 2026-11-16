/// Legacy-kit port of `_library/widgets/core/unsplash_image.dart` (the
/// original `UnsplashService` part file was already empty — there was no
/// networking logic left to carry over). Widgets-layer only; public API
/// identical to the original.
library;

import 'package:flutter/widgets.dart';

class UnsplashImage extends StatelessWidget {
  const UnsplashImage({super.key});

  @override
  Widget build(final BuildContext context) => const SizedBox.shrink();
}
