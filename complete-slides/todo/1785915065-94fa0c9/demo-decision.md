---
status: complete
priority: high
refs:
  - .cue/complete-slides/trace/1785915065-94fa0c9/second-rehearsal.md
  - .cue/complete-slides/plan/1785915065-94fa0c9/demo-recording-pipeline.md
---
# Reopen the demo decision

Raised by the audience at the second rehearsal (2026-08-05, 6 people).
Source: `trace/1785915065-94fa0c9/second-rehearsal.md`.

## Problem

The room expected a demo, waited for one, and did not get one. That
expectation was unmet rather than merely unfulfilled -- the audience
named it unprompted.

The original decision was that a recording proves nothing to a sceptic
who assumes fifteen takes, and that first-hand testimony with honest
failure rates is stronger evidence. That reasoning was about proving
**agents can write Nix**. It does not address a different and simpler
job: showing that `nix develop` produces a real, working environment.

## Options

1. **Pre-recorded terminal session** (asciinema), showing `nix develop`
   arriving at a meaningful outcome -- a green suite, a REPL with the
   right Ruby, a tool that was not on the host. Embedded so it cannot
   fail on stage. Costs 30-60 seconds the talk does not currently have.
2. **No demo, announced up front.** The audience's own fallback
   suggestion: state early that there will be no demo and why, so the
   room stops waiting for one. Costs one sentence.
3. Some hybrid: a still frame of the outcome rather than a recording.

## Tension to resolve

The talk is already 11 minutes over budget (36:00 against a 25:00
target). Option 1 adds time to a talk that must lose a lot of it.
Option 2 costs nothing and removes the disappointment, but leaves the
argument without empirical support.

Decide alongside the timing work, not separately.

## Note

Section 10 of `plan/index.md` (the palekiwi workspace) already
references a recorded terminal session in the outro that does not
exist. Whatever is decided here settles that reference too.

## Resolution

Decided 2026-08-06: **Adopt Option 1 (Pre-recorded terminal session via VHS).**

- **Format:** 35–45 second VHS terminal recording (`public/demo.mp4`), embedded in Slide 10 ("Case Study 1: A Ruby Shop") on auto-loop with `autoplay loop muted playsinline`.
- **Content:** Polyglot Ruby + `pg_config`/`libpq` system library environment (`ruby -v`, `pg_config --version`, `nix develop`, `bundle exec rspec` green).
- **Execution plan:** `.cue/complete-slides/plan/1785915065-94fa0c9/demo-recording-pipeline.md`.
- **Timing impact:** Spoken explanation is replaced by narration over the auto-loop video, resulting in net zero added time.

