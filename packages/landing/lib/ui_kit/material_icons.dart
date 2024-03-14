import 'package:jaspr/jaspr.dart';

/// https://fonts.google.com/icons?selected=Material+Symbols+Outlined:chevron_right:FILL@0;wght@400;GRAD@0;opsz@24&icon.query=arrow
class MaterialIcons {
  static const chevronRight = UiIcon('chevron_right');
  static const downloadForOffline = UiIcon('download_for_offline');
  static const download = UiIcon('download');
  static const openInNew = UiIcon('open_in_new');
}

class UiIcon {
  const UiIcon(this.code);
  final String code;
  @override
  String toString() => code;
}

class IconSpan extends StatelessComponent {
  const IconSpan({required this.icon, this.classes = '', super.key});
  final UiIcon icon;
  final String classes;
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield span([text('$icon')],
        classes: 'material-symbols-outlined p-0 m-0 $classes');
  }
}
