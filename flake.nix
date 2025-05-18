{
  description = "New Gear Motors Flake";

  inputs = {
    nixpkgs.url = "github:baileyluTCD/nixpkgs/build-mix-copy-hidden";
    systems.url = "github:nix-systems/default";

    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";
    blueprint.inputs.systems.follows = "systems";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  outputs =
    inputs:
    inputs.blueprint {
      inherit inputs;
      prefix = "nix/";
    };
}
