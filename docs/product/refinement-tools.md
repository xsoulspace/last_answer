# Decision & refinement tools

## Why these tools and where they fit

Refining ideas and docs is slow when we don’t know *what to do* or *why*. These tools give a clear “what to do” (steps) and “why” (outcome) so anyone can use them without learning theory. Names describe the **outcome**, not the method.

**Where they belong:** In **Ideas**, they structure answers (e.g. “Find root cause” on a “Why?” answer). In the **GDD/PRD editor**, they live under Select → Do: user selects a span and chooses a refinement action (Find root cause, See full picture, Test one change, etc.). Same tools, two entry points—faster refinement, higher quality, without leaving the doc.

---

## Single-prompt

**Single-prompt** is a disciplined way of working in which one plain-language goal becomes one clear execution path, proceeds through normal checkpoints, and counts as done only when evidence proves the result.

Use it when you want to go from a vague intent to a shippable outcome: state the goal in one sentence, follow the path, and treat “done” as proven by evidence, not by opinion.

---

## Tools (what to do and why)

| Tool name (outcome) | Origin | What to do | Why use it |
|--------------------|--------|------------|------------|
| **Find root cause** | 5 Whys (Toyota) | Ask “Why?” up to 5 times. The last answer is the root cause. | Stop fixing symptoms; fix what actually causes the problem. |
| **See the full picture** | SWOT | Four boxes: Strengths, Weaknesses, Opportunities, Threats. | Don’t commit with blind spots; see upside and risk in one view. |
| **Test one change** | PDSA (Plan–Do–Study–Act) | Plan (what we’ll do) → Do it → Study (what happened) → Act (keep, drop, or adjust). | Learn from one change before scaling; avoid big bets on untested assumptions. |
| **Improve with data** | Six Sigma / DMAIC | 1) Define the problem in one sentence. 2) What would “better” look like (one number or check)? 3) One change to try. 4) How will you check it? | Make improvement concrete and measurable instead of vague. |
| **Map causes** | Fishbone / Ishikawa diagram | One problem statement. Add 4–6 cause categories (e.g. People, Process, Tech, Environment). Under each, list possible causes. | Structure exploration of “what could be causing this?” without ad-hoc lists. |
| **Record the decision** | ADR (Architecture Decision Record) | For each decision: Context → Decision → Consequences. | Later you’ll know why we chose this; no “we always did it that way” amnesia. |
| **What would kill this?** | Inversion / Pre-mortem | Assume we shipped and it failed. List 3–5 reasons why. | Surface risks before commit; inversion often reveals what optimism hides. |
| **So what?** | Impact chain | Keep asking “So what?” until you hit the outcome that actually matters (e.g. revenue, retention, risk). | Move from feature/activity to real impact. |
| **One thing that must be true** | Critical assumption (Lean Startup) | “For this to work, one thing *must* be true. What is it?” Then: “How do we check that?” | Stress-test the idea; if that one thing is false, the idea fails. |
| **List assumptions** | Assumption mapping | Bullet “What are we assuming?” Mark each: know / believe / hope. | Make assumptions visible so we can validate or drop them. |
| **For vs against** | Pros and cons | Two columns, ~2 minutes: reasons for, reasons against. | Quick go/no-go without endless debate. |
| **Impact vs effort** | 2×2 prioritisation / impact–effort matrix | Two axes: Impact (low→high), Effort (low→high). Place options. Do high-impact, low-effort first. | Prioritise clearly; avoid “everything is important.” |
| **Can we undo it?** | Reversibility (decision theory) | “If we’re wrong, can we undo it? If no: slow down, get more signal.” | Don’t treat reversible and irreversible bets the same. |
| **Argue against it** | Red team / devil’s advocate | “Someone will say this is wrong. What would they say?” List and answer. | Strengthen the doc or idea by facing the best counterarguments. |
| **One sentence** | Elevator pitch / one-liner | “Say the idea in one sentence.” If you can’t, narrow the idea. | Force clarity; one-sentence goal is the bar (see GDD/PRD goal). |
| **When / I want / So I can** | Jobs to be done (JTBD) | Fill: “When [situation], I want to [action], so I can [outcome].” | Lock who it’s for and what job we’re helping them do. |

---

## Summary

- **Why:** So refinement is fast and high-quality, with clear “what to do” and “why,” without requiring theory.
- **Where:** Ideas (structure answers) and GDD/PRD editor (Select → Do refinement actions on a span).
- **Single-prompt:** One plain-language goal → one execution path → done when evidence proves the result.
