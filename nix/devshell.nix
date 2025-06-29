{
  pkgs,
  flake,
  ...
}:
let
  install-deps = pkgs.writeShellApplication {
    name = "install-deps";
    text = ''
      root=$(git rev-parse --show-toplevel)
      cd "$root"

      mix deps.get

      tailwind_path="$(mix eval 'Tailwind.bin_path() |> IO.puts()')"
      ln -sfv ${pkgs.tailwindcss_4}/bin/tailwindcss "$tailwind_path"

      cd ./assets
      npm install
    '';
  };
in
pkgs.mkShell {
  packages = with pkgs; [
    elixir
    nodejs
    watchman
    flyctl
    skopeo
    install-deps
    flake.packages.${system}.appDependencies
    flake.lib.${system}.treefmt.config.build.wrapper
  ];

  LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib/:/run/opengl-driver/lib/";

  shellHook = ''
    sh -c install-deps
  '';
}
