{ pkgs, flake }:
pkgs.mkShell {
  packages = with pkgs; [
    elixir
    flake.packages.${system}.appDependencies
    flake.lib.${system}.treefmt.config.build.wrapper
  ];

  shellHook = ''
    mix deps.get
  '';
}
