{ flake, system, ... }:
{
  projectRootFile = "flake.nix";

  programs.deadnix.enable = true;
  programs.nixfmt.enable = true;

  programs.shfmt.enable = true;

  programs.prettier.enable = true;

  settings.formatter.mix-fmt = {
    command = "${flake.packages.${system}.mixFmt}/bin/mix-fmt";
    includes = [
      "*.ex"
      "*.exs"
      "*.heex"
    ];
  };
}
