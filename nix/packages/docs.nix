{
  pkgs,
  flake,
  system,
}:
let
  mixNixDeps = pkgs.callPackages ../../deps.nix { };
in
pkgs.beamPackages.mixRelease {
  inherit mixNixDeps;

  pname = "docs";
  version = flake.lib.readMixVersion ../../mix.exs;

  src = flake;

  removeCookie = false;
  stripDebug = true;

  DATABASE_URL = "";
  SECRET_KEY_BASE = "";

  nativeBuildInputs = [
    flake.packages.${system}.appDependencies
  ];

  buildPhase = ''
    mix do \
      app.config --no-deps-check --no-compile, \
      docs --warnings-as-errors
  '';

  installPhase = ''
    mkdir -p $out/lib/doc

    cp -r ./doc/. $out/lib/doc
  '';
}
