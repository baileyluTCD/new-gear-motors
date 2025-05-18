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
  version = "0.1.0";

  src = flake;

  removeCookie = false;
  stripDebug = true;

  DATABASE_URL = "";
  SECRET_KEY_BASE = "";

  nativeBuildInputs = [
    flake.packages.${system}.appDependencies
  ];

  postBuild = ''
    tailwind_path="$(mix do \
      app.config --no-deps-check --no-compile, \
      eval 'Tailwind.bin_path() |> IO.puts()')"
    esbuild_path="$(mix do \
      app.config --no-deps-check --no-compile, \
      eval 'Esbuild.bin_path() |> IO.puts()')"

    ln -sfv ${pkgs.tailwindcss}/bin/tailwindcss "$tailwind_path"
    ln -sfv ${pkgs.esbuild}/bin/esbuild "$esbuild_path"
    ln -sfv ${mixNixDeps.heroicons} deps/heroicons

    mix do \
      app.config --no-deps-check --no-compile, \
      assets.deploy --no-deps-check
  '';
}
