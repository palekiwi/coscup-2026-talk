# Project Log

## [94fa0c9] Second rehearsal feedback split into two todos

Second rehearsal on 2026-08-05 to six people ran 36 minutes against a
25:00 content target. Two audience-raised items carved out of
trace/1785915065-94fa0c9/second-rehearsal.md into todos in the same
timestamp directory: syntax-highlight-contrast.md and
demo-decision.md, both high priority with four days to delivery.

The timing overrun is deliberately NOT a todo. It is a structural
problem the existing cut order cannot solve and belongs in
plan/index.md, not in a deferred note.

- **Found:** Rehearsal ran 36:00 against a 24:30 plan, roughly 11 minutes over. The planned cut order totals -3:35, so it is nowhere near sufficient and the plan's overrun estimate of 3 to 4.5 minutes was badly optimistic
- **Found:** Speaker could identify no section to cut wholesale, only 'less time on almost all slides'. That is a uniform-compression instinct, which is the failure mode plan/index.md was written to avoid
- **Found:** The audience wanted a demo and named its absence unprompted. The original no-demo rationale addressed proving agent competence, not showing that nix develop produces a working environment -- a different and easier job the rationale never covered
- **Found:** Code snippet contrast is a readability failure, not a cosmetic one: flake excerpts are the deck's primary visual and the audience could not read them
- **Found:** Font size and text volume are both constrained, so the contrast fix must come from the Shiki theme rather than from layout or content reduction
- **Decided:** Syntax highlighting fixed by changing the Shiki theme, not by enlarging fonts or deleting slide text; the text density serves listeners with weaker English comprehension and stays
- **Decided:** Demo decision reopened rather than reaffirmed, with option 2 (no demo, announced up front) recorded as the audience's own zero-cost fallback
- **Decided:** Demo decision to be made alongside the timing work, since option 1 adds time to a talk that must lose eleven minutes
- **Decided:** Timing overrun kept out of the todos and left for plan/index.md, since it requires a structural decision rather than a deferred note
- **Open:** How to recover eleven minutes. The existing cut order is insufficient by a factor of three and no section has been identified for removal
- **Open:** Whether the recorded terminal session referenced in the outro gets made or the reference gets dropped; the demo todo settles both
- **Open:** Projector size and rendering unverified; confirm on day one of the conference, talk is day two

## [94fa0c9] Demo recording plan finalized and linked to todo

Resolved demo decision todo by choosing Option 1 (pre-recorded VHS terminal session auto-looping on Slide 10). Created detailed executive plan in .cue/complete-slides/plan/1785915065-94fa0c9/demo-recording-pipeline.md linking to the demo todo and rehearsal trace.

The demo will record a 35-45 second sequence showing nix develop provisioning Ruby 3.3.6 + pg_config/libpq and running a passing rspec suite. Built headlessly via Charm's vhs tool, integrated into flake.nix as 'nix run .#record-demo', and embedded in Slidev Slide 10. Narration over the video replaces spoken explanation to ensure net zero added runtime.

- **Found:** A 45-second auto-looping terminal video provides visual proof of concept without adding talking time
- **Found:** Charm's vhs produces deterministic, crisp, dark-themed terminal MP4 output via nixpkgs
- **Found:** Playwright Chromium in Slidev PDF export snapshots the video's first frame cleanly
- **Decided:** Adopt Option 1 (pre-recorded terminal session) via Charm VHS tool, generating public/demo.mp4
- **Decided:** Embed auto-looping video in Slide 10 (Case Study 1: A Ruby Shop) where nix develop is introduced as everyone's entrypoint
- **Decided:** Demo records a polyglot Ruby + pg_config/libpq sequence culminating in a green rspec test suite
- **Decided:** Integrate vhs and record-demo command into coscup-2026-talk/flake.nix
- **Decided:** Narration over video replaces abstract spoken explanation, keeping time impact net-zero
- **Open:** Executing the 7 implementation steps from the demo-recording-pipeline plan

## [495017f-dirty] Committed record-demo target and font configuration in flake.nix

Committed flake changes in coscup-2026-talk (commit 495017f). Added record-demo package target using VHS, xvfb-run, ffmpeg, ttyd, chromium, and fontconfig with JetBrains Mono / Fira Code fonts. Verified end-to-end MP4 video generation via 'nix run .#record-demo -- test.tape' and playback via ffplay.

- **Found:** nix run .#record-demo produces crisp, high-contrast MP4/GIF assets using JetBrains Mono font and headless xvfb-run Chromium
- **Decided:** Committed 495017f in coscup-2026-talk adding record-demo and font configuration to flake.nix
- **Open:** Building the actual demo/ workspace and demo.tape script for Slide 10

## [495017f-dirty] Updated demo recording plan to in-progress with Step 3 completed

Updated demo-recording-pipeline executive plan to in-progress state. Marked Step 3 as completed following commit 495017f in coscup-2026-talk. Flake configured with vhs, xvfb-run, ffmpeg, ttyd, fontconfig, and JetBrains Mono/Fira Code fonts. End-to-end rendering tested and verified with ffplay. Remaining steps: create demo/ workspace, write demo.tape, generate public/demo.mp4, and embed in Slide 10.

- **Found:** VHS headless rendering with xvfb-run + JetBrains Mono font is verified and fully functional via nix run .#record-demo
- **Decided:** Updated plan .cue/complete-slides/plan/1785915065-94fa0c9/demo-recording-pipeline.md status to in-progress and marked Step 3 as complete
- **Open:** Steps 1, 2, 4, 5, 6, 7 of demo-recording-pipeline plan remaining

## [6fcb9d3] Settled production demo filenames and embedded video on Slide 10

Settled production video filenames and layout on Slide 10 in coscup-2026-talk (commit 6fcb9d3). Created demo.tape and public/demo.mp4, embedded /demo.mp4 on Slide 10 in a 2-column grid layout with object-contain and max-h-[380px]. Verified clean build and PDF export via 'nix run .#pdf'.

- **Found:** nix run .#record-demo seamlessly builds public/demo.mp4 from demo.tape using headless Chromium and xvfb-run
- **Decided:** Settled production demo filenames (demo.tape -> public/demo.mp4) and embedded /demo.mp4 on Slide 10
- **Open:** Scripting actual polyglot Ruby + pg_config sequence into demo.tape once demo/ workspace is ready

## [0c2fb81] Updated VHS tape font size (22) and line height (1.3)

Committed style updates in coscup-2026-talk (commit 0c2fb81). Set VHS font size to 22 and line height to 1.3 in demo.tape. Re-generated public/demo.mp4 and verified PDF slide export page 9 snapshot.

- **Found:** VHS natively supports Set LineHeight (1.3 gives excellent vertical spacing for terminal outputs)
- **Decided:** Committed 0c2fb81 updating demo.tape with Set FontSize 22 and Set LineHeight 1.3
- **Open:** Creating local demo/ workspace and scripting the full terminal sequence

## [5e60554] Completed pre-recorded terminal demo pipeline (demo.mp4) for Slide 10

Completed the pre-recorded terminal demo pipeline for Slide 10 of coscup-2026-talk. Built local demo application workspace in demo/ with Ruby 4.0 (pkgs.ruby_4_0), PostgreSQL 16 (pkgs.postgresql_16.pg_config and pkgs.libpq), Gemfile, .ruby-version, gemset.nix, and spec/demo_spec.rb. Rendered high-contrast terminal video public/demo.mp4 via Charm VHS (demo.tape) and verified auto-loop video embedding on Slide 10 and clean PDF export. Committed git commit 5e60554 in coscup-2026-talk.

- **Found:** nix develop inside demo/ provisions Ruby 4.0.6 and PostgreSQL 16.14 in seconds and runs passing rspec test suite
- **Found:** nix run .#record-demo produces deterministic 1100x676 MP4 video using Catppuccin Mocha theme and JetBrains Mono font
- **Found:** nix run .#pdf generates clean slides-export.pdf with Playwright Chromium capturing initial frame of video element
- **Decided:** Used Ruby 4.0 (pkgs.ruby_4_0) with .ruby-version 4.0.6 for modern runtime demonstration
- **Decided:** Used pkgs.postgresql_16.pg_config and pkgs.libpq for system C-library setup
- **Decided:** Committed demo workspace and public/demo.mp4 as commit 5e60554 in coscup-2026-talk

