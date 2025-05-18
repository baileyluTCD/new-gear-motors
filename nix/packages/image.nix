{
  pkgs,
  flake,
  system,
}:
pkgs.dockerTools.buildLayeredImage {
  name = "nix_phoenix_template_image";
  config.Cmd = [ "${flake.packages.${system}.default}/bin/new-gear-motors" ];
}
