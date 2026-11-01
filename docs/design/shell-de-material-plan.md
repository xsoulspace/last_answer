# Shell de-Material pass — critique and plan (2026-10-30)

The owner's verdict on the current shell: **"still too material-ish."**
References given: Zed's new-tab picker, Arc's floating pill chrome — and the
correction that matters: **the target vocabulary is Linear-ish/Notion-ish**
(precision, layered quiet surfaces, modern density); the Tufte reference was
about PRINCIPLES (ink is data), not styling — small-caps lettering and
newspaper rules read oldschool and go. `docs/DESIGN.md` §2–3 is amended
accordingly. Craft rules cross-checked against the installed impeccable
vocabulary (`.agents/skills/impeccable/`, craft-floor): contrast, one depth
system per layer, spacing rhythm, honest states, copy as navigation.

## 1. Critique — what makes it read Material

Looked at on the live window (see owner screenshots, 2026-10-30):

1. **Boxes where ink should be.** The rail search is an `OutlineInputBorder`
   rectangle; the composer sits in a rounded box with a visible border; the
   channel disc and the `#lab2` header chip are filled rounded containers;
   every region is framed by a divider. Müller-Brockmann's grid gives
   structure through alignment and whitespace — a border announces "I am a
   form control", which is exactly the Material dashboard smell.
2. **Full-chroma identity discs.** `actorColor` = golden-angle hue at
   saturation 0.58 / lightness 0.48 rendered as a FILLED circle for every
   actor and channel. Random saturated pink/green/red circles everywhere is
   the Discord/Material default; color stops being information because
   everything is colored.
3. **Chrome louder than content.** Icon buttons in boxes/chips, a circular
   send button, boxed presence dots, divider-under-everything. The loudest
   element on any screen should be the words people wrote; today it is the
   furniture.
4. **Type doing no work.** One weight, one size for almost everything
   (labelSmall/bodySmall everywhere), no scale steps to walk up or down, so
   hierarchy falls back to boxes and color. The design law asks for
   typography AS hierarchy.
5. **Both-side borders on inputs + hover pills + ripples** = the Material
   interaction vocabulary. The shell's own vocabulary is quieter: a hover
   tint, a selected tint, nothing else.

## 2. Direction — Linear precision, Notion calm

**Subject**: a reading-and-writing room for humans and actors. **Audience**:
the owner, at a desk, long sessions. **One job**: read the conversation —
so the beats carry the page and everything else steps back.

- **Layered surfaces, dark-first**: base → raised (one step of ink alpha)
  → overlay; hairlines at ~8% ink separate COLUMNS and floating layers,
  nothing inside a region. Structure from alignment and whitespace.
- **Inputs lose their borders** (Linear's law): a field is a placeholder
  over the surface; on hover it earns `shellField`, on focus a subtle
  ring/tint — never an always-on outline box.
- **Identity color stays deterministic but steps back**: same golden-angle
  hue law, deepened for text (sat 0.45 / light 0.36, ≥4.5:1 on light),
  disc fills become the hue at ~12% alpha with glyphs in the ink. Author
  NAMES in beats keep the ink (that is data); nothing else picks it up.
- **Depth is declared once per layer**: the reading grid is flat;
  FLOATING layers (miniwindows, menus, popovers) earn one soft
  offset+blur shadow beside their hairline — never zero-offset halos,
  never an elevation ladder.
- **Type scale gets real steps** (system sans; a self-hosted face is a
  named follow-up): micro-label 11 sentence-case muted (small-caps
  lettering retires), UI 12, body 13.5–14 @1.4+, title 15 w600, page 20.
- **Buttons stop being boxes**: icon affordances are bare glyphs at muted
  ink gaining a quiet hover tint; the send arrow accents only when there
  is text to send.
- **Motion answers action**: 100–150ms ease-out hovers/selection; no
  ambient loops.
- **Accent**: the theme's primary, spent on focus and the one active-tab
  marker — nowhere decorative.

## 3. Per-surface prescriptions

- **Rail**: borderless search (prefix glyph, `shellField` on hover/focus
  only); rows unchanged structurally; previews stay muted; presence dot
  smaller (4px) and colorless (ink 40%).
- **Conversation header**: drop the boxed channel chip; the title is text —
  `#lab2` at titleSmall w600 with the `#` in actor-muted; members count and
  actions as quiet muted text/glyphs on the same baseline. No divider box
  under the header — hairline only.
- **Beats**: bodyMedium text, gutter 44→48, author name w600 in actor color,
  timestamp muted labelSmall on the same line. More space between beat
  GROUPS than between beats inside a group (spacing rhythm).
- **Composer**: borderless field on the surface, hairline ABOVE it only,
  send arrow right-aligned; grows to 3 lines then scrolls.
- **Context panel**: tabs keep small-caps (they're the panel's nav); members
  rows lose the boxed presence, narration line stays muted italic.
- **Tab strip + new-tab picker**: tabs are text + quiet ✕, active tab gets
  the `shellSelected` tint and a 2px accent UNDERLINE (the one accent);
  picker entries are rows on the grid — icon tile in `shellField`, name,
  one-line hint — navigation, not cards.
- **Miniwindows**: keep hairline + fill; title bar small-caps; content =
  the peek (beats at bodySmall, this surface is a glance, not a read).

## 4. Laws kept

- All color still derives from the ambient `ThemeData` (no second palette);
  the only change is HOW MUCH ink each element earns.
- Widget keys untouched — this pass changes paint, never contracts.
- Accessibility floor (impeccable): muted text ≥4.5:1 (verify `shellMuted`
  and beat meta on both themes), hover/selected ≥3:1 against surface,
  keyboard focus visible, touch targets ≥34px stay.

## 5. Verification loop

flutter-design-loop on the live debug app: token edits → hot restart →
window capture (`universal-automation automation_screenshot`, windowId) →
contrast/spacing read → next edit. One surface at a time: beats first (the
content), then header, then rail, then panel, then tabs/picker.
