import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';

class CreateIdeaProjectScreen extends StatefulHookWidget {
  const CreateIdeaProjectScreen({
    required this.onBack,
    required this.onCreate,
    super.key,
  });
  final VoidCallback onBack;
  final ValueChanged<String> onCreate;

  @override
  State<CreateIdeaProjectScreen> createState() =>
      _CreateIdeaProjectScreenState();
}

class _CreateIdeaProjectScreenState extends State<CreateIdeaProjectScreen> {
  final _textFieldFocusNode = FocusNode();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      FocusScope.of(context).requestFocus(_textFieldFocusNode);
    });
    super.initState();
  }

  @override
  void dispose() {
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final textController = useTextEditingController();
    final effectiveInputDecoration = const InputDecoration()
        .applyDefaults(
          Theme.of(context).inputDecorationTheme,
        )
        .copyWith(
          hintText: context.l10n.createIdeaHelperText,
          border: const UnderlineInputBorder(),
        );

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: BackTextUniversalAppBar(
        titleStr: '',
        onBack: widget.onBack,
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
                  const IconIdeaButton(size: 76),
                  const SizedBox(height: 44),
                  Text(
                    context.l10n.whatsYourIdea,
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 87),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          onSubmitted: (final _) =>
                              widget.onCreate(textController.text),
                          focusNode: _textFieldFocusNode,
                          controller: textController,
                          maxLength: 90,
                          style: Theme.of(context).textTheme.displayLarge,
                          decoration: effectiveInputDecoration,
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: () => widget.onCreate(textController.text),
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
