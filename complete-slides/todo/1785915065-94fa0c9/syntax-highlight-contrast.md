---
status: complete
priority: high
refs: .cue/complete-slides/trace/1785915065-94fa0c9/second-rehearsal.md
---
# Code snippet syntax highlighting is unreadable

Raised by the audience at the second rehearsal (2026-08-05, 6 people).
Source: `trace/1785915065-94fa0c9/second-rehearsal.md`.

## Problem

Syntax highlighting in the code snippets has very low contrast against
the dark theme. Listeners could not read the code. Since roughly half
the deck is flake excerpts, this is not cosmetic -- it degrades the
single most important visual element in the talk.

## Constraints

- **Font size is nearly maxed out.** There is little vertical margin
  left on the code slides.
- **Text volume must stay.** The density is deliberate: listeners with
  weaker English listening comprehension recover the point from the
  screen. Do not solve contrast by deleting lines.
- Therefore the fix is a **better Shiki theme**, not a layout change.

## Actions

1. Pick a higher-contrast Shiki theme for the dark background. Verify
   against the actual flake snippets, not a sample file.
2. Check whether `styles/index.css` overrides (orange bold `#fb923c`,
   red inline code `#f87171`) still read well against the new theme.
3. Verify in the exported PDF as well as the browser -- the venue AV
   desk may run the PDF.
4. Confirm projector size and rendering on day one of the conference
   (talk is day two, 9 August).
