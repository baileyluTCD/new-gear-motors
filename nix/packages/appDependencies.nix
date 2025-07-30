{ pkgs }:
pkgs.symlinkJoin {
  name = "appDependencies";
  paths = with pkgs; [
    postgresql
    inotifyTools
    graphicsmagick
  ];
}
