import 'package:jaspr/jaspr.dart';
import 'package:landing/app.dart';
import 'package:landing/ui_kit/ui_kit.dart';

class HomeScreen extends StatelessComponent {
  const HomeScreen({super.key});
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
        TwSpacer.y('8 md:mt-20'),
        p([
          text(
              '🍃 Last Answer designed to never miss a moment of inspiration ✨')
        ],
            classes:
                'relative max-w-xs md:max-w-xl mx-auto text-xl md:text-3xl leading-relaxed md:leading-10 text-stone-600/80'),
        TwSpacer.y('8 md:mt-16'),
        StyledButton(
          decoration: StyledButtonDecoration.filled.copyWith(
            edgeInsets: 'pl-6 pr-4 py-3',
            textStyle: 'text-md font-semibold',
          ),
          title: div([
            text('Start for free'),
            IconSpan(icon: MaterialIcons.chevronRight)
          ], classes: 'flex items-center'),
          onClick: () => context.router.pushNamed(RoutePaths.download),
        ),
        TwSpacer.y('8'),
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
                  TwSpacer.y('2'),
                  h3([text(e.title)],
                      classes:
                          'font-semibold text-3xl tracking-wide md:text-4xl'),
                  TwSpacer.y('8'),
                  p([text(e.description)], classes: 'text-xl'),
                  TwSpacer.y('2'),
                ], classes: ''))
          ],
        ),
      ], classes: 'relative mx-auto max-w-4xl px-4 py-16 md:p-24 text-center'),
    ], classes: 'bg-zinc-300/10 rounded-[28px] shadow');

    yield section([
      TwSpacer.y('16 md:mt-20'),
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
      TwSpacer.y('16 md:mt-20'),
      div(
        [
          OpenAppButton(
            decoration: StyledButtonDecoration.filled.copyWith(
              edgeInsets: 'pl-6 pr-4 py-3',
              textStyle: 'text-md font-semibold',
            ),
            title: 'Open app',
          ),
          TwSpacer.x('12 md:mr-24'),
          LinkButton(
            titleText: 'Download',
            url: RoutePaths.download,
            liDecoration: LiLinkButtonDecoration.emeraldNormal.copyWith(
              textStyle: 'text-xl font-semibold',
            ),
          ),
        ],
        classes: 'flex flex-row items-center justify-center',
      ),
      // TODO(arenukvern): add community links,
      TwSpacer.y('20 md:mt-24'),
    ],
        classes: 'relative mx-auto max-w-5xl text-center '
            'px-4 pb-4 pt-16 md:py-28 md:pt-28 md:pb-18');
  }
}
