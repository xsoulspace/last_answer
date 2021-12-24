part of widgets;

class PopupButton extends HookWidget {
  const PopupButton({
    required final this.builder,
    required this.icon,
    this.useOnMobile = true,
    final Key? key,
  }) : super(key: key);
  final WidgetBuilder builder;
  final IconData icon;
  final bool useOnMobile;
  bool? onOpenPopup({
    required final BuildContext context,
    required final VoidCallback onClose,
  }) {
    if (isDesktop) return null;
    void close(final BuildContext context) {
      onClose();
      Navigator.maybePop(context);
    }

    if (isAppleDevice) {
      showCupertinoDialog(
        context: context,
        builder: (final context) {
          return CupertinoAlertDialog(
            actions: [
              CupertinoDialogAction(
                onPressed: () => close(context),
                child: Text(S.current.close.titleCase),
              ),
            ],
            content: builder(context),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (final context) {
          return AlertDialog(
            actions: [
              TextButton(
                onPressed: () => close(context),
                child: Text(
                  S.current.close.toUpperCase(),
                ),
              ),
            ],
            content: builder(context),
          );
        },
      );
    }

    return null;
  }

  @override
  Widget build(final BuildContext context) {
    final popupVisible = useIsBool();
    final popupHovered = useIsBool();
    final screenLayout = ScreenLayout.of(context);

    Future<void> onClose() async {
      await Future.delayed(const Duration(milliseconds: 300), () {
        if (popupHovered.value) return;
        popupVisible.value = false;
      });
    }

    useValueChanged<bool, bool>(
      popupVisible.value,
      (final _, final __) {
        if (!popupVisible.value) return;
        WidgetsBinding.instance?.addPostFrameCallback((final _) {
          onOpenPopup(
            context: context,
            onClose: () => popupVisible.value = false,
          );
        });
      },
    );

    final button = IconButton(
      onPressed: () => popupVisible.value = true,
      icon: Icon(icon),
    );

    if (!isDesktop) {
      if (useOnMobile) return button;

      return const SizedBox();
    }

    return PortalEntry(
      visible: popupVisible.value,
      portalAnchor:
          screenLayout.large ? Alignment.bottomLeft : Alignment.bottomRight,
      childAnchor: screenLayout.large ? Alignment.topRight : Alignment.topLeft,
      portal: MouseRegion(
        onExit: (final _) async {
          popupHovered.value = false;
          await onClose();
        },
        onHover: (final _) => popupHovered.value = true,
        child: builder(context),
      ),
      child: MouseRegion(
        onHover: (final _) {
          popupVisible.value = true;
        },
        onExit: (final _) async => onClose(),
        child: button,
      ),
    );
  }
}
