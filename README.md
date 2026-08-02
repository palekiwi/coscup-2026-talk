# COSCUP 2026 Presentation: Nix as the contract between developers and AI agents

Slide deck for the COSCUP 2026 presentation built with [Slidev](https://sli.dev/) and packaged with Nix.

## Quick Start

Run the live presentation server via Nix:

```sh
nix run .#present
```

Or enter the development shell:

```sh
nix develop
bun run dev
```

## Building and Exporting

To generate a static build:

```sh
bun run build
```

The output will be placed in `dist/`.

To export the presentation to PDF via Nix:

```sh
nix run .#pdf
```

This uses Nix's system Chromium binary under the hood to output `slides-export.pdf`.
