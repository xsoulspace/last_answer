import 'package:dart_acp_toolkit/dart_acp_toolkit.dart';

/// The coarse permission stance for a chat — the same three positions the
/// mainstream coding agents expose (codex's Read Only/Auto/Full Access,
/// zed's per-mode agent switcher, cursor's ask/auto/YOLO), mapped onto
/// ACP's request kinds. The client-side policy ALWAYS applies: agents
/// that advertise their own session modes get them driven in addition
/// (see [preferredAgentModeId]), but this layer never delegates the
/// final say to the agent.
enum ChatPermissionPolicy {
  /// Every request surfaces reject-first buttons (the default;
  /// DESIGN §4: deny-by-default is shown, never assumed).
  ask,

  /// Reads, edits, and moves inside the agent's flow are auto-allowed;
  /// anything with reach beyond the working set (execute, delete, other)
  /// still asks. This is codex's "Auto" / zed's `acceptEdits` stance.
  workspaceEdits,

  /// Everything auto-allowed. Explicit per-chat user decision, never a
  /// default (codex "Full Access" / cursor YOLO).
  fullAccess;

  /// Parses the persisted title-block value; unknown/absent → [ask].
  static ChatPermissionPolicy fromName(final String? name) =>
      ChatPermissionPolicy.values.firstWhere(
        (policy) => policy.name == name,
        orElse: () => ChatPermissionPolicy.ask,
      );

  /// Compact switcher label (the header's text-native toggle row).
  String get label => switch (this) {
    ChatPermissionPolicy.ask => 'ASK',
    ChatPermissionPolicy.workspaceEdits => 'WS EDITS',
    ChatPermissionPolicy.fullAccess => 'FULL',
  };

  /// Whether a permission request of this ACP kind is answered WITHOUT
  /// the user. `read` is never gated (an agent that cannot read cannot
  /// work); [workspaceEdits] extends to edit+move (the working set),
  /// keeping execute/delete/other behind a prompt: a command execution
  /// is not a workspace edit.
  bool autoAllows(final AcpPermissionRequest request) => switch (this) {
    ChatPermissionPolicy.fullAccess => true,
    ChatPermissionPolicy.workspaceEdits => switch (request.kind) {
      'read' || 'edit' || 'move' => true,
      _ => false,
    },
    ChatPermissionPolicy.ask => false,
  };

  /// The agent's OWN mode this policy prefers, when the agent advertises
  /// session modes at all (claude-code: default/acceptEdits/plan/
  /// bypassPermissions). Best-effort by id/name keywords; null = no
  /// advertised mode matches (the client-side policy remains the only
  /// enforcement, which is always sound).
  String? preferredAgentModeId(final AcpSessionModes modes) {
    String lower(final AcpSessionModeInfo mode) =>
        '${mode.id} ${mode.name ?? ''}'.toLowerCase();
    final wanted = switch (this) {
      ChatPermissionPolicy.ask => ['default', 'plan', 'normal'],
      ChatPermissionPolicy.workspaceEdits => [
        'acceptedit',
        'workspace',
        'auto',
      ],
      ChatPermissionPolicy.fullAccess => [
        'bypass',
        'fullaccess',
        'full_access',
        'yolo',
      ],
    };
    for (final keyword in wanted) {
      for (final mode in modes.available) {
        if (lower(mode).contains(keyword)) return mode.id;
      }
    }
    return null;
  }
}
