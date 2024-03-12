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
          title: 'Start for free',
        ),
        Spacer.y('8'),
      ],
          classes: 'relative mx-auto max-w-5xl text-center '
              'px-4 pb-4 pt-16 md:py-28 md:pt-28 md:pb-18')
    ]);

    yield div([
      section([
        BentoGrid(
          cards: [
            ...[
              (
                title: '- Wait, another note app? 👀',
                description:
                    'Yes 😉. You know, sometimes, it\'s not that hard to get inspiration, '
                    'but tooo much waiting for the right app will be open. '
                    'And in that moment - thoughts forgotten and time is lost. '
                    'So, with Last Answer we\'ve made it. ',
              ),
              (
                title: 'Start writing before data is loaded',
                description:
                    'Last Answer mission is to reduce any delays between '
                    'thought and writing - if you see the buttons '
                    'to create a Note or an Idea - you can instantly ⚡️ use '
                    'them without waiting.',
              ),
              (
                title: 'Offline-first 🏡, your ideas has priority',
                description:
                    'To give you fast access to your Notes and Ideas the app loads them as fast as possible, and only then, it loads theme, settings and other preferences. All your data stored in your device.',
              ),
              (
                title: 'Make Note',
                description: 'To convert quickly thoughts to words.',
              ),
              (
                title: 'Write Post ',
                description:
                    'You can write draft of post in Last Answer by using character limits specific to social networks. For example Discord has limit 2000:)',
              ),
              (
                title: 'Brainstorm Idea',
                description:
                    'You can use various technics, such as 5 why, six sigmas or similar. Just try it',
              ),
              (
                title: 'Share it! ',
                description:
                    'Every note is simple plain text which can be easily copied to any app. Ideas a little bit more complex, but they are also support sharing as simple text.',
              ),
              (
                title: "Read Flow",
                description:
                    "We write everyday in messangers, and they have certain flow - to read a chat your eye goes from bottom to up, the same way as you would write on typewriter machine - so as the LastAnswer. Every Note or Idea, designed to feel like a focused chat.",
              ),
              (
                title: 'Updates goes down -& up (if needed)',
                description:
                    'Last Answer has auto sorting function - you will see most recent notes are which you edited. Just like in messangers:)'
              ),
              (
                title: 'Configurable',
                description:
                    'You can change direction of Notes and Ideas in settings. As the Theme and Language.',
              ),
              (
                title: 'Backup & Restore',
                description:
                    'You can always save all data to one single file and restore from it.',
              )
            ].map((e) => Card([
                  Spacer.y('2'),
                  h3([text(e.title)],
                      classes:
                          'font-semibold text-3xl tracking-wide md:text-4xl'),
                  Spacer.y('8'),
                  p([text(e.description)], classes: 'text-xl'),
                  Spacer.y('2'),
                ], classes: ''))
          ],
        ),
      ], classes: 'relative mx-auto max-w-4xl px-4 py-16 md:p-24 text-center'),
    ], classes: 'bg-zinc-300/10 rounded-[28px] shadow');

    yield section([
      Spacer.y('16 md:mt-20'),
      div(
        [
          h1(
            // TODO(arenukvern): think about phrase, it's too much:)
            [text('Never lose thoughts in the breeze of time')],
            classes: 'text-4xl md:text-5xl tracking-tighter'
                'font-bold leading-2 md:leading-tight text-stone-900/80',
          )
        ],
        classes: 'max-w-sm md:max-w-md mx-auto',
      ),
      Spacer.y('16 md:mt-20'),
      div(
        [
          OpenAppButton(
            decoration: StyledButtonDecoration.filled.copyWith(
              edgeInsets: 'pl-6 pr-4 py-3',
              textStyle: 'text-md font-semibold',
            ),
            title: 'Open app',
          ),
          Spacer.x('12 md:mr-24'),
          StyledButton(
            decoration: StyledButtonDecoration.text,
            titleText: 'Download',
            onClick: () => throw UnimplementedError(),
          ),
        ],
        classes: 'flex flex-row items-center justify-center',
      ),
      // TODO(arenukvern): add community links,
      Spacer.y('20 md:mt-24'),
    ],
        classes: 'relative mx-auto max-w-5xl text-center '
            'px-4 pb-4 pt-16 md:py-28 md:pt-28 md:pb-18');
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
            classes:
                'bg-white/70 backdrop-blur-md transition max-w-8xl mx-auto py-2 '
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
