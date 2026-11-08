/// DESIGN.md v2 — the new-tab picker: a menu anchored under the strip's
/// `+`, NOT a tab (the picker-as-tab retired with the v3 anatomy). It
/// enumerates the format registry — the faces openable today, the rooms,
/// instance rows (the tab law: the same kind opens N times), the
/// creation flows, and named RUNWAY rows as honest absences (image
/// editing, video, audio — dimmed until the format lands; a new content
/// kind is a new tab-view registration here, never a new shell).
///
/// Keys: `newtab.page` (the panel), `newtab.entry.<surfaceId>` (rows),
/// `newtab.instance.<kind>`, `newtab.create.<flow>`,
/// `newtab.runway.<format>`.
library;

import 'package:lastanswer/common_imports.dart';

import 'package:lastanswer/shell/shell_theme.dart';

/// One picker row.
final class NewTabRow {
  const NewTabRow({
    required this.key,
    required this.label,
    this.onTap,
    this.icon,
    this.leading,
    this.enabled = true,
  });

  /// The widget key AND the Semantics name (the §2.3 contract).
  final String key;
  final String label;
  final IconData? icon;
  final Widget? leading;
  final bool enabled;
  final VoidCallback? onTap;
}

/// One labeled picker section.
final class NewTabSection {
  const NewTabSection({required this.rows, this.label});

  final String? label;
  final List<NewTabRow> rows;
}

/// The picker overlay: a barrier (tap-away closes) plus the panel
/// anchored to the owning strip's `+` through [link].
final class NewTabMenu extends StatelessWidget {
  const NewTabMenu({
    required this.link,
    required this.sections,
    required this.onClose,
    super.key,
  });

  final LayerLink link;
  final List<NewTabSection> sections;
  final VoidCallback onClose;

  @override
  Widget build(final BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: ModalBarrier(
          color: const Color(0x00000000),
          onDismiss: onClose,
        ),
      ),
      Positioned.fill(
        child: CompositedTransformFollower(
          link: link,
          // The `+` sits at the strip's RIGHT edge: the panel hangs
          // down-LEFT from it (right edges aligned) so it never leaves
          // the window — a down-right panel overflows narrow windows
          // and split panes (measured: taps on off-screen rows miss).
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          offset: const Offset(0, 6),
          child: Align(
            alignment: Alignment.topRight,
            child: _Panel(sections: sections),
          ),
        ),
      ),
    ],
  );
}

final class _Panel extends StatelessWidget {
  const _Panel({required this.sections});

  final List<NewTabSection> sections;

  @override
  Widget build(final BuildContext context) => Container(
    key: const ValueKey('newtab.page'),
    width: 280,
    constraints: const BoxConstraints(maxHeight: 460),
    decoration: BoxDecoration(
      color: context.la.surfaceRaised,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: context.shellHairline),
      boxShadow: shellFloatingShadow(context),
    ),
    child: ListView(
      // The ListView semantics law (the strip's comment applies here
      // too: the picker is an agent-addressable surface). Rows past the
      // fold build on scroll — measured 2026-11-08: `cacheExtent` does
      // NOT extend the built window here, so section order is the
      // contract (rooms first, runway last) and agents/tests scroll.
      padding: const EdgeInsets.symmetric(vertical: 6),
      children: [
        for (final section in sections) ...[
          if (section.label != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Text(section.label!, style: shellSectionLabel(context)),
            ),
          for (final row in section.rows) _Row(row: row),
        ],
      ],
    ),
  );
}

final class _Row extends StatefulWidget {
  const _Row({required this.row});

  final NewTabRow row;

  @override
  State<_Row> createState() => _RowState();
}

final class _RowState extends State<_Row> {
  var _hovering = false;

  @override
  Widget build(final BuildContext context) {
    final row = widget.row;
    final runways = !row.enabled;
    return Semantics(
      button: row.enabled,
      enabled: row.enabled,
      label: row.key,
      hint: row.label,
      child: MouseRegion(
        cursor: row.enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (final _) => setState(() => _hovering = true),
        onExit: (final _) => setState(() => _hovering = false),
        child: GestureDetector(
          key: ValueKey(row.key),
          behavior: HitTestBehavior.opaque,
          onTap: row.enabled ? row.onTap : null,
          child: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: _hovering && row.enabled ? context.shellSelected : null,
            child: Row(
              children: [
                if (row.leading != null) ...[
                  row.leading!,
                  const SizedBox(width: 8),
                ] else if (row.icon != null) ...[
                  Icon(
                    row.icon,
                    size: 14,
                    color: runways ? context.la.inkQuiet : context.shellMuted,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    row.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontSize: 12,
                      color: runways ? context.la.inkQuiet : context.la.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
