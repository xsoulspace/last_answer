import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lastanswer/library/widgets/core/hoverable_area.dart';

class HovarableListTile extends StatelessWidget {
  const HovarableListTile({
    required this.onTap,
    this.titleBuilder,
    this.leadingBuilder,
    final Key? key,
  }) : super(key: key);
  final HoverableWidgetBuilder? leadingBuilder;
  final HoverableWidgetBuilder? titleBuilder;
  final VoidCallback onTap;
  @override
  Widget build(final BuildContext context) {
    return HoverableArea(
      builder: (final context, final hovered) => ListTile(
        onTap: onTap,
        leading: leadingBuilder?.call(context, hovered),
        title: titleBuilder?.call(context, hovered),
      ),
    );
  }
}
