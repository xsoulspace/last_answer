import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/meaning_experiment_view.dart';

void main() {
  testWidgets(
    'full receipt scrolls locally while its disclosure stays visible',
    (tester) async {
      final outer = ScrollController();
      addTearDown(outer.dispose);
      final semantics = tester.ensureSemantics();
      final body = List.generate(
        500,
        (i) => 'exact receipt field $i',
      ).join('\n');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 558,
                height: 414,
                child: ListView(
                  controller: outer,
                  reverse: true,
                  children: [
                    MeaningEvidenceDetails(title: 'Receipt', body: body),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('+ Receipt'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<SelectableText>(find.byType(SelectableText)).data,
        body,
      );
      final rendered = tester.getSemantics(find.text(body)).getSemanticsData();
      expect([rendered.label, rendered.value], contains(body));
      expect(outer.position.maxScrollExtent, 0);
      final local = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byType(SingleChildScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(local.position.maxScrollExtent, greaterThan(1000));
      local.position.jumpTo(local.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(local.position.pixels, local.position.maxScrollExtent);
      expect(outer.offset, 0);
      final viewport = tester.getRect(find.byType(ListView));
      expect(
        viewport.contains(tester.getCenter(find.text('− Receipt'))),
        isTrue,
      );
      await tester.tap(find.text('− Receipt'));
      await tester.pumpAndSettle();
      expect(find.text(body), findsNothing);
      expect(find.text('+ Receipt'), findsOneWidget);
      semantics.dispose();
    },
  );

  testWidgets('expanded real receipt survives reversed lazy list eviction', (
    tester,
  ) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 558,
            height: 414,
            child: ListView(
              controller: scroll,
              reverse: true,
              children: [
                MeaningEvidenceDetails(
                  title: 'Details',
                  surfaceKey: const ValueKey('real_details_toggle'),
                  body: List.generate(
                    500,
                    (index) => 'receipt field $index',
                  ).join('\n'),
                ),
                for (var index = 0; index < 100; index++)
                  SizedBox(height: 100, child: Text('Earlier message $index')),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('real_details_toggle')));
    await tester.pumpAndSettle();
    expect(find.text('− Details'), findsOneWidget);
    final expandedExtent = scroll.position.maxScrollExtent;
    for (final offset in [2000.0, 6000.0, 14000.0]) {
      scroll.jumpTo(offset);
      await tester.pumpAndSettle();
      debugPrint(
        'lifecycle offset=$offset actual=${scroll.offset} '
        'extent=${scroll.position.maxScrollExtent}',
      );
    }
    scroll.jumpTo(0);
    await tester.pumpAndSettle();
    debugPrint(
      'lifecycle return actual=${scroll.offset} '
      'extent=${scroll.position.maxScrollExtent} '
      'expandedExtent=$expandedExtent',
    );
    expect(find.text('− Details'), findsOneWidget);
  });
}
