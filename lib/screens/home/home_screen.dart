part of home;

const _leftPadding = 2.0;
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
      body: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              VerticalProjectBar(),
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
    );
  }
}

class VerticalProjectBar extends StatelessWidget {
  const VerticalProjectBar({
    final Key? key,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      // TODO(arenukvern): add gradient
      decoration: const BoxDecoration(),
      child: Wrap(
        direction: Axis.vertical,
        runSpacing: 10,
        children: [
          SvgIconButton(
            onPressed: () {
              // TODO(arenukvern): add push for settings widget
              throw UnimplementedError();
            },
            svg: Assets.icons.idea,
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
    );
  }
}
