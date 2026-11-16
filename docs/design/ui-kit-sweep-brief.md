# UI kit sweep brief — Material → `la_ui` (2026-11-16)

The contract for every sweep lane of the ui-kit-rewrite program
(docs/design/ui-kit-rewrite-2026-11-16.md, DESIGN.md v6). Read this fully
before editing. The kit source is `packages/la_ui/lib/src/*.dart` — it is
small; when this brief is ambiguous, the source wins.

## Ground rules (every lane)

1. **Frozen contracts.** Widget `key:` values, semantics labels, l10n strings
   (`S.of(context).*`), callbacks, business logic and navigation are FROZEN.
   This is a component-layer replacement, never a behavior redesign.
2. **Stay in your lane.** Do not edit files outside your assigned list.
   Never edit: `lib/common_imports.dart`, `packages/la_ui/**`,
   `lib/_library/**`, `docs/**`. Do not add `import
   'package:flutter/material.dart'` anywhere; do not remove it from
   common_imports (the coordinator cuts it at the end).
3. **Tokens, not Theme.** In files you touch, replace `Theme.of(context)`
   reads with `context.laUi` tokens (colors, text styles, radii). Do NOT
   introduce new hex colors. Hover/press/selected fills must NOT be
   hand-rolled — `LaPressable` owns them.
4. **Verify.** After your edits: `fvm dart analyze <your dirs>` must show no
   NEW errors/warnings, and `fvm flutter test <your test files>` must pass.
   Run from the repo root `/Users/antonio/xs/storage_problem/last_answer`.
5. **No commits.** Leave the working tree dirty; the steward commits.
6. **Report API friction.** If the kit lacks something you need, work around
   it locally in your lane file (plain widgets-layer composition) and list
   it in your final report under "kit gaps". Do NOT edit the kit.
7. **flutter_animate**: in your files, replace `.animate()/.fadeIn()/.slideX()`
   chains with `TweenAnimationBuilder`/`AnimatedOpacity`/`AnimatedSlide` (kit
   motion tokens: `context.laUi.motionFast/motionSettle`, curve
   `motionCurve`) and drop the `package:flutter_animate` import.
8. **Material widgets with no kit equivalent** (RefreshIndicator, Stepper,
   TabBar+DefaultTabController, TimePicker, Autocomplete, ...): leave them
   untouched and list them in your report under "left as Material".
9. **Tests in your lane**: update `find.byType(TextButton)`-style finds to
   the kit types (`LaButton` etc.), and `find.byType(TextField)` to
   `LaField`/`EditableText` (text entry: `tester.enterText(find.byType(
   EditableText), ...)`). If `pumpAndSettle` hangs after a spinner swap,
   use bounded `tester.pump(duration)` calls instead.

## Kit API cheat sheet

All names come via `common_imports.dart` (it exports `package:la_ui/la_ui.dart`).

```dart
// ── Buttons (md = 34px, sm = 28px) ────────────────────────────────
LaButton(label: 'Save', onPressed: fn)                       // secondary
LaButton(label: 'Send', variant: LaButtonVariant.primary, onPressed: fn)
LaButton(label: 'Cancel', variant: LaButtonVariant.ghost, onPressed: fn)
LaButton(label: 'Delete', variant: LaButtonVariant.destructive, onPressed: fn)
LaButton(label: 'More', variant: LaButtonVariant.outline, ...)
LaButton(label: 'Docs', variant: LaButtonVariant.link, ...)   // accent text
LaButton(child: Row(...), onPressed: fn)                      // custom child
LaButton.icon(icon: const Icon(Icons.close, size: 16),
    tooltip: 'Close', onPressed: fn, size: LaButtonSize.sm)
LaButton(label: 'Go', expand: true, ...)                      // full width
// onPressed: null ⇒ disabled. Variants: primary secondary ghost outline
// destructive destructiveGhost link.

// ── Fields (Linear law: borderless → hover fill → focus ring) ─────
LaField(controller: c, focusNode: n, placeholder: 'Hint',
    onChanged: fn, onSubmitted: fn, autofocus: true,
    obscureText: false, keyboardType: TextInputType.text,
    textInputAction: TextInputAction.done, readOnly: false,
    enabled: true, prefix: Icon(...), suffix: LaButton.icon(...),
    errorText: 'Required', maxLength: 280, maxLines: 1)
LaTextArea(controller: c, minLines: 3, maxLines: 8, placeholder: ...)
// InputDecoration is GONE: hintText→placeholder, prefixIcon→prefix,
// suffixIcon→suffix, labelText→placeholder (or a Text above the field),
// helperText→drop or a Text below, errorText→errorText.

// ── Rows ──────────────────────────────────────────────────────────
LaRow(leading: w, titleText: '#general', metaText: '3 members',
    trailing: w, onTap: fn, onLongPress: fn, onSecondaryTap: fn,
    selected: bool, height: 34)          // 44 on touch layouts
LaRow(title: Text(...), meta: Text(...), ...)   // widget slots
LaRow.custom(child: w, onTap: fn, selected: b)  // free-form

// ── Menus / selects ───────────────────────────────────────────────
LaMenuAnchor(entries: [
    LaMenuItem(label: 'Rename', icon: Icon(Icons.edit, size: 14),
        onPressed: fn, shortcutHint: 'F2'),
    LaMenuItem(label: 'Archive', destructive: true, onPressed: fn),
    const LaMenuSeparator(),
    const LaMenuHeader('Danger'),
  ], child: triggerWidget)               // pointer-down opens
LaMenuAnchor.builder(entries: [...],
  childBuilder: (context, anchor) =>
      LaButton(label: 'Menu', onPressed: anchor.toggle))
showLaMenuAt(context, globalPosition: details.globalPosition,
  entries: [...])                        // imperative context menu
LaSelect<String>(value: v, onChanged: fn, placeholder: 'Choose…',
  items: const [LaSelectItem(value: 'a', label: 'A')], expand: true)
// LaSelectSize.sm/.md via size:.

// ── Overlays ──────────────────────────────────────────────────────
showLaDialog(context: context, builder: (c) => LaDialog(
    titleText: 'Title', description: 'Quiet line', content: w,
    actions: [LaButton(label: 'Cancel', variant: LaButtonVariant.ghost,
                 onPressed: () => Navigator.of(c).pop()),
              LaButton(label: 'OK', variant: LaButtonVariant.primary,
                 onPressed: () => Navigator.of(c).pop(true))]))
final ok = await showLaConfirm(context, title: 'Delete channel?',
    message: 'Consequence line', confirmLabel: 'Delete',
    destructive: true);                  // Future<bool>
showLaSheet(context: context, builder: (c) => content)  // bottom sheet
LaToast.show(context, message: 'Saved',
    variant: LaToastVariant.success, actionLabel: 'Undo', onAction: fn)
LaToast.info(context, 'msg'); LaToast.danger(context, 'msg');
LaTooltip(message: 'Hint', child: w)

// ── Toggles / progress ────────────────────────────────────────────
LaSwitch(value: b, onChanged: fn)   LaCheckbox(value: b, onChanged: fn)
LaRadio<String>(value: 'a', groupValue: sel, onChanged: fn)
LaSlider(value: v, onChanged: fn, min: 0, max: 1, divisions: 4)
LaSpinner(size: 18)                 LaProgress(value: 0.4)

// ── Chrome / surfaces ─────────────────────────────────────────────
LaHairline()  LaHairline(vertical: true)
LaBox(color: context.laUi.surface, border: BorderSide(color:
    context.laUi.rule), floating: true, radius: ..., padding: ...,
    child: w)
LaScaffold(body: w, topBar: LaTopBar(titleText: 'Settings',
    leading: backBtn, trailing: actions))
LaPill(label: 'M', icon: ..., color: ...)      // status token
LaBadge(count: unread)                          // accent count pill
LaScrollArea(child: ListView(...))  LaListView(children: [...])
LaPressable(onTap: fn, selected: b, child: w)   // hover/focus/press layer
LaClipSquircle(radius: BorderRadius.circular(8), child: image)
LaSelectableText('copyable text', style: ...)
SquircleShape / squirclePath / squircleDecoration(...)   // v6 corners

// ── Tokens: context.laUi ──────────────────────────────────────────
// colors: canvas surface surfaceRaised surfaceOverlay ink inkMuted
//   inkQuiet rule accent onAccent danger onDanger caution success scrim
//   fieldFill; hoverFill() pressedFill() selectedFill()
// radii: controlRadius smallRadius floatingRadius (+ squircleExponent)
// type: micro compact body emphasis section display buttonSm buttonMd
//   control mono   (TextStyle getters — copyWith(color:) as needed)
// motion: motionFast(120ms) motionSettle(150ms) motionOverlay(140ms)
//   motionCurve; floatingShadow
```

## Material → kit mapping

| Material | Kit |
|---|---|
| `TextButton` | `LaButton(variant: ghost)` (link-ish → `link`) |
| `TextButton.icon` | `LaButton(icon:…, label:…, variant: ghost)` |
| `FilledButton` | `LaButton(variant: primary)` |
| `ElevatedButton` | `LaButton(variant: secondary)` |
| `OutlinedButton` | `LaButton(variant: outline)` |
| `IconButton` | `LaButton.icon` (keep `tooltip:`) |
| `TextField`/`TextFormField` | `LaField` / `LaTextArea` (see field notes) |
| `DropdownButton(FormField)` | `LaSelect` |
| `PopupMenuButton` | `LaMenuAnchor` + `LaMenuItem` list |
| `MenuAnchor`/`MenuButtonAnchor` | `LaMenuAnchor` |
| `showDialog`+`AlertDialog` | `showLaDialog`+`LaDialog`; yes/no → `showLaConfirm` |
| `Dialog(child:)` | `LaBox(floating: true, color: surfaceOverlay, …)` |
| `showModalBottomSheet` | `showLaSheet` |
| `SnackBar`/`ScaffoldMessenger.showSnackBar` | `LaToast.show` (no Scaffold needed) |
| `Tooltip` | `LaTooltip` |
| `ListTile` | `LaRow` (title→titleText/title, subtitle→metaText/meta) |
| `Divider`/`VerticalDivider` | `LaHairline()` / `LaHairline(vertical: true)` |
| `CircularProgressIndicator` | `LaSpinner` |
| `LinearProgressIndicator` | `LaProgress(value: …)` |
| `Switch`/`Checkbox`/`Radio`/`Slider` | `LaSwitch`/`LaCheckbox`/`LaRadio`/`LaSlider` |
| `Card` | `LaBox(color: surface, border: BorderSide(color: rule))` |
| `Chip` | `LaPill` (or `LaRow` if interactive) |
| `Badge` | `LaBadge` |
| `Scaffold(body:)` | `LaScaffold(body:)` |
| `Scaffold(appBar: AppBar(…))` | `LaScaffold(topBar: LaTopBar(…))` |
| `InkWell`/`Material` hover wrappers | `LaPressable` (or drop the wrapper if a kit component now owns the surface) |
| `SelectableText` | `LaSelectableText` |
| `SearchBar` | `LaField(prefix: Icon(Icons.search, size: 16), placeholder: …)` |
| `SegmentedButton` | Row of `LaButton`s, selected one `primary`, rest `ghost` |
| `ExpansionTile` | `LaRow(trailing: LaChevron())` + conditional content |
| `Colors.x` (non-token) | nearest `context.laUi` token |
| `Theme.of(context).textTheme/…` | `context.laUi` styles/tokens |

`Icons.*` and `Colors.*` constants may stay (they are data, not grammar).

## _library / ui_kit → kit mapping (legacy kit demolition prep)

Your lane's files must STOP importing `lib/_library/**` and
`package:ui_kit`. Replace usages:

| Legacy | Replacement |
|---|---|
| `DiscordButton` | `LaButton(variant: primary, expand: …)` |
| `AppIconButton`, `CupertinoIconButton`, `SvgIconButton`, `IconShareButton`, `IconIdeaButton`, `EmojiButton`, `SpecialEmojiButton`, `CupertinoCloseButton`, `AdaptiveBackButton` | `LaButton.icon` (pass the same icon widget; keep callbacks/tooltips) |
| `HoverableListTile` | `LaRow` |
| `PopupButton`, `ButtonPopup`, `button_popup` helpers | `LaMenuAnchor` / `showLaMenuAt` |
| `HoverableArea` | `LaPressable.builder` (state.hovered drives your reveal) |
| `FocusBubbleContainer` | `LaPressable` / `LaFocusRing` |
| `MacosAppBar` | `LaTopBar` |
| `RemoveTitleDialog` | `showLaConfirm` |
| `StateLoader`, `LoadableWidget`, `UiCircularProgress` | conditional `LaSpinner` |
| `UiTextField` | `LaField` |
| `UiDivider` | `LaHairline` |
| `UiProgress` | `LaProgress` |
| `DangerZone` | local composition: `LaBox(border: BorderSide(color: laUi.danger))` + `LaButton(variant: destructiveGhost/destructive)` |
| `RightScrollbar` | `LaScrollArea` |
| `BackgroundFrostBox` | plain surface `LaBox` (blur is BANNED — DESIGN.md §Elevation: no glass blur as decoration) |
| Functional-only helpers (`DismissibleTile`, `ResponsiveWidget`, `SafeAreas`, `HeroId`, `ScrollKeyboardCloser`, `FadedRailPage`, `UnsplashImage`, `UnsplashService`, `EmojiGrid`, `SpecialEmojiGrid`, `SpecialEmojiKeyboard`) | lane D ports them to `lib/widgets/legacy_kit/` (widgets-layer only where possible); other lanes: if you use one, inline the same behavior in your lane or reference `package:lastanswer/widgets/legacy_kit/...` AFTER lane D lands — otherwise replace with the obvious widgets-layer equivalent (`Dismissible`, `Hero`, `LayoutBuilder`, `SafeArea`) |

## Definition of done (per lane)

- `grep -nE '\b(TextButton|IconButton|FilledButton|ElevatedButton|OutlinedButton|TextField|TextFormField|DropdownButton|PopupMenuButton|AlertDialog|showDialog|showModalBottomSheet|SnackBar|ScaffoldMessenger|Tooltip\(|ListTile|CircularProgressIndicator|LinearProgressIndicator|Switch\(|Checkbox\(|Radio\(|Slider\(|Card\(|InkWell|Material\(|SelectableText|Scaffold\(|AppBar\()' <your dirs>` returns only entries you listed as "left as Material" with a reason.
- `fvm dart analyze <your dirs>` — no new errors/warnings.
- `fvm flutter test <your lane's tests>` — green.
- Report: files changed; sites converted per widget class; kit gaps found;
  Material left in place (with reasons); test status.
