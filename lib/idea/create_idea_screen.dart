import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';

class CreateIdeaProjectScreen extends StatefulHookWidget {
  const CreateIdeaProjectScreen({
    super.key,
  });

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
    final color = context.colorScheme.onBackground.withOpacity(0.75);
    final textColor = context.colorScheme.onPrimaryContainer;

    void onCreate() {
      final text = _textController.text;
      if (text.isNotEmpty) {
        projectNotifier.createIdeaProject(context: context, title: text);
      }
      onBack();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: BackTextUniversalAppBar(
        titleStr: '',
        onBack: onBack,
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
                  IconIdeaButton(
                    size: 84,
                    onTap: () {},
                    color: color.withOpacity(0.4),
                  ),
                  const Gap(44),
                  Text(
                    context.l10n.whatsYourIdea,
                    style: context.textTheme.displaySmall?.copyWith(
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(87),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          autofocus: true,
                          onFieldSubmitted: (final _) => onCreate(),
                          controller: _textController,
                          maxLength: 90,
                          maxLines: null,
                          style: context.textTheme.displaySmall?.copyWith(
                            color: textColor,
                          ),
                          decoration: InputDecoration(
                            hintText: context.l10n.createIdeaHelperText,
                            border: const UnderlineInputBorder(),
                          ),
                        ),
                      ),
                      const Gap(6),
                      IconButton(
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
