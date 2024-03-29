import 'dart:io';

import 'package:server/src/web/widgets/default_page_widget.dart';
import 'package:serverpod/serverpod.dart';

class RouteRoot extends WidgetRoute {
  @override
  Future<Widget> build(
    final Session session,
    final HttpRequest request,
  ) async =>
      DefaultPageWidget();
}
