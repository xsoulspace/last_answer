part of home;

const _leftColumnWidth = 42.0;

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required final this.onProjectTap,
    required final this.onSettingsTap,
    required final this.onCreateIdeaTap,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<BasicProject> onProjectTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onCreateIdeaTap;
  @override
  Widget build(final BuildContext context) {
    // TODO(arenukvern): make the welcome dependant from platform day time
    const _welcome = 'Good evening';
    final _widgetSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(_welcome),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              // TODO(arenukvern): add push for info widget
              throw UnimplementedError();
            },
            icon: const Icon(Icons.info),
          ),
          IconButton(
            onPressed: () {
              // TODO(arenukvern): add push for settings widget
              throw UnimplementedError();
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                const SizedBox(height: 2),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    VerticalProjectBar(),
                    SizedBox(height: 14),
                  ],
                ),
                Expanded(
                  child: ListView.separated(
                    // TODO(arenukvern): add project tile
                    itemBuilder: (final _, final __) => Container(),
                    separatorBuilder: (final _, final __) =>
                        const SizedBox(height: 3),
                    // TODO(arenukvern): get projects count
                    itemCount: 1,
                  ),
                ),
              ],
            ),
          ),
          const SafeAreaBottom(),
        ],
      ),
    );
  }
}

class VerticalProjectBar extends StatelessWidget {
  const VerticalProjectBar({
    final Key? key,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 14,
        right: 14,
        bottom: 8,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        // TODO(arenukvern): add gradient
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Theme.of(context).splashColor,
        ),
        child: Wrap(
          direction: Axis.vertical,
          spacing: 16,
          children: [
            IconIdeaButton(
              onTap: () {
                // TODO(arenukvern): add push for settings widget
                throw UnimplementedError();
              },
            ),
            Text(
              S.current.idea,
              style: Theme.of(context).textTheme.caption,
            ),
            IconButton(
              onPressed: () {
                // TODO(arenukvern): add push for settings widget
                throw UnimplementedError();
              },
              icon: const Icon(Icons.book),
            ),
          ],
        ),
      ),
    );
  }
}
