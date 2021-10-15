part of home;

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required final this.onProjectTap,
    required final this.onSettingsTap,
    required final this.onInfoTap,
    required final this.onCreateIdeaTap,
    required final this.onCreateNoteTap,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<BasicProject> onProjectTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onInfoTap;
  final VoidCallback onCreateIdeaTap;
  final VoidCallback onCreateNoteTap;
  @override
  Widget build(final BuildContext context) {
    // TODO(arenukvern): make the welcome dependant from platform day time
    const _welcome = 'Good evening';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _welcome,
          style: Theme.of(context).textTheme.headline1,
        ),
        actions: [
          IconButton(
            onPressed: onInfoTap,
            icon: const Icon(Icons.info),
          ),
          IconButton(
            onPressed: onSettingsTap,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Row(
        children: [
          const SizedBox(height: 2),
          ColoredBox(
            color: Theme.of(context).primaryColor.withOpacity(.03),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                VerticalProjectBar(
                  onIdeaTap: onCreateIdeaTap,
                  onNoteTap: onCreateNoteTap,
                ),
                const SizedBox(height: 14),
                const SafeAreaBottom(),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(5),
                    reverse: true,
                    restorationId: 'projects',
                    itemBuilder: (final _, final __) {
                      final key = '';
                      return ProjectTile(
                        key: ValueKey(key),
                      );
                    },
                    separatorBuilder: (final _, final __) =>
                        const SizedBox(height: 3),
                    // TODO(arenukvern): get projects count
                    itemCount: 1,
                  ),
                ),
                const SafeAreaBottom(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VerticalProjectBar extends StatelessWidget {
  const VerticalProjectBar({
    required final this.onIdeaTap,
    required final this.onNoteTap,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onIdeaTap;
  final VoidCallback onNoteTap;
  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 6,
        right: 6,
        bottom: 8,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 6,
        ),
        // TODO(arenukvern): add gradient
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Theme.of(context).splashColor,
        ),
        child: Wrap(
          direction: Axis.vertical,
          spacing: 16,
          children: [
            BarItem(
              onTap: onIdeaTap,
              label: S.current.idea,
              child: IconIdeaButton(
                onTap: onIdeaTap,
              ),
            ),
            BarItem(
              onTap: onNoteTap,
              label: S.current.note,
              child: IconButton(
                onPressed: onNoteTap,
                icon: const Icon(Icons.book),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BarItem extends StatelessWidget {
  const BarItem({
    required final this.onTap,
    required final this.child,
    required final this.label,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onTap;
  final Widget child;
  final String label;
  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Stack(
          children: [
            SizedBox(
              height: 50,
              child: child,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
