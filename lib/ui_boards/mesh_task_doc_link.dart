import 'package:lastanswer/common_imports.dart';

/// The ACP session link (ADR 0039 stage 4, owner decision: delegated
/// ACP turns stay honest-but-invisible — never queue rows — but carry
/// a DIRECT LINK to the session they rode). A settled mesh turn's
/// verdict names the doc whose bridge served it; this renders the
/// quiet link that opens that doc tab. Honest absence: no `docId` in
/// the verdict, no link — nothing is invented.
final class MeshTaskDocLink extends StatelessWidget {
  const MeshTaskDocLink({
    required this.verdict,
    required this.onOpen,
    super.key,
  });

  /// The settled record's verdict map (the bridge stamps `docId`).
  final Map<String, Object?>? verdict;

  /// Opens the doc tab (`doc:<docId>` surface id, the shell's route).
  final void Function(String docId) onOpen;

  @override
  Widget build(final BuildContext context) {
    final docId = verdict?['docId'];
    if (docId is! String || docId.isEmpty) return const SizedBox.shrink();
    final la = context.la;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      key: ValueKey('boards.mesh.docLink.$docId'),
      onTap: () => onOpen(docId),
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text('→ doc:$docId', style: LaTokens.mono(9, la.inkMuted)),
      ),
    );
  }
}
