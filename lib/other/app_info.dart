import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({
    super.key,
  });
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
  Widget build(final BuildContext context) {
    final bodyText1Style = Theme.of(context).textTheme.bodyLarge;

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: BackTextUniversalAppBar(
        titleStr: context.l10n.appInfo,
        onBack: () => Navigator.pop(context),
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
                            const url = AppInfoScreen.privacyPolicyLink;
                            final uri = Uri.parse(url);
                            if (await url_launcher.canLaunchUrl(uri)) {
                              await url_launcher.launchUrl(uri);
                            }
                          },
                          child: Text(
                            context.l10n.privacyPolicy,
                            style: bodyText1Style,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            const url = AppInfoScreen.termsAndConditions;
                            final uri = Uri.parse(url);
                            if (await url_launcher.canLaunchUrl(uri)) {
                              await url_launcher.launchUrl(uri);
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
