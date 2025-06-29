{
  pkgs,
  flake,
  system,
}:
let
  mixNixDeps = pkgs.callPackages (flake + "/deps.nix") { };
in
pkgs.beamPackages.mixRelease rec {
  inherit mixNixDeps;

  pname = "next_gear_motors";
  version = flake.lib.readMixVersion (flake + "/mix.exs");

  src = flake;

  removeCookie = false;
  stripDebug = true;

  DATABASE_URL = "";
  SECRET_KEY_BASE = "";

  nativeBuildInputs = with pkgs; [
    flake.packages.${system}.appDependencies
    nodejs
    npmHooks.npmConfigHook
  ];

  npmDeps = pkgs.fetchNpmDeps {
    inherit version;

    pname = "${pname}-npm-deps";
    src = (flake + "/assets");
    hash = "sha256-nraoH7P/9t30QyIVXFWnGPy7owAm0Xy8YlmUfWdxDrk=";
  };

  npmRoot = "./assets";
  makeCacheWritable = true;

  postBuild = ''
    tailwind_path="$(mix do \
      app.config --no-deps-check --no-compile, \
      eval 'Tailwind.bin_path() |> IO.puts()')"
    esbuild_path="$(mix do \
      app.config --no-deps-check --no-compile, \
      eval 'Esbuild.bin_path() |> IO.puts()')"

    ln -sfv ${pkgs.tailwindcss_4}/bin/tailwindcss "$tailwind_path"
    ln -sfv ${pkgs.esbuild}/bin/esbuild "$esbuild_path"
    ln -sfv ${mixNixDeps.heroicons} deps/heroicons

    mix do \
      app.config --no-deps-check --no-compile, \
      assets.deploy --no-deps-check
  '';
}
