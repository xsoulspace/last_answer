import 'package:jaspr/client.dart';
import 'package:jaspr/dom.dart';
import 'package:landing/app.dart';
import 'package:landing/ui_kit/ui_kit.dart';

final _platforms = <PlatformLinksTuple>[
  (
    links: [
      (
        title: 'Google Play',
        url:
            'https://play.google.com/store/apps/details?id=dev.xsoulspace.lastanswer',
      ),
    ],
    platformTitle: 'Android',
  ),
  (
    links: [
      (
        title: 'Snapstore (Arm64, Amd64)',
        url: 'https://snapcraft.io/last-answer',
      ),
    ],
    platformTitle: 'Linux',
  ),
  (
    links: [
      (
        title: 'Microsoft Store (x86)',
        url: 'https://apps.microsoft.com/detail/9n1r319w0rvd',
      ),
    ],
    platformTitle: 'Windows',
  ),
];

class DownloadScreen extends StatelessComponent {
  const DownloadScreen({super.key});
  @override
  Component build(BuildContext context) {
    return section([
      Card([
        h2(
          [Component.text('Last Answer')],
          classes:
              'text-5xl md:text-7xl tracking-tighter leading-2 md:leading-tight',
        ),
        h4([
          Component.text('Notes & Ideas'),
        ], classes: 'text-2xl md:text-3xl text-stone-800/70'),
        TwSpacer.y('8'),
        div([
          Row(
            mainAxisAlignment: JustifyContent.spaceBetween,
            children: [
              p([
                Component.text(
                  'Simple and quick app to write your thoughts. Also, it is open source.',
                ),
              ], classes: 'w-fit'),
              TwSpacer.x('8'),
              div([], classes: 'w-max'),
            ],
          ),
        ], classes: 'w-full'),
        TwSpacer.y('4 md:mt-8'),
        Row(
          children: [
            LinkButton(
              styledDecoration: StyledButtonDecoration.outlined,
              openInNewTab: true,
              url: 'https://github.com/xsoulspace/last_answer',
              titleText: 'View on GitHub',
            ),
            TwSpacer.x('4'),
            OpenAppButton(title: 'Open app'),
          ],
        ),
        TwSpacer.y('12 md:mt-12'),
        div([hr()], classes: 'w-full'),
        TwSpacer.y('12'),
        h5([
          Component.text('Platforms'),
        ], classes: 'text-2xl font-light text-stone-800/60'),
        TwSpacer.y('4'),
        ..._platforms.map((e) => _PlatformTile(platform: e)),
      ]),
    ], classes: 'relative mx-auto max-w-4xl px-4 pb-8 pt-2 md:pb-16 text-center');
  }
}

typedef PlatformLinksTuple = ({
  String platformTitle,
  Iterable<PlatformLinkTuple> links,
});

typedef PlatformLinkTuple = ({String title, String url});

class _PlatformTile extends StatelessComponent {
  const _PlatformTile({required this.platform});
  final PlatformLinksTuple platform;
  @override
  Component build(BuildContext context) {
    return div([
      Row(
        mainAxisAlignment: JustifyContent.spaceBetween,
        children: [
          strong([Component.text(platform.platformTitle)], classes: ''),
          div(
            platform.links
                .map(
                  (e) => LinkButton(
                    liDecoration: LiLinkButtonDecoration.emeraldLight,
                    url: e.url,
                    title: div([
                      IconSpan(
                        icon: MaterialIcons.openInNew,
                        classes: 'text-sm',
                      ),
                      TwSpacer.x('2'),
                      Component.text(e.title),
                    ], classes: 'flex items-center'),
                    openInNewTab: true,
                  ),
                )
                .toList(),
            classes: 'w-1/2 flex flex-col',
          ),
        ],
      ),
    ], classes: 'pb-4 pt-4 border-b last:border-b-0 border-stone-100 w-full');
  }
}

class Row extends StatelessComponent {
  const Row({
    required this.children,
    this.mainAxisAlignment = JustifyContent.center,
    super.key,
  });
  final List<Component> children;
  final JustifyContent mainAxisAlignment;
  @override
  Component build(BuildContext context) {
    return div(
      styles: Styles(
        display: Display.flex,
        flexDirection: FlexDirection.row,
        justifyContent: mainAxisAlignment,
      ),
      children,
    );
  }
}
