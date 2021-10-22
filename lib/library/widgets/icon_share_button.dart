part of widgets;

class IconShareButton extends StatefulWidget {
  const IconShareButton({
    required final this.onTap,
    final Key? key,
  }) : super(key: key);
  final VoidCallback? onTap;

  @override
  State<IconShareButton> createState() => _IconShareButtonState();
}

class _IconShareButtonState extends State<IconShareButton> {
  final defaultIcon =
      isDesktop ? const Icon(Icons.copy) : const Icon(Icons.share);
  final doneIcon = const Icon(Icons.done);
  late Icon currentIcon;
  @override
  void initState() {
    super.initState();
    currentIcon = defaultIcon;
    setState(() {});
  }

  Future setDone() async {
    currentIcon = doneIcon;
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 1450), () {
      currentIcon = defaultIcon;
      setState(() {});
    });
  }

  @override
  Widget build(final BuildContext context) {
    return IconButton(
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
}
