library app_info;

import 'package:flutter/material.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({
    required final this.onBack,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onBack;
  static const discordLink = 'https://discord.gg/y54DpJwmAn';
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(
          onPressed: onBack,
        ),
        centerTitle: true,
        title: const Text('App info'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: ScreenLayout.maxFullscreenPageWidth,
          ),
          child: FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (final context, final snapshot) {
              final info = snapshot.data;
              final version = 'App version: ${info?.version}, '
                  'build: ${info?.buildNumber}';
              return ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(18),
                children: [
                  ...[
                    SelectableText(S.current.aboutAbstractWhatForDescription),
                    const SizedBox(height: 15),
                    const SelectableText(
                      'Please notice',
                      textAlign: TextAlign.center,
                    ),
                    const SelectableText(
                      'This version may not have all features of '
                      'previous version, such as languages and help and etc, '
                      'but they will return in the next updates - stay tuned:)',
                    ),
                    const SizedBox(height: 15),
                    SelectableText(
                      S.current.aboutAbstractIdeasImprovementsBugs,
                      textAlign: TextAlign.center,
                    ),
                    Wrap(
                      children: [
                        TextButton(
                          onPressed: () async {
                            if (await url_launcher.canLaunch(discordLink)) {
                              await url_launcher.launch(discordLink);
                            }
                          },
                          child: const Text('Join Discord'),
                        ),
                        const SelectableText(
                          'or send a message to idea@xsoulspace.dev',
                        ),
                      ],
                    ),
                    const SelectableText(
                      'Thank you for using this app and which you a nice day, '
                      'full of ideas and inspiration!:)',
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        showLicensePage(
                          context: context,
                          useRootNavigator: true,
                        );
                      },
                      child: const Text(
                        'Made with Flutter ❤ and Open Source Libraries',
                      ),
                    ),
                    SelectableText(
                      version,
                      textAlign: TextAlign.center,
                    ),
                  ].map(
                    (final w) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: w,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
