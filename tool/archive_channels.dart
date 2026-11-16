// Archives leftover machine-minted smoke channels (each dogfood leg
// leaves one `dogfood-<millis>` room behind; the workorder smokes leave
// `workorder-<millis>` rooms). Archiving is the registry's supported
// close verb: the row and its durable thread survive (the journal is
// authority — closing never destroys anything), the channel just
// leaves the live lists and stops shadowing DM reuse
// (realm_chat_service.dart `dmThreadOf`, the 2026-11-16
// cache-probe → dogfood-1794173922369 defect).
//
// Dry-run by default; `--apply` writes.
//   fvm dart tool/archive_channels.dart                  # list only
//   fvm dart tool/archive_channels.dart --apply          # archive dogfood-*
//   fvm dart tool/archive_channels.dart --prefix workorder- --apply
import 'dart:io';

import 'package:lastanswer/coding_agent/realm_chat/conversation_spaces.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

Future<void> main(final List<String> args) async {
  final apply = args.contains('--apply');
  final prefixIdx = args.indexOf('--prefix');
  final prefix = prefixIdx >= 0 && prefixIdx + 1 < args.length
      ? args[prefixIdx + 1]
      : 'dogfood-';

  final home =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE']!;
  final storeDir = Directory('$home/.xsoulspace/worlds/local/coordination');
  if (!storeDir.existsSync()) {
    // ignore: avoid_print
    print('FAIL no realm control store at ${storeDir.path}');
    exit(1);
  }
  final registry = ChannelRegistry(store: RealmControlStore(storeDir));
  final all = await registry.list(includeArchived: true);
  var stale = 0;
  for (final channel in all) {
    if (channel.archived || !channel.name.startsWith(prefix)) continue;
    stale++;
    // ignore: avoid_print
    print(
      '${apply ? "ARCHIVED" : "WOULD ARCHIVE"} '
      '${channel.channelId} "${channel.name}" thread=${channel.threadId} '
      'members=${channel.memberIds.join(",")}',
    );
    if (apply) await registry.archive(channelId: channel.channelId);
  }
  // ignore: avoid_print
  print(
    stale == 0
        ? 'VERDICT: CLEAN — no live "$prefix*" channels'
        : 'VERDICT: ${apply ? "ARCHIVED" : "FOUND"} $stale "$prefix*" '
            'channel(s)${apply ? "" : " (dry run — pass --apply to write)"}',
  );
  exit(0);
}
