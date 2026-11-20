import 'package:server/src/web/widgets/default_page_widget.dart';
import 'package:serverpod/serverpod.dart';

class RouteRoot extends WidgetRoute {
  @override
  Future<WebWidget> build(final Session session, final Request request) async =>
      DefaultPageWidget();
}
