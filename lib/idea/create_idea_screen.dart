import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/widgets/legacy_kit/legacy_kit.dart';

class CreateIdeaProjectScreen extends StatefulHookWidget {
  const CreateIdeaProjectScreen({super.key});

  @override
  State<CreateIdeaProjectScreen> createState() =>
      _CreateIdeaProjectScreenState();
}

class _CreateIdeaProjectScreenState extends State<CreateIdeaProjectScreen> {
  final _textController = TextEditingController();
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final projectNotifier = context.read<OpenedProjectNotifier>();
    void onBack() => Navigator.pop(context);
    final laUi = context.laUi;
    final color = laUi.ink.withValues(alpha: 0.75);
    final textColor = laUi.ink;

    void onCreate() {
      final text = _textController.text;
      if (text.isNotEmpty) {
        projectNotifier.createIdeaProject(context: context, title: text);
      }
      onBack();
    }

    return LaScaffold(
      topBar: LaTopBar(
        leading: LaButton.icon(
          icon: const LaClose(),
          onPressed: onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 8),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ScreenLayout.maxFullscreenPageWidth,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LaPressable(
                    onTap: () {},
                    showRing: false,
                    scaleOnPress: false,
                    child: Assets.icons.idea.svg(
                      height: 84,
                      width: 84,
                      colorFilter: ColorFilter.mode(
                        color.withValues(alpha: 0.4),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const Gap(44),
                  Text(
                    context.l10n.whatsYourIdea,
                    style: laUi.display.copyWith(color: color),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(87),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: LaField(
                          autofocus: true,
                          onSubmitted: (final _) => onCreate(),
                          controller: _textController,
                          maxLength: 90,
                          style: laUi.display.copyWith(color: textColor),
                          placeholder: context.l10n.createIdeaHelperText,
                        ),
                      ),
                      const Gap(6),
                      LaButton.icon(
                        onPressed: onCreate,
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
