{
  description = "COSCUP 2026 talk presentation: Nix as the contract between developers and AI agents";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
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

        build = pkgs.writeShellApplication {
          name = "build";
          runtimeInputs = [ pkgs.bun pkgs.nodejs ];
          text = ''
            exec ${pkgs.bun}/bin/bun run slidev build "$@"
          '';
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.bun
            pkgs.nodejs
          ];
        };

        packages = {
          default = present;
          present = present;
          build = build;
        };

        apps = {
          default = flake-utils.lib.mkApp { drv = present; };
          present = flake-utils.lib.mkApp { drv = present; };
          build = flake-utils.lib.mkApp { drv = build; };
        };
      });
}
