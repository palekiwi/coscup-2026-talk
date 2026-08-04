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
- Polyglot programmer (Nix, Rust, Haskell, TS, Lua, Nushell, ...)
- Red Hat Certified Engineer (configuration as code, Ansible)
- Creator of AI tooling (sandboxes, memory/context management, observability)
- Obsessive tinkerer and explorer

</div>
<div>

<img src="/mobility-android-based-rails.jpg" class="rounded-lg shadow-md max-h-70 mx-auto" alt="Rails on Android Tablet (2017)" />

<p class="text-xs text-center text-gray-400 mt-2">Taipei Ruby Meetup, 2017: Rails running on Android tablet</p>

</div>
</div>

---

# Why this talk? Why now?

- **The Shopify Anecdote:**
  - **Era 1 (2019):** Introduced Nix across ~1,000 macOS laptops to replace Homebrew
  - **Gap (2020-2023):** Shifted away to cloud development environments
  - **Era 2 (2024-present):** Returned to local Nix development with incremental opt-in
- AI coding agents require predictable, reproducible runtime environments
- Nix makes agents more effective, and agents make Nix more accessible

<div class="mt-6 p-4 bg-gray-800 rounded-lg text-center">

**Key takeaway:**  *Meet devs where they're at, migrate incrementally, allow opting-in*

</div>
---

# Three questions for the room

<v-clicks>

1. **Who uses an AI coding tool every day?**

2. **Who has seen a `flake.nix` in a repository?**

3. **Who has tried Nix, hit an error, and given up?**

</v-clicks>

---

# A few words about security


<div class="grid grid-cols-2 gap-4">
<div>

**Off-the sandboxes:**

- bubblewrap / seatbelt
- containers (docker/podman)
- gVisor
- firecracker (microVMs)
- KVM
- dedicated hardware

</div>
<div>

**Aspects of isolation:**

- filesystem
- processes
- system kernel
- user namespace
- envirnoment variables
- networking
- hardware resources (constraints)

</div>
</div>
---

# Agents need real environments, not just code

- Agents run tests, linters, LSPs, QA suites, and native builds
- High execution speed means higher rate of environment interaction
- Agents must operate inside isolated sandboxes to execute code safely
- **The concrete harm scenario:**

<div class="mt-6 p-4 bg-gray-800 rounded-lg text-center">

*"The agent wrote the code, could not run the test suite because the box
lacked the system library.
<br>
Declared success anyway, and you merged it."*

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
|  |  (Ruby 4.0.6, libpq, libvips, Node, Elm toolchain)    |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+
```

- An empty container is safe, but lacks runtimes, system libraries and developer tools
- Nix fills the sandbox deterministically, and runs identically in each environment
- **Talk's Scope:** Development environment only, pair-programming with AI

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
- Ruby 4.0.6 (via rbenv, asdf, or mise)
- PostgreSQL 16 client C-libraries (libpq-dev)
- ImageMagick / libvips
- Node.js 26 & pnpm 11
- Elm 0.19.1 & elm-format
```

- Written in prose, enforced by hope
- Language version managers cover runtimes, not system libraries or tools
- Agents fails or install conflicting versions without isolation

<div class="mt-6 p-4 bg-gray-800 rounded-lg text-center">

Your README promises an environment. Nix keeps the promise.

</div>

---

# Example 1: A Ruby Shop

```
+------------------+  +------------------+  +------------------+
| storefront       |  | checkout-api     |  | identity         |
| Ruby 4.0.6       |  | Ruby 3.3.6       |  | Ruby 4.0.2       |
| TS / Elm         |  | Sinatra          |  | Rails 8.0        |
+------------------+  +------------------+  +------------------+
+------------------+  +------------------+  +------------------+
| notifications    |  | admin-ui         |  | legacy-crm       |
| Go 1.23 / Redis  |  | Node 26 / Vue 3  |  | Ruby 1.8.7       |
|                  |  | React            |  | Java, Go         |
+------------------+  +------------------+  +------------------+
```

<div class="mt-6 p-4 bg-gray-800 rounded-lg text-center">

4 Ruby versions, 5 languages, 1 container

</div>

---

# A flake as everyone's entrypoint

- When a repository contains a `flake.nix`, the agent enters with `nix develop`
- No manual environment installation steps
- No global version manager shims
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

# Community flakes supply specialized package overlays

```nix {all|4-10|16-21|all}
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

---

# The complete production flake brings every piece together

<div class="h-[360px] overflow-y-auto text-xs font-mono rounded border border-gray-700 my-2">

```nix
{
  description = "Some Ruby Project";

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

# Example 2: An opensource AI tooling ecosystem

```
+------------------+  +------------------+  +------------------+
| cast             |  | cue              |  | cue-plugins      |
|                  |  |                  |  |                  |
| Rust, Nix        |  | Rust, TS         |  | TS, Bun          |
+------------------+  +------------------+  +------------------+
+------------------+  +------------------+  +------------------+
| cue.nvim         |  | agent harnesses  |  | OSS tooling      |
|                  |  |                  |  |                  |
| Lua              |  | TS, Rust, Go     |  | ???              |
+------------------+  +------------------+  +------------------+
```

<div class="mt-6 p-4 bg-gray-800 rounded-lg text-center">

Real workspace composition across Rust, TypeScript, Lua, and Nix
<br/>
Nix manages builds, cross-repo tool availability and distribution

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
|  |  (Ruby 4.0.6, libpq, libvips, nodejs)           |  |
|  +-------------------------------------------------+  |
+-------------------------------------------------------+
```

---

# Seamless package distribution across repositories

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Optionally pin to explicit Git brranch
    cast.url = "github:palekiwi-labs/cast/master";
    # Optionally pin to explicit Git commit
    cue.url = "github:palekiwi-labs/cue/2b25028b6cdcb4ff1a8d8dbb1624276fb2656a8d";
  };

  outputs = { self, nixpkgs, cast, cue }: {
    # Consume binaries directly in project environments
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
- No need to rebuild or fetch dependencies again

---

# The learning curve is still there but...

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
