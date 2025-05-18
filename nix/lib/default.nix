{ inputs, flake, ... }:
let
  eachSystem = inputs.nixpkgs.lib.genAttrs (import inputs.systems);
in
eachSystem (
  system:
  let
    pkgs = inputs.nixpkgs.legacyPackages.${system};
  in
  {
    treefmt = inputs.treefmt-nix.lib.evalModule pkgs (
      import ./treefmt-config.nix { inherit flake system; }
    );
  }
)
