part of widgets;

class PopupButton extends HookWidget {
  const PopupButton({
    required this.builder,
    required this.icon,
    final this.mobileBuilder,
    this.secondaryMobileAction,
    this.useOnMobile = true,
    this.title,
    final Key? key,
  }) : super(key: key);
  final WidgetBuilder builder;
  final WidgetBuilder? mobileBuilder;
  final Widget? secondaryMobileAction;
  final IconData icon;
  final bool useOnMobile;
  final Widget? title;

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
      builder: (final context) => AppDialog(
        builder: effectiveBuilder,
        close: close,
        secondaryMobileAction: secondaryMobileAction,
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

class AppDialog extends StatelessWidget {
  const AppDialog({
    required final this.secondaryMobileAction,
    required final this.title,
    required final this.close,
    required final this.builder,
    final Key? key,
  }) : super(key: key);
  final Widget? secondaryMobileAction;
  final Widget? title;
  final ValueChanged<BuildContext> close;
  final WidgetBuilder builder;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    Widget actions;
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primary : AppColors.primary1;

    final closeButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: defaultBorderRadius,
        ),
        side: BorderSide(
          color: primaryColor,
        ),
        primary: primaryColor,
      ),
      onPressed: () => close(context),
      child: Text(
        S.current.close.sentenceCase,
        style: theme.textTheme.headline6?.copyWith(
          color: primaryColor,
        ),
      ),
    );

    if (secondaryMobileAction != null) {
      actions = Row(
        children: [
          Expanded(child: secondaryMobileAction!),
          Expanded(
            child: closeButton,
          ),
        ],
      );
    } else {
      actions = Expanded(child: closeButton);
    }

    return WillPopScope(
      onWillPop: () async {
        close(context);

        return true;
      },
      child: Stack(
        children: [
          ColoredBox(
            color: theme.canvasColor,
            child: const SizedBox.expand(),
          ),
          Dialog(
            alignment: Alignment.topCenter,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Column(
              children: [
                if (title != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: title,
                    ),
                  ),
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
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: actions,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
