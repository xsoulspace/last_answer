import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/features/features.dart';

class GithubSyncButton extends StatefulWidget {
  const GithubSyncButton({super.key});

  @override
  State<GithubSyncButton> createState() => _GithubSyncButtonState();
}

class _GithubSyncButtonState extends State<GithubSyncButton> {
  final GithubSyncNotifier _notifier = GithubSyncNotifier();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      if (!mounted) return;
      unawaited(_notifier.checkConnection(context));
    });
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    if (!GithubSyncNotifier.isSupported) {
      return Text(
        context.l10n.githubSync,
        style: context.textTheme.bodySmall,
      );
    }
    return ListenableBuilder(
      listenable: _notifier,
      builder: (final context, final _) {
        final connected = _notifier.connected;
        final connecting = _notifier.connecting;
        if (connecting) {
          return const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        return SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(context.l10n.githubSync),
          subtitle: Text(
            connected
                ? context.l10n.githubConnected
                : context.l10n.connectGithub,
          ),
          value: connected,
          onChanged: (final value) => unawaited(
            value ? _notifier.connect(context) : _notifier.disconnect(context),
          ),
        );
      },
    );
  }
}
