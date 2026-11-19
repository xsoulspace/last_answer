import 'package:flutter/material.dart' show showLicensePage;
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ui_legacy/legacy_kit/legacy_kit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({super.key});
  static const privacyPolicyLink =
      'https://xsoulspace.dev/#/home/p/Ly08SUzbm9IbHg1aiHLp/privacy';
  static const termsAndConditions =
      'https://xsoulspace.dev/#/home/p/Ly08SUzbm9IbHg1aiHLp/terms';

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  final _info = PackageInfo.fromPlatform();
  @override
  Widget build(final BuildContext context) => LaScaffold(
      topBar: LaTopBar(
        leading: LaButton.icon(
          icon: const Icon(Icons.close, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        titleText: context.l10n.appInfo,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: ScreenLayout.maxFullscreenPageWidth,
          ),
          child: FutureBuilder<PackageInfo>(
            future: _info,
            builder: (final context, final snapshot) {
              final info = snapshot.data;
              final version = S
                  .of(context)
                  .appVersion(info?.buildNumber ?? '', info?.version ?? '');

              return ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(18),
                children: [
                  ...[
                    LaSelectableText(
                      context.l10n.aboutAbstractWhatForDescription,
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 5),
                    LaSelectableText(
                      context.l10n.niceDayWish,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    LaSelectableText(
                      context.l10n.aboutAbstractIdeasImprovementsBugs,
                      textAlign: TextAlign.center,
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        LaButton(
                          variant: LaButtonVariant.link,
                          label: context.l10n.joinDiscord,
                          onPressed: () async {
                            const url = _discordLink;
                            final uri = Uri.parse(url);
                            if (await url_launcher.canLaunchUrl(uri)) {
                              await url_launcher.launchUrl(uri);
                            }
                          },
                        ),
                        LaSelectableText(context.l10n.feedbackTextWithEmail),
                      ],
                    ),
                    LaButton(
                      variant: LaButtonVariant.link,
                      onPressed: () {
                        // Material's license page has no kit equivalent —
                        // left as Material intentionally.
                        showLicensePage(
                          context: context,
                          useRootNavigator: true,
                        );
                      },
                      label: context.l10n.madeWithLoveAndFlutter,
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        LaButton(
                          variant: LaButtonVariant.link,
                          onPressed: () async {
                            const url = AppInfoScreen.privacyPolicyLink;
                            final uri = Uri.parse(url);
                            if (await url_launcher.canLaunchUrl(uri)) {
                              await url_launcher.launchUrl(uri);
                            }
                          },
                          label: context.l10n.privacyPolicy,
                        ),
                        LaButton(
                          variant: LaButtonVariant.link,
                          onPressed: () async {
                            const url = AppInfoScreen.termsAndConditions;
                            final uri = Uri.parse(url);
                            if (await url_launcher.canLaunchUrl(uri)) {
                              await url_launcher.launchUrl(uri);
                            }
                          },
                          label: context.l10n.termsAndConditions,
                        ),
                      ],
                    ),
                    LaSelectableText(version, textAlign: TextAlign.center),
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

/// The community invite (was `DiscordButton` in the legacy kit).
const _discordLink = 'https://discord.gg/y54DpJwmAn';
