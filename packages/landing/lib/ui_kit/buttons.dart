import 'package:jaspr/jaspr.dart';

class StyledButtonDecoration {
  const StyledButtonDecoration(String classes,
      {this.edgeInsets = 'px-3 py-2', this.textStyle = 'text-sm font-semibold'})
      : classes = 'duration-100 $classes';
  static const filled = StyledButtonDecoration(
    'bg-emerald-500 hover:bg-emerald-600 '
    'active:bg-emerald-700 text-white '
    'rounded-full focus:outline-none',
  );
  static const text = StyledButtonDecoration('');
  final String classes;
  final String edgeInsets;
  final String textStyle;

  @override
  String toString() => [edgeInsets, classes, textStyle].join(' ');

  StyledButtonDecoration copyWith({String? edgeInsets, String? textStyle}) =>
      StyledButtonDecoration(
        classes,
        edgeInsets: edgeInsets ?? this.edgeInsets,
        textStyle: textStyle ?? this.textStyle,
      );
}

class StyledButton extends StatelessComponent {
  const StyledButton({
    required this.decoration,
    this.titleText = '',
    this.onClick,
    this.title,
    super.key,
  });
  final VoidCallback? onClick;
  final StyledButtonDecoration decoration;
  final String titleText;
  final Component? title;
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield button([title ?? text(titleText)],
        classes: decoration.toString(), onClick: onClick);
  }
}

typedef LiLinkButtonTuple = ({String title, String href});

class LiLinkButtonDecoration {
  const LiLinkButtonDecoration(String classes)
      : classes = 'duration-100 $classes';
  static const footerLink = LiLinkButtonDecoration(
    'text-xs text-stone-500/80 hover:text-stone-600/90',
  );
  static const homeAppBar = LiLinkButtonDecoration('hover:text-emerald-500');
  final String classes;
}

class LiLinkButton extends StatelessComponent {
  LiLinkButton({required this.item, required this.decoration});
  final LiLinkButtonDecoration decoration;
  final LiLinkButtonTuple item;
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield li([
      a([
        strong([text(item.title)])
      ], href: item.href, classes: decoration.classes)
    ]);
  }
}
