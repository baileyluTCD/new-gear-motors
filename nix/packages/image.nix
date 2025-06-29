{
  pkgs,
  flake,
  system,
}:
pkgs.dockerTools.buildLayeredImage {
  name = "next_gear_motors_image";
  tag = "latest";

  contents = [ flake.packages.${system}.default ];

  config.Cmd = [
    "next_gear_motors"
    "start"
  ];
}
