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

        ensureDependencies = ''
          if [ ! -f "node_modules/.bin/slidev" ]; then
            echo "node_modules missing or incomplete. Installing dependencies..."
            ${pkgs.bun}/bin/bun install --frozen-lockfile
          fi
        '';

        present = pkgs.writeShellApplication {
          name = "present";
          runtimeInputs = [ pkgs.bun pkgs.nodejs ];
          text = ''
            ${ensureDependencies}
            exec ${pkgs.bun}/bin/bun run slidev "$@"
          '';
        };

        build-slides = pkgs.writeShellApplication {
          name = "build-slides";
          runtimeInputs = [ pkgs.bun pkgs.nodejs ];
          text = ''
            ${ensureDependencies}
            exec ${pkgs.bun}/bin/bun run slidev build --out dist "$@"
          '';
        };

        export-pdf = pkgs.writeShellApplication {
          name = "export-pdf";
          runtimeInputs = [ pkgs.bun pkgs.nodejs pkgs.chromium ];
          text = ''
            ${ensureDependencies}
            exec ${pkgs.bun}/bin/bun run slidev export --executable-path "${pkgs.chromium}/bin/chromium" "$@"
          '';
        };

        fontsConf = pkgs.makeFontsConf {
          fontDirectories = [
            pkgs.jetbrains-mono
            pkgs.fira-code
            pkgs.nerd-fonts.fira-code
            pkgs.dejavu_fonts
          ];
        };

        record-demo = pkgs.writeShellApplication {
          name = "record-demo";
          runtimeInputs = [ pkgs.vhs pkgs.chromium pkgs.ffmpeg pkgs.bash pkgs.ttyd pkgs.xvfb-run pkgs.fontconfig ];
          text = ''
            export VHS_NO_SANDBOX=1
            export SHELL="${pkgs.bash}/bin/bash"
            export FONTCONFIG_FILE="${fontsConf}"
            if [ $# -eq 0 ]; then
              exec ${pkgs.xvfb-run}/bin/xvfb-run -a ${pkgs.vhs}/bin/vhs demo.tape
            else
              exec ${pkgs.xvfb-run}/bin/xvfb-run -a ${pkgs.vhs}/bin/vhs "$@"
            fi
          '';
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.bun
            pkgs.nodejs
            pkgs.chromium
            pkgs.vhs
            pkgs.ffmpeg
            pkgs.xvfb-run
            pkgs.jetbrains-mono
            pkgs.fira-code
            pkgs.nerd-fonts.fira-code
          ];
          shellHook = ''
            export FONTCONFIG_FILE="${fontsConf}"
          '';
        };

        packages = {
          default = present;
          present = present;
          build = build-slides;
          build-slides = build-slides;
          pdf = export-pdf;
          export-pdf = export-pdf;
          record-demo = record-demo;
        };
      });
}
