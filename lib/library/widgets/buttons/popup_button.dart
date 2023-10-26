part of '../widgets.dart';

class PopupButton extends HookWidget {
  const PopupButton({
    required this.builder,
    required this.icon,
    this.mobileBuilder,
    this.onMobileRemove,
    this.useOnMobile = true,
    this.title,
    super.key,
  });
  final WidgetBuilder builder;
  final WidgetBuilder? mobileBuilder;
  final IconData icon;
  final bool useOnMobile;
  final Widget? title;
  final VoidCallback? onMobileRemove;

  Future<void> onOpenPopup({
    required final BuildContext context,
    required final VoidCallback onClose,
  }) async {
    if (isDesktop) return;
    void close(final BuildContext context) {
      onClose();
      unawaited(Navigator.maybePop(context));
    }

    final effectiveBuilder = mobileBuilder ?? builder;

    return showDialog(
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

        WidgetsBinding.instance.addPostFrameCallback(
          (final _) async => onOpenPopup(
            context: context,
            onClose: () => popupVisible.value = false,
          ),
        );
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

    return PortalTarget(
      visible: popupVisible.value,
      anchor: screenLayout.large
          ? const Aligned(
              follower: Alignment.bottomRight,
              target: Alignment.topLeft,
            )
          : const Aligned(
              follower: Alignment.bottomRight,
              target: Alignment.topLeft,
            ),
      portalFollower: MouseRegion(
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
    required this.title,
    required this.close,
    required this.builder,
    required this.onRemove,
    super.key,
  });
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
              horizontal: 20,
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
    super.key,
  });
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
          backgroundColor: AppColors.accent3,
          padding: const EdgeInsets.all(14),
          shape: RoundedRectangleBorder(
            borderRadius: defaultBorderRadius,
          ),
        ),
        onPressed: onTap,
        child: Text(
          text ?? S.current.delete.sentenceCase,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent3,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: defaultBorderRadius,
        ),
      ),
      child: useIcon
          ? const Icon(Icons.delete_forever_rounded)
          : Text(
              text ?? S.current.delete.sentenceCase,
              style: Theme.of(context).textTheme.titleLarge,
              // ?.copyWith(color: AppColors.accent3),
            ),
    );
  }
}

class OutlinedPrimaryButton extends StatelessWidget {
  const OutlinedPrimaryButton({
    required this.onClose,
    this.useIcon = false,
    super.key,
  });
  final VoidCallback? onClose;
  final bool useIcon;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primary : AppColors.primary1;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        side: BorderSide(color: primaryColor),
      ),
      onPressed: onClose,
      child: useIcon
          ? const Icon(Icons.check)
          : Text(
              S.current.close.sentenceCase,
              style: theme.textTheme.titleLarge?.copyWith(
                color: primaryColor,
              ),
            ),
    );
  }
}
