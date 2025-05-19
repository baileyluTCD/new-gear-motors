{ inputs, flake, ... }:
let
  eachSystem = inputs.nixpkgs.lib.genAttrs (import inputs.systems);
  lib = inputs.nixpkgs.lib;
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
// {
  readMixVersion =
    mixExs:
    let
      text = builtins.readFile mixExs;
      matches = builtins.match ''^.*version: "(.*)".*$'' text;
    in
    assert lib.assertMsg (matches != null) "No match could be found for mix.exs version field";
    builtins.head matches;
}
