import 'package:jaspr/jaspr.dart';

/// https://fonts.google.com/icons?selected=Material+Symbols+Outlined:chevron_right:FILL@0;wght@400;GRAD@0;opsz@24&icon.query=arrow
class MaterialIcons {
  static const chevronRight = UiIcon('chevron_right');
}

class UiIcon {
  const UiIcon(this.code);
  final String code;
  @override
  String toString() => code;
}

class IconSpan extends StatelessComponent {
  const IconSpan({required this.icon, super.key});
  final UiIcon icon;
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield span([text('$icon')], classes: 'material-symbols-outlined p-0 m-0');
  }
}
