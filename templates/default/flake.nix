{
  description = "A Nix Flake template for `papyrus`.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    papyrus = {
      url = "github:Chihsiao/papyrus/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      papyrus,
    }:
    let
      allSystems = [
        "x86_64-linux"
      ];

      forAllSystems =
        f:
        nixpkgs.lib.genAttrs allSystems (
          system:
          f {
            pkgs = nixpkgs.legacyPackages.${system};
          }
        );
    in
    {
      devShells = forAllSystems (
        { pkgs }:
        {
          default = pkgs.mkShellNoCC {
            packages = [
              pkgs.bashInteractive
              papyrus.outputs.packages.${pkgs.system}.papyrus
            ];
          };
        }
      );
    };
}
