part of pack_app;

class _ValueKeys {
  _ValueKeys._();
  static const _home = ValueKey<String>('home');
  static const _settings = ValueKey<String>('settings');
  static const _generalSettings = ValueKey<String>('settings/general');
  static const _info = ValueKey<String>('info');

  static const _notes = ValueKey<String>('notes');
  static const _notesNote = ValueKey<String>('notes/note');
  static const _createIdea = ValueKey<String>('createIdea');
  static const _ideas = ValueKey<String>('ideas');
  static const _ideasIdea = ValueKey<String>('ideas/idea');
  static const _ideasIdeaAnswer = ValueKey<String>('ideas/idea/answer');
  static final _largeScreenHomeNavigator = GlobalKey();
}

/// Builds the top-level navigator for the app. The pages to display are based
/// on the `routeState` that was parsed by the TemplateRouteParser.
class AppNavigator extends StatefulWidget {
  const AppNavigator({
    required final this.navigatorKey,
    required final this.routeState,
    final Key? key,
  }) : super(key: key);
  final GlobalKey<NavigatorState> navigatorKey;
  final RouteState routeState;
  @override
  _AppNavigatorState createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  @override
  void initState() {
    super.initState();
    final notificationController = context.read<NotificationController>();
    if (notificationController.hasUnreadUpdates) {
      WidgetsBinding.instance?.addPostFrameCallback((final _) {
        showNotificationPopup(
          context: widget.navigatorKey.currentContext!,
          notificationController: notificationController,
        );
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    final popper = AppNavigatorPopper(
      routeState: widget.routeState,
      context: context,
    );
    final pageBuilder = AppNavigatorPageBuilder(
      popper: popper,
      context: context,
    );
    final layoutBuilder = AppNavigatorLayoutBuilder(
      pageBuilder: pageBuilder,
    );

    return ResponsiveNavigator(
      navigatorKey: widget.navigatorKey,
      onLargeScreen: layoutBuilder.getLargeScreenPages,
      onSmallScreen: layoutBuilder.getSmallScreenPages,
      onPopPage: popper.onPopPage,
    );
  }
}
