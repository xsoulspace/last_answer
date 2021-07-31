part of home;

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    final this.onPressed,
    final Key? key,
  }) : super(key: key);
  final VoidCallback? onPressed;
  @override
  Widget build(final BuildContext context) => Column(
        children: [
          const Text('Hello World!'),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(primary: Colors.blue),
            child: Row(
              children: const [
                Icon(
                  Icons.wb_sunny,
                  key: Key('icon_weather'),
                ),
                Text('Weather today')
              ],
            ),
          ),
        ],
      );
  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed));
  }
}
