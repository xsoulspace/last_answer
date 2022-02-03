part of widgets;

class PopupButton extends HookWidget {
  const PopupButton({
    required this.builder,
    required this.icon,
    final this.mobileBuilder,
    this.onMobileRemove,
    this.useOnMobile = true,
    this.title,
    final Key? key,
  }) : super(key: key);
  final WidgetBuilder builder;
  final WidgetBuilder? mobileBuilder;
  final IconData icon;
  final bool useOnMobile;
  final Widget? title;
  final VoidCallback? onMobileRemove;

  void onOpenPopup({
    required final BuildContext context,
    required final VoidCallback onClose,
  }) {
    if (isDesktop) return;
    void close(final BuildContext context) {
      onClose();
      Navigator.maybePop(context);
    }

    final effectiveBuilder = mobileBuilder ?? builder;

    showDialog(
      barrierDismissible: false,
      context: context,
      barrierColor: Colors.black12,
      builder: (final context) => MobilePopupButtonDialog(
        builder: effectiveBuilder,
        onRemove: onMobileRemove,
        close: close,
        title: title,
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final popupVisible = useIsBool();
    final popupHovered = useIsBool();
    final screenLayout = ScreenLayout.of(context);
    final getIsMounted = useIsMounted();
    Future<void> onClose() async {
      await Future.delayed(const Duration(milliseconds: 300), () {
        if (popupHovered.value) return;
        if (!getIsMounted()) return;
        popupVisible.value = false;
      });
    }

    useValueChanged<bool, void>(
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
      onPressed: () {
        popupVisible
          ..value = true
          // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
          ..notifyListeners();
      },
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

class MobilePopupButtonDialog extends StatelessWidget {
  const MobilePopupButtonDialog({
    required final this.title,
    required final this.close,
    required final this.builder,
    required this.onRemove,
    final Key? key,
  }) : super(key: key);
  final Widget? title;
  final ValueChanged<BuildContext> close;
  final VoidCallback? onRemove;
  final WidgetBuilder builder;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    final closeButton = RemoveActionButton(
      onTap: onRemove,
      useIcon: true,
    );

    return WillPopScope(
      onWillPop: () async {
        close(context);

        return true;
      },
      child: Dialog(
        alignment: Alignment.topCenter,
        insetPadding: EdgeInsets.zero,
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: [closeButton],
            title: title,
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 24,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    builder(context),
                  ],
                ),
                Divider(
                  color: theme.highlightColor,
                  height: 10,
                  endIndent: 12,
                  indent: 12,
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedPrimaryButton(
                    onClose: () => close(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RemoveActionButton extends StatelessWidget {
  const RemoveActionButton({
    required this.onTap,
    this.useIcon = false,
    this.filled = false,
    this.text,
    final Key? key,
  }) : super(key: key);
  final VoidCallback? onTap;
  final bool useIcon;
  final String? text;
  final bool filled;

  @override
  Widget build(final BuildContext context) {
    if (filled) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.all(14),
          shape: RoundedRectangleBorder(
            borderRadius: defaultBorderRadius,
          ),
          primary: AppColors.accent3,
        ),
        onPressed: onTap,
        child: Text(
          text ?? S.current.delete.sentenceCase,
          style: Theme.of(context).textTheme.headline6,
        ),
      );
    }

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: defaultBorderRadius,
        ),
        primary: AppColors.accent3,
      ),
      child: useIcon
          ? const Icon(Icons.delete_forever_rounded)
          : Text(
              text ?? S.current.delete.sentenceCase,
              style: Theme.of(context).textTheme.headline6,
              // ?.copyWith(color: AppColors.accent3),
            ),
    );
  }
}

class OutlinedPrimaryButton extends StatelessWidget {
  const OutlinedPrimaryButton({
    required this.onClose,
    this.useIcon = false,
    final Key? key,
  }) : super(key: key);
  final VoidCallback? onClose;
  final bool useIcon;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primary : AppColors.primary1;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        side: BorderSide(color: primaryColor),
        primary: primaryColor,
      ),
      onPressed: onClose,
      child: useIcon
          ? const Icon(Icons.check)
          : Text(
              S.current.close.sentenceCase,
              style: theme.textTheme.headline6?.copyWith(
                color: primaryColor,
              ),
            ),
    );
  }
}
