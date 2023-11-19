import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({
    required this.onBack,
    super.key,
  });
  final VoidCallback onBack;
  static const privacyPolicyLink =
      'https://github.com/xsoulspace/last_answer/blob/master/PRIVACY_POLICY.md';
  static const termsAndConditions =
      'https://github.com/xsoulspace/last_answer/blob/master/TERMS_AND_CONDITIONS.md';

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  final _info = PackageInfo.fromPlatform();
  @override
  Widget build(final BuildContext context) {
    final bodyText1Style = Theme.of(context).textTheme.bodyLarge;

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: BackTextUniversalAppBar(
        titleStr: context.l10n.appInfo,
        onBack: widget.onBack,
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
                  .appVersion(info?.version ?? '', info?.buildNumber ?? '');

              return ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(18),
                children: [
                  ...[
                    SelectableText(
                      context.l10n.aboutAbstractWhatForDescription,
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 5),
                    SelectableText(
                      context.l10n.niceDayWish,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    SelectableText(
                      context.l10n.aboutAbstractIdeasImprovementsBugs,
                      textAlign: TextAlign.center,
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        const DiscordButton(),
                        SelectableText(
                          context.l10n.feedbackTextWithEmail,
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
                        context.l10n.madeWithLoveAndFlutter,
                        style: bodyText1Style,
                      ),
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () async {
                            if (await url_launcher
                                .canLaunch(AppInfoScreen.privacyPolicyLink)) {
                              await url_launcher
                                  .launch(AppInfoScreen.privacyPolicyLink);
                            }
                          },
                          child: Text(
                            context.l10n.privacyPolicy,
                            style: bodyText1Style,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (await url_launcher
                                .canLaunch(AppInfoScreen.termsAndConditions)) {
                              await url_launcher
                                  .launch(AppInfoScreen.termsAndConditions);
                            }
                          },
                          child: Text(
                            context.l10n.termsAndConditions,
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
