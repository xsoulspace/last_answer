import 'package:flutter/material.dart';

extension WidgetX on Widget {
  SliverToBoxAdapter sliver() => SliverToBoxAdapter(child: this);
}
