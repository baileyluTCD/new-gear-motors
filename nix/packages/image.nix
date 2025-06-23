{
  pkgs,
  flake,
  system,
}:
pkgs.dockerTools.buildLayeredImage {
  name = "next_gear_motors_image";
  config.Cmd = [ "${flake.packages.${system}.default}/bin/next_gear_motors" ];
}
