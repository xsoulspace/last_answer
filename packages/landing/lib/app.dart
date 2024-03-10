import 'package:jaspr/jaspr.dart';

/// The root component for this app.
class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    // Renders a <p> element with 'Hello World' content.
    yield body([
      HeaderAppBar(),
      div(id: 'main', [
        div([text('Main')], classes: 'container'),
      ]),
      hr(),
      FotterBottomBar(),
    ]);
  }
}

typedef BottomNavLinkTuple = ({String title, String href});

class BottomNavLiLink extends StatelessComponent {
  BottomNavLiLink(this.item) : classes = '';
  BottomNavLiLink.secondary(this.item) : classes = 'secondary';
  BottomNavLiLink.contrast(this.item) : classes = 'contrast';
  final String classes;
  final BottomNavLinkTuple item;
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield li([
      a([
        strong([text(item.title)])
      ], href: item.href, classes: classes)
    ]);
  }
}

class HeaderAppBar extends StatelessComponent {
  const HeaderAppBar({super.key});
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield header([
      nav([
        ul([
          li([
            a([
              strong([text('Last Answer')])
            ], href: '/', classes: 'contrast')
          ]),
          ...[
            (title: 'Features', href: '/features'),
            (title: 'Sync', href: '/sync'),
            (title: 'Pricing', href: '/pricing'),
            (title: 'Community', href: '/community'),
          ].map(BottomNavLiLink.secondary),
        ]),
        ul([
          li([
            button([text('Open app')])
          ]),
        ])
      ], classes: 'container-fluid'),
    ]);
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
                  (title: 'Pricing', href: '/pricing'),
                ]
              ),
              (
                sectionTitle: 'Community',
                items: [
                  (title: 'All links', href: '/community'),
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
            ].map((e) => ul([
                  li([
                    h6([text(e.sectionTitle)])
                  ]),
                  ...e.items.map(BottomNavLiLink.contrast),
                ], classes: 'grid')),
          ]),
        ])
      ], classes: 'container'),
    ]);
  }
}
