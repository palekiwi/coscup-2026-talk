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

        rubyVersion = pkgs.lib.fileContents ../../.ruby-version;
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
          };
        };
      }
    );
}
