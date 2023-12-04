import 'package:flutter/cupertino.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:wiredash/wiredash.dart';

class FeedbackProvider extends StatelessWidget {
  const FeedbackProvider({
    required this.child,
    super.key,
  });
  final Widget child;
  static void show(final BuildContext context) {
    Wiredash.of(context).show(
      inheritMaterialTheme: true,
      options: FeedbackProvider.feedbackOptions,
    );
  }

  @override
  Widget build(final BuildContext context) {
    if (!Envs.isFeedbackAvailable) return child;
    return Wiredash(
      projectId: Envs.wiredashProjectId,
      secret: Envs.wiredashProjectSecret,
      feedbackOptions: feedbackOptions,
      child: child,
    );
  }

  static const feedbackOptions = WiredashFeedbackOptions(
    labels: [
      // Take the label ids from your project console
      // https://console.wiredash.io/ -> Settings -> Labels
      Label(
        id: 'label-mlxjl2sa6f',
        title: 'Bug',
      ),
      Label(
        id: 'label-qu10qzqcf2',
        title: 'Feature request',
      ),
    ],
  );
}

class FeedbackButton extends StatelessWidget {
  const FeedbackButton({super.key});

  @override
  Widget build(final BuildContext context) => Visibility(
        visible: Envs.isFeedbackAvailable,
        child: IconButton(
          onPressed: () => FeedbackProvider.show(context),
          icon: const Icon(CupertinoIcons.exclamationmark_bubble),
        ),
      );
}
