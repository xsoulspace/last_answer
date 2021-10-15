part of idea_project;

class CreateIdeaProjectScreen extends HookWidget {
  const CreateIdeaProjectScreen({
    required final this.onBack,
    required final this.onCreate,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onBack;
  final ValueChanged<String> onCreate;
  @override
  Widget build(final BuildContext context) {
    final textController = useTextEditingController();
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: onBack,
        ),
      ),
      body: Center(
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
            TextField(
              controller: textController,
              decoration: InputDecoration(
                helperText: S.current.createIdeaHelperText,
                border: const UnderlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () => onCreate(textController.text),
                  icon: const Icon(Icons.send),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
