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

**palekiwi** (`@palekiwi`)

---

# Shopify tried Nix, abandoned it, and came back

- **Era 1 (2019):** Burke Libbey introduced Nix to replace Homebrew and parts of Bundler across ~1,000 macOS laptops
- **The Gap (2020-2023):** Shifted away to cloud development environments (*Spin / Isospin*)
- **Era 2 (2024-present):** Moved back to local development with Nix and monorepos
- **Key takeaways:** *Meet devs where they're at*, *migrate incrementally*, *allow opting-in*

<v-click>

> *"Shopify has now learned this twice: you cannot just hand people Nix. So what do you do instead?"*

</v-click>

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

- Agents require isolated sandboxes to execute code safely
- An empty container is safe, but lacks runtimes and system dependencies
- Nix fills the sandbox deterministically, and runs identically on human laptops
- **Scope:** Development environment only (not production or deployment)

---

# Eight years of Ruby and Nix in production

<div class="grid grid-cols-2 gap-4">
<div>

- **palekiwi:** Personal control center & OSS maintainer
- **cast:** Docker & Nix reproducible agent sandboxes
- **cue:** File-based agent memory system in Rust
- **2017:** Running Rails on an Android tablet via terminal chroot
- **2026:** Presenting this entire deck from NixOS running on a **Steam Deck**

</div>
<div>

<img src="/mobility-android-based-rails.jpg" class="rounded-lg shadow-md max-h-70 mx-auto" alt="Rails on Android Tablet (2017)" />

<p class="text-xs text-center text-gray-400 mt-2">Taipei Ruby Meetup, 2017: Rails running on Android tablet</p>

</div>
</div>

---

# Three questions for the room

<v-clicks>

1. **Who uses an AI coding tool every day?**

2. **Who has seen a `flake.nix` in a repository?**

3. **Who has tried Nix, hit an error, and given up?**

</v-clicks>

<v-click>

<div class="mt-8 p-4 bg-gray-800 rounded-lg text-center">

*"You already know the value is there. You just could not pay the price of entry."*

</div>

</v-click>

---

# Agents need real environments, not just code

- Agents run tests, linters, LSPs, QA suites, and native builds
- High execution speed means higher rate of environment interaction
- **The concrete harm scenario:**

<div class="mt-6 p-4 bg-red-950 border border-red-800 rounded-lg">

> *"The agent wrote the code, could not run the test suite because the box lacked the system library, declared success anyway, and you merged it."*

</div>

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
- Ruby 3.4.2 (via rbenv or asdf)
- PostgreSQL 16 client libraries (libpq-dev)
- ImageMagick / libvips
- Node.js 22 & pnpm 9
- Elm 0.19.1 & elm-format
```

- Written in prose, enforced by hope
- Language version managers cover runtimes, not C libraries or tools
- Agents misread or install conflicting versions without isolation

<v-click>

> *"Your README promises an environment. Nix keeps the promise."*

</v-click>

---

# Four Ruby versions, two languages, one laptop

```
+------------------+  +------------------+  +------------------+
| storefront       |  | checkout-api     |  | identity         |
| Ruby 3.4.2       |  | Ruby 3.3.6       |  | Ruby 3.2.7       |
| Elm / Node 22    |  | Sinatra          |  | Rails 7.1        |
+------------------+  +------------------+  +------------------+
+------------------+  +------------------+  +------------------+
| notifications    |  | admin-ui         |  | legacy-crm       |
| Go 1.23 / Redis  |  | Node 22 / Vue 3  |  | Ruby 1.8.7       |
+------------------+  +------------------+  +------------------+
```

- A development environment is mostly not gems:
  `libpq`, `libxml2`, `libxslt`, `pkg-config`, `nodejs`, `pnpm`, `elm`, `elm-format`, `elm-language-server`
- Version managers handle the interpreter, never the system dependencies

---

# A flake.nix is the entry point for agents

- When a repository contains a `flake.nix`, the agent enters with `nix develop`
- Zero manual environment installation steps
- Zero global version manager shims
- Identical environment for both agent and human developer

---

# Nix is a purely functional, evaluated language

```nix
# Anonymous function: parameter: body
x: x + 1

# Applied inline:
(x: x + 1) 5                          # => 6

# Attribute set parameter applied inline:
({ x, y }: x + y) { x = 2; y = 3; }   # => 5
```

- `:` is the lambda arrow (not type annotation)
- `=` binds values in attribute sets (not variable assignment)
- `{ }` with `:` defines function parameter destructuring
- `...` is real syntax meaning "and any other inputs"

> *"That third form is the first line of almost every flake you will ever open."*

---

# A complete environment in forty lines of Nix

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
            pkgs.libpq
            pkgs.bundler
          ];
        };
      });
}
```

- Complete, self-contained development environment
- `flake.lock` pins every transitive dependency
- Enter with `nix develop`

---

# Read existing files instead of rewriting them

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

- Reads the `.ruby-version` file the team already maintains
- No new config files or lockfiles for human developers
- *"Meet devs where they're at"* rendered as code

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

# Configuration is a computed value, not static text

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

# The laptop contract is the sandbox contract

<div class="text-center my-12">

```
  Developer Laptop (flake.nix)
             │
             ▼
┌───────────────────────────┐
│   Identical Environment   │
└───────────────────────────┘
             ▲
             │
   Agent Sandbox (flake.nix)
```

</div>

- One environment definition for both human and AI pair programmer
- Zero environment drift between local dev and agent execution

---

# Layer global agent tools over project shells

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

- Global agent capabilities provided by host or outer flake
- Project specifics supplied by repository flake
- Vertical composition without global environment pollution

---

# Share packages directly across repositories

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    cue.url = "github:palekiwi-labs/cue";
  };

  outputs = { self, nixpkgs, cue }: {
    # Consume Rust binary directly in a TypeScript project build
    # No package registry, no release step required
  };
}
```

- Direct cross-repository dependency consumption
- Rust binary (`cue`) consumed in TypeScript plugin (`cue-plugins`)
- Zero release process or registry overhead

---

# Isolation and efficiency share the same mechanism

```
+-------------------------------------------------------------+
|                     Host System / Daemon                    |
|             nix-daemon (owns /nix/store Read-Write)          |
+------------------------------+------------------------------+
                               | Read-Only Mount (/nix)
             +-----------------+-----------------+
             v                                   v
+--------------------------+       +--------------------------+
|  Agent Sandbox 1         |       |  Agent Sandbox 2         |
|  (Debian + mounted /nix) |       |  (Debian + mounted /nix) |
+--------------------------+       +--------------------------+
```

- Sandboxes are lightweight Debian containers mounting `/nix` read-only
- Package reuse across all sandboxes at package granularity
- Zero rebuild time, zero store corruption risk

---

# Don't climb the learning curve. Delegate it.

- LLMs are remarkably effective at writing and repairing Nix flakes
- Scattered, online Nix documentation is well-suited for model synthesis
- **Real-world experience:** ~80% first-pass success rate; agent self-corrects evaluation errors

<div class="mt-8 p-4 bg-gray-800 rounded-lg text-center">

*"Don't climb the learning curve. Delegate it."*

</div>

---

# You must audit the contract, not author it

- Forty lines of `flake.nix` + `flake.lock` is far more auditable than a README + Dockerfile + CI YAML
- `nix develop` evaluates and builds the exact locked inputs
- Boundary 1 (System packages + Ruby) requires nobody's permission to start

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

<p class="text-center text-sm font-semibold">palekiwi</p>

</div>
</div>

<div class="mt-6 p-4 bg-gray-800 rounded-lg text-center font-bold">

*"It worked on my machine. Now it works on every machine -- including this one."*

</div>
