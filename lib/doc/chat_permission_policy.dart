import 'package:dart_acp_toolkit/dart_acp_toolkit.dart';
import 'package:xsoulspace_permission_core/xsoulspace_permission_core.dart';

/// The coarse permission stance for a chat — the same three positions the
/// mainstream coding agents expose (codex's Read Only/Auto/Full Access,
/// zed's per-mode agent switcher, cursor's ask/auto/YOLO), mapped onto
/// ACP's request kinds. The client-side policy ALWAYS applies: agents
/// that advertise their own session modes get them driven in addition
/// (see [preferredAgentModeId]), but this layer never delegates the
/// final say to the agent.
///
/// The DECISION itself is the shared permission contract
/// (xsoulspace_permission_core): each stance names its core policy and
/// ACP requests are adapted into [PermissionRequest]s at this edge.
/// The vocabulary, the escalate verb and the allow-lists live there;
/// this enum stays the persisted product identity (names, labels).
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

  /// This stance as the shared contract sees it — the same three
  /// positions, one name apart.
  PermissionStance get stance => switch (this) {
    ChatPermissionPolicy.ask => PermissionStance.ask,
    ChatPermissionPolicy.workspaceEdits => PermissionStance.workspaceEdits,
    ChatPermissionPolicy.fullAccess => PermissionStance.fullAccess,
  };

  /// Adapts an ACP wire request into the shared contract. The tool call
  /// id correlates the answer; the session id rides as origin
  /// (attribution, never authority); an unknown wire kind coerces to
  /// [PermissionKind.other] with the raw token preserved.
  PermissionRequest coreRequestOf(final AcpPermissionRequest request) =>
      PermissionRequest(
        id: request.toolCallId,
        title: request.title,
        kind: PermissionKind.coerce(request.kind),
        wireKindOverride: request.kind,
        details: request.details,
        origin: 'acp-session:${request.sessionId}',
      );

  /// The full decision for one ACP request under this stance —
  /// [PermissionAllow] when answered without the user,
  /// [PermissionEscalate] when the consent surface must render. The
  /// core contract's deny is never produced here by policy: a chat
  /// stance escalates what it does not auto-allow, and the surface is
  /// deny-by-default on its own.
  PermissionDecision decide(final AcpPermissionRequest request) =>
      stance.policy().decide(coreRequestOf(request));

  /// Whether a permission request of this ACP kind is answered WITHOUT
  /// the user. `read` is never gated (an agent that cannot read cannot
  /// work); [workspaceEdits] extends to edit+move (the working set),
  /// keeping execute/delete/other behind a prompt: a command execution
  /// is not a workspace edit.
  bool autoAllows(final AcpPermissionRequest request) =>
      decide(request) is PermissionAllow;

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
