import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core.dart';

extension BuildContextExtension on BuildContext {
  S get l10n => S.of(this);
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  GoRouter get router => GoRouter.of(this);
}
