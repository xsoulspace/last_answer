import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';

class PopupButton extends StatefulWidget {
  const PopupButton({
    required this.builder,
    required this.icon,
    this.mobileBuilder,
    this.onMobileRemove,
    this.useOnMobile = true,
    this.onWebClose,
    this.title,
    super.key,
  });
  final WidgetBuilder builder;
  final WidgetBuilder? mobileBuilder;
  final IconData icon;
  final bool useOnMobile;
  final Widget? title;
  final VoidCallback? onMobileRemove;
  final VoidCallback? onWebClose;

  @override
  State<PopupButton> createState() => _PopupButtonState();
}

class _PopupButtonState extends State<PopupButton> {
  bool _popupVisible = false;

  bool get popupVisible => _popupVisible;

  set popupVisible(final bool isVisible) {
    if (_popupVisible == isVisible) return;
    _popupVisible = isVisible;
    if (mounted) setState(() {});
    if (!isVisible) {
      widget.onWebClose?.call();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback(
      (final _) async => onOpenPopup(
        context: context,
        onClose: () => popupVisible = false,
      ),
    );
  }

  bool _popupHovered = false;

  bool get popupHovered => _popupHovered;

  set popupHovered(final bool value) {
    if (_popupHovered == value) return;
    _popupHovered = value;
    if (mounted) setState(() {});
  }

  Future<void> onOpenPopup({
    required final BuildContext context,
    required final VoidCallback onClose,
  }) async {
    if (PlatformInfo.isNativeWebDesktop) return;
    void close(final BuildContext context) {
      onClose();
      widget.onWebClose?.call();

      unawaited(Navigator.maybePop(context));
    }

    final effectiveBuilder = widget.mobileBuilder ?? widget.builder;

    return showAdaptiveDialog(
      barrierDismissible: false,
      context: context,
      barrierColor: Colors.black12,
      builder: (final context) => MobilePopupButtonDialog(
        builder: effectiveBuilder,
        onRemove: widget.onMobileRemove,
        close: close,
        title: widget.title,
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final screenLayout = ScreenLayout.of(context);
    Future<void> onClose([final MenuController? controller]) async {
      await Future.delayed(const Duration(milliseconds: 300), () {
        if (popupHovered) return;
        popupVisible = false;
        controller?.close();
      });
    }

    final button = IconButton(
      onPressed: () {
        popupVisible = true;
      },
      icon: Icon(widget.icon),
    );

    if (!PlatformInfo.isNativeWebDesktop) {
      if (widget.useOnMobile) return button;

      return const SizedBox();
    }
    return MenuAnchor(
      onClose: () async {
        popupHovered = false;
        await onClose();
      },
      alignmentOffset: const Offset(-250, -35),
      menuChildren: [
        MouseRegion(
          onExit: (final _) {
            popupHovered = false;
          },
          onHover: (final _) => popupHovered = true,
          child: widget.builder(context),
        ),
      ],
      builder: (final context, final controller, final child) => MouseRegion(
        onEnter: (final _) async {
          controller.open();
          popupHovered = true;
        },
        onExit: (final _) async {
          popupHovered = false;
          await onClose(controller);
        },
        onHover: (final _) => popupHovered = true,
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

    return NavigatorPopHandler(
      onPop: () async {
        close(context);
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
          text ?? context.l10n.delete.sentenceCase,
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
              text ?? context.l10n.delete.sentenceCase,
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
              context.l10n.close.sentenceCase,
              style: theme.textTheme.titleLarge?.copyWith(
                color: primaryColor,
              ),
            ),
    );
  }
}
