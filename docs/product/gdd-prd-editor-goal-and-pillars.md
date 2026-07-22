# GDD / PRD Editor — Goal & Pillars

## Goal (one sentence)

**The document is the product: one surface where you edit, discuss any span, and act with AI on exactly what you selected—without ever leaving the doc.**

---

## Problem we solve

- Capturing and refining ideas and design docs is slow when you have to leave the doc to discuss, comment, or use AI.
- Comments live in another UI; AI lives in another app. Context is lost; round-trips add friction.
- We want: **one surface** where you edit, discuss specific bits, and act with AI on exactly the selection you care about — without leaving the document.

---

## Pillars

These four pillars define what “done” looks like and how we make decisions. Each exists to make the goal true.

### 1. The document is the product — edit freely

- **What:** The doc is the product. Users edit GDD/PRD content without fighting the tool — no artificial limits, no “preview mode” to see structure. Optional structure (sections, headings, lists) supports GDD/PRD without getting in the way.
- **Success:** Writing and restructuring feel as fluid as the best notes experience. The doc is always the source of truth.
- **Why for the goal:** If editing is not free and fluid, users leave the surface; the goal collapses.

### 2. Select → Do (the 10x interaction)

- **What:** Selection defines scope. User selects text; a small contextual action set appears: Discuss, Ask AI, Expand, Summarise, and refinement tools (e.g. Find root cause, See full picture, Test one change—see [Decision & refinement tools](/product/refinement-tools)). One gesture, one place. No leaving the doc.
- **Success:** Select → choose action. No mode switch. First action feels instant (&lt;300 ms). Going back to “doc in one place, AI elsewhere” feels broken.
- **Why for the goal:** This is the differentiator. Without Select → Do in one surface, we are just another editor with a separate AI panel.

### 3. Discuss and thread every span

- **What:** Every sentence, paragraph, or chosen span can have its own discussion thread. Conversations are anchored to the exact fragment, not to a separate comments panel. Threads live on the span.
- **Success:** User opens a thread for “this paragraph” or “this sentence” and thinks/chats in context; the doc remains the source of truth; threads are first-class but secondary to the content.
- **Why for the goal:** Discussion in another UI is leaving the doc. Span-level threads keep “one surface” intact.

### 4. Pluggable inference (AI)

- **What:** The app depends on an **inference interface**, not a specific provider. Implementations (OpenAI, Codex, local, etc.) live in packages (e.g. `xsoulspace_inference`); anyone can wire their own solution. One default path for zero-friction start; pluggable for trust and ecosystem.
- **Success:** One clear abstraction in the app; multiple backends possible; no hard dependency on a single AI vendor. No “AI theater”—when we say AI, we use the inference interface.
- **Why for the goal:** Pluggable AI keeps trust and optionality so teams adopt the one surface without vendor lock-in.

---

## How the pillars work together

| User intent         | Pillar(s)                    | Outcome                                       |
| ------------------- | ---------------------------- | --------------------------------------------- |
| Write / restructure | Edit freely                  | Doc updates immediately; structure optional.  |
| “Discuss this”      | Select → Do + Discuss/thread | Thread opens for selected span; stay in doc.  |
| “Ask AI about this” | Select → Do + Pluggable AI   | Selection + context → inference; stay in doc. |
| “Expand / shorten”  | Select → Do + Pluggable AI   | Span + instruction → inference → suggestion.  |

**Golden rule:** If a feature makes the user leave the doc to discuss or use AI, it violates the goal.

---

## Non-goals (out of scope for this feature)

- Replacing the existing Ideas and Notes flows; this adds a **doc** type (GDD/PRD) alongside them. Ideas/Notes can feed into or from the doc (e.g. “Start from an idea” → doc).
- Building a specific AI provider inside the app; we define the interface and let packages implement it.
- Real-time multiplayer or presence; threads are async discussion per span. Multiplayer is a second act after Select → Do and threads are unbeatable.

---

## References

- Product/design discussion: GDD/PRD editor with free edit, span-level threads, selection actions, pluggable AI.
- Technical direction: block-based doc model, span identity, threads keyed by span, inference interface in core with implementations in packages (e.g. `xsoulspace_inference`).
