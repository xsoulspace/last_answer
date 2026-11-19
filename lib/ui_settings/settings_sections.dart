import 'package:lastanswer/common_imports.dart';

/// The settings document's model (ADR 0032): a [SettingsSection] is a
/// registry entry — a title and an ordered list of [SettingsEntry]s.
/// Adding a setting is adding an entry; the screen renders whatever the
/// registry holds (the endless-scroll promise is enforced by
/// construction, not by layout surgery).
///
/// An entry is either a ROW (title in the shell's label gutter, control
/// on the right — the columnar compact identity) or a BLOCK (a titled
/// region that carries its own row labels: the storage backends, the
/// agent-servers pane). Both carry `keywords` so the type-to-jump field
/// can find them.
final class SettingsSection {
  const SettingsSection({
    required this.id,
    required this.title,
    required this.entries,
  });

  /// Stable id — the TOC anchor and the section key's vocabulary
  /// (`settings.toc.<id>`).
  final String id;
  final String title;
  final List<SettingsEntry> entries;

  /// The entries matching a lowercased query (title or keywords).
  List<SettingsEntry> where(final String query) => [
    for (final entry in entries)
      if (entry.matches(query)) entry,
  ];
}

final class SettingsEntry {
  const SettingsEntry({
    required this.keyName,
    required this.title,
    required this.child,
    this.description = '',
    this.keywords = const [],
  }) : isBlock = false;

  /// A full-width region (checkbox rows, panes) that labels itself.
  const SettingsEntry.block({
    required this.keyName,
    required this.title,
    required this.child,
    this.keywords = const [],
  }) : description = '',
       isBlock = true;

  /// The entry's stable key base — rendered as
  /// `settings.entry.<keyName>` (DESIGN §6: keys are the agent's UI
  /// contract).
  final String keyName;
  final String title;
  final String description;
  final List<String> keywords;
  final Widget child;

  /// Rows go through the label gutter; blocks render full-width.
  final bool isBlock;

  bool matches(final String lowercasedQuery) =>
      title.toLowerCase().contains(lowercasedQuery) ||
      keywords.any(
        (final keyword) => keyword.toLowerCase().contains(lowercasedQuery),
      );
}
