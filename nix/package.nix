{
  pkgs,
  flake,
  system,
}:
let
  mixNixDeps = pkgs.callPackages ../deps.nix { };
in
pkgs.beamPackages.mixRelease {
  inherit mixNixDeps;

  pname = "new-gear-motors";
  version = flake.lib.readMixVersion ../mix.exs;

  src = flake;

  removeCookie = false;
  stripDebug = true;

  DATABASE_URL = "";
  SECRET_KEY_BASE = "";

  nativeBuildInputs = [
    flake.packages.${system}.appDependencies
  ];

  postBuild = ''
    bun_path="$(mix do \
      app.config --no-deps-check --no-compile, \
      eval 'Bun.bin_path() |> IO.puts()')"

    ln -sfv ${pkgs.bun}/bin/bun "$bun_path"
    ln -sfv ${mixNixDeps.heroicons} deps/heroicons

    mix do \
      app.config --no-deps-check --no-compile, \
      assets.deploy --no-deps-check
  '';
}
