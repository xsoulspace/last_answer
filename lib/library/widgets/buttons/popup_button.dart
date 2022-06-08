import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/hooks/hooks.dart';
import 'package:lastanswer/library/widgets/buttons/decorated_action_button.dart';
import 'package:lastanswer/library/widgets/buttons/oultined_action_button.dart';
import 'package:lastanswer/library/widgets/core/responsive_widget.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:recase/recase.dart';

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

        WidgetsBinding.instance.addPostFrameCallback((final _) {
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

    return PortalTarget(
      visible: popupVisible.value,
      anchor: Aligned(
        follower:
            screenLayout.large ? Alignment.bottomLeft : Alignment.bottomRight,
        target: screenLayout.large ? Alignment.topRight : Alignment.topLeft,
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
                  child: OutlinedPrimaryCloseButton(
                    onPressed: () => close(context),
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
    return DecoratedActionButton(
      onPressed: onTap,
      filled: filled,
      iconData: useIcon ? Icons.delete_forever_rounded : null,
      text: text,
    );
  }
}

class OutlinedPrimaryCloseButton extends StatelessWidget {
  const OutlinedPrimaryCloseButton({
    required this.onPressed,
    this.useIcon = false,
    final Key? key,
  }) : super(key: key);
  final VoidCallback? onPressed;
  final bool useIcon;
  @override
  Widget build(final BuildContext context) {
    return OutlinedActionButton(
      onPressed: onPressed,
      iconData: useIcon ? Icons.check : null,
      text: S.current.close.sentenceCase,
    );
  }
}
