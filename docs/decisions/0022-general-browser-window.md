# ADR 0022 — General embedded browser window

- Status: accepted (implementation in `lib/browser/`)
- Date: 2026-10-21
- Scope: a general-purpose embedded browser surface inside Last Answer.

## Context

The product direction (ADR 0012, ADR 0019) is a writable document/workspace
where humans and agents work on the same state. Some of that work needs a
*general* browser: a preview that renders **anything the embedded engine
supports**, not a React runtime and not a Dart-only compiler.

Earlier attempts drifted into "compile the Dart project and show the result".
That is one narrow case of a browser and it made the surface look like a
product-specific preview instead of a window onto the web. This ADR fixes the
scope: the surface is a browser.

## Decision

### 1. The surface is a browser, not a renderer

`WorkspaceBrowser` embeds a platform web view and gives the human an address
bar, navigation controls, a progress line, a page title and an error line.
Anything the engine can render, the window can render. There is no
intermediate document format, no JSX, no Dart-specific compilation step, and
no project code is executed or compiled by the window.

### 2. The engine is `flutter_inappwebview` 6.1.5 (cached), native first

The embedded view is the cached `flutter_inappwebview` 6.1.5 native platform
view (macOS / Android / iOS / Windows). On web the plugin resolves to its
iframe-based web implementation, whose limits are real and are stated in the
limitations below rather than hidden. The plugin dependency is added by the
parent in `pubspec.yaml`; this change set owns no pubspec edit.

### 3. A narrow, honest capability surface

The browser window is a *page viewer*. It is not an agent surface and it
carries no app capability:

- No JavaScript bridge is registered. The page cannot call into the app and
  the app does not expose document, harness or storage state to the page.
- No TLS trust override (`onReceivedServerTrustAuthRequest` is not
  handled) — the platform default applies.
- No automatic permission grants (`onPermissionRequest` is not handled) —
  the platform default applies.
- No file opening, no downloads handling, no process or server lifecycle.
  A server's lifecycle belongs to whoever owns the server (Oka), not to a
  browser window. The window never starts, stops or compiles anything.

### 4. Address navigation is `http`/`https` only

The address entry accepts `http` and `https` for any host, including
`localhost` and loopback addresses. A bare host is completed (`http` for
loopback, `https` otherwise). `javascript:`, `data:`, `file:`, `about:` and
any other scheme are refused by the address entry, and in-page navigation to
non-`http(s)` schemes is cancelled. The policy lives in
`lib/browser/browser_address.dart` as pure Dart so it is testable and
identical on every target.

### 5. Structure and seams

- `browser_address.dart` — address parsing policy (pure Dart).
- `browser_engine.dart` — the tiny engine contract the window drives.
- `browser_bridge.dart` — reported state (URL, title, progress, error) and
  navigation commands (pure Dart, no plugin, no platform imports).
- `browser_view.dart` — the view seam: `BrowserViewBuilder`.
- `native_browser_view.dart` — the only file that imports
  `flutter_inappwebview`; it attaches the engine and reports events.
- `workspace_browser.dart` — the window chrome.
- `browser_entry.dart` — `openWorkspaceBrowser(...)` (dialog) and
  `WorkspaceBrowserPage` (routable page). No route is registered here: the
  parent integrates the launcher.
- `browser_strings.dart` — EN/IT/RU strings local to the feature, so the
  shared l10n generation is not touched by this change.

Pure state files carry no platform or plugin imports, so the state rules can
be exercised on the Dart VM and in widget tests.

### 6. Design law

Chrome follows `docs/DESIGN.md`: no cards, no chips, no filled buttons, no
decorative icons. Hairlines (0.6px) separate regions, labels are small caps
with tracking, the page area is the content. Stable widget keys
(`browser.address`, `browser.go`, `browser.back`, `browser.forward`,
`browser.reload`, `browser.progress`, `browser.title`, `browser.error`,
`browser.close`, `browser.dialog`) are the agent-facing contract, as
DESIGN.md §8 requires.

## Alternatives considered

- **Keep the Dart-only preview.** Rejected: it is a special case of a
  browser, and it forces the surface to look like a product feature rather
  than a window.
- **React/JSX renderer.** Rejected: adds a second runtime and a second
  document format; the user asked for a general browser.
- **External browser only (`url_launcher`).** Rejected: it leaves the app
  and loses the in-window progress, title and error surface.
- **Own web view wrapper per platform.** Rejected: `flutter_inappwebview`
  is cached, maintained and already a project dependency direction.

## Runtime qualification — 2026-10-21

The native macOS application built and the runtime preflight passed all ten
checks using the version 7 toolkit source CLI. The embedded WebKit view
loaded a local HTML/CSS/JavaScript/canvas document, exposed its real title
and load/error state through `browser_window`, and navigated to a second
document. A desktop-window capture included the native page pixels. A
Flutter-layer capture alone is not evidence for embedded native content.

The browser MCP control addresses mounted windows; it refuses ambiguous
selection and executable URL schemes. Window handles include a runtime
epoch and must be rediscovered after restart. Navigation dispatch remains
distinct from document load and from application acceptance.

These checks do not establish Android rendering, arbitrary-site compatibility,
interactive page automation or completion of the shared-work product journey.

## Remaining limitations

- Web: the plugin's web implementation is iframe-based. Many sites refuse to
  be framed, so some pages will not render on web. Native (macOS/Android) is
  the supported target.
- Address navigation is `http`/`https` only, by decision.
- No downloads, no file pickers, no print, no "open in external browser"
  affordance yet.
- The window shows one page at a time; no tabs.

## Falsifier

If a concrete need appears for a second, project-specific rendering surface
(a Dart preview, a JSX component preview, an ACP transcript view), that
surface is a *projection* of the document, not a second browser, and belongs
with the document/agent surfaces — not in `lib/browser/`.
