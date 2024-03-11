import 'package:jaspr/jaspr.dart';

class ResponsiveBreakpointType {
  ResponsiveBreakpointType({
    this.sm = '',
    this.md = '',
    this.lg = '',
    this.xl = '',
    this.xxl = '',
  });
  final String sm;
  final String md;
  final String lg;
  final String xl;
  final String xxl;
}

/// will use m-{value} to define spacing
class Spacer extends StatelessComponent {
  const Spacer.x(final String value, {super.key}) : value = 'mr-$value';
  const Spacer.y(final String value, {super.key}) : value = 'mt-$value';
  final String value;
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div([], classes: value);
  }
}
