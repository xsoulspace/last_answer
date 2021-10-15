part of home;

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required final this.onProjectTap,
    required final this.onSettingsTap,
    required final this.onInfoTap,
    required final this.onCreateIdeaTap,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<BasicProject> onProjectTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onInfoTap;
  final VoidCallback onCreateIdeaTap;
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
        elevation: 0,
        backgroundColor: Colors.transparent,
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
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                const SizedBox(height: 2),
                ColoredBox(
                  color: Theme.of(context).primaryColor.withOpacity(.03),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      VerticalProjectBar(),
                      SizedBox(height: 14),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    restorationId: 'projects',
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
  void onIdea() {}
  void onNote() {}
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
              onTap: onIdea,
              label: S.current.idea,
              child: IconIdeaButton(
                onTap: onIdea,
              ),
            ),
            BarItem(
              onTap: onNote,
              label: S.current.note,
              child: IconButton(
                onPressed: onNote,
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
