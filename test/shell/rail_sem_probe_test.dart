import 'dart:io';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/app_shell.dart';
import 'package:lastanswer/shell/center_tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xsoulspace_ui_foundation/xsoulspace_ui_foundation.dart';
import 'hermetic_world_state.dart';

void main() {
  testWidgets('compact rail WITH roster: semantics labels', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final pin = Directory.systemTemp.createTempSync('rail_sem_');
    RealmWorld.debugDeviceHome = pin.path;
    addTearDown(() {
      RealmWorld.debugDeviceHome = null;
      pin.deleteSync(recursive: true);
    });
    late RealmChatService service;
    await tester.runAsync(() async {
      final temp = await Directory.systemTemp.createTemp('rail_sem_ws_');
      addTearDown(() => temp.delete(recursive: true));
      final world = await RealmWorld.open(rootOverride: temp.path);
      final roster = ActorRoster(replicaId: 'tester');
      service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: roster,
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      await service.ensureReady();
      await service.createActor(
        displayName: 'Scout Live',
        kind: ActorKind.model,
        brainRef: '',
      );
      await service.createChannel('guild');
    });
    final handle = tester.ensureSemantics();
    final worldState = hermeticWorldState();
    await worldState.refresh();
    await tester.binding.setSurfaceSize(const Size(1044, 768));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      GlobalStatesProvider(
        builder: (_) => MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: Scaffold(
            body: AppShell(
              service: service,
              worldState: worldState,
              child: const CenterTabsArea(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final labels = <String>[];
    void visit(SemanticsNode node) {
      if (node.label.isNotEmpty) labels.add(node.label.split('\n').first);
      node.visitChildren((c) {
        visit(c);
        return true;
      });
    }

    visit(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
    // §2.3 at the COMPACT rail width with a populated roster: every
    // rail entry, the open tab and the edge keep their key-contract
    // names in Flutter's own semantics tree (the live fmtk walker's
    // rail-drop is a toolkit gap, not an app absence — commit 06017111).
    final snapshot = labels.join('\n');
    for (final id in const [
      'conversations',
      'documents',
      'boards',
      'filesystem',
      'browser',
      'inspector',
      'threads',
      'terminal',
      'people',
    ]) {
      expect(snapshot, contains('rail.view.$id'));
    }
    expect(snapshot, contains('view.tab.conversations'));
    expect(snapshot, contains('edge.world'));
    expect(snapshot, contains('rail.actor.'));
    handle.dispose();
  });
}
