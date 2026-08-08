---
status: complete
refs:
  - .cue/complete-slides/todo/1785915065-94fa0c9/demo-decision.md
  - .cue/complete-slides/trace/1785915065-94fa0c9/second-rehearsal.md
---
# Executive Plan: Pre-recorded Terminal Demo Pipeline

## Foreword

Following feedback from the second rehearsal (2026-08-05, 6 audience members), a pre-recorded terminal demo will be embedded in the Slidev presentation deck. The rehearsal feedback indicated that the audience expected a visual proof-of-concept for `nix develop`. 

Rather than demonstrating AI agent code generation (which is hard to prove in a short recording), the demo focuses on the **developer-agent contract**: showing that `nix develop` instantly provisions a polyglot environment (Ruby 4.0 + `pg_config`/`libpq` system C-libraries) and produces a passing test suite (`rspec`).

To ensure zero stage risk and time efficiency:
- The video will be rendered deterministically using Charm's `vhs` CLI tool.
- The pipeline will be fully integrated into `coscup-2026-talk/flake.nix` via `nix run .#record-demo`.
- The video will auto-loop silently in Slide 10 ("Case Study 1: A Ruby Shop"), replacing spoken explanation rather than adding extra runtime.

## Architecture

1. **Embedded Demo Workspace (`demo/`)**: A self-contained minimal Ruby application inside `coscup-2026-talk` with `flake.nix`, `Gemfile`, `.ruby-version`, `gemset.nix`, `Gemfile.lock`, and a single `spec/demo_spec.rb` file.
2. **VHS Tape Script (`demo.tape`)**: Script specifying terminal dimensions (1100x676), font size (22px), high-contrast Catppuccin Mocha theme, typing speed, and key strokes.
3. **Flake Package Target (`record-demo`)**: Flake target in `coscup-2026-talk` bringing `vhs` from nixpkgs to build `public/demo.mp4`.
4. **Slidev Integration**: HTML `<video>` element on Slide 10 with `autoplay loop muted playsinline`. PDF exports via `nix run .#pdf` capture the initial frame safely.

## Implementation Steps

- [x] **Step 1: Create local demo application workspace in `demo/`**
  - Created `demo/flake.nix` providing Ruby 4.0 (`pkgs.ruby_4_0`), `pkgs.postgresql_16.pg_config`, `pkgs.libpq`, and `bundlerEnv`.
  - Created `demo/Gemfile`, `demo/.ruby-version` (`4.0.6`), `demo/gemset.nix`, `demo/Gemfile.lock`, and `demo/spec/demo_spec.rb`.
  - Verified `nix develop` execution inside `demo/`.

- [x] **Step 2: Create VHS tape script (`demo.tape`)**
  - Defined high-contrast terminal theme (Catppuccin Mocha), font size 22px, width 1100, height 676.
  - Scripted command flow: `ruby -v`, `pg_config --version`, `nix develop`, `ruby -v` (Ruby 4.0.6), `pg_config --version` (PostgreSQL 16.14), `rspec` (2 examples, 0 failures).
  - Output to `public/demo.mp4`.

- [x] **Step 3: Add `vhs` and `record-demo` app target to presentation `flake.nix`**
  - Added `vhs`, `ffmpeg`, `ttyd`, `chromium`, `xvfb-run`, `fontconfig`, `jetbrains-mono`, `fira-code`, and `nerd-fonts.fira-code` to `coscup-2026-talk/flake.nix`.
  - Configured `fontsConf` (`pkgs.makeFontsConf`) and exported `FONTCONFIG_FILE` for clean monospace font rendering in headless Chromium.
  - Added `nix run .#record-demo` target executing `vhs` wrapped with `xvfb-run -a`.
  - Verified end-to-end rendering via `test.tape` generating `public/test-demo.mp4` and committed as `495017f`.

- [x] **Step 4: Generate video asset**
  - Executed `nix run .#record-demo`.
  - Verified `public/demo.mp4` exists (179 KB) and plays cleanly.

- [x] **Step 5: Embed video in Slide 10 of `slides.md`**
  - Updated Slide 10 ("Case Study 1: A Ruby Shop") in `coscup-2026-talk/slides.md`.
  - Embedded `<video src="/demo.mp4" autoplay loop muted playsinline class="rounded-lg shadow-xl max-h-[380px] w-full object-contain">`.

- [x] **Step 6: Verify presentation build & PDF export**
  - Tested PDF export: `nix run .#pdf` produced `slides-export.pdf` cleanly.

- [x] **Step 7: Update todo and cue log**
  - Marked `demo-decision.md` todo as `complete`.
  - Logged milestone in cue history.
