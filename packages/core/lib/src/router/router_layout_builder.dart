part of 'router.dart';

class RouterLayoutBuilder<TRouterController extends RouterController,
    TBuilder extends RouterPageBuilder<TRouterController>> {
  RouterLayoutBuilder({
    required this.pageBuilder,
  });
  final TBuilder pageBuilder;
  String get pathTemplate => pageBuilder.pathTemplate;

  List<Page> buildPages() {
    return [];
  }
}
