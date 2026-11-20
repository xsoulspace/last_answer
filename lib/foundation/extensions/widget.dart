import 'package:material_ui/material_ui.dart' show Brightness, Colors, DefaultMaterialLocalizations, GlobalMaterialLocalizations, Icons, MaterialLocalizations, SliverToBoxAdapter, ThemeMode, Widget;

extension WidgetX on Widget {
  SliverToBoxAdapter sliver() => SliverToBoxAdapter(child: this);
}
