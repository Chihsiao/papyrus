{ sources ? import ./sources.nix }:

let
  pkgs = import sources.nixpkgs
    { config = {}; overlays = []; };
in

{
  ypp = pkgs.callPackage ./ypp.nix {};
}
