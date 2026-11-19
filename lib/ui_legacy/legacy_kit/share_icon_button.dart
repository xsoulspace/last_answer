/// Kit re-composition of the legacy `IconShareButton` (the sweep brief maps
/// it to `LaButton.icon`; this keeps its frozen behavior — platform icon
/// pick + the transient "done" checkmark — over the kit button). Used by
/// the idea and note lanes.
library;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:lastanswer/common_imports.dart';

class ShareIconButton extends StatefulWidget {
  const ShareIconButton({required this.onTap, super.key});
  final VoidCallback onTap;

  @override
  State<ShareIconButton> createState() => _ShareIconButtonState();
}

class _ShareIconButtonState extends State<ShareIconButton> {
  late Icon defaultIcon;
  final doneIcon = const Icon(Icons.done);
  late Icon currentIcon;
  @override
  void initState() {
    super.initState();
    IconData iconData;
    if (PlatformInfo.isNativeWebDesktop) {
      iconData = Icons.copy;
    } else {
      iconData = PlatformInfo.isCupertino ? CupertinoIcons.share : Icons.share;
    }
    defaultIcon = Icon(iconData);

    currentIcon = defaultIcon;
  }

  Future setDone() async {
    currentIcon = doneIcon;
    if (!mounted) return;
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 1450), () {
      currentIcon = defaultIcon;
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(final BuildContext context) => LaButton.icon(
    icon: AnimatedSwitcher(
      duration: const Duration(milliseconds: 700),
      child: currentIcon,
    ),
    onPressed: () async {
      widget.onTap();
      await setDone();
    },
  );
}
