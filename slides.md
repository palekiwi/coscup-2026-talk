---
theme: default
colorSchema: dark
highlighter: shiki
lineNumbers: true
drawings:
  persist: false
transition: slide-left
title: "Nix as the contract between developers and AI agents"
info: |
  COSCUP 2026 Talk Presentation
  Nix as the contract between developers and AI agents
---

# Nix as the contract between developers and AI agents

COSCUP 2026 - Ruby Track

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

- Developer and agent share the exact same environment contract
- Declarative dependencies defined once in `flake.nix`
- Zero drift between local development and sandbox execution

---

# Your README is a contract nobody enforces.

```markdown
## Prerequisites
- Ruby 3.3.6 (via rbenv or asdf)
- PostgreSQL 16 client libraries (libpq-dev)
- ImageMagick / libvips
- Node.js 20 & pnpm 9
- Elm 0.19.1 & elm-format
```

- Written in prose and enforced by hope
- Language version managers cover the runtime, not system libraries
- Agents misread or install conflicting versions without isolation

---

# Nix makes system dependencies explicit and locked.

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";
  };

  outputs = { self, nixpkgs, nixpkgs-ruby }: {
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      packages = [
        nixpkgs-ruby.packages.x86_64-linux."ruby-3.3.6"
        nixpkgs.legacyPackages.x86_64-linux.libpq
        nixpkgs.legacyPackages.x86_64-linux.libvips
        nixpkgs.legacyPackages.x86_64-linux.elmPackages.elm
      ];
    };
  };
}
```

- Complete environment in 20 lines
- Single lockfile (`flake.lock`) pins all transitive inputs
- Agent or human enters shell with one command: `nix develop`
