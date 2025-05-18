{
  pkgs,
  flake,
  system,
  ...
}:
let
  mixNixDeps = pkgs.callPackages ../../deps.nix { };
in
pkgs.beamPackages.mixRelease {
  inherit mixNixDeps;

  pname = "passes-mix-test";
  version = "0.1.0";

  src = flake;

  DATABASE_URL = "";
  SECRET_KEY_BASE = "";

  mixEnv = "test";

  nativeBuildInputs = [
    flake.packages.${system}.appDependencies
    flake.packages.${system}.postgresDev
  ];

  doCheck = true;
  checkPhase = ''
    postgres-dev &

    until pg_isready -h /tmp ; do sleep 1 ; done

    export HOME=$TMPDIR

    mix do \
      app.config --no-deps-check --no-compile, \
      credo, \
      sobelow, \
      deps.audit, \
      test --no-deps-check
  '';
}
