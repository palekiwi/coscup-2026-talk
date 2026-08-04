---
theme: default
colorSchema: dark
highlighter: shiki
lineNumbers: true
drawings:
  persist: false
transition: slide-left
title: "The Deterministic Rubyist: Taming Your AI Pair Programmer with Nix"
info: |
  COSCUP 2026 Talk Presentation
  The Deterministic Rubyist: Taming Your AI Pair Programmer with Nix
---

# The Deterministic Rubyist
### Taming Your AI Pair Programmer with Nix

COSCUP 2026 - Ruby Track

**Pawel Lisewski** (`@palekiwi`)

---

# About Pale Kiwi (Pawel Lisewski)

<div class="grid grid-cols-2 gap-4">
<div>

- Professional Rubyist
- Polyglot in love with functional programming, Haskell, Nix, Rust
- Interested in declarative, portable, and reproducible environments
- Red Hat Certified Engineer (RHCE)
- **2017:** Running Rails on an Android tablet via terminal chroot
- **2026:** Presenting this entire deck from NixOS running on a **Steam Deck**

</div>
<div>

<img src="/mobility-android-based-rails.jpg" class="rounded-lg shadow-md max-h-70 mx-auto" alt="Rails on Android Tablet (2017)" />

<p class="text-xs text-center text-gray-400 mt-2">Taipei Ruby Meetup, 2017: Rails running on Android tablet</p>

</div>
</div>

---

# Why this talk? Why now?

- AI coding agents require predictable, reproducible runtime environments
- Nix makes agents more effective, and agents make Nix more accessible
- **The Shopify Anecdote:**
  - **Era 1 (2019):** Introduced Nix across ~1,000 macOS laptops to replace Homebrew
  - **Gap (2020-2023):** Shifted away to cloud development environments
  - **Era 2 (2024-present):** Returned to local Nix development with incremental opt-in
- Key takeaway: *Meet devs where they're at, migrate incrementally, allow opting-in*

---

# Three questions for the room

<v-clicks>

1. **Who uses an AI coding tool every day?**

2. **Who has seen a `flake.nix` in a repository?**

3. **Who has tried Nix, hit an error, and given up?**

</v-clicks>

---

# Agents need real environments, not just code

- Agents run tests, linters, LSPs, QA suites, and native builds
- High execution speed means higher rate of environment interaction
- Agents must operate inside isolated sandboxes to execute code safely
- **The concrete harm scenario:**

<div class="mt-6 p-4 bg-red-950 border border-red-800 rounded-lg">

> *"The agent wrote the code, could not run the test suite because the box lacked the system library, declared success anyway, and you merged it."*

</div>

---

# A sandbox starts empty. Nix fills it.

```
+-------------------------------------------------------------+
|                      Developer Laptop                       |
|                                                             |
|  +-----------------------+     +-------------------------+  |
|  |     AI Agent          |     |    Developer Shell      |  |
|  |     (Sandbox)         |     |                         |  |
|  +-----------+-----------+     +------------+------------+  |
|              |                              |               |
|              v                              v               |
|  +-------------------------------------------------------+  |
|  |             flake.nix / Nix Store (/nix)              |  |
|  |  (Ruby 3.3.6, libpq, libvips, Node, Elm toolchain)    |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+
```

- An empty container is safe, but lacks runtimes and system C-libraries
- Nix fills the sandbox deterministically, and runs identically on developer laptops
- **Scope:** Development environment only (not production or deployment)

---

# Containers isolate processes, but fill boxes poorly

- **Package availability** is tied to the base distribution image
- **Composition** occurs at process boundaries rather than package boundaries
- **Slow rebuilds** whenever environment definitions change
- **Caching** operates at layer granularity instead of package granularity

<div class="mt-6 p-4 bg-gray-800 rounded-lg text-center">

*Composition, not competition: Nix composes with containers; it does not replace them.*

</div>

---

# Your README is a contract nobody enforces

```markdown
## Prerequisites
- Ruby 3.3.6 (via rbenv, asdf, or mise)
- PostgreSQL 16 client C-libraries (libpq-dev)
- ImageMagick / libvips
- Node.js 22 & pnpm 9
- Elm 0.19.1 & elm-format
```

- Written in prose, enforced by hope
- Language version managers cover runtimes, not system C-libraries or tools
- Agents misread or install conflicting versions without isolation

<v-click>

> *"Your README promises an environment. Nix keeps the promise."*

</v-click>

---

# 3 Ruby versions, 4 languages, 1 container

```
+------------------+  +------------------+  +------------------+
| storefront       |  | checkout-api     |  | identity         |
| Ruby 3.3.6       |  | Ruby 3.2.7       |  | Ruby 3.1.6       |
| Elm / Node 22    |  | Sinatra          |  | Rails 7.1        |
+------------------+  +------------------+  +------------------+
+------------------+  +------------------+  +------------------+
| notifications    |  | admin-ui         |  | legacy-crm       |
| Go 1.23 / Redis  |  | Node 22 / Vue 3  |  | Ruby 1.8.7       |
+------------------+  +------------------+  +------------------+
```

---

# A flake as everyone's entrypoint

- When a repository contains a `flake.nix`, the agent enters with `nix develop`
- Zero manual environment installation steps
- Zero global version manager shims
- Identical environment for both agent and human developer

---

# Nix is a purely functional, lazily evaluated, domain-specific programming language.

```nix
# Anonymous function: parameter: body
x: x + 1

# Applied inline:
(x: x + 1) 5                          # => 6

# Attribute set parameter applied inline:
({ x, y }: x + y) { x = 2; y = 3; }   # => 5
```

That third form is the first line of almost every flake you will ever open.

- `:` is the lambda arrow (not a type annotation)
- `=` binds values in attribute sets (not variable assignment)
- `{ }` with `:` defines function parameter destructuring
- `...` is real syntax meaning "and any other inputs"

---

# A minimal development environment in Nix

```nix {all|2-6|9-13|14-20|all}
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-ruby, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        ruby = nixpkgs-ruby.packages.${system}."ruby-3.3.6";
      in {
        devShells.default = pkgs.mkShell {
          packages = [
            ruby
            pkgs.libpq   # System C-library required by pg gem
            pkgs.bundler
          ];
        };
      });
}
```

---

# Nix configuration is a computation, not an inert text file

```nix
{
  outputs = { self, nixpkgs, nixpkgs-ruby, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        rubyVersion = pkgs.lib.fileContents ./.ruby-version;
        ruby = nixpkgs-ruby.packages.${system}."ruby-${rubyVersion}";
      in {
        devShells.default = pkgs.mkShell {
          packages = [ ruby pkgs.libpq ];
        };
      });
}
```

- Reads the existing `.ruby-version` file programmatically
- Evaluated dynamically via Git state; pinned precisely via `flake.lock`
- *"Meet devs where they're at"* rendered as code

---

# Double Gemfile: Computed configuration in action

```nix
# Synthesize an agent-specific Gemfile at evaluation time
agentGemfile = pkgs.writeText "Gemfile.agent" (
  pkgs.lib.replaceStrings 
    ["gem 'pry'", "gem 'byebug'"] 
    ["# gem 'pry'", "# gem 'byebug'"] 
    (builtins.readFile ./Gemfile)
  + "\ngem 'ruby-lsp'\n"
);
```

- **Remove interactive debuggers:** Strips `pry`/`byebug` to prevent non-interactive agent hangs
- **Inject agent tooling:** Adds `ruby-lsp` without editing checked-in `Gemfile`
- **Pure and declarative:** Computed without side effects at evaluation time

---

# Choose where to draw the Nix boundary

<div class="grid grid-cols-2 gap-4">
<div class="p-4 bg-gray-800 rounded-lg">

### Boundary 1 (Pragmatic)
- Nix provides system packages (`libpq`, `libvips`) + Ruby
- Bundler manages gems (`bundle install`) as usual
- Zero friction for existing gem workflows
- Immediate win in bare sandboxes

</div>
<div class="p-4 bg-gray-800 rounded-lg">

### Boundary 2 (Hermetic)
- Nix manages gems via `bundlerEnv` / `bundix`
- Stored in `/nix/store`, immutable and fully locked
- Ideal for full reproducibility
- Requires team adaptation

</div>
</div>

<div class="mt-4 p-3 bg-gray-900 border border-gray-700 rounded text-sm text-center">

Shopify insight: *"nix + bundix put up an immutable wall -- avoid bundix initially, migrate incrementally."*

</div>

---

# Hermetic gems with bundlerEnv

```nix
{
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        gems = pkgs.bundlerEnv {
          name = "spabreaks-gems";
          ruby = pkgs.ruby_3_3;
          gemdir = ./.;
        };
      in {
        devShells.default = pkgs.mkShell {
          packages = [ gems gems.wrappedRuby pkgs.libpq ];
        };
      });
}
```

- Gems built and isolated inside `/nix/store` via `bundlerEnv`
- Native C-extensions compiled against Nix system libraries
- Fully hermetic environment pinned by `gemset.nix`

---

# Case Study: The palekiwi multi-repository ecosystem

```
+-------------------------------------------------------------+
|               palekiwi Personal Control Center              |
|                     (Cross-project workspace)               |
+------------------------------+------------------------------+
                               |
       +-----------------------+-----------------------+
       |                                               |
       v                                               v
+-----------------------------+         +-----------------------------+
| cue (Rust CLI & Cuelib)     |         | cast (Rust Sandbox Engine)  |
| - cue-plugins (TS/Bun)      |         | - cast-agent                |
| - cue.nvim (Lua plugin)     |         | - cast-mcp-client           |
+-----------------------------+         +-----------------------------+
```

- Real workspace composition across Rust, TypeScript, Lua, and Nix
- Nix manages build sandboxes and cross-repo tool availability

---

# Vertical composition: Nesting development shells

```bash
# Outer shell: Global AI agent tools provided by host
$ nix develop github:palekiwi/nix-config#opencode
(cast-opencode) $

# Inner shell: Project specific environment
(cast-opencode) $ nix develop
(spabreaks-dev) $ bundle exec rake test
```

```
+-------------------------------------------------------+
|  Global Agent Harness Shell (llm-agents flake)        |
|  (opencode, cue, ast-grep, git)                        |
|  +-------------------------------------------------+  |
|  |  Project Development Shell (flake.nix)          |  |
|  |  (Ruby 3.3.6, libpq, libvips, nodejs)           |  |
|  +-------------------------------------------------+  |
+-------------------------------------------------------+
```

---

# Seamless package distribution across repositories

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Pin to explicit Git commit
    cast.url = "github:palekiwi-labs/cast/2b25028b6cdcb4ff1a8d8dbb1624276fb2656a8d";
    # Local filesystem path
    cue-plugins.url = "path:../cue-plugins";
  };

  outputs = { self, nixpkgs, cast, cue-plugins }: {
    # Consume Rust binaries directly in project builds
    # Zero release process or package registry required
  };
}
```

- Direct cross-repository dependency consumption
- Pinning via Git revisions or local filesystem sources

---

# Isolation and efficiency share the same mechanism

```
+-------------------------------------------------------------+
|                     Host System / Daemon                    |
|             nix-daemon (owns /nix/store Read-Write)          |
+------------------------------+------------------------------+
                               | Read-Only Mount (/nix)
              +----------------+----------------+
              v                                  v
+--------------------------+        +--------------------------+
|  Agent Sandbox 1         |        |  Agent Sandbox 2         |
|  (Debian + mounted /nix) |        |  (Debian + mounted /nix) |
+--------------------------+        +--------------------------+
```

- Sandboxes are lightweight Debian containers mounting `/nix` read-only
- Package reuse across all sandboxes at package granularity
- Zero rebuild time, zero store corruption risk

---

# Don't climb the learning curve. Delegate it.

- LLMs are remarkably effective at writing and repairing Nix flakes
- Scattered, online Nix documentation is well-suited for model synthesis
- Agents handle syntax and inputs while human developers audit the contract

<div class="mt-8 p-4 bg-gray-800 rounded-lg text-center">

*"Don't climb the learning curve. Delegate it."*

</div>

---

# Start at the first boundary

1. **Install Nix:** Use the Determinate Systems installer or devcontainer feature
2. **Add a `flake.nix`:** Target Boundary 1 for system libraries + Ruby runtime
3. **Let your agent prove it:** Agent builds and verifies the environment inside the sandbox
4. **Opt-in:** Human developers switch when ready

<div class="mt-8 p-4 bg-gray-800 rounded-lg text-center">

*"Start at the first boundary. One file, one repo, nobody's permission."*

</div>

---

# It worked on my machine. Now it works on every machine.

<div class="grid grid-cols-2 gap-4">
<div>

- **Presentation & Deck:** `github.com/palekiwi/coscup-2026-talk`
- **Workspace:** `github.com/palekiwi/palekiwi`
- **Open Source:** `github.com/palekiwi-labs`
- **Contact:** `contact@palekiwi.com`

</div>
<div>

<img src="/palekiwi-avatar.jpg" class="rounded-full w-40 h-40 mx-auto shadow-lg mb-4" alt="palekiwi" />

<p class="text-center text-sm font-semibold">Pawel Lisewski (@palekiwi)</p>

</div>
</div>

<div class="mt-6 p-4 bg-gray-800 rounded-lg text-center font-bold">

*"It worked on my machine. Now it works on every machine -- including this one."*

</div>
