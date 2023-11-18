import 'package:flutter/cupertino.dart';
import 'package:lastanswer/common_imports.dart';

class IconShareButton extends StatefulWidget {
  const IconShareButton({
    required this.onTap,
    super.key,
  });
  final VoidCallback? onTap;

  @override
  State<IconShareButton> createState() => _IconShareButtonState();
}

class _IconShareButtonState extends State<IconShareButton> {
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
  Widget build(final BuildContext context) => IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          child: currentIcon,
        ),
        onPressed: widget.onTap == null
            ? null
            : () async {
                widget.onTap?.call();
                await setDone();
              },
      );
}
