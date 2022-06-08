import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/hooks/hooks.dart';
import 'package:lastanswer/library/widgets/buttons/emoji_button.dart';
import 'package:lastanswer/library/widgets/core/emoji_grid.dart';
import 'package:lastanswer/library/widgets/core/safe_areas.dart';
import 'package:lastanswer/state/state.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:provider/provider.dart';

class SpecialEmojisKeyboardActions extends HookWidget {
  const SpecialEmojisKeyboardActions({
    required this.builder,
    required final this.controller,
    required this.focusNode,
    final Key? key,
  }) : super(key: key);
  final Widget Function(
    BuildContext context,
    VoidCallback showEmojiKeyboard,
    VoidCallback hideEmojiKeyboard,
    ValueNotifier<bool> isEmojiKeyboardOpen,
  ) builder;
  final FocusNode focusNode;
  final TextEditingController controller;
  @override
  Widget build(final BuildContext context) {
    final isEmojiKeyboardOpen = useIsBool();
    final isEmojiKeyboardOpening = useIsBool();
    if (isNativeDesktop || kIsWeb) {
      return builder(context, () {}, () {}, isEmojiKeyboardOpen);
    }

    final emojiKeyboardController = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );
    final emojiKeyboardHeight = useAnimation(
      Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(
          0,
          SpecialEmojisKeyboard.height,
        ),
      ).animate(
        CurvedAnimation(
          parent: emojiKeyboardController,
          curve: Curves.linearToEaseOut,
        ),
      ),
    );

    Future<void> closeEmojiKeyboard({final bool immediately = true}) async {
      if (immediately) {
        emojiKeyboardController.reset();
        isEmojiKeyboardOpen.value = false;
      } else {
        await emojiKeyboardController.reverse();
        isEmojiKeyboardOpen.value = false;
      }
    }

    useEffect(
      () {
        Future.delayed(
          const Duration(milliseconds: 110),
          () {
            final keyboardOpen = window.viewInsets.bottom > 0;
            if (keyboardOpen &&
                isEmojiKeyboardOpen.value &&
                !isEmojiKeyboardOpening.value) {
              closeEmojiKeyboard();
            }
          },
        );

        return null;
      },
      [window.viewInsets.bottom],
    );

    final emojiInserter = EmojiInserter.use(
      controller: controller,
      focusNode: focusNode,
      requestFocusOnInsert: false,
    );
    final footer = SpecialEmojisKeyboard(
      onChanged: emojiInserter.insert,
      onHide: () => closeEmojiKeyboard(immediately: false),
      onShowKeyboard: () {
        if (focusNode.hasFocus) {
          SoftKeyboard.open();
        } else {
          focusNode.requestFocus();
        }
      },
    );
    Future<void> showEmojiKeyboard() async {
      if (isEmojiKeyboardOpen.value) {
        await closeEmojiKeyboard(immediately: false);
      } else {
        isEmojiKeyboardOpening.value = true;
        await SoftKeyboard.close();
        isEmojiKeyboardOpen.value = true;
        await emojiKeyboardController.forward();
        await Future.delayed(const Duration(milliseconds: 400));
        isEmojiKeyboardOpening.value = false;
      }
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  child: builder(
                    context,
                    showEmojiKeyboard,
                    closeEmojiKeyboard,
                    isEmojiKeyboardOpen,
                  ),
                ),
              ),
              SizedBox(
                height: isEmojiKeyboardOpen.value
                    ? emojiKeyboardHeight.dy
                    : window.viewInsets.bottom / window.devicePixelRatio,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: emojiKeyboardHeight.dy - SpecialEmojisKeyboard.height,
          left: 0,
          right: 0,
          child: Offstage(
            offstage: !isEmojiKeyboardOpen.value,
            child: footer,
          ),
        ),
      ],
    );
  }
}

class SpecialEmojisKeyboard extends HookWidget implements PreferredSizeWidget {
  const SpecialEmojisKeyboard({
    required this.onChanged,
    required this.onShowKeyboard,
    required this.onHide,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<Emoji> onChanged;
  final VoidCallback onShowKeyboard;
  final VoidCallback onHide;
  static const height = 200.0;
  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(final BuildContext context) {
    final specialEmojisProvider = context.read<SpecialEmojiProvider>();
    final emojis = specialEmojisProvider.values;
    final theme = Theme.of(context);
    final emojiStyle = theme.textTheme.headline1?.copyWith(fontSize: 26);

    Widget buildEmojiButton(final Emoji emoji) {
      return KeyboardEmojiButton(
        key: ValueKey(emoji),
        emoji: emoji,
        style: emojiStyle,
        onPressed: () => onChanged(emoji),
      );
    }

    return Container(
      color: theme.highlightColor.withOpacity(0.1),
      height: preferredSize.height,
      width: preferredSize.width,
      child: Column(
        children: [
          const SizedBox(height: 4),
          Expanded(
            child: GridView.count(
              restorationId: 'special-emojis-grid',
              shrinkWrap: true,
              crossAxisCount: 10,
              semanticChildCount: emojis.length,
              mainAxisSpacing: 12,
              crossAxisSpacing: 2,
              padding: EdgeInsets.zero,
              children: emojis.map(buildEmojiButton).toList(),
            ),
          ),
          const BottomSafeArea(),
        ],
      ),
    );
  }
}
