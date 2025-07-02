{
  pkgs,
  flake,
  system,
}:
let
  nextGearMotors = flake.packages.${system}.default;

  startupScript = pkgs.writeShellScript "entrypoint" ''
    echo "Starting epmd..."
    ${pkgs.beamMinimalPackages.erlang}/bin/epmd -daemon

    echo "Running migrations..."
    ${nextGearMotors}/bin/next_gear_motors eval "NextGearMotors.Release.migrate"

    echo "Starting app..."
    ${nextGearMotors}/bin/next_gear_motors start
  '';
in
pkgs.dockerTools.buildLayeredImage {
  name = "next_gear_motors_image";
  tag = "latest";

  contents = [
    nextGearMotors
    pkgs.beamMinimalPackages.erlang
    flake.packages.${system}.appDependencies
  ];

  config.Cmd = [
    "${startupScript}"
  ];
}
