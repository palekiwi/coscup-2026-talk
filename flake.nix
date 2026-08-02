{
  description = "COSCUP 2026 talk presentation: Nix as the contract between developers and AI agents";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        present = pkgs.writeShellApplication {
          name = "present";
          runtimeInputs = [ pkgs.bun pkgs.nodejs ];
          text = ''
            exec ${pkgs.bun}/bin/bun run slidev "$@"
          '';
        };

        export-pdf = pkgs.writeShellApplication {
          name = "export-pdf";
          runtimeInputs = [ pkgs.bun pkgs.nodejs pkgs.chromium ];
          text = ''
            exec ${pkgs.bun}/bin/bun run slidev export --executable-path "${pkgs.chromium}/bin/chromium" "$@"
          '';
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.bun
            pkgs.nodejs
            pkgs.chromium
          ];
        };

        packages = {
          default = present;
          present = present;
          pdf = export-pdf;
          export-pdf = export-pdf;
        };
      });
}
