import 'package:jaspr/ui.dart';
import 'package:landing/app.dart';

class StyledButtonDecoration {
  const StyledButtonDecoration(
    this.classes, {
    this.edgeInsets = 'px-3 py-2',
    this.textStyle = 'text-sm font-semibold',
    this.transitions = 'duration-100',
  });
  static const filled = StyledButtonDecoration(
    'bg-emerald-500 hover:bg-emerald-600 '
    'active:bg-emerald-700 text-white '
    'rounded-full focus:outline-none',
  );
  static const outlined = StyledButtonDecoration(
    'border border-emerald-500 hover:border-emerald-600 active:border-emerald-700 '
    'text-emerald-500 hover:text-emerald-600 text-center '
    'rounded-full bg-emerald-200/20 hover:bg-emerald-200/40 active:bg-emerald-700'
    'focus:outline-none',
    textStyle: 'text-sm',
  );
  static const text = StyledButtonDecoration('');
  final String classes;
  final String edgeInsets;
  final String textStyle;
  final String transitions;

  @override
  String toString() =>
      [edgeInsets, classes, textStyle, 'cursor-pointer'].join(' ');

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

typedef LinkButtonTuple = ({String title, String url});

class LiLinkButtonDecoration {
  const LiLinkButtonDecoration(
    this.classes, {
    this.textStyle = 'font-normal',
    this.transitions = 'duration-100',
  });
  static const stone900 = LiLinkButtonDecoration(
    'text-stone-900/80 hover:text-stone-900/90',
    textStyle: 'text-xs',
  );
  static const stone = LiLinkButtonDecoration(
    'text-stone-500/80 hover:text-stone-600/90',
    textStyle: 'text-xs',
  );
  static const emeraldLight = LiLinkButtonDecoration('hover:text-emerald-500');
  static final emeraldNormal = emeraldLight.copyWith(textStyle: 'font-normal');
  final String classes;
  final String textStyle;
  final String transitions;

  LiLinkButtonDecoration copyWith({String? textStyle}) =>
      LiLinkButtonDecoration(
        classes,
        textStyle: textStyle ?? this.textStyle,
      );

  @override
  String toString() => [classes, textStyle, transitions].join(' ');
}

class LiLinkButton extends StatelessComponent {
  LiLinkButton({
    required this.item,
    required this.decoration,
    this.openInNewTab = false,
  });
  final LiLinkButtonDecoration? decoration;
  final LinkButtonTuple item;
  final bool openInNewTab;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield li([
      LinkButton(
        titleText: item.title,
        url: item.url,
        liDecoration: decoration,
        openInNewTab: openInNewTab,
      )
    ]);
  }
}

class LinkButton extends StatelessComponent {
  const LinkButton({
    this.liDecoration,
    this.styledDecoration,
    this.openInNewTab = false,
    this.title,
    this.titleText = '',
    this.url = '',
    super.key,
  }) : classes = '';
  const LinkButton.raw({
    this.openInNewTab = false,
    this.title,
    this.titleText = '',
    this.url = '',
    this.classes = '',
    super.key,
  })  : liDecoration = null,
        styledDecoration = null;
  final Component? title;
  final String titleText;
  final String url;
  final bool openInNewTab;
  final LiLinkButtonDecoration? liDecoration;
  final StyledButtonDecoration? styledDecoration;
  final String classes;
  @override
  Iterable<Component> build(BuildContext context) sync* {
    assert(url.isNotEmpty);

    final classes =
        (liDecoration ?? styledDecoration)?.toString() ?? this.classes;
    final title = this.title;
    final shouldUseA =
        url.startsWith('https://') || url.startsWith('http://') || openInNewTab;

    final children = [title ?? text(titleText)];
    // TODO(arenukvern): description, https://github.com/schultek/jaspr/issues/180
    if (shouldUseA) {
      yield a(
        children,
        href: url,
        target: shouldUseA ? Target.blank : null,
        classes: classes,
      );
    } else {
      yield button(
        children,
        onClick: () => context.router.pushNamed(url),
        classes: classes,
      );
    }
  }
}
