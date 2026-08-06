{
  description = "COSCUP Demo Workspace";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      ruby = pkgs.ruby_4_0;
      gems = pkgs.bundlerEnv {
        name = "demo-gems";
        inherit ruby;
        gemdir = ./.;
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          gems
          gems.wrappedRuby
          pkgs.postgresql_16.pg_config
          pkgs.libpq
        ];
      };
    };
}
