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
  static const privacyPolicyLink =
      'https://github.com/xsoulspace/last_answer/blob/master/PRIVACY_POLICY.md';
  static const termsAndConditions =
      'https://github.com/xsoulspace/last_answer/blob/master/TERMS_AND_CONDITIONS.md';
  @override
  Widget build(final BuildContext context) {
    final bodyText1Style = Theme.of(context).textTheme.bodyText1;
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(
          onPressed: onBack,
        ),
        centerTitle: true,
        title: Text(S.current.appInfo),
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
              final version = S.current
                  .appVersion(info?.version ?? '', info?.buildNumber ?? '');
              return ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(18),
                children: [
                  ...[
                    SelectableText(
                      S.current.aboutAbstractWhatForDescription,
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 5),
                    SelectableText(
                      S.current.niceDayWish,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    SelectableText(
                      S.current.aboutAbstractIdeasImprovementsBugs,
                      textAlign: TextAlign.center,
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () async {
                            if (await url_launcher.canLaunch(discordLink)) {
                              await url_launcher.launch(discordLink);
                            }
                          },
                          child: Text(
                            S.current.joinDiscord,
                            style: bodyText1Style,
                          ),
                        ),
                        SelectableText(
                          S.current.feedbackTextWithEmail,
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        showLicensePage(
                          context: context,
                          useRootNavigator: true,
                        );
                      },
                      child: Text(
                        S.current.madeWithLoveAndFlutter,
                        style: bodyText1Style,
                      ),
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () async {
                            if (await url_launcher
                                .canLaunch(privacyPolicyLink)) {
                              await url_launcher.launch(privacyPolicyLink);
                            }
                          },
                          child: Text(
                            S.current.privacyPolicy,
                            style: bodyText1Style,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (await url_launcher
                                .canLaunch(termsAndConditions)) {
                              await url_launcher.launch(termsAndConditions);
                            }
                          },
                          child: Text(
                            S.current.termsAndConditions,
                            style: bodyText1Style,
                          ),
                        ),
                      ],
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
