part of widgets;

class JoinDiscordButton extends StatelessWidget {
  const JoinDiscordButton({final this.text, final Key? key}) : super(key: key);
  static const discordLink = 'https://discord.gg/y54DpJwmAn';
  final String? text;
  @override
  Widget build(final BuildContext context) {
    return TextButton(
      onPressed: () async {
        final uri = Uri.parse(discordLink);
        if (await url_launcher.canLaunchUrl(uri)) {
          await url_launcher.launchUrl(uri);
        }
      },
      child: Text(
        text ?? S.current.joinDiscord,
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }
}

class SignInDiscordButton extends StatelessWidget {
  const SignInDiscordButton({
    required this.onPressed,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onPressed;
  @override
  Widget build(final BuildContext context) {
    return CupertinoIconButton(
      onPressed: onPressed,
      size: 32,
      svg: Assets.icons.discordLogoBlue,
    );
  }
}
