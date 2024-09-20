{ sources ? import ./nix/sources.nix }:

let
  pkgs = import sources.nixpkgs
    { config = {}; overlays = []; };

  utils = {
    ypp = pkgs.callPackage ./nix/ypp.nix {};
  };
in

pkgs.mkShellNoCC rec {
  packages = (with pkgs; [ mermaid-cli
    pandoc haskellPackages.pandoc-crossref
  ]) ++ (with utils; [
    ypp
  ]);
}
