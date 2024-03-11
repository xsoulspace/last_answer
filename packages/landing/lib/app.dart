import 'package:jaspr/jaspr.dart';
import 'package:landing/ui_kit/ui_kit.dart';

/// Main colors:
/// Emrald, stone,
/// The root component for this app.
class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    // Renders a <p> element with 'Hello World' content.
    yield body(
      [
        div([
          HeaderAppBar(),
          div([MainContent()], classes: 'overflow-x-hidden'),
          FotterBottomBar(),
        ], classes: 'flex min-h-screen flex-col justify-between')
      ],
      classes: 'antialiased text-stone-700 bg-amber-50/10',
    );
  }
}

class MainContent extends StatelessComponent {
  const MainContent({super.key});
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield SlideOne();
  }
}

class SlideOne extends StatelessComponent {
  const SlideOne({super.key});
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div([
      section([
        div(
          [
            h1(
              [text('Think fast, write faster')],
              classes: 'text-5xl md:text-8xl tracking-tighter'
                  'font-bold leading-2 md:leading-tight text-stone-900/80',
            )
          ],
          classes: 'max-w-sm md:max-w-md mx-auto',
        ),
        Spacer.y('8 md:mt-20'),
        p([
          text(
              '🍃 Last Answer designed to never miss a moment of inspiration ✨')
        ],
            classes:
                'relative max-w-xs md:max-w-xl mx-auto text-xl md:text-3xl leading-relaxed md:leading-10 text-stone-600/80'),
        Spacer.y('8 md:mt-16'),
        OpenAppButton(
          decoration: StyledButtonDecoration.filled.copyWith(
            edgeInsets: 'pl-6 pr-4 py-3',
            textStyle: 'text-md font-semibold',
          ),
          title: 'Use App for Free',
        ),
        Spacer.y('8'),
      ],
          classes:
              'relative mx-auto max-w-5xl p-4 pb-20 pt-16 text-center md:p-28')
    ]);
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
            Spacer.x('4'),
            a([
              strong([text('Last Answer')])
            ], href: '/', classes: 'flex-none'),
            Spacer.x('4'),
            div([
              nav([
                ul([
                  ...[
                    (title: 'Features', href: '/features'),
                    (title: 'Sync', href: '/sync'),
                    (title: 'Pricing', href: '/pricing'),
                    (title: 'Community', href: '/community'),
                  ].map((e) => LiLinkButton(
                      item: e, decoration: LiLinkButtonDecoration.homeAppBar)),
                ], classes: 'flex space-x-8'),
              ], classes: 'text-sm leading-6 font-semibold')
            ], classes: 'relative hidden md:flex items-center ml-auto'),
            AppBarBurgerButton(),
            Spacer.x('4'),
            OpenAppButton(
              title: 'Open app',
              decoration: StyledButtonDecoration.filled,
            ),
            Spacer.x('4')
          ], classes: 'relative flex items-center'),
        ],
            classes: 'bg-white/70 backdrop-blur-xl max-w-8xl mx-auto py-2 '
                'border-b border-stone-900/5'),
      ],
      classes: 'sticky top-0 z-50',
    );
  }
}

class FotterBottomBar extends StatelessComponent {
  const FotterBottomBar({super.key});
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield footer([
      div([
        section([
          nav([
            ...[
              (
                sectionTitle: 'Product',
                items: [
                  (title: 'Download', href: '/download'),
                  (title: 'Features', href: '/features'),
                  (title: 'Sync', href: '/sync'),
                  (title: 'Pricing', href: '/pricing'),
                ]
              ),
              (
                sectionTitle: 'Community',
                items: [
                  (title: 'About', href: '/community'),
                  (title: 'Discord (en)', href: '/'),
                  (title: 'Telegram (ru)', href: 'https://t.me/xsoulspace'),
                ]
              ),
              (
                sectionTitle: 'Legal',
                items: [
                  (title: 'Privacy', href: '/privacy'),
                  (title: 'Terms', href: '/terms'),
                  // (title: 'License', href: '/'),
                ]
              ),
            ].map((e) => div([
                  h5(
                    [text(e.sectionTitle)],
                    classes: 'text-base font-semibold text-stone-800',
                  ),
                  ul(
                    e.items
                        .map(
                          (e) => LiLinkButton(
                              item: e,
                              decoration: LiLinkButtonDecoration.footerLink),
                        )
                        .toList(),
                    classes: 'mt-2 space-y-1',
                  )
                ])),
          ], classes: 'grid grid-cols-2 gap-8 md:grid-cols-3 lg:grid-cols-6'),
          Spacer.y('6'),
          hr(),
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
    // TODO(arenukvern): add onClick,
    yield StyledButton(
      decoration: decoration,
      title: p([
        text(title),
        IconSpan(icon: MaterialIcons.chevronRight),
      ], classes: 'flex items-center'),
      onClick: () => throw UnimplementedError(),
    );
  }
}
