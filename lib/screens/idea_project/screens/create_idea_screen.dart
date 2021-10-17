part of idea_project;

class CreateIdeaProjectScreen extends StatefulHookWidget {
  const CreateIdeaProjectScreen({
    required final this.onBack,
    required final this.onCreate,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onBack;
  final ValueChanged<String> onCreate;

  @override
  State<CreateIdeaProjectScreen> createState() =>
      _CreateIdeaProjectScreenState();
}

class _CreateIdeaProjectScreenState extends State<CreateIdeaProjectScreen> {
  final focusNode = FocusNode();
  @override
  void initState() {
    focusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final textController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: widget.onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const IconIdeaButton(size: 76),
              const SizedBox(height: 44),
              Text(
                S.current.whatsYourIdea,
                style: Theme.of(context).textTheme.headline1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 87),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: focusNode,
                      controller: textController,
                      maxLength: 90,
                      style: Theme.of(context).textTheme.headline1,
                      decoration: const InputDecoration()
                          .applyDefaults(Theme.of(context).inputDecorationTheme)
                          .copyWith(
                            hintText: S.current.createIdeaHelperText,
                            border: const UnderlineInputBorder(),
                          ),
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
    );
  }
}