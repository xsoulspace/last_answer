import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'sections/sections.dart';
import 'ui_kit/ui_kit.dart';

/// Main colors:
/// Emrald, stone,
/// The root component for this app.
class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Router(
      routes: [
        ShellRoute(
            builder: (context, state, child) => AppNavigator(child: child),
            routes: [
              // Route(
              //   path: RoutePaths.home,
              //   builder: (context, state) => DownloadScreen(),
              // ),
              // FIXME(arenukvern): disabled for debugging purposes,
              Route(
                path: RoutePaths.home,
                name: RoutePaths.home,
                builder: (context, state) => HomeScreen(),
              ),
              Route(
                path: RoutePaths.download,
                name: RoutePaths.download,
                title: 'Last Answer: download',
                builder: (context, state) => DownloadScreen(),
              ),
            ]),
      ],
    );
  }
}

class RoutePaths {
  static const download = '/download';
  static const home = '/';
}

extension BuildContextX on BuildContext {
  RouterState get router => Router.of(this);
}

class AppNavigator extends StatelessComponent {
  const AppNavigator({required this.child, super.key});
  final Component child;
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield body(
      [
        div([
          HeaderAppBar(),
          div([child], classes: 'overflow-x-hidden'),
          FotterBottomBar(),
        ], classes: 'flex min-h-screen flex-col justify-between')
      ],
      classes: 'antialiased text-stone-700 bg-amber-50/10',
    );
  }
}

class HeaderAppBar extends StatelessComponent {
  const HeaderAppBar({super.key});
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield header(
      [
        div([
          div([
            TwSpacer.x('4'),
            LinkButton(
              liDecoration: LiLinkButtonDecoration.stone900
                  .copyWith(textStyle: 'text-xl font-semibold'),
              titleText: 'Last Answer',
              url: RoutePaths.home,
            ),
            TwSpacer.x('4'),
            div([
              nav([
                ul([
                  ...[
                    (title: 'Download', url: RoutePaths.download),
                    // (title: 'Sync', url: '/sync'),
                    // (title: 'Pricing', url: '/pricing'),
                    // (title: 'Community', url: '/community'),
                  ].map(
                    (e) => LiLinkButton(
                        item: e,
                        decoration: LiLinkButtonDecoration.emeraldNormal),
                  ),
                ], classes: 'flex space-x-8'),
              ], classes: 'text-sm leading-6 font-semibold')
              // FIXME(arenukvern): uncomment when menu is ready,
              // ], classes: 'relative hidden md:flex items-center ml-auto'),
            ], classes: 'relative flex items-center ml-auto'),
            // AppBarBurgerButton(),
            TwSpacer.x('4'),
            OpenAppButton(
              title: 'Open app',
              decoration: StyledButtonDecoration.filled,
            ),
            TwSpacer.x('4')
          ], classes: 'relative flex items-center'),
        ],
            classes:
                'bg-white/70 backdrop-blur-md transition max-w-8xl mx-auto py-2 '
                'border-b border-stone-900/5'),
      ],
      classes: 'sticky top-0 z-50',
    );
  }
}

final _bottomLinks = <FooterBottomBarLinkTuple>[
  (
    sectionTitle: 'Product',
    links: [
      (title: 'Download', url: RoutePaths.download),
      (
        title: 'Changelog',
        // TODO(arenukvern): add page,
        url:
            'https://github.com/xsoulspace/last_answer/blob/master/CHANGELOG.md'
      ),
      // (title: 'Features', url: '/features'),
      // (title: 'Sync', url: '/sync'),
      // (title: 'Pricing', url: '/pricing'),
    ]
  ),
  (
    sectionTitle: 'Community',
    links: [
      // (title: 'About', url: '/community'),
      (title: 'Discord (en)', url: 'https://discord.com/invite/y54DpJwmAn'),
      (title: 'Telegram (ru)', url: 'https://t.me/xsoulspace'),
    ]
  ),
  (
    sectionTitle: 'Legal',
    links: [
      // TODO(arenukvern): add page,
      (
        title: 'Privacy',
        url:
            'https://github.com/xsoulspace/last_answer/blob/master/PRIVACY_POLICY.md'
      ),
      // TODO(arenukvern): add page,
      (
        title: 'Terms',
        url:
            'https://github.com/xsoulspace/last_answer/blob/master/TERMS_AND_CONDITIONS.md'
      ),
      // TODO(arenukvern): add page,
      (
        title: 'License',
        url: 'https://github.com/xsoulspace/last_answer/blob/master/LICENSE'
      ),
    ]
  ),
];

typedef FooterBottomBarLinkTuple = ({
  String sectionTitle,
  List<LinkButtonTuple> links,
});

class FotterBottomBar extends StatelessComponent {
  const FotterBottomBar({super.key});
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield footer([
      div([
        section([
          nav([
            ..._bottomLinks.map(
              (e) => div(
                [
                  h5(
                    [text(e.sectionTitle)],
                    classes: 'text-base font-semibold text-stone-800',
                  ),
                  ul(
                    e.links
                        .map(
                          (link) => LiLinkButton(
                            item: link,
                            decoration: LiLinkButtonDecoration.stone,
                          ),
                        )
                        .toList(),
                    classes: 'mt-2 space-y-1',
                  ),
                ],
              ),
            ),
          ], classes: 'grid grid-cols-2 gap-8 md:grid-cols-3 lg:grid-cols-6'),
          TwSpacer.y('6'),
          hr(),
          // TODO(arenukvern): add social icons with links,
          p(
            [text('© 2020-2024 Anton Malofeev, Irina Veter.')],
            classes: 'mt-8 text-xs leading-5 text-stone-500',
          ),
        ])
      ], classes: 'mx-auto max-w-7xl px-12 py-8'),
    ], classes: 'z-10 border-t border-stone-100/80');
  }
}

class AppBarBurgerButton extends StatelessComponent {
  const AppBarBurgerButton({super.key});
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div([
      button([text('Menu')], classes: '')
    ], classes: 'ml-auto md:hidden');
  }
}

class OpenAppButton extends StatelessComponent {
  const OpenAppButton({
    this.decoration = StyledButtonDecoration.filled,
    required this.title,
    super.key,
  });
  final StyledButtonDecoration decoration;
  final String title;
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield LinkButton(
      styledDecoration: decoration,
      title: p([
        text(title),
        IconSpan(icon: MaterialIcons.chevronRight),
      ], classes: 'flex items-center'),
      url: 'https://xsoulspace.dev/last_answer',
    );
  }
}
