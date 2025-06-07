{ pkgs, flake, inputs, ... }:
pkgs.mkShell {
  packages = with pkgs; [
    elixir
    bun
    watchman
    flake.packages.${system}.appDependencies
    flake.lib.${system}.treefmt.config.build.wrapper
    inputs.bun2nix.packages.${system}.default
  ];

  LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib/:/run/opengl-driver/lib/";

  shellHook = ''
    export FLAKE_ROOT=$(git rev-parse --show-toplevel)
    ln -sfv ${pkgs.bun}/bin/bun $FLAKE_ROOT/_build/bun

    mix deps.get

    bun install --frozen-lockfile --cwd $FLAKE_ROOT/assets
  '';
}
