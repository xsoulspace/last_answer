part of widgets;

class DiscordButton extends StatelessWidget {
  const DiscordButton({this.text, super.key});
  static const discordLink = 'https://discord.gg/y54DpJwmAn';
  final String? text;
  @override
  Widget build(final BuildContext context) => TextButton(
      onPressed: () async {
        if (await url_launcher.canLaunch(discordLink)) {
          await url_launcher.launch(discordLink);
        }
      },
      child: Text(
        text ?? S.current.joinDiscord,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
}
