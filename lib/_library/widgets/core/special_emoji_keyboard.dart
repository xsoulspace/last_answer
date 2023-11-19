import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';

part 'special_emoji_keyboard.freezed.dart';

@freezed
class SpecialEmojisKeyboardControllerState
    with _$SpecialEmojisKeyboardControllerState {
  const factory SpecialEmojisKeyboardControllerState({
    @Default(false) final bool isKeyboardOpen,
    @Default(false) final bool isKeyboardOpening,
  }) = _SpecialEmojisKeyboardControllerState;
}

class SpecialEmojiController
    extends ValueNotifier<SpecialEmojisKeyboardControllerState> {
  SpecialEmojiController({
    required this.focusNode,
    required this.textController,
    required final TickerProvider tickerProvider,
  })  : _animationController = AnimationController(
          vsync: tickerProvider,
          duration: const Duration(milliseconds: 200),
        ),
        super(const SpecialEmojisKeyboardControllerState());
  final FocusNode focusNode;
  final TextEditingController textController;
  final AnimationController _animationController;
  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  late final _animation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(
      0,
      SpecialEmojisKeyboard.height,
    ),
  ).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: Curves.linearToEaseOut,
    ),
  );
  Offset get keyboardOffset => _animation.value;
  Future<void> closeEmojiKeyboard({final bool immediately = true}) async {
    if (immediately) {
      _animationController.reset();
    } else {
      await _animationController.reverse();
    }
    setValue(value.copyWith(isKeyboardOpen: false));
  }

  Future<void> switchEmojiKeyboard() async {
    if (value.isKeyboardOpen) {
      await closeEmojiKeyboard(immediately: false);
    } else {
      setValue(value.copyWith(isKeyboardOpening: true));
      await SoftKeyboard.close();
      setValue(value.copyWith(isKeyboardOpen: true));
      await _animationController.forward();
      await Future.delayed(const Duration(milliseconds: 400));
      setValue(value.copyWith(isKeyboardOpening: false));
    }
  }

  void showSoftKeyboard() {
    if (focusNode.hasFocus) {
      unawaited(SoftKeyboard.open());
    } else {
      focusNode.requestFocus();
    }
  }

  late final emojiInserter = EmojiInserter.use(
    controller: textController,
    focusNode: focusNode,
    requestFocusOnInsert: false,
  );
}

class SpecialEmojiKeyboardProvider extends HookWidget {
  const SpecialEmojiKeyboardProvider({
    required this.controller,
    required this.builder,
    super.key,
  });
  final SpecialEmojiController controller;
  final WidgetBuilder builder;

  @override
  Widget build(final BuildContext context) {
    if (PlatformInfo.isNativeDesktop || kIsWeb) return builder(context);
    final state = controller.value;
    final view = View.of(context);
    useEffect(
      () {
        Future.delayed(
          const Duration(milliseconds: 110),
          () async {
            final isSystemKeyboardOpen = view.viewInsets.bottom > 0;
            if (isSystemKeyboardOpen &&
                state.isKeyboardOpen &&
                !state.isKeyboardOpening) {
              await controller.closeEmojiKeyboard();
            }
          },
        );

        return null;
      },
      [view.viewInsets.bottom],
    );

    final keyboardOffset = controller.keyboardOffset;

    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  child: builder(context),
                ),
              ),
              SizedBox(
                height: controller.value.isKeyboardOpen
                    ? keyboardOffset.dy
                    : window.viewInsets.bottom / window.devicePixelRatio,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: keyboardOffset.dy - SpecialEmojisKeyboard.height,
          left: 0,
          right: 0,
          child: Offstage(
            offstage: !controller.value.isKeyboardOpen,
            child: SpecialEmojisKeyboard(
              onChanged: controller.emojiInserter.insert,
              onHide: () async =>
                  controller.closeEmojiKeyboard(immediately: false),
              onShowKeyboard: controller.showSoftKeyboard,
            ),
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
    super.key,
  });
  final ValueChanged<EmojiModel> onChanged;
  final VoidCallback onShowKeyboard;
  final VoidCallback onHide;
  static const height = 200.0;
  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(final BuildContext context) {
    final specialEmojisProvider = context.read<SpecialEmojiStateNotifier>();
    final emojis = specialEmojisProvider.values;
    final theme = Theme.of(context);
    final emojiStyle = theme.textTheme.displayLarge?.copyWith(fontSize: 26);

    Widget buildEmojiButton(final EmojiModel emoji) => KeyboardEmojiButton(
          key: ValueKey(emoji),
          emoji: emoji,
          style: emojiStyle,
          onPressed: () => onChanged(emoji),
        );

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
