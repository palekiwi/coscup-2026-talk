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

- Professional **Rubyist**
- **Polyglot** programmer (Nix, Rust, Haskell, TS, Lua, Nushell, ...)
- Red Hat Certified **Engineer** (configuration as code, Ansible)
- **Creator** of AI tooling (sandboxes, memory/context management, observability)
- Obsessive tinkerer and **explorer**

</div>
<div>

<img src="/mobility-android-based-rails.jpg" class="rounded-lg shadow-md max-h-70 mx-auto" alt="Rails on Android Tablet (2017)" />

<p class="text-xs text-center text-gray-400 mt-2">Taipei Ruby Meetup, 2017: Rails running on Android tablet</p>

</div>
</div>

---

# Agenda

1. **Why this? Why now?** — AI pair programmers and runtime requirements
2. **The problem you don't realize you have** — Unenforced READMEs and empty sandboxes
3. **The promise Nix keeps** — Deterministic development environments
4. **Case Study 1: Nix Deep Dive for Rubyists** — Flakes, syntax, and Ruby setups
5. **Case Study 2: Open Source with Nix** — Ecosystem composition and distribution
6. **Next steps** — Delegate the learning curve and start today

---

# Why this talk? Why now?

- **Shopify is going all-in on Nix:**
  - Standardized local development across thousands of engineers
  - Spoke with Shopify platform engineers at RubyKaigi
  - Key takeaway: *Meet devs where they're at, migrate incrementally, allow opting-in*
- **AI coding agents need deterministic runtimes:**
  - Agents can only be as good as the environment you give them
  - Nix makes agents effective, agents make Nix accessible

<div class="mt-6 p-4 bg-gray-800 rounded-lg text-center">

*Nix provides the contract between developers and AI agents.*

</div>

---

# Three questions for the room

<v-clicks>

1. **Who uses an AI coding tool every day?**

2. **Who has seen a `flake.nix` in a repository?**

3. **Who has tried Nix, hit an error, and given up?**

</v-clicks>

---

# Your README is a contract nobody enforces

```markdown
## Prerequisites
- Ruby 3.3.6 (via rbenv, asdf, or mise)
- PostgreSQL 16 client C-libraries (libpq-dev)
- ImageMagick / libvips
- Node.js 22 & pnpm 10
- Elm 0.19.1 & elm-format
```

- Written in prose, enforced by hope
- Version managers cover language runtimes, not C-libraries or system tools
- Developers waste hours debugging setup drift; AI agents fail silently or break system packages

<div class="mt-6 p-4 bg-gray-800 rounded-lg text-center">

Your README promises an environment. Nix keeps the promise.

</div>

---

# Agents need real environments, not just code

- Agents run tests, linters, LSPs, QA suites, and native builds
- High execution speed means higher rate of environment interaction
- Agents must operate inside isolated sandboxes to execute code safely
- **The concrete harm scenario:** *Is your agent lying to you?!*

<div class="mt-6 p-4 bg-gray-800 rounded-lg text-center">

"Agent couldn't inspect **vendor code**, so it guessed the **API**.
<br>
It couldn't run the **tests**, so it guessed the **outcome**.
<br>
<br>
Confidently declared green — and you merged it."

</div>

---

# A sandbox starts empty. Nix fills it.

```
+-------------------------------------------------------------+
|                      Developer Machine                      |
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

- **Containers isolate processes, but fill boxes poorly:** package availability, rebuilds, caching granularity
- Nix fills the sandbox deterministically and runs identically on human laptops

<div class="mt-6 p-4 bg-gray-800 rounded-lg text-center">

Composition, not competition: Nix composes with containers; it does not replace them.

</div>

---

# **Case Study 1:** A Ruby Shop

```
+------------------+  +------------------+  +------------------+
| storefront       |  | checkout-api     |  | identity         |
|                  |  |                  |  |                  |
| Ruby 3.3.6       |  | Ruby 3.3.4       |  | Ruby 4.0.2       |
| TS / Elm         |  | Sinatra          |  | Rails 8.0        |
+------------------+  +------------------+  +------------------+
+------------------+  +------------------+  +------------------+
| notifications    |  | admin-ui         |  | legacy-crm       |
|                  |  |                  |  |                  |
| Go 1.23 / Redis  |  | Node 22 / Vue 3  |  | Ruby 1.8.7       |
|                  |  | React            |  | Java, Go         |
+------------------+  +------------------+  +------------------+
```

<div class="mt-6 mb-6 p-4 bg-gray-800 rounded-lg text-center">

4 Ruby versions, 5 languages, 1 container

</div>

- When a repo contains `flake.nix`, anyone (or any agent) enters via `nix develop`
- No manual environment installation, no global version manager shims

---

# Nix is a purely functional language

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

# Interactive Quiz: Can you read a flake?

<div class="grid grid-cols-5 gap-6 items-center mt-4">
<div class="col-span-3 text-xs">

```nix {all|1,19|2-5,7|7|2-5,7|all}
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.ruby_3_3
            pkgs.libpq
          ];
        };
      });
}
```

</div>
<div class="col-span-2 text-base">

1. What are the outermost `{ ... }`?

2. What are `inputs` and `outputs`?

3. What is the type of `outputs`?

4. How do `inputs` and `outputs` relate?

</div>
</div>

---

# Hermetic Environment: Why Nix manages the full stack for agents

<div class="p-6 bg-gray-800 rounded-lg">

### The Hermetic Approach for AI Agents:
- Nix manages C-libraries, Ruby runtime **and** gems via `bundlerEnv` / `bundix`
- Everything stored in `/nix/store` — immutable, locked, and fully reproducible
- Eliminates imperatively mutated `vendor/bundle` or local gem states
- Ideal for AI agents: agents don't have human habits and thrive on strict contracts

</div>

<div class="mt-6 p-4 bg-gray-900 border border-gray-700 rounded text-center">

**Hermetic & Immutable:** Nix locks everything your gems assume, giving agents a 100% deterministic sandbox.

</div>

---

# Community flakes supply specialized package overlays

```nix {all|4-10|13-15|16-21|all}
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-ruby = {
      url = "github:bobvanderlinden/nixpkgs-ruby";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ inputs.nixpkgs-ruby.overlays.default ];
        };
      in { ... });
}
```

- `follows` pins community flake dependencies to your main `nixpkgs` revision
- Overlays extend `pkgs` directly without modifying upstream nixpkgs
- Specialized runtimes (`nixpkgs-ruby`) remain fully auditable and locked

---

# Nix files compute configuration from local files

```nix {all|1-2|4-7|all}
# Read local team file dynamically
rubyVersion = pkgs.lib.fileContents ./.ruby-version;

# Customize runtime compilation parameters
ruby = (pkgs."ruby-${rubyVersion}").override {
  yjitSupport = false;
};
```

- Meets developers where they are at by reading `.ruby-version` programmatically
- Packages are functions — `.override` customizes build flags deterministically
- Computed at evaluation time without global version manager shims

<div class="mt-6 p-4 bg-gray-800 rounded-lg text-center">

Configuration is a computed value, not a static file — and it remains 100% declarative.

</div>

---

# wrappedRuby and shell hooks build polyglot environments

```nix {all|1-6|10-12|15-17|all}
gems = pkgs.bundlerEnv {
  ruby = ruby;
  gemfile = ./Gemfile;
  lockfile = ./Gemfile.lock;
  gemset = ./gemset.nix;
};

devShells.default = pkgs.mkShell {
  buildInputs = with pkgs; [
    gems
    gems.wrappedRuby
    nodejs_26
  ];
  shellHook = ''
    echo "Ruby: $(ruby -v)" >&2
  '';
};
```

- `wrappedRuby` bakes `GEM_HOME`/`GEM_PATH` into wrappers, eliminating `bundle exec`
- `bundlerEnv` pins all gems into `/nix/store` for total immutability

---

# The complete production flake brings every piece together

<div class="h-[360px] overflow-y-auto text-xs font-mono rounded border border-gray-700 my-2">

```nix
{
  description = "Production Hermetic Ruby Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-ruby = {
      url = "github:bobvanderlinden/nixpkgs-ruby";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            inputs.nixpkgs-ruby.overlays.default
          ];
        };

        rubyVersion = pkgs.lib.fileContents ./.ruby-version;
        ruby = (pkgs."ruby-${rubyVersion}").override {
          yjitSupport = false;
        };

        gems = pkgs.bundlerEnv {
          ruby = ruby;
          gemfile = ./Gemfile;
          lockfile = ./Gemfile.lock;
          gemset = ./gemset.nix;
        };

      in
      {
        devShells = {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              gems
              gems.wrappedRuby

              nodejs_26
              typescript
            ];

            shellHook = ''
              echo "Ruby: $(ruby -v)" >&2
            '';
          };
        };
      }
    );
}
```

</div>

---

# **Case Study 2:** Your OpenSource AI ecosystem

```
+------------------+  +------------------+  +------------------+
| cast             |  | cue              |  | cue-plugins      |
| (sandbox)        |  | (memory/context) |  | (agent UX)       |
|                  |  |                  |  |                  |
| Rust, Nix        |  | Rust, TS         |  | TS, Bun          |
+------------------+  +------------------+  +------------------+
+------------------+  +------------------+  +------------------+
| cue.nvim         |  | agent harnesses  |  | OSS tooling      |
| (human UX)       |  | (cc, pi, oc,...) |  | (RAG, mux,...)   |
|                  |  |                  |  |                  |
| Lua              |  | TS, Rust, Go     |  | ???              |
+------------------+  +------------------+  +------------------+
```

<div class="mt-6 p-4 bg-gray-800 rounded-lg text-center">

Real workspace composition across Rust, TypeScript, Lua, and Nix
<br/>
Nix manages builds, cross-repo tool availability, and distribution

</div>

---

# Vertical composition: Nesting development shells

```bash
# Outer shell: Global AI agent tools provided by host
$ nix develop ~/.config/cast/nix
(global-env) $

# Inner shell: Project specific environment
(cast-opencode) $ nix develop
(project-env) $ bundle exec rubocop
```

```
+-------------------------------------------------------+
|  Global Agent Harness Shell (llm-agents flake)        |
|  (opencode, pi, cue, ast-grep, gh)                    |
|  +-------------------------------------------------+  |
|  |  Project Development Shell (flake.nix)          |  |
|  |  (Ruby 3.3.6, libpq, libvips, nodejs)           |  |
|  +-------------------------------------------------+  |
+-------------------------------------------------------+
```

<div class="mt-6 p-4 bg-gray-800 rounded-lg text-center">

Your project shell defines the app. Your global shell defines the agent.

</div>

---

# Seamless package distribution across repositories

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    cast.url = "github:palekiwi-labs/cast/master";
    cue.url = "github:palekiwi-labs/cue/2b25028b6cdcb4ff1a8d8dbb1624276fb2656a8d";
  };

  outputs = { self, nixpkgs, cast }: {
    # Consume binaries directly in project environments
  };
}
```

- Direct cross-repository dependency consumption without central registries
- Pinning via Git revisions or local filesystem sources

<div class="mt-6 p-4 bg-gray-800 rounded-lg text-center">

No package registry. No release pipeline. Just a Git URL and a lockfile.

</div>

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
- Package reuse across all sandboxes at package granularity (no duplication)

<div class="mt-6 p-4 bg-gray-800 rounded-lg text-center">

Don't rebuild. It is already there.

</div>

---

# Delegate the learning curve & Start today

<div class="grid grid-cols-2 gap-4">
<div class="p-4 bg-gray-800 rounded-lg">

### Why you don't need to fear Nix:
- LLMs are remarkably effective at writing and repairing Nix flakes
- Scattered documentation is ideal for model synthesis
- Agents handle syntax; developers audit the contract

</div>
<div class="p-4 bg-gray-800 rounded-lg">

### Your action plan:
1. **Install Nix:** Determinate installer or devcontainer
2. **Add `flake.nix`:** Target Hermetic environment for AI agents
3. **Let agent prove it:** Agent verifies inside sandbox
4. **Opt-in:** Human developers switch when ready

</div>
</div>

<div class="mt-6 p-4 bg-gray-900 border border-gray-700 rounded text-center font-bold">

*"Don't climb the learning curve. Delegate it."*
<br/>
*"Start at the first boundary. One file, one repo, nobody's permission."*

</div>

---

# Worked on my machine, works on every machine.

<div class="grid grid-cols-2 gap-4">
<div>

- **Presentation & Deck:** `github.com/palekiwi/coscup-2026-talk`
- **Workspace:** `github.com/palekiwi/palekiwi`
- **Open Source:** `github.com/palekiwi-labs`
- **Contact:** `contact@palekiwi.com`

</div>
<div>

<img src="/palekiwi-avatar.jpg" class="rounded-2 w-40 h-40 mx-auto shadow-lg mb-4" alt="palekiwi" />

<p class="text-center text-sm font-semibold">Pawel Lisewski (@palekiwi)</p>

</div>
</div>
