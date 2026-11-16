/// Legacy-kit port of `_library/widgets/core/special_emoji_keyboard.dart`
/// (+ the `SpecialEmojiButton`/`SpecialEmojisGrid` it rode).
///
/// Controller/keyboard animation/insertion logic is carried over VERBATIM
/// (the freezed state class is re-expressed as a plain immutable value with
/// the same fields and `copyWith`). Presentation is rebuilt over GridView +
/// kit components; the popup rides [LaMenuAnchor]. Public API identical to
/// the original.
library;

import 'package:flutter/foundation.dart' show immutable, kIsWeb;
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/widgets/legacy_kit/emoji.dart';
import 'package:lastanswer/widgets/legacy_kit/safe_areas.dart';

@immutable
class SpecialEmojisKeyboardControllerState {
  const SpecialEmojisKeyboardControllerState({
    this.isKeyboardOpen = false,
    this.isKeyboardOpening = false,
  });
  final bool isKeyboardOpen;
  final bool isKeyboardOpening;

  SpecialEmojisKeyboardControllerState copyWith({
    final bool? isKeyboardOpen,
    final bool? isKeyboardOpening,
  }) => SpecialEmojisKeyboardControllerState(
    isKeyboardOpen: isKeyboardOpen ?? this.isKeyboardOpen,
    isKeyboardOpening: isKeyboardOpening ?? this.isKeyboardOpening,
  );

  @override
  bool operator ==(final Object other) =>
      other is SpecialEmojisKeyboardControllerState &&
      other.isKeyboardOpen == isKeyboardOpen &&
      other.isKeyboardOpening == isKeyboardOpening;

  @override
  int get hashCode => Object.hash(isKeyboardOpen, isKeyboardOpening);
}

class SpecialEmojiController
    extends ValueNotifier<SpecialEmojisKeyboardControllerState> {
  SpecialEmojiController({
    required this.focusNode,
    required this.textController,
    required final TickerProvider tickerProvider,
  }) : _animationController = AnimationController(
         vsync: tickerProvider,
         duration: const Duration(milliseconds: 365),
       ),
       super(const SpecialEmojisKeyboardControllerState());
  final FocusNode focusNode;
  final TextEditingController textController;
  final AnimationController _animationController;
  @override
  void dispose() {
    _animation.removeListener(notifyListeners);
    _animationController.dispose();
    super.dispose();
  }

  late final _animation =
      Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, SpecialEmojisKeyboard.height),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOutExpo,
          ),
        )
        ..addListener(notifyListeners);
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
    if (PlatformInfo.isNativeWebDesktop) return builder(context);
    useListenable(controller);
    final keyboardOffset = controller.keyboardOffset;

    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              Expanded(child: GestureDetector(child: builder(context))),
              AnimatedBuilder(
                animation: controller,
                builder: (final context, final child) => SizedBox(
                  height:
                      controller.value.isKeyboardOpen ||
                          controller.value.isKeyboardOpening
                      ? keyboardOffset.dy
                      : 0,
                ),
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
              onHide: () {
                unawaited(controller.closeEmojiKeyboard(immediately: false));
              },
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
    final emojis = specialEmojisProvider.orderedValues;
    final laUi = context.laUi;
    final emojiStyle = laUi.display.copyWith(fontSize: 26);

    Widget buildEmojiButton(final EmojiModel emoji) => KeyboardEmojiButton(
      key: ValueKey(emoji),
      emoji: emoji,
      style: emojiStyle,
      onPressed: () => onChanged(emoji),
    );

    return Container(
      color: laUi.surfaceRaised,
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

/// The pinned-emoji popup grid (was wrapped in the legacy `ButtonPopup`).
class SpecialEmojisGrid extends StatelessWidget {
  const SpecialEmojisGrid({
    required this.onChanged,
    this.hideBorder = false,
    super.key,
  });
  final ValueChanged<EmojiModel> onChanged;
  final bool hideBorder;
  @override
  Widget build(final BuildContext context) {
    final emojiStyle = context.laUi.body;

    Widget buildEmojiButton(final EmojiModel emoji) => EmojiButton(
      key: ValueKey(emoji),
      emoji: emoji,
      style: emojiStyle,
      onPressed: () => onChanged(emoji),
    );

    final specialEmojisNotifier = context.watch<SpecialEmojiStateNotifier>();
    final emojis = specialEmojisNotifier.orderedValues;
    const maxItemsInRow = 9;

    return SizedBox(
      height: 200,
      width: !PlatformInfo.isNativeDesktop && !kIsWeb
          ? MediaQuery.of(context).size.width - 50
          : 250,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: GridView.count(
              restorationId: 'special-emojis-grid',
              shrinkWrap: true,
              crossAxisCount: maxItemsInRow,
              semanticChildCount: emojis.length,
              padding: const EdgeInsets.only(right: 12),
              children: emojis.map(buildEmojiButton).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// The special-emoji trigger (was the `_library` `SpecialEmojiButton`,
/// riding `PopupButton`/`IconButton`): mobile toggles the docked keyboard,
/// desktop/web opens the pinned grid in the kit menu.
class SpecialEmojiButton extends StatelessWidget {
  const SpecialEmojiButton({required this.controller, super.key});
  final SpecialEmojiController controller;

  @override
  Widget build(final BuildContext context) {
    if (!PlatformInfo.isNativeDesktop && !PlatformInfo.isWeb) {
      return LaButton.icon(
        onPressed: controller.switchEmojiKeyboard,
        icon: const Icon(Icons.emoji_flags_rounded),
      );
    }
    return LaMenuAnchor.builder(
      closeOnActivate: false,
      entries: [
        LaMenuCustom(
          SpecialEmojisGrid(onChanged: controller.emojiInserter.insert),
        ),
      ],
      childBuilder: (final context, final anchor) => LaButton.icon(
        icon: const Icon(Icons.emoji_flags_rounded),
        onPressed: anchor.toggle,
      ),
    );
  }
}
